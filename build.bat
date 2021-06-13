@ECHO off

ECHO Building.....
luvi inDev -o build/inDev.exe
ECHO Compiling VersionInfo
.\ResourceHacker.exe -open .\versionInfo.rc -save .\build\versionInfo.res -action compile -log NUL
ECHO Updating resources in Built executable
.\ResourceHacker.exe -script Update_VersionInfo.txt