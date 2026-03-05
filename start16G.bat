@echo off
setlocal enabledelayedexpansion

set RAM=16G
set FORGE_JAR=forge-1.16.5-36.2.34.jar

echo [INFO] Searching for Java 8...

set "JAVA_EXEC="

for /d %%i in (
    "C:\Program Files\Eclipse Adoptium\jdk-8*"
    "C:\Program Files\Eclipse Adoptium\jre-8*"
    "C:\Program Files\Java\jre1.8*"
    "C:\Program Files\Java\jdk1.8*"
    "C:\Program Files\Zulu\zulu-8*"
) do (
    if exist "%%i\bin\java.exe" (
        set "JAVA_EXEC=%%i\bin\java.exe"
        goto :START_SERVER
    )
)

java -version 2>&1 | findstr "1.8" >nul
if %errorlevel% equ 0 (
    set "JAVA_EXEC=java"
    goto :START_SERVER
)

echo.
echo [ERROR] Java 8 was NOT found!
echo Found versions in Adoptium folder:
dir /b "C:\Program Files\Eclipse Adoptium\"
echo.
echo Please install Java 8 (Temurin 8 LTS) or check paths.
pause
exit

:START_SERVER
echo [SUCCESS] Found Java 8 at: "%JAVA_EXEC%"
echo.

"%JAVA_EXEC%" -Xmx%RAM% -Xms%RAM% ^
-Dfml.readTimeout=180 ^
-Dfml.loginTimeout=180 ^
-XX:+UseG1GC ^
-XX:+ParallelRefProcEnabled ^
-XX:MaxGCPauseMillis=200 ^
-XX:+UnlockExperimentalVMOptions ^
-XX:+DisableExplicitGC ^
-XX:+AlwaysPreTouch ^
-XX:G1NewSizePercent=30 ^
-XX:G1MaxNewSizePercent=40 ^
-XX:G1HeapRegionSize=8M ^
-XX:G1ReservePercent=20 ^
-XX:G1HeapWastePercent=5 ^
-XX:G1MixedGCCountTarget=4 ^
-XX:InitiatingHeapOccupancyPercent=15 ^
-XX:G1MixedGCLiveThresholdPercent=90 ^
-XX:G1RSetUpdatingPauseTimePercent=5 ^
-XX:SurvivorRatio=32 ^
-XX:+PerfDisableSharedMem ^
-XX:MaxTenuringThreshold=1 ^
-jar %FORGE_JAR% nogui

pause