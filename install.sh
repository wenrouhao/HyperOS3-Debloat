#!/system/bin/sh

LATESTARTSERVICE=false
POSTFSDATA=false
PROPFILE=false
SKIPMOUNT=false

REPLACE=""
APEX_APPS=""

# 打印模块信息
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

# 获取音量键输入（音量+返回0，音量-返回1）
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

# 添加应用到精简列表
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

# 添加 apex 应用到精简列表
add_apex_app() {
  for pkg in "$@"; do
    if [ -z "$APEX_APPS" ]; then
      APEX_APPS="$pkg"
    else
      APEX_APPS="$APEX_APPS
$pkg"
    fi
  done
}

# 执行 apex 应用卸载
do_uninstall_apex() {
  [ -z "$APEX_APPS" ] && return
  for pkg in $APEX_APPS; do
    pm uninstall -k --user 0 "$pkg" 2>/dev/null
    echo "$pkg" >> "$MODPATH/.apex_apps_removed"
  done
}

# 显示精简列表并确认
show_replace_list() {
  ui_print " "
  ui_print " ============================================"
  ui_print "  📋 本次精简列表："
  local count=0
  for item in $REPLACE; do
    local app=$(basename "$item")
    ui_print "   ❌ $app"
    count=$((count + 1))
  done
  for item in $APEX_APPS; do
    ui_print "   ❌ $item（apex）"
    count=$((count + 1))
  done
  ui_print "   共 $count 个应用"
  ui_print " ============================================"
  ui_print "  🔊音量+ 确认精简 / 🔊音量- 取消"
  ui_print " ============================================"

  if getVolumeKey; then
    ui_print "  ⏳ 正在应用精简..."
    uninstall_data_apps
    do_uninstall_apex
  else
    ui_print "  ❎ 已取消精简"
  fi
}

# 选择模式（快速/标准/深度/自定义）
select_mode() {
  local mode=1
  local max_mode=4

  while true; do
    ui_print " "
    case $mode in
      1)
        ui_print " ✅ [1] 快速精简（推荐）"
        ui_print "     精简：广告追踪 + 游戏中心"
        ui_print "     保留：所有核心功能"
        ui_print "     👉 适合：大部分用户，安全无风险"
        ;;
      2)
        ui_print " ⚡ [2] 标准精简"
        ui_print "     精简：广告追踪 + 游戏中心"
        ui_print "     +云服务/跨屏协同/汽车互联/互联互通"
        ui_print "     👉 适合：不用小米云服务和跨设备互联"
        ;;
      3)
        ui_print " 🔥 [3] 深度精简"
        ui_print "     精简：标准精简全部内容"
        ui_print "     +AI/小爱 + 负一屏/内容 + 系统服务 + 无障碍/宏"
        ui_print "     ⚠️ 适合：追求极致精简，可能影响功能"
        ;;
      4)
        ui_print " 🎛️ [4] 自定义模式"
        ui_print "     每组功能单独选择"
        ui_print "     可逐个应用选择精简或保留"
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

