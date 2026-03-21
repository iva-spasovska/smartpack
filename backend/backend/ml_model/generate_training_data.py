import json
import random
from datetime import date, timedelta

def generate_training_data(num_samples=1000):
    """Generate synthetic training data for packing recommendations"""

    trip_types = ['city', 'beach', 'mountain', 'business']
    luggage_types = ['backpack', 'small_suitcase', 'large_suitcase']
    weather_conditions = ['clear', 'clouds', 'rain', 'snow']
    genders = ['male', 'female', 'other']

    # Base items everyone needs
    base_items = ['passport', 'phone_charger', 'toiletries']

    # Trip type specific items (gender-neutral)
    trip_items = {
        'city': ['comfortable_shoes', 'camera', 'umbrella', 'day_backpack', 'guidebook'],
        'beach': ['sunscreen', 'sandals', 'beach_towel', 'sunglasses', 'hat'],
        'mountain': ['hiking_boots', 'backpack', 'water_bottle', 'first_aid_kit', 'flashlight'],
        'business': ['laptop'],
    }

    # Gender-specific clothing by trip type
    gender_clothing = {
        'male': {
            'business': ['suit', 'tie', 'dress_shirt', 'belt', 'dress_shoes'],
            'formal': ['dress_pants', 'blazer'],
            'casual': ['jeans', 't-shirts', 'button_up_shirt'],
            'beach': ['swim_trunks'],
            'athletic': ['athletic_shorts', 'tank_top'],
        },
        'female': {
            'business': ['blazer', 'blouse', 'dress_pants', 'pencil_skirt', 'heels'],
            'formal': ['formal_dress'],
            'casual': ['jeans', 't-shirts', 'casual_blouse', 'skirt'],
            'beach': ['bikini', 'one_piece_swimsuit', 'sundress'],
            'athletic': ['athletic_shorts', 'tank_top', 'leggings'],
        },
        'other': {
            'business': ['blazer', 'dress_shirt', 'dress_pants', 'dress_shoes'],
            'formal': ['dress_pants', 'blazer'],
            'casual': ['jeans', 't-shirts', 'button_up_shirt'],
            'beach': ['swimsuit'],
            'athletic': ['athletic_shorts', 'tank_top'],
        }
    }

    # Weather-based items (trip-type aware)
    weather_items = {
        'rain': ['raincoat', 'umbrella', 'waterproof_shoes'],
        'snow': ['winter_coat', 'gloves', 'warm_boots', 'scarf'],
        'clear': ['sunglasses'],
        'clouds': [],
    }

    # Temperature-based clothing
    temp_clothing = {
        'cold': ['sweater', 'warm_jacket', 'warm_socks'],
        'mild': ['light_jacket'],
        'warm': ['shorts'],
    }

    data = []

    for _ in range(num_samples):
        # Generate random trip features
        trip_type = random.choice(trip_types)
        luggage_type = random.choice(luggage_types)
        gender = random.choice(genders)
        duration = random.randint(1, 14)

        # Temperature based on trip type and season
        if trip_type == 'beach':
            temperature = random.uniform(22, 35)  # Beach = warm
        elif trip_type == 'mountain':
            temperature = random.uniform(-5, 15)  # Mountain = cool/cold
        elif trip_type == 'business':
            temperature = random.uniform(10, 25)  # Business = varied
        else:  # city
            temperature = random.uniform(5, 30)  # City = varied

        # Weather condition (influenced by trip type)
        if trip_type == 'beach':
            weather_condition = random.choices(
                ['clear', 'clouds', 'rain'],
                weights=[0.7, 0.2, 0.1]  # Beach usually sunny
            )[0]
        elif trip_type == 'mountain':
            weather_condition = random.choices(
                ['clear', 'clouds', 'rain', 'snow'],
                weights=[0.3, 0.3, 0.2, 0.2]  # Mountain varied
            )[0]
        else:
            weather_condition = random.choice(weather_conditions)

        humidity = random.randint(30, 90)
        wind_speed = random.uniform(0, 15)

        # Determine temperature category
        if temperature < 10:
            temp_category = 'cold'
        elif temperature < 20:
            temp_category = 'mild'
        else:
            temp_category = 'warm'

        # Build item list
        items_needed = set(base_items.copy())

        # Add trip-specific items (gender-neutral)
        items_needed.update(trip_items[trip_type])

        # Add gender and trip-specific clothing
        if trip_type == 'business':
            # Business trips: formal only
            items_needed.update(gender_clothing[gender]['business'])
            items_needed.update(gender_clothing[gender]['formal'])

        elif trip_type == 'beach':
            # Beach trips: swimwear + casual
            items_needed.update(gender_clothing[gender]['beach'])
            items_needed.update(gender_clothing[gender]['casual'])

        elif trip_type == 'mountain':
            # Mountain trips: athletic + casual
            items_needed.update(gender_clothing[gender]['athletic'])
            items_needed.update(gender_clothing[gender]['casual'])

        else:  # city
            # City trips: casual + some formal
            items_needed.update(gender_clothing[gender]['casual'])
            # Maybe add one formal outfit for nice dinners
            if random.random() > 0.5:
                items_needed.update(random.sample(gender_clothing[gender]['formal'], 1))

        # Add weather-based items
        weather_additions = weather_items.get(weather_condition, [])

        # For business trips, filter out casual weather items
        if trip_type == 'business':
            # Only add rain/snow gear, no casual items
            business_safe_weather = ['raincoat', 'umbrella', 'winter_coat',
                                     'gloves', 'warm_boots', 'scarf', 'light_jacket']
            weather_additions = [item for item in weather_additions
                                 if item in business_safe_weather]

        items_needed.update(weather_additions)

        # Add temperature-based clothing (skip for business trips)
        if trip_type != 'business':
            temp_additions = temp_clothing[temp_category]
            items_needed.update(temp_additions)
        else:
            # For business, only add coat if very cold
            if temp_category == 'cold':
                items_needed.add('warm_coat')

        # Add duration-based quantities
        # items_needed.add(f'{duration * 2}_underwear')
        # items_needed.add(f'{duration + 1}_socks')
        items_needed.add('underwear')
        items_needed.add('socks')

        # Luggage type considerations
        if luggage_type == 'backpack':
            items_needed.add('compact_items_only')
            # Remove bulky items for backpack
            bulky_items = {'large_suitcase', 'multiple_shoes', 'heavy_coat'}
            items_needed = items_needed - bulky_items

        # Final cleanup: Remove contradictions
        # If business trip, absolutely no beach/casual items
        if trip_type == 'business':
            beach_casual_items = {
                'bikini', 'one_piece_swimsuit', 'swim_trunks', 'sundress',
                'sarong', 'beach_towel', 'sandals', 'shorts', 'athletic_shorts',
                'sport_shirt', 'sport_top', 'leggings', 't-shirts'
            }
            items_needed = items_needed - beach_casual_items

        # If beach trip, no heavy winter items (unless temp is very low)
        if trip_type == 'beach' and temperature > 15:
            winter_items = {'winter_coat', 'thermal_underwear', 'warm_boots',
                            'gloves', 'scarf', 'suit', 'tie', 'heels'}
            items_needed = items_needed - winter_items

        # Add some realistic randomness (people sometimes forget items)
        if random.random() > 0.9:  # 10% chance
            if len(items_needed) > 8:
                items_needed.pop()  # Forget one random item

        # Create sample
        sample = {
            'trip_type': trip_type,
            'luggage_type': luggage_type,
            'gender': gender,
            'duration': duration,
            'temperature': round(temperature, 2),
            'weather_condition': weather_condition,
            'humidity': humidity,
            'wind_speed': round(wind_speed, 2),
            'items': sorted(list(items_needed))  # Sort for consistency
        }

        data.append(sample)

    return data


