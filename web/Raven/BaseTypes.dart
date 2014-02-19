library Raven.BaseTypes;

import "dart:html";
import "dart:typed_data" show Uint8List;
import "Utils/Vec2.dart";
import "Renderer.dart";

class WorldOffset{
 // static final WorldOffset _instance = new WorldOffset._internal();
  double m_fOffsetX;
  double m_fOffsetY;
  
  WorldOffset(){
    m_fOffsetX=0.0;
    m_fOffsetY=0.0;
  }
  
  //WorldOffset(this.m_fOffsetX,this.m_fOffsetY);
  WorldOffset._internal();
  
}
abstract class DataAsset{
  
  void LoadFromData(Map<String,dynamic> p_xProperties);
}
abstract class Renderable{
  Vec2 m_vPos;
  int m_iW;
  int m_iH;
  int m_iRenderLayer;
  WorldOffset m_xOffset;
  bool m_bIgnoreVisCheck;
  bool m_bVisible;
  
  void SetOffset(WorldOffset p_xOffset);
  Renderable.create(Vec2 p_vPos,int p_iW,int p_iH,int p_iRenderLayer);
  void SetIgnoreVisCheck(bool p_bCheck);
  
  void Render(CanvasRenderingContext2D p_xCtx);
}

abstract class Updatable{

  void Update(num p_Delta);
}

abstract class Networkable{
  int m_iEntityID;
  
  int ParseSnapshot(Uint8List p_xData);
}

abstract class Clickable{
  
  void onClick(MouseEvent p_xEvent);
}

abstract class Scalable{
  double m_fScale;
  
  
  void onScale(double p_fScale);
}


abstract class BaseEntity implements Renderable, Updatable, DataAsset{
  Vec2 m_vPos;
  int m_iW;
  int m_iH;
  int m_iRenderLayer;
  int m_iEntityID;
  BaseEntity m_xParent;
  List<BaseEntity> m_xChildren;
  WorldOffset m_xOffset;
  bool m_bIgnoreVisCheck;
  bool m_bVisible;
  
  BaseEntity(){
    m_vPos=new Vec2(0.0,0.0);
    m_iW=0;
    m_iH=0;
    m_iEntityID=-1;
    m_iRenderLayer=2;
    m_xChildren=new List<BaseEntity>();
    m_xOffset=new WorldOffset();
    m_bIgnoreVisCheck=false;
    m_bVisible=true;
  }
  BaseEntity.create(Vec2 p_vPos, int p_iW, int p_iH,int p_iRenderLayer,[int p_iEntityID=-1]){
    m_vPos=p_vPos;
    m_iW=p_iW;
    m_iH=p_iH;
    m_iEntityID=p_iEntityID;
    m_iRenderLayer=p_iRenderLayer;
    m_xChildren=new List<BaseEntity>();
    m_xOffset=new WorldOffset();
    m_bIgnoreVisCheck=false;
    m_bVisible=true;
  }
  BaseEntity.createFromJSONMap(Map p_xObj,[Renderer p_xRenderer=null]){
    double x=p_xObj.containsKey("x")?(p_xObj["x"] as double):0.0;
    double y=p_xObj.containsKey("y")?(p_xObj["y"] as double):0.0;
    m_vPos=new Vec2(x,y);
    m_iW=p_xObj.containsKey("w")?p_xObj["w"]:10;
    m_iH=p_xObj.containsKey("h")?p_xObj["h"]:10;
    m_iRenderLayer=p_xObj.containsKey("l")?p_xObj["l"]:0;
    m_iEntityID=p_xObj.containsKey("ei")?p_xObj["ei"]:-1;
    m_xChildren=new List<BaseEntity>();
    m_xOffset=new WorldOffset();
    m_bIgnoreVisCheck=false;
    m_bVisible=true;
  }
  void SetIgnoreVisCheck(bool p_bCheck){m_bIgnoreVisCheck=p_bCheck;}
  void SetOffset(WorldOffset p_xOffset){
    m_xOffset=p_xOffset;
  }
  void RemoveChild(BaseEntity p_xW){
    if(m_xChildren.contains(p_xW)){
      m_xChildren.remove(p_xW);
    }
  }
  void AddChild(BaseEntity p_xChild){
    p_xChild.m_xParent=this;
    m_xChildren.add(p_xChild);
  }
  void AttachTo(BaseEntity p_xParent){
    if(p_xParent==null){
      return;
    }
    p_xParent.AddChild(this);
  }
  void Update(num p_nDelta){
    
    m_xChildren.forEach((e){
      e.Update(p_nDelta);
    });
  }
  double CalculateWorldPosX(){
  }
  void Render(CanvasRenderingContext2D p_xCtx){
    m_xChildren.forEach((e){
      e.Render(p_xCtx);
    });
  }
  void Unload(){
    m_xChildren.forEach((e){
      e.Unload();
    });
  }
  void LoadFromData(Map<String,dynamic> p_xProperties){
    
  }
  void Serialize();
}