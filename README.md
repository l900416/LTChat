# LTChat
Chat use XMPP framework and WebRTC framework

![](https://github.com/l900416/LTChat/blob/master/screenshots/1.png)
![](https://github.com/l900416/LTChat/blob/master/screenshots/2.png)

### Usage

#### Setp 1 Dependent


```Objective-C
    pod 'XMPPFramework', '~> 3.7.0'
    pod 'GoogleWebRTC' 
```

#### Step 2 Configuration


```Objective-C
    [LTChatConfig sharedInstance].xmppHost = @"192.168.1.75";
    [LTChatConfig sharedInstance].xmppPort = 8810;
    [LTChatConfig sharedInstance].xmppDomain = @"ms-linuxuat";
    [LTChatConfig sharedInstance].xmppResource = @"iOS";

```

#### Step 3 Usage

XMPP Messaging

```Objective-C
// Message Send
-(void)sendMessage:(NSString*)msg{
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.chatJid];
    [message addBody:msg];
    [[LTChatXMPPClient sharedInstance].xmppStream sendElement:message];
}

```


```Objective-C
    // Message Observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadChatData) name:kLTCHAT_XMPP_MESSAGE_CHANGE object:nil];

```

WebRTC Messaging

```Objective-C
- (void)didPressWebRTCButton:(UIButton *)sender{
    LTChatWebRTCClient *client = [LTChatWebRTCClient sharedInstance];
    client.myJID = [LTChatXMPPClient sharedInstance].xmppStream.myJID.full;
    client.remoteJID = self.chatJID.full;
    [client showRTCViewByRemoteName:self.chatJID.full isVideo:YES isCaller:YES];
}
```


### Upcoming features

 * Pod support
 * Chat Message UI
 * Video Call UI



## License

MIT License

Copyright (c) 2017 liangtong

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
