# AyuGram iOS

iOS 26 порт AyuGram для Android. Написан на Swift 6 + SwiftUI с использованием Liquid Glass дизайна iOS 26.

## Стек

- Swift 6 / SwiftUI
- iOS 26+ (Liquid Glass)
- [TDLibKit](https://github.com/Swiftgram/TDLibKit) — официальная Telegram TDLib
- SwiftData — база данных (вместо Room)
- async/await — вся асинхронщина

## Структура

```
iOS/
├── Package.swift
└── AyuGram/
    ├── App/                    # точка входа
    ├── Core/
    │   ├── TDLib/              # TDLibClient, настройка
    │   ├── Config/             # AyuConfig, AyuConstants
    │   ├── Auth/               # AuthViewModel
    │   ├── Ghost/              # GhostController
    │   ├── Messages/           # AyuMessagesController
    │   ├── Database/           # AyuDatabase (SwiftData)
    │   ├── Sync/               # AyuSyncController (WebSocket)
    │   └── Filter/             # AyuFilter (regex)
    ├── Features/
    │   ├── Auth/               # PhoneInput, CodeInput, PasswordInput
    │   ├── ChatList/           # ChatListView, ChatRowView
    │   ├── Chat/               # ChatView, MessageBubble, MessageHistory
    │   ├── Contacts/           # ContactsView
    │   ├── Calls/              # CallsView
    │   ├── Settings/           # все экраны настроек
    │   ├── Splash/             # SplashView
    │   └── Main/               # MainTabView
    └── Resources/
        └── Info.plist
```

## Реализованные фичи AyuGram

- Ghost Mode (sendReadPackets, sendOnlinePackets, sendUploadProgress, sendOfflinePacketAfterOnline)
- Сохранение удалённых сообщений
- История изменений сообщений
- Гибкие настройки сохранения медиа (по типу чата)
- Regex-фильтры сообщений
- AyuSync (WebSocket синхронизация)
- Local Premium
- Отключение рекламы
- Кастомные метки удалённых/изменённых сообщений
- Кнопка Ghost в боковом меню

## Настройка

1. Замени API ключи в `Core/TDLib/TDLibSetup.swift`:
   ```swift
   static let apiId: Int = YOUR_API_ID
   static let apiHash: String = "YOUR_API_HASH"
   ```
   Получить на https://my.telegram.org

2. Открой в Xcode: `File → Open → iOS/Package.swift`

3. Выбери таргет и запускай на устройстве с iOS 26+
