//
//  ListViewController.swift
//  FinancePlanner
//
//  Created by Anastasiia on 26.08.2022.
//

import UIKit

class ListViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var list = ["medical insurance 35$<done>", "lenses 10$ + solution 9$<done>", "gift on the mom’s BDay ~100$", "teeth 40$", "autumn coat 200-300$", "new sneakers ~100$", ""] {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ListItemCell.self, forCellWithReuseIdentifier: "listItemCell")
//        collectionView.allowsSelection = true
        
        updateUI()
    }
    
    func updateUI() {
        collectionView.reloadData()
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = list[indexPath.item]
        var newItem = item
        if item.contains("<done>") {
            newItem = item.replacingOccurrences(of:"<done>", with:"")
        } else {
            newItem = item + "<done>"
        }
        list.remove(at: indexPath.item)
        list.insert(newItem, at: indexPath.item)
    }
}
