//
//  ViewController.swift
//  MED Mobile
//
//  Created by Evan David on 10/19/18.
//  Copyright © 2018 Evan David. All rights reserved.
//

import UIKit
import Foundation
import SwiftSoup

class ViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {
    var searchResults:[EntrySearchResult] = []
    var searchResultsStrings:[String] = []
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultsStrings.count
    }

    
    @IBOutlet weak var searchOptionsPickerField: UITextField!
    let searchOptions = ["Headword (with alternate spellings)",
                         "Entire Entry",
                         "Headword (preferred spelling only)",
                         "Definition and Notes", "Etymology",
                         "Associated quotes and Manuscripts",
                         "Modern English word Equivalent"]
    let searchOptionCodes = ["hnf",
                             "anywhere",
                             "h",
                             "notes_and_def",
                             "etyma",
                             "citation",
                             "oed"]
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")!
        let text = searchResultsStrings[indexPath.row]
        
        cell.textLabel?.text = text
        
        return cell
    }
    
    
    let medHome = "https://quod.lib.umich.edu/m/middle-english-dictionary/dictionary"
    var defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        resultsView.dataSource = self
        query.delegate = self
        searchOptionsPickerField.loadDropdownData(data: searchOptions)
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        query.autocapitalizationType = .none
    }
     
    @IBOutlet weak var resultsView: UITableView!
    @IBOutlet weak var query: UISearchBar!
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        if let searchText = query.text {
            let option = searchOptionCodes[searchOptions.index(of: searchOptionsPickerField.text!) ?? 0]
            if searchResultsStrings.count > 0 {
                searchResults = []
                searchResultsStrings = []
            }
            getSearchResults(searchTerm: searchText, searchOption: option)
        }
    }
    
    func getSearchResults(searchTerm: String, searchOption:String) {
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: medHome) {
            urlComponents.query = "utf8=✓&search_field=\(searchOption)&q=\(searchTerm)" //NOTE: search_field=hnf will be modifiable later
            
            guard let url = urlComponents.url else {print("err"); return}
            
            dataTask = defaultSession.dataTask(with: url) {data, response, error in
                defer { self.dataTask = nil }
                
                if let error = error {
                    print("DataTaskError: " + error.localizedDescription + "\n")
                } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    self.handleSearchResults(html: data)
                }
            }
        }
        dataTask?.resume()
    }
    
    
    func handleSearchResults(html: Data) {
        let htmlString:String = String(data: html, encoding: String.Encoding.utf8)!
        do {
            let doc: Document = try SwiftSoup.parse(htmlString)
            let links: Elements = try doc.select("div.entry-panel")
            for e in links {
                let counter:String = try e.child(0).child(0).text()
                let headword:String = try e.child(0).child(1).text() //get h3 elem (first child)
                let pos:String = try e.child(0).child(2).text()
                let href:String = try e.child(0).child(1).attr("href")
                let entry = EntrySearchResult(headword: headword, pos: pos, href: href)
                
                let stringToAppend:String = "\(counter) \(headword), \(pos)"
                
                searchResults.append(entry)
                searchResultsStrings.append(stringToAppend)
            }
        } catch {print("errr")}
        updateView()
    }
    
    func updateView() {
        DispatchQueue.main.async {
            self.resultsView.reloadData()
        }
    }
    
    @IBAction func thornButton(_ sender: Any) {
        query.text?.append("þ")
    }
    @IBAction func ashButton(_ sender: Any) {
        query.text?.append("æ")
    }
    
    @IBAction func ethButton(_ sender: Any) {
        query.text?.append("ð")
    }
    @IBAction func yoghButton(_ sender: Any) {
        query.text?.append("ʒ")
    }
}
