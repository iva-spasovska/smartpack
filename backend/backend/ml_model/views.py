from rest_framework.response import Response
from rest_framework.viewsets import ReadOnlyModelViewSet
from rest_framework.permissions import IsAuthenticated
from .models import PackingRecommendation
from .serializers import PackingRecommendationSerializer
from .services import MLService
from ..trips.models import Trip

# Create your views here.
class PackingRecommendationViewSet(ReadOnlyModelViewSet):
    serializer_class = PackingRecommendationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return PackingRecommendation.objects.filter(
            trip__user=self.request.user
        )

    def retrieve(self, request, pk=None):
        try:
            trip = Trip.objects.get(id=pk, user=request.user)
        except Trip.DoesNotExist:
            return Response(
                {'error': 'Trip not found'},
                status=404
            )
        rec = MLService.generate_recommendation(trip)
        serializer = PackingRecommendationSerializer(rec)
        return Response(serializer.data)
