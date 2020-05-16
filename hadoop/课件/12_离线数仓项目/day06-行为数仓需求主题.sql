
行为数仓需求全部sql

	=============================需求1 每日活跃设备明细=========================	
	活跃用户：
		用户：  每个设备作为一个用户！mid号是用户的相关标识！
		活跃：  打开了应用，称为活跃用户！
				只要打开了应用，此时会产生启动日志信息！
	每日活跃设备明细：求每天的活跃设备明细，因此表应该是一个按照日期分区的分区表！
		明细：需要把cm字段的所有数据都写入到此表中！	
		
	-----------------------------相关表---------------------
	从dwd_start_log启动日志表中取数据
	
	-----------------------------思路-----------------------
	从dwd_start_log中查询数据时，需要根据mid号进行去重，将同一个设备产生的多条明细信息
	去重后再拼接，一个设备在表中以一行存在
	# 向分区表导入数据时，指定了分区值，查询的时候不需要赋值了！

	-----------------------------建表语句-------------------------------------
	create external table dws_uv_detail_day(
		`mid_id` 		string COMMENT '设备唯一标识',
		`user_id` 		string COMMENT '用户标识', 
		`version_code` 	string COMMENT '程序版本号', 
		`version_name` 	string COMMENT '程序版本名', 
		`lang` 			string COMMENT '系统语言', 
		`source` 		string COMMENT '渠道号', 
		`os` 			string COMMENT '安卓系统版本', 
		`area` 			string COMMENT '区域', 
		`model` 		string COMMENT '手机型号', 
		`brand` 		string COMMENT '手机品牌', 
		`sdk_version` 	string COMMENT 'sdkVersion', 
		`gmail` 		string COMMENT 'gmail', 
		`height_width` 	string COMMENT '屏幕宽高',
		`app_time` 		string COMMENT '客户端日志产生时的时间',
		`network` 		string COMMENT '网络模式',
		`lng` 			string COMMENT '经度',
		`lat` 			string COMMENT '纬度'
	)
	partitioned by(dt string)
	stored as parquet
	location '/warehouse/gmall/dws/dws_uv_detail_day';

	-----------------------------SQL------------------------
	insert overwrite table gmall.dws_uv_detail_day PARTITION(dt='2020-02-14')
	SELECT 
	mid_id, 
	concat_ws('|',collect_set(user_id)) user_id,
	concat_ws('|',collect_set(version_code)) version_code,
	concat_ws('|',collect_set(version_name)) version_name, 
	concat_ws('|',collect_set(lang)) lang, 
	concat_ws('|',collect_set(source)) source,
	concat_ws('|',collect_set(os)) os, 
	concat_ws('|',collect_set(area)) area, 
	concat_ws('|',collect_set(model)) model,
	concat_ws('|',collect_set(brand)) brand,
	concat_ws('|',collect_set(sdk_version)) sdk_version,
	concat_ws('|',collect_set(gmail)) gmail,
	concat_ws('|',collect_set(height_width)) height_width,
	concat_ws('|',collect_set(app_time)) app_time,
	concat_ws('|',collect_set(network)) network,
	concat_ws('|',collect_set(lng)) lng, 
	concat_ws('|',collect_set(lat)) lat
	FROM gmall.dwd_start_log
	where dt='2020-02-14'
	group by mid_id


	-----------------------------需求1.每周活跃设备明细-----------------------
	周活跃：在一周中，只要启动一次APP，就算是周活跃用户
	
	-----------------------------相关表---------------------
	从dws_uv_detail_day表中取数据

	-----------------------------思路-----------------------
	选取一周的范围，作为过滤的条件
	从dws_uv_detail_day中查询数据时，需要根据mid号进行去重，将同一个设备产生的多条明细信息
	去重后再拼接，一个设备在表中以一行存在

	求导入数据当前日期所在的周一和周日
	周一： date_sub(next_day('2020-02-14','mo'),7)
		   date_add(next_day('2020-02-14','mo'),-7)
		   
	周日： date_sub(next_day('2020-02-14','mo'),1)
		错误：date_sub(next_day('2020-02-14','sunday'),7)
			
	wk_dt(分区列)： 
		concat(date_sub(next_day('2020-02-14','mo'),7),'-',date_sub(next_day('2020-02-14','mo'),1))

	-----------------------------建表语句------------------------
	create external table dws_uv_detail_wk( 
		`mid_id` 		string COMMENT '设备唯一标识',
		`user_id` 		string COMMENT '用户标识', 
		`version_code` 	string COMMENT '程序版本号', 
		`version_name` 	string COMMENT '程序版本名', 
		`lang` 			string COMMENT '系统语言', 
		`source` 		string COMMENT '渠道号', 
		`os` 			string COMMENT '安卓系统版本', 
		`area` 			string COMMENT '区域', 
		`model` 		string COMMENT '手机型号', 
		`brand` 		string COMMENT '手机品牌', 
		`sdk_version` 	string COMMENT 'sdkVersion', 
		`gmail` 		string COMMENT 'gmail', 
		`height_width` 	string COMMENT '屏幕宽高',
		`app_time` 		string COMMENT '客户端日志产生时的时间',
		`network` 		string COMMENT '网络模式',
		`lng` 			string COMMENT '经度',
		`lat` 			string COMMENT '纬度',
		`monday_date`	string COMMENT '周一日期',
		`sunday_date` 	string COMMENT  '周日日期' 
	) COMMENT '活跃用户按周明细'
	PARTITIONED BY (`wk_dt` string)
	stored as parquet
	location '/warehouse/gmall/dws/dws_uv_detail_wk/';

	-----------------------------SQL------------------------
	set hive.exec.dynamic.partition.mode=nonstrict;
	insert overwrite TABLE gmall.dws_uv_detail_wk PARTITION(wk_dt)
	SELECT 
	mid_id, 
	concat_ws('|',collect_set(user_id)) user_id,
	concat_ws('|',collect_set(version_code)) version_code,
	concat_ws('|',collect_set(version_name)) version_name, 
	concat_ws('|',collect_set(lang)) lang, 
	concat_ws('|',collect_set(source)) source,
	concat_ws('|',collect_set(os)) os, 
	concat_ws('|',collect_set(area)) area, 
	concat_ws('|',collect_set(model)) model,
	concat_ws('|',collect_set(brand)) brand,
	concat_ws('|',collect_set(sdk_version)) sdk_version,
	concat_ws('|',collect_set(gmail)) gmail,
	concat_ws('|',collect_set(height_width)) height_width,
	concat_ws('|',collect_set(app_time)) app_time,
	concat_ws('|',collect_set(network)) network,
	concat_ws('|',collect_set(lng)) lng, 
	concat_ws('|',collect_set(lat)) lat,
	date_sub(next_day('2020-02-14','mo'),7) monday_date,
	date_sub(next_day('2020-02-14','mo'),1) sunday_date,
	concat(date_sub(next_day('2020-02-14','mo'),7),'-',date_sub(next_day('2020-02-14','mo'),1))
	FROM gmall.dws_uv_detail_day
	where dt BETWEEN date_sub(next_day('2020-02-14','mo'),7) and date_sub(next_day('2020-02-14','mo'),1) 
	group by mid_id;


	-----------------------------需求1.每月活跃设备明细-----------------------
	-----------------------------相关表---------------------
	从dws_uv_detail_day表中取数据
	-----------------------------思路-----------------------
	选取一月的范围，作为过滤的条件！
	从dws_uv_detail_day中查询数据时，需要根据mid号进行去重，将同一个设备产生的多条明细信息
	去重后再拼接，一个设备在表中以一行存在！
	一个月中相同的mid_id只出现一次

	-----------------------------建表语句-----------------------
	create external table dws_uv_detail_mn( 
		`mid_id` 		string COMMENT '设备唯一标识',
		`user_id` 		string COMMENT '用户标识', 
		`version_code` 	string COMMENT '程序版本号', 
		`version_name` 	string COMMENT '程序版本名', 
		`lang` 			string COMMENT '系统语言', 
		`source` 		string COMMENT '渠道号', 
		`os` 			string COMMENT '安卓系统版本', 
		`area` 			string COMMENT '区域', 
		`model` 		string COMMENT '手机型号', 
		`brand` 		string COMMENT '手机品牌', 
		`sdk_version` 	string COMMENT 'sdkVersion', 
		`gmail` 		string COMMENT 'gmail', 
		`height_width`	string COMMENT '屏幕宽高',
		`app_time` 		string COMMENT '客户端日志产生时的时间',
		`network` 		string COMMENT '网络模式',
		`lng` 			string COMMENT '经度',
		`lat` 			string COMMENT '纬度'
	) COMMENT '活跃用户按月明细'
	PARTITIONED BY (`mn` string)
	stored as parquet
	location '/warehouse/gmall/dws/dws_uv_detail_mn/';

	-----------------------------SQL------------------------
	set hive.exec.dynamic.partition.mode=nonstrict;
	insert overwrite TABLE gmall.dws_uv_detail_mn PARTITION(mn)
	SELECT 
	mid_id, 
	concat_ws('|',collect_set(user_id)) user_id,
	concat_ws('|',collect_set(version_code)) version_code,
	concat_ws('|',collect_set(version_name)) version_name, 
	concat_ws('|',collect_set(lang)) lang, 
	concat_ws('|',collect_set(source)) source,
	concat_ws('|',collect_set(os)) os, 
	concat_ws('|',collect_set(area)) area, 
	concat_ws('|',collect_set(model)) model,
	concat_ws('|',collect_set(brand)) brand,
	concat_ws('|',collect_set(sdk_version)) sdk_version,
	concat_ws('|',collect_set(gmail)) gmail,
	concat_ws('|',collect_set(height_width)) height_width,
	concat_ws('|',collect_set(app_time)) app_time,
	concat_ws('|',collect_set(network)) network,
	concat_ws('|',collect_set(lng)) lng, 
	concat_ws('|',collect_set(lat)) lat,
	date_format('2020-02-14','yyyy-MM')
	FROM gmall.dws_uv_detail_day
	where date_format('2020-02-14','yyyy-MM')=date_format(dt,'yyyy-MM')
	group by mid_id;



	-----------------------------需求1.生成每日，周，月后跃设备数量-----------------------
	-----------------------------相关表---------------------
	dws_uv_detail_day
	dws_uv_detail_wk
	dws_uv_detail_mn
	-----------------------------思路-----------------------
	dws_uv_detail_day，使用count(mid_id)统计日活跃设备数
	dws_uv_detail_wk， 使用count(mid_id)统计周活跃设备数
	dws_uv_detail_mn， 使用count(mid_id)统计月活跃设备数
	
	is_weekend：
		是否是一周的最后一天：if(date_sub(next_day('2020-02-14','mo'),1)='2020-02-14','Y','N')
			先求当前日期所在的周日：date_sub(next_day('2020-02-14','mo'),1)
			判断当前日期是否等于当前所在周的周日
				
	is_monthend：是否是一月的最后一天  if(last_day('2020-02-14')='2020-02-14','Y','N')
	
	-----------------------------建表语句------------------------			
	create external table ads_uv_count( 
		`dt` 			string COMMENT '统计日期',
		`day_count` 	bigint COMMENT '当日用户数量',
		`wk_count`  	bigint COMMENT '当周用户数量',
		`mn_count`  	bigint COMMENT '当月用户数量',
		`is_weekend` 	string COMMENT 'Y,N是否是周末,用于得到本周最终结果',
		`is_monthend` 	string COMMENT 'Y,N是否是月末,用于得到本月最终结果' 
	) COMMENT '活跃设备数'
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_uv_count/';
				
	-----------------------------SQL------------------------
	INSERT into table gmall.ads_uv_count
	SELECT 
		'2020-02-14' dt, 
		day_count, 
		wk_count, 
		mn_count, 
		if(date_sub(next_day('2020-02-14','mo'),1)='2020-02-14','Y','N') is_weekend, 
		if(last_day('2020-02-14')='2020-02-14','Y','N') is_monthend	
	FROM (select count(mid_id) day_count from gmall.dws_uv_detail_day where dt='2020-02-14') t1
	JOIN(select count(mid_id) wk_count from gmall.dws_uv_detail_wk WHERE wk_dt=
		concat(date_sub(next_day('2020-02-14','mo'),7),'-',date_sub(next_day('2020-02-14','mo'),1))) t2
	join(select count(mid_id) mn_count  from gmall.dws_uv_detail_mn 
		WHERE mn=date_format('2020-02-14','yyyy-MM')) t3



		
		
		
		
		
		
	=============================需求2 新增用户主题=========================
	新增用户： 
		用户：一个设备，作为一个用户，主要通过mid_id表示
		新增：第一次打开应用使用的用户称为新增用户
				
	-----------------------------需求2.每日新增设备明细-----------------------
	-----------------------------相关表---------------------
	dws_uv_detail_day(日活表)中查询
	dws_new_mid_day(每日新增设备表)
	
	-----------------------------思路-----------------------
	dws_uv_detail_day包含今天所有的活跃用户的信息：
			今天所有的活跃用户= 今天的新增用户 + 之前的历史用户 
			
	要向dws_new_mid_day插入的是2020-02-14的新用户，dws_new_mid_day里面已经有了
	从应用统计-2020-02-13所有的老用户信息，老用户的信息是唯一的！

	今天的新增用户=今天的活跃用户-之前的历史用户！

	今天的日活用户为集合 a
	之前的历史用户为集合 b 

	取a差b：  a left join b where b.xxx is null

	a集合：                  b集合
	mid_id  name			mid_id  age
	1		a				1		3
	2		b				4		6
	3		c

	a left join b on a.mid_id = b.mid_id where b.mid_id is null
	
		a集合：                 b集合
	mid_id  name			mid_id  age
	1		a				1		3
	2		b				null	null
	3		c				null	null	

	-----------------------------建表语句------------------------
	create external table dws_new_mid_day(
		`mid_id` 		string COMMENT '设备唯一标识',
		`user_id` 		string COMMENT '用户标识', 
		`version_code` 	string COMMENT '程序版本号', 
		`version_name` 	string COMMENT '程序版本名', 
		`lang` 			string COMMENT '系统语言', 
		`source` 		string COMMENT '渠道号', 
		`os` 			string COMMENT '安卓系统版本', 
		`area` 			string COMMENT '区域', 
		`model` 		string COMMENT '手机型号', 
		`brand` 		string COMMENT '手机品牌', 
		`sdk_version` 	string COMMENT 'sdkVersion', 
		`gmail` 		string COMMENT 'gmail', 
		`height_width` 	string COMMENT '屏幕宽高',
		`app_time` 		string COMMENT '客户端日志产生时的时间',
		`network` 		string COMMENT '网络模式',
		`lng` 			string COMMENT '经度',
		`lat` 			string COMMENT '纬度',
		`create_date`  	string COMMENT '创建时间' 
		) COMMENT '每日新增设备信息'
	stored as parquet
	location '/warehouse/gmall/dws/dws_new_mid_day/';
	 
	-----------------------------SQL------------------------
	insert into table gmall.dws_new_mid_day
	SELECT t1.* FROM  
	(select * from dws_uv_detail_day where dt='2020-02-14') t1
	LEFT JOIN gmall.dws_new_mid_day nm on t1.mid_id=nm.mid_id WHERE nm.mid_id is null;



	-----------------------------需求2.统计每日新增设备数-----------------------
	-----------------------------相关表---------------------
	从dws_new_mid_day，执行count统计即可

	-----------------------------建表语句-----------------------
	create external table ads_new_mid_count(
		`create_date`     string comment '创建时间' ,
		`new_mid_count`   BIGINT comment '新增设备数量' 
	) COMMENT '每日新增设备信息数量'
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_new_mid_count/';

	-----------------------------SQL------------------------
	insert into table ads_new_mid_count
	SELECT '2020-02-14',count(*) FROM  dws_new_mid_day where create_date='2020-02-14'








	=============================需求3 留存主题=========================
	-----------------------------DWS层每日留存用户明细表-----------------
	-----------------------------相关表---------------------
	dws_new_mid_day：每日的新增用户表
	dws_uv_detail_day:日活表

	-----------------------------思路-----------------------
	今天日活量中昨天新增的就是留存一天的；
	明细信息：从dws_uv_detail_day(日活表)取；
	
	create_date: 设备的新增日期（哪一天成为新用户的）从dws_new_mid_day根据mid_id查询
	retention_day：截至到当前日期留存的天数
			
	dt(日活数据的日期) = create_date + retention_day

	-----------------------------建表语句------------------------
	create external table dws_user_retention_day(
		`mid_id` 			string COMMENT '设备唯一标识',
		`user_id` 			string COMMENT '用户标识', 
		`version_code` 		string COMMENT '程序版本号', 
		`version_name` 		string COMMENT '程序版本名', 
		`lang` 				string COMMENT '系统语言', 
		`source` 			string COMMENT '渠道号', 
		`os` 				string COMMENT '安卓系统版本', 
		`area` 				string COMMENT '区域', 
		`model` 			string COMMENT '手机型号', 
		`brand` 			string COMMENT '手机品牌', 
		`sdk_version` 		string COMMENT 'sdkVersion', 
		`gmail` 			string COMMENT 'gmail', 
		`height_width` 		string COMMENT '屏幕宽高',
		`app_time` 			string COMMENT '客户端日志产生时的时间',
		`network` 			string COMMENT '网络模式',
		`lng` 				string COMMENT '经度',
		`lat` 				string COMMENT '纬度',
	    `create_date`  		string COMMENT '设备新增时间',
	    `retention_day`  	int    COMMENT '截止当前日期留存天数'
	) COMMENT '每日用户留存情况'
	PARTITIONED BY (`dt` string)
	stored as parquet
	location '/warehouse/gmall/dws/dws_user_retention_day/';

	-----------------------------SQL------------------------
	-- 求1日留存
	-- 先过滤，再关联比较好
	SELECT 
		t1.mid_id,
		t1.user_id, 
		t1.version_code,
		t1.version_name, 
		t1.lang, 
		t1.source,
		t1.os,
		t1.area,
		t1.model,
		t1.brand,
		t1.sdk_version, 
		t1.gmail, 
		t1.height_width,
		t1.app_time, 
		t1.network, 
		t1.lng, 
		t1.lat,
		t2.create_date, 
		1 retention_day, 
		'2020-02-15'
	FROM 
	(SELECT * from  gmall.dws_uv_detail_day where dt='2020-02-15') t1
	JOIN 
	(select mid_id,create_date from  gmall.dws_new_mid_day where create_date=date_sub('2020-02-15',1)) t2
	on t1.mid_id=t2.mid_id
	// 2.15留存一天的，今天的活跃用户是昨天新增的

	----------------------求1,2,3,n天的留存明细----------------------------
	insert overwrite TABLE dws_user_retention_day PARTITION(dt='2020-02-15')
	SELECT 
		t1.mid_id,
		t1.user_id, 
		t1.version_code,
		t1.version_name, 
		t1.lang, 
		t1.source,
		t1.os,
		t1.area,
		t1.model,
		t1.brand,
		t1.sdk_version, 
		t1.gmail, 
		t1.height_width,
		t1.app_time, 
		t1.network, 
		t1.lng, 
		t1.lat,
		t2.create_date, 
		1 retention_day
	FROM 
	(SELECT * from  gmall.dws_uv_detail_day where dt='2020-02-15') t1
	JOIN 
	(select mid_id,create_date from  gmall.dws_new_mid_day where create_date=date_sub('2020-02-15',1)) t2
	on t1.mid_id=t2.mid_id
	
	UNION all
	
	SELECT 
		t1.mid_id,
		t1.user_id, 
		t1.version_code,
		t1.version_name, 
		t1.lang, 
		t1.source,
		t1.os,
		t1.area,
		t1.model,
		t1.brand,
		t1.sdk_version, 
		t1.gmail, 
		t1.height_width,
		t1.app_time, 
		t1.network, 
		t1.lng, 
		t1.lat,
		t2.create_date, 
		2 retention_day
	FROM 
	(SELECT * from  gmall.dws_uv_detail_day where dt='2020-02-15') t1
	JOIN 
	(select mid_id,create_date from  gmall.dws_new_mid_day where create_date=date_sub('2020-02-15',2)) t2
	on t1.mid_id=t2.mid_id
	
	UNION all
	
	SELECT 
		t1.mid_id,
		t1.user_id, 
		t1.version_code,
		t1.version_name, 
		t1.lang, 
		t1.source,
		t1.os,
		t1.area,
		t1.model,
		t1.brand,
		t1.sdk_version, 
		t1.gmail, 
		t1.height_width,
		t1.app_time, 
		t1.network, 
		t1.lng, 
		t1.lat,
		t2.create_date, 
		3 retention_day
	FROM 
	(SELECT * from  gmall.dws_uv_detail_day where dt='2020-02-15') t1
	JOIN 
	(select mid_id,create_date from  gmall.dws_new_mid_day where create_date=date_sub('2020-02-15',3)) t2
	on t1.mid_id=t2.mid_id

	--union all在使用时要求拼接的SQL，字段数量和类型需要一致！
	--union all和union区别，union去重，union all不去重！



	----------------------------统计ads_user_retention_day_count每日留存用户的数量---------------
	-----------------------------相关表---------------------
	dws_user_retention_day
	-----------------------------思路-----------------------
	create_date： 	  从dws_user_retention_day查询
	retention_day：   从dws_user_retention_day查询
	retention_count： 使用count(*)统计

	先根据create_date过滤指定的新增日期日期用户的设备明细！
	再根据retention_day分组，之后count(*)
	选择create_date: 创建日期留存1天的有多少，留存2两天的有多少
	
	-----------------------------建表语句-------------------------
	create external table ads_user_retention_day_count(
	   `create_date`     string  comment  '设备新增日期',
	   `retention_day`   int     comment  '截止当前日期留存天数',
	   `retention_count` bigint  comment  '留存数量'
	) COMMENT '每日用户留存情况'
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_user_retention_day_count/';

	-----------------------------SQL------------------------
	insert into table gmall.ads_user_retention_day_count
	SELECT 
		'2020-02-14', 
		retention_day, 
		count(*)
	FROM gmall.dws_user_retention_day
	where create_date='2020-02-14' group by retention_day;
	// dws_user_retention_day这个表统计的是截止到当前每天留存情况！


	-----------------------------留存率---------------------
	-----------------------------相关表---------------------
	ads_user_retention_day_count
	ads_new_mid_count

	从以上两表取出同一条新增的设备的信息，因此设备的新增日期是关联的字段
	-----------------------------思路-----------------------
	`stat_date`        ： 一般是当前要统计数据的当天或后一天。不早于统计数据的日期！   
	`create_date`      ： 从ads_user_retention_day_count取
	`retention_day`    ： 从ads_user_retention_day_count取
	`retention_count`  ： 从ads_user_retention_day_count取
	`new_mid_count`    ： 从ads_new_mid_count统计当前新增设备的数量
	`retention_ratio`  ： retention_count/new_mid_count

	-----------------------------建表语句------------------------
	create external table ads_user_retention_day_rate(
     `stat_date`         string 		comment 	'统计日期',
     `create_date`       string 		comment 	'设备新增日期',
     `retention_day`     int     		comment 	'截止当前日期留存天数',
     `retention_count`   bigint 		comment 	'留存数量',
     `new_mid_count`     bigint			comment 	'当日设备新增数量',
     `retention_ratio`   decimal(10,2) 	comment 	'留存率'
	) COMMENT '每日用户留存情况'
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_user_retention_day_rate/';

	-----------------------------SQL------------------------
	insert into table ads_user_retention_day_rate
	SELECT 
		'2020-02-16',
		ur.create_date,
		ur.retention_day, 
		ur.retention_count, 
		nm.new_mid_count, 
		cast(ur.retention_count / nm.new_mid_count as decimal(10,2))
	FROM 
		ads_user_retention_day_count ur 
	JOIN
		ads_new_mid_count nm
	on ur.create_date=nm.create_date	
	where date_add(ur.create_date,ur.retention_day)='2020-02-16'
	
	# 每天插入数据的时候，假如统计的是2020-02-16的数据，只希望插入当前统计的留存率，
	# 所以在join后，指定create_date，关联后，如果不过滤，可能会插入重复的历史数据。











	=============================需求4 沉默主题=========================
	-----------------------------需求-----------------------
	沉默用户：只在安装当天启动过，且启动时间是在一周前

	只在安装当天启动过： 沉默用户只会产生的一天的启动日志
	启动时间是在一周前： 沉默用户产生启动日志的时间，必须距离当前的统计时间已经，间隔了7天

	-----------------------------相关表---------------------
	日活表dws_uv_detail_day（提前针对mid_id进行了合并）
	一个mid_id在日活表中一天最多有1条记录

	-----------------------------思路-----------------------
	从日活表中取出统计日期之前的所有数据，按照mid_id(用户设备号)分组，
	统计日活表所有的记录数=1的mid_id
	再判断，记录数=1的mid_id，当天产生的dt是否已经距离当前间隔了7天

	-----------------------------建表语句------------------------
	create external table ads_silent_count( 
		`dt` 			string COMMENT '统计日期',
		`silent_count` 	bigint COMMENT '沉默设备数'
	) 
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_silent_count';

	-----------------------------SQL------------------------
	insert into table ads_silent_count
	select '2020-02-16',count(*)
	from
		(select mid_id from dws_uv_detail_day where dt<='2020-02-16' GROUP by mid_id
		HAVING COUNT(mid_id)=1 and min(dt)<date_sub('2020-02-16',7)) tmp # 7天前小于

	# 一个用户7天前活动了，7天以内再次活动，count还是等于1，所以下面的写法错误！
	select '2020-02-16',count(*)
	FROM 
		(select mid_id from dws_uv_detail_day where dt<date_sub('2020-02-16',7) group by mid_id 
		having count(mid_id)=1) tmp



		
		
		
		

	=============================需求5 本周回流用户数=========================
	本周回流用户：上周没有使用应用，上周之前使用了应用，本周使用了应用
	本周回流用户=本周日活-本周新增用户-上周日活用户

	-----------------------------相关表---------------------
	dws_uv_detail_wk: 周活表
	dws_new_mid_day： 每日新增用户表

	-----------------------------思路-----------------------
	三个结果集做差：a left join b on a.x=b.x where b.x is null
	with 
		临时表名 as (),
		临时表名 as (),
		临时表名 as ()
		select 语句
		
	-----------------------------建表语句------------------------	
		create external table ads_back_count( 
		`dt` 			string COMMENT '统计日期',
		`wk_dt` 		string COMMENT '统计日期所在周',
		`wastage_count` bigint COMMENT '回流设备数'
	) 
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_back_count';

	-----------------------------SQL------------------------
	with t1 as 
	(SELECT mid_id FROM dws_uv_detail_wk
	where wk_dt=concat(date_sub(next_day('2020-02-14','mo'),7),'-',date_sub(next_day('2020-02-14','mo'),1))),

	t2 as
	(SELECT mid_id from dws_new_mid_day
	where create_date BETWEEN date_sub(next_day('2020-02-14','mo'),7) and  '2020-02-14'),

	t3 as
	(SELECT mid_id FROM dws_uv_detail_wk
	where wk_dt=concat(date_sub(next_day('2020-02-14','mo'),14),'-',date_sub(next_day('2020-02-14','mo'),8)))

	insert into table ads_back_count
	
	select 
		'2020-02-14',
		concat(date_sub(next_day('2020-02-14','mo'),7),'-',date_sub(next_day('2020-02-14','mo'),1)),
		count(*)
	from
	t1 left join t2 on t1.mid_id=t2.mid_id 
	left join t3 on t1.mid_id=t3.mid_id
	where t2.mid_id is null and t3.mid_id is null




	

	=============================需求6 流失用户数=========================
	流失用户： 最近7天未登录我们称之为流失用户
	如果一个用户，登录了，产生日活信息！
	如果一个用户在日活表中，最后一次登录的日期，距离当前已经间隔了7天，这个用户属于流失用户！

	-----------------------------相关表---------------------
	日活表dws_uv_detail_daily

	-----------------------------思路-----------------------
	统计日活表中，所有用户，最后一次登录的日期！
	判断日期是否距离当前小于7天

	-----------------------------建表语句------------------------
	create external table ads_wastage_count(
		`dt` 			string COMMENT '统计日期',
		`wastage_count` bigint COMMENT '流失设备数'
	)
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_wastage_count';

	-----------------------------SQL------------------------
	insert into table ads_wastage_count
	select '2020-02-18',COUNT(*)
	from 
		(select mid_id from dws_uv_detail_day
		where dt<='2020-02-18' group by mid_id having max(dt) < date_sub('2020-02-18',7)) tmp

	# 所有日活用户中，去掉最近七天的日活用户
	select '2020-02-20',COUNT(*) 
	from dws_uv_detail_day t1 
	left join 
		(select mid_id from dws_uv_detail_day  where dt 
		BETWEEN date_sub('2020-02-20',7) and '2020-02-20') t2 
	ON t1.mid_id = t2.mid_id where t2.mid_id is null  group by t1.mid_id






	=============================需求7 最近连续三周活跃用户数===============
	连续三周活跃用户： 在当前日期之前三周的周活表中，此用户都存在！
	周活表特点按照mid_id进行了去重！
	因此如果用户，在连续三周的周活中出现，那么就会有3条对应的记录！

	-----------------------------相关表---------------------
	周活表：dws_dv_detail_wk

	-----------------------------思路-----------------------
	求当前日期，之前三周的数据。根据mid分组，分组后统计组内记录数量=3，即是连续三周登录的用户
	
	-----------------------------建表语句------------------------
	create external table ads_continuity_wk_count( 
		`dt` 				string COMMENT '统计日期,一般用结束周周日日期,如果每天计算一次,可用当天日期',
		`wk_dt` 			string COMMENT '持续时间',
		`continuity_count` 	bigint
	) 
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_continuity_wk_count';

	-----------------------------SQL------------------------
	insert into table ads_continuity_wk_count
	select 
		'2020-02-18',
		concat(date_sub(next_day('2020-02-18','mo'),21),'-',date_sub(next_day('2020-02-18','mo'),1)),
		count(*)
	from    
	(select mid_id from dws_uv_detail_wk
		where monday_date BETWEEN date_sub(next_day('2020-02-18','mo'),21) and '2020-02-18'
		group by mid_id having count(*)=3) tmp




	=============================需求8 最近七天内连续三天活跃用户数===============	
	-----------------------------相关表---------------------
	日活表： dws_uv_detail_day
	-----------------------------思路-----------------------
	连续：
			假如A列，以X递增，以a开头
			假如B列，以Y递增，以b开头
			
			A   		 B				连续两列差值
			a			 b				b-a
			a+X			 b+y			b-a + (Y-x)
			a+2X		 b+2y			b-a + 2(y-X)
			
			假如A，B列都是连续的，有规律递增，那么每两列之间的差值，也是以Y-X递增。
			假如X=Y，此时每两列之间的差值，以0递增，差值一样！
			假如A，B列都是连续的，有规律递增，增幅一样，那么他们之间的差值一样！
			
	思路：①	取当前日志之前7天的数据
		  ②	按照用户mid_id分组，按照日期进行升序排序
		  ③	使用ROW_NUMBER函数，创建一个连续递增的列
		  ④	将日期列和rw列，做差
		  ⑤	将用户和差值进行分组，组内至少有3条记录，将复合条件的mid_id进行过滤即可
		  
	-----------------------------建表语句------------------------	  
	create external table ads_continuity_uv_count( 
		`dt` 				string COMMENT '统计日期',
		`wk_dt` 			string COMMENT '最近7天日期',
		`continuity_count` 	bigint
	) COMMENT '连续活跃设备数'
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_continuity_uv_count';

	-----------------------------SQL------------------------
	insert into TABLE ads_continuity_uv_count
	select 
		'2020-02-18', #统计数据的日期
		concat(date_sub('2020-02-18',7),'-','2020-02-18'), # 最近7天，当前日期减去7天
		count(DISTINCT mid_id)
	from
		(select mid_id
		from
			(SELECT 
				mid_id,dt,ROW_NUMBER() over(PARTITION by mid_id order by dt) rn,
				date_sub(dt,ROW_NUMBER() over(PARTITION by mid_id order by dt)) diff
			from dws_uv_detail_day where dt BETWEEN date_sub('2020-02-18',7) and '2020-02-18') tmp
		GROUP by mid_id,diff having count(*)>=3) tmp2


		// 1.取前七天的数据,得到rn,diff
		select mid_id,dt,row_number() over(partition by mid_id order by dt) rn,
			date_sub(dt,row_number() over(partition by mid_id order by dt)) diff
		from dws_uv_detail_day where dt between date_sub('2020-02-18',7) and '2020-02-18'  // t1
		
		// 2.按照mid_id,diff分组
		select mid_id from t1 group by mid_id,diff having count(*) >= 3  // t2
		
		// 3.选择结果
		select count(distinct mid_id) from t2
		
	
	
	
	
	
	=============================需求9 每个用户累计访问次数===============	
	向dws_user_total_count_day 插入数据
	-----------------------------相关表---------------------
	dwd_start_log(启动日志表)
	
	-----------------------------思路-----------------------
	用户每打开一次应用，就会产生一条启动日志。
	从启动日志表查询，根据用户(mid_id)分组，求每个用户产生的
	启动日志的总的数量(count)

	-----------------------------建表语句------------------------
	create external table dws_user_total_count_day( 
	`mid_id` 	string COMMENT '设备id',
	`subtotal` 	bigint COMMENT '每日登录小计'
	)
	partitioned by(`dt` string)
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/dws/dws_user_total_count_day';

	-----------------------------SQL------------------------
	insert overwrite table dws_user_total_count_day PARTITION(dt='2020-02-18')
	SELECT mid_id,count(*) subtotal	FROM dwd_start_log
	where dt='2020-02-18' GROUP by mid_id;
	
	
	
	-----------------------------需求9 ads层统计用户的累计访问次数-----------------------
	-----------------------------相关表---------------------
	dws_user_total_count_day
	
	-----------------------------思路-----------------------
	从dws_user_total_count_day中取出每个用户每天登录的次数，
	再取出每个用户之前每天登录的次数的总和
	
	-----------------------------建表语句------------------------
	create external table ads_user_total_count( 
		`mid_id` 	string COMMENT '设备id',
		`subtotal` 	bigint COMMENT '每日登录小计',
		`total` 	bigint COMMENT '登录次数总计'
	)
	partitioned by(`dt` string)
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_user_total_count';

	-----------------------------SQL------------------------
	insert overwrite table ads_user_total_count PARTITION(dt='2020-02-18')
	SELECT
		t1.mid_id,
		t1.subtotal,
		t2.total
	from 
	(select mid_id,subtotal from dws_user_total_count_day where dt='2020-02-18') t1
	JOIN
	(select mid_id,sum(subtotal) total FROM dws_user_total_count_day where dt<='2020-02-18'
		GROUP by mid_id) t2
	on t1.mid_id=t2.mid_id


	
	
	
	

	-----------------------------需求10 DWS层建立用户日志行为宽表-----------------------
	统计每个用户对每个商品的点击次数, 点赞次数, 收藏次数
	
	-----------------------------相关表---------------------
	dwd_display_log（商品点击表）：	mid_id(用户)，goodsid（商品id）
	dwd_favorites_log（收藏表）：	mid_id(用户)，course_id(商品id)
	dwd_praise_log(点赞表)： 		mid_id(用户)，target_id（商品id）

	-----------------------------思路-----------------------
	将用户对每个商品的点击次数，点赞次数，收藏次数等信息汇总到一张宽表中！

	从以上三个表中，先以用户和商品为单位，进行聚合！
	从以上三个表中取数据，根据mid_id和商品进行关联！将三个表的信息汇总合并！
		合并：常用join，使用join进行连接操作！
			  在hive中尽量少用join!
	
	-----------------------------建表语句------------------------			
	CREATE EXTERNAL TABLE dws_user_action_wide_log(
		`mid_id` 			string COMMENT '设备id',
		`goodsid` 			string COMMENT '商品id',
		`display_count` 	string COMMENT '点击次数',
		`praise_count` 		string COMMENT '点赞次数',
		`favorite_count` 	string COMMENT '收藏次数')
	PARTITIONED BY (`dt` string)
	stored as parquet
	location '/warehouse/gmall/dws/dws_user_action_wide_log/'
	TBLPROPERTIES('parquet.compression'='lzo');

	-----------------------------SQL------------------------
	insert overwrite TABLE dws_user_action_wide_log PARTITION(dt='2020-02-17')
	select 
		mid_id, 
		goodsid,
		sum(display_count),
		sum(praise_count), 
		sum(favorite_count)
	from
	(select 
		mid_id,goodsid,count(*) display_count,0 praise_count, 0 favorite_count 
	from dwd_display_log where dt='2020-02-17' group by mid_id,goodsid
	union all

	SELECT
		mid_id,target_id goodsid,0 display_count ,count(*) praise_count,0 favorite_count 
	from dwd_praise_log where dt='2020-02-17' group by mid_id,target_id
	union all

	select 
		mid_id,course_id goodsid, 0 display_count,0 praise_count, count(*) favorite_count
	from dwd_favorites_log where dt='2020-02-17' group by mid_id,course_id) tmp
	GROUP by mid_id,goodsid
	# 注意不要对分结果别名，会报错！

	

	-----------------------------需求10 ads_new_favorites_mid_day统计每天的新收藏用户数---------
	-----------------------------相关表---------------------
	dws_user_action_wide_log： 用户行为宽表
		统计的是每个用户对每个商品的点赞，点击和收藏的次数
	
	-----------------------------思路-----------------------
	从dws_user_action_wide_log，取出收藏的次数>0的记录,按用户分组，求此用户是否是新用户
	新用户：在所有使用了收藏功能的日期中，取日期最早(小)的，如果这个日期等于今天，
			那么说明当前用户是第一天使用收藏，就是新用户！
	
	-----------------------------建表语句------------------------
	create external table ads_new_favorites_mid_day( 
		`dt` 				string COMMENT '日期',
		`favorites_users` 	bigint COMMENT '新收藏用户数'
	) 
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_new_favorites_mid_day';

	-----------------------------SQL1------------------------
	insert into table ads_new_favorites_mid_day
	select '2020-02-17',count(*)
	from
	(select mid_id from dws_user_action_wide_log
	where favorite_count>0 group by mid_id having MIN(dt)='2020-02-17') tmp

	-----------------------------SQL2------------------------
	取出今天使用了收藏功能的用户，去除昨天以及之前使用了此功能的用户，注意去重！子查询添加别名
	select '2020-02-19',count(*) from (
		select DISTINCT mid_id from dws_user_action_wide_log 
		where dt='2020-02-19' and favorite_count >0
		and mid_id  not in 
	(select DISTINCT mid_id id from dws_user_action_wide_log t1 where dt<'2020-02-19' and favorite_count>0)   
	) t2



	
	
	

	-----------------------------需求11 各个商品点击次数top3的用户-----------------------
	点击次数存在歧义：
		是今天的点击次数？      从dws_user_action_wide_log使用今天日期过滤！
		是累计的总点击次数？    取dws_user_action_wide_log今天之前所有数据！
	
	求出每个商品的累计点击次数前三名的用户！
	
	-----------------------------相关表---------------------
	dws_user_action_wide_log
	
	-----------------------------思路-----------------------
	① 过滤出点击次数>0的用户，取这些用户今天之前的所有数据！
	② 按照商品id和用户id进行分组，统计每个用户对每件商品的累计点击次数！
	③ 针对每个商品的每个用户的累计点击次数，以商品为单位分区，
		按照用户的点击次数降序排序，求出排名前三的用户！

	-----------------------------建表语句------------------------
	create external table ads_goods_count( 
		`dt` 					string COMMENT '统计日期',
		`goodsid` 				string COMMENT '商品',
		`user_id` 				string COMMENT '用户',
		`goodsid_user_count` 	bigint COMMENT '商品用户点击次数'
	) 
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_goods_count';

	-----------------------------SQL------------------------
	insert into table ads_goods_count
	select 
	   '2020-02-17', goodsid,mid_id,totalCount
	from 
	(select  goodsid,mid_id,totalCount,
	RANK() over(PARTITION by goodsid order by totalCount desc )rn
	from 
	(SELECT
	   goodsid,mid_id,sum(display_count) totalCount
	from dws_user_action_wide_log
	where dt<='2020-02-17' and display_count>0
	GROUP by goodsid,mid_id) t1) t2
	where rn<=3

	第一步：点击次数大于零，截止当前每次商品，各个用户的累计点击次数
	select goodsid,mid_id,sum(display_count) totalCount from dws_user_action_wide_log t1
		where display_count > 0 and dt<='2020-02-17' group by goodsid ,mid_id 	// t2

	第二步：按照商品分区，点击次数降序排列
	select goodsid,mid_id,totalCount,
		rank() over(partition by goodsid order by totalCount desc) rn from t2  		// t3

	第三步：取出前三
	select '2020-02-17', goodsid,mid_id,totalCount from t3 where rn<=3








	-----------------------------需求12 统计每日各类别下点击次数top10的商品-----------------------
	-----------------------------相关表---------------------
	dws_user_action_wide_log: 在建宽表时应该充分考虑到所做的某一列需求可能涉及到的全部字段！
	dwd_display_log： category，mid_id,goodsid,没有聚合！

	-----------------------------思路-----------------------
	从dwd_display_log表取今天的点击数据，按照category和goodsid进行分组，求出每个商品点击的次数；
	以类别进行分区，以点击次数降序排序，求每个商品的排名；
	取排名前十的商品；
	
	-----------------------------建表语句------------------------------------------------
	create external table ads_goods_display_top10 ( 
		`dt` 			string COMMENT '日期',
		`category` 		string COMMENT '品类',
		`goodsid` 		string COMMENT '商品id',
		`goods_count` 	string COMMENT '商品点击次数'
	) 
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_goods_display_top10';

	-----------------------------SQL------------------------
	insert into table ads_goods_display_top10
	select 
		'2020-02-17',category,goodsid,goods_count
	from 
	(select category,goodsid,goods_count,
		RANK() over(PARTITION by category order by goods_count desc) rn
	from
	(select category,goodsid,count(*) goods_count from dwd_display_log
		where dt='2020-02-17' group by category,goodsid) t1) t2
	where rn <=10





	
	


	-----------------------------需求13 总点击次数最多的10个用户点击的各个的商品次数------------------
	`dt` 		string COMMENT '统计日期',
	`mid_id` 	string COMMENT '用户id',
	`u_ct` 		string COMMENT '用户总点击次数'  所有商品的总点击次数（个人认为）？ 对某个商品的总点击次数？
	`goodsid` 	string COMMENT '商品id',
	`d_ct` 		string COMMENT '用户对此商品总点击次数'

	-----------------------------相关表---------------------
	dws_user_action_wide_log
	
	-----------------------------思路-----------------------
	求总点击次数最多的10个用户
	再求出此10个用户各自点击的商品次数
	
	-----------------------------建表语句------------------------------------------------
	create external table ads_goods_user_count( 
	`dt` 			string COMMENT '统计日期',
	`mid_id` 		string COMMENT '用户id',
	`u_ct` 			string COMMENT '用户总点击次数',
	`goodsid` 		string COMMENT '商品id',
	`d_ct` 			string COMMENT '各个商品点击次数'
	) 
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_goods_user_count';

	-----------------------------SQL------------------------
	insert into TABLE ads_goods_user_count
	select 
		'2020-02-17',t1.mid_id,u_ct,goodsid,d_ct
	from 
	(select mid_id,sum(display_count) u_ct
		from dws_user_action_wide_log
		where dt<='2020-02-17' GROUP by mid_id order by u_ct desc limit 10) t1
	join 
		(select mid_id,goodsid,sum(display_count) d_ct
		from dws_user_action_wide_log where dt<='2020-02-17' group by mid_id,goodsid) t2
	on t1.mid_id=t2.mid_id where d_ct>0


	// 求总点击次数最多的10个用户
	select mid_id,sum(display_count) u_ct from dws_user_action_wide_log
		where dt<='2020-02-17' group by mid_id order by u_ct desc limit 10  // t1	
	
	// 再求出此10个用户各自点击的商品次数
	select mid_id,goodsid,sum(display_count) d_ct
		from dws_user_action_wide_log where dt<='2020-02-17' group by mid_id,goodsid  // t2
	
	// 结果	
	select '2020-02-17',t1.mid_id,u_ct,goodsid,d_ct 
		from t1 join t2 on t1.mid_id = t2.mid_id where d_ct>0






	-----------------------------需求14 月活跃率-------------
	月活跃用户与截止到该月累计的用户总和之间的比例
	-----------------------------相关表---------------------
	ads_uv_count： 		取月活跃用户
	ads_new_mid_count： 取截至到该月所有的用户数

	-----------------------------建表语句---------------------
	create external table ads_mn_ratio_count( 
	   `dt` 		string COMMENT '统计日期',
	   `mn` 		string COMMENT '统计月活跃率的月份',
	   `ratio` 		string COMMENT '活跃率'
	) 
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_mn_ratio_count';

	-----------------------------SQL------------------------
	# 统计2020-02-17日的月活跃率
	insert into table ads_mn_ratio_count
	select
		'2020-02-17',
		date_format('2020-02-17','yyyy-MM'),
		cast(mn_count/totalCount * 100 as decimal(10,2)) 
	from
	(SELECT mn_count from ads_uv_count where dt='2020-02-17' ) t1
	join
	(SELECT sum(new_mid_count) totalCount from ads_new_mid_count
		where create_date <= '2020-02-17') t2 

			
	
	
	
	
	
	
	
	
	
	
	
	
	
	
