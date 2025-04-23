#!/bin/sh

# 参数处理
if [ "$1" = "--install-luci-app-store" ]; then
    INSTALL_LUCI_APP_STORE=1
fi

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

# 安装luci-app-store
install_luci_app_store() {
    echo "正在直接安装 luci-app-store..."
    
    # 安装依赖
    install_deps || return 1
    
    # 获取IPK信息
    echo "正在获取软件包信息..."
    IPK=$(safe_curl "$ISTORE_REPO/Packages.gz" | zcat | grep -m1 '^Filename: luci-app-store.*\.ipk$' | sed -n -e 's/^Filename: \(.\+\)$/\1/p')
    
    [ -n "$IPK" ] || {
        echo "尝试从备用源获取..."
        IPK=$(safe_curl "$ISTORE_REPO_BACKUP/Packages.gz" | zcat | grep -m1 '^Filename: luci-app-store.*\.ipk$' | sed -n -e 's/^Filename: \(.\+\)$/\1/p')
        [ -n "$IPK" ] || {
            echo "无法获取软件包信息，请检查网络连接"
            return 1
        }
    }
    
    # 下载并安装
    echo "正在下载并安装 luci-app-store..."
    safe_curl "$ISTORE_REPO/$IPK" > /tmp/luci-app-store.ipk || {
        echo "尝试从备用源下载..."
        safe_curl "$ISTORE_REPO_BACKUP/$IPK" > /tmp/luci-app-store.ipk || {
            echo "下载失败，请检查网络连接"
            return 1
        }
    }
    
    opkg install /tmp/luci-app-store.ipk || {
        echo "安装失败"
        return 1
    }
    
    rm -f /tmp/luci-app-store.ipk
    echo "luci-app-store 安装成功！"
    return 0
}

# 主安装函数
do_istore() {
    if [ "$INSTALL_LUCI_APP_STORE" = "1" ]; then
        install_luci_app_store
        return $?
    fi
    
    echo "开始安装iStore..."
    # 原有安装逻辑...
    # ... (保持原来的do_istore函数内容不变)
}

# 执行安装
do_istore || {
    echo "安装过程中出现错误"
    exit 1
}

exit 0