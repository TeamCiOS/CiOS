//
//  QuestionListReactor.swift
//  CS
//
//  Created by Ko Seokjun on 5/28/24.
//

import ReactorKit
import RxSwift

class QuestionListReactor: Reactor {
  enum Action {
    case enterView
    case selectQuestion(Problem)
    case clearQuestion
  }
  enum Mutation {
    case setLoading(Bool)
    case loadQuestions([Problem])
    case selectQuestion(Problem)
    case clearQuestion
  }
  struct State {
    var selectedCategory: Category
    var questionList: [Problem]
    var selectedQuestion: Problem?
    var mode: StudyMode
    var isLoading: Bool = false
  }
  
  let initialState: State = State(
    selectedCategory: GlobalState.shared.selectedCategory.value,
    questionList: GlobalState.shared.questionList.value,
    mode: GlobalState.shared.mode.value
  )
}

extension QuestionListReactor {
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .enterView:
      return enterView()
    case .selectQuestion(let problem):
      return .just(Mutation.selectQuestion(problem))
    case .clearQuestion:
      return .just(Mutation.clearQuestion)
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .setLoading(let bool):
      newState.isLoading = bool
    case .loadQuestions(let arr):
      GlobalState.shared.questionList.accept(arr)
      newState.questionList = arr
    case .selectQuestion(let problem):
      newState.selectedQuestion = problem
    case .clearQuestion:
      newState.selectedQuestion = nil
    }
    return newState
  }
  
  func enterView() -> Observable<Mutation> {
    return Observable.create { [weak self] emitter in
      emitter.onNext(.setLoading(true))
      guard let self = self else {
        emitter.onCompleted()
        emitter.onNext(.setLoading(false))
        return Disposables.create()
      }
      if currentState.mode == .basic {
        let url = URL(string: "https://\(GlobalState.shared.serverURL.value)/category/problems/\(currentState.selectedCategory.id)")!
        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, err in
          if let err = err {
            emitter.onNext(.loadQuestions([Problem()]))
            emitter.onNext(.setLoading(false))
            emitter.onError(err)
          }
          else {
            do {
              let questions = try JSONDecoder().decode([Problem].self, from: data ?? Data())
              emitter.onNext(.loadQuestions(questions))
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
        emitter.onNext(.loadQuestions(DataBaseManager.shared.fetchProblems(categoryName: currentState.selectedCategory.name)))
        emitter.onNext(.setLoading(false))
        emitter.onCompleted()
      }
      return Disposables.create()
    }
  }
}


