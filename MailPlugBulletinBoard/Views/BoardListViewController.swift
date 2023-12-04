//
//  BoardListViewController.swift
//  MailPlugBulletinBoard
//
//  Created by 장예지 on 11/29/23.
//

import UIKit
import SnapKit

class BoardListViewController: UIViewController {
    
//MARK: - Properties
    var apiService: WebService = WebService()
    var viewModel: BoardListViewModel!
    var completionHandler: ((Int, String) -> ())?
    
//MARK: - Objects
    let titleLabel: UILabel = {
        let object = UILabel()
        object.text = "게시판"
        object.font = UIFont.systemFont(ofSize: 14)
        object.translatesAutoresizingMaskIntoConstraints = false
        return object
    }()
    
    let dismissButton: UIButton = {
        let object = UIButton()
        object.setImage(UIImage(named: "close"),for: .normal)
        object.translatesAutoresizingMaskIntoConstraints = false
        return object
    }()
    
    let navigationView: UIView = {
        let object = UIView()
        object.translatesAutoresizingMaskIntoConstraints = false
        return object
    }()
    
    let tableView: UITableView = {
        let object = UITableView()
        object.register(BoardListTableViewCell.self, forCellReuseIdentifier: BoardListTableViewCell.identifier)
        object.separatorStyle = .none
        object.translatesAutoresizingMaskIntoConstraints = false
        object.isScrollEnabled = false
        return object
    }()
    
    let lineView: UIView = {
        let object = UIView()
        object.backgroundColor = .systemGray4
        object.translatesAutoresizingMaskIntoConstraints = false
        return object
    }()
    
//MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let height: CGFloat = 40
        let bounds = self.navigationController!.navigationBar.bounds
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + height)
        
        view.backgroundColor = .white
        dismissButton.addTarget(self, action: #selector(tapDismissButton), for: .touchUpInside)
        tableView.delegate = self
        tableView.dataSource = self
        
        setLayout()   
        getData()
        
    }
    
    func setLayout(){
        navigationView.addSubview(dismissButton)
        navigationView.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(lineView)
        
        self.tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(80)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        navigationView.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.size.width - 40)
            make.height.equalTo(40)
        }
        
        lineView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(tableView.snp.top)
        }
        
        dismissButton.snp.makeConstraints { make in
            make.width.equalTo(24)
            make.height.equalTo(24)
            make.top.equalTo(navigationView.snp.top)
            make.left.equalTo(navigationView.snp.left)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(dismissButton.snp.bottom).offset(20)
            make.left.equalTo(navigationView.snp.left)
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navigationView)
    }
    
    func getData(){
        apiService.getBoards { boardList in
            if let boardList {
                self.viewModel = BoardListViewModel(boardList: boardList)
            } else {
                self.viewModel = BoardListViewModel(boardList: [])
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func tapDismissButton(_ sender: UIButton){
        self.dismiss(animated: true)
    }
    
}

extension BoardListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // UITableViewDataSource 메소드 구현
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel == nil ? 0 : self.viewModel.numberOfRowInSetion()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BoardListTableViewCell.identifier, for: indexPath) as? BoardListTableViewCell else {
            fatalError("not found")
        }
        
        cell.configureCell(displayName: viewModel.boardList[indexPath.row].displayName)
        return cell
    }
    
    // UITableViewDelegate 메소드 구현 (예: 셀 선택 시 동작)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true)
        let selectedBoard = self.viewModel.boardList[indexPath.row]
        completionHandler?(selectedBoard.boardId, selectedBoard.displayName)
    }
}