# 自定义模式：逐个分组选择
custom_mode() {
  ui_print "  🎛️ [OK] 自定义模式"
  ui_print "  🔊音量+ 精简此组 / 🔊音量- 进入选择"
  ui_print " ============================================"

  # 分组1：AI/小爱
  ui_print " "
  ui_print " 📦 [1/7] AI/小爱"
  ui_print "   包含：小爱推荐+超级小爱+语音唤醒+小爱视觉翻译+小爱服务+澎湃AI引擎"
  ui_print "   🔊音量+ 精简此组 / 🔊音量- 进入选择"

  if getVolumeKey; then
    # 音量+ = 精简整个分组
    ui_print "   ❌ 精简此组"
    add_to_replace \
      "/system/product/app/XiaoaiRecommendation" \
      "/system/product/app/VoiceAssistAndroidT" \
      "/system/product/app/VoiceTrigger" \
      "/system/product/app/AiasstVision" \
      "/system/product/app/MIUIAiasstService" \
      "/system/product/priv-app/MIUIAICR"
  else
    # 音量- = 进入逐个选择
    custom_group "AI/小爱" \
      "/system/product/app/XiaoaiRecommendation" "小爱推荐" \
      "/system/product/app/VoiceAssistAndroidT" "超级小爱" \
      "/system/product/app/VoiceTrigger" "语音唤醒" \
      "/system/product/app/AiasstVision" "小爱视觉翻译" \
      "/system/product/app/MIUIAiasstService" "小爱服务" \
      "/system/product/priv-app/MIUIAICR" "澎湃AI引擎"
  fi

  # 分组2：游戏中心
  ui_print " "
  ui_print " 📦 [2/7] 游戏中心"
  ui_print "   包含：游戏服务SDK+小游戏服务+游戏中心+游戏高能时刻"
  ui_print "   🔊音量+ 精简此组 / 🔊音量- 进入选择"

  if getVolumeKey; then
    # 音量+ = 精简整个分组
    ui_print "   ❌ 精简此组"
    add_to_replace \
      "/system/product/priv-app/MiGameCenterSDKService" \
      "/system/product/priv-app/MiniGameService" \
      "/system/product/data-app/MIUIGameCenter" \
      "/system/product/app/MiGameService_8550"
  else
    # 音量- = 进入逐个选择
    custom_group "游戏中心" \
      "/system/product/priv-app/MiGameCenterSDKService" "游戏服务SDK" \
      "/system/product/priv-app/MiniGameService" "小游戏服务" \
      "/system/product/data-app/MIUIGameCenter" "游戏中心" \
      "/system/product/app/MiGameService_8550" "游戏高能时刻"
  fi

  # 分组3：云服务/互联
  ui_print " "
  ui_print " 📦 [3/7] 云服务/互联"
  ui_print "   包含：云服务+云同步+云备份+妙享+汽车互联+互联互通"
  ui_print "   🔊音量+ 精简此组 / 🔊音量- 进入选择"

  if getVolumeKey; then
    # 音量+ = 精简整个分组
    ui_print "   ❌ 精简此组"
    add_to_replace \
      "/system/product/app/MIUICloudService" \
      "/system/product/app/MIUIMiCloudSync" \
      "/system/product/priv-app/MIUICloudBackup" \
      "/system/product/priv-app/MirrorOS3" \
      "/system/product/app/CarWith" \
      "/system/product/app/MIS" \
      "/system/product/app/MiLinkOS3Cn" \
      "/system/product/app/LyraWOS3CN"
  else
    # 音量- = 进入逐个选择
    custom_group "云服务/互联" \
      "/system/product/app/MIUICloudService" "小米云服务" \
      "/system/product/app/MIUIMiCloudSync" "小米云同步" \
      "/system/product/priv-app/MIUICloudBackup" "小米云备份" \
      "/system/product/priv-app/MirrorOS3" "小米妙享" \
      "/system/product/app/CarWith" "小米汽车互联" \
      "/system/product/app/MIS" "小米汽车互联服务" \
      "/system/product/app/MiLinkOS3Cn" "互联互通" \
      "/system/product/app/LyraWOS3CN" "跨设备通信"
  fi

  # 分组4：广告/追踪
  ui_print " "
  ui_print " 📦 [4/7] 广告/追踪"
  ui_print "   包含：智能服务+安全追踪服务+广告隐私权+AnalyticsCore"
  ui_print "   🔊音量+ 精简此组 / 🔊音量- 进入选择"

  if getVolumeKey; then
    # 音量+ = 精简整个分组
    ui_print "   ❌ 精简此组"
    add_to_replace \
      "/system/product/app/MSA" \
      "/system/product/app/SecurityOnetrackService" \
      "/system/product/app/AnalyticsCore"
    add_apex_app "com.android.adservices.api"
  else
    # 音量- = 进入逐个选择
    custom_group "广告/追踪" \
      "/system/product/app/MSA" "智能服务" \
      "/system/product/app/SecurityOnetrackService" "安全追踪服务" \
      "/system/product/app/AnalyticsCore" "AnalyticsCore"
    # apex 应用单独处理
    ui_print " "
    ui_print "   [4/4] 广告隐私权（apex）"
    ui_print "     🔊音量+ 精简 / 🔊音量- 保留"
    if getVolumeKey; then
      add_apex_app "com.android.adservices.api"
      ui_print "     ❌ 精简（apex）"
    else
      ui_print "     ✅ 保留"
    fi
  fi

  # 分组5：负一屏/内容
  ui_print " "
  ui_print " 📦 [5/7] 负一屏/内容"
  ui_print "   包含：智能助理+弹幕通知+内容扩展"
  ui_print "   🔊音量+ 精简此组 / 🔊音量- 进入选择"

  if getVolumeKey; then
    # 音量+ = 精简整个分组
    ui_print "   ❌ 精简此组"
    add_to_replace \
      "/system/product/priv-app/MIUIPersonalAssistantPhoneOS3" \
      "/system/product/priv-app/MiuiBarrage" \
      "/system/product/priv-app/MIUIContentExtension"
  else
    # 音量- = 进入逐个选择
    custom_group "负一屏/内容" \
      "/system/product/priv-app/MIUIPersonalAssistantPhoneOS3" "智能助理" \
      "/system/product/priv-app/MiuiBarrage" "弹幕通知" \
      "/system/product/priv-app/MIUIContentExtension" "内容扩展"
  fi

  # 分组6：系统服务
  ui_print " "
  ui_print " 📦 [6/7] 系统服务"
  ui_print "   包含：下载管理+扫一扫+打印+工作设置+窗口管理+报告+注册+系统服务+网络定位+健康数据+全局搜索"
  ui_print "   🔊音量+ 精简此组 / 🔊音量- 进入选择"

  if getVolumeKey; then
    # 音量+ = 精简整个分组
    ui_print "   ❌ 精简此组"
    add_to_replace \
      "/system/product/data-app/DownloadProviderUi" \
      "/system/product/data-app/MiuiScanner" \
      "/system/priv-app/BuiltInPrintService" \
      "/system/system_ext/app/MiuiPrintSpooler" \
      "/system/priv-app/ManagedProvisioning" \
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
      "/system/priv-app/SystemHelper" \
      "/system/product/priv-app/MetokNLP" \
      "/system/product/priv-app/MIUIQuickSearchBox"
    add_apex_app "com.android.healthconnect.controller"
  else
    # 音量- = 进入逐个选择
    custom_group_with_shortcut "系统服务" \
      "/system/product/data-app/DownloadProviderUi" "下载管理" \
      "/system/product/data-app/MiuiScanner" "扫一扫" \
      "/system/priv-app/BuiltInPrintService" "系统打印服务" \
      "/system/system_ext/app/MiuiPrintSpooler" "打印处理服务" \
      "/system/priv-app/ManagedProvisioning" "工作设置" \
      "/system/product/app/WMService" "窗口管理" \
      "/system/product/app/MIUIReporter" "UI报告" \
      "/system/product/priv-app/AutoRegistration" "注册服务" \
      "/system/product/priv-app/RegService" "注册服务" \
      "/system/system_ext/app/MiSightService" "质量监控" \
      "/system/system_ext/app/MiuiDaemon" "系统守护" \
      "/system/system_ext/app/VsimCore" "虚拟SIM" \
      "/system/system_ext/priv-app/EmergencyInfo" "紧急信息" \
      "/system/system_ext/priv-app/PowerInsight" "功耗分析" \
      "/system/system_ext/priv-app/com.qualcomm.qti.services.systemhelper" "系统助手" \
      "/system/priv-app/SystemHelper" "SystemHelper" \
      "/system/product/priv-app/MetokNLP" "网络位置服务" \
      "/system/product/priv-app/MIUIQuickSearchBox" "全局搜索"
    # apex 应用单独处理
    ui_print " "
    ui_print "   [19/19] 健康数据共享（apex）"
    ui_print "     🔊音量+ 精简 / 🔊音量- 保留"
    if getVolumeKey; then
      add_apex_app "com.android.healthconnect.controller"
      ui_print "     ❌ 精简（apex）"
    else
      ui_print "     ✅ 保留"
    fi
  fi

  # 分组7：无障碍/宏
  ui_print " "
  ui_print " 📦 [7/7] 无障碍/宏"
  ui_print "   包含：无障碍开关+宏+GPU驱动更新"
  ui_print "   🔊音量+ 精简此组 / 🔊音量- 进入选择"

  if getVolumeKey; then
    # 音量+ = 精简整个分组
    ui_print "   ❌ 精简此组"
    add_to_replace \
      "/system/product/app/SwitchAccess" \
      "/system/product/app/com.xiaomi.macro" \
      "/system/product/app/com.xiaomi.ugd"
  else
    # 音量- = 进入逐个选择
    custom_group "无障碍/宏" \
      "/system/product/app/SwitchAccess" "无障碍开关" \
      "/system/product/app/com.xiaomi.macro" "宏" \
      "/system/product/app/com.xiaomi.ugd" "GPU驱动更新"
  fi
}

