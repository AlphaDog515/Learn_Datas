# 如果是输入的日期按照取输入日期；如果没输入日期取当前时间的前一天
if [ -n "$1" ] ;then
   do_date=$1
else 
   do_date=`date -d "-1 day" +%F`
fi

echo "===日志日期为 $do_date==="
sql="
insert into table "$APP".ads_new_favorites_mid_day
select
    '$do_date' dt,
    count(*) favorites_users
from
(
    select
        mid_id
    from
        "$APP".dws_user_action_wide_log
    where
        favorite_count>0
    group by
        mid_id
    having
        min(dt)='$do_date'
)user_favorite;
"

$hive -e "$sql"

