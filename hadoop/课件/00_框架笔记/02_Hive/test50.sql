# 创建学生表
CREATE TABLE Student(Sid VARCHAR(6), Sname VARCHAR(10), Sage DATETIME, Ssex VARCHAR(10));
INSERT INTO Student VALUES('01' , '赵雷' , '1990-01-01' , '男');
INSERT INTO Student VALUES('02' , '钱电' , '1990-12-21' , '男');
INSERT INTO Student VALUES('03' , '孙风' , '1990-05-20' , '男');
INSERT INTO Student VALUES('04' , '李云' , '1990-08-06' , '男');
INSERT INTO Student VALUES('05' , '周梅' , '1991-12-01' , '女');
INSERT INTO Student VALUES('06' , '吴兰' , '1992-03-01' , '女');
INSERT INTO Student VALUES('07' , '郑竹' , '1989-07-01' , '女');
INSERT INTO Student VALUES('08' , '王菊' , '1990-01-20' , '女');

# 创建成绩表
CREATE TABLE SC(Sid VARCHAR(10), Cid VARCHAR(10), score DECIMAL(18,1));
INSERT INTO SC VALUES('01' , '01' , 80);
INSERT INTO SC VALUES('01' , '02' , 90);
INSERT INTO SC VALUES('01' , '03' , 99);
INSERT INTO SC VALUES('02' , '01' , 70);
INSERT INTO SC VALUES('02' , '02' , 60);
INSERT INTO SC VALUES('02' , '03' , 80);
INSERT INTO SC VALUES('03' , '01' , 80);
INSERT INTO SC VALUES('03' , '02' , 80);
INSERT INTO SC VALUES('03' , '03' , 80);
INSERT INTO SC VALUES('04' , '01' , 50);
INSERT INTO SC VALUES('04' , '02' , 30);
INSERT INTO SC VALUES('04' , '03' , 20);
INSERT INTO SC VALUES('05' , '01' , 76);
INSERT INTO SC VALUES('05' , '02' , 87);
INSERT INTO SC VALUES('06' , '01' , 31);
INSERT INTO SC VALUES('06' , '03' , 34);
INSERT INTO SC VALUES('07' , '02' , 89);
INSERT INTO SC VALUES('07' , '03' , 98);


# 课程表 Course
CREATE TABLE Course(Cid VARCHAR(10),Cname VARCHAR(10),Tid VARCHAR(10));
INSERT INTO Course VALUES('01' , '语文' , '02');
INSERT INTO Course VALUES('02' , '数学' , '01');
INSERT INTO Course VALUES('03' , '英语' , '03')

# 教师表 Teacher
CREATE TABLE Teacher(Tid VARCHAR(10),Tname VARCHAR(10));
INSERT INTO Teacher VALUES('01' , '张三');
INSERT INTO Teacher VALUES('02' , '李四');
INSERT INTO Teacher VALUES('03' , '王五')

# 显示所有的姓名组合不重复
SELECT s1.Sname,s2.Sname FROM Student s1,Student s2 WHERE s1.Sid < s2.Sid


# 表数据重复一遍
SELECT * FROM student s1 JOIN student s2 ON s1.sid = s2.sid

# 1.查询01课程比02课程成绩高的学生的信息及课程分数
# 三张表连接
SELECT s.*, a.score AS score_01, b.score AS score_02
FROM student s,
(SELECT sid, score FROM sc WHERE cid=01) a,
(SELECT sid, score FROM sc WHERE cid=02) b
WHERE a.sid = b.sid AND a.score > b.score AND s.sid = a.sid


# 2.查询平均成绩大于等于60分的同学的学生编号和学生姓名和平均成绩
SELECT s.sid,sname,AVG(score) AS avg_score
FROM student AS s JOIN sc
WHERE s.sid = sc.sid
GROUP BY s.sid 
HAVING avg_score > 60

# 3.查询在SC表存在成绩的学生信息
SELECT * FROM student WHERE sid IN (SELECT sid FROM sc WHERE score IS NOT NULL)

# 下面这条语句查询时间会短一些
EXPLAIN SELECT s.sname,s.sid
FROM student s LEFT JOIN sc ON s.sid=sc.sid WHERE sc.score IS NOT NULL
GROUP BY s.sname,s.sid


# 4.查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩(没成绩的显示为 null)
SELECT s.sid, s.sname, COUNT(cid) AS 选课总数, SUM(score) AS 总成绩
FROM student AS s LEFT JOIN sc
ON s.sid = sc.sid
GROUP BY s.sid


