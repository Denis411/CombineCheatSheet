import Foundation
import Combine

var subscription = Set<AnyCancellable>()

example(of: "\n.collect") {
    //  publishes one by one
    ["one", "two", "three", "four"].publisher
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0)} )
        .store(in: &subscription)
    
    //  publishes the whole array
    ["one", "two", "three", "four"].publisher
        .collect()
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0)} )
        .store(in: &subscription)
    
    //  publishes arrays of twos
    ["one", "two", "three", "four", "five"].publisher
        .collect(2)
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0)} )
        .store(in: &subscription)
}

example(of: "\n.map") {
    let numFormatter = NumberFormatter()
    numFormatter.numberStyle = .spellOut
    
    [12345, 3, 567].publisher
        .map { numFormatter.string(from: NSNumber(integerLiteral: $0)) ?? "none" }
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0)} )
        .store(in: &subscription)
}

example(of: "\n.replaceNil\n.replaceEmpty\n.replaceError") {
//  I added a nil so all elements in the array are now optional
    ["one", nil, "two"].publisher
        .replaceNil(with: "Fucking nil was found")
        .map{ $0! }
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscription)
}
