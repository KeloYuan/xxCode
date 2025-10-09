@echo off
chcp 65001 >nul
title HarmonyOS 知识库学习机器人

echo ========================================
echo   HarmonyOS 知识库自动化学习机器人
echo ========================================
echo.
echo 虚拟环境已激活！
echo.

cd /d %~dp0
call venv\Scripts\activate.bat

:menu
echo.
echo 请选择运行模式:
echo.
echo [1] 自动模式 - 自动搜索和学习（推荐）⭐
echo [2] 搜索模式 - 搜索特定主题
echo [3] 爬取模式 - 爬取指定 URL
echo [4] 查看配置
echo [5] 退出
echo.
set /p choice=请输入选项 (1-5): 

if "%choice%"=="1" goto auto
if "%choice%"=="2" goto search
if "%choice%"=="3" goto crawl
if "%choice%"=="4" goto config
if "%choice%"=="5" goto end
echo 无效选项，请重新选择
goto menu

:auto
echo.
echo 🤖 启动自动学习模式...
echo.
python knowledge_bot.py --mode auto
pause
goto menu

:search
echo.
set /p topic=请输入搜索主题（例如：HarmonyOS 动画）: 
echo.
echo 🔍 搜索主题: %topic%
echo.
python knowledge_bot.py --mode search --topic "%topic%"
pause
goto menu

:crawl
echo.
set /p url=请输入要爬取的 URL: 
echo.
echo 📥 爬取网页: %url%
echo.
python knowledge_bot.py --mode crawl --url "%url%"
pause
goto menu

:config
echo.
echo 📋 当前配置:
echo.
type config.json
echo.
pause
goto menu

:end
echo.
echo 感谢使用！
timeout /t 2 >nul
exit