# 4.1 查有成绩的学生信息
SELECT s.sid, s.sname, COUNT(*) AS 选课总数, SUM(score) AS 总成绩,
SUM(CASE WHEN cid = 01 THEN score ELSE NULL END) AS score_01,
SUM(CASE WHEN cid = 02 THEN score ELSE NULL END) AS score_02,
SUM(CASE WHEN cid = 03 THEN score ELSE NULL END) AS score_03
FROM student AS s JOIN sc
ON s.sid = sc.sid
GROUP BY s.sid

# 5.查询「李」姓老师的数量
SELECT COUNT(tname) FROM teacher WHERE tname LIKE '李%'

# 6.查询学过「张三」老师授课的同学的信息
SELECT * FROM student WHERE sid IN (
SELECT sid FROM sc JOIN course JOIN teacher
WHERE sc.cid = course.cid AND course.tid = teacher.tid AND tname = '张三')


# 7.查询没有学全所有课程的同学的信息,student,sc,course,teacher
SELECT s.sid,COUNT(*)
FROM student s JOIN sc JOIN course c ON s.sid=sc.sid AND sc.cid=c.cid 
GROUP BY s.sid HAVING COUNT(*) < (SELECT COUNT(*) FROM course);

SELECT * FROM student WHERE sid IN 
(SELECT sid FROM sc GROUP BY sid HAVING COUNT(cid) < (SELECT COUNT(*) FROM course))


# 9.查询和01号的同学学习的课程完全相同的其他同学的信息
SELECT cid FROM sc WHERE sid = '01' GROUP BY cid

SELECT * FROM Student
WHERE Sid IN(
	SELECT Sid FROM SC
	WHERE Cid IN (SELECT Cid FROM SC WHERE Sid = '01') AND Sid <>'01'
	GROUP BY Sid
	HAVING COUNT(Cid)>=3)
# sid<>01并且count(cid)>=3



# 8.查询至少有一门课与学号为01的同学所学相同的同学的信息
SELECT * FROM Student WHERE Sid IN(
    SELECT DISTINCT Sid FROM SC WHERE Cid IN(
        SELECT Cid FROM SC WHERE Sid='01'
    )
)
# 结论：in适合小数据量，连接查询大数据量更优，
# 当然多表连接查询还是能不用就不用的，大数据量时不建议使用多表连接查询，
# 应用时更因该相对于当下场景来选择。



# 10. 查询没学过”张三”老师讲授的任一门课程的学生姓名,not in
SELECT sname FROM student
WHERE sname NOT IN (
    SELECT s.sname
    FROM student AS s, course AS c, teacher AS t, sc
    WHERE s.sid = sc.sid
        AND sc.cid = c.cid
        AND c.tid = t.tid
        AND t.tname = '张三'
)

 
# 11.查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩
SELECT s.sid,s.sname,AVG(score)
FROM student s JOIN sc ON s.sid=sc.sid AND score<60
GROUP BY s.sid,s.sname HAVING COUNT(score)>-2

# 12.检索01课程分数小于60，按分数降序排列的学生信息
SELECT s.*,sc.score
FROM student s JOIN sc ON s.sid=sc.sid
WHERE sc.cid='01' AND sc.score<60 ORDER BY score DESC


# 13.按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩
SELECT sid,
    SUM(CASE WHEN cid=01 THEN score ELSE NULL END) AS score_01,
    SUM(CASE WHEN cid=02 THEN score ELSE NULL END) AS score_02,
    SUM(CASE WHEN cid=03 THEN score ELSE NULL END) AS score_03,
    AVG(score)
FROM sc GROUP BY sid
ORDER BY AVG(score) DESC

SELECT sid,AVG(score),
	SUM(IF(cid=01,score,NULL)) score_01,
	SUM(IF(cid=02,score,NULL)) score_02,
	SUM(IF(cid=03,score,NULL)) score_03
FROM sc GROUP BY sid
ORDER BY AVG(score) DESC


# 14.查询各科成绩最高分、最低分和平均分，以如下形式显示：课程 ID，课程 name，最高分，
# 最低分，平均分，及格率，中等率，优良率，优秀率(及格为>=60，中等为：70-80，
# 优良为：80-90，优秀为：>=90）。
# 要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列
SELECT c.cid,c.cname,MAX(sc.score),MIN(sc.score),AVG(sc.score),COUNT(*),
COUNT(CASE WHEN sc.score>=60 THEN 1 ELSE NULL END)/COUNT(*) AS '及格率',
COUNT(CASE WHEN sc.score>=70 AND sc.score<80 THEN 1 ELSE NULL END)/COUNT(*) AS '中等率',
COUNT(CASE WHEN sc.score>=80 AND sc.score<90 THEN 1 ELSE NULL END)/COUNT(*) AS '优良率',
COUNT(CASE WHEN sc.score>=90 THEN 1 ELSE NULL END)/COUNT(*) AS '优秀率'
FROM sc JOIN course c ON sc.cid=c.cid GROUP BY c.cid,c.cname
# count(*)没有统计空值,使用count与sum都可以


