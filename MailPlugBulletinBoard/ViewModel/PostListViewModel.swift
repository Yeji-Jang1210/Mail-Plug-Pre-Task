//
//  PostListViewModel.swift
//  MailPlugBulletinBoard
//
//  Created by 장예지 on 11/30/23.
//

import Foundation

class PostListViewModel {
    
//MARK: - Properties
    var apiService: WebService = WebService()
    var posts: [Post] = []
    var boardTitle: String?
    var boardId: Int?
    var page = 1
    var numberOfSection:Int{
        return 1
    }
    
    
//MARK: - Pagination Properties
    
    var currentPage = 1
    var isFetchingData = false
    var allDataLoaded = false
    
//MARK: - Functions
    init(id: Int, title: String){
        self.boardId = id
        self.boardTitle = title
    }
    
    func numberOfRowInSetion() -> Int{
        return self.posts.count
    }
    
    func fetchData(completion: @escaping () -> Void){
        guard !isFetchingData, !allDataLoaded else {
            completion()
            return
        }
        
        isFetchingData = true
        
        apiService.getPosts(pagination: false, boardId: boardId!, offset: posts.count) { [weak self] response in
            
            guard let self = self else { return }
            if let response = response {
                if response.value.isEmpty {
                    allDataLoaded = true
                } else {
                    posts.append(contentsOf: response.value)
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
    
    func loadNextPage(completion: @escaping () -> Void){
        guard !isFetchingData, !allDataLoaded else {
            completion()
            return
        }
        
        isFetchingData = true
        
        apiService.getPosts(pagination: true, boardId: boardId!, offset: posts.count) { [weak self] response in
            
            guard let self = self else { return }
            if let response = response {
                if response.value.isEmpty {
                    allDataLoaded = true
                } else {
                    posts.append(contentsOf: response.value)
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
