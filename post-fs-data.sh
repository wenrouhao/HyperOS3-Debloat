#!/system/bin/sh

# 加载包名映射
[ -f "$MODPATH/pkg_map.sh" ] && . "$MODPATH/pkg_map.sh"

APPS_CONF="$MODPATH/webroot/apps.conf"
RECORD_FILE="$MODPATH/.debloat_record"
LOG_FILE="$MODPATH/webroot/debug.log"

# 日志超过 3 天则清空
if [ -f "$LOG_FILE" ]; then
  find "$LOG_FILE" -mtime +3 -exec truncate -s 0 {} \; 2>/dev/null
fi

# apps.conf 不存在则跳过
[ -f "$APPS_CONF" ] || exit 0

# 1. 清除上次创建的 REPLACE 目录
if [ -f "$RECORD_FILE" ]; then
  while IFS= read -r dir; do
    [ -d "$dir" ] && rm -rf "$dir"
  done < "$RECORD_FILE"
fi

# 2. 读取 apps.conf，创建 REPLACE 目录 + 恢复取消精简的应用
: > "$RECORD_FILE"
while IFS='|' read -r path name pkg status group; do
  [ -z "$path" ] && continue
  case "$path" in \#*) continue ;; esac

  if [ "$status" = "1" ]; then
    # 创建 REPLACE 目录
    mod_dir="$MODPATH/$path"
    mkdir -p "$mod_dir"
    touch "$mod_dir/.replace"
    echo "$mod_dir" >> "$RECORD_FILE"

    # 卸载 data 副本
    [ -n "$pkg" ] && pm uninstall -k --user 0 "$pkg" >/dev/null 2>&1
  fi
done < "$APPS_CONF"
