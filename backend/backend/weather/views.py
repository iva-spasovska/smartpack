from rest_framework.viewsets import ReadOnlyModelViewSet
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.utils import timezone
from datetime import timedelta
from .models import WeatherSnapshot
from .serializers import WeatherSnapshotSerializer
from .services import WeatherService
from ..trips.models import Trip

# Create your views here.
class WeatherSnapshotViewSet(ReadOnlyModelViewSet):
    serializer_class = WeatherSnapshotSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return WeatherSnapshot.objects.filter(
            trip__user=self.request.user
        )

    def retrieve(self, request, pk=None):
        weather = self.get_queryset().filter(trip_id=pk).first()
        if not weather or weather.fetched_at < timezone.now() - timedelta(hours=3):
            trip = Trip.objects.get(id=pk, user=request.user)
            weather = WeatherService.fetch_weather(trip)
        serializer = WeatherSnapshotSerializer(weather)
        return Response(serializer.data)
