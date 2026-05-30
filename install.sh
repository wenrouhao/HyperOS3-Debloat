#!/system/bin/sh

LATESTARTSERVICE=false
POSTFSDATA=false
PROPFILE=false
SKIPMOUNT=false

REMOVE=""

print_modname() {
  ui_print " "
  ui_print "=================================="
  ui_print "  HyperOS3 终极精简模块 v2.0.0"
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

# 通用策略函数
# $1: 模块名称
# $2: 音量+描述（保留核心）
# $3: 音量-描述（全部精简）
# $4: 保留核心时的精简列表（空格分隔）
# $5: 全部精简时的精简列表（空格分隔）
choose_mode() {
  local name="$1"
  local keep_desc="$2"
  local full_desc="$3"
  local keep_list="$4"
  local full_list="$5"

  ui_print "  音量+：${keep_desc}"
  ui_print "  音量-：${full_desc}"

  if getVolumeKey; then
    ui_print "  ✔ ${keep_desc}"
    [ -n "$keep_list" ] && add_to_remove $keep_list
  else
    ui_print "  ✖ ${full_desc}"
    add_to_remove $full_list
  fi
}

apply_remove() {
  ui_print " "
  ui_print " 正在应用精简列表..."
  local count=0
  for path in $REMOVE; do
    [ -z "$path" ] && continue
    local target="$MODPATH$path"
    local dir=$(dirname "$target")
    mkdir -p "$dir"
    touch "$target"
    count=$((count + 1))
  done
  ui_print " 🎯 已精简 $count 个项目"
}

on_install() {
  ui_print " 选择精简模式："
  ui_print "  音量+：逐组自定义（推荐）"
  ui_print "  音量-：一键全部精简"
  ui_print " "

  if getVolumeKey; then
    ui_print " ✅ 已选择：逐组自定义"
    ui_print " "
  else
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
    apply_remove
    return 0
  fi

  ui_print " 进入各模块自定义："
  ui_print "  每组：音量+ 进入 / 音量- 跳过"
  ui_print " "

  # ============================================================
  # [1] AI / 小爱模块
  # ============================================================
  ui_print "--- [1] 🧠 AI / 小爱模块 ---"
  ui_print "  音量+ 进入 / 音量- 跳过"
  if getVolumeKey; then
    choose_mode "AI" \
      "保留核心（语音+唤醒+基础服务）" \
      "全部精简（含小爱核心能力）" \
      "/system/product/app/XiaoaiRecommendation /system/product/app/AiasstVision" \
      "/system/product/app/XiaoaiRecommendation /system/product/app/AiasstVision"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  # ============================================================
  # [2] 桌面搜索 / 游戏SDK
  # ============================================================
  ui_print "--- [2] 🔍 桌面搜索 / 游戏SDK ---"
  ui_print "  音量+ 进入 / 音量- 跳过"
  if getVolumeKey; then
    choose_mode "搜索/游戏" \
      "保留核心（搜索框）" \
      "全部精简（搜索框+游戏SDK+小游戏）" \
      "/system/product/priv-app/MiGameCenterSDKService /system/product/priv-app/MiniGameService" \
      "/system/product/priv-app/MIUIQuickSearchBox /system/product/priv-app/MiGameCenterSDKService /system/product/priv-app/MiniGameService"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  # ============================================================
  # [3] 无障碍 / 宏
  # ============================================================
  ui_print "--- [3] ♿ 无障碍 / 宏 ---"
  ui_print "  音量+ 进入 / 音量- 跳过"
  if getVolumeKey; then
    choose_mode "无障碍/宏" \
      "保留核心（无障碍服务）" \
      "全部精简（SwitchAccess+宏+ugd）" \
      "/system/product/app/com.xiaomi.macro /system/product/app/com.xiaomi.ugd" \
      "/system/product/app/SwitchAccess /system/product/app/com.xiaomi.macro /system/product/app/com.xiaomi.ugd"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  # ============================================================
  # [4] 系统预装
  # ============================================================
  ui_print "--- [4] 📦 系统预装 ---"
  ui_print "  音量+ 进入 / 音量- 跳过"
  if getVolumeKey; then
    choose_mode "系统预装" \
      "保留核心（下载管理）" \
      "全部精简（下载管理+游戏中心+扫一扫）" \
      "/system/product/data-app/MIUIGameCenter /system/product/data-app/MiuiScanner" \
      "/system/product/data-app/DownloadProviderUi /system/product/data-app/MIUIGameCenter /system/product/data-app/MiuiScanner"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  # ============================================================
  # [5] 云备份服务
  # ============================================================
  ui_print "--- [5] ☁️ 云备份服务 ---"
  ui_print "  音量+ 进入 / 音量- 跳过"
  if getVolumeKey; then
    choose_mode "云备份" \
      "保留核心（云服务基础）" \
      "全部精简（云服务+云同步+云备份）" \
      "/system/product/app/MIUIMiCloudSync /system/product/priv-app/MIUICloudBackup" \
      "/system/product/app/MIUICloudService /system/product/app/MIUIMiCloudSync /system/product/priv-app/MIUICloudBackup"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  # ============================================================
  # [6] 跨屏协同
  # ============================================================
  ui_print "--- [6] 📺 跨屏协同 ---"
  ui_print "  音量+ 进入 / 音量- 跳过"
  if getVolumeKey; then
    choose_mode "跨屏协同" \
      "保留核心（基础投屏）" \
      "全部精简（MirrorOS3）" \
      "" \
      "/system/product/priv-app/MirrorOS3"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  # ============================================================
  # [7] 汽车互联
  # ============================================================
  ui_print "--- [7] 🚗 汽车互联 ---"
  ui_print "  音量+ 进入 / 音量- 跳过"
  if getVolumeKey; then
    choose_mode "汽车互联" \
      "保留核心（基础连接）" \
      "全部精简（CarWith+MIS）" \
      "/system/product/app/MIS" \
      "/system/product/app/CarWith /system/product/app/MIS"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  # ============================================================
  # [8] 互联互通
  # ============================================================
  ui_print "--- [8] 🔗 互联互通 ---"
  ui_print "  音量+ 进入 / 音量- 跳过"
  if getVolumeKey; then
    choose_mode "互联互通" \
      "保留核心（基础连接）" \
      "全部精简（MiLink+Lyra）" \
      "/system/product/app/LyraWOS3CN" \
      "/system/product/app/MiLinkOS3Cn /system/product/app/LyraWOS3CN"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  # ============================================================
  # [9] 澎湃AI引擎
  # ============================================================
  ui_print "--- [9] 🤖 澎湃AI引擎 ---"
  ui_print "  音量+ 进入 / 音量- 跳过"
  if getVolumeKey; then
    choose_mode "澎湃AI" \
      "保留核心（基础AI服务）" \
      "全部精简（MIUIAICR）" \
      "" \
      "/system/product/priv-app/MIUIAICR"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  # ============================================================
  # [10] 应用商店
  # ============================================================
  ui_print "--- [10] 🛒 应用商店 ---"
  ui_print "  音量+ 进入 / 音量- 跳过"
  if getVolumeKey; then
    choose_mode "应用商店" \
      "保留核心（基础商店）" \
      "全部精简（MIUISuperMarket）" \
      "" \
      "/system/product/app/MIUISuperMarket_M2_M3"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  # ============================================================
  # [11] 负一屏 / 弹幕 / 内容扩展
  # ============================================================
  ui_print "--- [11] 📱 负一屏 / 弹幕 / 内容扩展 ---"
  ui_print "  音量+ 进入 / 音量- 跳过"
  if getVolumeKey; then
    choose_mode "负一屏/弹幕" \
      "保留核心（小组件/负一屏基础）" \
      "全部精简（负一屏体系）" \
      "/system/product/priv-app/MiuiBarrage /system/product/priv-app/MIUIContentExtension" \
      "/system/product/priv-app/MIUIPersonalAssistantPhoneOS3 /system/product/priv-app/MiuiBarrage /system/product/priv-app/MIUIContentExtension"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  # ============================================================
  # [12] 窗口管理 / 报告 / 注册
  # ============================================================
  ui_print "--- [12] 📋 窗口管理 / 报告 / 注册 ---"
  ui_print "  音量+ 进入 / 音量- 跳过"
  if getVolumeKey; then
    choose_mode "窗口/报告/注册" \
      "保留核心（窗口管理）" \
      "全部精简（WMService+报告+注册）" \
      "/system/product/app/MIUIReporter /system/product/priv-app/AutoRegistration /system/product/priv-app/RegService" \
      "/system/product/app/WMService /system/product/app/MIUIReporter /system/product/priv-app/AutoRegistration /system/product/priv-app/RegService"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  # ============================================================
  # [13] system_ext 服务
  # ============================================================
  ui_print "--- [13] ⚙️ system_ext 服务 ---"
  ui_print "  音量+ 进入 / 音量- 跳过"
  if getVolumeKey; then
    choose_mode "system_ext" \
      "保留核心（MiSight+Daemon）" \
      "全部精简（全部system_ext服务）" \
      "/system/system_ext/app/VsimCore /system/system_ext/priv-app/EmergencyInfo /system/system_ext/priv-app/PowerInsight /system/system_ext/priv-app/com.qualcomm.qti.services.systemhelper" \
      "/system/system_ext/app/MiSightService /system/system_ext/app/MiuiDaemon /system/system_ext/app/VsimCore /system/system_ext/priv-app/EmergencyInfo /system/system_ext/priv-app/PowerInsight /system/system_ext/priv-app/com.qualcomm.qti.services.systemhelper"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  # ============================================================
  # [⚠️ 14] NFC 服务
  # ============================================================
  ui_print "--- [⚠️ 14] NFC 服务 ---"
  ui_print "  ⚠️ 删除后门禁/公交卡/付款可能失效！"
  ui_print "  音量+ 进入 / 音量- 跳过"
  if getVolumeKey; then
    choose_mode "NFC" \
      "保留核心（基础NFC）" \
      "全部精简（NQNfcNci）" \
      "" \
      "/system/product/app/NQNfcNci"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  # ============================================================
  # [⚠️ 15] 系统安全组件
  # ============================================================
  ui_print "--- [⚠️ 15] 系统安全组件 ---"
  ui_print "  ⚠️ 可能影响系统兼容性！"
  ui_print "  音量+ 进入 / 音量- 跳过"
  if getVolumeKey; then
    choose_mode "安全组件" \
      "保留核心（基础安全）" \
      "全部精简（MIUIGuardProvider）" \
      "" \
      "/system/product/app/MIUIGuardProvider"
  else
    ui_print "  ⏭️ 跳过"
  fi
  ui_print " "

  # ============================================================
  # [⚠️ 16] 搜狗输入法
  # ============================================================
  ui_print "--- [⚠️ 16] 搜狗输入法 ---"
  ui_print "  ⚠️ 删除后请确保有其他输入法！"
  ui_print "  音量+ 进入 / 音量- 跳过"
  if getVolumeKey; then
    choose_mode "搜狗输入法" \
      "保留核心（基础输入法）" \
      "全部精简（SogouIME）" \
      "" \
      "/system/product/app/SogouIME"
  else
    ui_print "  ⏭️ 跳过"
  fi

  apply_remove
}

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
}
