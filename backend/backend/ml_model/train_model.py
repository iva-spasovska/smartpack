import json
import numpy as np
import pandas as pd
from sklearn.preprocessing import MultiLabelBinarizer, LabelEncoder
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import hamming_loss, accuracy_score
import joblib
from datetime import datetime


def load_training_data(filepath='backend/ml_model/training_data.json'):
    """Load training data from JSON file"""
    with open(filepath, 'r') as f:
        data = json.load(f)
    return data


def preprocess_data(data):
    """Convert raw data into feature matrix and target labels"""

    # Extract features manually
    trip_types = [sample['trip_type'] for sample in data]
    luggage_types = [sample['luggage_type'] for sample in data]
    genders = [sample['gender'] for sample in data]
    durations = [sample['duration'] for sample in data]
    temperatures = [sample['temperature'] for sample in data]
    weather_conditions = [sample['weather_condition'] for sample in data]
    humidities = [sample['humidity'] for sample in data]
    wind_speeds = [sample['wind_speed'] for sample in data]
    items_lists = [sample['items'] for sample in data]

    # Encode categorical variables
    trip_type_encoder = LabelEncoder()
    luggage_type_encoder = LabelEncoder()
    gender_encoder = LabelEncoder()
    weather_encoder = LabelEncoder()

    trip_type_encoded = trip_type_encoder.fit_transform(trip_types)
    luggage_type_encoded = luggage_type_encoder.fit_transform(luggage_types)
    gender_encoded = gender_encoder.fit_transform(genders)  # ✅ Add this
    weather_encoded = weather_encoder.fit_transform(weather_conditions)

    # Build feature matrix (X) - now with gender
    X = np.column_stack([
        trip_type_encoded,
        luggage_type_encoded,
        gender_encoded,
        durations,
        temperatures,
        weather_encoded,
        humidities,
        wind_speeds
    ])

    # Target labels (y) - multi-label
    mlb = MultiLabelBinarizer()
    y = mlb.fit_transform(items_lists)

    return X, y, mlb, trip_type_encoder, luggage_type_encoder, gender_encoder, weather_encoder


def train_model(X, y):
    """Train Random Forest classifier"""

    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    print(f"Training samples: {len(X_train)}")
    print(f"Test samples: {len(X_test)}")

    # Train model (one classifier per item label)
    # Using RandomForest with MultiOutput wrapper
    from sklearn.multioutput import MultiOutputClassifier

    base_classifier = RandomForestClassifier(
        n_estimators=100,
        max_depth=10,
        random_state=42,
        n_jobs=-1
    )

    model = MultiOutputClassifier(base_classifier)

    print("Training model...")
    model.fit(X_train, y_train)

    # Evaluate
    y_pred = model.predict(X_test)

    # Calculate metrics
    hamming = hamming_loss(y_test, y_pred)
    accuracy = accuracy_score(y_test, y_pred)

    print(f"\nModel Performance:")
    print(f"Hamming Loss: {hamming:.4f}")
    print(f"Exact Match Accuracy: {accuracy:.4f}")

    return model, (X_test, y_test)


def save_model(model, mlb, encoders, version='v1.0'):
    """Save trained model and encoders"""

    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    model_filename = f'backend/ml_model/packing_model_{version}_{timestamp}.joblib'

    # Save everything needed for prediction
    model_data = {
        'model': model,
        'mlb': mlb,
        'trip_type_encoder': encoders[0],
        'luggage_type_encoder': encoders[1],
        'gender_encoder': encoders[2],
        'weather_encoder': encoders[3],
        'version': version,
        'trained_at': timestamp
    }

    joblib.dump(model_data, model_filename)
    joblib.dump(model_data, 'backend/ml_model/packing_model_latest.joblib')

    print(f"\nModel saved to: {model_filename}")
    print(f"Also saved as: backend/ml_model/packing_model_latest.joblib")

    return model_filename


def main():
    """Main training pipeline"""

    print("=" * 50)
    print("SmartPack ML Model Training")
    print("=" * 50)

    # Load data
    print("\n1. Loading training data...")
    data = load_training_data()
    print(f"Loaded {len(data)} samples")

    # Preprocess
    print("\n2. Preprocessing data...")
    X, y, mlb, trip_encoder, luggage_encoder, gender_encoder, weather_encoder = preprocess_data(data)
    print(f"Feature matrix shape: {X.shape}")
    print(f"Target matrix shape: {y.shape}")
    print(f"Number of unique items: {len(mlb.classes_)}")

    # Train
    print("\n3. Training model...")
    model, test_data = train_model(X, y)

    # Save
    print("\n4. Saving model...")
    encoders = (trip_encoder, luggage_encoder, gender_encoder, weather_encoder)
    model_path = save_model(model, mlb, encoders)

    print("\n" + "=" * 50)
    print("Training complete!")
    print("=" * 50)

    return model, mlb, encoders


if __name__ == '__main__':
    main()