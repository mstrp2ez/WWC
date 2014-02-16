library Raven.Vec2;

import "dart:math";

class Vec2{
  num m_fX;
  num m_fY;
  
  Vec2(this.m_fX,this.m_fY);
  
  operator +(Vec2 p_vVec)=>new Vec2(m_fX+p_vVec.m_fX,m_fY+p_vVec.m_fY);
  operator -(Vec2 p_vVec)=>new Vec2(m_fX-p_vVec.m_fX,m_fY-p_vVec.m_fY);
  operator *(Vec2 p_vVec)=>new Vec2(m_fX*p_vVec.m_fX,m_fY*p_vVec.m_fY);
  operator /(Vec2 p_vVec)=>new Vec2(m_fX/p_vVec.m_fX,m_fY/p_vVec.m_fY);
  
  void AddV(Vec2 p_vV){
    m_fX+=p_vV.m_fX;
    m_fY+=p_vV.m_fY;
  }
  void AddS(num p_fS){
    m_fX+=p_fS;
    m_fY+=p_fS;
  }
  void SubV(Vec2 p_vV){
    m_fX-=p_vV.m_fX;
    m_fY-=p_vV.m_fY;
  }
  void SubS(num p_fS){
    m_fX-=p_fS;
    m_fY-=p_fS;
  }
  num Length(){
    return sqrt(m_fX*m_fX+m_fY*m_fY);
  }
  void Normalize(){
    num fL=Length();
    if(fL<=0.00001){
      return;
    }
    num fInv=1.0/fL;
    m_fX*=fInv;
    m_fY*=fInv;
  }
  void AbsLocal(){
    m_fX=m_fX.abs();
    m_fY=m_fY.abs();
  }
  num DistanceTo(Vec2 p_vPoint){
    num fDX=p_vPoint.m_fX-m_fX;
    num fDY=p_vPoint.m_fY-m_fY;
    return sqrt(fDX*fDX+fDY*fDY);
  }
  Vec2 Abs()=>new Vec2(m_fX.abs(),m_fY.abs());
  num Dot(Vec2 p_vVec){
    return (m_fX+p_vVec.m_fX)+(m_fY+p_vVec.m_fY);
  }
  Vec2 Copy(){
    return new Vec2(m_fX,m_fY);
  }
}