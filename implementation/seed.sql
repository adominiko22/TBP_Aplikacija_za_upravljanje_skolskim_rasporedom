SET search_path TO school;

INSERT INTO subject (name, code) VALUES
('Hrvatski jezik', 'HRV'),
('Engleski jezik', 'ENG'),
('Njemački jezik', 'NJE'),
('Matematika', 'MAT'),
('Fizika', 'FIZ'),
('Biologija', 'BIO'),
('Kemija', 'KEM'),
('Povijest', 'POV'),
('Geografija', 'GEO'),
('Latinski jezik', 'LAT'),
('Informatika', 'INF'),
('Vjeronauk', 'VJER'),
('Etika', 'ETI'),
('Tjelesna i zdravstvena kultura', 'TZK'),
('Glazbena umjetnost', 'GLAZ'),
('Filozofija', 'FIL'),
('Politika i gospodarstvo', 'PIG'),
('Psihologija', 'PSI'),
('Likovna umjetnost', 'LIK'),
('Sociologija', 'SOC'),
('Logika', 'LOG'),
('Sat razredne zajednice', 'RZ')
ON CONFLICT (code) DO NOTHING;
