#!/bin/bash
for((i=9;i<=12;i++))
do
	ods_log.sh $(date +%F -d "-$i day")
	dwd_start_log.sh $(date +%F -d "-$i day")
	dwd_base_log.sh $(date +%F -d "-$i day")
	dwd_event_log.sh $(date +%F -d "-$i day")
	dws_uv_log.sh $(date +%F -d "-$i day")
	ads_uv_log.sh $(date +%F -d "-$i day")
	dws_new_log.sh $(date +%F -d "-$i day")
	ads_new_log.sh $(date +%F -d "-$i day")
done
