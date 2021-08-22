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
    @IBOutlet weak var seasonCollectionView: UICollectionView!
    
    let refreshControl = UIRefreshControl()
    var characterList:[Character] = []
    var originalCharacterList:[Character] = []
    var selectedCell = 0
    var selectedSeason = -1
    var characterDictionary: [Int:Character] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        characterTableView.delegate = self
        characterTableView.dataSource = self
        
        characterTableView.refreshControl = refreshControl
        characterTableView.refreshControl?.beginRefreshing()
        
        seasonCollectionView.delegate = self
        seasonCollectionView.dataSource = self
        
        searchBar.delegate = self
        getBreakingBadCharacters()
    }

    func getBreakingBadCharacters(){
        
        let url = "https://breakingbadapi.com/api/characters"
        
        NetworkingService.shared.fetchData(url: url) { (error, json) in
            
            if let data = json {
                
                if let data = data as? Data {
                    
                    do {
                        
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [Dictionary<String, AnyObject>] {
                           
                            DispatchQueue.main.async {
                                self.characterTableView.refreshControl?.beginRefreshing()
                            }
                            
                            for character in json{
                                    
                                let breakingBadCharacter = Character(imageURL: character["img"] as! String, name: character["name"] as! String, occupation: character["occupation"] as! [String], status: character["status"] as! String, nickname: character["nickname"] as! String, seasonAppearances: character["appearance"] as! [Int])
                                    
                                self.originalCharacterList.append(breakingBadCharacter)
                        
                            }
                            
                            self.characterList = self.originalCharacterList
                            DispatchQueue.main.async {
                                self.characterTableView.refreshControl?.endRefreshing()
                                self.characterTableView.reloadData()
                                self.characterTableView.refreshControl = nil
                            }
                            
                        }
                    } catch {}
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailScreen = segue.destination as! DetailScreen
        detailScreen.breakingBadCharacter = characterList[selectedCell]
    }
}

extension MainCharacterList: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        characterList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "characterTableViewCell") as! CharacterTableViewCell
        
        let character = characterList[indexPath.row]
        let characterURL = URL(string:character.imageURL)!
        
        cell.imageWebView.load(URLRequest(url: characterURL))
        cell.characterNameLabel.text = character.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedCell = indexPath.row
        performSegue(withIdentifier: "detailScreenSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

}

extension MainCharacterList: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText == ""{
            if selectedSeason == -1{
                characterList = originalCharacterList
            }
            else{
                characterList = originalCharacterList.filter { $0.seasonAppearances.contains(selectedSeason+1) }
            }
        }
        else{
            if selectedSeason == -1{
                characterList = originalCharacterList.filter { $0.name.contains(searchText) }
            }
            else{
                characterList = originalCharacterList.filter { $0.name.contains(searchText) && $0.seasonAppearances.contains(selectedSeason+1)}
            }
        }
        
        DispatchQueue.main.async {
            self.characterTableView.reloadData()
        }
    }
}

extension MainCharacterList: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "seasonFilterCell", for: indexPath) as! seasonFilterCell
        cell.seasonLabel.text = "\(indexPath.row+1)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            if cell.contentView.backgroundColor == #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1){
                cell.contentView.backgroundColor = nil
                selectedSeason = -1
                if searchBar.searchTextField.text == ""{
                    characterList = originalCharacterList
                }
                else{
                    characterList = originalCharacterList.filter { $0.name.contains(searchBar.searchTextField.text!) }
                }
            }
            else{
                cell.contentView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
                selectedSeason = indexPath.row
                characterList = originalCharacterList.filter { $0.seasonAppearances.contains(indexPath.row+1) }
                
                if searchBar.searchTextField.text != ""{
                    characterList = characterList.filter { $0.name.contains(searchBar.searchTextField.text!) }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.characterTableView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? seasonFilterCell {
            cell.contentView.backgroundColor = nil
        }
    }
}
