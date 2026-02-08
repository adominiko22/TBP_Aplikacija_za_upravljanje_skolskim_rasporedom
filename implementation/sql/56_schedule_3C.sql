SET search_path TO school;


WITH data(day_of_week, lesson_no, subject_code, teacher_name, classroom_code) AS (
  VALUES
  -- Po
  (1, 1, 'KEM', 'Dana Svaguša',        '11'),
  (1, 2, 'MAT', 'Dino Jerković',       '9'),
  (1, 3, 'GEO', 'Roberta Pavičić',     '10'),
  (1, 4, 'INF', 'Petra Ujdur',         '19'), 
  (1, 5, 'FIZ', 'Ante Zovko',          '8'),
  (1, 6, 'INF', 'Petra Ujdur',         '19'),
  (1, 7, 'INF', 'Petra Ujdur',         '19'),

  (2, 1, 'ENG', 'Judita Mustapić',     '4'),
  (2, 2, 'ENG', 'Judita Mustapić',     '4'),
  (2, 3, 'RZ',  'Marija Tomić Veraja', '13'),
  (2, 4, 'TZK', 'Ivan Šprlje',         'DV'),
  (2, 5, 'HRV', 'Marija Tomić Veraja', '15'),
  (2, 6, 'MAT', 'Dino Jerković',       '9'),
  (2, 7, 'SOC', 'Željka Dodig',        '13'),

  (3, 1, 'NJE', 'Zoran Martinović',    '16'),
  (3, 2, 'BIO', 'Sandra Šoše',         '12'),
  (3, 3, 'POV', 'Ante Matić (zamjena)','10'),
  (3, 4, 'ENG', 'Judita Mustapić',     '4'),
  (3, 5, 'GEO', 'Roberta Pavičić',     '10'),
  (3, 6, 'LOG', 'Klaudia Soldatić',    '17'),
  (3, 7, 'FIZ', 'Ante Zovko',          '8'),

  (4, 1, 'FIZ', 'Ante Zovko',          '8'),
  (4, 2, 'HRV', 'Marija Tomić Veraja', '15'),
  (4, 3, 'HRV', 'Marija Tomić Veraja', '15'),
  (4, 4, 'KEM', 'Dana Svaguša',        '11'),
  (4, 5, 'MAT', 'Dino Jerković',       '9'),
  (4, 6, 'MAT', 'Dino Jerković',       '9'),
  (4, 7, 'BIO', 'Sandra Šoše',         '12'),

  (5, 1, 'NJE', 'Zoran Martinović',    '5'),
  (5, 2, 'MAT', 'Dino Jerković',       '9'),
  (5, 3, 'POV', 'Ante Matić (zamjena)','1'),
  (5, 4, 'VJER','Edita Jerković',      '5'),
  (5, 5, 'HRV', 'Marija Tomić Veraja', '15'),
  (5, 6, 'PSI', 'Ana Barišić',         '7'),
  (5, 7, 'TZK', 'Ivan Šprlje',         'DV')
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
   WHERE school_year='2025/2026' AND grade_level=3 AND label='C'),
  time_slot_id,
  'seed-3C'

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
