# 메일 플러그 iOS 개발 사전 과제

## 소개

메일플러그 메일앱 게시판 화면 구현

## 개발 환경

- 언어 : Swift
- Xcode 14 이상에서 빌드 가능
- Deployment Target iOS 14
- Code-based UI로 구현
- 외부 라이브러리 - Alamofire, SnapKit 사용
- UIKit 만 사용
- MVVM 패턴 활용

## 주요 기능

### API Service

- 사용 라이브러리: Alamofire
Alamofire 외부 라이브러리를 사용하여 header에 인증정보를 포함해서 API 요청을 받아 데이터를 디코딩합니다. 
아래의 코드는 API요청을 통한 코드 구현 예시 입니다.

```swift
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
```

API요청에 성공하여 받아온 데이터는 미리 Codable로 채택한 구조체 형식으로 디코딩 합니다.

```swift
struct BoardResponse: Codable {
    let value: [Board]
}

struct Board: Codable{
    let boardId: Int
    let displayName: String
}
```

### MainViewController

---

![MainViewController.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/7e923ea2-f11f-487a-b272-c20816c1932e/3c10c331-a493-403f-a2e4-85f62beb35bf/MainViewController.png)

MainViewController는 게시판이 선택 되어야 함으로 SceneDelegate에서 Board의 첫번째 배열의 값을 가져옵니다. 아래는 SceneDelegate에서 첫번째 값을 가져오는 기능을 구현한 코드입니다.

```swift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    

    let apiService: WebService = WebService()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // 새로운 UIWindow 인스턴스 생성
        let window = UIWindow(windowScene: windowScene)
        
        apiService.getBoards { board in
				//api요청으로 가져온 Board 정보 중 첫번째 값을 가져옵니다.
            if let boardId = board?.first?.boardId, let boardTitle = board?.first?.displayName {
								//가져온 값을 viewModel을 생성하여 대입합니다.
                let viewModel = PostListViewModel(id: boardId, title: boardTitle)
								//MainViewController를 생성합니다. view에 viewModel을 대입하여 주기 위해 UIStoryBoard 함수를 사용하여 MainViewController를 초기화 시켜줍니다.
                let rootViewController = UIStoryboard(name: "Main", bundle: .main).instantiateInitialViewController { code in
                    MainViewController(coder: code, viewModel: viewModel)
                }
                
                // 루트 뷰 컨트롤러를 설정하여 윈도우에 할당합니다.
                window.rootViewController = UINavigationController(rootViewController: rootViewController!)
                
                // 윈도우를 화면에 표시합니다.
                self.window = window
                window.makeKeyAndVisible()
            }
        }
    }
}
```

받아온 Board Id와 displayTitle을 MainViewController에 표시하고, 해당 게시판의 Id를 사용하여 게시글 목록을 받아옵니다. MainViewController를 포함한 모든 View는 외부라이브러리인 Snapkit를 사용하여 Auto Layout에 맞게 구현하였습니다.

MainViewController의 게시글 리스트는 Board와 같이 Post라는 구조체를 Codable을 채택하여 구현하였고, baseURL에 boardId, offset, limit정보를 받아오고 pagination 값을 통해 30개씩 화면에 띄울 수 있도록 구현하였습니다. UIScrollViewDelegate를 채택하여 Scroll이 맨 밑으로 가면 값을 받아옵니다. 
아래 코드는 scrollView가 맨 밑으로 향했을 때 실행하는 코드와 ViewModel에 다음 페이지를 받아오도록 구현한 코드입니다.

```swift
extension MainViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentOffset_y = scrollView.contentOffset.y
        let tableViewContentSize = tableView.contentSize.height
        
        if contentOffset_y > tableViewContentSize - 100 - scrollView.frame.size.height{
            
            guard !viewModel.apiService.isPagination else { return }
            
            DispatchQueue.main.async{
								//스크롤을 밑으로 당겼을 때 로딩 뷰를 실행합니다.
                self.tableView.tableFooterView = self.view.createSpinerFotter()
            }
            
						//모든 리스트를 불러오지 않았다면 실행하지 않습니다.
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
```

