#!/bin/bash

PKG_PATCH="$GITHUB_WORKSPACE/openwrt/package/"

# 预置 HomeProxy 数据
if [ -d *"homeproxy"* ]; then
	HP_RULES="surge"
	HP_PATCH="homeproxy/root/etc/homeproxy"

	chmod +x ./$HP_PATCH/scripts/*
	rm -rf ./$HP_PATCH/resources/*

	git clone -q --depth=1 --single-branch --branch "release" "https://github.com/Loyalsoldier/surge-rules.git" ./$HP_RULES/
	cd ./$HP_RULES/ && RES_VER=$(git log -1 --pretty=format:'%s' | grep -o "[0-9]*")

	echo $RES_VER | tee china_ip4.ver china_ip6.ver china_list.ver gfw_list.ver
	awk -F, '/^IP-CIDR,/{print $2 > "china_ip4.txt"} /^IP-CIDR6,/{print $2 > "china_ip6.txt"}' cncidr.txt
	sed 's/^\.//g' direct.txt > china_list.txt ; sed 's/^\.//g' gfw.txt > gfw_list.txt
	mv -f ./{china_*,gfw_list}.{ver,txt} ../$HP_PATCH/resources/

	cd .. && rm -rf ./$HP_RULES/

	cd $PKG_PATCH && echo "HomeProxy presets completed!"
fi

# 预置 OpenClash 内核
if [ -d *"openclash"* ]; then
	CORE_VER="https://raw.githubusercontent.com/vernesong/OpenClash/core/dev/core_version"
	CORE_TYPE=$(echo $WRT_TARGET | egrep -iq "64|86" && echo "amd64" || echo "arm64")
	CORE_TUN_VER=$(curl -sL $CORE_VER | sed -n "2{s/\r$//;p;q}")

	CORE_DEV="https://github.com/vernesong/OpenClash/raw/core/dev/dev/clash-linux-$CORE_TYPE.tar.gz"
	CORE_MATE="https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux-$CORE_TYPE.tar.gz"
	CORE_TUN="https://github.com/vernesong/OpenClash/raw/core/dev/premium/clash-linux-$CORE_TYPE-$CORE_TUN_VER.gz"

	mkdir ./luci-app-openclash/root/etc/openclash/core/ && cd ./luci-app-openclash/root/etc/openclash/core/

	curl -sL -o meta.tar.gz $CORE_MATE && tar -zxf meta.tar.gz && mv -f clash clash_meta
	curl -sL -o tun.gz $CORE_TUN && gzip -d tun.gz && mv -f tun clash_tun
	curl -sL -o dev.tar.gz $CORE_DEV && tar -zxf dev.tar.gz

	chmod +x ./* && rm -rf ./*.gz

	cd $PKG_PATCH && echo "OpenClash presets completed!"
fi