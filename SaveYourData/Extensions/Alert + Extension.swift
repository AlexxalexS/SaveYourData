import SwiftUI

extension Alert {

    init(alert: AlertMessage) {
        self.init(
            title: alert.title,
            message: alert.message,
            primaryButton: alert.primaryButton,
            secondaryButton: alert.secondaryButton
        )
    }

    init(
        title: String,
        message: String,
        primaryButton: Alert.Button? = nil,
        secondaryButton: Alert.Button? = nil
    ) {
        switch (primaryButton, secondaryButton) {
        case (let primary, let secondary) where primary != nil && secondary != nil:
            self.init(
                title: Text(title),
                message: Text(message),
                primaryButton: primary!,
                secondaryButton: secondary!
            )
        case (let primary, let secondary) where primary == nil && secondary != nil:
            self.init(title: Text(title), message: Text(message), dismissButton: secondary!)
        case (let primary, let secondary) where primary != nil && secondary == nil:
            self.init(title: Text(title), message: Text(message), dismissButton: primary!)
        default:
            self.init(title: Text(title), message: Text(message))
        }
    }
}
