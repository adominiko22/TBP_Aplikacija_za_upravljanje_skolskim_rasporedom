# TBP-Aplikacija za upravljanje školskim rasporedom

Ovaj projekt iz kolegija Teorije baza podataka predstavlja jednostavnu web aplikaciju za upravljanje i prikaz školskog rasporeda, implementiranu korištenjem PostgreSQL baze podataka i Flask web okvira. Sustav omogućuje pregled rasporeda po razredima i profesorima te administrativno upravljanje rasporedom uz stroga pravila integriteta podataka koja se provode na razini baze podataka.

Baza podataka implementira aktivno-temporalni model, pri čemu se promjene rasporeda ne brišu, već se vremenski verzioniraju, čime se omogućuje praćenje povijesti važenja rasporeda. Poslovna pravila (kurikulum, konflikti profesora i učionica) provode se pomoću okidača (triggers) i PL/pgSQL funkcija.

Svi podatci korišteni u projektu služe isključivo u edukacijske i demonstracijske svrhe.

---

## Struktura projekta

Projekt je organiziran hijerarhijski unutar direktorija `school-schedule` i sastoji se od sljedećih mapa i datoteka:

```text
school-schedule/
│
├── app/
│   ├── app.py
│   ├── db.py
│   ├── __init__.py
│   ├── __pycache__/
│   ├── static/
│   └── templates/
│       ├── base.html
│       ├── index.html
│       ├── class.html
│       ├── teacher.html
│       ├── admin_login.html
│       └── admin_panel.html
│
├── sql/
│   ├── 00_reset_all.sql
│   ├── 11_seed_timeslots_*.sql
│   ├── 12_seed_tracks.sql
│   ├── 13_seed_curriculum_rules.sql
│   ├── 20_seed_classes_*.sql
│   ├── 30_seed_classrooms.sql
│   ├── 31_seed_teachers_*.sql
│   ├── 32_seed_teacher_subject_*.sql
│   ├── 40_triggers.sql
│   ├── 41_views.sql
│   ├── 42_trigger_teacher_subject.sql
│   ├── 43_temporal_functions.sql
│   ├── 50_schedule_*.sql
│   └── ...
│
├── schema.sql
├── seed.sql
├── requirements.txt
├── .env
├── .env.example
├── .gitignore
└── README.md
```

### Opis glavnih komponenti

#### `app/`
Sadrži implementaciju Flask web aplikacije.

- **`app.py`**  
  Glavna aplikacijska datoteka. Definira rute za prikaz rasporeda po razredima i profesorima, administrativni dio aplikacije te logiku sesija i autentifikacije administratora.

- **`db.py`**  
  Pomoćni modul za rad s PostgreSQL bazom podataka korištenjem biblioteke `psycopg`. Omogućuje izvršavanje SQL upita i dohvat podataka.

- **`templates/`**  
  HTML predlošci izrađeni korištenjem Jinja2 templating sustava:
  - `index.html` – početna stranica
  - `class.html` – prikaz rasporeda po razredu
  - `teacher.html` – prikaz rasporeda po profesoru
  - `admin_login.html` – prijava administratora
  - `admin_panel.html` – administrativno upravljanje rasporedom
  - `base.html` – zajednički predložak

- **`static/`**  
  Predviđena mapa za statičke resurse (CSS, JavaScript); trenutno prazna.

---

#### `sql/`
Sadrži sve SQL skripte potrebne za inicijalizaciju, popunjavanje i logiku baze podataka.

- **Shema i osnovne strukture**
  - `schema.sql` – definicija tablica, relacija, ograničenja i indeksa
  - `41_views.sql` – pogledi za dohvat trenutnog rasporeda
  - `40_triggers.sql`, `42_trigger_teacher_subject.sql` – okidači za provedbu poslovnih pravila
  - `43_temporal_functions.sql` – funkcije vezane uz temporalnu logiku

- **Seed podaci**
  - predmeti, razredi, smjerovi, učionice, profesori i vremenski termini

- **Rasporedi**
  - SQL skripte za inicijalne rasporede pojedinih razreda

- **`00_reset_all.sql`**
  Glavna skripta koja briše postojeću shemu i ponovno kreira bazu zajedno sa svim početnim podatcima i pravilima.

---

## Korištene tehnologije i alati

### PostgreSQL
Relacijski sustav za upravljanje bazama podataka korišten za pohranu i obradu podataka o školskom rasporedu. Implementirani su:
- relacijski model podataka
- pogledi (views)
- okidači (triggers)
- PL/pgSQL funkcije
- temporalni mehanizmi verzioniranja podataka

Testirano na verziji **PostgreSQL 16.11**.

---

### Python
Korišten kao programski jezik za implementaciju aplikacijske logike.

- Verzija: **Python 3.12.3**
- Paketni upravitelj: **pip 24.0**

---

