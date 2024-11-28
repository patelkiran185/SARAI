from flask import Flask, request, jsonify, Response
from flask_cors import CORS
from keras.models import load_model
from keras.preprocessing import image
import numpy as np
from io import BytesIO
from PIL import Image
import cv2
from patchify import patchify
import base64
from zipfile import ZipFile
import io

app = Flask(__name__)
CORS(app) 

model = load_model('model.keras', custom_objects={"dice_loss": lambda x, y: x, "dice_coef": lambda x, y: x})

cf = {
    "image_size": 256,
    "num_channels": 3,
    "patch_size": 16,
    "flat_patches_shape": (256, 48) 
}


@app.route('/detect', methods=['POST'])
def flood_prediction():
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400

    img_file = request.files['image']
    img = Image.open(BytesIO(img_file.read()))
    img = img.convert("RGB") 

 
    img = img.resize((cf["image_size"], cf["image_size"]))
    img_array = np.array(img) / 255.0

   
    patch_shape = (cf["patch_size"], cf["patch_size"], cf["num_channels"])
    patches = patchify(img_array, patch_shape, cf["patch_size"])
    patches = np.reshape(patches, (-1, patch_shape[0] * patch_shape[1] * cf["num_channels"]))
    patches = patches.astype(np.float32)
    patches = np.expand_dims(patches, axis=0)
    pred = model.predict(patches, verbose=0)[0]
    pred = np.reshape(pred, (cf["image_size"], cf["image_size"], 1))
    pred = (pred > 0.5).astype(np.uint8)

    pred_edges = cv2.Canny(pred[:, :, 0] * 255, 100, 200)
    kernel = np.ones((3, 3), np.uint8)  
    thicker_edges = cv2.dilate(pred_edges, kernel, iterations=1)

    outline_mask = np.zeros((cf["image_size"], cf["image_size"], 3), dtype=np.uint8)
    outline_mask[:, :, 000] = thicker_edges  
    img_array = (img_array * 255).astype(np.uint8) 
    combined_image = cv2.addWeighted(img_array, 0.9, outline_mask, 0.3, 0)
 
    output = BytesIO()
    combined_pil_image = Image.fromarray(combined_image)
    combined_pil_image.save(output, format="PNG")
    output.seek(0)

    return Response(output.getvalue(), mimetype='image/png')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)