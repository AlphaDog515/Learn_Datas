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
insert into table ads_silent_count
select 
    '$do_date',
    count(*)
from
(select  
    mid_id
from dws_uv_detail_day
where dt<='$do_date'
GROUP by mid_id
HAVING COUNT(mid_id)=1 and min(dt)<date_sub('$do_date',7)) tmp
"
hive  -e "$sql"


