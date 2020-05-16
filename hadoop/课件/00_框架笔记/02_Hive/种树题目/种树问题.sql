一、数据
	plant_carbon.plant_id    | plant_carbon.plant_name  | plant_carbon.low_carbon 
	user_low_carbon.user_id  | user_low_carbon.data_dt  | user_low_carbon.low_carbon 
 
	提供的数据说明：
	流水表：记录了用户每天的蚂蚁森林低碳生活领取的记录流水。
		    table_name：user_low_carbon
			
	user_id data_dt     low_carbon
	u_001	2017/1/1	10
	u_001	2017/1/2	150
	u_001	2017/1/2	110
	u_001	2017/1/2	10
	u_001	2017/1/4	50
	u_001	2017/1/4	10
	u_001	2017/1/6	45
	u_001	2017/1/6	90
	u_002	2017/1/1	10
	u_002	2017/1/2	150
	u_002	2017/1/2	70
	u_002	2017/1/3	30
	u_002	2017/1/3	80
	u_002	2017/1/4	150
	u_002	2017/1/5	101
	u_002	2017/1/6	68
	...


	蚂蚁森林植物换购表:
		用于记录申领环保植物所需要减少的碳排放量
		table_name:plant_carbon
		
	植物编号	植物名		换购植物所需要的碳
	plant_id	plant_name	low_carbon
	p001		梭梭树		17
	p002		沙柳		19
	p003		樟子树		146
	p004		胡杨		215


	① 创建表
	create table user_low_carbon(user_id String,data_dt String,low_carbon int) 
		row format delimited fields terminated by '\t';
	
	create table plant_carbon(plant_id string,plant_name String,low_carbon int) 
		row format delimited fields terminated by '\t';

	② 加载数据
	load data local inpath "/home/atguigu/hivedatas/user_low_carbon.txt" into table user_low_carbon;
	load data local inpath "/home/atguigu/hivedatas/plant_carbon.txt" into table plant_carbon;

	③ 设置本地模式
	set hive.exec.mode.local.auto=true; 
 
 
	④答案格式：
	----------第一题---------------
	user_id	sum_low_carbon	sl_count	_c3
	u_007	1470	66	3
	u_013	1430	63	10
	u_008	1240	53	7
	u_005	1100	46	1
	u_010	1080	45	1
	u_014	1060	44	5
	u_011	960		39	2
	u_009	930		37	5
	u_006	830		32	9
	u_002	659		23	1

	----------第二题---------------
	t.user_id	t.data_dt	t.low_carbon
	u_002	2017/1/2	150
	u_002	2017/1/2	70
	u_002	2017/1/3	30
	u_002	2017/1/3	80
	u_002	2017/1/4	150
	u_002	2017/1/5	101
	u_005	2017/1/2	50
	u_005	2017/1/2	80
	u_005	2017/1/3	180
	u_005	2017/1/4	180
	u_005	2017/1/4	10
	u_008	2017/1/4	260
	u_008	2017/1/5	360
	u_008	2017/1/6	160
	u_008	2017/1/7	60
	u_008	2017/1/7	60
	u_009	2017/1/2	70
	u_009	2017/1/2	70
	u_009	2017/1/3	170
	u_009	2017/1/4	270
	u_010	2017/1/4	90
	u_010	2017/1/4	80
	u_010	2017/1/5	90
	u_010	2017/1/5	90
	u_010	2017/1/6	190
	u_010	2017/1/7	90
	u_010	2017/1/7	90
	u_011	2017/1/1	110
	u_011	2017/1/2	100
	u_011	2017/1/2	100
	u_011	2017/1/3	120
	u_013	2017/1/2	150
	u_013	2017/1/2	50
	u_013	2017/1/3	150
	u_013	2017/1/4	550
	u_013	2017/1/5	350
	u_014	2017/1/5	250
	u_014	2017/1/6	120
	u_014	2017/1/7	270
	u_014	2017/1/7	20 
 
 
 
