# opscript 命令简介

## 0. server.list 文件
机器列表清单，格式如下。其中，机器全名，是可以ssh登录的机器名。tag* 可以自定义任意，是筛选的条件

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
顺序ssh到列表上，执行 bash命令。单台执行完毕后，需要手动exit，自动进入下一台

```bash
fsh web 'uptime'
fsh all 'uptime'
fsh web '/sbin/nginx -s reload'
fsh `lh mysql` 'do something'
```

## 4. fcp

## 5. cdop
