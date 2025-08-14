"""
URL configuration for project.

Defines URL patterns for admin, authentication, dashboard, and API endpoints.
"""
from django.contrib import admin
from django.urls import path
from django.contrib.auth import views as auth_views
from .views import health, dashboard, LoginAPI, DashboardAPI, LogoutAPI

urlpatterns = [
    path('admin/', admin.site.urls),
    path('health/', health),
    path('', auth_views.LoginView.as_view(template_name='login.html'), name='login'),
    path('dashboard/', dashboard, name='dashboard'),
    path('logout/', auth_views.LogoutView.as_view(), name='logout'),
    path('api/login/', LoginAPI.as_view(), name='api-login'),
    path('api/dashboard/', DashboardAPI.as_view(), name='api-dashboard'),
    path('api/logout/', LogoutAPI.as_view(), name='api-logout'),
]
