DROP SCHEMA IF EXISTS school CASCADE;

\i schema.sql
\i seed.sql
\i sql/11_seed_timeslots_metkovic.sql
\i sql/12_seed_tracks.sql

\i sql/20_seed_classes_A_jezična.sql
\i sql/21_seed_classes_BD_opća.sql
\i sql/22_seed_classes_C_mat.sql

\i sql/13_seed_curriculum_rules.sql

\i sql/30_seed_classrooms.sql
\i sql/31_seed_teachers_metkovic.sql
\i sql/32_seed_teacher_subject_metkovic.sql

\i sql/40_triggers.sql
\i sql/41_views.sql
\i sql/43_temporal_functions.sql

\i sql/50_schedule_1A.sql
\i sql/52_schedule_2B.sql
\i sql/56_schedule_3C.sql
\i sql/58_schedule_4D.sql

\i sql/42_trigger_teacher_subject.sql

