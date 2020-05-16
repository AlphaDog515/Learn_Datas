建立数据库：
create database if not exists hql1015 location 'hdfs://hadoop102:9000/warehouse/hql1015'; 

// 大小写转化：ctrl + u, ctrl + shift + u, word中点击Aa即可

(1)手写hql 第1题
表结构：uid,subject_id,score
求：找出所有科目成绩都大于某一学科平均成绩的学生
数据集如下：
1001	01	90
1001	02	90
1001	03	90
1002	01	85
1002	02	85
1002	03	70
1003	01	70
1003	02	70
1003	03	85
建表语句：
create table score(uid string,subject_id string,score int) 
row format delimited fields terminated by '\t';

加载数据：
load data local inpath "/home/atguigu/hivedatas/score.txt" into table score;

方案一：
// 1.各科平均成绩
select subject_id,avg(score) avg_score from score group by subject_id;  // t1

// 2.一共多少科
select subject_id,avg_score,count(*) over() count_subject from t1;  // t2

// 上面两条sql可以合并
select subject_id,avg(score) avg_score,count(*) over() count_subject from score group by subject_id;

// 3.先统计出分数大于平均成绩的学生，然后选课数目等于总的课数
// 这个结果会过滤掉那些选课不足的同学
select uid from score join t2 on score.subject_id = t2.subject_id
where score.score > t2.avg_score 
group by uid having count(score.subject_id) = max(t2.count_subject);  // 需要加上max

方案二：
// 平均成绩
select uid,score,avg(score) over(partition by subject_id) avg_score from score;  // t1

// flag标记
select uid,if(score > avg_score,0,1) flag from t1;  // t2

// 分组求和
select uid from t2 group by uid having sum(flag)=0;





(2)手写hql 第2题
用户访问数据:
userid	visitdate	visitcount
u01		2017/1/21		5
u02		2017/1/23		6
u03		2017/1/22		8
u04		2017/1/20		3
u01		2017/1/23		6
u01		2017/2/21		8
u02		2017/1/23		6
u01		2017/2/22		4

使用sql统计出每个用户的累积访问次数，如下表所示：
用户id	月份		小计	累积
u01		2017-01		11		11
u01		2017-02		12		23
u02		2017-01		12		12
u03		2017-01		8		8
u04		2017-01		3		3

建表语句：
create table action
(userid string,visitdate string,visitcount int) 
row format delimited fields terminated by "\t";

加载数据：
load data local inpath "/home/atguigu/hivedatas/action.txt" into table action;

// 修改数据格式
select userid,date_format(regexp_replace(visitdate,'/','-'),'yyyy-MM') mn,visitcount
from action;    // t1

// 每人每月访问
select userid,mn,sum(visitcount) mn_count
from t1 group by userid,mn;    // t2

// 按月累计 # 指定了order by 窗口默认 rows between unbounded preceding and current row
select userid,mn,mn_count,sum(mn_count) over(partition by userid order by mn) from t2;

// 子查询的方式少了一个reducer，下面这种写法有两个reducer！
select userid,
date_format(regexp_replace(visitdate,'/','-'),'yyyy/MM') mn,
sum(visitcount) count_visit,
sum(sum(visitcount)) over(partition by userid order by date_format(regexp_replace(visitdate,'/','-'),'yyyy/MM') ) sumtotal
from action 
group by userid,date_format(regexp_replace(visitdate,'/','-'),'yyyy/MM')






(3)手写hql第3题
	有50w个京东店铺，每个顾客访问任何一个店铺的任何一个商品时都会产生一条访问日志，
	访问日志存储的表名为visit，访客的用户id为user_id，
	被访问的店铺名称为shop，访问时间为visit_time。
	数据样例：'huawei','1001','2017-02-10'，'apple','1001','2017-02-11'
请统计：
1)每个店铺的uv（访客数）
2)每个店铺访问次数top3的访客信息。输出店铺名称、访客id、访问次数

建表：
create table visit(user_id string,shop string) row format delimited fields terminated by '\t'; // hive

create table visit(shop varchar(10),user_id int(10),visit_name varchar(10)); // mysql

insert into visit(shop,user_id,visit_time)
values('app',1001,'2020-02-11'),
('app',1001,'2020-02-12'),
('app',1002,'2020-02-11'),
('app',1003,'2020-02-11'),
('huawei',1001,'2020-02-16'),
('huawei',1001,'2020-02-17'),
('huawei',1002,'2020-02-11'),
('huawei',1002,'2020-02-12'),
('huawei',1002,'2020-02-13'),
('huawei',1003,'2020-02-14'),
('huawei',1003,'2020-02-15'),
('huawei',1003,'2020-02-18'),
('huawei',1003,'2020-02-19'),
('huawei',1004,'2020-02-12'),
('mi',1001,'2020-02-16'),
('mi',1002,'2020-02-16')

