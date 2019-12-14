# Monitorizare Vot - iOS app [![Build status](https://build.appcenter.ms/v0.1/apps/742d5378-faae-4ad6-9204-d94eb3e98923/branches/master/badge)](https://appcenter.ms)

[![GitHub contributors](https://img.shields.io/github/contributors/code4romania/monitorizare-vot-ios.svg?style=for-the-badge)](https://github.com/code4romania/monitorizare-vot-ios/graphs/contributors) [![GitHub last commit](https://img.shields.io/github/last-commit/code4romania/monitorizare-vot-ios.svg?style=for-the-badge)](https://github.com/code4romania/monitorizare-vot-ios/commits/master) [![License: MPL 2.0](https://img.shields.io/badge/license-MPL%202.0-brightgreen.svg?style=for-the-badge)](https://opensource.org/licenses/MPL-2.0)

[See the project live](https://votemonitor.org/)

Monitorizare Vot is a mobile app for monitoring elections by authorized observers. They can use the app in order to offer a real-time snapshot on what is going on at polling stations and they can report on any noticeable irregularities.

The NGO-s with authorized observers for monitoring elections have real time access to the data the observers are transmitting therefore they can report on how voting is evolving and they can quickly signal to the authorities where issues need to be solved.

Moreover, where it is allowed, observers can also photograph and film specific situations and send the images to the NGO they belong to.

The app also has a web version, available for every citizen who wants to report on election irregularities. Monitorizare Vot was launched in 2016 and it has been used for the Romanian parliamentary elections so far, but it is available for further use, regardless of the type of elections or voting process.

[Contributing](#contributing) | [Built with](#built-with) | [Repos and projects](#repos-and-projects) | [Feedback](#feedback) | [License](#license) | [About Code4Ro](#about-code4ro)

## Contributing

This project is built by amazing volunteers and you can be one of them! Here's a list of ways in [which you can contribute to this project](.github/CONTRIBUTING.MD).

__IMPORTANT:__ Please follow the Code4Romania [WORKFLOW](.github/WORKFLOW.MD)

## Important, before you start

### Firebase

This project uses Firebase for event and usage tracking and Crashlytics for crash reports. So before you start work on it, you'll need to go to your Firebase console and create an app for this project, then download its `GoogleService-Info.plist` file and copy it to the `Config` folder.

### CocoaPods

This project uses CocoaPods for its dependency management, so make sure you install it if you didn't already, then run a `pod install` before you build the project.

## Built With

* Swift 5
* Core Data
* Firebase (Remote Config, Analytics, Crashlytics)
* Alamofire
* Reachability

Swagger docs for the API are available [here](https://mv-mobile-test.azurewebsites.net/swagger/index.html).

## Architecture

* The app is localized, meaning it's easier for any interested party to fork the project and use it in other countries, simply localizing the messages 
* The UI relies on the MvvM pattern
* The data is stored in the local Core Data instance and is uploaded to the server using the API described above
* In case of a faulty internet connection, the data is marked as unsynced (using the `synced` flag on interesting entities and we're automatically retrying when connection is re-established and when the user opening the app; there's also a manual sync function in the forms screen)
* We rely on Firebase's RemoteConfig for remote settings
* Most important events are logged using Firebase's Fabric events
* We monitor crashes using Firebase's Crashlytics
* The API client uses `Codable` models which are then transformed into Core Data models to be persisted locally

## Localization & Internationalization

The Localization files can be found in the `MonitorizareVot/Localizations` folder. If you want to add a new language, simply add it in Xcode, then copy the `Localizable.strings` and `InfoPlist.strings` files from the `Base`/`en` lproj folders and copy them in the new language's folder.

You should only update the strings on the right side of the `=` (equals sign). Make sure they're enclosed in double quotes (`"`) and that every line ends with a semicolon `;`.

In order to make the new language available (and maybe restrict other ones), make sure you edit the `ALLOWED_LANGUAGES` value in Build Settings (it's a comma separate list of language codes.

## Repos and projects

![alt text](https://raw.githubusercontent.com/code4romania/monitorizare-vot-ios/develop/vote_monitor_diagram.png)

- repo for the API - https://github.com/code4romania/monitorizare-vot
- repo for the Android app - https://github.com/code4romania/mon-vot-android-kotlin

Other related projects:

- https://github.com/code4romania/monitorizare-vot-ong

## Feedback

* Request a new feature on GitHub.
* Vote for popular feature requests.
* File a bug in GitHub Issues.
* Email us with other feedback contact@code4.ro

## License

This project is licensed under the MPL 2.0 License - see the [LICENSE](LICENSE) file for details

## About Code4Ro

Started in 2016, Code for Romania is a civic tech NGO, official member of the Code for All network. We have a community of over 500 volunteers (developers, ux/ui, communications, data scientists, graphic designers, devops, it security and more) who work pro-bono for developing digital solutions to solve social problems. #techforsocialgood. If you want to learn more details about our projects [visit our site](https://www.code4.ro/en/) or if you want to talk to one of our staff members, please e-mail us at contact@code4.ro.

Last, but not least, we rely on donations to ensure the infrastructure, logistics and management of our community that is widely spread across 11 timezones, coding for social change to make Romania and the world a better place. If you want to support us, [you can do it here](https://code4.ro/en/donate/).
