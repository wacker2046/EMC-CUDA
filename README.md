# EMC-CUDA
EMC GPU 挖矿程序：基于 CUDA 的高性能并行计算实现，支持多 GPU 协同工作，集成自动提交和交易管理功能。
   
      使用CUDA编写的Keccak算法进行GPU挖矿，解决当前难度过高导致CPU计算缓慢的问题。

注意：
- 可供编辑的配置文件
- 可视化哈希率显示
- 详细日志文件查看
- 极致的CUDA编程性能
- 分布式哈希计算（待推出）

<center>
挖矿状态报告 (测试机型：1060 6G，测试难度4)

| 使用 GPU 数量 | 1  |
| ------------- | --- |
| 当前哈希率    | 0.4582 GH/s |
| 已找到候选值  | 11 |
| 每分钟模型 (均值) | 8.9485 |
| 已运行时间    | 00:01:18 |

**交易日志**: `./logs/claim.log`  
**挖矿日志**: `./logs/cuda.log`

按回车键退出程序
</center>

### 安装使用步骤
1. 从 release 页面下载包含较完整 lib 的压缩文件版本。

   下载后解压:
   ```shell
   tar -xzvf EMC-CUDA-1.0.1-linux-amd64.tar.gz
   cd EMC-CUDA-1.0.1-linux-amd64
   ```
   
   或者**克隆仓库**：
   ```shell
   git clone https://github.com/wacker2046/EMC-CUDA.git
   cd EMC-CUDA
   ```

2. **修改配置文件**：
   打开 `config.yaml` 文件，根据需要修改以下配置：
   - `wallet_address`: 钱包地址
   - `private_key`: 私钥

3. **运行安装脚本**：
   ```shell
   bash ./run.sh # sh ./run.sh
   ```

### 常见问题

1. **程序无法运行或提示权限错误**：

   确保 `run.sh` 脚本具有执行权限：
   ```shell
   chmod +x run.sh
   ```

2. **CUDA 错误或设备不支持**：

   确保您的设备支持 CUDA，并且已安装正确版本的 NVIDIA 驱动和 CUDA 工具包。

3. **库文件缺失**：

   如果遇到库文件缺失的错误，可以尝试以下方法：

   a. 更新系统包：
   ```shell
   sudo apt update && sudo apt upgrade
   ```

   b. 安装常见的依赖库：
   ```shell
   sudo apt install build-essential libcurl4-openssl-dev libssl-dev
   ```

   c. 如果是特定的库文件缺失，可以尝试手动安装：
   ```shell
   sudo apt install libxxx-dev
   ```
   （将 'xxx' 替换为实际缺失的库名）

   d. 如果问题仍然存在，请检查 `cuda.log` 文件中的详细错误信息，并在 GitHub 上提交 issue。


### 说明

本软件支持多种 Linux 发行版，通过自动检测操作系统并安装所需的依赖项，简化安装和配置过程。对于Windows暂未测试和针对性开发，请尝试。

*抽取10%的CUDA算力用于测试开发。*

### 提示

EMC CUDA 以下简称“本软件”仅供学习、教育、性能评估用途。请不要将本软件用于商业目的或生产环境中。开发者不对因使用本软件而导致的任何损害、数据丢失或其他问题负责。

---