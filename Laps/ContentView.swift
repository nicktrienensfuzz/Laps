//
//  ContentView.swift
//  Laps
//
//  Created by Nicholas Trienens on 6/20/22.
//

import Base
import BaseWatch
import Combine
import CoreLocation
import DependencyContainer
import FuzzCombine
import MapKit
import NavigationStack
import SwiftUI

extension ContentView {
    class ViewModel: ObservableObject {
        private var publisherStorage = Set<AnyCancellable>()

        init() {
            do {
             let db = try DependencyContainer.resolve(key: ContainerKeys.database)
                //db.dbPool
                let string = try db.exportDatabaseContent(from: db.dbPool)
                print(string)
            }catch {
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject private var navigationStack: NavigationStackCompat

    var body: some View {
        Screen {
            ScrollView {
                VStack {
                    Button {
                        self.navigationStack.push(WorkOutForHollyView())
                    } label: {
                        Text("Holly's 30s")
                            .font(.title2)
                            .bold()
                    }
                    .padding(.top, 30)

                    Button {
                        self.navigationStack.push(RecordTrackView())
                    } label: {
                        Text("Record New Track")
                            .font(.title2)
                            .bold()
                    }
                    .padding(.top, 30)

                    Spacer()

                    TrackListView()
                        .padding()
                        .neumorphicStyle()

                    SelectedPlaylist()
                        .frame(maxWidth: .infinity)
                        .neumorphicStyle()

                    Spacer()
                    
                    Button {
                        do {
                         let db = try DependencyContainer.resolve(key: ContainerKeys.database)
                            let string = try db.exportDatabaseContent(from: db.dbPool)
                            let AV = UIActivityViewController(activityItems: [URL(fileURLWithPath: string)], applicationActivities: nil)
                 
                            UIApplication.shared.currentUIWindow()?.rootViewController?.present(AV, animated: true, completion: nil)
                        }catch {
                        }
                           }
                           label: {
                               Text("export db")
                           }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


public extension UIApplication {
    func currentUIWindow() -> UIWindow? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .filter({
                $0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
        
        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }

        return window
        
    }
}
