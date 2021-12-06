#!/bin/bash

#crontab -e
#设置用户名和令牌,自动提交不需要手动输入 user为github帐号 pwd为token
#git remote set-url origin https://user:pwd@github.com/mina998/test.git

#设置本地仓库路径
repo=/repo_path/
#站点路径
site=/site_path/
#远程分支
branch=master
#加解密字符串
code=mina998
#导出数据库名称
dbname=wordpressdb2
#数据库用户名, 如果不设置用户名和密码, 将用root用户空密码操作
dbuser=root
#数据库密码
dbpass=root

cd $repo && rm -rf * && cp -r $site/* ./

#如果没有设置MySQL用户名,就用root用户导出数据库,否则以指定用户导出
if [ -z $dbuser ]; then
	mysqldump $dbname | gzip -9 - > $dbname.sql.gz
else
	mysqldump -u$dbuser -p$dbpass $dbname | gzip -9 - > $dbname.sql.gz
fi

#把指定的文件移动到db目录
mkdir db && mv $dbname.sql.gz wp-config.php ./db/
#加密打包文件夹
tar -zcf - db/ --remove-files|openssl des3 -salt -k $code | dd of=db.des3

git add .
git commit -m "$(date +%Y-%m-%d %H%M%S)"
git push origin $branch
