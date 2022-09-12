import Foundation
import Combine

fileprivate var subscriptions = Set<AnyCancellable>()

example(of: "PassthroughSubject") {
//  <emits Strings, never emits an error>
    let passthroughSubject = PassthroughSubject<String, Never>()
    
    passthroughSubject
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions )
    
    passthroughSubject.send("Value 2")
    passthroughSubject.send("Value 3")
//  completion is not going to work
    passthroughSubject.send(completion: .finished)
    passthroughSubject.send("all emits are cancelled after completion")
}

example(of: "CurrentSubject") {
    let currentSubject = CurrentValueSubject<Int, Never>(0)
    
    currentSubject
        .sink(receiveValue: { num in print("Value is set to: \(num)") })
        .store(in: &subscriptions)
    
    print(currentSubject.value)
    
    currentSubject.send(1)
    currentSubject.send(2)
    currentSubject.send(3)
    
    print(currentSubject.value)
    
    currentSubject.send(completion: .finished)
}

example(of: "Type eraser") {
    let subject = PassthroughSubject<String, Never>()
    
//  eraseToAnyPublisher does not allow you to send through it
    let publisher = subject.eraseToAnyPublisher()
    
//    has no member of send
//    publisher.send("not allowed")
    
    publisher
        .sink(receiveValue: { newValue in print("New value is: \(newValue)")})
        .store(in: &subscriptions)
}
