//
//  BrandSelectionView.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/10/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

let brands = ["amiibo", "Cuttlegear", "Famitsu", "Firefin", "Forge", "KOG", "Inkline", "Krak-On", "Rockenberg", "Skalop", "Splash Mob", "SquidForce", "Takoroka", "Tentatek", "The SQUID GIRL", "Zekko", "Zink"]
let abilities = ["Bomb Range Up", "Bomb Sniffer", "Cold Blooded", "Comeback", "Damage Up", "Defence Up", "Haunt", "Ink Recovery Up", "Ink Resistance Up", "Ink Saver (Main)", "Ink Saver (Sub)", "Last-Ditch Effort", "Ninja Squid", "Opening Gambit", "Quick Respawn", "Quick Super Jump", "Recon", "Run Speed Up", "Special Charge Up", "Special Duration Up", "Special Saver", "Stealth Jump", "Swim Speed Up", "Tenacity", "None"]
let abilitiesBrands = [abilities[4], abilities[5], abilities[7], abilities[9], abilities[10], abilities[14], abilities[15], abilities[17], abilities[18], abilities[19], abilities[20], abilities[22], abilities[24]]
let abilitiesSecondaries = [abilities[0], abilities[4], abilities[5], abilities[7], abilities[9], abilities[10], abilities[14], abilities[15], abilities[17], abilities[18], abilities[19], abilities[20], abilities[22], abilities[24]]

// MARK: - IconSelectionView

protocol IconSelectionViewDelegate {
    func iconSelectionViewClose(view: IconSelectionView, sender: AnyObject)
    func iconSelectionViewBrandsUpdated(view: IconSelectionView, selectedBrands: [String])
    func iconSelectionViewAbilitiesUpdated(view: IconSelectionView, selectedAbilities: [String])
}

class IconSelectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var constraintBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintTop: NSLayoutConstraint!
    
    var delegate: IconSelectionViewDelegate?
    var view: UIView!
    var viewType = ""
    var showButtons = true
    var showTitle = true
    var singleSelection = false
    var currentSelection = -1
    var brandsSelected = [Bool]()
    var abilitiesSelected = [Bool]()
    var abilitiesAllowed = [String]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "IconSelectionView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    func configure() {
        view = loadViewFromNib()
        view.frame = bounds
        self.addSubview(view)
        
        collectionView.registerClass(BrandCell.self, forCellWithReuseIdentifier: "brandCell")
        collectionView.registerClass(AbilityCell.self, forCellWithReuseIdentifier: "abilityCell")
        collectionView.backgroundColor = UIColor.clearColor()
        
        clearSelections()
    }
    
    func clearSelections() {
        brandsSelected = Array(count: brands.count, repeatedValue: false)
        abilitiesSelected = Array(count: abilitiesAllowed.count, repeatedValue: false)
        currentSelection = -1
        collectionView.reloadData()
    }
    
    func setAbilities(abilitiesAllowed: [String]) {
        self.abilitiesAllowed = abilitiesAllowed
        abilitiesSelected = Array(count: abilitiesAllowed.count, repeatedValue: false)
        collectionView.reloadData()
    }
    
    func updateDisplay(displayButtons: Bool, displayTitle: Bool) {
        showButtons = displayButtons
        showTitle = displayTitle
        
        constraintBottom.constant = showButtons ? 50 : 0
        constraintTop.constant = showTitle ? 30 : 0
        
        self.setNeedsLayout()
    }
    
    func switchTypes(newType: String) {
        viewType = newType
        collectionView.reloadData()
        
        switch newType {
        case "brands":
            view.backgroundColor = UIColor.whiteColor()
            collectionView.backgroundColor = UIColor.whiteColor()
            btnClear.setTitleColor(UIColor.blackColor(), forState: .Normal)
            btnClose.setTitleColor(UIColor.blackColor(), forState: .Normal)
        case "abilities":
            view.backgroundColor = UIColor.blackColor()
            collectionView.backgroundColor = UIColor.blackColor()
            btnClear.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            btnClose.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        default: break
        }
    }
    
    func getProperHeight() -> CGFloat {
        return self.collectionView.collectionViewLayout.collectionViewContentSize().height + (showButtons ? 50 : 0) + (showTitle ? 30 : 0)
    }
    
    @IBAction func clearTapped(sender: AnyObject) {
        switch viewType {
        case "brands":
            brandsSelected = brandsSelected.map { _ in false }
            delegate?.iconSelectionViewBrandsUpdated(self, selectedBrands: [String]())
        case "abilities":
            abilitiesSelected = abilitiesSelected.map { _ in false }
            delegate?.iconSelectionViewAbilitiesUpdated(self, selectedAbilities: [String]())
        default: break
        }
        
        collectionView.reloadData()
    }
    
    @IBAction func closeTapped(sender: AnyObject) {
        delegate?.iconSelectionViewClose(self, sender: sender)
    }
    
    // MARK: - UICollectionView functions
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return viewType == "" ? 0 : 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch viewType {
        case "brands":
            return brands.count
        case "abilities":
            return abilitiesAllowed.count
        default:
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch viewType {
        case "brands":
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("brandCell", forIndexPath: indexPath) as! BrandCell
            cell.backgroundColor = UIColor.clearColor()
            cell.brandName = brands[indexPath.row]
            cell.pressed = singleSelection ? indexPath.row == currentSelection : brandsSelected[indexPath.row]
            cell.setNeedsDisplay()
            
            return cell
        case "abilities":
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("abilityCell", forIndexPath: indexPath) as! AbilityCell
            cell.pressed = singleSelection ? indexPath.row == currentSelection : abilitiesSelected[indexPath.row]
            cell.index = indexPath.row
            cell.update(abilitiesAllowed[indexPath.row])
            
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch viewType {
        case "brands":
            brandsSelected[indexPath.row] = !brandsSelected[indexPath.row]
            currentSelection = indexPath.row
            
            if singleSelection {
                delegate?.iconSelectionViewBrandsUpdated(self, selectedBrands: [brands[currentSelection]])
            } else {
                delegate?.iconSelectionViewBrandsUpdated(self, selectedBrands: brands.booleanFilter(brandsSelected)!)
            }
        case "abilities":
            abilitiesSelected[indexPath.row] = !abilitiesSelected[indexPath.row]
            currentSelection = indexPath.row
            
            if singleSelection {
                delegate?.iconSelectionViewAbilitiesUpdated(self, selectedAbilities: [abilitiesAllowed[currentSelection]])
            } else {
                delegate?.iconSelectionViewAbilitiesUpdated(self, selectedAbilities: abilitiesAllowed.booleanFilter(abilitiesSelected)!)
            }
        default: break
        }
        
        collectionView.reloadData()
    }
}

