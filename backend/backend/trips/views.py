from rest_framework.viewsets import ModelViewSet
from rest_framework.permissions import IsAuthenticated
from rest_framework.serializers import ValidationError
from .models import Trip
from .serializers import TripSerializer
from datetime import timezone

# Create your views here.
class TripViewSet(ModelViewSet):
    serializer_class = TripSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Trip.objects.select_related("user").filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    def perform_update(self, serializer):
        if serializer.instance.end_date and serializer.instance.end_date < timezone.now().date():
            raise ValidationError("Past trips cannot be modified")
        serializer.save()
