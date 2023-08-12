//
//  FullScreenController.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/08/12.
//

import UIKit
import SnapKit
import RxGesture
import RxSwift

class PointerFullScreenPhotoView: UIViewController {
    //MARK: - Properties
    var initialCenter: CGPoint?
    let dismissThreshold: CGFloat = 150.0
       
    let image: UIImage?
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    let disposeBag = DisposeBag()
    
    //MARK: - Lifecycle
    init(image: UIImage?) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        setupUI()
        setupGesture()
    }
    
    //MARK: - Methods
    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(dismissButton)
        dismissButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(Device.topInset + 20)
            $0.width.height.equalTo(25)
        }
    }
    
    private func setupGesture() {
        // 닫기 버튼 누를 때
        dismissButton.rx.tap
            .bind { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        setupSwipeToDismissGesture()
    }
    
    func setupSwipeToDismissGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        
        let translationY = translation.y <= 0 ? CGFloat(0) : translation.y
        
        switch recognizer.state {
        case .began:
            initialCenter = view.center
            
        case .changed:
            guard let initialCenter = initialCenter else { return }
            view.center = CGPoint(x: initialCenter.x,
                                  y: initialCenter.y + translationY)
            
        case .ended:
            guard let initialCenter = initialCenter else { return }
            let distanceMoved = view.center.y - initialCenter.y
            
            if distanceMoved > dismissThreshold {
                dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.center = initialCenter
                }
            }
            
        default:
            break
        }
    }
}
