//
//  ImageFieldTableViewCell.swift
//  AccountBook
//
//  Created by yang on 3/9/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class ImageFieldTableViewCell: UITableViewCell {
    @IBOutlet weak var transactionImageView: UIImageView!
    
    var imageData: NSData? {
        didSet {
            if imageData != nil {
                transactionImageView.contentMode = .scaleAspectFit
                transactionImageView.image = UIImage(data: imageData! as Data)
            }
        }
    }
}
