import pickle
import torch
from flask import Flask, request, jsonify
from PIL import Image
import torchvision.transforms as transforms
import torchvision.models as models
import os
from torchvision.models import VGG16_Weights

app = Flask(__name__)

def persistent_load(persid):
    if isinstance(persid, tuple) and persid[0] == 'storage':
        _, storage_type, key, location, size = persid
        if storage_type == torch.FloatStorage:
            if location.startswith('cuda'):
                # Map CUDA storage to CPU
                return torch.FloatStorage(size).cpu()
            else:
                return torch.FloatStorage(size)
    raise pickle.UnpicklingError(f"Unsupported persistent id encountered: {persid}")

# Load the model
model_path = 'my_model/data.pkl'
if not os.path.exists(model_path):
    raise FileNotFoundError(f"Model file not found: {model_path}")

with open(model_path, 'rb') as f:
    unpickler = pickle.Unpickler(f)
    unpickler.persistent_load = persistent_load
    model_state_dict = unpickler.load()
    print("Model state dict loaded successfully.")  # Debugging statement


nan_found = False
for key, value in model_state_dict.items():
    if torch.isnan(value).any():
        print(f"NaN found in state dictionary for key {key}! Reinitializing the entire model.")
        nan_found = True
        break

# Initialize the VGG-16 model (without pretrained weights, because you're loading custom weights)
model = models.vgg16(weights=VGG16_Weights.IMAGENET1K_V1)

# Define the custom classifier (same as the one used when saving the model)
classifier = torch.nn.Sequential(
    torch.nn.Linear(512 * 7 * 7, 512),
    torch.nn.ReLU(),
    torch.nn.Dropout(0.5),
    torch.nn.Linear(512, 256),
    torch.nn.ReLU(),
    torch.nn.Dropout(0.5),
    torch.nn.Linear(256, 5)  # 5 output classes
)

# Replace the default classifier with your custom classifier
model.classifier = classifier

def initialize_weights(layer):
    if hasattr(layer, 'weight') and layer.weight is not None:
        torch.nn.init.kaiming_normal_(layer.weight, mode='fan_out', nonlinearity='relu')
    if hasattr(layer, 'bias') and layer.bias is not None:
        torch.nn.init.constant_(layer.bias, 0)

if nan_found:
    # Reinitialize the entire model
    print("Reinitializing the entire model.")
    model.apply(initialize_weights)
else:
    # Load the model state dict
    model.load_state_dict(model_state_dict)
    print("Model loaded with custom classifier.")  

for name, param in model.named_parameters():
    if torch.isnan(param).any():
        print(f"NaN found in model weights for layer {name}! Reinitializing...")
        layer_name = name.split('.')[0]
        layer = getattr(model, layer_name)
        initialize_weights(layer)



# Define the class labels
class_labels = ['wheat', 'rice', 'maize', 'sugarcane', 'jute']

@app.route('/')
def index():
    return "Backend is running"

@app.route('/upload', methods=['POST'])
def upload_image():
    if 'file' not in request.files:
        print("No file part in the request.")  # Debugging statement
        return jsonify({'error': 'No file part'})
    
    file = request.files['file']
    if file.filename == '':
        print("No selected file.")  # Debugging statement
        return jsonify({'error': 'No selected file'})
    
    if file:
        image = Image.open(file.stream)
        print("Image uploaded successfully.")  # Debugging statement
        # Preprocess the image and make prediction
        result = predict(image)
        print(f"Prediction result: {result}")  # Debugging statement
        return jsonify({'success': True, 'result': result})

@app.route('/analyze', methods=['POST'])
def analyze_image():
    if 'file' not in request.files:
        print("No file part in the request.")  # Debugging statement
        return jsonify({'success': False, 'error': 'No file part'})
    
    file = request.files['file']
    if file.filename == '':
        print("No selected file.")  # Debugging statement
        return jsonify({'success': False, 'error': 'No selected file'})
    
    if file:
        image = Image.open(file.stream)
        print("Image uploaded successfully for analysis.")  # Debugging statement
        # Preprocess the image and make prediction
        result = predict(image)
        print(f"Analysis result: {result}")  # Debugging statement
        return jsonify({'success': True, 'result': result})

def preprocess(image):
    # Implement your preprocessing logic here
    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    tensor = transform(image).unsqueeze(0)  # Add batch dimension
    print(f"Preprocessed image tensor: {tensor}")  # Debugging statement
    return tensor

def predict(image):
    # Preprocess the image
    preprocessed_image = preprocess(image)
    preprocessed_image = preprocess(image)
    print(f"Preprocessed image tensor shape: {preprocessed_image.shape}")
    print(f"Preprocessed image tensor values: {preprocessed_image}")
    
    # Check for NaN values in the preprocessed image
    if torch.isnan(preprocessed_image).any():
        print("Warning: Preprocessed image contains NaN values.")
        return "Not able to classify due to invalid input data."
    
    # Make prediction
    model.eval()  # Set the model to evaluation mode
    with torch.no_grad():
        prediction = model(preprocessed_image)
    
    # Check for NaN values in the model output
    if torch.isnan(prediction).any():
        print(f"Raw model output (logits): {prediction}")  # Debugging statement
        print("Warning: Model output contains NaN values.")
        return "Not able to classify due to invalid model output."
    
    # Process the prediction
    result = postprocess(prediction)
    print(f"Prediction for known image: {image}, Result: {result}")
    
    return result

def postprocess(prediction, threshold=0.2):
    # Implement your postprocessing logic here
    probabilities = torch.nn.functional.softmax(prediction, dim=1)
    max_prob, predicted_class = torch.max(probabilities, 1)
    
    print(f"Probabilities: {probabilities}")  # Debugging statement
    print(f"Max probability: {max_prob.item()}, Predicted class: {predicted_class.item()}")
    for i, label in enumerate(class_labels):
        print(f"{label}: {probabilities[0][i].item()}") 
    
    if max_prob.item() < threshold:
        return "Not able to classify"
    else:
        return class_labels[predicted_class.item()]
    
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
