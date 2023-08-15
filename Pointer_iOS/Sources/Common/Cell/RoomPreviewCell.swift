//
//  RoomPreviewCell.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/11.
//

import UIKit
import SnapKit

protocol RoomPreviewCellDelegate: AnyObject {
    func roomCellActionImageTapped(roomId: Int, _ currentName: String)
}

class RoomPreviewCell: UICollectionViewCell {
    //MARK: - Identifier
    static let identifier = "RoomPreviewCell"
    
    //MARK: - Properties
    var roomViewModel: RoomCellViewModel? {
        didSet {
            configure()
        }
    }
    
    weak var delegate: RoomPreviewCellDelegate?
    
    let roomNameLabel: UILabel = {
        let label = UILabel()
        label.text = "우리 반"
        label.font = .notoSansRegular(size: 16)
        label.textColor = .rgb(red: 102, green: 102, blue: 102)
        return label
    }()
    
    let roomBodyLabel: UILabel = {
        let label = UILabel()
        label.text = "첫 인상이 가장 좋은 사람"
        label.font = .notoSansBold(size: 18)
        label.textColor = .black
        return label
    }()
    
    let memberCountLabel: UILabel = {
        let label = UILabel()
        label.text = "5 명"
        label.font = .notoSansRegular(size: 13)
        label.textColor = .pointerRed
        return label
    }()
    
    let starIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "pointer_star")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let leaderNameLabel: UILabel = {
        let label = UILabel()
        label.text = "포인터 님"
        label.font = .notoSansRegular(size: 13)
        label.textColor = .black
        return label
    }()
    
    lazy var actionContainerView: UIView = {
        let view = UIView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(actionImageTapped))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    lazy var actionImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "ellipsis")
        image.transform = image.transform.rotated(by: .pi/2)
        image.tintColor = .black
        image.contentMode = .scaleAspectFit
        image.isUserInteractionEnabled = true
        return image
    }()

    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selector
    @objc func actionImageTapped() {
        if let roomViewModel = roomViewModel {
            delegate?.roomCellActionImageTapped(roomId: roomViewModel.roomModel.roomId, roomViewModel.roomModel.roomNm)
        }
    }
    
    //MARK: - Functions
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 10
        clipsToBounds = false
        
        addSubview(roomNameLabel)
        addSubview(roomBodyLabel)
        addSubview(memberCountLabel)
        addSubview(starIcon)
        addSubview(leaderNameLabel)
        addSubview(actionContainerView)
        
        roomNameLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(21.5)
            $0.height.equalTo(27)
        }
        roomBodyLabel.snp.makeConstraints {
            $0.top.equalTo(roomNameLabel.snp.bottom)
            $0.leading.equalTo(roomNameLabel.snp.leading)
        }
        memberCountLabel.snp.makeConstraints {
            $0.leading.equalTo(roomBodyLabel.snp.leading)
            $0.bottom.equalToSuperview().inset(16)
            $0.width.greaterThanOrEqualTo(23)
        }
        starIcon.snp.makeConstraints {
            $0.leading.equalTo(memberCountLabel.snp.trailing).inset(-10)
            $0.top.equalTo(memberCountLabel)
            $0.bottom.equalTo(memberCountLabel)
        }
        
        leaderNameLabel.snp.makeConstraints {
            $0.leading.equalTo(starIcon.snp.trailing).inset(-3)
            $0.top.equalTo(starIcon)
            $0.bottom.equalTo(starIcon)
        }
        
        actionContainerView.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview().inset(16)
            $0.width.height.equalTo(20)
        }
        
        actionContainerView.addSubview(actionImageView)
        actionImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configure() {
        guard let viewModel = roomViewModel else { return }
        roomNameLabel.text = viewModel.roomModel.roomNm
        roomBodyLabel.text = viewModel.roomModel.question
        memberCountLabel.text = "\(viewModel.roomModel.memberCnt) 명"
        
        if viewModel.roomModel.topUserName == nil || viewModel.roomModel.topUserName == "" {
            starIcon.isHidden = true
            leaderNameLabel.text = ""
        } else {
            starIcon.isHidden = false
            leaderNameLabel.text = viewModel.roomModel.topUserName
        }
    }
}
