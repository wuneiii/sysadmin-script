# opscript 

简介：linux环境，用bash实现的，基于机器列表文件的，linux命令批量执行工具脚本。
注意：脚本适合于：集群中有单台机器（且称为中控机或者操作人员机）和其他所有机器有ssh信任关系。脚本scp和ssh登录均依赖信任关系。

## 0. server.list 文件
机器列表文件保存所有服务器名称，和基于管理方便，人为给服务器对应的标签。
机器列表清单文件，格式如下。其中，机器全名，是可以ssh登录的机器名。tag* 可以自定义任意，是筛选的条件

机器全名 =  tag1 tag2 tag3

```bash
eac-cw20-a14.sina.com = all web idca 
eac-cw20-a15.sina.com = all web idca 
eac-cw20-a16.sina.com = all mysql idca 
eac-cw20-a17.sina.com = all mysql mysql-bak idca 

eab-cw20-abc.sina.com = all offline idcb
eab-cw20-aadf.sina.com = all offline idcb 
eab-cw20-aad.sina.com = all svn idcb

```

## 1.  lh
返回机器列表，可根据机器名中的关键字过滤机器列表
```bash
lh 
lh web
lh idca web
```
## 2.  go
ssh 到某一台机器上。区别于ssh的地方在于：
go 命令后跟机器名中的的关键字、标签，作为从机器列表中的筛选条件。如果，符合筛选条件的机器仅一台，则ssh上去；如果是多台，类似lh，返回机器列表
```bash
go mysql-bak
```

## 3. fsh
命令格式： fsh '机器列表' "bash 命令"
将按照机器列表顺序，逐一 ssh 登录服务器，执行 bash命令。单台执行完毕后，需要手动exit，自动进入下一台

```bash
fsh web 'uptime'
fsh all 'uptime'
fsh web '/sbin/nginx -s reload'
fsh `lh mysql` 'do something'
```

## 4. fcp
命令格式： fcp '机器列表' "本地文件或目录" "远端路径"
将按机器列表顺序，逐一 scp 本地文件或者目录，但服务器，只定的远端路径。单个机器完成后，自动scp下一台。


```bash
fsh web '/home/data/ip.txt' "/otp/nginx/config/"
fsh web '/home/data/ip.txt' "/otp/nginx/config/blockip.txt"

fsh all '/home/datadir1' "/tmp/"
```
## 5. cdop
