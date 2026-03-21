from rest_framework import serializers
from .models import PackingItem, TripPackingItem, UserPackingList
from ..trips.models import Trip


class PackingItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = PackingItem
        fields = "__all__"


class TripPackingItemSerializer(serializers.ModelSerializer):
    item = PackingItemSerializer(read_only=True)
    item_id = serializers.PrimaryKeyRelatedField(
        queryset=PackingItem.objects.all(),
        source="item",
        write_only=True
    )

    class Meta:
        model = TripPackingItem
        fields = "__all__"

    def validate(self, attrs):
        trip = attrs.get("trip") or getattr(self.instance, "trip", None)
        item = attrs.get("item") or getattr(self.instance, "item", None)

        if trip and item:
            exists = TripPackingItem.objects.filter(
                trip=trip,
                item=item
            )

            if self.instance:
                exists = exists.exclude(pk=self.instance.pk)

            if exists.exists():
                raise serializers.ValidationError(
                    {"item": "This item already exists for the trip."}
                )

        return attrs


class UserPackingListSerializer(serializers.ModelSerializer):
    trip_id = serializers.IntegerField(write_only=True)
    trip_name = serializers.CharField(source='trip.name', read_only=True)
    destination = serializers.CharField(source='trip.destination', read_only=True)

    class Meta:
        model = UserPackingList
        fields = ['id', 'trip_id', 'trip_name', 'destination', 'items', 'created_at', 'updated_at']
        read_only_fields = ['created_at', 'updated_at']

    def validate_trip_id(self, value):
        user = self.context['request'].user

        try:
            trip = Trip.objects.get(id=value, user=user)
        except Trip.DoesNotExist:
            raise serializers.ValidationError("Trip not found or does not belong to you")

        return value

    def validate_items(self, value):
        if not isinstance(value, list):
            raise serializers.ValidationError("Items must be a list")

        for item in value:
            required_fields = ['id', 'name', 'quantity', 'is_checked']
            for field in required_fields:
                if field not in item:
                    raise serializers.ValidationError(f"Each item must have '{field}' field")

        return value

    def create(self, validated_data):
        trip_id = validated_data.pop('trip_id')
        trip = Trip.objects.get(id=trip_id)

        # Create or update
        user_list, created = UserPackingList.objects.update_or_create(
            trip=trip,
            defaults={'items': validated_data['items']}
        )

        return user_list