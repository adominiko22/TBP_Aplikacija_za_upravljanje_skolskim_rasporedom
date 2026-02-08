SET search_path TO school;


WITH data(day_of_week, lesson_no, subject_code, teacher_name, classroom_code) AS (
  VALUES
  (1, 1, 'GEO',  'Petar Nikolić',       '7'),
  (1, 2, 'GLAZ', 'Helena Dilber Plećaš','13'),
  (1, 3, 'NJE',  'Ana Bebić',           '2'),
  (1, 4, 'HRV',  'Suzana Nižić',        '15'),
  (1, 5, 'ENG',  'Ivona Šešelj',        '4'),
  (1, 6, 'ENG',  'Ivona Šešelj',        '4'),
  (1, 7, 'TZK',  'Stipan Prce',         'DV'),

  (2, 1, 'FIZ',  'Ana Dragović',        '8'),
  (2, 2, 'MAT',  'Magdalena Brajković', '9'),
  (2, 3, 'LAT',  'Ivana Menalo',        '16'),
  (2, 4, 'INF',  'Marinko Zubac',       'STEM'),
  (2, 5, 'INF',  'Marinko Zubac',       'STEM'),
  (2, 6, 'BIO',  'Vera Modrić',         '12'),
  (2, 7, 'POV',  'Roberta Pavičić',     '16'),

  (3, 1, 'KEM',  'Lora Prusac',         '11'),
  (3, 2, 'LAT',  'Ivana Menalo',        '8'),
  (3, 3, 'VJER', 'Edita Jerković',      '12'),
  (3, 4, 'BIO',  'Vera Modrić',         '12'),
  (3, 5, 'HRV',  'Suzana Nižić',        '15'),
  (3, 6, 'HRV',  'Suzana Nižić',        '15'),
  (3, 7, 'LIK',  'Marijana Dodig',      '14'),

  (4, 1, 'KEM',  'Lora Prusac',         '11'),
  (4, 2, 'MAT',  'Magdalena Brajković', '7'),
  (4, 3, 'MAT',  'Magdalena Brajković', '7'),
  (4, 4, 'NJE',  'Ana Bebić',           '2'),
  (4, 5, 'TZK',  'Stipan Prce',         'DV'),
  (4, 6, 'HRV',  'Suzana Nižić',        '15'),
  (4, 7, 'GEO',  'Petar Nikolić',       '3'),

  (5, 1, 'POV',  'Roberta Pavičić',     '16'),
  (5, 2, 'FIZ',  'Ana Dragović',        '8'),
  (5, 3, 'HRV',  'Suzana Nižić',        '15'),
  (5, 4, 'MAT',  'Magdalena Brajković', '7'),
  (5, 5, 'PSI',  'Ana Barišić',         '7'),
  (5, 6, 'ENG',  'Ivona Šešelj',        '4')
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
   WHERE school_year='2025/2026' AND grade_level=2 AND label='B'),
  time_slot_id,
  'seed-2B'

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

