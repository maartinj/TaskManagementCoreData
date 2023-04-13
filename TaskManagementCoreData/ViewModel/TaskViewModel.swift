//
//  TaskViewModel.swift
//  TaskManagement
//
//  Created by Marcin Jędrzejak on 13/04/2023.
//

import SwiftUI

class TaskViewModel: ObservableObject {
    
    // MARK: Current Week Days
    @Published var currentWeek: [Date] = []
    
    // MARK: Current Day
    // Storing the currentDay (this will be updated when ever user tapped on another date, based on that tasks will be displayed)
    @Published var currentDay: Date = Date()
    
    // MARK: Filtering Today Tasks
    // Filtering the tasks for the date user is selected
    @Published var filteredTasks: [Task]?
    
    // MARK: New Task View
    @Published var addNewTask: Bool = false
    
    // MARK: Initializing
    init() {
        fetchCurrentWeek()
    }
    
    func fetchCurrentWeek() {
        
        let today = Date()
        let calendar = Calendar.current
        
        let week = calendar.dateInterval(of: .weekOfMonth, for: today)
        
        guard let firstWeekDay = week?.start else {
            return
        }
        
        (1...7).forEach { day in
            
            if let weekday = calendar.date(byAdding: .day, value: day, to: firstWeekDay) {
                currentWeek.append(weekday)
            }
        }
    }
    
    // MARK: Extracting Date
    // A simply function which will return date as a String with user defined Date Format
    func extractDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
    
    // MARK: Checking if current Date is Today
    // When the app is opened we need to highlight the currentDay in WeekDays ScrollView. In order to do that we need to write a function which will verify if the weekDay is Today
    func isToday(date: Date) -> Bool {
        
        let calendar = Calendar.current
        
        return calendar.isDate(currentDay, inSameDayAs: date)
    }
    
    // MARK: Checking if the currentHour is task Hour
    // Writing a code which will verify whether the given task date and time is same as current Date and time (To highlight the Current Hour Tasks)
    func isCurrentHour(date: Date) -> Bool {
        
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        let currentHour = calendar.component(.hour, from: Date())
        
        return hour == currentHour
    }
}
