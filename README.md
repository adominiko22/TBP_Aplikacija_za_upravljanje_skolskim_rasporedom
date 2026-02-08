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
