#!/bin/bash -x
# Script to set up a new Django CRUD project using Poetry and SQLite

set -e

PROJECT_NAME="project"
SUPERUSER="admin"
SUPEREMAIL="admin@example.com"
SUPERPASS="Jcab90100"
DB_DIR="data"
DB_NAME="$DB_DIR/$PROJECT_NAME.sqlite3"

# Create project directory

mkdir -p "$PROJECT_NAME/$DB_DIR"
cd "$PROJECT_NAME"


# Initialize Poetry and create Django project

poetry init --no-interaction --name "$PROJECT_NAME" --dependency django --dependency djangorestframework

# Create a empty README.md before poetry install to avoid Poetry warning

touch README.md

echo "Complete README.md created."

poetry install --no-root
poetry run django-admin startproject $PROJECT_NAME .

# Update Django settings for SQLite DB
SETTINGS_FILE="$PROJECT_NAME/settings.py"
sed -i "s|'NAME': BASE_DIR / 'db.sqlite3'|'NAME': BASE_DIR / '$DB_NAME'|" "$SETTINGS_FILE"

# Make initial migrations and migrate
poetry run python manage.py migrate
echo "Complete: Project initialized, database configured, and migrated."

# Add rest_framework to INSTALLED_APPS
sed -i "/INSTALLED_APPS = \[/a \\    'rest_framework'," "$SETTINGS_FILE"
echo "Step 4 complete: Django REST Framework installed and configured."

# Check if the database file was created
if [ -f "$DB_NAME" ]; then
    echo "Project '$PROJECT_NAME' created with SQLite DB at '$DB_NAME'."
else
    echo "Project '$PROJECT_NAME' created, but database file '$DB_NAME' not found. Check Django settings."
fi


# Create Superuser (non-interactive)
poetry run python manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.filter(username='$SUPERUSER').exists() or User.objects.create_superuser('$SUPERUSER', '$SUPEREMAIL', '$SUPERPASS')"

# Add a health check endpoint
cat <<EOPY > $PROJECT_NAME/views.py
from django.http import JsonResponse
def health(request):
    return JsonResponse({'status': 'ok'})
EOPY

cat <<EOPY > $PROJECT_NAME/urls.py
from django.contrib import admin
from django.urls import path
from .views import health

urlpatterns = [
    path('admin/', admin.site.urls),
    path('health/', health),
]
EOPY

echo "Complete: Health check endpoint added at /health/."


# --- Frontend LAN configuration ---
# Detect LAN IP
LAN_IP=$(hostname -I | awk '{print $1}')

# Set up frontend .env for LAN access to backend
FRONTEND_ENV_FILE="../frontend/react_interface/.env"
echo "VITE_API_URL=http://$LAN_IP:8000" > "$FRONTEND_ENV_FILE"
echo "Frontend .env created/updated with backend LAN URL: http://$LAN_IP:8000"

# Print Vite dev server command for LAN access
echo "To run the React frontend for LAN access, use:"
echo "  cd ../frontend/react_interface"
echo "  npm install"
echo "  npm run dev -- --host 0.0.0.0"

echo "Setup complete!"
echo "Superuser credentials:"
echo "  Username: $SUPERUSER"
echo "  Email: $SUPEREMAIL"
echo "  Password: $SUPERPASS"
echo "Run 'poetry run python manage.py runserver 0.0.0.0:8000' to start the server for LAN access."
# End of setup_project_crud.sh