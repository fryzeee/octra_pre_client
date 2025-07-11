@echo off
ECHO.
ECHO Checking for Python installation...

REM Check if Python is installed and in the PATH
where python >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    ECHO Error: Python is not installed or not found in your PATH.
    PAUSE
    EXIT /B 1
)

ECHO.
ECHO Checking for virtual environment...

REM Check if the virtual environment doesn't exist, then create a new one
IF NOT EXIST "venv\Scripts\activate.bat" (
    ECHO Info: Virtual Environment not found. Performing setup...
    
    REM Remove the venv directory if it exists but is incomplete
    IF EXIST "venv" (
        ECHO Removing incomplete 'venv' directory...
        RMDIR /S /Q venv
    )
    
    ECHO 1. Creating Virtual Environment...
    python -m venv venv
    ECHO.
    ECHO Setup Complete.
)

REM Activate the virtual environment
ECHO Activating Virtual Environment...
CALL venv\Scripts\activate.bat

REM Install packages from requirements.txt
ECHO Installing package requirements...
pip install --no-cache-dir -r requirements.txt

REM Run the main program
ECHO.
ECHO Running Program...
python cli.py

ECHO.
ECHO Script has finished.
PAUSE
