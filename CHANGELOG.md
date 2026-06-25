# 更新日志

## v3.1.1

### 新增
- 新增19个应用精简支持

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
