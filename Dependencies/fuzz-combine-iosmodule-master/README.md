# FuzzCombine

This repo has a few generic helpers for writing Fuzz style MVVM apps in combine.

- Combine enabled Networking Client 
    - work in progress, needs most parameter encoding types
    - logging could be imporved


- OutputBuilder
    - We use this to bind a ViewController & ViewModel with types to contain inputs 
    ```ruby
    /// Conformance to this Protocol is a signal to the developer
    /// that this ViewModel uses Input/Output types for bindings and
    /// output is built Via a `buildOutput` method which takes interaction arguments

    in Practice 
        func setupSubscriptions() {
            let output = vm.buildOutput(ViewModel.Input(
                buttonTap: content.loginButton.tapPublisher(),
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
        }
    ```

- Load Result Types
    - Non Capturing: `LoadStatus`
    - Capturing: `LoadResult`
    ```ruby
    /// The state of a data load.
    ///
    /// - loading: A load is in progress.
    /// - success: data has been loaded.
    /// - error: An error occurred when loading.
    /// - notStarted: No load is in progress. This represents both "a load is complete" and "a load has not started."
    public enum LoadResult<T>: Equatable 
    ```

- Combine Extensions
    - With Latest From
    - Button tap publisher

- Store
     - Actions as Mutation to state
     - Published changes regaredless of  Value-Semantics(Class & Struct will both push an update after and action is applied)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.



## Requirements

## Installation

FuzzCombine is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FuzzCombine', :git => 'git@github.com:fuzz-productions/fuzz-combine-iosmodule.git'
```

## Author

Nick Trienens, nick@fuzz.pro

## License

FuzzCombine is available under the MIT license. See the LICENSE file for more info.
