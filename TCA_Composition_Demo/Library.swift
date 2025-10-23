//
//  Library.swift
//  TCA_Composition_Demo
//
//  Created by Dim on 23.10.2025.
//

import ComposableArchitecture

/* Список плееров
 Можно сбросить все плееры разом
 При запуске одного, все другие останавливаются (только один плеер может работать в момент времени)
 */

@Reducer
struct Library {

    @ObservableState
    struct State: Equatable {
        var title: String = ""
        var players: IdentifiedArray<Player.State.ID, Player.State>
    }

    enum Action: Equatable {
        case reset
        case players(IdentifiedAction<Player.State.ID, Player.Action>)
    }

    var body: some Reducer<Library.State, Library.Action> {
        Reduce { state, action in
            switch action {
                case .reset:
                    state.title = "Used player ids:"
                    let effects = state.players.ids.map { id in
                        Effect.send(
                            Action.players(
                                .element(id: id, action: .reset)
                            )
                        )
                    }
                    return .merge(effects)
                case .players(let player) where player.action == .start:
                    state.title += " \(player.id)"
                    let effects = state.players.ids
                        .filter { $0 != player.id }
                        .map { id in
                            Effect.send(
                                Action.players(
                                    .element(id: id, action: .stop)
                                )
                            )
                        }
                    return .merge(effects)
                case .players:
                    return .none
            }
        }
        .forEach(\.players, action: \.players) {
            Player()
        }
    }
}

import SwiftUI

struct LibraryView: View {

    let store: Store<Library.State, Library.Action>

    var body: some View {
        VStack {
            Text(store.title)
            ForEachStore(store.scope(state: \.players, action: \.players)) {
                PlayerView(store: $0)
            }
            Button("reset") {
                store.send(.reset)
            }
            .font(.title)
        }
        .onAppear {
            store.send(.reset)
        }
    }
}


extension IdentifiedAction {

    var element: (id: ID, action: Action) {
        switch self {
            case let .element(id, action):
                return (id: id, action: action)
        }
    }

    var id: ID {
        element.id
    }

    var action: Action {
        element.action
    }
}

#Preview {
    LibraryView(
        store: .init(
            initialState: .init(
                players: .init(
                    arrayLiteral:
                        Player.State(id: 0),
                        Player.State(id: 1),
                        Player.State(id: 2),
                        Player.State(id: 3),
                        Player.State(id: 4)
                )
            ),
            reducer: { Library() }
        )
    )
}
