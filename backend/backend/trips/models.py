from django.core.exceptions import ValidationError
from django.db import models
from django.conf import settings

# Create your models here.
User = settings.AUTH_USER_MODEL

class Trip(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='trips')
    name = models.CharField(max_length=200, null=True, blank=True)
    destination = models.CharField(max_length=200)
    start_date = models.DateField()
    end_date = models.DateField()

    TRIP_CHOICES = (
        ('city', 'City'),
        ('beach', 'Beach'),
        ('mountain', 'Mountain'),
        ('business', 'Business'),
    )
    trip_type = models.CharField(
        max_length=10,
        choices=TRIP_CHOICES,
    )

    LUGGAGE_CHOICES = (
        ('backpack', 'Backpack'),
        ('small_suitcase', 'Small suitcase (≤ 10kg)'),
        ('large_suitcase', 'Large suitcase (> 10kg)'),
    )

    luggage_type = models.CharField(
        max_length=20,
        choices=LUGGAGE_CHOICES
    )

    created_at = models.DateTimeField(auto_now_add=True)

    def clean(self):
        if self.end_date < self.start_date:
            raise ValidationError("End date must be after start date")

    @property
    def duration_days(self):
        return (self.end_date - self.start_date).days + 1

    def __str__(self):
        return f"{self.name} ({self.destination})"