use employee;
select * from data_science_team;

/*Q3.Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, and DEPARTMENT from the employee record table, and make a list of employees and details of their department.*/
select EMP_ID, FIRST_NAME, LAST_NAME, GENDER,DEPT from emp_record_table;

/* Q4.Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, and EMP_RATING if the EMP_RATING is: 
->less than two
->greater than four 
->between two and four */

Select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING from emp_record_table where emp_rating <2;
Select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING from emp_record_table where emp_rating >4;
Select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING from emp_record_table where emp_rating between 2 and 4;

/*Q5. Write a query to concatenate the FIRST_NAME and the LAST_NAME of employees in the Finance department from the employee table and then give the resultant column alias as NAME.*/
SELECT CONCAT(FIRST_NAME," ", LAST_NAME) AS NAME from emp_record_table where DEPT = 'FINANCE';

/*Q6. Write a query to list only those employees who have someone reporting to them. Also, show the number of reporters (including the President).*/

alter table emp_record_table change `MANAGER ID`  MANAGER_ID varchar(45);
SELECT 
  E1.EMP_ID, E1.FIRST_NAME, E1.LAST_NAME,
  (SELECT COUNT(*) FROM emp_record_table E2 WHERE E2.MANAGER_ID = E1.EMP_ID) AS REPORTERS_COUNT
FROM emp_record_table E1
WHERE E1.EMP_ID IN (SELECT DISTINCT MANAGER_ID FROM emp_record_table);

SELECT MANAGER_ID, count(EMP_ID) 
FROM emp_record_table 
WHERE MANAGER_ID IS NOT NULL 
GROUP BY MANAGER_ID ORDER BY MANAGER_ID ASC;

/*Q7. Write a query to list down all the employees from the healthcare and finance departments using union. Take data from the employee record table*/
SELECT * FROM emp_record_table where dept ='HEALTHCARE' 
Union
 SELECT * FROM emp_record_table where dept = 'FINANCE'
 
 /*Q8.Write a query to list down employee details such as EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPARTMENT, and EMP_RATING grouped by dept. Also include the respective employee rating along with the max emp rating for the department.*/
 #SELECT E1.EMP_ID, E1.FIRST_NAME, E1.LAST_NAME, E1.`ROLE`, E1.DEPT, E1.EMP_RATING, MAX(E2.EMP_RATING) AS MAX_RATING FROM emp_record_table E1 JOIN emp_record_table E2 ON E1.DEPT=E2.DEPT GROUP BY E1.DEPT,E1.EMP_ID,E1.FIRST_NAME,E1.LAST_NAME, E1.`ROLE`,E1.EMP_RATING;
 SELECT E1.EMP_ID,
  E1.FIRST_NAME,
  E1.LAST_NAME,
  E1.`ROLE`,
  E1.DEPT,
  E1.EMP_RATING,
  MAX(E2.EMP_RATING) AS MAX_RATING
FROM emp_record_table E1
JOIN emp_record_table E2
  ON E1.DEPT = E2.DEPT
GROUP BY
  E1.DEPT,
  E1.EMP_ID,
  E1.FIRST_NAME,
  E1.LAST_NAME,
  E1.`ROLE`,
  E1.EMP_RATING;
  
#Q9.Write a query to calculate the minimum and the maximum salary of the employees in each role. Take data from the employee record table. 
SELECT `ROLE`,MIN(SALARY) AS MIN_SALARY,MAX(SALARY) AS MAX_SALARY FROM emp_record_table group by `ROLE`ORDER BY MAX_SALARY DESC

#Q10.Write a query to assign ranks to each employee based on their experience. Take data from the employee record table.
SELECT EMP_ID ,exp, rank() over (order by exp desc) as `rank` FROM emp_record_table;

SELECT EMP_ID, FIRST_NAME, LAST_NAME, EXP,
  CASE
    WHEN EXP <= 2 THEN 'Junior'
    WHEN EXP <= 5 THEN 'Associate'
    WHEN EXP <= 10 THEN 'Senior'
    WHEN EXP <= 12 THEN 'Lead'
    ELSE 'Manager'
  END AS Experience_Rank
FROM emp_record_table order by Exp desc;

