SET search_path TO school;

CREATE OR REPLACE VIEW v_current_schedule AS
SELECT
    ev.id AS event_id,
    sc.id AS class_id,
    sc.school_year,
    sc.grade_level,
    sc.label AS class_label,
    pt.name AS track,
    ts.day_of_week,
    ts.lesson_no,
    ts.starts_at,
    ts.ends_at,
    s.code AS subject_code,
    s.name AS subject_name,
    t.id AS teacher_id,
    t.full_name AS teacher_name,
    c.code AS classroom_code,
    se.note
FROM scheduled_event ev
JOIN school_class sc ON sc.id = ev.class_id
JOIN program_track pt ON pt.id = sc.track_id
JOIN time_slot ts ON ts.id = ev.time_slot_id
JOIN schedule_entry se ON se.event_id = ev.id
JOIN subject s ON s.id = se.subject_id
JOIN teacher t ON t.id = se.teacher_id
JOIN classroom c ON c.id = se.classroom_id
WHERE ev.valid_to IS NULL;

CREATE OR REPLACE VIEW v_current_schedule_by_class AS
SELECT *
FROM v_current_schedule
ORDER BY grade_level, class_label, day_of_week, lesson_no;

CREATE OR REPLACE VIEW v_current_schedule_by_teacher AS
SELECT *
FROM v_current_schedule
ORDER BY teacher_name, day_of_week, lesson_no;
