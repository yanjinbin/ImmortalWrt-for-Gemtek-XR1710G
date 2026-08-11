#!/bin/sh
#
# Optional PPPoE WAN setup (build-time option).
# Default firmware is a DHCP client on WAN.  When the build workflow is run
# with enable_pppoe=yes plus a broadband account/password, this file is
# written into /etc/config/pppoe-settings at build time and applied on first
# boot; otherwise the default DHCP client configuration is kept untouched.

. /lib/functions/system.sh

[ "$(board_name)" = "gemtek,xr1710g-ubi" ] || [ "$(board_name)" = "gemtek,w1700k-ubi" ] || exit 0

[ -f /etc/config/pppoe-settings ] || exit 0

enable_pppoe="$(sed -n 's/^enable_pppoe=//p' /etc/config/pppoe-settings | head -n1)"
pppoe_account="$(sed -n 's/^pppoe_account=//p' /etc/config/pppoe-settings | head -n1)"
pppoe_password="$(sed -n 's/^pppoe_password=//p' /etc/config/pppoe-settings | head -n1)"

[ "$enable_pppoe" = "yes" ] || exit 0

if [ -z "$pppoe_account" ] || [ -z "$pppoe_password" ]; then
	logger -t pppoe "PPPoE enabled but account/password missing, keeping DHCP client"
	exit 0
fi

uci -q get network.wan >/dev/null 2>&1 || exit 0

uci set network.wan.proto='pppoe'
uci set network.wan.username="$pppoe_account"
uci set network.wan.password="$pppoe_password"
uci set network.wan.keepalive='5'
uci commit network

logger -t pppoe "WAN switched to PPPoE ($pppoe_account)"

exit 0