```swift
func loadNextPage(completion: @escaping () -> Void){
        guard !isFetchingData, !allDataLoaded else {
            completion()
            return
        }
        
        isFetchingData = true
        
        apiService.getPosts(pagination: true, boardId: boardId!, offset: posts.count) { [weak self] response in
            
            guard let self = self else { return }
            if let response = response {
                if response.value.isEmpty {
                    allDataLoaded = true
                } else {
                    posts.append(contentsOf: response.value)
                    page += 1
                }
            }
            else {
                print("error")
            }
            
            isFetchingData = false
            completion()
            
        }
    }
```

### BoardListViewController

---

![BoardListView.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/7e923ea2-f11f-487a-b272-c20816c1932e/a7d4aba8-e4a5-411b-8268-27a19350399e/BoardListView.png)

MainViewController에서 hambuger menu bar button을 클릭하면 BoardListViewController를 present로 띄웁니다. BoardListViewController에서 tableView cell을 선택했을 때, boardId와 board displayname정보를 받아오기 위하여 completionHandler를 사용하여 BoardListViewController가 dismiss됐을 때에도 데이터를 받아올 수 있도록 구현하였습니다.

```swift
@objc func tapMenuButton(_ sender: UIButton){
        
    // UINavigationController를 생성하고 rootViewController로 새로운 UIViewController를 설정
    let controller = BoardListViewController()
    
		//escaping closure를 사용하여 함수의 실행 흐름에 상관 없이 실행합니다.
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
```

### SearchViewController

---

![SearchViewController.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/7e923ea2-f11f-487a-b272-c20816c1932e/854481da-36b2-4ede-b846-74cdfea30af5/SearchViewController.png)

SearchViewController는 MainViewController에서 search 버튼을 탭했을 때 나오는 View입니다. 텍스트가 입력되지 않았을 때 EmptyViewController의 View를 띄우도록 구현하였습니다. 

검색창에서 검색을 했을 때 범위를 선택할 수 있도록 tableView를 띄웁니다. 검색된 단어가 있을 경우에는 해당 단어를 NSAttributedString을 사용하여 빨간색으로 만듭니다.

searchTableView에서 검색 타입을 선택하면 검색창에 타입과 검색 단어를 띄울 수 있도록 구현하였습니다.

```swift
func setAttributeSerachBarText(index: Int){
      let searchType = SearchViewModel.Types.allCases[index]
      //검색 후 searchBar의 텍스트 형식 변경 (전체를 선택했을 경우 "전체 : [검색내용]" 으로 표시되게 설정합니다
      let combinedText = "\(searchType.korValue) : \(searchBar.text!)"
      
      let attributedString = NSMutableAttributedString(string: combinedText)
      
      // 서로 다른 텍스트에 서로 다른 스타일을 적용할 수 있습니다.
			// 타입 글짜의 attributedString 속성을 설정합니다.
      attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: NSRange(location: 0, length: searchType.korValue.count + 3))
      attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), range: NSRange(location: 0, length: searchType.korValue.count + 3))
      
			// 검색한 단어의 attributeString 속성을 설정합니다.
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
```

검색 단어와 타입을 baseURL에 추가하여 API 요청을 합니다. MainViewController에서 선택한 board의 리스트에서 검색하며, 검색한 단어와 검색 범위에 해당하는 게시글이 없다면 EmptyViewController의 View를 띄웁니다. MainViewController와 동일하게 30개씩 불러올 수 있도록 pagination 기능을 추가하였습니다.

아래의 코드는 검색된 단어를 찾아 빨간색으로 highlight하는 코드 입니다. 

```swift
switch viewModel.selectedSearchType {
//선택된 타입의 string에서 선택된 단어만 빨갛게 표시합니다.
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

func highlightSearchText(text: String) -> NSAttributedString {
		//대문자로 입력되는 경우, 소문자로 바꿔 선택된 단어가 있는지 검색합니다.
    guard let searchKey = viewModel?.inputText.lowercased(), !searchKey.isEmpty else {
        return NSAttributedString(string: text)
    }
    
		//cell에 입력될 text에서 검색한 단어를 찾아 빨갛게 설정합니다.
    let attributedString = NSMutableAttributedString(string: text)
    attributedString.addAttribute(.foregroundColor, value: UIColor(named: "searchKeyColor")!, range: (text as NSString).range(of: searchKey, options: .caseInsensitive))
    
    return attributedString
}
```
