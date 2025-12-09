//
//  PHPicker.swift
//  My PDF
//
//  Created by Эдвард on 12/10/25.
//

import SwiftUI
import PhotosUI

struct PHPicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    var onComplete: () -> Void = {}
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 0
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PHPicker
        
        init(_ parent: PHPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            let group = DispatchGroup()
            var images: [UIImage] = []
            
            for result in results {
                group.enter()
                
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                        defer { group.leave() }
                        
                        if let image = image as? UIImage {
                            images.append(image)
                        }
                    }
                } else {
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.parent.selectedImages.append(contentsOf: images)
                self.parent.onComplete()
            }
        }
    }
}
