//
//  SearchTableViewCell.swift
//  MailPlugBulletinBoard
//
//  Created by 장예지 on 11/29/23.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    static let identifier: String = "SearchTableViewCell"
    
    let filteringLabel: UILabel = {
        let object = UILabel()
         object.textColor = .gray
         object.font = UIFont.systemFont(ofSize: 12)
         object.translatesAutoresizingMaskIntoConstraints = false
         return object
    }()

    let searchTextLabel: UILabel = {
       let object = UILabel()
        object.textColor = .black
        object.font = UIFont.systemFont(ofSize: 15)
        object.translatesAutoresizingMaskIntoConstraints = false
        return object
    }()
    
    let arrowImageView: UIImageView = {
        let object = UIImageView()
        object.image = UIImage(named: "Value & Icon")?.withRenderingMode(.alwaysTemplate)
        object.tintColor = .gray
        object.translatesAutoresizingMaskIntoConstraints = false
        return object
    }()
    
    let cellView: UIView = {
       let object = UIView()
        object.translatesAutoresizingMaskIntoConstraints = false
        return object
    }()
    
    // 셀의 초기화 및 UI 구성을 위한 메소드
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(cellView)
        
        cellView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        cellView.addSubview(filteringLabel)
        cellView.addSubview(searchTextLabel)
        cellView.addSubview(arrowImageView)
        
        filteringLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(25)
        }
        
        searchTextLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(filteringLabel.snp.right)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.width.equalTo(15)
            make.height.equalTo(15)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
        }
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(filter: String, recent: String){
        filteringLabel.text = "\(filter) : "
        searchTextLabel.text = recent
    }
}
