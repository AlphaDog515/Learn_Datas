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
insert into table ads_new_mid_count
SELECT 
    '$do_date',
    count(*)
FROM  
dws_new_mid_day
where create_date='$do_date'
"
hive  -e "$sql"


