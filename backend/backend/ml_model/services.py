import joblib
import numpy as np
from .models import PackingRecommendation
from ..packing.services import PackingService

class MLService:
    _model_data = None

    @classmethod
    def load_model(cls):
        """Load the trained model (singleton pattern)"""
        if cls._model_data is None:
            try:
                cls._model_data = joblib.load('backend/ml_model/packing_model_latest.joblib')
                print(f"ML Model loaded: {cls._model_data['version']}")
            except FileNotFoundError:
                print("Warning: ML model not found. Train the model first!")
                return None
        return cls._model_data

    @staticmethod
    def prepare_features(trip):
        """Convert trip data into feature vector for model"""
        model_data = MLService.load_model()
        if model_data is None:
            return None

        # Encode trip features
        trip_type_encoded = model_data['trip_type_encoder'].transform([trip.trip_type])[0]
        luggage_type_encoded = model_data['luggage_type_encoder'].transform([trip.luggage_type])[0]

        # Get user gender
        user_gender = trip.user.gender if trip.user.gender else 'other'
        gender_encoded = model_data['gender_encoder'].transform([user_gender])[0]

        # Get weather data
        try:
            weather = trip.weather
            temperature = weather.temperature
            weather_encoded = model_data['weather_encoder'].transform([weather.condition])[0]
            humidity = weather.humidity
            wind_speed = weather.wind_speed
        except:
            # No weather data, use defaults
            temperature = 15.0
            weather_encoded = 0
            humidity = 50
            wind_speed = 5.0

        # Create feature vector
        features = np.array([[
            trip_type_encoded,
            luggage_type_encoded,
            gender_encoded,
            trip.duration_days,
            temperature,
            weather_encoded,
            humidity,
            wind_speed
        ]])

        return features

    @staticmethod
    def generate_recommendation(trip):
        """Generate ML-based packing recommendations"""
        model_data = MLService.load_model()

        if model_data is None:
            # Fallback to rule-based if model not available
            return MLService._fallback_recommendation(trip)

        # Prepare features
        features = MLService.prepare_features(trip)
        if features is None:
            return MLService._fallback_recommendation(trip)

        # Make prediction
        model = model_data['model']
        mlb = model_data['mlb']

        # Get probabilities
        predictions = model.predict(features)[0]

        # Convert binary predictions back to item names
        recommended_items = [
            item for item, pred in zip(mlb.classes_, predictions) if pred == 1
        ]

        # Calculate confidence score (average probability)
        confidence_score = float(np.mean(predictions))

        # Save recommendation
        rec, _ = PackingRecommendation.objects.update_or_create(
            trip=trip,
            defaults={
                "recommended_items": recommended_items,
                "confidence_score": confidence_score,
                "model_version": model_data['version']
            }
        )

        return rec

    @staticmethod
    def _fallback_recommendation(trip):
        """Fallback to rule-based recommendations if ML model unavailable"""
        suggestions = PackingService.suggest_items(trip)

        rec, _ = PackingRecommendation.objects.update_or_create(
            trip=trip,
            defaults={
                "recommended_items": suggestions,
                "confidence_score": 0.85,  # Fixed confidence for rules
                "model_version": "rule_based_fallback"
            }
        )

        return rec