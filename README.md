AQSPocketActivity
=================

[iOS] UIActivity class for Pocket

![](http://img.shields.io/cocoapods/v/AQSPocketActivity.svg?style=flat) [![Build Status](https://travis-ci.org/AquaSupport/AQSPocketActivity.svg?branch=master)](https://travis-ci.org/AquaSupport/AQSActionMessageActivity)

Usage
---

```objc
UIActivity *pocketActivity = [[AQSPocketActivity alloc] init];

UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:pocketActivity];

[self presentViewController:activityViewController animated:YES completion:NULL];
```

Accepted `activityItems` Types
---

- `NSURL` (Accepts multiple)

Can perform activity when
---

- When Pocket iOS App is installed.
- At least one `NSURL` is provided.

Setup
---

`AQSPocketActivity` requires 3-min setup.

1. Regist Pocket App http://getpocket.com/api/signup with "Add" capability and obtain a consumer key. (`consumerKey`)
2. Setup URL Scheme for receiving callback from Pocket iOS App. 
  1. Setup URL Scheme like `pocketapp42` where `42` is your `consumerKey`'s first part. (For consumer key `12345-abcdefghijklmn`, the number is `12345`)
  2. Set the URL Identifier for the URL Scheme `com.getpocket.sdk`.
3. On your `- application:didFinishLaunchingWithOptions:`, call `[AQSPocketActivity setupPocketWithConsumerKey:consumerKey]`
4. On your `- application:handleOpenURL:`, call `[AQSPocketActivity handleOpenURL:url]`

Combining them, `AppDelegate` will be like as follow.

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AQSPocketActivity setupPocketWithConsumerKey:@"12345-abcdefghijklmn"];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([AQSPocketActivity handleOpenURL:url] == YES) {
        return YES;
    }
    
    // Put your code for handling passed URL.
    return NO;
}
```

Installation
---

```
pod "AQSPocketActivity"
```

Link to Documents
---

https://dl.dropboxusercontent.com/u/7817937/___doc___AQSPocketActivity/html/index.html

Related Projects
---

- [AQSShareService](https://github.com/AquaSupport/AQSShareService) - UX-improved sharing feature in few line. 

References
---

- Pocket/Pocket-ObjC-SDK : https://github.com/Pocket/Pocket-ObjC-SDK
- Pocket: Developer API : http://getpocket.com/developer/apps/new
