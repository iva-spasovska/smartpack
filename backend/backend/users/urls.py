# from rest_framework.routers import DefaultRouter
# from django.urls import path
# from .views import UserProfileViewSet, RegisterView
#
# router = DefaultRouter()
# router.register(r'profile', UserProfileViewSet, basename='profile')
#
# urlpatterns = [
#     path('register/', RegisterView.as_view({'post': 'create'}), name='register'),
# ] + router.urls

from django.urls import path
from .views import UserProfileView, RegisterView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('profile/', UserProfileView.as_view(), name='profile'),
]