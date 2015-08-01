//
//  ViewController.swift
//  PDKTSwipableCard
//
//  Created by Victor Baro on 01/08/2015.
//  Copyright © 2015 Produkt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var animator: UIDynamicAnimator!
    var cardBehavior: CardBehaviour!
    var itemView: UIView!
    
    let midSectionWidth : CGFloat = 360
    let itemAspectRatio: CGFloat = 0.9
    var offset = CGPoint.zeroPoint
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSquareView()
        addGestureRecognizers()
        setupDynamics()
    }
    
    func setupSquareView() {
        let screenBounds = UIScreen.mainScreen().bounds
        let length = floor(0.3  * max(screenBounds.width, screenBounds.height))
        itemView = UIView(frame: CGRect(x: screenBounds.width/2 - 100, y: screenBounds.height/2, width: length, height: floor(length / itemAspectRatio)))
        itemView.autoresizingMask = []
        itemView.layer.cornerRadius = 10
        itemView.backgroundColor = UIColor.blueColor()
    }
    
    func addGestureRecognizers() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "pan:")
        itemView.addGestureRecognizer(panGestureRecognizer)
        view.addSubview(itemView)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPress:")
        view.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    func setupDynamics(){
        animator = UIDynamicAnimator(referenceView: view)
        animator.delegate = self
        cardBehavior = CardBehaviour(item: itemView, midSectionWidth: midSectionWidth)
        animator.addBehavior(cardBehavior)
    }
    
    func pan(pan: UIPanGestureRecognizer) {
        var location = pan.locationInView(view)
        let xDistance = itemView.center.x - CGRectGetWidth(view.frame)/2
        
        switch pan.state {
        case .Began:
            let center = itemView.center
            offset.x = location.x - center.x
            offset.y = location.y - center.y
            cardBehavior.isEnabled = false
            UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                self.itemView.transform = CGAffineTransformScale(self.itemView.transform, 1.2, 1.2)
                }, completion: nil)
            
        case .Changed:
            location.x -= offset.x
            location.y -= offset.y
            
            itemView.center = location
            itemView.transform = CGAffineTransformMakeRotation(xDistance/500)
            itemView.backgroundColor = colorForXPosition(xDistance)
            
        case .Cancelled, .Ended:
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                self.itemView.transform = CGAffineTransformIdentity
                }, completion: nil)
            
            let velocity = pan.velocityInView(view)
            cardBehavior.isEnabled = true
            cardBehavior.addLinearVelocity(velocity)
        default: ()
        }
    }
    
    func longPress(longPress: UILongPressGestureRecognizer) {
        guard longPress.state == .Began else { return }
        animator.debugEnabled = !animator.debugEnabled
    }
    
    func colorForXPosition(xPosition : CGFloat) -> UIColor {
        let bluecolor = UIColor.blueColor()
        let finalColor = xPosition > 0 ? UIColor.greenColor() : UIColor.redColor()
        if xPosition < -midSectionWidth/2 {
            return finalColor
        } else if xPosition > midSectionWidth/2 {
            return finalColor
        }
        return bluecolor
    }
}

extension ViewController : UIDynamicAnimatorDelegate {
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        if itemView.center != view.center {
            itemView.center = view.center
            itemView.backgroundColor = UIColor.blueColor()
        }
    }
}

