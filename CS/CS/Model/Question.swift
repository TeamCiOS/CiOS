//
//  Question.swift
//  CS
//
//  Created by Ko Seokjun on 5/29/24.
//

import Foundation
import RealmSwift

class Problem: Object, Decodable {
  @objc dynamic var id: Int = 0
  @objc dynamic var question: String = "error"
  @objc dynamic var answer: String?
  @objc dynamic var categoryName: String = "error"
  @objc dynamic var orderNum: Int = 0
  
  override static func primaryKey() -> String? {
    return "id"
  }
  
  private enum CodingKeys: String, CodingKey {
    case id, question, answer, categoryName, orderNum
  }
}
