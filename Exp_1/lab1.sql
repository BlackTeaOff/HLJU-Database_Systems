DROP DATABASE IF EXISTS lab1;
CREATE DATABASE lab1 CHARACTER SET utf8mb4;
USE lab1;

# 建表

CREATE TABLE employee (
    ssn char(18) NOT NULL ,
    name char(10) NOT NULL ,
    bdate char(10) NOT NULL ,
    address char(30) NOT NULL ,
    sex char(2) NOT NULL ,
    salary float NOT NULL ,
    superssn char(18) NOT NULL ,
    dno char(3) NOT NULL ,
    PRIMARY KEY (ssn)
);

CREATE TABLE department (
    dnumber char(3) NOT NULL ,
    dname varchar(30) NOT NULL ,
    mgrssn char(18) NOT NULL ,
    mgrstartdate date NOT NULL ,
    PRIMARY KEY (dnumber)
);

CREATE TABLE depart_location (
    dnumber char(3) NOT NULL ,
    dlocation varchar(30) NOT NULL,
    PRIMARY KEY (dnumber)
);

CREATE TABLE project (
    pnumber char(3) NOT NULL ,
    pname varchar(30) NOT NULL ,
    plocation varchar(30) NOT NULL ,
    dnum char(3) NOT NULL ,
    PRIMARY KEY (pnumber)
);

CREATE TABLE works_on (
    essn char(18) NOT NULL ,
    pno char(3) NOT NULL ,
    hours int NOT NULL ,
    PRIMARY KEY (essn, pno)
);

CREATE TABLE dependent (
    essn char(18) NOT NULL ,
    dependent_name char(10) NOT NULL ,
    sex char(2) NOT NULL ,
    bdate char(10) NOT NULL ,
    relationship char(10) NOT NULL ,
    PRIMARY KEY (essn, dependent_name)
);

# 插入数据

INSERT INTO employee VALUES
('230101198009081234', '张三', '1980-09-08', '哈尔滨道里区十二道街', '男', 3125,
 '23010119751201312X', 'd1'),
('230101198107023736', '李四', '1981-07-02', '哈尔滨道外区三道街', '男', 2980,
 '23010119751201312X', 'd1'),
('23010119751201312X', '张红', '1975-12-01', '哈尔滨南岗区三十道街', '男', 4260,
 '23010119751201312X', 'd1'),
('230101198204078121', '王二', '1982-04-07', '哈尔滨动力区六十道街', '男', 2890,
 '23010119751201312X', 'd1'),
('23010119950101XXXX', '灰太狼', '1995-01-01', '青青草原狼堡', '男', 1200,
 '23010119960101XXXX', 'd2'),
('23010119960101XXXX', '红太狼', '1996-01-01', '青青草原狼堡', '女', 3600,
 '23010119960101XXXX', 'd2'),
('23010120050101XXXX', '喜羊羊', '2005-01-01', '青青草原大肥羊学校', '男', 1000,
 '23010120050101XXXX', 'd3'),
('XXXXXXXXXXXXXXXXXX', '超人', '3000-01-01', '外星', '男', 100000,
 '23010120050101XXXX', 'd4');

INSERT INTO department VALUES
('d1', '研发部', '23010119751201312X', '2008-01-01'),
('d2', '捕羊部', '23010119960101XXXX', '2006-01-01'),
('d3', '防狼部', '23010120050101XXXX', '2006-01-01'),
('d4', '全能部', 'XXXXXXXXXXXXXXXXXX', '3000-01-01');

INSERT INTO depart_location VALUES
('d1', '哈尔滨'),
('d2', '青青草原'),
('d3', '青青草原'),
('d4', '地球');

INSERT INTO project VALUES
('p1', '研究项目 1', '哈尔滨', 'd1'),
('p2', '哈同公路', '哈尔滨', 'd1'),
('p3', '立交桥', '哈尔滨', 'd1'),
('p4', '机场建设', '哈尔滨', 'd1'),
('p5', '抓羊', '青青草原', 'd2'),
('p6', '吃羊', '青青草原', 'd2'),
('p7', '防狼', '青青草原', 'd3');

INSERT INTO works_on VALUES
('23010119751201312X', 'p1', 100),
('23010119751201312X', 'p2', 90),
('23010119751201312X', 'p3', 85),
('23010119751201312X', 'p4', 100),
('230101198009081234', 'p1', 65),
('230101198009081234', 'p2', 76),
('230101198009081234', 'p3', 67),
('230101198107023736', 'p2', 89),
('230101198107023736', 'p3', 79),
('230101198107023736', 'p4', 91),
('230101198204078121', 'p2', 23),
('230101198204078121', 'p3', 36),
('23010119950101XXXX', 'p2', 11),
('23010119950101XXXX', 'p5', 100),
('23010119950101XXXX', 'p6', 100),
('23010119960101XXXX', 'p5', 100),
('23010119960101XXXX', 'p6', 100),
('23010120050101XXXX', 'p7', 100),
('XXXXXXXXXXXXXXXXXX', 'p1', 100),
('XXXXXXXXXXXXXXXXXX', 'p2', 100),
('XXXXXXXXXXXXXXXXXX', 'p3', 100),
('XXXXXXXXXXXXXXXXXX', 'p4', 100),
('XXXXXXXXXXXXXXXXXX', 'p5', 100),
('XXXXXXXXXXXXXXXXXX', 'p6', 100),
('XXXXXXXXXXXXXXXXXX', 'p7', 100);

