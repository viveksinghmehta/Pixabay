//
//  SearchController.swift
//  Pixabay
//
//  Created by Vivek Singh Mehta on 10/02/21.
//

import UIKit
import DefaultsKit

class SearchController: UIViewController {

    
    //MARK:- Outlets
    @IBOutlet weak var recentlySearchedTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    //MARK:- Properties
    var isSearching: Bool = false
    var recentlySearchedWords: [String] = [String]()
    var filteredWords: [String] = [String]()
    var pixabayImagesModel: PixabayImagesModel!
    var curentKeyword: String = ""
    
    //MARK:- Identifier
    private let identifier: String = "searchedWord"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarInit()
        searchBarInit()
        tableViewInit()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkForRecentlySearchedWords()
    }
    
    
    fileprivate func tableViewInit() {
        recentlySearchedTable.register(UINib(nibName: "SearchedWordsCell", bundle: nil), forCellReuseIdentifier: identifier)
        recentlySearchedTable.estimatedRowHeight = 50
        recentlySearchedTable.delegate = self
        recentlySearchedTable.dataSource = self
        recentlySearchedTable.tableFooterView = UIView()
        recentlySearchedTable.reloadData()
    }
    
    
    
    fileprivate func checkForRecentlySearchedWords() {
        if let words = Defaults().get(for: .recentlySearchedWords) {
           recentlySearchedWords = words.reversed()
            recentlySearchedTable.reloadData()
        }
    }
    
    
    
    
    fileprivate func navigationBarInit() {
        self.title = "Pixabay"
    }
    
    
    
    fileprivate func searchBarInit() {
        searchBar.delegate = self
        searchBar.placeholder = "try searching \"anime\""
    }

}


extension SearchController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredWords.count
        } else {
           return recentlySearchedWords.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? SearchedWordsCell else { return UITableViewCell() }
        if isSearching {
            cell.cellLabel?.text = filteredWords[indexPath.row]
        } else {
            cell.cellLabel?.text = recentlySearchedWords[indexPath.row]
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching {
            searchForImages(keyword: filteredWords[indexPath.row])
            print(filteredWords[indexPath.row])
        } else {
            searchForImages(keyword: recentlySearchedWords[indexPath.row])
            print(recentlySearchedWords[indexPath.row])
        }
    }
    
    
    fileprivate func searchForImages(keyword: String) {
        let parameters = [
            "q": keyword,
            "per_page": "20",
            "page": "1"
        ]
        NetworkService.shared.getImages(with: parameters, model: PixabayImagesModel.self) { [weak self] (response) in
            guard let weakself = self else { return }
            switch response {
            case .success(let model):
                print(model)
                weakself.showAllImages(model)
            case .failure(let error):
                print(error.localizedDescription)
                weakself.showAlert(title: "Error", msg: error.localizedDescription)
            }
        }
    }
    
    fileprivate func checkForData(_ model: PixabayImagesModel) {
        if let images = model.images, !images.isEmpty {
            showAllImages(model)
        } else {
            showAlert(title: "No result found", msg: "Please try with some different keywords")
        }
    }
    
    fileprivate func saveKeyword() {
        if let words = Defaults().get(for: .recentlySearchedWords) {
            if words.count == 10 {
                recentlySearchedWords.remove(at: 0)
                saveFullKeyWords()
            } else {
                saveFullKeyWords()
            }
        } else {
            saveFullKeyWords()
        }
    }
    
    
    fileprivate func saveFullKeyWords() {
        recentlySearchedWords.append(curentKeyword)
        let keywords = recentlySearchedWords.reversed()
        let temp: [String] = keywords.map({ $0 })
        Defaults().set(temp, for: .recentlySearchedWords)
    }
    
    
    fileprivate func showAllImages(_ model: PixabayImagesModel) {
        let gallery = GalleryController()
        gallery.pixabayImagesModel = model
        self.navigationController?.pushViewController(gallery, animated: true)
    }
    
    
}


extension SearchController: UISearchBarDelegate {
    
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.returnKeyType = .search
        return true
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        view.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let keyword = searchBar.text, !keyword.isEmpty {
            curentKeyword = keyword
            searchForImages(keyword: keyword)
            view.endEditing(true)
            searchBar.text = nil
            searchBar.setShowsCancelButton(false, animated: true)
        } else {
            
        }
    }
    
}
