from rest_framework.routers import DefaultRouter
from .views import PackingItemViewSet, TripPackingItemViewSet, UserPackingListViewSet

router = DefaultRouter()
router.register(r'items', PackingItemViewSet, basename='packingitem')
router.register(r'trip-items', TripPackingItemViewSet, basename='trippackingitem')
router.register(r'user-list', UserPackingListViewSet, basename='user-packing-list')

urlpatterns = router.urls
