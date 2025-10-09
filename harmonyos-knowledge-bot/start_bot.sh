#!/bin/bash

echo "========================================"
echo "  HarmonyOS 知识库自动化学习机器人"
echo "========================================"
echo ""

function show_menu() {
    echo "请选择运行模式:"
    echo ""
    echo "[1] 搜索模式 - 搜索特定主题"
    echo "[2] 爬取模式 - 爬取指定 URL"
    echo "[3] 自动模式 - 自动搜索和学习（推荐）"
    echo "[4] 分析模式 - 分析 Gitee 仓库"
    echo "[5] 退出"
    echo ""
    read -p "请输入选项 (1-5): " choice
    
    case $choice in
        1)
            read -p "请输入搜索主题: " topic
            python3 knowledge_bot.py --mode search --topic "$topic"
            read -p "按 Enter 继续..."
            show_menu
            ;;
        2)
            read -p "请输入要爬取的 URL: " url
            python3 knowledge_bot.py --mode crawl --url "$url"
            read -p "按 Enter 继续..."
            show_menu
            ;;
        3)
            echo "启动自动学习模式..."
            python3 knowledge_bot.py --mode auto
            read -p "按 Enter 继续..."
            show_menu
            ;;
        4)
            read -p "请输入 Gitee 仓库名: " repo
            python3 knowledge_bot.py --mode analyze --repo "$repo"
            read -p "按 Enter 继续..."
            show_menu
            ;;
        5)
            echo "感谢使用！"
            exit 0
            ;;
        *)
            echo "无效选项，请重新选择"
            show_menu
            ;;
    esac
}

show_menu

