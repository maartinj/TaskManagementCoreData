//
//  NewTask.swift
//  TaskManagementCoreData
//
//  Created by Marcin Jędrzejak on 14/04/2023.
//

import SwiftUI

// Creating a separate view for adding New Task, which will allows the user to define about the task, ie.: Title, Description and Task Date
struct NewTask: View {
    @Environment(\.dismiss) var dismiss
    
    // MARK: Task Values
    @State var taskTitle: String = ""
    @State var taskDescription: String = ""
    @State var taskDate: Date = Date()
    
    // MARK: Core Data Context
    @Environment(\.managedObjectContext) var context
    var body: some View {
        
        NavigationView {
            
            List {
                
                Section {
                    TextField("Go to work", text: $taskTitle)
                } header: {
                    Text("Task Title")
                }
                
                Section {
                    TextField("Nothing", text: $taskDescription)
                } header: {
                    Text("Task Description")
                }
                
                Section {
                    DatePicker("", selection: $taskDate)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                } header: {
                    Text("Task Date")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Add New Task")
            .navigationBarTitleDisplayMode(.inline)
            // MARK: Disabling Dismiss on Swipe
            // Simply disablimng the Swipe to close action in our Sheet
            .interactiveDismissDisabled()
            // MARK: Action Buttons
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        
                        // Film 10:10
                        // Simply create a new Entity object with managed context and set the values for the object nad finally save the context, this will create a new Object in our Core Data
                        let task = Task(context: context)
                        task.taskTitle = taskTitle
                        task.taskDescription = taskDescription
                        task.taskDate = taskDate
                        
                        // Saving
                        try? context.save()
                        // Dismissing View
                        dismiss()
                    }
                    .disabled(taskTitle == "" || taskDescription == "")
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
            }
        }
    }
}
