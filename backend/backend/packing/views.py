from rest_framework.viewsets import ReadOnlyModelViewSet, ModelViewSet
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import action
from rest_framework.response import Response
from .services import PackingService
from .models import PackingItem, TripPackingItem
from .serializers import PackingItemSerializer, TripPackingItemSerializer
from ..trips.models import Trip


# Create your views here.
class PackingItemViewSet(ReadOnlyModelViewSet):
    queryset = PackingItem.objects.all()
    serializer_class = PackingItemSerializer
    permission_classes = [IsAuthenticated]


class TripPackingItemViewSet(ModelViewSet):
    serializer_class = TripPackingItemSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return TripPackingItem.objects.filter(
            trip__user=self.request.user
        )

    def perform_create(self, serializer):
        serializer.save()

    @action(detail=False, methods=['post'], url_path='suggest')
    def suggest_items(self, request):
        """Generate packing suggestions for a trip"""
        trip_id = request.data.get('trip_id')
        trip = Trip.objects.get(id=trip_id, user=request.user)

        suggestions = PackingService.suggest_items(trip)

        return Response({
            'trip_id': trip_id,
            'suggestions': suggestions,
            'count': len(suggestions)
        })