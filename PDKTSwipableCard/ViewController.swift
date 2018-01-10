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
    var offset = CGPoint.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSquareView()
        addGestureRecognizers()
        setupDynamics()
    }
    
    func setupSquareView() {
		let screenBounds = UIScreen.main.bounds
        let length = floor(0.3  * max(screenBounds.width, screenBounds.height))
        itemView = UIView(frame: CGRect(x: screenBounds.width/2 - 100, y: screenBounds.height/2, width: length, height: floor(length / itemAspectRatio)))
        itemView.autoresizingMask = []
        itemView.layer.cornerRadius = 10
        itemView.backgroundColor = UIColor.blue
    }
    
    func addGestureRecognizers() {
		let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(pan:)))
        itemView.addGestureRecognizer(panGestureRecognizer)
        view.addSubview(itemView)
        
		let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(longPress:)))
        view.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    func setupDynamics(){
        animator = UIDynamicAnimator(referenceView: view)
        animator.delegate = self
        cardBehavior = CardBehaviour(item: itemView, midSectionWidth: midSectionWidth)
        animator.addBehavior(cardBehavior)
    }
    
    func pan(pan: UIPanGestureRecognizer) {
		var location = pan.location(in: view)
        let xDistance = itemView.center.x - (view.frame.width)/2
        
        switch pan.state {
		case .began:
            let center = itemView.center
            offset.x = location.x - center.x
            offset.y = location.y - center.y
            cardBehavior.isEnabled = false
			UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
				self.itemView.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
                }, completion: nil)
            
		case .changed:
            location.x -= offset.x
            location.y -= offset.y
            
            itemView.center = location
            itemView.transform = CGAffineTransform.init(rotationAngle: xDistance/500)
            itemView.backgroundColor = colorForXPosition(xPosition:  xDistance)
            
		case .cancelled, .ended:
			UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
                self.itemView.transform = CGAffineTransform.identity
                }, completion: nil)
            
            let velocity = pan.velocity(in: view)
            cardBehavior.isEnabled = true
			cardBehavior.addLinearVelocity(velocity: velocity)
        default: ()
        }
    }
    
    func longPress(longPress: UILongPressGestureRecognizer) {
		guard longPress.state == .began else { return }
		animator.isDebugEnabled = !animator.isDebugEnabled
    }
    
    func colorForXPosition(xPosition : CGFloat) -> UIColor {
		let bluecolor = UIColor.blue
        let finalColor = xPosition > 0 ? UIColor.green : UIColor.red
        if xPosition < -midSectionWidth/2 {
            return finalColor
        } else if xPosition > midSectionWidth/2 {
            return finalColor
        }
        return bluecolor
    }
}

extension ViewController : UIDynamicAnimatorDelegate {
	func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        if itemView.center != view.center {
            itemView.center = view.center
			itemView.backgroundColor = UIColor.blue
        }
    }
}

