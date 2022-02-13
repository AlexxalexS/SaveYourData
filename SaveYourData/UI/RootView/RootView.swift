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

final class Loader: ObservableObject {

    enum LoaderState {

        case show
        case hide

    }

    @Published var state: LoaderState = .hide

    static let shared = Loader()

}


@main
struct RootView: App {

    @ObservedObject var stateManager = RootState.shared
    @ObservedObject var stateLoader = Loader.shared

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
                if case .show = stateLoader.state {
                    LoaderView()
                }
            }.onAppear {
                guard
                    accessToken != nil,
                    secret != nil
                else {
                    stateManager.state = .auth
                    return
                }
                stateManager.state = .home
            }
        }
    }

}
