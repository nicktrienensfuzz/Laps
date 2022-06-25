//
//  PlaylistDetailsView.swift
//  Laps
//
//  Created by Nicholas Trienens on 6/21/22.
//

import SwiftUI
import MusicKit
import Base
import MediaPlayer

struct PlaylistDetailsView: View {
    var playlist: Playlist
    @State private var songs: MPMediaItemCollection?
    @State private var showingSongPicker = false
    var body: some View {
        VStack{
            if let tracks = playlist.tracks {
                ForEach(tracks) { track in
                    Text("\(track.artistName) - \(track.title)")
                }
            } else {
                Button(action: {
                      self.showingSongPicker = true
                  }
                  ){
                      Text("Edit Test Song")
                  }
                  .sheet(isPresented: $showingSongPicker) {
                      MusicPicker(songs: self.$songs)
                  }
                if let songs = songs {
                    Text("Playing")
                        .task {
                            do{
                                
                            let player = MPMusicPlayerController.applicationMusicPlayer
                                //osLog(songs.id.rawValue)
                            /// Set the queue
                                player.setQueue(with: songs)
                            try await player.prepareToPlay()
                            /// Finally, play the album!
                            player.play()
                          } catch {
                            osLog(error)
                          }
                        }
                }
                 
                Text("empty")
                    
            }
        }
    }
}

struct PlaylistDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
        //PlaylistDetailsView()
        }
    }
}


struct MusicPicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var songs: MPMediaItemCollection?

    class Coordinator: NSObject, UINavigationControllerDelegate, MPMediaPickerControllerDelegate {
        var parent: MusicPicker

        init(_ parent: MusicPicker) {
            self.parent = parent
        }
        func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
            osLog(mediaItemCollection.items.first?.title)
            parent.songs = mediaItemCollection
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MusicPicker>) -> MPMediaPickerController {
        let picker = MPMediaPickerController(mediaTypes: .music)
        
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: MPMediaPickerController, context: UIViewControllerRepresentableContext<MusicPicker>) {

    }
}
