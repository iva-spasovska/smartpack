from django.db import models

# Create your models here.
class PackingRecommendation(models.Model):
    trip = models.ForeignKey(
        "trips.Trip",
        on_delete=models.CASCADE,
        related_name="ml_recommendations"
    )

    recommended_items = models.JSONField()
    confidence_score = models.FloatField()

    model_version = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"ML Recommendation for {self.trip}"
