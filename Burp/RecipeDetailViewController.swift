//
//  RecipeDetailViewController.swift
//  Burp
//
//  Created by William on 5/23/17.
//  Copyright © 2017 Yang Wang. All rights reserved.
//

import UIKit

class RecipeDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	// MARK: - UIElements
	@IBOutlet weak var titleImage: UIImageView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var name: UILabel!
	
	
	// MARK: - Fields
	let cellReuseIdentifier = "stepDetailCell"
	var id = ""
	var pic = ""
	let loading = ProgressHUD(text: "Loading")
	var stepDataCollection : [stepData] = []
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 100
		self.view.addSubview(loading)
		getRecipe()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	// MARK: - Table View Config
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return stepDataCollection.count == 0 ? 0 : 1
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return stepDataCollection.count
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Step \(section + 1)"
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell : stepCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! stepCell
		
		cell.content.text = stepDataCollection[indexPath.section].content
		
		return cell
	}
	
	// MARK: - Retrive Data
	func getRecipe() {
		var request = URLRequest(url: URL(string: "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/\(self.id)/information?includeNutrition=false")!)
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
			let recipeInfo = JSONobject as? [String : Any]
			self.pic = recipeInfo!["image"] as! String
			self.downloadRecipeImage()
			OperationQueue.main.addOperation {
				self.name.text = (recipeInfo!["title"] as! String)
				print(self.name.text!)
			}
			let instructions = recipeInfo?["analyzedInstructions"] as! [[String : Any]]
			let steps = instructions[0]["steps"] as! [[String : Any]]
			self.stepDataCollection.removeAll(keepingCapacity: false)
			for step in steps {
				self.stepDataCollection.append(stepData(json: step)!)
			}
			OperationQueue.main.addOperation {
				self.loading.removeFromSuperview()
				self.tableView.reloadData()
			}
		}
		task.resume()
	}
	
	func downloadRecipeImage() {
		let requestURL = URL(string: self.pic)!
		let sessionConfig = URLSessionConfiguration.default
		let session = URLSession(configuration: sessionConfig)
		let request = URLRequest(url: requestURL)
		
		let task = session.downloadTask(with: request) { (location, response, error) in
			if let location = location, error == nil {
				let locationPath = location.path
				let cache = NSHomeDirectory() + "/Library/Caches/\(self.id + self.pic.components(separatedBy: ".").last!)"
				let fileManager = FileManager.default
				
				do {
					try fileManager.moveItem(atPath: locationPath, toPath: cache)
				} catch CocoaError.fileWriteFileExists {
				} catch let error as NSError {
					print("Error: \(error.domain)")
				}
				DispatchQueue.main.async {
					self.titleImage.image = UIImage(contentsOfFile: cache)
				}
			} else {
				OperationQueue.main.addOperation {
					let alert = UIAlertController.init(title: "Error!", message: "Network Error", preferredStyle: .alert)
					let action = UIAlertAction.init(title: "Retry", style: .default, handler: {(alert: UIAlertAction!) in
						self.viewDidLoad()})
					alert.addAction(action)
					self.present(alert, animated: true, completion: nil)
				}
				print("Fail to download recipe image")
			}
		}
		task.resume()
	}
	

	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "detailToComment" {
			let dest = segue.destination as! commentTableViewController
			dest.id = id
		}
    }
	
}
