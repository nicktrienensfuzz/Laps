//
//  ViewController.swift
//  FuzzCombine
//
//  Created by Nick Trienens on 04/05/2020.
//  Copyright (c) 2020 Nick Trienens. All rights reserved.
//

import Combine
import FuzzCombine
import SVProgressHUD
import TuvaCore
import UIKit

class ViewController: UIViewController, ViewCustomizer {
    var vm = ViewModel()
    let content = View()
    private var publisherStorage = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        addViews()
        constrainViews()
        styleViews()

        setupSubscriptions()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "push", style: .plain, target: self, action: #selector(push))
    }

    @objc func push() {
        navigationController?.pushViewController(ViewController(), animated: true)
    }

    func setupSubscriptions() {
        let tap = content.loginButton.tapPublisher()

        let output = vm.buildOutput(ViewModel.Input(
            buttonTap: tap,
            email: content.emailField.publisher(for: \.text).eraseToAnyPublisher(),
            password: content.passwordField.publisher(for: \.text).eraseToAnyPublisher()
        ))

        output.isValid
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: content.loginButton)
            .store(in: &publisherStorage)

        output.loadStatus
            .receive(on: RunLoop.main)
            .sink(receiveValue: { status in
                switch status {
                case .loading: SVProgressHUD.show()
                default: SVProgressHUD.dismiss(completion: nil)
                }
            })
            .store(in: &publisherStorage)

        print(output)
    }

    func addViews() {
        view.addSubview(content)
    }

    func constrainViews() {
        content.translatesAutoresizingMaskIntoConstraints = false
        content.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        content.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        content.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        content.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    func styleViews() {
        view.backgroundColor = .white
    }

    class View: UIView, ViewCustomizer {
        let loginButton = UIButton()
        let emailField = UITextField()
        let passwordField = UITextField()

        override init(frame: CGRect) {
            super.init(frame: frame)
            addViews()
            constrainViews()
            styleViews()
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func addViews() {
            addSubview(emailField)
            addSubview(passwordField)
            addSubview(loginButton)
        }

        func constrainViews() {
            emailField.translatesAutoresizingMaskIntoConstraints = false
            emailField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            emailField.widthAnchor.constraint(equalToConstant: 200).isActive = true

            passwordField.translatesAutoresizingMaskIntoConstraints = false
            passwordField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 10).isActive = true
            passwordField.widthAnchor.constraint(equalToConstant: 200).isActive = true

            loginButton.translatesAutoresizingMaskIntoConstraints = false
            loginButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            loginButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            loginButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 10).isActive = true
        }

        func styleViews() {
            loginButton.setTitle("test", for: .normal)
            loginButton.backgroundColor = .red

            emailField.borderStyle = .line
            passwordField.borderStyle = .line
        }
    }
}
