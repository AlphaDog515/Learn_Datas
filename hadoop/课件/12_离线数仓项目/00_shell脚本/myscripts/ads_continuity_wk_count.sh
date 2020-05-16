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
insert into table ads_continuity_wk_count
select 
    '$do_date',
    concat(date_sub(next_day('$do_date','mo'),21),'-',date_sub(next_day('$do_date','mo'),1)),
    count(*)
from    
(select 
    mid_id
from dws_uv_detail_wk
where monday_date BETWEEN date_sub(next_day('$do_date','mo'),21)
and '$do_date'
group by mid_id
having count(*)=3) tmp
"
hive  -e "$sql"


