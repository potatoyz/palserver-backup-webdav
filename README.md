## 1 自动备份流程

### 1.1 脚本配置与下载

您可以通过以下脚本自动化备份过程。请复制下面的脚本内容，并按需替换 WebDAV 配置。如果您不打算使用 WebDAV 上传功能，可以选择删除相关部分。

```sh
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
```

### 1.2 设置 Cron 定时任务

#### 1.2.1 启动 Cron 任务编辑器：
```bash
crontab -e
```

#### 1.2.2 添加定时备份任务：

将以下行添加至文件末尾，以实现每 30 分钟执行一次备份：

```
*/30 * * * * /home/palu/backup_script.sh
```

#### 1.2.3 保存并退出编辑器。

## 2 定期清理本地备份文件

### 2.1 清理脚本

定期清理一周前的本地备份文件及其父文件夹，以优化存储空间。使用以下脚本实现：

```sh
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
```

### 2.2 添加定时任务

在 Cron 中添加以下任务，以每周自动执行一次清理操作：

```sh
0 1 * * 0 /home/palu/delete_old_backups_weekly.sh
```

通过上述步骤，您可以确保自动备份的持续性和有效的本地存储管理。
