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

insert into table gmall.dws_new_mid_day
SELECT 
    t1.*
FROM  
(select * from dws_uv_detail_day where dt='$do_date') t1
LEFT JOIN gmall.dws_new_mid_day nm
on t1.mid_id=nm.mid_id
WHERE nm.mid_id is null;
"
hive  -e "$sql"


