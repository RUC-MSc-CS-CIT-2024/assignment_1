-- 1. Find the names of all the instructors from Biology department.
SELECT name
FROM instructor
WHERE dept_name = 'Biology';

-- 2. Find the names of courses in Computer science department which have 3 credits.
SELECT title
FROM course
WHERE dept_name = 'Comp. Sci.' AND credits = 3;

-- 3. For the student with ID 30397, show all course_id and title of all courses registered for by the student.
-- Note: Via Natual join due to the same column course_id, using distinct not to have duplicates( to make it look like the result then add a ORDER BY. 
SELECT DISTINCT course_id, course.title
FROM course
NATURAL JOIN takes
WHERE takes.id = '30397' 
ORDER BY course.course_id ASC;

-- 4. As above, but show the total number of credits for such courses (taken by that student).
-- Don't display the tot_creds value from the student table, you should use SQL aggregation on courses taken by the student.
-- Note: Use SUM() on credits and rename, remember GROUP BY.
SELECT DISTINCT course.course_id, course.title, SUM(course.credits) sum
FROM course
NATURAL JOIN takes
WHERE takes.id = '30397'
GROUP BY course.course_id, course.title
ORDER BY course.course_id ASC;

-- 5. Now display the total credits (over all courses) for each of the students having more than 85 in total credits, along with the ID of the student.
-- don't bother about the name of the student.
-- don't bother about students who have not registered.
-- Note: Not use Student table but join takes and course so the don'ts are meet. Remember HAVING insted of WERE.
SELECT takes.id, SUM(course.credits) sum
FROM takes
NATURAL JOIN course
GROUP BY takes.id
HAVING SUM(course.credits) > 85;

-- 6. Find the names of all students who have taken any course at the Languages department with the grade 'A+' (there should be no duplicate names)
SELECT DISTINCT student.name
FROM student
JOIN takes ON takes.id = student.id
JOIN course ON course.course_id = takes.course_id
WHERE course.dept_name = 'Languages' AND takes.grade = 'A+';

-- 7. Display the IDs of all instructors from the Marketing department who have never taught a course (interpret "taught" as "taught or is scheduled to teach").
-- Note: Subquery and using NOT IN to deselect teaching instructors - Using instructors and teaches).
SELECT id
FROM instructor
WHERE dept_name = 'Marketing' 
AND id NOT IN (
  SELECT teaches.id
  FROM teaches
);

-- 8. As above, but display the names of the instructors also, not just the IDs.
SELECT id, name
FROM instructor
WHERE dept_name = 'Marketing' 
AND id NOT IN (
  SELECT teaches.id
  FROM teaches
);

-- 9. Using the university schema, write an SQL query to find the number of students in each section in year 2009.
-- The result columns should be “course_id, sec_id, year, semester, num”, where the latter is the number.
-- You do not need to output sections with 0 students.
-- Note: When joining you should specify every match and not only the year eg. but also the rest as done here. 
  -- GROUP BY is still nesseary when using aggratefunctions.
	-- HAVING makes sure not to take any 0 values.
SELECT section.course_id, section.sec_id, section.semester, section.year,  COUNT(takes.id) num
FROM section
JOIN takes ON takes.course_id = section.course_id
           AND takes.sec_id = section.sec_id
           AND takes.year = section.year
           AND takes.semester = section.semester
WHERE section.year = 2009
GROUP BY section.course_id, section.sec_id, section.year, section.semester
HAVING COUNT(takes.id) > 0;

-- 10. Find the maximum and minimum enrollment across all sections, considering only sections that had some enrollment, dont worry about those that had no students taking that section.
-- Tip: you can use a subquery in from or a with-clause to provide an intermediate table on (course_id,sec_id, semester,year,num) where num is the count of enrolled students.
-- Note: The subquery FROM must have an alias here i called it 'section_counts'.
SELECT MAX(num) max, MIN(num) min
FROM ( 
    SELECT section.course_id, section.sec_id, section.year, section.semester, COUNT(takes.id) AS num
    FROM section
    JOIN takes ON takes.course_id = section.course_id
              AND takes.sec_id = section.sec_id
              AND takes.year = section.year
              AND takes.semester = section.semester
    GROUP BY section.course_id, section.sec_id, section.year, section.semester
) section_counts;

-- 11. Find all sections that had the maximum enrollment (along with the enrollment). Tip: you can use a subquery in from or a with clause.
-- Note: 
 -- Inner Subquery (max_counts): Computes the maximum number of students across all sections.
 -- Outer Subquery (section_counts): Computes the number of students for each section.
 -- And then slecetion where the num matches the maximum enrollment found in the inner subquery.
