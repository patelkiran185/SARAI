from flask import Flask, request, jsonify
from flask_cors import CORS
from keras.models import load_model
from keras.preprocessing import image
import numpy as np
from io import BytesIO
from PIL import Image
import cv2
from patchify import patchify
import base64
import os

app = Flask(__name__)
CORS(app)


# Load the model
model = load_model(
    'model.keras', 
    custom_objects={
        "dice_loss": lambda x, y: x, 
        "dice_coef": lambda x, y: x
    }
)

# Configuration
cf = {
    "image_size": 256,
    "num_channels": 3,
    "patch_size": 16,
    "flat_patches_shape": (256, 48)
}

# Path to the ground truth image
GROUND_TRUTH_PATH = os.path.join(os.path.dirname(__file__), 'groundimage.png')


def encoded_image(image_path):
    """
    Encode the image from the specified path into a base64 string.
    """
    try:
        # Open the image
        with open(image_path, "rb") as img_file:
            # Read and encode the image to base64
            encoded_image = base64.b64encode(img_file.read()).decode('utf-8')
        return encoded_image
    except Exception as e:
        print(f"Error encoding image: {e}")
        return None


def encode_image(image_data):
    """
    Encode a NumPy array image into a base64 string.
    """
    if image_data is None:
        raise ValueError("Cannot encode a None image.")
    print(f"Image data shape: {image_data.shape}, dtype: {image_data.dtype}")
    
    # Ensure single-channel image (grayscale) is handled properly
    if len(image_data.shape) == 3 and image_data.shape[2] == 1:  # Single-channel image
        image_data = image_data.squeeze(axis=2)  # Convert to (H, W)
    elif len(image_data.shape) != 2 and len(image_data.shape) != 3:
        raise ValueError(f"Unsupported image shape: {image_data.shape}")

    # Convert to a PNG image and encode to base64
    output = BytesIO()
    Image.fromarray(image_data).save(output, format="PNG")
    output.seek(0)
    return base64.b64encode(output.getvalue()).decode('utf-8')


@app.route('/detect', methods=['POST'])
def flood_prediction():
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400

    img_file = request.files['image']
    img = Image.open(BytesIO(img_file.read()))
    img = img.convert("RGB")

    # Preprocess the image
    img = img.resize((cf["image_size"], cf["image_size"]))
    img_array = np.array(img) / 255.0

    # Generate patches and predict
    patch_shape = (cf["patch_size"], cf["patch_size"], cf["num_channels"])
    patches = patchify(img_array, patch_shape, cf["patch_size"])
    patches = np.reshape(patches, (-1, patch_shape[0] * patch_shape[1] * cf["num_channels"]))
    patches = patches.astype(np.float32)
    patches = np.expand_dims(patches, axis=0)

    pred = model.predict(patches, verbose=0)[0]
    pred = np.reshape(pred, (cf["image_size"], cf["image_size"], 1))
    pred = (pred > 0.5).astype(np.uint8)

    # Encode ground truth image
    ground_truth_base64 = encoded_image(GROUND_TRUTH_PATH)
    if ground_truth_base64 is None:
        return jsonify({'error': 'Ground truth image not found or could not be encoded'}), 500

    # Generate predicted mask and overlay
    predicted_mask = (pred * 255).astype(np.uint8)  # Ensure it's 2D grayscale
    if len(predicted_mask.shape) == 3 and predicted_mask.shape[2] == 1:
        predicted_mask = predicted_mask.squeeze(axis=2)

    pred_edges = cv2.Canny(pred[:, :, 0] * 255, 100, 200)
    kernel = np.ones((3, 3), np.uint8)
    thicker_edges = cv2.dilate(pred_edges, kernel, iterations=1)

    # Overlay red spots
    outline_mask = np.zeros((cf["image_size"], cf["image_size"], 3), dtype=np.uint8)
    outline_mask[:, :, 0] = thicker_edges
    combined_image = cv2.addWeighted((img_array * 255).astype(np.uint8), 0.9, outline_mask, 0.3, 0)

    # Return encoded images
    return jsonify({
        "ground_truth": ground_truth_base64,
        "predicted_mask": encode_image(predicted_mask),
        "result_image": encode_image(combined_image)
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
