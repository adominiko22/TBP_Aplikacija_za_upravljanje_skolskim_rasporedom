SET search_path TO school;

INSERT INTO classroom (code, name, capacity) VALUES
('STEM', 'STEM kabinet / Informatika', 20),
('DV',   'Dvorana', 0)
ON CONFLICT (code) DO NOTHING;

INSERT INTO classroom (code, name, capacity) VALUES
('1',  'Učionica 1', 28),
('2',  'Učionica 2', 28),
('3',  'Učionica 3', 28),
('4',  'Učionica 4', 28),
('5',  'Učionica 5', 28),
('7',  'Učionica 7', 28),
('8',  'Učionica 8', 28),
('9',  'Učionica 9', 28),
('10', 'Učionica 10', 28),
('11', 'Učionica 11', 28),
('12', 'Učionica 12', 28),
('13', 'Učionica 13', 28),
('14', 'Učionica 14', 28),
('15', 'Učionica 15', 28),
('16', 'Učionica 16', 28),
('17', 'Učionica 17', 28),
('19', 'Učionica 19', 28)
ON CONFLICT (code) DO NOTHING;
