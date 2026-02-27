from rest_framework.routers import DefaultRouter
from .views import PackingItemViewSet, TripPackingItemViewSet

router = DefaultRouter()
router.register(r'items', PackingItemViewSet, basename='packingitem')
router.register(r'trip-items', TripPackingItemViewSet, basename='trippackingitem')

urlpatterns = router.urls
