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
   
-- Modifikasi Data log
-- ==========================================
-- 1. INSERT DATA SINTESIS (28 BARIS BARU)
-- Fokus pada event 'like' dan 'save'
-- ==========================================

INSERT INTO music_listening_logs (log_id, user_name, song_title, event_type, listen_timestamp, duration_seconds)
VALUES 
(73, 'andi_music', 'City Lights', 'like', '2025-09-04 08:15:00', 0),
(74, 'kiki_song', 'Langit Senja', 'SAVE', '2025/09/04 08:20:00', 0),
(75, 'hana_l', 'Pulse', 'Liked', '04/09/2025 08:30', 0),
(76, 'indra99', 'Broken Roads', 'save_song', '2025-09-04 09:10:00', 0),
(77, 'dewii', 'Silent Echo', 'Like', '2025-09-04 09:15:00', 0),
(78, 'eko_stream', 'Rindu Malam', 'saved', '2025-09-04 09:25:00', 0),
(79, 'budi88', 'City Lights', 'LIKE', '2025-09-04 10:05:00', 0),
(80, 'citra.id', 'Pulse', 'save', '04/09/2025 10:15', 0),
(81, 'linaaudio', 'Langit Senja', 'like', '2025/09/04 10:45:00', 0),
(82, 'andi_music', 'Midnight Drive', 'SAVE_SONG', '2025-09-04 11:00:00', 0),
(83, 'kiki_song', 'Broken Roads', 'Liked', '2025-09-04 11:30:00', 0),
(84, 'hana_l', 'City Lights', 'save', '2025-09-04 12:15:00', 0),
(85, 'indra99', 'Silent Echo', 'like', '04/09/2025 13:00', 0),
(86, 'dewii', 'Langit Senja', 'Saved', '2025-09-04 13:20:00', 0),
(87, 'eko_stream', 'Pulse', 'Like', '2025/09/04 14:10:00', 0),
(88, 'budi88', 'Broken Roads', 'save', '2025-09-04 15:05:00', 0),
(89, 'citra.id', 'Silent Echo', 'like', '2025-09-04 15:30:00', 0),
(90, 'linaaudio', 'City Lights', 'save_song', '04/09/2025 16:00', 0),
(91, 'andi_music', 'Rindu Malam', 'Like', '2025-09-04 16:45:00', 0),
(92, 'kiki_song', 'Pulse', 'saved', '2025-09-04 17:15:00', 0),
(93, 'hana_l', 'Broken Roads', 'LIKE', '2025/09/04 18:00:00', 0),
(94, 'indra99', 'City Lights', 'save', '2025-09-04 19:10:00', 0),
(95, 'dewii', 'Midnight Drive', 'like', '2025-09-04 19:40:00', 0),
(96, 'eko_stream', 'Langit Senja', 'SAVE', '04/09/2025 20:05', 0),
(97, 'budi88', 'Pulse', 'Liked', '2025-09-04 21:00:00', 0),
(98, 'citra.id', 'Broken Roads', 'save', '2025-09-04 21:30:00', 0),
(99, 'linaaudio', 'Silent Echo', 'like', '2025/09/04 22:15:00', 0),
(100, 'andi_music', 'Langit Senja', 'Saved', '2025-09-04 23:00:00', 0);

-- ==========================================
-- 2. NORMALISASI EVENT (TERMASUK LIKE & SAVE)
-- ==========================================
UPDATE music_listening_logs
SET event_type = 
    CASE
        -- Kelompok PLAY
        WHEN LOWER(REPLACE(REPLACE(TRIM(event_type), '_', ' '), '-', ' ')) IN 
             ('play', 'play song', 'listen', 'start') THEN 'play'
        
        -- Kelompok LIKE
        WHEN LOWER(REPLACE(REPLACE(TRIM(event_type), '_', ' '), '-', ' ')) IN 
             ('like', 'liked') THEN 'like'
             
        -- Kelompok SAVE
        WHEN LOWER(REPLACE(REPLACE(TRIM(event_type), '_', ' '), '-', ' ')) IN 
             ('save', 'save song', 'saved') THEN 'save'
             
        -- Biarkan teks aslinya (jangan diubah jadi 'other') jika tidak ada yang cocok
        ELSE event_type 
    END;


-- ==========================================
-- 3. FIX TIMESTAMP 
-- (Asumsi jika belum dijalankan sebelumnya)
-- ==========================================
UPDATE music_listening_logs
SET listen_timestamp = 
    CASE
        WHEN listen_timestamp LIKE '____/__/__ %' THEN STR_TO_DATE(listen_timestamp, '%Y/%m/%d %H:%i:%s')
        WHEN listen_timestamp LIKE '____-__-__ %' THEN STR_TO_DATE(listen_timestamp, '%Y-%m-%d %H:%i:%s')
        WHEN listen_timestamp LIKE '__/__/____ %' THEN STR_TO_DATE(listen_timestamp, '%d/%m/%Y %H:%i')
        ELSE listen_timestamp -- Biarkan jika sudah dalam format datetime
    END;


-- ==========================================
-- 4. BUAT TABEL CLEAN (MODIFIED)
-- ==========================================
DROP TABLE IF EXISTS clean_logs_modified;

CREATE TABLE clean_logs_modified AS
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