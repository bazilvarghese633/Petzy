# Petzy 🐾

A modern Flutter pet e-commerce app with Firebase backend, featuring seamless shopping experience for pet products and services.

✨ Features
✅ Real-time Firebase Sync: Products and cart are instantly synchronized across devices.
🛒 E-commerce Functionality: Browse, search, and purchase pet products with ease.
🔐 Google Authentication: Secure login with Google Sign-In.
📱 BLoC State Management: Robust and scalable architecture pattern.
💳 Payment Integration: Razorpay integration for seamless payments.
⭐ Reviews & Ratings: User-generated reviews for products.
👜 Shopping Cart: Full-featured cart with quantity management.
📍 Address Management: Save and manage multiple delivery addresses.
💰 Wallet System: Digital wallet for convenient payments.
📦 Order Tracking: Complete order history and status tracking.
❤️ Favorites: Save your favorite products for later.

🛠️ Tech Stack
Framework: Flutter
State Management: BLoC
Backend: Firebase (Firestore, Authentication)
Payment: Razorpay
Image Storage: Cloudinary
UI: Material Design 3

📦 Core Dependencies
dependencies:
  flutter_bloc: ^9.1.1
  cloud_firestore: ^5.6.8
  firebase_auth: ^5.5.4
  firebase_core: ^3.13.1
  razorpay_flutter: ^1.4.0
  google_sign_in: ^6.3.0
  image_picker: ^1.1.2
  cloudinary_public: ^0.23.1
  google_fonts: ^6.2.1
  google_nav_bar: ^5.0.7
  lottie: ^3.3.1
  shimmer: ^3.0.0
  shared_preferences: ^2.5.3

📁 Project Structure
lib/
├── features/
│   ├── core/           # Core utilities, colors, and themes
│   ├── data/           # Data sources and repository implementations
│   ├── domain/         # Domain models, repositories, and use cases
│   └── presentation/   # UI screens, BLoCs, and widgets
├── firebase_options.dart # Firebase configuration
└── main.dart           # App entry point

Made with ❤️ using Flutter
