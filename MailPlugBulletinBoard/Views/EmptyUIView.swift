//
//  EmptyUIView.swift
//  MailPlugBulletinBoard
//
//  Created by 장예지 on 12/4/23.
//

import Foundation
import UIKit
import SnapKit

class EmptyUIView: UIViewController {
    
    let emptyView: UIView = {
        let object = UIView()
        object.translatesAutoresizingMaskIntoConstraints = false
        return object
    }()
    
    let imageView: UIImageView = {
        let object = UIImageView()
        object.contentMode = .scaleAspectFit
        object.translatesAutoresizingMaskIntoConstraints = false
        return object
    }()
    
    let label: UILabel = {
        let object = UILabel()
        object.text = "검색 결과가 없습니다. \n 다른 검색어를 입력해 보세요."
        object.font = UIFont.systemFont(ofSize: 14)
        object.textColor = .gray
        object.numberOfLines = 2
        object.translatesAutoresizingMaskIntoConstraints = false
        return object
    }()
    
    init(image: UIImage = UIImage(systemName: "exclamationmark.triangle.fill")!, labelText: String) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.label.text = labelText
        self.label.textAlignment = .center
        
        // Add subviews to the view hierarchy
        self.view.addSubview(imageView)
        self.view.addSubview(label)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            
            make.width.equalTo(image.size.width)
            make.height.equalTo(image.size.height)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.centerX.equalTo(imageView.snp.centerX)
        }
        
        imageView.image = image
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
