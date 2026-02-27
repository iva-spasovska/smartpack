from django.db import models

# Create your models here.
class WeatherSnapshot(models.Model):
    trip = models.OneToOneField(
        'trips.Trip',
        on_delete=models.CASCADE,
        related_name='weather',
    )

    temperature = models.FloatField(help_text="Temperature in Celsius")
    condition = models.CharField(max_length=50)
    humidity = models.PositiveIntegerField()
    wind_speed = models.FloatField(help_text="Wind speed in m/s")

    api_source = models.CharField(max_length=50, default='openweathermap')
    fetched_at = models.DateTimeField(auto_now_add=True)

    @property
    def is_rainy(self):
        return self.condition.lower() in ["rain", "drizzle", "thunderstorm"]

    @property
    def is_snowy(self):
        return self.condition.lower() == "snow"

    @property
    def is_sunny(self):
        return self.condition.lower() == "clear"

    @property
    def is_windy(self):
        return self.wind_speed > 10

    def __str__(self):
        return f"Weather for {self.trip.name}"
