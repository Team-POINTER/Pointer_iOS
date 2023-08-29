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
    var viewWillShowIndex: Int?
    var disposeBag = DisposeBag()
    let viewModel: SearchViewModel
    
    let searchBar: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor.navBackColor
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
    
    lazy var roomResultController = SearchResultController(withResultType: .room, viewModel: viewModel)
    lazy var accountResultController = SearchResultController(withResultType: .account, viewModel: viewModel)
    lazy var viewControllers = [roomResultController, accountResultController]
    lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        return vc
    }()

    
    //MARK: - Lifecycle
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
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
        let input = SearchViewModel.Input(searchBarTextEditEvent: searchBar.rx.text.orEmpty.asObservable())
        let output = viewModel.transform(input: input)
        
        resultTypeSegmentControl.rx
            .controlEvent(.valueChanged)
            .map { [weak self] in
                return self?.resultTypeSegmentControl.index
            }
            .subscribe { [weak self] event in
                if let index = event.element?.flatMap({ $0 }) {
                    self?.currentPage = index
                }
            }.disposed(by: disposeBag)
        
        output.tapedNextViewController
            .bind { [weak self] viewController in
                if let vc = viewController {
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.presenter
            .bind { [weak self] viewController in
                if let vc = viewController {
                    let nav = BaseNavigationController.templateNavigationController(nil, viewController: vc)
                    self?.tabBarController?.presentWithNavigationPushStyle(nav)
                }
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - Selector
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
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
        // viewWillShowIndex에 데이터가 있으면 해당 페이지로 이동
        if let index = viewWillShowIndex {
            self.currentPage = index
        }
    }
    
    private func setupNavi() {
        let searchBarWidth = Device.width - Device.navigationBarHeight - 55
        searchBar.widthAnchor.constraint(equalToConstant: searchBarWidth).isActive = true
        
        let backButtonImage = UIImage(systemName: "chevron.backward")
        let backButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButtonImage, size: Device.navigationBarHeight, target: self, handler: #selector(backButtonTapped))
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
