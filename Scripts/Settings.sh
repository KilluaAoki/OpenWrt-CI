#!/bin/bash

CFG_FILE="./package/base-files/files/bin/config_generate"

# 修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")

# 修改默认 IP 地址
sed -i "s/192\.168\.1\.1/$WRT_IP/g" $CFG_FILE

# 修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE