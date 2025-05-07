import random
from datetime import datetime, timedelta, time, date
from faker import Faker
import uuid
from collections import defaultdict
from math import floor, ceil
Faker.seed(4321)
fake = Faker()
random.seed(4321)

# =====================
# CONFIGURATION SECTION
# =====================

CONFIG_BIG = {
    "max_rows_per_insert": 5000, # for memory conservation of db server
    "num_locations": 5,
    "num_festivals": 10,
    "stages_per_location": 10,
    "min_stage_capacity": 500,
    "max_stage_capacity": 10000,
    "stage_capacity_step": 1000,
    "events_per_festival": 25,
    "equipment_per_stage": 5,
    "num_personnel": 5000,
    "min_technical_personnel": 300,
    "num_artists": 1000,
    "num_bands": 100,
    "num_visitors": 40000,
    "percent_sold": 0.95,
    "resales_buyers_per_event": 30,
    "resales_sellers_per_event": 10,
    "ratings_per_performance": 500,
    "image_frequency": 2,
    "festival_base_year": 2017,
    "min_performance_gap": 5,    # minutes
    "max_performance_gap": 30,   # minutes
    "max_performance_hours": 3,
    "vip_capacity_percent": 0.1,
    "security_personnel_percent": 0.05,
    "assistant_personnel_percent": 0.02
}

CONFIG_SMALL = {
    "max_rows_per_insert": 5000, # for memory conservation of db server
    "num_locations": 1,
    "num_festivals": 1,
    "stages_per_location": 1,
    "min_stage_capacity": 5,
    "max_stage_capacity": 10,
    "stage_capacity_step": 5,
    "events_per_festival": 2,
    "equipment_per_stage": 2,
    "num_personnel": 5,
    "min_technical_personnel": 5,
    "num_artists": 10,
    "num_bands": 1,
    "num_visitors": 20,
    "percent_sold": 0.9,
    "resales_buyers_per_event": 1,
    "resales_sellers_per_event": 1,
    "ratings_per_performance": 1,
    "image_frequency": 2,
    "festival_base_year": 2021,
    "min_performance_gap": 5,    # minutes
    "max_performance_gap": 30,   # minutes
    "max_performance_hours": 3,
    "vip_capacity_percent": 0.1,
    "security_personnel_percent": 0.05,
    "assistant_personnel_percent": 0.02
}

CONFIG = CONFIG_BIG
# CONFIG = CONFIG_SMALL

# =====================
# DATA STORES
# =====================
data = {
    "continents": [], "performance_types": [], "experiences": [],
    "ticket_categories": [], "payment_methods": [], "jobs": [],
    "locations": [], "stages": [], "festivals": [], "events": [],
    "stage_equipment": [], "personnel": [], "event_personnel": [], "genres": [], "subgenres": [],
    "artists": [], "bands": [], "band_artists": [], "artist_subgenres": [], "band_subgenres": [],
    "performances": [], "visitors": [], "tickets": [], "resales_buyer": [],
    "resales_seller": [], "ratings": [], "images": [], "festival_images": [],
    "artist_images": [], "band_images": [], "stage_images": []
}

# =====================
# HELPER FUNCTIONS
# =====================

verbs = [
    'Rock', 'Dance', 'Groove', 'Vibe', 'Jam', 'Blast', 'Echo', 'Spin', 'Rave', 'Bop', 
    'Shake', 'Thump', 'Vibrate', 'Bounce', 'Jam', 'Flow', 'Move', 'Surge', 'Beat', 'Pulse', 
    'Rush', 'Slide', 'Strum', 'Sync', 'Twist', 'Spin', 'Swing', 'Shout', 'Charge', 'Chime', 
    'Flicker', 'Strut', 'Harmonize', 'Clap', 'Riff', 'Drop', 'Buzz', 'Jammin', 'Bounce', 'Whirl'
]

