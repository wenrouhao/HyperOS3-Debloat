#!/system/bin/sh

LATESTARTSERVICE=false
POSTFSDATA=false
PROPFILE=false
SKIPMOUNT=false

REMOVE=""

print_modname() {
  ui_print " "
  ui_print "=================================="
  ui_print "  HyperOS3 终极精简模块 v1.0.0"
  ui_print "  作者：温柔浩"
  ui_print "=================================="
  ui_print " "
}

getVolumeKey() {
  sleep 1
  keyInfo=true
  while $keyInfo; do
    keyInfo=$(getevent -qlc 1 | grep KEY_VOLUME)
    if [ "$keyInfo" == "" ]; then
      continue
    else
      isUpKey=$(echo $keyInfo | grep KEY_VOLUMEUP)
      [ "$isUpKey" != "" ] && return 0 || return 1
      break
    fi
  done
}

add_to_remove() {
  for path in $@; do
    REMOVE="$REMOVE
$path"
  done
}

on_install() {
  ui_print " 选择精简模式："
  ui_print "  音量+：一键全部精简（推荐）"
  ui_print "  音量-：逐组自定义"
  ui_print " "

  if getVolumeKey; then
    ui_print " ✅ 已选择：一键全部精简"
    ui_print " "
    add_to_remove \
      "/system/product/app/XiaoaiRecommendation" \
      "/system/product/app/AiasstVision" \
      "/system/product/app/SwitchAccess" \
      "/system/product/app/com.xiaomi.macro" \
      "/system/product/app/com.xiaomi.ugd" \
      "/system/product/priv-app/MIUIQuickSearchBox" \
      "/system/product/priv-app/MiGameCenterSDKService" \
      "/system/product/priv-app/MiniGameService" \
      "/system/product/data-app/DownloadProviderUi" \
      "/system/product/data-app/MIUIGameCenter" \
      "/system/product/data-app/MiuiScanner" \
      "/system/product/app/MIUICloudService" \
      "/system/product/app/MIUIMiCloudSync" \
      "/system/product/priv-app/MIUICloudBackup" \
      "/system/product/priv-app/MirrorOS3" \
      "/system/product/app/CarWith" \
      "/system/product/app/MIS" \
      "/system/product/app/MiLinkOS3Cn" \
      "/system/product/app/LyraWOS3CN" \
      "/system/product/priv-app/MIUIAICR" \
      "/system/product/priv-app/MIUIPersonalAssistantPhoneOS3" \
      "/system/product/priv-app/MiuiBarrage" \
      "/system/product/priv-app/MIUIContentExtension" \
      "/system/product/app/WMService" \
      "/system/product/app/MIUIReporter" \
      "/system/product/priv-app/AutoRegistration" \
      "/system/product/priv-app/RegService" \
      "/system/system_ext/app/MiSightService" \
      "/system/system_ext/app/MiuiDaemon" \
      "/system/system_ext/app/VsimCore" \
      "/system/system_ext/priv-app/EmergencyInfo" \
      "/system/system_ext/priv-app/PowerInsight" \
      "/system/system_ext/priv-app/com.qualcomm.qti.services.systemhelper" \
      "/system/product/app/NQNfcNci" \
      "/system/product/app/MIUIGuardProvider" \
      "/system/product/app/SogouIME" \
      "/system/product/app/MIUISuperMarket_M2_M3"
    ui_print " 🎯 全部精简项已启用"
    return 0
  fi

  ui_print " ✅ 已选择：逐组自定义"
  ui_print " "

  ui_print "--- [1] 🧠 超级小爱相关 ---"
  ui_print "  保留：语音唤醒+语音助手+小爱服务"
  ui_print "  精简：小爱建议/小爱视觉"
  ui_print "  音量+精简 / 音量-跳过"
  if getVolumeKey; then
    add_to_remove "/system/product/app/XiaoaiRecommendation" "/system/product/app/AiasstVision"
    ui_print "  ✅ 已精简"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  ui_print "--- [2] 🔍 桌面搜索/游戏SDK ---"
  ui_print "  搜索框/游戏中心SDK/小游戏服务"
  ui_print "  音量+精简 / 音量-跳过"
  if getVolumeKey; then
    add_to_remove "/system/product/priv-app/MIUIQuickSearchBox" "/system/product/priv-app/MiGameCenterSDKService" "/system/product/priv-app/MiniGameService"
    ui_print "  ✅ 已精简"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  ui_print "--- [3] ♿ 无障碍/宏 ---"
  ui_print "  SwitchAccess/宏/ugd"
  ui_print "  音量+精简 / 音量-跳过"
  if getVolumeKey; then
    add_to_remove "/system/product/app/SwitchAccess" "/system/product/app/com.xiaomi.macro" "/system/product/app/com.xiaomi.ugd"
    ui_print "  ✅ 已精简"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  ui_print "--- [4] 📦 系统预装 ---"
  ui_print "  游戏中心/扫一扫/下载管理"
  ui_print "  音量+精简 / 音量-跳过"
  if getVolumeKey; then
    add_to_remove "/system/product/data-app/DownloadProviderUi" "/system/product/data-app/MIUIGameCenter" "/system/product/data-app/MiuiScanner"
    ui_print "  ✅ 已精简"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  ui_print "--- [5] ☁️ 云备份服务 ---"
  ui_print "  云服务/云同步/云备份"
  ui_print "  音量+精简 / 音量-跳过"
  if getVolumeKey; then
    add_to_remove "/system/product/app/MIUICloudService" "/system/product/app/MIUIMiCloudSync" "/system/product/priv-app/MIUICloudBackup"
    ui_print "  ✅ 已精简"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  ui_print "--- [6] 📺 跨屏协同 ---"
  ui_print "  音量+精简 / 音量-跳过"
  if getVolumeKey; then
    add_to_remove "/system/product/priv-app/MirrorOS3"
    ui_print "  ✅ 已精简"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  ui_print "--- [7] 🚗 汽车互联 ---"
  ui_print "  CarWith/MIS"
  ui_print "  音量+精简 / 音量-跳过"
  if getVolumeKey; then
    add_to_remove "/system/product/app/CarWith" "/system/product/app/MIS"
    ui_print "  ✅ 已精简"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  ui_print "--- [8] 🔗 互联互通 ---"
  ui_print "  MiLink/Lyra通信"
  ui_print "  音量+精简 / 音量-跳过"
  if getVolumeKey; then
    add_to_remove "/system/product/app/MiLinkOS3Cn" "/system/product/app/LyraWOS3CN"
    ui_print "  ✅ 已精简"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  ui_print "--- [9] 🤖 澎湃AI引擎 ---"
  ui_print "  音量+精简 / 音量-跳过"
  if getVolumeKey; then
    add_to_remove "/system/product/priv-app/MIUIAICR"
    ui_print "  ✅ 已精简"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  ui_print "--- [10] 🛒 应用商店 ---"
  ui_print "  音量+精简 / 音量-跳过"
  if getVolumeKey; then
    add_to_remove "/system/product/app/MIUISuperMarket_M2_M3"
    ui_print "  ✅ 已精简"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  ui_print "--- [11] 📱 负一屏/弹幕/内容扩展 ---"
  ui_print "  音量+精简 / 音量-跳过"
  if getVolumeKey; then
    add_to_remove "/system/product/priv-app/MIUIPersonalAssistantPhoneOS3" "/system/product/priv-app/MiuiBarrage" "/system/product/priv-app/MIUIContentExtension"
    ui_print "  ✅ 已精简"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  ui_print "--- [12] 📋 窗口管理/报告/注册 ---"
  ui_print "  WMService/报告/自动注册/注册服务"
  ui_print "  音量+精简 / 音量-跳过"
  if getVolumeKey; then
    add_to_remove "/system/product/app/WMService" "/system/product/app/MIUIReporter" "/system/product/priv-app/AutoRegistration" "/system/product/priv-app/RegService"
    ui_print "  ✅ 已精简"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  ui_print "--- [13] ⚙️ system_ext服务 ---"
  ui_print "  MiSight/Daemon/VsimCore/紧急信息/电源/高通助手"
  ui_print "  音量+精简 / 音量-跳过"
  if getVolumeKey; then
    add_to_remove "/system/system_ext/app/MiSightService" "/system/system_ext/app/MiuiDaemon" "/system/system_ext/app/VsimCore" "/system/system_ext/priv-app/EmergencyInfo" "/system/system_ext/priv-app/PowerInsight" "/system/system_ext/priv-app/com.qualcomm.qti.services.systemhelper"
    ui_print "  ✅ 已精简"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  ui_print "--- [⚠️ 14] NFC服务 ---"
  ui_print "  ⚠️ 删除后门禁/公交卡/付款可能失效！"
  ui_print "  音量+精简 / 音量-跳过"
  if getVolumeKey; then
    add_to_remove "/system/product/app/NQNfcNci"
    ui_print "  ✅ 已精简"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  ui_print "--- [⚠️ 15] 系统安全组件 ---"
  ui_print "  ⚠️ 可能影响系统兼容性！"
  ui_print "  音量+精简 / 音量-跳过"
  if getVolumeKey; then
    add_to_remove "/system/product/app/MIUIGuardProvider"
    ui_print "  ✅ 已精简"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  ui_print "--- [⚠️ 16] 搜狗输入法 ---"
  ui_print "  ⚠️ 删除后请确保有其他输入法！"
  ui_print "  音量+精简 / 音量-跳过"
  if getVolumeKey; then
    add_to_remove "/system/product/app/SogouIME"
    ui_print "  ✅ 已精简"
  else
    ui_print "  ⏭️ 跳过"
  fi
}

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
}
