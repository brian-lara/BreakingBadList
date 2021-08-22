//
//  DetailScreen.swift
//  BreakingBadList
//
//  Created by Brian Lara on 8/21/21.
//

import Foundation
import UIKit
import WebKit

class DetailScreen: UIViewController{
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var imageWebView: WKWebView!
    @IBOutlet weak var seasonAppearancesLabel: UILabel!
    @IBOutlet weak var occupationLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    var breakingBadCharacter: Character?
    
    override func viewDidLoad() {
        nameLabel.text = breakingBadCharacter!.name
        nicknameLabel.text = breakingBadCharacter!.nickname
        
        let url = URL(string:breakingBadCharacter!.imageURL)!
        imageWebView.load(URLRequest(url: url))
        imageWebView.scrollView.isScrollEnabled = false;
        imageWebView.scrollView.bounces = false;
        
        var seasonAppearancesString = ""
        for (i,num) in breakingBadCharacter!.seasonAppearances.enumerated(){
            if i != breakingBadCharacter!.seasonAppearances.count - 1{
                seasonAppearancesString += num.description + ", "
            }
            else{
                seasonAppearancesString += num.description
            }
        }
        seasonAppearancesLabel.text = seasonAppearancesString
        
        var occupationString = ""
        for (i,string) in breakingBadCharacter!.occupation.enumerated(){
            if i != breakingBadCharacter!.occupation.count - 1{
                occupationString += string + ", "
            }
            else{
                occupationString += string
            }
        }
        occupationLabel.text = occupationString
        
        statusLabel.text = breakingBadCharacter!.status
    }
}
