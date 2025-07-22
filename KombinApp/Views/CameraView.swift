//
//  CameraView.swift
//  KombinApp
//
//  Created by Burak Gökce on 21.07.2025.
//

import SwiftUI
import UIKit
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        
        print("📸 CameraView oluşturuluyor...")
        
        // Kamera kullanılabilirlik kontrolü
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("✅ Kamera mevcut - kamera modu")
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
            picker.cameraDevice = .rear
        } else {
            print("⚠️ Kamera mevcut değil - galeri modu")
            picker.sourceType = .photoLibrary
        }
        
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        picker.modalPresentationStyle = .fullScreen
        
        print("✅ ImagePicker yapılandırıldı")
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
            super.init()
            print("📋 CameraView Coordinator oluşturuldu")
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            print("✅ Fotoğraf seçildi/çekildi!")
            
            if let image = info[.originalImage] as? UIImage {
                print("🖼️ Fotoğraf işleniyor...")
                parent.imageData = image.jpegData(compressionQuality: 0.8)
                print("✅ Fotoğraf başarıyla kaydedildi - Boyut: \(parent.imageData?.count ?? 0) bytes")
            } else {
                print("❌ Fotoğraf alınamadı")
            }
            
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            print("❌ Fotoğraf seçimi iptal edildi")
            parent.dismiss()
        }
    }
}