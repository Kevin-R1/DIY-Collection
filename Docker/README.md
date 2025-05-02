# 不滥用随意用


## Docker镜像加速命令📦
##使用方法
- 直接复制粘贴
- Linux 系统，推荐 Debian 或 Ubuntu LTS，NAS比如飞牛os都行
- 运行整个代码，如果第一遍运行输入密码后没有更改直接舍弃sudo mkdir -p /etc/docker
- 以sudo tee /etc/docker/daemon.json <<-'EOF'这行的所有代码复制使用
```
sudo mkdir -p /etc/docker

sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://docker.namia.eu.org"]  
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```
