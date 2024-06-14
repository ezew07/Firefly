//
//  ContentView.swift
//  Firefly
//
//  Created by Eze, William (IRG) on 14/06/2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var newToDo: String = ""
    private let firebaseManager = FirebaseManager.shared
    @State private var todos: [Todo] = []
    
    var body: some View {
        NavigationStack{
            List{
                if todos.isEmpty {
                    Text("Add your first todo below")
                }
                else {
                    ForEach(todos, id: \.id) { todo in
                        HStack{
                            Text(todo.content)
                            Spacer()
                            Text(todo.createdAt.formatted(date: .abbreviated, time: .omitted))
                                .fontWeight(.light)
                        
                        }
                    }
                    .onDelete(perform: { indexSet in
                        indexSet.forEach{ index in
                            firebaseManager.deleteTodo(id: todos[index].id) { error in
                                if let error = error{
                                    print("Error: \(error.localizedDescription)")
                                }
                            }
                        }
                        todos.remove(atOffsets: indexSet)
                    })
                }
            }
            .listStyle(PlainListStyle())
            
            Divider()
            
            TextField("Enter a to-do", text: $newToDo)
                .onSubmit {
                    if newToDo.count > 0 {
                        firebaseManager.saveToDo(todo: newToDo)
                        newToDo = ""
                        
                        firebaseManager.getToDo { todos, error in
                            if let error = error {
                                print("Error: \(error.localizedDescription)")
                            }
                            else {
                                guard let todos = todos else {
                                    print("Something went wrong")
                                    return
                                }
                                
                                self.todos = todos.sorted {
                                    $0.createdAt < $1.createdAt
                                }
                            }
                        }

                        
                    }
                }
                .padding()
                .navigationTitle("Firefly")
        }
        
        .onAppear {
            firebaseManager.getToDo { todos, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                else {
                    guard let todos = todos else {
                        print("Something went wrong")
                        return
                    }
                    
                    self.todos = todos.sorted {
                        $0.createdAt < $1.createdAt
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
