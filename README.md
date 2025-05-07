# Project for NTUA DB Course (Spring 2025)

This database, written for Postgresql, contains data for music festivals.

## Important Disclaimer
The file `sql/load.sql` was too large to include on the [repository](https://github.com/FaidonKourounakis/ntua-db) as Github has a 100MB file limit. That's why it was split into multiple chunks `sql/load_part_x.sql`. It can be deterministically generated via the command `$ cd code  && ./make_load_sql.sh` or alternatively reconstructed from its chunks with `$ reconstruct_load_sql.sh`(on unix systems).

## Project Structure
- `sql/` contains all sql files demanded by the project description, including the schema, constraints & triggers, indexes, data, queries and their outputs
- `code/` contains all scripts and my own code used
- `diagrams/` contains the relational and the ER diagram
- `docs/` contians the report for the project.

## Instructions

1. Install postgres, postgres-contrib, python, faker (python lib)
2. Change directory to `$ cd code` to run the automated scripts
3. Run `./make_load_sql.sh` to create the `load.sql` file with all the insert statements. This basically combines the output of `print_fake_data.py` with `adjust_data_for_Q14.sql` into a single, gigantic `load.sql`. Depending on the configuration (specified in `print_fake_data.py`) this can take some time, and the resulting file may be hundreds of megabytes long.
4. Alternatively you can split/reconstruct the single `load.sql` to/from its chuncks `load_part_x.sql` using the scripts `./split_load_sql.sh`/`./reconstruct_load_sql.sh` respectively.

5. Run `./setup_db.sh` to create a user, the database, install the schema (specified in `sql/install.sql`) and insert all the data (`sql/load.sql`).
6. Run `./run_queries.sql` in order to run all the QXX.sql queries and create their output files.


## Assumptions
- IDs of entities are serial for simplicity (we assume a non distributed system)
- Stage is a new entity 
- Personnel Job is currently Assistant/Security/Technical and is store in different table
- Storing Birth date instead of age for personnel (Age is derived)
- Genres and sub-genres are many, can't be represented as enums or strings and since sub-genres belong to a genre we model them as separate entities
- Genres of artist or band can be derived from their subgenres
- Event has pre-defined datetime and duration
- Bands are seperate Entities
- When a band performs, assume all band members perform
- Stage info of ticket derived from Ticket.Event.Stage
- Resales queues are implemented in two entities, one with Resales Buyers that want to buy tickets and one with Resales Sellers (the ticket offers)
- Resales have specific category, as foreign key to the category table (VIP/General/Backstage)
- Images are separate entity, held in static server, can be accessed through links.
- Visitors either rate all categories (Artist Performance, Sound/Lighting etc.) or none. As such a rating includes all the categories
- In addition to visitors, the entities artist, band and personnel all have emails.
- Entities that have pictures: Festival, Artists, Bands, Stages, Stage Equipment, related through junction tables

## Compulsory Constraints
- One Festival per year, as such the begin and end date year is equal and unique. To check uniqueness efficiently, a generated column "year" is created that has the constraint of being  unique.
- Every stage hosts <=1 event at a time
- Event personnel: Security has to be >= 5% of stage capacity, Assistants >= 2% of stage capacity (trigger on event/event_personnel statements)
- Time breaks between performances of event, in [5,30] min range. (Checked while adding/changing new performance)
- Performance Duration <= 3 Hours (Constraint)
- Events and festivals can't be canceled (deletions disallowed through restricted foreign references to performance and festival tables)
- Artists can't perform at the same time in multiple stages. (Trigger that ensures artists' performances don't overlap)
- Performers can not perform in >3 consecutive years
- Ticket number per event can't surpass stage capacity
- VIP Ticket numbers <= 10% of capacity
- A resale happens with the first matching seller and buyer

## Extra Constraints Implemented
- Payment Methods, Continents, Ticket Categories, Jobs, Experience (Levels), Performance Types can't be deleted (enforced through restricted foreign references to those tables)
- Email formating
- Event durations during the associated festival dates.
- Performance inside the duration of the Event
- One ticket per performance per person (assured because primary key of ticket consists of performance and visitor id)
- Band Genres/sub-genres included in every band's member genres/sub-genres (Implicit)
- In order to be offering a ticket for resales it must be unused
- Can't resell nonexistent tickets (Ensured by foreign key reference of seller to his ticket)

## Other Possible Constraints (Not implemented for simplicity)
- Stages of events of a festival are in the same location as the festival
- Personnel can only be at one event at a time
- First performance of event has same date time
- Last performance of event has ends on event finish date time
- 1st Performance of Event has to have type of "Warm Up" and have the same date time as event.
- Can't use tickets on resales offer
- Can't offer to buy ticket that is already owned by buyer
- At most one rating per visitor per performance
- Only visitors which attended a performance can create ratings (having used tickets)

## Tables/Entities (Rough sketch, see sql/install.sql or diagrams/relational.pdf for the entire schema)
# Database Schema Documentation

### Lookup Tables (ID + Name)
- **Continent**  
  - `ID`  
  - `Name`  

- **Payment Method**  
  - `ID`  
  - `Name`  

- **Ticket Category**  
  - `ID`  
  - `Name`  

- **Experience**  
  - `ID`  
  - `Name` (Training, Beginner, Average, Experienced, Very Experienced)  

- **Job**  
  - `ID`  
  - `Name` (Security, Assistant, Technical)  

- **Performance Type**  
  - `ID`  
  - `Name`  

---

### Core Entities

#### Festival
- `ID`  
- `Name`  
- `Begin Date` (Date)  
- `End Date` (Date)  
- `Location ID` (Composite Attribute in ER Diagram)  

### Location
- `ID`  
- `Address` (String)  
- `Coordinates` (Coordinates Type)  
- `City` (String)  
- `Country` (String)  
- `Continent ID` (FK to Continent)  

#### Event
- `ID`  
- `Festival ID` (FK to Festival)  
- `Stage ID` (FK to Stage)  
- `Date Time` (DateTime)  
- `Duration` (Time)  

#### Performance
- `ID`  
- `Event ID` (FK to Event)  
- `Performance Type ID` (FK to Performance Type)  
- `Date Time` (DateTime)  
- `Duration` (Time)  
- `Artist ID` (FK to Artist, *one of Artist/Band must be null*)  
- `Band ID` (FK to Band, *one of Artist/Band must be null*)  

#### Stage
- `ID`  
- `Name` (String)  
- `Description` (String)  
- `Capacity` (Unsigned Int)  
- *Equipment List managed via `Stage Equipment` table*  

#### Stage Equipment
- `Stage ID` (PK, FK to Stage)  
- `Equipment` (PK, String)  

#### Personnel
- `ID`  
- `Job ID` (FK to Job)  
- `First Name` (String)  
- `Last Name` (String)  
- `Birth Date` (Date)  
- `Experience ID` (FK to Experience, *1–5 scale*)  

#### Event Personnel
- `Event ID` (PK, FK to Event)  
- `Personnel ID` (PK, FK to Personnel)  

---

### Artist & Genre Entities

#### Artist
- `ID`  
- `First Name` (String)  
- `Last Name` (String)  
- `Nickname` (Optional)  
- `Birth Date` (Date)  
- `Website` (Optional)  
- `Instagram` (Optional)  
- *Genres derived via `Artist Subgenre`*  

#### Genre
- `ID`  
- `Name` (String, e.g., Rock, Jazz)  

#### Subgenre
- `Genre ID` (PK, FK to Genre)  
- `Name` (PK, String, e.g., Hard Rock, Bebop)  

#### Artist Subgenre
- `Subgenre ID` (Composite FK to Subgenre: `Genre ID` + `Name`)  

#### Band
- `ID`  
- `Name` (String)  
- `Established` (Date)  
- `Instagram` (Optional)  
- `Website` (Optional)  
- *Genres derived from members' subgenres*  

#### Band_Artist
- `Band ID` (PK, FK to Band)  
- `Artist ID` (PK, FK to Artist)  

---

### Visitor & Ticketing

#### Visitor
- `First Name` (String)  
- `Last Name` (String)  
- `Phone Number`  
- `Email`  
- `Birth Date` (Date)  

#### Ticket
- `Visitor ID` (FK to Visitor)  
- `Event ID` (FK to Event)  
- `Category ID` (FK to Ticket Category)  
- `Purchase DateTime`  
- `Price`  
- `Payment Method ID` (FK to Payment Method)  
- `Barcode` (EAN-13)  
- `Used` (Boolean)  

#### Resales Sellers
- `Visitor ID` (PK, FK to Visitor)  
- `Performance ID` (PK, FK to Performance)  
- `Offer DateTime`  

---

### Ratings & Media

#### Rating
- `Visitor ID` (FK to Visitor)  
- `Performance ID` (FK to Performance)  
- `Artist Performance` (1–5 Likert)  
- `Sound/Lighting` (1–5 Likert)  
- `Stage Presence` (1–5 Likert)  
- `Organization` (1–5 Likert)  
- `Overall Impression` (1–5 Likert)  

#### Images
- `ID`  
- `Link`  
- `Description`  