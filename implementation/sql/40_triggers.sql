
SET search_path TO school;

CREATE OR REPLACE FUNCTION school.trg_close_prev_scheduled_event()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.valid_from IS NULL THEN
        NEW.valid_from := now();
    END IF;

    UPDATE school.scheduled_event
       SET valid_to = NEW.valid_from
     WHERE class_id = NEW.class_id
       AND time_slot_id = NEW.time_slot_id
       AND valid_to IS NULL;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS close_prev_scheduled_event ON school.scheduled_event;

CREATE TRIGGER close_prev_scheduled_event
BEFORE INSERT ON school.scheduled_event
FOR EACH ROW
EXECUTE FUNCTION school.trg_close_prev_scheduled_event();


CREATE OR REPLACE FUNCTION school.trg_check_curriculum()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_track_id BIGINT;
    v_grade_level INT;
BEGIN
    SELECT sc.track_id, sc.grade_level
    INTO v_track_id, v_grade_level
    FROM school.school_class sc
    WHERE sc.id = (
        SELECT ev.class_id
        FROM school.scheduled_event ev
        WHERE ev.id = NEW.event_id
    );

    IF v_track_id IS NULL OR v_grade_level IS NULL THEN
        RAISE EXCEPTION 'Ne mogu odrediti razred ili smjer za event_id=%', NEW.event_id;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM school.curriculum_rule cr
        WHERE cr.track_id = v_track_id
          AND cr.grade_level = v_grade_level
          AND cr.subject_id = NEW.subject_id
          AND cr.is_allowed = TRUE
    ) THEN
        RAISE EXCEPTION
            'Predmet nije dopušten po kurikulumu (track_id=%, razred=%)',
            v_track_id, v_grade_level;
    END IF;

    RETURN NEW;
END;
$$;


DROP TRIGGER IF EXISTS check_curriculum_entry ON school.schedule_entry;

CREATE TRIGGER check_curriculum_entry
BEFORE INSERT OR UPDATE ON school.schedule_entry
FOR EACH ROW
EXECUTE FUNCTION school.trg_check_curriculum();


CREATE OR REPLACE FUNCTION school.trg_prevent_conflicts()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_time_slot_id BIGINT;
BEGIN
    SELECT time_slot_id
      INTO v_time_slot_id
      FROM school.scheduled_event
     WHERE id = NEW.event_id;

    IF EXISTS (
        SELECT 1
          FROM school.schedule_entry se
          JOIN school.scheduled_event ev ON ev.id = se.event_id
         WHERE se.classroom_id = NEW.classroom_id
           AND ev.time_slot_id = v_time_slot_id
           AND ev.valid_to IS NULL
           AND ev.id <> NEW.event_id
    ) THEN
        RAISE EXCEPTION 'Konflikt: učionica je već zauzeta u tom terminu.';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM school.schedule_entry se
          JOIN school.scheduled_event ev ON ev.id = se.event_id
         WHERE se.teacher_id = NEW.teacher_id
           AND ev.time_slot_id = v_time_slot_id
           AND ev.valid_to IS NULL
           AND ev.id <> NEW.event_id
    ) THEN
        RAISE EXCEPTION 'Konflikt: profesor već predaje u tom terminu.';
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS prevent_conflicts_entry ON school.schedule_entry;

CREATE TRIGGER prevent_conflicts_entry
BEFORE INSERT OR UPDATE ON school.schedule_entry
FOR EACH ROW
EXECUTE FUNCTION school.trg_prevent_conflicts();


DO $$
BEGIN
  IF NOT EXISTS (
      SELECT 1
      FROM pg_constraint
      WHERE conname = 'uq_schedule_entry_event'
        AND conrelid = 'school.schedule_entry'::regclass
  ) THEN
    ALTER TABLE school.schedule_entry
    ADD CONSTRAINT uq_schedule_entry_event UNIQUE (event_id);
  END IF;
END $$;



