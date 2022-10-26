//
//  UserRepository.swift
//  ContactManagement
//
//  Created by le.n.t.trung on 26/10/2022.
//

import Foundation

final class UserRepository: RepositoryType {

    typealias T = DomainUser
    typealias K = DomainProject
    private let network = APICaller.shared
    
    func getAllUser(urlApi: String, completion: @escaping ([DomainUser]?, Error?) -> Void) {
        network.getJSON(urlApi: urlApi) { (data: Users?, error) in
            var domainUserList = [DomainUser]()
            if let data = data {
                for user in data.items {
                    domainUserList.append(DomainUser(
                        login: user.login,
                        id: user.id,
                        avatarUrl: user.avatar_url,
                        htmlUrl: user.html_url,
                        followersUrl: user.followers_url,
                        followingUrl: user.following_url,
                        reposUrl: user.repos_url
                    ))
                }
                DispatchQueue.main.async {
                    completion(domainUserList, nil)
                }
            }
        }
    }
    
    func getUserDetail(urlApi: String, completion: @escaping (DomainUser?, Error?) -> (Void)) {
        network.getJSON(urlApi: urlApi) { (data: User?, error) in
            if let data = data {
                let domainUser = DomainUser(
                    login: data.login,
                    id: data.id,
                    avatarUrl: data.avatar_url,
                    htmlUrl: data.html_url,
                    followersUrl: data.followers_url,
                    followingUrl: data.following_url,
                    reposUrl: data.repos_url
                )
                DispatchQueue.main.async {
                    completion(domainUser, nil)
                }
            }
        }
    }
    
    func getAllRelationshipOfUser(urlApi: String, completion: @escaping ([DomainUser]?, Error?) -> Void) {
        network.getJSON(urlApi: urlApi) { (data: [User]?, error) in
            var domainUserList = [DomainUser]()
            if let data = data {
                for user in data {
                    domainUserList.append(DomainUser(
                        login: user.login,
                        id: user.id,
                        avatarUrl: user.avatar_url,
                        htmlUrl: user.html_url,
                        followersUrl: user.followers_url,
                        followingUrl: user.following_url,
                        reposUrl: user.repos_url
                    ))
                }
                DispatchQueue.main.async {
                    completion(domainUserList, nil)
                }
            }
        }
    }
    
    func getAllRepoOfUser(urlApi: String, completion: @escaping ([DomainProject]?, Error?) -> Void) {
        network.getJSON(urlApi: urlApi) { (data: [Project]?, error) in
            var domainRepoList = [DomainProject]()
            if let data = data {
                for repo in data {
                    domainRepoList.append(DomainProject(
                        id: repo.id,
                        name: repo.name
                    ))
                }
                DispatchQueue.main.async {
                    completion(domainRepoList, nil)
                }
            }
        }
    }
}
