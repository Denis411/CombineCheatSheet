import Foundation
import Combine


example(of: "Practice") {
    class SomeClass {
        var someValue = 0 {
            didSet {
                print("Did set")
            }
        }
    }
    
    let someClass = SomeClass()
    
//    var publisher = [0].publisher
    var publisher: Publishers.Sequence<[Int], Never> = [0].publisher
    
    var subscriber = publisher
        .filter{ element in
            print("hhhhh \(element)")
            return element != 100
        }
        .assign(to: \.someValue, on: someClass)
    
    
    
    publisher.append(3)
    publisher.append(8)
    
    print(someClass.someValue)
    
    subscriber.cancel()
}
