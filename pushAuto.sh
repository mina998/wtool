#！/bin/bash

#数据库名
db_name=wp
#数据库用户名
db_user=wp
#数据库密码
db_pass=wp
#数据库导出加密字符串
encrypt=mina998
#网站绝对路径
webpath=/www/wwwroot/www.xxx.com/
#切换目录
cd $webpath
#删除数据文件
if [ -f db.zip ]; then
	rm db.zip
fi
#导出MySQL数据
mysqldump -u$db_user -p$db_pass $db_name > $db_name.sql
#加密打包文件 需要安装zip unzip
zip -P $encrypt db.zip $db_name.sql
#删除原文件
rm $db_name.sql
git add .
git commit -m "$(date +%Y-%m-%d %H%M%S)"
git push origin master

#解密命令 unzip -P 密码 要解密的文件.zip
