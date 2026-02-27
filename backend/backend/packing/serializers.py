from rest_framework import serializers
from .models import PackingItem, TripPackingItem

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