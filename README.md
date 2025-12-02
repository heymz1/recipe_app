# Recipe App

A Flutter mobile application for managing recipes with local storage, image support, and Material Design UI.

## Features

- ✅ Create, Read, Update, and Delete recipes
- ✅ Filter recipes by type (Breakfast, Lunch, Dinner, Dessert, Snack, Beverage)
- ✅ Add images to recipes using device gallery
- ✅ Store ingredients and cooking steps for each recipe
- ✅ Persistent local storage using Hive
- ✅ Material Design 3 UI
- ✅ Responsive layout for different screen sizes
- ✅ Pre-populated sample recipes

## Requirements

- Flutter SDK 3.8.1 or higher
- Dart SDK compatible with Flutter
- Android SDK (for Android builds)
- iOS development tools (for iOS builds, macOS only)

## Dependencies

- `hive`: ^2.2.3 - Local database storage
- `hive_flutter`: ^1.1.0 - Flutter integration for Hive
- `image_picker`: ^1.0.7 - Image selection from gallery
- `path_provider`: ^2.1.2 - Access to file system directories
- `intl`: ^0.19.0 - Internationalization and date formatting

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd recipe_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Hive Adapters

The Hive type adapters need to be generated for the Recipe model:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Run the App

For debug mode:
```bash
flutter run
```

For release mode:
```bash
flutter run --release
```

## Project Structure

```
lib/
├── main.dart                     # App entry point
├── models/
│   ├── recipe_model.dart        # Recipe data model with Hive annotations
│   ├── recipe_model.g.dart      # Generated Hive adapter
│   └── recipe_type_model.dart   # Recipe type model
├── services/
│   └── recipe_service.dart      # Business logic and data operations
├── screens/
│   ├── recipe_list_screen.dart   # Main screen with recipe list
│   ├── recipe_detail_screen.dart # Recipe details with edit/delete
│   └── recipe_form_screen.dart   # Create/edit recipe form
├── widgets/
│   └── recipe_card_widget.dart   # Reusable recipe card
└── assets/
    └── recipetypes.json          # Recipe types configuration
```

## Usage

### Viewing Recipes

- The app opens to a grid view of all recipes
- Use the dropdown filter to view recipes by type
- Tap on any recipe card to view full details

### Adding a New Recipe

1. Tap the "Add Recipe" floating action button
2. Fill in the recipe name
3. Select a recipe type from the dropdown
4. (Optional) Add an image from your gallery
5. Add ingredients using the "+" button
6. Add cooking steps using the "+" button
7. Tap "Save Recipe"

### Editing a Recipe

1. Open a recipe's detail page
2. Tap the edit icon in the app bar
3. Modify any fields as needed
4. Tap "Update Recipe"

### Deleting a Recipe

1. Open a recipe's detail page
2. Tap the delete icon in the app bar
3. Confirm deletion in the dialog

## Building for Production

### Android APK

```bash
flutter build apk --release
```

The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## Data Persistence

The app uses Hive for local storage. All recipes are automatically saved and persist across app restarts. Data is stored in the application documents directory.

## Responsive Design

The app adapts to different screen sizes:
- **Small screens**: 2-column grid
- **Medium screens (>600px)**: 3-column grid
- **Large screens (>900px)**: 4-column grid

## Architecture

The app follows a clean architecture pattern with separation of concerns:

- **Models**: Data structures with serialization logic
- **Services**: Business logic and data access
- **Screens**: UI pages and user interaction
- **Widgets**: Reusable UI components

## OOP Principles Applied

- **Encapsulation**: Data and methods are encapsulated in appropriate classes
- **Abstraction**: Service layer abstracts storage implementation
- **Single Responsibility**: Each class has a single, well-defined purpose
- **Don't Repeat Yourself (DRY)**: Reusable widgets and service methods

## Dart/Flutter Conventions

- ✅ camelCase for variable and method names
- ✅ PascalCase for class names
- ✅ snake_case for file names
- ✅ Proper use of const constructors
- ✅ Null safety enabled
- ✅ Async/await for asynchronous operations
- ✅ Proper widget lifecycle management

## Troubleshooting

### Build Runner Issues

If you encounter issues with generated files, run:

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Image Picker Permissions

Ensure your Android manifest and iOS Info.plist have the necessary permissions for accessing the photo library.

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photos to add recipe images</string>
```

## License

This project is created for educational purposes.
