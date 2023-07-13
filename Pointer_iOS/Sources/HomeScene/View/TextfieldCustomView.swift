//
//  TextfieldCustomView.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/15.
//

import UIKit
import RxSwift
import SnapKit

protocol CustomTextfieldViewDelegate: AnyObject {
    func textDidChanged(text: String)
}

class CustomTextfieldView: UIView {
    //MARK: - Properties
    lazy var textfield: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor.rgb(red: 239, green: 239, blue: 239)
        tf.placeholder = "룸 이름을 입력하세요"
        tf.font = .notoSansRegular(size: 16)
        tf.delegate = self
        tf.textColor = .black
        return tf
    }()
    
    let wordLimitLabel: UILabel = {
        let label = UILabel()
        label.font = .notoSans(font: .notoSansKrLight, size: 13)
        label.textColor = UIColor.rgb(red: 102, green: 102, blue: 102)
        return label
    }()
    
    weak var delegate: CustomTextfieldViewDelegate?
    
    let height: CGFloat
    let maximumCharacterCount: Int = 15
    var currentCharacterCount = PublishSubject<Int>()
    let disposeBag = DisposeBag()
    
    //MARK: - Lifecycle
    init(roomName: String, withViewHeight height: CGFloat) {
        self.height = height
        super.init(frame: .zero)
        bind()
        setupUI()
        self.textfield.text = roomName
        self.currentCharacterCount.onNext(roomName.count)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Bind
    private func bind() {
        currentCharacterCount.subscribe { [weak self] in
            if let count = $0.element {
                self?.configureWordLimitView(current: count)
            }
        }.disposed(by: disposeBag)
    }
    
    //MARK: - Functions
    private func setupUI() {
        heightAnchor.constraint(equalToConstant: height).isActive = true
        
        addSubview(textfield)
        textfield.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.top.bottom.equalToSuperview()
        }
        
        textfield.layer.cornerRadius = height / 2
        textfield.clipsToBounds = true
        textfield.addLeftPadding(width: 15)
        textfield.rightView = wordLimitLabel
        textfield.rightViewMode = .always
    }
    
    private func configureWordLimitView(current: Int) {
        wordLimitLabel.text = "\(current) / \(maximumCharacterCount)    "
    }
}

extension CustomTextfieldView: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textfield.text else { return }
        currentCharacterCount.onNext(text.count)
        delegate?.textDidChanged(text: text)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        guard textField.text!.count < maximumCharacterCount else { return false }
        return true
    }
}

extension UITextField {
    func addLeftPadding(width: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
}
