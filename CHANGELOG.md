# 更新日志

## v4.1.0

### 新增
- 自定义精简应用：设置中开启，可添加系统应用到"自定义"分组
- 模块日志：默认关闭，可在设置中开启

### 优化
- CSS/JS/HTML 分离，使用 parceljs 打包混淆
- 保存时增量更新，只执行状态变化的应用
- 删除 apps.db 中没有包名的应用

### 修复
- 修复覆盖安装时自定义应用丢失
- 修复 apps.db CRLF 行尾导致的空行问题

## v4.0.0

### 新增
- WebUI 科技风界面：暗色/亮色主题切换、搜索栏、彩色分组标识
- 危险项精简确认弹窗：开启危险项精简时弹出警告提示
- 使用说明 Tips 区域
- 分组展开/收起动画优化
- 新增小米互联通信服务到云服务/互联分组

### 修复
- 修复 REPLACE 无法处理 data-app 副本的问题
- 修复 do_uninstall_apex 无条件写记录的问题
- 修复模式3预设列表重复条目和缺反斜杠
- 修复 custom_group_with_shortcut 进入时未显示应用列表

### 重构
- 包名映射表提取到独立文件 pkg_map.sh
- 新增 apps.db 单一数据源，统一管理所有应用信息
- 新增 post-fs-data.sh 开机同步精简配置
- WebUI 直接操作 REPLACE 目录，切换即时生效

## v3.1.1

### 新增
- 新增19个应用精简支持
- 新增 WebUI 精简管理界面（KernelSU 管理器内打开）
- 安装时支持"跳过，稍后通过 WebUI 配置"选项
- WebUI 支持逐个应用开关精简、保存配置、保存并重启
- 新增调试日志功能（webroot/debug.log，3天自动清理）

### 修复
- 修复模式3预设列表重复条目和缺少反斜杠的问题
- 修复 grep 子串误匹配风险（改用 -xF 精确匹配）
- 修复 uninstall.sh 未清理 webroot 和记录文件的问题

### 重构
- 包名映射表提取到独立文件 `pkg_map.sh`
- 安装时对所有 REPLACE 应用统一执行 `pm uninstall -k --user 0`
- 覆盖安装时保留旧配置或重新选择

## v3.1.0

### 新增
- 新增"小米互联通信服务"（com.xiaomi.mi_connect_service）到云服务/互联分组
- 新增包名映射表文件 `pkg_map.sh`，独立维护夹名→包名映射

### 修复
- 修复精简机制无法处理 data-app 副本的问题：用户手动更新过的应用会绕过 REPLACE 遮蔽，现在对所有 REPLACE 应用额外执行 `pm uninstall -k --user 0` 卸载 data 分区副本
- 修复 `do_uninstall_apex()` 无条件写入记录文件的问题，改为只在卸载成功时记录

### 重构
- 包名映射表从 install.sh 提取到独立文件 `pkg_map.sh`
- 删除旧的 `uninstall_data_apps()`，统一由 `uninstall_replace_apps()` 处理所有 REPLACE 应用的 data 副本卸载和记录

## v3.0.1

### 修复
- 修复 getVolumeKey 函数潜在的死循环风险，改为标准 `while true` 写法

### 优化
- 自定义模式逐个选择后显示本组结果预览，支持重选本组

## v3.0.0

### 新增
- 新增 15 个应用精简支持：AnalyticsCore、广告隐私权(apex)、健康数据共享(apex)、小米汽车互联服务、互联互通、跨设备通信、小米智能卡(2个)、米币支付、应用商店、游戏高能时刻、网络位置服务、系统打印服务、打印处理服务、工作设置
- 自定义模式支持分组快捷选择：音量+精简整组，音量-进入逐个选择
- 系统服务分组增加"全部精简/全部保留/逐个选择"三种快捷选项

### 优化
- 重新分组为 7 个分类：AI/小爱、游戏中心、云服务/互联、广告/追踪、负一屏/内容、系统服务、无障碍/宏
- 全局搜索和应用商店移到危险项单独确认
- 危险项新增：应用商店、小米智能卡、Cell Broadcast Service

### 修复
- 修复 SystemHelper 路径错误（/system/priv-app/SystemHelper）
- 修复 MiuiPrintSpooler 路径错误（/system/system_ext/app/）
- 修复 product/system_ext 目录权限问题（兼容独立分区设备）
- 修复 uninstall.sh 先恢复应用再删除目录
- 清理旧版遗留的 product 和 system_ext 目录

### 兼容性
- 兼容 /product 独立分区和 /system/product 两种设备布局
- KernelSU 自动创建符号链接处理不同分区布局
