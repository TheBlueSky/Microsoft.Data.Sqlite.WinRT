@echo off

SET msbuildPath=C:\Program Files (x86)\MSBuild\14.0\Bin

"%msbuildPath%\msbuild" Microsoft.Data.Sqlite.sln /p:Configuration=Release /p:Platform="Any CPU"

pause
