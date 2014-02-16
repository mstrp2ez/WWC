library Raven.Websocket;

import "dart:html";
import "dart:typed_data" show Uint8List;
import "dart:async";
//import "../BaseTypes.dart";

class Network{
  static int m_iPlayerID;
  static Network m_xInstance;
  bool m_bLoggedIn;
  WebSocket m_xSocket;
  Map<int,String> m_xOpCodes;
  
  Network._internal(String p_sHost){
    m_xSocket=new WebSocket(p_sHost);
    m_xSocket.binaryType="arraybuffer";
    m_xSocket.onOpen.listen(onConnect);
    m_xSocket.onMessage.listen(onData);
    m_bLoggedIn=false;
    m_xOpCodes={0x02:"NetLoggedIn",0x01:"NetMessage",0x03:"NetSnapshot",0x08:"NetFullSnapshot"};
    window.on["NetLoggedIn"].listen(onLoggedIn);
  }
  
  factory Network.create(String p_sHost){
      if(m_xInstance==null){
        m_xInstance=new Network._internal(p_sHost);
      }
      return m_xInstance;
  }
  void onLoggedIn(CustomEvent p_xEvent){
    Uint8List xData=p_xEvent.detail["d"];
    String sResult=new String.fromCharCodes(xData.sublist(0, 2));
    if(sResult=="ok"){
      int iIdx=2;
      int iTmpID=xData[iIdx++];
      iTmpID=(iTmpID<<8)|xData[iIdx++];
      iTmpID=(iTmpID<<16)|xData[iIdx++];
      iTmpID=(iTmpID<<24)|xData[iIdx++];
      
      m_iPlayerID=iTmpID;
      m_bLoggedIn=true;
      window.console.log("Logged in");
      window.dispatchEvent(new CustomEvent("NetLoggedInOk"));
      return;
    }
    window.dispatchEvent(new CustomEvent("NetLoggedInFail"));
  }
  void Send(Uint8List p_xData){
    if(m_xSocket.readyState!=WebSocket.OPEN){new Timer(new Duration(milliseconds:5),(){
        this.Send(p_xData);
        
      });
      return;
    }
    m_xSocket.send(p_xData);
  }
  
  void onData(MessageEvent p_xEvent){
   Uint8List xData=p_xEvent.data;

    int iOpCode=xData[0];
    xData=xData.sublist(1);
    if(m_xOpCodes.containsKey(iOpCode)){
      String sType=m_xOpCodes[iOpCode];
      window.dispatchEvent(new CustomEvent(sType, canBubble: false, cancelable: false,detail:{"d":xData}));
    }
  }
  void onConnect(Event p_xEvent){
    window.console.log("Connected");
  }
}