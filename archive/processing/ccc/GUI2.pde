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
  int offxc = 750; //150
  int offyc = 50;
  GuiCoformer(processing.core.PApplet theParent){ //String models[]
     super(theParent);

 
    
    // Selection
    this.addBang("cnt", // contrast
    offxc+20,offyc+255,13,13).
    setId(301).
    setColorForeground(color(200,200,200)); 
    
    this.addBang("sat", // saturate
    offxc+40,offyc+255,13,13).
    setId(302).
    setColorForeground(color(255,50,50)); 
    
    this.addBang("bri", // bright
    offxc+60,offyc+255,13,13).
    setId(303).
    setColorForeground(color(255,255,100));   
    // hues
    this.addBang("h-", // hue down
    offxc+20,offyc+285,13,13).
    setId(305).
    setColorForeground(color(150,150,255)); 
    
    this.addBang("h+", // hue up
    offxc+40,offyc+285,13,13).
    setId(306).
    setColorForeground(color(255,255,150)); 
    
    
    this.addBang("n1", // neighbour mode 1
    offxc+20,offyc+315,13,13).
    setId(311).
    setColorForeground(color(255,200,200));      
     
    this.addBang("n2", // neighbour mode 2
    offxc+40,offyc+315,13,13).
    setId(312).
    setColorForeground(color(255,150,150));    
   
  

 
    this.addBang("org", 
    offxc+20,offyc+345,13,13).
    setId(321).
    setColorForeground(color(255,245,230));      
     
    this.addBang("drk", 
    offxc+40,offyc+345,13,13).
    setId(322).
    setColorForeground(color(240,220,0));  
     
    this.addBang("map", 
    offxc+60,offyc+345,13,13).
    setId(323).
    setColorForeground(color(255,200,30));   
    
    this.addBang("0", // open
    offxc+106,offyc+345+110,13,13).
    setId(500).
    setColorForeground(color(255));   
    
    this.addBang("A1", 
    offxc+86,offyc+315+110,13,13).
    setId(501).
    setColorForeground(color(190,190,120));   
    
    this.addBang("A2", 
    offxc+106,offyc+315+110,13,13).
    setId(502).
    setColorForeground(color(210,210,140)); 
    
    this.addBang("subd", // scale mode
    offxc+106,offyc+285,13,13).
    setId(308).
    setColorForeground(color(180));   
    
    
    
    this.addSlider("cc", // This slider chooses a color mode
    0,35, // min and max values
    cc, // the default value
    offxc+20,offyc+385, // X,Y position of slider
    100,13). // width and height of slider
    setId(100).
    setColorBackground(color(220,100,0)); // set controller ID
    
   this.addSlider("P1", // name, must match variable name
    0,255, // min and max values
    P1, // the default value
    offxc+20,offyc+70, // X,Y position of slider
    100,13) // width and height of slider
    .setId(1); // set controller ID
    
   this.addSlider("P2", // name, must match variable name
    0,255, // min and max values
    P2, // the default value
    offxc+20,offyc+90, // X,Y position of slider
    100,13) // width and height of slider
    .setId(2); // set controller ID

   this.addSlider("P3", // name, must match variable name
    0,255, // min and max values
    P3, // the default value
    offxc+20,offyc+110, // X,Y position of slider
    100,13). // width and height of slider
    setId(3); // set controller ID
   
   this.addSlider("P4", // name, must match variable name
    0,255, // min and max values
    P4, // the default value
    offxc+20,offyc+135, // X,Y position of slider
    100,13). // width and height of slider
    setId(4); // set controller ID
    
   this.addSlider("P5", // name, must match variable name
    0,255, // min and max values
    P5, // the default value
    offxc+20,offyc+155, // X,Y position of slider
    100,13). // width and height of slider
    setId(5); // set controller ID
   
   this.addSlider("P6", // name, must match variable name
    0,255, // min and max values
    P6, // the default value
    offxc+20,offyc+175, // X,Y position of slider
    100,13). // width and height of slider
    setId(6); // set controller ID
    
   this.addSlider("P7", // name, must match variable name
    0,100, // min and max values
    P7, // the default value
    offxc+20,offyc+200, // X,Y position of slider
    100,13). // width and height of slider
    setId(7).
    setColorBackground(color(130)); // set controller ID
    
    this.addSlider("P8", // name, must match variable name
    0,100, // min and max values
    P8, // the default value
    offxc+20,offyc+220, // X,Y position of slider
    100,13). // width and height of slider
    setId(8).
    setColorBackground(color(130)); // set controller ID      
  }
         
         
         
  
}

