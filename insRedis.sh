#!/usr/bin/env bash
cat << EOF


+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
REQUIRED:     centOS-6 (Defulte 64bit)
DESCRIPTION:  Install Redis in CentOS
SOFTVERSION:    Redis-2.8.23
AUTHOR:       Yangzhiquan
REVISION:     1.2
++++++++++++++++++++++++++++++++++++++++++++++++++++++++


EOF
usage="\033[31mUsage: $0 [install]\033[0m"

redis_port=6379

base_dir=/app/local/redis


path_test(){
    #检查redis目录是否存在,$1:baseDir
    echo "开始检测目录"
    for dir in $1
    do
        if [ -d $dir ];then
            echo -e "\033[31mError:${dir}目录已存在,请先确认次目录是否已安装redis,如果没有安装,请手动删除此目录,并重新运行此程序!\033[0m"
            exit 0
        else
            mkdir -p ${dir}
            echo "${dir}目录已创建完成!"
        fi
    done
}

port_test(){
    #检查端口号是否占用,$1:Port
    port_nu=` netstat -ntlp | grep ${1} |wc -l`
    if [ $port_nu -gt 0 ]; then
        echo -e "\033[31mError: 安装程序已退出，mongodb port 被占用,请确认该端口号\033[0m"
        exit 0
    fi
}

develop_install(){
    #安装基础开发环境
    yum -y install gcc-c++ wget dos2unix
    echo "基础开发环境已安装完成!"
}


get_soft(){
    #软件下载
    if [ ! -e redis-2.8.23.tar ]; then
        echo "开始下载redis-2.8.23.tar"
        wget http://oms.2144gy.com:810/upfiles/soft/redis-2.8.23.tar
        echo "软件下载成功，开始解压配置"
    fi
}

Install(){
    #解压安装redis $1:baseDir
    echo "开始解压软件."
    tar xvf redis-2.8.23.tar
    echo "解压已完成。"
    cd redis-2.8.23
    make
    echo "编译已完成,开始配置软件"
    mkdir ${1}/bin ${1}/log ${1}/data
    cp -rf src/redis-server ${1}/bin
    cp -rf src/redis-benchmark ${1}/bin
    cp -rf src/redis-cli ${1}/bin
    cp -rf src/redis-check-aof ${1}/bin
    cp -rf src/redis-check-dump ${1}/bin
    echo "软件配置已完成."
}

config(){
    #开始修改配置文件,$1:baseDir
    echo "开始修改配置redis.conf"
    wget -P ./redis_tmp/ http://oms.2144gy.com:810/upfiles/soft/config/redis/redis.conf
    cp -rf ./redis_tmp/redis.conf ${1}
    chown -R root.root ${1}
    echo "redis.conf配置文件修改完成!"
    echo export PATH=\$PATH:${1}/bin >/etc/profile.d/redis.sh
    source /etc/profile
    echo "redis加入环境变量已完成"
}

edit_start_file(){
    #编辑开机启动文件,
    echo "开始导入开机启动文件############################"
    wget -P ./redis_tmp/ http://oms.2144gy.com:810/upfiles/soft/config/redis/redis
    dos2unix ./redis_tmp/redis
    cp -rf ./redis_tmp/redis /etc/init.d/
    rm -rf ./redis_tmp/
    chmod 755 /etc/init.d/redis
    chkconfig --add redis
    echo "redis已加入开机启动"
}

start(){
    ${1}/bin/redis-server  ${1}/redis.conf
    echo -e "\033[31m安装已全部完成,请执行下面的语句刷新环境变量\033[0m"
    echo "source /etc/profile"
}

case $1 in
    install)
        path_test ${base_dir}
        port_test ${redis_port}
        develop_install
        get_soft
        Install ${base_dir}
        config ${base_dir}
        edit_start_file
        start ${base_dir}
        ;;
    *)
       echo -e $usage
       exit 0
       ;;
esac
