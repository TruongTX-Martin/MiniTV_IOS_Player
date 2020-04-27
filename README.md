## 지원 버전

- IOS : 11.0 (2017년 9월 19일 출시)
- H/W : iPhone 6 이후

## Architecture

## Usage

```
import MinischoolOne
```

**MSPlayer**

player 초기화

```
self.player = MinischoolOne.MSPlayer(self.view, viewController: self, serviceAppVersion: serviceAppVersion, url: url)
```

|       name        |       type       | default |    description     |
| :---------------: | :--------------: | :-----: | :----------------: |
|   containerView   |      UIView      |         | container ui view  |
|  viewController   | UIViewController |         | ui view controller |
| serviceAppVersion |      String      |   1.0   |    app version     |
|        url        |      String      |         |     class link     |

class 진입 및 실행

```
self.player.run()
```

class 종료

```
@objc func didEnterBackground(_ notification: Notification) {
    print("didEnterBackground")
    self.player.closeAll()
}

override func viewWillDisappear(_ animated: Bool) {
    print("viewWillDisappear")
    self.player.closeAll()
}
```

**MSPlayerDelegate**

```
self.player.delegate = self

func MSPlayer(_ player: MSPlayer, didChangedStatus newStatus: MSPlayerStatus) {
    switch newStatus {
    case .waiting:
        print("waiting")
    case .started:
        print("started")
    case .ended:
        print("ended")
    default:
        print("errorOcccured")
    }
}
```

```
    func MSPlayer(_ player: MSPlayer, errorOccured error: Error) {
        print(error.localizedDescription)
    }
```

**MSPlayerStatus**

- waiting : 수업 대기 중
- started : 수업 시작
- ended : 수업 종료
- errorOcccured : 에러 발생

**Native Logs**

Sample:
{
  "message": "Test send native logs",
  "serviceAppVersion": "1.0",
  "frameworkVersion": "1.3.3",
  "deviceInfo": {
    "model": "iPhone XS Max",
    "os": "iOS 13.4.1",
    "name": "Michael’s iPhone XS Max",
    "camera_status": "Authorized",              // Authorized, Denied, Not Determined, Unknown
    "microphone_status": "Granted",          // Granted, Denied, Not Determined, Unknown
    "speaker": {
      "status": "OFF",                                  // ON, OFF
      "volume": 0.6686747074127197        // 0.0 representing the minimum volume and 1.0 representing the maximum volume.
    },
    "network": {
      "type": "4G",                                      // WIFI, 4G, 3G, 2G, NO INTERNET
      "status": "Connected"                      // Connected/ Not Connected
    }
  }
}
