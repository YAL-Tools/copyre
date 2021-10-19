del /Q copyre.n
haxe build-neko.hxml

del /Q bin\bin\Copyre.exe
haxe build-cs.hxml

del /Q copyre.zip
cmd /C 7z a copyre.zip copyre.n
cd bin\bin
cmd /C 7z a ..\..\copyre.zip Copyre.exe
pause