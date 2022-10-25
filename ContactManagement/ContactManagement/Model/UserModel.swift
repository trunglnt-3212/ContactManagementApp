import Foundation
struct User: Codable {
    let login: String
    let id: Int
    let avatar_url: String
    let html_url: String
    let followers_url: String
    let following_url: String
    let repos_url: String
}
