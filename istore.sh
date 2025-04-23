cat > /tmp/install_istore.sh << "EOF"
#!/bin/sh
# 安装iStore 参考 https://github.com/linkease/istore
do_istore() {
    echo "do_istore method==================>"
    # 换源
    ISTORE_REPO=https://istore.istoreos.com/repo/all/store
    FCURL="curl --fail --show-error"

    # 绕过代理（如果需要）
    export http_proxy=""
    export https_proxy=""

    # 检查并安装curl
    curl -V >/dev/null 2>&1 || {
        echo "prereq: install curl"
        opkg info curl | grep -Fqm1 curl || opkg update
        opkg install curl || exit 1
    }

    # 获取最新的iStore IPK包
    IPK=$($FCURL "$ISTORE_REPO/Packages.gz" | zcat | grep -m1 '^Filename: luci-app-store.*\.ipk$' | sed -n -e 's/^Filename: \(.\+\)$/\1/p')

    [ -n "$IPK" ] || {
        echo "Failed to get iStore IPK filename."
        exit 1
    }

    # 下载并安装iStore
    $FCURL "$ISTORE_REPO/$IPK" | tar -xzO ./data.tar.gz | tar -xzO ./bin/is-opkg >/tmp/is-opkg

    [ -s "/tmp/is-opkg" ] || {
        echo "Failed to extract is-opkg."
        exit 1
    }

    chmod 755 /tmp/is-opkg
    /tmp/is-opkg update || exit 1
    /tmp/is-opkg opkg install --force-reinstall luci-lib-taskd luci-lib-xterm || exit 1
    /tmp/is-opkg opkg install --force-reinstall luci-app-store || exit 1
    [ -s "/etc/init.d/tasks" ] || /tmp/is-opkg opkg install --force-reinstall taskd || exit 1
    [ -s "/usr/lib/lua/luci/cbi.lua" ] || /tmp/is-opkg opkg install luci-compat >/dev/null 2>&1

    # 换源
    sed -i 's/istore.linkease.com/istore.istoreos.com/g' /bin/is-opkg
    sed -i 's/istore.linkease.com/istore.istoreos.com/g' /etc/opkg/compatfeeds.conf
    sed -i 's/istore.linkease.com/istore.istoreos.com/g' /www/luci-static/istore/index.js

    # 清理临时文件
    rm -f /tmp/is-opkg
}

do_istore
EOF