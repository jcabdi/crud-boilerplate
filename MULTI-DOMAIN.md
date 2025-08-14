
# Multi-Domain Support in Django

This document explains approaches for serving multiple domains or customers with Django, including scenarios where each customer has different data needs and their own URL.

## Basic Multi-Domain Setup

1. **ALLOWED_HOSTS**

   Add all your domains to the `ALLOWED_HOSTS` list in `settings.py`:

   ```python
   ALLOWED_HOSTS = ['domain1.com', 'domain2.com', 'sub.domain3.com']
   ```

2. **CORS**

   Add all frontend domains to `CORS_ALLOWED_ORIGINS`:

   ```python
   CORS_ALLOWED_ORIGINS = [
       "https://frontend1.com",
       "https://frontend2.com",
   ]
   ```

3. **Dynamic Handling**

   For advanced setups (per-domain logic, custom branding, or tenant separation), use Django’s `sites` framework or a package like `django-hosts` or `django-tenants`.

4. **Automation**

   You can extend your setup script to prompt for a comma-separated list of domains and update `ALLOWED_HOSTS` and `CORS_ALLOWED_ORIGINS` accordingly.

---

## Serving Different Customers with Different Data Models

Suppose you want to serve two different customers, each with their own data needs (e.g., one manages books, the other manages client data), and each should access their data via a unique URL. Here are the main architectural options:

### 1. Multi-Tenant (Single Project, Isolated Data)

- Use a single Django project.
- Use a package like `django-tenants` or `django-tenant-schemas` to isolate data per customer (tenant).
- Each customer gets a unique subdomain or domain (e.g., `customer1.yourapp.com`, `customer2.yourapp.com`).
- The database is shared, but data is separated at the schema or row level.
- You can customize models per tenant (advanced).

**Pros:**

- Centralized codebase and deployment.
- Scalable for many customers.

**Cons:**

- More complex setup.
- Custom per-tenant models require advanced configuration.

### 2. Multi-Project (Separate Django Apps/Projects)

- Create two separate Django projects or apps, each with its own models and database.
- Deploy each project on a different URL (e.g., `books.yourapp.com`, `clients.yourapp.com`).
- Each project is fully independent.

**Pros:**

- Simple, clear separation.
- Each project can evolve independently.

**Cons:**

- Code duplication if there’s shared logic.
- Harder to maintain as the number of customers grows.

### 3. Single Project, Multiple Apps, URL Routing

- Use a single Django project.
- Create separate Django apps: one for books, one for clients.
- Use URL routing to serve each app at a different path or subdomain (e.g., `/books/`, `/clients/`).
- Use permissions/authentication to ensure users only access their own data.

**Pros:**

- Easier to share code and logic.
- Simple to set up for a small number of customers.

**Cons:**

- Not true data isolation (unless you enforce it).
- All data in the same database.

---

## Summary

- **For strict data isolation and scalability:** use a multi-tenant approach with `django-tenants`.
- **For simple, small-scale needs:** use separate apps in one project, or separate projects.
- **Always use authentication and permissions to ensure data privacy.**
