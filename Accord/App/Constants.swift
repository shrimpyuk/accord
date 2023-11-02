//
//  Constants.swift
//  Accord
//
//  Created by evelyn on 2020-11-27.
//

import Combine
import Foundation
import SwiftUI

// Discord WebSocket
var wss: Gateway!

let rootURL: String = "https://discord.com/api/v9"
let root = URL(string: "https://discord.com/api/v9")!
let cdnURL: String = "https://cdn.discordapp.com"
var user_id: String = .init()
var avatar: Data = .init()
var proxyIP: String? = UserDefaults.standard.string(forKey: "proxyIP")
var proxyPort: String? = UserDefaults.standard.string(forKey: "proxyPort")
var proxyEnabled: Bool = UserDefaults.standard.bool(forKey: "proxyEnabled")
var pastelColors: Bool = UserDefaults.standard.bool(forKey: "pastelColors")
// var discordStockSettings: Bool = UserDefaults.standard.bool(forKey: "discordStockSettings")
var DiscordDesktopRPCEnabled = UserDefaults.standard.bool(forKey: "DiscordDesktopRPCEnabled")
var darkMode: Bool = UserDefaults.standard.bool(forKey: "darkMode")
var sortByMostRecent: Bool = UserDefaults.standard.bool(forKey: "sortByMostRecent")
var pfpShown: Bool = UserDefaults.standard.bool(forKey: "pfpShown")
var musicPlatform: Platforms? = Platforms(rawValue: UserDefaults.standard.string(forKey: "MusicPlatform") ?? "")
let discordUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) discord/0.0.282 Chrome/108.0.5359.215 Electron/22.3.26 Safari/537.36"
var dscVersion = 242_566

let xcodeRPCAppID = "926282502937641001"
let musicRPCAppID = "925514277987704842"
let discordDesktopRPCAppID = "928798784174051399"
let vsCodeRPCAppID = "928861386140971078"
var spotifyToken: String?

#if DEBUG
    let keychainItemName = "red.evelyn.accord.token.debug"
#else
    let keychainItemName = "red.evelyn.accord.token"
#endif

enum Globals {
    // static var cancellable: Cancellable?

    // static var suffixes: Bool = UserDefaults.standard.bool(forKey: "enableSuffixRemover")
    static var pronounDB: Bool = UserDefaults.standard.bool(forKey: "pronounDB")
    
    static var token: String? {
        get {
            Storage.globals?.token
        }
        set(new) {
            Storage.globals?.token = new ?? ""
        }
    }
    
    static var user: User?
    static var plugins: [AccordPlugin] = []

//    func loadPlugins() {
//        let path = FileManager.default.urls(for: .documentDirectory,
//                                            in: .userDomainMask)[0]
//        let directoryContents = try! FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
//        for item in directoryContents {
//            if item.isFileURL {
//                let plugin = Plugins().loadView(url: String(item.absoluteString.dropFirst(7)))
//                Self.plugins.append(plugin!)
//            }
//        }
//    }
//
//    class func loadVersion() {
//        concurrentQueue.async {
//            Self.cancellable = RequestPublisher.fetch(Res.self, url: URL(string: "https://api.discord.sale"))
//                .sink(receiveCompletion: { _ in
//                }) { res in
//                    print(dscVersion)
//                    dscVersion = res.statistics.newest_build.number
//                    UserDefaults.standard.set(dscVersion, forKey: "clientVersion")
//                    print(dscVersion)
//                }
//        }
//    }
}

// class Res: Decodable {
//    var statistics: Response
//    class Response: Decodable {
//        class Build: Decodable {
//            var number: Int
//        }
//
//        var newest_build: Build
//    }
// }
