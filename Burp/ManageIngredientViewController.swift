//
//  ManageIngredientViewController.swift
//  Burp
//
//  Created by Saif Mustafa on 6/5/17.
//  Copyright © 2017 Yang Wang. All rights reserved.
//

import UIKit

class ManageIngredientViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
	
	// MARK: - UIElement
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var find: UIButton!
	
	// MARK: - Fields
	
	let cellReuseIdentifier = "ManageTableCell"
	var ingDataCollection = [ingData]()
	let loading = ProgressHUD(text: "Loading")
	var username : String = UserDefaults.standard.string(forKey: defaultsKeys.username)!
	
	//MARK: - UIElement Action
	
	@IBAction func removePressed(_ sender: UIButton) {
		sender.isEnabled = false
		if let cell = sender.superview?.superview?.superview as? ManageTableCell {
			let indexPath = tableView.indexPath(for: cell)!
			ingDataCollection.remove(at: indexPath.row)
			if ingDataCollection.count == 0 {
				find.isEnabled = false
			}
			deleteIngredientOnServer(cell: cell, index: indexPath)
		}
	}
	
//	@IBAction func logout(_ sender: UIBarButtonItem) {
//		self.navigationController?.dismiss(animated: true, completion: nil)
//	}
	
	// MARK: - Retrieve Remote Data
	
	fileprivate func downloadIngredients() {
		var request = URLRequest(url: URL(string: "https://students.washington.edu/yangw97/Burp/ingredient.php")!)
		request.httpMethod = "POST"
		let postString = "action=download&account=\(username)"
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
			let JSONobject = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
			let ingList = JSONobject as? [Any]
			self.ingDataCollection.removeAll(keepingCapacity: false)
			for ing in ingList! {
				var ingObject = ingData(json: ing as! [String:Any])!
				ingObject.added = true
				self.ingDataCollection.append(ingObject)
			}
			OperationQueue.main.addOperation {
				if self.ingDataCollection.count > 0 {
					self.find.isEnabled = true
				}
				self.tableView.reloadData()
				self.loading.removeFromSuperview()
			}
		}
		task.resume()
	}
	
	fileprivate func downloadIngredientImage(ofName name : String, cell : ManageTableCell) {
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
	
	func deleteIngredientOnServer(cell: ManageTableCell, index: IndexPath) {
		var request = URLRequest(url: URL(string: "https://students.washington.edu/yangw97/Burp/ingredient.php")!)
		request.httpMethod = "POST"
		let postString = "action=delete&account=\(username)&ingredient_name=\(cell.name.text!)"
		request.httpBody = postString.data(using: .utf8)
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			guard let _ = data, error == nil else {
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
				OperationQueue.main.addOperation {
					let alert = UIAlertController.init(title: "Error!", message: "Network Error", preferredStyle: .alert)
					let action = UIAlertAction.init(title: "Retry", style: .default, handler: {(alert: UIAlertAction!) in
						self.viewDidLoad()})
					alert.addAction(action)
					self.present(alert, animated: true, completion: nil)
				}
			}
			OperationQueue.main.addOperation {
				print("deleted")
				self.tableView.deleteRows(at: [index], with: .automatic)
			}
		}
		task.resume()
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
		let cell:ManageTableCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ManageTableCell
		
		// Configure the cell...
		let currentIngredientData = ingDataCollection[indexPath.row]
		cell.name.text = currentIngredientData.name
		cell.username = username
		cell.picname = currentIngredientData.picName
		cell.addButton.isEnabled = true
		// Deal with image, if image cached, no download
		let imagePath = NSHomeDirectory() + "/Library/Caches/\(currentIngredientData.picName)"
		if FileManager.default.fileExists(atPath: imagePath) {
			cell.pic.image = UIImage(contentsOfFile: imagePath)
		} else {
			cell.pic.image = nil
			downloadIngredientImage(ofName: currentIngredientData.picName, cell: cell)
		}
		
		return cell
	}
	
	// MARK: - View Control
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
//		self.viewDidLoad()
		self.view.addSubview(loading)
		downloadIngredients()
	}
    
    func addNavBarImage(){
        
        let navController = navigationController!;
        
        let image = #imageLiteral(resourceName: "logo");
        let imageView = UIImageView(image: image);
        
        let bannerWidth = navController.navigationBar.frame.size.width;
        let bannerHeight = navController.navigationBar.frame.size.height;
        
        let bannerX = bannerWidth / 2 - image.size.width / 2;
        let bannerY = bannerHeight / 2 - image.size.height / 2;
        
        imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight);
        imageView.contentMode = .scaleAspectFit;
        
        navigationItem.titleView = imageView;
        
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
//		downloadIngredients()
        addNavBarImage();
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "manageToRecipe" {
			var list : String = ingDataCollection[0].name.replacingOccurrences(of: " ", with: "+")
			if ingDataCollection.count > 1 {
				for i in 1..<ingDataCollection.count {
					list.append("%2C\(ingDataCollection[i].name.replacingOccurrences(of: " ", with: "+"))")
				}
			}
			let dest = segue.destination as! RecipeTableViewController
			dest.ingList = list
		}
	}
}
