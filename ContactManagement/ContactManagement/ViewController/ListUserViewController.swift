//
//  ListUserViewController.swift
//  ContactManagement
//
//  Created by le.n.t.trung on 18/10/2022.
//

import UIKit

class ListUserViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchUITextField: UITextField!
    @IBOutlet private weak var searchUIView: UIView!
    @IBOutlet private weak var searchIconImageView: UIImageView!
    
    private var listUser = [User]()
    private var listUserToShow = [User]()
    private var search: String = ""
    private var searching: Bool = false
    private let network = Network.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        initListUser()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
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
        searchUITextField.delegate = self
        searchIconImageView.layer.cornerRadius = searchIconImageView.frame.height / 2
        searchIconImageView.clipsToBounds = true
        searchUIView.setCornerRadius(radiusValue: 5, isTopBorder: false)
        searchUITextField.borderStyle = .none
    }
    
    private func initListUser() {
        network.getQuote(urlApi: "https://api.github.com/search/users?q=abc") { [weak self] (data, error) -> (Void) in
            guard let self = self else { return }
            if let _ = error {
                return
            }
            do {
                if let data = data {
                    let users = try JSONDecoder().decode(Users.self, from: data)
                    DispatchQueue.main.async {
                        self.listUser = users.items
                        self.listUserToShow = users.items
                        self.tableView.reloadData()
                    }
                }
            } catch let error {
                print(error)
            }
        }
    }
    
    @IBAction func showFavoriteUsersAction(_ sender: Any) {
        guard let favoriteUsersViewController = storyboard?.instantiateViewController(withIdentifier: "FavoriteUsersViewController") as? FavoriteUsersViewController else {
            return
        }
        self.navigationController?.pushViewController(favoriteUsersViewController, animated: true)
    }
    
    @IBAction func deleteContentSearchAction(_ sender: Any) {
        searchUITextField.text = ""
        listUserToShow = listUser
        tableView.reloadData()
    }
}

extension ListUserViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listUserToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoTableViewCell",
                                                       for: indexPath) as? UserInfoTableViewCell else {
            return UITableViewCell()
        }
        cell.bindData(user: listUserToShow[indexPath.row], isHiddenShowDetailButton: false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let userDetailViewController = storyboard.instantiateViewController(withIdentifier: "UserDetailViewController") as? UserDetailViewController else {
            return
        }
        userDetailViewController.bindData(loginUserString: listUserToShow[indexPath.row].login)
        self.navigationController?.pushViewController(userDetailViewController, animated: true)
    }
}

extension ListUserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text ?? "")
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        guard let oldText = textField.text,
              let range = Range(range, in: oldText) else {
            return true
        }
        let newText = oldText.replacingCharacters(in: range, with: string)
        if newText.isEmpty {
            listUserToShow = listUser
        } else {
            listUserToShow = self.listUser.filter { $0.login.localizedCaseInsensitiveContains(newText) }
        }
        self.tableView.reloadData()
        return true
    }
}

