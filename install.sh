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
  while true; do
    local keyInfo=$(getevent -qlc 1 | grep KEY_VOLUME)
    if [ -n "$keyInfo" ]; then
      local isUpKey=$(echo "$keyInfo" | grep KEY_VOLUMEUP)
      [ -n "$isUpKey" ] && return 0 || return 1
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

# 解压数据文件
unzip -o "$ZIPFILE" -d "$MODPATH" 2>/dev/null
. $MODPATH/pkg_map.sh

# 卸载 REPLACE 应用的 data 分区副本（防止用户更新过的应用绕过精简）
uninstall_replace_apps() {
  local record_file="$MODPATH/.data_apps_removed"
  : > "$record_file"
  for item in $REPLACE; do
    local pkg=$(get_pkg_name "$item")
    [ -z "$pkg" ] && continue
    if pm uninstall -k --user 0 "$pkg" >/dev/null 2>&1; then
      echo "$pkg" >> "$record_file"
    fi
  done
}

# 生成 apps.conf 配置文件（供 WebUI 和 post-fs-data.sh 使用）
generate_apps_conf() {
  local conf="$MODPATH/webroot/apps.conf"
  local old_conf="/data/adb/modules/$MODID/webroot/apps.conf"
  mkdir -p "$MODPATH/webroot"
  echo "# HyperOS3 Debloat 配置" > "$conf"
  echo "# 格式：路径|显示名|包名|状态（1=精简 0=保留）|分组" >> "$conf"

  # 记录 apps.db 中的路径
  local db_paths=""
  local line
  while IFS= read -r line; do
    case "$line" in \#*|"") continue ;; esac
    local path=$(echo "$line" | cut -d'|' -f1)
    local display=$(echo "$line" | cut -d'|' -f2)
    local pkg=$(echo "$line" | cut -d'|' -f3)
    local group=$(echo "$line" | cut -d'|' -f4)
    db_paths="$db_paths
$path"
    local status=0
    echo "$REPLACE" | grep -qxF "$path" && status=1
    # APEX 应用检查
    case "$path" in apex:*)
      local apex_pkg="${path#apex:}"
      echo "$APEX_APPS" | grep -qxF "$apex_pkg" && status=1
    ;; esac
    echo "$path|$display|$pkg|$status|$group" >> "$conf"
  done < "$APPS_DB"

  # 保留旧 apps.conf 中的自定义应用（不在 apps.db 中的）
  if [ -f "$old_conf" ]; then
    while IFS='|' read -r _p _n _pkg _st _g; do
      [ -z "$_p" ] && continue; case "$_p" in \#*) continue ;; esac
      case "$db_paths" in
        *"$_p"*) continue ;;
      esac
      echo "$_p|$_n|$_pkg|$_st|$_g" >> "$conf"
    done < "$old_conf"
  fi
}

# 记录 REPLACE 目录（供 post-fs-data.sh 清理）
record_replace_dirs() {
  local record="$MODPATH/.debloat_record"
  : > "$record"
  for item in $REPLACE; do
    echo "$MODPATH/$item" >> "$record"
  done
}

# 执行 apex 应用卸载
do_uninstall_apex() {
  [ -z "$APEX_APPS" ] && return
  : > "$MODPATH/.apex_apps_removed"
  for pkg in $APEX_APPS; do
    if pm uninstall -k --user 0 "$pkg" >/dev/null 2>&1; then
      echo "$pkg" >> "$MODPATH/.apex_apps_removed"
    fi
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
    uninstall_replace_apps
    do_uninstall_apex
    generate_apps_conf
    record_replace_dirs
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
        ui_print "     +AI/小爱 + 内容/工具/安全 + 系统服务 + 无障碍/宏"
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

  local groups=$(get_all_groups)
  local total_groups=$(echo "$groups" | wc -l)
  local group_idx=0

  for group_name in $groups; do
    group_idx=$((group_idx + 1))

    # 跳过危险项（由 dangerous_items 处理）
    [ "$group_name" = "危险项" ] && continue

    local group_apps=$(get_apps_by_group "$group_name")

    # 生成描述文字
    local desc=""
    for app_path in $group_apps; do
      local dname=$(get_display_name "$app_path")
      [ -n "$desc" ] && desc="${desc}+"
      desc="${desc}${dname}"
    done

    ui_print " "
    ui_print " 📦 [${group_idx}/${total_groups}] ${group_name}"
    ui_print "   包含：${desc}"
    ui_print "   🔊音量+ 精简此组 / 🔊音量- 进入选择"

    if getVolumeKey; then
      ui_print "   ❌ 精简此组"
      for app_path in $group_apps; do
        case "$app_path" in
          apex:*) add_apex_app "${app_path#apex:}" ;;
          *) add_to_replace "$app_path" ;;
        esac
      done
    else
      # 构建 custom_group 参数：路径1 名称1 路径2 名称2 ...
      local group_args=""
      for app_path in $group_apps; do
        local dname=$(get_display_name "$app_path")
        group_args="$group_args $app_path $dname"
      done

      # 系统服务使用快捷选择模式
      if [ "$group_name" = "系统服务" ]; then
        custom_group_with_shortcut "$group_name" $group_args
        # apex 应用单独处理
        ui_print " "
        ui_print "   健康数据共享（apex）"
        ui_print "     🔊音量+ 精简 / 🔊音量- 保留"
        if getVolumeKey; then
          add_apex_app "com.android.healthconnect.controller"
          ui_print "     ❌ 精简（apex）"
        else
          ui_print "     ✅ 保留"
        fi
      elif [ "$group_name" = "广告/追踪" ]; then
        custom_group "$group_name" $group_args
        # apex 应用单独处理
        ui_print " "
        ui_print "   广告隐私权（apex）"
        ui_print "     🔊音量+ 精简 / 🔊音量- 保留"
        if getVolumeKey; then
          add_apex_app "com.android.adservices.api"
          ui_print "     ❌ 精简（apex）"
        else
          ui_print "     ✅ 保留"
        fi
      else
        custom_group "$group_name" $group_args
      fi
    fi
  done
}

