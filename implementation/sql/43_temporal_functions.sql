SET search_path TO school;

CREATE OR REPLACE FUNCTION school.get_schedule_as_of(
  p_ts timestamptz,
  p_class_id bigint DEFAULT NULL,
  p_teacher_id bigint DEFAULT NULL
)
RETURNS TABLE (
  event_id bigint,
  class_id bigint,
  school_year text,
  grade_level int,
  class_label text,
  track text,
  day_of_week int,
  lesson_no int,
  starts_at time,
  ends_at time,
  subject_code text,
  subject_name text,
  teacher_id bigint,
  teacher_name text,
  classroom_code text,
  note text,
  valid_from timestamptz,
  valid_to timestamptz
)
LANGUAGE sql
STABLE
AS $$
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
    se.note,
    ev.valid_from,
    ev.valid_to
  FROM school.scheduled_event ev
  JOIN school.school_class sc ON sc.id = ev.class_id
  JOIN school.program_track pt ON pt.id = sc.track_id
  JOIN school.time_slot ts ON ts.id = ev.time_slot_id
  JOIN school.schedule_entry se ON se.event_id = ev.id
  JOIN school.subject s ON s.id = se.subject_id
  JOIN school.teacher t ON t.id = se.teacher_id
  JOIN school.classroom c ON c.id = se.classroom_id
  WHERE ev.valid_from <= p_ts
    AND (ev.valid_to IS NULL OR ev.valid_to > p_ts)
    AND (p_class_id IS NULL OR sc.id = p_class_id)
    AND (p_teacher_id IS NULL OR t.id = p_teacher_id)
  ORDER BY sc.grade_level, sc.label, ts.day_of_week, ts.lesson_no;
$$;
