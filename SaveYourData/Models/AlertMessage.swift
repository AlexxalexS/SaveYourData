//
//  AlertMessage.swift
//  SaveYourData
//
//  Created by Alexey on 13.02.2022.
//

import SwiftUI

struct AlertMessage: Identifiable {

    let id = UUID()
    var title: String
    var message: String
    var primaryButton: Alert.Button?
    var secondaryButton: Alert.Button?

}
