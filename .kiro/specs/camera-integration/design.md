# Camera Integration Design Document

## Overview

This document outlines the design for integrating camera functionality into the KombinApp, providing users with the ability to capture photos of their clothing items directly through the device camera with proper error handling and fallback mechanisms.

## Architecture

### Component Structure
```
AddClothingView (SwiftUI)
├── CameraButton (UI Component)
├── CameraPickerView (UIViewControllerRepresentable)
│   ├── UIImagePickerController
│   └── CameraCoordinator (Delegate)
├── PermissionManager (Helper)
└── ImageDisplayView (UI Component)
```

### Data Flow
1. User taps "Kamerayı Aç" button
2. PermissionManager checks camera availability and permissions
3. CameraPickerView presents UIImagePickerController
4. User captures photo or cancels
5. CameraCoordinator handles result and updates @State
6. ImageDisplayView shows captured photo

## Components and Interfaces

### CameraPickerView (UIViewControllerRepresentable)
```swift
struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context)
    func makeCoordinator() -> CameraCoordinator
}
```

### CameraCoordinator (Delegate Handler)
```swift
class CameraCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let parent: CameraPickerView
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
}
```

### PermissionManager (Helper Class)
```swift
class PermissionManager {
    static func checkCameraPermission() -> CameraPermissionStatus
    static func requestCameraPermission(completion: @escaping (Bool) -> Void)
    static func isCameraAvailable() -> Bool
}

enum CameraPermissionStatus {
    case authorized, denied, notDetermined, restricted
}
```

### AddClothingView Integration
```swift
struct AddClothingView: View {
    @State private var selectedImage: UIImage?
    @State private var showCamera = false
    @State private var showPermissionAlert = false
    @State private var permissionMessage = ""
    
    // Camera button and image display logic
}
```

## Data Models

### Image State Management
```swift
// State variables for camera functionality
@State private var selectedImage: UIImage?
@State private var imageData: Data?
@State private var showCamera = false
@State private var showPhotoLibrary = false
@State private var showPermissionAlert = false
@State private var permissionMessage = ""
```

### Permission States
```swift
enum CameraState {
    case idle
    case requestingPermission
    case cameraActive
    case photoLibraryActive
    case permissionDenied
    case cameraUnavailable
}
```

## Error Handling

### Permission Errors
- **Camera Permission Denied**: Show alert with message "Kamera izni verilmedi" and option to open Settings
- **Camera Not Available**: Automatically fallback to photo library with user notification
- **Hardware Not Supported**: Display appropriate message and use photo library

### Camera Operation Errors
- **Camera Initialization Failed**: Fallback to photo library
- **Photo Capture Failed**: Allow user to retry or cancel
- **Memory Issues**: Handle gracefully with user feedback

### Fallback Mechanisms
1. **Primary**: Device camera with proper permissions
2. **Secondary**: Photo library if camera unavailable
3. **Tertiary**: Error message with guidance if both fail

## Testing Strategy

### Unit Tests
- PermissionManager functionality
- CameraCoordinator delegate methods
- State management logic
- Error handling scenarios

### Integration Tests
- Camera permission flow
- Photo capture and display
- Fallback to photo library
- UI state transitions

### Device Testing
- Test on physical devices (camera required)
- Test permission grant/deny scenarios
- Test on devices without camera
- Test in both light and dark modes

### Edge Cases
- Low memory situations
- Camera hardware failures
- Permission changes while app is running
- Background/foreground transitions during camera use

## Implementation Notes

### iOS 16+ Compatibility
- Use modern SwiftUI patterns
- Leverage new permission APIs where available
- Maintain backward compatibility for iOS 16.0

### Performance Considerations
- Lazy loading of camera components
- Proper memory management for images
- Efficient image compression and storage

### Accessibility
- VoiceOver support for camera button
- Alternative text for captured images
- Keyboard navigation support

### Dark Mode Support
- Adaptive colors for all UI components
- Proper contrast ratios
- Consistent theming with app design