//
//  ContentView.swift
//  TestableDragAndDrop
//
//  Created by Victor Rolando Sanchez Jara on 2/18/20.
//  Copyright © 2020 Victor Rolando Sanchez Jara. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var setChooseImage: Bool = false
    @State var chosenAssetImage: UIImage?
    // I also tried not using this boolean to reduce the number of times updateUI is called, but I still get the same result of multiple images being added
    // My idea was that by only updating chosenAssetImage, updateUIView would be called less times
//    @State var shouldAddImage: Bool = false
    
    var body: some View {
        NavigationView {
            DragAndDropRepresentable(chosenAssetImage: $chosenAssetImage, setChooseImage: $setChooseImage)
                // See comment above on shouldAddImage
                //        DragAndDropRepresentable(shouldAddImage: $shouldAddImage, chosenAssetImage: $chosenAssetImage, setChooseImage: $setChooseImage)
                .navigationBarTitle("Dragging images")
                // Instead of calling a collection view inside the DragAndDropRepresentable, I'm using a sheet in SwiftUI. Trying to do most of the work in SwiftUI and leave only complex things for UIKit + Representable
                .sheet(isPresented: self.$setChooseImage, onDismiss: nil) {
                    VStack {
                        Button(action: {
                            self.setChooseImage = false
                            self.chosenAssetImage = UIImage(named: "testImage")
                            // See comment above on shouldAddImage
                            //                    self.shouldAddImage = true
                        }) {
                            Image("testImage")
                                .renderingMode(Image.TemplateRenderingMode?.init(Image.TemplateRenderingMode.original))
                            
                            Text("Image 1")
                        }
                        Button(action: {
                            self.setChooseImage = false
                            self.chosenAssetImage = UIImage(named: "testImage2")
                            // See comment above on shouldAddImage
                            //                    self.shouldAddImage = true
                        }) {
                            Image("testImage2")
                                .renderingMode(Image.TemplateRenderingMode?.init(Image.TemplateRenderingMode.original))
                            Text("Image 2")
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
