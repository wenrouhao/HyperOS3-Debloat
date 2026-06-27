#!/system/bin/sh

# 应用数据库文件路径
APPS_DB="$MODPATH/apps.db"

# 从 apps.db 获取包名
# 参数：应用路径
get_pkg_name() {
  local folder=$(basename "$1")
  local line
  while IFS= read -r line; do
    case "$line" in \#*|"") continue ;; esac
    local f=$(echo "$line" | cut -d'|' -f1 | xargs basename)
    if [ "$f" = "$folder" ]; then
      echo "$line" | cut -d'|' -f3
      return
    fi
  done < "$APPS_DB"
  echo ""
}

# 从 apps.db 获取中文显示名
# 参数：应用路径
get_display_name() {
  local folder=$(basename "$1")
  local line
  while IFS= read -r line; do
    case "$line" in \#*|"") continue ;; esac
    local f=$(echo "$line" | cut -d'|' -f1 | xargs basename)
    if [ "$f" = "$folder" ]; then
      echo "$line" | cut -d'|' -f2
      return
    fi
  done < "$APPS_DB"
  echo "$folder"
}

# 从 apps.db 获取分组名
# 参数：应用路径
get_group() {
  local folder=$(basename "$1")
  local line
  while IFS= read -r line; do
    case "$line" in \#*|"") continue ;; esac
    local f=$(echo "$line" | cut -d'|' -f1 | xargs basename)
    if [ "$f" = "$folder" ]; then
      echo "$line" | cut -d'|' -f4
      return
    fi
  done < "$APPS_DB"
  echo "其他"
}

# 从 apps.db 获取所有应用路径
get_all_apps() {
  local line
  while IFS= read -r line; do
    case "$line" in \#*|"") continue ;; esac
    echo "$line" | cut -d'|' -f1
  done < "$APPS_DB"
}

# 从 apps.db 获取所有分组名（按出现顺序，去重）
get_all_groups() {
  local line
  local seen=""
  while IFS= read -r line; do
    case "$line" in \#*|"") continue ;; esac
    local group=$(echo "$line" | cut -d'|' -f4)
    case "$seen" in
      *"$group"*) continue ;;
    esac
    seen="$seen $group"
    echo "$group"
  done < "$APPS_DB"
}

# 从 apps.db 获取指定分组的所有应用路径
get_apps_by_group() {
  local target="$1"
  local line
  while IFS= read -r line; do
    case "$line" in \#*|"") continue ;; esac
    local group=$(echo "$line" | cut -d'|' -f4)
    if [ "$group" = "$target" ]; then
      echo "$line" | cut -d'|' -f1
    fi
  done < "$APPS_DB"
}

