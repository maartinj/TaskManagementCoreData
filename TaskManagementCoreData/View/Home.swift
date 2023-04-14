//
//  Home.swift
//  TaskManagement
//
//  Created by Marcin Jędrzejak on 13/04/2023.
//

import SwiftUI

struct Home: View {
    @StateObject var taskModel: TaskViewModel = TaskViewModel()
    @Namespace var animation
    
    // MARK: Core Data Context
    @Environment(\.managedObjectContext) var context
    // MARK: Edit Button Context
    @Environment(\.editMode) var editButton
     
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            
            // MARK: Lazy Stack With Pinned Header
            LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]) {
                
                Section {
                    
                    // MARK: Current Week View
                    ScrollView(.horizontal, showsIndicators: false) {
                        
                        HStack(spacing: 10) {
                            
                            ForEach(taskModel.currentWeek, id: \.self) { day in
                                
                                VStack(spacing: 10) {
                                    
                                    Text(taskModel.extractDate(date: day, format: "dd"))
                                        .font(.system(size: 15))
                                        .fontWeight(.semibold)
                                    
//                                    Text(day.formatted(date: .abbreviated, time: .omitted))
                                    // EEE will return dat as MON, TUE,.... etc.
                                    Text(taskModel.extractDate(date: day, format: "EEE"))
                                        .font(.system(size: 14))
                                    
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 8, height: 8)
                                        .opacity(taskModel.isToday(date: day) ? 1 : 0)
                                }
                                .foregroundStyle(taskModel.isToday(date: day) ? .primary : .secondary)
                                .foregroundColor(taskModel.isToday(date: day) ? .white : .black)
                                // MARK: Capsule Shape
                                .frame(width: 45, height: 90)
                                .background(
                                    ZStack {
                                        // MARK: Matched Geometry Effect
                                        // Adding Matched Geometry Animation when a WeekDay is changed
                                        if taskModel.isToday(date: day) {
                                            Capsule()
                                                .fill(.black)
                                                .matchedGeometryEffect(id: "CURRENTDAY", in: animation)
                                        }
                                        
                                    }
                                )
                                .contentShape(Capsule())
                                .onTapGesture {
                                    // Updating Current Day
                                    withAnimation {
                                        taskModel.currentDay = day
                                    }
                                }
                                
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    TasksView()
                    
                } header: {
                    HeaderView()
                }

            }
        }
        // To Fill the SafeArea we need to ignore the top Safe Area, as a result the view will be moved up, to avoid that retrieve the safeArea top value and add as a top padding
        .ignoresSafeArea(.container, edges: .top)
        // MARK: Add Button
        .overlay (
            
            Button(action: {
                taskModel.addNewTask.toggle()
            }, label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black, in: Circle())
            })
            .padding()
            
            , alignment: .bottomTrailing
        )
        .sheet(isPresented: $taskModel.addNewTask) {
            NewTask()
        }
    }
    
    // MARK: Tasks View
    // Let's build the TasksView which will update dynamically when ever user is tapped on another date
    func TasksView() -> some View {
        
        LazyVStack(spacing: 20) {
            
            // Converting object as Our Task Model
            DynamicFilteredView(dateToFilter: taskModel.currentDay) { (object: Task) in
                
                TaskCardView(task: object)
            }
        }
        .padding()
        .padding(.top)
    }
    
    // MARK: Task Card View
    func TaskCardView(task: Task) -> some View {
        
        // MARK: Since CoreData Values will Give Optional data
        HStack(alignment: .top, spacing: 30) {
            
            VStack(spacing: 10) {
                Circle()
                    .fill(taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? (task.isCompleted ? .green : .black) : .clear)
                    .frame(width: 15, height: 15)
                    .background(
                        
                        Circle()
                            .stroke(.black, lineWidth: 1)
                            .padding(-3)
                    )
                    .scaleEffect(!taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? 0.8 : 1)
                
                Rectangle()
                    .fill(.black)
                    .frame(width: 3)
            }
            
            VStack {
                
                HStack(alignment: .top, spacing: 10) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text(task.taskTitle ?? "")
                            .font(.title2.bold())
                        
                        Text(task.taskDescription ?? "")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .hLeading()
                    
                    Text(task.taskDate?.formatted(date: .omitted, time: .shortened) ?? "")
                }
                
                // Highlighting Current Tasks
                if taskModel.isCurrentHour(date: task.taskDate ?? Date()) {
                    
                    // MARK: Team Members
                    HStack(spacing: 12) {
                        
                        // MARK: Check Button
                        if !task.isCompleted {
                            
                            Button {
                                // Updating the Task Status
                                task.isCompleted = true
                                
                                // Saving
                                try? context.save()
                            } label: {
                                
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.black)
                                    .padding(10)
                                    .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
                                
                            }
                        }
                        
                        Text(task.isCompleted ? "Marked as Completed" : "Mark Task as Completed")
                            .font(.system(size: task.isCompleted ? 14 : 16, weight: .light))
                            .foregroundColor(task.isCompleted ? .gray : .white)
                            .hLeading()
                    }
                    .padding(.top)
                }
            }
            .foregroundColor(taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? .white : .black)
            .padding(taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? 15 : 0)
            .padding(.bottom, taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? 0 : 10)
            .hLeading()
            .background(
                Color("Black")
                    .cornerRadius(25)
                    .opacity(taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? 1 : 0)
            )
        }
        .hLeading()
    }
    
    // MARK: Header
    func HeaderView() -> some View {
        
        HStack(spacing: 10) {
            
            VStack(alignment: .leading, spacing: 10) {
                
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .foregroundColor(.gray)
                
                Text("Today")
                    .font(.largeTitle.bold())
            }
            .hLeading()
            
            // MARK: Edit Button
            EditButton()
        }
        .padding()
        .padding(.top, getSaveArea().top)
        .background(Color.white)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

// MARK: UI Design Helper functions
// These extensions will avoid the use of Spacer() & .frame() also it improces code readability
extension View {
    
    func hLeading() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func hTrailing() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    func hCenter() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    // MARK: Safe Area
    func getSaveArea() -> UIEdgeInsets {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        guard let safeArea = screen.windows.first?.safeAreaInsets else {
            return .zero
        }
        
        return safeArea
    }
}
