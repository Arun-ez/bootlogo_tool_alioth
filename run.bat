@echo off
title Alioth bootlogo tool
setlocal enabledelayedexpansion
set xxd=bin\xxd.exe
set dd=bin\busybox.exe dd
set busybox=bin\busybox.exe
set grep=bin\grep.exe
set output_file=logo.img
set resolution=1080x2400
set output_file_path=output\%output_file%
set file_input=output\logo.img
set output_zip=flashable_bootlogo_alioth.zip
set output_zip_path=output\%output_zip%
:start
echo.
echo.
echo.
echo.                   #--------------------------------------------------#
echo.                   #  Mi 11x/Poco f3/Redmi k40 BootLogo Image Maker   #
echo.                   #                                                  #
echo.                   #             ==   By ArunEZ  ==                   #
echo.                   #--------------------------------------------------#
echo.
echo.
echo.
echo.

echo.    --------------------
echo.     1. Create Bootlogo 
echo.    --------------------
echo.
echo.    -----------------------
echo.     2. Decompress Bootlogo 
echo.    -----------------------
echo.
echo.    -----------------------
echo.     3. Exit
echo.    -----------------------

echo.&echo.&set /P Process=  Choose your option : 
echo.
echo.


If /I "%Process%"=="1" goto :compress
If /I "%Process%"=="2" goto :decompress
If /I "%Process%"=="3" goto :Exit
:Exit
exit

:compress
if not exist "output\" mkdir "output\"
if not exist "temp\" ( mkdir "temp\"& attrib /S /D +h "temp" )
del /Q temp\* 2>NUL
del /Q %output_file_path% 2>NUL
del /Q %output_zip_path% 2>NUL

echo.  Varifying files ...
echo.                                                  
set logo_path="not_found"
if exist "pics\logo.jpg" set logo_path="pics\logo.jpg"
if exist "pics\logo.jpeg" set logo_path="pics\logo.jpeg"
if exist "pics\logo.png" set logo_path="pics\logo.png"
if exist "pics\logo.gif" set logo_path="pics\logo.gif"
if exist "pics\logo.bmp" set logo_path="pics\logo.bmp"
if %logo_path%=="not_found" echo.logo picture not found in 'pics' folder.. EXITING&echo.&echo.&pause&exit

set fastboot_path="not_found"
if exist "pics\fastboot.jpg" set fastboot_path="pics\fastboot.jpg"
if exist "pics\fastboot.jpeg" set fastboot_path="pics\fastboot.jpeg"
if exist "pics\fastboot.png" set fastboot_path="pics\fastboot.png"
if exist "pics\fastboot.gif" set fastboot_path="pics\fastboot.gif"
if exist "pics\fastboot.bmp" set fastboot_path="pics\fastboot.bmp"
if %fastboot_path%=="not_found" echo.fastboot picture not found in 'pics' folder.. EXITING&echo.&echo.&pause&exit

set system_corrupt_path="not_found"
if exist "pics\system_corrupt.jpg" set system_corrupt_path="pics\system_corrupt.jpg"
if exist "pics\system_corrupt.jpeg" set system_corrupt_path="pics\system_corrupt.jpeg"
if exist "pics\system_corrupt.png" set system_corrupt_path="pics\system_corrupt.png"
if exist "pics\system_corrupt.gif" set system_corrupt_path="pics\system_corrupt.gif"
if exist "pics\system_corrupt.bmp" set system_corrupt_path="pics\system_corrupt.bmp"
if %system_corrupt_path%=="not_found" echo.system_corrupt picture not found in 'pics' folder.. EXITING&echo.&echo.&pause&exit

