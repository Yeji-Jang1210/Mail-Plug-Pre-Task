//
//  SearchViewController.swift
//  MailPlugBulletinBoard
//
//  Created by 장예지 on 11/29/23.
//

import UIKit
import SnapKit

class SearchViewController: UIViewController {
    
    //MARK: - properties
    var apiService = WebService()
    var viewModel: SearchViewModel!
    
    //MARK: - objects
    let searchBar: UISearchBar = {
        let object = UISearchBar()
        object.layer.cornerRadius = 1
        object.setValue("취소", forKey: "cancelButtonText")
        if let textFieldInsideSearchBar = object.value(forKey: "searchField") as? UITextField {
            // UITextField의 속성을 설정하여 placeholder 텍스트 크기를 변경합니다.
            textFieldInsideSearchBar.font = UIFont.systemFont(ofSize: 13)
        }
        let cancelButtonAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "searchBarCancelColor")!]
         UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes , for: .normal)
        
        return object
    }()
    
    let filteringTableView: UITableView = {
        let object = UITableView()
        object.translatesAutoresizingMaskIntoConstraints = false
        object.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        return object
    }()
    
    let searchTypeTableView: UITableView = {
        let object = UITableView()
        object.translatesAutoresizingMaskIntoConstraints = false
        object.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
        return object
    }()

    let filteringResultEmptyView = EmptyUIView(image: UIImage(named:"filteringResultEmptyImage")!, labelText: "검색 결과가 없습니다. \n 다른 검색어를 입력해 보세요.").view!
    
    let searchTextEmptyView = EmptyUIView(image: UIImage(named: "searchTextEmptyImage")!, labelText: "게시글의 제목, 내용 또는 작성자에 포함된 \n 단어 또는 문장을 검색해 주세요.").view!
    //MARK: - functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        searchTypeTableView.backgroundColor = UIColor(named: "tableViewBackColor")!
        filteringTableView.backgroundColor = UIColor(named: "tableViewBackColor")!
        
        self.searchBar.delegate = self
        self.searchBar.placeholder = "\(viewModel!.boardTitle)에서 검색"
        self.searchBar.showsCancelButton = true
        
        searchTypeTableView.delegate = self
        searchTypeTableView.dataSource = self
        searchTypeTableView.isHidden = true
        
        filteringTableView.delegate = self
        filteringTableView.dataSource = self
        filteringTableView.isHidden = true
        
        self.view.addSubview(searchTextEmptyView)
        self.view.addSubview(filteringResultEmptyView)
        
        searchTextEmptyView.translatesAutoresizingMaskIntoConstraints = false
        searchTextEmptyView.isHidden = false
        
        filteringResultEmptyView.translatesAutoresizingMaskIntoConstraints = false
        filteringResultEmptyView.isHidden = true
        
        //self.view.addSubview(self.searchBar)
        self.view.addSubview(self.searchTypeTableView)
        self.view.addSubview(self.filteringTableView)
        
        setLayout()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchBar)
    }
    
    func setLayout(){
        searchTextEmptyView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        filteringResultEmptyView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        searchBar.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.size.width - 40)
            make.height.equalTo(40)
        }
        
        self.searchTypeTableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        self.filteringTableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    // 서치바에서 검색버튼을 눌렀을 때 호출
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        
        // 테이블 뷰를 업데이트
        searchTypeTableView.isHidden = false
        filteringTableView.isHidden = true
        searchTypeTableView.reloadData()
        
        searchTextEmptyView.isHidden = true
        
    }
    
    // UISearchBarDelegate를 준수하여 검색바에 포커싱이 가해질 때 호출되는 메서드 구현
       func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
           // 검색바에 포커싱이 가해질 때, 입력된 텍스트를 비움
           
           if !filteringTableView.isHidden || !filteringResultEmptyView.isHidden {
               filteringResultEmptyView.isHidden = true
               searchTextEmptyView.isHidden = false

               searchBar.text = ""
               viewModel.filteringPosts = []
               viewModel.page = 1
               viewModel.isFetchingData = false
               viewModel.allDataLoaded = false

           }
       }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 검색 바에 입력된 텍스트를 뷰 모델의 inputText에 할당
        viewModel!.inputText = searchText
    }
    
    // 서치바에서 취소 버튼을 눌렀을 때 호출
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = ""
        searchTypeTableView.isHidden = true
        filteringTableView.isHidden = true
        
        self.dismiss(animated: true)
    }
    
    // 서치바 키보드 내리기
    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    // UITableViewDataSource 메소드 구현
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchTypeTableView {
            return SearchViewModel.Types.allCases.count
        } else {
            return viewModel.filteringPosts.count
        }
    }
    
    func updateUIForEmptyState() {
        if viewModel.filteringPosts.isEmpty {
            // Show the empty state view
            filteringResultEmptyView.isHidden = false

            // Hide the TableView
            filteringTableView.isHidden = true
        } else {
            // Hide the empty state view
            filteringResultEmptyView.isHidden = true

            // Show the TableView
            filteringTableView.isHidden = false
        }
        
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == searchTypeTableView {
            // 사용자 정의 셀을 dequeue합니다.
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath) as! SearchTableViewCell
            
            cell.configureCell(filter: SearchViewModel.Types.allCases.map{$0.korValue}[indexPath.row], recent: "\(viewModel.inputText)")
            return cell
        } else {
            // 사용자 정의 셀을 dequeue합니다.
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell else {
                fatalError("not found")
            }
            
            
            
            guard let data = viewModel?.filteringPosts[indexPath.row] else { return cell }
            
            switch viewModel.selectedSearchType {
            case .all:
                cell.writerLabel.attributedText = highlightSearchText(text: data.writer.displayName)
                cell.titleLabel.attributedText = highlightSearchText(text: data.title)
            case .contents:
                break
            case .title:
                cell.titleLabel.attributedText = highlightSearchText(text: data.title)
                cell.writerLabel.text = data.isAnonymous ? data.writer.displayName : "익명"
            case .writer:
                if data.isAnonymous {
                    cell.writerLabel.text = "익명"
                } else {
                    cell.writerLabel.attributedText = highlightSearchText(text: data.writer.displayName)
                }
                cell.titleLabel.text = data.title
            case .none:
                break
            }
            
            
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
            
            // 데이터를 셀에 설정합니다.
            cell.configureSearchTableViewCell(time: data.postDate, viewCount: data.viewCount)
            
            return cell
        }
    }
    
    // UITableViewDelegate 메소드 구현 (예: 셀 선택 시 동작)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == searchTypeTableView {
            searchTypeTableView.isHidden = true
            filteringTableView.isHidden = false
            viewModel.selectedSearchType = SearchViewModel.Types.allCases[indexPath.row]
            if viewModel.selectedSearchType != .contents {
                setAttributeSerachBarText(index: indexPath.row)
            } else {
                filteringTableView.isHidden = true
                filteringResultEmptyView.isHidden = false
            }
        }
    }
    
    func setAttributeSerachBarText(index: Int){
        let searchType = SearchViewModel.Types.allCases[index]
        //검색 후 searchBar의 텍스트 형식 변경
        let combinedText = "\(searchType.korValue) : \(searchBar.text!)"
        
        let attributedString = NSMutableAttributedString(string: combinedText)
        
        // 서로 다른 텍스트에 서로 다른 스타일을 적용할 수 있습니다.
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: NSRange(location: 0, length: searchType.korValue.count + 3))
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), range: NSRange(location: 0, length: searchType.korValue.count + 3))
        
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: searchType.korValue.count + 3, length: searchBar.text?.count ?? 0))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: searchType.korValue.count + 3, length: searchBar.text?.count ?? 0))
        
        searchBar.searchTextField.attributedText = attributedString

        viewModel.fetchData {
            DispatchQueue.main.async {
                self.updateUIForEmptyState()
                self.filteringTableView.reloadData()
            }
        }
    }
    
    func highlightSearchText(text: String) -> NSAttributedString {
        guard let searchKey = viewModel?.inputText.lowercased(), !searchKey.isEmpty else {
                return NSAttributedString(string: text)
            }

            let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.foregroundColor, value: UIColor(named: "searchKeyColor")!, range: (text as NSString).range(of: searchKey, options: .caseInsensitive))

            return attributedString
        }
}

extension SearchViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard !filteringTableView.isHidden else {return}
        
        let contentOffset_y = scrollView.contentOffset.y
        let tableViewContentSize = filteringTableView.contentSize.height
        
        if contentOffset_y > tableViewContentSize - 100 - scrollView.frame.size.height{
            
            guard !viewModel.apiService.isPagination else { return }
            
            DispatchQueue.main.async {
                self.filteringTableView.tableFooterView = self.view.createSpinerFotter()
            }
            
            viewModel.loadNextPage { [weak self] in
                guard let self = self else { return }
                
                DispatchQueue.main.async{
                    self.filteringTableView.tableFooterView = nil
                    self.filteringTableView.reloadData()
                }
                
            }
        }
    }
}
