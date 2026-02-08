SET search_path TO school;

INSERT INTO teacher (full_name) VALUES
('Martina Pačić'),
('Suzana Nižić'),
('Marija Tomić Veraja'),
('Petra Sršen'),
('Vedrana Pažin'),

('Branka Vladimir'),
('Ivona Šešelj'),
('Judita Mustapić'),

('Svjetlana Bebić'),
('Ana Bebić'),
('Zoran Martinović'),

('Ivana Menalo'),

('Helena Dilber Plećaš'),

('Marijana Dodig'),
('Željka Dodig'),

('Ana Barišić'),

('Klaudia Soldatić'),

('Zoran Vidović'),
('Roberta Pavičić'),
('Ante Matić (zamjena)'),
('Stanislav Simat (zamjena)'),

('Ivan Đerek'),
('Petar Nikolić'),

('Ljubica Jerković'),
('Magdalena Brajković'),
('Dino Jerković'),
('Ante Zovko'),

('Angela Ćelić'),
('Ana Dragović'),

('Antonela Dragobratović'),
('Lora Prusac'),
('Dana Svaguša'),

('Marija Volarević'),
('Vera Modrić'),
('Sandra Šoše'),

('Sanja Goluža'),
('Marinko Zubac'),
('Petra Ujdur'),

('Ivan Šprlje'),
('Stipan Prce'),

('Edita Jerković')
ON CONFLICT (full_name) DO NOTHING;
