SET search_path TO school;


WITH
data(day_of_week, lesson_no, subject_code, teacher_name, classroom_code) AS (
  VALUES

  (1, 1, 'ENG', 'Branka Vladimir', '3'),
  (1, 2, 'ENG', 'Branka Vladimir', '3'),
  (1, 3, 'GEO', 'Ivan Đerek', '8'),
  (1, 4, 'NJE', 'Svjetlana Bebić', '5'),
  (1, 5, 'NJE', 'Svjetlana Bebić', '5'),
  (1, 6, 'BIO', 'Marija Volarević', '12'),


  (2, 1, 'RZ',  'Martina Pačić', '1'),
  (2, 2, 'KEM', 'Antonela Dragobratović', '12'),
  (2, 3, 'MAT', 'Ljubica Jerković', '9'),
  (2, 4, 'LAT', 'Ivana Menalo', '16'),
  (2, 5, 'HRV', 'Martina Pačić', '1'),
  (2, 6, 'HRV', 'Martina Pačić', '1'),


  (3, 1, 'FIZ', 'Angela Ćelić', '9'),
  (3, 2, 'ENG', 'Branka Vladimir', '3'),
  (3, 3, 'HRV', 'Martina Pačić', '1'),
  (3, 4, 'HRV', 'Martina Pačić', '1'),
  (3, 5, 'NJE', 'Svjetlana Bebić', '5'),
  (3, 6, 'POV', 'Zoran Vidović', '1'),
  (3, 7, 'TZK', 'Ivan Šprlje', 'DV'),


  (4, 1, 'KEM', 'Antonela Dragobratović', '12'),
  (4, 2, 'GEO', 'Ivan Đerek', '12'),
  (4, 3, 'NJE', 'Svjetlana Bebić', '5'),
  (4, 4, 'MAT', 'Ljubica Jerković', '7'),
  (4, 5, 'BIO', 'Marija Volarević', '12'),
  (4, 6, 'TZK', 'Ivan Šprlje', 'DV'),
  (4, 7, 'FIZ', 'Angela Ćelić', '9'),

  (5, 1, 'GLAZ', 'Helena Dilber Plećaš', '13'),
  (5, 2, 'LIK',  'Marijana Dodig', '3'),
  (5, 3, 'MAT',  'Ljubica Jerković', '7'),
  (5, 4, 'ENG',  'Branka Vladimir', '3'),
  (5, 5, 'VJER', 'Edita Jerković', '1'),
  (5, 6, 'LAT',  'Ivana Menalo', '8'),
  (5, 7, 'POV',  'Zoran Vidović', '15')
),
ts AS (
  SELECT d.*, t.id AS time_slot_id
  FROM data d
  JOIN time_slot t
    ON t.day_of_week = d.day_of_week
   AND t.lesson_no   = d.lesson_no
),
ins_ev AS (
  INSERT INTO scheduled_event (class_id, time_slot_id, created_by)
   SELECT
  (SELECT id
   FROM school_class
   WHERE school_year='2025/2026' AND grade_level=1 AND label='A'),
  time_slot_id,
  'seed-1A'

  FROM ts
  RETURNING id, time_slot_id
),
ev_map AS (
  SELECT e.id AS event_id, ts.subject_code, ts.teacher_name, ts.classroom_code
  FROM ins_ev e
  JOIN ts ON ts.time_slot_id = e.time_slot_id
)
INSERT INTO schedule_entry (event_id, subject_id, teacher_id, classroom_id)
SELECT
  m.event_id,
  (SELECT id FROM subject   WHERE code = m.subject_code),
  (SELECT id FROM teacher   WHERE full_name = m.teacher_name),
  (SELECT id FROM classroom WHERE code = m.classroom_code)
FROM ev_map m;
