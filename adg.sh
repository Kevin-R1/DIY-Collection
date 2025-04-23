#!/bin/bash
# Build by Kevin-R1
# Modified to work without VPN dependency

# 颜色定义
RED='\e[91m'
GREEN='\e[92m'
YELLOW='\e[93m'
BLUE='\e[94m'
RESET='\e[0m'

# 默认容器路径
default_path() {
    save_path=/mnt/mmcblk2p4
    # 检查默认路径是否存在，不存在则使用当前目录
    [ ! -d "$save_path" ] && save_path=$PWD
}

# 检查Docker是否安装
check_docker() {
    if ! command -v docker &>/dev/null; then
        echo -e "${RED}未检测到Docker，请先安装Docker${RESET}"
        exit 1
    fi
}

# 检查Docker服务状态
check_docker_service() {
    if ! systemctl is-active --quiet docker; then
        echo -e "${YELLOW}Docker服务未运行，正在尝试启动...${RESET}"
        sudo systemctl start docker || {
            echo -e "${RED}启动Docker服务失败${RESET}"
            exit 1
        }
    fi
}

# 使用国内镜像源拉取ADG镜像
pull_adg_image() {
    local mirrors=(
        "docker.io/adguard/adguardhome:latest"
        "registry.cn-shanghai.aliyuncs.com/adguard/adguardhome:latest"
        "registry.cn-hangzhou.aliyuncs.com/adguard/adguardhome:latest"
    )
    
    for mirror in "${mirrors[@]}"; do
        echo -e "${BLUE}尝试从 ${mirror} 拉取镜像...${RESET}"
        if docker pull "$mirror"; then
            docker tag "$mirror" adguard/adguardhome:latest
            echo -e "${GREEN}镜像拉取成功${RESET}"
            return 0
        fi
    done
    
    echo -e "${RED}所有镜像源拉取失败，请检查网络连接${RESET}"
    exit 1
}

# 功能选择菜单
main_menu() {
    while true; do
        clear
        echo -e "${GREEN}=== AdGuard Home 管理脚本 ===${RESET}"
        echo "当前容器路径: ${BLUE}$save_path${RESET}"
        echo "1. 设置容器路径"
        echo "2. 管理工作目录"
        echo "3. 管理ADG容器"
        echo "0. 退出脚本"
        read -p "请输入选择 [0-3]: " choice

        case $choice in
            1) docker_path ;;
            2) manage_workspace ;;
            3) manage_container ;;
            0) echo -e "${GREEN}退出脚本${RESET}"; exit 0 ;;
            *) echo -e "${RED}无效输入${RESET}"; sleep 1 ;;
        esac
    done
}

# 设置容器路径
docker_path() {
    while true; do
        echo -e "\n${GREEN}当前容器路径: ${BLUE}$save_path${RESET}"
        df -h
        echo -e "\n0. 返回主菜单"
        echo "1. 使用当前路径 ($PWD)"
        echo "2. 自定义路径"
        read -p "请选择: " opt

        case $opt in
            0) return ;;
            1) 
                save_path=$PWD
                echo -e "${GREEN}已设置为当前路径${RESET}"
                return
                ;;
            2)
                read -p "请输入绝对路径: " custom_path
                if [ -d "$custom_path" ]; then
                    if [ -w "$custom_path" ]; then
                        save_path=$custom_path
                        echo -e "${GREEN}路径设置成功${RESET}"
                        return
                    else
                        echo -e "${RED}错误: 对路径 $custom_path 没有写入权限${RESET}"
                    fi
                else
                    echo -e "${RED}错误: 路径 $custom_path 不存在${RESET}"
                fi
                ;;
            *) echo -e "${RED}无效选择${RESET}" ;;
        esac
    done
}

# 创建工作目录
create_workspace() {
    local dir_num=$1
    local workdir="${save_path}/adg/workdir${dir_num}"
    local confdir="${save_path}/adg/confdir${dir_num}"
    
    mkdir -p "$workdir" "$confdir" || {
        echo -e "${RED}创建目录失败${RESET}"
        return 1
    }
    
    echo -e "${GREEN}工作目录创建成功:${RESET}"
    echo "工作目录: $workdir"
    echo "配置目录: $confdir"
    return 0
}

# 管理工作目录
manage_workspace() {
    while true; do
        echo -e "\n${GREEN}=== 工作目录管理 ===${RESET}"
        echo "1. 创建ADG工作目录"
        echo "2. 导出工作目录"
        echo "3. 删除工作目录"
        echo "0. 返回主菜单"
        read -p "请选择: " choice

        case $choice in
            0) return ;;
            1)
                read -p "输入要创建的目录编号 (1或2): " num
                if [[ "$num" =~ ^[12]$ ]]; then
                    create_workspace "$num"
                else
                    echo -e "${RED}无效编号，请输入1或2${RESET}"
                fi
                ;;
            2) export_workspace ;;
            3) delete_workspace ;;
            *) echo -e "${RED}无效选择${RESET}" ;;
        esac
    done
}

# 导出工作目录
export_workspace() {
    read -p "输入要导出的目录编号 (1或2): " num
    [[ ! "$num" =~ ^[12]$ ]] && {
        echo -e "${RED}无效编号${RESET}"
        return
    }

    local source_dir="${save_path}/adg"
    [ ! -d "$source_dir" ] && {
        echo -e "${RED}源目录不存在${RESET}"
        return
    }

    read -p "输入目标路径: " target_path
    [ ! -d "$target_path" ] && {
        echo -e "${RED}目标路径不存在${RESET}"
        return
    }

    echo -e "${YELLOW}正在导出目录...${RESET}"
    cp -r "${source_dir}/workdir${num}" "${source_dir}/confdir${num}" "$target_path/" && \
    echo -e "${GREEN}导出成功${RESET}" || \
    echo -e "${RED}导出失败${RESET}"
}

