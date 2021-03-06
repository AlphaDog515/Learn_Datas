
一、自定义函数
	1.先编写自定义的函数
		①引入依赖 
			<dependency>
				<groupId>org.apache.hive</groupId>
				<artifactId>hive-exec</artifactId>
				<version>1.2.1</version>
			</dependency>
		
		② 自定义UDF函数，继承UDF类
		③ 提供evaluate()，可以提供多个重载的此方法，但是方法名是固定的
		④ evaluate()不能返回void，但是可以返回null!
	
	2.打包: build package
	
	3.安装: 在HIVE_HOME/auxlib 目录下存放jar包！
	
	4.创建函数
		注意：用户自定义的函数，是有库的范围！指定库下创建的函数，只在当前库有效！		
		create [temporary] function  函数名  as  自定义的函数的全类名
		temporary：该函数仅对创建它的连接可见，并在删除该连接时随之自动删除！
		

		
		
二、存储格式
	1.  在大数据领域一般都采用列式存储

	2.  ORC 和 PARQUET对比
			ORC：    hive独有，只有在hive中可以使用, ORC更优一点！ ORC的压缩比高！
			PARQUET：clodera公司提供的一个旨在整个hadoop生态系统中设计一个通用的高效的数据格式！
					 PARQUET格式的文件，不仅hive支持，hbase，impala，spark都支持！
							
	3.  总结
			① 如果表以TEXTFILE为格式存储数据，可以使用load的方式，否则都必须使用insert into!
			② 压缩比：ORC>PARQUET>TEXTFILE;
			③ 在查询速度上无明显差别;
			④ 一般使用ORC(内部使用SNAPPY压缩）;
			⑤ 如果使用Parquet(LZO);
		
		
		
		
三、练习
	1.ETL
			① 统一集合类型的分隔符为&，替换最后一个字段的分隔符由\t替换为&；
			② 去除category中每个类别多余的空格；
			③ 每行数据至少有9个字段；
			
			如何进行ETL： 
				① 写shell脚本使用awk,sed这些工具；
				② 写java程序进行ETL（我们采用）；
				③ 使用一些专业的ETL工具，例如kettle；
			
			
			
四、练习答案
	sql执行顺序：
		select * from 表1 join 表2 on xxx where xxx  group by  xxx  having xxx order by limit xxx
	a) 先关联表 join
	b) where 
	c) group by
	d) having
	e) select
	f) order by
	h) limit

	gulivideo_user_ori(uploader ,videos ,friends )
	gulivideo_ori(videoId, uploader, age, category, length, views, rate, ratings, comments,relatedId )

建表语句
	视频表
	create table gulivideo_ori(
		videoId 	string, 
		uploader	string, 
		age 		int, 
		category 	array<string>, 
		length 		int, 
		views 		int, 
		rate 		float, 
		ratings 	int, 
		comments 	int,
		relatedId 	array<string>
	)
	row format delimited fields terminated by "\t"
	collection items terminated by "&"
	stored as textfile;
	
	字段			备注			详细描述
	video id		视频唯一id		11位字符串
	uploader		视频上传者		上传视频的用户名String
	age				视频年龄		视频在平台上的整数天
	category		视频类别		上传视频指定的视频分类
	length			视频长度		整形数字标识的视频长度
	views			观看次数		视频被浏览的次数
	rate			视频评分		满分5分
	ratings			流量			视频的流量，整型数字
	conments		评论数			一个视频的整数评论数
	related ids		相关视频id		相关视频的id，最多20个

	用户表
	create table gulivideo_user_ori(
		uploader 	string,
		videos 		int,
		friends 	int
	)
	row format delimited fields terminated by "\t" 
	stored as textfile;
	
	字段		备注			字段类型
	uploader	上传者用户名	string
	videos		上传视频数		int
	friends		朋友数量		int

	
	
加载数据：
	gulivideo_ori：
		load data local inpath "/home/atguigu/hivedatas/gulivideo/*" into table gulivideo_ori;

	gulivideo_user_ori：
		load data inpath "/home/atguigu/hivedatas/user.txt" into table gulivideo_user_ori;



