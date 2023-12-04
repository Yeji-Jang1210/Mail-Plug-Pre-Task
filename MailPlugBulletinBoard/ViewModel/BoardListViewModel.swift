//
//  BoardListViewModel.swift
//  MailPlugBulletinBoard
//
//  Created by 장예지 on 11/29/23.
//

import Foundation
import Alamofire

class BoardListViewModel {
    
//MARK: - Properties
    var boardList: [Board] = []
    
    init(boardList: [Board]) {
        self.boardList = boardList
    }
    
    var numberOfSection:Int{
        return 1
    }
    
    var completionHandler: ((Int, String) -> ())?
//MARK: -Functions
    func numberOfRowInSetion() -> Int{
        return self.boardList.count
    }
}
