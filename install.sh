#!/system/bin/sh

LATESTARTSERVICE=false
POSTFSDATA=false
PROPFILE=false
SKIPMOUNT=false

REPLACE=""

print_modname() {
  ui_print " "
  ui_print "=================================="
  ui_print "  HyperOS3 终极精简模块 v2.4.0"
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

add_to_replace() {
  for path in $@; do
    REPLACE="$REPLACE
$path"
  done
}

# 通用模块选择函数
# $1: 模块名称
# $2: 音量+描述
# $3: 音量-描述
# $4: 音量+精简列表
# $5: 音量-精简列表
choose_module() {
  local name="$1"
  local keep_desc="$2"
  local full_desc="$3"
  local keep_list="$4"
  local full_list="$5"

  ui_print "--- $name ---"
  ui_print "  音量+：$keep_desc"
  ui_print "  音量-：$full_desc"

  if getVolumeKey; then
    ui_print "  [OK] $keep_desc"
    [ -n "$keep_list" ] && add_to_replace $keep_list
  else
    ui_print "  [X] $full_desc"
    add_to_replace $full_list
  fi
}

select_mode() {
  local mode=1
  local max_mode=4

  while true; do
    case $mode in
      1)
        ui_print "  ============================"
        ui_print "  [1] 快速精简（推荐）"
        ui_print "      一键精简广告/推送/游戏"
        ui_print "  ============================"
        ;;
      2)
        ui_print "  ============================"
        ui_print "  [2] 标准精简"
        ui_print "      +云服务/负一屏/汽车互联"
        ui_print "  ============================"
        ;;
      3)
        ui_print "  ============================"
        ui_print "  [3] 深度精简"
        ui_print "      +系统服务/窗口管理/AI引擎"
        ui_print "  ============================"
        ;;
      4)
        ui_print "  ============================"
        ui_print "  [4] 自定义模式"
        ui_print "      每组可选保留核心或全精简"
        ui_print "  ============================"
        ;;
    esac

    ui_print "  音量+ 确认 / 音量- 切换"

    if getVolumeKey; then
      ui_print " "
      ui_print "  [OK] 已选择：模式$mode"
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
  ui_print "  音量+ = 确认/保留核心"
  ui_print "  音量- = 切换/全部精简"
  ui_print "  选项会循环显示：1->2->3->4->1..."
  ui_print " ============================================"
  ui_print " "
  ui_print " 选择精简模式："
  ui_print " "

  select_mode
  local choice=$?

  case $choice in
    1)
      ui_print "  [OK] 快速精简"
      ui_print "  只精简广告/推送/游戏/无障碍"
      ui_print "  保留所有核心功能"
      add_to_replace \
        "/system/product/app/XiaoaiRecommendation" \
        "/system/product/app/AiasstVision" \
        "/system/product/app/SwitchAccess" \
        "/system/product/app/com.xiaomi.macro" \
        "/system/product/app/com.xiaomi.ugd" \
        "/system/product/priv-app/MiGameCenterSDKService" \
        "/system/product/priv-app/MiniGameService" \
        "/system/product/data-app/MIUIGameCenter"
      ;;
    2)
      ui_print "  [OK] 标准精简"
      ui_print "  精简广告/推送/游戏/无障碍"
      ui_print "  +云服务/负一屏/汽车互联/互联互通"
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
      ui_print "  [OK] 深度精简"
      ui_print "  精简广告/推送/游戏/无障碍"
      ui_print "  +云服务/负一屏/汽车互联/互联互通"
      ui_print "  +系统服务/窗口管理/AI引擎"
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
      ui_print "  [OK] 自定义模式"
      ui_print "  每组可选保留核心或全精简"
      ui_print " "

      # AI/小爱模块
      choose_module "AI/小爱模块" \
        "保留核心（语音+唤醒）" \
        "全部精简（含小爱核心）" \
        "/system/product/app/AiasstVision" \
        "/system/product/app/XiaoaiRecommendation /system/product/app/AiasstVision"

      # 搜索/游戏
      choose_module "搜索/游戏" \
        "保留搜索框" \
        "全部精简（搜索+游戏SDK）" \
        "/system/product/priv-app/MiGameCenterSDKService /system/product/priv-app/MiniGameService" \
        "/system/product/priv-app/MIUIQuickSearchBox /system/product/priv-app/MiGameCenterSDKService /system/product/priv-app/MiniGameService"

      # 无障碍/宏
      choose_module "无障碍/宏" \
        "保留无障碍服务" \
        "全部精简（SwitchAccess+宏）" \
        "/system/product/app/com.xiaomi.macro /system/product/app/com.xiaomi.ugd" \
        "/system/product/app/SwitchAccess /system/product/app/com.xiaomi.macro /system/product/app/com.xiaomi.ugd"

      # 系统预装
      choose_module "系统预装" \
        "保留下载管理" \
        "全部精简（下载+游戏+扫一扫）" \
        "/system/product/data-app/MIUIGameCenter /system/product/data-app/MiuiScanner" \
        "/system/product/data-app/DownloadProviderUi /system/product/data-app/MIUIGameCenter /system/product/data-app/MiuiScanner"

      # 云备份
      choose_module "云备份" \
        "保留云服务基础" \
        "全部精简（云服务+同步+备份）" \
        "/system/product/app/MIUIMiCloudSync /system/product/priv-app/MIUICloudBackup" \
        "/system/product/app/MIUICloudService /system/product/app/MIUIMiCloudSync /system/product/priv-app/MIUICloudBackup"

      # 跨屏协同
      choose_module "跨屏协同" \
        "保留基础投屏" \
        "全部精简（MirrorOS3）" \
        "" \
        "/system/product/priv-app/MirrorOS3"

      # 汽车互联
      choose_module "汽车互联" \
        "保留基础连接" \
        "全部精简（CarWith+MIS）" \
        "/system/product/app/MIS" \
        "/system/product/app/CarWith /system/product/app/MIS"

      # 互联互通
      choose_module "互联互通" \
        "保留基础连接" \
        "全部精简（MiLink+Lyra）" \
        "/system/product/app/LyraWOS3CN" \
        "/system/product/app/MiLinkOS3Cn /system/product/app/LyraWOS3CN"

      # 澎湃AI引擎
      choose_module "澎湃AI引擎" \
        "保留基础AI服务" \
        "全部精简（MIUIAICR）" \
        "" \
        "/system/product/priv-app/MIUIAICR"

      # 应用商店
      choose_module "应用商店" \
        "保留基础商店" \
        "全部精简（MIUISuperMarket）" \
        "" \
        "/system/product/app/MIUISuperMarket_M2_M3"

      # 负一屏/弹幕
      choose_module "负一屏/弹幕" \
        "保留小组件/负一屏基础" \
        "全部精简（负一屏体系）" \
        "/system/product/priv-app/MiuiBarrage /system/product/priv-app/MIUIContentExtension" \
        "/system/product/priv-app/MIUIPersonalAssistantPhoneOS3 /system/product/priv-app/MiuiBarrage /system/product/priv-app/MIUIContentExtension"

      # 窗口管理/报告/注册
      choose_module "窗口管理/报告/注册" \
        "保留窗口管理" \
        "全部精简（WMService+报告+注册）" \
        "/system/product/app/MIUIReporter /system/product/priv-app/AutoRegistration /system/product/priv-app/RegService" \
        "/system/product/app/WMService /system/product/app/MIUIReporter /system/product/priv-app/AutoRegistration /system/product/priv-app/RegService"

      # system_ext服务
      choose_module "system_ext服务" \
        "保留MiSight+Daemon" \
        "全部精简（全部system_ext服务）" \
        "/system/system_ext/app/VsimCore /system/system_ext/priv-app/EmergencyInfo /system/system_ext/priv-app/PowerInsight /system/system_ext/priv-app/com.qualcomm.qti.services.systemhelper" \
        "/system/system_ext/app/MiSightService /system/system_ext/app/MiuiDaemon /system/system_ext/app/VsimCore /system/system_ext/priv-app/EmergencyInfo /system/system_ext/priv-app/PowerInsight /system/system_ext/priv-app/com.qualcomm.qti.services.systemhelper"
      ;;
  esac

  # 危险项确认
  ui_print " "
  ui_print "  [!!] 危险项确认（可跳过）："

  ui_print "  NFC服务 - 门禁/公交卡/付款可能失效"
  ui_print "  音量+ 精简 / 音量- 保留"
  if getVolumeKey; then
    add_to_replace "/system/product/app/NQNfcNci"
    ui_print "  [OK] 精简NFC"
  else
    ui_print "  [--] 保留NFC"
  fi

  ui_print "  系统安全组件 - 可能影响兼容性"
  ui_print "  音量+ 精简 / 音量- 保留"
  if getVolumeKey; then
    add_to_replace "/system/product/app/MIUIGuardProvider"
    ui_print "  [OK] 精简安全组件"
  else
    ui_print "  [--] 保留安全组件"
  fi

  ui_print "  搜狗输入法 - 请确保有其他输入法"
  ui_print "  音量+ 精简 / 音量- 保留"
  if getVolumeKey; then
    add_to_replace "/system/product/app/SogouIME"
    ui_print "  [OK] 精简搜狗输入法"
  else
    ui_print "  [--] 保留搜狗输入法"
  fi

  uninstall_data_apps
}

uninstall_data_apps() {
  echo "$REPLACE" | grep -q "MIUIGameCenter" && pm uninstall -k --user 0 com.xiaomi.gamecenter 2>/dev/null
  echo "$REPLACE" | grep -q "MiuiScanner" && pm uninstall -k --user 0 com.xiaomi.scanner 2>/dev/null
  echo "$REPLACE" | grep -q "DownloadProviderUi" && pm uninstall -k --user 0 com.android.providers.downloads.ui 2>/dev/null
}

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
}
