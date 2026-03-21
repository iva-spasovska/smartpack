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


class UserPackingList(models.Model):
    trip = models.OneToOneField(
        'trips.Trip',
        on_delete=models.CASCADE,
        related_name='user_packing_list'
    )
    items = models.JSONField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Packing list for {self.trip}"

    class Meta:
        verbose_name = "User Packing List"
        verbose_name_plural = "User Packing Lists"