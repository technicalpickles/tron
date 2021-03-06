:: Purpose:       Temp file cleanup
:: Requirements:  Admin access helps but is not required
:: Author:        reddit.com/user/vocatus ( vocatus.gate@gmail.com ) // PGP key: 0x07d1490f82a211a2
:: Version:       1.0.3-TRON + Add removal of "HKCU\SOFTWARE\Classes\Local Settings\Muicache". Thanks to /u/TheDevilsAdvocat
::                1.0.2-TRON * Add removal of C:\HP folder
::                1.0.1-TRON - Remove OS version calculation, since we inherit this from Tron
::                1.0.0-TRON * Stripped out many things not necessary for Tron
::                           - Removed logging (Tron handles logging)
SETLOCAL


:::::::::::::::
:: VARIABLES :: -------------- These are the defaults. Change them if you so desire. --------- ::
:::::::::::::::
:: No user-set variables for this script


:: --------------------------- Don't edit anything below this line --------------------------- ::


:::::::::::::::::::::
:: PREP AND CHECKS ::
:::::::::::::::::::::
@echo off
pushd %SystemDrive%
set SCRIPT_VERSION=1.0.2-TRON
set SCRIPT_UPDATED=2015-04-22


::::::::::::::::::::::::::
:: USER CLEANUP SECTION :: -- Most stuff in here doesn't require Admin rights
::::::::::::::::::::::::::
:: Create the log header for this job
echo --------------------------------------------------------------------------------------------
echo %CUR_DATE% %TIME%  TempFileCleanup v%SCRIPT_VERSION%, executing as %USERDOMAIN%\%USERNAME%
echo --------------------------------------------------------------------------------------------
echo.
echo  Starting temp file cleanup
echo  --------------------------
echo.
echo   Cleaning USER temp files...

::::::::::::::::::::::
:: Version-agnostic :: (these jobs run regardless of OS version)
::::::::::::::::::::::
:: Create log line
echo.  %% echo  ! Cleaning USER temp files... %% echo. 

:: User temp files, history, and random My Documents stuff
del /F /S /Q "%TEMP%" 2>NUL

:: Internet Explorer cleanup // Disabled for Tron, since Tron runs this command natively
::rundll32.exe inetcpl.cpl,ClearMyTracksByProcess 4351

:: Windows.old cleanup (Windows.old is left behind after an upgrade installation). Thanks to /u/bodkov
:: Disabled for Tron
REM if exist %SystemDrive%\Windows.old\ (
	REM takeown /F %SystemDrive%\Windows.old\* /R /A /D Y
	REM echo y| cacls %SystemDrive%\Windows.old\*.* /C /T /grant administrators:F
	REM rmdir /S /Q %SystemDrive%\Windows.old\
	REM )

::::::::::::::::::::::
:: Version-specific :: (these jobs run depending on OS version)
::::::::::::::::::::::
:: First block handles XP/2k3, second block handles Vista and up
:: Read 9 characters into the WIN_VER variable. Only versions of Windows older than Vista had "Microsoft" as the first part of their title,
:: so if we don't find "Microsoft" in the first 9 characters we can safely assume we're not on XP/2k3.
if /i "%WIN_VER:~0,9%"=="Microsoft" (
	for /D %%x in ("%SystemDrive%\Documents and Settings\*") do (
		del /F /Q "%%x\Local Settings\Temp\*" 2>NUL
		del /F /Q "%%x\Recent\*" 2>NUL
		del /F /Q "%%x\Local Settings\Temporary Internet Files\*" 2>NUL
		del /F /Q "%%x\Local Settings\Application Data\ApplicationHistory\*" 2>NUL
		del /F /Q "%%x\My Documents\*.tmp" 2>NUL
	)
) else (
	for /D %%x in ("%SystemDrive%\Users\*") do ( 
		del /F /Q "%%x\AppData\Local\Temp\*" 2>NUL
		del /F /Q "%%x\AppData\Roaming\Microsoft\Windows\Recent\*" 2>NUL
		del /F /Q "%%x\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" 2>NUL
		del /F /Q "%%x\My Documents\*.tmp" 2>NUL
	)
)

echo. && echo   Done. && echo.
echo.  && echo   Done. && echo.



::::::::::::::::::::::::::::
:: SYSTEM CLEANUP SECTION :: -- Most stuff here requires Admin rights
::::::::::::::::::::::::::::
echo.
echo   Cleaning SYSTEM temp files...
echo   Cleaning SYSTEM temp files...  && echo.


::::::::::::::::::::::
:: Version-agnostic :: (these jobs run regardless of OS version)
::::::::::::::::::::::
:: JOB: System temp files
:: Disabled for Tron since a lot of people seem to run it from C:\temp
:: del /F /S /Q "%WINDIR%\TEMP\*" 2>NUL

:: JOB: Root drive garbage (usually C drive)
rmdir /S /Q %SystemDrive%\Temp 2>NUL
for %%i in (bat,txt,log,jpg,jpeg,tmp,bak,backup,exe) do (
			del /F /Q "%SystemDrive%\*.%%i" 2>NUL
		)

:: JOB: Remove files left over from installing Nvidia/ATI/AMD/Dell/Intel/HP drivers
for %%i in (NVIDIA,ATI,AMD,Dell,Intel,HP) do (
			rmdir /S /Q "%SystemDrive%\%%i" 2>NUL
		)

:: JOB: Remove the Office installation cache. Usually around ~1.5 GB
if exist %SystemDrive%\MSOCache rmdir /S /Q %SystemDrive%\MSOCache 

