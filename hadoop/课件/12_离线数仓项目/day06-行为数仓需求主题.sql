
��Ϊ��������ȫ��sql

	=============================����1 ÿ�ջ�Ծ�豸��ϸ=========================	
	��Ծ�û���
		�û���  ÿ���豸��Ϊһ���û���mid�����û�����ر�ʶ��
		��Ծ��  ����Ӧ�ã���Ϊ��Ծ�û���
				ֻҪ����Ӧ�ã���ʱ�����������־��Ϣ��
	ÿ�ջ�Ծ�豸��ϸ����ÿ��Ļ�Ծ�豸��ϸ����˱�Ӧ����һ���������ڷ����ķ�����
		��ϸ����Ҫ��cm�ֶε��������ݶ�д�뵽�˱��У�	
		
	-----------------------------��ر�---------------------
	��dwd_start_log������־����ȡ����
	
	-----------------------------˼·-----------------------
	��dwd_start_log�в�ѯ����ʱ����Ҫ����mid�Ž���ȥ�أ���ͬһ���豸�����Ķ�����ϸ��Ϣ
	ȥ�غ���ƴ�ӣ�һ���豸�ڱ�����һ�д���
	# �������������ʱ��ָ���˷���ֵ����ѯ��ʱ����Ҫ��ֵ�ˣ�

	-----------------------------�������-------------------------------------
	create external table dws_uv_detail_day(
		`mid_id` 		string COMMENT '�豸Ψһ��ʶ',
		`user_id` 		string COMMENT '�û���ʶ', 
		`version_code` 	string COMMENT '����汾��', 
		`version_name` 	string COMMENT '����汾��', 
		`lang` 			string COMMENT 'ϵͳ����', 
		`source` 		string COMMENT '������', 
		`os` 			string COMMENT '��׿ϵͳ�汾', 
		`area` 			string COMMENT '����', 
		`model` 		string COMMENT '�ֻ��ͺ�', 
		`brand` 		string COMMENT '�ֻ�Ʒ��', 
		`sdk_version` 	string COMMENT 'sdkVersion', 
		`gmail` 		string COMMENT 'gmail', 
		`height_width` 	string COMMENT '��Ļ���',
		`app_time` 		string COMMENT '�ͻ�����־����ʱ��ʱ��',
		`network` 		string COMMENT '����ģʽ',
		`lng` 			string COMMENT '����',
		`lat` 			string COMMENT 'γ��'
	)
	partitioned by(dt string)
	stored as parquet
	location '/warehouse/gmall/dws/dws_uv_detail_day';

	-----------------------------SQL------------------------
	insert overwrite table gmall.dws_uv_detail_day PARTITION(dt='2020-02-14')
	SELECT 
	mid_id, 
	concat_ws('|',collect_set(user_id)) user_id,
	concat_ws('|',collect_set(version_code)) version_code,
	concat_ws('|',collect_set(version_name)) version_name, 
	concat_ws('|',collect_set(lang)) lang, 
	concat_ws('|',collect_set(source)) source,
	concat_ws('|',collect_set(os)) os, 
	concat_ws('|',collect_set(area)) area, 
	concat_ws('|',collect_set(model)) model,
	concat_ws('|',collect_set(brand)) brand,
	concat_ws('|',collect_set(sdk_version)) sdk_version,
	concat_ws('|',collect_set(gmail)) gmail,
	concat_ws('|',collect_set(height_width)) height_width,
	concat_ws('|',collect_set(app_time)) app_time,
	concat_ws('|',collect_set(network)) network,
	concat_ws('|',collect_set(lng)) lng, 
	concat_ws('|',collect_set(lat)) lat
	FROM gmall.dwd_start_log
	where dt='2020-02-14'
	group by mid_id


	-----------------------------����1.ÿ�ܻ�Ծ�豸��ϸ-----------------------
	�ܻ�Ծ����һ���У�ֻҪ����һ��APP���������ܻ�Ծ�û�
	
	-----------------------------��ر�---------------------
	��dws_uv_detail_day����ȡ����

	-----------------------------˼·-----------------------
	ѡȡһ�ܵķ�Χ����Ϊ���˵�����
	��dws_uv_detail_day�в�ѯ����ʱ����Ҫ����mid�Ž���ȥ�أ���ͬһ���豸�����Ķ�����ϸ��Ϣ
	ȥ�غ���ƴ�ӣ�һ���豸�ڱ�����һ�д���

	�������ݵ�ǰ�������ڵ���һ������
	��һ�� date_sub(next_day('2020-02-14','mo'),7)
		   date_add(next_day('2020-02-14','mo'),-7)
		   
	���գ� date_sub(next_day('2020-02-14','mo'),1)
		����date_sub(next_day('2020-02-14','sunday'),7)
			
	wk_dt(������)�� 
		concat(date_sub(next_day('2020-02-14','mo'),7),'-',date_sub(next_day('2020-02-14','mo'),1))

	-----------------------------�������------------------------
	create external table dws_uv_detail_wk( 
		`mid_id` 		string COMMENT '�豸Ψһ��ʶ',
		`user_id` 		string COMMENT '�û���ʶ', 
		`version_code` 	string COMMENT '����汾��', 
		`version_name` 	string COMMENT '����汾��', 
		`lang` 			string COMMENT 'ϵͳ����', 
		`source` 		string COMMENT '������', 
		`os` 			string COMMENT '��׿ϵͳ�汾', 
		`area` 			string COMMENT '����', 
		`model` 		string COMMENT '�ֻ��ͺ�', 
		`brand` 		string COMMENT '�ֻ�Ʒ��', 
		`sdk_version` 	string COMMENT 'sdkVersion', 
		`gmail` 		string COMMENT 'gmail', 
		`height_width` 	string COMMENT '��Ļ���',
		`app_time` 		string COMMENT '�ͻ�����־����ʱ��ʱ��',
		`network` 		string COMMENT '����ģʽ',
		`lng` 			string COMMENT '����',
		`lat` 			string COMMENT 'γ��',
		`monday_date`	string COMMENT '��һ����',
		`sunday_date` 	string COMMENT  '��������' 
	) COMMENT '��Ծ�û�������ϸ'
	PARTITIONED BY (`wk_dt` string)
	stored as parquet
	location '/warehouse/gmall/dws/dws_uv_detail_wk/';

	-----------------------------SQL------------------------
	set hive.exec.dynamic.partition.mode=nonstrict;
	insert overwrite TABLE gmall.dws_uv_detail_wk PARTITION(wk_dt)
	SELECT 
	mid_id, 
	concat_ws('|',collect_set(user_id)) user_id,
	concat_ws('|',collect_set(version_code)) version_code,
	concat_ws('|',collect_set(version_name)) version_name, 
	concat_ws('|',collect_set(lang)) lang, 
	concat_ws('|',collect_set(source)) source,
	concat_ws('|',collect_set(os)) os, 
	concat_ws('|',collect_set(area)) area, 
	concat_ws('|',collect_set(model)) model,
	concat_ws('|',collect_set(brand)) brand,
	concat_ws('|',collect_set(sdk_version)) sdk_version,
	concat_ws('|',collect_set(gmail)) gmail,
	concat_ws('|',collect_set(height_width)) height_width,
	concat_ws('|',collect_set(app_time)) app_time,
	concat_ws('|',collect_set(network)) network,
	concat_ws('|',collect_set(lng)) lng, 
	concat_ws('|',collect_set(lat)) lat,
	date_sub(next_day('2020-02-14','mo'),7) monday_date,
	date_sub(next_day('2020-02-14','mo'),1) sunday_date,
	concat(date_sub(next_day('2020-02-14','mo'),7),'-',date_sub(next_day('2020-02-14','mo'),1))
	FROM gmall.dws_uv_detail_day
	where dt BETWEEN date_sub(next_day('2020-02-14','mo'),7) and date_sub(next_day('2020-02-14','mo'),1) 
	group by mid_id;


	-----------------------------����1.ÿ�»�Ծ�豸��ϸ-----------------------
	-----------------------------��ر�---------------------
	��dws_uv_detail_day����ȡ����
	-----------------------------˼·-----------------------
	ѡȡһ�µķ�Χ����Ϊ���˵�������
	��dws_uv_detail_day�в�ѯ����ʱ����Ҫ����mid�Ž���ȥ�أ���ͬһ���豸�����Ķ�����ϸ��Ϣ
	ȥ�غ���ƴ�ӣ�һ���豸�ڱ�����һ�д��ڣ�
	һ��������ͬ��mid_idֻ����һ��

	-----------------------------�������-----------------------
	create external table dws_uv_detail_mn( 
		`mid_id` 		string COMMENT '�豸Ψһ��ʶ',
		`user_id` 		string COMMENT '�û���ʶ', 
		`version_code` 	string COMMENT '����汾��', 
		`version_name` 	string COMMENT '����汾��', 
		`lang` 			string COMMENT 'ϵͳ����', 
		`source` 		string COMMENT '������', 
		`os` 			string COMMENT '��׿ϵͳ�汾', 
		`area` 			string COMMENT '����', 
		`model` 		string COMMENT '�ֻ��ͺ�', 
		`brand` 		string COMMENT '�ֻ�Ʒ��', 
		`sdk_version` 	string COMMENT 'sdkVersion', 
		`gmail` 		string COMMENT 'gmail', 
		`height_width`	string COMMENT '��Ļ���',
		`app_time` 		string COMMENT '�ͻ�����־����ʱ��ʱ��',
		`network` 		string COMMENT '����ģʽ',
		`lng` 			string COMMENT '����',
		`lat` 			string COMMENT 'γ��'
	) COMMENT '��Ծ�û�������ϸ'
	PARTITIONED BY (`mn` string)
	stored as parquet
	location '/warehouse/gmall/dws/dws_uv_detail_mn/';

	-----------------------------SQL------------------------
	set hive.exec.dynamic.partition.mode=nonstrict;
	insert overwrite TABLE gmall.dws_uv_detail_mn PARTITION(mn)
	SELECT 
	mid_id, 
	concat_ws('|',collect_set(user_id)) user_id,
	concat_ws('|',collect_set(version_code)) version_code,
	concat_ws('|',collect_set(version_name)) version_name, 
	concat_ws('|',collect_set(lang)) lang, 
	concat_ws('|',collect_set(source)) source,
	concat_ws('|',collect_set(os)) os, 
	concat_ws('|',collect_set(area)) area, 
	concat_ws('|',collect_set(model)) model,
	concat_ws('|',collect_set(brand)) brand,
	concat_ws('|',collect_set(sdk_version)) sdk_version,
	concat_ws('|',collect_set(gmail)) gmail,
	concat_ws('|',collect_set(height_width)) height_width,
	concat_ws('|',collect_set(app_time)) app_time,
	concat_ws('|',collect_set(network)) network,
	concat_ws('|',collect_set(lng)) lng, 
	concat_ws('|',collect_set(lat)) lat,
	date_format('2020-02-14','yyyy-MM')
	FROM gmall.dws_uv_detail_day
	where date_format('2020-02-14','yyyy-MM')=date_format(dt,'yyyy-MM')
	group by mid_id;



	-----------------------------����1.����ÿ�գ��ܣ��º�Ծ�豸����-----------------------
	-----------------------------��ر�---------------------
	dws_uv_detail_day
	dws_uv_detail_wk
	dws_uv_detail_mn
	-----------------------------˼·-----------------------
	dws_uv_detail_day��ʹ��count(mid_id)ͳ���ջ�Ծ�豸��
	dws_uv_detail_wk�� ʹ��count(mid_id)ͳ���ܻ�Ծ�豸��
	dws_uv_detail_mn�� ʹ��count(mid_id)ͳ���»�Ծ�豸��
	
	is_weekend��
		�Ƿ���һ�ܵ����һ�죺if(date_sub(next_day('2020-02-14','mo'),1)='2020-02-14','Y','N')
			����ǰ�������ڵ����գ�date_sub(next_day('2020-02-14','mo'),1)
			�жϵ�ǰ�����Ƿ���ڵ�ǰ�����ܵ�����
				
	is_monthend���Ƿ���һ�µ����һ��  if(last_day('2020-02-14')='2020-02-14','Y','N')
	
	-----------------------------�������------------------------			
	create external table ads_uv_count( 
		`dt` 			string COMMENT 'ͳ������',
		`day_count` 	bigint COMMENT '�����û�����',
		`wk_count`  	bigint COMMENT '�����û�����',
		`mn_count`  	bigint COMMENT '�����û�����',
		`is_weekend` 	string COMMENT 'Y,N�Ƿ�����ĩ,���ڵõ��������ս��',
		`is_monthend` 	string COMMENT 'Y,N�Ƿ�����ĩ,���ڵõ��������ս��' 
	) COMMENT '��Ծ�豸��'
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_uv_count/';
				
	-----------------------------SQL------------------------
	INSERT into table gmall.ads_uv_count
	SELECT 
		'2020-02-14' dt, 
		day_count, 
		wk_count, 
		mn_count, 
		if(date_sub(next_day('2020-02-14','mo'),1)='2020-02-14','Y','N') is_weekend, 
		if(last_day('2020-02-14')='2020-02-14','Y','N') is_monthend	
	FROM (select count(mid_id) day_count from gmall.dws_uv_detail_day where dt='2020-02-14') t1
	JOIN(select count(mid_id) wk_count from gmall.dws_uv_detail_wk WHERE wk_dt=
		concat(date_sub(next_day('2020-02-14','mo'),7),'-',date_sub(next_day('2020-02-14','mo'),1))) t2
	join(select count(mid_id) mn_count  from gmall.dws_uv_detail_mn 
		WHERE mn=date_format('2020-02-14','yyyy-MM')) t3



		
		
		
		
		
		
	=============================����2 �����û�����=========================
	�����û��� 
		�û���һ���豸����Ϊһ���û�����Ҫͨ��mid_id��ʾ
		��������һ�δ�Ӧ��ʹ�õ��û���Ϊ�����û�
				
	-----------------------------����2.ÿ�������豸��ϸ-----------------------
	-----------------------------��ر�---------------------
	dws_uv_detail_day(�ջ��)�в�ѯ
	dws_new_mid_day(ÿ�������豸��)
	
	-----------------------------˼·-----------------------
	dws_uv_detail_day�����������еĻ�Ծ�û�����Ϣ��
			�������еĻ�Ծ�û�= ����������û� + ֮ǰ����ʷ�û� 
			
	Ҫ��dws_new_mid_day�������2020-02-14�����û���dws_new_mid_day�����Ѿ�����
	��Ӧ��ͳ��-2020-02-13���е����û���Ϣ�����û�����Ϣ��Ψһ�ģ�

	����������û�=����Ļ�Ծ�û�-֮ǰ����ʷ�û���

	������ջ��û�Ϊ���� a
	֮ǰ����ʷ�û�Ϊ���� b 

	ȡa��b��  a left join b where b.xxx is null

	a���ϣ�                  b����
	mid_id  name			mid_id  age
	1		a				1		3
	2		b				4		6
	3		c

	a left join b on a.mid_id = b.mid_id where b.mid_id is null
	
		a���ϣ�                 b����
	mid_id  name			mid_id  age
	1		a				1		3
	2		b				null	null
	3		c				null	null	

	-----------------------------�������------------------------
	create external table dws_new_mid_day(
		`mid_id` 		string COMMENT '�豸Ψһ��ʶ',
		`user_id` 		string COMMENT '�û���ʶ', 
		`version_code` 	string COMMENT '����汾��', 
		`version_name` 	string COMMENT '����汾��', 
		`lang` 			string COMMENT 'ϵͳ����', 
		`source` 		string COMMENT '������', 
		`os` 			string COMMENT '��׿ϵͳ�汾', 
		`area` 			string COMMENT '����', 
		`model` 		string COMMENT '�ֻ��ͺ�', 
		`brand` 		string COMMENT '�ֻ�Ʒ��', 
		`sdk_version` 	string COMMENT 'sdkVersion', 
		`gmail` 		string COMMENT 'gmail', 
		`height_width` 	string COMMENT '��Ļ���',
		`app_time` 		string COMMENT '�ͻ�����־����ʱ��ʱ��',
		`network` 		string COMMENT '����ģʽ',
		`lng` 			string COMMENT '����',
		`lat` 			string COMMENT 'γ��',
		`create_date`  	string COMMENT '����ʱ��' 
		) COMMENT 'ÿ�������豸��Ϣ'
	stored as parquet
	location '/warehouse/gmall/dws/dws_new_mid_day/';
	 
	-----------------------------SQL------------------------
	insert into table gmall.dws_new_mid_day
	SELECT t1.* FROM  
	(select * from dws_uv_detail_day where dt='2020-02-14') t1
	LEFT JOIN gmall.dws_new_mid_day nm on t1.mid_id=nm.mid_id WHERE nm.mid_id is null;



	-----------------------------����2.ͳ��ÿ�������豸��-----------------------
	-----------------------------��ر�---------------------
	��dws_new_mid_day��ִ��countͳ�Ƽ���

	-----------------------------�������-----------------------
	create external table ads_new_mid_count(
		`create_date`     string comment '����ʱ��' ,
		`new_mid_count`   BIGINT comment '�����豸����' 
	) COMMENT 'ÿ�������豸��Ϣ����'
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_new_mid_count/';

	-----------------------------SQL------------------------
	insert into table ads_new_mid_count
	SELECT '2020-02-14',count(*) FROM  dws_new_mid_day where create_date='2020-02-14'








	=============================����3 ��������=========================
	-----------------------------DWS��ÿ�������û���ϸ��-----------------
	-----------------------------��ر�---------------------
	dws_new_mid_day��ÿ�յ������û���
	dws_uv_detail_day:�ջ��

	-----------------------------˼·-----------------------
	�����ջ��������������ľ�������һ��ģ�
	��ϸ��Ϣ����dws_uv_detail_day(�ջ��)ȡ��
	
	create_date: �豸���������ڣ���һ���Ϊ���û��ģ���dws_new_mid_day����mid_id��ѯ
	retention_day����������ǰ�������������
			
	dt(�ջ����ݵ�����) = create_date + retention_day

	-----------------------------�������------------------------
	create external table dws_user_retention_day(
		`mid_id` 			string COMMENT '�豸Ψһ��ʶ',
		`user_id` 			string COMMENT '�û���ʶ', 
		`version_code` 		string COMMENT '����汾��', 
		`version_name` 		string COMMENT '����汾��', 
		`lang` 				string COMMENT 'ϵͳ����', 
		`source` 			string COMMENT '������', 
		`os` 				string COMMENT '��׿ϵͳ�汾', 
		`area` 				string COMMENT '����', 
		`model` 			string COMMENT '�ֻ��ͺ�', 
		`brand` 			string COMMENT '�ֻ�Ʒ��', 
		`sdk_version` 		string COMMENT 'sdkVersion', 
		`gmail` 			string COMMENT 'gmail', 
		`height_width` 		string COMMENT '��Ļ���',
		`app_time` 			string COMMENT '�ͻ�����־����ʱ��ʱ��',
		`network` 			string COMMENT '����ģʽ',
		`lng` 				string COMMENT '����',
		`lat` 				string COMMENT 'γ��',
	    `create_date`  		string COMMENT '�豸����ʱ��',
	    `retention_day`  	int    COMMENT '��ֹ��ǰ������������'
	) COMMENT 'ÿ���û��������'
	PARTITIONED BY (`dt` string)
	stored as parquet
	location '/warehouse/gmall/dws/dws_user_retention_day/';

	-----------------------------SQL------------------------
	-- ��1������
	-- �ȹ��ˣ��ٹ����ȽϺ�
	SELECT 
		t1.mid_id,
		t1.user_id, 
		t1.version_code,
		t1.version_name, 
		t1.lang, 
		t1.source,
		t1.os,
		t1.area,
		t1.model,
		t1.brand,
		t1.sdk_version, 
		t1.gmail, 
		t1.height_width,
		t1.app_time, 
		t1.network, 
		t1.lng, 
		t1.lat,
		t2.create_date, 
		1 retention_day, 
		'2020-02-15'
	FROM 
	(SELECT * from  gmall.dws_uv_detail_day where dt='2020-02-15') t1
	JOIN 
	(select mid_id,create_date from  gmall.dws_new_mid_day where create_date=date_sub('2020-02-15',1)) t2
	on t1.mid_id=t2.mid_id
	// 2.15����һ��ģ�����Ļ�Ծ�û�������������

	----------------------��1,2,3,n���������ϸ----------------------------
	insert overwrite TABLE dws_user_retention_day PARTITION(dt='2020-02-15')
	SELECT 
		t1.mid_id,
		t1.user_id, 
		t1.version_code,
		t1.version_name, 
		t1.lang, 
		t1.source,
		t1.os,
		t1.area,
		t1.model,
		t1.brand,
		t1.sdk_version, 
		t1.gmail, 
		t1.height_width,
		t1.app_time, 
		t1.network, 
		t1.lng, 
		t1.lat,
		t2.create_date, 
		1 retention_day
	FROM 
	(SELECT * from  gmall.dws_uv_detail_day where dt='2020-02-15') t1
	JOIN 
	(select mid_id,create_date from  gmall.dws_new_mid_day where create_date=date_sub('2020-02-15',1)) t2
	on t1.mid_id=t2.mid_id
	
	UNION all
	
	SELECT 
		t1.mid_id,
		t1.user_id, 
		t1.version_code,
		t1.version_name, 
		t1.lang, 
		t1.source,
		t1.os,
		t1.area,
		t1.model,
		t1.brand,
		t1.sdk_version, 
		t1.gmail, 
		t1.height_width,
		t1.app_time, 
		t1.network, 
		t1.lng, 
		t1.lat,
		t2.create_date, 
		2 retention_day
	FROM 
	(SELECT * from  gmall.dws_uv_detail_day where dt='2020-02-15') t1
	JOIN 
	(select mid_id,create_date from  gmall.dws_new_mid_day where create_date=date_sub('2020-02-15',2)) t2
	on t1.mid_id=t2.mid_id
	
	UNION all
	
	SELECT 
		t1.mid_id,
		t1.user_id, 
		t1.version_code,
		t1.version_name, 
		t1.lang, 
		t1.source,
		t1.os,
		t1.area,
		t1.model,
		t1.brand,
		t1.sdk_version, 
		t1.gmail, 
		t1.height_width,
		t1.app_time, 
		t1.network, 
		t1.lng, 
		t1.lat,
		t2.create_date, 
		3 retention_day
	FROM 
	(SELECT * from  gmall.dws_uv_detail_day where dt='2020-02-15') t1
	JOIN 
	(select mid_id,create_date from  gmall.dws_new_mid_day where create_date=date_sub('2020-02-15',3)) t2
	on t1.mid_id=t2.mid_id

	--union all��ʹ��ʱҪ��ƴ�ӵ�SQL���ֶ�������������Ҫһ�£�
	--union all��union����unionȥ�أ�union all��ȥ�أ�



	----------------------------ͳ��ads_user_retention_day_countÿ�������û�������---------------
	-----------------------------��ر�---------------------
	dws_user_retention_day
	-----------------------------˼·-----------------------
	create_date�� 	  ��dws_user_retention_day��ѯ
	retention_day��   ��dws_user_retention_day��ѯ
	retention_count�� ʹ��count(*)ͳ��

	�ȸ���create_date����ָ�����������������û����豸��ϸ��
	�ٸ���retention_day���飬֮��count(*)
	ѡ��create_date: ������������1����ж��٣�����2������ж���
	
	-----------------------------�������-------------------------
	create external table ads_user_retention_day_count(
	   `create_date`     string  comment  '�豸��������',
	   `retention_day`   int     comment  '��ֹ��ǰ������������',
	   `retention_count` bigint  comment  '��������'
	) COMMENT 'ÿ���û��������'
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_user_retention_day_count/';

	-----------------------------SQL------------------------
	insert into table gmall.ads_user_retention_day_count
	SELECT 
		'2020-02-14', 
		retention_day, 
		count(*)
	FROM gmall.dws_user_retention_day
	where create_date='2020-02-14' group by retention_day;
	// dws_user_retention_day�����ͳ�Ƶ��ǽ�ֹ����ǰÿ�����������


	-----------------------------������---------------------
	-----------------------------��ر�---------------------
	ads_user_retention_day_count
	ads_new_mid_count

	����������ȡ��ͬһ���������豸����Ϣ������豸�����������ǹ������ֶ�
	-----------------------------˼·-----------------------
	`stat_date`        �� һ���ǵ�ǰҪͳ�����ݵĵ�����һ�졣������ͳ�����ݵ����ڣ�   
	`create_date`      �� ��ads_user_retention_day_countȡ
	`retention_day`    �� ��ads_user_retention_day_countȡ
	`retention_count`  �� ��ads_user_retention_day_countȡ
	`new_mid_count`    �� ��ads_new_mid_countͳ�Ƶ�ǰ�����豸������
	`retention_ratio`  �� retention_count/new_mid_count

	-----------------------------�������------------------------
	create external table ads_user_retention_day_rate(
     `stat_date`         string 		comment 	'ͳ������',
     `create_date`       string 		comment 	'�豸��������',
     `retention_day`     int     		comment 	'��ֹ��ǰ������������',
     `retention_count`   bigint 		comment 	'��������',
     `new_mid_count`     bigint			comment 	'�����豸��������',
     `retention_ratio`   decimal(10,2) 	comment 	'������'
	) COMMENT 'ÿ���û��������'
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_user_retention_day_rate/';

	-----------------------------SQL------------------------
	insert into table ads_user_retention_day_rate
	SELECT 
		'2020-02-16',
		ur.create_date,
		ur.retention_day, 
		ur.retention_count, 
		nm.new_mid_count, 
		cast(ur.retention_count / nm.new_mid_count as decimal(10,2))
	FROM 
		ads_user_retention_day_count ur 
	JOIN
		ads_new_mid_count nm
	on ur.create_date=nm.create_date	
	where date_add(ur.create_date,ur.retention_day)='2020-02-16'
	
	# ÿ��������ݵ�ʱ�򣬼���ͳ�Ƶ���2020-02-16�����ݣ�ֻϣ�����뵱ǰͳ�Ƶ������ʣ�
	# ������join��ָ��create_date����������������ˣ����ܻ�����ظ�����ʷ���ݡ�











	=============================����4 ��Ĭ����=========================
	-----------------------------����-----------------------
	��Ĭ�û���ֻ�ڰ�װ������������������ʱ������һ��ǰ

	ֻ�ڰ�װ������������ ��Ĭ�û�ֻ�������һ���������־
	����ʱ������һ��ǰ�� ��Ĭ�û�����������־��ʱ�䣬������뵱ǰ��ͳ��ʱ���Ѿ��������7��

	-----------------------------��ر�---------------------
	�ջ��dws_uv_detail_day����ǰ���mid_id�����˺ϲ���
	һ��mid_id���ջ����һ�������1����¼

	-----------------------------˼·-----------------------
	���ջ����ȡ��ͳ������֮ǰ���������ݣ�����mid_id(�û��豸��)���飬
	ͳ���ջ�����еļ�¼��=1��mid_id
	���жϣ���¼��=1��mid_id�����������dt�Ƿ��Ѿ����뵱ǰ�����7��

	-----------------------------�������------------------------
	create external table ads_silent_count( 
		`dt` 			string COMMENT 'ͳ������',
		`silent_count` 	bigint COMMENT '��Ĭ�豸��'
	) 
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_silent_count';

	-----------------------------SQL------------------------
	insert into table ads_silent_count
	select '2020-02-16',count(*)
	from
		(select mid_id from dws_uv_detail_day where dt<='2020-02-16' GROUP by mid_id
		HAVING COUNT(mid_id)=1 and min(dt)<date_sub('2020-02-16',7)) tmp # 7��ǰС��

	# һ���û�7��ǰ��ˣ�7�������ٴλ��count���ǵ���1�����������д������
	select '2020-02-16',count(*)
	FROM 
		(select mid_id from dws_uv_detail_day where dt<date_sub('2020-02-16',7) group by mid_id 
		having count(mid_id)=1) tmp



		
		
		
		

	=============================����5 ���ܻ����û���=========================
	���ܻ����û�������û��ʹ��Ӧ�ã�����֮ǰʹ����Ӧ�ã�����ʹ����Ӧ��
	���ܻ����û�=�����ջ�-���������û�-�����ջ��û�

	-----------------------------��ر�---------------------
	dws_uv_detail_wk: �ܻ��
	dws_new_mid_day�� ÿ�������û���

	-----------------------------˼·-----------------------
	������������a left join b on a.x=b.x where b.x is null
	with 
		��ʱ���� as (),
		��ʱ���� as (),
		��ʱ���� as ()
		select ���
		
	-----------------------------�������------------------------	
		create external table ads_back_count( 
		`dt` 			string COMMENT 'ͳ������',
		`wk_dt` 		string COMMENT 'ͳ������������',
		`wastage_count` bigint COMMENT '�����豸��'
	) 
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_back_count';

	-----------------------------SQL------------------------
	with t1 as 
	(SELECT mid_id FROM dws_uv_detail_wk
	where wk_dt=concat(date_sub(next_day('2020-02-14','mo'),7),'-',date_sub(next_day('2020-02-14','mo'),1))),

	t2 as
	(SELECT mid_id from dws_new_mid_day
	where create_date BETWEEN date_sub(next_day('2020-02-14','mo'),7) and  '2020-02-14'),

	t3 as
	(SELECT mid_id FROM dws_uv_detail_wk
	where wk_dt=concat(date_sub(next_day('2020-02-14','mo'),14),'-',date_sub(next_day('2020-02-14','mo'),8)))

	insert into table ads_back_count
	
	select 
		'2020-02-14',
		concat(date_sub(next_day('2020-02-14','mo'),7),'-',date_sub(next_day('2020-02-14','mo'),1)),
		count(*)
	from
	t1 left join t2 on t1.mid_id=t2.mid_id 
	left join t3 on t1.mid_id=t3.mid_id
	where t2.mid_id is null and t3.mid_id is null




	

	=============================����6 ��ʧ�û���=========================
	��ʧ�û��� ���7��δ��¼���ǳ�֮Ϊ��ʧ�û�
	���һ���û�����¼�ˣ������ջ���Ϣ��
	���һ���û����ջ���У����һ�ε�¼�����ڣ����뵱ǰ�Ѿ������7�죬����û�������ʧ�û���

	-----------------------------��ر�---------------------
	�ջ��dws_uv_detail_daily

	-----------------------------˼·-----------------------
	ͳ���ջ���У������û������һ�ε�¼�����ڣ�
	�ж������Ƿ���뵱ǰС��7��

	-----------------------------�������------------------------
	create external table ads_wastage_count(
		`dt` 			string COMMENT 'ͳ������',
		`wastage_count` bigint COMMENT '��ʧ�豸��'
	)
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_wastage_count';

	-----------------------------SQL------------------------
	insert into table ads_wastage_count
	select '2020-02-18',COUNT(*)
	from 
		(select mid_id from dws_uv_detail_day
		where dt<='2020-02-18' group by mid_id having max(dt) < date_sub('2020-02-18',7)) tmp

	# �����ջ��û��У�ȥ�����������ջ��û�
	select '2020-02-20',COUNT(*) 
	from dws_uv_detail_day t1 
	left join 
		(select mid_id from dws_uv_detail_day  where dt 
		BETWEEN date_sub('2020-02-20',7) and '2020-02-20') t2 
	ON t1.mid_id = t2.mid_id where t2.mid_id is null  group by t1.mid_id






	=============================����7 ����������ܻ�Ծ�û���===============
	�������ܻ�Ծ�û��� �ڵ�ǰ����֮ǰ���ܵ��ܻ���У����û������ڣ�
	�ܻ���ص㰴��mid_id������ȥ�أ�
	�������û������������ܵ��ܻ��г��֣���ô�ͻ���3����Ӧ�ļ�¼��

	-----------------------------��ر�---------------------
	�ܻ��dws_dv_detail_wk

	-----------------------------˼·-----------------------
	��ǰ���ڣ�֮ǰ���ܵ����ݡ�����mid���飬�����ͳ�����ڼ�¼����=3�������������ܵ�¼���û�
	
	-----------------------------�������------------------------
	create external table ads_continuity_wk_count( 
		`dt` 				string COMMENT 'ͳ������,һ���ý�������������,���ÿ�����һ��,���õ�������',
		`wk_dt` 			string COMMENT '����ʱ��',
		`continuity_count` 	bigint
	) 
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_continuity_wk_count';

	-----------------------------SQL------------------------
	insert into table ads_continuity_wk_count
	select 
		'2020-02-18',
		concat(date_sub(next_day('2020-02-18','mo'),21),'-',date_sub(next_day('2020-02-18','mo'),1)),
		count(*)
	from    
	(select mid_id from dws_uv_detail_wk
		where monday_date BETWEEN date_sub(next_day('2020-02-18','mo'),21) and '2020-02-18'
		group by mid_id having count(*)=3) tmp




	=============================����8 ������������������Ծ�û���===============	
	-----------------------------��ر�---------------------
	�ջ�� dws_uv_detail_day
	-----------------------------˼·-----------------------
	������
			����A�У���X��������a��ͷ
			����B�У���Y��������b��ͷ
			
			A   		 B				�������в�ֵ
			a			 b				b-a
			a+X			 b+y			b-a + (Y-x)
			a+2X		 b+2y			b-a + 2(y-X)
			
			����A��B�ж��������ģ��й��ɵ�������ôÿ����֮��Ĳ�ֵ��Ҳ����Y-X������
			����X=Y����ʱÿ����֮��Ĳ�ֵ����0��������ֵһ����
			����A��B�ж��������ģ��й��ɵ���������һ������ô����֮��Ĳ�ֵһ����
			
	˼·����	ȡ��ǰ��־֮ǰ7�������
		  ��	�����û�mid_id���飬�������ڽ�����������
		  ��	ʹ��ROW_NUMBER����������һ��������������
		  ��	�������к�rw�У�����
		  ��	���û��Ͳ�ֵ���з��飬����������3����¼��������������mid_id���й��˼���
		  
	-----------------------------�������------------------------	  
	create external table ads_continuity_uv_count( 
		`dt` 				string COMMENT 'ͳ������',
		`wk_dt` 			string COMMENT '���7������',
		`continuity_count` 	bigint
	) COMMENT '������Ծ�豸��'
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_continuity_uv_count';

	-----------------------------SQL------------------------
	insert into TABLE ads_continuity_uv_count
	select 
		'2020-02-18', #ͳ�����ݵ�����
		concat(date_sub('2020-02-18',7),'-','2020-02-18'), # ���7�죬��ǰ���ڼ�ȥ7��
		count(DISTINCT mid_id)
	from
		(select mid_id
		from
			(SELECT 
				mid_id,dt,ROW_NUMBER() over(PARTITION by mid_id order by dt) rn,
				date_sub(dt,ROW_NUMBER() over(PARTITION by mid_id order by dt)) diff
			from dws_uv_detail_day where dt BETWEEN date_sub('2020-02-18',7) and '2020-02-18') tmp
		GROUP by mid_id,diff having count(*)>=3) tmp2


		// 1.ȡǰ���������,�õ�rn,diff
		select mid_id,dt,row_number() over(partition by mid_id order by dt) rn,
			date_sub(dt,row_number() over(partition by mid_id order by dt)) diff
		from dws_uv_detail_day where dt between date_sub('2020-02-18',7) and '2020-02-18'  // t1
		
		// 2.����mid_id,diff����
		select mid_id from t1 group by mid_id,diff having count(*) >= 3  // t2
		
		// 3.ѡ����
		select count(distinct mid_id) from t2
		
	
	
	
	
	
	=============================����9 ÿ���û��ۼƷ��ʴ���===============	
	��dws_user_total_count_day ��������
	-----------------------------��ر�---------------------
	dwd_start_log(������־��)
	
	-----------------------------˼·-----------------------
	�û�ÿ��һ��Ӧ�ã��ͻ����һ��������־��
	��������־���ѯ�������û�(mid_id)���飬��ÿ���û�������
	������־���ܵ�����(count)

	-----------------------------�������------------------------
	create external table dws_user_total_count_day( 
	`mid_id` 	string COMMENT '�豸id',
	`subtotal` 	bigint COMMENT 'ÿ�յ�¼С��'
	)
	partitioned by(`dt` string)
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/dws/dws_user_total_count_day';

	-----------------------------SQL------------------------
	insert overwrite table dws_user_total_count_day PARTITION(dt='2020-02-18')
	SELECT mid_id,count(*) subtotal	FROM dwd_start_log
	where dt='2020-02-18' GROUP by mid_id;
	
	
	
	-----------------------------����9 ads��ͳ���û����ۼƷ��ʴ���-----------------------
	-----------------------------��ر�---------------------
	dws_user_total_count_day
	
	-----------------------------˼·-----------------------
	��dws_user_total_count_day��ȡ��ÿ���û�ÿ���¼�Ĵ�����
	��ȡ��ÿ���û�֮ǰÿ���¼�Ĵ������ܺ�
	
	-----------------------------�������------------------------
	create external table ads_user_total_count( 
		`mid_id` 	string COMMENT '�豸id',
		`subtotal` 	bigint COMMENT 'ÿ�յ�¼С��',
		`total` 	bigint COMMENT '��¼�����ܼ�'
	)
	partitioned by(`dt` string)
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_user_total_count';

	-----------------------------SQL------------------------
	insert overwrite table ads_user_total_count PARTITION(dt='2020-02-18')
	SELECT
		t1.mid_id,
		t1.subtotal,
		t2.total
	from 
	(select mid_id,subtotal from dws_user_total_count_day where dt='2020-02-18') t1
	JOIN
	(select mid_id,sum(subtotal) total FROM dws_user_total_count_day where dt<='2020-02-18'
		GROUP by mid_id) t2
	on t1.mid_id=t2.mid_id


	
	
	
	

	-----------------------------����10 DWS�㽨���û���־��Ϊ���-----------------------
	ͳ��ÿ���û���ÿ����Ʒ�ĵ������, ���޴���, �ղش���
	
	-----------------------------��ر�---------------------
	dwd_display_log����Ʒ�������	mid_id(�û�)��goodsid����Ʒid��
	dwd_favorites_log���ղر���	mid_id(�û�)��course_id(��Ʒid)
	dwd_praise_log(���ޱ�)�� 		mid_id(�û�)��target_id����Ʒid��

	-----------------------------˼·-----------------------
	���û���ÿ����Ʒ�ĵ�����������޴������ղش�������Ϣ���ܵ�һ�ſ���У�

	�������������У������û�����ƷΪ��λ�����оۺϣ�
	��������������ȡ���ݣ�����mid_id����Ʒ���й����������������Ϣ���ܺϲ���
		�ϲ�������join��ʹ��join�������Ӳ�����
			  ��hive�о�������join!
	
	-----------------------------�������------------------------			
	CREATE EXTERNAL TABLE dws_user_action_wide_log(
		`mid_id` 			string COMMENT '�豸id',
		`goodsid` 			string COMMENT '��Ʒid',
		`display_count` 	string COMMENT '�������',
		`praise_count` 		string COMMENT '���޴���',
		`favorite_count` 	string COMMENT '�ղش���')
	PARTITIONED BY (`dt` string)
	stored as parquet
	location '/warehouse/gmall/dws/dws_user_action_wide_log/'
	TBLPROPERTIES('parquet.compression'='lzo');

	-----------------------------SQL------------------------
	insert overwrite TABLE dws_user_action_wide_log PARTITION(dt='2020-02-17')
	select 
		mid_id, 
		goodsid,
		sum(display_count),
		sum(praise_count), 
		sum(favorite_count)
	from
	(select 
		mid_id,goodsid,count(*) display_count,0 praise_count, 0 favorite_count 
	from dwd_display_log where dt='2020-02-17' group by mid_id,goodsid
	union all

	SELECT
		mid_id,target_id goodsid,0 display_count ,count(*) praise_count,0 favorite_count 
	from dwd_praise_log where dt='2020-02-17' group by mid_id,target_id
	union all

	select 
		mid_id,course_id goodsid, 0 display_count,0 praise_count, count(*) favorite_count
	from dwd_favorites_log where dt='2020-02-17' group by mid_id,course_id) tmp
	GROUP by mid_id,goodsid
	# ע�ⲻҪ�Էֽ���������ᱨ��

	

	-----------------------------����10 ads_new_favorites_mid_dayͳ��ÿ������ղ��û���---------
	-----------------------------��ر�---------------------
	dws_user_action_wide_log�� �û���Ϊ���
		ͳ�Ƶ���ÿ���û���ÿ����Ʒ�ĵ��ޣ�������ղصĴ���
	
	-----------------------------˼·-----------------------
	��dws_user_action_wide_log��ȡ���ղصĴ���>0�ļ�¼,���û����飬����û��Ƿ������û�
	���û���������ʹ�����ղع��ܵ������У�ȡ��������(С)�ģ����������ڵ��ڽ��죬
			��ô˵����ǰ�û��ǵ�һ��ʹ���ղأ��������û���
	
	-----------------------------�������------------------------
	create external table ads_new_favorites_mid_day( 
		`dt` 				string COMMENT '����',
		`favorites_users` 	bigint COMMENT '���ղ��û���'
	) 
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_new_favorites_mid_day';

	-----------------------------SQL1------------------------
	insert into table ads_new_favorites_mid_day
	select '2020-02-17',count(*)
	from
	(select mid_id from dws_user_action_wide_log
	where favorite_count>0 group by mid_id having MIN(dt)='2020-02-17') tmp

	-----------------------------SQL2------------------------
	ȡ������ʹ�����ղع��ܵ��û���ȥ�������Լ�֮ǰʹ���˴˹��ܵ��û���ע��ȥ�أ��Ӳ�ѯ��ӱ���
	select '2020-02-19',count(*) from (
		select DISTINCT mid_id from dws_user_action_wide_log 
		where dt='2020-02-19' and favorite_count >0
		and mid_id  not in 
	(select DISTINCT mid_id id from dws_user_action_wide_log t1 where dt<'2020-02-19' and favorite_count>0)   
	) t2



	
	
	

	-----------------------------����11 ������Ʒ�������top3���û�-----------------------
	��������������壺
		�ǽ���ĵ��������      ��dws_user_action_wide_logʹ�ý������ڹ��ˣ�
		���ۼƵ��ܵ��������    ȡdws_user_action_wide_log����֮ǰ�������ݣ�
	
	���ÿ����Ʒ���ۼƵ������ǰ�������û���
	
	-----------------------------��ر�---------------------
	dws_user_action_wide_log
	
	-----------------------------˼·-----------------------
	�� ���˳��������>0���û���ȡ��Щ�û�����֮ǰ���������ݣ�
	�� ������Ʒid���û�id���з��飬ͳ��ÿ���û���ÿ����Ʒ���ۼƵ��������
	�� ���ÿ����Ʒ��ÿ���û����ۼƵ������������ƷΪ��λ������
		�����û��ĵ���������������������ǰ�����û���

	-----------------------------�������------------------------
	create external table ads_goods_count( 
		`dt` 					string COMMENT 'ͳ������',
		`goodsid` 				string COMMENT '��Ʒ',
		`user_id` 				string COMMENT '�û�',
		`goodsid_user_count` 	bigint COMMENT '��Ʒ�û��������'
	) 
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_goods_count';

	-----------------------------SQL------------------------
	insert into table ads_goods_count
	select 
	   '2020-02-17', goodsid,mid_id,totalCount
	from 
	(select  goodsid,mid_id,totalCount,
	RANK() over(PARTITION by goodsid order by totalCount desc )rn
	from 
	(SELECT
	   goodsid,mid_id,sum(display_count) totalCount
	from dws_user_action_wide_log
	where dt<='2020-02-17' and display_count>0
	GROUP by goodsid,mid_id) t1) t2
	where rn<=3

	��һ����������������㣬��ֹ��ǰÿ����Ʒ�������û����ۼƵ������
	select goodsid,mid_id,sum(display_count) totalCount from dws_user_action_wide_log t1
		where display_count > 0 and dt<='2020-02-17' group by goodsid ,mid_id 	// t2

	�ڶ�����������Ʒ���������������������
	select goodsid,mid_id,totalCount,
		rank() over(partition by goodsid order by totalCount desc) rn from t2  		// t3

	��������ȡ��ǰ��
	select '2020-02-17', goodsid,mid_id,totalCount from t3 where rn<=3








	-----------------------------����12 ͳ��ÿ�ո�����µ������top10����Ʒ-----------------------
	-----------------------------��ر�---------------------
	dws_user_action_wide_log: �ڽ����ʱӦ�ó�ֿ��ǵ�������ĳһ����������漰����ȫ���ֶΣ�
	dwd_display_log�� category��mid_id,goodsid,û�оۺϣ�

	-----------------------------˼·-----------------------
	��dwd_display_log��ȡ����ĵ�����ݣ�����category��goodsid���з��飬���ÿ����Ʒ����Ĵ�����
	�������з������Ե����������������ÿ����Ʒ��������
	ȡ����ǰʮ����Ʒ��
	
	-----------------------------�������------------------------------------------------
	create external table ads_goods_display_top10 ( 
		`dt` 			string COMMENT '����',
		`category` 		string COMMENT 'Ʒ��',
		`goodsid` 		string COMMENT '��Ʒid',
		`goods_count` 	string COMMENT '��Ʒ�������'
	) 
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_goods_display_top10';

	-----------------------------SQL------------------------
	insert into table ads_goods_display_top10
	select 
		'2020-02-17',category,goodsid,goods_count
	from 
	(select category,goodsid,goods_count,
		RANK() over(PARTITION by category order by goods_count desc) rn
	from
	(select category,goodsid,count(*) goods_count from dwd_display_log
		where dt='2020-02-17' group by category,goodsid) t1) t2
	where rn <=10





	
	


	-----------------------------����13 �ܵ����������10���û�����ĸ�������Ʒ����------------------
	`dt` 		string COMMENT 'ͳ������',
	`mid_id` 	string COMMENT '�û�id',
	`u_ct` 		string COMMENT '�û��ܵ������'  ������Ʒ���ܵ��������������Ϊ���� ��ĳ����Ʒ���ܵ��������
	`goodsid` 	string COMMENT '��Ʒid',
	`d_ct` 		string COMMENT '�û��Դ���Ʒ�ܵ������'

	-----------------------------��ر�---------------------
	dws_user_action_wide_log
	
	-----------------------------˼·-----------------------
	���ܵ����������10���û�
	�������10���û����Ե������Ʒ����
	
	-----------------------------�������------------------------------------------------
	create external table ads_goods_user_count( 
	`dt` 			string COMMENT 'ͳ������',
	`mid_id` 		string COMMENT '�û�id',
	`u_ct` 			string COMMENT '�û��ܵ������',
	`goodsid` 		string COMMENT '��Ʒid',
	`d_ct` 			string COMMENT '������Ʒ�������'
	) 
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_goods_user_count';

	-----------------------------SQL------------------------
	insert into TABLE ads_goods_user_count
	select 
		'2020-02-17',t1.mid_id,u_ct,goodsid,d_ct
	from 
	(select mid_id,sum(display_count) u_ct
		from dws_user_action_wide_log
		where dt<='2020-02-17' GROUP by mid_id order by u_ct desc limit 10) t1
	join 
		(select mid_id,goodsid,sum(display_count) d_ct
		from dws_user_action_wide_log where dt<='2020-02-17' group by mid_id,goodsid) t2
	on t1.mid_id=t2.mid_id where d_ct>0


	// ���ܵ����������10���û�
	select mid_id,sum(display_count) u_ct from dws_user_action_wide_log
		where dt<='2020-02-17' group by mid_id order by u_ct desc limit 10  // t1	
	
	// �������10���û����Ե������Ʒ����
	select mid_id,goodsid,sum(display_count) d_ct
		from dws_user_action_wide_log where dt<='2020-02-17' group by mid_id,goodsid  // t2
	
	// ���	
	select '2020-02-17',t1.mid_id,u_ct,goodsid,d_ct 
		from t1 join t2 on t1.mid_id = t2.mid_id where d_ct>0






	-----------------------------����14 �»�Ծ��-------------
	�»�Ծ�û����ֹ�������ۼƵ��û��ܺ�֮��ı���
	-----------------------------��ر�---------------------
	ads_uv_count�� 		ȡ�»�Ծ�û�
	ads_new_mid_count�� ȡ�������������е��û���

	-----------------------------�������---------------------
	create external table ads_mn_ratio_count( 
	   `dt` 		string COMMENT 'ͳ������',
	   `mn` 		string COMMENT 'ͳ���»�Ծ�ʵ��·�',
	   `ratio` 		string COMMENT '��Ծ��'
	) 
	row format delimited fields terminated by '\t'
	location '/warehouse/gmall/ads/ads_mn_ratio_count';

	-----------------------------SQL------------------------
	# ͳ��2020-02-17�յ��»�Ծ��
	insert into table ads_mn_ratio_count
	select
		'2020-02-17',
		date_format('2020-02-17','yyyy-MM'),
		cast(mn_count/totalCount * 100 as decimal(10,2)) 
	from
	(SELECT mn_count from ads_uv_count where dt='2020-02-17' ) t1
	join
	(SELECT sum(new_mid_count) totalCount from ads_new_mid_count
		where create_date <= '2020-02-17') t2 

			
	
	
	
	
	
	
	
	
	
	
	
	
	
	
