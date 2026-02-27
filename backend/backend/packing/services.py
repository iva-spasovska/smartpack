class PackingService:
    @staticmethod
    def suggest_items(trip):
        """Rule-based packing suggestions"""
        suggestions = []

        # Base items for all trips
        base_items = ['passport', 'phone_charger', 'toiletries']
        suggestions.extend(base_items)

        # Trip type specific
        if trip.trip_type == 'beach':
            suggestions.extend(['swimsuit', 'sunscreen', 'sandals'])
        elif trip.trip_type == 'mountain':
            suggestions.extend(['hiking_boots', 'jacket', 'backpack'])
        elif trip.trip_type == 'business':
            suggestions.extend(['laptop', 'formal_shoes', 'suit'])
        elif trip.trip_type == 'city':
            suggestions.extend(['comfortable_shoes', 'camera', 'umbrella'])

        # Weather-based (if weather exists)
        if hasattr(trip, 'weather'):
            weather = trip.weather
            if weather.is_rainy:
                suggestions.extend(['raincoat', 'umbrella'])
            if weather.is_snowy:
                suggestions.extend(['winter_coat', 'gloves', 'warm_boots'])
            if weather.is_sunny:
                suggestions.extend(['sunglasses', 'hat', 'sunscreen'])
            if weather.temperature < 10:
                suggestions.extend(['sweater', 'jacket'])
            elif weather.temperature > 25:
                suggestions.extend(['shorts', 't-shirts', 'light_clothing'])

        # Duration-based
        days = trip.duration_days
        suggestions.append(f"{days * 2}_underwear")  # 2x underwear per day
        suggestions.append(f"{days + 1}_socks")

        # Luggage type
        if trip.luggage_type == 'backpack':
            suggestions.append('compact_items_only')

        return list(set(suggestions))  # Remove duplicates