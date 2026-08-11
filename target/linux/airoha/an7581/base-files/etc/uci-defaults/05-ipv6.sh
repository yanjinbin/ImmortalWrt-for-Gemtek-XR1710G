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

logger -t ipv6 "IPv6 disabled (WAN6=none, RA/DHCPv6 off, fw4 disable_ipv6=1)"

exit 0