二、需求一
	1.蚂蚁森林植物申领统计
		问题：假设2017年1月1日开始记录低碳数据（user_low_carbon），
		假设2017年10月1日之前满足申领条件的用户都申领了一颗p004-胡杨，
		剩余的能量全部用来领取"p002-沙柳"。
		统计在10月1日累计申领"p002-沙柳"排名前10的用户信息；以及他比后一名多领了几颗沙柳。
		得到的统计结果如下表样式：
		user_id,plant_count,less_count(比后一名多领了几颗沙柳);


	①统计用户在 2017-1-1 至 2017-10-1期间一共收集了多少碳量
		// 注意between and中字符串的比较规则，逐位比较，忽略长度
		// '/'与'-'的ascII的值都比0小，顺序为：- / 0
		select user_id,sum(low_carbon) sumCarbon
		from user_low_carbon
		where regexp_replace(data_dt,'/','-') between '2017-1-1' and  '2017-10-1'
		group by user_id    //t1
	
	user_id sumCarbon
	u_001	475
	u_002	659
	u_003	620
	u_004	640
	u_005	1100
	u_006	830
	u_007	1470
	u_008	1240
	u_009	930
	u_010	1080
	u_011	960
	u_012	250
	u_013	1430
	u_014	1060
	u_015	290
	

	②统计胡杨和沙柳单价
		胡杨单价：
			select low_carbon huyangCarbon from  plant_carbon where  plant_id='p004';  //t2

		沙柳单价： 
			select low_carbon shaliuCarbon from  plant_carbon where  plant_id='p002';  //t3


	③计算每个用户领取了多少棵沙柳,t2 t3只有一列 join以后直接添加一个字段
		select user_id, floor((sumCarbon-huyangCarbon)/shaliuCarbon) shaliuCount
		from t1 join t2 join t3
		order by shaliuCount desc		
	limit 11       //t4
	
	+-------------+---------------+------------------+------------------+--------------+--+
	| t1.user_id  | t1.sumcarbon  | t2.huyangcarbon  | t3.shaliucarbon  | shaliucount  |
	+-------------+---------------+------------------+------------------+--------------+--+
	| u_007       | 1470          | 215              | 19               | 66           |
	| u_013       | 1430          | 215              | 19               | 63           |
	| u_008       | 1240          | 215              | 19               | 53           |
	| u_005       | 1100          | 215              | 19               | 46           |
	| u_010       | 1080          | 215              | 19               | 45           |
	| u_014       | 1060          | 215              | 19               | 44           |
	| u_011       | 960           | 215              | 19               | 39           |
	| u_009       | 930           | 215              | 19               | 37           |
	| u_006       | 830           | 215              | 19               | 32           |
	| u_002       | 659           | 215              | 19               | 23           |
	| u_004       | 640           | 215              | 19               | 22           |
	| u_003       | 620           | 215              | 19               | 21           |
	| u_001       | 475           | 215              | 19               | 13           |
	| u_015       | 290           | 215              | 19               | 3            |
	| u_012       | 250           | 215              | 19               | 1            |
	+-------------+---------------+------------------+------------------+--------------+--+

	④统计前10用户，比后一名多多少
		select user_id,shaliuCount,rank() over(order by shaliuCount desc),
			shaliuCount-lead(shaliuCount,1,0) over(order by shaliuCount desc)
		from t4
		// 注意：查询上一行与下一行的差值 

	------------------组合后的sql-------------------------------------
	select user_id,shaliuCount,rank() over(order by shaliuCount desc),
	shaliuCount-lead(shaliuCount,1,0) over(order by shaliuCount desc)
	from 
		(select  user_id, floor((sumCarbon-huyangCarbon)/shaliuCarbon) shaliuCount
		from  
		(select user_id,sum(low_carbon) sumCarbon
		from user_low_carbon
			where regexp_replace(data_dt,'/','-') between '2017-1-1' and  '2017-10-1'
			group by  user_id ) t1 
		join 
			(select low_carbon huyangCarbon from  plant_carbon where  plant_id='p004') t2 
		join 
			(select low_carbon shaliuCarbon from  plant_carbon where  plant_id='p002') t3
		order by shaliuCount desc
		limit 11) t4
	// 返回的结果是11条；
	
	u_007	66	1	3
	u_013	63	2	10
	u_008	53	3	7
	u_005	46	4	1
	u_010	45	5	1
	u_014	44	6	5
	u_011	39	7	2
	u_009	37	8	5
	u_006	32	9	9
	u_002	23	10	1
	u_004	22	11	22
	
	
	
	