echo.  Varifiation succeed , generating bootlogo ...
echo.                                                  
bin\ffmpeg.exe -hide_banner -loglevel quiet -i %logo_path% -pix_fmt rgb24 -s %resolution% -y "temp\logo_1.bmp" > NUL
bin\ffmpeg.exe -hide_banner -loglevel quiet -i %fastboot_path% -pix_fmt rgb24 -s %resolution% -y "temp\logo_2.bmp" > NUL
bin\ffmpeg.exe -hide_banner -loglevel quiet -i %logo_path% -pix_fmt rgb24 -s %resolution% -y "temp\logo_3.bmp" > NUL
bin\ffmpeg.exe -hide_banner -loglevel quiet -i %system_corrupt_path% -pix_fmt rgb24 -s %resolution% -y "temp\logo_4.bmp" > NUL
copy /b "bin\header.bin"+"temp\logo_1.bmp"+"bin\footer.bin"+"temp\logo_2.bmp"+"bin\footer.bin"+"temp\logo_3.bmp"+"bin\footer.bin"+"temp\logo_4.bmp"+"bin\footer.bin" %output_file_path% >NUL
echo.      
if exist %output_file_path% ( echo.  Successfully generated logo.img "output" folder
) else ( echo.    FAILED.. Try Again&echo.&echo.&pause&exit )

echo.      
echo.      
echo.   Get flashable Zip?    
echo.
echo.    --------------------
echo.     Press y to YES
echo.    --------------------
echo.
echo.    -----------------------
echo.     Press n to NO
echo.    -----------------------
echo.&echo.&set /P INPUT=  Choose your option : 
If /I "%INPUT%"=="y" goto :FLASHABLE
If /I "%INPUT%"=="Y" goto :FLASHABLE
If /I "%INPUT%"=="yes" goto :FLASHABLE
If /I "%INPUT%"=="n" goto :EOL
If /I "%INPUT%"=="N" goto :EOL
If /I "%INPUT%"=="no" goto :EOL

:FLASHABLE
copy /Y bin\gen_bootlogo_alioth.zip %output_zip_path% >NUL
cd output
..\bin\7za a %output_zip% %output_file% >NUL
cd..

if exist %output_zip_path% (
 echo.&echo.&echo.    SUCCESS!
 echo.
 echo.    Flashable zip file created in "output" folder
 echo.
 echo.    You can flash the '%output_zip%' from any custom recovery like TWRP,Orangefox
) else ( echo.&echo.&echo Flashable ZIP not created.. )

goto :EOL

:decompress
for /f "tokens=1 delims=:" %%i in ('!grep! --only-matching --byte-offset --binary --text --perl-regexp "\x{42}\x{4D}" "!file_input!"') do (
set offset=%%i
set /a blockoffset=!offset!+2
for /f %%i in ('!busybox! xxd -p -s !offset! -l 16 !file_input! ^| findstr /b /n "424d................36000000"') do (
for /f %%i in ('!busybox! od -td -An --skip-bytes=!blockoffset! --read-bytes=4 !file_input!') do (set blocksize=%%i)&set "blocksize=!blocksize: =!"
rem echo blocksize=!blocksize!
echo.&echo    Triggered offset !offset! 
rem set skipbytes=%%i
rem set /a skipbytes=^(%%i-1^)*16+2
echo.&echo    Triggered offset !offset! !blockoffset!
rem echo %%j
rem for /f %%i in ('!busybox! od -td -An --skip-bytes=!blockoffset! --read-bytes=4 !file_input!') do (set blocksize=%%i)&set blocksize=!blocksize: =!
echo.&echo    Triggered offset !offset! !blocksize!
if not defined n set n=0
set /a n=!n!+1
if "!offset!"=="0" (
!xxd! -p -l !blocksize! !file_input! | !busybox! tr -d "\n" | !xxd! -p -r > !n!.bmp
) else (
!xxd! -p -s !offset! -l !blocksize! !file_input! | !busybox! tr -d "\n" | !xxd! -p -r > !n!.bmp
)
rem !xxd! -p -s !offset! -l !blocksize! !file_input! | !busybox! tr -d "\n" > !n!.bmp.tmp
)
if not defined offset echo.&echo     Wrong offset & block
)

goto :EOL


:EOL
echo.                       
echo.               ===== Tasking Completed!! ====
echo.
goto :start 
                                             



