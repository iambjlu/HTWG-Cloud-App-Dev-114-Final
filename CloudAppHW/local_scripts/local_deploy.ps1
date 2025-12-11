# CloudAppHW Local Deployment Script (Windows)

# Ensure we are in the project root
$ScriptDir = Split-Path $MyInvocation.MyCommand.Path
Set-Location "$ScriptDir\.."
Write-Host "Working directory: $(Get-Location)"

Write-Host "==========================================" -ForegroundColor Green
Write-Host "   CloudAppHW Local Deployment Script     " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Check for Node.js
if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Node.js is not installed." -ForegroundColor Red
    Write-Host "Please install Node.js from https://nodejs.org/"
    exit
}
Write-Host "Node.js found."

# Check for MySQL
$mysqlCmd = Get-Command mysql -ErrorAction SilentlyContinue
if (!$mysqlCmd) {
    Write-Host "Warning: 'mysql' command not found." -ForegroundColor Yellow
    Write-Host "Ensure MySQL is installed and in your PATH for automatic DB setup."
}

# Step 1: Database Setup
Write-Host "`n------------------------------------------" -ForegroundColor Yellow
Write-Host "Step 1: Database Setup" -ForegroundColor Yellow
$runDbInit = Read-Host "Do you want to run the database initialization script? (y/n)"

if ($runDbInit -match "^[Yy]") {
    if (!$mysqlCmd) {
        Write-Host "Error: Cannot run init script without mysql client." -ForegroundColor Red
    } else {
        $dbUser = Read-Host "Enter MySQL User (default: root)"
        if ([string]::IsNullOrWhiteSpace($dbUser)) { $dbUser = "root" }
        
        Write-Host "Enter MySQL Password:"
        $passObj = Read-Host -AsSecureString
        $dbPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($passObj))

        Write-Host "Running local_scripts/init_db.sql..."
        
        $initSqlPath = Resolve-Path ".\local_scripts\init_db.sql"
        if ([string]::IsNullOrEmpty($dbPass)) {
            & mysql -u "$dbUser" -e "source $initSqlPath"
        } else {
            & mysql -u "$dbUser" -p"$dbPass" -e "source $initSqlPath"
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Database initialized successfully." -ForegroundColor Green
        } else {
            Write-Host "Error initializing database." -ForegroundColor Red
            Write-Host "You can manually import local_scripts/init_db.sql."
        }
    }
}

# Step 2: Backend Setup
Write-Host "`n------------------------------------------" -ForegroundColor Yellow
Write-Host "Step 2: Backend Setup" -ForegroundColor Yellow
Set-Location "backend-api"

if (!(Test-Path ".env")) {
    Write-Host "Creating .env file from example..."
    Copy-Item ".env.example" ".env"
    Write-Host "IMPORTANT: You must configure backend-api/.env now." -ForegroundColor Red
    Start-Process "notepad" ".env" -Wait
    Read-Host "Press Enter after you have saved and closed the .env file..."
}

Write-Host "Installing backend dependencies..."
npm install

Write-Host "Starting Backend in background..."
# Start npm start in a new minimized window
$backendProcess = Start-Process npm -ArgumentList "start" -PassThru -WindowStyle Minimized
if ($backendProcess) {
    Write-Host "Backend started with PID $($backendProcess.Id)." -ForegroundColor Green
    Write-Host "Backend logs will appear in the minimized window."
} else {
    Write-Host "Failed to start backend." -ForegroundColor Red
}

# Step 3: Frontend Setup
Write-Host "`n------------------------------------------" -ForegroundColor Yellow
Write-Host "Step 3: Frontend Setup" -ForegroundColor Yellow
Set-Location "..\frontend-vue"

if (!(Test-Path ".env")) {
    Write-Host "Creating .env file from example..."
    Copy-Item ".env.example" ".env"
    Write-Host "IMPORTANT: You must configure frontend-vue/.env now (Firebase config)." -ForegroundColor Red
    Start-Process "notepad" ".env" -Wait
    Read-Host "Press Enter after you have saved and closed the .env file..."
}

Write-Host "Installing frontend dependencies..."
npm install

Write-Host "`nStarting Frontend..." -ForegroundColor Green
Write-Host "The application will run at http://localhost:5173" -ForegroundColor Green
Write-Host "To stop the backend, find the minimized Node/npm window and close it."

npm run dev
