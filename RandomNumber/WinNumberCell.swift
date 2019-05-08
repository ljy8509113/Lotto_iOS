//
//  WinNumberCell.swift
//  RandomNumber
//
//  Created by ljy on 08/05/2019.
//  Copyright © 2019 ljy. All rights reserved.
//

import UIKit

class WinNumberCell: UITableViewCell {

    @IBOutlet weak var labelNo: UILabel!
    @IBOutlet weak var label_1: UILabel!
    @IBOutlet weak var label_2: UILabel!
    @IBOutlet weak var label_3: UILabel!
    @IBOutlet weak var label_4: UILabel!
    @IBOutlet weak var label_5: UILabel!
    @IBOutlet weak var label_6: UILabel!
    @IBOutlet weak var label_7: UILabel!
    
    func setData(value:Win){
        labelNo.text = "\(value.no)"
        label_1.text = "\(value.nm1)"
        label_2.text = "\(value.nm2)"
        label_3.text = "\(value.nm3)"
        label_4.text = "\(value.nm4)"
        label_5.text = "\(value.nm5)"
        label_6.text = "\(value.nm6)"
        label_7.text = "\(value.bonus)"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
