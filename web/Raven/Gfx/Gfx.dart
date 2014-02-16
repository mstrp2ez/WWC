library Raven.Gfx;

import "dart:html";
import "dart:async";
import "dart:convert" show JSON;
import "../BaseTypes.dart";
import "../Utils/Vec2.dart";


class Gfx implements Renderable{
  Vec2 m_vPos;
  int m_iW;
  int m_iH;
  int m_iRenderLayer;
  bool m_bLoaded;
  bool m_bScaled;
  bool m_bVisible;
  ImageElement m_xImage;
  WorldOffset m_xOffset;
  bool m_bIgnoreVisCheck;
  
  Gfx.create(String p_sSrc, Vec2 p_vPos, int p_iW, int p_iH, int p_iRenderLayer, [bool p_bScaled= false]){
    m_vPos=p_vPos;
    m_iW=p_iW;
    m_iH=p_iH;
    m_bVisible=true;
    m_iRenderLayer=p_iRenderLayer;
    m_bLoaded=false;
    m_xImage=new ImageElement();
    m_xImage.onLoad.listen(onImageLoaded);
    m_xImage.src=p_sSrc;
    m_bScaled=p_bScaled;
  }
  Gfx.createFromImageElement(ImageElement p_xImage, Vec2 p_vPos, int p_iW, int p_iH, int p_iRenderLayer, [bool p_bScaled= false]) {
    m_vPos=p_vPos;
    m_iW=p_iW;
    m_iH=p_iH;
    m_iRenderLayer=p_iRenderLayer;
    m_bLoaded=true;
    m_xImage=p_xImage;
    m_bScaled=p_bScaled;
  }
  void SetIgnoreVisCheck(bool p_sCheck){m_bIgnoreVisCheck=p_sCheck;}
  void SetOffset(WorldOffset p_xOffset){m_xOffset=p_xOffset;}
  void onImageLoaded(Event p_xEvent){
    m_bLoaded=true;
  }
  void Render(CanvasRenderingContext2D p_xCtx){
    if(m_bLoaded==false){return;}
    double x=m_vPos.m_fX;
    double y=m_vPos.m_fY;
    if(m_bScaled==true){
      p_xCtx.drawImageScaled(m_xImage, x, y, m_iW, m_iH);
    }else{
      p_xCtx.drawImage(m_xImage, x, y);
    }
  }
  void Serialize(){
    
  }
}


class AnimationFrame{
  int m_iX;
  int m_iY;
  int m_iW;
  int m_iH;
  AnimationFrame m_xNext;
  
  AnimationFrame(this.m_iX,this.m_iY,this.m_iH,this.m_iW,this.m_xNext);
}

class Animation extends BaseEntity implements Renderable, Updatable, Scalable{
  List<AnimationFrame> m_xAnimations;
  AnimationFrame m_xCurrentFrame;
  int m_iCurrentAnimation;
  int m_iLastUpdate;
  int m_iThreshold;
  double m_fScale;
  bool m_bLoaded;
  String m_sSource;
  ImageElement m_xImage;
  
  Animation():super(){
    m_bLoaded=false;
    m_iLastUpdate=0;
    m_iCurrentAnimation=0;
    m_xCurrentFrame=null;
    m_sSource=""; 
    m_fScale=1.0;
  }
  
  Animation.create(String p_sSrc,Vec2 p_vPos,int p_iW,int p_iH,int p_iRenderLayer, [int p_iEntityID=-1]) : super.create(p_vPos,p_iW,p_iH,p_iRenderLayer, p_iEntityID){
    m_bLoaded=false;
    m_iLastUpdate=0;
    m_fScale=1.0;
    m_iCurrentAnimation=0;
    m_xCurrentFrame=null;
    m_sSource=p_sSrc; 
    
    Load();
  }
  Animation.createFromJSONMap(Map p_xMap) : super.createFromJSONMap(p_xMap){}
  void Load([String p_sSrc=""]){
    String sSrc=m_sSource;
    if(p_sSrc!=""){
      m_sSource=sSrc=p_sSrc;
    }
    m_fScale=1.0;
    HttpRequest.getString(sSrc).then(onAnimationData);
  }
  void onAnimationData(String p_Data){
    var xData=JSON.decode(p_Data);
    m_xImage=new ImageElement();
    m_iThreshold=xData["rate"];
    m_xImage.src=xData["src"];
    m_xAnimations=new List<AnimationFrame>();
    List xAnims=xData["animation"];
    xAnims.forEach(ParseFrames);
    if(m_xAnimations.length>0){
      m_xCurrentFrame=m_xAnimations[0];
    }
    document.dispatchEvent(new CustomEvent("AnimationLoaded", canBubble: true, cancelable: true, detail: {"src":m_sSource}));
    m_bLoaded=true;
  }
  void onScale(double p_fDelta){
    m_fScale+=p_fDelta;
  }
  void ParseFrames(p_Val){
    AnimationFrame xHead=null;
    AnimationFrame xLast=null;
    (p_Val as List).forEach((v){
      AnimationFrame xFrame=new AnimationFrame(v["x"], v["y"], v["h"], v["w"], xLast);
      if(xLast!=null){xLast.m_xNext=xFrame;}
      xLast=xFrame;
      if(xHead==null){xHead=xFrame;}
    });
    xLast.m_xNext=xHead;
    m_xAnimations.add(xHead);
  }
  void Render(CanvasRenderingContext2D p_xContext){
    if(m_bLoaded==false){return;}
    double x=m_vPos.m_fX+m_xOffset.m_fOffsetX;
    double y=m_vPos.m_fY+m_xOffset.m_fOffsetY;
    int iSX=m_xCurrentFrame.m_iX;
    int iSY=m_xCurrentFrame.m_iY;
    int iSW=m_xCurrentFrame.m_iW;
    int iSH=m_xCurrentFrame.m_iH;
    double fEW=iSW*m_fScale;
    double fEH=iSH*m_fScale;
    p_xContext.drawImageScaledFromSource(m_xImage,
        iSX, 
        iSY, 
        iSW,
        iSH,
        x,
        y,
        fEW,
        fEH);
  }
  void SetAnimation(int p_iAnim){
    if(m_bLoaded==false){new Timer(new Duration(milliseconds:5),(){
        this.SetAnimation(p_iAnim);
      });
      return;
    }
    if(m_iCurrentAnimation==p_iAnim){
      return;
    }
    m_iCurrentAnimation=p_iAnim;
    p_iAnim=(p_iAnim<0)?m_xAnimations.length-1: (p_iAnim>=m_xAnimations.length)?0:p_iAnim;
    m_xCurrentFrame=m_xAnimations[p_iAnim];
  }
  void Update(num p_nDelta){
    if(m_bLoaded==false){return;}
    if(p_nDelta.toInt()>=m_iThreshold+m_iLastUpdate){
      m_iLastUpdate=p_nDelta.toInt();
      if(m_xCurrentFrame!=null){
        m_xCurrentFrame=m_xCurrentFrame.m_xNext;
      }
    }
  }
  void Serialize(){}
  
}