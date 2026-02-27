from rest_framework import serializers
from .models import PackingRecommendation

class PackingRecommendationSerializer(serializers.ModelSerializer):
    class Meta:
        model = PackingRecommendation
        fields = "__all__"
        read_only_fields = ("confidence_score", "model_version", "created_at")
