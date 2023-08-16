//
//  NotificationViewController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/25.
//

import UIKit
import BetterSegmentedControl
import SnapKit
import RxSwift

class NotificationViewController: BaseViewController {
    //MARK: - Properties
    var disposeBag = DisposeBag()
    
    // 세그먼트 컨트롤
    private lazy var notiTypeSegmentControl: BetterSegmentedControl = {
        let notiIcon = UIImage(named: "notiIcon") ?? UIImage()
        let personIcon = UIImage(named: "personIcon") ?? UIImage()
        let segment = IconSegment.segments(withIcons: [notiIcon, personIcon], iconSize: CGSize(width: 17, height: 17), normalBackgroundColor: .clear, normalIconTintColor: .gray, selectedBackgroundColor: .white, selectedIconTintColor: .black)
        let control = BetterSegmentedControl(frame: .zero, segments: segment, options: [.cornerRadius(21), .backgroundColor(.clear), .indicatorViewBackgroundColor(.white), .indicatorViewInset(0)])
        return control
    }()
    
    // 뷰컨트롤러s
    lazy var roomNotiVC = NotificationDetailViewController(withNotificationType: .room(viewModel: NotiDetailRoomViewModel()))
    lazy var friendsNotiVC = NotificationDetailViewController(withNotificationType: .friends(viewModel: NotiDetailFriendsViewModel()))
    
    lazy var viewControllers = [roomNotiVC, friendsNotiVC]
    lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        return vc
    }()
    
    // 현재 페이지
    var currentPage: Int = 0 {
        didSet {
            configurePage(previousPage: oldValue, currentPage: currentPage)
        }
    }
    
    //MARK: - Lifecycle
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavi()
        setupPageViewController()
        setupUI()
        bind()
    }
    
    //MARK: - Bind
    private func bind() {
        notiTypeSegmentControl.rx
            .controlEvent(.valueChanged)
            .map { [weak self] in return self?.notiTypeSegmentControl.index }
            .subscribe { [weak self] event in
                if let index = event.element?.flatMap({ $0 }) {
                    self?.currentPage = index
                }
            }.disposed(by: disposeBag)
    }
    
    //MARK: - Selector
    @objc private func backButtonTapped() {
        self.navigationController?.dismissWithNavigationPopStyle()
    }
    
    //MARK: - Functions
    private func setupNavi() {
        navigationItem.title = "알림"
        
        let backButtonImage = UIImage(systemName: "chevron.backward")
        let backButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButtonImage, size: Device.navigationBarHeight, target: self, handler: #selector(backButtonTapped))
        
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func configurePage(previousPage: Int, currentPage: Int) {
        let direction: UIPageViewController.NavigationDirection = previousPage < currentPage ? .forward : .reverse
        pageViewController.setViewControllers([viewControllers[currentPage]], direction: direction, animated: true)
        
        notiTypeSegmentControl.setIndex(currentPage)
    }
    
    private func setupPageViewController() {
        pageViewController.delegate = self
        pageViewController.dataSource = self
        if let firstVC = viewControllers.first {
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    private func setupUI() {
        view.addSubview(notiTypeSegmentControl)
        notiTypeSegmentControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(84)
            $0.height.equalTo(41)
        }
        
        // 페이지 뷰 컨트롤러
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        
        pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(notiTypeSegmentControl.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        pageViewController.didMove(toParent: self)
    }
}

extension NotificationViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? NotificationDetailViewController,
              let index = viewControllers.firstIndex(of: vc) else { return nil }
        let previousIndex = index - 1
        if previousIndex < 0 {
            return nil
        }
        return viewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? NotificationDetailViewController,
              let index = viewControllers.firstIndex(of: vc) else { return nil }
        let nextIndex = index + 1
        if nextIndex == viewControllers.count {
            return nil
        }
        return viewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentVC = pageViewController.viewControllers?.first as? NotificationDetailViewController,
              let currentIndex = viewControllers.firstIndex(of: currentVC) else { return }
        currentPage = currentIndex
    }
}
