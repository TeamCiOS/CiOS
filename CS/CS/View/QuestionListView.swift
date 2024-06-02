//
//  QuestionListView.swift
//  CS
//
//  Created by Ko Seokjun on 5/28/24.
//

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import UIKit

class QuestionListView: UIViewController, View, UITableViewDelegate {
  var disposeBag: DisposeBag = DisposeBag()
  let activityIndicator = UIActivityIndicatorView(style: .large)
  let tableView = UITableView()
  var titleLabel: UILabel = {
    let uiLabel = UILabel()
    uiLabel.text = "네트워크 오류"
    uiLabel.font = .systemFont(ofSize: 20, weight: .bold)
    return uiLabel
  }()
  
  init(reactor: QuestionListReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureNavigation()
    configureView()
    initConstraint()
    reactor?.action.onNext(Reactor.Action.enterView)
  }
}

extension QuestionListView {
  func configureNavigation() {
    self.title = "문제 선택하기"
  }
  
  func configureView() {
    let view = UIView()
    self.view = view
    view.backgroundColor = .systemBackground
    tableView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
    tableView.layer.cornerRadius = 10
    tableView.separatorInset.left = 0
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 44
    tableView.register(
      QuestionCell.self,
      forCellReuseIdentifier: "QuestionCell"
    )
    tableView.rowHeight = UITableView.automaticDimension
    [titleLabel, tableView, activityIndicator].forEach {
      self.view.addSubview($0)
    }
  }
  
  func initConstraint() {
    activityIndicator.snp.makeConstraints {
      $0.centerX.centerY.equalToSuperview()
      $0.width.height.equalTo(50)
    }
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
      $0.leading.equalToSuperview().offset(20)
    }
    tableView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(12)
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-20)
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-12)
    }
  }
  
  func bind(reactor: QuestionListReactor) {
    tableView.rx.modelSelected(Problem.self)
      .map { Reactor.Action.selectQuestion($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    reactor.state.map { $0.selectedCategory.name }
      .asDriver(onErrorJustReturn: "error")
      .drive(titleLabel.rx.text)
      .disposed(by: disposeBag)
    reactor.state.map { $0.isLoading }
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] isLoading in
        if isLoading {
          self?.activityIndicator.startAnimating()
          self?.activityIndicator.isHidden = false
        }
        else {
          self?.activityIndicator.stopAnimating()
          self?.activityIndicator.isHidden = true
        }
      })
      .disposed(by: disposeBag)
    reactor.state.map { $0.questionList }
      .asDriver(onErrorJustReturn: [Problem]())
      .drive(tableView.rx.items(cellIdentifier: "QuestionCell", cellType: QuestionCell.self)) { idx, item, cell in
        cell.numLabel.text = "\(item.orderNum)"
        cell.titleLabel.text = item.question
      }
      .disposed(by: disposeBag)
    reactor.state.map { $0.selectedQuestion }
      .observe(on: MainScheduler.asyncInstance)
      .compactMap { $0 }
      .subscribe(onNext: { [weak self, weak reactor] problem in
        let caroselView = CardCaroselView(reactor: CaroselReactor(selectedQuestion: problem))
        self?.navigationController?.pushViewController(caroselView, animated: true)
        reactor?.action.onNext(.clearQuestion)
      })
      .disposed(by: disposeBag)
  }
}

