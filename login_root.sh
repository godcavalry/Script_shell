#!/usr/bin/env bash
#控制是否允许root通过ssh登录,

usage="Usage: login_root.sh [root_on|root_off|password_on|password_off]"

root_off(){
    #关闭root通过ssh登录
    sed -i "s/^#PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
    sed -i "s/^PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
    service sshd restart
    echo "root登录已关闭"
}

root_on(){
    #允许root通过ssh登录
    sed -i "s/^PermitRootLogin.*/#PermitRootLogin no/g" /etc/ssh/sshd_config
    echo "root登录已开启"
    service sshd restart
}

password_off(){
    #关闭密码认证
    sed -i "s/^PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config
    service sshd restart
    echo "密码认证已关闭"
}

password_on(){
    #开启密码认证
    sed -i "s/^PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
    service sshd restart
    echo "密码认证已开启"
}
case $1 in
    root_on)
        root_on
        ;;
    root_off)
        root_off
        ;;
    password_on)
        password_on
        ;;
    password_off)
        password_off
        ;;
    *)
        echo $usage
        exit 1
        ;;
esac
