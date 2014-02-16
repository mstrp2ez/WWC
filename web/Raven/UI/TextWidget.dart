library Raven.TextWidget;

import "dart:html";
import "BaseWidget.dart";
import "../Utils/Vec2.dart";
import "../BaseTypes.dart";

class TextWidget extends BaseWidget implements Clickable{
  String m_sText;
  String m_sTextColor;
  String m_sFont;
  String m_sTextShadow;
  TextWidget():super(){
    m_sText="";
    m_sTextColor="#000000";
  }
  void ParseProperties(Map p_xProperties){
    super.ParseProperties(p_xProperties);
    Map xP=p_xProperties;
    
    m_sText=(xP.containsKey("text")?xP["text"]:"");
    m_sTextColor=(xP.containsKey("textcolor")?xP["textcolor"]:"#000000");
    m_sFont=(xP.containsKey("font")?xP["font"]:"12px Arial");
    m_sTextShadow=(xP.containsKey("textshadow")?xP["textshadow"]:"");
  }
  void Render(CanvasRenderingContext2D p_xCtx){
    if(IsVisible()==false){return;}
    Vec2 vP=CalculateAbsolutePosition();
    p_xCtx.textBaseline="top";
    p_xCtx.font=m_sFont;
    int iTextSize=14;
    p_xCtx.fillStyle=m_sTextColor;
    if(m_sTextShadow.length>0){
      p_xCtx.shadowColor=m_sTextShadow;
      p_xCtx.shadowOffsetX=1;
      p_xCtx.shadowOffsetY=1;
    }
    List<String> xWords=m_sText.split(' ');
    String sLine='';
    int iIdx=0;
    double x=vP.m_fX;
    double y=vP.m_fY;
    xWords.forEach((e){
      String sTestLine=sLine+e+' ';
      TextMetrics xMetric=p_xCtx.measureText(sTestLine);
      if(xMetric.width>m_iW-10 && iIdx > 0){
        p_xCtx.fillText(sLine, x, y, m_iW);
        sLine=e+' ';
        y+=iTextSize;
      }else{
        sLine=sTestLine;
      }
      iIdx++;
    });
    p_xCtx.fillText(sLine, x, y, m_iW);
    p_xCtx.shadowColor="";
    p_xCtx.shadowOffsetX=0;
    p_xCtx.shadowOffsetY=0;
    super.Render(p_xCtx);
  }
}