SELECT course_id, sec_id, semester, year, num
FROM (
    SELECT section.course_id, section.sec_id, section.year, section.semester, COUNT(takes.id) AS num
    FROM section
    JOIN takes ON takes.course_id = section.course_id
               AND takes.sec_id = section.sec_id
               AND takes.year = section.year
               AND takes.semester = section.semester
    GROUP BY section.course_id, section.sec_id, section.year, section.semester
) AS section_counts
WHERE num = (
    SELECT MAX(num)
    FROM (
        SELECT COUNT(takes.id) AS num
        FROM section
        JOIN takes ON takes.course_id = section.course_id
                   AND takes.sec_id = section.sec_id
                   AND takes.year = section.year
                   AND takes.semester = section.semester
        GROUP BY section.course_id, section.sec_id, section.year, section.semester
    ) AS max_counts
);

-- 12. As in in Q10, but now also include sections with no students taking them; the enrollment for such sections should be treated as 0.
-- Tip: Use aggregation and outer join.
-- Note: Full Join (full outer join takes all values also 0).
SELECT MAX(num) max, MIN(num) min
FROM ( 
    SELECT section.course_id, section.sec_id, section.year, section.semester, COUNT(takes.id) AS num
    FROM section
    FULL JOIN takes ON takes.course_id = section.course_id
              AND takes.sec_id = section.sec_id
              AND takes.year = section.year
              AND takes.semester = section.semester
    GROUP BY section.course_id, section.sec_id, section.year, section.semester
) section_counts;

-- 13. Find all courses that the instructor with id '19368' have taught.
-- Note: remomber again the joining on all keys.
SELECT teaches.id, section.course_id, section.sec_id, section.semester, section.year
FROM teaches
JOIN section ON section.course_id = teaches.course_id
             AND section.sec_id = teaches.sec_id
             AND section.year = teaches.year
             AND section.semester = teaches.semester
WHERE teaches.id = '19368';

-- 14. Find instructors who have taught all the above courses.
-- Hint: one option is to use "... not exists (... except ...)"
SELECT t1.id
FROM teaches t1
WHERE NOT EXISTS (
    SELECT *
    FROM teaches t2
    WHERE t2.id = '19368'
    AND NOT EXISTS (
        SELECT 1
        FROM teaches t3
        WHERE t3.id = t1.id
        AND t3.course_id = t2.course_id
    )
)
GROUP BY t1.id;

-- 15. Insert each instructor as a student, with tot_creds = 0, in the same department
-- Note: Where -- ensures that instructors who are already students (i.e., whose id exists in the student table) are not inserted again.
INSERT INTO student (id, name, dept_name, tot_cred)
SELECT instructor.id, instructor.name, instructor.dept_name, 0
FROM instructor
WHERE instructor.id NOT IN (SELECT student.id FROM student);

-- 16. Now delete all the newly added "students" above (note: already existing students who happened to have tot_creds = 0 should not get deleted)
DELETE FROM student
WHERE id IN (
	SELECT instructor.id
	FROM instructor
)
AND tot_cred = 0;

-- 17. You may have noticed that the tot_cred value for students do not always match the credits from courses they have taken. Write a query to compare these that show a students id and tot_cred together with the correct calculated total credits. Show only the cases where the two values match
SELECT student.id, student.tot_cred, SUM(course.credits) sum
FROM student
JOIN takes ON takes.id = student.id
JOIN course ON course.course_id = takes.course_id
GROUP BY student.id, student.tot_cred
HAVING SUM(course.credits) = student.tot_cred;

-- 18. Write and execute a query to update tot_cred for all students to the correct calculated value based on the credits passed - thereby bringing the database back to consistency.
UPDATE student
SET tot_cred = (
    SELECT SUM(course.credits)
    FROM takes
    JOIN course ON course.course_id = takes.course_id
    WHERE takes.id = student.id
    GROUP BY takes.id
);

-- 19. Run Q17 again, but now only show when the two values differ
-- Note. Not equal <>
SELECT student.id, student.tot_cred, SUM(course.credits) sum
FROM student
JOIN takes ON takes.id = student.id
JOIN course ON course.course_id = takes.course_id
GROUP BY student.id, student.tot_cred
HAVING SUM(course.credits) <> student.tot_cred;

-- 20. Update the salary of each instructor to 29001 + 10000 times the number of course sections they have taught.
-- First, ensure you have the correct count of course sections for each instructor

-- Update the salary for instructors who have taught sections
UPDATE instructor
SET salary = 29001 + COALESCE(10000 * section_counts.num_sections_taught, 0)
FROM (
    -- Subquery to count the number of sections each instructor has taught
    SELECT id, COUNT(*) AS num_sections_taught
    FROM teaches
    GROUP BY id
) AS section_counts
WHERE instructor.id = section_counts.id;

-- Update the salary for instructors who have not taught any sections
UPDATE instructor
SET salary = 29001
WHERE id NOT IN (
    SELECT DISTINCT id
    FROM teaches
);

-- 21. List name and salary for the 10 first instructors (alphabetic order)
SELECT name, salary
FROM instructor
ORDER BY name ASC
LIMIT 10;

