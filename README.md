# Warning

Do not use the current version of this - it's unstable and may result in data loss. There is `refactor` branch that was started (a rewrite from scratch, with much much better conflict resolution), but I have no real reason to continue this project anymore. Feel free to adopt and use as you wish.

# DropboxSync

[![Version](https://img.shields.io/cocoapods/v/DropboxSync.svg?style=flat)](http://cocoapods.org/pods/DropboxSync)
[![License](https://img.shields.io/cocoapods/l/DropboxSync.svg?style=flat)](http://cocoapods.org/pods/DropboxSync)
[![Platform](https://img.shields.io/cocoapods/p/DropboxSync.svg?style=flat)](http://cocoapods.org/pods/DropboxSync)

There are many different ways to "sync" files, which is maybe why Dropbox themselves don't appear to provide a library with syncing. `DropboxSync` works on comparing the time that a record was last updated to keep the most up-to-date copy and replace older versions.

By implementing the `DropboxSyncable` protocol methods in your class will make the class syncable via Dropbox:

``` swift
public protocol DropboxSyncable {
    // Unique id, e.g. UUID
    func syncableUniqueIdentifier() -> String

    // Time the record was last updated
    func syncableUpdatedAt() -> Date

    // Serialize + Deserialize to save and load from Dropbox
    // Note: Make sure you don't update your updatedAt when deserializing
    func syncableSerialize() -> Data
    static func syncableDeserialize(_ data: Data)

    // Deletes are synced too
    static func syncableDelete(uniqueIdentifier: String)
}
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

DropboxSync is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "DropboxSync"
```

### 1. Create an app in [Dropbox developer "My apps"](https://www.dropbox.com/developers/apps)

- You can leave the settings as default
- Note the `App key`

### 2. Put the Dropbox settings in `Info.plist`:

- [Manually](https://github.com/dropbox/SwiftyDropbox#application-plist-file) or;
- Add the following to your [`Ambientfile`](https://github.com/Dan2552/ambient-xcode):
  - replace `{DIRECTORY}` with the relative directory that the file sits in
  - replace `{APP_KEY}` with your `App Key`

``` ruby
plist "{DIRECTORY}/Info.plist" do
  entry "CFBundleURLTypes", [
    { "CFBundleTypeRole" => "Editor", "CFBundleURLSchemes" => [ "db-{APP_KEY}" ] }
  ]
  entry "LSApplicationQueriesSchemes", [ "dbapi-2", "dbapi-8-emm"]
end
```

### 3. Call setup within your `AppDelegate`:

- replace `{APP_KEY}` with your `App Key`

``` swift
import DropboxSync

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    DropboxSyncAuthorization.setup(appKey: {APP_KEY})
    return true
}
```

### 4. Support the redirect callback in `AppDelegate`:

``` swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
    DropboxSyncAuthorization.handleRedirect(url: url)
    return true
}
```

### 5. Allow the user to login to their Dropbox in your UI flow:

``` swift
DropboxSyncAuthorization.authorize()
```

### 6. Declare/schedule your sync

``` swift
DropboxSync(Database.objects(Note.self)).sync()
```

if you want to run it at an interval, you can use `Timer`:

``` swift
timers.append(Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
    DropboxSync(Database.objects(Note.self)).sync()
})
```

## Author

Daniel Inkpen, dan2552@gmail.com

## License

DropboxSync is available under the MIT license. See the LICENSE file for more info.
