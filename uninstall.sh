#!/system/bin/sh
rm -rf /data/adb/modules/$MODID/system

RECORD_FILE="/data/adb/modules/$MODID/.data_apps_removed"
if [ -f "$RECORD_FILE" ]; then
  while IFS= read -r pkg; do
    [ -n "$pkg" ] && pm install-existing --user 0 "$pkg" 2>/dev/null
  done < "$RECORD_FILE"
fi
