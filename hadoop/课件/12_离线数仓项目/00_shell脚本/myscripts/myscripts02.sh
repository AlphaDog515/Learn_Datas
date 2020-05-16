#!/bin/bash
for((i=0;i<=14;i++))
do
	dws_retation_day.sh $(date +%F -d "-$i day")
	ads_silent_log.sh $(date +%F -d "-$i day")
	ads_back_log.sh $(date +%F -d "-$i day")
	ads_wastage_log.sh $(date +%F -d "-$i day")
	ads_continuity_wk_count.sh $(date +%F -d "-$i day")
	ads_continuity_log.sh $(date +%F -d "-$i day")
done
