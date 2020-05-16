#!/bin/bash

for((i=8;i<=9;i++))
do
        ods_log.sh 2020-02-0$i
        dwd_start_log.sh 2020-02-0$i
        dwd_base_log.sh 2020-02-0$i
        dwd_event_log.sh 2020-02-0$i
        dws_uv_log.sh 2020-02-0$i
        ads_uv_log.sh 2020-02-0$i
        dws_new_log.sh 2020-02-0$i
        ads_new_log.sh 2020-02-0$i
        dws_retation_day.sh 2020-02-0$i
done

for((i=10;i<=18;i++))
do
	ods_log.sh 2020-02-$i
	dwd_start_log.sh 2020-02-$i
	dwd_base_log.sh 2020-02-$i
	dwd_event_log.sh 2020-02-$i
	dws_uv_log.sh 2020-02-$i
	ads_uv_log.sh 2020-02-$i
	dws_new_log.sh 2020-02-$i
	ads_new_log.sh 2020-02-$i
	dws_retation_day.sh 2020-02-$i
done


