# Backend (Django)
FROM python:3.12-slim AS backend

WORKDIR /app/backend

# Install Poetry
RUN pip install poetry

# Copy backend files
COPY backend/ ./

# Install dependencies
RUN poetry config virtualenvs.create false && poetry install --no-interaction --no-root

# Collect static files (if needed)
# RUN poetry run python manage.py collectstatic --noinput

# Expose Django port
EXPOSE 8000

# Start Django server
CMD ["poetry", "run", "python", "manage.py", "runserver", "0.0.0.0:8000"]

# Frontend (React)
FROM node:20-slim AS frontend
WORKDIR /app/frontend/react_interface
COPY frontend/react_interface/ ./
RUN npm install && npm run build

# Production container (serving both)
FROM python:3.12-slim AS final
WORKDIR /app

# Copy backend from build stage
COPY --from=backend /app/backend /app/backend

# Copy frontend build to backend's staticfiles (optional, for serving with Django)
COPY --from=frontend /app/frontend/react_interface/dist /app/backend/django_folder/static/

WORKDIR /app/backend

EXPOSE 8000

CMD ["poetry", "run", "python", "manage.py", "runserver", "0.0.0.0:8000"]
