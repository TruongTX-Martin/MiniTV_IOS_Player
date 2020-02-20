


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

|        name       |       type       | default |     description    |
|:-----------------:|:----------------:|:-------:|:------------------:|
|   containerView   |      UIView      |         | container ui view  |
|   viewController  | UIViewController |         | ui view controller |
| serviceAppVersion |      String      |   1.0   | app version        |
|        url        |      String      |         | class link         |

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
* waiting : 수업 대기 중 
* started : 수업 시작
* ended : 수업 종료
* errorOcccured : 에러 발생








