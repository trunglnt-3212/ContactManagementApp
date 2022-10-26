//
//  UserDetailViewController.swift
//  ContactManagement
//
//  Created by le.n.t.trung on 19/10/2022.
//

import UIKit
import CoreData

final class UserDetailViewController: UIViewController {
    
    @IBOutlet private weak var DetailnfoUIView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var avatarUIImageView: UIImageView!
    @IBOutlet private weak var BannerUIView: UIView!
    @IBOutlet private weak var followingTabUIView: UIView!
    @IBOutlet private weak var followersTabUIView: UIView!
    @IBOutlet private weak var followingTabButton: UIButton!
    @IBOutlet private weak var followersTabButton: UIButton!
    @IBOutlet private weak var favoriteImageView: UIImageView!
    @IBOutlet private weak var favoriteUIView: UIView!
    @IBOutlet private weak var repoCountLabel: UILabel!
    @IBOutlet private weak var followingCountLabel: UILabel!
    @IBOutlet private weak var followersCountLabel: UILabel!
    @IBOutlet private weak var nameUserLabel: UILabel!
    
    private var listFollowersUser = [DomainUser]()
    private var listFollowingUser = [DomainUser]()
    private var listRepo = [DomainProject]()
    private var userInfo: DomainUser?
    private var loginUser: String?
    private var users: [NSManagedObject] = []
    private var isFirstTap = true
    private var isFavorite = false
    private let userRepository = UserRepository()
    private let network = APICaller.shared
    private let coreData = CoreData.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func bindData(loginUserString: String) {
        loginUser = "https://api.github.com/users/" + loginUserString
        userRepository.getUserDetail(urlApi: loginUser ?? "") { [weak self] (data, error) -> (Void) in
            guard let self = self else { return }
            if let _ = error {
                return
            }
                if let data = data {
                    DispatchQueue.main.async {
                        self.userInfo = data
                        self.getData()
                        self.tableView.reloadData()
                    }
                }
        }
    }
    
    private func configView() {
        DetailnfoUIView.setCornerRadius(radiusValue: 10, isTopBorder: false)
        favoriteUIView.layer.cornerRadius = favoriteUIView.frame.height / 2
        favoriteUIView.clipsToBounds = true
        avatarUIImageView.layer.cornerRadius = avatarUIImageView.frame.height / 2
        avatarUIImageView.clipsToBounds = true
        navigationItem.hidesBackButton = true
        tableView.register(UINib(nibName: "UserInfoTableViewCell",
                                 bundle: nil),
                           forCellReuseIdentifier: "UserInfoTableViewCell")
        tableView.dataSource = self
        setUpTabUIView(activeTab: followersTabUIView, inactiveTab: followingTabUIView)
        setUpTabUIButton(activeButton: followersTabButton, inactiveButton: followingTabButton)
        nameUserLabel.text = userInfo?.login
    }
    
    private func getData() {
        checkIsFavoriteUser()
        setImageForFavoriteButton()
        initListFollowersUser()
        initListFollowingUser()
        initListRepo()
        initAvatarImage()
    }
    
    private func initListFollowersUser() {
        userRepository.getAllRelationshipOfUser(urlApi: userInfo?.followersUrl ?? "") { [weak self] (data, error) -> (Void) in
            guard let self = self else { return }
            if let _ = error {
                return
            }
                if let data = data {
                    DispatchQueue.main.async {
                        self.listFollowersUser = data
                        self.tableView.reloadData()
                        self.followersCountLabel.text = String(self.listFollowersUser.count)
                    }
                }
        }
    }
    
    private func initListFollowingUser() {
        userRepository.getAllRelationshipOfUser(urlApi: userInfo?.followingUrl.replacingOccurrences(of: "{/other_user}", with: "") ?? "") { [weak self] (data, error) -> (Void) in
            guard let self = self else { return }
            if let _ = error {
                return
            }
                if let data = data {
                    DispatchQueue.main.async {
                        self.listFollowingUser = data
                        self.tableView.reloadData()
                        self.followingCountLabel.text = String(self.listFollowingUser.count)
                    }
                }
        }
    }
    
