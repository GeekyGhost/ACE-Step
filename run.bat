@echo off
setlocal enabledelayedexpansion

REM Set the current directory as the project directory
set "PROJECT_DIR=%~dp0"
cd /d "%PROJECT_DIR%"

REM Check if Python is installed
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Python is not installed or not in PATH. Please install Python 3.10 or later.
    goto :end
)

REM Check if virtual environment exists, create if not
if not exist "venv\" (
    echo Creating virtual environment...
    python -m venv venv
    if !ERRORLEVEL! NEQ 0 (
        echo Failed to create virtual environment.
        goto :end
    )
    echo Virtual environment created successfully.
) else (
    echo Virtual environment already exists.
)

REM Activate the virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat
if %ERRORLEVEL% NEQ 0 (
    echo Failed to activate virtual environment.
    goto :end
)

REM Check if requirements are installed
echo Checking requirements...
pip freeze | findstr /C:"torch" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Installing requirements...
    
    REM Check if CUDA is available and install appropriate PyTorch version
    nvidia-smi >nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        echo NVIDIA GPU detected, installing PyTorch with CUDA support...
        pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
    )
    
    REM Install the package and dependencies
    pip install -e .
    if !ERRORLEVEL! NEQ 0 (
        echo Failed to install requirements.
        goto :end
    )
    echo Requirements installed successfully.
) else (
    echo Requirements already installed.
)

REM Check if models have been downloaded
echo Checking if models are downloaded...
REM We'll use the acestep command with a checkpoint path check first
set "MODELS_DOWNLOADED=false"

REM Attempt to run with --help to see if the command is available
acestep --help >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ACE-Step command is available. Models will be downloaded automatically if needed.
    set "MODELS_DOWNLOADED=true"
)

REM Launch the UI
echo Launching ACE-Step UI...
echo.
echo The model will be downloaded automatically on first run if needed.
echo The UI will be available at http://127.0.0.1:7865 once it starts.
echo.

REM Launch ACE-Step with default settings
echo Running ACE-Step...
acestep

:end
endlocal
pause