adjectives = [
    'Electric', 'Wild', 'Funky', 'Vibrant', 'Loud', 'Radical', 'Epic', 'Dynamic', 'Cosmic', 
    'Neon', 'Explosive', 'Hypnotic', 'Breezy', 'Intense', 'Intoxicating', 'Bright', 'Fiery', 
    'Rebellious', 'Vivid', 'Blazing', 'Free', 'Limitless', 'Tropical', 'Majestic', 'Pulsating', 
    'Magnetic', 'Groovy', 'Lush', 'Wild', 'Sonic', 'Bold', 'Boisterous', 'Raucous', 'Heavy', 
    'Electric', 'Kinetic', 'Burning', 'Incredible', 'Fiery', 'Cloudy', 'Mysterious', 'Surreal', 
    'Fierce', 'Adventurous', 'Mystic', 'Dizzying', 'Sizzling'
]

nouns = [
    'Vibes', 'Rhythms', 'Beats', 'Tones', 'Sounds', 'Grooves', 'Waves', 'Echoes', 'Riffs', 
    'Chords', 'Tunes', 'Melodies', 'Waves', 'Rays', 'Frequencies', 'Breezes', 'Notes', 'Chimes', 
    'Vibrations', 'Motions', 'Echoes', 'Shimmers', 'Energy', 'Rumbles', 'Lights', 'Flashes', 
    'Spectra', 'Surges', 'Pulse', 'Bass', 'Tunes', 'Flows', 'Tremors', 'Pulses', 'Winds', 'Spark', 
    'Colors', 'Beats', 'Basses', 'Sparks', 'Shakes', 'Frequencies', 'Strums', 'Explosions', 
    'Reflections', 'Ripples', 'Storms', 'Rush', 'Flares', 'Murmurs', 'Phases', 'Storms', 'Thunder'
]

# Function to generate a music festival event title
def generate_title():
    # Randomly select one from each list
    verb = random.choice(verbs)
    adjective = random.choice(adjectives)
    noun = random.choice(nouns)

    # Combine them into a music festival title
    title = f"{verb} {adjective} {noun}"
    
    return title

def time_range(start: datetime, duration: timedelta) -> tuple:
    return (start, start + duration)

def overlaps(a: tuple, b: tuple) -> bool:
    return a[0] < b[1] and a[1] > b[0]

def should_add_image(entity_id: int) -> bool:
    return entity_id % CONFIG["image_frequency"] == 0

# =====================
# DATA GENERATION
# =====================

data["jobs"] = [
    (1, "Technical"),
    (2, "Security"),
    (3, "Assistant")
]

data["payment_methods"] = [
    (1, "Credit"),
    (2, "Debit"),
    (3, "Bank Transfer")
]

data["continents"] = [
    (1, "North America"),
    (2, "South America"),
    (3, "Europe"),
    (4, "Africa"),
    (5, "Oceania"),
    (6, "Antarctica")
]

data["performance_types"] = [
    (1, "Warm Up"),
    (2, "Headline"),
    (3, "Special Gues")
]

data["experiences"] = [
    (1, "Training"),
    (2, "Beginner"),
    (3, "Average"),
    (4, "Experienced"),
    (5, "Expert")    
]

data["ticket_categories"] = [
    (1, "General"),
    (2, "VIP"),
    (3, "Backstage")
]

# Generate Locations
for _ in range(CONFIG["num_locations"]):
    data["locations"].append((
        fake.street_address(),
        fake.longitude(),
        fake.latitude(),
        fake.city(),
        fake.country(),
        random.randint(1, len(data["continents"]))
    ))

# Generate Stages and Equipment
equipment_pool = ['PA System', 'Lighting Rig', 'LED Wall', 'Pyrotechnics',
                 'Drum Kit', 'DJ Booth', 'Fog Machine', 'Lasers']
for loc_id in range(1, CONFIG["num_locations"] + 1):
    for _ in range(CONFIG["stages_per_location"]):
        # Create stage
        stage = (
            loc_id,
            f"{fake.color_name()} Stage",
            fake.sentence(),
            random.randrange(CONFIG["min_stage_capacity"], CONFIG["max_stage_capacity"], CONFIG["stage_capacity_step"])
        )
        data["stages"].append(stage)
        stage_id = len(data["stages"])

        # Add equipment
        equipment = random.sample(equipment_pool, CONFIG["equipment_per_stage"])
        data["stage_equipment"].extend([(stage_id, f"{random.randint(1, 10)}x {eq}") for eq in equipment])

