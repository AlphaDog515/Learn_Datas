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

with t1 as 
(SELECT 
    mid_id
FROM dws_uv_detail_wk
where wk_dt=concat(date_sub(next_day('$do_date','mo'),7),'-',date_sub(next_day('$do_date','mo'),1))),
t2 as
(SELECT
    mid_id
from dws_new_mid_day
where create_date BETWEEN date_sub(next_day('$do_date','mo'),7) and  '$do_date'),
t3 as
(SELECT 
    mid_id
FROM dws_uv_detail_wk
where wk_dt=concat(date_sub(next_day('$do_date','mo'),14),'-',date_sub(next_day('$do_date','mo'),8)))
insert into table ads_back_count
select 
    '$do_date',
    concat(date_sub(next_day('$do_date','mo'),7),'-',date_sub(next_day('$do_date','mo'),1)),
    count(*)
from
t1 left join t2 on t1.mid_id=t2.mid_id 
left join t3 on t1.mid_id=t3.mid_id
where t2.mid_id is null and t3.mid_id is null

"
hive  -e "$sql"