# 删除工作目录
delete_workspace() {
    read -p "输入要删除的目录编号 (1或2): " num
    [[ ! "$num" =~ ^[12]$ ]] && {
        echo -e "${RED}无效编号${RESET}"
        return
    }

    read -p "确定要删除目录${num}吗？这将永久删除配置数据 [y/N]: " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || return

    rm -rf "${save_path}/adg/workdir${num}" "${save_path}/adg/confdir${num}" && \
    echo -e "${GREEN}删除成功${RESET}" || \
    echo -e "${RED}删除失败${RESET}"
}

# 管理ADG容器
manage_container() {
    while true; do
        echo -e "\n${GREEN}=== ADG容器管理 ===${RESET}"
        echo "1. 创建ADG容器"
        echo "2. 更新ADG容器"
        echo "3. 查看容器状态"
        echo "4. 修改容器配置"
        echo "0. 返回主菜单"
        read -p "请选择: " choice

        case $choice in
            0) return ;;
            1) create_container ;;
            2) update_container ;;
            3) container_status ;;
            4) modify_container ;;
            *) echo -e "${RED}无效选择${RESET}" ;;
        esac
    done
}

# 创建ADG容器
create_container() {
    read -p "输入容器编号 (1或2): " num
    [[ ! "$num" =~ ^[12]$ ]] && {
        echo -e "${RED}无效编号${RESET}"
        return
    }

    check_docker
    check_docker_service
    pull_adg_image

    local workdir="${save_path}/adg/workdir${num}"
    local confdir="${save_path}/adg/confdir${num}"
    
    [ ! -d "$workdir" ] && {
        read -p "工作目录不存在，是否创建? [y/N]: " create
        [[ "$create" =~ ^[Yy]$ ]] || return
        create_workspace "$num" || return
    }

    docker run -d \
        --name "adguardhome${num}" \
        -v "${workdir}:/opt/adguardhome/work" \
        -v "${confdir}:/opt/adguardhome/conf" \
        --restart always \
        --net host \
        adguard/adguardhome:latest && \
    echo -e "${GREEN}容器创建成功${RESET}" || \
    echo -e "${RED}容器创建失败${RESET}"

    echo -e "\n${YELLOW}首次设置请访问: http://<你的IP>:3000${RESET}"
}

# 更新ADG容器
update_container() {
    read -p "输入要更新的容器编号 (1或2): " num
    [[ ! "$num" =~ ^[12]$ ]] && {
        echo -e "${RED}无效编号${RESET}"
        return
    }

    check_docker_service
    pull_adg_image

    docker stop "adguardhome${num}" 2>/dev/null
    docker rm "adguardhome${num}" 2>/dev/null

    create_container
}

# 容器状态管理
container_status() {
    read -p "输入容器编号 (1或2): " num
    [[ ! "$num" =~ ^[12]$ ]] && {
        echo -e "${RED}无效编号${RESET}"
        return
    }

    while true; do
        echo -e "\n${GREEN}容器 adguardhome${num} 状态${RESET}"
        echo "1. 查看状态"
        echo "2. 启动容器"
        echo "3. 停止容器"
        echo "4. 重启容器"
        echo "5. 查看日志"
        echo "0. 返回"
        read -p "请选择: " choice

        case $choice in
            0) return ;;
            1) docker ps -f "name=adguardhome${num}" ;;
            2) docker start "adguardhome${num}" ;;
            3) docker stop "adguardhome${num}" ;;
            4) docker restart "adguardhome${num}" ;;
            5) docker logs -f "adguardhome${num}" ;;
            *) echo -e "${RED}无效选择${RESET}" ;;
        esac
    done
}

# 修改容器配置
modify_container() {
    read -p "输入容器编号 (1或2): " num
    [[ ! "$num" =~ ^[12]$ ]] && {
        echo -e "${RED}无效编号${RESET}"
        return
    }

    local conf_file="${save_path}/adg/confdir${num}/AdGuardHome.yaml"
    [ ! -f "$conf_file" ] && {
        echo -e "${RED}配置文件不存在${RESET}"
        return
    }

    while true; do
        echo -e "\n${GREEN}当前配置:${RESET}"
        grep -E "bind_port:|port:" "$conf_file"
        echo -e "\n1. 修改管理端口"
        echo "2. 修改DNS端口"
        echo "0. 返回"
        read -p "请选择: " choice

        case $choice in
            0) return ;;
            1)
                read -p "输入新管理端口 (3000-65535): " port
                [[ "$port" =~ ^[0-9]+$ ]] && (( port >= 3000 && port <= 65535 )) || {
                    echo -e "${RED}无效端口号${RESET}"
                    continue
                }
                sed -i "s/bind_port: .*/bind_port: ${port}/" "$conf_file"
                echo -e "${GREEN}管理端口已修改，需要重启容器生效${RESET}"
                ;;
            2)
                read -p "输入新DNS端口 (53或其他): " port
                [[ "$port" =~ ^[0-9]+$ ]] && (( port >= 1 && port <= 65535 )) || {
                    echo -e "${RED}无效端口号${RESET}"
                    continue
                }
                sed -i "s/port: .*/port: ${port}/" "$conf_file"
                echo -e "${GREEN}DNS端口已修改，需要重启容器生效${RESET}"
                ;;
            *) echo -e "${RED}无效选择${RESET}" ;;
        esac
    done
}

# 初始化
default_path
check_docker
main_menu