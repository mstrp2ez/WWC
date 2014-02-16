library Raven.Renderer;

import "dart:html";
import "BaseTypes.dart";

class Renderer{
  CanvasRenderingContext2D m_xContext;
  List<Renderable> m_xItems;
  WorldOffset m_xWorldOffset;
  String m_sBackgroundColor;
  
  Renderer(CanvasRenderingContext2D p_xContext, WorldOffset p_xWorldOffset){
    m_xContext=p_xContext;
    m_xWorldOffset=p_xWorldOffset;
    m_xItems=new List<Renderable>();
  }
  
  void AddItem(Renderable p_xItem){
    m_xItems.add(p_xItem);
    m_xItems.sort((a,b)=>(a.m_iRenderLayer.compareTo(b.m_iRenderLayer)));
  }
  void Sort(){
    m_xItems.sort((a,b)=>(a.m_iRenderLayer.compareTo(b.m_iRenderLayer)));
  }
  bool RemoveItem(Renderable p_xItem){
    return m_xItems.remove(p_xItem);
  }
  void Update(num p_nDelta){
    m_xItems.forEach((e){
      if(e is Updatable){
        e.Update(p_nDelta);
      }
    });
  }
  void Render(){
    m_xItems.forEach((e){
      if(e.m_bIgnoreVisCheck==false){
        double fOffsetX=(e.m_xOffset!=null)?e.m_xOffset.m_fOffsetX:0.0;
        double fOffsetY=(e.m_xOffset!=null)?e.m_xOffset.m_fOffsetY:0.0;
        double x=e.m_vPos.m_fX+fOffsetX;
        double y=e.m_vPos.m_fY+fOffsetY;
        int w=e.m_iW;
        int h=e.m_iH;
      
        if(x+w<-w||x>m_xContext.canvas.width){return;}
        if(y+h<-h||y>m_xContext.canvas.height){return;}
      }
      
      if(e.m_bVisible){
        e.Render(m_xContext);
      }
    });
  }
  void ClearScreen(){
    //m_xContext.clearRect(0, 0, m_xContext.canvas.width, m_xContext.canvas.height);
    m_xContext.fillStyle="#253568";
    m_xContext.fillRect(0,0,m_xContext.canvas.width, m_xContext.canvas.height);
  }
}