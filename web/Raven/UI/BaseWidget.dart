library Raven.BaseWidget;

import "dart:html";
import "../Gfx/Gfx.dart";
import "../Utils/Vec2.dart";
import "../BaseTypes.dart";

class BaseWidget implements Renderable, Clickable{
  Vec2 m_vPos;
  BaseWidget m_xParent;
  List<BaseWidget> m_xChildren;
  List<dynamic> m_xClickEventListeners;
  String m_sClickEvent;
  Gfx m_xBackground;
  String m_sBgColor;
  int m_iW;
  int m_iH;
  int m_iRenderLayer;
  bool m_bVisible;
  bool m_bDraggable;
  bool m_bMouseDown;
  String m_sName;
  WorldOffset m_xOffset;
  bool m_bIgnoreVisCheck;
  
  BaseWidget(){
    m_xChildren=new List<BaseWidget>();
    m_vPos=new Vec2(0.0,0.0);
    m_sBgColor="#ff0000";
    m_iW=0;
    m_iH=0;
    m_bVisible=true;
    m_iRenderLayer=14;
    m_sName="";
    m_xClickEventListeners=new List<dynamic>();
    m_sClickEvent="";
    m_bIgnoreVisCheck=true;
    m_bDraggable=false;
    m_bMouseDown=false;
  }
  void SetIgnoreVisCheck(bool p_bCheck){m_bIgnoreVisCheck=p_bCheck;}
  void SetOffset(WorldOffset p_xOffset){
    m_xOffset=p_xOffset;
  }
  void SetName(String p_sName){
    m_sName=p_sName;
  }
  void RegisterClickEventListener(dynamic p_xCallback){
    m_xClickEventListeners.add(p_xCallback);
  }
  void ParseProperties(Map p_xProperties){
    Map xP=p_xProperties;
    num x=0.0;
    num y=0.0;
    
   
    m_iW=(xP.containsKey("w")?xP["w"]:0);
    m_iH=(xP.containsKey("h")?xP["h"]:0);
    if(xP.containsKey("x")){
      if(xP["x"] is String){
        if(xP["x"]=="center"){
          if(m_xParent==null){
            DivElement xD=querySelector("#wrap");
            x=(xD.clientWidth/2)-(m_iW/2);
          }else{
            x=((m_xParent.m_vPos.m_fX+m_xParent.m_iW)/2)-(m_iW/2);
          }
        }
      }else{
        x=xP["x"];
      }
      if(xP["y"] is String){
        if(xP["y"]=="center"){
          if(m_xParent==null){
            DivElement xD=querySelector("#wrap");
            y=(xD.clientHeight/2)-(m_iH/2); 
          }else{
            y=((m_xParent.m_vPos.m_fY+m_xParent.m_iH)/2)-(m_iH/2);
          }
        }
      }else{
        y=xP["y"]; 
      }
      
    }
    m_vPos.m_fX=x;
    m_vPos.m_fY=y;
    m_iRenderLayer=(xP.containsKey("l")?xP["l"]:m_iRenderLayer);
    m_bVisible=(xP.containsKey("visible")?xP["visible"]:true);
    m_sBgColor=(xP.containsKey("bgcolor")?xP["bgcolor"]:"");
    m_iRenderLayer=(xP.containsKey("l")?xP["l"]:14);
    m_bDraggable=(xP.containsKey("draggable")?xP["draggable"]:m_bDraggable);
    if(xP.containsKey("imgsrc")){
      m_xBackground=new Gfx.create(xP["imgsrc"], new Vec2(0.0,0.0), m_iW, m_iH, 1, false);
    }
    if(xP.containsKey("events")){
      if((xP["events"] as Map).containsKey("click")){
        m_sClickEvent=xP["events"]["click"];
        
      }
    }
    if(m_xParent!=null){
      BaseWidget xCurr=m_xParent;
      while(xCurr!=null){
        m_iRenderLayer+=1;
        xCurr=xCurr.m_xParent;
      }  
    }
    
    document.onClick.listen(onClick);
  }
  void onClick(MouseEvent p_xEvent){
    if(!m_bVisible){return;}
    int x=p_xEvent.offset.x;
    int y=p_xEvent.offset.y;
    Vec2 vP=CalculateAbsolutePosition();
    if(x<vP.m_fX||x>vP.m_fX+m_iW){return;}
    if(y<vP.m_fY||y>vP.m_fY+m_iH){return;}
    
    if(m_sClickEvent.length>0){
      document.dispatchEvent(new CustomEvent("UIClick", canBubble: true, cancelable: true, detail: {"t":m_sClickEvent}));
    }
    
    p_xEvent.preventDefault();
  }
  void onMouseUp(MouseEvent p_xEvent){
    m_bMouseDown=false;
  }
  void onMouseDown(MouseEvent p_xEvent){
    m_bMouseDown=true;
  }
  void onMouseMove(MouseEvent p_xEvent){
    if(m_bMouseDown){
      Vec2 vLocal=new Vec2(p_xEvent.offset.x-this.m_vPos.m_fX, p_xEvent.offset.y-this.m_vPos.m_fY);
      if(vLocal.m_fX<0||vLocal.m_fY<0){return;}
      if(vLocal.m_fX>m_iW){return;}
      if(vLocal.m_fY>m_iH){return;}
      
      this.m_vPos.m_fX=p_xEvent.offset.x-vLocal.m_fX;
      this.m_vPos.m_fY=p_xEvent.offset.y-vLocal.m_fY;
    }
  }
  void AddChild(BaseWidget p_xW){
    p_xW.m_xParent=this;
    m_xChildren.add(p_xW);
  }
 
