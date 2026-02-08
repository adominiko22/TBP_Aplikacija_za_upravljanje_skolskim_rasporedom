import os
import logging
import re
from functools import wraps
from datetime import timedelta, datetime

from dotenv import load_dotenv
from flask import Flask, render_template, request, redirect, url_for, session, flash
from psycopg import errors

from app.db import fetch_all, fetch_one, execute

load_dotenv()


def create_app():
    app = Flask(__name__)
    app.secret_key = os.getenv("SECRET_KEY", "dev-secret")

    app.permanent_session_lifetime = timedelta(minutes=1)
    app.config.update(
        SESSION_COOKIE_HTTPONLY=True,
        SESSION_COOKIE_SAMESITE="Lax",
    )

    ADMIN_PIN = os.getenv("ADMIN_PIN", "1234")

    logging.basicConfig(level=logging.INFO)

    def require_admin(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            if not session.get("is_admin"):
                return redirect(url_for("admin_login"))
            return f(*args, **kwargs)
        return wrapper

    @app.before_request
    def admin_session_timeout():
        if session.get("is_admin"):
            last_activity = session.get("last_activity")
            if last_activity:
                try:
                    last_activity_dt = datetime.fromisoformat(last_activity)
                except ValueError:
                    session.clear()
                    flash("Sesija je istekla.", "info")
                    return redirect(url_for("admin_login"))

                if datetime.utcnow() - last_activity_dt > timedelta(minutes=1):
                    session.clear()
                    flash("Sesija je istekla zbog neaktivnosti.", "info")
                    return redirect(url_for("admin_login"))

            session["last_activity"] = datetime.utcnow().isoformat()

    def clean_db_message(e: Exception) -> str:
        msg = ""
        diag = getattr(e, "diag", None)
        if diag and getattr(diag, "message_primary", None):
            msg = (diag.message_primary or "").strip()
        else:
            msg = str(e).strip()

        msg = msg.split("CONTEXT:", 1)[0].strip()

        if msg.lower().startswith("konflikt:"):
            msg = msg.split(":", 1)[1].strip()

        if "nije dopušten po kurikulumu" in msg.lower():
            msg = re.sub(r"\s*\(.*\)\s*$", "", msg).strip()
            return "Odabrani predmet nije dopušten za smjer/kurikulum ovog razreda."

        msg = re.sub(r"\s*\(.*\)\s*$", "", msg).strip()

        if not msg:
            msg = "Došlo je do pogreške."

        return msg

    @app.get("/")
    def index():
        classes = fetch_all("""
            SELECT id, school_year, grade_level, label
            FROM school.school_class
            WHERE is_active = TRUE
            ORDER BY school_year DESC, grade_level, label;
        """)

        rows = fetch_all("""
            SELECT DISTINCT
                subject_name,
                teacher_id,
                teacher_name
            FROM school.v_current_schedule
            ORDER BY subject_name, teacher_name;
        """)

        subjects_with_teachers = {}
        for r in rows:
            subjects_with_teachers.setdefault(r["subject_name"], []).append({
                "id": r["teacher_id"],
                "name": r["teacher_name"],
            })

        return render_template(
            "index.html",
            classes=classes,
            subjects_with_teachers=subjects_with_teachers
        )

    @app.get("/class/<int:class_id>")
    def view_class(class_id: int):
        cls = fetch_one("""
            SELECT sc.id, sc.school_year, sc.grade_level, sc.label, pt.name AS track
            FROM school.school_class sc
            JOIN school.program_track pt ON pt.id = sc.track_id
            WHERE sc.id = %s;
        """, (class_id,))
        if not cls:
            return "Razred ne postoji", 404

        rows = fetch_all("""
            SELECT day_of_week, lesson_no, subject_code, teacher_name, classroom_code
            FROM school.v_current_schedule_by_class
            WHERE class_id = %s
            ORDER BY day_of_week, lesson_no;
        """, (class_id,))

        grid = {(r["day_of_week"], r["lesson_no"]): r for r in rows}
        return render_template("class.html", cls=cls, grid=grid)

    @app.get("/teacher/<int:teacher_id>")
    def view_teacher(teacher_id: int):
        teacher = fetch_one(
            "SELECT id, full_name FROM school.teacher WHERE id=%s;",
            (teacher_id,)
        )
        if not teacher:
            return "Profesor ne postoji", 404

        rows = fetch_all("""
            SELECT day_of_week, lesson_no, subject_code, classroom_code,
                   grade_level, class_label
            FROM school.v_current_schedule_by_teacher
            WHERE teacher_id = %s
            ORDER BY day_of_week, lesson_no, grade_level, class_label;
        """, (teacher_id,))

        grid = {}
        for r in rows:
            grid.setdefault((r["day_of_week"], r["lesson_no"]), []).append(r)

        return render_template("teacher.html", teacher=teacher, grid=grid)

    @app.get("/admin")
    def admin_login():
        return render_template("admin_login.html")

    @app.post("/admin")
    def admin_login_post():
        if request.form.get("pin") == ADMIN_PIN:
            session["is_admin"] = True
            session.permanent = True
            session["last_activity"] = datetime.utcnow().isoformat()

            flash("Uspješno ste prijavljeni.", "success")
            return redirect(url_for("admin_panel"))

        flash("Neispravan PIN.", "error")
        return redirect(url_for("admin_login"))

    @app.get("/admin/logout")
    def admin_logout():
        session.clear()
        flash("Odjavljeni ste.", "info")
        return redirect(url_for("index"))

    @app.get("/admin/panel")
    @require_admin
    def admin_panel():
        classes = fetch_all("""
            SELECT id, school_year, grade_level, label
            FROM school.school_class
            WHERE is_active = TRUE
            ORDER BY school_year DESC, grade_level, label;
        """)
        subjects = fetch_all(
            "SELECT id, code, name FROM school.subject WHERE is_active=TRUE ORDER BY code;"
        )
        teachers = fetch_all(
            "SELECT id, full_name FROM school.teacher WHERE is_active=TRUE ORDER BY full_name;"
        )
        classrooms = fetch_all(
            "SELECT id, code FROM school.classroom WHERE is_active=TRUE ORDER BY code;"
        )

        return render_template(
            "admin_panel.html",
            classes=classes,
            subjects=subjects,
            teachers=teachers,
            classrooms=classrooms,
        )

    @app.post("/admin/upsert")
    @require_admin
    def admin_upsert():
        class_id = int(request.form["class_id"])
        day = int(request.form["day_of_week"])
        lesson = int(request.form["lesson_no"])
        subject_id = int(request.form["subject_id"])
        teacher_id = int(request.form["teacher_id"])
        classroom_id = int(request.form["classroom_id"])

        ts = fetch_one("""
            SELECT id
            FROM school.time_slot
            WHERE day_of_week=%s AND lesson_no=%s;
        """, (day, lesson))

        if not ts:
            flash("Odabrani dan i sat ne postoje u sustavu.", "error")
            return redirect(url_for("admin_panel"))

        try:
            execute("""
                WITH ins_ev AS (
                    INSERT INTO school.scheduled_event (class_id, time_slot_id, created_by)
                    VALUES (%s, %s, %s)
                    RETURNING id
                )
                INSERT INTO school.schedule_entry
                    (event_id, subject_id, teacher_id, classroom_id)
                SELECT id, %s, %s, %s
                FROM ins_ev;
            """, (
                class_id,
                ts["id"],
                "admin",
                subject_id,
                teacher_id,
                classroom_id,
            ))
        except errors.RaiseException as e:
            app.logger.exception("RAISE pri upisu")
            flash(clean_db_message(e), "error")
            return redirect(url_for("admin_panel"))
        except errors.UniqueViolation:
            app.logger.exception("Unique violation pri upisu")
            flash("Taj termin je već zauzet u rasporedu.", "error")
            return redirect(url_for("admin_panel"))
        except errors.ForeignKeyViolation:
            app.logger.exception("Foreign key violation pri upisu")
            flash("Odabrani predmet, profesor ili učionica nisu valjani.", "error")
            return redirect(url_for("admin_panel"))
        except Exception:
            app.logger.exception("Nepoznata greška pri upisu")
            flash("Došlo je do pogreške pri spremanju promjene.", "error")
            return redirect(url_for("admin_panel"))

        flash("Promjena je uspješno spremljena.", "success")
        return redirect(url_for("view_class", class_id=class_id))

    @app.post("/admin/delete")
    @require_admin
    def admin_delete():
        class_id = int(request.form["class_id"])
        day = int(request.form["day_of_week"])
        lesson = int(request.form["lesson_no"])

        ts = fetch_one("""
            SELECT id
            FROM school.time_slot
            WHERE day_of_week=%s AND lesson_no=%s;
        """, (day, lesson))

        if not ts:
            flash("Odabrani dan i sat ne postoje u sustavu.", "error")
            return redirect(url_for("admin_panel"))

        try:
            execute("""
                UPDATE school.scheduled_event
                   SET valid_to = now()
                 WHERE class_id = %s
                   AND time_slot_id = %s
                   AND valid_to IS NULL;
            """, (class_id, ts["id"]))
        except errors.RaiseException as e:
            app.logger.exception("RAISE pri brisanju")
            flash(clean_db_message(e), "error")
            return redirect(url_for("admin_panel"))
        except Exception:
            app.logger.exception("Greška pri brisanju sata")
            flash("Došlo je do pogreške pri uklanjanju sata.", "error")
            return redirect(url_for("admin_panel"))

        flash("Sat je uspješno uklonjen iz rasporeda.", "success")
        return redirect(url_for("view_class", class_id=class_id))

    return app


app = create_app()

if __name__ == "__main__":
    app.run(debug=True)
