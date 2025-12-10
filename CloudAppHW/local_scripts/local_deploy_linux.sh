#!/bin/bash

# CloudAppHW Local Deployment for Linux (Ubuntu/Debian)

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Starting Local Deployment for Linux...${NC}"

# Ensure we are in the project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Assuming the script is in local_scripts/ inside the root
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"
echo -e "${BLUE}Working directory: $(pwd)${NC}"

# Update and Install Dependencies
echo -e "${GREEN}Updating package list and installing dependencies...${NC}"
sudo apt update
sudo apt install -y curl

# Install Node.js (Version 20.x)
if ! command -v node &> /dev/null; then
    echo -e "${BLUE}Installing Node.js...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
else
    echo -e "${GREEN}Node.js is already installed.${NC}"
fi

# Install MySQL Server
if ! command -v mysql &> /dev/null; then
    echo -e "${BLUE}Installing MySQL Server...${NC}"
    sudo apt install -y mysql-server
else
    echo -e "${GREEN}MySQL is already installed.${NC}"
fi

# Start MySQL
echo -e "${GREEN}Ensuring MySQL service is running...${NC}"
sudo systemctl start mysql
sudo systemctl enable mysql

# Configure Database
echo -e "${GREEN}Configuring Database...${NC}"

DB_INIT_SQL="
CREATE DATABASE IF NOT EXISTS cloud_app_db;
USE cloud_app_db;
CREATE TABLE IF NOT EXISTS travellers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255)
);
CREATE TABLE IF NOT EXISTS itineraries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    traveller_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    destination VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    short_description VARCHAR(80),
    detail_description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (traveller_id) REFERENCES travellers(id) ON DELETE CASCADE
);
"

# On Ubuntu, sudo mysql usually allows root login via socket
echo -e "${BLUE}Setting up database tables (using sudo mysql)...${NC}"
sudo mysql -e "$DB_INIT_SQL"

# Setup Backend
echo -e "${GREEN}Setting up Backend...${NC}"
cd backend-api
if [ ! -f .env ]; then
    echo -e "${BLUE}Creating .env for Backend...${NC}"
    cat <<EOF > .env
PORT=3000
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=cloud_app_db
# Note: If your app cannot connect as root without password, you may need to create a dedicated SQL user.
GEMINI_API_KEY=
GCP_PROJECT_ID=
EOF
    echo -e "${RED}IMPORTANT: Please edit backend-api/.env and add your GEMINI_API_KEY!${NC}"
fi
npm install
cd ..

# Setup Frontend
echo -e "${GREEN}Setting up Frontend...${NC}"
cd frontend-vue
if [ ! -f .env ]; then
    echo -e "${BLUE}Creating .env for Frontend...${NC}"
    echo "VITE_API_BASE_URL=http://localhost:3000" > .env
fi
npm install
cd ..

# Run Servers
echo -e "${GREEN}Starting Servers...${NC}"

# Start Backend in background
echo -e "${BLUE}Starting Backend...${NC}"
cd backend-api
nohup node server.js > backend.log 2>&1 &
BACKEND_PID=$!
echo -e "${GREEN}Backend started (PID: $BACKEND_PID). Logs: backend-api/backend.log${NC}"
cd ..

# Start Frontend in background
echo -e "${BLUE}Starting Frontend...${NC}"
cd frontend-vue
nohup npm run dev > frontend.log 2>&1 &
FRONTEND_PID=$!
echo -e "${GREEN}Frontend started (PID: $FRONTEND_PID). Logs: frontend-vue/frontend.log${NC}"
cd ..

echo -e "${GREEN}Application deployed successfully!${NC}"
echo -e "Access the app at: http://localhost:5173"
echo -e "To stop the servers, use 'kill $BACKEND_PID' and 'kill $FRONTEND_PID' (or pkill node)"
