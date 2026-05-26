from rest_framework import serializers
from .models import UserProfile
from datetime import date


class UserProfileSerializer(serializers.ModelSerializer):
    age = serializers.ReadOnlyField()
    email = serializers.EmailField(read_only=True)
    password = serializers.CharField(write_only=True, required=False)
    profile_photo_url = serializers.SerializerMethodField()

    class Meta:
        model = UserProfile
        fields = [
            "id",
            "username",
            "email",
            "password",
            "date_of_birth",
            "gender",
            "profile_photo",
            "profile_photo_url",
            "preferences",
            "age",
        ]
        read_only_fields = ["profile_photo_url"]
        extra_kwargs = {
            'password': {'write_only': True},
            'profile_photo': {'write_only': True, 'required': False},
        }

    def validate_date_of_birth(self, value):
        if value and value > date.today():
            raise serializers.ValidationError("Date of birth cannot be in the future")
        return value

    def get_profile_photo_url(self, obj):
        if not obj.profile_photo:
            return None

        request = self.context.get("request")
        url = obj.profile_photo.url
        if request is None:
            return url

        return request.build_absolute_uri(url)
