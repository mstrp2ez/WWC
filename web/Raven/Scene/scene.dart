library Raven.Scene;

import "dart:html";
import "dart:convert";
import "dart:async";

import "../Gfx/Gfx.dart";
import "../BaseTypes.dart";
import "../Renderer.dart";


class Scene{
  List<Renderable> m_xAssets;
  //Map<String, dynamic> m_xLookup;
  Renderer m_xRenderer;
  
  Scene(this.m_xRenderer){
    m_xAssets=new List<Renderable>();
    
  }
  
  Future LoadFromData(String p_sSrc){
    Unload();
    
    
    return HttpRequest.getString(p_sSrc).then(onData);
  }
  void onData(String p_sData){
    Map xSceneAssets=JSON.decode(p_sData);
    xSceneAssets.forEach((k,v){
      try{
        Renderable xNA=NewAsset(k);
        
      }on ArgumentError catch(e){
        window.console.log(e.message);
      }
    });
  }
  void ParseChildren(Map p_xChildren){
    
  }
  Renderable NewAsset(String p_sType){
    if(p_sType=="Gfx"){
      return new Gfx();
    }else if(p_sType=="Animation"){
      return new Animation();
    }else{
      throw new ArgumentError();
    }
  }
  void AddAsset(Renderable p_xAsset){
    if(m_xAssets.contains(p_xAsset)){return;}
    m_xAssets.add(p_xAsset);
  }
  void RemoveAsset(Renderable p_xAsset){
    m_xAssets.remove(p_xAsset);
  }
  void Unload(){
    m_xAssets.forEach((e){
      m_xRenderer.RemoveItem(e);
    });
  }
  
}