from .models import PackingRecommendation

class MLService:
    @staticmethod
    def generate_recommendation(trip):
        # Example pseudo-logic
        recommended_items = ["T-shirt", "Shorts"]  # Call your ML model here
        confidence_score = 0.95
        model_version = "v1.0"

        rec, _ = PackingRecommendation.objects.update_or_create(
            trip=trip,
            defaults={
                "recommended_items": recommended_items,
                "confidence_score": confidence_score,
                "model_version": model_version
            }
        )
        return rec
