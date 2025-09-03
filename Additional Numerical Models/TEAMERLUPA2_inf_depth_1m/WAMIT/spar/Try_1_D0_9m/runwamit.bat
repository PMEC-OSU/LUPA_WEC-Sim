:: Batch file for running all tests included in testruns directory
:: Freely distributed by WAMIT INC.
:: Make sure to set the environment variable WAMITV7DIR as the path to where the wamit executable is installed
:: Make sure that config.wam is set properly.

@echo off
echo "Cleaning up all of the files first ..."

del %1.out
del %1.fpt
del %1.idf
del %1.pnl
del %1.p2f
del %1.5pb
del %1.5v?
del %1.6??
del %1.??
del error*.%1

echo "Preparing to run %1"
call:runwamitFunc %1

goto:eof

:runwamitFunc
::del fnames.wam
::copy %~1.wam fnames.wam
\wamitv7\wamit
copy errorp.log errorp.%~1
copy errorf.log errorf.%~1
copy wamitlog.txt wamitlog.%~1

echo "%~1 complete.  I will open notepad to view output if you uncomment the next few lines.  Press space to continue..."
Pause

::notepad.exe errorp.%~1
::notepad.exe errorf.%~1
::notepad.exe wamitlog.%~1
::notepad.exe %~1.out

goto:eof
 