//
//  RootReactor.swift
//  CS
//
//  Created by Ko Seokjun on 5/27/24.
//

import ReactorKit
import RxSwift

// ViewModel
// Mutation과 State는 한 쌍이다. 하지만 Action은 ViewController와 관련있을 때 작성
class RootReactor: Reactor {
  // 여러 액션들을 정의
  enum Action {
    case modeToggle
    case getCategory
    case selectCategory(Category)
    case clearCategory
  }
  // State값을 바꾸는 가장 작은 단위
  enum Mutation {
    case modeToggle
    case setLoad(Bool)
    case loadCategory(arr: [Category])
    case setSelectedCategory(Category)
    case clearCategory
  }
  // 값이나 상태값
  struct State {
    var mode: StudyMode
    var categoryArr: [Category]
    var isLoad: Bool
    var selectedCategory: Category?
  }
  
  let initialState: State = State(
    mode: GlobalState.shared.mode.value,
    categoryArr: [], 
    isLoad: false
  )
}

extension RootReactor {
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .modeToggle: return .just(.modeToggle)
    case .getCategory:
      return fetchCategories()
    case .selectCategory(let category):
      return .just(Mutation.setSelectedCategory(category))
    case .clearCategory:
      return .just(.clearCategory)
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .modeToggle:
      newState.mode = state.mode == .basic ? .star : .basic
      GlobalState.shared.mode.accept(newState.mode)
    case .setLoad(let bool):
      newState.isLoad = bool
    case .loadCategory(let arr):
      newState.categoryArr = arr
    case .setSelectedCategory(let category):
      newState.selectedCategory = category
      GlobalState.shared.selectedCategory.accept(category)
    case .clearCategory:
      newState.selectedCategory = nil
    }
    return newState
  }
  
  func fetchCategories() -> Observable<Mutation> {
    if currentState.mode == .basic {
      let url = URL(string: "https://\(GlobalState.shared.serverURL.value)/category")!
      return Observable.create { emitter in
        emitter.onNext(.setLoad(true))
        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, err in
          if let err = err {
            emitter.onNext(.setLoad(false))
            emitter.onError(err)
          }
          else {
            do {
              let categories = try JSONDecoder().decode([Category].self, from: data ?? Data())
              emitter.onNext(.loadCategory(arr: categories))
              emitter.onNext(.setLoad(false))
              emitter.onCompleted()
            }
            catch {
              emitter.onNext(.setLoad(false))
              emitter.onError(NSError(domain: "Unknown error", code: -1, userInfo: nil))
            }
          }
        }.resume()
        return Disposables.create()
      }
    }
    return Observable.create { [weak self] emitter in
      emitter.onNext(.setLoad(true))
      emitter.onNext(
        .loadCategory(arr: DataBaseManager.shared.fetchCategories(categories: self?.currentState.categoryArr ?? [Category(id: 0, name: "error")] ))
      )
      emitter.onNext(.setLoad(false))
      emitter.onCompleted()
      return Disposables.create()
    }
  }
}