:: JOB: Remove the Windows installation cache. Can be up to 1.0 GB
if exist %SystemDrive%\i386 rmdir /S /Q %SystemDrive%\i386 
		
:: JOB: Empty all recycle bins on Windows 5.1 (XP/2k3) and 6.x (Vista and up) systems
if exist %SystemDrive%\RECYCLER rmdir /s /q %SystemDrive%\RECYCLER
if exist %SystemDrive%\$Recycle.Bin rmdir /s /q %SystemDrive%\$Recycle.Bin

:: JOB: Clear MUI cache
reg delete "HKCU\SOFTWARE\Classes\Local Settings\Muicache" /f

:: JOB: Windows update logs & built-in backgrounds (space waste)
del /F /Q %WINDIR%\*.log 2>NUL
del /F /Q %WINDIR%\*.txt 2>NUL
del /F /Q %WINDIR%\*.bmp 2>NUL
del /F /Q %WINDIR%\*.tmp 2>NUL
del /F /Q %WINDIR%\Web\Wallpaper\*.* 2>NUL
rmdir /S /Q %WINDIR%\Web\Wallpaper\Dell 2>NUL

:: JOB: Flash cookies (both locations)
rmdir /S /Q "%APPDATA%\Macromedia\Flash Player\#SharedObjects" 2>NUL
rmdir /S /Q "%APPDATA%\Macromedia\Flash Player\macromedia.com\support\flashplayer\sys" 2>NUL


::::::::::::::::::::::
:: Version-specific :: (these jobs run depending on OS version)
::::::::::::::::::::::
:: JOB: Windows XP/2k3: "guided tour" annoyance
if /i "%WIN_VER:~0,9%"=="Microsoft" (
	del %WINDIR%\system32\dllcache\tourstrt.exe 2>NUL
	del %WINDIR%\system32\dllcache\tourW.exe 2>NUL
	rmdir /S /Q %WINDIR%\Help\Tours 2>NUL
	)


:: JOB: Windows Server: remove built-in media files (all Server versions)
echo %WIN_VER% | findstr /i /c:"server" >NUL
if %ERRORLEVEL%==0 (
	echo.
	echo  ! Server operating system detected.
	echo    Removing built-in media files ^(.wav, .midi, etc^)...
	echo.
	echo.  && echo  ! Server operating system detected. Removing built-in media files ^(.wave, .midi, etc^)... && echo. 

	:: 2. Take ownership of the files so we can actually delete them. By default even Administrators have Read-only rights. 
	echo    Taking ownership of %WINDIR%\Media in order to delete files... && echo.
	echo    Taking ownership of %WINDIR%\Media in order to delete files...  && echo. 
	if exist %WINDIR%\Media takeown /f %WINDIR%\Media /r /d y 2>NUL && echo. 
	if exist %WINDIR%\Media icacls %WINDIR%\Media /grant administrators:F /t  && echo. 
	
	:: 3. Do the cleanup
	rmdir /S /Q %WINDIR%\Media 2>NUL
	
	echo    Done.
	echo.
	echo    Done. 
	echo. 
	)

:: JOB: Windows CBS logs
::      these only exist on Vista and up, so we look for "Microsoft", and assuming we don't find it, clear out the folder
echo %WIN_VER% | findstr /i /c:"server" >NUL
if not %ERRORLEVEL%==0 del /F /Q %WINDIR%\Logs\CBS\* 2>NUL

:: JOB: Windows XP/2003: Cleanup hotfix uninstallers. They use a lot of space so removing them is beneficial.
:: Really we should use a tool that deletes their corresponding registry entries, but oh well.

::  0. Check Windows version.
::    We simply look for "Microsoft" in the version name, because only versions prior to Vista had the word "Microsoft" as part of their version name
::    Everything after XP/2k3 drops the "Microsoft" prefix
echo %WIN_VER% | findstr /i /c:"Microsoft" >NUL
if %ERRORLEVEL%==0 (
	:: 1. If we made it here we're doing the cleanup. Notify user and log it.
	echo.
	echo  ! Windows XP/2003 detected.
	echo    Removing hotfix uninstallers...
	echo.
	echo.  && echo  ! Windows XP/2003 detected. Removing hotfix uninstallers...

	:: 2. Build the list of hotfix folders. They always have "$" signs around their name, e.g. "$NtUninstall092330$" or "$hf_mg$"
	pushd %WINDIR%
	dir /A:D /B $*$ > %TEMP%\hotfix_nuke_list.txt 2>NUL

	:: 3. Do the hotfix clean up
	for /f %%i in (%TEMP%\hotfix_nuke_list.txt) do (
		echo Deleting %%i...
		echo Deleted folder %%i 
		rmdir /S /Q %%i 2>NUL
		)

	:: 4. Log that we are done with hotfix cleanup and leave the Windows directory
	echo    Done.  && echo.
	echo    Done. 
	del %TEMP%\hotfix_nuke_list.txt
	echo.
	popd
)

echo   Done. && echo.
echo   Done. && echo.

::::::::::::::::::::::::::
:: Cleanup and complete ::
::::::::::::::::::::::::::
:complete
@echo off
echo --------------------------------------------------------------------------------------------
echo %CUR_DATE% %TIME%  TempFileCleanup v%SCRIPT_VERSION%, finished. Executed as %USERDOMAIN%\%USERNAME%
echo --------------------------------------------------------------------------------------------
echo.
echo  Cleanup complete.
echo.
echo  Log saved at: %LOGPATH%\%LOGFILE%
echo.
ENDLOCAL
