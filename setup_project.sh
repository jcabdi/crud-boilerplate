# ...existing code...
#!/bin/bash

# Bash script to rename the Django project folder and update all references
# Usage: Run this script from the project root

# --- Color definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
# YELLOW color is no longer used
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
RESET='\033[0m'

 # Prompt for new project name
echo -e "${CYAN}${BOLD}${UNDERLINE}Django + React CRUD Project Customizer${RESET}"
read -p $'\nEnter your new Django project name (no spaces): ' NEWNAME

# Prompt for author name and email
read -p $'Enter author name: ' AUTHOR_NAME
read -p $'Enter author email: ' AUTHOR_EMAIL
echo

OLDNAME="django_folder"
BACKEND_DIR="backend"

# Rename project folder
echo -e "${CYAN}Renaming $BACKEND_DIR/$OLDNAME to $BACKEND_DIR/$NEWNAME ...${RESET}"
mv "$BACKEND_DIR/$OLDNAME" "$BACKEND_DIR/$NEWNAME"

# Replace occurrences in all files (excluding .git and __pycache__)
echo -e "${CYAN}Updating references in files ...${RESET}"
grep -rl --exclude-dir={.git,__pycache__} "$OLDNAME" "$BACKEND_DIR/" | xargs sed -i "s/$OLDNAME/$NEWNAME/g"


# Also update the project name and author in the pyproject.toml file
TOML_FILE="$BACKEND_DIR/pyproject.toml"
if [ -f "$TOML_FILE" ]; then
    echo -e "${CYAN}Updating project name in $TOML_FILE ...${RESET}"
    sed -i "s/name = \".*\"/name = \"$NEWNAME\"/g" "$TOML_FILE"
    echo -e "${CYAN}Updating author in $TOML_FILE ...${RESET}"
    sed -i "s|authors = \[.*\]|authors = [\"$AUTHOR_NAME <$AUTHOR_EMAIL>\"]|g" "$TOML_FILE"
fi

# Update the welcome message in the login interface (frontend)
LOGIN_FILE="frontend/react_interface/src/Login.jsx"
if [ -f "$LOGIN_FILE" ]; then
    echo -e "${CYAN}Updating welcome message in $LOGIN_FILE ...${RESET}"
    sed -i "s/Welcome to [A-Za-z0-9_ -]* Portal/Welcome to $NEWNAME Portal/g" "$LOGIN_FILE"
fi

# Optionally, rename the database file if it uses the old name
db_old="$BACKEND_DIR/data/project.sqlite3"
db_new="$BACKEND_DIR/data/${NEWNAME}.sqlite3"
if [ -f "$db_old" ]; then
    echo -e "${CYAN}Renaming database file ...${RESET}"
    mv "$db_old" "$db_new"
    sed -i "s/project.sqlite3/${NEWNAME}.sqlite3/g" "$BACKEND_DIR/$NEWNAME/settings.py"
fi

echo -e "${GREEN}${BOLD}Project renaming complete!${RESET}"

# Install backend dependencies
echo -e "${CYAN}Installing backend dependencies with poetry...${RESET}"
cd "$BACKEND_DIR"
# Do not use any color codes here, let poetry handle its own output
poetry install --no-root
cd ..
echo

# --- LAN IP confirmation and server instructions ---
LAN_IP=$(hostname -I | awk '{print $1}')
echo -e "${CYAN}Detected LAN IP: ${BOLD}$LAN_IP${RESET}"
echo -e "${CYAN}This IP will be used to configure Django's ALLOWED_HOSTS and CORS settings, so your project is accessible from other devices on your network.${RESET}"
read -p $'If this is correct, press [Enter]. To use a different IP, type it and press [Enter]: ' USER_IP
if [ -n "$USER_IP" ]; then
    LAN_IP="$USER_IP"
fi
echo -e "${CYAN}Using LAN IP: ${BOLD}$LAN_IP${RESET}"

# Update ALLOWED_HOSTS and CORS_ALLOWED_ORIGINS in settings.py
SETTINGS_FILE="$BACKEND_DIR/$NEWNAME/settings.py"
if [ -f "$SETTINGS_FILE" ]; then
    echo -e "${CYAN}Updating ALLOWED_HOSTS and CORS_ALLOWED_ORIGINS in $SETTINGS_FILE ...${RESET}"
    sed -i "s/ALLOWED_HOSTS = \[.*\]/ALLOWED_HOSTS = ['localhost', '${LAN_IP}']/g" "$SETTINGS_FILE"
    # Robustly replace the entire CORS_ALLOWED_ORIGINS block (multi-line safe)
    sed -i "/CORS_ALLOWED_ORIGINS = \[/,/^]/c\CORS_ALLOWED_ORIGINS = [\"http://${LAN_IP}:5173\",]" "$SETTINGS_FILE"
fi

