#!/bin/bash
#向ods的两个表中导入每天的数据，为数据创建LZO索引
#接受要导入数据的日期参数,-n可以判断后面的参数是否为赋值，如果赋值，返回true,否则返回false
#为判断的变量名加双引号
if [ -n "$1" ]
then
	 do_date=$1
else
	do_date=$(date -d yesterday +%F)
fi

echo ===日志日期为$do_date===

APP=gmall
sql="
load data inpath '/origin_data/gmall/log/topic_start/$do_date' into table $APP.ods_start_log partition(dt='$do_date');

load data inpath '/origin_data/gmall/log/topic_event/$do_date' into table $APP.ods_event_log partition(dt='$do_date');
"
hive  -e "$sql"

hadoop jar /opt/module/hadoop-2.7.2/share/hadoop/common/hadoop-lzo-0.4.20.jar com.hadoop.compression.lzo.DistributedLzoIndexer /warehouse/gmall/ods/ods_start_log/dt=$do_date

hadoop jar /opt/module/hadoop-2.7.2/share/hadoop/common/hadoop-lzo-0.4.20.jar com.hadoop.compression.lzo.DistributedLzoIndexer /warehouse/gmall/ods/ods_event_log/dt=$do_date



