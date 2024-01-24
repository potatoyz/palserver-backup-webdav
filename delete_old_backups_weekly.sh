#!/bin/bash

# 定义本地备份目录
LOCAL_BACKUP_DIR="/home/palu/backup"

# 查找本地一周之前的.tar.gz备份文件
OLD_FILES=$(find "$LOCAL_BACKUP_DIR" -type f -name "*.tar.gz" -mtime +7)

for file in $OLD_FILES; do
    # 删除文件
    rm -f "$file"
    echo "已删除文件：$file"
    
    # 获取文件所在目录
    DIR=$(dirname "$file")
    
    # 如果文件夹为空，则删除文件夹
    if [ -z "$(ls -A $DIR)" ]; then
        rmdir "$DIR"
        echo "已删除空文件夹：$DIR"
    fi
done

echo "已成功删除一周之前的本地备份文件及其父文件夹: $(date)"