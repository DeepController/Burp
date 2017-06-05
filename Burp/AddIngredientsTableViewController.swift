//
//  AddIngredientsTableViewController.swift
//  Burp
//
//  Created by William on 5/29/17.
//  Copyright © 2017 Yang Wang. All rights reserved.
//

import UIKit

class AddIngredientsTableViewController: ViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

	// MARK: - UIElements
	@IBOutlet var tableView: UITableView!
	
	// MARK: - Fields
	let cellReuseIdentifier = "IngredientCell"
	var ingDataCollection = [ingData]()
	var cacheImageURL : URL? = nil
	var searchController = UISearchController()
	var username : String = UserDefaults.standard.string(forKey: defaultsKeys.username)!
	let searching = ProgressHUD(text: "Searching")
//	var uploaded = false
	
	
	//
	// MARK: - View Control
	//
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		configureSearchController()
		searchController.isActive = true
		searchController.searchBar.becomeFirstResponder()
		cacheImageURL = try! FileManager().url(for: .cachesDirectory,
		                                       in: .userDomainMask,
		                                       appropriateFor: nil,
		                                       create: true)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	@IBAction func donePressed(_ sender: UIBarButtonItem) {
		self.navigationController?.dismiss(animated: true, completion: nil)
	}
	
	
	//
	// MARK: - Retrieve Data
	//
	
	fileprivate func searchIngredient(ofName name : String) {
		let query = name.replacingOccurrences(of: " ", with: "+")
		var request = URLRequest(url: URL(string: "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/food/ingredients/autocomplete?metaInformation=false&number=10&query=\(query)")!)
		request.httpMethod = "GET"
		request.addValue("vxPA0uhUCXmshjiEBrQ1Dgu6pP2dp126FVcjsngqOvVZln3jt9", forHTTPHeaderField: "X-Mashape-Key")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
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
				print("error=\(String(describing: error))")
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
				print("statusCode should be 200, but is \(httpStatus.statusCode)")
				print("response = \(String(describing: response))")
			}
			
			let JSONobject = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
			let ingList = JSONobject as? [Any]
			self.ingDataCollection.removeAll(keepingCapacity: false)
			for ing in ingList! {
				let ingObject = ingData(json: ing as! [String:Any])!
				//self.downloadIngredientImage(ofName: ingObject.picName)
				self.ingDataCollection.append(ingObject)
			}
			self.checkAddedIngredients(json: String(data: data, encoding: .utf8)!)
		}
		task.resume()
	}
	
	fileprivate func downloadIngredientImage(ofName name : String, cell : IngredientsCell) {
		let source = "https://spoonacular.com/cdn/ingredients_100x100/\(name)"
		let requestURL = URL(string: source)!
		let sessionConfig = URLSessionConfiguration.default
		let session = URLSession(configuration: sessionConfig)
		let request = URLRequest(url: requestURL)
		
		let task = session.downloadTask(with: request) { (location, response, error) in
			if let location = location, error == nil {
				let locationPath = location.path
				let cache = NSHomeDirectory() + "/Library/Caches/\(name)"
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
				print("Fail to download cache image")
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
	
//	func uploadImage(ImageData : Data, format : String) {
//		var b64 = ImageData.base64EncodedString()
//		b64 = b64.replacingOccurrences(of: "+", with: "%2B")
//		let query = format+","+b64
//		var request = URLRequest(url: URL(string: "https://students.washington.edu/yangw97/Burp/uploadImg.php")!)
//		request.httpMethod = "POST"
//		let postString = "id=1234&account=\(username)&data=\(query)"
//		print("The poststring : \(postString)")
//		request.httpBody = postString.data(using: .utf8)
//		let task = URLSession.shared.dataTask(with: request) { data, response, error in
//			guard let data = data, error == nil else {
//				// check for fundamental networking error
//				print("error=\(String(describing: error))")
//				return
//			}
//			
//			if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
//				// check for http errors
//				print("statusCode should be 200, but is \(httpStatus.statusCode)")
//				print("response = \(String(describing: response))")
//			}
//			let responseString = String(data: data, encoding: .utf8)!
//			print("Feedback: " + responseString)
//			print("Upload Complete")
//		}
//		task.resume()
//	}
	
	fileprivate func checkAddedIngredients(json : String) {
		var request = URLRequest(url: URL(string: "https://students.washington.edu/yangw97/Burp/ingredient.php")!)
		request.httpMethod = "POST"
		let postString = "action=check&account=\(username)&json=\(json)"
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
				print("error=\(String(describing: error))")
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
				print("statusCode should be 200, but is \(httpStatus.statusCode)")
				print("response = \(String(describing: response))")
			}
			let result = String(data: data, encoding: .utf8)!
			let arr = result.components(separatedBy: ":")
			for num in arr {
				if num != "" {
					let n : Int = Int(num)!
					self.ingDataCollection[n].added = true
				}
			}
			OperationQueue.main.addOperation {
				self.tableView.reloadData()
				self.searching.removeFromSuperview()
			}
		}
		task.resume()
	}
	
	//
	// MARK: - Search Bar Configuration
	//
	
	func configureSearchController() {
		// initialize search bar
		searchController = UISearchController(searchResultsController: nil)
		searchController.dimsBackgroundDuringPresentation = true
		searchController.searchBar.placeholder = "Search For Ingredient You Have"
		searchController.searchBar.delegate = self
		searchController.searchBar.sizeToFit()
		
		// put search bar at the top of the table view
		tableView.tableHeaderView = searchController.searchBar
	}
	
	func searchBarSearchButtonClicked(_ searchBar : UISearchBar) {
		let isEmpty = searchBar.text?.range(of: "^[ /s]*$", options: .regularExpression, range: nil, locale: nil) != nil
		
		if !isEmpty {
			searchIngredient(ofName: searchBar.text!)
			searchController.isActive = false
			self.view.addSubview(searching)
		} else {
			super.popAlert(content: "Please enter non-empty query!")
		}
	}
	
	//
	// MARK: - Table view Configuration
	//
	
	// number of rows in table view
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return ingDataCollection.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		// create a new cell if needed or reuse an old one
		let cell:IngredientsCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! IngredientsCell
		
		// Configure the cell...
		let currentIngredientData = ingDataCollection[indexPath.row]
		cell.name.text = currentIngredientData.name
		cell.username = username
		cell.picname = currentIngredientData.picName
		// Deal with image, if image cached, no download
		let imagePath = NSHomeDirectory() + "/Library/Caches/\(currentIngredientData.picName)"
//		if !uploaded {
//			uploaded = true
//			let format = currentIngredientData.picName.components(separatedBy: ".")[1]
//			let imageData = try! Data(contentsOf: URL(fileURLWithPath: imagePath))
//			self.uploadImage(ImageData: imageData, format: format)
//		}
		if FileManager.default.fileExists(atPath: imagePath) {
			cell.pic.image = UIImage(contentsOfFile: imagePath)
		} else {
			cell.pic.image = nil
			downloadIngredientImage(ofName: currentIngredientData.picName, cell: cell)
		}
		if currentIngredientData.added {
			cell.addButton.setTitle("Remove", for: .normal)
			cell.addButton.setTitleColor(UIColor.red, for: .normal)
		} else {
			cell.addButton.setTitle("Add", for: .normal)
			cell.addButton.setTitleColor(UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1), for: .normal)
		}
		
		return cell
	}
}
