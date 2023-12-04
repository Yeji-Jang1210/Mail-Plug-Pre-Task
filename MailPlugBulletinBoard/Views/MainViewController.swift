//
//  MainViewController.swift
//  MailPlugBulletinBoard
//
//  Created by 장예지 on 11/28/23.
//

import UIKit
import Alamofire
import SnapKit

class MainViewController: UIViewController {
    
    //MARK: - properties
    
    private var viewModel: PostListViewModel
    var apiService: WebService = WebService()
    var isLastPage: Bool = false
    
    //MARK: - objects
    let menuButton: UIButton = {
        let object = UIButton()
        object.setImage(UIImage(named: "hamburger menu"), for: .normal)
        return object
    }()
    
    let searchButton: UIButton = {
        let object = UIButton()
        object.setImage(UIImage(named: "search"), for:.normal)
        return object
    }()
    
    let boardTitle: UILabel = {
        let object = UILabel()
        object.font = UIFont.systemFont(ofSize: 22)
        object.textAlignment = NSTextAlignment.center
        object.sizeToFit()
        return object
    }()
    
    let tableView: UITableView = {
        let object = UITableView()
        object.separatorStyle = .none
        object.translatesAutoresizingMaskIntoConstraints = false
        object.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        return object
    }()
    
    let customView: UIView = {
        let object = UIView()
        object.translatesAutoresizingMaskIntoConstraints = false
        return object
    }()
    
    let emptyPostView = EmptyUIView(image: UIImage(named: "emptyPostImage")!, labelText: "등록된 게시글이 없습니다.").view!
    
    //MARK: - functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.tableView.backgroundColor = UIColor(named: "tableViewBackColor")!
        searchButton.addTarget(self, action: #selector(tapSearchButton), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(tapMenuButton), for: .touchUpInside)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        setLayout()
        viewModel.fetchData {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    init?(coder: NSCoder, viewModel: PostListViewModel) {
        self.viewModel = viewModel
        self.boardTitle.text = viewModel.boardTitle!
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Use `init(coder:viewModel:)` to instantiate a `ViewController` instance.")
    }
    
    func setLayout(){
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        boardTitle.translatesAutoresizingMaskIntoConstraints = false
        
        customView.addSubview(menuButton)
        customView.addSubview(boardTitle)
        customView.addSubview(searchButton)
        
        self.view.addSubview(emptyPostView)
        
        emptyPostView.translatesAutoresizingMaskIntoConstraints = false
        emptyPostView.isHidden = false
        
        self.view.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        
        customView.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.size.width - 40)
            make.height.equalTo(40)
        }
        
        menuButton.snp.makeConstraints { make in
            make.width.equalTo(24)
            make.height.equalTo(24)
            make.centerY.equalTo(customView.snp.centerY)
            make.left.equalTo(customView.snp.left).offset(10)
        }
        
        boardTitle.snp.makeConstraints { make in
            make.left.equalTo(menuButton.snp.right).offset(20)
            make.centerY.equalTo(customView.snp.centerY)
        }
        
        searchButton.snp.makeConstraints { make in
            make.width.equalTo(24)
            make.height.equalTo(24)
            make.centerY.equalTo(customView.snp.centerY)
            make.right.equalTo(customView.snp.right)
        }

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customView)
    }
    
    @objc func tapMenuButton(_ sender: UIButton){
        
        // UINavigationController를 생성하고 rootViewController로 새로운 UIViewController를 설정
        let controller = BoardListViewController()
        
        controller.completionHandler = { id, title in
            self.viewModel = PostListViewModel(id: id, title: title)
            self.apiService.getPosts(boardId: id) { response in
                if let response = response {
                    self.viewModel.posts = response.value
                }
                
                self.isLastPage = false
                DispatchQueue.main.async{
                    self.boardTitle.text = title
                    self.tableView.reloadData()
                }
            }
        }
        
        let navigationController = UINavigationController(rootViewController: controller)
        self.present(navigationController, animated: true)
    }
    
    @objc func tapSearchButton(_ sender:UIButton){
        let viewModel = SearchViewModel(boardId: viewModel.boardId!, boardTitle: viewModel.boardTitle!)
        let controller = SearchViewController()
        controller.viewModel = viewModel
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen
        
        self.present(navigationController, animated: true)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    // UITableViewDataSource 메소드 구현
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.viewModel.numberOfSection == 0 {
            emptyPostView.isHidden = false
        } else {
            emptyPostView.isHidden = true
        }
        return self.viewModel.numberOfRowInSetion()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 사용자 정의 셀을 dequeue합니다.
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell else {
            fatalError("not found")
        }
        
        let data = viewModel.posts[indexPath.row]
        cell.newPostLabel.isHidden =  data.isNewPost
        
        if data.postType == "reply" {
            cell.postTypeLabel.text = "RE"
            cell.postTypeLabel.backgroundColor = .black
            cell.postTypeLabel.isHidden = false
        } else {
            if data.postType == "notice" {
                cell.postTypeLabel.backgroundColor = UIColor(named: "noticeColor")
                cell.postTypeLabel.text = "공지"
                cell.postTypeLabel.isHidden = false
            } else {
                cell.postTypeLabel.isHidden = true
            }
        }
        
        cell.newPostLabel.isHidden = !data.isNewPost
        cell.attachmentsImageView.isHidden = data.attachmentsCount == 0 ? true : false
        cell.writerLabel.text = data.isAnonymous ? "익명" : data.writer.displayName
        
        // 데이터를 셀에 설정합니다.
        cell.configureCell(title: data.title, time: data.postDate, viewCount: data.viewCount)
        
        return cell
    }
    
}

extension MainViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentOffset_y = scrollView.contentOffset.y
        let tableViewContentSize = tableView.contentSize.height
        
        if contentOffset_y > tableViewContentSize - 100 - scrollView.frame.size.height{
            
            guard !viewModel.apiService.isPagination else { return }
            
            DispatchQueue.main.async{
                self.tableView.tableFooterView = self.view.createSpinerFotter()
            }
            
            viewModel.loadNextPage { [weak self] in
                guard let self = self else { return }
                
                DispatchQueue.main.async{
                    self.tableView.tableFooterView = nil
                    self.tableView.reloadData()
                }
                
            }
        }
    }
}

extension UIView {
    func createSpinerFotter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        
        return footerView
    }
    
}
