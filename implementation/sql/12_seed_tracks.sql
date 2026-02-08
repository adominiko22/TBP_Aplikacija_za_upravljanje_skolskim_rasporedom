SET search_path TO school;

INSERT INTO program_track (name, description) VALUES
('Opća gimnazija', 'Opći gimnazijski program'),
('Jezična gimnazija', 'Jezični gimnazijski program'),
('Prirodoslovno-matematička gimnazija', 'Prirodoslovno-matematički program')
ON CONFLICT (name) DO NOTHING;
