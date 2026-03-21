from rest_framework import serializers
from .models import PackingRecommendation

class PackingRecommendationSerializer(serializers.ModelSerializer):
    recommended_items = serializers.SerializerMethodField()

    class Meta:
        model = PackingRecommendation
        fields = "__all__"
        read_only_fields = ("confidence_score", "model_version", "created_at")

    def get_recommended_items(self, obj):
        """
        Transform flat item list into structured data with quantities
        for frontend checkbox UI with counters
        """
        trip = obj.trip
        duration = trip.duration_days

        # Define item metadata
        item_metadata = self._get_item_metadata(duration)

        # Build structured response
        structured_items = []

        for item_id in obj.recommended_items:
            # Get metadata or create default
            metadata = item_metadata.get(item_id, {
                'name': item_id.replace('_', ' ').title(),
                'category': 'other',
                'quantity': 1,
                'is_required': False
            })

            structured_items.append({
                'id': item_id,
                'name': metadata['name'],
                'category': metadata['category'],
                'quantity': metadata['quantity'],
                'is_checked': True,  # All ML-recommended items start checked
                'is_required': metadata['is_required']
            })

        # Sort by category and name for consistent ordering
        structured_items.sort(key=lambda x: (x['category'], x['name']))

        return structured_items

    def _get_item_metadata(self, duration):
        """
        Define metadata for all possible packing items
        Returns dict with item_id as key
        """
        return {
            # ==================== ESSENTIALS ====================
            'passport': {
                'name': 'Passport',
                'category': 'essentials',
                'quantity': 1,
                'is_required': True
            },
            'phone_charger': {
                'name': 'Phone Charger',
                'category': 'electronics',
                'quantity': 1,
                'is_required': True
            },
            'toiletries': {
                'name': 'Toiletries',
                'category': 'essentials',
                'quantity': 1,
                'is_required': True
            },

            # ==================== CLOTHING BASICS ====================
            'underwear': {
                'name': 'Underwear',
                'category': 'clothing',
                'quantity': duration * 2,
                'is_required': True
            },
            'socks': {
                'name': 'Socks',
                'category': 'clothing',
                'quantity': duration + 1,
                'is_required': True
            },

            # ==================== BUSINESS ATTIRE ====================
            'blazer': {
                'name': 'Blazer',
                'category': 'clothing',
                'quantity': 1,
                'is_required': False
            },
            'blouse': {
                'name': 'Blouse',
                'category': 'clothing',
                'quantity': min(3, max(2, duration // 2)),  # 2-3 blouses
                'is_required': False
            },
            'dress_pants': {
                'name': 'Dress Pants',
                'category': 'clothing',
                'quantity': 2,
                'is_required': False
            },
            'pencil_skirt': {
                'name': 'Pencil Skirt',
                'category': 'clothing',
                'quantity': 1,
                'is_required': False
            },
            'dress': {
                'name': 'Dress',
                'category': 'clothing',
                'quantity': 1,
                'is_required': False
            },
            'button_up_shirt': {
                'name': 'Button-Up Shirt',
                'category': 'clothing',
                'quantity': min(1, duration),
                'is_required': False
            },
            'casual_blouse': {
                'name': 'Casual Blouse',
                'category': 'clothing',
                'quantity': min(1, duration),
                'is_required': False
            },
            'tank_top': {
                'name': 'Tank Top',
                'category': 'clothing',
                'quantity': 2,
                'is_required': False
            },
            'heels': {
                'name': 'Heels',
                'category': 'shoes',
                'quantity': 1,
                'is_required': False
            },
            'formal_dress': {
                'name': 'Formal Dress',
                'category': 'clothing',
                'quantity': 1,
                'is_required': False
            },
            'suit': {
                'name': 'Suit',
                'category': 'clothing',
                'quantity': 1,
                'is_required': False
            },
            'tie': {
                'name': 'Tie',
                'category': 'accessories',
                'quantity': 2,
                'is_required': False
            },
            'dress_shirt': {
                'name': 'Dress Shirt',
                'category': 'clothing',
                'quantity': min(4, duration),
                'is_required': False
            },
            'dress_shoes': {
                'name': 'Dress Shoes',
                'category': 'shoes',
                'quantity': 1,
                'is_required': False
            },
            'belt': {
                'name': 'Belt',
                'category': 'accessories',
                'quantity': 1,
                'is_required': False
            },

            # ==================== CASUAL CLOTHING ====================
            'jeans': {
                'name': 'Jeans',
                'category': 'clothing',
                'quantity': 2,
                'is_required': False
            },
            'casual_shirt': {
                'name': 'Casual Shirt',
                'category': 'clothing',
                'quantity': min(3, duration),
                'is_required': False
            },
            'casual_top': {
                'name': 'Casual Top',
                'category': 'clothing',
                'quantity': min(3, duration),
                'is_required': False
            },
            't-shirts': {
                'name': 'T-Shirts',
                'category': 'clothing',
                'quantity': min(4, duration),
                'is_required': False
            },
            'shorts': {
                'name': 'Shorts',
                'category': 'clothing',
                'quantity': 2,
                'is_required': False
            },
            'skirt': {
                'name': 'Skirt',
                'category': 'clothing',
                'quantity': 1,
                'is_required': False
            },

            # ==================== BEACHWEAR ====================
            'swimsuit': {
                'name': 'Swimsuit',
                'category': 'beachwear',
                'quantity': 1,
                'is_required': False
            },
            'bikini': {
                'name': 'Bikini',
                'category': 'beachwear',
                'quantity': 2,
                'is_required': False
            },
            'one_piece_swimsuit': {
                'name': 'One Piece Swimsuit',
                'category': 'beachwear',
                'quantity': 1,
                'is_required': False
            },
            'swim_trunks': {
                'name': 'Swim Trunks',
                'category': 'beachwear',
                'quantity': 2,
                'is_required': False
            },
            'sundress': {
                'name': 'Sundress',
                'category': 'clothing',
                'quantity': 2,
                'is_required': False
            },
            'beach_towel': {
                'name': 'Beach Towel',
                'category': 'beachwear',
                'quantity': 1,
                'is_required': False
            },
            'sandals': {
                'name': 'Sandals',
                'category': 'shoes',
                'quantity': 1,
                'is_required': False
            },
            'sunscreen': {
                'name': 'Sunscreen',
                'category': 'essentials',
                'quantity': 1,
                'is_required': False
            },
            'sunglasses': {
                'name': 'Sunglasses',
                'category': 'accessories',
                'quantity': 1,
                'is_required': False
            },
            'hat': {
                'name': 'Hat',
                'category': 'accessories',
                'quantity': 1,
                'is_required': False
            },
            'sarong': {
                'name': 'Sarong',
                'category': 'beachwear',
                'quantity': 1,
                'is_required': False
            },

            # ==================== OUTERWEAR ====================
            'light_jacket': {
                'name': 'Light Jacket',
                'category': 'outerwear',
                'quantity': 1,
                'is_required': False
            },
            'warm_jacket': {
                'name': 'Warm Jacket',
                'category': 'outerwear',
                'quantity': 1,
                'is_required': False
            },
            'warm_coat': {
                'name': 'Warm Coat',
                'category': 'outerwear',
                'quantity': 1,
                'is_required': False
            },
            'winter_coat': {
                'name': 'Winter Coat',
                'category': 'outerwear',
                'quantity': 1,
                'is_required': False
            },
            'sweater': {
                'name': 'Sweater',
                'category': 'clothing',
                'quantity': 2,
                'is_required': False
            },
            'cardigan': {
                'name': 'Cardigan',
                'category': 'clothing',
                'quantity': 1,
                'is_required': False
            },
            'raincoat': {
                'name': 'Raincoat',
                'category': 'outerwear',
                'quantity': 1,
                'is_required': False
            },

            # ==================== ATHLETIC / OUTDOOR ====================
            'athletic_shorts': {
                'name': 'Athletic Shorts',
                'category': 'athletic',
                'quantity': 2,
                'is_required': False
            },
            'sport_top': {
                'name': 'Sport Top',
                'category': 'athletic',
                'quantity': 2,
                'is_required': False
            },
            'sport_shirt': {
                'name': 'Sport Shirt',
                'category': 'athletic',
                'quantity': 2,
                'is_required': False
            },
            'leggings': {
                'name': 'Leggings',
                'category': 'athletic',
                'quantity': 2,
                'is_required': False
            },
            'hiking_boots': {
                'name': 'Hiking Boots',
                'category': 'shoes',
                'quantity': 1,
                'is_required': False
            },
            'backpack': {
                'name': 'Backpack',
                'category': 'accessories',
                'quantity': 1,
                'is_required': False
            },
            'water_bottle': {
                'name': 'Water Bottle',
                'category': 'accessories',
                'quantity': 1,
                'is_required': False
            },
            'first_aid_kit': {
                'name': 'First Aid Kit',
                'category': 'essentials',
                'quantity': 1,
                'is_required': False
            },
            'flashlight': {
                'name': 'Flashlight',
                'category': 'accessories',
                'quantity': 1,
                'is_required': False
            },

            # ==================== ELECTRONICS ====================
            'laptop': {
                'name': 'Laptop',
                'category': 'electronics',
                'quantity': 1,
                'is_required': False
            },

            # ==================== BUSINESS ITEMS ====================
            'business_cards': {
                'name': 'Business Cards',
                'category': 'business',
                'quantity': 20,
                'is_required': False
            },
            'notebook': {
                'name': 'Notebook',
                'category': 'business',
                'quantity': 1,
                'is_required': False
            },
            'pen': {
                'name': 'Pen',
                'category': 'business',
                'quantity': 2,
                'is_required': False
            },

            # ==================== ACCESSORIES ====================
            'umbrella': {
                'name': 'Umbrella',
                'category': 'accessories',
                'quantity': 1,
                'is_required': False
            },
            'comfortable_shoes': {
                'name': 'Comfortable Shoes',
                'category': 'shoes',
                'quantity': 1,
                'is_required': False
            },
            'camera': {
                'name': 'Camera',
                'category': 'electronics',
                'quantity': 1,
                'is_required': False
            },
            'day_backpack': {
                'name': 'Day Backpack',
                'category': 'accessories',
                'quantity': 1,
                'is_required': False
            },
            'guidebook': {
                'name': 'Guidebook',
                'category': 'accessories',
                'quantity': 1,
                'is_required': False
            },

            # ==================== WEATHER ITEMS ====================
            'gloves': {
                'name': 'Gloves',
                'category': 'accessories',
                'quantity': 1,
                'is_required': False
            },
            'scarf': {
                'name': 'Scarf',
                'category': 'accessories',
                'quantity': 1,
                'is_required': False
            },
            'warm_boots': {
                'name': 'Warm Boots',
                'category': 'shoes',
                'quantity': 1,
                'is_required': False
            },
            'thermal_underwear': {
                'name': 'Thermal Underwear',
                'category': 'clothing',
                'quantity': duration,
                'is_required': False
            },
            'waterproof_shoes': {
                'name': 'Waterproof Shoes',
                'category': 'shoes',
                'quantity': 1,
                'is_required': False
            },
            'warm_socks': {
                'name': 'Warm Socks',
                'category': 'clothing',
                'quantity': duration,
                'is_required': False
            },

            # ==================== MISC ====================
            'compact_items_only': {
                'name': 'Pack Compact Items Only',
                'category': 'reminder',
                'quantity': 1,
                'is_required': False
            },
            'light_clothing': {
                'name': 'Light Clothing',
                'category': 'clothing',
                'quantity': duration,
                'is_required': False
            },
            'long_sleeve_shirt': {
                'name': 'Long Sleeve Shirt',
                'category': 'clothing',
                'quantity': 2,
                'is_required': False
            },
            'short_sleeve_shirts': {
                'name': 'Short Sleeve Shirts',
                'category': 'clothing',
                'quantity': min(4, duration),
                'is_required': False
            },
        }