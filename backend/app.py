from flask import Flask, Response, request, jsonify
from PIL import Image
import torch
import torch.nn as nn
from torchvision import transforms, models
import io
from flask_cors import CORS
import base64
import os
import numpy as np
import cv2

import tensorflow as tf
from tensorflow.keras.models import load_model
from patchify import patchify

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

def tversky_loss(y_true, y_pred, alpha=0.7, beta=0.3):
    smooth = 1e-6
    y_true_flat = tf.keras.backend.flatten(y_true)
    y_pred_flat = tf.keras.backend.flatten(y_pred)
    true_pos = tf.reduce_sum(y_true_flat * y_pred_flat)
    false_neg = tf.reduce_sum(y_true_flat * (1 - y_pred_flat))
    false_pos = tf.reduce_sum((1 - y_true_flat) * y_pred_flat)
    tversky = (true_pos + smooth) / (true_pos + alpha * false_neg + beta * false_pos + smooth)
    return 1 - tversky

def dice_coef(y_true, y_pred):
    smooth = 1e-15
    y_true = tf.keras.layers.Flatten()(y_true)
    y_pred = tf.keras.layers.Flatten()(y_pred)
    intersection = tf.reduce_sum(y_true * y_pred)
    return (2. * intersection + smooth) / (tf.reduce_sum(y_true) + tf.reduce_sum(y_pred) + smooth)

def iou(y_true, y_pred):
    smooth = 1e-15
    intersection = tf.reduce_sum(y_true * y_pred)
    sum_ = tf.reduce_sum(y_true + y_pred)
    jac = (intersection + smooth) / (sum_ - intersection + smooth)
    return jac

def sensitivity(y_true, y_pred):
    true_positives = tf.reduce_sum(tf.round(y_true * y_pred))
    possible_positives = tf.reduce_sum(tf.round(y_true))
    return true_positives / (possible_positives + tf.keras.backend.epsilon())

def precision(y_true, y_pred):
    true_positives = tf.reduce_sum(tf.round(y_true * y_pred))
    predicted_positives = tf.reduce_sum(tf.round(y_pred))
    return true_positives / (predicted_positives + tf.keras.backend.epsilon())

def specificity(y_true, y_pred):
    true_negatives = tf.reduce_sum(tf.round((1 - y_true) * (1 - y_pred)))
    possible_negatives = tf.reduce_sum(tf.round(1 - y_true))
    return true_negatives / (possible_negatives + tf.keras.backend.epsilon())

flood_model = load_model("modell.keras", custom_objects={
    'tversky_loss': tversky_loss,
    'dice_coef': dice_coef,
    'iou': iou,
    'sensitivity': sensitivity,
    'precision': precision,
    'specificity': specificity
})

cf = {
    "image_size": 256,
    "patch_size": 16,
    "num_channels": 3,
    "flat_patches_shape": (
        (256**2) // (16**2),
        16 * 16 * 3,
    )
}

def preprocess_image_for_flood_detection(image):
    """Preprocess image for flood detection model."""
    # Convert PIL Image to numpy array
    image = np.array(image)
    
    # Resize image
    image = cv2.resize(image, (cf["image_size"], cf["image_size"]))
    
    # Normalize pixel values
    image = image / 255.0

    # Convert to patches
    patch_shape = (cf["patch_size"], cf["patch_size"], cf["num_channels"])
    patches = patchify(image, patch_shape, cf["patch_size"])
    patches = np.reshape(patches, cf["flat_patches_shape"])
    patches = np.expand_dims(patches, axis=0)  # Add batch dimension
    
    return patches

@app.route('/detect', methods=['POST'])
def detect_flood():
    print("Received a request for flood detection")
    
    try:
        # Check for image in request
        if 'image' in request.files:
            file = request.files['image']
            original_image = Image.open(file).convert('RGB')
            print("Image received from file")
        else:
            return jsonify({'error': 'No image file provided'}), 400
        
        # Resize input image to match model's expected input size
        image = original_image.resize((cf["image_size"], cf["image_size"]))
        
        # Load ground truth image
        ground_truth_path = 'groundimage1.png'  # Adjust the filename as needed
        if os.path.exists(ground_truth_path):
            ground_truth_original = Image.open(ground_truth_path).convert('RGB')
            # Resize ground truth to match input image size
            ground_truth_original = ground_truth_original.resize((cf["image_size"], cf["image_size"]))
            print("Ground truth image loaded")
        else:
            print(f"Ground truth image not found at {ground_truth_path}")
            # Create a blank ground truth image if file doesn't exist
            ground_truth_original = Image.new('RGB', (cf["image_size"], cf["image_size"]))
        
        # Preprocess image
        processed_image = preprocess_image_for_flood_detection(image)
        print("Image preprocessed for flood detection")
        
        # Predict
        prediction = flood_model.predict(processed_image)
        print("Prediction made by the model")
        prediction = np.squeeze(prediction)  # Remove batch dimension
        prediction = (prediction > 0.5).astype(np.uint8)  # Thresholding
        
        # Convert prediction to images
        # Predicted Mask
        predicted_mask_image = (prediction * 255).astype(np.uint8)
        predicted_mask_pil = Image.fromarray(predicted_mask_image, mode='L')  # 'L' mode for grayscale
        
        # Ground Truth 
        ground_truth_array = np.array(ground_truth_original)
        ground_truth_gray = cv2.cvtColor(ground_truth_array, cv2.COLOR_RGB2GRAY)
        _, ground_truth_binary = cv2.threshold(ground_truth_gray, 127, 255, cv2.THRESH_BINARY)
        ground_truth_pil = Image.fromarray(ground_truth_binary, mode='L')
        
        # Result Image (overlay prediction on original image)
        result_image = np.array(original_image).copy()
        result_image = cv2.resize(result_image, (cf["image_size"], cf["image_size"]))
        mask_overlay = np.stack([predicted_mask_image] * 3, axis=-1)  # Ensure mask has 3 channels
        result_image[mask_overlay[:, :, 0] > 0] = [255, 0, 0]  # Red overlay for flood areas
        result_image_pil = Image.fromarray(result_image)
        
        # Save images to byte buffers
        ground_truth_buf = io.BytesIO()
        ground_truth_pil.save(ground_truth_buf, format='PNG')
        ground_truth_buf.seek(0)
        
        predicted_mask_buf = io.BytesIO()
        predicted_mask_pil.save(predicted_mask_buf, format='PNG')
        predicted_mask_buf.seek(0)
        
        result_image_buf = io.BytesIO()
        result_image_pil.save(result_image_buf, format='PNG')
        result_image_buf.seek(0)
        
        # Encode images to base64
        ground_truth_base64 = base64.b64encode(ground_truth_buf.getvalue()).decode('utf-8')
        predicted_mask_base64 = base64.b64encode(predicted_mask_buf.getvalue()).decode('utf-8')
        result_image_base64 = base64.b64encode(result_image_buf.getvalue()).decode('utf-8')
        
        # Return JSON with base64 encoded images
        return jsonify({
            'ground_truth': ground_truth_base64,
            'predicted_mask': predicted_mask_base64,
            'result_image': result_image_base64,
            'flood_detected': bool(np.max(prediction) > 0)
        })
    
    except Exception as e:
        print(f"Error during flood detection: {str(e)}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)