#!/bin/sh
#
# Optional IPv6 toggle (build-time option).
# Default firmware is built with IPv6 OFF: on first boot WAN6 is set to none,
# LAN RA/DHCPv6 (odhcpd) is disabled and the firewall stops processing IPv6.
# When the build workflow is run with enable_ipv6=yes, the stock IPv6-enabled
# defaults are left untouched.

. /lib/functions/system.sh

[ "$(board_name)" = "gemtek,xr1710g-ubi" ] || [ "$(board_name)" = "gemtek,w1700k-ubi" ] || exit 0

[ -f /etc/config/ipv6-settings ] || exit 0

enable_ipv6="$(sed -n 's/^enable_ipv6=//p' /etc/config/ipv6-settings | head -n1)"
[ "$enable_ipv6" = "no" ] || exit 0

# 关闭 WAN6 / LAN6 接口
uci -q set network.wan6.proto='none'
uci -q set network.wan6.disabled='1'
uci -q delete network.lan6
uci -q delete network.lan.ip6assign
uci -q delete network.lan.ip6hint
uci -q delete network.lan.ip6ifaceid
uci -q delete network.lan.ip6class

# 关闭 LAN 的 IPv6 RA/DHCPv6 (odhcpd)
if uci -q get dhcp.lan >/dev/null 2>&1; then
	uci set dhcp.lan.ra='disabled'
	uci set dhcp.lan.dhcpv6='disabled'
	uci -q delete dhcp.lan.ra_management
	uci -q delete dhcp.lan.ndp
	uci -q delete dhcp.lan.ra_slaac
fi

# 开启 dnsmasq AAAA 记录过滤 (防止客户端获取 IPv6 地址后连接超时)
if uci -q get dhcp.@dnsmasq[0] >/dev/null 2>&1; then
	uci set dhcp.@dnsmasq[0].filter_aaaa='1'
fi

# 禁用 odhcpd 服务
if [ -x /etc/init.d/odhcpd ]; then
	/etc/init.d/odhcpd disable
fi

# 防火墙关闭 IPv6 处理
if uci -q get firewall.@defaults[0] >/dev/null 2>&1; then
	uci set firewall.@defaults[0].disable_ipv6='1'
fi

uci commit network
uci commit dhcp
uci commit firewall

# 内核级别禁用 IPv6
mkdir -p /etc/sysctl.d
cat <<'EOF' > /etc/sysctl.d/10-disable-ipv6.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

logger -t ipv6 "IPv6 disabled (WAN6=none/disabled, RA/DHCPv6 off, filter_aaaa=1, fw4 disable_ipv6=1, sysctl disable_ipv6=1)"

exit 0
