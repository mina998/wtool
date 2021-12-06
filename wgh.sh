#!/bin/bash

# 安装Socat
if [ ! -x /usr/bin/git ] ; then 
	apt update
	apt install git
	git config --global user.name "username" 	#设置用户
	git config --global user.email "user@email.com" #设置邮箱
fi

#接收站点路径
sitef(){
	read -p "请输入站点路径,以/结尾(默认: /usr/local/lsws/wordpress/):" site
	if [ -z $site ];then
		site=/usr/local/lsws/wordpress/
	fi
}
#接收GitHub仓库地址
repof(){
	read -p "请输入仓库地址(示例: https://github.com/mina998/test.git):" repo
	if [ -z "${repo}" ];then
		repof
	fi
}
#接收加解密字符
encode(){
	read -p "请输入加解密字符(默认: mina998):" pass
	if [ -z "${pass}" ];then
		pass=mina998
	fi
}
#接收MySQL数据库信息
dbinfo(){
	read -p "请输入数据库名称:" dbname
	read -p "请输入数据库用户名:" dbuser

	if [ -z $dbname ]; then
		dbinfo
	fi
}

# 上传
action1(){
	#设置操作目录
	backup=backup2
	#目录是否存在
	if [ -d $backup ]; then
		echo "操作目录已存在,请删除!"
		exit 0
	fi
	#获取站点路径
	sitef
	#拷贝站点并删除指定文件
	cp -r $site $backup && cd $backup && rm -rf .git
	#获取MySQL信息
	dbinfo
	#如果没有接收到MySQL用户名,就用root用户导出数据库,否则以指定用户导出
	if [ -z $dbuser ]; then
		mysqldump $dbname | gzip -9 - > $dbname.sql.gz
	else
		echo "以下需要输入MySQL密码"
		mysqldump -u$dbuser -p $dbname | gzip -9 - > $dbname.sql.gz
	fi
	#把指定的文件移动到db目录
	mkdir db && mv $dbname.sql.gz wp-config.php ./db/
	#获取加密字符串
	encode
	#加密打包文件夹
	tar -zcf - db/ --remove-files|openssl des3 -salt -k $pass | dd of=db.des3
	#获取仓库地址
	repof
	#初始化一个本地仓库
	git init
	git add .
	git commit -m "$(date +%Y-%m-%d)"
	#分支重命名
	git branch -M master
	#把本地仓库和远程仓库关联
	git remote add origin $repo
	echo "以下需要输入GitHub用户名和密码(为ToKen)"
	#把分支推送到远程仓库
	git push -u origin master --force	
}

action2(){
	#获取站点路径
	sitef
	#判断路径并创建
	if [ ! -d $site ] ; then
	  	mkdir -p $site
	fi
	#进入站点目录
	cd $site
	#获取远程仓库地址
	repof
	#获取指定提交ID
	read -p "请输入要拉取指定提交ID(例:2ef3fb1), 如果留空将拉取最新代码:" rcid
	if [ -z "${rcid}" ];then
	#拉取最新代码
		git clone --depth=1 $repo site
		if [ ! -d site ];then
			echo "拉取代码失败,退出"
			exit 0
		fi
		mv ./site/* ./
		mv ./site/.htaccess ./
		rm -rf site
	else
	#拉取指定 提交id 或 分支 代码
		git init
		git remote add origin $repo
		git fetch --all
		git reset --hard $rcid
		rm -rf .git
	fi
	#加密文件是否存在
	if [ ! -f db.des3 ];then
		echo "数据文件不存在, 退出"
		exit 0
	fi
	#获取解密字符串
	encode
	#解密文件
	dd if=db.des3 |openssl des3 -d -k $pass |tar zxf -
	#是否解密成功
	if [ ! -d db ];then
		echo "解密字符串不正确, 退出"
		exit 0
	fi
	#移动文件到指定位置
	mv db/wp-config.php ./
	#解压数据库备份文件
	gzip -d ./db/*.sql.gz
	#查看
	ls db
	#获取数据库备份文件
	read -p "请输入数据文件:" tables
	#获取MySQL信息
	dbinfo
	echo "以下需要输入MySQL密码"
	#把数据导入到指定数据库
	mysql -u$dbuser -p $dbname < ${site}db/${tables}
	rm -rf db db.des3
	
	chown -R nobody:nogroup $site		 #设置文件目录所有者
	find $site -type d -exec chmod 750 {} \; #目录权限
	find $site -type f -exec chmod 640 {} \; #文件权限
}

menu(){
	echo "上传到Github(1)  下载还原到本地(2)"
	read -p "请选择:" num
	if [ $num -eq 1 ]; then
		action1
	else
		action2
	fi
}
menu

