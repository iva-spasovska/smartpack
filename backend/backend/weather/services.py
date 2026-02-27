import requests
from django.conf import settings

from .models import WeatherSnapshot

API_KEY = settings.OPENWEATHERMAP_API_KEY
BASE_URL = "https://api.openweathermap.org/data/2.5/weather"

class WeatherService:
    @staticmethod
    def fetch_weather(trip):
        params = {
            "q": trip.destination,
            "appid": API_KEY,
            "units": "metric"
        }

        try:
            response = requests.get(BASE_URL, params=params, timeout=10)
            response.raise_for_status()
        except requests.RequestException as e:
            raise Exception(f"Weather API error: {str(e)}")

        data = response.json()

        weather, _ = WeatherSnapshot.objects.update_or_create(
            trip=trip,
            defaults={
                "temperature": data["main"]["temp"],
                "humidity": data["main"]["humidity"],
                "wind_speed": data["wind"]["speed"],
                "condition": data["weather"][0]["main"].lower(),
                "api_source": "openweathermap",
            }
        )
        return weather