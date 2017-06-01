//
//  addCommentViewController.swift
//  Burp
//
//  Created by Yichao Wang on 5/31/17.
//  Copyright © 2017 Yang Wang. All rights reserved.
//

import UIKit

class addCommentViewController: UIViewController {

    
    
    @IBOutlet weak var ratingText: UITextField!
    @IBOutlet weak var reviewText: UITextView!
    @IBOutlet weak var titleText: UITextField!
    
    
    @IBAction func submitPressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "commentTableViewController") as! commentTableViewController
        vc.titleText = titleText.text!
        vc.rating = ratingText.text!
        vc.review = reviewText.text!
        self.navigationController?.pushViewController(vc, animated: true)


    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