SELECT c.cid AS 课程号, c.cname AS 课程名称, COUNT(*) AS 选修人数,
    MAX(score) AS 最高分, MIN(score) AS 最低分, AVG(score) AS 平均分,
    SUM(CASE WHEN score >= 60 THEN 1 ELSE 0 END)/COUNT(*) AS 及格率,
    SUM(CASE WHEN score >= 70 AND score < 80 THEN 1 ELSE 0 END)/COUNT(*) AS 中等率,
    SUM(CASE WHEN score >= 80 AND score < 90 THEN 1 ELSE 0 END)/COUNT(*) AS 优良率,
    SUM(CASE WHEN score >= 90 THEN 1 ELSE 0 END)/COUNT(*) AS 优秀率
FROM sc, course c
WHERE c.cid = sc.cid
GROUP BY c.cid
ORDER BY COUNT(*) DESC, c.cid ASC


# 17. 统计各科成绩各分数段人数：课程编号，课程名称，[100-85]，[85-70]，[70-60]，[60-0] 及所占百分比

SELECT c.cid AS 课程编号, c.cname AS 课程名称, A.*
FROM course AS c,
(SELECT cid,
    SUM(CASE WHEN score >= 85 THEN 1 ELSE 0 END)/COUNT(*) AS 100_85,
    SUM(CASE WHEN score >= 70 AND score < 85 THEN 1 ELSE 0 END)/COUNT(*) AS 85_70,
    SUM(CASE WHEN score >= 60 AND score < 70 THEN 1 ELSE 0 END)/COUNT(*) AS 70_60,
    SUM(CASE WHEN score < 60 THEN 1 ELSE 0 END)/COUNT(*) AS 60_0
FROM sc GROUP BY cid) AS A
WHERE c.cid = A.cid



# 20.查询出只选修两门课程的学生学号和姓名

SELECT s.sid, s.sname, COUNT(cid)
FROM student s, sc
WHERE s.sid = sc.sid
GROUP BY s.sid
HAVING COUNT(cid)=2


# 24. 查询 1990 年出生的学生名单
SELECT * FROM student WHERE YEAR(sage) = 1990

# 33.成绩不重复，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩

SELECT s.*, MAX(score)
FROM student s, teacher t, course c, sc
WHERE s.sid = sc.sid
    AND sc.cid = c.cid
    AND c.tid = t.tid
    AND t.tname = '张三'


# 40.查询各学生的年龄，只按年份来算
SELECT NOW() # 2020-01-17 18:22:12
SELECT sname, YEAR(NOW())-YEAR(sage) AS age FROM student

# 41.按照出生日期来算，当前月日 < 出生年月的月日则，年龄减一
SELECT sname, TIMESTAMPDIFF(YEAR, sage, NOW()) AS age FROM student


SELECT DATEDIFF('2018-03-22 00:00:00', '2018-03-20 23:59:59'); # 2
SELECT DATEDIFF('2019-10-12','2019-10-01') # 11前面的减去后面的


SELECT TIMESTAMPDIFF(YEAR, '2019-03-24 23:59:00', '2020-03-22 00:00:00'); # 0
SELECT TIMESTAMPDIFF(DAY, '2019-03-20 23:59:00', '2019-03-22 00:00:00');
SELECT TIMESTAMPDIFF(HOUR, '2018-03-20 09:00:00', '2018-03-22 10:00:00');
SELECT TIMESTAMPDIFF(MINUTE, '2018-03-20 09:00:00', '2018-03-22 10:00:00');
SELECT TIMESTAMPDIFF(SECOND, '2019-03-22 09:00:00', '2019-03-22 10:00:00');


# 42.查询本周过生日的学生
SELECT * FROM student WHERE WEEK(NOW()) = WEEK(sage)

# 43. 查询下周过生日的学生
SELECT * FROM student WHERE (WEEK(NOW())+1) = WEEK(sage)
SELECT WEEK('2020-1-12') # 从周日开始计算


# 44. 查询本月过生日的学生
SELECT * FROM student WHERE MONTH(NOW()) = MONTH(sage)


# 45. 查询下月过生日的学生
SELECT * FROM student WHERE (MONTH(NOW())+1) = MONTH(sage)

SELECT MONTH('2019-10-10') # 10
