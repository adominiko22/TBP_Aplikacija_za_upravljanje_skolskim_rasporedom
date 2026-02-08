SET search_path TO school;

DO $$
DECLARE d int;
BEGIN
  FOR d IN 1..5 LOOP
    INSERT INTO time_slot(day_of_week, lesson_no, starts_at, ends_at)
    VALUES
      (d, 1, '07:30', '08:15'),
      (d, 2, '08:20', '09:05'),
      (d, 3, '09:10', '09:55'),
      (d, 4, '10:15', '11:00'),
      (d, 5, '11:05', '11:50'),
      (d, 6, '11:55', '12:40'),
      (d, 7, '12:45', '13:25')
    ON CONFLICT (day_of_week, lesson_no) DO NOTHING;
  END LOOP;
END $$;
