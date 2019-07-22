//
//  UIViewController+ViewControllerObjC.h
//  Minischool-Demo
//
//  Created by JONGYOUNG CHUNG on 21/07/2019.
//  Copyright © 2019 Minischool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MinischoolOne"

@interface ViewController: UIViewController, MSPlayerDelegate ()
    MSPlayer player;

NSString serviceAppVersion = "1.0";
NSString url = "http://172.16.3.95:8080";
    //    let url = "https://stage-p2.minischool.co.kr/preview/"

    let classKeyAndToken = "Y2sxNTYzMjU4NDQ3MTAydG9rZW4xMDE1NjE2OTA2Nzg5NDM="
    let role = "s"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.player = MinischoolOne.MSPlayer(self.view, viewController: self, serviceAppVersion: serviceAppVersion, url: url, classKeyAndToken: classKeyAndToken, role: role)
        
        self.player.delegate = self
        
        self.player.run()
    }

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

    func MSPlayer(_ player: MSPlayer, errorOccured error: Error) {
        print(error.localizedDescription)
    }
@end

NS_ASSUME_NONNULL_END
