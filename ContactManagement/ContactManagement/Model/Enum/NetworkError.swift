//
//  NetworkError.swift
//  ContactManagement
//
//  Created by le.n.t.trung on 26/10/2022.
//

import Foundation

enum NetworkError: Error {
    case badResponse
    case badStatusCode(Int)
    case badData
}
