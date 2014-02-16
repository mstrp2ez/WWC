library Raven.Util;

import "dart:typed_data" show Uint8List;

class Util{
  static Uint8List MixedListToUint8(List p_xData){
    int iSize=CalculateListSize(p_xData);
    Uint8List xRet=new Uint8List(iSize);
    int i,iC=p_xData.length;
    for(i=0;i<iC;i++){
      if(p_xData[i] is int){
        xRet[i]=p_xData[i];
      }
      if(p_xData[i] is String){
        int j,jC=(p_xData[i] as String).length;
        for(j=0;j<jC;j++){
          xRet[i+j]=(p_xData[i] as String).codeUnitAt(j);
        }
      }
      if(p_xData[i] is List){
        Uint8List xTmp=MixedListToUint8(p_xData[i]);
        int j,jC=xTmp.length;
        for(j=0;j<jC;j++){
          xRet[i+j]=xTmp[j];
        }
      }
    }
    return xRet;
  }
  static int CalculateListSize(List p_xData){
    int i,iC=p_xData.length;
    int iSize=0;
    for(i=0;i<iC;i++){ //calculate size
     if(p_xData[i] is int){
       iSize+=1;
     }
     if(p_xData[i] is String){
       iSize+=(p_xData[i] as String).length;
     }
     if(p_xData[i] is List){
       iSize+=CalculateListSize(p_xData[i]);
     }
    }
    return iSize;
  }
}