# 自定义模式：逐个应用选择（兼容 sh）
# 参数：分组名 应用路径1 应用名1 应用路径2 应用名2 ...
custom_group() {
  local group_name="$1"
  shift
  local total=$(( $# / 2 ))
  local i=1

  ui_print " "
  ui_print " 📦 ${group_name} - 逐个选择"
  ui_print "   🔊音量+ 精简 / 🔊音量- 保留"

  while [ $# -ge 2 ]; do
    local app_path="$1"
    local app_name="$2"
    shift 2

    ui_print " "
    ui_print "   [${i}/${total}] ${app_name}"

    if getVolumeKey; then
      add_to_replace "$app_path"
      ui_print "     ❌ 精简"
    else
      ui_print "     ✅ 保留"
    fi
    i=$((i + 1))
  done

  ui_print " "
  ui_print " 📦 ${group_name} - 选择完成"
}

# 自定义模式：带快捷选项的应用选择（兼容 sh）
# 参数：分组名 应用路径1 应用名1 应用路径2 应用名2 ...
custom_group_with_shortcut() {
  local group_name="$1"
  shift
  local total=$(( $# / 2 ))
  local opt=1
  local all_args="$@"

  ui_print " "
  ui_print " 📦 ${group_name} - 选择方式"
  ui_print "   🔊音量+ 确认 / 🔊音量- 切换"

  while true; do
    case $opt in
      1) ui_print "   [1] ❌ 全部精简" ;;
      2) ui_print "   [2] ✅ 全部保留" ;;
      3) ui_print "   [3] 🔧 逐个选择" ;;
    esac

    if getVolumeKey; then
      case $opt in
        1)
          ui_print "   ❌ 全部精简"
          local _path=""
          local _name=""
          local _args="$all_args"
          while [ -n "$_args" ]; do
            _path=$(echo "$_args" | cut -d' ' -f1)
            _name=$(echo "$_args" | cut -d' ' -f2)
            add_to_replace "$_path"
            _args=$(echo "$_args" | cut -d' ' -f3-)
          done
          ;;
        2)
          ui_print "   ✅ 全部保留"
          ;;
        3)
          ui_print "   🔧 逐个选择"
          custom_group "$group_name" $all_args
          ;;
      esac
      return
    else
      opt=$((opt + 1))
      [ $opt -gt 3 ] && opt=1
    fi
  done
}

