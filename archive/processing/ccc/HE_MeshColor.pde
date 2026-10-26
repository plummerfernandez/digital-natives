class HE_MeshColor extends HE_Mesh {
  Algocolor algocolor;
  //HashMap <Integer, Integer> colorSave = new HashMap <Integer, Integer> (); //to hold the colors, face key
  ArrayList vertexColors; // = new ArrayList<Integer>(); 
  float fAmax, fAmin, objectDepth, objectHeight, objectWidth;
  float BL, BH, BNL, BNH;
  
  // extends the original constructor
  HE_MeshColor(HEC_Creator creator) {
    super(creator);  
    this.getFaceAreas();
    this.getObjectDims();
    algocolor = new Algocolor();
    algocolor.setObjectValues(objectDepth, objectHeight, objectWidth, fAmin,fAmax);
    vertexColors  = new ArrayList<Integer>(); 
    this.setColors();
    
  }

  // this function handles the display of the faces
  void display() {
      // go over all the faces in the mesh
      for (HE_Face f : getFacesAsList()) {
        // fill using their unique color (stored in the hashmap with their unique face key)
         //fill(colorSave.get(f.key()));
         fill( f.getLabel() );
        // draw the face
        render.drawFace(f);
      }
  }
  // this function saves a color stl file
  void saveStl(){
     STLWriter stl; // Toxi Color Stl writer
     STLColorModel colModel;
      // create stl color model with mesh base color
     // the true flag means facets can have their own RGB value
     colModel=new MaterialiseSTLColorModel(0x112233,true);
     // create STLWriter instance
     stl = new STLWriter(colModel, 10000);
     
     
     save("savedStls/" + DateUtils.timeStamp() + "_preview.png"); //save screenshot
     // start toxi save
     stl.beginSave(sketchPath("savedStls/" + DateUtils.timeStamp() + "_colorSTL.stl"),this.numberOfFaces());
     // go over all the faces in the mesh
      for (HE_Face f : getFacesAsList()) {
        // fill using their unique color (stored in the hashmap with their unique face key)
        //color c = colorSave.get(f.key());
        color c = color(f.getLabel());
        // get face vertices
        ArrayList<HE_Vertex> vlist = new ArrayList(f.getFaceVertices());
  
        HE_Vertex v1 = new HE_Vertex();
        HE_Vertex v2 = new HE_Vertex();
        HE_Vertex v3 = new HE_Vertex();
        
        int i = 0;     
        for (HE_Vertex v : vlist){ //hacky way of getting list items
          if(i == 0){
            v1 = v;
          }
          else if(i == 1){
            v2 = v;
          }
          else if(i == 2){
            v3 = v;
          }
          i++;
        }
 
        // face normal
        WB_Vector3d nrml = f.getFaceNormal();
        //converting hemesh to toxi
        Vec3D Vec1 = new Vec3D(v1.xf(), v1.yf(), v1.zf()); 
        Vec3D Vec2 = new Vec3D(v2.xf(), v2.yf(), v2.zf());
        Vec3D Vec3 = new Vec3D(v3.xf(), v3.yf(), v3.zf());
        Vec3D Nrm = new Vec3D(nrml.xf(), nrml.yf(), nrml.zf());
        //toxi stl.face needs face vertices,normal,color
        stl.face(Vec2, Vec1, Vec3, Nrm, c); 
        // draw the face
        render.drawFace(f);
      }
      stl.endSave(); 
      println("STL saved"); 
  }
  
  // save  a VRML file
  void saveVRML(){
    this.triangulate();
    println("exporting VRML");
    StringBuffer buffer = new StringBuffer();
    buffer.append("#VRML V2.0 utf8\n");
    buffer.append("#Made by Matthew Plummer-Fernandez");
    buffer.append("\n");
    buffer.append("Shape {\n");   
    buffer.append("\tappearance Appearance {\n");
    buffer.append("\t\tmaterial Material {\n");
    buffer.append("\t\t}  #Material\n");
    buffer.append("\t} #Appearance\n");
    buffer.append("\tgeometry IndexedFaceSet {\n");
    buffer.append("\t\tcoord  DEF AllCoords Coordinate {\n");
    buffer.append("\t\tpoint [\n");
    
    // list vertices coordinates
    HashMap <Integer, Integer> vertexKeys = new HashMap <Integer, Integer> ();
    int counter = 0;
    for(HE_Vertex v : this.getVerticesAsArray()){
      buffer.append("\t\t\t"+v.xf()+" "+v.yf()+" "+v.zf()+",\n");
      vertexKeys.put(v.key(), counter);
      counter++;
    }
    
    buffer.append("\t\t] #point\n");
    buffer.append("\t\t} #Coordinate\n");
    buffer.append("\t\tcoordIndex [\n");
    
    // list faces vertices indexes
    counter = 0;
    ArrayList<HE_Vertex> vlist;
    for(HE_Face f : this.getFacesAsArray()){
      vlist = new ArrayList(f.getFaceVertices());
      if (vlist.size()==3) {
        buffer.append("\t\t\t"+vertexKeys.get(vlist.get(0).key())+" "+vertexKeys.get(vlist.get(1).key())+" "+vertexKeys.get(vlist.get(2).key())+" -1\n");
      }
      vlist.clear();
      counter++;
    }
    
    buffer.append("\t\t] #coordIndex\n");
    buffer.append("\t\tcolorPerVertex FALSE\n");
    buffer.append("\t\tcolor Color {\n");
    buffer.append("\t\t\tcolor [\n");
    
    // list face colors
    counter = 0;
    for(HE_Face f : this.getFacesAsArray()){
      vlist = new ArrayList(f.getFaceVertices());
      if (vlist.size()==3) {
        //color cf = colorSave.get(f.key());
        color cf = color(f.getLabel());
        float red = red(cf)/255.0;
        float green = green(cf)/255.0;
        float blue = blue(cf)/255.0;
        buffer.append("\t\t\t"+red+" "+green+" "+blue+",\n");
      }
      vlist.clear();
      counter++;
    }

    buffer.append("\t\t\t] #color\n");
    buffer.append("\t\t} #Color\n");  
    buffer.append("\t} #IndexedFaceSet\n");
    buffer.append("} #Shape\n");
    
    String[] output=new String[1];
    output[0] = buffer.toString();
    saveStrings("savedStls/" + DateUtils.timeStamp() + ".wrl", output);
    save("savedStls/" + DateUtils.timeStamp() + "_preview.png"); //save screenshot
    println("exporting done.");
  }
  
  // set all the colors in the mesh
  void setColors() {
    // clear the whole list of colors (start from scratch)
    //colorSave.clear();
    color c;
    // go over all the faces in the mesh
    for (HE_Face f : getFacesAsList()) { // ITERATION LOOP FOR SETTING A COLOR TO EACH FACE
      // get face middle
      WB_Point3d faceMiddle = f.getFaceCenter();
      float fX = faceMiddle.xf(); //using the x coordinate.
      float fY = faceMiddle.yf(); //using the y coordinate.
      float fZ = faceMiddle.zf(); //using the z coordinate for face height.
      float fA = (float)f.getFaceArea();
      // get color from algorithm
      algocolor.updateParameters(P1,P2,P3,P4,P5,P6,P7,P8);
      c = algocolor.getFaceColor(fX,fY,fZ,fA,cc);
      // put the color in it's unique place in the hashmap (based on the unique face key)
      //colorSave.put(f.key(), c);
      f.setLabel(c);
    }
  }
  
  // ----- OBJ COLORS -------
  void setVertexColors(ArrayList VC){
    vertexColors = VC;
    println("setVertexColors done");
    println("vertexColors size =  " + vertexColors.size());
    //println(vertexColors);
  }
  
   //lerp of saved color with new color
  void setColors2(){   
    println("vertexColors list size =" + vertexColors.size()); 
    for (HE_Face f : getFacesAsList()) {
      
      //works only for triangulated meshes
      List<HE_Vertex> nvertices = f.getFaceVertices();
       
      color c1 = (Integer)vertexColors.get(nvertices.get(0).key()-2092);
      color c2 = (Integer)vertexColors.get(nvertices.get(1).key()-2092);
      color c3 = (Integer)vertexColors.get(nvertices.get(2).key()-2092);
      
      //there is probaly a better way averaging three colors
      color mix12  = lerpColor(c1, c2, .66);
      color mix13  = lerpColor(c1, c3, .66);
      color mix = lerpColor(mix12, mix13, .5);
      
      //color oldC = color(colorSave.get(f.key()));
      color oldC = color(f.getLabel());
      color newC = lerpColor(mix, oldC, .8); // .6
      
      //colorSave.put(f.key(), newC);
      f.setLabel(newC);
    }
  }
  

  
   //hue of algocolor, with saturation of input color
  void setColors3(int mode){   
    println("vertexColors list size =" + vertexColors.size()); 
    for (HE_Face f : getFacesAsList()) {
      
      
      //works only for triangulated meshes
      List<HE_Vertex> nvertices = f.getFaceVertices();
       
      color c1 = (Integer)vertexColors.get(nvertices.get(0).key()-2092);
      color c2 = (Integer)vertexColors.get(nvertices.get(1).key()-2092);
      color c3 = (Integer)vertexColors.get(nvertices.get(2).key()-2092);
      
      //there is probaly a better way averaging three colors
      color mix12  = lerpColor(c1, c2, .66);
      color mix13  = lerpColor(c1, c3, .66);
      color mix = lerpColor(mix12, mix13, .5);
      
      //color oldC = color(colorSave.get(f.key()));
      color oldC = color(f.getLabel());
      color newC = lerpColor(mix, oldC, 0.9); // .5
      
      //colorSave.put(f.key(), newC);
      
      float hf = hue(oldC); //newC
      
      float sf1 = saturation(newC);//oldC
      float sf2 = saturation(mix);//oldC
      float sf = 255;
      
      
      float bf1 = brightness(oldC);
      float bf2 = brightness(mix);
      float bf = 200;
      
      if(mode == 1){
        //bf = (bf1+bf2)*0.5;
        WB_Point3d faceMiddle = f.getFaceCenter();
        float fZ = faceMiddle.zf();
        float heightmap = (this.objectHeight-(this.objectHeight * P8/100));
        float gradStrength = fZ/heightmap*0.6;
        bf = (bf1*(1-gradStrength)+bf2*(gradStrength));
        if(bf > 255){bf=255;};
        
        sf = (sf1+sf2)*0.5;
        if(sf > 255){sf=255;};
      }
      else if(mode == 2){
        float gradStrength = 1;
        WB_Point3d faceMiddle = f.getFaceCenter();
        float fZ = faceMiddle.zf();
        float heightmap = (this.objectHeight-(this.objectHeight * P8/100));
        gradStrength = fZ/heightmap*0.6;
        //println( "gradStrength is = " + gradStrength ); 
        // calculate mix dependent on height of face 
        bf = (bf1*(1-gradStrength)+bf2*(gradStrength));
        if(bf > 255){bf=255;};
        // gentle gradient on saturation
        gradStrength = fZ/heightmap*0.3;
        sf = (sf1*(1-gradStrength)*1.2+sf2*(gradStrength)*0.8);
        if(sf > 255){sf=255;};
        //before we just used:
        //sf = (sf1+sf2)*0.5;
        
      }
      else if(mode == 3){
        float gradStrength = 1;
        WB_Point3d faceMiddle = f.getFaceCenter();
        float fZ = faceMiddle.zf();
        float heightmap = (this.objectHeight-(this.objectHeight * P8/100));
        //gradStrength = (fZ-(this.objectHeight * P8/100))/this.objectHeight;
        gradStrength = fZ/heightmap*0.6;
        //println( "gradStrength is = " + gradStrength ); 
        // calculate mix dependent on height of face 
        
        //we want bf1 to be stronger when fZ is lower
        if(1>0){
        bf = (bf1*(1-gradStrength)+bf2*(gradStrength));
        sf = (sf1*(1-gradStrength)+sf2*(gradStrength));
        
         //sf = (sf1+sf2)*0.5;
        }
        else{
          bf = bf1;
          sf = sf1;
           //sf = (sf1*(1-gradStrength)+sf2*(gradStrength));
          println("diff");
        }
      }
      else if(mode == 4){
        float gradStrength = 1;
        WB_Point3d faceMiddle = f.getFaceCenter();
        float fZ = faceMiddle.zf();
        float heightmap = (this.objectHeight-(this.objectHeight * P8/100));
        gradStrength = fZ/heightmap*0.6;
        //println( "gradStrength is = " + gradStrength ); 
        // calculate mix dependent on height of face 
        //bf = (bf1*(1-gradStrength)+bf2*(gradStrength));
        bf = bf1;
        if(bf > 255){bf=255;};
        // gentle gradient on saturation
        gradStrength = fZ/heightmap*0.3;
        sf = (sf1*(1-gradStrength)*1.2+sf2*(gradStrength)*0.8);
        //sf = sf1;
        if(sf > 255){sf=255;};
        //before we just used:
        //sf = (sf1+sf2)*0.5;
        
      }
      
      
      colorMode(HSB, 255, 255, 255); 
      color cN = color(hf, sf, bf);
      colorMode(RGB,255); 
      //colorSave.put(f.key(), cN);
      f.setLabel(cN);
      
    }
  }
  

  
  
  void setColors2b() {     
     int i = 0;
     for (HE_Face f : getFacesAsList()) {
       color c = (255);
       if(i < vertexColors.size()){ // quick hack to use vertex c on faces
         //List<HE_Vertex> vertices = f.getFaceVertices();
         c = (Integer)vertexColors.get(i);
       }
       //colorSave.put(f.key(), c);
       f.setLabel(c);
       i++;
     }
  }
  
  
  void getObjectDims(){
    WB_AABB3D box = this.getAABB();
    objectDepth = (float)box.getHeight(); //x
    objectHeight = (float)box.getDepth(); //y
    objectWidth = (float)box.getWidth();  //z
    println(objectWidth +  ", " + objectDepth +  ", " + objectHeight);
  }
  
  void getFaceAreas(){
    fAmax=0; fAmin=100; 
    for (HE_Face f : getFacesAsList()) { 
      float fA = (float)f.getFaceArea();
      if(fA > fAmax){
        fAmax = fA;
      }
      if(fA < fAmin){
        fAmin = fA;
      }
    }
  }
  
  void contrast(){
    BL = 255;
    BH = 0;
    // first define existing high and low of brightness
    for (HE_Face f : getFacesAsList()) {
        // get face color
        color cf = color(f.getLabel());// colorSave.get(f.key());
        float brightness = brightness(cf);
        
        if(brightness > BH){
          BH = brightness;
        }
        if(brightness < BL){
          BL = brightness;
        }        
      }
       
     // now go over faces, map brightness onto full range, save face
     for (HE_Face f : getFacesAsList()) {
        // get face color
        //color cf = colorSave.get(f.key());
        color cf = color(f.getLabel());
        float hf = hue(cf);
        float sf = saturation(cf);
        float bf = brightness(cf);
        colorMode(HSB, 255, 255, 255);
        float bN = map(bf, BL, BH, 0, 255);
        color cN = color(hf, sf, bN);
        colorMode(RGB,255); 
        //colorSave.put(f.key(), cN);
        f.setLabel(cN);
     }
  colorMode(RGB,255);   
  }
  
  void saturate(){
     // now go over faces, map brightness onto full range, save face
     for (HE_Face f : getFacesAsList()) {
        // get face color
        //color cf = colorSave.get(f.key());
        color cf = color(f.getLabel());
        float hf = hue(cf);
        float sf = saturation(cf);
        float bf = brightness(cf);
        colorMode(HSB, 255, 255, 255);
        //float bN = map(bf, BL, BH, 0, 255);
        float dice = random(1);
        if((sf <= 245)&&(bf<155)&&(dice>0.4)){
          sf = sf + 10;
        }
        color cN = color(hf, sf, bf);
        colorMode(RGB,255); 
        //colorSave.put(f.key(), cN);
        f.setLabel(cN);
     }
  colorMode(RGB,255);   
  }
  
  void brightenbrights(){
     // now go over faces, map brightness onto full range, save face
     for (HE_Face f : getFacesAsList()) {
        // get face color
        //color cf = colorSave.get(f.key());
        color cf = color(f.getLabel());
        float hf = hue(cf);
        float sf = saturation(cf);
        float bf = brightness(cf);
        colorMode(HSB, 255, 255, 255);
        //float bN = map(bf, BL, BH, 0, 255);
        //float dice = random(1);
        if((bf>150)&&(bf<=245)){
          bf = bf + 10;
        }
        color cN = color(hf, sf, bf);
        colorMode(RGB,255); 
        //colorSave.put(f.key(), cN);
        f.setLabel(cN);
     }
  colorMode(RGB,255);   
  }

  void hueShift(int direction){
     // now go over faces, map brightness onto full range, save face
     for (HE_Face f : getFacesAsList()) {
        // get face color
        //color cf = colorSave.get(f.key());
        color cf = color(f.getLabel());
        float hf = hue(cf);
        float sf = saturation(cf);
        float bf = brightness(cf);
        colorMode(HSB, 255, 255, 255);
        //float bN = map(bf, BL, BH, 0, 255);
        if(hf <= 250){
          hf = hf + 2*direction;
        }
        color cN = color(hf, sf, bf);
        colorMode(RGB,255); 
        //colorSave.put(f.key(), cN);
        f.setLabel(cN);
     }
  colorMode(RGB,255);   
  }
  
  void colorPair(){ 
     HashMap <Integer, Integer> faceLocker = new HashMap <Integer, Integer> ();
     int counter = 0;
     for (HE_Face f : getFacesAsList()) {
       color cf = color(f.getLabel());
       for (HE_Face neighbour : f.getNeighborFaces()) {
         if(faceLocker.containsKey(f.key())){
          // We have this face already
         }
         else{
           neighbour.setLabel(cf);
           faceLocker.put(f.key(), counter);
           counter++;
         } 
       }
     }
  }
  
    void colorNeighbour(){ 
     HashMap <Integer, Integer> faceLocker = new HashMap <Integer, Integer> ();
     int counter = 0;
     for (HE_Face f : getFacesAsList()) {
       color cf = color(f.getLabel());
       for (HE_Face neighbour : f.getNeighborFaces()) {
         if(faceLocker.containsKey(f.key())){
          // We have this face already
         }
         else{
           neighbour.setLabel(cf);
           faceLocker.put(f.key(), counter);
           counter++;
           break;
           
         }
         break;
       }
     }
  }
  
  
    void colorPairBump(float s){
    
     HashMap <Integer, Integer> faceLocker = new HashMap <Integer, Integer> ();
     HE_Selection sel = new HE_Selection(this); 
     sel.clear();
     int counter = 0;
     for (HE_Face f : getFacesAsList()) {
       color cf = color(f.getLabel());
       for (HE_Face neighbour : f.getNeighborFaces()) {
         if(faceLocker.containsKey(f.key())){
          // We have this face already
         }
         else{
           color cOld = color(neighbour.getLabel());
           neighbour.setLabel(cf);
           faceLocker.put(f.key(), counter);
           counter++;
           if(cOld != cf){
             sel.add(f);
           }
         } 
       }
     }
     sel.collectVertices();
     HEM_VertexExpand modifier=new HEM_VertexExpand();
     modifier.setDistance(s);
     modifier.apply(sel);
     for(HE_Vertex v : sel.getVerticesAsArray()){
       //v.scale(s,s,s);
     }
  }

}



