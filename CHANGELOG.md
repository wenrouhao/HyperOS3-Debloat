# 更新日志

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
