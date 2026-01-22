#!/bin/bash

# CloudAppHW Local Deployment Script (Mac/Linux)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}   CloudAppHW Local Deployment Script     ${NC}"
echo -e "${GREEN}==========================================${NC}"

# Ensure we are in the project root
cd "$(dirname "$0")/.." || exit
echo "Working directory: $(pwd)"

# Check for Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}Error: Node.js is not installed.${NC}"
    echo "Please install Node.js from https://nodejs.org/"
    exit 1
fi
echo -e "Node.js version: $(node -v)"

# Check for MySQL
if ! command -v mysql &> /dev/null; then
    echo -e "${YELLOW}Warning: 'mysql' command not found.${NC}"
    echo "You cannot automatically initialize the database, but you can continue if your DB is already set up."
else
    echo -e "MySQL client found."
fi

# Step 1: Database Setup
echo -e "\n${YELLOW}------------------------------------------${NC}"
echo -e "${YELLOW}Step 1: Database Setup${NC}"
echo "This step will create the 'travel_app_db' database and tables."
read -p "Do you want to run the database initialization script? (y/n): " RUN_DB_INIT

if [[ "$RUN_DB_INIT" =~ ^[Yy]$ ]]; then
    if ! command -v mysql &> /dev/null; then
        echo -e "${RED}Error: Cannot run init script without mysql client.${NC}"
        exit 1
    fi

    read -p "Enter MySQL User (default: root): " DB_USER
    DB_USER=${DB_USER:-root}
    read -s -p "Enter MySQL Password: " DB_PASS
    echo ""
    
    echo "Running local_scripts/init_db.sql..."
    if [ -z "$DB_PASS" ]; then
         mysql -u "$DB_USER" < ./local_scripts/init_db.sql
    else
         mysql -u "$DB_USER" -p"$DB_PASS" < ./local_scripts/init_db.sql
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Database initialized successfully.${NC}"
    else
        echo -e "${RED}Error initializing database. Please check your credentials.${NC}"
        echo "You can manually import local_scripts/init_db.sql if this persists."
        read -p "Continue anyway? (y/n): " CONTINUE_DB
        if [[ ! "$CONTINUE_DB" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
else
    echo "Skipping database initialization."
fi

# Step 2: Backend Setup
echo -e "\n${YELLOW}------------------------------------------${NC}"
echo -e "${YELLOW}Step 2: Backend Setup${NC}"
cd backend-api || exit

if [ ! -f .env ]; then
    echo "Creating .env file from example..."
    cp .env.example .env
    echo -e "${RED}IMPORTANT: You must configure backend-api/.env now.${NC}"
    
    # Attempt to update DB_USER if we know it
    if [ -n "$DB_USER" ]; then
        # Use perl to avoid cross-platform sed issues or just simple sed
        sed -i.bak "s/DB_USER=root/DB_USER=$DB_USER/" .env || true
        rm -f .env.bak
    fi

    echo "Opening .env for editing..."
    if [ -n "$EDITOR" ]; then
        $EDITOR .env
    elif command -v nano &> /dev/null; then
        nano .env
    elif command -v vi &> /dev/null; then
        vi .env
    else
        echo "Could not open editor. Please edit backend-api/.env manually in another window."
    fi
    read -p "Press Enter after you have finished editing backend-api/.env..."
fi

echo "Installing backend dependencies..."
npm install

echo "Starting Backend..."
# Run in background
nohup npm start > backend.log 2>&1 &
BACKEND_PID=$!
echo -e "${GREEN}Backend started with PID $BACKEND_PID.${NC}"
echo "Logs are being written to backend-api/backend.log"
sleep 2

# Check if it died immediately
if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo -e "${RED}Backend failed to start. Check backend-api/backend.log${NC}"
    cat backend.log
    exit 1
fi

# Step 3: Frontend Setup
echo -e "\n${YELLOW}------------------------------------------${NC}"
echo -e "${YELLOW}Step 3: Frontend Setup${NC}"
cd ../frontend-vue || exit

if [ ! -f .env ]; then
    echo "Creating .env file from example..."
    cp .env.example .env
    echo -e "${RED}IMPORTANT: You must configure frontend-vue/.env now (Firebase config).${NC}"
    
    if [ -n "$EDITOR" ]; then
        $EDITOR .env
    elif command -v nano &> /dev/null; then
        nano .env
    elif command -v vi &> /dev/null; then
        vi .env
    else
         echo "Could not open editor. Please edit frontend-vue/.env manually in another window."
    fi
    read -p "Press Enter after you have finished editing frontend-vue/.env..."
fi

echo "Installing frontend dependencies..."
npm install

echo -e "\n${GREEN}Starting Frontend...${NC}"
echo -e "${GREEN}The application should happen at http://localhost:5173${NC}"
echo "Press Ctrl+C to stop both Backend and Frontend."

# Trap Ctrl+C to kill backend
trap "echo 'Stopping servers...'; kill $BACKEND_PID; exit" SIGINT SIGTERM

npm run dev
