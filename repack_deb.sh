#!/bin/bash
# repack_deb.sh
#
# 用法:
#   ./repack_deb.sh some-package.deb
#
# 说明:
# 1. 解包 .deb 文件，得到 debian-binary、control.tar.zst、data.tar.zst（或其他压缩格式）。
# 2. 使用 zstd 解压 zst 文件，并用 xz 压缩得到 control.tar.xz 和 data.tar.xz。
# 3. 使用 ar 命令重新生成 .deb 包，并将其存放在 /tmp/ 目录下。
# 4. 清理工作目录中生成的中间文件。
#
# 注意:
# - 本脚本假定输入的 .deb 包中使用的压缩格式为 zstd，
#   如果有不同的压缩格式请相应调整脚本。
# - 脚本中使用的 ar 参数 "-m -c -a sdsd" 是按照你的要求提供，
#   如果遇到问题，可以尝试使用常见的参数如 "rcs"。

set -e

if [ "$(id -u)" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi


# 检查输入参数
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 package.deb"
    exit 1
fi

INPUT_DEB="$1"

if [ ! -f "$INPUT_DEB" ]; then
    echo "Error: File '$INPUT_DEB' not found."
    exit 1
fi

# 获取绝对路径和基本文件名
INPUT_DEB_ABS="$(readlink -f "$INPUT_DEB")"
BASENAME=$(basename "$INPUT_DEB")
NEW_DEB="/tmp/$BASENAME"

# 创建临时工作目录
WORKDIR=$(mktemp -d)
echo "Using temporary working directory: $WORKDIR"
cd "$WORKDIR"

# 将 .deb 文件复制到工作目录中
cp "$INPUT_DEB_ABS" .

# 提取 .deb 包中的所有文件
echo "Extracting $BASENAME ..."
ar x "$BASENAME"

# 检查需要的文件是否存在
if [ ! -f control.tar.zst ]; then
    echo "Error: control.tar.zst not found in the package."
    exit 1
fi

if [ ! -f data.tar.zst ]; then
    echo "Error: data.tar.zst not found in the package."
    exit 1
fi

# 使用 zstd 解压并用 xz 重新压缩 control 和 data 文件
echo "Recompressing control.tar.zst -> control.tar.xz ..."
zstd -d < control.tar.zst | xz > control.tar.xz

echo "Recompressing data.tar.zst -> data.tar.xz ..."
zstd -d < data.tar.zst | xz > data.tar.xz

# 重新打包 .deb 文件
echo "Reassembling new .deb package at $NEW_DEB ..."
# 注意: 这里使用的参数 "-m -c -a sdsd" 是按照你给出的命令，如果有问题请调整
ar -m -c -a sdsd "$NEW_DEB" debian-binary control.tar.xz data.tar.xz

echo "New package created: $NEW_DEB"

# 清理中间文件
echo "Cleaning up temporary files..."
rm -f debian-binary control.tar.zst control.tar.xz data.tar.zst data.tar.xz "$BASENAME"
cd -
rm -rf "$WORKDIR"

echo "Done."
