//
//  Post.swift
//  MailPlugBulletinBoard
//
//  Created by 장예지 on 11/28/23.
//

import Foundation

struct BoardResponse: Codable {
    let value: [Board]
}

struct Board: Codable{
    let boardId: Int
    let displayName: String
}

struct PostResponse: Codable {
    let value: [Post]
    let limit: Int
    let total: Int
}

struct Post: Codable {
    let postId: Int
    let title: String
    let boardId: Int
    let writer: Writer
    let contents: String
    let createdDateTime: String
    let viewCount: Int
    let postType: String
    let isNewPost: Bool
    let hasInlineImage: Bool
    let commentsCount: Int
    let attachmentsCount: Int
    let isAnonymous: Bool
    let isOwner: Bool
    let hasReply: Bool
    
    var postDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = dateFormatter.date(from: self.createdDateTime) else { return ""}
        if date.isInToday {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: date)
        } else if date.isInYesterday {
            return "어제"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: date)
        }
    }
}

struct Writer: Codable{
    let displayName: String
    let emailAddress: String
}

extension Date {
    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }
    
    var isInYesterday: Bool { Calendar.current.isDateInYesterday(self) }
    var isInToday:     Bool { Calendar.current.isDateInToday(self) }
}
