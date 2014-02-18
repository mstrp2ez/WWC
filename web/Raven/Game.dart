library Raven.Game;

import "dart:html";
import "dart:async";
import "BaseTypes.dart";
import "Renderer.dart";
import "UI/UI.dart";
import "UI/TextWidget.dart";
import "Gfx/Gfx.dart";

class Game{
  CanvasElement m_xCanvas;
  Renderer m_xRenderer;
  UI m_xUI;
  Timer m_xTimerHandle;
  int m_iTimerValue;
  TextWidget m_xTimerRef;
  Animation m_xAnimation;
  
  Game(this.m_xCanvas);
  
  void Init(){
  
    CanvasRenderingContext xContext=m_xCanvas.getContext('2d');
    WorldOffset xOffset=new WorldOffset();
    xOffset.m_fOffsetX=0.0;
    xOffset.m_fOffsetY=0.0;
    m_xRenderer=new Renderer(xContext, xOffset);
    m_iTimerValue=0;
    
    m_xUI=new UI(m_xRenderer, 0);
    m_xUI.Load("assets/mainmenu.json", 0, (e){
      document.on["UIClick"].listen(onUIClick);  
    });
    
    m_xAnimation=new Animation();
    m_xAnimation.Load("assets/playeranim.json").then((e){
      m_xRenderer.AddItem(m_xAnimation);
      m_xAnimation.SetAnimation(1);
    });

    
    Run(0);
  }
  
  void onUIClick(CustomEvent p_xEvent){
    if(!(p_xEvent.detail is Map)){return;}
    String sType=p_xEvent.detail["t"];
    
    if(sType=="onstartbtnclicked"){
      m_xUI.Load("assets/gameui.json",0,(e){
        m_xTimerRef=m_xUI.GetWidgetByName("timertext");
        m_xTimerHandle=new Timer.periodic(new Duration(seconds:1), (e){
          m_iTimerValue++;
          m_xTimerRef.m_sText=m_iTimerValue.toString();
        });
      });
      
      return;
    }
    if(sType=="onaboutbtnclicked"){
      
      return;
    }
  }
  
  void Run(num p_nDelta){
    m_xRenderer.ClearScreen();
    Update(p_nDelta);
    Render();
    
    window.animationFrame.then(this.Run);
  }
  void Update(num p_nDelta){


    m_xRenderer.Update(p_nDelta);
  }
  void Render(){
    m_xRenderer.Render();
  }
}