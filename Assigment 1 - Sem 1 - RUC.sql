--1
SELECT name
FROM instructor
WHERE dept_name='Biology';

--2
SELECT title
FROM course
WHERE dept_name='Comp. Sci.' and credits=3;

--3
SELECT DISTINCT course_id, title
FROM takes natural join course
WHERE id='30397'
ORDER BY course_id;

--4
SELECT course_id,title, sum(credits)
FROM takes natural join course
WHERE id='30397'
GROUP BY course_id, title;

--5
SELECT id, sum(credits)
FROM takes NATURAL JOIN course
GROUP BY id
HAVING sum(credits) > 85;

--6
-- Did not work with natural join because it was joining based on dept_name as well
-- Better to specify explicit join with ON or in WHERE clause
SELECT DISTINCT name
FROM student s 
JOIN takes t ON s.id = t.id
JOIN course c ON t.course_id = c.course_id
WHERE c.dept_name='Languages' AND grade='A+'
ORDER BY name;

--7
(SELECT id
FROM instructor
WHERE dept_name = 'Marketing')
EXCEPT(
SELECT id
FROM instructor NATURAL JOIN teaches
WHERE dept_name = 'Marketing');

--8
(SELECT id, name
FROM instructor
WHERE dept_name = 'Marketing')
EXCEPT(
SELECT id, name
FROM instructor NATURAL JOIN teaches
WHERE dept_name = 'Marketing');

--9
SELECT course_id, sec_id, year, semester, count(id) as num
FROM section NATURAL JOIN takes
WHERE year = 2009
GROUP BY course_id, sec_id, year, semester;

--10
SELECT max(sectionEnrollments.num), min(sectionEnrollments.num)
FROM (
SELECT count(id) as num
FROM section NATURAL JOIN takes
GROUP BY course_id, sec_id, year, semester) sectionEnrollments;

--11
WITH 
max_enroll(value) as 
(SELECT max(sectionEnrollments.num)
FROM (
SELECT count(id) as num
FROM section NATURAL JOIN takes
GROUP BY course_id, sec_id, year, semester) sectionEnrollments),

list(course_id, sec_id, year, semester,num) as (
SELECT course_id, sec_id, year, semester, count(id) as num
FROM section NATURAL JOIN takes
GROUP BY course_id, sec_id, year, semester)

SELECT course_id, sec_id, semester, year, num
FROM max_enroll, list
WHERE max_enroll.value = list.num;

--12
SELECT max(sectionEnrollments.num), min(sectionEnrollments.num)
FROM (
SELECT count(id) as num
FROM section NATURAL LEFT OUTER JOIN takes
GROUP BY course_id, sec_id, year, semester) sectionEnrollments;

--13
SELECT id, course_id, sec_id, semester, year
FROM instructor NATURAL JOIN teaches NATURAL LEFT OUTER JOIN course
WHERE id='19368';

--14
SELECT id
FROM instructor as I
WHERE NOT EXISTS(

(SELECT course_id
FROM instructor NATURAL JOIN teaches NATURAL LEFT OUTER JOIN course
WHERE id='19368')
EXCEPT
(SELECT T.course_id
FROM teaches as T
WHERE I.id = T.id));

--15
INSERT INTO student
SELECT id, name, dept_name, 0
FROM instructor
WHERE id NOT IN (SELECT id FROM student);

--16
DELETE FROM student
WHERE id in(
SELECT id FROM instructor
WHERE id in (SELECT id from student where tot_cred=0));

--17
SELECT id, tot_cred , sum(credits)
FROM student NATURAL JOIN takes JOIN course USING (course_id)
GROUP BY id
HAVING tot_cred = sum(credits);

--18
--HAVE NOT TESTED THIS ONE AND CHEATED W AI
UPDATE student s
SET tot_cred = (
    SELECT CASE 
               WHEN SUM(c.credits) IS NULL THEN 0 
               ELSE SUM(c.credits) 
           END
    FROM takes t
    JOIN course c ON t.course_id = c.course_id
    WHERE t.id = s.id
    GROUP BY t.id
);
/*
--APPARENTLY THIS CAN DO THE SAME
UPDATE student s
SET tot_cred = (
    SELECT COALESCE(SUM(c.credits), 0)
    FROM takes t
    JOIN course c ON t.course_id = c.course_id
    WHERE t.id = s.id
    GROUP BY t.id
);
*/
--19
SELECT id, tot_cred , sum(credits)
FROM student NATURAL JOIN takes JOIN course USING (course_id)
GROUP BY id
HAVING tot_cred <> sum(credits);

--20
-- CHEATED AS WELL
UPDATE instructor i
SET salary = 29001 + 10000 * (
    SELECT COUNT(*)
    FROM teaches t
    WHERE t.id = i.id
);

--21
SELECT id, name, salary
FROM instructor
ORDER BY name LIMIT 10;