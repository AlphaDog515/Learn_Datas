#!/bin/bash

# 定义变量方便修改
APP=gmall
hive=/opt/module/hive/bin/hive
hadoop=/opt/module/hadoop-2.7.2/bin/hadoop

# 如果是输入的日期按照取输入日期；如果没输入日期取当前时间的前一天
if [ -n "$1" ] ;then
   do_date=$1
else 
   do_date=`date -d "-1 day" +%F`
fi

echo "===日志日期为 $do_date==="
sql="
insert overwrite table "$APP".dws_user_total_count_day partition(dt='$do_date')
select
    mid_id,
    count(mid_id) cm
from
    "$APP".dwd_start_log
where
    dt='$do_date'
group by
    mid_id,dt;
"

$hive -e "$sql"

