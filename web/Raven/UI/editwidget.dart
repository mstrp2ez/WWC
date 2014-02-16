library Raven.EditWidget;

import "dart:html";
import "dart:async";
import "BaseWidget.dart";
import "../Utils/Vec2.dart";

class EditWidget extends BaseWidget{
  String m_sBorderColor;
  String m_sHighlightBorderColor;
  String m_sBackgroundColor;
  String m_sText;
  bool m_bFocused;
  List<Function> m_xEditCallbacks;

  
  EditWidget() : super(){
    m_sBorderColor="#555555";
    m_sHighlightBorderColor="#eeeeee";
    m_sBackgroundColor="#333333";
    m_bFocused=false;
    m_sText="";
    
    m_xEditCallbacks=new List<Function>();
    
    document.onClick.listen(onClick);
    document.onKeyDown.listen(onKeyDown);
  }
  
  void onKeyDown(KeyboardEvent p_xEvent){
    int iW=p_xEvent.which;
    
    if(!m_bFocused){return;}
    
    if(iW==8){ //backspace
      if(m_sText.length>0){
        m_sText=m_sText.substring(0, m_sText.length-1);
      }
    }else{
      String sNC=new String.fromCharCode(iW);
      RegExp xTest=new RegExp(".*[0-9].*");
      if(xTest.hasMatch(sNC)){
        m_sText+=sNC;
      }
    }
    
    
    p_xEvent.preventDefault();
    m_xEditCallbacks.forEach((e){
      (e(m_sText));
    });
  }
  
  void RegisterEditCallback(Function p_xF){
    if(m_xEditCallbacks.contains(p_xF)){return;}
    m_xEditCallbacks.add(p_xF);
  }
  
  void onClick(MouseEvent p_xEvent){
    Vec2 vP=CalculateAbsolutePosition();
    Vec2 vLocal=new Vec2(p_xEvent.offset.x-vP.m_fX, p_xEvent.offset.y-vP.m_fY);
    if(vLocal.m_fX<0||vLocal.m_fY<0){m_bFocused=false;return;}
    if(vLocal.m_fX>m_iW){m_bFocused=false;return;}
    if(vLocal.m_fY>m_iH){m_bFocused=false;return;}
    
    m_bFocused=true;
    p_xEvent.preventDefault();
    
    
  }
  
  void Render(CanvasRenderingContext2D p_xCtx){
    if(!IsVisible()){return;}
    p_xCtx.strokeStyle=(m_bFocused)?m_sHighlightBorderColor:m_sBorderColor;
    p_xCtx.fillStyle=1;
    
    Vec2 vP=CalculateAbsolutePosition();
    
    num x=vP.m_fX;
    num y=vP.m_fY;
    
    num w=m_iW;
    num h=m_iH;
    
  //  p_xCtx.save();
    
    p_xCtx.beginPath();
    p_xCtx.moveTo(x,y);
    p_xCtx.lineTo(x+m_iW, y);
    p_xCtx.lineTo(x+m_iW, y+m_iH);
    p_xCtx.lineTo(x, y+m_iH);
    p_xCtx.closePath();
    p_xCtx.stroke();
    
  //  p_xCtx.clip();
    
    p_xCtx.fillStyle=m_sBackgroundColor;
    p_xCtx.fill();
    
    p_xCtx.font="12px Arial";
    p_xCtx.strokeText(m_sText, x+2, y, m_iW);
    
 //   p_xCtx.restore();

  }
  
}