三、题目二
	问题：查询user_low_carbon表中每日流水记录，条件为：
		用户在2017年，连续三天（或以上）的天数里，
		每天减少碳排放（low_carbon）都超过100g的用户低碳流水。
		需要查询返回满足以上条件的user_low_carbon表中的记录流水【不去重】。
		例如用户u_002符合条件的记录，2017/1/2~2017/1/5连续四天的碳排放量之和都大于等于100g;

		plant_carbon.plant_id    | plant_carbon.plant_name  | plant_carbon.low_carbon 
		user_low_carbon.user_id  | user_low_carbon.data_dt  | user_low_carbon.low_carbon 

		
	①过滤2017年的数据，统计每个用户每天共收集了多少碳
		select user_id,regexp_replace(data_dt,'/','-') dt,sum(low_carbon) carbonPerDay
		from user_low_carbon
		where year(regexp_replace(data_dt,'/','-'))=2017 
			group by user_id,data_dt having  carbonPerDay >= 100  //t1


	②过滤复合连续3天的数据
		如果判断当前记录复合连续三天的条件？
		a)如果当前日期位于连续三天中的第一天，
		  使用当前日期减去当前日期后一天的日期，差值一定为-1，
		  使用当前日期减去当前日期后二天的日期，差值一定为-2，
												
		b)如果当前日期位于连续三天中的第二天，
		  使用当前日期减去 当前日期前一天的日期，差值一定为1，
		  使用当前日期减去 当前日期后一天的日期，差值一定为-1，
												
		c)如果当前日期位于连续三天中的第三天，
		  使用当前日期减去 当前日期前一天的日期，差值一定为1，
		  使用当前日期减去 当前日期前二天的日期，差值一定为2，
												
		满足a,b,c其中之一，当前日期就复合要求
		

	求当前日期和当前之前，前1，2天和后1，2天日期的差值

	select user_id,dt,carbonPerDay,
		datediff(dt,lag(dt,1,'1970-1-1') over(partition by user_id order by dt))  pre1diff,
		datediff(dt,lag(dt,2,'1970-1-1') over(partition by user_id order by dt))  pre2diff,
		datediff(dt,lead(dt,1,'1970-1-1') over(partition by user_id order by dt)) after1diff,
		datediff(dt,lead(dt,2,'1970-1-1') over(partition by user_id order by dt)) after2diff
	from  t1    //t2


	③过滤数据
		select user_id,regexp_replace(dt,'-','/') newdt,carbonPerDay
		from t2
		where (after1diff=-1 and after2diff=-2)  or 
			  (pre1diff=1 and after1diff=-1)     or 
			  (pre1diff=1 and pre2diff=2)    // t3

	  
	④关联原表，求出每日的流水
		select u.*
		from t3 join user_low_carbon u
		on t3.user_id=u.user_id and t3.newdt=u.data_dt

	----------------------组合最终SQL-------------------
	select u.*
	from 
		(select user_id,regexp_replace(dt,'-','/') newdt,carbonPerDay
		from  
		(select  user_id,dt,carbonPerDay,
			datediff(dt,lag(dt,1,'1970-1-1') over(partition by user_id order by dt)) pre1diff,
			datediff(dt,lag(dt,2,'1970-1-1') over(partition by user_id order by dt)) pre2diff,
			datediff(dt,lead(dt,1,'1970-1-1') over(partition by user_id order by dt)) after1diff,
			datediff(dt,lead(dt,2,'1970-1-1') over(partition by user_id order by dt)) after2diff
			from  (select  user_id,regexp_replace(data_dt,'/','-') dt,sum(low_carbon) carbonPerDay
			from  user_low_carbon
			where year(regexp_replace(data_dt,'/','-'))=2017
			group by user_id,data_dt 
			having  carbonPerDay >= 100)t1) t2
		where (after1diff=-1 and  after2diff=-2)   or 
					(pre1diff=1 and after1diff=-1) or 
					(pre1diff=1 and pre2diff=2)) t3 
	join user_low_carbon u on t3.user_id=u.user_id and t3.newdt=u.data_dt;
		
		