select shop,user_id,count(*) uv from visit group by shop,user_id;
--结果
shop	user_id		uv
app		1001		2
app		1002		1
app		1003		1
huawei	1001		2
huawei	1002		3
huawei	1003		4
huawei	1004		1
mi		1001		1
mi		1002		1
	
// 每个店铺的uv（访客数）
select shop,count(distinct user_id) uv from visit group by shop;  

// 第二种写法
select shop, count (*) uv from 
(select shop,user_id, count (*) uv from visit group by shop,user_id) t1 
group by shop;


// 每个店铺访问次数top3的访客信息。输出店铺名称、访客id、访问次数
select shop,user_id,pv from(
	select shop,user_id,count(*) pv,rank() over(partition by shop order by count(*) desc) rn
	from visit group by shop,user_id ) t1 
where rn<=3;

select shop,user_id,count(*) pv,rank() over(partition by shop order by count(*) desc) rn
	from visit group by shop,user_id;
--结果
shop	user_id	pv	rn
app		1001	2	1
app		1002	1	2
app		1003	1	2
huawei	1003	4	1
huawei	1002	3	2
huawei	1001	2	3
huawei	1004	1	4
mi		1001	1	1
mi		1002	1	1

select shop,user_id,count(*) pv,rank() over(partition by shop,user_id order by count(*) desc) rn
	from visit group by shop,user_id
--结果
shop	user_id	pv	rn
app		1001	2	1
app		1002	1	1
app		1003	1	1
huawei	1001	2	1
huawei	1002	3	1
huawei	1003	4	1
huawei	1004	1	1
mi		1001	1	1
mi		1002	1	1

// 查询每个店铺被每个用户访问次数
select shop,user_id,count(*) ct from visit group by shop,user_id;   // t1

// 计算每个店铺被用户访问次数排名
select shop,user_id,ct,rank() over(partition by shop order by ct) rk from t1;   // t2

// 取每个店铺排名前3
select shop,user_id,ct from t2 where rk<=3;





(4)手写hql 第4题
已知一个表order_tbl，有如下字段:date，order_id，user_id，amount。
	请给出sql进行统计:数据样例:2017-01-01,10029028,1000003251,33.57。
	1)给出 2017年每个月的订单数、用户数、总成交金额。
	2)给出2017年11月的新客数(指在11月才有第一笔订单)
	
建表
create table order_tab(dt string,order_id string,user_id string,amount decimal(10,2)) 
row format delimited fields terminated by '\t';
	
create table order_tbl(
	`date` varchar(10),order_id varchar(10),user_id varchar(10),amount decimal(10,2));

insert into order_tbl(`date`,order_id,user_id,amount)
values('2020-02-11','10','20',10.00),
('2020-02-11','11','20',1.00),
('2020-02-11','12','21',2.0),
('2020-02-11','13','21',3.00),
('2020-02-11','14','21',4.00),
('2020-02-11','15','22',5.00),
('2020-02-11','16','23',6.00),
('2020-03-10','16','20',7.00)

--数据
date		order_id	user_id		amount
2020-02-11	10			20			10
2020-02-11	11			20			1
2020-02-11	12			21			2
2020-02-11	13			21			3
2020-02-11	14			21			4
2020-02-11	15			22			5
2020-02-11	16			23			6
2020-03-10	16			20			7

// 每月订单、用户、成交额
	select 
		date_format(`date`,'yyyy-MM') per_month, 
		count(order_id) order_count,
		count(distinct user_id) user_count,
		sum(amount) total_amount 
	from order_tbl where year(`date`)=2020 group by date_format(`date`,'yyyy-MM');	
		
	-- 结果
	per_month	order_count	user_count	total_amount
	2020-02		7			4			31
	2020-03		1			1			7



// 截止11月所有用户 - 之前所有用户
	select distinct(user_id) from order_tbl where date_format(`date`,'yyyy-MM')<='2020-02';  //t1
	select distinct(user_id) from order_tbl where date_format(`date`,'yyyy-MM')<'2020-02';   //t2

	select t1.user_id from 
		(select distinct(user_id) from order_tbl where date_format(`date`,'yyyy-MM')<='2020-03') t1 
	left join 
		(select distinct(user_id) from order_tbl where date_format(`date`,'yyyy-MM')<'2020-03') t2 
	on t1.user_id = t2.user_id where t2.user_id is null;

	
