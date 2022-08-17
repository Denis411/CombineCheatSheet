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

example(of: "\n.scan") {
    var num: Int { .random(in: -10...10) }
    
    let august2019 = (0...22)
        .map { _ in num }
        .publisher
    
    august2019
//  like reduce
        .scan(50) { latest, current in max(0, latest + current) }
        .sink(receiveValue: { print($0) })
        .store(in: &subscription)
}

example(of: "More filters") {
    var nums = (0...10).publisher
    
    nums
        .first(where: { num in num % 2 == 0} )
        .sink { num in
            print(".first(where: {} ) gives you: \(num)")
        }
        .store(in: &subscription)
    
    nums
        .last(where: { num in num % 2 == 0})
        .sink { print(".last(where: {} ) gives you: \($0)") }
        .store(in: &subscription)
}

example(of: "More filters") {
    var nums = PassthroughSubject<Int, Never>()
    
    nums
        .first(where: { num in num % 2 == 0} )
        .sink { num in
            print(".first(where: {} ) gives you: \(num)")
        }
        .store(in: &subscription)
    
    nums
        .last(where: { num in num % 2 == 0})
        .sink { print(".last(where: {} ) gives you: \($0)") }
        .store(in: &subscription)
    
    nums.send(11)
    nums.send(22)
    nums.send(33)
    nums.send(44)
    nums.send(55)
    nums.send(77)
    nums.send(completion: .finished)
}
