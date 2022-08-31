//
//  ViewModel.swift
//  FuzzCombine_Example
//
//  Created by Nick Trienens on 4/22/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Combine
import Foundation
import FuzzCombine

class ViewModel: OutputBuilder {
    private let client = TestClient(baseURLString: "https://virtserver.swaggerhub.com/nicktrienens/Fuzztival/1.0.0")
    private var publisherStorage = Set<AnyCancellable>()
    private let isValid = CurrentValueSubject<Bool, Never>(false)
    private let loadStatus = CurrentValueSubject<LoadStatus, Never>(.notStarted)

    @Published var test: String = "nick"

    let authClient = AuthClient()
    enum Action {
        case append(String)
        case completed
    }

    let strings = Store<[String], Action>(
        initialValue: [],
        reducer: { state, action in
            switch action {
            case let .append(data):
                state.append(data)
            case .completed:
                print(state)
            }
        }
    )

    init() {}

    struct Input {
        let buttonTap: AnyPublisher<Void, Never>
        let email: AnyPublisher<String?, Never>
        let password: AnyPublisher<String?, Never>
    }

    struct Output {
        let isValid: AnyPublisher<Bool, Never>
        let loadStatus: AnyPublisher<LoadStatus, Never>
    }

    func buildOutput(_ input: Input) -> Output {
        let values = Publishers.CombineLatest(input.email, input.password)
        values
            .sink { [weak self] _, _ in
                guard let self = self else { return }
                self.isValid.send(true)
            }
            .store(in: &publisherStorage)

        input.buttonTap
            .withLatestFrom(values.print())
            .setFailureType(to: Error.self)
            .flatMap { [weak self] _, _ -> AnyPublisher<TestClient.User, Error> in
                guard let self = self else {
                    return Fail(error: HTTPError("Deinited Self"))
                        .eraseToAnyPublisher()
                }
                self.loadStatus.send(.loading)
                return self.client.fetchMe()
            }
            .sink(receiveCompletion: { [weak self] in
                guard let self = self else { return }

                print("complete: \($0)")
                switch $0 {
                case let .failure(error):
                    self.loadStatus.send(.error(error))
                case .finished:
                    self.loadStatus.send(.success)
                }
            }, receiveValue: { [weak self] in
                guard let self = self else { return }
                print("event: \($0)")
                self.loadStatus.send(.success)

            })
            .store(in: &publisherStorage)

        return Output(
            isValid: isValid.eraseToAnyPublisher(),
            loadStatus: loadStatus.eraseToAnyPublisher()
        )
    }

    private func signIn() {
        authClient.signIn()
            .sink(
                receiveCompletion: {
                    print($0)
                },
                receiveValue: {
                    print($0)
                }
            )
            .store(in: &publisherStorage)
    }
}
