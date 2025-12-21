# Discount Scanner Application Plan

## 1. Application Type
A cross-platform mobile application named "Discount Scanner," built using the Flutter framework to ensure compatibility with both Android and iOS from a single codebase.

## 2. Core Technologies
*   **Framework:** Flutter will be used for the core application UI and business logic.
*   **Language:** Dart.
*   **Camera Access:** The official Flutter `camera` plugin will be integrated to provide access to the device's camera hardware.
*   **Text Recognition (OCR):** Google's ML Kit for Flutter (`google_ml_kit_text_recognition`) will be used for powerful and efficient on-device text recognition. This allows the app to work without an internet connection.

## 3. User Experience (UX) and Core Features

### 3.1. Home Screen
*   The application will launch to a simple, welcoming screen.
*   A single, prominent "Scan Price Tag" call-to-action button will be the primary focus.

### 3.2. Scanning Process
*   Activating the scan button will open a full-screen live camera view.
*   The app will continuously analyze the camera feed using OCR to detect and parse text in real-time.
*   A visual overlay (e.g., a rectangle) may be used to guide the user in positioning the price tag within the camera's view.

### 3.3. Automatic Discount Calculation
*   The OCR service will specifically search for patterns matching prices (e.g., `$19.99`, `€25.00`) and discount rates (e.g., `20%`, `30% off`, `-15%`).
*   If both a price and a discount are successfully detected, the app will navigate to a results screen.
*   The results screen will clearly display:
    *   Original Price
    *   Detected Discount
    *   Final, Calculated Price

### 3.4. Manual Discount Entry
*   If the OCR detects a price but fails to find a discount rate, the app will transition to a manual entry screen.
*   This screen will display the detected "Original Price".
*   Below the price, a user-friendly, scrollable list or grid of buttons will be presented with predefined discount values (5%, 10%, 15%, ..., 95%).

### 3.5. Final Price Calculation (Manual)
*   When the user taps a discount button, the app will perform the calculation.
*   The UI will update instantly to show the "Final Price" based on the user's selection.

## 4. Visual Design
*   The app will adhere to modern UI/UX standards, utilizing Material Design principles.
*   The design will be clean, uncluttered, and focused on making the scanning and calculation process as intuitive and fast as possible.
*   The look and feel will be consistent and high-quality on both Android and iOS devices.
