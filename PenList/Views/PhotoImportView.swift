//
//  PhotoImportView.swift
//  PenList
//
//  Created by Garry Eves on 12/4/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import Foundation
import SwiftUI

class selectedImageClass: ObservableObject {
    @Published var image: Image? = nil
}

struct CaptureImageView {
    @Binding var isShown: Bool
    @Binding var image: UIImage?
//    @Binding var image: Image?
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(isShown: $isShown, image: $image)
  }
}

extension CaptureImageView: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<CaptureImageView>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<CaptureImageView>) {
        
    }
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  @Binding var isCoordinatorShown: Bool
  @Binding var imageInCoordinator: UIImage?
//@Binding var imageInCoordinator: Image?
  init(isShown: Binding<Bool>, image: Binding<UIImage?>) {
 //   init(isShown: Binding<Bool>, image: Binding<Image?>) {
    _isCoordinatorShown = isShown
    _imageInCoordinator = image
  }
  func imagePickerController(_ picker: UIImagePickerController,
                didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
     guard let unwrapImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
     imageInCoordinator = unwrapImage
//     imageInCoordinator = Image(uiImage: unwrapImage)
     isCoordinatorShown = false
  }
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
     isCoordinatorShown = false
  }
}

//struct imagePicker: View {
//    @Binding var tempPhoto: UIImage?
// //   @Binding var tempPhoto: Image?
//    @Binding var showChild: Bool
//    
//    @State var showCaptureImageView: Bool = true
//    
//    var body: some View {
//        return VStack {
//            HStack {
//                Spacer()
//                Text("Select Photo")
//                    .font(.title)
//                Spacer()
//                
//                Button("Close") {
//                    self.showChild = false
//                }
//            }
//            .padding(.bottom, 10)
//            .padding(.leading, 20)
//            .padding(.trailing, 20)
//            .padding(.top, 15)
//            
//            ZStack {
//                VStack {
//                    tempPhoto?.resizable()
//                        .frame(width: 250, height: 250)
//                        .shadow(radius: 10)
//                        }
//                if (showCaptureImageView) {
//                    CaptureImageView(isShown: $showCaptureImageView, image: $tempPhoto)
//                }
//            }
//        }
//    }
//}