# 危险项确认
dangerous_items() {
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
  ui_print "  📡 Cell Broadcast Service - 紧急警报服务"
  ui_print "  ⚠️ 精简后收不到地震/灾害预警"
  ui_print "  🔊音量+ 精简 / 🔊音量- 保留"
  if getVolumeKey; then
    add_to_replace "/system/priv-app/CellBroadcastServiceModulePlatform"
    ui_print "  ❌ 精简紧急警报"
  else
    ui_print "  ✅ 保留紧急警报"
  fi

  ui_print " "
  ui_print "  💳 小米智能卡 - NFC公交卡/门禁/付款"
  ui_print "  ⚠️ 精简后门禁/公交卡/付款全部失效"
  ui_print "  🔊音量+ 精简 / 🔊音量- 保留"
  if getVolumeKey; then
    add_to_replace "/system/product/app/MINextpay" "/system/product/app/MITSMClient"
    ui_print "  ❌ 精简智能卡"
  else
    ui_print "  ✅ 保留智能卡"
  fi

  ui_print " "
  ui_print "  💰 米币支付 - 小米支付服务"
  ui_print "  🔊音量+ 精简 / 🔊音量- 保留"
  if getVolumeKey; then
    add_to_replace "/system/product/app/PaymentService"
    ui_print "  ❌ 精简米币支付"
  else
    ui_print "  ✅ 保留米币支付"
  fi

  ui_print " "
  ui_print "  🛒 小米应用商店 - 应用下载"
  ui_print "  🔊音量+ 精简 / 🔊音量- 保留"
  if getVolumeKey; then
    add_to_replace "/system/product/app/MIUISuperMarket_M2_M3"
    ui_print "  ❌ 精简应用商店"
  else
    ui_print "  ✅ 保留应用商店"
  fi
}

