//
//  WebService.swift
//  MailPlugBulletinBoard
//
//  Created by 장예지 on 11/30/23.
//

import Foundation
import Alamofire

class WebService {
    private var baseUrl = "https://mp-dev.mail-server.kr/api/v2/boards"
    private let authToken = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2ODgxMDM5NDAsImV4cCI6MCwidXNlcm5hbWUiOiJtYWlsdGVzdEBtcC1kZXYubXlwbHVnLmtyIiwiYXBpX2tleSI6IiMhQG1wLWRldiFAIyIsInNjb3BlIjpbImVhcyJdLCJqdGkiOiI5MmQwIn0.Vzj93Ak3OQxze_Zic-CRbnwik7ZWQnkK6c83No_M780"
    
    var isPagination = false
    
    func getBoards(completion: @escaping ([Board]?)->()) {
        // Alamofire를 사용하여 API 호출
        AF.request(baseUrl, method: .get, headers: ["Authorization": authToken])
            .validate()
            .responseDecodable(of: BoardResponse.self) { response in
                switch response.result {
                case .success(let result):
                    completion(result.value)
                case .failure(let error):
                    print(error)
                    completion([])
                }
            }
        
    }
    
    private func performRequest(url: String, completion: @escaping (PostResponse?) -> ()) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            AF.request(url, method: .get, headers: ["Authorization": self.authToken])
                .validate()
                .responseDecodable(of: PostResponse.self) { response in
                    switch response.result {
                    case .success(let result):
                        completion(result)
                    case .failure(let error):
                        print(error)
                        completion(nil)
                    }
                    
                    if self.isPagination {
                        self.isPagination = false
                    }
                }
        }
    }

    func getPosts(pagination: Bool = false, boardId: Int, offset: Int = 0, limit: Int = 30, completion: @escaping (PostResponse?) -> ()) {
        if pagination {
            isPagination = true
        }
        
        let url = self.baseUrl + "/\(boardId)/posts?offset=\(offset)&limit=\(limit)"
        performRequest(url: url, completion: completion)
    }

    func getFilteringPosts(pagination: Bool = false, boardId: Int, searchText: String, target: String, offset: Int = 0, limit: Int = 30, completion: @escaping (PostResponse?) -> ()) {
        if pagination {
            isPagination = true
        }
        
        let urlString = self.baseUrl + "/\(boardId)/posts?search=\(searchText)&searchTarget=\(target)&offset=\(offset)&limit=\(limit)"
        
        if let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            performRequest(url: encodedUrl, completion: completion)
        } else {
            print("encoded error")
        }
    }
}
