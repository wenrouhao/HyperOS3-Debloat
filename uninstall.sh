#!/system/bin/sh
rm -rf /data/adb/modules/$MODID/system

pm install-existing --user 0 com.xiaomi.gamecenter 2>/dev/null
pm install-existing --user 0 com.xiaomi.scanner 2>/dev/null
pm install-existing --user 0 com.android.providers.downloads.ui 2>/dev/null
