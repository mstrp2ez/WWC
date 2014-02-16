library Raven.Tilemap;

import "dart:html";
import "dart:async";
import "../Renderer.dart";
import "../Gfx/Gfx.dart";
import "../BaseTypes.dart";
import "../Utils/Vec2.dart";

class PathFindingMeta{
  int m_iF;
  int m_iH;
  int m_iG;
  Tile m_xParent;
  
  PathFindingMeta(this.m_iF,this.m_iG,this.m_iH,this.m_xParent);
  
  void Clear(){
    m_iF=0;
    m_iH=0;
    m_iG=0;
    m_xParent=null;
  }
}

class Tile extends BaseEntity{
  int m_iTileType;
  int m_iCol;
  int m_iRow;
  bool m_bVisible;
  bool m_bSelected;
  PathFindingMeta m_xMeta;
  
  
  Tile(){}
  Tile.create(Vec2 p_vPos,int p_iTileType, int p_iCol, int p_iRow, int p_iW, int p_iH, int p_iRenderLayer):super.create(p_vPos,p_iW,p_iH,p_iRenderLayer){
    m_iTileType=p_iTileType;
    m_iCol=p_iCol;
    m_iRow=p_iRow;
    m_bVisible=true;
    m_bSelected=false;
    m_xMeta=new PathFindingMeta(0,0,0,null);
  }
 
  void Serialize(){}
}

class RawTile extends Tile implements Clickable{
  String m_sColor;
  
  RawTile.create(String p_sColor,int p_iTileType, int p_iCol, int p_iRow, int p_iW, int p_iH, int p_iRenderLayer) : super.create(new Vec2((p_iCol*p_iW).toDouble(),(p_iRow*p_iH).toDouble()),p_iTileType,p_iCol,p_iRow,p_iW,p_iH,p_iRenderLayer){
    m_sColor=p_sColor;
  }
  
  void Render(CanvasRenderingContext2D p_xCtx){
    //this is slow, but whatever
    if(m_bVisible==false){return;}
    double x=m_vPos.m_fX+m_xOffset.m_fOffsetX;
    double y=m_vPos.m_fY+m_xOffset.m_fOffsetY;
    p_xCtx.fillStyle=m_sColor;
    p_xCtx.fillRect(x, y, m_iW, m_iH);
    if(m_bSelected){
      x+=1;
      y+=1;
      p_xCtx.strokeStyle="#000";
      p_xCtx.lineWidth=2;
      p_xCtx.beginPath();
      p_xCtx.moveTo(x, y);
      p_xCtx.lineTo(x+m_iW-2, y);
      p_xCtx.lineTo(x+m_iW-2, y+m_iH-2);
      p_xCtx.lineTo(x, y+m_iH-2);
      p_xCtx.closePath();
      p_xCtx.stroke();
    }
  }
  void onClick(MouseEvent p_xEvent){
    num x=p_xEvent.offset.x;
    num y=p_xEvent.offset.y;
    double fX=m_vPos.m_fX+m_xOffset.m_fOffsetX;
    double fY=m_vPos.m_fY+m_xOffset.m_fOffsetY;
    bool bSel=true;
    if(x<fX||x>fX+m_iW){bSel=false;}
    if(y<fY||y>fY+m_iH){bSel=false;}
    m_bSelected=bSel;
  }
}

class ImgTile extends Tile {
  Gfx m_xGfx;
  
  ImgTile.create(ImageElement p_xSpritesheet,int p_iTileType, int p_iCol, int p_iRow, int p_iW, int p_iH, int p_iRenderLayer) : super.create(new Vec2((p_iCol*p_iW).toDouble(),(p_iRow*p_iH).toDouble()),p_iTileType,p_iCol,p_iRow,p_iW,p_iH,p_iRenderLayer){
    m_xGfx=new Gfx.createFromImageElement(p_xSpritesheet, new Vec2((p_iCol*p_iW).toDouble(),(p_iRow*p_iH).toDouble()), p_iW, p_iH, p_iRenderLayer, false);
  }
   
  void Render(CanvasRenderingContext2D p_xCtx){
    if(m_bVisible==false){return;}
    double x=m_vPos.m_fX+m_xOffset.m_fOffsetX;
    double y=m_vPos.m_fY+m_xOffset.m_fOffsetY;
    
    m_xGfx.m_vPos.m_fX=x;
    m_xGfx.m_vPos.m_fY=y;
    //m_xGfx.Render(p_xCtx);
    p_xCtx.drawImageScaledFromSource(m_xGfx.m_xImage, m_iTileType*m_iW,0,m_iW,m_iH,x,y,m_iW,m_iH);
  }
}

