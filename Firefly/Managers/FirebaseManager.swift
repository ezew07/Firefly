//
//  FirebaseManager.swift
//  Firefly
//
//  Created by Eze, William (IRG) on 14/06/2024.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    private init() {}
    
    private let db = Firestore.firestore()
    
    func saveToDo(todo: String) {
        let newToDoRef = db.collection("todos").document()
        newToDoRef.setData([
            "content": todo,
            "createdAt": Date()
        ])
    }
    
    func getToDo(completion: @escaping ([Todo]?, Error?) -> Void) {
        db.collection("todos").getDocuments { querySnapshot, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil, error)
            }
            else {
                guard let documents = querySnapshot?.documents else {
                    print("Error getting querySnapshot documents")
                    completion(nil,nil)
                    return
                }
                
                var todos: [Todo] = []
                for document in documents {
                    let id = document.documentID
                    let data = document.data()
                    let todo = Todo(id: id, data: data)
                    todos.append(todo)
                }
                completion(todos, nil)
                
            }
        }
    }
    
    func deleteTodo(id: String, completion: @escaping (Error?) -> Void) {
        db.collection("todos").document(id).delete { error in
            completion(error)
        }
    }
    
    
}
