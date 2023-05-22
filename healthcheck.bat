@echo off
REM Environment Variables
REM HUB_HOST
REM BROWSER
REM MODULE

SET MAX_RETRIES=10
SET RETRY_INTERVAL=1
SET RETRY_COUNT=0

REM Function to exit the script with an error message
:exit_with_error
echo Error: %1
exit /b 1

:retry
SET /A RETRY_COUNT+=1

IF %RETRY_COUNT% GTR %MAX_RETRIES% (
  CALL :exit_with_error "Selenium Hub did not become ready after %MAX_RETRIES% retries."
)

REM Sleep for the specified interval before the next retry
ping -n %RETRY_INTERVAL% 127.0.0.1 > nul

FOR /F "tokens=3 delims=: " %%G IN ('curl -s http://%HUB_HOST%:4444/wd/hub/status ^| findstr /C:"\"ready\": true"') DO (
  IF "%%G"=="true" (
    echo Selenium Hub is ready. Starting test execution...
    REM Start the Java command
    java -cp selenium-docker.jar:selenium-docker-tests.jar:libs/* -DHUB_HOST=%HUB_HOST% -DBROWSER=%BROWSER% org.testng.TestNG %MODULE%
    exit /b 0
  )
)

CALL :retry