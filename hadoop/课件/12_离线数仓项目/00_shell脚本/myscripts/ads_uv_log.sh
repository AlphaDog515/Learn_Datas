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

INSERT into table gmall.ads_uv_count
SELECT 
'$do_date' dt, 
day_count, 
wk_count, 
mn_count, 
if( date_sub(next_day('$do_date','mo'),1)='$do_date','Y','N') is_weekend, 
if(last_day('$do_date')='$do_date','Y','N') is_monthend
FROM 
(select count(mid_id) day_count  from gmall.dws_uv_detail_day where dt='$do_date') t1
JOIN
(select count(mid_id) wk_count  from gmall.dws_uv_detail_wk WHERE wk_dt=concat(date_sub(next_day('$do_date','mo'),7),'-',date_sub(next_day('$do_date','mo'),1))) t2
join
(select count(mid_id) mn_count  from gmall.dws_uv_detail_mn 
WHERE mn=date_format('$do_date','yyyy-MM')) t3
"
hive  -e "$sql"


