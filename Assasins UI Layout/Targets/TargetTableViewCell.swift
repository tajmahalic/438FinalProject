//
//  TargetTableViewCell.swift
//  Assasins UI Layout
//
//  Created by Eliot Tong on 11/20/18.
//  Copyright © 2018 CSE438. All rights reserved.
//

import UIKit

protocol TargetTableViewCellDelegate {
    func didTapTrack(_ sender: TargetTableViewCell)
}

class TargetTableViewCell: UITableViewCell {

    @IBOutlet weak var targetImage: UIImageView!
    @IBOutlet weak var sessionText: UILabel!
    @IBOutlet weak var targetNameText: UILabel!
    @IBOutlet weak var timeRemainingText: UILabel!
    @IBOutlet weak var trackButton: UIButton!
    
    
    var delegate:TargetTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func actionTrack(_ sender: UIButton) {
        delegate?.didTapTrack(self)
    }
}
