//
//  MainCharacterList.swift
//  BreakingBadList
//
//  Created by Brian Lara on 8/19/21.
//

import UIKit

class MainCharacterList: UIViewController {
    
    @IBOutlet weak var characterTableView: UITableView!
    
    struct Character {
        var imageURL: String
        var image: UIImage?
        var name: String
        var occupation: [String]
        var status: String
        var nickname: String
        var seasonAppearances: [Int]
    }
    
    var characterList:[Character] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        characterTableView.delegate = self
        characterTableView.dataSource = self
        getBreakingBadCharacters()
    }

    func getBreakingBadCharacters(){
        
        let url = "https://breakingbadapi.com/api/characters"
        
        NetworkingService.shared.fetchData(url: url) { (error, json) in
            
            if let _error = error {
                print(_error)
            }
            
            if let data = json {
                
                if let data = data as? Data {
                    
                    do {
                        
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [Dictionary<String, AnyObject>] {
                            for (index,character) in json.enumerated(){
                                let breakingBadCharacter = Character(imageURL: character["img"] as! String, image: UIImage(), name: character["name"] as! String, occupation: character["occupation"] as! [String], status: character["status"] as! String, nickname: character["nickname"] as! String, seasonAppearances: character["appearance"] as! [Int])
                                
                                self.characterList.append(breakingBadCharacter)
                                self.getCharacterImage(url: breakingBadCharacter.imageURL, index: index)
                            }
                        }
                        DispatchQueue.main.async {
                            self.characterTableView.reloadData()
                        }
                    } catch {}
                }
            }
        }
    }
    
    func getCharacterImage(url:String, index:Int){
                                
        NetworkingService.shared.fetchData(url: url) { (error, data) in
            
            if let _error = error {
                print(_error)
            }
            
            if let _data = data {
                self.characterList[index].image = UIImage(data: _data as! Data)
                DispatchQueue.main.async {
                    self.characterTableView.reloadData()
                }
            }
        }
    }
}

extension MainCharacterList: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        characterList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "characterTableViewCell") as! CharacterTableViewCell
        
        cell.characterImage.image = characterList[indexPath.row].image
        cell.characterNameLabel.text = characterList[indexPath.row].name
        
        return cell
    }
}
