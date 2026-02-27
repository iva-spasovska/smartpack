from rest_framework import serializers
from .models import WeatherSnapshot

class WeatherSnapshotSerializer(serializers.ModelSerializer):
    is_rainy = serializers.ReadOnlyField()
    is_sunny = serializers.ReadOnlyField()
    is_snowy = serializers.ReadOnlyField()
    is_windy = serializers.ReadOnlyField()

    class Meta:
        model = WeatherSnapshot
        fields = "__all__"
        read_only_fields = ("trip", "api_source", "fetched_at")
