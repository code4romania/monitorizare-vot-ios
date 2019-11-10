# Important, before you start

## Local build configuration

In order to run the app on your device, make sure you create a `LocalConfiguration.xcconfig` file in this folder and add your own bundle id, team id and signing preference. Its structure is the same as the `CustomConfiguration.xcconfig` file, but, obviously skip the `#include` directive.

This file will not be committed to the repository (it's in the `.gitignore`), but will be included by XCode and it will update the information automatically. Also, because we're using this local config structure, don't make changes to the build settings regarding the bundle id, team id or signing preference. If you did so, just delete the custom values and let the build settings be updated from the xcconfig files.

If you want to use the `dev` API, copy the Development link that's commented in the `CustomConfiguration.xcconfig` and use it in your own `LocalConfiguration.xcconfig`. If you want to test production, don't add an `API_URL` variable at all.

This might seem obvious, but don't make any changes directly into `CustomConfiguration.xcconfig`, because they'll be committed with the rest of the changes. Use `LocalConfiguration.xcconfig` for your own configs.

If you're interested in how this works, check out [this tutorial](https://www.matrixprojects.net/p/xcconfig-for-shared-projects/)

## Firebase

This project uses Firebase for event, usage tracking and Crashlytics for crash reports. So before you start work on it, you'll need to go to your Firebase console and create an app for this project, then download its `GoogleService-Info.plist` file and copy it in this folder. 

If you updated the app id in the previous step, in the local config file, use the same bundle identifier in Firebase console.
