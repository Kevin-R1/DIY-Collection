# AdGuardHome 双模式部署指南
## 附赠[`国内外广告部分拦截黑名单和白名单`](https://raw.githubusercontent.com/Kevin-R1/Two-docker-agd/refs/heads/main/AdGuard%E6%A8%A1%E6%9D%BF/%E5%B9%BF%E5%91%8A%E6%8B%A6%E6%88%AA%E9%BB%91%E5%90%8D%E5%8D%95.txt)
## 📦 方案选择
![img.png](img/tp.png)
### 方案1：固件内置版
- 使用固件自带AdGuardHome
- 直接粘贴 AdGuardHome-cn.yaml 内容到模板
- 重启服务生效
- 保持默认DNS服务端口（如53）或者通过Web界面（IP：3000端口）更改监听
- 博主模板已通过Web更改固件自带AdGuardHome:3000管理端口为8551,Docker为8552监听固件自带8553,Docker为8554进行管理界面 ![img.png](img/3.png)
#### 优势：  
- 系统深度集成  
- 低资源消耗  
- 一键配置生效
### 方案2：Docker版部署（推荐隔离环境）NAS等其他带Docker的直接用下面通用
- 准备步骤
- SSH给Docker固件创建文件夹
```
mkdir -p /mnt/mmcblk2p4/adg
```
- 容器部署命令.
- N1部署直接用
```
wget https://raw.githubusercontent.com/Kevin-R1/Two-docker-agd/main/adg.sh && sh adg.sh
```
- 二次运行脚本进入交互菜单
```
. adg.sh
```

关键配置说明
- 端口映射
- 管理界面：3000→3001（避免冲突）
- NAS等其他服务期带Docker的
- ![img.png](img/2.png)
- 监听服务：53→54.8553等（需调整上游DNS设置并不局限随意改只要不冲突）
性能优化
- 启用DNS缓存
- 建议查询日志保留24小时
- 国内用户推荐使用自己更改或者复制博主的AdGuardHome-cn.yaml模板的优化规则
- - ![img.png](img/1.png)
- 国内外用户文件夹找到 /mnt/mmcblk2p4/adg/confdir1，如果没有就Docker部署创建并且上传AdGuardHome.yaml到confdir1此为docker版本配置的yaml文件上传路径


# OpenWrt
luci-app-mosdns：需代理！
```
sh -c "$(curl -ksS https://raw.githubusercontent.com/Kevin-R1/Two-docker-agd/main/luci-app-mosdns.sh)"
```
商店 [`悟空的日常`]( https://github.com/wukongdaily)
- SSH链接安装iStore商店 (ARM64 & x86-64通用)
```
wget -qO imm.sh https://cafe.cpolar.top/wkdaily/zero3/raw/branch/main/zero3/imm.sh && chmod +x imm.sh && ./imm.sh
```
# Linux二款管理脚本合集需代理！
## 推荐家用Linux工具箱 [`kejilion`]( https://github.com/kejilion/sh)
### 首次运行
```
curl -sS -O https://raw.githubusercontent.com/kejilion/sh/refs/heads/main/cn/kejilion.sh && chmod +x kejilion.sh && ./kejilion.sh
```
### 二次运行SSH
```
sudo -i
K
```
# VPS节点工具箱 [`eooce`]( https://github.com/eooce/ssh_tool) 
## 首次运行
```
curl -fsSL https://raw.githubusercontent.com/eooce/ssh_tool/main/ssh_tool.sh -o ssh_tool.sh && chmod +x ssh_tool.sh && ./ssh_tool.sh
```
### 二次运行SSH
```
sudo -i
./ssh_tool.sh
```



