#!/system/bin/sh

LATESTARTSERVICE=false
POSTFSDATA=false
PROPFILE=false
SKIPMOUNT=false

REPLACE=""

print_modname() {
  local version=$(unzip -p "$ZIPFILE" module.prop 2>/dev/null | grep "^version=" | cut -d'=' -f2)
  [ -z "$version" ] && version="unknown"
  ui_print " "
  ui_print "=================================="
  ui_print "  📦 HyperOS3 终极精简模块 $version"
  ui_print "  👤 作者：温柔浩"
  ui_print "=================================="
  ui_print " "
}

getVolumeKey() {
  sleep 1
  local keyInfo=true
  while $keyInfo; do
    keyInfo=$(getevent -qlc 1 | grep KEY_VOLUME)
    if [ "$keyInfo" == "" ]; then
      continue
    else
      local isUpKey=$(echo $keyInfo | grep KEY_VOLUMEUP)
      [ "$isUpKey" != "" ] && return 0 || return 1
    fi
  done
}

add_to_replace() {
  for path in "$@"; do
    if [ -z "$REPLACE" ]; then
      REPLACE="$path"
    else
      REPLACE="$REPLACE
$path"
    fi
  done
}

choose_module() {
  local name="$1"
  local core_desc="$2"
  local keep_list="$3"
  local full_list="$4"
  local opt=1

  local delete_list=""
  for item in $full_list; do
    local found=0
    for keep in $keep_list; do
      [ "$item" = "$keep" ] && found=1 && break
    done
    [ $found -eq 0 ] && delete_list="$delete_list $item"
  done

  local max_opt=3
  [ -z "$delete_list" ] && max_opt=2

  while true; do
    ui_print " "
    ui_print " ───────────────────"
    ui_print " 📦 ${name}"
    if [ $max_opt -eq 2 ]; then
      case $opt in
        1) ui_print "   [1] ❌ 精简" ;;
        2) ui_print "   [2] ✅ 保留" ;;
      esac
    else
      case $opt in
        1) ui_print "   [1] ❌ 全部精简" ;;
        2) ui_print "   [2] 🔧 $core_desc" ;;
        3) ui_print "   [3] ✅ 全部保留" ;;
      esac
    fi
    ui_print "   🔊音量+ 确认 / 🔊音量- 切换"

    if getVolumeKey; then
      case $opt in
        1)
          ui_print "   ❌ 精简"
          add_to_replace $full_list
          ;;
        2)
          if [ $max_opt -eq 2 ]; then
            ui_print "   ✅ 保留"
          else
            ui_print "   🔧 $core_desc"
            [ -n "$delete_list" ] && add_to_replace $delete_list
          fi
          ;;
        3)
          ui_print "   ✅ 全部保留"
          ;;
      esac
      sleep 2
      return
    else
      opt=$((opt + 1))
      [ $opt -gt $max_opt ] && opt=1
    fi
  done
}

select_mode() {
  local mode=1
  local max_mode=4

  while true; do
    ui_print " "
    case $mode in
      1)
        ui_print " ✅ [1] 快速精简（推荐）"
        ui_print "     精简：广告/推送/游戏/无障碍"
        ui_print "     保留：所有核心功能"
        ui_print "     👉 适合：大部分用户，安全无风险"
        ;;
      2)
        ui_print " ⚡ [2] 标准精简"
        ui_print "     精简：广告/推送/游戏/无障碍/小爱视觉翻译"
        ui_print "     +云服务/跨屏协同/汽车互联/互联互通/应用商店"
        ui_print "     👉 适合：不用小米云服务和跨设备互联"
        ;;
      3)
        ui_print " 🔥 [3] 深度精简"
        ui_print "     精简：标准精简全部内容"
        ui_print "     +负一屏/弹幕/AI引擎/窗口管理/系统服务"
        ui_print "     ⚠️ 适合：追求极致精简，可能影响功能"
        ;;
      4)
        ui_print " 🎛️ [4] 自定义模式"
        ui_print "     每组功能单独选择"
        ui_print "     全部精简 / 保留核心 / 全部保留（不删）"
        ;;
    esac

    ui_print "   🔊音量+ 确认 / 🔊音量- 切换"

    if getVolumeKey; then
      ui_print " "
      ui_print "  ✅ 已选择：模式$mode"
      return $mode
    else
      mode=$((mode + 1))
      [ $mode -gt $max_mode ] && mode=1
    fi
  done
}

