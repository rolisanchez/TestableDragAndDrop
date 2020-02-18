//
//  DragAndDropRepresentable.swift
//  TestableDragAndDrop
//
//  Created by Victor Rolando Sanchez Jara on 2/18/20.
//  Copyright © 2020 Victor Rolando Sanchez Jara. All rights reserved.
//

import SwiftUI
// MARK: UIViewRepresentable
struct DragAndDropRepresentable: UIViewRepresentable {
    // MARK: Bindings
    // I also tried not using this boolean to reduce the number of times updateUI is called, but I still get the same result of multiple images being added
    // My idea was that by only updating chosenAssetImage, updateUIView would be called less times
//    @Binding var shouldAddImage: Bool
    @Binding var chosenAssetImage: UIImage?
    @Binding var setChooseImage: Bool
    
    func makeUIView(context: Context) -> DragAndDropUIView {
        let setChooseImage: (() -> Void) = {
            self.setChooseImage = true
        }
        let view = DragAndDropUIView(frame: CGRect.zero, setChooseImage: setChooseImage)
        return view
    }
    
    // MARK: This is called when something bindings change
    func updateUIView(_ uiView: DragAndDropUIView, context: UIViewRepresentableContext< DragAndDropRepresentable >) {
//        if shouldAddImage  {
//            shouldAddImage = false
//            guard let image = chosenAssetImage else { return }
//            uiView.addNewAssetImage(image: image)
//        }
        if let chosenAssetImage = chosenAssetImage {
            uiView.addNewAssetImage(image: chosenAssetImage)
            
        }
        self.chosenAssetImage = nil
    }
}

// MARK: UIView
class DragAndDropUIView: UIView {
    // MARK: Views
    let containerView = UIView()
    let assetsView = UIView()
    var trashCanImageView = UIImageView()
    let addAssetButton = UIButton(type: .system)
    
    // MARK: Editable Images
    var selectedImage: DraggableImage!
    var editableImages = [DraggableImage]()
    // Action to perform when pressing the button
    var setChooseImage: (() -> Void)!
    
    // MARK: Init this view and setup subviews.
    init(frame: CGRect, setChooseImage: @escaping (() -> Void)) {
        super.init(frame: frame)
        
        self.setChooseImage = setChooseImage
        
        self.addSubview(containerView)
        containerView.addSubview(assetsView)
        
        self.addSubview(addAssetButton)
        self.addSubview(trashCanImageView)
        
        // Setup image view
        trashCanImageView.backgroundColor = .orange
        trashCanImageView.image = UIImage(systemName: "trash.fill")
        trashCanImageView.isHidden = true // Only shown when draggin images
        
        // Setup buttons
        addAssetButton.setTitle("Add Asset", for: .normal)
        addAssetButton.layer.cornerRadius = 25
        addAssetButton.addTarget(self, action: #selector(addAssetButtonPressed), for: .touchUpInside)
        
        // Constraints
        containerView.translatesAutoresizingMaskIntoConstraints = false
        assetsView.translatesAutoresizingMaskIntoConstraints = false
        addAssetButton.translatesAutoresizingMaskIntoConstraints = false
        trashCanImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -55),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            addAssetButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15),
            addAssetButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            assetsView.topAnchor.constraint(equalTo: containerView.topAnchor),
            assetsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            assetsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            assetsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            trashCanImageView.widthAnchor.constraint(equalToConstant: 50),
            trashCanImageView.heightAnchor.constraint(equalToConstant: 50),
            trashCanImageView.centerYAnchor.constraint(equalTo: addAssetButton.centerYAnchor),
            trashCanImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Button pressed. Show images for selection in SwiftUI parent
    @objc func addAssetButtonPressed() {
        setChooseImage()
    }
    
    // MARK: What to do with chosen image from parent
    func addNewAssetImage(image: UIImage){
        print("addNewAssetImage")
        
        let draggableImage = DraggableImage(image: image)
        
        draggableImage.contentMode = .scaleAspectFill
        draggableImage.frame = CGRect(x: 150, y: 150, width: 150, height: 150)
        draggableImage.isUserInteractionEnabled = true
        assetsView.addSubview(draggableImage)
        
        //        draggableFace.frame = CGRect(x: 150, y: 150, width: 150, height: 150)
        //        draggableFace.isUserInteractionEnabled = true
        
        draggableImage.startedSelection = { [weak self] in
            guard let self = self else { return }
            self.trashCanImageView.isHidden = false
            self.selectedImage = draggableImage
        }
        
        draggableImage.stoppedSelection = { [weak self] in
            guard let self = self else { return }
            self.trashCanImageView.isHidden = true
            self.selectedImage = nil
        }
        
        draggableImage.setOthersAsNotSelected = { [weak self] in
            guard let self = self else { return }
            self.editableImages.forEach { (editableImage) in
                if editableImage != draggableImage {
                    editableImage.isSelected = false
                }
            }
        }
        
        draggableImage.checkDragOverTrash = { [weak self] in
            guard let self = self else { return }
            if (draggableImage.frame.intersects(self.trashCanImageView.frame)) {
                self.deleteSelectedImage()
            }
        }
        
        selectedImage = draggableImage
        draggableImage.isSelected = true
        
        editableImages.append(draggableImage)
        
    }
    
    // MARK: Delete image when dragginh to trash can
    func deleteSelectedImage() {
        if let index = editableImages.firstIndex(of: selectedImage) {
            editableImages.remove(at: index)
            selectedImage.checkDragOverTrash = nil
            
            self.selectedImage.removeFromSuperview()
            self.selectedImage.isSelected = false
            self.selectedImage = nil
        } else {
            print("NOT found in editable images")
        }
        
    }
}
