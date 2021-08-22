//
//  CharacterTableViewCell.swift
//  BreakingBadList
//
//  Created by Brian Lara on 8/19/21.
//

import Foundation
import UIKit
import WebKit

class CharacterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var characterNameLabel: UILabel!
    @IBOutlet weak var imageWebView: WKWebView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
