# VoiceManager
Swift VoiceManager

```
startEnable:Bool 錄音狀態

VoiceManager.recordVoice(ViewController, startEnable: true)
{ (permissionStatus, seconds, secString, status, url) in
  // permissionStatus:Bool   權限狀態
  // seconds:Float           錄音秒數
  // secString:String        錄音時間(00:00:00)
  // status:Bool             是否正在錄音
  // url:URL                 產生檔案路經
}
```
