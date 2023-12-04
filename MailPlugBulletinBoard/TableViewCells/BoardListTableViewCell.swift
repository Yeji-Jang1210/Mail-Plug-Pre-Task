//
//  BoardListTableViewCell.swift
//  MailPlugBulletinBoard
//
//  Created by 장예지 on 11/29/23.
//

import UIKit
import SnapKit

class BoardListTableViewCell: UITableViewCell {
    
    static let identifier = "BoardListTableViewCell"
    
    let displayLabel: UILabel = {
       let object = UILabel()
        object.textColor = .black
        object.font = UIFont.systemFont(ofSize: 16)
        object.translatesAutoresizingMaskIntoConstraints = false
        return object
    }()
    
    // 셀의 초기화 및 UI 구성을 위한 메소드
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(displayLabel)
        
        displayLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(displayName: String){
        displayLabel.text = displayName
    }

}
