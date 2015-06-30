//
//  RankingTableViewCell.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 30/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit

class RankingTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userDrinked: UILabel!
    @IBOutlet weak var userPosition: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