#Q11. Write a query to create a view that displays employees in various countries whose salary is more than six thousand. Take data from the employee record table.
CREATE VIEW HIGH_SALARIED_EMPLOYEE AS
SELECT EMP_ID, FIRST_NAME, LAST_NAME, COUNTRY, SALARY
FROM emp_record_table where SALARY>6000;

SELECT * FROM HIGH_SALARIED_EMPLOYEE;

#Q12. Write a nested query to find employees with experience of more than ten years. Take data from the employee record table.
SELECT EMP_ID, EXP FROM emp_record_table WHERE EXP>10
#SELECT EMP_ID , EXP FROM (SELECT * FROM EMP_RECORD_TABLE WHERE EXP >10) AS TAB;

#Q13.Write a query to create a stored procedure to retrieve the details of the employees whose experience is more than three years. Take data from the employee record table.

DELIMITER //
CREATE PROCEDURE GETEXPEMP()
BEGIN
SELECT * FROM emp_record_table where EXP>3;
END
// DELIMITER ;

CALL GETEXPEMP();

#Q14. Write a query using stored functions in the project table to check whether the job profile assigned to each employee in the data science team matches the organization’s set standard.
/*The standard being:
For an employee with experience less than or equal to 2 years assign 'JUNIOR DATA SCIENTIST',
For an employee with the experience of 2 to 5 years assign 'ASSOCIATE DATA SCIENTIST',
For an employee with the experience of 5 to 10 years assign 'SENIOR DATA SCIENTIST',
For an employee with the experience of 10 to 12 years assign 'LEAD DATA SCIENTIST',
For an employee with the experience of 12 to 16 years assign 'MANAGER'.*/

DELIMITER $$
CREATE FUNCTION CHECK_JOB_PROFILE(EXP INT)
RETURNS VARCHAR(40)
DETERMINISTIC 
BEGIN
DECLARE CHCK VARCHAR(40);
	IF EXP <=2 THEN SET CHCK ='Junior Data Scientist';
    ELSEIF EXP <=5 THEN SET CHCK ='Associate Data Scientist';
    ELSEIF EXP <=10 THEN SET CHCK = 'Senior Data Scientist';
    ELSEIF EXP <=12 THEN SET CHCK = 'Lead Data Scientist';
    ELSEIF EXP <=20 THEN SET CHCK = 'Manager';
    ELSE SET CHCK = 'none';
END IF;
  RETURN CHCK;
END$$
DELIMITER ;

SELECT 
    EMP_ID, FIRST_NAME, LAST_NAME, `ROLE`,EXP
FROM
    emp_record_table
WHERE
    `ROLE` = CHECK_JOB_PROFILE(EXP);    
    



DELIMITER $$
CREATE FUNCTION check_job_role(EXP INT) RETURNS VARCHAR(40) DETERMINISTIC
BEGIN
  DECLARE chck VARCHAR(40);
  IF EXP <= 2 THEN
    SET chck = 'JUNIOR DATA SCIENTIST';
  ELSEIF EXP <= 5 THEN
    SET chck = 'ASSOCIATE DATA SCIENTIST';
  ELSEIF EXP <= 10 THEN
    SET chck = 'SENIOR DATA SCIENTIST';
  ELSEIF EXP <= 12 THEN
    SET chck = 'LEAD DATA SCIENTIST';
  ELSE
    SET chck = 'MANAGER';
  END IF;
  RETURN chck;
END $$
DELIMITER ;

-- Check mismatches:
SELECT EMP_ID, FIRST_NAME, LAST_NAME, `ROLE`
FROM data_science_team
WHERE `ROLE` <> check_job_role(EXP);

#Q15. Create an index to improve the cost and performance of the query to find the employee whose FIRST_NAME is ‘Eric’ in the employee table after checking the execution plan.
create index firstname on emp_record_table(first_name(10));

#Q16. Write a query to calculate the bonus for all the employees, based on their ratings and salaries (Use the formula: 5% of salary * employee rating).
select *, (0.05*salary*emp_rating) as bonus from emp_record_table;

#Q17. Write a query to calculate the average salary distribution based on the continent and country. Take data from the employee record table.
 SELECT CONTINENT,COUNTRY, AVG(SALARY) FROM EMP_RECORD_TABLE GROUP BY CONTINENT, COUNTRY;