四、题目二解法二
	问题：查询user_low_carbon表中每日流水记录，条件为：
		用户在2017年，连续三天（或以上）的天数里，
		每天减少碳排放（low_carbon）都超过100g的用户低碳流水。
		需要查询返回满足以上条件的user_low_carbon表中的记录流水【不去重】。

	①过滤2017年的数据，统计每个用户每天共收集了多少碳
		select user_id,regexp_replace(data_dt,'/','-') dt,sum(low_carbon) carbonPerDay
		from user_low_carbon
			where year(regexp_replace(data_dt,'/','-'))=2017
			group by user_id,data_dt having  carbonPerDay >= 100  //t1

	如何判断当前数据是连续的？
		如何理解连续？
		当前有A,B两列，A列的起始值从a开始，B列的起始值从b开始,
				假设A列每次递增X，B列每次递增Y。
				如果A列和B列都是连续递增！A列和B列之间的差值，总是相差(x-y)。
				如果X=Y，A列和B列之间的差值，总是相差0。
		
				A			B
			1.	a			b				a-b
			2. 	a+X			b+Y				(a-b)+(x-y)
			3.	a+2x		b+2y			(a-b)+2(x-y)
			4.	a+3x		b+3y
			n	a+(n-1)x	b+(n-1)y


		判断日期是连续的？连续的日期，每行之间的差值为1
			连续的日期每次递增1，再提供一个参考列，这个参考列每次也是递增1
			dt，从2017-1-1开始递增，每次递增1
			B列，从1开始递增，每次递增1
			如果dt列和B列都是连续的！
			此时，dt列-B列=每行的差值每行的差值之间的差值，一定等于0，每行之间的差值相等！
			
			dt						列B				diff
			2017-1-1				1				2016-12-31
			2017-1-3				2				2017-1-1
			2017-1-5				3				2017-1-2
			2017-1-6				4				2017-1-2
			2017-1-7				5				2017-1-2
			2017-1-8				6				2017-1-2
			2017-1-12				7				2017-1-5
			2017-1-13				8				2017-1-5
			2017-1-15				9				2017-1-6
			2017-1-16				10				2017-1-6
			2017-1-17				11				2017-1-6

	
	
	//判断连续,求出中间表,差值一样连续
	select user_id,dt,carbonPerDay,
		date_sub(dt,row_number() over(partition by user_id order by dt)) diff
	from t1   //t2

	//判断连续的天数超过3天 count(*) 统计每一个分区的数量
	select user_id,dt,carbonPerDay,diff,count(*) over(partition by user_id,diff) diffcount
	from t2   //t3

	// 过滤超过3天的数据
	select user_id,dt from t3 where diffcount>=3   //t4

	// 关联原表求出结果即可
	select u.* from t4 join user_low_carbon u on t4.user_id=u.user_id and t4.newdt=u.data_dt
	
	-------------------------------------sql拼接结果-------------------------------------
	select u.*
	from 
		(select user_id,regexp_replace(dt,'-','/') newdt
		from 
			(select user_id,dt,carbonPerDay,diff,count(*) over(partition by user_id,diff) diffcount
			from 
				(select user_id,dt,carbonPerDay,
					date_sub(dt,row_number() over(partition by user_id order by dt)) diff
				from 
					(select user_id,regexp_replace(data_dt,'/','-') dt,sum(low_carbon) carbonPerDay
					from user_low_carbon
						where year(regexp_replace(data_dt,'/','-'))=2017
						group by user_id,data_dt 
						having  carbonPerDay >= 100) t1)
		t2) t3
		where diffcount>=3) t4 
	join user_low_carbon u
	on t4.user_id=u.user_id and t4.newdt=u.data_dt


五、总结
	where year(regexp_replace(data_dt,'/','-'))=2017
	
	where regexp_replace(data_dt,'/','-') between '2017-1-1' and  '2017-10-1'
	
	floor((sumCarbon-huyangCarbon)/shaliuCarbon) shaliuCount

	shaliuCount-lead(shaliuCount,1,0) over(order by shaliuCount desc)

	datediff(dt,lag(dt,2,'1970-1-1') over(partition by user_id order by dt))  pre2diff
	
	datediff(dt,lead(dt,1,'1970-1-1') over(partition by user_id order by dt)) after1diff

	//判断连续,求出中间表,差值一样连续
	select user_id,dt,carbonPerDay,
		date_sub(dt,row_number() over(partition by user_id order by dt)) diff
	from t1   //t2

	//判断连续的天数超过3天 count(*) 统计每一个分区的数量
	select user_id,dt,carbonPerDay,diff,count(*) over(partition by user_id,diff) diffcount
	from t2   //t3

	// 过滤超过3天的数据
	select user_id,dt from t3 where diffcount>=3   //t4











