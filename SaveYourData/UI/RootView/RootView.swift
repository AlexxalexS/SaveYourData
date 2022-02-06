import SwiftUI

final class RootState: ObservableObject {

    enum Screen {

        case auth
        case home
        case empty

    }

    @Published var state: Screen = .empty

    static let shared = RootState()

}


@main
struct RootView: App {

    @ObservedObject var stateManager = RootState.shared

    var body: some Scene {
        WindowGroup {
            ZStack {
                if case .auth = stateManager.state {
                    NavigationView {
                        AuthView()
                            .hiddenNavigationBarStyle()
                    }
                }
                if case .home = stateManager.state {
                    NavigationView {
                        HomeView()
                            .hiddenNavigationBarStyle()
                    }
                }
            }.onAppear {
                guard accessToken != nil, secret != nil else {
                    stateManager.state = .auth
                    return
                }
                stateManager.state = .home
            }
        }
    }

}
