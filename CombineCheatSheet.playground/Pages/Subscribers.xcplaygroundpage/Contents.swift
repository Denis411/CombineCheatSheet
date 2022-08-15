import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "Subscriber") {
    class SomeUIKitClass {
        var text: String = ""
    }
    
    let someUIKitClass = SomeUIKitClass()
    
    let subscriber = Subscribers.Assign(object: someUIKitClass, keyPath: \.text)
    
}
