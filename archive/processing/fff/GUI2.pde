// class of P5 in the colours of my choice
class ControlP52 extends ControlP5 { //class version with my color preferences built in
   ControlP52(processing.core.PApplet theParent){
     super(theParent);
     this.setColorBackground(color(180)); 
     this.setColorForeground(color(255));
     this.setColorValue(color(255));
     this.setColorActive(color(12,14,28));
     this.setColorLabel(color(100)); 
   }
}



class GuiCoformer extends ControlP52{
  int offx = 750;
  int offy = 50;
  GuiCoformer(processing.core.PApplet theParent){ //String models[]
     super(theParent);

   this.addSlider("co", // This slider chooses a color mode
    0,20, // min and max values
    co, // the default value
    offx+20,offy+385, // X,Y position of slider
    100,13). // width and height of slider
    setId(200).
    setColorBackground(color(220,100,0)); // set controller ID
    
   this.addSlider("X1", // name, must match variable name
    0,100, // min and max values
    X1, // the default value
    offx+20,offy+70, // X,Y position of slider
    100,13) // width and height of slider
    .setId(21); // set controller ID
    
   this.addSlider("Y1", // name, must match variable name
    0,100, // min and max values
    Y1, // the default value
    offx+20,offy+90, // X,Y position of slider
    100,13) // width and height of slider
    .setId(22); // set controller ID

   this.addSlider("Z1", // name, must match variable name
    0,100, // min and max values
    Z1, // the default value
    offx+20,offy+110, // X,Y position of slider
    100,13). // width and height of slider
    setId(23); // set controller ID
   
   this.addSlider("X2", // name, must match variable name
    0,100, // min and max values
    X2, // the default value
    offx+20,offy+135, // X,Y position of slider
    100,13). // width and height of slider
    setId(24); // set controller ID
    
   this.addSlider("Y2", // name, must match variable name
    0,100, // min and max values
    Y2, // the default value
    offx+20,offy+155, // X,Y position of slider
    100,13). // width and height of slider
    setId(25); // set controller ID
   
   this.addSlider("Z2", // name, must match variable name
    0,100, // min and max values
    Z2, // the default value
    offx+20,offy+175, // X,Y position of slider
    100,13). // width and height of slider
    setId(26); // set controller ID
    
   this.addSlider("S1", // name, must match variable name
    0,100, // min and max values
    S1, // the default value
    offx+20,offy+200, // X,Y position of slider
    100,13). // width and height of slider
    setId(27).
    setColorBackground(color(130)); // set controller ID
    
    this.addSlider("S2", // name, must match variable name
    0,100, // min and max values
    S2, // the default value
    offx+20,offy+220, // X,Y position of slider
    100,13). // width and height of slider
    setId(28).
    setColorBackground(color(130)); // set controller ID      
    
    // Selection
    this.addBang("sa", // select all
    offx+20,offy+255,13,13).
    setId(301).
    setColorForeground(color(255,255,40)); 
    
    this.addBang("sz", // select in z region
    offx+40,offy+255,13,13).
    setId(302).
    setColorForeground(color(255,255,210));   
  
    this.addBang("ct", // crop top
    offx+86,offy+255,13,13).
    setId(303).
    setColorForeground(color(0,240,240));      
     
    this.addBang("cb", // crop base
    offx+106,offy+255,13,13).
    setId(304).
    setColorForeground(color(110,100,85));  
    
     // Transforms
    this.addBang("tw", // twist
    offx+20,offy+285,13,13).
    setId(305).
    setColorForeground(color(100,40,230)); 
    
    this.addBang("ts", // twist sine
    offx+40,offy+285,13,13).
    setId(306).
    setColorForeground(color(150,240,150)); 
    
    this.addBang("sm", // smooth
    offx+60,offy+285,13,13).
    setId(307).
    setColorForeground(color(255,240,220));   
  
    this.addBang("d1", // divide 1 - planar
    offx+20,offy+315,13,13).
    setId(311).
    setColorForeground(color(255,200,200));      
     
    this.addBang("d2", // divide 2 - catmull-clark
    offx+40,offy+315,13,13).
    setId(312).
    setColorForeground(color(255,150,150));    
   
    this.addBang("d3", // divide 3 - fractal
    offx+60,offy+315,13,13).
    setId(313).
    setColorForeground(color(255,0,0));   
 
    this.addBang("cup", 
    offx+20,offy+345,13,13).
    setId(321).
    setColorForeground(color(255,245,230));      
     
    this.addBang("bel", 
    offx+40,offy+345,13,13).
    setId(322).
    setColorForeground(color(240,220,0));  
     
   
    this.addBang("trm", 
    offx+60,offy+345,13,13).
    setId(323).
    setColorForeground(color(255,200,30));   
    
    this.addBang("0", // divide 3 - fractal
    offx+106,offy+345+110,13,13).
    setId(500).
    setColorForeground(color(255));   
    
    this.addBang("A1", 
    offx+86,offy+315+110,13,13).
    setId(501).
    setColorForeground(color(190,190,120));   
    
    this.addBang("A2", 
    offx+106,offy+315+110,13,13).
    setId(502).
    setColorForeground(color(210,210,140)); 
    
    this.addBang("sc", // scale mode
    offx+106,offy+285,13,13).
    setId(308).
    setColorForeground(color(180));   
         
         
         
  }
}

