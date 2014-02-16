library Raven.UI;

import "dart:html";
import "dart:convert";
import "dart:mirrors";
import "BaseWidget.dart";
import "BtnWidget.dart";
import "TextWidget.dart";
import "../Renderer.dart";
import "editwidget.dart";


class UI{
  List<BaseWidget> m_xChildren;
  Renderer m_xRenderer;
  int m_iID;
  
  UI(this.m_xRenderer,[int p_iID=-1]){
    m_xChildren=new List<BaseWidget>();
    m_iID=p_iID;
  }
  
  void Load(String p_sSrc,[int p_iID=-1]){
    if(p_iID!=-1){
      m_iID=p_iID;
    }
    HttpRequest.getString(p_sSrc).then(onLayoutLoaded);
  }
  
  void onLayoutLoaded(String p_sData){
    Map xLayout=JSON.decode(p_sData);
    xLayout.forEach((k,v){
      BaseWidget xNW=NewWidget(v["type"]);
      xNW.SetName(k);
      xNW.ParseProperties(v["p"]);
      m_xRenderer.AddItem(xNW);
      m_xChildren.add(xNW);
      if((v as Map).containsKey("childwidgets")){
        ParseChildren(v["childwidgets"],xNW);
      }
    });
    document.dispatchEvent(new CustomEvent("UILoaded", canBubble: true, cancelable: true, detail: {"id":m_iID}));
  }
  void ParseChildren(Map p_xChildren,BaseWidget p_xParent){
    p_xChildren.forEach((k,v){
      BaseWidget xNW=NewWidget(v["type"]);
      xNW.SetName(k);
      if(xNW==null){return;}
      p_xParent.AddChild(xNW);
      xNW.ParseProperties(v["p"]);
      m_xRenderer.AddItem(xNW);
      m_xChildren.add(xNW);
      if((v as Map).containsKey("childwidgets")){
        ParseChildren(v["childwidgets"],xNW);
      }
    });
  }
//  void onClick(MouseEvent p_xEvent){
//    m_xChildren.forEach((e){
//      if(e is Clickable){
//       e.onClick(p_xEvent); 
//      }
//    });
//  }
  BaseWidget CreateNewWidget(String p_sType, Map p_xProperties){
    BaseWidget xNW=NewWidget(p_sType);
    xNW.ParseProperties(p_xProperties);
    m_xRenderer.AddItem(xNW);
    m_xChildren.add(xNW);
    
    return xNW;
  }
  BaseWidget NewWidget(String p_sType){
    if(p_sType=="BaseWidget"){
      return new BaseWidget();
    }
    if(p_sType=="BtnWidget"){
      return new BtnWidget();
    }
    if(p_sType=="TextWidget"){
      return new TextWidget();
    }
    if(p_sType=="EditableBaseWidget"){
      return new EditableBaseWidget();
    }
    if(p_sType=="EditWidget"){
      return new EditWidget();
    }
    return null;
  }
  BaseWidget GetWidgetByName(String p_sName){
    for(BaseWidget xW in m_xChildren){
      if(xW.m_sName==p_sName){
        return xW;
      }
    }
    return null;
  }
  List<BaseWidget> GetWidgetsOfType(String p_sType){
    List<BaseWidget> xRet=new List();
    for(BaseWidget xW in m_xChildren){
      ClassMirror xM=reflectClass(xW.runtimeType);
      if(MirrorSystem.getName(xM.simpleName)==p_sType){
        xRet.add(xW);
      }
    }
    return xRet;
  }
}