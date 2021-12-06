#!/bin/bash

#文档
#MySQL导出工具: https://www.cnblogs.com/markLogZhu/p/11398028.html
#Linux定时任务: https://www.runoob.com/linux/linux-comm-crontab.html
#Linux定时任务: https://www.cnblogs.com/makalochen/p/12784314.html
#bypy百度网盘1: https://blog.csdn.net/qq_35425070/article/details/96577512
#bypy百度网盘2: https://gitee.com/zgg189/bypy?_from=gitee_search 
#系统提示不支持UTF8中文: https://blog.csdn.net/weixin_34343308/article/details/91759898

#运行该脚本需要安装依赖包
#apt install python3
#apt install python3-pip
#pip install bypy

#备份数据库名
db_name=abcdc
#网站根目录
web_dir=/wwwroot/www.website.com

#备份文件保存目录
backup=/root/backup/

#备份网站保存名称
web_save_name=$(date +%Y-%m-%d).web.tar.gz
#备份数据库保存名称
sql_save_name=$(date +%Y-%m-%d).sql.gz

#数据库用户名
db_user=root
#数据库密码
db_pass=passowrd

# 判断本地备份目录，不存在则创建
if [ ! -d $backup ] ; then
  	mkdir -p $backup
fi

cd $backup
rm -rf *

# 打包本地网站数据,这里用--exclude排除文件及无用的目录
if [ ! -f $web_save_name ] ; then
  	tar -zcPf $web_save_name $web_dir
fi

# 导出MySQL数据库
if [ ! -f $sql_save_name ] ; then
   mysqldump $db_name | gzip -9 - > $sql_save_name
fi

#上传到百度网盘 which bypy
/usr/local/bin/bypy upload -s 40960

exit 0

