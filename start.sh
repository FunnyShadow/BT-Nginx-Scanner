#!/bin/bash
#### BT 2022.12.3 Nginx Arbitrary Code Execution Vulnerability Scanner
#### Made By BlueFunny_

### Variables ###
## Files
bt="$1"
nginx="${bt:=/www}/server/nginx/sbin/nginx"
oldNginx="${bt}/server/nginx/sbin/nginxBak"
nginxMD5File="${bt}/server/panel/data/nginx_md5.pl"
virusFiles=(
    /var/tmp/count
    /var/tmp/count.txt
    /var/tmp/backkk
    /var/tmp/msglog.txt
    /var/tmp/systemd-private-56d86f7d8382402517f3b51625789161d2cb-chronyd.service-jP37av
    /tmp/systemd-private-56d86f7d8382402517f3b5-jP37av
)

## Language
if [ "$(locale -a | grep "zh_CN")" != "" ]; then
    zh=1
    export LANG="zh_CN.UTF-8"
else
    zh=0
fi

## Other
check=0
infection=0
nginxInfection=0
clean=""

### Tools ###
## Localize echo
LEcho() {
    case $1 in
    red)
        [ "${zh}" == 1 ] && printf '\033[1;31m%b\033[0m\n' "$2"
        [ "${zh}" == 0 ] && printf '\033[1;31m%b\033[0m\n' "$3"
        ;;
    green)
        [ "${zh}" == 1 ] && printf '\033[1;32m%b\033[0m\n' "$2"
        [ "${zh}" == 0 ] && printf '\033[1;32m%b\033[0m\n' "$3"
        ;;
    cyan)
        [ "${zh}" == 1 ] && printf '\033[1;36m%b\033[0m\n' "$2"
        [ "${zh}" == 0 ] && printf '\033[1;36m%b\033[0m\n' "$3"
        ;;
    cyan_n)
        [ "${zh}" == 1 ] && printf '\033[1;36m%b\033[0m' "$2"
        [ "${zh}" == 0 ] && printf '\033[1;36m%b\033[0m' "$3"
        ;;
    yellow)
        [ "${zh}" == 1 ] && printf '\033[1;33m%b\033[0m\n' "$2"
        [ "${zh}" == 0 ] && printf '\033[1;33m%b\033[0m\n' "$3"
        ;;
    error)
        Clean
        echo '================================================='
        [ "${zh}" == 1 ] && printf '\033[1;31;40m%b\033[0m\n' "$2"
        [ "${zh}" == 0 ] && printf '\033[1;31;40m%b\033[0m\n' "$3"
        echo '================================================='
        exit 1
        ;;
    *)
        [ "${zh}" == 1 ] && echo "$2"
        [ "${zh}" == 0 ] && echo "$3"
        ;;
    esac
    return
}

### Main ###
Copyright() {
    LEcho cyan "[-] BT 2022.12.3 Nginx 任意执行代码漏洞扫描工具" "[-] BT 2022.12.3 Nginx Arbitrary Code Execution Vulnerability Scanner"
    LEcho cyan "[-] Made By BlueFunny_" "[-] Made By BlueFunny_"
    LEcho cyan "[-] Version: 1.0" "[-] Version: 1.0"
    LEcho cyan "[-] Github: https://github.com/FunnyShadow/BT-Nginx-Scanner" "[-] Github: https://github.com/FunnyShadow/BT-Nginx-Scanner"
}
CheckBT() {
    LEcho echo "[-] 正在检测宝塔面板文件..." "[-] Checking BT panel files..."
    if [ ! -d "${bt}" ]; then
        LEcho yellow "[!] 未找到宝塔面板文件, 您可能不需要运行此脚本或者需要手动指定!" "[!] BT panel not found, you may not need to run this script or you need to specify it manually!"
        LEcho error "[-] 使用方法: $0 [宝塔面板目录]" "[-] Usage: $0 [BT panel directory]"
    fi
    return
}

CheckNginx() {
    LEcho echo "[-] 正在检测 Nginx 是否被感染..." "[-] Checking if Nginx is infected..."
    if [ ! -f "${nginx}" ]; then
        LEcho yellow "[!] 未找到Nginx, 跳过扫描!" "[!] Nginx not found, skipping scan!"
        return
    fi
    if [ -f ${nginxMD5File} ]; then
        if ! md5sum -c ${nginx} ${nginxMD5File}; then
            nginxInfection=1
        fi
    else
        [ "$(ls -l ${nginx} | awk '{print $5}')" == "4730568" ] && nginxInfection=1
    fi
    return
}

CheckVirusFiles() {
    LEcho echo "[-] 正在检测是否存在病毒文件..." "[-] Checking if there are virus files..."
    while true; do
        if [ -f "${virusFiles[$check]}" ]; then
            infection=1
            break
        fi
        check=$((check + 1))
        if [ "${check}" == "${#virusFiles[@]}" ]; then
            break
        fi
    done
    return
}

CheckInfection() {
    if [ "${infection}" == 1 ]; then
        LEcho yellow "[!] 检测到系统已经被感染, 是否尝试修复? (y/n)" "[!] System has been infected, do you want to try to fix it? (y/n)"
        LEcho yellow "[!] 请注意, 修复操作并非一定有效, 仅为缓解作用, 且不一定会成功!" "[!] Please note that the repair operation is not necessarily effective, only for temporary relief, and may not be successful!"
        read -rp 请输入选项: clean
        if [ "${clean}" == "y" ]; then
            Clean
        else
            LEcho red "[-] 已经扫描完毕, 已感染" "[-] Scan complete, infected"
        fi
    else
        LEcho green "[√] 已扫描完毕, 未感染!" "[√] Scan complete, not infected!"
    fi
    return
}

Clean() {
    if [ "${infection}" == 1 ]; then
        LEcho echo "[-] 正在关闭宝塔面板服务..." "[-] Shutting down BT panel service..."
        /etc/init.d/bt stop
        LEcho echo "[-] 正在清理感染文件..." "[-] Cleaning infected files..."
        rm -rf "${virusFiles[@]}"
        LEcho echo "[-] 正在尝试修复面板文件..." "[-] Trying to repair panel files..."
        /etc/init.d/bt 16
    fi
    if [ "${nginxInfection}" == 1 ]; then
        LEcho echo "[-] 正在关闭 Nginx 服务..." "[-] Shutting down Nginx service..."
        /etc/init.d/nginx stop
        if [ "$(pgrep nginx)" != "" ]; then
            LEcho echo "[-] Nginx 进程未关闭, 正在强制关闭..." "[-] Nginx process not closed, forcing closure..."
            killall -9 nginx
        fi
        if [ -f "${oldNginx}" ]; then
            LEcho echo "[-] 正在清理 Nginx 文件..." "[-] Cleaning Nginx files..."
            rm -rf "${nginx}"
            LEcho echo "[-] 正在尝试修复 Nginx 文件..." "[-] Trying to repair Nginx files..."
            mv -f "${oldNginx}" "${nginx}"
        else
            LEcho yellow "[!] 由于不存在旧版 Nginx 文件, 无法修复 Nginx 文件, 请手动修复!" "[!] Because there is no old version of Nginx file, Nginx file cannot be repaired, please repair manually!"
        fi
    fi
    LEcho green "[√] 尝试修复成功" "[√] Try to repair successfully"
    return
}

### Start ###
Copyright
CheckBT
CheckNginx
CheckVirusFiles
CheckInfection
exit 0
