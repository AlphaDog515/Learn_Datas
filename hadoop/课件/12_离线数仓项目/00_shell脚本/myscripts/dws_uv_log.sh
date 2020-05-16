#!/bin/bash
if [ -n "$1" ]
then
	 do_date=$1
else
	do_date=$(date -d yesterday +%F)
fi

echo ===日志日期为$do_date===


sql="
set hive.exec.dynamic.partition.mode=nonstrict;
use gmall;

insert overwrite table gmall.dws_uv_detail_day PARTITION(dt='$do_date')
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
where dt='$do_date'
group by mid_id;

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
date_sub(next_day('$do_date','mo'),7) monday_date,
date_sub(next_day('$do_date','mo'),1) sunday_date,
concat(date_sub(next_day('$do_date','mo'),7),'-',date_sub(next_day('$do_date','mo'),1))
FROM gmall.dws_uv_detail_day
where dt BETWEEN date_sub(next_day('$do_date','mo'),7)
and date_sub(next_day('$do_date','mo'),1) 
group by mid_id;

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
date_format('$do_date','yyyy-MM')
FROM gmall.dws_uv_detail_day
where date_format('$do_date','yyyy-MM')=date_format(dt,'yyyy-MM')
group by mid_id;

"
hive  -e "$sql"


