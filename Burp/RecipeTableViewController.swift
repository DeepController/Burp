//
//  RecipeTableViewController.swift
//  Burp
//
//  Created by William on 6/3/17.
//  Copyright © 2017 Yang Wang. All rights reserved.
//

import UIKit

class RecipeTableViewController: UITableViewController {
	
	let cellReuseIdentifier = "recipeCell"
	var ingList : String = ""
	var recDataCollection : [recData] = []
	let searching = ProgressHUD(text: "Searching")
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.delegate = self
		tableView.dataSource = self
		self.view.addSubview(searching)
		searchRecipe()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Retreive Data
	fileprivate func searchRecipe() {
		var request = URLRequest(url: URL(string: "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/searchComplex?addRecipeInformation=false&fillIngredients=false&includeIngredients=\(self.ingList)&instructionsRequired=true&limitLicense=false&number=10&offset=0&query=&ranking=2")!)
		request.httpMethod = "GET"
		request.addValue("vxPA0uhUCXmshjiEBrQ1Dgu6pP2dp126FVcjsngqOvVZln3jt9", forHTTPHeaderField: "X-Mashape-Key")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			guard let data = data, error == nil else {
				// check for fundamental networking error
				print("error=\(String(describing: error))")
				return
			}
			
			if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
				// check for http errors
				print("statusCode should be 200, but is \(httpStatus.statusCode)")
				print("response = \(String(describing: response))")
			}
			
			let JSONobject = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
			let recList = JSONobject as? [String : Any]
			let recResults = recList?["results"] as! [[String : Any]]
			self.recDataCollection.removeAll(keepingCapacity: false)
			for rec in recResults {
				let recObject = recData(json: rec)!
				if !recObject.miss {
					self.recDataCollection.append(recObject)
				}
			}
			if self.recDataCollection.count <= 0 {
				OperationQueue.main.addOperation {
					let alert = UIAlertController.init(title: "No recipe found!", message: "Please add more ingredients and try again!", preferredStyle: .alert)
					let action = UIAlertAction.init(title: "Go to Manage", style: .default, handler: {(alert: UIAlertAction!) in self.navigationController?.popViewController(animated: true)})
					alert.addAction(action)
					self.present(alert, animated: true, completion: nil)
				}
			} else {
				OperationQueue.main.addOperation {
					self.searching.removeFromSuperview()
					self.tableView.reloadData()
				}
			}
		}
		task.resume()
	}
	
	fileprivate func downloadRecipeImage(source: String, cell : RecipeCell) {
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
				print("Fail to download recipe image")
			}
		}
		task.resume()
	}
	
	// MARK: - Table view data source
	
	//    override func numberOfSections(in tableView: UITableView) -> Int {
	//        // #warning Incomplete implementation, return the number of sections
	//        return 0
	//    }
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return recDataCollection.count
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell : RecipeCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! RecipeCell
		
		let currentRecipeData = recDataCollection[indexPath.row]
		cell.name.text = currentRecipeData.name
		cell.picName = currentRecipeData.picURL.components(separatedBy: "/").last!
		// Deal with image, if image cached, no download
		let imagePath = NSHomeDirectory() + "/Library/Caches/\(cell.picName)"
		if FileManager.default.fileExists(atPath: imagePath) {
			cell.pic.image = UIImage(contentsOfFile: imagePath)
		} else {
			cell.pic.image = nil
			downloadRecipeImage(source: currentRecipeData.picURL, cell: cell)
		}
		
		return cell
	}
	
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "recipeToDetail" {
			let dest = segue.destination as! RecipeDetailViewController
			dest.id = recDataCollection[(self.tableView.indexPath(for: (sender as! RecipeCell))?.row)!].id.description
		}
	}
	
	
}