    private func initListRepo() {
        userRepository.getAllRepoOfUser(urlApi: userInfo?.reposUrl ?? "") { [weak self] (data, error) -> (Void) in
            guard let self = self else { return }
            if let _ = error {
                return
            }
                if let data = data {
                    DispatchQueue.main.async {
                        self.listRepo = data
                        self.repoCountLabel.text = String(self.listRepo.count)
                    }
                }
        }
    }
    
    private func initAvatarImage() {
        network.getImage(imageURL: (userInfo?.avatarUrl) ?? "") { [weak self] (data, error)  in
            guard let self = self else { return }
            if let error = error {
                print(error)
                return
            }
            if let data = data {
                self.avatarUIImageView.image = UIImage(data: data)
            }
        }
    }
    
    private func setUpTabUIView(activeTab: UIView, inactiveTab: UIView) {
        activeTab.backgroundColor = .white
        activeTab.setCornerRadius(radiusValue: 10, isTopBorder: true)
        inactiveTab.backgroundColor = BannerUIView.backgroundColor
        inactiveTab.clearCornerRadius()
    }
    
    private func setUpTabUIButton(activeButton: UIButton, inactiveButton: UIButton) {
        activeButton.setTitleColor(.black, for: .normal)
        inactiveButton.setTitleColor(.white, for: .normal)
    }
    
    private func checkIsFavoriteUser() {
        coreData.getFavoriteUserList { items, error in
            guard error == nil else {
                print("Could not fetch. \(String(describing: error))")
                return
            }
            for item in items {
                if (item.value(forKey: "id") as! Int == (self.userInfo?.id ?? 0)) {
                    self.isFavorite = true
                    return
                }
            }
        }
    }
    
    private func setImageForFavoriteButton() {
        if (isFavorite) {
            favoriteImageView.image = UIImage(systemName: "heart.fill")
            favoriteImageView.tintColor = .red
        } else {
            favoriteImageView.image = UIImage(systemName: "heart.fill")
            favoriteImageView.tintColor = .white
        }
    }
    
    private func changeImageForFavoriteButton() {
        isFavorite.toggle()
        setImageForFavoriteButton()
    }
    
    @IBAction private func FollowersTabAction(_ sender: Any) {
        setUpTabUIView(activeTab: followersTabUIView, inactiveTab: followingTabUIView)
        setUpTabUIButton(activeButton: followersTabButton, inactiveButton: followingTabButton)
        isFirstTap = true
        tableView.reloadData()
    }
    
    @IBAction private func FollowingTabAction(_ sender: Any) {
        setUpTabUIView(activeTab: followingTabUIView, inactiveTab: followersTabUIView)
        setUpTabUIButton(activeButton: followingTabButton, inactiveButton: followersTabButton)
        isFirstTap = false
        tableView.reloadData()
    }
    
    @IBAction private func backButtonAction(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction private func favoriteTapAction(_ sender: Any) {
        if (isFavorite) {
            coreData.deleteUserFromCoreData(userInfo: userInfo)
        } else {
            coreData.addUserToCoreData(userInfo: userInfo)
        }
        changeImageForFavoriteButton()
    }
}

extension UIView {
    func setCornerRadius(radiusValue: Float, isTopBorder: Bool) {
        layer.masksToBounds = true
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = CGFloat(radiusValue)
        if (isTopBorder) {
            layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    
    func clearCornerRadius() {
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 0
        layer.cornerRadius = 0
    }
}

extension UserDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isFirstTap) {
            return listFollowersUser.count
        }
        return listFollowingUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoTableViewCell",
                                                       for: indexPath) as? UserInfoTableViewCell else {
            return UITableViewCell()
        }
        if (isFirstTap) {
            cell.bindData(user: listFollowersUser[indexPath.row], isHiddenShowDetailButton: true)
        }
        else {
            cell.bindData(user: listFollowingUser[indexPath.row], isHiddenShowDetailButton: true)
        }
        return cell
    }
}
