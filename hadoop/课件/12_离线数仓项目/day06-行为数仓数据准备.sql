表名
	1 ODS层
	ods_start_log				启动日志表
	ods_event_log				事件日志表

	2 DWD层
	dwd_start_log				启动表
	dwd_base_event_log			事件表

	dwd_display_log				商品点击表
	dwd_newsdetail_log			商品详情页表
	dwd_loading_log				商品列表页表
	dwd_ad_log					广告表
	dwd_notification_log		消息通知表
	dwd_active_foreground_log	用户前台活跃表
	dwd_active_background_log	用户后台活跃表
	dwd_comment_log				评论表
	dwd_favorites_log			收藏表
	dwd_praise_log				点赞表
	dwd_error_log				错误日志表

	3 DWS层
	dws_uv_detail_day			每日活跃设备明细表
	dws_uv_detail_wk			每周活跃设备明细表
	dws_uv_detail_mn			每月活跃设备明细表

	dws_new_mid_day				每日新增设备明细表
	dws_user_retention_day		每日留存用户明细表
	dws_user_total_count_day	用户累计访问次数表
	dws_user_action_wide_log	用户日志行为宽表

	4 ADS层
	ads_uv_count				活跃设备数表
	ads_new_mid_count			每日新增设备表
	ads_user_retention_day_count留存用户数表
	ads_user_retention_day_rate	留存用户比率表
	
	ads_silent_count			沉默用户表
	ads_back_count				本周回流用户表
	ads_wastage_count			流失用户表
	ads_continuity_wk_count		连续三周活跃用户表
	ads_continuity_uv_count		最近七天内连续三天活跃用户表
	ads_user_total_count		用户累计访问次数表
	ads_new_favorites_mid_day	新收藏用户数表
	
	ads_goods_count				各个商品点击次数表
	ads_goods_display_top10		每日各类别下点击次数top10的商品表
	ads_goods_user_count		点击次数最多的10个用户点击的商品次数表
	ads_mn_ratio_count			月活跃率表
	
	
	

代码
日志生成脚本：向指定目录生产数据：lg 5 1000	
	#!/bin/bash
	#在hadoop102,hadoop103产生日志
	for i in hadoop102 hadoop103
	do
		ssh $i java -cp 
		/opt/module/log-collector-0.0.1-SNAPSHOT-jar-with-dependencies.jar 
		com.atguigu.appclient.AppMain $1 $2 > /dev/null 2>&1 &


