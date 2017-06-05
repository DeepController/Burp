//
//  commentTableViewController.swift
//  Burp
//
//  Created by William on 6/5/17.
//  Copyright © 2017 Yang Wang. All rights reserved.
//

import UIKit

class commentTableViewController: UITableViewController {

	// MARK: - UIElement
	
	
	// MARK: - Fields
	var id : String = ""
	var username : String = UserDefaults.standard.string(forKey: defaultsKeys.username)!
	var commentDataCollection : [commentData] = []
	let loading = ProgressHUD(text: "Loading")
	
	// MARK: - View Control
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.viewDidLoad()
		downloadComments()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.addSubview(loading)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: - Retrieve Data
	
	func downloadComments() {
		var request = URLRequest(url: URL(string: "https://students.washington.edu/yangw97/Burp/getComment.php")!)
		request.httpMethod = "POST"
		let postString = "id=\(id)"
		request.httpBody = postString.data(using: .utf8)
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			guard let data = data, error == nil else {
				// check for fundamental networking error
				OperationQueue.main.addOperation {
					let alert = UIAlertController.init(title: "Error!", message: "Network Error", preferredStyle: .alert)
					let action = UIAlertAction.init(title: "Retry", style: .default, handler: {(alert: UIAlertAction!) in
						self.viewDidLoad()})
					alert.addAction(action)
					self.present(alert, animated: true, completion: nil)
				}
				return
			}
			
			if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
				// check for http errors
				OperationQueue.main.addOperation {
					let alert = UIAlertController.init(title: "Error!", message: "Network Error", preferredStyle: .alert)
					let action = UIAlertAction.init(title: "Retry", style: .default, handler: {(alert: UIAlertAction!) in
						self.viewDidLoad()})
					alert.addAction(action)
					self.present(alert, animated: true, completion: nil)
				}
			}
			let responseString = String(data: data, encoding: .utf8)!
			print("Feedback: " + responseString)
			if !responseString.contains("Nothing") {
				let JSONobject = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
				let commentList = JSONobject as? [[String : Any]]
				self.commentDataCollection.removeAll(keepingCapacity: false)
				for comment in commentList! {
					let commentObject = commentData(json: comment)!
					self.commentDataCollection.append(commentObject)
				}
			}
			OperationQueue.main.addOperation {
				self.tableView.reloadData()
				self.loading.removeFromSuperview()
			}
		}
		task.resume()
	}
	
	func downloadCommentImage(source : String, cell : commentTableViewCell) {
		let requestURL = URL(string: source)!
		let sessionConfig = URLSessionConfiguration.default
		let session = URLSession(configuration: sessionConfig)
		let request = URLRequest(url: requestURL)
		
		let task = session.downloadTask(with: request) { (location, response, error) in
			if let location = location, error == nil {
				let locationPath = location.path
				let cache = NSHomeDirectory() + "/Library/Caches/\(cell.picName)"
				let fileManager = FileManager.default
				
				do {
					try fileManager.moveItem(atPath: locationPath, toPath: cache)
				} catch CocoaError.fileWriteFileExists {
				} catch let error as NSError {
					print("Error: \(error.domain)")
				}
				DispatchQueue.main.async {
					cell.pic.image = UIImage(contentsOfFile: cache)
				}
			} else {
				OperationQueue.main.addOperation {
					let alert = UIAlertController.init(title: "Error!", message: "Network Error", preferredStyle: .alert)
					let action = UIAlertAction.init(title: "Retry", style: .default, handler: {(alert: UIAlertAction!) in
						self.viewDidLoad()})
					alert.addAction(action)
					self.present(alert, animated: true, completion: nil)
				}
			}
		}
		task.resume()
	}


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return commentDataCollection.count
    }

	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! commentTableViewCell

        // Configure the cell...
		let currentCommentData = commentDataCollection[indexPath.row]
		cell.name.text = currentCommentData.name
		cell.review.text = currentCommentData.content
		cell.rating.text = "Rating: " + currentCommentData.rating
		cell.picName = currentCommentData.picName.components(separatedBy: "/").last!
		// Deal with image, if image cached, no download
		let imagePath = NSHomeDirectory() + "/Library/Caches/\(cell.picName)"
		if FileManager.default.fileExists(atPath: imagePath) {
			cell.pic.image = UIImage(contentsOfFile: imagePath)
		} else {
			cell.pic.image = nil
			downloadCommentImage(source: currentCommentData.picName, cell: cell)
		}

        return cell
	}
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "commentToAdd" {
			let destNav = segue.destination as! UINavigationController
			let dest = destNav.topViewController as! addCommentViewController
			dest.id = id
		}
	}
}
