#!/bin/sh

# 使用国内镜像源
ISTORE_REPO="https://cdn.jsdelivr.net/gh/linkease/istore@main/repo/all/store"
# 备用源
ISTORE_REPO_BACKUP="https://istore.istoreos.com/repo/all/store"

# 最大重试次数
MAX_RETRY=3

# 带重试的curl下载
safe_curl() {
    local url=$1
    local retry=0
    local success=0
    
    while [ $retry -lt $MAX_RETRY ]; do
        if curl --fail --show-error --connect-timeout 20 --retry 3 "$url" 2>/dev/null; then
            success=1
            break
        fi
        
        echo "下载失败，正在重试 ($((retry+1))/$MAX_RETRY)..."
        retry=$((retry+1))
        sleep 3
    done
    
    [ $success -eq 1 ] || return 1
}

# 安装必要依赖
install_deps() {
    echo "正在检查并安装必要依赖..."
    
    # 检查并安装curl
    if ! command -v curl >/dev/null; then
        echo "正在安装curl..."
        opkg update >/dev/null 2>&1
        opkg install curl >/dev/null 2>&1 || {
            echo "无法安装curl，请检查网络连接"
            return 1
        }
    fi
    
    # 检查并安装zcat
    if ! command -v zcat >/dev/null; then
        echo "正在安装zcat..."
        opkg update >/dev/null 2>&1
        opkg install zlib-bin >/dev/null 2>&1 || {
            echo "无法安装zcat，请检查网络连接"
            return 1
        }
    fi
    
    return 0
}

# 主安装函数
do_istore() {
    echo "开始安装iStore..."
    
    # 安装依赖
    install_deps || return 1
    
    # 尝试从主源获取IPK信息
    echo "正在获取软件包信息..."
    IPK=$(safe_curl "$ISTORE_REPO/Packages.gz" | zcat | grep -m1 '^Filename: luci-app-store.*\.ipk$' | sed -n -e 's/^Filename: \(.\+\)$/\1/p')
    
    # 如果主源失败，尝试备用源
    if [ -z "$IPK" ]; then
        echo "主源不可用，尝试备用源..."
        IPK=$(safe_curl "$ISTORE_REPO_BACKUP/Packages.gz" | zcat | grep -m1 '^Filename: luci-app-store.*\.ipk$' | sed -n -e 's/^Filename: \(.\+\)$/\1/p')
        [ -n "$IPK" ] || {
            echo "无法获取软件包信息，请检查网络连接"
            return 1
        }
    fi
    
    # 下载并提取IPK
    echo "正在下载iStore主程序..."
    if ! safe_curl "$ISTORE_REPO/$IPK" >/tmp/istore.ipk 2>/dev/null; then
        echo "尝试从备用源下载..."
        if ! safe_curl "$ISTORE_REPO_BACKUP/$IPK" >/tmp/istore.ipk 2>/dev/null; then
            echo "下载失败，请检查网络连接"
            return 1
        fi
    fi
    
    # 提取is-opkg工具
    echo "正在安装iStore..."
    tar -xzOf /tmp/istore.ipk ./data.tar.gz | tar -xzO ./bin/is-opkg >/tmp/is-opkg
    
    if [ ! -s "/tmp/is-opkg" ]; then
        echo "提取安装工具失败"
        return 1
    fi
    
    chmod 755 /tmp/is-opkg
    
    # 安装组件
    /tmp/is-opkg update >/dev/null 2>&1
    /tmp/is-opkg opkg install --force-reinstall luci-lib-taskd luci-lib-xterm >/dev/null 2>&1 || {
        echo "安装依赖组件失败"
        return 1
    }
    
    /tmp/is-opkg opkg install --force-reinstall luci-app-store >/dev/null 2>&1 || {
        echo "安装主程序失败"
        return 1
    }
    
    [ -s "/etc/init.d/tasks" ] || /tmp/is-opkg opkg install --force-reinstall taskd >/dev/null 2>&1
    [ -s "/usr/lib/lua/luci/cbi.lua" ] || /tmp/is-opkg opkg install luci-compat >/dev/null 2>&1
    
    # 替换为国内源
    echo "配置国内镜像源..."
    sed -i 's/istore.linkease.com/istore.istoreos.com/g' /bin/is-opkg >/dev/null 2>&1
    sed -i 's/istore.linkease.com/istore.istoreos.com/g' /etc/opkg/compatfeeds.conf >/dev/null 2>&1
    sed -i 's/istore.linkease.com/istore.istoreos.com/g' /www/luci-static/istore/index.js >/dev/null 2>&1
    
    # 清理临时文件
    rm -f /tmp/istore.ipk /tmp/is-opkg
    
    echo "iStore安装完成！"
    echo "请访问路由器Web界面的'服务'菜单中的'iStore'"
    return 0
}

# 执行安装
do_istore || {
    echo "安装过程中出现错误"
    exit 1
}

exit 0
