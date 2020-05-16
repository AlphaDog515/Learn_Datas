业务数仓所有需求sql:

	-----------------------------需求	dwd层降维后的商品表-------
	-----------------------------相关表---------------------
	ods_ods_sku_info
	ods_base_category1
	ods_base_category2
	ods_base_category3
	-----------------------------思路-----------------------
	通过四个表先过滤要导入日期的数据，再关联，
	将和商品相关的1，2，3级分类信息汇总，插入到dwd_sku_info
	
	-----------------------------建表语句------------------------
	create external table dwd_sku_info(
		`id` 				string COMMENT 'skuId',
		`spu_id` 			string COMMENT 'spuid',
		`price` 			decimal(10,2) COMMENT '',
		`sku_name` 			string COMMENT '',
		`sku_desc` 			string COMMENT '',
		`weight` 			string COMMENT '',
		`tm_id` 			string COMMENT 'id',
		`category3_id` 		string COMMENT '1id',
		`category2_id` 		string COMMENT '2id',
		`category1_id` 		string COMMENT '3id',
		`category3_name` 	string COMMENT '3',
		`category2_name` 	string COMMENT '2',
		`category1_name` 	string COMMENT '1',
		`create_time` 		string COMMENT ''
	) 
	PARTITIONED BY (`dt` string)
	stored as parquet
	location '/warehouse/gmall/dwd/dwd_sku_info/'
	tblproperties ("parquet.compression"="snappy");

	-----------------------------SQL1------------------------
	insert overwrite table dwd_sku_info PARTITION(dt='2020-02-16')
	SELECT 
		t1.id, t1.spu_id, t1.price,
		t1.sku_name, 
		t1.sku_desc, 
		t1.weight, 
		t1.tm_id, 
		t1.category3_id,
		t3.id category2_id, 
		t4.id category1_id,
		t2.name category3_name,
		t3.name category2_name,
		t4.name category1_name,
		t1.create_time
	FROM 
		(select * from ods_sku_info where dt='2020-02-16') t1 
	join 
		(select * from ods_base_category3 where dt='2020-02-16') t2 on t1.category3_id=t2.id 
	join 
		(select * from ods_base_category2 where dt='2020-02-16') t3 on t2.category2_id=t3.id
	join
		(select * from ods_base_category1 where dt='2020-02-16' )t4 on t3.category1_id=t4.id

	-----------------------------SQL2------------------------
	SELECT 
		t1.id, 
		t1.spu_id, 
		t1.price, 
		t1.sku_name, 
		t1.sku_desc, 
		t1.weight, 
		t1.tm_id, 
		t1.category3_id, 
		t2.category2_id, 
		t3.category1_id, 
		t2.name, 
		t3.name, 
		t4.name, 
		t1.create_time
	FROM 
		ods_sku_info t1 
	join 
		ods_base_category3 t2 on t1.category3_id = t2.id 
	join 
		ods_base_category2 t3 on t2.category2_id = t3.id
	join 
		ods_base_category1 t4 on t3.category1_id = t4.id 
	where t1.dt='2020-02-06' and t2.dt='2020-02-06' and t3.dt='2020-02-06' and t4.dt='2020-02-06'	
	# 过滤日期需要写四个，注意参考列所在的表的字段名！	
		
		
		
		
	-----------------------------需求	dws_user_action------------
	创建用户在电商业务中的行为宽表，统计每个用户每天的
	下单总数，支付总数，下单总金额，支付总金额和评论次数
	
	-----------------------------相关表---------------------
	dwd_order_info：  取user_id(用户)，total_amount(当前订单金额)
	dwd_payment_info：取user_id(用户)，total_amount(当前支付金额)
	dwd_comment_log： 取user_id(用户)，统计评论次数
	
	-----------------------------思路-----------------------
	最后拼接结果集时，不能使用join!
		因为三个结果集中，可能存在差异（只存在在t3，不在t2,t1中）
	使用full join!

	不使用join，使用union all

	如果基于用户在收货成功后才能评论的业务逻辑，可以使用Join!

	union all 要注意拼接结果集的字段个数，类型，顺序必须一致！
	
	-----------------------------建表语句------------------------
	create external table dws_user_action(   
		user_id         string      	comment '用户id',
		order_count     bigint      	comment '下单次数 ',
		order_amount    decimal(16,2)  	comment '下单金额 ',
		payment_count   bigint      	comment '支付次数',
		payment_amount  decimal(16,2)	comment '支付金额 ',
		comment_count   bigint      	comment '评论次数'
	) COMMENT '每日用户行为宽表'
	PARTITIONED BY (`dt` string)
	stored as parquet
	location '/warehouse/gmall/dws/dws_user_action/';

	-----------------------------SQL------------------------
	insert overwrite TABLE dws_user_action PARTITION(dt='2020-02-16')
	select
		user_id,sum(order_count),sum(order_amount),
		sum(payment_count),sum(payment_amount),
		sum(comment_count)
	from
	
	(select 
		user_id,count(*) order_count,sum(total_amount) order_amount,
		0 payment_count,0 payment_amount,0 comment_count
	from dwd_order_info where dt='2020-02-16' GROUP by user_id
	
	union all	
	select 
		user_id,0 order_count,0 order_amount,
		count(*) payment_count,sum(total_amount) payment_amount,
		0 comment_count
	from dwd_payment_info where dt='2020-02-16' GROUP by user_id
	
	union all	
	select 
		user_id,0 order_count,0 order_amount,
		0 payment_count,0 payment_amount,
		count(*) comment_count
	from dwd_comment_log where dt='2020-02-16' GROUP by user_id) tmp
	GROUP by user_id

	
	
	
	
	
	-----------------------------需求	ads_gmv_sum_day-----------------------
	统计每天的成交总额
	-----------------------------相关表---------------------
	dws_user_action
	-----------------------------建表语句-----------------------
	create external table ads_gmv_sum_day(
		`dt`           string 			COMMENT '统计日期',
		`gmv_count`    bigint			COMMENT '当日gmv订单个数',
		`gmv_amount`   decimal(16,2) 	COMMENT '当日gmv订单总金额',
		`gmv_payment`  decimal(16,2) 	COMMENT '当日支付金额'
	) COMMENT 'GMV'
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_gmv_sum_day/';

	-----------------------------SQL------------------------
	insert into table ads_gmv_sum_day
	select 
		'2020-02-16',
		sum(order_count) gmv_count,
		sum(order_amount) gmv_amount,
		sum(payment_amount) gmv_payment
	from dws_user_action where dt='2020-02-16'
	
	
	
	
	
	-----------------------------需求	转化率之用户新鲜度及漏斗分析 ads_user_convert_day-------
	转化率：单日实际做xxx事情的人数 / 当日日活 = xxx单日转化率
	用户新鲜度：  用户新鲜度也是转化率的一种
				  指当日新增用户 / 当日日活用户
				  
	用户： 设备
	-----------------------------相关表---------------------
	ads_uv_count： 		获取一天的日活
	ads_new_mid_count： 获取一天的新增人数
	
	-----------------------------建表语句--------------------
	drop table if exists ads_user_convert_day;
	create external table ads_user_convert_day( 
		`dt` string 					COMMENT '统计日期',
		`uv_m_count`  	bigint 			COMMENT '当日活跃设备',
		`new_m_count` 	bigint		 	COMMENT '当日新增设备',
		`new_m_ratio`   decimal(10,2) 	COMMENT '当日新增占日活的比率'
	) COMMENT '转化率'
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_user_convert_day/';

	-----------------------------SQL1------------------------
	insert into table ads_user_convert_day
	select 
		'2020-02-16',
		uv_m_count,
		new_m_count,
		cast(new_m_count/uv_m_count*100 as decimal(10,2)) 		// 转化为百分数*100 
	from
		(select day_count uv_m_count from ads_uv_count where dt='2020-02-16') t1
	join
		(SELECT	new_mid_count  new_m_count from ads_new_mid_count where create_date='2020-02-16') t2
	
	-----------------------------SQL2------------------------	
	SELECT 
		'2020-02-16' dt, 
		day_count uv_m_count,new_mid_count new_m_count, 
		cast(day_count/new_mid_count as decimal (10,2)) new_m_ratio   
		// 在cast里面不能使用别名uv_m_count等！
	from (select day_count from ads_uv_count where dt='2020-02-16') t1 
	join (select new_mid_count from ads_new_mid_count where create_date='2020-02-16') t2


	
	
	-----------------------------需求	ads_user_action_convert_day 转化率之漏斗分析----------
	总访问人数： uv  根据用户身份去重后的数据！
	总访问人次： pv
		同一个人可以多次访问！ 如果将访问的人次数据，根据用户去重后，得到人数！
		
	用户： user_id
	-----------------------------相关表---------------------
	dwd_start_log：   取当天的总访问人数
	dws_user_action： 取当天的下单人数和支付人数
	
	-----------------------------思路-----------------------
	total_visitor_m_count`  bigint 		COMMENT 	'总访问人数': 	从启动日志中找
	order_u_count` 			bigint    	COMMENT 	'下单人数'： 	从dws_user_action中找
	`payment_u_count` 		bigint     	COMMENT 	'支付人数'：	从dws_user_action中找
	
	-----------------------------建表语句-----------------------
	create external table ads_user_action_convert_day(
		`dt` 							string 				COMMENT '统计日期',
		`total_visitor_m_count`  		bigint 				COMMENT '总访问人数',
		`order_u_count` 				bigint     			COMMENT '下单人数',
		`visitor2order_convert_ratio`  	decimal(10,2) 		COMMENT '访问到下单转化率',
		`payment_u_count` 				bigint     			COMMENT '支付人数',
		`order2payment_convert_ratio` 	decimal(10,2) 		COMMENT '下单到支付的转化率'
	 ) COMMENT '用户行为漏斗分析'
	row format delimited  fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_user_action_convert_day/';

	-----------------------------SQL------------------------
	--下单人数
	select count(*) order_u_count from dws_user_action where dt='2020-02-16' and order_count>0
	// dws_user_action表是union all以后的表，所以需要过滤order_count>0
	
	--支付人数
	select count(*) payment_u_count	from dws_user_action where dt='2020-02-16' and payment_count>0

	--改写
	select 
		sum(if(order_count>0,1,0)) order_u_count,
		sum(if(payment_count>0,1,0)) payment_u_count
	from dws_user_action where dt='2020-02-16'
	
	-----------------------------SQL------------------------
	insert into table ads_user_action_convert_day
	select
		'2020-02-14',
		total_visitor_m_count,
		order_u_count,
		cast(order_u_count/total_visitor_m_count*100 as decimal(10,2)) visitor2order_convert_ratio,
		payment_u_count,
		cast(payment_u_count/order_u_count*100 as decimal(10,2)) order2payment_convert_ratio
	from 
	(select count(*) total_visitor_m_count from
		(select user_id	from dwd_start_log where dt='2020-02-16' group by user_id) t1) t3
	join
	(select 
		sum(if(order_count>0,1,0)) order_u_count,
		sum(if(payment_count>0,1,0)) payment_u_count
	from dws_user_action where dt='2020-02-16') t2

	注：select count(DISTINCT user_id ) total_visitor_m_count from dwd_start_log where dt='2020-02-16'
	与下面的结果一样！
		select count(*) total_visitor_m_count from
			(select user_id	from dwd_start_log where dt='2020-02-16' group by user_id) t1

	
	
	
	
	
	
	
	
	
	
	-----------------------------需求	用户购买商品明细表 dws_sale_detail_daycount ---------------
	复购率： 重复购买的概率！
	同一件商品 购买过的人数有 10 人
	购买同一件商品 二次的人数有 8 人
	购买同一件商品 三次的人数有 6人

	此商品，单次复购率：8/10
			多(至少购买3次)次复购率： 6/10
			
	用户购买商品明细表： 用户分别购买的商品明细是什么
	-----------------------------相关表---------------------
	dwd_user_info： 	取出用户的相关信息
	dwd_sku_info： 		取出和商品相关的信息
	ods_order_detail： 	订单详情表
	ods_payment_info： 	支付流水表
	-----------------------------思路-----------------------

	根据birthday求年龄： 1990-1-1
	求生日当天和今天间隔多少天：【虚岁】 ceil(datediff('2020-02-21','1990-1-1')/365)
	求生日当月和今天所在月间隔多少月： 	 ceil(months_between('2020-02-21','1990-1-1')/12)
	年份相减：select year(current_date()) -year('1994-05-16')

	sku_num int comment '购买个数'：
			只有支付了才算购买，下单不算购买！
			要从ods_order_detail和ods_payment_info的交集中取
			
	order_count string comment '当日下单单数'： 
			分歧： 此用户当日一共下的总单数？
				   此用户当日购买此商品下的单数？ 	（个人认为）
				
	order_amount string comment '当日下单金额'：
			分歧： 此用户当日一共下的总的总金额数？ 
				   此用户当日购买此商品花费总金额？ （个人认为）				

	userid  sku_id  order_count(总单数)
	1		1001	100【都是100意义不大】
	1		1002	100
	1		1001	100
	1		1002	100
	1		1003	100
	1		1004	100
	1		1005	100
	1		1006	100
	1		1007	100

	-----------------------------建表语句------------------------
	create external table dws_sale_detail_daycount(   
		user_id   				string  		comment '用户 id',
		sku_id    				string 			comment '商品 Id',
		user_gender 			string 			comment '用户性别',
		user_age 				string  		comment '用户年龄',
		user_level 				string 			comment '用户等级',
		order_price 			decimal(10,2) 	comment '商品价格',
		sku_name 				string   		comment '商品名称',
		sku_tm_id 				string   		comment '品牌id',
		sku_category3_id 		string 			comment '商品三级品类id',
		sku_category2_id 		string 			comment '商品二级品类id',
		sku_category1_id 		string 			comment '商品一级品类id',
		sku_category3_name 		string 			comment '商品三级品类名称',
		sku_category2_name 		string 			comment '商品二级品类名称',
		sku_category1_name 		string 			comment '商品一级品类名称',
		spu_id  				string 			comment '商品 spu',
		sku_num  				int 			comment '购买个数',
		order_count 			string 			comment '当日下单单数',
		order_amount 			string 			comment '当日下单金额'
	) COMMENT '用户购买商品明细表'
	PARTITIONED BY (`dt` string)
	stored as parquet
	location '/warehouse/gmall/dws/dws_user_sale_detail_daycount/'
	tblproperties ("parquet.compression"="snappy");

	-----------------------------SQL------------------------
	with t1 as (
	select
		id user_id,gender user_gender,
		ceil(months_between('2020-02-16',birthday) / 12) user_age,
		user_level
	from dwd_user_info where dt = '2020-02-16'),	 // 取出用户信息

	t2 as (
	select
		id sku_id,
		price order_price,
		sku_name,
		tm_id sku_tm_id,
		category3_id sku_category3_id,
		category2_id sku_category2_id,
		category1_id sku_category1_id,
		category3_name sku_category3_name,
		category2_name sku_category2_name,
		category1_name sku_category1_name,
		spu_id spu_id
	from dwd_sku_info where dt = '2020-02-16'),		 // 取出商品信息

	t3 as (
	select
		orderdatail.sku_num,
		orderdatail.sku_id,
		orderdatail.user_id
	from ods_order_detail orderdatail
	join ods_payment_info payment on orderdatail.order_id = payment.order_id
	where orderdatail.dt = '2020-02-16'	and payment.dt = '2020-02-16' ),
	// 此处使用订单id关联，即使有user_id也是重复字段！
	// 取支付成功的订单数量，使用内连接！
	
	t4 as (
	select
		orderdatail.sku_id,
		orderdatail.user_id,
		count(*) order_count,
		sum(orderdatail.order_price*orderdatail.sku_num) order_amount
	from ods_order_detail orderdatail
	join ods_payment_info payment on orderdatail.order_id = payment.order_id
	where orderdatail.dt = '2020-02-16' and payment.dt = '2020-02-16'
	group by orderdatail.user_id,orderdatail.sku_id)

	insert overwrite TABLE dws_sale_detail_daycount PARTITION(dt = '2020-02-16')
	select
		t1.user_id,
		t2.sku_id,
		t1.user_gender,
		t1.user_age,
		t1.user_level,
		t2.order_price,
		t2.sku_name,
		t2.sku_tm_id,
		t2.sku_category3_id,
		t2.sku_category2_id,
		t2.sku_category1_id,
		t2.sku_category3_name,
		t2.sku_category2_name,
		t2.sku_category1_name,
		t2.spu_id,
		t3.sku_num,
		t4.order_count,
		t4.order_amount
	from t4
	join t3 on t4.sku_id = t3.sku_id and t4.user_id = t3.user_id
	join t1 on t1.user_id = t3.user_id
	join t2 on t3.sku_id = t2.sku_id



	-----------------------------需求	ads_sale_tm_category1_stat_mn-------
	统计某一个品牌的月复购率
	-----------------------------相关表-----------------------------
	dws_sale_detail_daycount: 统计了用户每一天购买的每一件商品的明细，一个商品属于一单
		tm_id： 		品牌id	
		order_count：	此用户当日购买此商品下的单数
		order_amount： 	此用户当日购买此商品花费总金额
		
	-----------------------------思路-----------------------
	统计每个用户，这个月购买此品牌下的商品，购买了多少次（单）？

	选取dws_sale_detail_daycount一个月范围的数据
	统计这个月中，购买了这个品牌下的商品一次以上的有多少人
	统计这个月中，购买了这个品牌下的商品二次以上的有多少人
	统计这个月中，购买了这个品牌下的商品三次以上的有多少人

	选取dws_sale_detail_daycount一个月范围的数据，按照user_id和tm_id分组，
	累加购买了这个品牌的商品下了多少单(多少次)

	-----------------------------建表语句------------------------
	create external table ads_sale_tm_category1_stat_mn(   
		tm_id 					string 			comment '品牌id',
		category1_id 			string 			comment '1级品类id ',
		category1_name 			string 			comment '1级品类名称 ',
		buycount  				bigint 			comment '购买人数',
		buy_twice_last 			bigint  		comment '两次以上购买人数',
		buy_twice_last_ratio 	decimal(10,2)  	comment '单次复购率',
		buy_3times_last   		bigint 			comment '三次以上购买人数',
		buy_3times_last_ratio 	decimal(10,2)  	comment '多次复购率',
		stat_mn 				string 			comment '统计月份',
		stat_date 				string 			comment '统计日期' 
	) COMMENT '复购率统计'
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_sale_tm_category1_stat_mn/';
	
	-----------------------------SQL------------------------
	INSERT into TABLE ads_sale_tm_category1_stat_mn
	select
		sku_tm_id, sku_category1_id,sku_category1_name,
		sum(if(order_count_per_mn>=1,1,0)) buycount,
		sum(if(order_count_per_mn>=2,1,0)) buy_twice_last,
		
		cast(sum(if(order_count_per_mn>=2,1,0))/sum(if(order_count_per_mn>=1,1,0))*100 as decimal(10,2)) buy_twice_last_ratio,
		
		sum(if(order_count_per_mn>=3,1,0)) buy_3times_last,
		
		cast(sum(if(order_count_per_mn>=3,1,0)) / sum(if(order_count_per_mn>=1,1,0)) * 100 as decimal(10,2)) buy_3times_last_ratio,
		
		date_format('2020-02-16','yyyy-MM') stat_mn,
		
		'2020-02-16'
	from 
	(select 
		user_id,sku_tm_id,count(order_count) order_count_per_mn,sku_category1_id,sku_category1_name
	from  dws_sale_detail_daycount
		where date_format(dt,'yyyy-MM')=date_format('2020-02-16','yyyy-MM')
		group by sku_tm_id,user_id,sku_category1_id,sku_category1_name 
	) tmp
	group by sku_tm_id,sku_category1_id,sku_category1_name
	// 由于普通字段与聚合函数使用时需要加group by因此最外层有group by!
	// 由于一个品牌对应一个类别所以可以添加多个分组字段！
	
	
	
	-----------------------------需求	各用户等级对应的复购率前十的商品排行---------
	dws_sale_detail_daycount

	结果：  用户等级数*10
			统计的是商品
	
	-----------------------------思路-----------------------
	统计今天之前的所有的数据：
	① 每个用户每个商品的购买次数
		user_id  sku_id   等级    时间	
		1			10		A     2020-02-15
		2			10		B     2020-02-15	
		20			10		A     2020-02-15	
		
		1			10		A     2020-02-16
		1			11		A     2020-02-16
		1			12		A     2020-02-16
		2			10		B     2020-02-16
		3			11		B     2020-02-16
		4			12		B     2020-02-16
		20			10		A     2020-02-16
		
		---结果：
		user_id  sku_id   等级    次数
		1			10		A  		2	
		1			11		A  		1
		1			12		A  		1
		2			10		B  		2
		3			11		B  		1
		4			12		B  		1
		20			10		A  		2
		
	② 再按照用户等级和商品进行分组，统计每个等级下对商品的复购率
		user_id  sku_id   等级    次数
		1			10		A  		2	
		1			11		A  		1
		1			12		A  		1
		2			10		B  		2
		3			11		B  		1
		4			12		B  		1
		20			10		A  		2

		---结果：			
		用户等级	sku_id	 1次人数	2次人数		复购率
		A				10		2			2		100%
		A				11		1			0		0%
		A				12		1			0		0%
		B				10		1			1		0%
		B				11		1			0		0%
		B				12		1			0		0%
		
		
	-----------------------------建表语句------------------------
	create  table ads_ul_rep_ratio(   
		user_level 			string 			comment '用户等级' ,
		sku_id 				string 			comment '商品id',
		buy_count 			bigint  		comment '购买总人数',
		buy_twice_count 	bigint 			comment  '两次购买总数',
		buy_twice_rate 		decimal(10,2)  	comment  '二次复购率', 
		rank 				string 			comment  '排名' ,
		state_date 			string 			comment '统计日期'
	) COMMENT '复购率统计'
	row format delimited  fields terminated by '\t' 
	location '/warehouse/gmall/ads/ads_ul_rep_ratio/';
	
	-----------------------------SQL------------------------
	第一步：求出各等级下，每个商品每个人的购买次数；
		select  user_level,sku_id,user_id,
			count(*) total_buy_count_per_person
		from dws_sale_detail_daycount 
			where dt <= '2020-02-16' group by user_level,sku_id,user_id  	// tmp
	
	第二步：求出复购率；
		select user_level,sku_id,
			sum(if(total_buy_count_per_person >= 1, 1, 0)) buy_count,
			sum(if(total_buy_count_per_person >= 2, 1, 0)) buy_twice_count,
			cast(sum(if(total_buy_count_per_person >= 2, 1, 0)) / 
				sum(if(total_buy_count_per_person >= 1, 1, 0))* 100 as decimal(10,2)) buy_twice_rate
		from tmp group by user_level,sku_id			// tmp2
	
	第三步：求排名；
		select user_level,sku_id,buy_count,buy_twice_count,buy_twice_rate,
			rank() over(PARTITION by user_level	order by buy_twice_rate desc) rn
		from tmp2 where buy_twice_rate>0			// tmp3
	
	第四步：求前十；
		SELECT user_level,sku_id,buy_count,buy_twice_count,buy_twice_rate,rn,'2020-02-16'
			from tmp3 where rn <= 10
			
	-----------------------------SQL------------------------
	--count(*)  一个用户购买此商品的所有的次数	
	INSERT INTO TABLE ads_ul_rep_ratio
	SELECT
		user_level,
		sku_id,
		buy_count,
		buy_twice_count,
		buy_twice_rate,
		rn,
		'2020-02-16'
	from
		(
		select
			user_level,
			sku_id,
			buy_count,
			buy_twice_count,
			buy_twice_rate,
			rank() over(PARTITION by user_level
		order by buy_twice_rate desc) rn
		from
			(
			select
				user_level,
				sku_id,
				sum(if(total_buy_count_per_person >= 1, 1, 0)) buy_count,
				sum(if(total_buy_count_per_person >= 2, 1, 0)) buy_twice_count,
cast(sum(if(total_buy_count_per_person >= 2, 1, 0))/ sum(if(total_buy_count_per_person >= 1, 1, 0))* 100 as decimal(10,2)) buy_twice_rate
			from
				(
				select user_level,sku_id,user_id,
					count(*) total_buy_count_per_person
				from dws_sale_detail_daycount where dt <= '2020-02-16'
				group by user_level,sku_id,user_id     
				) tmp
			group by user_level,sku_id) tmp2
		where buy_twice_rate>0) tmp3
	where rn <= 10
	
	
	
	
	
	
	
	
	
	
	-----------------------------需求	新付费用户数 dws_pay_user_detail-----------------------
	新付费用户数：判断今天掏钱支付的用户中，哪些是新用户，统计其数量
				  取今天支付的所有用户-历史新付费用户(dws_pay_user_detail)
	类似统计每日新增用户
	
	-----------------------------相关表---------------------
	dws_pay_user_detail: 每天统计今天的新付费用户有哪些
						 截至到今天，表中已经有了今天之前所有付费的用户(付费的老用户)
	
	dws_sale_detail_daycount： 	取所有掏钱的用户
	dwd_user_info: 				用户信息表
	
	-----------------------------思路-----------------------
	从dws_sale_detail_daycount取今天所有用户的购买明细，和dws_pay_user_detail做差集，
	统计出哪些是新用户，去重后，和用户信息表拼接：

	-----------------------------建表语句------------------------
	create external table dws_pay_user_detail(   
		`user_id` 		string comment '付费用户id',
		`name` 			string comment '付费用户姓名',
		`birthday` 		string COMMENT '',
		`gender` 		string COMMENT '',
		`email` 		string COMMENT '',
		`user_level` 	string COMMENT ''
	) COMMENT '付费用户表'
	PARTITIONED BY (`dt` string)
	stored as parquet
	location '/warehouse/gmall/dws/dws_pay_user_detail/';

	-----------------------------SQL------------------------
	insert overwrite table dws_pay_user_detail PARTITION(dt='2020-02-16')	
	SELECT ui.id,ui.name,ui.birthday,ui.gender,ui.email,ui.user_level
	from(
		select distinct t1.user_id from(select user_id from dws_sale_detail_daycount where dt = '2020-02-16') t1
		left join dws_pay_user_detail pu on t1.user_id = pu.user_id where pu.user_id is null) t2
	join (select * from dwd_user_info where dt = '2020-02-16') ui on t2.user_id = ui.id
		
		
	
	
	
	
	-----------------------------需求	ads_pay_user_count------------
	-----------------------------相关表---------------------
	dws_pay_user_detail
	-----------------------------建表语句-----------------------
	create external table ads_pay_user_count(   
		dt 			string 	COMMENT '统计日期',
		pay_count   bigint  COMMENT '付费用户数'
	)COMMENT '付费用户表'
	stored as parquet
	location '/warehouse/gmall/dws/ads_pay_user_count/';

	-----------------------------SQL------------------------
	insert into table ads_pay_user_count
	select '2020-02-16',count(*) from dws_pay_user_detail where dt='2020-02-16'

	
	
	
	
	-----------------------------需求	付费用户率---------------------
	用户：user_id!=mid_id
		  假如现在每人都用自己的手机(设备)登录自己的帐号！user_id=mid_id
	付费用户率: 付费的用户数 / 所有用户数 
	
	-----------------------------相关表---------------------
	ads_pay_user_count： 截至到今天所有的付费用户数
	ads_new_mid_count（不用）: 每天新增的设备数
	dws_user_info:  用户表，统计当前的用户数
	
	-----------------------------建表语句-----------------------
	create external table ads_pay_user_ratio (   
		dt 					string 			comment '统计日期',
		pay_count   		bigint  		comment '总付费用户数',
		user_count 			bigint 			comment '总用户数',
		pay_count_ratio 	decimal(10,2) 	COMMENT '付费用户比率'
	) COMMENT '付费用户率表'
	stored as parquet
	location '/warehouse/gmall/dws/ads_pay_user_ratio';

	-----------------------------SQL------------------------
	insert INTO TABLE ads_pay_user_ratio 
	SELECT
		'2020-02-16',pay_count,user_count,
		cast(pay_count/user_count*100 as decimal(10,2))
	from 
		(select sum(pay_count) pay_count from ads_pay_user_count where dt<='2020-02-16') t1
	join
		(SELECT	count(*) user_count	from dwd_user_info	where dt='2020-02-16') t2

	
	
	
	
	-----------------------------需求	每个用户最近一次购买时间----------------------
	-----------------------------相关表---------------------
	dws_sale_detail_daycount:  每个用户每天的购买的商品明细
	dws_user_action（推荐）：  每个用户每天的下单，支付明细（去重）
	
	-----------------------------建表语句-----------------------
	create external table ads_user_last_pay(
		user_id   	string  comment '用户id',
		pay_date 	string 	comment '最近一次购买时间'
	) COMMENT '用户最近一次购买时间表'
	stored as parquet
	location '/warehouse/gmall/dws/ads_user_last_pay/';

	-----------------------------SQL------------------------
	insert overwrite TABLE ads_user_last_pay
	select user_id,	max(dt)
	from dws_user_action where payment_count>0 GROUP by user_id

	
	
	
	
	
	
	
	-----------------------------需求	商品每日下单排行Top10----------------------
	-----------------------------相关表---------------------
	dws_sale_detail_daycount:  每个用户每天的购买的商品明细
	
	-----------------------------思路-----------------------
	求今日的销售明细，按商品分组，统计数量，排序取前十
	
	-----------------------------建表语句------------------------
	create external table ads_goods_order_count_day(   
		dt 			string 	comment '统计日期',
		sku_id   	string  comment '商品id',
		order_count bigint 	comment '下单次数'
	) COMMENT '商品下单top10'
	stored as parquet
	location '/warehouse/gmall/dws/ads_goods_order_count_day/';

	-----------------------------SQL------------------------
	insert into TABLE ads_goods_order_count_day
	select '2020-02-16',sku_id,count(*) order_count
	from dws_sale_detail_daycount
	where dt='2020-02-16' group by sku_id order by order_count desc limit 10

	
	
	
	
	
	-----------------------------需求	统计每个月订单付款率------
	订单付款率：订单支付数 / 订单下单数 
	
	-----------------------------相关表---------------------
	dws_user_action（推荐）：每个用户每天的下单数和支付数
	
	-----------------------------思路-----------------------
	取一个月，所有用户的下单数累加，和所有用户的支付数累加
	
	-----------------------------建表语句-----------------------
	create external  table ads_order2pay_mn (
		`dt` 							string 			COMMENT '统计日期',
		`order_u_count` 				bigint     		COMMENT '下单人数',
		`payment_u_count` 				bigint     		COMMENT '支付人数',
		`order2payment_convert_ratio` 	decimal(10,2) 	COMMENT '下单到支付的转化率'
	 ) COMMENT ''
	row format delimited  fields terminated by '\t'
	location '/warehouse/gmall/ads/ ads_order2pay_mn /';

	-----------------------------SQL------------------------
	insert into TABLE ads_order2pay_mn
	SELECT
		'2020-02-16',
		sum(order_count) order_u_count, 
		sum(payment_count) payment_u_count,
	    cast(sum(payment_count)/ sum(order_count) * 100 as  decimal(10,2)) order2payment_convert_ratio
	from dws_user_action where date_format(dt,'yyyy-MM') = date_format('2020-02-16','yyyy-MM')
	
	
	
	
	
	
	
	
	
	
	