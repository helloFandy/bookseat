DROP TABLE IF EXISTS `b_notify`;
CREATE TABLE `b_notify` (
                            `id` int NOT NULL AUTO_INCREMENT,
                            `title` varchar(255) NOT NULL COMMENT '标题',
                            `content` text NOT NULL,
                            `create_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建日期',
                            `create_by` varchar(100) NOT NULL COMMENT '创建人id',
                            `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
                            PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;

LOCK TABLES `b_notify` WRITE;
INSERT INTO `b_notify` VALUES (2,'关于自习室座位调整的通知','因为近期自习室需要扩建，因此与2023年5月16号暂停1号自习室的预约','2023-01-16 23:15:29','null',0);
UNLOCK TABLES;

DROP TABLE IF EXISTS `b_room`;
CREATE TABLE `b_room` (
                          `id` int NOT NULL AUTO_INCREMENT,
                          `name` varchar(45) DEFAULT NULL COMMENT '自习室名称',
                          `location` varchar(200) DEFAULT NULL COMMENT '位置',
                          `rows` varchar(45) NOT NULL COMMENT '规格-排数',
                          `cols` varchar(45) NOT NULL COMMENT '规格-列数',
                          `is_enable` tinyint(1) DEFAULT '1' COMMENT '是否可用；0:不可用，1:可用',
                          `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否删除；0:未删除，1:逻辑删除',
                          PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;

LOCK TABLES `b_room` WRITE;
INSERT INTO `b_room` VALUES (1,'1号会议室','综合楼1楼','10','10',1,0),(2,'2号会议室','综合楼1楼','2','3',1,0),(5,'3号会议室','综合楼2楼','3','4',1,0);
UNLOCK TABLES;

DROP TABLE IF EXISTS `b_seats`;
CREATE TABLE `b_seats` (
                           `id` int NOT NULL AUTO_INCREMENT,
                           `rows` int NOT NULL COMMENT '第几排',
                           `cols` int NOT NULL COMMENT '第几列',
                           `room_id` int NOT NULL COMMENT '自习室id',
                           `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
                           PRIMARY KEY (`id`),
                           UNIQUE KEY `uniq_room_row_col` (`room_id`,`cols`,`rows`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb3;

LOCK TABLES `b_seats` WRITE;
INSERT INTO `b_seats` VALUES (1,1,1,1,0),(3,1,2,2,0),(4,1,2,1,0),(6,1,4,1,0),(10,1,3,1,0),(11,1,5,1,0),(12,1,6,1,0),(13,1,7,1,0),(14,1,8,1,0),(15,1,9,1,0),(16,1,10,1,0),(17,1,1,2,0),(18,2,1,2,0),(19,2,2,2,0),(20,2,1,1,0),(21,2,2,1,0);
UNLOCK TABLES;

DROP TABLE IF EXISTS `b_user_seats`;
CREATE TABLE `b_user_seats` (
                                `id` int NOT NULL AUTO_INCREMENT,
                                `user_id` int NOT NULL COMMENT '用户id',
                                `seat_id` int NOT NULL COMMENT '座位id',
                                `start_time` datetime NOT NULL COMMENT '开始时间',
                                `end_time` datetime NOT NULL COMMENT '结束时间',
                                `status` tinyint(1) DEFAULT '1' COMMENT '状态：1待签到、2已签到、3释放',
                                `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '逻辑删除 0未删除  1已删除',
                                `create_date` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建日期',
                                PRIMARY KEY (`id`),
                                KEY `idx_start_end` (`start_time`,`end_time`) USING BTREE COMMENT '开始时间，结束时间联合索引'
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;

LOCK TABLES `b_user_seats` WRITE;
INSERT INTO `b_user_seats` VALUES (2,1,1,'2023-01-15 10:10:10','2023-01-15 17:10:00',2,0,'2023-01-14 17:10:00'),(3,2,3,'2023-01-15 12:10:00','2023-01-15 17:00:00',1,0,NULL),(4,1,1,'2023-01-17 22:00:00','2023-01-17 23:00:00',1,0,'2023-01-17 21:56:49'),(5,1,4,'2023-01-17 23:00:00','2023-01-18 00:00:00',1,0,'2023-01-17 22:02:51');
UNLOCK TABLES;


DROP TABLE IF EXISTS `b_user`;
CREATE TABLE `b_user` (
                          `id` int NOT NULL AUTO_INCREMENT,
                          `name` varchar(32) NOT NULL,
                          `password` varchar(32) NOT NULL,
                          `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态；1:生效，2:逻辑删除',
                          `user_type` tinyint(1) NOT NULL DEFAULT '1' COMMENT '用户类型；1:管理员，2:学生，3:老师',
                          `username` varchar(45) NOT NULL COMMENT '账号',
                          `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
                          `mobile` varchar(20) DEFAULT NULL COMMENT '手机号',
                          `reputation` int NOT NULL DEFAULT '100' COMMENT '信誉值，低于60不能选座',
                          PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;


LOCK TABLES `b_user` WRITE;
INSERT INTO `b_user` VALUES (1,'管理员','12345678',1,1,'admin',0,NULL,100),(2,'小邹1号','123456',1,2,'zqr001',0,NULL,100),(3,'小邹2号','123456',1,2,'zqr002',0,NULL,100),(4,'小邹3号','123456',1,2,'zqr003',1,NULL,100),(5,'小邹4号','123456',1,2,'zqr004',0,'13367650000',100),(6,'小邹5号','123456',1,2,'null',0,'13367650000',100);
UNLOCK TABLES;