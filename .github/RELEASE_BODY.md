## ImmortalWrt for Gemtek XR1710G — @DATE@ Build (@COMMIT@)

> SoC: Airoha AN7581GT · 内核 6.18.41 · Wi-Fi 7（BE19000，2.4/5/6GHz 三频）· 构建于 @TIME@

### 预装 LuCI 应用（9 个，全部含中文翻译）

**设备专属**
- `luci-app-airoha-npu` — SoC 状态监控 + 超频
- `luci-app-airoha-fancontrol` — 风扇速度/温度控制
- `luci-app-airoha-flowsense` — PPE 硬件 offload 监控 + 延迟检测（支持自定义 Ping 目标）

**网络工具**
- `luci-app-upnp` / `luci-app-firewall`（firewall4/nftables）/ `luci-app-arpbind` / `luci-app-mlo`（Wi-Fi 7 多链路）/ `luci-app-package-manager`（APK）/ `luci-app-ttyd`（Web 终端）

### 移植的魔改插件（来自 ImmortalWrt-ImageBuilder）

- **luci-app-nikki** — 透明代理（fork 魔改：配置文件批量上传、上传并选中重载、重载后清除旧连接）；内置 mihomo 预编译二进制 + geox 数据集（geoip/geosite/mmdb，首次启动免下载）
- **luci-theme-uniwrt** — UniWRT Portal 主题（fork）
- **luci-theme-footstrap** — Footstrap 主题（fork 魔改：底部栏固件构建版本标记）

### 默认信息

- 管理地址：http://192.168.1.1 或 http://immortalwrt.lan
- 用户名 `root`，密码：无
- 无线 SSID：`XR1710G-2G` / `XR1710G-5G` / `XR1710G-6G`（前缀 `XR1710G`，分频段命名）
- 无线初始密码（2.4/5/6G 统一）：`yjb123456`

### 刷机

- 固件：`immortalwrt-airoha-an7581-gemtek_xr1710g-ubi-squashfs-sysupgrade.itb`
- 方法：LuCI → 系统 → 备份/升级 → 刷写固件
- 校验：见下方 `sha256sums`

### 说明

- 本次构建已移除 17 个不再预装的 LuCI 应用及其核心依赖（DDNS / Lucky / UDPXY / KMS / 看门狗 / 组播等），需要时可通过系统内 APK 包管理器随时安装
- 设备专属 `luci-app-airoha-recovery`（U-Boot 恢复入口）一并预装

---
