USE travel_app_db;

-- Ensure dummy user exists
INSERT IGNORE INTO travellers (email, name, membership_tier, is_admin) 
VALUES ('demo_ad_data@example.com', 'Demo User', 'Premium', 0);

-- Get ID (variable not supported in simple source, so using subquery)
SET @uid = (SELECT id FROM travellers WHERE email = 'demo_ad_data@example.com' LIMIT 1);

INSERT INTO itineraries (
    traveller_id, title, destination, start_date, end_date, 
    short_description, detail_description
) VALUES 
(
    @uid, 'Cyberpunk Adventures in Tokyo', 'Tokyo', '2025-04-01', '2025-04-10', 
    'Neon lights, sushi, and ancient temples.', 
    'Day 1: Arrival in Narita, check-in at Shinjuku Godzilla Hotel.\nDay 2: Explore Akihabara electric town and manga shops.\nDay 3: Visit Senso-ji Temple in Asakusa and Skytree.\nDay 4: Day trip to Hakone for hot springs.\nDay 5: Shibuya Crossing and Harajuku fashion street.\nDay 6: Tsukiji Outer Market sushi breakfast.\nDay 7: TeamLab Planets digital art museum.\nDay 8: Ghibli Museum in Mitaka.\nDay 9: Shopping in Ginza.\nDay 10: Departure.'
),
(
    @uid, 'Romantic Getaway in Paris', 'Paris', '2025-05-12', '2025-05-20', 
    'Eiffel Tower, Louvre, and Croissants.', 
    'A week in the city of love.\n\nHighlights:\n- Sunset picnic at Eiffel Tower\n- Louvre Museum tour (Mona Lisa)\n- Boat cruise on the Seine River\n- Montmartre artists village\n- Day trip to Palace of Versailles\n- Shopping at Champs-Élysées'
),
(
    @uid, 'Big Apple Burst', 'New York', '2025-06-15', '2025-06-22', 
    'Manhattan skyscrapers and Broadway shows.', 
    'Experiencing the energy of NYC.\n\n- Walk the Brooklyn Bridge\n- Statue of Liberty ferry\n- Central Park cycling\n- Times Square at night\n- Broadway show (The Lion King)\n- Top of the Rock observation deck'
),
(
    @uid, 'London Royal Tour', 'London', '2025-07-10', '2025-07-18', 
    'History, tea, and the Royals.', 
    'Exploring the heart of the UK.\n\n- Buckingham Palace Changing of the Guard\n- British Museum\n- Tower of London and Crown Jewels\n- London Eye\n- Afternoon Tea at The Ritz\n- Harry Potter Warner Bros Studio Tour'
),
(
    @uid, 'Swiss Alps Hiking', 'Zurich', '2025-08-01', '2025-08-10', 
    'Mountains, chocolates, and lakes.', 
    'Nature retreat in Switzerland.\n\n- Old Town Zurich\n- Train to Lucerne\n- Mount Pilatus cable car\n- Interlaken adventure sports\n- Jungfraujoch - Top of Europe\n- Bern old city'
),
(
    @uid, 'Tropical Bali Escape', 'Bali', '2025-09-05', '2025-09-15', 
    'Beaches, temples, and yoga.', 
    'Relaxing in Island of Gods.\n\n- Ubud Monkey Forest\n- Rice Terraces in Tegalalang\n- Uluwatu Temple sunset dance\n- Seminyak beach clubs\n- Nusa Penida day trip'
);
