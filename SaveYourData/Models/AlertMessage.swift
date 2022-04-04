import SwiftUI

struct AlertMessage: Identifiable {

    let id = UUID()
    var title: String
    var message: String
    var primaryButton: Alert.Button?
    var secondaryButton: Alert.Button?

}
