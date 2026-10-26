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
      println(cid);
      colormesh.saveCopy();
      switch(cid){
         //------------ algo calls ----------------//
         case 301:
           colormesh.contrast(); 
           break;
         case 302:
           colormesh.saturate();
           break;
         case 303:
           colormesh.brightenbrights();
           break;
         case 305:
           colormesh.hueShift(-1); 
           break;
         case 306:
           colormesh.hueShift(1);   
           break;
         case 308:
           colormesh.SubD();
           break;
         case 311:
           colormesh.colorPair(); 
           break;
         case 312:
           colormesh.colorNeighbour(); 
           break;
         case 321:
           cc = 2;
           colormesh.setColors();
           break;
         case 322:
           cc = 13;
           colormesh.setColors();
           break;
         case 323:
           cc = 34;
           colormesh.setColors();
           break;
         case 500:
           cid = 321;
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
         //----------- ccc slider values ------------//
         case 100:
         colormesh.setColors();
          break;
         case 1:
         colormesh.setColors();
          break;
         case 2:
         colormesh.setColors();
          break;
         case 3:
         colormesh.setColors();
          break;
         case 4:
         colormesh.setColors();
          break;
         case 5:
         colormesh.setColors();
          break;
         case 6:
         colormesh.setColors();
          break;
         case 7:
         colormesh.setColors();
          break;
         case 8:
         colormesh.setColors();
          break;
          
      }  
      
   }

}