INSERT INTO dependent VALUES
('230101198009081234', '张三妻', '女', '1983-09-02', '配偶'),
('230101198009081234', '张三儿', '男', '2005-01-01', '父子'),
('23010119950101XXXX', '小灰灰', '男', '2009-01-01', '父子'),
('23010119960101XXXX', '小灰灰', '男', '2009-01-01', '母子');


# 查询数据

# 3.1
SELECT essn FROM works_on WHERE pno = 'p2';

# 3.2
SELECT COUNT(*) FROM works_on JOIN project ON pno = pnumber WHERE pname = '哈同公路';

# 3.3
SELECT name, address FROM employee JOIN department ON dno = dnumber WHERE dname = '研发部' AND salary < 3000;

# 3.4
# 相关子查询, 把外面的属性 ssn 一个一个带到里面的子查询进行查询, 里面查询没查到就保留该条
SELECT name FROM employee WHERE NOT EXISTS (SELECT * FROM works_on WHERE essn = ssn AND pno = 'p1');
# 不相关子查询, 先执行里面, 把结果带到外面
SELECT name FROM employee WHERE ssn NOT IN (SELECT essn FROM works_on WHERE pno = 'p1');

# 3.5
SELECT name FROM employee WHERE NOT EXISTS (SELECT * FROM dependent WHERE essn = ssn);

SELECT name FROM employee WHERE ssn NOT IN (SELECT essn FROM dependent);

# 3.6
SELECT name, dname FROM employee JOIN department ON dno = dnumber WHERE superssn =
                                                                        (SELECT ssn FROM employee WHERE name = '张红');

# 3.7
# HAVING 和 GROUP BY 配合使用, 先统计后过滤
SELECT essn, COUNT(*) FROM works_on GROUP BY essn HAVING COUNT(*) >= 3;

# 3.8
SELECT essn FROM works_on WHERE pno IN ('p1', 'p2') GROUP BY essn HAVING COUNT(*) = 2;

# 3.9
SELECT ssn, name FROM employee WHERE ssn IN (SELECT essn FROM works_on GROUP BY essn HAVING COUNT(*) =
                                                                                (SELECT COUNT(*) FROM project));

# 3.10
SELECT name FROM employee JOIN works_on ON ssn = essn WHERE pno = 'p2' AND salary <
                                                                (SELECT salary FROM employee WHERE name = '张三');

# 3.11
# 张三没参加的项目很多, 所以去重
SELECT DISTINCT name FROM employee JOIN works_on ON ssn = essn WHERE pno IN (SELECT pnumber FROM project WHERE
    NOT EXISTS (SELECT * FROM works_on JOIN employee ON ssn = essn WHERE pnumber = pno AND name = '张三'
));

# 3.12
SELECT name FROM employee JOIN works_on ON ssn = essn WHERE name != '王二' AND pno IN (SELECT pno FROM works_on
    JOIN employee ON ssn = essn WHERE name = '王二') GROUP BY ssn HAVING COUNT(*) = (SELECT COUNT(*) FROM works_on
    JOIN employee ON ssn = essn WHERE name = '王二');

# 3.13
SELECT name, AVG(hours) FROM employee JOIN works_on ON ssn = essn WHERE ssn IN
                    (SELECT essn FROM works_on WHERE hours >= 100 GROUP BY essn HAVING COUNT(*) >= 2) GROUP BY name;

# 3.14
SELECT name FROM employee JOIN works_on ON ssn = essn JOIN project ON pno = pnumber GROUP BY ssn
                                                                                    HAVING COUNT(DISTINCT dnum) >= 3;

# 3.15
SELECT name FROM employee JOIN works_on ON ssn = essn WHERE pno IN ('p1', 'p2', 'p3') GROUP BY ssn HAVING COUNT(*) = 3;


# 测试
SELECT name FROM employee e JOIN dependent d ON essn = ssn WHERE dependent_name = '小灰灰' AND d.relationship = '父子';


# 关系模式及数据维护

# 1
ALTER TABLE dependent
    ADD work_unit VARCHAR(50),
    ADD job VARCHAR(20);


SET SQL_SAFE_UPDATES = 0;

# 2
UPDATE dependent
SET work_unit = '研发部',
    job = '工程师';

# 3
UPDATE employee SET salary = 3000;

# 4
UPDATE dependent SET job = '教师' WHERE essn = '230101198009081234' AND dependent_name = '张三妻';

# 5
UPDATE employee SET salary = salary * 1.1 WHERE dno = (SELECT dnumber FROM department WHERE dname = '研发部');

# 6
DELETE FROM dependent WHERE essn = '23010119950101XXXX';

# 7
DELETE FROM employee WHERE dno = (SELECT dnumber FROM department WHERE dname = '研发部');

# 8
ALTER TABLE dependent
    DROP COLUMN work_unit,
    DROP COLUMN job;
