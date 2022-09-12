import UIKit
import Combine

fileprivate var subscriptions = Set<AnyCancellable>()

// 1)
// - a
example(of: "Notification Center") {
    let center = NotificationCenter.default
    let myNotification = Notification.Name("MyNotification")
//    let newNotification = UITextField.textDidChangeNotification
    
//  Do not look for some meaning, this is just a bridge from the old to the new
    let publisher = center.publisher(for: myNotification, object: nil)
    
    let subscription = publisher
        .print()
        .sink { _ in print("Notification received from a publisher") }
    
    center.post(name: myNotification, object: nil)
    subscription.cancel()
}
// - b

example(of: "NotificationCenter.Publisher") {
    let newName = Notification.Name("Combine")
    let publisher = NotificationCenter.Publisher(center: .default, name: newName, object: nil)
        .sink(receiveValue: { print($0)} )
        .store(in: &subscriptions)
    
    NotificationCenter.default.post(name: newName, object: nil)
//    NotificationCenter.default.addObserver(self, selector: #selector(<#T##@objc method#>), name: newName, object: nil)
}

// 2)
example(of: "Just") {
//  just emits an output to each subscriber just ones
    var just = Just("Can be any data type")
    
    just
        .sink(receiveCompletion: { nextElement in print("next element is: \(nextElement)") },
              receiveValue: { nextElement in print("next element is: \(nextElement)") } )
        .store(in: &subscriptions)
}

// 3
example(of: "KVO, old fashioned way") {
//    KVO works only in objc runtime
//    watched property must be dynamic
    class Teacher: NSObject {
        @objc dynamic var name = String()
    }
    
    class Faculty: NSObject {
//   we observe teachers
        @objc var oldTeacher: Teacher
        @objc var newTeacher: Teacher
        var nameObservation: NSKeyValueObservation?
        
        init(oldTeacher: Teacher, newTeacher: Teacher) {
            self.oldTeacher = oldTeacher
            self.newTeacher = newTeacher
        }
        
        func observeTeachers() {
// this way is okay as well \.oldTeacher.name
            nameObservation =  observe(\Faculty.oldTeacher.name, options: [.new, .old, .initial, .prior]) { facultyClass, change in
//                comes form options
//                change.newValue
//                change.oldValue
//                change.isPrior
                guard let updatedValue = change.newValue else { return }
                print("🔹 KVO value was changed for: \(updatedValue)")
            }
            
//          is not assign to an observation therefore is not observed
            observe(\.newTeacher.name, options: [.new]) { facultyObject, change in
                guard let updatedValue = change.newValue else { return }
                print("🔸 KVO value was changed for: \(updatedValue)")
            }
        }
    }
    
    
    let teacher  = Teacher()
    let teacher2 = Teacher()
    [teacher, teacher2].forEach { element in element.name = "Initial name" }
    
    let faculty = Faculty(oldTeacher: teacher, newTeacher: teacher2)
    faculty.observeTeachers()
    teacher.name = "New name"
    teacher2.name = "New name"
}

// 4
example(of: "KVO, new way. assign(to: on:)") {
    class SomeObject {
        var value: Int = 0 {
            didSet { print("new value is: \(value)") }
        }
    }
    
    let object = SomeObject()
    
    [1, 2].publisher
        .assign(to: \.value, on: object)
        .store(in: &subscriptions)
}


extension Notification.Name {
    static let basicUsage = Notification.Name("Basic Usage")
}

// 4
import UIKit
example(of: "Basic usage") {
    
    struct BlogPost {
        let title: String
    }
    
    let publisher = NotificationCenter.Publisher(center: .default, name: .basicUsage, object: nil)
        .map { (notification) -> String? in
            return (notification.object as? BlogPost)?.title
        }
    
//  Use on a custom class
    class ClassToChange {
//     changeVar must be optional to work with .subscribe
         var changableVar: String? = ""
    }
    
    let instanceOfClassToChange = ClassToChange()

    let subscriber = Subscribers.Assign(object: instanceOfClassToChange,
                                        keyPath: \.changableVar)

    publisher.subscribe(subscriber)
    
    
//  Use on UI elements
    let label = UILabel()
    
    let subscription = Subscribers.Assign(object: label, keyPath: \.text)
    
    publisher.subscribe(subscription)
    
}

