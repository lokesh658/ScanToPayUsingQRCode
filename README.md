# ScanToPayUsingQRCode

A Flutter QR code-based payment application for point-of-sale transactions.

## Features

- 📦 **Inventory Management**: Browse and select products from a beautiful grid interface
- 🛒 **Smart Cart**: Add/remove items with real-time price calculation including tax
- 📱 **QR Generation**: Generate compact QR codes containing invoice data
- 📷 **QR Scanning**: Scan QR codes from phone displays using camera
- 💳 **Payment Verification**: View detailed invoice breakdown before payment

## Getting Started

### Prerequisites

- Flutter SDK 3.10.7 or higher
- Dart SDK
- Android Studio / VS Code

### Installation

```bash
flutter pub get
flutter run
```

## How It Works

1. **Merchant**: Select products → Generate QR code
2. **Customer**: Scan QR code → Verify invoice → Pay

## Tech Stack

- **Framework**: Flutter
- **State Management**: GetX
- **QR Processing**: zxing2
- **Camera**: camera package
- **Image Processing**: image package
