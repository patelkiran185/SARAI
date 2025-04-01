# SARAI
- Remote sensing involves collecting information about the Earth's surface without direct contact, usually using satellites, drones, or aircraft. SAR is one of the key technologies used in remote sensing because it works in all weather conditions and during day or night.
- SAR (Synthetic Aperture Radar) images are powerful tools for remote sensing because they can capture detailed information from the Earth's surface, regardless of weather conditions or lighting (e.g., during night or cloudy days).
- Synthetic Aperture Radar (SAR) images play a crucial role in remote sensing applications. However, interpreting SAR images can be challenging because they often contain speckle noise (a grainy texture) and appear in grayscale, which makes it harder to identify and analyze key details.

## Aim
It is a mobile application named SARAI. 
Goal is to create a mobile app that leverages Generative AI (GenAI) techniques to solve three key challenges:
- Colorization of SAR images to improve their readability and usability.
- Flood area detection to help map and assess regions affected by flooding.
- Clasification of crop images using GENAI

## 🌟 Overview
Synthetic aperture radar (SAR) imagery is crucial in remote sensing applications. However, due to inherent speckle noise and the grayscale nature of these images, interpreting them can be difficult. Our colorization techniques significantly improve the visual quality of SAR images, facilitating better analysis and yielding valuable information for diverse applications.

### Key Functionalities  

1. **Crop Classification**  
   - **Objective:** Accurately predicts crop types among five different classes.  
   - **Models Used:**  
     - **VGG16:** Achieved an impressive accuracy of 90%.  
     - **Vision Transformer (ViT):** Improved accuracy to 97%.  

2. **Flood Area Detection**  
   - **Objective:** Successfully identifies and maps areas susceptible to flooding.  
   - **Model Used:**   
     - **UNETR:** Delivered an outstanding accuracy of 96% in spatial segmentation.  

3. **SAR Image Colorization**  
   - **Objective:** Creates realistic colorized SAR images, enhancing visual interpretability for detailed analysis.  
   - **Model Used:**  
     - **Pix2Pix:** Achieved a Fréchet Inception Distance (FID) score of 320, underscoring the realism in image synthesis.  

4. **Backend Dockerization**  
   - Facilitates deployment by containerizing all deep learning models using Docker, enhancing scalability and management.  


## 🚀 Technology Stack  

- **Frontend:**   
  - **Flutter:** To build a sleek, responsive user interface for an exceptional user experience.  

- **Backend:**   
  - **Flask:** For developing APIs and backend integration.  

- **Containerization:**   
  - **Docker:** Ensures smooth deployment and scalability of the application.  

- **Deep Learning Models Used:**  
  - **VGG16**  
  - **Vision Transformer (ViT)**  
  - **UNETR**  
  - **Pix2Pix**
 
## 🛠️ Installation  

To set up **SARAI** locally, follow these steps:  

1. **Clone the repository:**  
   ```bash  
   git clone https://github.com/patelkiran185/SARAI.git 
   cd SARAI  
2. **Set up the backend environment:**
    ```bash
    cd backend  
    pip install -r requirements.txt
3. **Build and run Docker containers:**
    ```bash
    docker-compose up --build  
4. **Launch the frontend:**
    ```bash 
    flutter run  