# Generate Festivals
for year_offset in range(CONFIG["num_festivals"]):
    year = CONFIG["festival_base_year"] + year_offset
    month = random.randint(5, 9)
    day = random.randint(1,20)
    days = random.randint(2,8)
    start_date = datetime(year, month, day)
    end_date = datetime(year, month, day + days)
    data["festivals"].append((
        f"Festival {year}",
        start_date.date(),
        end_date.date(),
        random.randint(1, CONFIG["num_locations"])
    ))

# =====================
# GENERATE EVENTS (DAILY STAGE BLOCKS)
# =====================
for festival_id, festival in enumerate(data["festivals"], start=1):
    festival_name, start_date, end_date, location_id = festival
    start_dt = datetime.combine(start_date, datetime.min.time())
    end_dt = datetime.combine(end_date, datetime.min.time())

    # Get stages belonging to this festival's location
    festival_stages = [
        (stage_id, stage) 
        for stage_id, stage in enumerate(data["stages"], start=1) 
        if stage[0] == location_id
    ]

    # Generate daily events for each stage
    current_day = start_date
    while current_day <= end_date:
        for stage_id, stage in festival_stages:
            # Randomize event start time (between 9:00 AM and 6:00 PM)
            start_hour = random.randint(12, 20)
            start_minute = random.choice([0, 15, 30, 45])
            event_start = datetime.combine(current_day, datetime.strptime(f"{start_hour}:{start_minute}", "%H:%M").time())

            # Randomize event duration (between 6 and 12 hours)
            event_duration = timedelta(hours=random.randint(2, 6))
            event_end = event_start + event_duration

            # Ensure the event doesn't go past midnight
            if event_end.date() > current_day:
                event_end = datetime.combine(current_day, datetime.strptime("23:59", "%H:%M").time())
                event_duration = event_end - event_start

            title = f"{generate_title()} {event_start.year}!"

            data["events"].append((
                title,
                festival_id,
                stage_id,
                event_start,
                event_duration
            ))
        current_day += timedelta(days=1)
        
# Generate Personnel with Job Constraints
required_security = sum(ceil(s[3] * CONFIG["security_personnel_percent"]) for s in data["stages"])
required_assistants = sum(ceil(s[3] * CONFIG["assistant_personnel_percent"]) for s in data["stages"])

# Generate required roles first
for _ in range(required_security):
    data["personnel"].append((
        2, # job_id of Security
        fake.first_name(),
        fake.last_name(),
        fake.date_of_birth(minimum_age=21, maximum_age=55),
        random.randint(3, len(data["experiences"])),
        fake.unique.email()
    ))

for _ in range(required_assistants):
    data["personnel"].append((
        3, # job_id of Assistant
        fake.first_name(),
        fake.last_name(),
        fake.date_of_birth(minimum_age=18, maximum_age=60),
        random.randint(1, len(data["experiences"]) - 2),
        fake.unique.email()
    ))

# Fill remaining personnel
remaining = max(
    CONFIG["num_personnel"] - required_security - required_assistants, 
    CONFIG["min_technical_personnel"])
for _ in range(remaining):
    data["personnel"].append((
        1, # job_id of Technical
        fake.first_name(),
        fake.last_name(),
        fake.date_of_birth(minimum_age=18, maximum_age=65),
        random.randint(1, len(data["experiences"])),
        fake.unique.email()
    ))
    

security_personnel = [i for i, p in enumerate(data["personnel"], start=1) if p[0] == 2]
assistant_personnel = [i for i, p in enumerate(data["personnel"], start=1) if p[0] == 3]
technical_personnel = [i for i, p in enumerate(data["personnel"], start=1) if p[0] == 1]

for event_id, event in enumerate(data["events"], start=1):
    stage_id = event[2]
    capacity = data["stages"][stage_id-1][3]
    
    # Calculate required personnel
    required_security = max(1, int(capacity * CONFIG["security_personnel_percent"]))
    required_assistants = max(1, int(capacity * CONFIG["assistant_personnel_percent"]))
    required_technical = min(CONFIG["min_technical_personnel"], random.randint(5, 50))

    # Select security personnel
    selected_security = random.sample(security_personnel, required_security)
    data["event_personnel"].extend([(event_id, p) for p in selected_security])
    
    # Select assistants
    selected_assistants = random.sample(assistant_personnel, required_assistants)
    data["event_personnel"].extend([(event_id, p) for p in selected_assistants])

    # Select technical
    selected_technical = random.sample(technical_personnel, required_technical)
    data["event_personnel"].extend([(event_id, p) for p in selected_technical])

