# 
# Table structure for table 'access_log_tb'
#
CREATE TABLE access_log_tb (
  visitor_ip varchar(15) DEFAULT '' NOT NULL,
  host_name varchar(10) DEFAULT '' NOT NULL,
  date_time datetime DEFAULT '0000-00-00 00:00:00' NOT NULL,
  user_id varchar(8),
  KEY index_ip (visitor_ip),
  KEY index_vhost (host_name),
  KEY index_time (date_time)
);

# visitor_ip,host_name,date_time,user_id