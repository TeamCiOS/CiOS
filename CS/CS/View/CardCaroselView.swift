//
//  CardCaroselView.swift
//  CS
//
//  Created by Ko Seokjun on 5/29/24.
//

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import UIKit
import WebKit

class CardCaroselView: UIViewController, View, WKNavigationDelegate {
  var disposeBag: DisposeBag = DisposeBag()
  var containerView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 4
    view.layer.borderWidth = 2
    view.layer.borderColor = CGColor(red: 0.17, green: 0.68, blue: 0.27, alpha: 1)
    return view
  }()
  
  var titleContainer: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 14
    view.backgroundColor = UIColor(red: 0.17, green: 0.68, blue: 0.27, alpha: 1)
    return view
  }()
  
  var titleLabel: UILabel = {
    let uiLabel = UILabel()
    uiLabel.text = "문제"
    uiLabel.textColor = .white
    uiLabel.font = .systemFont(ofSize: 16, weight: .medium)
    return uiLabel
  }()
  
  var starBtn: UIButton = {
    var button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.titleLabel?.adjustsFontForContentSizeCategory = true
    button.setImage(UIImage(systemName: "star"), for: .normal)
    button.tintColor = .secondaryLabel
    return button
  }()
  
  var numberLabel: UILabel = {
    let uiLabel = UILabel()
    uiLabel.text = "error"
    uiLabel.textColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1)
    uiLabel.font = .systemFont(ofSize: 12, weight: .medium)
    return uiLabel
  }()
  
  var questionLabel: UILabel = {
    let uiLabel = UILabel()
    uiLabel.text = "error"
    return uiLabel
  }()
  
  var showBtn: UIButton = {
    let uiBtn = UIButton()
    uiBtn.setTitle("정답보기 >", for: .normal)
    uiBtn.setTitleColor(UIColor(red: 0.17, green: 0.68, blue: 0.27, alpha: 1), for: .normal)
    return uiBtn
  }()
  
  let activityIndicator = UIActivityIndicatorView(style: .large)
  
  var webView: WKWebView = {
    let webView = WKWebView(frame: .zero)
    return webView
  }()
  
  init(reactor: CaroselReactor) {
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
  }
  
  override func viewWillAppear(_ animated: Bool) {
    reactor?.action.onNext(.enterView)
  }
  
  deinit {
    webView.stopLoading()
  }
}

extension CardCaroselView {
  func configureNavigation() {
    self.title = ""
  }
  
  func configureView() {
    let view = UIView()
    self.view = view
    webView = WKWebView()
    webView.navigationDelegate = self
    view.backgroundColor = .systemBackground
    [containerView, showBtn, activityIndicator].forEach {
      self.view.addSubview($0)
    }
    [titleContainer, starBtn, numberLabel, questionLabel, webView].forEach {
      self.containerView.addSubview($0)
    }
    titleContainer.addSubview(titleLabel)
  }
  
  func initConstraint() {
    containerView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(50)
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-20)
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
    }
    webView.frame = containerView.bounds
    activityIndicator.snp.makeConstraints {
      $0.centerX.centerY.equalToSuperview()
      $0.width.height.equalTo(50)
    }
    titleContainer.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalToSuperview().offset(24)
      $0.height.equalTo(30)
    }
    titleLabel.snp.makeConstraints {
      $0.centerX.centerY.equalToSuperview()
      $0.leading.trailing.equalTo(titleContainer).inset(20)
    }
    starBtn.snp.makeConstraints {
      $0.centerY.equalTo(titleLabel.snp.centerY)
      $0.trailing.equalToSuperview().offset(-40)
    }
    numberLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(titleLabel.snp.bottom).offset(12)
    }
    questionLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(numberLabel.snp.bottom).offset(26)
      $0.leading.equalToSuperview().offset(26)
      $0.trailing.equalToSuperview().offset(-26)
    }
    webView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    toggleHidden()
    showBtn.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-30)
    }
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    let javascript = "document.querySelector('header').style.display='none';"
    webView.evaluateJavaScript(javascript, completionHandler: { (result, error) in
      if let error = error {
        print("JavaScript error: \(error.localizedDescription)")
      }
    })
  }
  
  func bind(reactor: CaroselReactor) {
    starBtn.rx.tap.map { Reactor.Action.storeToggle }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    showBtn.rx.tap.map { Reactor.Action.buttonClick }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    Observable.combineLatest(reactor.state.map { $0.questionList }, reactor.state.map { $0.selectedQuestion })
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] arr, problem in
        guard let self = self else { return }
        titleLabel.text = "문제 \(problem.orderNum)"
        numberLabel.text = "\(problem.orderNum) / \(arr.count)"
        questionLabel.text = problem.question
        let urlString = problem.answer
        guard let url = URL(string: urlString ?? "") else { return }
        let request = URLRequest(url: url)
        webView.load(request)
      })
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
    reactor.state.map { $0.isStore }
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] isStore in
        if isStore {
          self?.starBtn.tintColor = UIColor(red: 0.17, green: 0.68, blue: 0.27, alpha: 1)
          self?.starBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        else {
          self?.showBtn.tintColor = .secondaryLabel
          self?.starBtn.setImage(UIImage(systemName: "star"), for: .normal)
        }
      })
      .disposed(by: disposeBag)
    reactor.state.map { $0.answerShow }
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] answerShow in
        self?.toggleHidden()
        if answerShow {
          self?.showBtn.setTitle("정답 가리기 >", for: .normal)
        } else {
          self?.showBtn.setTitle("정답 보기 >", for: .normal)
        }
      })
      .disposed(by: disposeBag)
  }
  
  func toggleHidden() {
    titleContainer.isHidden.toggle()
    titleLabel.isHidden.toggle()
    starBtn.isHidden.toggle()
    numberLabel.isHidden.toggle()
    questionLabel.isHidden.toggle()
    webView.isHidden.toggle()
  }
}

