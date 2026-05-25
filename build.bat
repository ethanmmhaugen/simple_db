@echo off
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64 > nul 2>&1
if not exist build mkdir build
cl.exe /nologo /EHsc /Zi ^
  /Fe"build\main.exe" ^
  /Fo"build\\" ^
  /Fd"build\\" ^
  main.c custom_get_line.c