echo
echo -e "${CYAN}Installing frontend dependencies with npm...${RESET}"
cd frontend/react_interface
npm install
cd ../..
echo -e "${GREEN}${BOLD}Frontend dependencies installed successfully!${RESET}"
echo
# --- Backend setup ---
echo -e "${GREEN}${BOLD}Setup complete!${RESET}"
echo -e "\n${BOLD}To run the Django backend for LAN access, use:${RESET}"
echo -e "  ${CYAN}cd backend${RESET}"
echo -e "  ${CYAN}poetry shell${RESET}"
echo -e "  ${CYAN}python manage.py runserver 0.0.0.0:8000${RESET}"
echo -e "${BOLD}To run the React frontend for LAN access, use:${RESET}"
echo -e "  ${CYAN}cd frontend/react_interface${RESET}"
echo -e "  ${CYAN}npm run dev -- --host 0.0.0.0${RESET}"

# --- Default credentials and admin info ---
echo -e "\n${CYAN}${BOLD}Default login credentials for the web interface:${RESET}"
echo -e "  ${BOLD}Username:${RESET} admin"
echo -e "  ${BOLD}Password:${RESET} admin1234567890"
echo -e "\n${RED}A Django admin (superuser) account is already created with these credentials.${RESET}"
echo -e "${CYAN}You can access the Django admin interface at:${RESET} http://${LAN_IP}:8000/admin/"
echo -e "${RED}For security, log in to the admin interface and change the password or create a new superuser as soon as possible.${RESET}"

# --- Optionally run backend and frontend servers automatically ---
echo -e "\n${BOLD}Would you like to start the Django backend server now?${RESET} (y/n) "
read -r RUN_BACKEND
if [[ "$RUN_BACKEND" =~ ^[Yy]$ ]]; then
    # Check if port 8000 is available
    if lsof -i :8000 >/dev/null 2>&1; then
        echo -e "${RED}Port 8000 is already in use. The Django backend server will NOT be started to avoid running on a different port.${RESET}"
        echo -e "${CYAN}Please free port 8000 and try again if you want to run the Django backend server on the default port.${RESET}"
    else
        echo -e "${CYAN}Starting Django backend server in background...${RESET}"
        nohup bash -c 'cd backend && poetry run python manage.py runserver 0.0.0.0:8000' > backend_django.log 2>&1 &
        DJANGO_PID=$!
        echo $DJANGO_PID > backend_django.pid
        echo -e "${GREEN}Django backend server started on http://${LAN_IP}:8000 (PID: $DJANGO_PID)${RESET}"
        echo -e "  Log: backend_django.log | PID file: backend_django.pid"
    fi
fi


echo -e "\n${BOLD}Would you like to start the React frontend server now?${RESET} (y/n) "
read -r RUN_FRONTEND
if [[ "$RUN_FRONTEND" =~ ^[Yy]$ ]]; then
    # Check if port 5173 is available
    if lsof -i :5173 >/dev/null 2>&1; then
        echo -e "${RED}Port 5173 is already in use. The React server will NOT be started to avoid running on a different port.${RESET}"
        echo -e "${CYAN}Please free port 5173 and try again if you want to run the React server on the default port.${RESET}"
    else
        echo -e "${CYAN}Starting React frontend server in background...${RESET}"
        nohup bash -c 'cd frontend/react_interface && npm run dev -- --host 0.0.0.0' > frontend_react.log 2>&1 &
        REACT_PID=$!
        echo $REACT_PID > frontend_react.pid
        echo -e "${GREEN}React frontend server started on http://${LAN_IP}:5173 (PID: $REACT_PID)${RESET}"
        echo -e "  Log: frontend_react.log | PID file: frontend_react.pid"
    fi
fi

echo -e "\n${CYAN}To stop the servers, run the following commands from the project root:${RESET}"
echo -e "  ${CYAN}if [ -f backend_django.pid ]; then kill \$(cat backend_django.pid) && rm backend_django.pid; fi${RESET}"
echo -e "  ${CYAN}if [ -f frontend_react.pid ]; then kill \$(cat frontend_react.pid) && rm frontend_react.pid; fi${RESET}"
echo -e "  ${CYAN}lsof -ti :8000 | xargs kill -9${RESET}   # Force kill any process using port 8000 (Django)"
echo -e "  ${CYAN}lsof -ti :5173 | xargs kill -9${RESET}   # Force kill any process using port 5173 (React)"
echo -e "${CYAN}Logs are saved to backend_django.log and frontend_react.log.${RESET}"

# --- Extra: Kill strayed running servers ---
echo -e "\n${RED}If you suspect there are strayed Django or React servers running, you can kill them with:${RESET}"
echo -e "  ${CYAN}pgrep -f 'manage.py runserver' | xargs kill -9${RESET}   # Kill all Django runserver processes"
echo -e "  ${CYAN}pgrep -f 'npm run dev' | xargs kill -9${RESET}           # Kill all React dev servers"
echo -e "${CYAN}You can check with 'ps aux | grep runserver' or 'ps aux | grep npm' before killing if you want to review.${RESET}"
