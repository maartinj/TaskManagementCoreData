//
//  DynamicFilteredView.swift
//  TaskManagementCoreData
//
//  Created by Marcin Jędrzejak on 14/04/2023.
//

import SwiftUI
import CoreData

// Now we are going to create a CustomView Builder which will dynamically filter the core data using NSPredicates and returns the ManagedObjects to define the Views
// Why we need this?
// Since SwiftUI @FetchRequest can be called once and cannot be sorted/filtered, so we are writing a CustomView which will dynamically updates the @FetchRequest!
struct DynamicFilteredView<Content: View, T>: View where T: NSManagedObject {
    // MARK: Core Data Request
    @FetchRequest var request: FetchedResults<T>
    let content: (T) -> Content
    
    // MARK: Building Custom ForEach which will give Coredata object to build View
    init(dateToFilter: Date, @ViewBuilder content: @escaping (T) -> Content) {
        
        // You can see that the tasks are not updating when ever the date is changed, this is because we didn't write any predicate for our Custom View Builder
        // Writing a Predicate which will fetch the tasks for the currently selected date
        // MARK: Predicate to Filter With NSPredicate
        let calendar = Calendar.current
        
        let today = calendar.startOfDay(for: dateToFilter)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: dateToFilter)!
        
        // Filter Key
        let filterKey = "taskDate"
        
        // This will fetch task between today and tomorrow which is 24 HRS
        let predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) =< %@", argumentArray: [today, tomorrow])
        
        
        // Initializing Request with NSPredicate
        _request = FetchRequest(entity: T.entity(), sortDescriptors: [], predicate: predicate)
        self.content = content
    }
    
    var body: some View {
        
        Group {
            if request.isEmpty {
                Text("No tasks found!!!")
                    .font(.system(size: 16))
                    .fontWeight(.light)
                    .offset(y: 100)
            } else {
                ForEach(request, id: \.objectID) { object in
                    self.content(object)
                }
            }
        }
    }
}
