"""
Views for Django project.

Includes health check, dashboard rendering, and REST API endpoints for login, dashboard, and logout.
"""
from django.http import JsonResponse

from django.http import JsonResponse, HttpResponse
from django.contrib.auth.decorators import login_required
from django.shortcuts import render

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.contrib.auth import authenticate, login, logout
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator

def health(request):
    return JsonResponse({'status': 'ok'})

@login_required
def dashboard(request):
    return render(request, 'dashboard.html')

# API: Login
@method_decorator(csrf_exempt, name='dispatch')
class LoginAPI(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')
        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
            return Response({'success': True, 'username': user.username})
        return Response({'success': False, 'error': 'Invalid credentials'}, status=400)

# API: Dashboard (protected)
class DashboardAPI(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response({'message': f'Welcome {request.user.username}!', 'username': request.user.username})

# API: Logout
class LogoutAPI(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        logout(request)
        return Response({'success': True})