on_install() {
  ui_print " "
  ui_print " ============================================"
  ui_print "  📖 操作说明："
  ui_print "  🔊音量+ = 确认当前选项"
  ui_print "  🔊音量- = 切换到下一个选项"
  ui_print "  🔄 选项循环：1 -> 2 -> 3 -> 4 -> 1..."
  ui_print " "
  ui_print "  [1] [2] [3] 为预设模式，一键精简"
  ui_print "  [4] 自定义模式，每组单独选择"
  ui_print " ============================================"

  select_mode
  local choice=$?

  ui_print " "
  ui_print " ============================================"

  case $choice in
    1)
      ui_print "  ✅ [OK] 快速精简"
      ui_print "  精简：广告/推送/游戏/无障碍"
      ui_print "  保留：所有核心功能"
      ui_print " ============================================"
      add_to_replace \
        "/system/product/app/XiaoaiRecommendation" \
        "/system/product/app/SwitchAccess" \
        "/system/product/app/com.xiaomi.macro" \
        "/system/product/app/com.xiaomi.ugd" \
        "/system/product/priv-app/MiGameCenterSDKService" \
        "/system/product/priv-app/MiniGameService" \
        "/system/product/data-app/MIUIGameCenter"
      ;;
    2)
      ui_print "  ⚡ [OK] 标准精简"
      ui_print "  精简：广告/推送/游戏/无障碍/小爱视觉翻译"
      ui_print "  +云服务/跨屏协同/汽车互联/互联互通/应用商店"
      ui_print " ============================================"
      add_to_replace \
        "/system/product/app/XiaoaiRecommendation" \
        "/system/product/app/AiasstVision" \
        "/system/product/app/SwitchAccess" \
        "/system/product/app/com.xiaomi.macro" \
        "/system/product/app/com.xiaomi.ugd" \
        "/system/product/priv-app/MiGameCenterSDKService" \
        "/system/product/priv-app/MiniGameService" \
        "/system/product/data-app/MIUIGameCenter" \
        "/system/product/app/MIUICloudService" \
        "/system/product/app/MIUIMiCloudSync" \
        "/system/product/priv-app/MIUICloudBackup" \
        "/system/product/priv-app/MirrorOS3" \
        "/system/product/app/CarWith" \
        "/system/product/app/MIS" \
        "/system/product/app/MiLinkOS3Cn" \
        "/system/product/app/LyraWOS3CN" \
        "/system/product/app/MIUISuperMarket_M2_M3"
      ;;
    3)
      ui_print "  🔥 [OK] 深度精简"
      ui_print "  精简：广告/推送/游戏/无障碍"
      ui_print "  +云服务/跨屏协同/汽车互联/互联互通/应用商店"
      ui_print "  +负一屏/弹幕/AI引擎/窗口管理/系统服务"
      ui_print " ============================================"
      add_to_replace \
        "/system/product/app/XiaoaiRecommendation" \
        "/system/product/app/VoiceAssistAndroidT" \
        "/system/product/app/VoiceTrigger" \
        "/system/product/app/AiasstVision" \
        "/system/product/app/MIUIAiasstService" \
        "/system/product/app/SwitchAccess" \
        "/system/product/app/com.xiaomi.macro" \
        "/system/product/app/com.xiaomi.ugd" \
        "/system/product/priv-app/MiGameCenterSDKService" \
        "/system/product/priv-app/MiniGameService" \
        "/system/product/data-app/MIUIGameCenter" \
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
      ;;
    4)
      ui_print "  🎛️ [OK] 自定义模式"
      ui_print "  每组可选：全部保留（不删） / 保留核心（删部分） / 全部精简（全删）"
      ui_print "  🔊音量+ 确认 / 🔊音量- 切换"
      ui_print " ============================================"

      choose_module "🤖 AI/小爱（小爱推荐+超级小爱+语音唤醒+小爱视觉翻译+小爱服务）" \
        "保留（超级小爱+语音唤醒）" \
        "/system/product/app/VoiceAssistAndroidT /system/product/app/VoiceTrigger" \
        "/system/product/app/XiaoaiRecommendation /system/product/app/VoiceAssistAndroidT /system/product/app/VoiceTrigger /system/product/app/AiasstVision /system/product/app/MIUIAiasstService"

      choose_module "🔍 搜索/游戏（全局搜索+游戏服务+小游戏服务）" \
        "保留（全局搜索）" \
        "/system/product/priv-app/MIUIQuickSearchBox" \
        "/system/product/priv-app/MIUIQuickSearchBox /system/product/priv-app/MiGameCenterSDKService /system/product/priv-app/MiniGameService"

      choose_module "♿ 无障碍/宏（无障碍开关+宏+GPU驱动更新）" \
        "保留（无障碍开关）" \
        "/system/product/app/SwitchAccess" \
        "/system/product/app/SwitchAccess /system/product/app/com.xiaomi.macro /system/product/app/com.xiaomi.ugd"

      choose_module "📱 系统预装（下载管理+游戏中心+扫一扫）" \
        "保留（下载管理）" \
        "/system/product/data-app/DownloadProviderUi" \
        "/system/product/data-app/DownloadProviderUi /system/product/data-app/MIUIGameCenter /system/product/data-app/MiuiScanner"

      choose_module "☁️ 云备份（小米云服务+小米云同步+小米云备份）" \
        "保留（小米云服务）" \
        "/system/product/app/MIUICloudService" \
        "/system/product/app/MIUICloudService /system/product/app/MIUIMiCloudSync /system/product/priv-app/MIUICloudBackup"

      choose_module "📺 跨屏协同（小米妙享）" \
        "保留（小米妙享）" \
        "/system/product/priv-app/MirrorOS3" \
        "/system/product/priv-app/MirrorOS3"

      choose_module "🚗 汽车互联（小米汽车互联）" \
        "保留（小米汽车互联）" \
        "/system/product/app/CarWith" \
        "/system/product/app/CarWith"

      choose_module "🔗 互联互通（互联互通+跨设备通信+小米互联服务）" \
        "保留（互联互通+小米互联服务）" \
        "/system/product/app/MiLinkOS3Cn /system/product/app/MIS" \
        "/system/product/app/MiLinkOS3Cn /system/product/app/LyraWOS3CN /system/product/app/MIS"

      choose_module "🧠 澎湃AI引擎（小米澎湃AI引擎）" \
        "保留（小米澎湃AI引擎）" \
        "/system/product/priv-app/MIUIAICR" \
        "/system/product/priv-app/MIUIAICR"

      choose_module "🛒 应用商店（小米应用商店）" \
        "保留（小米应用商店）" \
        "/system/product/app/MIUISuperMarket_M2_M3" \
        "/system/product/app/MIUISuperMarket_M2_M3"

      choose_module "📋 负一屏/弹幕（智能助理+弹幕通知+内容扩展）" \
        "保留（智能助理）" \
        "/system/product/priv-app/MIUIPersonalAssistantPhoneOS3" \
        "/system/product/priv-app/MIUIPersonalAssistantPhoneOS3 /system/product/priv-app/MiuiBarrage /system/product/priv-app/MIUIContentExtension"

      choose_module "📊 窗口管理/报告/注册（窗口管理+UI报告+注册服务）" \
        "保留（窗口管理）" \
        "/system/product/app/WMService" \
        "/system/product/app/WMService /system/product/app/MIUIReporter /system/product/priv-app/AutoRegistration /system/product/priv-app/RegService"

      choose_module "⚙️ 系统服务（质量监控+系统守护+虚拟SIM+紧急信息+功耗分析+系统助手）" \
        "保留（质量监控+系统守护）" \
        "/system/system_ext/app/MiSightService /system/system_ext/app/MiuiDaemon" \
        "/system/system_ext/app/MiSightService /system/system_ext/app/MiuiDaemon /system/system_ext/app/VsimCore /system/system_ext/priv-app/EmergencyInfo /system/system_ext/priv-app/PowerInsight /system/system_ext/priv-app/com.qualcomm.qti.services.systemhelper"
      ;;
  esac

  ui_print " "
  ui_print " ============================================"
  ui_print "  ⚠️ 危险项确认（可跳过）"
  ui_print " ============================================"

  ui_print " "
  ui_print "  📱 NFC服务 - 门禁/公交卡/付款可能失效"
  ui_print "  🔊音量+ 精简 / 🔊音量- 保留"
  if getVolumeKey; then
    add_to_replace "/system/product/app/NQNfcNci"
    ui_print "  ❌ 精简NFC"
  else
    ui_print "  ✅ 保留NFC"
  fi

  ui_print " "
  ui_print "  🛡️ 系统安全组件 - 可能影响兼容性"
  ui_print "  🔊音量+ 精简 / 🔊音量- 保留"
  if getVolumeKey; then
    add_to_replace "/system/product/app/MIUIGuardProvider"
    ui_print "  ❌ 精简安全组件"
  else
    ui_print "  ✅ 保留安全组件"
  fi

  ui_print " "
  ui_print "  ⌨️ 搜狗输入法 - 请确保有其他输入法"
  ui_print "  🔊音量+ 精简 / 🔊音量- 保留"
  if getVolumeKey; then
    add_to_replace "/system/product/app/SogouIME"
    ui_print "  ❌ 精简搜狗输入法"
  else
    ui_print "  ✅ 保留搜狗输入法"
  fi

  ui_print " "
  ui_print "  ⌨️ 讯飞输入法小米版 - 请确保有其他输入法"
  ui_print "  🔊音量+ 精简 / 🔊音量- 保留"
  if getVolumeKey; then
    add_to_replace "/data/app/iFlytekIME"
    ui_print "  ❌ 精简讯飞输入法"
  else
    ui_print "  ✅ 保留讯飞输入法"
  fi

  ui_print " "
  ui_print " ============================================"
  ui_print "  📋 本次精简列表："
  local count=0
  for item in $REPLACE; do
    local app=$(basename "$item")
    ui_print "   ❌ $app"
    count=$((count + 1))
  done
  ui_print "   共 $count 个应用"
  ui_print " ============================================"
  ui_print "  🔊音量+ 确认精简 / 🔊音量- 取消"
  ui_print " ============================================"

  if getVolumeKey; then
    ui_print "  ⏳ 正在应用精简..."
    uninstall_data_apps
  else
    ui_print "  ❎ 已取消精简"
  fi
}

uninstall_data_apps() {
  local record_file="$MODPATH/.data_apps_removed"
  : > "$record_file"

  if echo "$REPLACE" | grep -q "MIUIGameCenter"; then
    pm uninstall -k --user 0 com.xiaomi.gamecenter 2>/dev/null
    echo "com.xiaomi.gamecenter" >> "$record_file"
  fi
  if echo "$REPLACE" | grep -q "MiuiScanner"; then
    pm uninstall -k --user 0 com.xiaomi.scanner 2>/dev/null
    echo "com.xiaomi.scanner" >> "$record_file"
  fi
  if echo "$REPLACE" | grep -q "DownloadProviderUi"; then
    pm uninstall -k --user 0 com.android.providers.downloads.ui 2>/dev/null
    echo "com.android.providers.downloads.ui" >> "$record_file"
  fi
}

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
}
