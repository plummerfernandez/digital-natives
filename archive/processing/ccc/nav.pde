class Nav{
  
 //parameters
 boolean mouseDragged;
 float lastX, zoom, offsetX, offsetY, turn;
 int startX, startY;
 float initScale;
 int pressX, pressY;
 float initX, initTurn;
 
 //constructor
 Nav(int sx, int sy, float si){ //x dist from center, y dist from center, default scale
   startX = sx;
   startY = sy;
   initScale = si;
   mouseDragged = false;
   lastX=0;
   zoom=1;
   offsetY=0;
   offsetX=0;
   turn=0;
   initX=0;
   initTurn=0;
 }
 void autoscale(float h, float w, float d){
   
   float max = 0.0;
   float[] dims = new float[3];
   dims[0] = h;
   dims[1] = w;
   dims[2] = d;
   
   for(int x=0; x<3; x++){ 
      if(dims[x]>max){ 
            max = dims[x]; 
        } 
    } 
  
   // change initScale and startY to satisfy height of object.
   initScale = (100/max*4);
   startY = int(h*0.01*50);   
 }
 
 void display(){
   translate(width/2,height/2);
   scale(initScale, initScale, initScale*-1); 
   scale(zoom,zoom,zoom);
   rotateX(PI/2);
   //rotateZ(PI); // models were back to front
   translate(offsetX,0,offsetY);
  
   if(mouseDragged){
      lastX = (((mouseY-pressY+height/2)*-1.0f/height)*TWO_PI-PI)+initX;   
      turn =  (((mouseX-pressX+width/2)*-1.0f/width)*TWO_PI-PI)+initTurn;
   }
   rotateX(lastX);
   rotateZ(turn*-1);
   translate(startX,0,startY*-1);
 }
 
 void released(){
   mouseDragged=false;
 }
 void dragged(){
   mouseDragged=true;
 }
 void pressed(){
   pressX = mouseX;
   pressY = mouseY;
   initX = lastX;
   initTurn = turn;
 }
 void keyUp(){
   offsetY = offsetY+0.05;//1
 }
  void keyDown(){
   offsetY = offsetY-0.05;
 }
  void keyLeft(){
   offsetX = offsetX-0.05;
 }
  void keyRight(){
   offsetX = offsetX+0.05; //1
 }
  void reset(){
    lastX =0;
    zoom = 1;
    offsetX = 0;
    offsetY = 0;
    turn =0;
    initX = 0;
 } 
 void wheeled(float wheelAmount){
   zoom = zoom + wheelAmount/20;
  if(zoom < 0.4){
    zoom = 0.4;
  }
 }
 
}
