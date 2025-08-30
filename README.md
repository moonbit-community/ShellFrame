# Shell Frame

基于 MoonBit 构建的实验性图像压缩工具，实现了 JPEG 风格的 DCT 压缩和自适应量化。

## 项目概述

Shell Frame 演示了以下图像压缩技术：
- 离散余弦变换 (DCT) 进行频域分析
- YCbCr 色彩空间转换以提高压缩效率
- 基于图像内容的自适应量化矩阵
- 游程编码压缩系数

## 功能特性

- **快速 DCT 实现**：使用 1D 变换优化的可分离 2D DCT
- **自适应量化**：基于块方差的动态量化
- **色彩空间优化**：RGB 到 YCbCr 转换，支持色度子采样
- **多质量级别**：生成不同质量设置的压缩图像
- **二进制输出格式**：使用 Z 字形扫描序列的紧凑 .bin 文件
- **可视化工具**：DCT 系数可视化和对比输出

## 依赖项

- **ImageMagick**：用于像素 I/O 操作的图像处理库
  - MagickWand C API 绑定，用于读写图像文件
  - 需要 ImageMagick 开发头文件 (`libmagickwand-dev`)

## 构建

```bash
# 安装 ImageMagick 开发库 (Ubuntu/Debian)
sudo apt-get install libmagickwand-dev

# 构建产物
moon build --target native
```

## 使用方法

直接使用 `moon run --target native src/main.mbt` 运行。程序将生成：

- **压缩图像**：质量级别为 10, 30, 50, 80, 95 的 `peppers_compressed_q{质量}.png`
- **DCT 可视化**：显示频域系数的 `peppers_dct_q{质量}.png`
- **二进制文件**：包含压缩 DCT 数据的 `peppers_compressed_q{质量}.bin`
- **原始 DCT 输出**：显示未量化变换系数的 `peppers_dct.png`

## 技术细节

### 压缩流水线

1. **色彩空间转换**：RGB → YCbCr 用于感知优化
2. **块分割**：8×8 像素块进行 DCT 处理
3. **DCT 变换**：前向二维离散余弦变换
4. **自适应量化**：基于内容感知的量化矩阵缩放
5. **系数编码**：Z 字形扫描和游程编码
6. **二进制序列化**：紧凑存储格式

## 架构

```
src/
├── main.mbt          # 主压缩流水线
├── magick.mbt        # ImageMagick FFI 绑定
├── magick_stub.c     # C 包装函数
└── moon.pkg.json     # 包配置
```

代码库使用 MoonBit 的原生 FFI 功能与 ImageMagick 的 MagickWand API 接口，同时用纯 MoonBit 实现所有压缩算法。

## 实验性状态

这是一个探索 MoonBit 现代系统编程的研究项目。压缩率和质量无法匹配生产级 JPEG 编码器，但演示了图像压缩中使用的核心算法和技术。

### 与标准 JPEG 的差异

本实现为了简化和教学目的，忽略了以下标准 JPEG 编码步骤：

- **霍夫曼编码**：未实现熵编码，直接存储量化系数
- **DC 系数差分编码**：相邻块的 DC 系数未进行差分编码
- **色度子采样**：YCbCr 各通道使用相同分辨率
- **精确的量化表**：使用简化的自适应量化而非标准 JPEG 表

这些简化使得代码更易理解，但也导致压缩效率和质量均会低于标准 JPEG。

## 许可证

Apache 2.0
