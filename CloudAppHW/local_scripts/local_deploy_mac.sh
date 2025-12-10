#!/bin/bash

# CloudAppHW Local Deployment for macOS
# Prerequisites: Homebrew

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Starting Local Deployment for macOS...${NC}"

# Ensure we are in the project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Assuming the script is in local_scripts/ inside the root
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"
echo -e "${BLUE}Working directory: $(pwd)${NC}"

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Homebrew is not installed. Please install it first: https://brew.sh/${NC}"
    exit 1
fi

# Install Dependencies
echo -e "${GREEN}Installing dependencies (node, mysql)...${NC}"
brew install node mysql

# Start MySQL
echo -e "${GREEN}Starting MySQL service...${NC}"
brew services start mysql
# Wait a bit for MySQL to be ready
sleep 5

# Configure Database
echo -e "${GREEN}Configuring Database...${NC}"
MYSQL_CMD="mysql -u root"

# DB Initialization SQL
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

# Check if we can connect without password
if $MYSQL_CMD -e "SELECT 1" &> /dev/null; then
    $MYSQL_CMD -e "$DB_INIT_SQL"
    echo -e "${GREEN}Database configured successfully.${NC}"
else
    echo -e "${BLUE}MySQL root password seems to be set. Please enter it to configure the database:${NC}"
    mysql -u root -p -e "$DB_INIT_SQL"
fi

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
# IMPORTANT: Add your actual keys below
GEMINI_API_KEY=
GCP_PROJECT_ID=
# GCP_SERVICE_ACCOUNT_JSON=./path/to/your/service-account.json
EOF
    echo -e "${RED}Created backend-api/.env. Please edit it to add your API keys!${NC}"
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

# Open Backend in new tab
osascript -e 'tell app "Terminal" to do script "cd \"'$(pwd)'/backend-api\" && echo \"Starting Backend...\" && node server.js"'

# Open Frontend in new tab
osascript -e 'tell app "Terminal" to do script "cd \"'$(pwd)'/frontend-vue\" && echo \"Starting Frontend...\" && npm run dev"'

echo -e "${GREEN}Deployment scripts launched in new Terminal windows!${NC}"
echo -e "${BLUE}Backend running on port 3000.${NC}"
echo -e "${BLUE}Frontend will likely run on http://localhost:5173${NC}"
