如何修改内核版本？
进入 Kernel build options
在当前的 Global build settings 子菜单中，直接选择：

Kernel build options --->
按 Enter 进入。

修改内核版本
进入后你会看到类似选项：

Kernel version (6.6.xx)  --->  # 选择或输入目标版本（如6.12）
如果支持6.12，直接选择对应版本。

如果没有6.12选项，说明当前OpenWrt分支未官方支持，需手动修改（见下文）。

保存并退出
按 Esc 返回上级菜单，选择 Save 保存配置。

如果菜单中没有6.12选项怎么办？
方法1：手动修改 .config 文件
打开 .config 文件：

bash
nano .config
找到并修改以下行：

ini
CONFIG_LINUX_6_6=y → CONFIG_LINUX_6_12=y
如果不存在，直接添加：

ini
CONFIG_LINUX_6_12=y
保存后运行：

bash
make defconfig  # 同步配置
方法2：通过命令强制切换
bash
sed -i 's/CONFIG_LINUX_6_6=y/CONFIG_LINUX_6_12=y/' .config
make defconfig
关键注意事项
清理旧编译文件
切换内核后必须清理：

bash
make target/linux/clean
检查内核兼容性

确认 target/linux/x86/patches-6.12 目录存在（x86平台需匹配你的架构）。

如果缺少补丁，需从OpenWrt官方更新源码或手动移植。

重新编译

bash
make -j$(nproc) V=s
验证是否成功
编译完成后检查：

bash
cat build_dir/target-*/linux-*/linux-*/Makefile | grep "VERSION ="
输出应类似：

VERSION = 6
PATCHLEVEL = 12
SUBLEVEL = 0
