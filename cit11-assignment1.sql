\timing
-- GROUP: cit11 
-- MEMBERS: 
-- <Ida Hay Jørgensen	stud-ijoergense@ruc.dk> 
-- <Julius Krüger Madsen	stud-juliusm@ruc.dk>
-- <Marek Laslo	stud-laslo@ruc.dk> 
-- <Sofus Hilfling Nielsen	stud-sofusn@ruc.dk>


-- 1.
select name from instructor where dept_name = 'Biology';

-- 2.
select title from course where credits = 3 and dept_name = 'Comp. Sci.';

-- 3.
select c.course_id, c.title from takes t join course c on t.course_id = c.course_id where t.id = '30397';

-- 4.
SELECT c.course_id, c.title, SUM(c.credits) AS sum FROM takes t JOIN course c ON t.course_id = c.course_id WHERE t.id = '30397' GROUP BY c.course_id, c.title;

-- 5.
SELECT t.id, SUM(c.credits) AS sum FROM takes t JOIN course c ON t.course_id = c.course_id GROUP BY t.id HAVING SUM(c.credits) > 85;

-- 6.
SELECT s.name FROM student s JOIN takes t ON s.id = t.id JOIN course c ON c.course_id = t.course_id WHERE t.grade = 'A+' AND c.dept_name = 'Languages';

-- 7.
SELECT i.id FROM instructor i LEFT OUTER JOIN teaches t ON i.id = t.id WHERE t.id IS NULL;

-- 8.
SELECT i.id, i.name FROM instructor i LEFT OUTER JOIN teaches t ON i.id = t.id WHERE t.id IS NULL;

-- 9.
SELECT s.course_id, s.sec_id, s.semester, s.year, COUNT(t.ID) AS num FROM section s JOIN takes t ON s.course_id = t.course_id AND s.sec_id = t.sec_id AND s.year = t.year AND s.semester = t.semester WHERE s.year = '2009' GROUP BY s.course_id, s.sec_id, s.semester, s.year HAVING COUNT(t.ID) > 0;

-- 10.
WITH section_enrollment AS (
    SELECT course_id, sec_id, semester, year, COUNT(id) AS num
    FROM takes
    GROUP BY course_id, sec_id, semester, year
    HAVING COUNT(id) > 0
)
SELECT MAX(num), MIN(num)
FROM section_enrollment;

-- 11.
WITH section_enrollment AS (
    SELECT course_id, sec_id, semester, year, COUNT(id) AS num
    FROM takes
    GROUP BY course_id, sec_id, semester, year
)
SELECT course_id, sec_id, semester, year, num
FROM section_enrollment
WHERE num = (SELECT MAX(num) FROM section_enrollment);

-- 12.
WITH section_enrollment AS (
    SELECT s.course_id, s.sec_id, s.semester, s.year, COUNT(t.id) AS num
    FROM section s
    LEFT JOIN takes t ON s.course_id = t.course_id AND s.sec_id = t.sec_id 
                      AND s.semester = t.semester AND s.year = t.year
    GROUP BY s.course_id, s.sec_id, s.semester, s.year
)
SELECT MAX(num), MIN(num)
FROM section_enrollment;

-- 13.
SELECT id, course_id, sec_id, semester, year
FROM teaches
WHERE id = '19368';

-- 14.
WITH instructor_courses AS (
    SELECT course_id, sec_id, semester, year
    FROM teaches
    WHERE id = '19368'
)
SELECT t.id
FROM teaches t
WHERE NOT EXISTS (
    SELECT course_id, sec_id, semester, year
    FROM instructor_courses
    EXCEPT
    SELECT course_id, sec_id, semester, year
    FROM teaches t2
    WHERE t.id = t2.id
)
GROUP BY t.id;

-- 15.
INSERT INTO student (id, name, dept_name, tot_cred)
SELECT id, name, dept_name, 0
FROM instructor
WHERE id NOT IN (SELECT id FROM student);

-- 16.
DELETE FROM student
WHERE id IN (
    SELECT id FROM instructor
) AND tot_cred = 0 AND id NOT IN (
    SELECT id FROM takes
);

-- 17.
WITH student_total_credits AS (
    SELECT s.id, SUM(c.credits) AS sum_credits
    FROM student s
    JOIN takes t ON s.id = t.id
    JOIN course c ON t.course_id = c.course_id
    GROUP BY s.id
)
SELECT s.id, s.tot_cred, stc.sum_credits
FROM student s
JOIN student_total_credits stc ON s.id = stc.id
WHERE s.tot_cred = stc.sum_credits;

-- 18.
WITH student_total_credits AS (
    SELECT s.id, SUM(c.credits) AS sum_credits
    FROM student s
    JOIN takes t ON s.id = t.id
    JOIN course c ON t.course_id = c.course_id
    GROUP BY s.id
)
UPDATE student
SET tot_cred = stc.sum_credits
FROM student_total_credits stc
WHERE student.id = stc.id;

-- 19.
WITH student_total_credits AS (
    SELECT s.id, SUM(c.credits) AS sum_credits
    FROM student s
    JOIN takes t ON s.id = t.id
    JOIN course c ON t.course_id = c.course_id
    GROUP BY s.id
)
SELECT s.id, s.tot_cred, stc.sum_credits
FROM student s
JOIN student_total_credits stc ON s.id = stc.id
WHERE s.tot_cred <> stc.sum_credits;

-- 20.
WITH instructor_section_count AS (
    SELECT id, COUNT(*) AS section_count
    FROM teaches
    GROUP BY id
)
UPDATE instructor
SET salary = 29001 + (section_count * 10000)
FROM instructor_section_count isc
WHERE instructor.id = isc.id;

-- 21.
SELECT id, name, salary
FROM instructor
ORDER BY name
LIMIT 10;
