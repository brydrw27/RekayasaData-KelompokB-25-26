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

-- =========================
-- 3. FIX TIMESTAMP (ANTI ERROR)
-- =========================

-- convert format campuran / dan -
UPDATE music_listening_logs
SET listen_timestamp = 
    CASE
        -- format: 2025/09/02 21:05:00
        WHEN listen_timestamp LIKE '____/__/__ %' THEN 
            STR_TO_DATE(listen_timestamp, '%Y/%m/%d %H:%i:%s')

        -- format: 2025-09-02 21:05:00
        WHEN listen_timestamp LIKE '____-__-__ %' THEN 
            STR_TO_DATE(listen_timestamp, '%Y-%m-%d %H:%i:%s')

        -- format: 03/09/2025 00:03
        WHEN listen_timestamp LIKE '__/__/____ %' THEN 
            STR_TO_DATE(listen_timestamp, '%d/%m/%Y %H:%i')

        ELSE NULL
    END;

-- =========================
-- 4. BUAT TABEL CLEAN
-- =========================

DROP TABLE IF EXISTS clean_logs;

CREATE TABLE clean_logs AS
SELECT 
    l.log_id,
    u.user_id,
    u.username,
    s.song_id,
    s.title,
    s.artist_name,
    s.genre_text,
    l.event_type,
    l.listen_timestamp,
    l.duration_seconds
FROM music_listening_logs l
JOIN music_users u ON l.user_name = u.username
JOIN music_songs s ON l.song_title = s.title;

-- =========================
-- 🔍 CEK DATA
-- =========================
SELECT * FROM clean_logs;

-- =========================
-- 📊 JAWAB SOAL
-- =========================

-- 1. Genre paling sering diputar
SELECT genre_text, COUNT(*) AS total_play
FROM clean_logs
WHERE event_type = 'play'
GROUP BY genre_text
ORDER BY total_play DESC;

-- 2. Artis dengan pemutaran terbanyak
SELECT artist_name, COUNT(*) AS total_play
FROM clean_logs
WHERE event_type = 'play'
GROUP BY artist_name
ORDER BY total_play DESC;

-- 3. Distribusi waktu (per jam)
SELECT HOUR(listen_time) AS jam, COUNT(*) AS jumlah
FROM clean_logs
WHERE event_type = 'play'
GROUP BY jam
ORDER BY jam;

-- 4. User paling aktif
SELECT username, COUNT(*) AS total_activity
FROM clean_logs
GROUP BY username
ORDER BY total_activity DESC;

-- 5. Aktivitas tidak wajar
SELECT *
FROM clean_logs
WHERE duration_seconds <= 5 
   OR duration_seconds > 3600;