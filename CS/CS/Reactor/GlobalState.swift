//
//  GlobalState.swift
//  CS
//
//  Created by Ko Seokjun on 5/30/24.
//

import RxSwift
import RxCocoa

class GlobalState {
  static let shared = GlobalState()
  private init() {}
  let mode = BehaviorRelay<StudyMode>(value: .basic)
  let selectedCategory = BehaviorRelay<Category>(value: Category(id: 0, name: "error"))
  let questionList = BehaviorRelay<[Problem]>(value: [])
  let serverURL = BehaviorRelay<String>(value: Bundle.main.object(forInfoDictionaryKey: "Server_URL") as? String ?? "")
}
