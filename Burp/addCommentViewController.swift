//
//  addCommentViewController.swift
//  Burp
//
//  Created by Yichao Wang on 5/31/17.
//  Copyright © 2017 Yang Wang. All rights reserved.
//

import UIKit

class addCommentViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var ratingText: UITextField!
    @IBOutlet weak var reviewText: UITextView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func addImagePressed(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "commentTableViewController") as! commentTableViewController
      //  vc.titleText = titleText.text!
        vc.rating = ratingText.text!
        vc.review = reviewText.text!
        if (imageView.image != nil) {
            vc.imageView = imageView.image!
        }
        self.navigationController?.pushViewController(vc, animated: true)


    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
     
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        } else {
            print("Something went wrong")
        }
     
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
