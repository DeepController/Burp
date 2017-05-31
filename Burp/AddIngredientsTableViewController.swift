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
	@IBOutlet weak var search: UISearchBar!
	
	// MARK: - Fields
	let cellReuseIdentifier = "IngredientCell"
	var ingDataCollection = [ingData]()
	var cacheImageURL : URL? = nil
	var resultSearchController = UISearchController()
	
	//
	// MARK: - View Control
	//
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
		tableView.delegate = self
		tableView.dataSource = self
		search.delegate = self
		cacheImageURL = try! FileManager().url(for: .cachesDirectory,
		                                  in: .userDomainMask,
		                                  appropriateFor: nil,
		                                  create: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
				print("error=\(String(describing: error))")
				return
			}
			
			if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
				// check for http errors
				print("statusCode should be 200, but is \(httpStatus.statusCode)")
				print("response = \(String(describing: response))")
			}
			
			let JSONobject = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
			let ingList = JSONobject as? [Any]
			self.ingDataCollection.removeAll(keepingCapacity: false)
			for ing in ingList! {
				let ingObject = ingData(json: ing as! [String:Any])!
//				self.downloadIngredientImage(ofName: ingObject.picName)
				self.ingDataCollection.append(ingObject)
			}
			OperationQueue.main.addOperation {
				self.tableView.reloadData()
			}
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
//				let cacheDirect = NSHomeDirectory() + "/Library/Caches"
//				var isDir : ObjCBool = true
				let fileManager = FileManager.default
//				print("tmp file exist? \(fileManager.fileExists(atPath: locationPath))")
//				print("cache directory exist? \(fileManager.fileExists(atPath: cacheDirect, isDirectory: &isDir))")
//				print("cache file exist? \(fileManager.fileExists(atPath: cache))")
				do {
					try fileManager.moveItem(atPath: locationPath, toPath: cache)
				} catch CocoaError.fileWriteFileExists {
//					if (FileManager.default.fileExists(atPath: cache)) {
//						try! fileManager.removeItem(atPath: cache)
//						try! fileManager.moveItem(atPath: locationPath, toPath: cache)
//					}
				} catch let error as NSError {
					print("Error: \(error.domain)")
				}
				DispatchQueue.main.async {
					cell.imageView?.image = UIImage(contentsOfFile: cache)
					cell.setNeedsLayout() //invalidate current layout
					cell.layoutIfNeeded() //update immediately
				}
			} else {
				print("Fail to download cache image")
			}
		}
		task.resume()
	}
	
	//
	// MARK: - Search Bar Configuration
	//
	
	override func touchesBegan(_ touches:Set<UITouch>, with event:UIEvent?) {
//		search.resignFirstResponder()
	}
	
	func searchBarSearchButtonClicked(_ searchBar : UISearchBar) {
		let isEmpty = searchBar.text?.range(of: "^[ /s]*$", options: .regularExpression, range: nil, locale: nil) != nil

		if !isEmpty {
//			print("searching")
			searchIngredient(ofName: searchBar.text!)
			search.resignFirstResponder()
		} else {
//			print("poping alert")
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
		cell.imageView?.image = nil
		downloadIngredientImage(ofName: currentIngredientData.picName, cell: cell)
//		let fileURL = cacheImageURL.appendingPathComponent(currentIngredientData.picName)
//		cell.imageView?.image = UIImage(data: try! Data(contentsOf: fileURL))
		
		return cell
	}
	
	/*
	func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 0
	}
	*/


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
