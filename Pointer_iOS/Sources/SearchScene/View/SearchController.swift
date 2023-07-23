//
//  SearchController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/18.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import BetterSegmentedControl

class SearchController: BaseViewController {
    //MARK: - Properties
    var disposeBag = DisposeBag()
    
    let searchBar: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = .darkGray
        tf.attributedPlaceholder = NSMutableAttributedString(string: "검색어를 입력하세요.", attributes: [NSAttributedString.Key.foregroundColor: UIColor.pointerGray, NSAttributedString.Key.font: UIFont.notoSansRegular(size: 13)])
        tf.textColor = .white
        tf.heightAnchor.constraint(equalToConstant: Device.navigationBarHeight).isActive = true
//        tf.widthAnchor.constraint(equalToConstant: 300).isActive = true
        tf.addLeftPadding(width: 15)
        tf.layer.cornerRadius = 20
        tf.clipsToBounds = true
        return tf
    }()
    
    private lazy var resultTypeSegmentControl: BetterSegmentedControl = {
        let labelSeg = LabelSegment.segments(withTitles: ["룸", "계정"],
                                             normalFont: .notoSans(font: .notoSansKrMedium, size: 13),
                                             normalTextColor: .pointerGray,
                                             selectedFont: .notoSans(font: .notoSansKrMedium, size: 13),
                                             selectedTextColor: .black)
        let seg = BetterSegmentedControl(frame: .zero,
                                         segments: labelSeg,
                                         options: [.cornerRadius(21), .backgroundColor(.clear), .indicatorViewBackgroundColor(.white), .indicatorViewInset(0)])
        return seg
    }()
    
    var currentPage: Int = 0 {
        didSet {
            configurePage(previousPage: oldValue, currentPage: currentPage)
        }
    }
    
    lazy var roomResultController = SearchResultController(withResultType: .room)
    lazy var accountResultController = SearchResultController(withResultType: .account)
    lazy var viewControllers = [roomResultController, accountResultController]
    lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        return vc
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .thin, scale: .default)
        button.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        button.backgroundColor = .pointerRed
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleActionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavi()
        setupUI()
        bind()
        setupPageViewController()
    }
    
    //MARK: - Bind
    private func bind() {
        resultTypeSegmentControl.rx
            .controlEvent(.valueChanged)
            .map { [weak self] in return self?.resultTypeSegmentControl.index }
            .subscribe { [weak self] event in
                if let index = event.element?.flatMap({ $0 }) {
                    self?.currentPage = index
                }
            }.disposed(by: disposeBag)
    }
    
    //MARK: - Selector
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // 액션 버튼 핸들러 (임시)
    @objc private func handleActionButtonTapped() {
        let modifyRoomName = PointerAlertActionConfig(title: "룸 이름 편집", textColor: .pointerAlertFontColor) { [weak self] _ in
            print("DEBUG - 룸 이름 편집 눌림")
            self?.modifyRoomNameAction()
        }
        let inviteRoomWithLink = PointerAlertActionConfig(title: "링크로 룸 초대", textColor: .pointerAlertFontColor) { _ in
            print("DEBUG - 링크로 룸 초대 눌림")
        }
        let exitRoom = PointerAlertActionConfig(title: "룸 나가기", textColor: .pointerRed, font: .boldSystemFont(ofSize: 18)) { _ in
            print("DEBUG - 룸 나가기 눌림")
        }
        let actionSheet = PointerAlert(alertType: .actionSheet, configs: [modifyRoomName, inviteRoomWithLink, exitRoom])
        present(actionSheet, animated: true)
    }
    
    //MARK: - Functionse
    private func configurePage(previousPage: Int, currentPage: Int) {
        let direction: UIPageViewController.NavigationDirection = previousPage < currentPage ? .forward : .reverse
        pageViewController.setViewControllers([viewControllers[currentPage]], direction: direction, animated: true)
        
        resultTypeSegmentControl.setIndex(currentPage)
    }
    
    private func setupPageViewController() {
        pageViewController.delegate = self
        pageViewController.dataSource = self
        if let firstVC = viewControllers.first {
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    private func setupNavi() {
        let searchBarWidth = Device.width - Device.navigationBarHeight - 55
        searchBar.widthAnchor.constraint(equalToConstant: searchBarWidth).isActive = true
        
        let backButtonImage = UIImage(systemName: "chevron.backward")
        let backButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButtonImage, size: Device.navigationBarHeight, target: self, color: UIColor.navBackColor, handler: #selector(backButtonTapped))
        let titleView = UIBarButtonItem(customView: searchBar)
        
        navigationItem.leftBarButtonItems = [backButton, titleView]
    }
    
    private func setupUI() {
        view.addSubview(resultTypeSegmentControl)
        resultTypeSegmentControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(10.6)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(84)
            $0.height.equalTo(42)
        }

        // PAGE VC
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        
        pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(resultTypeSegmentControl.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        pageViewController.didMove(toParent: self)
        
        // 액션 버튼
        view.addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.width.height.equalTo(62)
            $0.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(13)
            actionButton.layer.cornerRadius = 62 / 2
            actionButton.clipsToBounds = true
        }
    }
    
    // 룸 이름 변경 액션 (임시)
    private func modifyRoomNameAction() {
        let confirmAction = PointerAlertActionConfig(title: "확인", textColor: .white, backgroundColor: .pointerRed, font: .notoSansBold(size: 18)) {
            if let text = $0 {
                print("DEBUG - 방이름 : \(text)")
            } else {
                print("변경 내역 없음")
            }
        }
        let cancelAction = PointerAlertActionConfig(title: "취소", textColor: .pointerAlertFontColor, backgroundColor: .clear, font: .notoSansBold(size: 18), handler: nil)
        let customView = CustomTextfieldView(roomName: "임시 방 이름", withViewHeight: 50)
        let alert = PointerAlert(alertType: .alert, configs: [confirmAction, cancelAction], title: "방 이름 변경", description: "변경할 이름을 입력해주세요", customView: customView)
        self.present(alert, animated: true)
    }
}

extension SearchController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? SearchResultController,
              let index = viewControllers.firstIndex(of: vc) else { return nil }
        let previousIndex = index - 1
        if previousIndex < 0 {
            return nil
        }
        return viewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? SearchResultController,
              let index = viewControllers.firstIndex(of: vc) else { return nil }
        let nextIndex = index + 1
        if nextIndex == viewControllers.count {
            return nil
        }
        return viewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentVC = pageViewController.viewControllers?.first as? SearchResultController,
              let currentIndex = viewControllers.firstIndex(of: currentVC) else { return }
        currentPage = currentIndex
    }
}
