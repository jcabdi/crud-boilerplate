# Changing Database Type in Django

This guide explains how to switch your Django project to a different database backend (e.g., from SQLite to PostgreSQL or MySQL) for future scalability or production needs.

## 1. Install the Database Driver

- **PostgreSQL:**

  ```bash
  poetry add psycopg2-binary
  ```

- **MySQL:**

  ```bash
  poetry add mysqlclient
  ```

- **Other databases:**

  Check Django documentation for the appropriate driver.

## 2. Update `settings.py`

Edit the `DATABASES` section to match your new database. Example for PostgreSQL:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'your_db_name',
        'USER': 'your_db_user',
        'PASSWORD': 'your_db_password',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
```

For MySQL, use `'ENGINE': 'django.db.backends.mysql'` and the appropriate port/user/password.

## 3. Migrate the Database

Run migrations to set up the schema in the new database:

```bash
poetry run python manage.py migrate
```

## 4. Data Migration (Optional)

If you have existing data you want to move:

- Use Django’s `dumpdata` and `loaddata` commands:

  ```bash
  poetry run python manage.py dumpdata > db.json
  # After switching DB settings and migrating:
  poetry run python manage.py loaddata db.json
  ```

- For large or complex migrations, consider tools like `pgloader` (for SQLite to PostgreSQL).

## 5. Use Environment Variables (Recommended)

For production, keep sensitive database credentials out of source code. Use environment variables and packages like `python-dotenv` or Django’s `os.environ`.

## 6. Test Your Setup

- Run your app and ensure all features work as expected.
- Check for any database-specific issues (e.g., field types, migrations).

---

**Tip:** Always back up your data before making major changes to your database configuration.