# Generate Genres/Subgenres
genres = {
    'Rock': ['Alternative', 'Classic', 'Progressive'],
    'Pop': ['Dance', 'Synthpop', 'Indie'],
    'Electronic': ['House', 'Techno', 'Dubstep'],
    'Hip Hop': ['Trap', 'Old School', 'Drill'],
    'Jazz': ['Smooth', 'Bebop', 'Fusion']
}
for genre_id, (name, subgenres) in enumerate(genres.items(), start=1):
    data["genres"].append((name,))
    data["subgenres"].extend([(genre_id, sg) for sg in subgenres])

# Generate Artists with Subgenres
artist_availability = defaultdict(list)
for artist_id in range(1, CONFIG["num_artists"] + 1):
    # Create artist
    data["artists"].append((
        fake.first_name(),
        fake.last_name(),
        fake.user_name() if random.random() > 0.5 else None,
        fake.date_of_birth(minimum_age=15, maximum_age=70),
        fake.unique.email(),
        fake.url() if random.random() > 0.5 else None,
        f"@{fake.user_name()}" if random.random() > 0.5 else None
    ))

    # Assign subgenres
    artist_genres = random.sample(list(genres.keys()), random.randint(1,3))
    for genre in artist_genres:
        subgs = random.sample(genres[genre], random.randint(1, 2))
        data["artist_subgenres"].extend([
            (artist_id, list(genres.keys()).index(genre) + 1, sg)
            for sg in subgs
        ])

# Generate Bands with Members
for band_id in range(1, CONFIG["num_bands"] + 1):
    # Create band
    data["bands"].append((
        f"{fake.last_name()} Collective",
        fake.date_between(start_date='-20y', end_date='today'),
        fake.unique.email(),
        fake.url() if random.random() > 0.5 else None,
        f"@{fake.user_name()}" if random.random() > 0.5 else None
    ))

    # Add members (3-5 artists)
    members = random.sample(
        range(1, CONFIG["num_artists"] + 1),
        random.randint(2, min(7, CONFIG["num_artists"]))
    )
    data["band_artists"].extend([(band_id, m) for m in members])

    # Assign subgenres
    band_genres = random.sample(list(genres.keys()), random.randint(1,3))
    for genre in band_genres:
        subgs = random.sample(genres[genre], random.randint(1, 2))
        data["band_subgenres"].extend([
            (band_id, list(genres.keys()).index(genre) + 1, sg)
            for sg in subgs
        ])

# =====================
# GENERATE PERFORMANCES WITH CONSTRAINTS
# =====================
artist_availability = defaultdict(list)
artist_years = defaultdict(list)
performance_id = 1

