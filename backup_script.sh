#!/bin/bash

# 定义源目录和备份目录变量
SOURCE_DIR="/home/palu/Steam/steamapps/common/PalServer/Pal/Saved/SaveGames/0"
MONTH_DIR=$(date +\%Y-\%m)
DATE_DIR=$(date +\%Y-\%m-\%d)
DATETIME_DIR="$(basename $DATE_DIR)-$(date +\%H\%M\%S)"
BACKUP_MONTH_DIR="/home/palu/backup/$MONTH_DIR"
BACKUP_DATE_DIR="$BACKUP_MONTH_DIR/$DATE_DIR"
BACKUP_DIR="$BACKUP_DATE_DIR/$DATETIME_DIR"
BACKUP_FILE_NAME="$DATETIME_DIR.tar.gz"

# 创建备份目录（如不存在）
mkdir -p "$BACKUP_DIR"

# 复制文件到备份目录
cp -a "$SOURCE_DIR/." "$BACKUP_DIR"

# 定义WebDAV服务器相关变量
WEBDAV_URL="<Webdav-url>" 
WEBDAV_USER="<User>"
WEBDAV_PASSWORD="<Password>"

# 压缩备份文件
tar -czvf "$BACKUP_DATE_DIR/$BACKUP_FILE_NAME" -C "$BACKUP_DIR" .

# 在WebDAV中创建月份和日期目录
curl -X MKCOL -u "$WEBDAV_USER:$WEBDAV_PASSWORD" "$WEBDAV_URL/$MONTH_DIR/"
curl -X MKCOL -u "$WEBDAV_USER:$WEBDAV_PASSWORD" "$WEBDAV_URL/$MONTH_DIR/$DATE_DIR/"

# 将备份文件上传至WebDAV
curl -T "$BACKUP_DATE_DIR/$BACKUP_FILE_NAME" \
     -u "$WEBDAV_USER:$WEBDAV_PASSWORD" \
     "$WEBDAV_URL/$MONTH_DIR/$DATE_DIR/$BACKUP_FILE_NAME"

# 删除本地的原始备份目录
rm -rf "$BACKUP_DIR"

echo "备份已成功完成并上传至WebDAV: $(date)"