// 2020-02购买的订单中，上次没有购买信息	
select user_id,order_id,`date`,
lag(`date`,1,0) over(partition by user_id order by `date`) preorderdate
from order_tbl;   // t1
		
select count(user_id) `11月新客数` from t1
where date_format(`date`,'yyyy-MM')='2020-02' and preorderdate=0;
	
select user_id,order_id,`date`,
lag (`date`,1,0) over(partition by user_id order by `date`) preorderdate from order_tbl;
--结果
user_id	order_id	date			preorderdate
20		10			2020-02-11		0
20		11			2020-02-11		2020-02-11
20		16			2020-03-10		2020-02-11
21		12			2020-02-11		0
21		13			2020-02-11		2020-02-11
21		14			2020-02-11		2020-02-11
22		15			2020-02-11		0
23		16			2020-02-11		0

	
// 2020-02之前购买的订单中，最小日期是2020-02		
select user_id from order_tbl where date_format(`date`,'yyyy-MM') <= '2020-02'
group by user_id having date_format(min(`date`),'yyyy-MM') = '2020-02';	
--结果	
user_id
20
21
22
23





(5)手写HQL第5题
有日志如下，请写出代码求得所有用户和活跃用户的总数及平均年龄。
（活跃用户指连续两天都有访问记录的用户）日期 用户 年龄
数据集:
2019-02-11,test_1,23
2019-02-11,test_2,19
2019-02-11,test_3,39
2019-02-11,test_1,23
2019-02-11,test_3,39
2019-02-11,test_1,23
2019-02-12,test_2,19
2019-02-13,test_1,23
2019-02-15,test_2,19
2019-02-16,test_2,19
// 建表
create table user_age(dt string,user_id string,age int)row format delimited fields terminated by ',';

// 加载数据
load data local inpath "/home/atguigu/hivedatas/user_age.txt" into table user_age;

// 按照日期用户分组，排序并给出排名
select dt,user_id,min(age) age,rank() over(partition by user_id order by dt) rk
from user_age group by dt,user_id;  // t1

// 计算日期及排名差值
select user_id,age,date_sub(dt,rk) flag
from t1;    // t2

// 过滤出差值大于2
select user_id,min(age) age
from t2 group by user_id,flag having count(*)>=2;    // t3

// 去重
select user_id,min(age) age from  t3
group by user_id;      // t4

// 活跃用户平均年龄
select count(*) ct,cast(sum(age)/count(*) as decimal(10,2)) from t4;

// 所有用户
select user_id,min(age) age from user_age group by user_id;   // t5

// 平均年龄
select count(*) user_count,cast((sum(age)/count(*)) as decimal(10,1)) 
from t5;

// 合并结果集 union all
select
   0 user_total_count,
   0 user_total_avg_age,
   count(*) twice_count,
   cast(sum(age)/count(*) as decimal(10,2)) twice_count_avg_age
from t4

union all
select
   count(*) user_total_count,
   cast((sum(age)/count(*)) as decimal(10,1)),
   0 twice_count,
   0 twice_count_avg_age
from t5;  // t6

// 结果
_u1.user_total_count _u1.user_total_avg_age	_u1.twice_count	_u1.twice_count_avg_age
0	0	1	19
3	27	0	0

select 
    sum(user_total_count),
    sum(user_total_avg_age),
    sum(twice_count),
    sum(twice_count_avg_age)
from t6;

// 合并最终的结果也可以采用join的方式，在本题中join是2mapper 6reducer，
// union all是2mapper 7reducer



(6)手写HQL 第6题
请用sql写出所有用户中在今年10月份第一次购买商品的金额，
表ordertable字段:
(购买用户：userid，金额：money，购买时间：paymenttime(格式：2017-10-01)，订单id：orderid)
// 建表
create table ordertable(
	userid string,
	money int,
	paymenttime string,
	orderid string)
row format delimited fields terminated by '\t';

创建数据测试
1	11	2020-02-10	001
1	12	2020-02-10	002
2	13	2020-01-10	003
2	14	2020-02-10	004
3	15	2020-03-10	005
// load data local inpath '/home/atguigu/hivedatas/ordertable.txt' into table ordertable;