// MARK: - AbilityCell

class AbilityCell: UICollectionViewCell {
    var imageView: UIImageView!
    var pressed = false
    var index = -1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        imageView = UIImageView(frame: CGRectMake(5, 6, 54, 54))
        addSubview(imageView)
    }
    
    func update(ability: String) {
        let image: UIImage = pressed ? SplatAppStyle.imageOfAbilityContainerSelected: SplatAppStyle.imageOfAbilityContainerUnselected
        backgroundColor = UIColor(patternImage: image)
        imageView.image = UIImage(named: "ability\(ability.removeWhitespace()).png")
    }
}

// MARK: - BrandCell

class BrandCell: UICollectionViewCell {
    let shadowA = SplatAppStyle.shadowSelected
    let shadowB = SplatAppStyle.shadowUnselected
    let fillA = SplatAppStyle.brandPressedFill
    let fillB = UIColor.whiteColor()
    
    var index = -1
    var brandName = ""
    var pressed = false
    
    override func drawRect(rect: CGRect) {
        switch brandName {
        case "amiibo":
            SplatAppStyle.drawBrandAmiibo(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Cuttlegear":
            SplatAppStyle.drawBrandCuttlegear(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Famitsu":
            SplatAppStyle.drawBrandFamitsu(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Firefin":
            SplatAppStyle.drawBrandFirefin(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Forge":
            SplatAppStyle.drawBrandForge(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Inkline":
            SplatAppStyle.drawBrandInkline(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "KOG":
            SplatAppStyle.drawBrandKOG(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Krak-On":
            SplatAppStyle.drawBrandKrakOn(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Rockenberg":
            SplatAppStyle.drawBrandRockenberg(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Skalop":
            SplatAppStyle.drawBrandSkalop(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Splash Mob":
            SplatAppStyle.drawBrandSplashMob(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "SquidForce":
            SplatAppStyle.drawBrandSquidForce(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Takoroka":
            SplatAppStyle.drawBrandTakoroka(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Tentatek":
            SplatAppStyle.drawBrandTentatek(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "The SQUID GIRL":
            SplatAppStyle.drawBrandTheSQUIDGIRL(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Zekko":
            SplatAppStyle.drawBrandZekko(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Zink":
            SplatAppStyle.drawBrandZink(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        default:
            super.drawRect(rect)
        }
    }
}
