# 自用工具集
```
#下载脚本
wget https://raw.githubusercontent.com/litespeedtech/ols1clk/master/ols1clk.sh
#常用安装命令
bash ols1clk.sh --lsphp 74 -w --mariadbver 10.5 --dbname wordpressdb --dbuser dbuser
#安装扩展
apt install lsphp74-imagick -y
```
# 设置文件目录权限
```
chown -R nobody:nogroup wordpress/  #修改文件目录所有者
find wordpress/ -type d -exec chmod 750 {} \; #目录权限
find wordpress/ -type f -exec chmod 640 {} \; #文件权限
```

# 301 跳转到HTTPS 添加到 .htaccess 或者 面板-资源集-重写规则中
```
RewriteCond %{SERVER_PORT} 80
RewriteRule ^(.*)$ https://%{HTTP_HOST}$1 [R,L]
```
# 解压SQL文件
```
gzip -d  aaaa.sql.gz 
```
# 解压文件
```
tar -zvxf web.tar.gz
```

# MySQL导入数据
```
mysql
mysql > use db_name 
mysql > source /path/aaaa.sql

mysql -uroot -p dbname < /path/aaaa.sql
```


```
# 添加一个管理员并设置密码
GRANT ALL PRIVILEGES ON *.* TO 'admini'@'localhost' IDENTIFIED BY '设置的密码' WITH GRANT OPTION; 
#添加用户
mysql > insert into mysql.user(Host,User,Password) values("localhost","test",password("1234"));
#更新密码
mysql > update mysql.user set password=password('新密码') where User="test" and Host="localhost";
#删除用户
mysql  >Delete FROM user Where User='test' and Host='localhost';
#删除用户
drop user 'username'@'host';  
```

```
create database test; #新建数据库
show databases;       #查看所有数据库
show tables;          #查看所有表       
drop database test;   #删除数据库
select user,host from mysql.user;   #查看所有用户
```

# 授权test用户有testDB数据库的所有权限
```
grant all privileges on testDB.* to 'test'@'%' identified by 'test123';
```
# 刷新权限
```
mysql > flush privileges;
```
# 更换域名
```
1.替换站点和主页域名
UPDATE wp_options SET option_value=replace(option_value, '旧域名', '新域名') WHERE option_name='home' OR option_name='siteurl';

2.插件 Better Search Replace：查找和替换数据库内容
https://wordpress.org/plugins/better-search-replace/
```
