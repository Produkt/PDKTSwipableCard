//
//  CardBehaviour.swift
//  Interactive Animations
//
//  Created by Victor Baro on 21/06/2015.
//  Copyright © 2015 Produkt. All rights reserved.
//

import UIKit

enum VerticalSection: Int {
    case LeftSection = 0
    case MidSection
    case RightSection
}

class CardBehaviour : UIDynamicBehavior {
    private var midSectionWidth: CGFloat
    private let itemBehavior: UIDynamicItemBehavior
    private let item: UIDynamicItem
    private var fieldBehaviors = [UIFieldBehavior]()
    

    var isEnabled = true {
        didSet {
            if isEnabled {
                for fieldBehavior in fieldBehaviors {
                    fieldBehavior.addItem(item)
                }
                itemBehavior.addItem(item)
            }
            else {
                for fieldBehavior in fieldBehaviors {
                    fieldBehavior.removeItem(item)
                }
                itemBehavior.removeItem(item)
            }
        }
    }
    
    init(item: UIDynamicItem, midSectionWidth: CGFloat) {
        self.item = item
        self.midSectionWidth = midSectionWidth
        itemBehavior = UIDynamicItemBehavior(items: [item])
        itemBehavior.density = 0.001
        itemBehavior.resistance = 15
        itemBehavior.friction = 0.0
        itemBehavior.allowsRotation = true
        
        super.init()

        addChildBehavior(itemBehavior)
        for _ in 0...2 {
            let fieldBehavior = UIFieldBehavior.springField()
            fieldBehavior.addItem(item)
            fieldBehaviors.append(fieldBehavior)
            addChildBehavior(fieldBehavior)
        }
    }
    
	override func willMove(to dynamicAnimator: UIDynamicAnimator?) {
		super.willMove(to: dynamicAnimator)
        guard let bounds = dynamicAnimator?.referenceView?.bounds else { return }
		updateFieldsInBounds(bounds: bounds)
    }
    
    func updateFieldsInBounds(bounds: CGRect) {
        if bounds != CGRect.zero {
            let itemBounds = item.bounds
            let height = bounds.height
            let width = bounds.width
            let sideFieldWidth =  itemBounds.width
            
            // Private function to update the position & region of a given field.
            func updateRegionForField(field: UIFieldBehavior, _ point: CGPoint) {
                field.position = point
                if point.x == width/2 {
                    field.region = UIRegion(size: CGSize(width: midSectionWidth, height: height))
                } else {
                    field.region = UIRegion(size: CGSize(width: sideFieldWidth, height: height))
                }
            }
            
            // Calculate fields' center.
            let midCenter = CGPoint(x: width/2, y: height/2)
            let leftCenter = CGPoint(x: midCenter.x - sideFieldWidth/2 - midSectionWidth/2, y: height/2)
            let rightCenter = CGPoint(x: midCenter.x + sideFieldWidth/2 + midSectionWidth/2, y: height/2)
            print("Left, mid, right: \(leftCenter, midCenter, rightCenter)")

           updateRegionForField(field: fieldBehaviors[VerticalSection.LeftSection.rawValue], leftCenter)
            updateRegionForField(field: fieldBehaviors[VerticalSection.MidSection.rawValue], midCenter)
            updateRegionForField(field: fieldBehaviors[VerticalSection.RightSection.rawValue], rightCenter)
        }
    }

    func addLinearVelocity(velocity: CGPoint) {
		itemBehavior.addLinearVelocity(velocity, for: item)
    }
    
    func positionForSection(section: VerticalSection) -> CGPoint {
        return fieldBehaviors[section.rawValue].position
    }
    
    func currentSection() -> VerticalSection? {
        if let bounds = dynamicAnimator?.referenceView?.bounds {
            let position = item.center
            let thirdWidth = bounds.width / 3.0
            var rect = CGRect(origin: CGPoint.zero, size: CGSize(width: thirdWidth, height: bounds.height))
            
            if rect.contains(position) { return .LeftSection }
            
            rect.origin = CGPoint(x: thirdWidth, y: 0)
            if rect.contains(position) { return .MidSection }
            

            rect.origin = CGPoint(x: 2 * thirdWidth, y: 0)
            if rect.contains(position) { return .RightSection }
        }
        
        return nil
    }
}
