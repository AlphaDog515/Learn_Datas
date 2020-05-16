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
insert into table ads_wastage_count
select 
    '$do_date',
      COUNT(*)
from
(select 
    mid_id
from dws_uv_detail_day
where dt<='$do_date'
group by mid_id
having max(dt) < date_sub('$do_date',7)) tmp

"
hive  -e "$sql"


