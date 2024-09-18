#!/bin/bash
export LD_LIBRARY_PATH="$PWD/lib:$LD_LIBRARY_PATH"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函数：打印彩色日志
log() {
    local level=$1
    local message=$2
    case $level in
        "INFO")
            echo -e "${GREEN}[INFO]${NC} $message"
            ;;
        "WARN")
            echo -e "${YELLOW}[WARN]${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message"
            ;;
        *)
            echo -e "${BLUE}[DEBUG]${NC} $message"
            ;;
    esac
}

# 函数：检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 函数：安装 Redis
install_redis() {
    log "INFO" "正在安装 Redis..."
    case "$1" in
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get install -y redis-server
            ;;
        centos)
            sudo yum install -y epel-release
            sudo yum install -y redis
            ;;
        mac)
            if command_exists brew; then
                brew install redis
            else
                log "ERROR" "请先安装 Homebrew，然后重新运行此脚本。"
                exit 1
            fi
            ;;
        *)
            log "ERROR" "不支持的操作系统。"
            exit 1
            ;;
    esac
}

# 函数：配置新的 Redis 实例
configure_new_redis() {
    log "INFO" "正在配置新的 Redis 实例..."
    REDIS_CONF="./redis_2024.conf"
    cat > $REDIS_CONF <<EOL
port 2024
daemonize yes
pidfile ./redis_2024.pid
logfile ./redis_2024.log
dir ./
EOL
}

# 函数：验证钱包地址和私钥格式
validate_config() {
    local config_file="config.yaml"
    if [ ! -f "$config_file" ]; then
        log "ERROR" "配置文件 $config_file 不存在。"
        return 1
    fi

    local wallet_address=$(grep "wallet_address:" $config_file | awk '{print $2}' | tr -d '"')
    local private_key=$(grep "private_key:" $config_file | awk '{print $2}' | tr -d '"')

    if [ -z "$wallet_address" ] || [ -z "$private_key" ]; then
        log "ERROR" "钱包地址或私钥为空。请在 $config_file 中正确配置。"
        return 1
    fi

    if [[ ! $wallet_address =~ ^0x[a-fA-F0-9]{40}$ ]]; then
        log "ERROR" "钱包地址格式不正确。应为0x开头的42个字符。"
        return 1
    fi

    if [[ ! $private_key =~ ^[a-fA-F0-9]{64}$ ]]; then
        log "ERROR" "私钥格式不正确。应为64位字符（不含0x）。"
        return 1
    fi

    return 0
}

# 检测操作系统
log "INFO" "正在检测操作系统..."
log "DEBUG" "OSTYPE: $OSTYPE"

if [ -z "$OSTYPE" ]; then
    log "WARN" "OSTYPE 为空，尝试使用 uname 检测系统"
    OSTYPE=$(uname -s)
fi

case "$OSTYPE" in
    linux*|Linux*)
        log "INFO" "检测到 Linux 系统"
        if command_exists apt-get; then
            log "DEBUG" "检测到 apt-get，可能是 Ubuntu 或 Debian"
            if [ -f /etc/debian_version ]; then
                log "INFO" "检测到 Debian"
                OS="debian"
            else
                log "INFO" "检测到 Ubuntu"
                OS="ubuntu"
            fi
        elif command_exists yum; then
            log "INFO" "检测到 CentOS"
            OS="centos"
        else
            log "ERROR" "无法识别的 Linux 发行版"
            exit 1
        fi
        ;;
    darwin*|Darwin*)
        log "INFO" "检测到 macOS"
        OS="mac"
        ;;
    *)
        log "ERROR" "不支持的操作系统: $OSTYPE"
        exit 1
        ;;
esac

log "INFO" "识别的操作系统: $OS"

# 检查并创建logs文件夹
if [ ! -d "logs" ]; then
    log "INFO" "正在创建logs文件夹..."
    mkdir logs
    if [ $? -eq 0 ]; then
        log "INFO" "logs文件夹创建成功。"
    else
        log "ERROR" "创建logs文件夹失败。请检查权限。"
        exit 1
    fi
else
    log "INFO" "logs文件夹已存在。"
fi

# 提醒用户配置钱包地址和私钥
log "WARN" "重要提醒：确保您已在 config.yaml 文件中正确配置了您的钱包地址和私钥。"
log "INFO" "钱包地址应为0x开头的42个字符。"
log "INFO" "私钥应为64位字符（不含0x）。"

while true; do
    read -p "您是否已完成配置？(y/n): " config_done
    if [ "$config_done" = "y" ]; then
        if validate_config; then
            log "INFO" "配置验证通过。"
            break
        else
            log "WARN" "请修正配置后重试。"
        fi
    else
        log "WARN" "请完成配置后再次运行此脚本。"
        exit 1
    fi
done

# 检查 Redis 是否已安装
if ! command_exists redis-cli; then
    install_redis $OS
fi

# 配置新的 Redis 实例
configure_new_redis

# 启动新的 Redis 实例
log "INFO" "正在启动新的 Redis 实例..."
redis-server $REDIS_CONF

# 启动 claim_emc 程序
log "INFO" "正在启动 claim_emc 程序..."
./claim_emc &

# 启动 CUDA 挖矿程序
log "INFO" "正在启动 CUDA 挖矿程序..."
log "INFO" "按 Ctrl+C 可以安全地终止所有进程。"
./cuda_mining

pkill -f 'claim_emc'

# 脚本结束
log "INFO" "脚本执行完毕。"
