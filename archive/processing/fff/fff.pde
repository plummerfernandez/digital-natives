// fff by Matthew Plummer-Fernandez, 2016 (but initiated 2012)
// www.plummerfernandez.com
// Shared under Creative Commons "share-alike non-commercial use only" license.
// CONTROLS: Keyboard press 's' to save, 'a' for a screenshot + notes
import wblut.math.*;
import wblut.processing.*;
import wblut.core.*;
import wblut.*;
import wblut.hemesh.*;
import wblut.geom.*;
// Toxiclibs for the import stl and save color stl
import toxi.util.datatypes.*;
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.math.*;
import toxi.util.*;
import toxi.processing.*;
import controlP5.*;
import java.util.List;

//--------------------------parameters--------------------------//
int cc, P1, P2, P3, P4, P5, P6, P7, P8; //ccc values
int co, X1, Y1, Z1, X2, Y2, Z2, S1, S2; //coformer values
String[] stlnames;

float strokeV;
boolean linesOn = true;
boolean scalingOn = false;
boolean help = false;
boolean display_limbomesh = false;
String helptext = "";
int reversal = 1;
String path;

Coformer colormesh; // the mesh from a custom class
HE_Mesh limbomesh;
HEC_FromObjFileColor obj;
WB_Render render;
Nav nav;
GuiCoformer gui2;



//--------------------------setup----------------------------//
void setup() {
  size(1000,750, P3D);
  frameRate(30); 
  cc = 2;
  P1 = 0;
  P2 = 240;
  P3 = 240;
  P4 = 110;
  P5 = 110;
  P6 = 85;
  P7 = 0;
  P8 = 0;
  Z1 = 100;
  X1 = 100;
  Y1 = 100;

  nav = new Nav(0,50,3); //  Nav(x from center, y from center, scale)
  loadFiles(); // find models for dropdown menu
  gui2 = new GuiCoformer(this); //intialise interface
  path = sketchPath("importStls/" + stlnames[0]);
  colormesh = new Coformer(fromStl(path)); 
  limbomesh = colormesh.get();
  nav.autoscale(colormesh.objectHeight,colormesh.objectWidth,colormesh.objectDepth);
  strokeV = colormesh.objectHeight/1200;
  render=new WB_Render(this); 
  smooth(4); 
}
//---------------------------------------------------------//
void draw() {
  draw_coformer();
}


// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void draw_coformer(){
  strokeV = colormesh.objectHeight/1200;
  background(230);
  
 
  gui2.show();
  fill(100); 
  stroke(100); 
  text("_f_f_f_", 482, 40); //title, coformer
  text(colormesh.coname, 770 , 465);
  
  if(scalingOn ==true){
    fill(255,100,0); 
    ellipse(750+91,50+293,10,10);
    fill(100); 
  }
  
  if(help==true){
    text(helptext, 770,500);
  }
  hint(ENABLE_DEPTH_TEST);
  pushMatrix();
  
  ambientLight(150, 150, 150);
  directionalLight(50, 50, 50, 0, 0, -1);
  directionalLight(150, 150, 150, 1, -1, 0);  
  lightFalloff(1, 0, 0);
  lightSpecular(0, 0, 0);   

  nav.display();  
  stroke(50);
  strokeWeight(strokeV);
  if(linesOn==true){ 
    render.drawEdges(colormesh);
  }
  noStroke();
  

  if(display_limbomesh == true){
   
    render.drawFaces(limbomesh);

  }
  
    colormesh.display();
  
  
  noFill();
  
  if(linesOn==true){
    
  // line for twist guidance
  stroke(100);
  strokeWeight(strokeV*2); 
  WB_Line L=new WB_Line(S2/4,0,0,S1/2,0,200);
  
  render.draw(L,colormesh.objectHeight*3);
  
  stroke(100);
  strokeWeight(strokeV); 

  float boxHeight = (float(Z1)/100)*colormesh.objectHeight - (float(Z2)/100)*colormesh.objectHeight;
  float boxZpos = (float(Z2)/100)*colormesh.objectHeight + boxHeight/2;
  
  float boxWidth = (float(X1)/100)*colormesh.objectWidth - (float(X2)/100)*colormesh.objectWidth;
  float boxXpos = (float(X2)/100)*colormesh.objectWidth + boxWidth/2 - colormesh.objectWidth/2; 
  
  float boxDepth = (float(Y1)/100)*colormesh.objectDepth - (float(Y2)/100)*colormesh.objectDepth;
  float boxYpos = (float(Y2)/100)*colormesh.objectDepth + boxDepth/2 - colormesh.objectDepth/2; 
    
  translate(boxXpos,boxYpos,boxZpos);
  box(boxWidth,boxDepth,boxHeight);
  
 //planes for looper
  WB_Plane pl1;
  WB_Plane pl2;
  fill(255,255,255,60);
   
  if ((colormesh.coname.equals("mirror"))||(colormesh.coname.equals("quattro formaggi"))||(colormesh.coname.equals("666"))){
       pl1 = new WB_Plane(0,0,colormesh.objectHeight/2,1,0,0);
       render.draw(pl1,colormesh.objectHeight*1.3);
  }
  if (colormesh.coname.equals("quattro formaggi")){
       fill(255,200,200,60);
       pl2 = new WB_Plane(0,0,colormesh.objectHeight/2,0,1,0);   
       render.draw(pl2,colormesh.objectHeight*1.3);
  } 
  
  }
 
  popMatrix();
  noLights();
  hint(DISABLE_DEPTH_TEST);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
public void mouseDragged() { //Handle mouse
  if( gui2.window(this).isMouseOver()) return;
   nav.dragged();
}
public void mouseReleased() { 
  nav.released();
}

public void mousePressed() { 
  nav.pressed();
}


public void mouseWheel(MouseEvent event) {
  float eWheel = event.getAmount();
  nav.wheeled(eWheel);
}

public void keyPressed() { // handle keyboard

 // NAVIGATION CONTROLS
  if (key == CODED) {
    if (keyCode == UP) {
       nav.keyUp();
    } else if (keyCode == DOWN) {
       nav.keyDown();
    } 
    else if (keyCode == LEFT) {
       nav.keyLeft();
    } 
    else if (keyCode == RIGHT) {
       nav.keyRight();
    } 
  }
  if(key=='.'){ // reset nav
      colormesh.getObjectDims();
      nav.autoscale(colormesh.objectHeight,colormesh.objectWidth,colormesh.objectDepth);
      nav.reset();
  }
  
  // FILE CONTROLS
  if(key=='s'){ // save stl file
    println("s");
     colormesh.saveStl();
  }
  if(key=='d'){ // save VRML file
    println("d");
     colormesh.rotateAboutAxis(radians(90), 0,0,0,0,0,-100);
     colormesh.flipAllFaces();
     colormesh.saveVRML();
     colormesh.flipAllFaces();
     colormesh.rotateAboutAxis(radians(90), 0,0,0,0,0,100);
  }
  if(key=='a'){ // save a screenshot + notes
     takeNote();
  }
  if(key=='z'){ // undo
     colormesh.undo();
     colormesh.selectAll();
     colormesh.getObjectDims();
  } 
  if(key=='o'){ // save a screenshot + notes
     selectInput("Select a file to corrupt or repair:", "openFile");
  }
  
  
  // ALGO CONTROLS
  if(key==ENTER){ // execute command
    background(230);
    colormesh.execute();
    colormesh.setColors();
    colormesh.moveToZero();
    colormesh.getObjectDims();
    colormesh.selectAll();
  }
  
  // OBJECT POSITIONING CONTROLS
  if(key=='§'){ // reverse direction of displace and rotate
    reversal = reversal * -1;
  }
  // DISPLACE XYZ
  if(key=='1'){  
     colormesh.moveSection(0,0,reversal);
     colormesh.getObjectDims();
  }
  if(key=='2'){ 
     colormesh.moveSection(reversal,0,0);
     colormesh.getObjectDims();
  }
  if(key=='3'){
     colormesh.moveSection(0,reversal,0);
     colormesh.getObjectDims();
  }
  // ROTATE XYZ
  if(key=='4'){
  colormesh.rotateAboutAxis(reversal*PI/20,0,0,0,0,0,1);  
  colormesh.getObjectDims();
  }
  if(key=='5'){
  colormesh.rotateAboutAxis(reversal*PI/20,0,0,0,1,0,0);  
  colormesh.getObjectDims();
  }
  if(key=='6'){
  colormesh.rotateAboutAxis(reversal*PI/20,0,0,0,0,1,0); 
  colormesh.getObjectDims(); 
  }

  // INTERFACE CONTROLS
  if(key=='l'){
    if (linesOn == true){
      linesOn = false;
    }
    else if (linesOn == false){
      linesOn = true;
    }
  }

  if(key=='h'){ //help
    if (help == true){
      help = false;
    }
    else if (help == false){
      help = true;
    }
  }

}

