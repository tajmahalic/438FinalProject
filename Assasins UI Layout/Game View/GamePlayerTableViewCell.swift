//
//  PlayerTableViewCell.swift
//  Assasins UI Layout
//
//  Created by Eliot Tong on 12/1/18.
//  Copyright © 2018 CSE438. All rights reserved.
//

import UIKit

class GamePlayerTableViewCell: UITableViewCell {

    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var statusText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameText.layer.borderWidth = 0.5
        statusText.layer.borderWidth = 0.5
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
