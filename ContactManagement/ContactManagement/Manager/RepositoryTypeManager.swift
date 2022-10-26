//
//  Networker.swift
//  Quotes
//
//  Created by Sam Meech-Ward on 2020-05-23.
//  Copyright © 2020 meech-ward. All rights reserved.
//

import Foundation

protocol RepositoryType {
    associatedtype T
    associatedtype K
    
    func getAllUser(urlApi: String, completion: @escaping ([T]?, Error?) -> Void)
    func getUserDetail(urlApi: String, completion: @escaping (T?, Error?) -> (Void))
    func getAllRelationshipOfUser(urlApi: String, completion: @escaping ([T]?, Error?) -> Void)
    func getAllRepoOfUser(urlApi: String, completion: @escaping ([K]?, Error?) -> Void)
}