### Flask
Lagani web okvir za izradu web aplikacije. Flask se koristi za:
- definiranje web ruta
- povezivanje s bazom podataka
- rad sa sesijama i autentifikacijom administratora
- renderiranje HTML predložaka

---

### psycopg
Biblioteka za komunikaciju s PostgreSQL bazom podataka iz Python aplikacije (psycopg3).

---

### HTML / Jinja2
Korišteni za izradu korisničkog sučelja i dinamičko generiranje web stranica.

---

### Ubuntu Linux
Operacijski sustav korišten za razvoj i testiranje aplikacije.

---

## Pokretanje projekta iz ZIP arhive (Ubuntu Linux)

Ovaj odjeljak opisuje postupak pokretanja projekta iz ZIP arhive, bez potrebe za korištenjem GitHub repozitorija. Upute pretpostavljaju Linux okruženje (Ubuntu) i služe za lokalno pokretanje aplikacije i baze podataka.

---

### Preduvjeti

Na sustavu moraju biti instalirani sljedeći alati:

- PostgreSQL (server i `psql` klijent)
- Python 3.12+
- `pip`
- `python3-venv`

Primjer instalacije na Ubuntu sustavu:

```bash
sudo apt update
sudo apt install -y postgresql postgresql-client python3 python3-venv python3-pip
```

Provjera instalacija:

```bash
psql --version
python3 --version
pip --version
```

Projekt je razvijen i testiran s:
- PostgreSQL 16.11
- Python 3.12.3
- pip 24.0

---

### 1) Raspakiravanje ZIP arhive

Pretpostavlja se da se projekt nalazi u arhivi `school-schedule.zip`.

```bash
unzip school-schedule.zip
cd school-schedule
```

Provjeriti da direktorij sadrži mape `app/` i `sql/` te konfiguracijske datoteke.

---

### 2) Konfiguracija varijabli okruženja

U root direktoriju projekta potrebno je pripremiti `.env` datoteku.

Ako već ne postoji:

```bash
cp .env.example .env
nano .env
```

Minimalni sadržaj `.env` datoteke:

```env
DATABASE_URL=postgresql://school_app:school_app_pw@localhost:5432/school_db
ADMIN_PIN=1234
SECRET_KEY=dev-secret-change-me
```

---

### 3) Python virtualno okruženje i ovisnosti

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

---

### 4) Inicijalizacija PostgreSQL baze podataka

#### 4.1 Kreiranje korisnika i baze (jednokratno)

Na Ubuntu sustavima PostgreSQL koristi sistemskog korisnika `postgres`.

```bash
sudo -u postgres psql
```

U PostgreSQL konzoli izvršiti:

```sql
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'school_app') THEN
    CREATE ROLE school_app LOGIN PASSWORD 'school_app_pw';
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'school_db') THEN
    CREATE DATABASE school_db OWNER school_app;
  END IF;
END $$;

GRANT ALL PRIVILEGES ON DATABASE school_db TO school_app;
```

Izlazak iz konzole:

```sql
\q
```

---

#### 4.2 Inicijalizacija sheme i podataka

Projekt sadrži glavnu SQL skriptu za reset i inicijalizaciju baze:

```bash
PGPASSWORD=school_app_pw psql -h localhost -U school_app -d school_db -f sql/00_reset_all.sql
```

Ova skripta:
- briše postojeću shemu (ako postoji)
- kreira tablice, indekse, poglede i okidače
- puni bazu inicijalnim podatcima

---

### 5) Pokretanje Flask aplikacije

U root direktoriju projekta, s aktiviranim virtualnim okruženjem:

```bash
python3 -m flask --app app.app run --debug
```

Aplikacija je dostupna na adresi:

```
http://127.0.0.1:5000/
```

Administratorski dio:
```
http://127.0.0.1:5000/admin
```

PIN za prijavu definiran je u `.env` datoteci (`ADMIN_PIN`).

---

## Automatizirano pokretanje (skripta)

Projekt uključuje skriptu `run_local.sh` koja automatizira:

- pripremu `.env` datoteke
- kreiranje Python virtualnog okruženja
- instalaciju Python ovisnosti
- kreiranje PostgreSQL korisnika i baze
- inicijalizaciju baze podataka
- pokretanje Flask aplikacije

### Pokretanje skripte

```bash
chmod +x run_local.sh
./run_local.sh
```

Skripta može zatražiti administratorsku (`sudo`) lozinku radi kreiranja PostgreSQL baze i korisnika.

---

### Napomena

Ako PostgreSQL korisnik i baza već postoje, moguće je preskočiti ručne korake inicijalizacije i koristiti isključivo automatiziranu skriptu.

Sve promjene rasporeda u sustavu se vremenski verzioniraju, a poslovna pravila (kurikulum i konflikti) provode se na razini baze podataka pomoću okidača.

