-- =========================
-- 0. PAKAI SCHEMA
-- =========================
USE spotify;

SET SQL_SAFE_UPDATES = 0;

-- =========================
-- 1. STANDARDISASI GENRE
-- =========================
-- step 1: lowercase + bersihin dash/strip biar konsisten
UPDATE music_songs
SET genre_text = LOWER(REPLACE(genre_text, '-', ' '));

-- step 2: standardisasi ke 5 kategori utama
UPDATE music_songs
SET genre_text = 
    CASE 
        -- POP (termasuk indie pop, pop indonesia, dll)
        WHEN genre_text LIKE '%pop%' THEN 'pop'

        -- ROCK (alt rock, alternative rock, rock alternatif, dll)
        WHEN genre_text LIKE '%rock%' 
             OR genre_text LIKE '%alternatif%' 
             OR genre_text LIKE '%alternative%' THEN 'rock'

        -- ELECTRONIC (edm, electronic)
        WHEN genre_text LIKE '%electronic%' 
             OR genre_text LIKE '%edm%' THEN 'electronic'

        -- ACOUSTIC (handle typo accoustic juga)
        WHEN genre_text LIKE '%acoustic%' 
             OR genre_text LIKE '%accoustic%' THEN 'acoustic'

        -- OTHER (sisanya)
        ELSE 'other'
    END;

-- =========================
-- 2. NORMALISASI EVENT
-- =========================
UPDATE music_listening_logs
SET event_type = 
    CASE
        WHEN LOWER(REPLACE(REPLACE(TRIM(event_type), '_', ' '), '-', ' ')) IN 
             ('play', 'Play', 'PLAY_SONG', 'listen', 'start')
        THEN 'play'
        ELSE 'other'
    END;
    SELECT event_type, COUNT(*) 
FROM music_listening_logs
GROUP BY event_type;