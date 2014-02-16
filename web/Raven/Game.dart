library Raven.Game;

import "dart:html";
import "dart:async";
import "BaseTypes.dart";
import "Renderer.dart";
import "Tilemap/Tilemap.dart";

class Game{
  CanvasElement m_xCanvas;
  Renderer m_xRenderer;
  Tilemap m_xTilemap;
  
  Game(this.m_xCanvas);
  
  void Init(){
  
    CanvasRenderingContext xContext=m_xCanvas.getContext('2d');
    WorldOffset xOffset=new WorldOffset();
    xOffset.m_fOffsetX=0.0;
    xOffset.m_fOffsetY=0.0;
    m_xRenderer=new Renderer(xContext, xOffset);
    
    Tilemap xTilemap = new Tilemap(m_xRenderer, 'assets/tilemapatlas.png',40,40);
    xTilemap.GenerateFromImageAtlas('assets/map0.png');
    
    Run(0);
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