if __name__ == '__main__':
    import os

    # Generate training data
    print("=" * 60)
    print("SmartPack Training Data Generator")
    print("=" * 60)

    print("\nGenerating training data...")
    training_data = generate_training_data(2000)

    # Ensure directory exists
    os.makedirs('backend/ml_model', exist_ok=True)

    # Save to JSON file
    output_file = 'backend/ml_model/training_data.json'
    with open(output_file, 'w') as f:
        json.dump(training_data, f, indent=2)

    print(f"Generated {len(training_data)} training samples")
    print(f"Saved to: {output_file}")

    # Show statistics
    print("\nDataset Statistics:")

    trip_types = {}
    genders = {}
    for sample in training_data:
        trip_type = sample['trip_type']
        gender = sample['gender']
        trip_types[trip_type] = trip_types.get(trip_type, 0) + 1
        genders[gender] = genders.get(gender, 0) + 1

    print("\nTrip Types:")
    for trip_type, count in sorted(trip_types.items()):
        print(f"  {trip_type}: {count}")

    print("\nGenders:")
    for gender, count in sorted(genders.items()):
        print(f"  {gender}: {count}")

    # Show sample
    print("\nSample Training Example:")
    sample = training_data[0]
    print(f"  Trip Type: {sample['trip_type']}")
    print(f"  Gender: {sample['gender']}")
    print(f"  Duration: {sample['duration']} days")
    print(f"  Temperature: {sample['temperature']}°C")
    print(f"  Weather: {sample['weather_condition']}")
    print(f"  Items ({len(sample['items'])}):")
    for item in sample['items'][:10]:  # Show first 10
        print(f"    - {item}")
    if len(sample['items']) > 10:
        print(f"    ... and {len(sample['items']) - 10} more")

    print("\n" + "=" * 60)
    print("Training data generation complete!")
    print("=" * 60)