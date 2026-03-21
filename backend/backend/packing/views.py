from rest_framework import status
from rest_framework.viewsets import ReadOnlyModelViewSet, ModelViewSet
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import action
from rest_framework.response import Response
from .services import PackingService
from .models import PackingItem, TripPackingItem, UserPackingList
from .serializers import PackingItemSerializer, TripPackingItemSerializer, UserPackingListSerializer
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


class UserPackingListViewSet(ModelViewSet):
    serializer_class = UserPackingListSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return UserPackingList.objects.filter(trip__user=self.request.user)

    def retrieve(self, request, pk=None):
        # pk is trip_id
        try:
            user_list = UserPackingList.objects.get(
                trip_id=pk,
                trip__user=request.user
            )
            serializer = UserPackingListSerializer(user_list)
            return Response(serializer.data)
        except UserPackingList.DoesNotExist:
            return Response(
                {'error': 'Packing list not found for this trip'},
                status=status.HTTP_404_NOT_FOUND
            )

    def create(self, request):
        serializer = UserPackingListSerializer(
            data=request.data,
            context={'request': request}
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response(serializer.data, status=status.HTTP_201_CREATED)

    def update(self, request, pk=None, partial=False):
        try:
            user_list = UserPackingList.objects.get(
                trip_id=pk,
                trip__user=request.user
            )
        except UserPackingList.DoesNotExist:
            return Response(
                {'error': 'Packing list not found'},
                status=status.HTTP_404_NOT_FOUND
            )

        serializer = UserPackingListSerializer(
            user_list,
            data=request.data,
            partial=partial,
            context={'request': request}
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response(serializer.data)