// 第一次购买
select userid,money,paymenttime,
lag (date_format(paymenttime,'yyyy-MM'),1,0) 
over(partition by userid,date_format(paymenttime,'yyyy-MM') order by date_format(paymenttime,'yyyy-MM')) last_buy
from ordertable;  // t1

select userid,sum(money)
from t1 where date_format(paymenttime,'yyyy-MM')='2020-02' and last_buy=0
group by userid;


// 用户当月最小购买时间
select userid,min(paymenttime) paymenttime
from ordertable
where date_format(paymenttime,'yyyy-MM')='2020-02'
group by userid;  // t1

// 关联求出money字段
select t1.userid,t1.paymenttime,od.money
from t1 join ordertable od
on t1.userid=od.userid and t1.paymenttime=od.paymenttime;





(7)手写HQL 第7题
有一个线上服务器访问日志格式如下(用sql答题)
时间                     接口                         ip地址
2016-11-09 11：22：05    /api/user/login              110.23.5.33
2016-11-09 11：23：10    /api/user/detail             57.3.2.16
.....
2016-11-09 23：59：40    /api/user/login              200.6.5.166

求11月9号下午14点（14-15点），访问api/user/login接口的top10的ip地址
数据集
2016-11-09 14:22:05	/api/user/login	110.23.5.33
2016-11-09 11:23:10	/api/user/detail	57.3.2.16
2016-11-09 14:59:40	/api/user/login	200.6.5.166
2016-11-09 14:22:05	/api/user/login	110.23.5.34
2016-11-09 14:22:05	/api/user/login	110.23.5.34
2016-11-09 14:22:05	/api/user/login	110.23.5.34
2016-11-09 11:23:10	/api/user/detail	57.3.2.16
2016-11-09 23:59:40	/api/user/login	200.6.5.166
2016-11-09 14:22:05	/api/user/login	110.23.5.34
2016-11-09 11:23:10	/api/user/detail	57.3.2.16
2016-11-09 23:59:40	/api/user/login	200.6.5.166
2016-11-09 14:22:05	/api/user/login	110.23.5.35
2016-11-09 14:23:10	/api/user/detail	57.3.2.16
2016-11-09 23:59:40	/api/user/login	200.6.5.166
2016-11-09 14:59:40	/api/user/login	200.6.5.166
2016-11-09 14:59:40	/api/user/login	200.6.5.166

// 建表
create table ip(
    time string,
    interface string,
    ip string)
row format delimited fields terminated by '\t';


求11月9号下午14点（14-15点），访问api/user/login接口的top10的ip地址
select ip,count(*) total_count
from ip 
where date_format(time,'yyyy-MM-dd HH') between '2016-11-09 14' and '2016-11-09 15'   
and interface='/api/user/login'
group by ip order by total_count desc limit 10;

// 方案二：
select ip,interface,count(*) ct
from ip
where date_format(time,'yyyy-MM-dd HH')>='2016-11-09 14'
and date_format(time,'yyyy-MM-dd HH')<='2016-11-09 15'
and interface='/api/user/login'
group by ip,interface
order by ct desc limit 10;






(8)手写SQL 第8题
有一个账号表如下，请写出SQL语句，查询各自区组的money排名前十的账号（分组取前10）
// 建表（MySQL）
create table `account`
(`dist_id` int（11）default null comment '区组id',
`account` varchar（100）default null comment '账号',
`gold` int（11）default 0 comment '金币');

select * from account as a
where
    (select count(distinct(a1.gold))
    from account as a1 where a1.dist_id = a.dist_id and a1.gold > a.gold) < 10;





(9)手写HQL 第9题
有三张表分别为会员表（member）销售表（sale）退货表（regoods）
（1）会员表有字段memberid（会员id，主键）credits（积分）;
（2）销售表有字段memberid（会员id，外键）购买金额（MNAccount）;
（3）退货表中有字段memberid（会员id，外键）退货金额（RMNAccount）.

业务说明
（1）销售表中的销售记录可以是会员购买，也可以是非会员购买。（即销售表中的memberid可以为空）;
（2）销售表中的一个会员可以有多条购买记录;
（3）退货表中的退货记录可以是会员，也可是非会员;
（4）一个会员可以有一条或多条退货记录。

查询需求：
分组查出销售表中所有会员购买金额，
同时分组查出退货表中所有会员的退货金额，
把会员id相同的购买金额-退款金额得到的结果更新到表会员表中对应会员的积分字段（credits）

数据集
sale
1001    50.3
1002    56.5
1003    235
1001    23.6
1005    56.2
        25.6
        33.5