flume日志采集脚本：f1 start|stop
	#!/bin/bash
	#使用start启动脚本，使用stop停止脚本
	if(($#!=1))
	then
		echo 请输入start或stop!
		exit;
	fi

	#定义cmd用来保存要执行的命令
	cmd=cmd
	if [ $1 = start ]
	then
		cmd="nohup flume-ng agent -c $FLUME_HOME/conf/ -n a1 
		-f $FLUME_HOME/myagents/f1.conf 
		-Dflume.root.logger=DEBUG,console > /home/atguigu/f1.log 2>&1 &"

	elif [ $1 = stop ]
	then 
		cmd="ps -ef  | grep f1.conf | grep -v grep | awk  '{print \$2}' | xargs kill -9"

	else
		echo 请输入start或stop!
	fi

	#在hadoop102和hadoop103开启采集
	for i in hadoop102 hadoop103
	do
		ssh $i $cmd
	done
 
	
采集通道脚本：f2 start|stop
	#!/bin/bash
	#使用start启动脚本，使用stop停止脚本
	if(($#!=1))
	then
		echo 请输入start或stop!
		exit;
	fi

	if [ $1 = start ]
	then
		ssh hadoop104 "nohup flume-ng agent -c $FLUME_HOME/conf/ -n a1 
		-f $FLUME_HOME/myagents/f2.conf 
		-Dflume.root.logger=INFO,console > /home/atguigu/f2.log 2>&1 &"

	elif [ $1 = stop ]
	then 
		ssh hadoop104 "ps -ef  | grep f2.conf | grep -v grep | awk  '{print \$2}' | xargs kill -9"

	else
		echo 请输入start或stop!
	fi


创建启动日志表：ods_start_log
	drop table if exists ods_start_log;
	CREATE EXTERNAL TABLE ods_start_log(`line` string)
	PARTITIONED BY (`dt` string)
	STORED AS
		INPUTFORMAT 'com.hadoop.mapred.DeprecatedLzoTextInputFormat'
		OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
	LOCATION '/warehouse/gmall/ods/ods_start_log';
 
创建事件日志表：ods_event_log 
	drop table if exists ods_event_log;
	CREATE EXTERNAL TABLE ods_event_log(`line` string)
	PARTITIONED BY (`dt` string)
	STORED AS
		INPUTFORMAT 'com.hadoop.mapred.DeprecatedLzoTextInputFormat'
		OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
	LOCATION '/warehouse/gmall/ods/ods_event_log';
 
 
ODS层加载数据脚本：ods_log.sh '2020-02-14'
	#!/bin/bash
	#向ods的两个表中导入每天的数据，为数据创建LZO索引
	#接受要导入数据的日期参数,-n可以判断后面的参数是否为赋值，如果赋值，返回true,否则返回false
	#为判断的变量名加双引号
	if [ -n "$1" ]
	then
		do_date=$1
	else
		do_date=$(date -d yesterday +%F)
	fi

	echo ===日志日期为$do_date===

	APP=gmall
	sql="load data inpath '/origin_data/gmall/log/topic_start/$do_date' 
			into table $APP.ods_start_log partition(dt='$do_date');
		 load data inpath '/origin_data/gmall/log/topic_event/$do_date' 
			into table $APP.ods_event_log partition(dt='$do_date');"
	
	hive  -e "$sql"

	hadoop jar /opt/module/hadoop-2.7.2/share/hadoop/common/hadoop-lzo-0.4.20.jar 
		com.hadoop.compression.lzo.DistributedLzoIndexer 
		/warehouse/gmall/ods/ods_start_log/dt=$do_date

	hadoop jar /opt/module/hadoop-2.7.2/share/hadoop/common/hadoop-lzo-0.4.20.jar 
		com.hadoop.compression.lzo.DistributedLzoIndexer 
		/warehouse/gmall/ods/ods_event_log/dt=$do_date

		
		

DWD层创建启动表
	drop table if exists dwd_start_log;
	CREATE EXTERNAL TABLE dwd_start_log(
	`mid_id` string,
	`user_id` string, 
	`version_code` string, 
	`version_name` string, 
	`lang` string, 
	`source` string, 
	`os` string, 
	`area` string, 
	`model` string,
	`brand` string, 
	`sdk_version` string, 
	`gmail` string, 
	`height_width` string,  
	`app_time` string,
	`network` string, 
	`lng` string, 
	`lat` string, 
	`entry` string, 
	`open_ad_type` string, 
	`action` string, 
	`loading_time` string, 
	`detail` string, 
	`extend1` string
	)
	PARTITIONED BY (dt string)
	stored as parquet
	location '/warehouse/gmall/dwd/dwd_start_log/'
	TBLPROPERTIES('parquet.compression'='lzo');
	
	
DWD层启动表加载数据脚本：dwd_start_log.sh '2020-02-14'	
	#!/bin/bash
	if [ -n "$1" ]
	then
		do_date=$1
	else
		do_date=$(date -d yesterday +%F)
	fi

	echo ===日志日期为$do_date===

	sql="insert overwrite table gmall.dwd_start_log	PARTITION (dt='$do_date')
	select 
		get_json_object(line,'$.mid') mid_id,
		get_json_object(line,'$.uid') user_id,
		get_json_object(line,'$.vc') version_code,
		get_json_object(line,'$.vn') version_name,
		get_json_object(line,'$.l') lang,
		get_json_object(line,'$.sr') source,
		get_json_object(line,'$.os') os,
		get_json_object(line,'$.ar') area,
		get_json_object(line,'$.md') model,
		get_json_object(line,'$.ba') brand,
		get_json_object(line,'$.sv') sdk_version,
		get_json_object(line,'$.g') gmail,
		get_json_object(line,'$.hw') height_width,
		get_json_object(line,'$.t') app_time,
		get_json_object(line,'$.nw') network,
		get_json_object(line,'$.ln') lng,
		get_json_object(line,'$.la') lat,
		get_json_object(line,'$.entry') entry,
		get_json_object(line,'$.open_ad_type') open_ad_type,
		get_json_object(line,'$.action') action,
		get_json_object(line,'$.loading_time') loading_time,
		get_json_object(line,'$.detail') detail,
		get_json_object(line,'$.extend1') extend1
	from gmall.ods_start_log 
	where dt='$do_date';"	
	hive  -e "$sql"

	

DWD层创建事件表
	drop table if exists dwd_base_event_log;
	CREATE EXTERNAL TABLE dwd_base_event_log(
	`mid_id` string,
	`user_id` string, 
	`version_code` string, 
	`version_name` string, 
	`lang` string, 
	`source` string, 
	`os` string, 
	`area` string, 
	`model` string,
	`brand` string, 
	`sdk_version` string, 
	`gmail` string, 
	`height_width` string, 
	`app_time` string, 
	`network` string, 
	`lng` string, 
	`lat` string, 
	`event_name` string, 
	`event_json` string, 
	`server_time` string
	)
	PARTITIONED BY (`dt` string)
	stored as parquet
	location '/warehouse/gmall/dwd/dwd_base_event_log/'
	TBLPROPERTIES('parquet.compression'='lzo');

	-----------------------------事件日志数据的导入-----------------------
	将事件数据先根据事件名和事件json展开
	-----------------------------相关表---------------------
	从ods_event_log将数据展开，导入到dwd_base_event_log
	-----------------------------思路-----------------------
	使用udf函数base_analizer取出原始数据中的cm中的属性，时间戳和et对应的JSON数组字符串
	使用udtf函数flat_analizer取出每一个事件名和事件JSON
	-----------------------------SQL------------------------
	insert overwrite TABLE gmall.dwd_base_event_log PARTITION(dt='2020-02-15')
	SELECT 
	base_analizer(line,'mid') mid_id, 
	base_analizer(line,'uid') user_id, 
	base_analizer(line,'vc') version_code, 
	base_analizer(line,'vn') version_name, 
	base_analizer(line,'l') lang, 
	base_analizer(line,'sr') source, 
	base_analizer(line,'os') os, 
	base_analizer(line,'ar') area, 
	base_analizer(line,'md') model, 
	base_analizer(line,'ba') brand, 
	base_analizer(line,'sv') sdk_version, 
	base_analizer(line,'g') gmail, 
	base_analizer(line,'hw') height_width, 
	base_analizer(line,'t') app_time, 
	base_analizer(line,'nw') network, 
	base_analizer(line,'ln') lng,
	base_analizer(line,'la') lat,
	en event_name,
	ej event_json,
	base_analizer(line,'ts') server_time
	FROM gmall.ods_event_log
		LATERAL VIEW flat_analizer(base_analizer(line,'et')) tmp as en,ej
	WHERE dt='2020-02-15' 
	
DWD层事件表加载数据脚本：dwd_base_log.sh '2020-02-14' 
	#!/bin/bash
	# 定义变量方便修改
	APP=gmall
	hive=/opt/module/hive/bin/hive

	# 如果是输入的日期按照取输入日期；如果没输入日期取当前时间的前一天
	if [ -n "$1" ] ;then
		do_date=$1
	else 
		do_date=`date -d "-1 day" +%F`  
	fi 

	sql="use gmall;
	insert overwrite table "$APP".dwd_base_event_log partition(dt='$do_date')
	select
		base_analizer(line,'mid') as mid_id,
		base_analizer(line,'uid') as user_id,
		base_analizer(line,'vc') as version_code,
		base_analizer(line,'vn') as version_name,
		base_analizer(line,'l') as lang,
		base_analizer(line,'sr') as source,
		base_analizer(line,'os') as os,
		base_analizer(line,'ar') as area,
		base_analizer(line,'md') as model,
		base_analizer(line,'ba') as brand,
		base_analizer(line,'sv') as sdk_version,
		base_analizer(line,'g') as gmail,
		base_analizer(line,'hw') as height_width,
		base_analizer(line,'t') as app_time,
		base_analizer(line,'nw') as network,
		base_analizer(line,'ln') as lng,
		base_analizer(line,'la') as lat,
		event_name,
		event_json,
		base_analizer(line,'ts') as server_time
	from "$APP".ods_event_log 
		lateral view flat_analizer(base_analizer(line,'et')) tem_flat as event_name,event_json
	where dt='$do_date'  and base_analizer(line,'et')<>'';"

	$hive -e "$sql"
 
 
 
DWD层创建事件表： 
	#1商品点击表
	drop table if exists dwd_display_log;
	CREATE EXTERNAL TABLE dwd_display_log(
	`mid_id` string,
	`user_id` string,
	`version_code` string,
	`version_name` string,
	`lang` string,
	`source` string,
	`os` string,
	`area` string,
	`model` string,
	`brand` string,
	`sdk_version` string,
	`gmail` string,
	`height_width` string,
	`app_time` string,
	`network` string,
	`lng` string,
	`lat` string,
	`action` string,
	`goodsid` string,
	`place` string,
	`extend1` string,
	`category` string,
	`server_time` string
	)
	PARTITIONED BY (dt string)
	stored as parquet
	location '/warehouse/gmall/dwd/dwd_display_log/'
	TBLPROPERTIES('parquet.compression'='lzo');


	#2商品详情页表
	drop table if exists dwd_newsdetail_log;
	CREATE EXTERNAL TABLE dwd_newsdetail_log(
	`mid_id` string,
	`user_id` string, 
	`version_code` string, 
	`version_name` string, 
	`lang` string, 
	`source` string, 
	`os` string, 
	`area` string, 
	`model` string,
	`brand` string, 
	`sdk_version` string, 
	`gmail` string, 
	`height_width` string, 
	`app_time` string,  
	`network` string, 
	`lng` string, 
	`lat` string, 
	`entry` string,
	`action` string,
	`goodsid` string,
	`showtype` string,
	`news_staytime` string,
	`loading_time` string,
	`type1` string,
	`category` string,
	`server_time` string)
	PARTITIONED BY (dt string)
	stored as parquet
	location '/warehouse/gmall/dwd/dwd_newsdetail_log/'
	TBLPROPERTIES('parquet.compression'='lzo');


	#3商品列表页表
	drop table if exists dwd_loading_log;
	CREATE EXTERNAL TABLE dwd_loading_log(
	`mid_id` string,
	`user_id` string, 
	`version_code` string, 
	`version_name` string, 
	`lang` string, 
	`source` string, 
	`os` string, 
	`area` string, 
	`model` string,
	`brand` string, 
	`sdk_version` string, 
	`gmail` string,
	`height_width` string,  
	`app_time` string,
	`network` string, 
	`lng` string, 
	`lat` string, 
	`action` string,
	`loading_time` string,
	`loading_way` string,
	`extend1` string,
	`extend2` string,
	`type` string,
	`type1` string,
	`server_time` string)
	PARTITIONED BY (dt string)
	stored as parquet
	location '/warehouse/gmall/dwd/dwd_loading_log/'
	TBLPROPERTIES('parquet.compression'='lzo');


	#4广告表
	drop table if exists dwd_ad_log;
	CREATE EXTERNAL TABLE dwd_ad_log(
	`mid_id` string,
	`user_id` string, 
	`version_code` string, 
	`version_name` string, 
	`lang` string, 
	`source` string, 
	`os` string, 
	`area` string, 
	`model` string,
	`brand` string, 
	`sdk_version` string, 
	`gmail` string, 
	`height_width` string,  
	`app_time` string,
	`network` string, 
	`lng` string, 
	`lat` string, 
	`entry` string,
	`action` string,
	`content` string,
	`detail` string,
	`ad_source` string,
	`behavior` string,
	`newstype` string,
	`show_style` string,
	`server_time` string)
	PARTITIONED BY (dt string)
	stored as parquet
	location '/warehouse/gmall/dwd/dwd_ad_log/'
	TBLPROPERTIES('parquet.compression'='lzo');


	#5消息通知表
	drop table if exists dwd_notification_log;
	CREATE EXTERNAL TABLE dwd_notification_log(
	`mid_id` string,
	`user_id` string, 
	`version_code` string, 
	`version_name` string, 
	`lang` string,
	`source` string, 
	`os` string, 
	`area` string, 
	`model` string,
	`brand` string, 
	`sdk_version` string, 
	`gmail` string, 
	`height_width` string,  
	`app_time` string,
	`network` string, 
	`lng` string, 
	`lat` string, 
	`action` string,
	`noti_type` string,
	`ap_time` string,
	`content` string,
	`server_time` string
	)
	PARTITIONED BY (dt string)
	stored as parquet
	location '/warehouse/gmall/dwd/dwd_notification_log/'
	TBLPROPERTIES('parquet.compression'='lzo');


	#6用户前台活跃表
	drop table if exists dwd_active_foreground_log;
	CREATE EXTERNAL TABLE dwd_active_foreground_log(
	`mid_id` string,
	`user_id` string,
	`version_code` string,
	`version_name` string,
	`lang` string,
	`source` string,
	`os` string,
	`area` string,
	`model` string,
	`brand` string,
	`sdk_version` string,
	`gmail` string,
	`height_width` string,
	`app_time` string,
	`network` string,
	`lng` string,
	`lat` string,
	`push_id` string,
	`access` string,
	`server_time` string)
	PARTITIONED BY (dt string)
	stored as parquet
	location '/warehouse/gmall/dwd/dwd_foreground_log/'
	TBLPROPERTIES('parquet.compression'='lzo');


	#7用户后台活跃表
	drop table if exists dwd_active_background_log;
	CREATE EXTERNAL TABLE dwd_active_background_log(
	`mid_id` string,
	`user_id` string,
	`version_code` string,
	`version_name` string,
	`lang` string,
	`source` string,
	`os` string,
	`area` string,
	`model` string,
	`brand` string,
	`sdk_version` string,
	`gmail` string,
	 `height_width` string,
	`app_time` string,
	`network` string,
	`lng` string,
	`lat` string,
	`active_source` string,
	`server_time` string
	)
	PARTITIONED BY (dt string)
	stored as parquet
	location '/warehouse/gmall/dwd/dwd_background_log/'
	TBLPROPERTIES('parquet.compression'='lzo');


	#8评论表
	drop table if exists dwd_comment_log;
	CREATE EXTERNAL TABLE dwd_comment_log(
	`mid_id` string,
	`user_id` string,
	`version_code` string,
	`version_name` string,
	`lang` string,
	`source` string,
	`os` string,
	`area` string,
	`model` string,
	`brand` string,
	`sdk_version` string,
	`gmail` string,
	`height_width` string,
	`app_time` string,
	`network` string,
	`lng` string,
	`lat` string,
	`comment_id` int,
	`userid` int,
	`p_comment_id` int, 
	`content` string,
	`addtime` string,
	`other_id` int,
	`praise_count` int,
	`reply_count` int,
	`server_time` string
	)
	PARTITIONED BY (dt string)
	stored as parquet
	location '/warehouse/gmall/dwd/dwd_comment_log/'
	TBLPROPERTIES('parquet.compression'='lzo');


	#9收藏表
	drop table if exists dwd_favorites_log;
	CREATE EXTERNAL TABLE dwd_favorites_log(
	`mid_id` string,
	`user_id` string, 
	`version_code` string, 
	`version_name` string, 
	`lang` string, 
	`source` string, 
	`os` string, 
	`area` string, 
	`model` string,
	`brand` string, 
	`sdk_version` string, 
	`gmail` string, 
	`height_width` string,  
	`app_time` string,
	`network` string, 
	`lng` string, 
	`lat` string, 
	`id` int, 
	`course_id` int, 
	`userid` int,
	`add_time` string,
	`server_time` string
	)
	PARTITIONED BY (dt string)
	stored as parquet
	location '/warehouse/gmall/dwd/dwd_favorites_log/'
	TBLPROPERTIES('parquet.compression'='lzo');


	#10点赞表
	drop table if exists dwd_praise_log;
	CREATE EXTERNAL TABLE dwd_praise_log(
	`mid_id` string,
	`user_id` string, 
	`version_code` string, 
	`version_name` string, 
	`lang` string, 
	`source` string, 
	`os` string, 
	`area` string, 
	`model` string,
	`brand` string, 
	`sdk_version` string, 
	`gmail` string, 
	`height_width` string,  
	`app_time` string,
	`network` string, 
	`lng` string, 
	`lat` string, 
	`id` string, 
	`userid` string, 
	`target_id` string,
	`type` string,
	`add_time` string,
	`server_time` string
	)
	PARTITIONED BY (dt string)
	stored as parquet
	location '/warehouse/gmall/dwd/dwd_praise_log/'
	TBLPROPERTIES('parquet.compression'='lzo');


	#11错误日志表
	drop table if exists dwd_error_log;
	CREATE EXTERNAL TABLE dwd_error_log(
	`mid_id` string,
	`user_id` string, 
	`version_code` string, 
	`version_name` string, 
	`lang` string, 
	`source` string, 
	`os` string, 
	`area` string, 
	`model` string,
	`brand` string, 
	`sdk_version` string, 
	`gmail` string, 
	`height_width` string,  
	`app_time` string,
	`network` string, 
	`lng` string, 
	`lat` string, 
	`errorBrief` string, 
	`errorDetail` string, 
	`server_time` string)
	PARTITIONED BY (dt string)
	stored as parquet
	location '/warehouse/gmall/dwd/dwd_error_log/'
	TBLPROPERTIES('parquet.compression'='lzo');


DWD层事件表加载数据脚本：dwd_event_log.sh '2020-02-14'
	#!/bin/bash
	# 定义变量方便修改
	APP=gmall
	hive=/opt/module/hive/bin/hive

	# 如果是输入的日期按照取输入日期；如果没输入日期取当前时间的前一天
	if [ -n "$1" ] ;then
		do_date=$1
	else 
		do_date=`date -d "-1 day" +%F`  
	fi 

	sql="set hive.exec.dynamic.partition.mode=nonstrict;
	insert overwrite table "$APP".dwd_display_log
	PARTITION (dt='$do_date')
	select 
		mid_id,
		user_id,
		version_code,
		version_name,
		lang,
		source,
		os,
		area,
		model,
		brand,
		sdk_version,
		gmail,
		height_width,
		app_time,
		network,
		lng,
		lat,
		get_json_object(event_json,'$.kv.action') action,
		get_json_object(event_json,'$.kv.goodsid') goodsid,
		get_json_object(event_json,'$.kv.place') place,
		get_json_object(event_json,'$.kv.extend1') extend1,
		get_json_object(event_json,'$.kv.category') category,
		server_time
	from "$APP".dwd_base_event_log 
	where dt='$do_date' and event_name='display';

	insert overwrite table "$APP".dwd_newsdetail_log
	PARTITION (dt='$do_date')
	select 
		mid_id,
		user_id,
		version_code,
		version_name,
		lang,
		source,
		os,
		area,
		model,
		brand,
		sdk_version,
		gmail,
		height_width,
		app_time,
		network,
		lng,
		lat,
		get_json_object(event_json,'$.kv.entry') entry,
		get_json_object(event_json,'$.kv.action') action,
		get_json_object(event_json,'$.kv.goodsid') goodsid,
		get_json_object(event_json,'$.kv.showtype') showtype,
		get_json_object(event_json,'$.kv.news_staytime') news_staytime,
		get_json_object(event_json,'$.kv.loading_time') loading_time,
		get_json_object(event_json,'$.kv.type1') type1,
		get_json_object(event_json,'$.kv.category') category,
		server_time
	from "$APP".dwd_base_event_log 
	where dt='$do_date' and event_name='newsdetail';

	insert overwrite table "$APP".dwd_loading_log
	PARTITION (dt='$do_date')
	select 
		mid_id,
		user_id,
		version_code,
		version_name,
		lang,
		source,
		os,
		area,
		model,
		brand,
		sdk_version,
		gmail,
		height_width,
		app_time,
		network,
		lng,
		lat,
		get_json_object(event_json,'$.kv.action') action,
		get_json_object(event_json,'$.kv.loading_time') loading_time,
		get_json_object(event_json,'$.kv.loading_way') loading_way,
		get_json_object(event_json,'$.kv.extend1') extend1,
		get_json_object(event_json,'$.kv.extend2') extend2,
		get_json_object(event_json,'$.kv.type') type,
		get_json_object(event_json,'$.kv.type1') type1,
		server_time
	from "$APP".dwd_base_event_log 
	where dt='$do_date' and event_name='loading';

	insert overwrite table "$APP".dwd_ad_log
	PARTITION (dt='$do_date')
	select 
		mid_id,
		user_id,
		version_code,
		version_name,
		lang,
		source,
		os,
		area,
		model,
		brand,
		sdk_version,
		gmail,
		height_width,
		app_time,
		network,
		lng,
		lat,
		get_json_object(event_json,'$.kv.entry') entry,
		get_json_object(event_json,'$.kv.action') action,
		get_json_object(event_json,'$.kv.content') content,
		get_json_object(event_json,'$.kv.detail') detail,
		get_json_object(event_json,'$.kv.source') ad_source,
		get_json_object(event_json,'$.kv.behavior') behavior,
		get_json_object(event_json,'$.kv.newstype') newstype,
		get_json_object(event_json,'$.kv.show_style') show_style,
		server_time
	from "$APP".dwd_base_event_log 
	where dt='$do_date' and event_name='ad';

	insert overwrite table "$APP".dwd_notification_log
	PARTITION (dt='$do_date')
	select 
		mid_id,
		user_id,
		version_code,
		version_name,
		lang,
		source,
		os,
		area,
		model,
		brand,
		sdk_version,
		gmail,
		height_width,
		app_time,
		network,
		lng,
		lat,
		get_json_object(event_json,'$.kv.action') action,
		get_json_object(event_json,'$.kv.noti_type') noti_type,
		get_json_object(event_json,'$.kv.ap_time') ap_time,
		get_json_object(event_json,'$.kv.content') content,
		server_time
	from "$APP".dwd_base_event_log 
	where dt='$do_date' and event_name='notification';

	insert overwrite table "$APP".dwd_active_foreground_log
	PARTITION (dt='$do_date')
	select 
		mid_id,
		user_id,
		version_code,
		version_name,
		lang,
		source,
		os,
		area,
		model,
		brand,
		sdk_version,
		gmail,
		height_width,
		app_time,
		network,
		lng,
		lat,
	get_json_object(event_json,'$.kv.push_id') push_id,
	get_json_object(event_json,'$.kv.access') access,
		server_time
	from "$APP".dwd_base_event_log 
	where dt='$do_date' and event_name='active_foreground';

	insert overwrite table "$APP".dwd_active_background_log
	PARTITION (dt='$do_date')
	select 
		mid_id,
		user_id,
		version_code,
		version_name,
		lang,
		source,
		os,
		area,
		model,
		brand,
		sdk_version,
		gmail,
		height_width,
		app_time,
		network,
		lng,
		lat,
		get_json_object(event_json,'$.kv.active_source') active_source,
		server_time
	from "$APP".dwd_base_event_log 
	where dt='$do_date' and event_name='active_background';

	insert overwrite table "$APP".dwd_comment_log
	PARTITION (dt='$do_date')
	select 
		mid_id,
		user_id,
		version_code,
		version_name,
		lang,
		source,
		os,
		area,
		model,
		brand,
		sdk_version,
		gmail,
		height_width,
		app_time,
		network,
		lng,
		lat,
		get_json_object(event_json,'$.kv.comment_id') comment_id,
		get_json_object(event_json,'$.kv.userid') userid,
		get_json_object(event_json,'$.kv.p_comment_id') p_comment_id,
		get_json_object(event_json,'$.kv.content') content,
		get_json_object(event_json,'$.kv.addtime') addtime,
		get_json_object(event_json,'$.kv.other_id') other_id,
		get_json_object(event_json,'$.kv.praise_count') praise_count,
		get_json_object(event_json,'$.kv.reply_count') reply_count,
		server_time
	from "$APP".dwd_base_event_log 
	where dt='$do_date' and event_name='comment';

	insert overwrite table "$APP".dwd_favorites_log
	PARTITION (dt='$do_date')
	select 
		mid_id,
		user_id,
		version_code,
		version_name,
		lang,
		source,
		os,
		area,
		model,
		brand,
		sdk_version,
		gmail,
		height_width,
		app_time,
		network,
		lng,
		lat,
		get_json_object(event_json,'$.kv.id') id,
		get_json_object(event_json,'$.kv.course_id') course_id,
		get_json_object(event_json,'$.kv.userid') userid,
		get_json_object(event_json,'$.kv.add_time') add_time,
		server_time
	from "$APP".dwd_base_event_log 
	where dt='$do_date' and event_name='favorites';

	insert overwrite table "$APP".dwd_praise_log
	PARTITION (dt='$do_date')
	select 
		mid_id,
		user_id,
		version_code,
		version_name,
		lang,
		source,
		os,
		area,
		model,
		brand,
		sdk_version,
		gmail,
		height_width,
		app_time,
		network,
		lng,
		lat,
		get_json_object(event_json,'$.kv.id') id,
		get_json_object(event_json,'$.kv.userid') userid,
		get_json_object(event_json,'$.kv.target_id') target_id,
		get_json_object(event_json,'$.kv.type') type,
		get_json_object(event_json,'$.kv.add_time') add_time,
		server_time
	from "$APP".dwd_base_event_log 
	where dt='$do_date' and event_name='praise';

	insert overwrite table "$APP".dwd_error_log
	PARTITION (dt='$do_date')
	select 
		mid_id,
		user_id,
		version_code,
		version_name,
		lang,
		source,
		os,
		area,
		model,
		brand,
		sdk_version,
		gmail,
		height_width,
		app_time,
		network,
		lng,
		lat,
		get_json_object(event_json,'$.kv.errorBrief') errorBrief,
		get_json_object(event_json,'$.kv.errorDetail') errorDetail,
		server_time
	from "$APP".dwd_base_event_log 
	where dt='$do_date' and event_name='error';"

	$hive -e "$sql"



