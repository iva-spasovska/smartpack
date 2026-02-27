from rest_framework import serializers
from .models import Trip
from datetime import date


class TripSerializer(serializers.ModelSerializer):
    duration_days = serializers.ReadOnlyField()

    class Meta:
        model = Trip
        fields = '__all__'
        read_only_fields = ('user', 'created_at')

    def validate(self, attrs):
        start_date = attrs.get("start_date")
        end_date = attrs.get("end_date")

        if start_date and end_date and end_date < start_date:
            raise serializers.ValidationError(
                {"end_date": "End date must be after start date"}
            )

        return attrs

    def create(self, validated_data):
        if not validated_data.get('name'):
            start_date = validated_data.get('start_date')
            year = start_date.year if start_date else date.today().year
            validated_data["name"] = f"{validated_data['destination']} {year}"

        return super().create(validated_data)
