#!/system/bin/sh

# 恢复 data-app（在删除模块目录之前）
RECORD_FILE="/data/adb/modules/$MODID/.data_apps_removed"
if [ -f "$RECORD_FILE" ]; then
  while IFS= read -r pkg; do
    [ -n "$pkg" ] && pm install-existing --user 0 "$pkg" >/dev/null 2>&1
  done < "$RECORD_FILE"
fi

# 恢复 apex 应用
APEX_RECORD_FILE="/data/adb/modules/$MODID/.apex_apps_removed"
if [ -f "$APEX_RECORD_FILE" ]; then
  while IFS= read -r pkg; do
    [ -n "$pkg" ] && pm install-existing --user 0 "$pkg" >/dev/null 2>&1
  done < "$APEX_RECORD_FILE"
fi

# 删除模块目录
rm -rf /data/adb/modules/$MODID/system
rm -rf /data/adb/modules/$MODID/product
rm -rf /data/adb/modules/$MODID/system_ext
rm -rf /data/adb/modules/$MODID/webroot
rm -f /data/adb/modules/$MODID/.data_apps_removed
rm -f /data/adb/modules/$MODID/.apex_apps_removed
rm -f /data/adb/modules/$MODID/.debloat_record
