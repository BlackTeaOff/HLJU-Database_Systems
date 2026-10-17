USE lab1;

DROP PROCEDURE IF EXISTS proc_dept_emp_project;
DROP PROCEDURE IF EXISTS proc_highest_salary_dept;
DROP PROCEDURE IF EXISTS proc_highest_salary_dept2;

# 定界符从 ';' 改成 '//'
# 给 SQL 发送大代码块
DELIMITER //

# 给部门号查员工基本信息及其项目
CREATE PROCEDURE proc_dept_emp_project(IN in_dno CHAR(3))
BEGIN

    SELECT *
    FROM employee
    LEFT JOIN works_on ON ssn = essn
    LEFT JOIN project ON pno = pnumber
    WHERE dno = in_dno;

END //

DELIMITER ;

CALL proc_dept_emp_project('d1');
CALL proc_dept_emp_project('d2');

DELIMITER //

# 工资最高职工所在的部门名称和工资, 该部门中职工的信息
CREATE PROCEDURE proc_highest_salary_dept()
BEGIN
    SELECT dname, salary
    FROM employee
    JOIN department ON dno = dnumber
    WHERE salary = (SELECT MAX(salary) FROM employee);

    SELECT *
    FROM employee
    WHERE dno IN (
    SELECT dno
    FROM employee
    WHERE salary = (SELECT MAX(salary) FROM employee));
END //

# 变量的作用域只在 BEGIN 和 END 内
CREATE PROCEDURE proc_highest_salary_dept2()
BEGIN
    DECLARE max_sal FLOAT;
    DECLARE target_dno CHAR(3);

    SELECT dno, salary INTO target_dno, max_sal
    FROM employee
    ORDER BY salary DESC
    LIMIT 1;

    SELECT dname, max_sal
    FROM department
    WHERE dnumber = target_dno;

    SELECT * FROM employee WHERE dno = target_dno;
END //

DELIMITER ;

CALL proc_highest_salary_dept();
CALL proc_highest_salary_dept2();


# 触发器
DROP TRIGGER IF EXISTS depart_update;
DROP TRIGGER IF EXISTS employee_delete;

DELIMITER //

CREATE TRIGGER depart_update
AFTER UPDATE ON department
FOR EACH ROW
BEGIN
    UPDATE employee
    SET dno = NEW.dnumber
    WHERE dno = OLD.dnumber;
END //

CREATE TRIGGER employee_delete
AFTER DELETE ON employee
FOR EACH ROW
BEGIN
    DELETE
    FROM works_on
    WHERE essn = OLD.ssn;
END //

DELIMITER ;

# 测试

# 改变 d2 -> d20
SELECT name, dno FROM employee WHERE dno = 'd2';
UPDATE department SET dnumber = 'd20' WHERE dnumber = 'd2';
SELECT name, dno FROM employee WHERE dno = 'd20';
UPDATE department SET dnumber = 'd2' WHERE dnumber = 'd20';

# 插入后删除
INSERT INTO employee VALUES ('999', 'Test', '2000-01-01',
                             'Test', '男', '5000', 'test', 'd1');
INSERT INTO works_on VALUES ('999', 'p1', 50);
SELECT * FROM works_on WHERE essn = '999';
DELETE FROM employee WHERE ssn = '999';
SELECT * FROM works_on WHERE essn = '999';

/*

DROP TRIGGER IF EXISTS 触发器名字;

DELIMITER //

CREATE TRIGGER 触发器名字
{BEFORE 或 AFTER} {INSERT 或 UPDATE 或 DELETE} ON 监视的表名
FOR EACH ROW
BEGIN
    -- 这里写具体的动作（UPDATE、DELETE、或者拦截报错）
END //

DELIMITER ;
*/

#

DELIMITER  //
CREATE TRIGGER test
AFTER UPDATE ON department
FOR EACH ROW
BEGIN
    UPDATE project SET dnum = NEW.dnumber WHERE dnum = OLD.dnumber;
END //

DELIMITER ;

#

DELIMITER //
CREATE TRIGGER test2
AFTER DELETE ON project
FOR EACH ROW
BEGIN
    DELETE FROM works_on WHERE pno = OLD.pnumber;
END //
DELIMITER ;

#
DELIMITER //
CREATE TRIGGER test3
BEFORE INSERT ON employee
FOR EACH ROW
BEGIN
    IF NEW.salary < 1000 THEN
        SET NEW.salary = 1000;
    END IF;
END //
DELIMITER ;

#

DELIMITER //
CREATE TRIGGER test4
BEFORE INSERT ON works_on
FOR EACH ROW
BEGIN
    IF NEW.hours < 0 THEN
        SET NEW.hours = 0;
    END IF;
    IF NEW.hours > 120 THEN
        SET NEW.hours = 120;
    END IF;
END //

#

DELIMITER //
CREATE TRIGGER test5
BEFORE UPDATE ON employee
FOR EACH ROW
BEGIN
    IF NEW.salary < OLD.salary THEN
        SET NEW.salary = OLD.salary;
    END IF;
END //

DELIMITER ;

#

DELIMITER //
CREATE TRIGGER test6
AFTER DELETE ON employee
FOR EACH ROW
BEGIN
    DELETE FROM dependent WHERE essn = OLD.ssn;
END //
DELIMITER ;

#

DELIMITER //
CREATE TRIGGER test7
AFTER UPDATE ON project
FOR EACH ROW
BEGIN
    UPDATE works_on SET pno = NEW.pnumber WHERE pno = OLD.pnumber;
END //
DELIMITER ;

#

#
DELIMITER //
CREATE TRIGGER test8
AFTER UPDATE ON employee
FOR EACH ROW
BEGIN
    UPDATE department SET mgrssn = NEW.ssn WHERE mgrssn = OLD.ssn;
END //

DELIMITER ;
#



# 删部门，把部门员工删掉
DELIMITER //
CREATE TRIGGER test9
AFTER DELETE ON department
FOR EACH ROW
BEGIN
    DELETE FROM employee WHERE dno = OLD.dnumber;
END //
DELIMITER ;
#

SELECT * FROM employee WHERE dno = 'd1';
DELETE FROM department WHERE dnumber = 'd1';
SELECT * FROM employee WHERE dno = 'd1';
