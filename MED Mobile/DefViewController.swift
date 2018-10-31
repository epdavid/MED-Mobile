//
//  DefViewController.swift
//  MED Mobile
//
//  Created by Evan David on 10/22/18.
//  Copyright © 2018 Evan David. All rights reserved.
//

import UIKit
import SwiftSoup

struct Definition {
    var number:String
    var definition:String
}

class DefViewController: UIViewController, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return definitions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defCellReuseIdentifier")! as! DefTableViewCell
        let num = definitions[indexPath.row].number
        let def = definitions[indexPath.row].definition
        
        cell.number?.text = num
        cell.definition?.text = def
        
        return cell
    }
    
    var href:String?
    var definitions:[Definition] = []
    var dataTask: URLSessionDataTask?
    var defaultSession = URLSession(configuration: .default)
    let mainUrl = "https://quod.lib.umich.edu"
    
    var entryInfo:[String] = []
    //@IBOutlet weak var etymLabel: UILabel!
    
    @IBOutlet weak var definitionsView: UITableView!
    
    @IBOutlet var labels: [UILabel]!
   // @IBOutlet weak var formLabel: UILabel!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.showLoader()
        definitionsView.dataSource = self
        definitionsView.rowHeight = UITableView.automaticDimension
        definitionsView.estimatedRowHeight = 140
        
        getWebData()
    }
    
    func updateView() {
        DispatchQueue.main.async {
            for x in stride(from: 0, to: self.labels.count, by: 1) {
                self.labels[x].text = self.entryInfo[x]
            }
            self.definitionsView.reloadData()
            self.view.hideLoader()
        }
    }
    
    func getWebData() {
        dataTask?.cancel()
        if let thisHref = href {
            let thisUrl = "\(mainUrl)\(thisHref)"
            if var urlComponents = URLComponents(string: thisUrl) {
                guard let url = urlComponents.url else {print("err"); return}
                
                dataTask = defaultSession.dataTask(with: url) {data, response, error in
                    defer { self.dataTask = nil }
                    
                    if let error = error {
                        print("DataTaskError:" + error.localizedDescription + "\n")
                    } else if let data = data,
                              let response = response as? HTTPURLResponse,
                              response.statusCode == 200 {
                        self.handleData(html: data)
                    }
                }
            }
            
        }
        dataTask?.resume()
    }
    
    func handleData(html: Data) {
        let htmlString:String = String(data: html, encoding: String.Encoding.utf8)!
        
        do {
            let doc: Document = try SwiftSoup.parse(htmlString)
            
            let entryHeadword:Element = try doc.select("div.entry-headword").first()!
            entryInfo.append(entryHeadword.ownText())
            entryInfo.append(entryHeadword.child(0).ownText())
            
            let formsAndEtym:Element = try doc.select("table.table").first()!
            try entryInfo.append(formsAndEtym.child(0).child(0).child(1).text())
            try entryInfo.append(formsAndEtym.child(0).child(1).child(1).text())
            
            let senses:Elements = try doc.select("div.senses div.sense")
            for def in senses {
                let senseNum = def.child(0).child(0).ownText()
                let sense = def.child(0).child(1).ownText()
                let definition = Definition(number: senseNum, definition: sense)
                definitions.append(definition)
            }
        } catch {print("err")}
        updateView()
    }

}
