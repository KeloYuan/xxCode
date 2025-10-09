@echo off
chcp 65001 >nul
echo ========================================
echo   HarmonyOS 知识库自动化学习机器人
echo ========================================
echo.

:menu
echo 请选择运行模式:
echo.
echo [1] 搜索模式 - 搜索特定主题
echo [2] 爬取模式 - 爬取指定 URL
echo [3] 自动模式 - 自动搜索和学习（推荐）
echo [4] 分析模式 - 分析 Gitee 仓库
echo [5] 退出
echo.
set /p choice=请输入选项 (1-5): 

if "%choice%"=="1" goto search
if "%choice%"=="2" goto crawl
if "%choice%"=="3" goto auto
if "%choice%"=="4" goto analyze
if "%choice%"=="5" goto end
goto menu

:search
echo.
set /p topic=请输入搜索主题: 
python knowledge_bot.py --mode search --topic "%topic%"
pause
goto menu

:crawl
echo.
set /p url=请输入要爬取的 URL: 
python knowledge_bot.py --mode crawl --url "%url%"
pause
goto menu

:auto
echo.
echo 启动自动学习模式...
python knowledge_bot.py --mode auto
pause
goto menu

:analyze
echo.
set /p repo=请输入 Gitee 仓库名: 
python knowledge_bot.py --mode analyze --repo "%repo%"
pause
goto menu

:end
echo.
echo 感谢使用！
timeout /t 2 >nul

