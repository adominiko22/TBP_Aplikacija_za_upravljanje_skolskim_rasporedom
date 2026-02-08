SET search_path TO school;

INSERT INTO teacher_subject (teacher_id, subject_id)
SELECT t.id, s.id
FROM (VALUES
    ('Martina Pačić', 'Hrvatski jezik'),
    ('Suzana Nižić', 'Hrvatski jezik'),
    ('Marija Tomić Veraja', 'Hrvatski jezik'),
    ('Petra Sršen', 'Hrvatski jezik'),
    ('Vedrana Pažin', 'Hrvatski jezik'),

    ('Branka Vladimir', 'Engleski jezik'),
    ('Ivona Šešelj', 'Engleski jezik'),
    ('Judita Mustapić', 'Engleski jezik'),

    ('Svjetlana Bebić', 'Njemački jezik'),
    ('Ana Bebić', 'Njemački jezik'),
    ('Zoran Martinović', 'Njemački jezik'),

    ('Ivana Menalo', 'Latinski jezik'),

    ('Helena Dilber Plećaš', 'Glazbena umjetnost'),

    ('Marijana Dodig', 'Likovna umjetnost'),
    ('Marijana Dodig', 'Sociologija'),
    ('Marijana Dodig', 'Politika i gospodarstvo'),

    ('Ana Barišić', 'Psihologija'),

    ('Klaudia Soldatić', 'Logika'),
    ('Klaudia Soldatić', 'Filozofija'),
    ('Klaudia Soldatić', 'Etika'),

    ('Željka Dodig', 'Sociologija'),

    ('Zoran Vidović', 'Povijest'),
    ('Roberta Pavičić', 'Povijest'),
    ('Ante Matić (zamjena)', 'Povijest'),
    ('Stanislav Simat (zamjena)', 'Povijest'),

    ('Ivan Đerek', 'Geografija'),
    ('Petar Nikolić', 'Geografija'),
    ('Roberta Pavičić', 'Geografija'),
    ('Stanislav Simat (zamjena)', 'Geografija'),

    ('Ljubica Jerković', 'Matematika'),
    ('Magdalena Brajković', 'Matematika'),
    ('Dino Jerković', 'Matematika'),
    ('Ante Zovko', 'Matematika'),
    ('Ante Zovko', 'Fizika'),

    ('Angela Ćelić', 'Fizika'),
    ('Ana Dragović', 'Fizika'),

    ('Antonela Dragobratović', 'Kemija'),
    ('Lora Prusac', 'Kemija'),
    ('Dana Svaguša', 'Kemija'),

    ('Marija Volarević', 'Biologija'),
    ('Vera Modrić', 'Biologija'),
    ('Sandra Šoše', 'Biologija'),

    ('Sanja Goluža', 'Informatika'),
    ('Marinko Zubac', 'Informatika'),
    ('Petra Ujdur', 'Informatika'),

    ('Ivan Šprlje', 'Tjelesna i zdravstvena kultura'),
    ('Stipan Prce', 'Tjelesna i zdravstvena kultura'),

    ('Edita Jerković', 'Vjeronauk')
) AS v(teacher_name, subject_name)
JOIN teacher t ON t.full_name = v.teacher_name
JOIN subject s ON s.name = v.subject_name
ON CONFLICT DO NOTHING;