for event_id, event in enumerate(data["events"], start=1):
    name, festival_id, stage_id, event_start, event_duration = event
    event_end = event_start + event_duration
    current_time = event_start
    festival_year = event_start.year

    while current_time < event_end:
        remaining_time = floor((event_end - current_time).total_seconds() / 60)
        if remaining_time < 30:
            break
            
        max_duration = min(CONFIG["max_performance_hours"] * 60, remaining_time)
        performance_duration = timedelta(minutes=random.randrange(20, max_duration, 5))
        performance_end = current_time + performance_duration

        # ============================================
        # 1. FILTER AVAILABLE PERFORMERS
        # ============================================
        available_artists = []
        available_bands = []

        # Check solo artists
        for artist_id in range(1, CONFIG["num_artists"] + 1):
            # Time availability check
            time_conflict = any(
                overlaps((current_time, performance_end), booked)
                for booked in artist_availability.get(artist_id, [])
            )
            
            # 3-year rule check
            recent_years = artist_years.get(artist_id, [])[-3:]
            year_conflict = len(recent_years) >= 3 and all(
                y in (festival_year-3, festival_year-2, festival_year-1)
                for y in recent_years
            )

            if not time_conflict and not year_conflict:
                available_artists.append(artist_id)

        # Check bands
        for band_id in range(1, CONFIG["num_bands"] + 1):
            members = [m[1] for m in data["band_artists"] if m[0] == band_id]
            band_available = True
            
            for member_id in members:
                # Time availability for each member
                if any(
                    overlaps((current_time, performance_end), booked)
                    for booked in artist_availability.get(member_id, [])
                ):
                    band_available = False
                    break
                
                # 3-year rule for each member
                recent_years = artist_years.get(member_id, [])[-3:]
                if len(recent_years) >= 3 and all(
                    y in (festival_year-3, festival_year-2, festival_year-1)
                    for y in recent_years
                ):
                    band_available = False
                    break

            if band_available:
                available_bands.append(band_id)

        # ============================================
        # 2. SELECT PERFORMER FROM AVAILABLE OPTIONS
        # ============================================
        performer_type = None
        selected_artist = None
        selected_band = None

        if available_artists or available_bands:
            # Choose performer type with 30% chance for bands if available
            if available_bands and (random.random() < 0.3 or not available_artists):
                selected_band = random.choice(available_bands)
                performer_type = 'band'
            else:
                selected_artist = random.choice(available_artists)
                performer_type = 'artist'

        # ============================================
        # 3. SCHEDULE PERFORMANCE OR ADVANCE TIME
        # ============================================
        if performer_type:
            # Add performance
            performance_data = (
                event_id, stage_id, current_time, performance_duration,
                random.randint(1, len(data["performance_types"])),
                selected_artist, selected_band
            )
            data["performances"].append(performance_data)

            # Update availability tracking
            if performer_type == 'artist':
                artist_availability[selected_artist].append((current_time, performance_end))
                artist_years[selected_artist].append(festival_year)
            else:
                members = [m[1] for m in data["band_artists"] if m[0] == selected_band]
                for member_id in members:
                    artist_availability[member_id].append((current_time, performance_end))
                    artist_years[member_id].append(festival_year)

            # Move to next time slot
            current_time = performance_end
            performance_id += 1
        else:
            # No available performers - advance time by minimum gap
            current_time += timedelta(minutes=CONFIG["min_performance_gap"])

        # Add mandatory gap between performances
        if current_time < event_end and performer_type:  # Only if we actually added a performance
            gap = timedelta(minutes=random.randrange(
                CONFIG["min_performance_gap"], 
                CONFIG["max_performance_gap"], 
                5
            ))
            current_time += gap

# Generate Visitors
for _ in range(CONFIG["num_visitors"]):
    data["visitors"].append((
        fake.first_name(),
        fake.last_name(),
        fake.phone_number() if random.random() > 0.2 else None,
        fake.unique.email(),
        fake.date_of_birth(minimum_age=13, maximum_age=80)
    ))

# Get current date for comparison
today = datetime.now()

# Generate Tickets with Capacity Constraints
for event_idx, event in enumerate(data["events"], start=1):
    stage_id = event[2]
    capacity = data["stages"][stage_id-1][3]
    max_vip = int(capacity * CONFIG["vip_capacity_percent"])
    event_date = event[3]
    
    # Create shuffled list of all possible visitors
    all_visitors = list(range(1, CONFIG["num_visitors"] + 1))
    random.shuffle(all_visitors)

    sold_vip = floor(CONFIG["percent_sold"] * max_vip)
    sold_total = floor(CONFIG["percent_sold"] * capacity)
    
    # Split into VIP and non-VIP visitors
    vip_visitors = all_visitors[:sold_vip]
    non_vip_visitors = all_visitors[sold_vip:sold_total]
    
    # Generate VIP tickets
    for visitor_id in vip_visitors:
        # Determine if ticket is used (90% chance if event is in the past)
        used = (today > event_date) and (random.random() < 0.9)
        
        data["tickets"].append((
            visitor_id,
            event_idx,
            2, # VIP ticket_category
            fake.date_time_between(
                start_date=event_date - timedelta(days=30),
                end_date=event_date
            ),
            round(random.uniform(150, 300), 2),  # Higher price for VIP
            random.randint(1, len(data["payment_methods"])),
            uuid.uuid4().hex[:20],
            used  # Add used status
        ))
    
    # Generate non-VIP tickets
    for visitor_id in non_vip_visitors:
        category = random.choices(
            [1, 3], # General and Backstage ticket_category
            weights=[0.99, 0.01],
            k=1
        )[0]
        
        # Determine if ticket is used (90% chance if event is in the past)
        used = (today > event_date) and (random.random() < 0.9)
        
        data["tickets"].append((
            visitor_id,
            event_idx,
            category,
            fake.date_time_between(
                start_date=event_date - timedelta(days=30),
                end_date=event_date
            ),
            round(random.uniform(50, 200), 2),  # Lower price range
            random.randint(1, len(data["payment_methods"])),
            uuid.uuid4().hex[:20],
            used  # Add used status
        ))

