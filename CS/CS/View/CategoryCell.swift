//
//  CategoryCell.swift
//  CS
//
//  Created by Ko Seokjun on 5/27/24.
//

import SnapKit
import UIKit

class CategoryCell: UITableViewCell {
  var mode: StudyMode = .basic
  var containerView: UIView = {
      let view = UIView()
      view.layer.cornerRadius = 12
      view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
      return view
    }()
  var chapterLabel: UILabel = {
    let uiLabel = UILabel()
    uiLabel.font = .systemFont(ofSize: 12)
    return uiLabel
  }()
  var titleLabel: UILabel = {
    let uiLabel = UILabel()
    uiLabel.font = .systemFont(ofSize: 20, weight: .thin)
    return uiLabel
  }()
  var star: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(systemName: "star.fill")
    view.tintColor = UIColor(red: 0.17, green: 0.68, blue: 0.27, alpha: 1)
    return view
  }()
  var cntLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 16)
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(containerView)
    [chapterLabel, titleLabel, star, cntLabel].forEach {
      self.containerView.addSubview($0)
    }
    initConstraint()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension CategoryCell {
  func initConstraint() {
    containerView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(20)
      $0.top.bottom.equalToSuperview().inset(4)
    }
    
    chapterLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview().offset(16)
    }
    
    titleLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalTo(chapterLabel.snp.trailing).offset( mode == .basic ? 22 : 0 )
    }
    
    star.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().offset(-52)
    }
    
    cntLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalTo(star.snp.trailing).offset(4)
    }
  }
}
