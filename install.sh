#!/system/bin/sh

LATESTARTSERVICE=false
POSTFSDATA=false
PROPFILE=false
SKIPMOUNT=false

REMOVE=""

print_modname() {
  ui_print " "
  ui_print "=================================="
  ui_print "  HyperOS3 终极精简模块 v2.2.0"
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

ask_dangerous() {
  ui_print " "
  ui_print " ⚠️ 危险项确认（可跳过）："

  ui_print "  NFC服务 - 门禁/公交卡/付款可能失效"
  ui_print "  音量+ 精简 / 音量- 保留"
  if getVolumeKey; then
    add_to_remove "/system/product/app/NQNfcNci"
    ui_print "  ✅ 精简NFC"
  else
    ui_print "  ⏭️ 保留NFC"
  fi

  ui_print "  系统安全组件 - 可能影响兼容性"
  ui_print "  音量+ 精简 / 音量- 保留"
  if getVolumeKey; then
    add_to_remove "/system/product/app/MIUIGuardProvider"
    ui_print "  ✅ 精简安全组件"
  else
    ui_print "  ⏭️ 保留安全组件"
  fi

  ui_print "  搜狗输入法 - 请确保有其他输入法"
  ui_print "  音量+ 精简 / 音量- 保留"
  if getVolumeKey; then
    add_to_remove "/system/product/app/SogouIME"
    ui_print "  ✅ 精简搜狗输入法"
  else
    ui_print "  ⏭️ 保留搜狗输入法"
  fi
}

select_mode() {
  local mode=1
  local max_mode=4

  while true; do
    case $mode in
      1)
        ui_print " ┌─────────────────────────────┐"
        ui_print " │ 1. 轻度精简（推荐）         │"
        ui_print " │    广告/推送/游戏/无障碍     │"
        ui_print " └─────────────────────────────┘"
        ;;
      2)
        ui_print " ┌─────────────────────────────┐"
        ui_print " │ 2. 中度精简                 │"
        ui_print " │    +云服务/负一屏/汽车互联   │"
        ui_print " └─────────────────────────────┘"
        ;;
      3)
        ui_print " ┌─────────────────────────────┐"
        ui_print " │ 3. 极限精简                 │"
        ui_print " │    +系统服务/窗口管理/AI引擎 │"
        ui_print " └─────────────────────────────┘"
        ;;
      4)
        ui_print " ┌─────────────────────────────┐"
        ui_print " │ 4. 自定义模式               │"
        ui_print " │    逐组选择（16组）          │"
        ui_print " └─────────────────────────────┘"
        ;;
    esac

    ui_print "  音量+ 确认 / 音量- 切换"

    if getVolumeKey; then
      ui_print " "
      ui_print " ✅ 已选择：模式$mode"
      return $mode
    else
      mode=$((mode + 1))
      [ $mode -gt $max_mode ] && mode=1
      ui_print " "
    fi
  done
}

