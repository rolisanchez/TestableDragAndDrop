//
//  DraggableImage.swift
//  TestableDragAndDrop
//
//  Created by Victor Rolando Sanchez Jara on 2/18/20.
//  Copyright © 2020 Victor Rolando Sanchez Jara. All rights reserved.
//


import UIKit

class DraggableImage: UIImageView {
    
    private var originalCenter: CGPoint?
    private var dragStart: CGPoint?
    
    private var originalImage: UIImage!
    
    var startedSelection: (() -> ())!
    var stoppedSelection: (() -> ())!
    var setOthersAsNotSelected: (() -> ())!
    var checkDragOverTrash: (() -> ())?
    
    var lastRotation : CGFloat = 0.0
    var previousScale : CGFloat = 1.0
    var beginX : CGFloat = 0.0
    var beginY : CGFloat = 0.0
    
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                removeBlinkingImage()
                setBlinkingImageWithBorder()
                startedSelection()
            } else {
                removeBlinkingImage()
                setSlowBlinkingImage()
                stoppedSelection()
            }
        }
    }
    
    func removeBlinkingImage(){
        self.image = originalImage
        self.layer.removeAllAnimations()
        self.alpha = 1.0 // To avoid alpha stopping at an alpha different than 1 during animation
    }
    
    func setSlowBlinkingImage(){
        UIView.animate(withDuration: 0.7,
                       delay: 0,
                       options: [.repeat, .autoreverse, .allowUserInteraction],
                       animations: { self.alpha = 0.1 }
        )
    }
    
    func setBlinkingImageWithBorder() {
        let borderSize: CGFloat = 1.08
        let outlinedImageRect = CGRect(x: 0.0, y: 0.0, width: originalImage.size.width * borderSize, height: originalImage.size.height * borderSize)
        
        let imgX = originalImage.size.width * (borderSize - 1) * 0.5
        let imgY = originalImage.size.height * (borderSize - 1) * 0.5
        let width = originalImage.size.width
        let height = originalImage.size.height
        
        let imageRect = CGRect(x: imgX, y: imgY, width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(outlinedImageRect.size, false, borderSize)
        
        originalImage.draw(in: outlinedImageRect)
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.setBlendMode(.sourceIn)
        context?.setFillColor(UIColor.orange.cgColor)
        context?.fill(outlinedImageRect)
        
        
        originalImage.draw(in: imageRect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.image = newImage
        
        
        UIView.animate(withDuration: 0.7,
                       delay: 0,
                       options: [.repeat, .autoreverse, .allowUserInteraction],
                       animations: { self.alpha = 0.1 }
        )
        
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        
        self.originalImage = image
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        self.addGestureRecognizer(tap)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotate))
        self.addGestureRecognizer(rotationGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(scale))
        self.addGestureRecognizer(pinchGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        self.addGestureRecognizer(panGesture)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func doubleTapped(){
        //        isSelected.toggle()
    }
    
    @objc func rotate(sender : Any){
        if let sender = sender as? UIRotationGestureRecognizer {
            if sender.state == .ended {
                lastRotation = 0.0
                return
            }
            let rotation : CGFloat = 0.0 - (lastRotation - sender.rotation)
            let currentTransform = self.transform
            let newTransform = currentTransform.rotated(by: rotation)
            self.transform = newTransform
            lastRotation = sender.rotation
        }
    }
    
    @objc func scale(sender : Any){
        if let sender = sender as? UIPinchGestureRecognizer {
            if sender.state == .ended {
                previousScale = 1.0
                return
            }
            let newScale = 1.0 - (previousScale - sender.scale)
            let currentTransform = self.transform
            let newTransform = currentTransform.scaledBy(x: newScale, y: newScale)
            self.transform = newTransform
            previousScale = sender.scale
        }
    }
    
    @objc func pan(sender : Any){
        if let sender = sender as? UIPanGestureRecognizer {
            var newCenter = sender.translation(in: superview)
            if(sender.state == .began) {
                // Set other images as "not selected", only this is selected
                setOthersAsNotSelected()
                isSelected = true
                
                beginX = self.center.x
                beginY = self.center.y
                
            }
            newCenter = CGPoint.init(x: beginX + newCenter.x, y: beginY + newCenter.y)
            self.center = newCenter
            checkDragOverTrash?()
        }
    }
    
}

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
        
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
}

