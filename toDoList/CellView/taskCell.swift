//
//  taskCell.swift
//  toDoList
//
//  Created by Mohamed Sobhi  Fouda on 2/15/18.
//  Copyright © 2018 Mohamed Sobhi Fouda. All rights reserved.
//

import UIKit

class taskCell: UITableViewCell {

    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var titleTask: UILabel!
    @IBOutlet weak var imageTask: UIImageView!
    @IBOutlet weak var statusTask: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
