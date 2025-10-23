//
//  TCA_Composition_DemoApp.swift
//  TCA_Composition_Demo
//
//  Created by Dim on 22.10.2025.
//

import ComposableArchitecture
import SwiftUI

@main
struct TCA_Composition_DemoApp: App {
    var body: some Scene {
        WindowGroup {
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
    }
}
