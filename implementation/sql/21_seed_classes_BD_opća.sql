SET search_path TO school;

DO $$
DECLARE
    v_year TEXT := '2025/2026';
    v_track_id BIGINT;
    g INT;
    lbl TEXT;
BEGIN
    SELECT id INTO v_track_id
    FROM program_track
    WHERE name = 'Opća gimnazija';

    IF v_track_id IS NULL THEN
        RAISE EXCEPTION 'Nedostaje track: Opća gimnazija (program_track).';
    END IF;

    FOREACH lbl IN ARRAY ARRAY['B','D'] LOOP
        FOR g IN 1..4 LOOP
            INSERT INTO school_class (school_year, grade_level, label, track_id)
            VALUES (v_year, g, lbl, v_track_id)
            ON CONFLICT (school_year, grade_level, label) DO NOTHING;
        END LOOP;
    END LOOP;
END $$;