class Tilemap{
  Renderer m_xRenderer;
  List<Tile> m_xTiles;
  ImageElement m_xSpritesheet;
  bool m_bAtlasLoaded;
  bool m_bNoAtlas;
  int m_iTileW;
  int m_iTileH;
  WorldOffset m_xOffset;
  
  Tilemap(Renderer p_xRenderer, String p_sAtlasSrc, [int p_iW=80, int p_iH=80]){
    m_xRenderer=p_xRenderer;
    m_bAtlasLoaded=false;
    m_xTiles=new List<Tile>();
    m_bNoAtlas=false;
    m_xSpritesheet=new ImageElement();
    m_xSpritesheet.onLoad.listen(onAtlasLoad);
    if(p_sAtlasSrc!=""){
      m_xSpritesheet.src=p_sAtlasSrc;
    }else{
      m_bNoAtlas=true;
    }
    m_iTileW=p_iW;
    m_iTileH=p_iH;
    
    document.on["SolvePath"].listen(onSolvePath);
  }
  void SetOffset(WorldOffset p_xOffset){
    m_xOffset=p_xOffset;
  }
  void onAtlasLoad(Event p_xEvent){
    m_bAtlasLoaded=true;
    document.dispatchEvent(new CustomEvent("tilemapatlasloaded", canBubble: true, cancelable: true, detail: {}));
  }
  Tile NewRawTile(String p_sColor, int p_iType, int p_iCol,int p_iRow, int p_iLayer){
    Tile xNT=new RawTile.create(p_sColor,p_iType, p_iCol, p_iRow, m_iTileW, m_iTileH, p_iLayer);
    m_xTiles.add(xNT);
    m_xRenderer.AddItem(xNT);
    return xNT;
  }
  Tile NewImgTile(int p_iType, int p_iCol,int p_iRow, int p_iLayer){
    if(m_bAtlasLoaded){
      Tile xNT=new ImgTile.create(m_xSpritesheet,p_iType, p_iCol, p_iRow, m_iTileW, m_iTileH, p_iLayer);
      m_xTiles.add(xNT);
      m_xRenderer.AddItem(xNT);
      return xNT;
    }
    return null;
  }
  void SetVis(int p_iStart,int p_iEnd, bool p_bVis){
    m_xTiles.getRange(p_iStart, p_iEnd).forEach((e){
      e.m_bVisible=p_bVis;
    });
  }
  Tile RemoveTile(Tile p_xTile){
    m_xTiles.remove(p_xTile);
    m_xRenderer.RemoveItem(p_xTile);
    return p_xTile;
  }
  Tile RemoveTileByColRow(int p_iCol, int p_iRow){
    m_xTiles.forEach((e){
      if(e.m_iCol==p_iCol){
        if(e.m_iRow==p_iRow){
          m_xTiles.remove(e);
          m_xRenderer.RemoveItem(e);
        }
      }
    });
  }
  Tile GetTileByWorldPos(num p_nX,num p_nY){
    Tile xFound=null;
    for(Tile e in m_xTiles){
      double fX=e.m_vPos.m_fX;
      double fY=e.m_vPos.m_fY;
      if(p_nX>=fX&&p_nX<=fX+e.m_iW){
        if(p_nY>=fY&&p_nY<=fY+e.m_iW){
          return e;
        }
      }
    }
    return null;
  }
  Tile GetTileByColRow(int p_iCol,int p_iRow){
    for(Tile e in m_xTiles){
      if(e.m_iCol==p_iCol){
        if(e.m_iRow==p_iRow){
          return e;
        }
      }
    }
    return null;
  }
  List<Tile> GetAdjecent(Tile p_xT){
    int iIdx=m_xTiles.indexOf(p_xT);
    if(iIdx==-1){return null;}
    List<Tile> xRet=new List<Tile>();
    
    int iRow=p_xT.m_iRow;
    
    //find first in row
    Tile xTmp=p_xT;
    int iW=0;
    int iTmpIdx=iIdx;
    while(xTmp.m_iRow==iRow){
      iTmpIdx--;
      if(iTmpIdx<0){break;}
      xTmp=m_xTiles[iTmpIdx];
    }
    xTmp=m_xTiles[iTmpIdx+1];
    while(xTmp.m_iRow==iRow){
      iTmpIdx++;
      if(iTmpIdx>=m_xTiles.length){break;}
      iW++;
      xTmp=m_xTiles[iTmpIdx];
    }
    iW-=1;
    if(iIdx+1<m_xTiles.length&&m_xTiles[iIdx+1].m_iRow==iRow){
      xRet.add(m_xTiles[iIdx+1]);  
    }
    if(iIdx-1>=0&&m_xTiles[iIdx-1].m_iRow==iRow){
      xRet.add(m_xTiles[iIdx-1]);  
    }
    
    if(iIdx+iW<m_xTiles.length&&m_xTiles[iIdx+iW].m_iRow==iRow+1){
      xRet.add(m_xTiles[iIdx+iW]);  
    }
    if(iIdx-iW>=0&&m_xTiles[iIdx-iW].m_iRow==iRow-1){
      xRet.add(m_xTiles[iIdx-iW]);  
    }
    
    if(iIdx+iW-1<m_xTiles.length&&m_xTiles[iIdx+iW-1].m_iRow==iRow+1){
      xRet.add(m_xTiles[iIdx+iW-1]);  
    }
    if(iIdx-iW-1>=0&&m_xTiles[iIdx-iW-1].m_iRow==iRow-1){
      xRet.add(m_xTiles[iIdx-iW-1]);  
    }
    
    if(iIdx+iW+1<m_xTiles.length&&m_xTiles[iIdx+iW+1].m_iRow==iRow+1){
      xRet.add(m_xTiles[iIdx+iW+1]);  
    }
    if(iIdx-iW+1>=0&&m_xTiles[iIdx-iW+1].m_iRow==iRow-1){
      xRet.add(m_xTiles[iIdx-iW+1]);  
    }
    
    return xRet;
  }
  void onSolvePath(CustomEvent p_xEvent){
    num nSX=p_xEvent.detail["sx"];
    num nSY=p_xEvent.detail["sy"];
    num nEX=p_xEvent.detail["ex"];
    num nEY=p_xEvent.detail["ey"];
    Tile xStart=GetTileByWorldPos(nSX, nSY);
    Tile xEnd=GetTileByWorldPos(nEX, nEY);
//    RemoveTile(xEnd);
    List<Tile> xPath=SolvePath(xStart, xEnd);
    if(xPath==null){return;}
//    for(Tile e in xPath){
//      RemoveTile(e);
//    }
    document.dispatchEvent(new CustomEvent("MovementPath", canBubble:true , cancelable:true , detail:{"p":xPath} ));
  }
  List<Tile> SolvePath(Tile p_xStartTile, Tile p_xEndTile){
    List<Tile> xRet=new List<Tile>();
    if(m_xTiles.indexOf(p_xStartTile)==-1){return null;}
    if(m_xTiles.indexOf(p_xEndTile)==-1){return null;}
    
    List<Tile> xOpen=new List<Tile>();
    List<Tile> xClosed=new List<Tile>();
    
    p_xStartTile.m_xMeta.Clear();
    p_xStartTile.m_xMeta.m_iH=(p_xStartTile.m_iCol-p_xEndTile.m_iCol+p_xStartTile.m_iRow-p_xEndTile.m_iRow).abs();
    xOpen.add(p_xStartTile);
    
    int iSanity=10000;
    while(xOpen.length>0&&(iSanity>0)){
      iSanity--;
      Tile xCurrent=xOpen.removeAt(0);
      xClosed.add(xCurrent);
      List<Tile> xAdj=GetAdjecent(xCurrent);
      int iDir=0;
      for(Tile e in xAdj){
        if(xClosed.indexOf(e)!=-1){continue;}
        if(e.m_iTileType==2||e.m_iTileType==12){continue;}
        if(xOpen.indexOf(e)==-1){
          xOpen.add(e);
          int iG=(iDir<4)?10:14;
          iDir++;
          int iH=0;
          
          e.m_xMeta.m_xParent=xCurrent;
          Tile xTmp=e.m_xMeta.m_xParent;
          while(xTmp!=null){
            iG+=xTmp.m_xMeta.m_iG;
            xTmp=xTmp.m_xMeta.m_xParent;
          }
          iH=(e.m_iCol-p_xEndTile.m_iCol).abs()+(e.m_iRow-p_xEndTile.m_iRow).abs();
          e.m_xMeta.m_iF=iG+iH;
          e.m_xMeta.m_iG=iG;
          e.m_xMeta.m_iH=iH;
        }
//        }else{
//          int iG=(iDir<4)?10:14;
//          iDir++;
//          int iH=0;
//          int iCurrG=e.m_xMeta.m_iG;
//          int iCompG=xCurrent.m_xMeta.m_iG+iG;
//          if(iCompG<iCurrG){
//            e.m_xMeta.m_xParent=xCurrent;
//            Tile xTmp=xCurrent;
//            while(xTmp!=null){
//              iG+=xTmp.m_xMeta.m_iG;
//              xTmp=xTmp.m_xMeta.m_xParent;
//            }
//            iH=(p_xEndTile.m_iCol-e.m_iCol)+(p_xEndTile.m_iRow-e.m_iRow);
//            e.m_xMeta.m_iF=iG+iH;
//            e.m_xMeta.m_iG=iG;
//            e.m_xMeta.m_iH=iH;
//          }
//        }
      }
      xOpen.sort((a,b)=>a.m_xMeta.m_iF.compareTo(b.m_xMeta.m_iF));
     
      if(xClosed.indexOf(p_xEndTile)!=-1){
        break;
      }
    }
    if(iSanity>0){
      Tile xC=p_xEndTile;
      while(xC!=null){
        xRet.add(xC);
        xC=xC.m_xMeta.m_xParent;
      }
    }
    return xRet;
  }
  Tile GetSelected(){
    for(Tile e in m_xTiles){
      if(e.m_bSelected){
        return e;
      }
    }
    return null;
   }
    
  
  void GenerateFromImageAtlas(String p_sImageSource){
    ImageElement xImageMap=new ImageElement();
    xImageMap.onLoad.listen((e){
      CanvasElement xTmpCanvas=new CanvasElement(width: xImageMap.width, height: xImageMap.height);
      CanvasRenderingContext2D xCtx=xTmpCanvas.getContext('2d');
      xCtx.drawImage(xImageMap, 0, 0);
      ImageData xData=xCtx.getImageData(0, 0, xImageMap.width, xImageMap.height);
      int i, iC=xData.width*xData.height*4;
      int iCol=0,iRow=0;
      int iStep=4;
      int iW=xData.width*iStep;

      for(i=0;i<iC;i+=iStep){
        int iR=(i~/iW);
        int iCount=0;
        if(xData.data[i]>10){
          if(i-iStep>=(iR*iW)&&xData.data[i-iStep]>10){
            iCount+=8;
          }
          if(i+iStep<(iR*iW+iW)&&xData.data[i+iStep]>10){
            iCount+=2;
          }
          if(i-iW>=0&&xData.data[i-iW]>10){
            iCount+=1;
          }
          if(i+iW<iC&&xData.data[i+iW]>10){
            iCount+=4;
          }
          if(iCount<=0){
            iCount=15;
          }
        }else{
//          if(i-iW>=0&&xData.data[i-iW]>10){
//            iCount=1;
//          }
        }
        NewImgTile(iCount, iCol, iRow, (iCount==0)?0:1);
        
        iCol++;
        if(iCol>=xData.width){
          iCol=0;
          iRow++;
        }
      }
    });
    xImageMap.src=p_sImageSource;
  }
  void GenerateFromImageRaw(String p_sSrc){
    ImageElement xImageMap=new ImageElement();
    xImageMap.onLoad.listen((e){
      CanvasElement xTmpCanvas=new CanvasElement(width: xImageMap.width, height: xImageMap.height);
      CanvasRenderingContext2D xCtx=xTmpCanvas.getContext('2d');
      xCtx.drawImage(xImageMap, 0, 0);
      ImageData xData=xCtx.getImageData(0, 0, xImageMap.width, xImageMap.height);
      int i, iC=xData.width*xData.height*4;
      int iCol=0,iRow=0;
      int iStep=4;
      int iW=xData.width*iStep;
      List xPixelData=xData.data;
      for(i=0;i<iC;i+=iStep){
        
        int iR=xPixelData[i];
        int iG=xPixelData[i+1];
        int iB=xPixelData[i+2];
        String sR=iR.toRadixString(16);
        String sG=iG.toRadixString(16);
        String sB=iB.toRadixString(16);
        
        String sColor="#" "$sR" "$sG" "$sB";
        
        List<String> xFilter=['#FFD84E','#4FFF5D','#5B81FF','#5B81FF','#9EBAA0'];
        int iType=xFilter.indexOf(sColor.toUpperCase());
        
        Tile xNT=NewRawTile(sColor, iType, iCol, iRow, 0);
        if(m_xOffset!=null){
          xNT.SetOffset(m_xOffset);
        }
        
        iCol++;
        if(iCol>=xData.width){
          iCol=0;
          iRow++;
        }
      }
      document.dispatchEvent(new CustomEvent("TilemapLoaded", canBubble: true, cancelable: true, detail: {}));
    });
    xImageMap.src=p_sSrc;
  }
  
}