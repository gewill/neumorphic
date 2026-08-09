import SwiftUI

enum NeumorphicControlAction {
    static func toggle(_ value: Binding<Bool>) {
        value.wrappedValue.toggle()
    }

    static func select<Value>(_ value: Value, selection: Binding<Value>) {
        selection.wrappedValue = value
    }
}
