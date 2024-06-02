//
//  RootView.swift
//  CS
//
//  Created by Ko Seokjun on 5/27/24.
//

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import UIKit

class RootView: UIViewController, View, UITableViewDelegate {
  var disposeBag: DisposeBag = DisposeBag()
  let rightButton = UIBarButtonItem(image: UIImage(systemName: "star"), style: .plain, target: nil, action: nil)
  var tableView = UITableView()
  let activityIndicator = UIActivityIndicatorView(style: .large)
  // ReactorKit은 reactor값이 변해야 bind메소드가 작동되기 때문에 reactor 필요
  // 그래서 사용하기 편하게 이니셜라이즈를 추가 작성
  init(reactor: RootReactor) {
    super.init(nibName: nil, bundle: nil)
    // View의 기본 구현
    self.reactor = reactor
  }
  // 코드로 뷰 생성할 때, 사용 -> 사용할 필요가 없는데, 쓰고 있기 때문
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureNavigation()
    configureView()
    initConstraint()
    reactor?.action.onNext(.getCategory)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
}

extension RootView {
  func configureNavigation() {
    navigationController?.navigationBar.backgroundColor = .clear
    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController?.navigationBar.shadowImage = UIImage()
    navigationController?.hidesBarsOnSwipe = true
    self.navigationItem.rightBarButtonItem = rightButton
    self.title = "CS"
  }
  
  func configureView() {
    let view = UIView()
    self.view = view
    view.backgroundColor = .systemBackground
    tableView.register(
      CategoryCell.self,
      forCellReuseIdentifier: "CategoryCell"
    )
    tableView.rx.rowHeight.onNext(80)
    [tableView, activityIndicator].forEach {
      self.view.addSubview($0)
    }
  }
  
  func initConstraint() {
    tableView.separatorStyle = .none
    tableView.snp.makeConstraints {
      $0.top.leading.trailing.bottom.equalToSuperview()
    }
    activityIndicator.snp.makeConstraints {
      $0.centerX.centerY.equalToSuperview()
      $0.width.height.equalTo(50)
    }
  }
  
  func bind(reactor: RootReactor) {
    rightButton.rx.tap
      .map { Reactor.Action.modeToggle }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    rightButton.rx.tap
      .map { Reactor.Action.getCategory }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    tableView.rx.modelSelected((Category, StudyMode).self)
      .map { $0.0 }
      .map { Reactor.Action.selectCategory($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    reactor.state.map { $0.mode }
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] mode in
        if mode == .basic {
          self?.rightButton.image = UIImage(systemName: "star")
          self?.rightButton.tintColor = .secondaryLabel
          self?.title = "CS"
        }
        else {
          self?.rightButton.image = UIImage(systemName: "star.fill")
          self?.rightButton.tintColor = UIColor(red: 0.17, green: 0.68, blue: 0.27, alpha: 1)
          self?.title = "즐겨찾기"
        }
      })
      .disposed(by: disposeBag)
    reactor.state.map { $0.isLoad }
      .distinctUntilChanged()
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] isLoad in
        if isLoad {
          self?.rightButton.isEnabled = false
          self?.activityIndicator.startAnimating()
          self?.activityIndicator.isHidden = false
        }
        else {
          self?.rightButton.isEnabled = true
          self?.activityIndicator.stopAnimating()
          self?.activityIndicator.isHidden = true
        }
      })
      .disposed(by: disposeBag)
    Observable.combineLatest(reactor.state.map { $0.mode }, reactor.state.map { $0.categoryArr })
      .map { (mode, categories) in categories.map { (element: $0, mode: mode) } }
      .observe(on: MainScheduler.instance)
      .bind(to: tableView.rx.items(cellIdentifier: "CategoryCell", cellType: CategoryCell.self)) { idx, item, cell in
        cell.mode = item.mode
        if item.mode == .basic {
          cell.chapterLabel.text = "Chapter \(item.element.id)"
          cell.titleLabel.text = item.element.name
          cell.star.isHidden = true
          cell.cntLabel.isHidden = true
        }
        else {
          cell.chapterLabel.text = ""
          cell.titleLabel.text = item.element.name
          cell.star.isHidden = false
          cell.cntLabel.isHidden = false
          cell.cntLabel.text = "\(item.element.storeN!)"
        }
        
      }
      .disposed(by: disposeBag)
    reactor.state.map { $0.selectedCategory }
      .observe(on: MainScheduler.asyncInstance)
      .compactMap { $0 }
      .subscribe(onNext: { [weak self, weak reactor] category in
        let questionListView = QuestionListView(reactor: QuestionListReactor())
        self?.navigationController?.pushViewController(questionListView, animated: true)
        reactor?.action.onNext(.clearCategory)
      })
      .disposed(by: disposeBag)
  }
}
