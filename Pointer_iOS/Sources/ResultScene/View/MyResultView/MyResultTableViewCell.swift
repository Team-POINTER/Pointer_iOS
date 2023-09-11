//
//  MyResultTableViewCell.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/25.
//

import UIKit
import SnapKit

class MyResultTableViewCell: UITableViewCell {
    
    static let identifier = "MyResultTableViewCell"
    
    var result: TotalQuestionResultData? {
        didSet {
            configure()
        }
    }
    
    //MARK: - Properties
    private var backView: HintBackgroundView = {
        $0.layer.cornerRadius = 16
        return $0
    }(HintBackgroundView())
    
    private var questionLabel: UILabel = {
        $0.text = "가장 친해지고 싶은 사람은?"
        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 18)
        $0.textColor = UIColor.white
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    private var selectedMeNumber: UILabel = {
        $0.text = "3 / 20"
        $0.font = UIFont.notoSansBold(size: 18)
        $0.textColor = UIColor.pointerRed
        return $0
    }(UILabel())
    
    private var hintDate: UILabel = {
        $0.text = "23.03.25"
        $0.font = UIFont.notoSansRegular(size: 13)
        $0.textColor = UIColor.white
        return $0
    }(UILabel())
    
    //MARK: - Life Cycles
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUIandConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //MARK: - set UI
    private func setUIandConstraints() {
        backgroundColor = .clear
        
        contentView.addSubview(backView)
        backView.addSubview(questionLabel)
        backView.addSubview(selectedMeNumber)
        backView.addSubview(hintDate)
        
        backView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(9)
        }
        questionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24.47)
            make.leading.trailing.equalToSuperview().inset(21.61)
        }
        selectedMeNumber.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(21.61)
            make.bottom.equalToSuperview().inset(20.48)
        }
        hintDate.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(16.48)
        }
    }

    func configure() {
        guard let result = result else { return }
        questionLabel.text = result.question
        selectedMeNumber.text = "\(result.votedMemberCnt) / \(result.allVoteCnt)"
        hintDate.text = result.createdAt
    }
    
}
