//
//  CaroselReactor.swift
//  CS
//
//  Created by Ko Seokjun on 5/29/24.
//

import ReactorKit
import RxSwift

class CaroselReactor: Reactor {
  enum Action {
    case storeToggle
    case enterView
    case buttonClick
    case setLoading(Bool)
  }
  enum Mutation {
    case changeIsStore
    case storeToggle
    case setLoading(Bool)
    case loadAnswer(Problem)
    case changeCardMode
  }
  struct State {
    var questionList: [Problem] = GlobalState.shared.questionList.value
    var selectedQuestion: Problem
    var isStore: Bool = false
    var answerShow = false
    var mode: StudyMode = GlobalState.shared.mode.value
    var isLoading: Bool = false
  }
  
  let initialState: State
  
  init(selectedQuestion: Problem) {
    self.initialState = State(selectedQuestion: selectedQuestion)
  }
}

extension CaroselReactor {
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .setLoading(let bool):
      return .just(.setLoading(bool))
    case .enterView:
      return loadAnswer()
    case .storeToggle:
      return .just(.storeToggle)
    case .buttonClick:
      return .just(.changeCardMode)
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case.changeIsStore:
      let results = DataBaseManager.shared.fetchProblem (
        id: self.currentState.selectedQuestion.id ,
        categoryName: self.currentState.selectedQuestion.categoryName
      )
      if results.question != Problem().question {
        newState.isStore = true
      }
      else {
        newState.isStore = false
      }
    case .storeToggle:
      if currentState.isStore {
        DataBaseManager.shared.deleteProblem(
          id: currentState.selectedQuestion.id,
          categoryName: currentState.selectedQuestion.categoryName
        )
      }
      else {
        DataBaseManager.shared.addProblem(
          id: currentState.selectedQuestion.id,
          question: currentState.selectedQuestion.question,
          answer: currentState.selectedQuestion.answer ?? "",
          categoryName: currentState.selectedQuestion.categoryName,
          orderNum: currentState.selectedQuestion.orderNum
        )
      }
      newState.isStore.toggle()
    case .loadAnswer(let problem):
      newState.selectedQuestion = problem
    case .setLoading(let bool):
      newState.isLoading = bool
    case .changeCardMode:
      newState.answerShow.toggle()
    }
    return newState
  }
  
  func loadAnswer() -> Observable<Mutation> {
    return Observable.create { [weak self] emitter in
      emitter.onNext(.changeIsStore)
      emitter.onNext(.setLoading(true))
      guard let self = self else {
        emitter.onCompleted()
        return Disposables.create()
      }
      if currentState.mode == .basic {
        guard let url = URL(string: "https://\(GlobalState.shared.serverURL.value)/problems/\(currentState.selectedQuestion.id)")
        else {
          emitter.onNext(.setLoading(false))
          emitter.onCompleted()
          return Disposables.create()
        }
        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, err in
          if let err = err {
            emitter.onNext(.loadAnswer(Problem()))
            emitter.onNext(.setLoading(false))
            emitter.onError(err)
          }
          else {
            do {
              let answer = try JSONDecoder().decode(Problem.self, from: data ?? Data())
              emitter.onNext(.loadAnswer(answer))
              emitter.onNext(.setLoading(false))
              emitter.onCompleted()
            }
            catch {
              emitter.onError(NSError(domain: "Unknown error", code: -1, userInfo: nil))
            }
          }
        }.resume()
      }
      else {
        emitter.onNext(.loadAnswer(DataBaseManager.shared.fetchProblem(id: currentState.selectedQuestion.id, categoryName: currentState.selectedQuestion.categoryName)))
        emitter.onNext(.setLoading(false))
        emitter.onCompleted()
      }
      return Disposables.create()
    }
  }
}

