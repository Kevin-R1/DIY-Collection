#!/bin/sh
# 增强版iStore安装脚本 - 自动多源依赖处理+GitHub加速
# 参考: https://github.com/linkease/istore

do_istore() {
    echo "╔════════════════════════════════════════╗"
    echo "║ iStore 增强版安装脚本                  ║"
    echo "║ 自动处理依赖+多源加速+网络故障转移     ║"
    echo "╚════════════════════════════════════════╝"

    # 定义全局变量
    export RETRY_COUNT=3
    export CONNECT_TIMEOUT=30
    export GH_MIRROR="https://github.namia.eu.org/"
    export FCURL="curl --fail --show-error --retry $RETRY_COUNT --connect-timeout $CONNECT_TIMEOUT"

    # 彩色输出定义
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    NC='\033[0m' # No Color

    # 检查并安装curl（带GitHub镜像加速）
    check_curl() {
        if ! command -v curl >/dev/null 2>&1; then
            echo -e "${YELLOW}正在安装curl...${NC}"
            
            # 尝试原始源安装
            opkg update >/dev/null 2>&1
            opkg install curl >/dev/null 2>&1 && return 0
            
            # 失败时尝试GitHub加速源
            echo -e "${YELLOW}通过GitHub镜像加速安装curl...${NC}"
            curl_pkg_url="${GH_MIRROR}Kevin-R1/Two-docker-agd/raw/main/packages/curl_7.86.0-2_x86_64.ipk"
            if $FCURL -o /tmp/curl.ipk "$curl_pkg_url"; then
                opkg install /tmp/curl.ipk && rm -f /tmp/curl.ipk && return 0
            fi
            
            echo -e "${RED}错误：无法安装curl，请检查网络连接${NC}"
            exit 1
        fi
    }

    # 多源下载函数（自动故障转移）
    smart_download() {
        local url=$1
        local output=$2
        local retries=$3
        
        # 尝试原始URL
        if $FCURL -o "$output" "$url"; then
            return 0
        fi
        
        # 失败时尝试GitHub镜像
        if [[ "$url" == *"github.com"* ]]; then
            local gh_mirror_url="${url/github.com/$GH_MIRROR}"
            echo -e "${YELLOW}尝试通过GitHub镜像下载: $gh_mirror_url${NC}"
            if $FCURL -o "$output" "$gh_mirror_url"; then
                return 0
            fi
        fi
        
        # 尝试国内镜像源替换
        if [[ "$url" == *"downloads.openwrt.org"* ]]; then
            local cn_url="${url/downloads.openwrt.org/mirrors.cernet.edu.cn/openwrt}"
            echo -e "${YELLOW}尝试通过国内镜像下载: $cn_url${NC}"
            if $FCURL -o "$output" "$cn_url"; then
                return 0
            fi
        fi
        
        return 1
    }

    # 从多源查找包（带缓存机制）
    find_package() {
        local pkg=$1
        echo -e "${GREEN}正在全网搜索包: $pkg${NC}"
        
        # 定义搜索源（按优先级排序）
        local search_sources=(
            "https://istore.istoreos.com/repo/all/store"
            "https://mirrors.cernet.edu.cn/openwrt/releases/22.03.7/packages/x86_64/base"
            "https://downloads.openwrt.org/releases/22.03.7/packages/x86_64/base"
            "${GH_MIRROR}coolsnowwolf/packages/raw/master/x86_64"
            "${GH_MIRROR}immortalwrt/packages/raw/master/x86_64"
        )
        
        for src in "${search_sources[@]}"; do
            echo -e "搜索源: ${YELLOW}$src${NC}"
            
            # 处理GitHub特殊路径
            if [[ "$src" == *"github.namia.eu.org"* ]]; then
                local packages_file="${src}/Packages"
            else
                local packages_file="${src}/Packages.gz"
            fi
            
            if smart_download "$packages_file" "/tmp/packages_temp" $RETRY_COUNT; then
                # 处理压缩包或普通文件
                if [[ "$packages_file" == *.gz ]]; then
                    zcat "/tmp/packages_temp" | grep -m1 "^Filename: .*/${pkg}[^/]*\.ipk$" && {
                        rm -f /tmp/packages_temp
                        local pkg_path=$(zcat "/tmp/packages_temp" | grep -m1 "^Filename: .*/${pkg}[^/]*\.ipk$" | awk '{print $2}')
                        echo "${src}/${pkg_path}"
                        return 0
                    }
                else
                    grep -m1 "^Filename: .*/${pkg}[^/]*\.ipk$" "/tmp/packages_temp" && {
                        rm -f /tmp/packages_temp
                        local pkg_path=$(grep -m1 "^Filename: .*/${pkg}[^/]*\.ipk$" "/tmp/packages_temp" | awk '{print $2}')
                        echo "${src}/${pkg_path}"
                        return 0
                    }
                fi
                rm -f /tmp/packages_temp
            fi
        done
        
        echo -e "${RED}错误：在所有源中找不到包 $pkg${NC}"
        return 1
    }

    # 安装核心依赖
    install_core_deps() {
        local core_deps=("luci-lib-taskd" "luci-lib-xterm" "taskd" "luci-compat")
        
        for dep in "${core_deps[@]}"; do
            if ! opkg list-installed | grep -q "^${dep} "; then
                echo -e "${GREEN}▶ 处理依赖: $dep${NC}"
                
                # 尝试官方源安装
                opkg install $dep >/dev/null 2>&1 && continue
                
                # 失败时从多源获取
                pkg_url=$(find_package "$dep")
                if [ $? -eq 0 ]; then
                    echo -e "${YELLOW}从备用源下载: $pkg_url${NC}"
                    if smart_download "$pkg_url" "/tmp/${dep}.ipk" $RETRY_COUNT; then
                        opkg install "/tmp/${dep}.ipk" || opkg install --force-depends "/tmp/${dep}.ipk"
                        rm -f "/tmp/${dep}.ipk"
                    else
                        echo -e "${RED}下载失败: $dep${NC}"
                    fi
                else
                    echo -e "${YELLOW}警告: 跳过不可用的依赖 $dep${NC}"
                fi
            fi
        done
    }

    # 主安装流程
    check_curl
    install_core_deps

    # 获取iStore主程序
    echo -e "${GREEN}🚀 正在获取iStore主程序...${NC}"
    ISTORE_REPO="https://istore.istoreos.com/repo/all/store"
    
    if ! smart_download "$ISTORE_REPO/Packages.gz" "/tmp/Packages.gz" $RETRY_COUNT; then
        echo -e "${RED}错误：无法下载Packages.gz${NC}"
        exit 1
    fi

    IPK=$(zcat /tmp/Packages.gz | grep -m1 '^Filename: luci-app-store.*\.ipk$' | sed -n -e 's/^Filename: \(.\+\)$/\1/p')
    [ -n "$IPK" ] || {
        echo -e "${RED}错误：无法解析iStore包信息${NC}"
        exit 1
    }

    # 安装iStore
    echo -e "${GREEN}🔧 正在安装iStore主程序...${NC}"
    if smart_download "$ISTORE_REPO/$IPK" "/tmp/istore.ipk" $RETRY_COUNT; then
        tar -xzOf "/tmp/istore.ipk" ./data.tar.gz | tar -xzO ./bin/is-opkg >/tmp/is-opkg
        chmod 755 /tmp/is-opkg
        
        # 使用is-opkg安装
        /tmp/is-opkg update
        /tmp/is-opkg install luci-app-store || {
            echo -e "${YELLOW}尝试强制安装iStore...${NC}"
            /tmp/is-opkg opkg install --force-depends luci-app-store
        }
    else
        echo -e "${RED}错误：iStore主程序下载失败${NC}"
        exit 1
    fi

    # 替换源地址
    echo -e "${GREEN}🔄 更新源地址...${NC}"
    for file in /bin/is-opkg /etc/opkg/compatfeeds.conf /www/luci-static/istore/index.js; do
        [ -f "$file" ] && sed -i 's/istore.linkease.com/istore.istoreos.com/g' "$file"
    done

    # 验证安装
    if [ -f "/usr/libexec/istorec/" ]; then
        echo -e "\n${GREEN}✔ iStore 安装成功！${NC}"
        echo -e "访问地址: http://$(uci get network.lan.ipaddr 2>/dev/null || echo '路由器IP')/cgi-bin/luci/app-store"
    else
        echo -e "\n${YELLOW}⚠ 安装完成但可能有部分组件未正确安装${NC}"
    fi
}

# 执行安装
do_istore