# Generate Resales
for event_id in range(1, len(data["events"]) + 1):
    # Get all tickets for this event
    event_tickets = [t for t in data["tickets"] if t[1] == event_id]
    
    # Filter for unused tickets only
    unused_tickets = [t for t in event_tickets if not t[7]]
    
    # Sellers: Randomly select from unused tickets
    sellers = random.sample(
        unused_tickets,
        min(CONFIG["resales_sellers_per_event"], len(unused_tickets))
    )
    data["resales_seller"].extend([(t[0], t[1], datetime.now()) for t in sellers])
    
    # Find all visitors without a ticket for this event
    all_visitors = set(range(1, CONFIG["num_visitors"] + 1))
    ticket_holders = {t[0] for t in event_tickets}
    eligible_buyers = list(all_visitors - ticket_holders)
    
    # Sample buyers from eligible visitors
    num_buyers = min(CONFIG["resales_buyers_per_event"], len(eligible_buyers))
    selected_buyers = random.sample(eligible_buyers, num_buyers)
    
    # Add buyers to resales
    for visitor_id in selected_buyers:
        data["resales_buyer"].append((
            visitor_id,
            event_id,
            datetime.now(),
            random.randint(1, len(data["ticket_categories"]))
        ))
    
# Generate Ratings
for performance_id, performance in enumerate(data["performances"], start=1):
    event_id = performance[0]  # performance.event_id references event.event_id
    
    attending_visitors = {
        t[0]  # visitor_id
        for t in data["tickets"] 
        if t[1] == event_id and t[7]  # t[7] is 'used' status
    }
    
    num_ratings = min(CONFIG["ratings_per_performance"], len(attending_visitors))
    rating_visitors = random.sample(list(attending_visitors), num_ratings)

    for visitor_id in rating_visitors:
        data["ratings"].append((
            visitor_id,
            performance_id,
            random.randint(1, 5),
            random.randint(1, 5),
            random.randint(1, 5),
            random.randint(1, 5),
            random.randint(1, 5)
        ))

# Generate Images
image_id = 1
entities = [
    ('festival', data["festivals"]),
    ('artist', data["artists"]),
    ('band', data["bands"]),
    ('stage', data["stages"])
]

for entity_type, collection in entities:
    for idx, _ in enumerate(collection, start=1):
        if should_add_image(idx):
            img = (
                f"https://example.com/images/{entity_type}-{idx}-{uuid.uuid4()}.jpg",
                fake.sentence()
            )
            data["images"].append(img)

            if entity_type == 'festival':
                data["festival_images"].append((idx, image_id))
            elif entity_type == 'artist':
                data["artist_images"].append((idx, image_id))
            elif entity_type == 'band':
                data["band_images"].append((idx, image_id))
            elif entity_type == 'stage':
                data["stage_images"].append((idx, image_id))

            image_id += 1

# =====================
# SQL OUTPUT
# =====================

