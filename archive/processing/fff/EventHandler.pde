void controlEvent(ControlEvent theEvent) {
  
   if (theEvent.isGroup()) {
        String modelName = stlnames[int(theEvent.group().value())];
        String type = modelName;
        type = type.substring(modelName.length() - 3, modelName.length());
        if(type.equals("stl")){
          colormesh = new Coformer(fromStl(modelName)); 
          nav.autoscale(colormesh.objectHeight,colormesh.objectWidth,colormesh.objectDepth);
        }
        if(type.equals("obj")){
          println("this is an OBJ");
          obj = new HEC_FromObjFileColor(sketchPath("importStls/"+modelName));
          colormesh.clear();
          colormesh = new Coformer(obj);
          colormesh.setVertexColors(obj.getVertexColors());
          println("mesh made");
          nav.autoscale(colormesh.objectHeight,colormesh.objectWidth,colormesh.objectDepth);
          //colormesh.setColors2();
        }
   }
  
   if (theEvent.isController()) {
     
      Controller c=theEvent.controller();
      int cid=c.id();
      colormesh.saveCopy();
      switch(cid){
         //------------ algo calls ----------------//
         case 301:
         colormesh.getObjectDims();
         colormesh.selectAll();
         colormesh.moveToZero();
         colormesh.getObjectDims();
         colormesh.setColors();
         
         break;
         case 302:
         colormesh.getObjectDims();
         colormesh.selectRegion1();
         break;
         case 303:
         colormesh.cropTop();
         colormesh.getObjectDims();
         colormesh.selectAll();
         break;
         case 304:
         colormesh.cropBase();
         colormesh.getObjectDims();
         colormesh.selectAll();
         break;
         case 305:
         colormesh.twist();
         break;
         case 306:
         colormesh.sineTwist();   
         break;
         case 307:
         colormesh.smoothe();
         colormesh.getObjectDims();
         break;
         case 308:
         if (scalingOn == true){
            scalingOn = false;
          }
          else if (scalingOn == false){
            scalingOn = true;
          }
          break;
         case 311:
         colormesh.subdiv();
         colormesh.getObjectDims();
         colormesh.selectAll();
         break;
         case 312:
         colormesh.catmullClarkSubD();
         colormesh.getObjectDims();
         colormesh.selectAll();
         break;
         case 313:
         colormesh.fractalSubD();
         colormesh.getObjectDims();
         colormesh.selectAll();
         break;
         case 321:
         colormesh.cup();
         colormesh.getObjectDims();
         colormesh.selectAll();
         break;
         case 322:
         colormesh.bellbase();
         colormesh.getObjectDims();
         colormesh.selectAll();
         break;
         case 323:
         colormesh.trumpet();
         colormesh.getObjectDims();
         colormesh.selectAll();
         break;
         case 500:
         display_limbomesh = false;
         limbomesh.clear();
         selectInput("Select a file to corrupt or repair:", "openFile");
         colormesh.getObjectDims();
         colormesh.selectAll();
         break;
         case 501:
         appendMesh();
         break;
         case 502:
         addMesh();         
         break;
         //----------- coformer values ------------//
         case 21: //move P1 slider
          X1=(int)c.value(); 
          colormesh.update(co, X1, Y1, Z1, X2, Y2, Z2, S1, S2);
          break;
         case 22: //move P2 slider
          Y1=(int)c.value();
          colormesh.update(co, X1, Y1, Z1, X2, Y2, Z2, S1, S2);
          break;
         case 23: //move P3 slider
          Z1=(int)c.value();
          colormesh.update(co, X1, Y1, Z1, X2, Y2, Z2, S1, S2);
          break;
         case 24: //move P4 slider
          X2=(int)c.value();
          colormesh.update(co, X1, Y1, Z1, X2, Y2, Z2, S1, S2);
          if (scalingOn == true){
            colormesh.xScaleMesh();
           }
          break;
         case 25: //move P5 slider
          Y2=(int)c.value();
          colormesh.update(co, X1, Y1, Z1, X2, Y2, Z2, S1, S2);
          if (scalingOn == true){
            colormesh.yScaleMesh();
           }
          break;
         case 26: //move P6 slider
          Z2=(int)c.value();
          colormesh.update(co, X1, Y1, Z1, X2, Y2, Z2, S1, S2);
          if (scalingOn == true){
            colormesh.zScaleMesh();
           }
          break;
         case 27: //move P7 slider
          S1=(int)c.value();
          colormesh.update(co, X1, Y1, Z1, X2, Y2, Z2, S1, S2);
          if (scalingOn == true){
            colormesh.allScaleMesh();
           }
          break;
         case 28: //move P8 slider
          S2=(int)c.value();
          colormesh.update(co, X1, Y1, Z1, X2, Y2, Z2, S1, S2);
          break;
         case 200: //move cc slider
          co=(int)c.value();
          colormesh.update(co, X1, Y1, Z1, X2, Y2, Z2, S1, S2);
          break;
      }  
      colormesh.setColors();
   }

}
