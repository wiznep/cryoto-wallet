# Wallet App

A cryptocurrency wallet mobile application built with Flutter.

## Features

- **Authentication**: Sign in and sign up with email/password or Google account
- **Wallet Management**: View wallet balances, addresses, and transactions
- **Crypto Operations**: 
  - Send cryptocurrency to other addresses
  - Receive cryptocurrency via generated QR codes
  - View transaction details and history
  - Swap cryptocurrency (UI placeholder for future implementation)
- **Theme Support**: Light and dark mode with user preference persistence
- **Local Storage**: Wallet data persisted using Hive
- **Security**: Password validation, secure wallet displays, and clipboard integration

## Tech Stack

- **Flutter**: UI framework for cross-platform development
- **Provider**: State management
- **Hive**: Local data storage
- **Shared Preferences**: User preferences storage
- **QR Flutter**: QR code generation for wallet addresses

## Getting Started

1. Ensure you have Flutter installed and set up (https://flutter.dev/docs/get-started/install)
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the application

## Project Structure

```
lib/
├── main.dart          # Application entry point
├── providers/         # State management
│   ├── auth_provider.dart
│   ├── theme_provider.dart
│   └── wallet_provider.dart
├── screens/           # UI screens
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home_screen.dart
│   ├── transaction_detail_screen.dart
│   ├── send_screen.dart
│   └── receive_screen.dart
├── themes/            # Theme configuration
│   └── app_theme.dart
├── utils/             # Utility functions
│   └── number_formatter.dart
└── widgets/           # Reusable UI components
    ├── auth/
    │   └── social_button.dart
    └── home/
        ├── action_button.dart
        ├── balance_card.dart
        └── wallet_list_item.dart
```

## Implemented Screens

1. **Splash Screen**: Initial loading screen with animation
2. **Authentication Screens**: Login and Sign-up screens with form validation
3. **Home Screen**: Main dashboard with wallet balance, actions and transactions
4. **Transaction Detail Screen**: Detailed view of selected transactions
5. **Send Screen**: UI for sending cryptocurrency to another address
6. **Receive Screen**: Generate and display QR code for receiving cryptocurrency

## Notes

This is a demo application that simulates cryptocurrency wallet functionality. It doesn't connect to actual blockchain networks and uses mock data for demonstration purposes.
