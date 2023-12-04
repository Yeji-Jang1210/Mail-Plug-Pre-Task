//
//  PostTableViewCell.swift
//  MailPlugBulletinBoard
//
//  Created by 장예지 on 11/28/23.
//

import UIKit


class BasePaddingLabel: UILabel {
    private var padding = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
    
    convenience init(padding: UIEdgeInsets) {
        self.init()
        self.padding = padding
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right
        
        return contentSize
    }
}

class PostTableViewCell: UITableViewCell {
    
    static let identifier = "PostTableViewCell"
    
    //포트스타입
    let postTypeLabel: BasePaddingLabel = {
        let object = BasePaddingLabel()
        object.translatesAutoresizingMaskIntoConstraints = false
        object.clipsToBounds = true
        object.layer.cornerRadius = 8
        object.textColor = .white
        object.font = UIFont.systemFont(ofSize: 10)
        object.setContentHuggingPriority(.defaultLow, for: .horizontal)
        object.setContentCompressionResistancePriority(.required, for: .horizontal)
        return object
        
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    //첨부파일
    let attachmentsImageView: UIImageView = {
        let object = UIImageView()
        object.translatesAutoresizingMaskIntoConstraints = false
        object.image = UIImage(systemName: "Attechment")
        object.tintColor = .gray
        object.contentMode = .scaleAspectFit
        object.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return object
    }()
    
    //New표시
    let newPostLabel: BasePaddingLabel = {
        let object = BasePaddingLabel(padding: UIEdgeInsets(top: 1, left: 4, bottom: 1, right: 4))
        object.translatesAutoresizingMaskIntoConstraints = false
        object.text = "N"
        object.clipsToBounds = true
        object.backgroundColor = .red
        object.layer.cornerRadius = 8
        object.textColor = .white
        object.font = UIFont.systemFont(ofSize: 10)
        return object
    }()
    
    let writerLabel: UILabel = {
        let object = UILabel()
        object.translatesAutoresizingMaskIntoConstraints = false
        object.font = UIFont.systemFont(ofSize: 12)
        object.textColor = UIColor.gray
        return object
    }()
    
    let createdDateTimeLabel: UILabel = {
        let object = UILabel()
        object.translatesAutoresizingMaskIntoConstraints = false
        object.font = UIFont.systemFont(ofSize: 12)
        object.textColor = UIColor.gray
        return object
    }()
    
    //눈 이미지
    let viewImageView: UIImageView = {
        let object = UIImageView()
        object.translatesAutoresizingMaskIntoConstraints = false
        object.image = UIImage(named: "Union")
        object.contentMode = .scaleAspectFit
        return object
    }()
    
    let viewCountLabel: UILabel = {
        let object = UILabel()
        object.translatesAutoresizingMaskIntoConstraints = false
        object.font = UIFont.systemFont(ofSize: 12)
        object.textColor = .gray
        return object
    }()
    
    let postStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }()
    
    let titleStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    let detailStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }()
    
    let cellView: UIView = {
        let view = UIView()
        return view
    }()
    
    // 셀의 초기화 및 UI 구성을 위한 메소드입니다.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        setStackView()
        
        postStackView.addArrangedSubview(titleStackView)
        postStackView.addArrangedSubview(detailStackView)
        
        titleStackView.addArrangedSubview(postTypeLabel)
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(attachmentsImageView)
        titleStackView.addArrangedSubview(newPostLabel)
        
        let list: [UIView] = [writerLabel,createdDateTimeLabel]
        for i in 0...1 {
            
            if let originalImage = UIImage(systemName: "circle.fill") {
                
                //UIImageView에 들어가는 Image Size를 조정
                let newSize = CGSize(width: 4.0, height: 4.0)
                
                UIGraphicsImageRenderer(size: newSize).image { _ in
                    originalImage.draw(in: CGRect(origin: .zero, size: newSize))
                }
                
                let imageView = UIImageView(image: UIGraphicsImageRenderer(size: newSize).image { _ in
                    originalImage.draw(in: CGRect(origin: .zero, size: newSize))
                })
                
                imageView.tintColor = .gray
                imageView.contentMode = .scaleAspectFit
                imageView.translatesAutoresizingMaskIntoConstraints = false
                
                detailStackView.addArrangedSubview(list[i])
                detailStackView.addArrangedSubview(imageView)
            }
        }

        detailStackView.addArrangedSubview(viewImageView)
        detailStackView.addArrangedSubview(viewCountLabel)
        
        
        // Autolayout을 사용하여 UI 요소의 제약을 설정
        NSLayoutConstraint.activate([
            attachmentsImageView.widthAnchor.constraint(equalToConstant: 15),
            attachmentsImageView.heightAnchor.constraint(equalToConstant: 15),
            newPostLabel.widthAnchor.constraint(equalToConstant: 15),
            
            viewImageView.widthAnchor.constraint(equalToConstant: 15),
            viewImageView.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 셀의 내용을 설정하는 메소드
    func configureCell(title: String, time: String, viewCount: Int) {
        titleLabel.text = title
        createdDateTimeLabel.text = time
        viewCountLabel.text = String(viewCount)
    }
    
    func configureSearchTableViewCell(time: String, viewCount: Int) {
        createdDateTimeLabel.text = time
        viewCountLabel.text = String(viewCount)
    }
    
    func setStackView() {
        addSubview(postStackView)
        
        postStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        postStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        postStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        postStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
    }
    
    func setup() {
        addSubview(cellView)
        cellView.setAnchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 4, paddingRight: 8)
    }
    
    //cell 재사용 방지
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
}

extension UIView {
    func setAnchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,
                   paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant:  paddingTop).isActive = true
        }
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant:  paddingLeft).isActive = true
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant:  -paddingRight).isActive = true
        }
    }
}

extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}

