from django.contrib.auth.models import AbstractUser
from django.db import models
from datetime import date

class UserProfile(AbstractUser):
    # inherits username, email, password, etc.
    date_of_birth = models.DateField(null=True, blank=True)
    GENDER_CHOICES = (
        ('male', 'Male'),
        ('female', 'Female'),
        ('other', 'Other'),
    )
    gender = models.CharField(
        max_length=10,
        choices=GENDER_CHOICES,
        null=True,
        blank=True
    )

    @property
    def age(self):
        if not self.date_of_birth:
            return None

        today = date.today()
        return (
                today.year
                - self.date_of_birth.year
                - (
                        (today.month, today.day)
                        < (self.date_of_birth.month, self.date_of_birth.day)
                )
        )

    preferences = models.JSONField(default=dict, blank=True)
    def __str__(self):
        return self.username
