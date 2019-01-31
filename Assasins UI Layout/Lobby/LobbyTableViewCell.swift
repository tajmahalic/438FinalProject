//
//  LobbyTableViewCell.swift
//  Assasins UI Layout
//
//  Created by Eliot Tong on 11/25/18.
//  Copyright © 2018 CSE438. All rights reserved.
//

import UIKit

class LobbyTableViewCell: UITableViewCell {

    @IBOutlet weak var sessionNameText: UILabel!
    @IBOutlet weak var numPlayersText: UILabel!
    @IBOutlet weak var capacityText: UILabel!
    @IBOutlet weak var sessionTypeText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
