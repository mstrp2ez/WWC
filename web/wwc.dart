import 'dart:html';
import 'Raven/Game.dart';


void main() {
  CanvasElement xCanvas=querySelector('#canvas');
  Game xGame=new Game(xCanvas);
  xGame.Init();
  
  
  
}
