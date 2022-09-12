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

// 6
example(of: "More filters") {
    let nums = PassthroughSubject<Int, Never>()
    
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
    
    nums.send(1000)

    nums
        .first(where: { $0.isMultiple(of: 100)} )
        .sink { filteredNum in
            print("This num is multiple by 100: \(filteredNum)")
        }
        .store(in: &subscription)

    nums.send(10_000)
    nums.send(completion: .finished)
}

// 7
example(of: "Remove Duplicates") {
    let string = "How How How How are you, are you okay okay okay okay okay , are your cats cats okay?"
    let array = string.components(separatedBy: " ")
    
    let publisher: Publishers.Sequence<[String], Never> = array.publisher
    
    publisher
        .removeDuplicates() // Duplicates that go one after another are removed
        .sink { word in print("\(word)", terminator: "_")}
        .store(in: &subscription)
}

// 8
example(of: "Compact Map") {
    let arrayOfNums = [nil, 3, 4, 3, nil]
    let publisher = arrayOfNums.publisher
    
    publisher
        .compactMap { Int($0 ?? 0) }
        .sink { print($0) }
        .store(in: &subscription)
    
    publisher.append(nil)
    publisher.append(5)
    publisher.append(1000000)
//  nil in arrayOfNums is replaced with a zero
}

// 9
example(of: "Ignore Output") {
    let publisher = [9,0,3,4].publisher
    
    publisher
        .ignoreOutput()
        .sink { completion in
            print("Completion: \(completion)")
        } receiveValue: { output in
            print("The output that is not printed due to .ignoreOutput: \(output)")
        }
        .store(in: &subscription)
    
    publisher
        .sink(receiveCompletion: { completion in
            print("Completion for the second observable: \(completion)")
        }, receiveValue: { value in
            print("The second subscriber: \(value)")
        })
        .store(in: &subscription)
    
    publisher.append(100000)
}

// 10
example(of: "Prefix") {
    let publiser = [1,2,3,4,1000].publisher
    
    publiser
        .prefix(2)
        .sink { completion in
            print("Completion: \(completion)")
        } receiveValue: { value in
            print("Prefixed value: \(value)")
        }
        .store(in: &subscription)

    publiser.append(101)
    publiser.append(102)
    publiser.append(104)
}

//11
example(of: "Drop(while: some condition)") {
    let publisher = (0...10).publisher
    print(21 / 2) // output 10 cus it's an Int
    print(2 / 5)  // output 0 for the same reason
    
    print("⁉️ DOES NOT WORK!!!!!!")
    publisher
        .drop(while: { $0 % 5 != 0})
        .sink { value in
            print("After dropping value: \(value)")
        }
        .store(in: &subscription)
}
