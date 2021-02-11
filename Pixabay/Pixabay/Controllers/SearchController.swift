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
            curentKeyword = filteredWords[indexPath.row]
            print(filteredWords[indexPath.row])
        } else {
            searchForImages(keyword: recentlySearchedWords[indexPath.row])
            curentKeyword = recentlySearchedWords[indexPath.row]
            print(recentlySearchedWords[indexPath.row])
        }
    }
    
    
    fileprivate func searchForImages(keyword: String) {
        let parameters = [
            "q": keyword,
            "page": "1"
        ]
        Loader.shared.addLoader(on: self, frames: view.bounds)
        NetworkService.shared.getImages(with: parameters, model: PixabayImagesModel.self) { [weak self] (response) in
            guard let weakself = self else { return }
            Loader.shared.removeLoader(from: weakself)
            switch response {
            case .success(let model):
                print(model)
                weakself.checkForData(model)
            case .failure(let error):
                print(error.localizedDescription)
                weakself.showAlert(title: "Error", msg: error.localizedDescription)
            }
        }
    }
    
    fileprivate func checkForData(_ model: PixabayImagesModel) {
        if let images = model.images, !images.isEmpty {
            saveKeyword()
            showAllImages(model)
        } else {
            showAlert(title: "No result found", msg: "Please try with some different keywords")
        }
    }
    
    
    //Save the searched keywords
    fileprivate func saveKeyword() {
        if let words = Defaults().get(for: .recentlySearchedWords) {
            if words.count == 10 {
                recentlySearchedWords.remove(at: 0)
                saveFullKeyWords()
            } else {
                if let _ = recentlySearchedWords.filter( { $0.lowercased() == curentKeyword.lowercased() } ).first, let index = recentlySearchedWords.firstIndex(where: { $0.lowercased() == curentKeyword.lowercased() }) {
                    recentlySearchedWords.remove(at: index)
                    saveFullKeyWords()
                } else {
                    saveFullKeyWords()
                }
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
        gallery.searchedKeyword = curentKeyword
        gallery.pixabayImagesModel = model
        self.navigationController?.pushViewController(gallery, animated: true)
    }
    
    
}


extension SearchController: UISearchBarDelegate {
    
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        isSearching = true
        searchBar.returnKeyType = .search
        return true
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        isSearching = false
        recentlySearchedTable.reloadData()
        view.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let keyword = searchBar.text {
            filteredWords = recentlySearchedWords.filter( {$0.contains(keyword) })
            recentlySearchedTable.reloadData()
        }
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        recentlySearchedTable.reloadData()
        if let keyword = searchBar.text, !keyword.isEmpty {
            curentKeyword = keyword
            searchForImages(keyword: keyword)
            view.endEditing(true)
            searchBar.text = nil
            searchBar.setShowsCancelButton(false, animated: true)
        } else {
            showAlert(title: "Please enter you keyword", msg: "please enter your keywords for searching the images.")
        }
    }
    
}


class Loader {
    
    static let shared = Loader()
    
    let loadingView: UIView = {
       let view = UIView()
        //Adding blur view to the loader
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        
        //Adding the activityIndiicator to the view
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .black
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        return view
    }()
    
    func addLoader(on: UIViewController, frames: CGRect) {
        loadingView.frame = frames
        on.view.addSubview(loadingView)
    }
    
    func removeLoader(from controller: UIViewController) {
        loadingView.removeFromSuperview()
    }
}
