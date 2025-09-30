#!/bin/bash

# HarmonyOS 应用快速安装并运行脚本

echo "📱 检查连接的设备..."
hdc list targets

if [ $? -ne 0 ]; then
    echo "❌ 没有连接的设备，请检查："
    echo "   1. 设备是否通过 USB 连接"
    echo "   2. 设备是否开启了开发者模式和 USB 调试"
    exit 1
fi

# 检查 HAP 文件是否存在
if [ -f "entry/build/default/outputs/default/app/entry-default.hap" ]; then
    HAP_FILE="entry/build/default/outputs/default/app/entry-default.hap"
    echo "📦 找到 HAP 文件: $HAP_FILE"
elif [ -f "entry/build/default/outputs/default/entry-default-unsigned.hap" ]; then
    HAP_FILE="entry/build/default/outputs/default/entry-default-unsigned.hap"
    echo "📦 找到 HAP 文件: $HAP_FILE"
else
    echo "❌ 未找到 HAP 文件，请先在 DevEco Studio 中编译项目"
    echo "   或运行: Build > Build Hap(s)/APP(s)"
    exit 1
fi

echo "📦 安装应用..."
hdc install -r "$HAP_FILE"

if [ $? -eq 0 ]; then
    echo "✅ 安装成功！"
    
    echo "🚀 启动应用..."
    hdc shell aa start -a EntryAbility -b com.niki.xxcode
    
    if [ $? -eq 0 ]; then
        echo "✅ 应用已启动！"
        echo ""
        echo "📋 查看日志（Ctrl+C 退出）..."
        sleep 1
        hdc hilog | grep xxcode
    else
        echo "⚠️  启动失败，但应用已安装，请手动打开"
    fi
else
    echo "❌ 安装失败，请检查："
    echo "   1. 设备连接是否正常"
    echo "   2. HAP 文件是否有效"
    echo "   3. 设备是否有足够的存储空间"
fi
