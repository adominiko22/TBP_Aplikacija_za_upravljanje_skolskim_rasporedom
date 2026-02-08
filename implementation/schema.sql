CREATE SCHEMA IF NOT EXISTS school;
SET search_path TO school;

CREATE TABLE program_track (
    id          BIGSERIAL PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE,  
    description TEXT
);

CREATE TABLE school_class (
    id           BIGSERIAL PRIMARY KEY,
    school_year  TEXT NOT NULL,        
    grade_level  INT NOT NULL CHECK (grade_level BETWEEN 1 AND 4),
    label        TEXT NOT NULL,       
    track_id     BIGINT NOT NULL REFERENCES program_track(id),
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_class UNIQUE (school_year, grade_level, label)
);

CREATE TABLE subject (
    id         BIGSERIAL PRIMARY KEY,
    name       TEXT NOT NULL,
    code       TEXT NOT NULL UNIQUE,
    is_active  BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE teacher (
    id         BIGSERIAL PRIMARY KEY,
    full_name  TEXT NOT NULL UNIQUE,
    email      TEXT,
    is_active  BOOLEAN NOT NULL DEFAULT TRUE
);

SET search_path TO school;

CREATE TABLE IF NOT EXISTS teacher_subject (
  teacher_id BIGINT NOT NULL REFERENCES teacher(id) ON DELETE CASCADE,
  subject_id BIGINT NOT NULL REFERENCES subject(id) ON DELETE CASCADE,
  PRIMARY KEY (teacher_id, subject_id)
);

CREATE INDEX IF NOT EXISTS idx_teacher_subject_teacher ON teacher_subject(teacher_id);
CREATE INDEX IF NOT EXISTS idx_teacher_subject_subject ON teacher_subject(subject_id);



CREATE TABLE classroom (
    id         BIGSERIAL PRIMARY KEY,
    code       TEXT NOT NULL UNIQUE,  
    name       TEXT,
    capacity   INT,
    is_active  BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE TABLE subject_classroom (
    subject_id   BIGINT NOT NULL REFERENCES subject(id) ON DELETE CASCADE,
    classroom_id BIGINT NOT NULL REFERENCES classroom(id),
    is_primary   BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (subject_id, classroom_id)
);

CREATE TABLE time_slot (
    id          BIGSERIAL PRIMARY KEY,
    day_of_week INT NOT NULL CHECK (day_of_week BETWEEN 1 AND 5),
    lesson_no   INT NOT NULL CHECK (lesson_no BETWEEN 1 AND 7),
    starts_at   TIME NOT NULL,
    ends_at     TIME NOT NULL,
    CONSTRAINT uq_slot UNIQUE (day_of_week, lesson_no),
    CONSTRAINT ck_time CHECK (ends_at > starts_at)
);

CREATE TABLE scheduled_event (
    id           BIGSERIAL PRIMARY KEY,
    class_id     BIGINT NOT NULL REFERENCES school_class(id),
    time_slot_id BIGINT NOT NULL REFERENCES time_slot(id),
    valid_from   TIMESTAMPTZ NOT NULL DEFAULT now(),
    valid_to     TIMESTAMPTZ NULL,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by   TEXT,
    CONSTRAINT ck_valid_period CHECK (valid_to IS NULL OR valid_to > valid_from)
);


CREATE TABLE schedule_entry (
    id           BIGSERIAL PRIMARY KEY,
    event_id     BIGINT NOT NULL REFERENCES scheduled_event(id) ON DELETE CASCADE,
    subject_id   BIGINT NOT NULL REFERENCES subject(id),
    teacher_id   BIGINT NOT NULL REFERENCES teacher(id),
    classroom_id BIGINT NOT NULL REFERENCES classroom(id),
    note         TEXT
);

CREATE TABLE curriculum_rule (
    id                  BIGSERIAL PRIMARY KEY,
    track_id            BIGINT NULL REFERENCES program_track(id),
    grade_level         INT NOT NULL CHECK (grade_level BETWEEN 1 AND 4),
    subject_id          BIGINT NOT NULL REFERENCES subject(id),
    is_allowed          BOOLEAN NOT NULL DEFAULT TRUE,
    min_hours_per_week  INT,
    max_hours_per_week  INT,
    CONSTRAINT uq_curriculum UNIQUE (track_id, grade_level, subject_id),
    CONSTRAINT ck_hours CHECK (
        min_hours_per_week IS NULL
        OR max_hours_per_week IS NULL
        OR max_hours_per_week >= min_hours_per_week
    )
);

CREATE UNIQUE INDEX idx_event_current
ON scheduled_event (class_id, time_slot_id)
WHERE valid_to IS NULL;

CREATE INDEX idx_entry_event ON schedule_entry(event_id);
CREATE INDEX idx_entry_teacher ON schedule_entry(teacher_id);
CREATE INDEX idx_entry_classroom ON schedule_entry(classroom_id);

