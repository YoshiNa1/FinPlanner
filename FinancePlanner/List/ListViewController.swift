//
//  ListViewController.swift
//  FinancePlanner
//
//  Created by Anastasiia on 26.08.2022.
//

import UIKit

class ListViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var initialGestureLocationInCell: CGPoint = .zero
    
    var list = ["medical insurance 35$<done>", "lenses 10$ + solution 9$<done>", "gift on the mom’s BDay ~100$", "teeth 40$", "autumn coat 200-300$", "new sneakers ~100$", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ListItemCell.self, forCellWithReuseIdentifier: "listItemCell")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        collectionView.addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
        collectionView.addGestureRecognizer(longPressGesture)
        
        updateUI()
    }
    
    func updateUI() {
        collectionView.reloadData()
    }

    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        let gestureLocation = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: gestureLocation) else { return }
        if isPressableArea(gesture) {
            if(gesture.state == .ended) {
                let item = list[indexPath.item]

                var newItem = item
                if item.contains("<done>") {
                    newItem = item.replacingOccurrences(of:"<done>", with:"")
                } else {
                    newItem = item + "<done>"
                }
                list.remove(at: indexPath.item)
                list.insert(newItem, at: indexPath.item)
                updateUI()
            }
        }
    }

    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        let isNeedToRespond = isPressableArea(gesture)
        switch gesture.state {
        case .began:
            if isNeedToRespond {
                guard let indexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else { break }
                let cell = self.collectionView.cellForItem(at: indexPath)!
                let gestureLocation_RelativeToOrigin = gesture.location(in: cell)
                let gestureLocation_RelativeToCentre = CGPoint(x: gestureLocation_RelativeToOrigin.x - cell.frame.size.width/2,
                                                               y: gestureLocation_RelativeToOrigin.y - cell.frame.size.height/2)
         
                self.initialGestureLocationInCell = gestureLocation_RelativeToCentre
                self.collectionView.beginInteractiveMovementForItem(at: indexPath)
            }
        case .changed:
            let gestureLocationInCollectionView = gesture.location(in: gesture.view)
            let targetPosition = CGPoint(x: gestureLocationInCollectionView.x - self.initialGestureLocationInCell.x,
                                         y: gestureLocationInCollectionView.y - self.initialGestureLocationInCell.y)
            collectionView.updateInteractiveMovementTargetPosition(targetPosition)
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    func isPressableArea(_ gesture: UIGestureRecognizer) -> Bool {
        let gestureLocation = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: gestureLocation) else { return false }
        let cell = collectionView.cellForItem(at: indexPath) as! ListItemCell

        let cellIconFrame = collectionView.convert(cell.iconView.frame, from:cell)
        if cellIconFrame.contains(gestureLocation) {
            return true
        }
        return false
    }
}

extension ListViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 370, height: 24)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16;
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listItemCell", for: indexPath as IndexPath) as! ListItemCell
        let item = list[indexPath.item]
        cell.configureCell(with: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = list[sourceIndexPath.row]
        list.remove(at: sourceIndexPath.item)
        list.insert(item, at: destinationIndexPath.row)
        updateUI()
    }
    
}
