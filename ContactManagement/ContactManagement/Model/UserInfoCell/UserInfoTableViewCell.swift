//
//  UserInfoTableViewCell.swift
//  ContactManagement
//
//  Created by le.n.t.trung on 18/10/2022.
//

import UIKit
import CoreData

class UserInfoTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var gitHubLinkLabel: UILabel!
    @IBOutlet private weak var nameUserLabel: UILabel!
    @IBOutlet private weak var avatarUserImageView: UIImageView!
    @IBOutlet private weak var cellUIView: UIView!
    @IBOutlet private weak var showDetailButton: UIImageView!
    
    private let network = APICaller.shared
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
    }
    
    private func configView() {
        avatarUserImageView.layer.cornerRadius = avatarUserImageView.frame.height / 2
        avatarUserImageView.clipsToBounds = true
        cellUIView.dropShadow(color: .black, offSet: .zero, radius: 3)
        selectionStyle = .none
    }

    func bindData(user: DomainUser, isHiddenShowDetailButton: Bool) {
        self.network.getImage(imageURL: (user.avatarUrl)) { [weak self] (data, error)  in
            guard let self = self else { return }
            if let error = error {
                print(error)
                return
            }
            if let data = data {
                self.avatarUserImageView.image = UIImage(data: data)
            }
        }
        if (isHiddenShowDetailButton) {
            showDetailButton.isHidden = true
        }
        nameUserLabel.text = user.login
        gitHubLinkLabel.text = user.htmlUrl
    }
    
    func bindDataFromCoreData(_ user: NSManagedObject) {
        let avatar = (user.value(forKey: "avatarUrl") as? String) ?? ""
        self.network.getImage(imageURL: avatar) { [weak self] (data, error)  in
            guard let self = self else { return }
            if let error = error {
                print(error)
                return
            }
            if let data = data {
                self.avatarUserImageView.image = UIImage(data: data)
            }
        }
        nameUserLabel.text = (user.value(forKey: "login") as? String) ?? ""
        gitHubLinkLabel.text = (user.value(forKey: "htmlUrl") as? String) ?? ""
    }
}

extension UIView {
    func dropShadow(color: UIColor, opacity: Float = 0.2, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        layer.cornerRadius = 20
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 1
    }
}
