"""
Example script demonstrating API usage
"""
import requests
import json


def test_api(base_url="http://localhost:8080"):
    """Test the Clinical Assertion Classification API"""
    
    print("=" * 60)
    print("Clinical Assertion Classification API - Example Usage")
    print("=" * 60)
    print()
    
    # Test cases
    test_sentences = [
        ("The patient denies chest pain.", "ABSENT"),
        ("He has a history of hypertension.", "PRESENT"),
        ("If the patient experiences dizziness, reduce the dosage.", "CONDITIONAL"),
        ("No signs of pneumonia were observed.", "ABSENT"),
    ]
    
    # 1. Health Check
    print("1. Health Check")
    print("-" * 60)
    try:
        response = requests.get(f"{base_url}/health")
        if response.status_code == 200:
            health = response.json()
            print(f"✓ Status: {health['status']}")
            print(f"✓ Model Loaded: {health['model_loaded']}")
            print(f"✓ Model Name: {health['model_name']}")
        else:
            print(f"✗ Health check failed: {response.status_code}")
    except Exception as e:
        print(f"✗ Error: {e}")
    print()
    
    # 2. Single Predictions
    print("2. Single Predictions")
    print("-" * 60)
    for sentence, expected_label in test_sentences:
        try:
            response = requests.post(
                f"{base_url}/predict",
                json={"sentence": sentence}
            )
            if response.status_code == 200:
                result = response.json()
                match = "✓" if result['label'] == expected_label else "✗"
                print(f"{match} Sentence: {sentence}")
                print(f"  Predicted: {result['label']} (score: {result['score']:.4f})")
                print(f"  Expected: {expected_label}")
            else:
                print(f"✗ Prediction failed: {response.status_code}")
        except Exception as e:
            print(f"✗ Error: {e}")
        print()
    
    # 3. Batch Prediction
    print("3. Batch Prediction")
    print("-" * 60)
    try:
        sentences = [s for s, _ in test_sentences]
        response = requests.post(
            f"{base_url}/predict/batch",
            json={"sentences": sentences}
        )
        if response.status_code == 200:
            result = response.json()
            print(f"✓ Processed {len(result['predictions'])} sentences")
            for i, (pred, (sentence, expected)) in enumerate(zip(result['predictions'], test_sentences)):
                match = "✓" if pred['label'] == expected else "✗"
                print(f"{match} [{i+1}] {pred['label']} (score: {pred['score']:.4f}) - Expected: {expected}")
        else:
            print(f"✗ Batch prediction failed: {response.status_code}")
    except Exception as e:
        print(f"✗ Error: {e}")
    print()
    
    print("=" * 60)
    print("Testing complete!")
    print("=" * 60)


if __name__ == "__main__":
    import sys
    
    # Get base URL from command line or use default
    base_url = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8080"
    
    print(f"Testing API at: {base_url}")
    print()
    
    test_api(base_url)
