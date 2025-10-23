//
//  Wrapper.swift
//  TCA_Composition_Demo
//
//  Created by Dim on 23.10.2025.
//

import ComposableArchitecture

/*
 завернуть плеер во враппер
 от плеера к врапперу: враппер меняет свой тайтл в зависимости от состояния плеера (играет / не играет)
    каноничный способ реакция на экшены
    или просто смена своего стейта на баз изменного стейта плеера
 от враппера к плееру: враппер может сбросить плеер

 * показать что будет если не подцепить редьюсер плеера в редьюсере враппера
 */

@Reducer
struct Wrapper {

    @ObservableState
    struct State: Equatable {
        var title: String = "nil"
        var player: Player.State
    }

    enum Action: Equatable {
        case reset
        case player(Player.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.player, action: \.player) {
            Player()
        }
        Reduce  {state, action in
            switch action {
                case .reset:
                    return .send(.player(.reset))
                case .player(.start):
                    state.title =  "playing"
                    return .none
                case .player(.stop):
                    state.title =  "stopped"
                    return .none
                case .player(.reset):
                    state.title =  "resetted"
                    return .none
                case .player:
                    return .none
            }
        }
    }
}

import SwiftUI

struct WrapperView: View {

    let store: Store<Wrapper.State, Wrapper.Action>

    var body: some View {
        VStack {
            Text(store.title)
                .font(.largeTitle)
            PlayerView(
                store: store.scope(
                    state: \.player,
                    action: \.player
                )
            )
            Button("reset") {
                store.send(.reset)
            }
            .font(.title)
        }
    }
}

#Preview {
    WrapperView(
        store: .init(
            initialState: .init(player: .init(id: 0)),
            reducer: { Wrapper() }
        )
    )
}
