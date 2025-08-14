#!/bin/bash

# stop_servers.sh - Stop Django and React servers and free their ports
# Usage: Run from the project root

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RESET='\033[0m'

stopped_any=false

# Stop Django backend by PID file
if [ -f backend_django.pid ]; then
    DJANGO_PID=$(cat backend_django.pid)
    if kill $DJANGO_PID 2>/dev/null; then
        echo -e "${GREEN}Stopped Django backend server (PID: $DJANGO_PID)${RESET}"
        rm backend_django.pid
        stopped_any=true
    else
        echo -e "${RED}Failed to stop Django backend with PID $DJANGO_PID (may not be running)${RESET}"
    fi
fi

# Stop React frontend by PID file
if [ -f frontend_react.pid ]; then
    REACT_PID=$(cat frontend_react.pid)
    if kill $REACT_PID 2>/dev/null; then
        echo -e "${GREEN}Stopped React frontend server (PID: $REACT_PID)${RESET}"
        rm frontend_react.pid
        stopped_any=true
    else
        echo -e "${RED}Failed to stop React frontend with PID $REACT_PID (may not be running)${RESET}"
    fi
fi

# Force kill any process using port 8000 (Django)
if lsof -ti :8000 >/dev/null 2>&1; then
    lsof -ti :8000 | xargs kill -9
    echo -e "${CYAN}Force killed all processes using port 8000 (Django)${RESET}"
    stopped_any=true
fi

# Force kill any process using port 5173 (React)
if lsof -ti :5173 >/dev/null 2>&1; then
    lsof -ti :5173 | xargs kill -9
    echo -e "${CYAN}Force killed all processes using port 5173 (React)${RESET}"
    stopped_any=true
fi

if [ "$stopped_any" = false ]; then
    echo -e "${CYAN}No running Django or React servers found to stop.${RESET}"
fi

echo -e "${CYAN}Logs are saved to backend_django.log and frontend_react.log.${RESET}"