# 主安装流程
on_install() {
  restore_data_apps

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
      ui_print "  精简：广告追踪 + 游戏中心"
      ui_print "  保留：所有核心功能"
      ui_print " ============================================"
      add_to_replace \
        "/system/product/app/MSA" \
        "/system/product/app/SecurityOnetrackService" \
        "/system/product/app/AnalyticsCore" \
        "/system/product/priv-app/MiGameCenterSDKService" \
        "/system/product/priv-app/MiniGameService" \
        "/system/product/data-app/MIUIGameCenter" \
        "/system/product/app/MiGameService_8550"
      add_apex_app "com.android.adservices.api"
      ;;
    2)
      ui_print "  ⚡ [OK] 标准精简"
      ui_print "  精简：广告追踪 + 游戏中心"
      ui_print "  +云服务/跨屏协同/汽车互联/互联互通"
      ui_print " ============================================"
      add_to_replace \
        "/system/product/app/MSA" \
        "/system/product/app/SecurityOnetrackService" \
        "/system/product/app/AnalyticsCore" \
        "/system/product/priv-app/MiGameCenterSDKService" \
        "/system/product/priv-app/MiniGameService" \
        "/system/product/data-app/MIUIGameCenter" \
        "/system/product/app/MiGameService_8550" \
        "/system/product/app/MIUICloudService" \
        "/system/product/app/MIUIMiCloudSync" \
        "/system/product/priv-app/MIUICloudBackup" \
        "/system/product/priv-app/MirrorOS3" \
        "/system/product/app/CarWith" \
        "/system/product/app/MIS" \
        "/system/product/app/MiLinkOS3Cn" \
        "/system/product/app/LyraWOS3CN"
      add_apex_app "com.android.adservices.api"
      ;;
    3)
      ui_print "  🔥 [OK] 深度精简"
      ui_print "  精简：标准精简全部内容"
      ui_print "  +AI/小爱 + 负一屏/内容 + 系统服务 + 无障碍/宏"
      ui_print " ============================================"
      add_to_replace \
        "/system/product/app/MSA" \
        "/system/product/app/SecurityOnetrackService" \
        "/system/product/app/AnalyticsCore" \
        "/system/product/priv-app/MiGameCenterSDKService" \
        "/system/product/priv-app/MiniGameService" \
        "/system/product/data-app/MIUIGameCenter" \
        "/system/product/app/MiGameService_8550" \
        "/system/product/app/MIUICloudService" \
        "/system/product/app/MIUIMiCloudSync" \
        "/system/product/priv-app/MIUICloudBackup" \
        "/system/product/priv-app/MirrorOS3" \
        "/system/product/app/CarWith" \
        "/system/product/app/MIS" \
        "/system/product/app/MiLinkOS3Cn" \
        "/system/product/app/LyraWOS3CN" \
        "/system/product/app/XiaoaiRecommendation" \
        "/system/product/app/VoiceAssistAndroidT" \
        "/system/product/app/VoiceTrigger" \
        "/system/product/app/AiasstVision" \
        "/system/product/app/MIUIAiasstService" \
        "/system/product/priv-app/MIUIAICR" \
        "/system/product/priv-app/MIUIPersonalAssistantPhoneOS3" \
        "/system/product/priv-app/MiuiBarrage" \
        "/system/product/priv-app/MIUIContentExtension" \
        "/system/product/data-app/DownloadProviderUi" \
        "/system/product/data-app/MiuiScanner" \
        "/system/priv-app/BuiltInPrintService" \
        "/system/system_ext/app/MiuiPrintSpooler" \
        "/system/priv-app/ManagedProvisioning" \
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
        "/system/priv-app/SystemHelper" \
        "/system/product/priv-app/MetokNLP" \
        "/system/product/priv-app/MIUIQuickSearchBox" \
        "/system/product/app/SwitchAccess" \
        "/system/product/app/com.xiaomi.macro" \
        "/system/product/app/com.xiaomi.ugd"
      add_apex_app "com.android.adservices.api" "com.android.healthconnect.controller"
      ;;
    4)
      custom_mode
      ;;
  esac

  # 危险项确认
  dangerous_items

  # 显示精简列表并确认
  show_replace_list
}

# 恢复之前精简的应用（覆盖安装时）
restore_data_apps() {
  # 恢复 data-app
  local old_record="/data/adb/modules/$MODID/.data_apps_removed"
  if [ -f "$old_record" ]; then
    while IFS= read -r pkg; do
      [ -n "$pkg" ] && pm install-existing --user 0 "$pkg" 2>/dev/null
    done < "$old_record"
  fi

  # 恢复 apex 应用
  local apex_record="/data/adb/modules/$MODID/.apex_apps_removed"
  if [ -f "$apex_record" ]; then
    while IFS= read -r pkg; do
      [ -n "$pkg" ] && pm install-existing --user 0 "$pkg" 2>/dev/null
    done < "$apex_record"
  fi
}

# 精简data-app
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
  # 确保 product 和 system_ext 目录有执行权限（兼容独立分区设备）
  [ -d "$MODPATH/system/product" ] && set_perm_recursive $MODPATH/system/product 0 0 0755 0644
  [ -d "$MODPATH/system/system_ext" ] && set_perm_recursive $MODPATH/system/system_ext 0 0 0755 0644
}
