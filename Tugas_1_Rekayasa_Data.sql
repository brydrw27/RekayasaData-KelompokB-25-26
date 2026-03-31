-- Tugas 1 Rekayasa Data

-- Number 1
-
-- Number 2
SELECT * FROM`tugas1rekdat` .mahasiswa 
WHERE NPM IS NULL 
   OR Nama IS NULL 
   OR Angkatan IS NULL 
   OR Prodi IS NULL 
   OR IPK IS NULL;
   
SELECT * FROM`tugas1rekdat` .dosen 
WHERE NIDN IS NULL 
   OR NamaDosen IS NULL 
   OR Prodi IS NULL;
   
SELECT * FROM`tugas1rekdat` .krs 
WHERE NPM IS NULL 
   OR KodeMK IS NULL 
   OR Semester IS NULL 
   OR Nilai IS NULL;
   
SELECT * FROM`tugas1rekdat` .mata_kuliah 
WHERE KodeMK IS NULL 
   OR NamaMK IS NULL 
   OR SKS IS NULL 
   OR Prodi IS NULL;
   
-- Number 3
SELECT NPM, KodeMK, Semester, COUNT(*) AS jumlah
FROM krs
GROUP BY NPM, KodeMK, Semester
HAVING COUNT(*) > 1;

-- Number 4

-- Number 5

-- Number 6

-- Number 7 untuk prodi
SELECT 
    Prodi, 
    COUNT(*) AS Frekuensi
FROM 
    mahasiswa
GROUP BY 
    Prodi
ORDER BY 
    Frekuensi DESC;

-- Number 7 untuk prodi dosen
SELECT 
    Prodi, 
    COUNT(*) AS Frekuensi
FROM 
    dosen
GROUP BY 
    Prodi
ORDER BY 
    Frekuensi DESC;

-- Number 7 untuk prodi mata kuliah
SELECT 
    Prodi, 
    COUNT(*) AS Frekuensi
FROM 
    mata_kuliah
GROUP BY 
    Prodi
ORDER BY 
    Frekuensi DESC;

-- Number 7 untuk nilai
SELECT 
    Nilai, 
    COUNT(*) AS Frekuensi
FROM 
    krs
GROUP BY 
    Nilai
ORDER BY 
    CASE 
        WHEN Nilai = 'A' THEN 1
        WHEN Nilai = 'A-' THEN 2
        WHEN Nilai = 'B+' THEN 3
        WHEN Nilai = 'B' THEN 4
        WHEN Nilai = 'C+' THEN 5
        WHEN Nilai = 'C' THEN 6
        ELSE 7 
    END;
    
-- Number 7 untuk angkatan
SELECT 
    Angkatan, 
    COUNT(*) AS Frekuensi
FROM 
    mahasiswa
GROUP BY 
    Angkatan
ORDER BY 
    Angkatan ASC;
    
-- Number 7 untuk sks
SELECT 
    SKS, 
    COUNT(*) AS Frekuensi
FROM 
    mata_kuliah
GROUP BY 
    SKS
ORDER BY 
    SKS ASC;
    
-- Number 7 untuk semester
SELECT 
    Semester, 
    COUNT(*) AS Frekuensi
FROM 
    krs
GROUP BY 
    Semester
ORDER BY 
    Semester ASC;
    
-- Number 7 untuk kodemk
SELECT 
    'KRS' AS KodeMK, 
    COUNT(*) AS Frekuensi
FROM 
    krs;

-- Number 8
SELECT *
FROM mahasiswa
WHERE IPK > (
    SELECT AVG(IPK)
    FROM mahasiswa
);

-- Number 9
SELECT *
FROM tugas1.mahasiswa m
JOIN tugas1.krs k ON m.NPM = k.NPM
JOIN tugas1.mata_kuliah mk ON k.KodeMK = mk.KodeMK;
SELECT m.NPM
FROM tugas1.mahasiswa m
JOIN tugas1.krs k ON m.NPM = k.NPM
JOIN tugas1.mata_kuliah mk ON k.KodeMK = mk.KodeMK
WHERE m.Prodi <> mk.Prodi;

-- Number 10

-- Number 11

-- Number 12
SELECT DISTINCT mahasiswa.Nama
FROM mahasiswa
JOIN krs ON mahasiswa.NPM = krs.NPM
JOIN mata_kuliah ON krs.KodeMK = mata_kuliah.KodeMK
WHERE mata_kuliah.SKS = (SELECT MAX(SKS) FROM mata_kuliah);

SELECT DISTINCT mahasiswa.Nama, mata_kuliah.NamaMK, mata_kuliah.SKS
FROM mahasiswa
JOIN krs ON mahasiswa.NPM = krs.NPM
JOIN mata_kuliah ON krs.KodeMK = mata_kuliah.KodeMK
WHERE mata_kuliah.SKS = (SELECT MAX(SKS) FROM mata_kuliah);

-- Number 13
SELECT Nama
FROM mahasiswa
WHERE NPM NOT IN (
    SELECT NPM
    FROM krs
    WHERE KodeMK = 'IF101'
);

-- Number 14
SELECT m.Nama
FROM tugas1.mahasiswa m
JOIN tugas1.krs k ON m.NPM = k.NPM
JOIN tugas1.mata_kuliah mk ON k.KodeMK = mk.KodeMK
GROUP BY m.NPM, m.Nama
HAVING MIN(mk.SKS) = 3 AND MAX(mk.SKS) = 3;

-- Number 15

-- Number 16

-- Number 17
SELECT 
    (COUNT(CASE WHEN t1.jml_mk > t2.ref_mk THEN 1 END) * 100.0 / (SELECT COUNT(*) FROM mahasiswa)) AS Persentase
FROM 
    (SELECT NPM, COUNT(*) as jml_mk FROM krs GROUP BY NPM) t1,
    (SELECT MAX(jml_ref) as ref_mk FROM (
        SELECT COUNT(*) as jml_ref 
        FROM krs k 
        JOIN mahasiswa m ON k.NPM = m.NPM 
        WHERE m.IPK = (SELECT MAX(IPK) FROM mahasiswa)
        GROUP BY k.NPM
    ) as sub_ref) t2;

-- Number 18
SELECT 
(
    SELECT COUNT(DISTINCT m.NPM)
    FROM mahasiswa m
    JOIN krs k ON m.NPM = k.NPM
    JOIN mata_kuliah mk ON k.KodeMK = mk.KodeMK
    WHERE m.Prodi <> mk.Prodi
)
/
(
    SELECT COUNT(*) FROM mahasiswa
) AS proporsi_lintas_prodi;

-- Number 19
-
-- Number 20