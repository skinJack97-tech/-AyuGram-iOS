/*
 * Порт AyuFilter.java — regex-фильтрация сообщений
 */

import Foundation

final class AyuFilter {
    static let shared = AyuFilter()
    private var cachedRegexes: [NSRegularExpression] = []
    private let config = AyuConfig.shared

    private init() {
        rebuildCache()
    }

    func rebuildCache() {
        let options: NSRegularExpression.Options = config.regexFiltersCaseInsensitive ? [.caseInsensitive] : []
        cachedRegexes = config.regexFilters.compactMap {
            try? NSRegularExpression(pattern: $0, options: options)
        }
    }

    func shouldFilter(_ text: String) -> Bool {
        guard config.regexFiltersEnabled else { return false }
        let range = NSRange(text.startIndex..., in: text)
        return cachedRegexes.contains { $0.firstMatch(in: text, range: range) != nil }
    }
}
