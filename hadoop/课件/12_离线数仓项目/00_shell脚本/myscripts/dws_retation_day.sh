#!/bin/bash
if [ -n "$1" ]
then
	 do_date=$1
else
	do_date=$(date -d yesterday +%F)
fi

echo ===日志日期为$do_date===


sql="

use gmall;
insert overwrite TABLE dws_user_retention_day PARTITION(dt='$do_date')
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
(SELECT * from  gmall.dws_uv_detail_day where dt='$do_date') t1
JOIN 
(select mid_id,create_date from  gmall.dws_new_mid_day where create_date=date_sub('$do_date',1)) t2
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
(SELECT * from  gmall.dws_uv_detail_day where dt='$do_date') t1
JOIN 
(select mid_id,create_date from  gmall.dws_new_mid_day where create_date=date_sub('$do_date',2)) t2
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
(SELECT * from  gmall.dws_uv_detail_day where dt='$do_date') t1
JOIN 
(select mid_id,create_date from  gmall.dws_new_mid_day where create_date=date_sub('$do_date',3)) t2
on t1.mid_id=t2.mid_id
"
hive  -e "$sql"


