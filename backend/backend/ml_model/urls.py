from rest_framework.routers import DefaultRouter
from .views import PackingRecommendationViewSet

router = DefaultRouter()
router.register(r'', PackingRecommendationViewSet, basename='recommendation')

urlpatterns = router.urls
