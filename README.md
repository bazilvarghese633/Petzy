# Petzy 🐾
> *A modern Flutter pet e-commerce experience — built with love for pets and clean code.*

---

## What is Petzy?

Petzy is a full-featured pet e-commerce app built with Flutter and Firebase. From browsing products to checkout, everything is real-time, smooth, and beautifully designed.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔥 **Real-time Sync** | Products and cart instantly synchronized via Firebase |
| 🛒 **E-commerce** | Browse, search, and purchase pet products with ease |
| 🔐 **Google Auth** | Secure one-tap login with Google Sign-In |
| 💳 **Payments** | Razorpay integration for seamless checkout |
| 👜 **Smart Cart** | Full cart management with quantity controls |
| ❤️ **Favorites** | Save and revisit your favorite products |
| ⭐ **Reviews** | User-generated ratings and reviews |
| 📍 **Addresses** | Save and manage multiple delivery addresses |
| 💰 **Wallet** | Built-in digital wallet for quick payments |
| 📦 **Order Tracking** | Complete order history and live status updates |

---

## 🛠️ Tech Stack

```
Flutter          →  Cross-platform UI framework
BLoC             →  State management
Firebase         →  Firestore + Authentication backend
Razorpay         →  Payment gateway
Cloudinary       →  Image storage & delivery
Material 3       →  Design system
```

---

## 📦 Dependencies

```yaml
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
```

---

## 📁 Project Structure

```
lib/
├── features/
│   ├── core/            # Utilities, colors, themes
│   ├── data/            # Data sources, repository implementations
│   ├── domain/          # Models, repositories, use cases
│   └── presentation/    # Screens, BLoCs, widgets
├── firebase_options.dart
└── main.dart
```

---

<p align="center">Made with ❤️ using Flutter</p>