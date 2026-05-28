from django.core.management.base import BaseCommand
from ...models import PackingItem

ITEMS = [
    # Essentials
    {"name": "Passport", "category": "essentials"},
    {"name": "Phone Charger", "category": "electronics"},
    {"name": "Toiletries", "category": "essentials"},
    {"name": "First Aid Kit", "category": "essentials"},
    {"name": "Sunscreen", "category": "essentials"},

    # Clothing
    {"name": "T-Shirts", "category": "clothing"},
    {"name": "Jeans", "category": "clothing"},
    {"name": "Underwear", "category": "clothing"},
    {"name": "Socks", "category": "clothing"},
    {"name": "Sweater", "category": "clothing"},
    {"name": "Shorts", "category": "clothing"},
    {"name": "Dress Shirt", "category": "clothing"},
    {"name": "Suit", "category": "clothing"},
    {"name": "Dress Pants", "category": "clothing"},
    {"name": "Blazer", "category": "clothing"},

    # Shoes
    {"name": "Comfortable Shoes", "category": "shoes"},
    {"name": "Sandals", "category": "shoes"},
    {"name": "Hiking Boots", "category": "shoes"},
    {"name": "Dress Shoes", "category": "shoes"},

    # Beachwear
    {"name": "Swimsuit", "category": "beachwear"},
    {"name": "Beach Towel", "category": "beachwear"},

    # Outerwear
    {"name": "Jacket", "category": "outerwear"},
    {"name": "Raincoat", "category": "outerwear"},
    {"name": "Winter Coat", "category": "outerwear"},

    # Electronics
    {"name": "Laptop", "category": "electronics"},
    {"name": "Camera", "category": "electronics"},

    # Accessories
    {"name": "Umbrella", "category": "accessories"},
    {"name": "Sunglasses", "category": "accessories"},
    {"name": "Hat", "category": "accessories"},
    {"name": "Backpack", "category": "accessories"},
    {"name": "Water Bottle", "category": "accessories"},
]

class Command(BaseCommand):
    help = 'Seed the PackingItem catalog'

    def handle(self, *args, **kwargs):
        created = 0
        for item in ITEMS:
            _, was_created = PackingItem.objects.get_or_create(
                name=item['name'],
                defaults={'category': item['category']}
            )
            if was_created:
                created += 1

        self.stdout.write(self.style.SUCCESS(f'Done! {created} items created.'))