  Vec2 CalculateAbsolutePosition(){
    Vec2 vParents=new Vec2(0.0,0.0);
    if(m_xParent!=null){
      vParents.AddV(m_xParent.CalculateAbsolutePosition());
    }
    return vParents+m_vPos;
  }
  bool IsVisible(){
    bool bVis=m_bVisible;
    BaseWidget xCurr=m_xParent;
    while(xCurr!=null){
      if(xCurr.m_bVisible==false){
        bVis=false;
        break;
      }
      xCurr=xCurr.m_xParent;
    }
    return bVis;
  }
  void Render(CanvasRenderingContext2D p_xCtx){
    if(IsVisible()==false){return;}
    Vec2 vP=CalculateAbsolutePosition();
    if(m_xBackground!=null){
      m_xBackground.m_vPos.m_fX=vP.m_fX;
      m_xBackground.m_vPos.m_fY=vP.m_fY;
      m_xBackground.Render(p_xCtx);
    }else{
      if(m_sBgColor.length>0){
        p_xCtx.fillStyle=m_sBgColor;
        p_xCtx.fillRect(vP.m_fX, vP.m_fY, m_iW, m_iH);
      }
    }
  }
}

class EditableBaseWidget extends BaseWidget{
  bool m_bSelected;
  Gfx m_xEditSelection;
  
  EditableBaseWidget() : super(){
    m_xEditSelection=new Gfx.create("assets/editselected.png", new Vec2(0,0), 10, 10, this.m_iRenderLayer+1,true);
    m_bSelected=false;
  }
  
  void onClick(MouseEvent p_xEvent){
    if(!m_bVisible){return;}
    int x=p_xEvent.offset.x;
    int y=p_xEvent.offset.y;
    Vec2 vP=CalculateAbsolutePosition();
    if(x<vP.m_fX||x>vP.m_fX+m_iW){return;}
    if(y<vP.m_fY||y>vP.m_fY+m_iH){return;}
    
    m_bSelected=!m_bSelected;
    
    p_xEvent.preventDefault();
    document.dispatchEvent(new CustomEvent("UIEditableClick", cancelable: true, canBubble: true, detail: {"t":this}));
  }
  void Render(CanvasRenderingContext2D p_xCtx){
    if(IsVisible()==false){return;}
    Vec2 vP=CalculateAbsolutePosition();
    if(m_xBackground!=null){
      m_xBackground.m_vPos.m_fX=vP.m_fX;
      m_xBackground.m_vPos.m_fY=vP.m_fY;
      m_xBackground.Render(p_xCtx);
    }else{
      if(m_sBgColor.length>0){
        p_xCtx.fillStyle=m_sBgColor;
        p_xCtx.fillRect(vP.m_fX, vP.m_fY, m_iW, m_iH);
      }
    }
    if(m_bSelected){
      m_xEditSelection.m_vPos=this.m_vPos.Copy();
      m_xEditSelection.m_iW=this.m_iW;
      m_xEditSelection.m_iH=this.m_iH;
      m_xEditSelection.Render(p_xCtx);
    }
  }
}