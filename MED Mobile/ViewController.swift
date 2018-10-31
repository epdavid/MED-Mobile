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
    let medHome = "https://quod.lib.umich.edu/m/middle-english-dictionary/dictionary"
    var defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    let searchOptions = ["Headword (with alternate spellings)",
                         "Headword (preferred spelling only)",
                         "Entire Entry",
                         "Definition and Notes", "Etymology",
                         "Associated quotes and Manuscripts",
                         "Modern English word Equivalent"]
    let searchOptionCodes = ["hnf",
                             "h",
                             "anywhere",
                             "notes_and_def",
                             "etyma",
                             "citation",
                             "oed"]
    
    @IBOutlet weak var searchOptionsPickerField: UITextField!
    @IBOutlet weak var resultsView: UITableView!
    @IBOutlet weak var query: UISearchBar!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = resultsView.indexPathForSelectedRow
        let result = searchResults[(indexPath?.row)!]
        let destVC = segue.destination as! DefViewController
        
        destVC.href = result.getHref()

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")!
        let text = searchResults[indexPath.row].getSearchString()
        let definition = searchResults[indexPath.row].getDef()
        
        cell.textLabel?.text = text
        cell.detailTextLabel?.text = definition
        
        return cell
    }
    

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
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        if let searchText = query.text {
            let option = searchOptionCodes[searchOptions.index(of: searchOptionsPickerField.text!) ?? 0]
            if searchResults.count > 0 {
                searchResults = []
            }
            getSearchResults(searchTerm: searchText, searchOption: option)
        }
    }
    
    func getSearchResults(searchTerm: String, searchOption:String) {
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: medHome) {
            urlComponents.query = "utf8=✓&search_field=\(searchOption)&q=\(searchTerm)" 
            
            guard let url = urlComponents.url else {print("err"); return}
            
            dataTask = defaultSession.dataTask(with: url) {data, response, error in
                defer { self.dataTask = nil }
                
                if let error = error {
                    print("DataTaskError: " + error.localizedDescription + "\n")
                    let errorEntry = EntrySearchResult(headword: "Error: No Internet Connection", pos: "", href: "#", def: "", counter: "!!")
                    self.searchResults.append(errorEntry)
                    DispatchQueue.main.async {
                        self.resultsView.reloadData()
                        self.resultsView.isUserInteractionEnabled = false
                    }
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
                let def:String = try e.child(1)
                    .select("div.definition-block")
                    .select("div.definition").first()?.text() ?? "No definition preview available"
                
                let entry = EntrySearchResult(headword: headword, pos: pos, href: href, def: def, counter: counter)
                
                searchResults.append(entry)
            }
        } catch {print("errr")}
        updateView()
    }
    
    func updateView() {
        DispatchQueue.main.async {
            if (!self.resultsView.isUserInteractionEnabled) {
                self.resultsView.isUserInteractionEnabled = true
            }
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