1.统计视频观看数Top10
	解题思路：将观看数降序排序，排序后取前10
	查询语句：
		select videoId,views from gulivideo_ori order by views desc limit 10 

	结果：
	--------------+-----------+--+
	|   videoid    |   views   |
	+--------------+-----------+--+
	| dMH0bHeiRNg  | 42513417  |
	| 0XxI-hvPRRA  | 20282464  |
	| 1dmVU08zVpA  | 16087899  |
	| RB-wUgnyGv0  | 15712924  |
	| QjA5faZF1A8  | 15256922  |
	| -_CSo1gOd48  | 13199833  |
	| 49IDp76kjPw  | 11970018  |
	| tYnn51C3X_w  | 11823701  |
	| pv5zWaTEVkI  | 11672017  |
	| D2kJZOfq7zk  | 11184051  |


	
	
2.统计视频类别热度Top10
	统计视频热度((一个类别下，观看的总的views最多视频最热))的top10类别

	//先将每个视频的类别炸裂
	select videoid,categoryName,views
	from gulivideo_ori
	lateral view explode(category) tmp as categoryName   //t1

	//统计每个类型的views总数，并排序取前十
	select categoryName,sum(views) sumViews
	from t1
	group by categoryName
	order by sumViews desc
	limit 10

	------------------最终sql---------------------

	select categoryName,sum(views) sumViews
	from 
		(select  videoid,categoryName,views
		from  gulivideo_ori
		lateral view explode(category) tmp as  categoryName) t1
	group by categoryName
	order by sumViews desc
	limit 10

	结果：
	+----------------+-------------+--+
	|  categoryname  |  sumviews   |
	+----------------+-------------+--+
	| Music          | 2420437295  |
	| Entertainment  | 1639816318  |
	| Comedy         | 1598182384  |
	| Animation      | 655812236   |
	| Film           | 655812236   |
	| Sports         | 644927678   |
	| Games          | 504654575   |
	| Gadgets        | 504654575   |
	| Blogs          | 424400923   |
	| People         | 424400923   |


	

3.统计出视频观看数最高的20个视频的所属类别,以及该类别包含Top20视频的个数
	视图(View)：①视图是一种特殊(逻辑上存在)的表
				②视图是只读的
				③视图可以将敏感的字段进行保护，只将用户需要查询的字段暴露在视图中，保护数据隐私
				
	create view 视图名  as select 语句

	create view categoryView as select  
		videoid,categoryName,views
	from gulivideo_ori lateral view explode(category) tmp as categoryName

	// 观看数最高的20个视频
	select videoId,views from gulivideo_ori	order by views desc	limit 20    // t1

	select categoryName,count(*) videoNum
	from t1 join categoryView cv on t1.videoId=cv.videoid
	group by categoryName  //t2 // 内连接

	----------------最终sql---------------------
	select  categoryName,count(*) videoNum
	from 
		(select  videoId,views
		from  gulivideo_ori
		order by  views desc
		limit 20 ) t1 
	join categoryView cv
	on t1.videoId=cv.videoid
	group by categoryName 

	结果：
	----------------+-----------+--+
	|  categoryname  | videonum  |
	+----------------+-----------+--+
	| Blogs          | 2         |
	| Comedy         | 6         |
	| Entertainment  | 6         |
	| Music          | 6         |
	| People         | 2 


	
	
