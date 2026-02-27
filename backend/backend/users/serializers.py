from rest_framework import serializers
from .models import UserProfile
from datetime import date


class UserProfileSerializer(serializers.ModelSerializer):
    age = serializers.ReadOnlyField()
    email = serializers.EmailField(read_only=True)
    password = serializers.CharField(write_only=True, required=False)

    class Meta:
        model = UserProfile
        fields = [
            "id",
            "username",
            "email",
            "password",
            "date_of_birth",
            "gender",
            "preferences",
            "age",
        ]
        extra_kwargs = {
            'password': {'write_only': True}
        }

    def validate_date_of_birth(self, value):
        if value and value > date.today():
            raise serializers.ValidationError("Date of birth cannot be in the future")
        return value