from django.db import models

# Create your models here.
class PackingItem(models.Model):
    name = models.CharField(max_length=100)
    category = models.CharField(max_length=50)

    def __str__(self):
        return self.name


class TripPackingItem(models.Model):
    trip = models.ForeignKey(
        "trips.Trip",
        on_delete=models.CASCADE,
        related_name="packing_items"
    )
    item = models.ForeignKey(PackingItem, on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField(default=1)
    is_checked = models.BooleanField(default=False)

    class Meta:
        unique_together = ('trip', 'item')
