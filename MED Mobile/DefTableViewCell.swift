//
//  DefTableViewCell.swift
//  MED Mobile
//
//  Created by Evan David on 10/30/18.
//  Copyright © 2018 Evan David. All rights reserved.
//

import UIKit

class DefTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var definition: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
