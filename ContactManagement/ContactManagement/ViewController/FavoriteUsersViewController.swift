//
//  FavoriteUsersViewController.swift
//  ContactManagement
//
//  Created by le.n.t.trung on 19/10/2022.
//

import UIKit
import CoreData

final class FavoriteUsersViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var listFavoriteUser = [NSManagedObject]()
    private let coreData = CoreData.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        coreData.getFavoriteUserList { items, error in
            guard error == nil else {
                print("Could not fetch. \(String(describing: error))")
                return
            }
            self.listFavoriteUser = items
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func configView() {
        tableView.register(UINib(nibName: "UserInfoTableViewCell",
                                 bundle: nil),
                           forCellReuseIdentifier: "UserInfoTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction private func backButtonAction(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
}

extension FavoriteUsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listFavoriteUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoTableViewCell",
                                                       for: indexPath) as? UserInfoTableViewCell else {
            return UITableViewCell()
        }
        let user = listFavoriteUser[indexPath.row]
        cell.bindDataFromCoreData(user)
        return cell
    }
}

extension FavoriteUsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let userDetailViewController = storyboard.instantiateViewController(withIdentifier: "UserDetailViewController") as? UserDetailViewController else {
            return
        }
        userDetailViewController.bindData(loginUserString: listFavoriteUser[indexPath.row].value(forKey: "login") as! String)
        self.navigationController?.pushViewController(userDetailViewController, animated: true)
    }
}
