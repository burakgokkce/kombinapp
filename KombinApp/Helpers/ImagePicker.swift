//
//  ImagePicker.swift
//  KombinApp
//
//  Created by Burak Gökce on 21.07.2025.
//

import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        
        print("🎥 ImagePicker oluşturuluyor - sourceType: \(sourceType == .camera ? "Camera" : "PhotoLibrary")")
        
        // Kamera için ekstra kontroller
        if sourceType == .camera {
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                print("❌ Kamera mevcut değil")
                return picker
            }
            
            // Kamera için gerekli ayarlar
            picker.cameraCaptureMode = .photo
            picker.cameraDevice = .rear
        }
        
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        picker.modalPresentationStyle = .fullScreen
        
        print("✅ ImagePicker yapılandırıldı")
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Güncelleme gerekmiyor
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
            super.init()
            print("📋 ImagePicker Coordinator oluşturuldu")
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            print("✅ Fotoğraf seçildi/çekildi")
            
            if let image = info[.originalImage] as? UIImage {
                print("🖼️ Fotoğraf işleniyor...")
                parent.imageData = image.jpegData(compressionQuality: 0.8)
                print("✅ Fotoğraf data'ya dönüştürüldü")
            } else {
                print("❌ Fotoğraf alınamadı")
            }
            
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            print("❌ Fotoğraf seçimi iptal edildi")
            parent.dismiss()
        }
        
        // Hata durumları için
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any], error: Error?) {
            if let error = error {
                print("❌ ImagePicker hatası: \(error.localizedDescription)")
            }
            parent.dismiss()
        }
    }
}