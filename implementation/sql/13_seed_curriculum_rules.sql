SET search_path TO school;

DELETE FROM curriculum_rule;

INSERT INTO curriculum_rule (track_id, grade_level, subject_id, is_allowed)
SELECT pt.id, g.grade_level, s.id, TRUE
FROM program_track pt
CROSS JOIN (VALUES (1),(2),(3),(4)) AS g(grade_level)
CROSS JOIN subject s
ON CONFLICT (track_id, grade_level, subject_id) DO UPDATE
SET is_allowed = EXCLUDED.is_allowed;

UPDATE curriculum_rule cr
SET is_allowed = FALSE
FROM program_track pt
JOIN subject s ON s.code = 'INF'
WHERE cr.track_id = pt.id
  AND cr.subject_id = s.id
  AND pt.name IN ('Jezična gimnazija')
  AND cr.grade_level IN (3,4);

UPDATE curriculum_rule cr
SET is_allowed = FALSE
FROM program_track pt
JOIN subject s ON s.code = 'PSI'
WHERE cr.track_id = pt.id
  AND cr.subject_id = s.id
  AND pt.name IN ('Jezična gimnazija','Prirodoslovno-matematička gimnazija')
  AND cr.grade_level IN (1,2,4);

UPDATE curriculum_rule cr
SET is_allowed = FALSE
FROM program_track pt
JOIN subject s ON s.code = 'PSI'
WHERE cr.track_id = pt.id
  AND cr.subject_id = s.id
  AND pt.name = 'Opća gimnazija'
  AND cr.grade_level IN (1,4);

UPDATE curriculum_rule cr
SET is_allowed = FALSE
FROM subject s
WHERE cr.subject_id = s.id
  AND s.code IN ('LOG','SOC')
  AND cr.grade_level NOT IN (3,4);

UPDATE curriculum_rule cr
SET is_allowed = FALSE
FROM program_track pt
JOIN subject s ON s.code = 'LIK'
WHERE cr.track_id = pt.id
  AND cr.subject_id = s.id
  AND pt.name = 'Prirodoslovno-matematička gimnazija'
  AND cr.grade_level IN (3,4);

UPDATE curriculum_rule cr
SET is_allowed = FALSE
FROM program_track pt
JOIN subject s ON s.code = 'GLAZ'
WHERE cr.track_id = pt.id
  AND cr.subject_id = s.id
  AND pt.name = 'Prirodoslovno-matematička gimnazija'
  AND cr.grade_level IN (3,4);
  
UPDATE curriculum_rule cr
SET is_allowed = FALSE
FROM subject s
WHERE cr.subject_id = s.id
  AND s.code = 'PIG'
  AND cr.grade_level <> 4;



