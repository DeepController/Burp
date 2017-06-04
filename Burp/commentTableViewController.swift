//
//  commentTableViewController.swift
//  Burp
//
//  Created by Yichao Wang on 5/30/17.
//  Copyright © 2017 Yang Wang. All rights reserved.
//

import UIKit

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

class commentTableViewController: UITableViewController {

    var recipeId = 1234
    var name = "testname"
  //  var titleText = ""
    var rating = ""
    var review = ""
    var imageView = UIImage()
    
    var commentSet = [comment]()
    
    struct comment {
        var title : String
        var review : String
        var rating : String
        var photo : String
    }
    
    func imgUpload() {
    
     /*   let request = NSMutableURLRequest(url: NSURL(string: "http://students.washington.edu/wangyic/burp/uploadImg.php")! as URL)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if (imageView == nil) {return}
        request.httpBody = createBody(parameters: [:],
                        boundary: boundary,
                        data: UIImageJPEGRepresentation(imageView, 1)!,
                        mimeType: "image/jpg",
                        filename: "hello.jpg")

        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            print(1234)
            if error != nil {
                print("error=\(error)")
                return
            }
            //print("responseString = \(responseString)")
        }
        task.resume()*/
/*        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            print(1234)
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                print("error")
                return
            }

            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)

            print(dataString)            
        }
        task.resume()*/
    }
    func createBody(parameters: [String: String],
                boundary: String,
                data: Data,
                mimeType: String,
                filename: String) -> Data {
        let body = NSMutableData()

        let boundaryPrefix = "--\(boundary)\r\n"

        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }

        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))

        return body as Data
    }
    


    func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }

    func phpRequest() {
        let request = NSMutableURLRequest(url: NSURL(string: "http://students.washington.edu/wangyic/burp/addComment.php")! as URL)
        request.httpMethod = "POST"


        let postString = "recipeId=\(recipeId)&name=\(name)&rating=\(rating)&content=\(review)"
        request.httpBody = postString.data(using: String.Encoding.utf8)

        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            if error != nil {
                print("error=\(error)")
                return
            }
            
           // let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [Dictionary<String, AnyObject>]
            for item in json! {
                self.commentSet.append(comment(title: item["name"] as! String, review: item["content"] as! String, rating: item["rating"] as! String, photo: item["image"] as! String))
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            //print("responseString = \(responseString)")
        }
        task.resume()
    
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
                if (imageView != nil) {
            imgUpload();
        }
        phpRequest();
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.navigationBar.isHidden = false

	}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return commentSet.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! commentTableViewCell
       /* cell.title.text = titleText
        cell.rating.text = "Rating: \(rating)"
        cell.review.lineBreakMode = .byWordWrapping
        cell.review.numberOfLines = 0
        cell.review.text = review
        cell.commentImage.image = imageView*/
        
        cell.title.text = commentSet[indexPath.row].title
        cell.rating.text = "Rating: \(commentSet[indexPath.row].rating)"
        cell.review.lineBreakMode = .byWordWrapping
        cell.review.numberOfLines = 0
        cell.review.text = commentSet[indexPath.row].review
      //  cell.commentImage.image = imageView
        
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        //cell.textLabel!.text = commentSet[indexPath.row].title
        //cell.detailTextLabel!.text = commentSet[indexPath.row].review
        
        // Configure the cell...

        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