4.统计视频观看数Top50所关联视频的所属类别(最热(总观看数最多))Rank
	//观看数最高的50个视频以及关联视频
	select videoId,views,relatedId
	from gulivideo_ori
	order by views desc
	limit 50    // t1

	//炸裂求出所有的关联视频
	select distinct(col1) relatedVideoId
	from t1
	lateral view explode(relatedId) tmp as col1  //t2

	//求出相关视频所属的类别及每个类别的总观看数
	select categoryName,sum(cv.views) sumViews
	from 
		t2 
	join categoryView cv
	on t2.relatedVideoId=cv.videoid
	group by categoryName    // t3

	//求出类别的热度排名
	select categoryName,sumViews,rank() over(order by sumViews desc)
	from t3


	-------------------最终sql---------------------

	select  categoryName,sumViews,rank() over(order by sumViews desc)
	from (select categoryName,sum(cv.views) sumViews
	from (select distinct(col1)  relatedVideoId
	from (select videoId,views,relatedId
	from  gulivideo_ori
	order by views desc
	limit 50) t1
	lateral view explode(relatedId) tmp as col1 ) t2 join categoryView cv
	on t2.relatedVideoId=cv.videoid
	group by categoryName )t3

	结果：
	 categoryname  | sumviews  | rank_window_0  |
	+----------------+-----------+----------------+--+
	| Entertainment  | 39756244  | 1              |
	| Comedy         | 33167588  | 2              |
	| Music          | 28379960  | 3              |
	| Animation      | 8563583   | 4              |
	| Film           | 8563583   | 4              |
	| Games          | 4339996   | 6              |
	| Gadgets        | 4339996   | 6              |
	| Blogs          | 3529193   | 8              |
	| People         | 3529193   | 8              |
	| Sports         | 2314721   | 10             |
	| Animals        | 798878    | 11             |
	| Pets           | 798878    | 11             |
	| News           | 779979    | 13             |
	| Politics       | 779979    | 13             |
	| Places         | 701597    | 15             |
	| Travel         | 701597    | 15             |
	| Howto          | 475425    | 17             |
	| DIY            | 475425    | 17             |
	| Autos          | 179583    | 19             |
	| Vehicles       | 179583    | 19  


	
	

5.统计每个类别中的视频热度Top10  //views最多为视频最热

	create view categoryView as
	select videoid,categoryName,views
	from  gulivideo_ori
	lateral view explode(category) tmp as categoryName

	--------------------------------------
	//求每个视频在每个类别的排名
	select videoid,categoryName,views,rank() over(partition by categoryName order by views desc) rn
	from categoryView   //t1

	//求每个类别的前10视频
	select videoid,categoryName,views,rn
	from t1
	where rn <= 10 

	---------------------最终sql---------------------
	select videoid,categoryName,views,rn
	from 
		(select videoid,categoryName,views,rank() over(partition by categoryName order by views desc) rn
		from 
			categoryView ) t1
	where rn <= 10 


	
	
	
7.统计上传视频最多的用户Top10以及他们上传的观看次数在前20的视频
	gulivideo_user_ori(uploader,videos,friends )
	gulivideo_ori(videoId,uploader,age,category,length,views,rate,ratings,comments,relatedId)

	create view categoryView as
	select videoid,categoryName,views
	from  gulivideo_ori
	lateral view explode(category) tmp as  categoryName
	
	---------------------------------思路1-------------------------------------------
	// 统计上传视频最多的用户Top10以及他们上传所有视频中，观看次数在前20的视频

	// 求上传视频最多的用户Top10
	select uploader,videos
	from gulivideo_user_ori
	order by videos desc 
	limit 10    //t1

	// 求这十个人上传的观看次数在前20的视频
	select video.videoId,video.views
	from t1 join gulivideo_ori video
	on t1.uploader=video.uploader
	order by views desc
	limit 20

	----------------------最终sql---------------------
	select video.videoId,video.views
	from 
		(select  uploader,videos
		from  gulivideo_user_ori
		order by  videos desc 
		limit 10 ) t1 
	join gulivideo_ori video
	on t1.uploader=video.uploader
	order by views desc
	limit 20

	
	
	------------------------------------思路2----------------------------------------
	// 统计上传视频最多的用户Top10以及他们每个人上传所有视频中，观看次数在前20的视频
	
	// 求上传视频最多的用户Top10
	select uploader,videos
	from gulivideo_user_ori
	order by videos desc 
	limit 10    //t1
	
	select videoId,views,rank() over(partition by video.uploader order by views desc) rn
	from t1 join gulivideo_ori video
	on t1.uploader=video.uploader    // t2

	// 从t2中选取rn <=20 的所有数据
	select videoId,views,rn
	from t2
	where rn <=20 

	-----------------------最终sql---------------------
	select videoId,views,rn
	from (select  videoId,views,rank() over(partition by video.uploader order by views desc) rn
	from (select  uploader,videos
	from gulivideo_user_ori
	order by videos desc 
	limit 10)t1 join  gulivideo_ori video
	on t1.uploader=video.uploader  )t2
	where rn <=20 		
					