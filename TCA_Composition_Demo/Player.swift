//
//  Player.swift
//  TCA_Composition_Demo
//
//  Created by Dim on 22.10.2025.
//

import  ComposableArchitecture

/* Плеер с таймером
 Показывает секунды
 Можно запускать / останавливать / сбрасывать (тап по всей области)
 Если сбросить на запущенном плеере, то он автоматически оствновится
 */

@Reducer
struct Player {

    @ObservableState
    struct State: Equatable, Identifiable {
        var id: Int // нужно для отмены
        var time: Int = 0
        var inProgress: Bool = false
    }

    enum Action: Equatable {
        case start
        case stop
        case reset
        case tick
    }

    @Dependency(\.continuousClock) var clock

//    enum CancelID {
//        case timer
//    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .start:
                    state.inProgress = true
                    return .run { send in
                        while true {
                            try await clock.sleep(for: .seconds(1))
                            await send(.tick)
                        }
                    }
                    .cancellable(id: state.id)
                case .stop:
                    state.inProgress = false
                    return .cancel(id: state.id)
                case .reset:
                    state.time = 0
                    state.inProgress = false
                    return .cancel(id: state.id)
                case .tick:
                    state.time += 1
                    return .none
            }
        }
    }
}

import SwiftUI

struct PlayerView: View {

    let store: Store<Player.State, Player.Action>

    var body: some View {
        Button {
            store.send(.reset)
        } label: {
            Text("\(store.time) sec.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.black)
            Button {
                store.send(store.inProgress ? .stop : .start)
            } label: {
                Image(systemName: store.inProgress ? "stop.fill" : "play")
            }

        }
        .padding()
        .font(.largeTitle)
        .frame(width: 200)
        .background(.yellow)
        .clipShape(.capsule)
    }
}

#Preview {
    PlayerView(store: .init(initialState: .init(id: 0), reducer: {
        Player()
    }))
}
