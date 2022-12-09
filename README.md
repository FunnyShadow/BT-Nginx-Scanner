  # BT-Nginx-Scanner
一个简单的扫描与清理工具, 用于解决 2022.12.3 被爆出的 BT Nginx 任意代码执行漏洞

## 脚本使用方法

你可以直接运行下面的命令运行此脚本

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/FunnyShadow/BT-Nginx-Scanner/main/start.sh)
# 国内用户可尝试下面的命令
bash <(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/FunnyShadow/BT-Nginx-Scanner/main/start.sh)
```

或使用 [GitHub Releases](https://github.com/FunnyShadow/BT-Nginx-Scanner/releases) 中利用 shc 工具打包制作的二进制版本



## 漏洞相关分析
#### 问题概述
宝塔系 Nginx/Apache 均出现严重漏洞

#### 漏洞效果
1. 可直接获取系统最高权限

2. 可执行任意命令

3. 可直接修改Nginx配置文件

4. 可直接修改数据库

#### 特征
1. `/<宝塔安装目录>/server/nginx/sbin/nginx` 文件大小变为 4.51MB (其他均不算)

2. 存在以下任一文件（可能全部存在）

- /var/tmp/count

- /var/tmp/count.txt

- /var/tmp/backkk

- /var/tmp/msglog.txt

- /var/tmp/systemd-private-56d86f7d8382402517f3b51625789161d2cb-chronyd.service-jP37av

- /tmp/systemd-private-56d86f7d8382402517f3b5-jP37av

3. 使用无痕模式访问目标网站的js文件，内容中包含: _0xd4d9 或 _0x2551 关键词的

4. *(可能)* 服务器被种挖矿木马

5. 此木马是随机性木马, 随机触发

6. 面板日志/系统日志都被清空过的

#### 建议
1. 使用非默认端口号

2. 暂时关闭面板 (直接防火墙封堵端口或暂停面板服务) 或 升级至最新版并修复面板

3. 暂时关闭Nginx 或 升级至最新版 (已经升级的可以尝试卸载重装)

4. 开启面板 BA 验证

5. 开启面板 IP 授权验证

#### 相关帖子
官方公告: https://www.bt.cn/bbs/thread-105121-1-1.html

#### 附言
现已确定, `/<宝塔安装目录>/server/nginx/sbin/nginxBak` 文件为宝塔升级回退文件, 如已中招, 可以尝试使用此文件恢复至升级前的版本

## 协议
本项目采用 GPL 3.0 进行开源
