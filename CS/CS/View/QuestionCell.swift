//
//  QuestionCell.swift
//  CS
//
//  Created by Ko Seokjun on 5/29/24.
//

import UIKit
import SnapKit

class QuestionCell: UITableViewCell {
  var numLabel: UILabel = {
    let uiLabel = UILabel()
    uiLabel.font = .systemFont(ofSize: 12)
    return uiLabel
  }()
  
  var titleLabel: UILabel = {
    let uiLabel = UILabel()
    uiLabel.numberOfLines = 0
    uiLabel.font = .systemFont(ofSize: 12)
    return uiLabel
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
    [numLabel, titleLabel].forEach {
      self.contentView.addSubview($0)
    }
    initConstraint()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension QuestionCell {
  func initConstraint() {
    numLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview().offset(20)
      $0.width.equalTo(36).priority(900)
    }
    
    titleLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalTo(numLabel.snp.trailing).offset(4).priority(899)
      $0.trailing.equalToSuperview().offset(-14)
      $0.top.equalTo(contentView.snp.top).offset(8)
      $0.bottom.equalTo(contentView.snp.bottom).offset(-8)
    }
  }
}

