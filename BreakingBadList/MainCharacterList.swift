//
//  MainCharacterList.swift
//  BreakingBadList
//
//  Created by Brian Lara on 8/19/21.
//

import UIKit

class MainCharacterList: UIViewController {
    
    @IBOutlet weak var characterTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    struct Character {
        var imageURL: String
        var image: UIImage?
        var name: String
        var occupation: [String]
        var status: String
        var nickname: String
        var seasonAppearances: [Int]
    }
    
    let refreshControl = UIRefreshControl()
    var characterList:[Character] = []
    var originalCharacterList:[Character] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        characterTableView.delegate = self
        characterTableView.dataSource = self
        
        characterTableView.refreshControl = refreshControl
        characterTableView.refreshControl?.beginRefreshing()
        
        searchBar.delegate = self
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
                           
                            DispatchQueue.main.async {
                                self.characterTableView.refreshControl?.beginRefreshing()
                            }
                            
                            for (i,character) in json.enumerated(){
                                
                                self.getCharacterImage(url: character["img"] as! String) { success, image in
                                    
                                    let breakingBadCharacter = Character(imageURL: character["img"] as! String, image: image, name: character["name"] as! String, occupation: character["occupation"] as! [String], status: character["status"] as! String, nickname: character["nickname"] as! String, seasonAppearances: character["appearance"] as! [Int])
                                    
                                    self.originalCharacterList.append(breakingBadCharacter)
                                    
                                    if i == json.count-1{

                                        self.characterList = self.originalCharacterList
                                        DispatchQueue.main.async {
                                            self.characterTableView.refreshControl?.endRefreshing()
                                            self.characterTableView.reloadData()
                                            self.characterTableView.refreshControl = nil
                                        }
                                    }
                                }
                            }
                        }
                    } catch {}
                }
            }
        }
    }
    
    func getCharacterImage(url:String, completion: @escaping (Bool?, UIImage) -> Void){
        
        NetworkingService.shared.fetchData(url: url) { (error, data) in
            
            if let _error = error {
                completion(false,UIImage())
            }
            
            if let _data = data {

                completion(true,UIImage(data: _data as! Data)!)
                
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

extension MainCharacterList: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText == ""{
            characterList = originalCharacterList
        }
        else if let seasonInt = Int(searchText){
            characterList = originalCharacterList.filter { $0.seasonAppearances.contains(seasonInt) }
        }
        else{
            characterList = originalCharacterList.filter { $0.name.contains(searchText) }
        }
        DispatchQueue.main.async {
            self.characterTableView.reloadData()
        }
    }
}
