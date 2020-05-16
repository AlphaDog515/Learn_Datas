#!/bin/bash
for((i=0;i<=14;i++))
do
	dws_user_total_count_day.sh $(date +%F -d "-$i day")
	ads_user_total_count.sh $(date +%F -d "-$i day")
	dws_user_action_wide_log.sh $(date +%F -d "-$i day")
	ads_new_favorites_mid_day.sh $(date +%F -d "-$i day")
	ads_goods_count.sh $(date +%F -d "-$i day")
	ads_goods_display_top10.sh $(date +%F -d "-$i day")
	ads_goods_user_count.sh $(date +%F -d "-$i day")
	ads_mn_ratio_count.sh $(date +%F -d "-$i day")
done
