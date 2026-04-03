/*
 * AyuGram iOS — полный порт AyuConfig.java
 */

import Foundation
import Combine

@Observable
final class AyuConfig {
    static let shared = AyuConfig()

    private let defaults = UserDefaults(suiteName: "ayuconfig")!

    // MARK: - Ghost essentials
    var sendReadPackets: Bool       { didSet { save("sendReadPackets", sendReadPackets) } }
    var sendOnlinePackets: Bool     { didSet { save("sendOnlinePackets", sendOnlinePackets) } }
    var sendUploadProgress: Bool    { didSet { save("sendUploadProgress", sendUploadProgress) } }
    var sendOfflinePacketAfterOnline: Bool { didSet { save("sendOfflinePacketAfterOnline", sendOfflinePacketAfterOnline) } }
    var markReadAfterSend: Bool     { didSet { save("markReadAfterSend", markReadAfterSend) } }
    var useScheduledMessages: Bool  { didSet { save("useScheduledMessages", useScheduledMessages) } }

    // MARK: - Message history
    var saveDeletedMessages: Bool   { didSet { save("saveDeletedMessages", saveDeletedMessages) } }
    var saveMessagesHistory: Bool   { didSet { save("saveMessagesHistory", saveMessagesHistory) } }

    // MARK: - Media saving
    var saveMedia: Bool                     { didSet { save("saveMedia", saveMedia) } }
    var saveMediaInPrivateChats: Bool       { didSet { save("saveMediaInPrivateChats", saveMediaInPrivateChats) } }
    var saveMediaInPublicChannels: Bool     { didSet { save("saveMediaInPublicChannels", saveMediaInPublicChannels) } }
    var saveMediaInPrivateChannels: Bool    { didSet { save("saveMediaInPrivateChannels", saveMediaInPrivateChannels) } }
    var saveMediaInPublicGroups: Bool       { didSet { save("saveMediaInPublicGroups", saveMediaInPublicGroups) } }
    var saveMediaInPrivateGroups: Bool      { didSet { save("saveMediaInPrivateGroups", saveMediaInPrivateGroups) } }
    var saveForBots: Bool                   { didSet { save("saveForBots", saveForBots) } }
    var saveFormatting: Bool                { didSet { save("saveFormatting", saveFormatting) } }
    var saveReactions: Bool                 { didSet { save("saveReactions", saveReactions) } }

    // MARK: - Features
    var keepAliveService: Bool      { didSet { save("keepAliveService", keepAliveService) } }
    var disableAds: Bool            { didSet { save("disableAds", disableAds) } }
    var localPremium: Bool          { didSet { save("localPremium", localPremium) } }
    var regexFiltersEnabled: Bool   { didSet { save("regexFiltersEnabled", regexFiltersEnabled) } }
    var regexFiltersInChats: Bool   { didSet { save("regexFiltersInChats", regexFiltersInChats) } }
    var regexFiltersCaseInsensitive: Bool { didSet { save("regexFiltersCaseInsensitive", regexFiltersCaseInsensitive) } }

    // MARK: - Customization
    var showGhostToggleInDrawer: Bool { didSet { save("showGhostToggleInDrawer", showGhostToggleInDrawer) } }
    var showKillButtonInDrawer: Bool  { didSet { save("showKillButtonInDrawer", showKillButtonInDrawer) } }
    var deletedMarkText: String       { didSet { save("deletedMarkText", deletedMarkText) } }
    var editedMarkText: String        { didSet { save("editedMarkText", editedMarkText) } }

    // MARK: - AyuSync
    var syncEnabled: Bool           { didSet { save("syncEnabled", syncEnabled) } }
    var useSecureConnection: Bool   { didSet { save("useSecureConnection", useSecureConnection) } }
    var syncServerURL: String       { didSet { save("syncServerURL", syncServerURL) } }
    var syncServerToken: String     { didSet { save("syncServerToken", syncServerToken) } }

    // MARK: - Regex filters
    var regexFilters: [String] {
        get { (try? JSONDecoder().decode([String].self, from: defaults.data(forKey: "regexFilters") ?? Data())) ?? [] }
        set { defaults.set(try? JSONEncoder().encode(newValue), forKey: "regexFilters") }
    }

