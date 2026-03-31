-- Tugas 1 Rekayasa Data

-- Number 1
-
-- Number 2

-- Number 3
SELECT NPM, KodeMK, Semester, COUNT(*) AS jumlah
FROM krs
GROUP BY NPM, KodeMK, Semester
HAVING COUNT(*) > 1;

-- Number 4

-- Number 5

-- Number 6

-- Number 7

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