def sql_interval(duration: timedelta) -> str:
    hours = duration.seconds // 3600
    minutes = (duration.seconds // 60) % 60
    return f"{hours} hours {minutes} minutes"

def raise_notice(s: str):
    print(f"DO $$ BEGIN RAISE NOTICE '{s}'; END $$;")
    
def batch_insert(table: str, columns: list, values: list, triggers: list = []):
    print(f"-- {table}")
    if len(values) == 0:
        print("-- No data generated for this table\n")
        return

    raise_notice(f"Inserting into {table}...")

    # Temporarily disable triggers for performace
    for trigger in triggers:
        print(f"ALTER TABLE {table} DISABLE TRIGGER {trigger};")

    # Process all values into formatted rows first
    rows = []
    for row in values:
        formatted = []
        for val in row:
            if isinstance(val, str):
                formatted.append(f"'{val}'")
            elif isinstance(val, (datetime, date, time)):
                formatted.append(f"'{val.isoformat()}'")
            elif isinstance(val, timedelta):
                formatted.append(f"'{sql_interval(val)}'")  # Keep your existing interval conversion
            elif val is None:
                formatted.append("NULL")
            else:
                formatted.append(str(val))
        rows.append(f"({', '.join(formatted)})")

    # Split into chunks
    chunk_size = CONFIG["max_rows_per_insert"]
    for i in range(0, len(rows), chunk_size):
        chunk = rows[i:i + chunk_size]
        print(f"INSERT INTO {table} ({', '.join(columns)}) VALUES")
        print(",\n".join(chunk) + ";\n")

    for trigger in triggers:
        print(f"ALTER TABLE {table} ENABLE TRIGGER {trigger};")

    raise_notice(f"Inserting into {table}... done!")

    print()  # Add final newline separator

print("BEGIN;")

batch_insert("continent", ["continent_id", "name"], data["continents"])
batch_insert("performance_type", ["performance_type_id", "name"], data["performance_types"])
batch_insert("experience", ["experience_id", "name"], data["experiences"])
batch_insert("ticket_category", ["ticket_category_id", "name"], data["ticket_categories"])
batch_insert("payment_method", ["payment_method_id", "name"], data["payment_methods"])
batch_insert("job", ["job_id", "name"], data["jobs"])
batch_insert("location", ["address", "longitude", "latitude", "city", "country", "continent_id"], data["locations"])
batch_insert("stage", ["location_id", "name", "description", "capacity"], data["stages"])
batch_insert("festival", ["name", "begin_date", "end_date", "location_id"], data["festivals"])
batch_insert("stage_equipment", ["stage_id", "equipment"], data["stage_equipment"])
batch_insert("personnel", ["job_id", "first_name", "last_name", "birth_date", "experience_id", "email"], data["personnel"])
batch_insert("genre", ["name"], data["genres"])
batch_insert("subgenre", ["genre_id", "name"], data["subgenres"])
batch_insert("artist", ["first_name", "last_name", "nickname", "birth_date", "email", "website", "instagram"], data["artists"])
batch_insert("band", ["name", "established", "email", "website", "instagram"], data["bands"])
batch_insert("band_artist", ["band_id", "artist_id"], data["band_artists"])
batch_insert("artist_subgenre", ["artist_id", "genre_id", "subgenre_name"], data["artist_subgenres"])
batch_insert("band_subgenre", ["band_id", "genre_id", "subgenre_name"], data["band_subgenres"])


batch_insert(
    "event", 
    ["title", "festival_id", "stage_id", "date_time", "duration"], 
    data["events"], 
    ["trigger_personnel_requirements_on_event"])

batch_insert(
    "event_personnel", 
    ["event_id", "personnel_id"], 
    data["event_personnel"],
    ["trigger_personnel_requirements_on_personnel"])

batch_insert(
    "performance", 
    ["event_id", "stage_id", "date_time", "duration", "performance_type_id", "artist_id", "band_id"],
    data["performances"])

batch_insert(
    "visitor", 
    ["first_name", "last_name", "phone_number", "email", "birth_date"], 
    data["visitors"])

batch_insert(
    "ticket", 
    ["visitor_id", "event_id", "ticket_category_id", "purchase_date_time", "price", "payment_method_id", "barcode", "used"], 
    data["tickets"],
    ["trigger_limit_ticket_count_on_insert"])

batch_insert(
    "resales_buyer", 
    ["visitor_id", "event_id", "date_time", "ticket_category_id"],
    data["resales_buyer"])

batch_insert(
    "resales_seller", 
    ["visitor_id", "event_id", "date_time"], 
    data["resales_seller"])

batch_insert(
    "rating",
    ["visitor_id", "performance_id", "artist_performance", "sound_lighting", "stage_presence", "organization", "overall_impression"],
    data["ratings"])

batch_insert("images", ["link", "description"], data["images"])
batch_insert("festival_image", ["festival_id", "image_id"], data["festival_images"])
batch_insert("artist_image", ["artist_id", "image_id"], data["artist_images"])
batch_insert("band_image", ["band_id", "image_id"], data["band_images"])
batch_insert("stage_image", ["stage_id", "image_id"], data["stage_images"])

# Commit the transaction
print("COMMIT;")