    private init() {
        let d = UserDefaults(suiteName: "ayuconfig")!
        sendReadPackets = d.bool(forKey: "sendReadPackets", default: true)
        sendOnlinePackets = d.bool(forKey: "sendOnlinePackets", default: true)
        sendUploadProgress = d.bool(forKey: "sendUploadProgress", default: true)
        sendOfflinePacketAfterOnline = d.bool(forKey: "sendOfflinePacketAfterOnline", default: false)
        markReadAfterSend = d.bool(forKey: "markReadAfterSend", default: true)
        useScheduledMessages = d.bool(forKey: "useScheduledMessages", default: false)
        saveDeletedMessages = d.bool(forKey: "saveDeletedMessages", default: true)
        saveMessagesHistory = d.bool(forKey: "saveMessagesHistory", default: true)
        saveMedia = d.bool(forKey: "saveMedia", default: true)
        saveMediaInPrivateChats = d.bool(forKey: "saveMediaInPrivateChats", default: true)
        saveMediaInPublicChannels = d.bool(forKey: "saveMediaInPublicChannels", default: false)
        saveMediaInPrivateChannels = d.bool(forKey: "saveMediaInPrivateChannels", default: true)
        saveMediaInPublicGroups = d.bool(forKey: "saveMediaInPublicGroups", default: false)
        saveMediaInPrivateGroups = d.bool(forKey: "saveMediaInPrivateGroups", default: true)
        saveForBots = d.bool(forKey: "saveForBots", default: true)
        saveFormatting = d.bool(forKey: "saveFormatting", default: true)
        saveReactions = d.bool(forKey: "saveReactions", default: true)
        keepAliveService = d.bool(forKey: "keepAliveService", default: true)
        disableAds = d.bool(forKey: "disableAds", default: true)
        localPremium = d.bool(forKey: "localPremium", default: false)
        regexFiltersEnabled = d.bool(forKey: "regexFiltersEnabled", default: false)
        regexFiltersInChats = d.bool(forKey: "regexFiltersInChats", default: false)
        regexFiltersCaseInsensitive = d.bool(forKey: "regexFiltersCaseInsensitive", default: true)
        showGhostToggleInDrawer = d.bool(forKey: "showGhostToggleInDrawer", default: true)
        showKillButtonInDrawer = d.bool(forKey: "showKillButtonInDrawer", default: false)
        deletedMarkText = d.string(forKey: "deletedMarkText") ?? AyuConstants.defaultDeletedMark
        editedMarkText = d.string(forKey: "editedMarkText") ?? "Edited"
        syncEnabled = d.bool(forKey: "syncEnabled", default: false)
        useSecureConnection = d.bool(forKey: "useSecureConnection", default: true)
        syncServerURL = d.string(forKey: "syncServerURL") ?? AyuConstants.defaultSyncServer
        syncServerToken = d.string(forKey: "syncServerToken") ?? ""
    }

    // MARK: - Ghost mode
    var isGhostModeActive: Bool {
        !sendReadPackets && !sendOnlinePackets && !sendUploadProgress && sendOfflinePacketAfterOnline
    }

    func setGhostMode(_ enabled: Bool) {
        sendReadPackets = !enabled
        sendOnlinePackets = !enabled
        sendUploadProgress = !enabled
        sendOfflinePacketAfterOnline = enabled
    }

    func toggleGhostMode() {
        setGhostMode(!isGhostModeActive)
    }

    // MARK: - Regex filters
    func addFilter(_ text: String) {
        var list = regexFilters
        list.insert(text, at: 0)
        regexFilters = list
    }

    func editFilter(at index: Int, text: String) {
        var list = regexFilters
        guard list.indices.contains(index) else { return }
        list[index] = text
        regexFilters = list
    }

    func removeFilter(at index: Int) {
        var list = regexFilters
        guard list.indices.contains(index) else { return }
        list.remove(at: index)
        regexFilters = list
    }

    private func save(_ key: String, _ value: Bool) {
        defaults.set(value, forKey: key)
    }

    private func save(_ key: String, _ value: String) {
        defaults.set(value, forKey: key)
    }
}

private extension UserDefaults {
    func bool(forKey key: String, default defaultValue: Bool) -> Bool {
        object(forKey: key) != nil ? bool(forKey: key) : defaultValue
    }
}