regoods
1001    20.1
1002    23.6
1001    10.1
        23.5
        10.2
1005    0.8

// 建表
create table member(memberid string,credits double) row format delimited fields terminated by '\t';
create table sale(memberid string,MNAccount double) row format delimited fields terminated by '\t';
create table regoods(memberid string,RMNAccount double) row format delimited fields terminated by '\t';

// 所有会员的购买金额
select memberid,sum(MNAccount) MNAccount
from sale where memberid!='' group by memberid;  // t1

// 会员的退货金额
select memberid,sum(RMNAccount) RMNAccount
from regoods where memberid!='' group by memberid; // t2
 
// 插入数据
insert into table member
select t1.memberid,MNAccount-RMNAccount
from t1 join t2 on t1.memberid=t2.memberid;





(10)手写HQL 第10题
1. 用一条SQL语句查询出每门课都大于80分的学生姓名
name   kecheng   fenshu
张三    语文    81
张三    数学    75
李四    语文    76
李四    数学    90
王五    语文    81
王五    数学    100
王五    英语    90

A: select distinct name from table where name not in (select distinct name from table where fenshu <= 80)
B：select name from table group by name having min(fenshu)>80

2. 学生表如下:
自动编号   	学号  		姓名 	课程编号 	课程名称 	分数
1     		2005001 	张三   	0001   		数学   		69
2     		2005002 	李四   	0001   		数学   		89
3     		2005001 	张三   	0001   		数学   		69
删除除了自动编号不同, 其他都相同的学生冗余信息

delete tablename where 自动编号 not in(select min(自动编号) from tablename group by 学号, 姓名, 课程编号, 课程名称, 分数)


3.一个叫team的表，里面只有一个字段name,一共有4条纪录，分别是a,b,c,d,对应四个球队，
现在四个球队进行比赛，用一条sql语句显示所有可能的比赛组合.

select a.name, b.name from team a, team b where a.name < b.name


4.面试题：怎么把这样一个
year   month amount
1991   1     1.1
1991   2     1.2
1991   3     1.3
1991   4     1.4
1992   1     2.1
1992   2     2.2
1992   3     2.3
1992   4     2.4
查成这样一个结果
year m1  m2  m3   m4
1991 1.1 1.2 1.3 1.4
1992 2.1 2.2 2.3 2.4 

答案
select year, 
(select amount from aaa m where month=1 and m.year=aaa.year) as m1,
(select amount from aaa m where month=2 and m.year=aaa.year) as m2,
(select amount from aaa m where month=3 and m.year=aaa.year) as m3,
(select amount from  aaa m where month=4 and m.year=aaa.year) as m4
from aaa group by year


5.说明：复制表(只复制结构,源表名：a 新表名：b) 
SQL: select * into b from a where 1<>1 (where1=1，拷贝表结构和数据内容)
ORACLE: create table b As select * from a where 1=2
 

6. 原表: courseid coursename score
-------------------------------------
1 java 70
2 oracle 90
3 xml 40
4 jsp 30
5 servlet 80
-------------------------------------
为了便于阅读,查询此表后的结果显式如下(及格分数为60):
courseid coursename score mark
---------------------------------------------------
1 java 70 pass
2 oracle 90 pass
3 xml 40 fail
4 jsp 30 fail
5 servlet 80 pass
---------------------------------------------------
写出此查询语句
select courseid, coursename ,score ,if(score>=60, "pass","fail")  as mark from course;


7.表名：购物信息
购物人      商品名称     数量
A            甲          2
B            乙          4
C            丙          1
A            丁          2
B            丙          5
……
 
给出所有购入商品为两种或两种以上的购物人记录?
select * from 购物信息 where 购物人 in (select 购物人 from 购物信息 group by 购物人 having count(*) >= 2);


8.info表
date result
2005-05-09 win
2005-05-09 lose 
2005-05-09 lose 
2005-05-09 lose 
2005-05-10 win 
2005-05-10 lose 
2005-05-10 lose 
如果要生成下列结果, 该如何写sql语句? 
date  　　  win lose
2005-05-09  2   2 
2005-05-10  1   2 

答案： 
(1) select date,
	sum(case when result = "win" then 1 else 0 end) as "win", 
	sum(case when result = "lose" then 1 else 0 end) as "lose"
from info group by date; 

(2) select a.date, a.result as win, b.result as lose 
　　from 
　　(select date, count(result) as result from info where result = "win" group by date) as a 
　　join 
　　(select date, count(result) as result from info where result = "lose" group by date) as b 
on a.date = b.date;






