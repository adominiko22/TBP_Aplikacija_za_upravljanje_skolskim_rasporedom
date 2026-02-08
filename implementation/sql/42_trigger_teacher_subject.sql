SET search_path TO school;

CREATE OR REPLACE FUNCTION school.trg_check_teacher_subject()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM school.teacher_subject ts
        WHERE ts.teacher_id = NEW.teacher_id
          AND ts.subject_id = NEW.subject_id
    ) THEN
        RAISE EXCEPTION 'Profesor ne predaje odabrani predmet.';
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS check_teacher_subject ON school.schedule_entry;

CREATE TRIGGER check_teacher_subject
BEFORE INSERT OR UPDATE ON school.schedule_entry
FOR EACH ROW
EXECUTE FUNCTION school.trg_check_teacher_subject();
