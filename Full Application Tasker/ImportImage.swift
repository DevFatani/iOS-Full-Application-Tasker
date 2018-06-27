//
//  ImportImage.swift
//  Full Application Tasker
//
//  Created by Muhammad Fatani on 25/06/2018.
//  Copyright © 2018 Muhammad Fatani. All rights reserved.
//
import UIKit
import Foundation
class ImportImage: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblPath: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func onGalleryClick(_ sender: UIButton) {
        importImageFrom(sourceType: .photoLibrary)
    }
    @IBAction func onCameraClick(_ sender: UIButton) {
        importImageFrom(sourceType: .camera)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        let path = self.generateImageUrl(fileName: "\(UUID.init().uuidString).jpg");
        self.lblPath.text = path.absoluteString
        Logger.normal(tag: "ImportImage", message: path)
        self.dismiss(animated: true, completion: nil)
    }
    
    func importImageFrom(sourceType type: UIImagePickerControllerSourceType){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
//        picker.mediaTypes = ["public.movie", "public.image"]
        picker.sourceType = type
        self.present(picker, animated: true, completion: nil)
        
    }
    
    func generateImageUrl(fileName: String)-> URL{
        let fileURL = FileUnit.getTempPath(fileName: fileName)
        let data = UIImageJPEGRepresentation(self.imageView.image!, 0.3)
        do {
            try data?.write(to:fileURL as URL)
        } catch let error{
                print(error)
        }
        return fileURL
    }
}
