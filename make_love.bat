@echo off

for %%A in ("%~f0\..") do set "gamename=%%~nxA"

if exist "%cd%\build" rmdir /s /q "%cd%\build"
mkdir "%cd%\build\"

xcopy /b "C:\Program Files\LOVE\*.dll" "%cd%\build\" /Y
winrar a -r -ep1 -afzip -x*.bat -x*.sublime-* -x.gitignore -x.git\* -x.git -xbuild "%cd%\build\%gamename%.love" "%cd%\*"
copy /b "C:\Program Files\LOVE\love.exe"+"%cd%\build\%gamename%.love" "%cd%\build\%gamename%.exe"

del /F "%cd%\build\%gamename%.love"