# 自定义模式：逐个应用选择（兼容 sh，支持重选本组）
# 参数：分组名 应用路径1 应用名1 应用路径2 应用名2 ...
custom_group() {
  local group_name="$1"
  shift
  local total=$(( $# / 2 ))
  local all_args="$*"
  local retry=true

  while $retry; do
    retry=false
    local i=1
    local group_selected=""
    local args="$all_args"

    ui_print " "
    ui_print " 📦 ${group_name} - 逐个选择"
    ui_print "   🔊音量+ 精简 / 🔊音量- 保留"

    # 逐项选择
    while [ -n "$args" ]; do
      local app_path=$(echo "$args" | cut -d' ' -f1)
      local app_name=$(echo "$args" | cut -d' ' -f2)
      args=$(echo "$args" | cut -d' ' -f3-)

      ui_print " "
      ui_print "   [${i}/${total}] ${app_name}"

      if getVolumeKey; then
        case "$app_path" in
          apex:*) add_apex_app "${app_path#apex:}" ;;
          *) add_to_replace "$app_path" ;;
        esac
        group_selected="$group_selected $app_path"
        ui_print "     ❌ 精简"
      else
        ui_print "     ✅ 保留"
      fi
      i=$((i + 1))
    done

    # 显示本组结果
    ui_print " "
    ui_print " 📦 ${group_name} - 已选择："
    local display_args="$all_args"
    while [ -n "$display_args" ]; do
      local d_path=$(echo "$display_args" | cut -d' ' -f1)
      local d_name=$(echo "$display_args" | cut -d' ' -f2)
      display_args=$(echo "$display_args" | cut -d' ' -f3-)
      if echo "$group_selected" | grep -q "$d_path"; then
        ui_print "   ❌ $d_name"
      else
        ui_print "   ✅ $d_name"
      fi
    done

    # 确认/重选
    ui_print " "
    ui_print " 🔊音量+ 确认 / 🔊音量- 重选本组"
    if ! getVolumeKey; then
      # 重选：从 REPLACE 中移除本组已选
      for p in $group_selected; do
        REPLACE=$(echo "$REPLACE" | grep -vxF "$p")
      done
      retry=true
    fi
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

  # 先显示本组应用列表
  ui_print " "
  ui_print " 📦 ${group_name}（${total}项）"
  local _show_args="$all_args"
  while [ -n "$_show_args" ]; do
    local _s_name=$(echo "$_show_args" | cut -d' ' -f2)
    ui_print "   · $_s_name"
    _show_args=$(echo "$_show_args" | cut -d' ' -f3-)
  done

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
            case "$_path" in
              apex:*) add_apex_app "${_path#apex:}" ;;
              *) add_to_replace "$_path" ;;
            esac
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
  ui_print "  ⌨️ 搜狗输入法小米版 - 请确保有其他输入法"
  ui_print "  🔊音量+ 精简 / 🔊音量- 保留"
  if getVolumeKey; then
    add_to_replace "/system/product/app/SogouIME"
    ui_print "  ❌ 精简搜狗输入法"
  else
    ui_print "  ✅ 保留搜狗输入法"
  fi

  ui_print " "
  ui_print "  ⌨️ 讯飞输入法 - 请确保有其他输入法"
  ui_print "  🔊音量+ 精简 / 🔊音量- 保留"
  if getVolumeKey; then
    add_to_replace "/data/app/iFlytekIME"
    ui_print "  ❌ 精简讯飞输入法"
  else
    ui_print "  ✅ 保留讯飞输入法"
  fi

  ui_print " "
  ui_print "  📡 Cell Broadcast Service(紧急警报) - 紧急警报服务"
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
  ui_print "  🛒 应用商店 - 应用下载"
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

  # 检测是否为覆盖安装
  local old_conf="/data/adb/modules/$MODID/webroot/apps.conf"
  if [ -f "$old_conf" ]; then
    ui_print " "
    ui_print " ============================================"
    ui_print "  🔍 检测到已有配置"
    ui_print "  🔊音量+ 应用旧配置 / 🔊音量- 重新选择"
    ui_print " ============================================"
    if getVolumeKey; then
      ui_print "  ✅ 应用旧配置"
      # 从旧配置中读取状态为1的应用
      while IFS='|' read -r path name pkg status group; do
        [ -z "$path" ] && continue
        case "$path" in \#*) continue ;; esac
        if [ "$status" = "1" ]; then
          case "$path" in
            apex:*) add_apex_app "${path#apex:}" ;;
            *) add_to_replace "$path" ;;
          esac
        fi
      done < "$old_conf"
      # 生成新配置（data 副本已在上次安装时卸载，REPLACE 会遮蔽系统版本）
      generate_apps_conf
      record_replace_dirs
      return
    else
      ui_print "  🔄 重新选择"
    fi
  fi

  ui_print " "
  ui_print " ============================================"
  ui_print "  🔊音量+ 立即选择精简模式"
  ui_print "  🔊音量- 跳过，稍后通过 WebUI 配置"
  ui_print " ============================================"

  if ! getVolumeKey; then
    # 跳过：生成空配置，全部保留
    ui_print "  ⏭️ 已跳过，重启后通过 WebUI 配置"
    generate_apps_conf
    record_replace_dirs
    return
  fi

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
        "/system/product/app/LyraWOS3CN" \
        "/system/product/app/MiConnectService" \
        "/system_ext/app/digitalkey" \
        "/product/app/RideModeAudio"
      add_apex_app "com.android.adservices.api"
      ;;
    3)
      ui_print "  🔥 [OK] 深度精简"
      ui_print "  精简：标准精简全部内容"
      ui_print "  +AI/小爱 + 内容/工具/安全 + 系统服务 + 无障碍/宏"
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
        "/system/product/app/MiConnectService" \
        "/system_ext/app/digitalkey" \
        "/product/app/RideModeAudio" \
        "/system/product/app/XiaoaiRecommendation" \
        "/system/product/app/VoiceAssistAndroidT" \
        "/system/product/app/VoiceTrigger" \
        "/system/product/app/AiasstVision" \
        "/system/product/app/MIUIAiasstService" \
        "/system/product/priv-app/MIUIAICR" \
        "/system/product/priv-app/MIUIPersonalAssistantPhoneOS3" \
        "/system/product/priv-app/MiuiBarrage" \
        "/system/product/priv-app/MIUIContentExtension" \
        "/product/app/MIGalleryLockscreen" \
        "/product/app/MIUIMiDrive" \
        "/product/app/MiBugReportOS3" \
        "/product/app/hybrid" \
        "/product/priv-app/MIUIYellowPage" \
        "/product/app/ThirdAppAssistant" \
        "/product/app/ContentCatcherOS3_1" \
        "/product/app/MIUITouchAssistant" \
        "/product/app/greenguard" \
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
        "/system/app/Stk" \
        "/system/app/CarrierDefaultApp" \
        "/system/priv-app/CallLogBackup" \
        "/product/priv-app/ConfigUpdater" \
        "/product/app/CatchLog" \
        "/system_ext/priv-app/TouchService" \
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
      [ -n "$pkg" ] && pm install-existing --user 0 "$pkg" >/dev/null 2>&1
    done < "$old_record"
  fi

  # 恢复 apex 应用
  local apex_record="/data/adb/modules/$MODID/.apex_apps_removed"
  if [ -f "$apex_record" ]; then
    while IFS= read -r pkg; do
      [ -n "$pkg" ] && pm install-existing --user 0 "$pkg" >/dev/null 2>&1
    done < "$apex_record"
  fi
}

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
  # 确保 product 和 system_ext 目录有执行权限（兼容独立分区设备）
  [ -d "$MODPATH/system/product" ] && set_perm_recursive $MODPATH/system/product 0 0 0755 0644
  [ -d "$MODPATH/system/system_ext" ] && set_perm_recursive $MODPATH/system/system_ext 0 0 0755 0644
}
