\timing
-- GROUP: cit11, MEMBERS: Ida Hay Jørgensen, Julius Krüger Madsen, Marek Laslo, Sofus Hilfling Nielsen
-- 1
SELECT "name" 
FROM instructor 
WHERE dept_name = 'Biology';

-- 2
SELECT title 
FROM course 
WHERE dept_name = 'Comp. Sci.' AND credits = 3;

-- 3
SELECT DISTINCT course_id, title 
FROM takes
NATURAL JOIN course
WHERE id = '30397';

-- 4
SELECT course_id, title, SUM(credits) 
FROM takes
NATURAL JOIN course
WHERE id = '30397'
GROUP BY course_id, title;

-- 5
SELECT id, SUM(credits) 
FROM takes
NATURAL JOIN course
GROUP BY id
HAVING SUM(credits) > 85;

-- 6
SELECT DISTINCT "name" 
FROM student
NATURAL JOIN takes
JOIN course USING(course_id) 
WHERE grade = 'A+' 
  AND course.dept_name = 'Languages';

-- 7
(SELECT id 
  FROM instructor 
  WHERE dept_name = 'Marketing')
EXCEPT 
(SELECT id 
  FROM teaches);

-- 8
SELECT id, "name" 
FROM instructor
NATURAL LEFT JOIN teaches
WHERE course_id IS NULL 
  AND dept_name = 'Marketing';

-- 9
SELECT course_id, sec_id, semester, "year", COUNT(*) AS num 
FROM takes
NATURAL JOIN "section"
GROUP BY course_id, sec_id, semester, "year"
HAVING "year" = 2009;

-- 10
WITH
  takes_count AS
    (SELECT COUNT(*) AS total 
    FROM takes
    GROUP BY course_id, sec_id, semester, "year")
SELECT MAX(total), MIN(total) 
FROM takes_count;

-- 11
WITH
  takes_count AS
    (SELECT course_id, sec_id, semester, "year", COUNT(*) AS total 
    FROM takes
    NATURAL JOIN "section"
    GROUP BY course_id, sec_id, semester, "year"),
  max_takes AS
    (SELECT MAX(total) 
    FROM takes_count)
SELECT course_id, sec_id, semester, "year", total AS sum 
FROM takes_count, max_takes
WHERE total = "max";

-- 12
WITH
  takes_count AS
    (SELECT COUNT(id) AS total 
    FROM takes
    NATURAL RIGHT JOIN "section"
    GROUP BY course_id, sec_id, semester, "year")
SELECT MAX(total), MIN(total) 
FROM takes_count;

-- 13
SELECT id, course_id, sec_id, semester, "year" 
FROM teaches
WHERE id = '19368';

-- 14
SELECT DISTINCT id 
FROM teaches
WHERE course_id IN (
  SELECT course_id 
  FROM teaches 
  WHERE id = '19368');

-- 15
INSERT INTO student (id, "name", dept_name, tot_cred)
SELECT id, "name", dept_name, 0 AS tot_cerd 
FROM instructor
WHERE id NOT IN (
  SELECT id 
  FROM student);

-- 16
DELETE FROM student 
WHERE id IN (
    SELECT id 
    FROM instructor)
  AND tot_cred = 0;

-- 17
SELECT id, tot_cred, SUM(credits)
FROM student 
NATURAL JOIN takes 
JOIN course USING(course_id)
GROUP BY id
HAVING tot_cred = SUM(credits);

-- 18
UPDATE student AS s
SET tot_cred = (
    SELECT SUM(credits) 
    FROM takes AS t
    NATURAL JOIN course
    WHERE s.id = t.id
    GROUP BY id);

-- 19
SELECT id, tot_cred, SUM(credits)
FROM student 
NATURAL JOIN takes 
JOIN course USING(course_id)
GROUP BY id
HAVING tot_cred != SUM(credits);

-- 20
UPDATE instructor AS i
SET salary = 29001 + 10000 * 
  (SELECT COUNT(sec_id) 
    FROM instructor AS i2
    NATURAL LEFT JOIN teaches
    NATURAL LEFT JOIN "section"
    WHERE i.id = i2.id
    GROUP BY id);

-- 21
SELECT "name", salary 
FROM instructor
ORDER BY "name"
LIMIT 10;
