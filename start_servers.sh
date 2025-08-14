#!/bin/bash

# start_servers.sh - Start Django and React servers on their default ports if available
# Usage: Run from the project root

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Detect LAN IP
LAN_IP=$(hostname -I | awk '{print $1}')

# Start Django backend
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

# Start React frontend
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
