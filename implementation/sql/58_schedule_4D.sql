SET search_path TO school;


WITH data(day_of_week, lesson_no, subject_code, teacher_name, classroom_code) AS (
  VALUES
  (1, 1, 'GEO',  'Ivan Đerek',            '10'),
  (1, 2, 'INF',  'Marinko Zubac',         'STEM'),
  (1, 3, 'INF',  'Marinko Zubac',          'STEM'),
  (1, 4, 'LIK',  'Marijana Dodig',        '14'),
  (1, 5, 'MAT',  'Magdalena Brajković',   '7'),
  (1, 6, 'TZK',  'Stipan Prce',           'DV'),
  (1, 7, 'FIL',  'Klaudia Soldatić',      '17'),

  (2, 1, 'ENG',  'Branka Vladimir',       '3'),
  (2, 2, 'ENG',  'Branka Vladimir',       '3'),
  (2, 3, 'FIZ',  'Ana Dragović',          '8'),
  (2, 4, 'HRV',  'Vedrana Pažin',         '2'),
  (2, 5, 'TZK',  'Stipan Prce',           'DV'),
  (2, 6, 'RZ',   'Vedrana Pažin',         '2'),

  (3, 1, 'BIO',  'Vera Modrić',           '12'),
  (3, 2, 'MAT',  'Magdalena Brajković',   '7'),
  (3, 3, 'FIZ',  'Ana Dragović',          '8'),
  (3, 4, 'ENG',  'Branka Vladimir',       '3'),
  (3, 5, 'NJE',  'Ana Bebić',             '4'),
  (3, 6, 'VJER', 'Edita Jerković',        '9'),
  (3, 7, 'POV',  'Roberta Pavičić',       '1'),

  (4, 1, 'HRV',  'Vedrana Pažin',         '2'),
  (4, 2, 'HRV',  'Vedrana Pažin',         '2'),
  (4, 3, 'KEM',  'Dana Svaguša',          '11'),
  (4, 4, 'MAT',  'Magdalena Brajković',   '14'),
  (4, 5, 'PIG',  'Marijana Dodig',        '13'),
  (4, 6, 'POV',  'Roberta Pavičić',       '1'),
  (4, 7, 'GEO',  'Ivan Đerek',            '10'),

  (5, 1, 'KEM',  'Dana Svaguša',          '11'),
  (5, 2, 'GLAZ', 'Helena Dilber Plećaš',  '13'),
  (5, 3, 'HRV',  'Vedrana Pažin',         '2'),
  (5, 4, 'BIO',  'Vera Modrić',           '12'),
  (5, 5, 'NJE',  'Ana Bebić',             '5'),
  (5, 6, 'POV',  'Roberta Pavičić',       '15'),
  (5, 7, 'FIL',  'Klaudia Soldatić',      '17')
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
   WHERE school_year='2025/2026' AND grade_level=4 AND label='D'),
  time_slot_id,
  'seed-4D'

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

