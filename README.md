# CanineaAI

CanineaAI is a Flutter-powered mobile app that uses AI to identify dog breeds from your photos. Instantly discover the breed of any dog, get fun facts, view your prediction history, read the latest dog news, and more—all in a beautiful, modern interface.

---

## ✨ Features

- **Dog Breed Identification**: Snap a photo or pick one from your gallery to identify the breed of any dog using an on-device AI model.
- **Top-3 Predictions**: See the top three most likely breeds with confidence scores.
- **Breed Info & Fun Facts**: Get a random image and a fun fact about the predicted breed (powered by Dog CEO and dog fact APIs).
- **Prediction History**: View your past predictions, including breed, confidence, date, and breed image. Clear your history anytime.
- **Dog News**: Stay up-to-date with the latest dog-related news articles (via GNews API).
- **Dark Mode**: Toggle between light and dark themes in the settings.
- **Share Results**: Share your predictions and fun facts with friends.

---

## 🚀 Installation

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.0.0 or higher)
- Android Studio, Xcode, or a compatible IDE
- A device or emulator (Android or iOS)

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/canine_ai.git
cd canine_ai
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run the App
- **Android:**
  - Connect your device or start an emulator.
  - Run:
    ```bash
    flutter run
    ```
- **iOS:**
  - Open the project in Xcode and ensure signing is set up, or use:
    ```bash
    flutter run
    ```

### 4. Permissions
The app requires:
- Camera access (for taking photos)
- Storage access (for picking images)
- Internet access (for fetching breed info, fun facts, and news)

---

## 📱 Usage Guide

1. **Launch the App**: Enjoy a splash screen and land on the home page.
2. **Identify a Dog Breed**:
   - Tap the **Camera** or **Gallery** button to select a dog photo.
   - Once an image is selected, tap **Predict**.
   - View the top-3 predicted breeds with confidence scores.
   - See a random image and fun fact about the top breed.
   - Share your result or go back to try another photo.
3. **View Prediction History**:
   - Tap the **History** icon in the top bar to see all past predictions.
   - Clear your history with the trash icon.
4. **Read Dog News**:
   - Tap the **News** icon to browse the latest dog-related articles.
   - Tap an article to read it in your browser.
5. **Change Theme**:
   - Tap the **Settings** icon to toggle dark mode.

---

## 🗂️ Project Structure
- `lib/` — Main Dart source files
- `assets/` — Images, fonts, Lottie animations, and the AI model
- `android/` — Android-specific files
- `test/` — Widget tests

---

## 📝 Credits
- **App Icon & Placeholder**: [pngtree.com](https://pngtree.com/)
- **Dog Images & Fun Facts**: [Dog CEO API](https://dog.ceo/dog-api/) & [Dog Facts API](https://kinduff.github.io/dog-api/)
- **News**: [GNews API](https://gnews.io/)

---

## Dataset Acknowledgement

This project uses a dataset provided by Aditya Khosla et al. for training and evaluation purposes. (http://vision.stanford.edu/aditya86/ImageNetDogs/) 

## 📄 License
This project is for educational and demonstration purposes. See individual asset sources for their respective licenses.