//---------------------------------------------------------//
void takeNote(){
    save("screenshots/" + DateUtils.timeStamp() + "image.png");  
    println("note taken");
    String[] output=new String[9];
    output[0] = "cc = " + cc;
    output[1] = "P1 = " + P1;
    output[2] = "P2 = " + P2;
    output[3] = "P3 = " + P3; 
    output[4] = "P4 = " + P4; 
    output[5] = "P5 = " + P5; 
    output[6] = "P6 = " + P6; 
    output[7] = "P7 = " + P7; 
    output[8] = "P8 = " + P8; 
    saveStrings("screenshots/" + DateUtils.timeStamp() + "notes.txt",output); 
}

void loadFiles(){
  String[] filenames;
   // find models for dropdown menu
  String path = sketchPath+"/importStls";
  filenames = listFileNames(path);
  //go through files
  int j=0;
  for (int i = 0; i < filenames.length; i++) { 
   //catch extension
   String type = filenames[i]; 
   type = type.substring(type.length() - 3, type.length());
   //count stls
   if((type.equals("stl"))||(type.equals("obj"))){
     j++;
   } 
  }
  stlnames = new String[j];
  println("stlnames.length = "+stlnames.length);
  int numModels = 0;
  for (int i = 0; i < filenames.length; i++) { 
    String type = filenames[i]; 
    type = type.substring(type.length() - 3, type.length());
    if((type.equals("stl"))||(type.equals("obj"))){
     print("stl found = ");
     String file = filenames[i];
     //file = file.substring(0, file.length() - 4);  // delete the .stl bit
     println(file); 
     stlnames[numModels] = file; 
     numModels++; 
   } 
  }  
}
// This function returns all the files in a directory as an array of Strings  
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}


void openFile(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    path =  selection.getAbsolutePath();
    
    String type = path.toLowerCase(); 
    type = type.substring(type.length() - 3, type.length());
    if(type.equals("stl")){
        
        colormesh = new Coformer(fromStl(path)); 
        //mesh = new SMesh(fromStl());
        nav.autoscale(colormesh.objectHeight,colormesh.objectWidth,colormesh.objectDepth);
        nav.reset();
//        meshSelected = true;
//        // find filename
//        String[] names = split(path, '/');
//        filename = names[names.length-1];
//        // generate new filename + path for save
//        newPathName = path.substring(0, path.length()-4) + "_"+ stage + ".stl";
//        newPathName2 = path.substring(0, path.length()-4) + "_"+ stage + "_s.png";   
    }
    else{
      println("User did not select a valid STL ");
    }    
    
  }
}

