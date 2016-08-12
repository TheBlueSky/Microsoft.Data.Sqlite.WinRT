@echo off

pushd ..\src\

SET msbuildPath=C:\Program Files (x86)\MSBuild\14.0\Bin
"%msbuildPath%\msbuild" Microsoft.Data.Sqlite.sln /p:Configuration=Release /p:Platform="Any CPU"

popd

mkdir artifacts
copy ..\src\Microsoft.Data.Sqlite\bin\release\*.dll .\artifacts
nuget pack Microsoft.Data.Sqlite.WinRT.nuspec -o .\artifacts

pause
