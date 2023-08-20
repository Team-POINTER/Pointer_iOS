//
//  FriendsListViewController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/05/13.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

class FriendsListViewController: BaseViewController {
    //MARK: - Properties
    var disposeBag = DisposeBag()
    let viewModel: FriendsListViewModel
    
    let searchHeaderView = FriendsListHeaderView()
    
    let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .pointerRed
        button.tintColor = .white
        return button
    }()
    
    lazy var collectionView: UserListCollectionView = {
        let view = UserListCollectionView(type: viewModel.listType)
        view.showFriendCountLabel = viewModel.listType == .normal ? true : false
        view.friendCountTitle = "친구"
        view.friendsListCelldelegate = self
        view.relationshipDelegate = self
        view.viewModel = self.viewModel
        return view
    }()
    
    //MARK: - Lifecycle
    init(viewModel: FriendsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        bind()
    }
    
    //MARK: - bind
    func bind() {
        let input = FriendsListViewModel.Input(
            searchTextFieldEditEvent: searchHeaderView.searchTextField.rx.text.orEmpty.asObservable(),
            collectionViewItemSelected: collectionView.collectionView.rx.itemSelected.asObservable(),
            collectionViewModelSelected: collectionView.collectionView.rx.modelSelected(FriendsModel.self).asObservable(),
            confirmButtonTappedEvent: confirmButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        
        confirmButton.setAttributedTitle(viewModel.getInitialButtonAttributeString(), for: .normal)
        
        // 뷰모델에서 받은 유저 리스트를 커스텀 collectionView의 데이터소스로
        viewModel.userList
            .bind(to: collectionView.userList)
            .disposed(by: disposeBag)
        
        // 다음 뷰
        viewModel.nextViewController
            .bind { [weak self] vc in
                if let vc = vc {
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        output.buttonAttributeString
            .bind { [weak self] attribute in
                self?.confirmButton.setAttributedTitle(attribute, for: .normal)
            }
            .disposed(by: disposeBag)
        
        viewModel.dismiss
            .bind { [weak self] type in
                switch type {
                case .sucess:
                    self?.navigationController?.popToRootViewController(animated: true)
                case .roomMemberNotExist:
                    self?.dismissAlert(title: "돌아가기", description: "룸 멤버가 존재하지 않습니다.") {
                        print("룸 멤버 존재 Alert error")
                    }
                case .roomCreateOverLimit:
                    self?.dismissAlert(title: "돌아가기", description: "룸 인원이 초과되었습니다.") {
                        print("룸 인원 초과 Alert error")
                    }
                case .none:
                    print("룸 생성 수 초과 error도 생각 해야할 듯!")
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.inviteLink
            .bind { [weak self] link in
                guard let self = self else { return }
                
                var shareObject = [Any]()
                
                shareObject.append(link)
                
                let activityViewController = UIActivityViewController(activityItems : shareObject, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                
                //activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.mail]
                
                self.present(activityViewController, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - Selector
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func linkButtonTapped() {
        viewModel.inviteFriendWithLinkRequest()
    }
    
    @objc private func plusButtonTapped() {
        print("plus Button Tapped")
    }
    
    //MARK: - Functions
    func setupUI() {
        view.backgroundColor = .clear
        view.addSubview(searchHeaderView)
        view.addSubview(collectionView)
        
        searchHeaderView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(60)
        }
        
        switch viewModel.listType {
        // 타입이 Select일 경우
        case .select:
            // 버튼 추가
            view.addSubview(confirmButton)
            confirmButton.snp.makeConstraints {
                $0.width.equalToSuperview()
                $0.height.equalTo(60)
                $0.bottom.equalTo(view.safeAreaLayoutGuide)
                confirmButton.layer.cornerRadius = 13
                confirmButton.clipsToBounds = true
            }
            
            collectionView.snp.makeConstraints {
                $0.top.equalTo(searchHeaderView.snp.bottom)
                $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
                $0.bottom.equalTo(confirmButton.snp.top)
            }
        // 타입이 Normal일 경우
        case .normal:
            collectionView.snp.makeConstraints {
                $0.top.equalTo(searchHeaderView.snp.bottom)
                $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
                $0.bottom.equalToSuperview()
            }
        }
    }
    
    func setupNavigationBar() {
        switch viewModel.listType {
        case .select:
            navigationItem.title = "룸 이름"
            navigationItem.leftBarButtonItem = UIBarButtonItem.getPointerBackBarButton(target: self, handler: #selector(backButtonTapped))
            
            let linkImage = UIImage(systemName: "link")
            let rightBarButton = UIBarButtonItem.getPointerBarButton(withIconimage: linkImage, target: self, handler: #selector(linkButtonTapped))
            navigationItem.rightBarButtonItem = rightBarButton
        case .normal:
            navigationItem.title = "OOO님의 친구"
            navigationItem.leftBarButtonItem = UIBarButtonItem.getPointerBackBarButton(target: self, handler: #selector(backButtonTapped))
            
            let plusImage = UIImage(systemName: "plus")
            let rightBarButton = UIBarButtonItem.getPointerBarButton(withIconimage: plusImage, target: self, handler: #selector(plusButtonTapped))
            navigationItem.rightBarButtonItem = rightBarButton
        }
    }
    
    func dismissAlert(title: String, description: String, completion: @escaping() -> Void) {
        let backAction = PointerAlertActionConfig(title: title, textColor: .black, backgroundColor: .clear, font: .notoSansBold(size: 16), handler: { [weak self] _ in
            self?.dismiss(animated: true)
            completion()
        })
    
        let alert = PointerAlert(alertType: .alert, configs: [backAction], description: description)
        present(alert, animated: true)
    }
}

extension FriendsListViewController: FriendsListCellDelegate {
    func userSelected(user: FriendsListResultData) {
        // something
    }
}

extension FriendsListViewController: RelationshipFriendActionDelegate {
    func showActionAlert(alert: PointerAlert) {
        self.present(alert, animated: true)
    }
    
    func didFriendRelationshipChanged() {
        viewModel.requestFriendList()
    }
}
