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
            Group {
                ZStack {
                    if case .auth = stateManager.state {
                        NavigationView {
                            AuthView()
                                .hiddenNavigationBarStyle()
                        }.transition(.slide)
                        //.transition(.opacity.animation(.easeInOut(duration: 0.1)))
                    }
                    if case .home = stateManager.state {
                        NavigationView {
                            HomeView()
                                .hiddenNavigationBarStyle()
                        }.transition(.slide)
                    }
                    if case .show = stateLoader.state {
                        LoaderView().transition(.opacity.animation(.easeInOut))
                    }
                }
            }.animation(.default, value: stateManager.state)
            .onAppear {
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
