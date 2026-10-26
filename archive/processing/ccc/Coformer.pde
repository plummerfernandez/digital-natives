class Coformer extends HE_MeshColor {
  HE_Selection sel;
  String coname;
  int X1, Y1, Z1, X2, Y2, Z2, S1, S2, co;
  HE_Mesh meshCopy;

  
  Coformer(HEC_Creator creator){
    super(creator);
    sel = new HE_Selection(this);  
    this.selectAll();
    coname = " ";
    meshCopy = this.get();
  }
  
  void update(int co_, int X1_,int Y1_,int Z1_,int X2_,int Y2_,int Z2_,int S1_,int S2_){
    X1 = X1_;
    Y1 = Y1_;
    Z1 = Z1_;
    X2 = X2_;
    Y2 = Y2_;
    Z2 = Z2_;
    S1 = S1_;
    S2 = S2_;
    co = co_;
    // update name
    switch(co){

    case 0:
      coname = "wave";
      helptext = "test helptext";
      break;
    case 1:
      coname = "cavity";
      break;
    case 2:
      coname = "wide base";
      break;
    case 3:
      coname = "natives patch";
      break; 
    case 4:
      coname = "cup2";
      helptext = "try S1=81, S2=61";
      break;      
    case 5:
      coname = "scaleZExpo";
      break;
    case 6:
      coname = "toastieStretch";
      break;
    case 7:
      coname = "flip";
      break;
    case 8:
      coname = "mirror";
      break;
    case 9:
      coname = "quattro";
      break;
    case 10:
      coname = "six";
      break;
    case 11:
      coname = "fatslab";
      break;
    case 12:
      coname = "printerHeadSlip";
      break;
    case 13:
      coname = "scaleSelection";
      break;
    case 14:
      coname = "spikes";
      break;
    case 15:
      coname = "empty";
      break;
    case 16:
      coname = "empty";
      break;
    case 17:
      coname = "perlin";
      break;
    case 18:
      coname = "empty";
      break;
    case 19:
      coname = "perlinForward2";
      break;
    case 20:
      coname = "empty";
      break;
    default:
      coname = " ";
      break;
    } 
  }
  
  //-------co-former master execute button -----------// 
  void execute(){
    saveCopy();
    
    switch(co){
    case 0:
      wave();
      break;
    case 1:
      cavityGlitch2();
      break;
    case 2:
      wideBase();
      break;
    case 3:
      patchToBase0();
      break;
    case 4:
      cup2();
      break;
    case 5:
       scaleZExpo();
       break;
    case 6:
       toastieStretch();
       break;
    case 7:
       motherFlipper();
       break;
    case 8:
       mirror();
       break;
    case 9:
       quattro();
       break;
    case 10:
       //sixsixsix();
    case 11:
       fatslab();
       break;
    case 12:
       printerHeadSlip();
       break;
    case 13:
       scaleSelection();
       break;
    case 14:
       spikes();
       break;
    case 15:
       //trumpet();
       break;
    case 16:
       //cup();
       break;
    case 17:
       perlin();
       break;
    case 18:
       //bell();
       break;
    case 19:
       perlinForward2();
       break;
    case 20:
       //bellbase();
       break;
    }
    
  }
//  //-------co-former master execute button -----------// 
//  void execute(){
//    saveCopy();
//    
//    switch(co){
//    case 0:
//      selectAll();
//      break;
//    case 1:
//      selectRegion1();
//      break;
//    case 2:
//      selectRegion2();
//      break;
//    case 3:
//      smoothe();
//      break;
//    case 4:
//      twist();
//      break;
//    case 5:
//      wave();
//      break;
//    case 6:
//      bend1();
//      break;
//    case 7:
//      bend2();
//      break;
//    case 8:
//      cavityGlitch2();
//      break;
//    case 9:
//      wideBase();
//      break;
//    case 10:
//      cropBase();
//      break;
//    case 11:
//      cropTop();
//      break;
//    case 12:
//      patchToBase0();
//      break;
//    case 13:
//      patchGlitchToSide();
//      break;
//    case 14:
//       explodePatch();
//       break;
//    case 15:
//       toastieStretch();
//       break;
//    case 16:
//       motherFlipper();
//       break;
//    case 17:
//       subdiv();
//       break;
//    case 18:
//       mirror();
//       break;
//    case 19:
//       quattro();
//       break;
//    case 20:
//       //sixsixsix();
//    case 21:
//       fatslab();
//       break;
//    case 22:
//       goodPoint();
//       break;
//    case 23:
//       blamethrower();
//       break;
//    case 24:
//       printerHeadSlip();
//       break;
//    case 25:
//       sineTwist();
//       break;
//    case 26:
//       scaleSelection();
//       break;
//    case 27:
//       catmullClarkSubD();
//       break;
//    case 28:
//       fractalSubD();
//       break;
//    case 29:
//       spikes();
//       break;
//    case 30:
//       trumpet();
//       break;
//    case 31:
//       cup();
//       break;
//    case 32:
//       perlin();
//       break;
//    case 33:
//       bell();
//       break;
//    case 34:
//       perlinForward2();
//       break;
//    case 35:
//       bellbase();
//       break;
//    }
//    
//  }
 //----------------undo--------------------------//
 void undo(){
  this.clear();
  this.add(meshCopy);
  //meshCopy.clear();
  this.saveCopy();
  this.setColors(); 
  println("undone");
 }
 void saveCopy(){
  meshCopy.clear();
  meshCopy = this.get();
 }
 //-------move to absolute center ---------------//
 void moveToCenter(){
    WB_AABB3D box = this.getAABB();
    double objDepth = box.getHeight(); //x
    double objHeight = box.getDepth(); //y
    double objWidth =  box.getWidth(); //z
    //calculate center
    WB_Point3d center = box.getCenter();
    double centerX = center.x;
    double centerY = center.y;
    double centerZ = center.z;
    //distances to move 
  }
  
 //-------co-former select operations -----------// 
 void selectAll(){
   sel.clear();
   for (HE_Face f : getFacesAsList()) {
     sel.add(f);
   }
   sel.collectVertices();
   println("selection count = " + sel.numberOfVertices());
 }
//------------------------------------------------//
void selectRegion1(){
    sel.clear();
    float upLimit; 
    float botLimit; 
    
    upLimit =(float(Z1)/100)*this.objectHeight;
    botLimit = (float(Z2)/100)*this.objectHeight;
    
    // Z selection only
    for (HE_Face f : getFacesAsList()) {
    WB_Point3d faceMiddle = f.getFaceCenter();
    float fZ = faceMiddle.zf(); //using the z coordinate for face height.
      if((fZ < upLimit)&&(fZ > botLimit)){ 
         sel.add(f);
       } 
   }   
   
   sel.collectVertices();
   println("selection count = " + sel.numberOfVertices());  
  }
//------------------------------------------------//
  void selectRegion2(){
    sel.clear();
    float upLimit; 
    float botLimit; 
    float leftLimit;
    float rightLimit;
    
    upLimit =(float(Z1)/100)*this.objectHeight;
    botLimit = (float(Z2)/100)*this.objectHeight;
    //println("upLimit = " + upLimit);
    //println("botLimit = " + botLimit);
    
    float boxWidth = (float(X1)/100)*colormesh.objectWidth - (float(X2)/100)*colormesh.objectWidth;
    float boxXpos = (float(X2)/100)*colormesh.objectWidth + boxWidth/2 - colormesh.objectWidth/2; 
    
    leftLimit = boxXpos;
    rightLimit = boxXpos + boxWidth;
    //println("leftLimit = " + leftLimit);
    //println("rightLimit = " + rightLimit);
   
    for (HE_Face f : getFacesAsList()) {
    WB_Point3d faceMiddle = f.getFaceCenter();
    float fX = faceMiddle.xf(); 
    float fY = faceMiddle.yf();
    float fZ = faceMiddle.zf();
    
    
      if((fZ < upLimit)&&(fZ > botLimit)){ 
           if((fX > leftLimit)&&(fX < rightLimit)){ 
             sel.add(f);
         }
       } 
   }   
   
   sel.collectVertices();
   println("selection count = " + sel.numberOfVertices());  
  }
  //-------co-former modifier operations -----------// 
  void smoothe(){   
    this.modifySelected(new HEM_Smooth(),sel);
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  void subdiv(){   
    HES_Planar subd = new HES_Planar();
    subd.apply(sel);
    this.setColors();
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  void twist(){
    for(HE_Vertex v : sel.getVerticesAsArray()){
     //v.rotateAboutAxis(v.z * 0.005, 0,0,0,0,0,100); //(double angle, double p1x, double p1y, double p1z, double p2x, double p2y, double p2z) 
     //  WB_Line L=new WB_Line(0,0,0,map(X1,0,100,-1,1),map(Y1,0,100,-1,1),map(Z1,0,100,-1,1));
     
     //// ccc+cf version 
     //v.rotateAboutAxis(v.z * 0.005, 0,0,0,map(X1,0,100,-1,1),map(Y1,0,100,-1,1),map(Z1,0,100,-1,1));
     
     /// retro version / WB_Line L=new WB_Line(S2/4,0,0,S1,0,200);
     v.rotateAboutAxis(v.z * 0.005 * reversal, S2/4,0,0,S1/2,0,200);
    }
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  void wave(){
    for(HE_Vertex v : sel.getVerticesAsArray()){
      float fvz = (float)v.z;
      v.moveTo(v.x + sin(fvz/objectHeight*PI*10)*S1/100, v.y, v.z); 
    }
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  void bend1(){
      HEM_Twist modifier=new HEM_Twist();
      WB_Line L = new WB_Line(X1,Y1,Z1,X2,Y2,Z2);
      //WB_Line L=new WB_Line(0,0,0,map(X1,0,100,-1,1),map(Y1,0,100,-1,1),map(Z1,0,100,-1,1));
      modifier.setTwistAxis(L);// Bending axis
      modifier.setAngleFactor(30.0/400);// Angle per unit distance (in degrees) to the ground plane
      this.modifySelected(modifier,sel);
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  void bend2(){
      HEM_Twist modifier=new HEM_Twist();
      //WB_Line L = new WB_Line(X1,Y1,Z1,X2,Y2,Z2);
      WB_Line L=new WB_Line(0,0,0,map(X1,0,100,-1,1),map(Y1,0,100,-1,1),map(Z1,0,100,-1,1));
      modifier.setTwistAxis(L);// Bending axis
      modifier.setAngleFactor(30.0/400 *-1);// Angle per unit distance (in degrees) to the ground plane
      this.modifySelected(modifier,sel);
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  void moveSection(int mx,int my,int mz){
    for(HE_Vertex v : sel.getVerticesAsArray()){
      double dvz = v.z;
      double dvx = v.x; 
      double dvy = v.y; 
       v.moveTo(dvx+mx*0.05,dvy+my*0.05,dvz+mz*0.05);
    }
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  void cavityGlitch2(){
   HE_Face[] allFaces = this.getFacesAsArray();
   HE_Selection facesToDelete = new HE_Selection(this);
   HE_Face randomFace = allFaces[(int)random(allFaces.length)];
   for (HE_Face neighbour : randomFace.getNeighborFaces()) {
     
           facesToDelete.add(neighbour);
            for (HE_Face neighbour2 : neighbour.getNeighborFaces()) {
              if((int)random(10)>3){
                 facesToDelete.add(neighbour2);
                 for (HE_Face neighbour3 : neighbour2.getNeighborFaces()) {
                      if((int)random(10)>3){
                       facesToDelete.add(neighbour3);
                          for (HE_Face neighbour4 : neighbour3.getNeighborFaces()) {
                            if((int)random(10)>3){
                               facesToDelete.add(neighbour4);
                              }
                           }
                 
                         }
                  }
                 
               }
            }
        
   }
   facesToDelete.grow(int(S1/10));
   facesToDelete.collectVertices();
   this.delete(facesToDelete); 
 }
 // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 void wideBase() {
   for(WB_Point3d v : getVerticesAsPoint()){
    double dvz = v.z; //using the z coordinate for face height.
    float fZ = (float)dvz;
    if (fZ <= objectHeight/10){
      float cupScale = 2 - fZ/(objectHeight*0.1); 
      v.scale(cupScale,cupScale,1); 
    }
   }
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  void moveToZero(){
    float distanceZ = basePosition();
    this.move(0,0,distanceZ*-1);
  }
  float basePosition(){
     WB_AABB3D bbox = this.getAABB();
     double heightHD = bbox.getDepth();
     float heightH = (float)heightHD;
     WB_Point3d bbCenter = bbox.getCenter();
     double centerZ = bbCenter.z;
     double baseZ = centerZ - heightHD*0.5;
     float baseZF = (float)baseZ;
     return baseZF;  
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  void cropBase(){
      WB_Plane P=new WB_Plane(0,0,(float(Z2)/100)*this.objectHeight,0,0,1);
      HEM_Slice sm=new HEM_Slice().setPlane(P);
      sm.setCap(false);
      this.modify(sm);
      println("crop done");
      moveToZero();
      setColors(); 
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  void cropTop(){
      WB_Plane P=new WB_Plane(0,0,(float(Z1)/100)*this.objectHeight,0,0,-1);
      HEM_Slice sm=new HEM_Slice().setPlane(P);
      sm.setCap(false);
      this.modify(sm);
      println("crop done");
      setColors(); 
  }
 // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  HE_Selection glitchBoundaryToSide() {
    ArrayList<HE_Halfedge> boundary = new ArrayList(this.getBoundaryHalfedges());
    HE_Selection lsel=new HE_Selection(this);
    if (boundary.size()>0) {
     for (HE_Halfedge he: boundary) {
      //HE_Vertex v=new HE_Vertex(x, y, z);
      HE_Vertex heV = he.getEndVertex();
      double heX = heV.x + objectWidth/random(3,10);
      double heY = heV.y;
      double heZ = heV.z;
      HE_Vertex v=new HE_Vertex(heX, heY, heZ);
      this.add(v);
      HE_Halfedge he1=new HE_Halfedge();
      he1.setVertex(he.getEndVertex());
      HE_Halfedge he2=new HE_Halfedge();
      he2.setVertex(v);
      v.setHalfedge(he2);
      he.setNext(he1);
      he1.setNext(he2);
      he2.setNext(he);
      HE_Face f=new HE_Face();
      f.setHalfedge(he);
      he.setFace(f);
      he1.setFace(f);
      he2.setFace(f);
      this.add(he1);
      this.add(he2);
      this.add(f);
      lsel.add(f);
    }
    this.pairHalfedges();
    this.capHalfedges();
  }
  return lsel;
 }
 // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 void patchGlitchToSide(){
    HE_Selection selection = glitchBoundaryToSide();
    HE_Selection deletion =  new HE_Selection(this);  
    for (HE_Face f : selection.getFacesAsList()) {  
           if(random(1)<0.5){
              deletion.add(f);
            }
    }
    this.delete(deletion);
    this.setColors(); 
 }
 // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 HE_Selection explodePatch() {
  ArrayList<HE_Halfedge> boundary = new ArrayList(this.getBoundaryHalfedges());
  HE_Selection lsel=new HE_Selection(this);
  if (boundary.size()>0) {
    
    for (HE_Halfedge he: boundary) {
      //point 1:
      // (0,0,0)
      
      //point 2:
      HE_Vertex heV = he.getEndVertex();
      float x2 = (float)heV.x;
      float y2 = (float)heV.y;
      float z2 = (float)heV.z;
      
      float k;
      float len = (float)objectWidth*0.9;
      k = sqrt((pow(len,2.0))/(pow(x2,2.0)+pow(y2,2.0)));
      
      //point 3:
      double x3;
      double y3;
      double z3;
      
      x3 = x2 * k;
      y3 = y2 * k;
      z3 = z2 * k;
  
      HE_Vertex v=new HE_Vertex(x3, y3, heV.z); // instead of z3
      this.add(v);
      HE_Halfedge he1=new HE_Halfedge();
      he1.setVertex(he.getEndVertex());
      HE_Halfedge he2=new HE_Halfedge();
      he2.setVertex(v);
      v.setHalfedge(he2);
      he.setNext(he1);
      he1.setNext(he2);
      he2.setNext(he);
      HE_Face f=new HE_Face();
      f.setHalfedge(he);
      he.setFace(f);
      he1.setFace(f);
      he2.setFace(f);
      this.add(he1);
      this.add(he2);
      this.add(f);
      lsel.add(f);
    }
    this.pairHalfedges();
    this.capHalfedges();
  }
  setColors();
  return lsel;
 }
 // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 void toastieStretch(){
    for(WB_Point3d v : this.getVerticesAsPoint()){
    double dvz = v.z;
    double dvx = v.x; 
    double dvy = v.y; 
    //float fZ = (float)dvz;
    if (dvx > 0){
      v.moveTo(dvx+objectWidth/4,dvy,dvz);
     }
     else{
      v.moveTo(dvx-objectWidth/4,dvy,dvz);
     }
   }
//   HE_Selection deletion =  new HE_Selection(this);
//   for (HE_Face f : this.getFacesAsList()) {
//      // get face middle
//      WB_Point3d faceMiddle = f.getFaceCenter();
//      float fX = faceMiddle.xf(); //using the x coordinate.
//      if((fX < objectWidth/5)&&(fX>-objectWidth/5)){
//        if(random(1)<0.3){
//              deletion.add(f);
//         }
//      }
//   }
//   this.delete(deletion);
   this.setColors();
 }
 // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 void mirror(){
              
      HEM_Slice sm=new HEM_Slice().setPlane(new WB_Plane(0,0,colormesh.objectHeight/2,1,0,0));
      sm.setCap(false);
      this.modify(sm);
      println("crop done");
      HE_Mesh mesh2;
      mesh2 = this.get();
      mesh2.scale(1,-1,1,(new WB_Point3d(0,0,0)));
      mesh2.rotateAboutAxis(PI,0,0,0,0,0,1);
      mesh2.flipAllFaces();
      this.add(mesh2);
      
      WB_ExplicitPolygon[] polygons = this.getPolygons(); 
      HEC_FromPolygons pCreator=new HEC_FromPolygons();
      pCreator.setPolygons(polygons);      
      HE_Mesh mesh3 = new HE_Mesh(pCreator);
      
      mesh3.flipAllFaces();      
      this.delete(this.selectAllFaces());
      this.add(mesh3);
      this.pairHalfedges();           
      this.setColors(); 
 }
 // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 void quattro(){
          
      HEM_Slice sm=new HEM_Slice().setPlane(new WB_Plane(0,0,colormesh.objectHeight/2,1,0,0));
      sm.setCap(false);
      this.modify(sm);
      
      HEM_Slice sm2=new HEM_Slice().setPlane(new WB_Plane(0,0,colormesh.objectHeight/2,0,1,0));
      sm2.setCap(false);
      this.modify(sm2);
     
      println("crop done");
      HE_Mesh mesh2;
      mesh2 = this.get();
      mesh2.scale(1,-1,1,(new WB_Point3d(0,0,0)));
      mesh2.rotateAboutAxis(PI,0,0,0,0,0,1);    
      mesh2.flipAllFaces();
      HE_Mesh mesh3;
      mesh3 = mesh2.get();
      mesh3.scale(-1,1,1,(new WB_Point3d(0,0,0)));
      mesh3.rotateAboutAxis(PI,0,0,0,0,0,1);    
      mesh3.flipAllFaces();
      HE_Mesh mesh4;
      mesh4 = mesh3.get();
      mesh4.scale(1,-1,1,(new WB_Point3d(0,0,0)));
      mesh4.rotateAboutAxis(PI,0,0,0,0,0,1);    
      mesh4.flipAllFaces();
      println("debug A");
      this.add(mesh2);
      this.add(mesh3);
      this.add(mesh4);
      println("debug B");
      WB_ExplicitPolygon[] polygons = this.getPolygons(); 
      HEC_FromPolygons pCreator=new HEC_FromPolygons();
      pCreator.setPolygons(polygons);
      HE_Mesh hemeshN=new HE_Mesh(pCreator); 
//      println("debug C");
//      hemeshN.flipAllFaces();      
       //this.delete(this.selectAllFaces()); //---> problems here, tried //this.clear();
      this.add(hemeshN);
      this.pairHalfedges();     
      this.setColors(); 
      println("debug E");
 }
 
  void patchToBase0(){
  ArrayList<HE_Halfedge> boundary = new ArrayList(this.getBoundaryHalfedges());
  
    ArrayList<HE_Halfedge> lowerboundary = new ArrayList();
  
  for (HE_Halfedge he: boundary) {
      HE_Vertex heV = he.getEndVertex();
      float heZ = (float)heV.z-1;
      if(heZ<this.objectHeight/3) {
        lowerboundary.add(he);
      }
  }
  
  if (lowerboundary.size()>0) {
    HE_Vertex v=new HE_Vertex(0, 0, 0);
    this.add(v);
    for (HE_Halfedge he: lowerboundary) {
      HE_Halfedge he1=new HE_Halfedge();
      he1.setVertex(he.getEndVertex());
      HE_Halfedge he2=new HE_Halfedge();
      he2.setVertex(v);
      v.setHalfedge(he2);
      he.setNext(he1);
      he1.setNext(he2);
      he2.setNext(he);
      HE_Face f=new HE_Face();
      f.setHalfedge(he);
      he.setFace(f);
      he1.setFace(f);
      he2.setFace(f);
      this.add(he1);
      this.add(he2);
      this.add(f);
    }
    this.pairHalfedges();
  }
  this.setColors(); 
 }
 
 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
 void motherFlipper(){
      WB_Point3d point1 = this.getCenter();
      WB_Point3d point2 = this.getCenter();
      point1.moveBy(1,0,0);
      point2.moveBy(-1,0,0);
      
      this.rotateAboutAxis(180,point1,point2); //scales object for some reason
      this.scale(1.7); //counter scale
      this.moveToZero();      
      this.setColors(); 
  }
 // - - - - - - - - - - - - - - - - - - - - - - - - - - - -   
 void fatslab(){
   for(WB_Point3d v : this.getVerticesAsPoint()){
    double dvz = v.z; //using the z coordinate for face height.
    double dvx = v.x; 
    double dvy = v.y; 
    float fZ = (float)dvz;
    if (fZ <= 4){
      v.moveTo(dvx,dvy,(dvz-10));
     }
   }
 }
 // - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
 void goodPoint(){
   WB_Point3d[] allPoints = this.getVerticesAsPoint();
   WB_Point3d randomPoint = allPoints[(int)random(allPoints.length)];
   double dvz = randomPoint.z; 
   double dvx = randomPoint.x; 
   double dvy = randomPoint.y; 
   randomPoint.moveTo(dvx*random(1,2),dvy*random(1,2),dvz*random(1,2));
 }
 // - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
 void blamethrower(){
   WB_Point3d[] allPoints = this.getVerticesAsPoint();
   WB_Point3d[] randomPoints = new WB_Point3d[1]; //was 6
   for (int i = 0; i < 1; i = i+1){ //was < 6 but want to have more control
     randomPoints[i] = allPoints[(int)random(allPoints.length)];
   } 
   for (WB_Point3d p: randomPoints){
     p.moveTo(p.x+objectWidth*0.1*random(2,5),p.y,p.z); //was 0.2*random(1,4)
   } 
 } 
 // - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
 void printerHeadSlip(){
   HE_Mesh cutPart = this.get();
   WB_Plane P=new WB_Plane(0,0,(float(Z1)/100)*this.objectHeight,0,0,-1);
   HEM_Slice sm=new HEM_Slice().setPlane(P);
   sm.setCap(false);
   this.modify(sm);
   //HE_Selection cutPart = sm.cut;
   
   //top part
   WB_Plane P2=new WB_Plane(0,0,(float(Z1)/100)*this.objectHeight,0,0,1);
   HEM_Slice sm2=new HEM_Slice().setPlane(P2);
   sm2.setCap(false);
   cutPart.modify(sm2);

   for(HE_Vertex v : cutPart.getVerticesAsArray()){
       v.moveTo(v.x,v.y,v.z+1);
    }
    
    //join boundaries
    ArrayList<HE_Halfedge> boundary = new ArrayList(cutPart.getBoundaryHalfedges());
    HE_Selection lsel=new HE_Selection(this);
    if (boundary.size()>0) {
     for (HE_Halfedge he: boundary) {
      HE_Vertex heV = he.getEndVertex();
      double heX = heV.x;
      double heY = heV.y;
      double heZ = heV.z-1;
      HE_Vertex v=new HE_Vertex(heX, heY, heZ);
      cutPart.add(v);
      HE_Halfedge he1=new HE_Halfedge();
      he1.setVertex(he.getEndVertex());
      HE_Halfedge he2=new HE_Halfedge();
      he2.setVertex(v);
      v.setHalfedge(he2);
      he.setNext(he1);
      he1.setNext(he2);
      he2.setNext(he);
      HE_Face f=new HE_Face();
      f.setHalfedge(he);
      he.setFace(f);
      he1.setFace(f);
      he2.setFace(f);
      cutPart.add(he1);
      cutPart.add(he2);
      cutPart.add(f);
      lsel.add(f);
      /// now other face      
      print("he = ");
      println(he.getEndVertex());
      print("he1 = ");
      println(he1.getEndVertex());
      print("he2 = ");
      println(he2.getEndVertex());
      println(" - - - "); 
       
      HE_Vertex he2v = he2.getEndVertex();
      HE_Vertex he3v=new HE_Vertex(he2v.x, he2v.y, he2v.z-1);
      
      HE_Halfedge a=new HE_Halfedge();
      HE_Halfedge b=new HE_Halfedge();
      HE_Halfedge c=new HE_Halfedge();
      
      a.setVertex(v);
      v.setHalfedge(a);
      b.setVertex(he3v);
      he3v.setHalfedge(b);
      c.setVertex(he2v);
      he2v.setHalfedge(c);
      
      a.setNext(b);
      b.setNext(c);
      c.setNext(a);
      
      HE_Face f2=new HE_Face();
      f2.setHalfedge(a);
      a.setFace(f2);
      b.setFace(f2);
      c.setFace(f2);
      
      cutPart.add(he3v);
      cutPart.add(f2);
      cutPart.add(a);
      cutPart.add(b);
      cutPart.add(c);
      lsel.add(f2);
      
     }
    }
    this.add(cutPart);
    this.pairHalfedges();
    this.capHalfedges();
    this.setColors();  
    
    // make from polygon soup
    WB_ExplicitPolygon[] polygons = this.getPolygons(); 
    HEC_FromPolygons pCreator=new HEC_FromPolygons();
    pCreator.setPolygons(polygons);      
    HE_Mesh mesh3 = new HE_Mesh(pCreator);  
    mesh3.flipAllFaces();      
    this.clear();
    this.add(mesh3);
    this.pairHalfedges(); 
    this.setColors();
    
    this.selectRegion1();
 }
 // - - - - - - - - - - - - - - - - - - - - - - - - - - - -   
 void sineTwist(){
  for(WB_Point3d v : this.getVerticesAsPoint()){
     double dvz = v.z;
     float fvz = (float)dvz;
     v.rotateAboutAxis(fvz*-0.002* reversal* sin(fvz/objectHeight*PI+(Z1/100)*objectHeight), 0,0,0,0,0,1); 
     //v.rotateAboutAxis(v.z * 0.005, 0,0,0,map(X1,0,100,-1,1),map(Y1,0,100,-1,1),map(Z1,0,100,-1,1)); twist normal
    }
 }
 // - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
 void scaleSelection(){
   for(HE_Vertex v : sel.getVerticesAsArray()){
      double dvz = v.z;
      double dvx = v.x; 
      double dvy = v.y; 
      v.moveTo(dvx,dvy,dvz*1.1);
    }
 }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
 void SubD(){
   this.subdivide(new HES_Planar(), 1);
   this.triangulate();
 }
 // - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
 void catmullClarkSubD(){
   this.subdivide(new HES_CatmullClark(), 1);
   this.triangulate();
 }
 
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
  void fractalSubD(){
    
     for (HE_Face f : getFacesAsList()) {
       WB_Point3d faceMiddle = f.getFaceCenter();
       //float fX = faceMiddle.xf(); 
       //float fY = faceMiddle.yf();
       float fZ = faceMiddle.zf();
       HE_Selection selection = new HE_Selection(this); 
       selection.add(f);
       HES_CatmullClark cc = new HES_CatmullClark();
       this.subdivideSelected(cc, selection,int((fZ/(this.objectHeight*0.7))*2)); 
     }
     this.triangulate();
     this.setColors();  
  }
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
   void spikes(){
     float spikeLength = ((float)S1/5 *-1*reversal); //50
     this.getFaceAreas(); //fAmax
     
     for (HE_Face f : getFacesAsList()) {
       float fA = (float)f.getFaceArea();
       float aRatio = fA / this.fAmax;
       HE_Selection selection = new HE_Selection(this); 
       selection.add(f);
       HEM_Extrude extrude1 = new HEM_Extrude();
       extrude1.setDistance(aRatio * spikeLength); 
       extrude1.setChamfer(1); //1
       this.modifySelected(extrude1, selection);  
     }
     //this.setColors(); 
   }
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
   void trumpet(){
     for(HE_Vertex v : sel.getVerticesAsArray()){
      double dvz = v.z;
      double dvx = v.x; 
      double dvy = v.y; 
      v.moveTo(dvx*(1.01*dvz/objectHeight+0.5),dvy*(1.01*dvz/objectHeight+0.5),dvz); //was *1.1
    }
   }
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
   void cup(){
     for(HE_Vertex v : sel.getVerticesAsArray()){
      double dvz = v.z;
      float fZ = (float)dvz;
      //float cupScale=(S1/100)+(sin(fZ/objectHeight+S2));
      float cupScale=(81/100)+(sin(fZ/objectHeight+61));
      v.scale(cupScale,cupScale,1); 
     
    }
   }
   
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
   void cup2(){
     for(HE_Vertex v : sel.getVerticesAsArray()){
      double dvz = v.z;
      float fZ = (float)dvz;
      float cupScale=(S1/100)+(sin(fZ/objectHeight+S2));
      //float cupScale=(81/100)+(sin(fZ/objectHeight+61));
      v.scale(cupScale,cupScale,1); 
     
    }
   }
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
   void perlin(){
     for(HE_Vertex v : sel.getVerticesAsArray()){
      float noiseScale= S2 * 0.002;
      float strength = map(S1,0,100,0.1,1);
      float PN = map(noise(v.xf()*noiseScale, v.yf()*noiseScale, v.zf()*noiseScale), 0, 1, strength*-1, strength);
      v.scale(1+PN,1+PN,1+PN);
    }
   }
   
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
   void perlinForward(){
     float noiseUp = 0.06; //0.035
     float noiseDown = 0.005; //0.005
     float strengthUp = 1.3; //1.1
     float strengthDown = 1; //0.8
     float displaceUp = 1.4; //1.3
     float displaceDown = 0.6; //0.7
     float noiseRate= map(random(0,1),0,1,noiseDown,noiseUp);//0.02 or 0.03
     float strength= random(strengthDown,strengthUp); //1.2
     float yOffset = random(-100,100);
     for(HE_Vertex v : sel.getVerticesAsArray()){
       
      float offset = map(noise(v.xf()*noiseRate, v.yf()*noiseRate-yOffset, v.zf()*noiseRate), 0, strength, 0, 1);
      if((v.z > 0)&&(v.y > 0)){
        float distance = map(offset,0,1,displaceDown,displaceUp); //0.65,1.35
        v.scale(distance,distance,distance);
        //println(distance);
      }
    }
   }
   
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
   void perlinForward2(){
     float noiseUp = 0.6; //0.035
     float noiseDown = 0.05; //0.005
     float strengthUp = 1.3; //1.1
     float strengthDown = 1; //0.8
     float displaceUp = 1.4; //1.3
     float displaceDown = 0.9; //0.7
     float noiseRate= 1; //map(random(0,1),0,1,noiseDown,noiseUp);//0.02 or 0.03
     float strength= random(strengthDown,strengthUp); //1.2
     float yOffset = random(-100,100);
     for(HE_Vertex v : sel.getVerticesAsArray()){
       
      float offset = map(noise(v.xf()*noiseRate, v.yf()*noiseRate-yOffset, v.zf()*noiseRate), 0, strength, 0, 1);
      if((v.y < 0)&&(v.y > -10000)){
        float distance = map(offset,0,1,displaceDown,displaceUp); //0.65,1.35
        v.scale(1,distance,1);
        //println(distance);
      }
    }
   }
   
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
   void bell(){
     println("bell");
     for(HE_Vertex v : sel.getVerticesAsArray()){
      double dvz = v.z;
      float fZ = (float)dvz;
      float strength = map(S1,0,100,0.1,1);
      float cupScale=0.9+map((cos(degrees(fZ/objectHeight*map(S2,0,100,0,0.5)))* strength),-1,1,0,1);
      
      //cupScale = cupScale * strength;
      v.scale(cupScale,cupScale,1); 
    }
   }
     // - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
   void bellbase(){
     println("bell");
     
     float selTop = 0;
     
     for(HE_Vertex v : sel.getVerticesAsArray()){
      
        float fZ = v.zf();
        if (fZ > selTop){
          selTop = fZ;
        }
     }
     
     
     for(HE_Vertex v : sel.getVerticesAsArray()){
      double dvz = v.z;
      float fZ = (float)dvz;
      float strength = map(S1,0,100,0.1,1);
      float cupScale=map((cos(degrees(fZ/selTop*map(S2,0,100,0,0.5)))* strength),-1,1,1,1.5);
      
      float newStrength = map(fZ,0,selTop,0.5,0);
      
      cupScale = cupScale * newStrength;
      
      v.scale(1+cupScale,1+cupScale,1); 
    }
   }
   //- - - - - - - - - - - - - - -
   // scale object in the z direction
  void zScaleMesh() {
   WB_AABB3D box = this.getAABB();
   float currentObjectHeight = (float)box.getDepth(); //z
   float userDesiredHeight = map(Z2,0,100,this.objectHeight*0.2,this.objectHeight*2);
   float scalingNeeded = userDesiredHeight/currentObjectHeight;
   this.scale(1,1,scalingNeeded);
   }
   // scale object in the x direction
  void xScaleMesh() {
   WB_AABB3D box = this.getAABB();
   float currentObjectDepth = (float)box.getHeight(); //x
   float userDesiredDepth = map(X2,0,100,this.objectDepth*0.2,this.objectDepth*2);
   float scalingNeeded = userDesiredDepth/currentObjectDepth;
   this.scale(1,scalingNeeded,1);
   }
   // scale object in the y direction
  void yScaleMesh() {
   WB_AABB3D box = this.getAABB();
   float currentObjectWidth = (float)box.getWidth(); //y
   float userDesiredWidth = map(Y2,0,100,this.objectWidth*0.2,this.objectWidth*2);
   float scalingNeeded = userDesiredWidth/currentObjectWidth;
   this.scale(scalingNeeded,1,1);
   }
   // scale object in the y direction
  void allScaleMesh() {
   WB_AABB3D box = this.getAABB();
   float currentObjectHeight = (float)box.getDepth(); //z
   float userDesiredHeight = map(S1,0,100,this.objectHeight*0.2,this.objectHeight*2);
   float scalingNeeded = userDesiredHeight/currentObjectHeight;
   this.scale(scalingNeeded,scalingNeeded,scalingNeeded);
   }
   
      //- - - - - - - - - - - - - - -
   // scale object in the z direction but exponentially
  void zScaleMeshExpo() {
   WB_AABB3D box = this.getAABB();
   float currentObjectHeight = (float)box.getDepth(); //z
   float userDesiredHeight = map(Z2,0,100,this.objectHeight*0.2,this.objectHeight*2);
   float scalingNeeded = userDesiredHeight/currentObjectHeight;
   this.scale(1,1,scalingNeeded);
   }
   
   void scaleZExpo(){
     for(HE_Vertex v : sel.getVerticesAsArray()){
      double dvz = v.z;
      double dvx = v.x; 
      double dvy = v.y; 
      v.moveTo(dvx,dvy,dvz*(1.01*dvz/objectHeight+0.5)); //was *1.1
    }
   }
   
 
}


