# DropboxSync

[![CI Status](http://img.shields.io/travis/Daniel Green/DropboxSync.svg?style=flat)](https://travis-ci.org/Daniel Green/DropboxSync)
[![Version](https://img.shields.io/cocoapods/v/DropboxSync.svg?style=flat)](http://cocoapods.org/pods/DropboxSync)
[![License](https://img.shields.io/cocoapods/l/DropboxSync.svg?style=flat)](http://cocoapods.org/pods/DropboxSync)
[![Platform](https://img.shields.io/cocoapods/p/DropboxSync.svg?style=flat)](http://cocoapods.org/pods/DropboxSync)

By implementing the DropboxSyncable protocol methods in your class will make the class syncable via Dropbox:
```swift
public protocol DropboxSyncable {
    func uniqueIdentifier() -> String
    func lastUpdatedDate() -> NSDate
    func serializeForSync() -> NSData
    static func deserializeForSync(data: NSData)
}
```

There are many different ways to "sync" files. DropboxSync will currently, quite naively, replace versions stored in Dropbox with the most recently changed. It's simple, but for the moment it fulfills my own requirements. Pull requests very welcome.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

DropboxSync is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "DropboxSync"
```

## Author

Daniel Inkpen, dan2552@gmail.com

## License

DropboxSync is available under the MIT license. See the LICENSE file for more info.
