import Foundation

private var  timesInitiated: Int = 1
    
public func example(of description: String, action: () -> Void) {
    print("\n 🔴 \(timesInitiated)) Example of: \(description)")
    action()
    timesInitiated += 1
}
