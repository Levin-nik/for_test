# T-ID
## Содержание
* [Предварительные этапы](#Предварительные-этапы)
* [Установка](#Установка)
    * [Swift Package Manager](#Swift-Package-Manager)
    * [Cocoapods](#Cocoapods)
* [Требования к приложению](#Требования-к-приложению)
* [Структура публичной части SDK](#Структура-публичной-части-SDK)
    * [ITID](#ITID)
    * [TAuthError](#TAuthError)
* [Получение ITID](#Получение-ITID)
* [Авторизация](#Авторизация)
    * [Перед началом](#Перед-началом)
    * [Выполнение авторизации](#Выполнение-авторизации)
    * [Продолжение авторизации](#Продолжение-авторизации)
    * [Обновление авторизационных данных](#Обновление-авторизационных-данных)
    * [Отзыв авторизационных данных](#Отзыв-авторизационных-данных)
    * [Структура TTokenPayload](#Структура-TTokenPayload)
    * [Хранение Refresh Token](#Хранение-Refresh-Token)
* [Авторизация через ASWebAuthenticationSession](#Авторизация-через-ASWebAuthenticationSession)
    * [Сценарий App to Web](#Сценарий-App-to-Web)
    * [Сценарий White Label](#Сценарий-White-Label)
* [UI](#UI)
* [Отладка без приложения Т-Банк](#Отладка-без-приложения-Т-Банк)
    * [Настройка приложения](#Настройка-приложения)
    * [Получение реализации ITID для отладки](#Получение-реализации-ITID-для-отладки)
    * [Приложение для отладки](#Приложение-для-отладки)
* [Пример приложения](#Пример-приложения)
    * [AppDelegate](#AppDelegate)
    * [AuthViewController](#AuthViewController)
* [Поддержка](#Поддержка)
* [Разработчики](#Разработчики)

## Предварительные этапы
Для начала работы с T-ID в качестве партнера заполните заявку на подключение на [данной странице](https://www.tbank.ru/business/open-api/). После рассмотрения вашей заявки вы получите по электронной почте `client_id` и пароль. Подробная инструкция доступна в [документации](https://developer.tbank.ru/docs/api#section/Partnerskij-scenarij).

## Установка

### Swift Package Manager
`T-ID` поддерживает Swift Package Manager. Инструкцию по настройке SPM для вашего проекта можно найти [здесь](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).
После настройки проекта просто добавьте ссылку на репозиторий как зависимость:

```
https://opensource.tbank.ru/mobile-tech/T-ID-iOS
```

### Cocoapods
Для установки `T-ID` с помощью [CocoaPods](https://cocoapods.org) необходимо добавить следующую строчку в ваш `Podfile`:

```ruby
pod 'T-ID'
```

Затем выполните команду `pod install` в директории проекта.

## Требования к приложению

Для работы SDK необходимо следующее:

+ iOS 14 и выше
+ Зарегистрированный идентификатор авторизуемого приложения (`client_id`)
+ Зарегистрированная авторизуемым приложением [URL схема](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app), которая будет использоваться для возврата в приложение после авторизации
+ Использование Universal Links для авторизации через ASWebAuthenticationSession доступно начиная с iOS 17.4. Для корректной работы требуется соответствующая настройка [Associated Domains Entitlement](https://developer.apple.com/documentation/xcode/supporting-associated-domains) в приложении и на домене. Потребуется тип `webcredentials:`
+ Добавленная запись в `plist`, позволяющая Вашему приложению переходить в приложение Т-Банк:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>bank100000000004</string>
</array>
```
+ Добавленная запись в `plist`, позволяющая Вашему приложению получать запасные сертификаты SSL Т-Банк.

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>tcsbank.ru</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
        <key>t-bank-app.ru</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
        <key>t-bank-app.su</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
        <key>tbank.ru</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
    </dict>
</dict>
```

## Структура публичной части SDK

### ITID
Авторизацией занимается объект, реализующий протокол `ITID`. В свою очередь, протокол `ITID` является композицией следующих протоколов:

+ `ITAuthInitiator` - инициатор начала процесса авторизации
+ `ITAuthCallbackHandler` - обработчик возврата в приложение из приложения Т-Банк
+ `ITCredentialsRefresher` - объект, умеющий обновлять `Credentials` по их `Refresh token`
+ `ITSignOutInitiator` - инициатор отзыва авторизационных данных
+ `IAuthWebSessionSourceProvider` - провайдет источника для показа [ASWebAuthenticationSession](#Авторизация-через-ASWebAuthenticationSession)

В зависимости от архитектуры приложения можно использовать непосредственно`ITID` или каждый подпротокол отдельно в требуемой части системы.

### TAuthError
`TAuthError` типа `enum` описывает возможные ошибки авторизации

| Значение                     | Описание                                                      |
| ---------------------------- |---------------------------------------------------------------|
| `failedToLaunchApp`          | Не удалось запустить приложение Т-Банк                      |
| `failedToLaunchWebSession`   | Не удалось запустить web-сессию                               |
| `cancelledByUser`            | Авторизация отменена пользователем после перехода в Т-Банк  |
| `unavailable`                | Авторизация сторонних приложений недоступна для пользователя  |
| `failedToObtainToken`        | Не удалось завершить авторизацию после возврата из приложения |
| `failedToRefreshCredentials` | Не удалось обновить токены                                    |
| `invalidPhone`               | Передан номер телефона, не соответствующий `^\\+7\\d{10}`   |
| `invalidPresentationContext` | Передан невалидный контекст для презентации web-сессии       |
| `authWebSessionFailed`       | Авторизация в web-сессии не удалась                           |
| `invalidWebSessionAuthURL`   | Передан невалидный URL для web-сессии                         |
| `invalidWebSessionCallbackURL` | Передан невалидный callback URL для web-сессии             |
| `missingAuthCodeURL`         | Отсутствует URL для получения токена                          |

При получении ошибки рекомендуется предложить пользователю попробовать позже.

## Получение ITID

SDK поставляет публичную абстракцию `ITIDFactory` и публичный класс `TIDFactory`, реализующий её и служащий для сборки и предоставления объекта, реализующего `ITID`. 

```swift
// Идентификатор приложения
let clientId = "someClient"
// URL обратного вызова, необходимый для возврата в приложение
let callbackUrl = "myapp://authorized"

// Инициализация фабрики ITID
let factory = TIDFactory(
    clientId: clientId,
    callbackUrl: callbackUrl
)
// Получение ITID
let tid = factory.build()
```

После получения `ITID`, приложение может начинать авторизацию.

## Авторизация

### Перед началом

`ITAuthInitiator` может предоставить информацию о возможности выполнения авторизации с помощью флага `isTAuthAvailable`. Поднятый флаг означает, что у пользователя установлено приложение Т-Банк, через которое можно осуществить вход. При вызове метода `startTAuth` с поднятным флагом будет осуществлен переход в заданное приложение для инициализации авторизации, в случае если флаг опущен, пользователь будет перенаправлен на страницу этого приложения в App Store.

### Выполнение авторизации

Для начала авторизации необходимо вызвать метод `startTAuth` объекта `ITAuthInitiator`:

```swift
tid.startTAuth { result in
    do {
        let payload = try result.get()
        print("Access token obtained: \(payload.accessToken)")
    } catch {
        print(error)
    }
}
```

Вызов этого метода приведет к перенаправлению пользователя в приложение Т-Банк для подтверждения авторизации приложения.

### Продолжение авторизации

После подтверждения авторизации пользователем будет произведен возврат в авторизуемое приложение для завершения авторизации. Обратный переход будет осуществлен с помощью URL обратного вызова, предоставленным приложением. Задача приложения на этом этапе в том, чтобы передать полученный `AppDelegate` URL в метод `handleCallbackUrl` объекта `ITAuthCallbackHandler`:

```swift
func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
) -> Bool {
    return tid.handleCallbackUrl(url)
}
```

SDK обработает переданные в URL параметры завершит авторизацию, передав объект `Result<TTokenPayload, TAuthError>` в блок, определенный при вызове `startTAuth()`.

### Обновление авторизационных данных

Время от времени приложению необходимо получать актуальный объект `TTokenPayload` (например, когда срок жизни предыдущего истек).

Для этого необходимо вызвать метод `obtainTokenPayload` объекта `ITCredentialsRefresher` как показано ниже:

```swift
let credentials: TTokenPayload = ...

tid.obtainTokenPayload(using: credentials.refreshToken) { result in
    do {
        let newCredentials: TTokenPayload = try result.get()
    } catch {
        print(error)
    }
}
```

### Отзыв авторизационных данных

Иногда может возникнуть ситуация когда полученные авторизационные данные более не нужны. Например, при выходе смене или отключении аккаунта пользователя в авторизованном приложении. В таком случае, приложению необходимо выполнить отзыв авторизационных данных с помощью `ITSignOutInitiator`:

```swift
let credentials: TTokenPayload = ...

tid.signOut(with: credentials.accessToken, tokenTypeHint: .access, completion: { result in
    do {
        _ = try result.get()
        
        print("Signed out")
    } catch {
        print(error)
    }
})
```

### Структура TTokenPayload

В результате успешной авторизации приложение получает объект `Credentials`, содержащий следующие свойства:

+ `accessToken` - токен для обращения к API Т-Банк
+ `refreshToken` - токен, необходимый для получения нового `accessToken`. Может отсутствовать в случае если пользователь запретил авторизуемому приложению доступ в любое время
+ `idToken` - идентификатор пользователя в формате JWT
+ `expirationTimeout` - время, через которое `accessToken` станет неактуальным и нужно будет получить новый с помощью `refreshToken`

### Хранение Refresh Token

При получении `TTokenPayload` и наличии у него поля `refreshToken` имеет смысл сохранить значение этого поля чтобы иметь возможность запросить новый `accessToken`, когда прежний станет неактивным. Рекомендуемый способ хранения токена - [Keychain Services](https://developer.apple.com/documentation/security/keychain_services)

## Авторизация через ASWebAuthenticationSession

Помимо сценария `App to App`, в SDK также поддерживается авторизация в формате `App to Web`. Это может потребоваться в следующих случаях:
- **Приложение Т-Банк не установлено** или недоступно для открытия через Universal Link.
- **Необходима авторизация через White Label**, когда требуется брендирование формы авторизации под дизайн партнёра.

Для корректной работы авторизации в Web необходимо:
1. Установить в `TargetAppConfiguration` значение `usesUniversalLinks = true`. (Для `TApp` это уже установлено **по умолчанию**)
2. Передать провайдер `IAuthWebSessionSourceProvider` в фабрику при инициализации SDK.

### Сценарий App to Web

Если на устройстве пользователя **не установлено приложение Т-Банк** или оно недоступно для открытия по `Universal Link`, SDK попытается открыть `ASWebAuthenticationSession` для веб-авторизации. Для этого выполните следующие шаги:

```swift
let factory = TIDFactory(
    clientId: clientId,
    callbackUrl: callbackUrl
    // ваш кастомный webSessionSourceProvider
)

// Инстанс SDK
let tid = factory.build()

// Вызов авторизации
tid.startTAuth { result in
    // ...
}
```

1. После вызова `startTAuth` пользователю будет предложена авторизация по номеру телефона.
2. В случае успешной авторизации в Web-сессии автоматически передаст управление обратно в SDK для продолжения процесса.

### Сценарий White Label

Сценарий `White Label` подразумевает авторизацию строго через Web-сессию с возможностью брендирования веб-формы под дизайн партнёра. 
Чтобы воспользоваться White Label:
```swift

// При инициализации добавьте флаг .whiteLabel
let factory = TIDFactory(
    clientId: clientId,
    callbackUrl: callbackUrl,
    mode: .whiteLabel
    // ваш кастомный webSessionSourceProvider
)

// Инстанс SDK
let tid = factory.build()

// При вызове авторизации, используйте новую функцию с номером телефона пользователя
tid.startTAuth(phone: "+79999999999") { result in
    // ...
}
```
**Важно:** поддерживаются только номера, соответствующие регулярному выражению `^\\+7\\d{10}`. При несоответствии данному формату будет выброшена ошибка `.invalidPhone`.

1. После открытия Web-сессии пользователь сразу попадает на экран ввода кода из СМС.
2. В случае успешной авторизации Web-сессии автоматически передаст управление обратно в SDK для продолжения процесса.

## UI
SDK поставляет два варианта фирменных кнопок входа через Т-Банк.
Первый вариант - стандартная прямоугольная кнопка с текстом, с возможностью задать текст, радиус скругления и шрифт. Так же можно выбрать один из трех вариантов цветового стиля и размера. Есть возможность добавить дополнительный текст для привлечения клиентов.
Второй вариант - компактная кнопка без текста, так же можно выбрать один из трех цветовых стилей. 
```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    // Создание стандартной кнопки
    let button = TIDButtonBuilder.build()
    
    // Добавление обработчика нажатия
    button.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
    
    // Добавление в иерархию
    view.addSubview(button)
    
    // Отступ кнопки от краёв
    let padding: CGFloat = 16
    
    // Расположение кнопки на экране
    button.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
    ])
}
```

Обратите внимание: после получения кнопки необходимо расположить её на экране, а также добавить обработчик события нажатия. 
Для верстки рекомендуется использовать `AutoLayout` без указания высоты так как она задается с помощью `intrinsicContentSize`.

Более подробно ознакомиться с правилами размещения кнопки Вы можете [здесь](https://www.figma.com/file/Yj3o7yQotahvBxfIKhBmJc/Tinkoff-ID-guide).

## Отладка без приложения Т-Банк
В случаях когда необходима отладка интеграции `T-ID` без приложения Т-Банк или на симуляторе iOS, SDK предоставляет реализацию T-ID для отладки.

Её отличия от основной реализации:
* Вместо приложения Т-Банк переход происходит в специальное приложение, позволяющее выбрать сценарий авторизации
* Не происходит запросов к серверам Т-Банк

### Настройка приложения
Для того, чтобы разрешить приложению переход в приложение для отладки, необходимо в `plist` файл вашего приложения добавить следующее:

```xml
<key>LSApplicationQueriesSchemes</key>
    <string>tiddebug</string>
</array>
```

Далее необходимо установить приложение `T-ID-Debug` на устройство или симулятор. Проект приложения находится [здесь](https://opensource.tbank.ru/mobile-tech/T-ID-iOS/tree/master/Example-Debug).

ℹ️ Реализация SDK для отладки использует тот же интерфейс `ITID`, что и стандартная реализация, поэтому при соблюдении принципа инверсии зависимостей вы можете внедрить её без изменения кода своего приложения. Также `ITIDFactory` представляет собой абстрактную фабрику, что позволяет при соблюдении того же принципа внедрять и её вместо внедрения уже собранного объекта `ITID`.

### Получение реализации `ITID` для отладки
Теперь, когда ваше приложение настроено и приложение-отладчик установлено, можно собрать реализацию `ITID` для отладки. Сделать это можно следующим образом:

```swift
// Ссылка по которой будет осуществлен возврат в приложение
let callbackUrl: String = ""

// Конфигурация для отладки
let configuration = DebugConfiguration(
    canRefreshTokens: true, // Если флаг `canRefreshTokens` поднят, то обновление токенов будет завершаться без ошибки
    canLogout: true // Если флаг `canLogout` поднят, выход из приложения будет завершаться без ошибки
)

// Фабрика, возвращающая реализацию ITID для отладки
let factory: ITIDFactory = DebugTIDFactory(
    callbackUrl: callbackUrl,
    configuration: configuration
)

// Реализация ITID для отладки
let debugTID: ITID = factory.build()
```

Далее вы можете использовать полученный объект, как обычный `ITID`.

### Приложение для отладки
После вызова метода `startTAuth` у реализации `ITID` для отладки вы попадете в отладочное приложение. После перехода вам будет представлен список возможных действий, а именно:
* `Вернуться и успешно завершить вход` - возвращает обратно в ваше приложение и успешно отдает токены-заглушки
* `Вернуться и не завершить вход` - возвращает обратно в ваше приложение и завершает вход с ошибкой получения токенов
* `Отменить вход` - возвращает обратно в ваше приложение и симулирует отмену входа пользователем
* `Симуляция недоступности входа` - возвращает обратно в приложение и симулирует недоступность `T-ID` для пользователя

## Пример приложения

SDK поставляется с примером приложения. Для запуска примера склонируйте репозиторий, выполните команду `pod install` в папке Example, откройте сгенерированный `.xcworkspace`файл и запустите проект.

Приложение включает в себя `AppDelegate` и `AuthViewController`.

### AppDelegate

`AppDelegate` создает `AuthViewController` и устанавливает его в качестве корневого контроллера окна приложения. При запуске приложения создается фабрика `ITIDFactory`, собирающая `ITID` в методе `applicationDidFinishLaunching` и передающая его в качестве параметров при инициализации `AuthViewController`.

⚠️ Обратите внимание! В `AppDelegate.swift` определена структура `Constant`, одним из полей которой является `clientId` типа  `String`. Для тестирования авторизации необходимо заменить её содержимое `client_id`, полученным при регистрации в T-ID.

### AuthViewController

`AuthViewController` инициируется ссылками на объекты, реализующими `ITAuthInitiator`, `ITCredentialsRefresher`, `ITSignOutInitiator` и `IAuthWebSessionSourceProvider` соответственно.

## Поддержка
Сообщать об ошибках и запрашивать новый функционал можно в разделе [Issues](https://opensource.tbank.ru/mobile-tech/T-ID-iOS/issues)
Почта для обращений - `tid_support@tbank.ru`
