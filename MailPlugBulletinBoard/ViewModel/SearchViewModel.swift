//
//  SearchViewModel.swift
//  MailPlugBulletinBoard
//
//  Created by 장예지 on 12/1/23.
//

import Foundation

class SearchViewModel {
    enum Types: String, CaseIterable {
        case all, title, contents, writer
        
        var korValue: String {
            switch self{
            case .all:
                return "전체"
            case .title:
                return "제목"
            case .writer:
                return "작성자"
            case .contents:
                return "내용"
            }
        }
    }
//MARK: - Properties
    var apiService: WebService = WebService()
    var inputText: String = ""
    var numberOfSection: Int{
        return 1
    }
    var filteringPosts: [Post] = []
    var selectedSearchType: Types?
    var boardId: Int
    var boardTitle: String
    
    //MARK: - Pagination Properties
    var page: Int = 1
    var isFetchingData = false
    var allDataLoaded = false
    
    //MARK: - Functions
    init(boardId: Int, boardTitle: String){
        self.boardId = boardId
        self.boardTitle = boardTitle
    }
    
    func numberOfRowInSetion() -> Int{
        return self.filteringPosts.count
    }
    
    func fetchData(completion: @escaping () -> Void){
        guard !isFetchingData, !allDataLoaded else {
            completion()
            return
        }
        
        isFetchingData = true
        
        if let selectedSerachType = selectedSearchType?.rawValue {
            apiService.getFilteringPosts(pagination: false, boardId: boardId, searchText: inputText, target: selectedSerachType) { [weak self] response in
                
                guard let self = self else { return }
                if let response = response {
                    if response.value.isEmpty {
                        allDataLoaded = true
                    } else {
                        filteringPosts.append(contentsOf: response.value)
                        page += 1
                    }
                }
                else {
                    filteringPosts = []
                }
                
                isFetchingData = false
                completion()
                
            }
        }
        
    }
    
    func loadNextPage(completion: @escaping () -> Void){
        guard !isFetchingData, !allDataLoaded else {
            completion()
            return
        }
        
        isFetchingData = true
        
        if let selectedSerachType = selectedSearchType?.rawValue {
            apiService.getFilteringPosts(pagination: true, boardId: boardId, searchText: inputText, target: selectedSerachType, offset: filteringPosts.count) { [weak self] response in
                
                guard let self = self else { return }
                if let response = response {
                    if response.value.isEmpty {
                        allDataLoaded = true
                    } else {
                        filteringPosts.append(contentsOf: response.value)
                        page += 1
                    }
                }
                else {
                    print("error")
                }
                
                isFetchingData = false
                completion()
                
            }
        }
        
    }
    
}
