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

# 从 apps.db 同步 apps.conf（新增应用默认保留，已有应用保留用户设置）
APPS_DB="$MODPATH/apps.db"
if [ -f "$APPS_DB" ]; then
  # 读取旧配置的状态
  OLD_STATUS=""
  if [ -f "$APPS_CONF" ]; then
    while IFS='|' read -r _p _n _s _st _g; do
      [ -z "$_p" ] && continue; case "$_p" in \#*) continue ;; esac
      OLD_STATUS="$OLD_STATUS
$_p=$_st"
    done < "$APPS_CONF"
  fi

  # 从 apps.db 生成新配置，保留旧状态
  TMP_CONF="$MODPATH/webroot/apps.conf.tmp"
  echo "# HyperOS3 Debloat 配置" > "$TMP_CONF"
  echo "# 格式：路径|显示名|包名|状态（1=精简 0=保留）|分组" >> "$TMP_CONF"

  # 记录 apps.db 中的路径
  DB_PATHS=""

  while IFS= read -r line; do
    line="${line%$(printf '\r')}"
    case "$line" in \#*|"") continue ;; esac
    path=$(echo "$line" | cut -d'|' -f1)
    display=$(echo "$line" | cut -d'|' -f2)
    pkg=$(echo "$line" | cut -d'|' -f3)
    group=$(echo "$line" | cut -d'|' -f4)
    DB_PATHS="$DB_PATHS
$path"
    # 查找旧状态，默认 0（保留）
    status=0
    old=$(echo "$OLD_STATUS" | grep "^$path=" | tail -1)
    [ -n "$old" ] && status="${old#*=}"
    echo "$path|$display|$pkg|$status|$group" >> "$TMP_CONF"
  done < "$APPS_DB"

  # 保留旧 apps.conf 中的自定义应用（不在 apps.db 中的）
  if [ -f "$APPS_CONF" ]; then
    while IFS='|' read -r _p _n _pkg _st _g; do
      _p="${_p%$(printf '\r')}"
      [ -z "$_p" ] && continue; case "$_p" in \#*) continue ;; esac
      case "$DB_PATHS" in
        *"$_p"*) continue ;;
      esac
      echo "$_p|$_n|$_pkg|$_st|$_g" >> "$TMP_CONF"
    done < "$APPS_CONF"
  fi

  mv "$TMP_CONF" "$APPS_CONF"
fi

# apps.conf 不存在则跳过
[ -f "$APPS_CONF" ] || exit 0

# 清除上次创建的 REPLACE 目录
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

  # APEX/pm: 前缀的应用：用 pm uninstall 处理
  case "$path" in apex:*|pm:*)
    if [ "$status" = "1" ] && [ -n "$pkg" ]; then
      pm uninstall -k --user 0 "$pkg" >/dev/null 2>&1
    else
      [ -n "$pkg" ] && pm install-existing --user 0 "$pkg" >/dev/null 2>&1
    fi
    continue
  ;; esac

  if [ "$status" = "1" ]; then
    # 创建 REPLACE 目录
    mod_dir="$MODPATH/$path"
    mkdir -p "$mod_dir"
    touch "$mod_dir/.replace"
    echo "$mod_dir" >> "$RECORD_FILE"

    # 卸载 data 副本
    [ -n "$pkg" ] && pm uninstall -k --user 0 "$pkg" >/dev/null 2>&1
  else
    # 恢复被取消精简的应用
    [ -n "$pkg" ] && pm install-existing --user 0 "$pkg" >/dev/null 2>&1
  fi
done < "$APPS_CONF"
