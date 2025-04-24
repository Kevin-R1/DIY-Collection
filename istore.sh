#!/bin/sh

# 交互式安装 iStore
install_istore() {
    # 禁用代理（确保直连）
    unset http_proxy https_proxy all_proxy

    # 定义颜色
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color

    # 欢迎信息
    echo -e "${YELLOW}\n=== iStore 交互式安装脚本 ===${NC}"
    echo -e "当前系统：$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
    echo -e "硬件架构：$(uname -m)\n"

    # 步骤1：检查网络
    check_network() {
        echo -e "${GREEN}[1/4] 正在检查网络连接...${NC}"
        if ! ping -c 1 istore.istoreos.com >/dev/null 2>&1; then
            echo -e "${RED}错误：无法连接 iStore 源服务器${NC}"
            echo -e "尝试使用国内镜像..."
            ISTORE_REPO="https://istore.linkease.com/repo/all/store"
        else
            ISTORE_REPO="https://istore.istoreos.com/repo/all/store"
        fi
        echo -e "使用源：${YELLOW}$ISTORE_REPO${NC}"
    }

    # 步骤2：安装依赖
    install_deps() {
        echo -e "\n${GREEN}[2/4] 正在检查依赖...${NC}"
        for pkg in curl wget tar; do
            if ! command -v $pkg >/dev/null; then
                echo -e "正在安装 $pkg..."
                opkg update >/dev/null 2>&1
                opkg install $pkg || {
                    echo -e "${RED}安装 $pkg 失败！${NC}"
                    exit 1
                }
            fi
        done
    }

    # 步骤3：下载安装
    download_install() {
        echo -e "\n${GREEN}[3/4] 正在获取安装脚本...${NC}"
        SCRIPT_URL="https://raw.githubusercontent.com/Kevin-R1/Two-docker-agd/main/istore.sh"
        
        # 尝试多种下载方式
        if command -v curl >/dev/null; then
            curl -fsSL $SCRIPT_URL | sh -s -- $ISTORE_REPO
        elif command -v wget >/dev/null; then
            wget -O - $SCRIPT_URL | sh -s -- $ISTORE_REPO
        else
            echo -e "${RED}错误：需要 curl 或 wget${NC}"
            exit 1
        fi
    }

    # 步骤4：验证安装
    verify_install() {
        echo -e "\n${GREEN}[4/4] 验证安装...${NC}"
        if opkg list-installed | grep -q luci-app-store; then
            echo -e "${GREEN}✓ iStore 安装成功！${NC}"
            echo -e "访问方式："
            echo -e "1. 打开浏览器访问 ${YELLOW}http://$(uci get network.lan.ipaddr 2>/dev/null || echo '192.168.1.1')${NC}"
            echo -e "2. 在菜单中找到 ${GREEN}iStore${NC} 选项"
        else
            echo -e "${RED}安装失败，请检查日志${NC}"
            exit 1
        fi
    }

    # 执行安装流程
    check_network
    install_deps
    download_install
    verify_install
}

# 用户确认
echo -n "是否开始安装 iStore？ [y/N] "
read answer
case $answer in
    [Yy]* ) install_istore;;
    * ) echo "安装已取消"; exit 0;;
esac