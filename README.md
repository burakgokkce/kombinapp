# KombinApp - AI-Powered Outfit Suggestion App

A sophisticated SwiftUI app that allows users to upload their own clothing items and receive AI-powered outfit suggestions with a beautiful pink/purple pastel theme and full dark mode support.

## 🎯 Core Features

### 🎨 Beautiful Design
- Soft pastel pink/purple theme (#ffb6c1 → #d291bc)
- Full dark mode compatibility with automatic theme switching
- Modern capsule buttons with soft shadows
- Clean, minimal interface with smooth transitions
- Responsive design that adapts to all screen sizes

### 📱 Complete App Experience
- **Splash Screen**: Pink-to-purple gradient with animated logo (2-second auto-navigation)
- **Bottom Tab Navigation**: Generate Outfit, My Closet, Settings
- **Camera Integration**: Full camera and photo library support
- **AI-Powered Suggestions**: Smart outfit recommendations based on your wardrobe
- **Multi-language Support**: English and Turkish with seamless switching

### 🧥 Advanced Clothing Management
- **Seven Categories**: Top, Bottom, Shoes, Accessories, Jeans, Skirts, Dresses
- **Real Photo Upload**: Camera capture or gallery selection
- **AI Detection**: Automatic color and style recognition from uploaded images
- **Smart Organization**: Filter and browse by category
- **Local Storage**: All items saved securely on device

### 🤖 AI-Powered Outfit Generation
- **"What should I wear today?" button**: Instant outfit suggestions
- **Style Preferences**: Choose from Casual, Formal, Sporty, Elegant, Trendy, Comfortable
- **Custom Descriptions**: Describe your desired style in natural language
- **Smart Combinations**: AI creates complete outfits (Top + Bottom + Shoes + Optional Accessory)
- **Interactive Feedback**: "I like it 💖" or "Try again 🔄" buttons
- **Favorites System**: Save and manage preferred outfit combinations

### ⚙️ Advanced Settings
- **Theme Modes**: Light, Dark, Auto (follows system)
- **Languages**: English and Turkish with flag indicators
- **Developer Contact**: Direct email integration (contact@ybdigitall.com)
- **App Version**: Version tracking and display

## 🏗️ Project Structure

```
KombinApp/
├── Models/
│   ├── ClothingItem.swift          # AI-enhanced clothing data model
│   ├── Outfit.swift                # Outfit combination model
│   └── AppSettings.swift           # App configuration and settings
├── ViewModels/
│   └── ClothingStore.swift         # Complete data management with AI integration
├── Services/
│   └── AIOutfitService.swift       # AI-powered outfit suggestion engine
├── Views/
│   ├── SplashView.swift           # Animated splash screen
│   ├── MainTabView.swift          # Tab navigation with dark mode support
│   ├── MyClosetView.swift         # Clothing management and organization
│   ├── AddClothingView.swift      # Camera/gallery integration with AI detection
│   ├── GenerateOutfitView.swift   # AI-powered outfit suggestions
│   └── SettingsView.swift         # Comprehensive settings with localization
├── Helpers/
│   ├── ImagePicker.swift          # Camera and photo library integration
│   └── ColorExtension.swift       # Hex color utilities
└── Info.plist                     # Camera and photo library permissions
```

## 🛠️ Technical Implementation

- **Framework**: SwiftUI with iOS 16+ compatibility
- **Architecture**: MVVM pattern with ObservableObject
- **AI Integration**: Simulated AI color/style detection with extensible architecture
- **Camera Support**: Full UIImagePickerController integration
- **Dark Mode**: Complete dark mode support with automatic theme switching
- **Localization**: English and Turkish language support
- **Data Persistence**: Local storage with rich dummy data
- **Permissions**: Camera and photo library access properly configured

## 🎨 Design System

### Color Palette
- **Primary Pink**: `#ffb6c1` (Light Pink)
- **Primary Purple**: `#d291bc` (Lilac)
- **Adaptive Backgrounds**: System backgrounds that work in light and dark modes
- **Dynamic Colors**: AI-detected colors from clothing images

### UI Components
- **Capsule Buttons**: Gradient and outlined styles with proper dark mode support
- **Cards**: Rounded rectangles with adaptive shadows
- **AI Previews**: Dynamic color-based clothing visualizations
- **Icons**: SF Symbols with consistent sizing and theming

## 🚀 Getting Started

1. **Open Project**: Launch in Xcode 15+
2. **Build & Run**: Works on iOS Simulator and devices (camera features require device)
3. **Grant Permissions**: Allow camera and photo library access when prompted
4. **Add Clothing**: Upload photos of your real clothes
5. **Get AI Suggestions**: Receive personalized outfit recommendations

## 📱 App Flow

1. **Launch**: Beautiful splash screen with gradient animation
2. **Generate Outfit**: AI-powered suggestions with style preferences
3. **My Closet**: Upload and organize your clothing with AI detection
4. **Settings**: Customize theme, language, and view app info

## 🌟 Key Highlights

### AI-Powered Features
- **Smart Color Detection**: AI automatically identifies clothing colors from photos
- **Style Recognition**: AI detects casual, formal, or sporty styles
- **Intelligent Combinations**: AI creates cohesive outfit suggestions
- **Natural Language Processing**: Describe your style preferences in text
- **Learning Algorithm**: Suggestions improve based on your preferences

### User Experience
- **Real Photo Integration**: Upload actual photos of your clothes
- **Instant Feedback**: Like or regenerate suggestions with one tap
- **Dark Mode Excellence**: Seamless experience in all lighting conditions
- **Multi-language Support**: Full English and Turkish localization
- **Offline Functionality**: All features work without internet connection

### Technical Excellence
- **Camera Integration**: Full camera and photo library support
- **AI Architecture**: Extensible design ready for real ML integration
- **Performance Optimized**: Smooth animations and responsive UI
- **Privacy Focused**: All data stored locally on device
- **Accessibility Ready**: VoiceOver and accessibility support

## 🔮 Future Enhancements

- **Real AI Integration**: Core ML or Vision framework implementation
- **Cloud Sync**: iCloud synchronization across devices
- **Social Features**: Share outfits with friends
- **Weather Integration**: Weather-appropriate suggestions
- **Shopping Integration**: Purchase similar items online

The app delivers a complete, AI-powered outfit suggestion experience with modern SwiftUI best practices, full dark mode support, and a delightful pink/purple aesthetic! 🎉✨