on_install() {
  ui_print " ============================================"
  ui_print "  使用说明："
  ui_print "  · 音量+ = 确认当前选项"
  ui_print "  · 音量- = 切换到下一个选项"
  ui_print "  · 选项会循环显示：1→2→3→4→1..."
  ui_print " ============================================"
  ui_print " "
  ui_print " 选择精简模式："
  ui_print " "

  select_mode
  local choice=$?

  case $choice in
    1)
      ui_print " 轻度精简"
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
        "/system/product/data-app/MiuiScanner"
      ;;
    2)
      ui_print " 中度精简"
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
        "/system/product/priv-app/MIUIPersonalAssistantPhoneOS3" \
        "/system/product/priv-app/MiuiBarrage" \
        "/system/product/priv-app/MIUIContentExtension" \
        "/system/product/app/MIUISuperMarket_M2_M3"
      ask_dangerous
      ;;
    3)
      ui_print " 极限精简"
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
        "/system/product/app/MIUISuperMarket_M2_M3"
      ask_dangerous
      ;;
    4)
      ui_print " 自定义模式"
      ui_print "  每组：音量+ 精简 / 音量- 跳过"
      ui_print " "

      ui_print "--- AI/小爱 ---"
      ui_print "  音量+ 精简 / 音量- 跳过"
      if getVolumeKey; then
        add_to_remove "/system/product/app/XiaoaiRecommendation" "/system/product/app/AiasstVision"
        ui_print "  ✅ 已精简"
      else
        ui_print "  ⏭️ 跳过"
      fi

      ui_print "--- 搜索/游戏 ---"
      ui_print "  音量+ 精简 / 音量- 跳过"
      if getVolumeKey; then
        add_to_remove "/system/product/priv-app/MIUIQuickSearchBox" "/system/product/priv-app/MiGameCenterSDKService" "/system/product/priv-app/MiniGameService"
        ui_print "  ✅ 已精简"
      else
        ui_print "  ⏭️ 跳过"
      fi

      ui_print "--- 无障碍/宏 ---"
      ui_print "  音量+ 精简 / 音量- 跳过"
      if getVolumeKey; then
        add_to_remove "/system/product/app/SwitchAccess" "/system/product/app/com.xiaomi.macro" "/system/product/app/com.xiaomi.ugd"
        ui_print "  ✅ 已精简"
      else
        ui_print "  ⏭️ 跳过"
      fi

      ui_print "--- 系统预装 ---"
      ui_print "  音量+ 精简 / 音量- 跳过"
      if getVolumeKey; then
        add_to_remove "/system/product/data-app/DownloadProviderUi" "/system/product/data-app/MIUIGameCenter" "/system/product/data-app/MiuiScanner"
        ui_print "  ✅ 已精简"
      else
        ui_print "  ⏭️ 跳过"
      fi

      ui_print "--- 云备份 ---"
      ui_print "  音量+ 精简 / 音量- 跳过"
      if getVolumeKey; then
        add_to_remove "/system/product/app/MIUICloudService" "/system/product/app/MIUIMiCloudSync" "/system/product/priv-app/MIUICloudBackup"
        ui_print "  ✅ 已精简"
      else
        ui_print "  ⏭️ 跳过"
      fi

      ui_print "--- 跨屏协同 ---"
      ui_print "  音量+ 精简 / 音量- 跳过"
      if getVolumeKey; then
        add_to_remove "/system/product/priv-app/MirrorOS3"
        ui_print "  ✅ 已精简"
      else
        ui_print "  ⏭️ 跳过"
      fi

      ui_print "--- 汽车互联 ---"
      ui_print "  音量+ 精简 / 音量- 跳过"
      if getVolumeKey; then
        add_to_remove "/system/product/app/CarWith" "/system/product/app/MIS"
        ui_print "  ✅ 已精简"
      else
        ui_print "  ⏭️ 跳过"
      fi

      ui_print "--- 互联互通 ---"
      ui_print "  音量+ 精简 / 音量- 跳过"
      if getVolumeKey; then
        add_to_remove "/system/product/app/MiLinkOS3Cn" "/system/product/app/LyraWOS3CN"
        ui_print "  ✅ 已精简"
      else
        ui_print "  ⏭️ 跳过"
      fi

      ui_print "--- 澎湃AI引擎 ---"
      ui_print "  音量+ 精简 / 音量- 跳过"
      if getVolumeKey; then
        add_to_remove "/system/product/priv-app/MIUIAICR"
        ui_print "  ✅ 已精简"
      else
        ui_print "  ⏭️ 跳过"
      fi

      ui_print "--- 应用商店 ---"
      ui_print "  音量+ 精简 / 音量- 跳过"
      if getVolumeKey; then
        add_to_remove "/system/product/app/MIUISuperMarket_M2_M3"
        ui_print "  ✅ 已精简"
      else
        ui_print "  ⏭️ 跳过"
      fi

      ui_print "--- 负一屏/弹幕 ---"
      ui_print "  音量+ 精简 / 音量- 跳过"
      if getVolumeKey; then
        add_to_remove "/system/product/priv-app/MIUIPersonalAssistantPhoneOS3" "/system/product/priv-app/MiuiBarrage" "/system/product/priv-app/MIUIContentExtension"
        ui_print "  ✅ 已精简"
      else
        ui_print "  ⏭️ 跳过"
      fi

      ui_print "--- 窗口管理/报告/注册 ---"
      ui_print "  音量+ 精简 / 音量- 跳过"
      if getVolumeKey; then
        add_to_remove "/system/product/app/WMService" "/system/product/app/MIUIReporter" "/system/product/priv-app/AutoRegistration" "/system/product/priv-app/RegService"
        ui_print "  ✅ 已精简"
      else
        ui_print "  ⏭️ 跳过"
      fi

      ui_print "--- system_ext服务 ---"
      ui_print "  音量+ 精简 / 音量- 跳过"
      if getVolumeKey; then
        add_to_remove "/system/system_ext/app/MiSightService" "/system/system_ext/app/MiuiDaemon" "/system/system_ext/app/VsimCore" "/system/system_ext/priv-app/EmergencyInfo" "/system/system_ext/priv-app/PowerInsight" "/system/system_ext/priv-app/com.qualcomm.qti.services.systemhelper"
        ui_print "  ✅ 已精简"
      else
        ui_print "  ⏭️ 跳过"
      fi

      ask_dangerous
      ;;
  esac

  apply_remove
}

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
}
