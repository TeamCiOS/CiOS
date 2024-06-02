//
//  DataBaseManager.swift
//  CS
//
//  Created by Ko Seokjun on 5/29/24.
//

import UIKit
import RealmSwift

final class DataBaseManager {
  
  static let shared = DataBaseManager()
  
  private let database: Realm
  
  private init() {
    self.database = try! Realm()
  }
  
  func fetchCategories(categories: [Category]) -> [Category] {
    do {
      var returnArr = [Category]()
      let realm = try Realm()
      for category in categories {
        let predicate = NSPredicate(format: "categoryName == %@", category.name)
        let results = realm.objects(Problem.self).filter(predicate)
        if results.count >= 1 {
          returnArr.append(Category(id: results[0].id, name: results[0].categoryName, storeN: results.count))
        }
      }
      return returnArr
    } catch let error {
      print("Failed to fetch problems: \(error.localizedDescription)")
      return [Category]()
    }
  }
  
  func fetchProblem(id: Int, categoryName: String) -> Problem {
    do {
      let realm = try Realm()
      let predicate = NSPredicate(format: "id == %d AND categoryName == %@", id, categoryName)
      let results = realm.objects(Problem.self).filter(predicate)
//      print("Success to fetch")
      if results.count > 0{
//        print(results[0])
        return results[0]
      }
      return Problem()
    } catch let error {
      print("Failed to fetch problems: \(error.localizedDescription)")
      return Problem()
    }
  }
  
  func fetchProblems(categoryName: String) -> [Problem] {
    do {
      let realm = try Realm()
      let predicate = NSPredicate(format: "categoryName == %@", categoryName)
      let results = Array(realm.objects(Problem.self).filter(predicate))
      return results
    } catch let error {
      print("Failed to fetch problems: \(error.localizedDescription)")
      return [Problem()]
    }
  }
  
  func addProblem(id: Int, question: String, answer: String, categoryName: String, orderNum: Int) {
    let problem = Problem()
    problem.id = id
    problem.question = question
    problem.answer = answer
    problem.categoryName = categoryName
    problem.orderNum = orderNum
    
    do {
      let realm = try Realm()
      try realm.write {
        realm.add(problem, update: .modified)
      }
      print("Problem added/updated successfully")
    } catch let error {
      print("Failed to add problem: \(error.localizedDescription)")
    }
  }
  
  func deleteProblem(id: Int, categoryName: String) {
    do {
      let realm = try Realm()
      let problemsToDelete = realm.objects(Problem.self).filter("id == %@ AND categoryName == %@", id, categoryName)
      
      try realm.write {
        realm.delete(problemsToDelete)
      }
      print("Problems deleted successfully")
    } catch let error {
      print("Failed to delete problems: \(error.localizedDescription)")
    }
  }
}
