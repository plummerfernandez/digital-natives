// All coloring algorithms are placed here 
// so face colors can be fetched by HE_MeshColor

class Algocolor {
  //Parameters
  color oldColor, tempColor;
  float noisy;
  float radus, objectRadius;
  color c, cA, cB;
  int rred, ggreen, bblue;
  int P1, P2, P3, P4, P5, P6, P7, P8, algo;
  float redR, greenG, blueB;
  int prob;
  float noiseScale, PN;
  //from object
  float objectDepth, objectHeight, objectWidth;
  float fAmax, fAmin;
  String algoname;
  float fakefZ, faker;

  //constructor
  Algocolor(){
    oldColor = color(0,0,0);
    tempColor = color(0,0,0);
    P1 = 0;
    P2 = 240;
    P3 = 240;
    P4 = 110;
    P5 = 110;
    P6 = 85;
    P7 = 0;
    P8 = 0;
    algo = 2;
    objectDepth =20; 
    objectHeight=20;
    objectWidth =20;
    algoname = "#ccc";
  }
  void setObjectValues(float d, float h, float w, float Amin, float Amax){
    objectDepth = d;
    objectHeight = h;
    objectWidth = w;
    fAmax = Amax;
    fAmin = Amin;
    
  }
  
  void updateParameters(int Q1,int Q2,int Q3,int Q4,int Q5,int Q6,int Q7,int Q8){
    P1 = Q1;
    P2 = Q2;
    P3 = Q3;
    P4 = Q4;
    P5 = Q5;
    P6 = Q6;
    P7 = Q7;
    P8 = Q8;
  }


  color getFaceColor(float fx, float fy, float fz, float fa, int algo){ //provide face x,y,z coordinates
    noisy = random(P7)-random(P7);
    float heightmap = (objectHeight-(objectHeight * P8/100));
   
    switch(algo){
      
      
      case 35: // Unique Passengers gradient
          algoname = "unique passengers";
               /// HIGH SATURATION COLOR AT ONE END OF GRADIENT
          colorMode(HSB, 255);
          int hue1 = P1;
          int hue2 = P2;
          
          color c1 = color(hue1,P3,255);
          color c22 = color(hue2,P4,P5);
          colorMode(RGB,255);
          
          int c1Red = (int)red(c1);
          int c1Green = (int)green(c1);
          int c1Blue = (int)blue(c1);        
          int c2Red = (int)red(c22);
          int c2Green = (int)green(c22);
          int c2Blue = (int)blue(c22); 
          
          rred = int(map(fz, (objectHeight * P8/100), objectHeight, c2Red, c1Red));
          ggreen = int(map(fz, (objectHeight * P8/100), objectHeight, c2Green, c1Green));
          bblue = int(map(fz, (objectHeight * P8/100), objectHeight, c2Blue, c1Blue));
          c = color(rred+noisy, ggreen+noisy, bblue+noisy);
         
         return c;   
 
      
      case 34: // mapping heights 2
          algoname = "mapping 3 height2 v2";
          float noisy2 = 0; //random(100)-random(100);
          
          if(fz <= (objectHeight/2)){
          rred = int(map(fz, 0, objectHeight/2, P7, P4)+noisy2);
          ggreen = int(map(fz, 0, objectHeight/2, 0, P5)+noisy2);
          bblue = int(map(fz, 0, objectHeight/2, P8, P6)+noisy2);
          }
          else if(fz > (objectHeight/2)){
          rred = int(map(fz, objectHeight/2, objectHeight, P4, P1)+noisy2);
          ggreen = int(map(fz, objectHeight/2, objectHeight, P5, P2)+noisy2);
          bblue = int(map(fz, objectHeight/2, objectHeight, P6, P3)+noisy2);
          }
          
          c = color(rred, ggreen, bblue);
          return c;     
     
     
      case 33: // mapping heights 2
          algoname = "mapping 3 height2";
          
          if(fz <= (objectHeight/2)){
          rred = int(map(fz, 0, objectHeight/2, P7, P4));
          ggreen = int(map(fz, 0, objectHeight/2, 0, P5));
          bblue = int(map(fz, 0, objectHeight/2, P8, P6));
          }
          else if(fz > (objectHeight/2)){
          rred = int(map(fz, objectHeight/2, objectHeight, P4, P1));
          ggreen = int(map(fz, objectHeight/2, objectHeight, P5, P2));
          bblue = int(map(fz, objectHeight/2, objectHeight, P6, P3));
          }
          
          c = color(rred, ggreen, bblue);
          return c;     
     
      case 32: // mapping heights 2
          algoname = "mapping 2 height2";
          
          if(fz <= (objectHeight/2)){
          rred = int(map(fz, 0, objectHeight/2, P8, P4));
          ggreen = int(map(fz, 0, objectHeight/2, P8, P5));
          bblue = int(map(fz, 0, objectHeight/2, P8, P6));
          }
          else if(fz > (objectHeight/2)){
          rred = int(map(fz, objectHeight/2, objectHeight, P4, P1));
          ggreen = int(map(fz, objectHeight/2, objectHeight, P5, P2));
          bblue = int(map(fz, objectHeight/2, objectHeight, P6, P3));
          }
          
          c = color(rred, ggreen, bblue);
          return c;    
          
       case 31: // mapping radius
          algoname = "double mapper reverse";
           noisy2 = random(100)-random(100);
          radus = sqrt(pow(fx,2) + pow(fy,2)); //hacky radius estimations
          objectRadius = (objectWidth + objectDepth)/4; //hacky radius estimations
          
          redR = int(map(radus, objectRadius, (0.1),  P4, P1)+noisy2);
          greenG = int(map(radus, objectRadius,(0.1),  P5, P2)+noisy2);
          blueB = int(map(radus, objectRadius,(0.1),  P6, P3)+noisy2);
          
          rred = int(map(fz, (0.1), objectHeight, redR, P6)+noisy2);
          ggreen = int(map(fz, (0.1), objectHeight, greenG, P7)+noisy2);
          bblue = int(map(fz, (0.1), objectHeight, blueB, P8)+noisy2);
          
          c = color(rred, ggreen, bblue);
          return c;  
      
       
      case 30: // mapping radius
          algoname = "double mapper2";
          radus = sqrt(pow(fx,2) + pow(fy,2)); //hacky radius estimations
          objectRadius = (objectWidth + objectDepth)/4; //hacky radius estimations
          
          redR = int(map(radus, (0.1), objectRadius, P4, P1));
          greenG = int(map(radus, (0.1), objectRadius, P5, P2));
          blueB = int(map(radus, (0.1), objectRadius, P6, P3));
          
          rred = int(map(fz, (0.1), objectHeight, redR, P6));
          ggreen = int(map(fz, (0.1), objectHeight, greenG, P7));
          bblue = int(map(fz, (0.1), objectHeight, blueB, P8));
          
          c = color(rred, ggreen, bblue);
          return c;  
      
      case 29: // mapping radius
          algoname = "double mapper";
          radus = sqrt(pow(fx,2) + pow(fy,2)); //hacky radius estimations
          objectRadius = (objectWidth + objectDepth)/4; //hacky radius estimations
          
          redR = int(map(radus, (objectRadius * P8/100), objectRadius, P4, P1));
          greenG = int(map(radus, (objectRadius * P8/100), objectRadius, P5, P2));
          blueB = int(map(radus, (objectRadius * P8/100), objectRadius, P6, P3));
          
          rred = int(map(fz, (objectHeight * P8/100), objectHeight, redR, P1));
          ggreen = int(map(fz, (objectHeight * P8/100), objectHeight, greenG, P2));
          bblue = int(map(fz, (objectHeight * P8/100), objectHeight, blueB, P3));
          
          c = color(rred+noisy, ggreen+noisy, bblue+noisy);
          return c;
      
      case 28: // mapping radius and height
          algoname = "mapping radius and height";
          radus = sqrt(pow(fx,2) + pow(fy,2)); //hacky radius estimations
          objectRadius = (objectWidth + objectDepth)/4; //hacky radius estimations
          //c = color((radus/objectRadius * P1)+P4+noisy,(radus/objectRadius * P2)+P5+noisy,(radus/objectRadius * P3)+P6+noisy); 
          //c = color((fz/objectHeight * P1)+P4+noisy,(radus/objectRadius * P2)+P5+noisy,(radus/objectRadius * P3)+P6+noisy); 
          rred = int(map(fz, (objectHeight * P8/100), objectHeight, P4, P1));
          ggreen = int(map(radus, (objectRadius * P8/100), objectRadius, P5, P2));
          bblue = int(map(radus, (objectRadius * P8/100), objectRadius, P6, P3));
          c = color(rred, ggreen, bblue);
          return c;
          
      case 27: // mapping radius
          algoname = "mapping radius";
          radus = sqrt(pow(fx,2) + pow(fy,2)); //hacky radius estimations
          objectRadius = (objectWidth + objectDepth)/4; //hacky radius estimations
          //c = color((radus/objectRadius * P1)+P4+noisy,(radus/objectRadius * P2)+P5+noisy,(radus/objectRadius * P3)+P6+noisy); 
          rred = int(map(radus, (objectRadius * P8/100), objectRadius, P4, P1));
          ggreen = int(map(radus, (objectRadius * P8/100), objectRadius, P5, P2));
          bblue = int(map(radus, (objectRadius * P8/100), objectRadius, P6, P3));
          c = color(rred+noisy, ggreen+noisy, bblue+noisy);
          return c;
          
      case 26:
          algoname = "unique visitor";
          fakefZ = random(-10,objectHeight);
          faker = fakefZ/heightmap;
          
          if(fz > (objectHeight/2) ){
            
            
             c1 = color((fz/heightmap * P1)+P4+noisy,(fz/heightmap * P2)+P5+noisy,(fz/heightmap  * P3)+P6+noisy); 
            color c2 = color((faker * P1)+P4+noisy,(faker * P2)+P5+noisy,(faker  * P3)+P6+noisy); 
            float lerpAmount = map(fz,objectHeight,(objectHeight/2),0,1);
            color c = lerpColor(c1, c2, lerpAmount);
            return c;
          }
          else{
            c = color((faker * P1)+P4+noisy,(faker * P2)+P5+noisy,(faker  * P3)+P6+noisy); 
            return c;
          }
      
      case 25:
          algoname = "officer dapples";
          fakefZ = random(-5,objectHeight);
          faker = fakefZ/heightmap;
          c = color((faker * P1)+P4+noisy,(faker * P2)+P5+noisy,(faker  * P3)+P6+noisy); 
          return c;
          
      case 24: // mapping + area
          algoname = "3D mapping + perlin, radus";
          noiseScale= P7 * 0.003;
          PN = 1.2* map(noise(fx*noiseScale, fy*noiseScale, fz*noiseScale), 0, 1, -130, 130);
          
          radus = sqrt(pow(fx,2) + pow(fy,2)); //hacky radius estimations
          objectRadius = (objectWidth + objectDepth)/4; //hacky radius estimations
          //c = color((fz/objectHeight * P1)+P4+noisy,(radus/objectRadius * P2)+P5+noisy,(radus/objectRadius * P3)+P6+noisy); 
          
          rred = int(map(fz+(fa*0.1), 0, (objectHeight * P8/100)+(fAmax*0.1), P4, P1));
          ggreen = int(map(fa, 0,fAmax, P5, P2));
          bblue =  int(map(fz, (objectHeight * P8/100), objectHeight, P6, P3)); 
          
          c = color(rred+int(PN), radus/objectRadius * ggreen+int(PN), radus/objectRadius * bblue+int(PN));
          return c;  
      
      case 23: // mapping + area
          algoname = "3D mapping + perlin, nutty2";
          noiseScale= P7 * 0.003;
          PN = 1.2* map(noise(fx*noiseScale, fy*noiseScale, fz*noiseScale), 0, 1, -130, 130);
          
          //radus = sqrt(pow(fx,2) + pow(fy,2)); //hacky radius estimations
          //objectRadius = (objectWidth + objectDepth)/4; //hacky radius estimations
          //c = color((fz/objectHeight * P1)+P4+noisy,(radus/objectRadius * P2)+P5+noisy,(radus/objectRadius * P3)+P6+noisy); 
          
          rred = int(map(fz+(fa*0.1), 0, (objectHeight * P8/100)+(fAmax*0.1), P4, P1));
          ggreen = int(map(fa, 0,fAmax, P5, P2));
          bblue =  int(map(fz, (objectHeight * P8/100), objectHeight, P6, P3)); 
          
          c = color(rred+int(PN), ggreen+int(PN), bblue+int(PN));
          return c;  
          
      case 22: // mapping + area
          algoname = "3D mapping + perlin - nuts";
          noiseScale= P7 * 0.003;
          PN = 1.2* map(noise(fx*noiseScale, fy*noiseScale, fz*noiseScale), 0, 1, -130, 130);
          
          rred = int(map(fz+(fa*0.1), 0, (objectHeight * P8/100)+(fAmax*0.1), P4, P1));
          ggreen = int(map(fa, 0,fAmax, P5, P2));
          bblue =  (int(map(fa, 0,fAmax, P5, P2)) + int(map(fz, (objectHeight * P8/100), objectHeight, P6, P3)))/2; 
          
          c = color(rred+int(PN), ggreen+int(PN), bblue+int(PN));
          return c;  
          
      case 21: // mapping + area
          algoname = "3D mapping + perlin2";
          noiseScale= P7 * 0.005;
          PN = 1.5* map(noise(fx*noiseScale, fy*noiseScale, fz*noiseScale), 0, 1, -130, 130);
          
          rred = int(map(fz+(fa*0.1), 0, (objectHeight * P8/100)+(fAmax*0.1), P4, P1));
          ggreen = int(map(fa, 0,fAmax, P5, P2));
          bblue =  int(map(fz, (objectHeight * P8/100), objectHeight, P6, P3)); 
          
          c = color(rred+int(PN), ggreen+int(PN), bblue+int(PN));
          return c;     
      
      case 20: // mapping + area + perlin + everything
          algoname = "3D mapping + perlin";
          noiseScale= P7 * 0.005;
          PN = map(noise(fx*noiseScale, fy*noiseScale, fz*noiseScale), 0, 1, -130, 130);
          
          rred = int(map(fz+(fa*0.5), 0, (objectHeight * P8/100)+(fAmax*0.5), P4, P1));
          ggreen = int(map(fz+(fa*0.5), 0, (objectHeight * P8/100)+(fAmax*0.5), P5, P2));
          bblue = int(map(fz+(fa*0.5), 0, (objectHeight * P8/100)+(fAmax*0.5), P6, P3));
          
          c = color(rred+int(PN), ggreen+int(PN), bblue+int(PN));
          return c; 
      
      case 19: // mapping + area
          algoname = "3D mapping area 3";
          rred = int(map(fa, 0, fAmax, P4, P1));
          ggreen = int(map(fz, (objectHeight * P8/100), objectHeight, P5, P2));
          bblue =  int(map(fz+(fa*0.05)*(fa*0.01), (objectHeight * P8/100), objectHeight+(fAmax*0.05)*(fAmax*0.01), P6, P3));
          c = color(rred+noisy, ggreen+noisy, bblue+noisy);
          return c;    
      
      case 18: // mapping + area
          algoname = "3D mapping area 2";
          rred = int(map(fz+(fa*0.1), 0, (objectHeight * P8/100)+(fAmax*0.1), P4, P1));
          ggreen = int(map(fa, 0,fAmax, P5, P2));
          bblue =  int(map(fz, (objectHeight * P8/100), objectHeight, P6, P3)); 
          c = color(rred+noisy, ggreen+noisy, bblue+noisy);
          return c;     
      
      case 17: // mapping + area
          algoname = "3D mapping area";
          noiseScale= P7 * 0.003;
          PN = 1.2* map(noise(fx*noiseScale, fy*noiseScale, fz*noiseScale), 0, 1, -130, 130);
          
          rred = int(map(fz, (objectHeight * P8/100), objectHeight, P4, P1));
          ggreen = int(map(fz+(fa*0.1), 0, (objectHeight * P8/100)+(fAmax*0.1), P5, P2));
          bblue = int(map(fa, 0,fAmax, P6, P3));
          c = color(rred+int(PN), ggreen+int(PN), bblue+int(PN));
          return c;         
                   
      case 16: // mapping + area
          algoname = "mapping area^2";
          noiseScale= P7 * 0.003;
          PN = 1.2* map(noise(fx*noiseScale, fy*noiseScale, fz*noiseScale), 0, 1, -130, 130);
          rred = int(map(fz+(fa*0.05)*(fa*0.01), (objectHeight * P8/100), objectHeight+(fAmax*0.05)*(fAmax*0.01), P4, P1));
          ggreen = int(map(fz+(fa*0.05)*(fa*0.01), (objectHeight * P8/100), objectHeight+(fAmax*0.05)*(fAmax*0.01), P5, P2));
          bblue = int(map(fz+(fa*0.05)*(fa*0.01), (objectHeight * P8/100), objectHeight+(fAmax*0.05)*(fAmax*0.01), P6, P3));
          c = color(rred+int(PN), ggreen+int(PN), bblue+int(PN));
          return c;   
      
      case 15: // mapping area+height
          algoname = "mapping area+height";
          if(P7 > 0){
            noiseScale= P7 * 0.003;
            PN = 1.2* map(noise(fx*noiseScale, fy*noiseScale, fz*noiseScale), 0, 1, -130, 130);
           }else{
             PN = 0;
           }
          
          rred = int(map(fz+(fa*0.5), 0, (objectHeight * P8/100)+(fAmax*0.5), P4, P1));
          ggreen = int(map(fz+(fa*0.5), 0, (objectHeight * P8/100)+(fAmax*0.5), P5, P2));
          bblue = int(map(fz+(fa*0.5), 0, (objectHeight * P8/100)+(fAmax*0.5), P6, P3));
          //c = color(rred+int(PN), ggreen+int(PN), bblue+int(PN));
          c = color(rred+noisy, ggreen+noisy, bblue+noisy);
          return c;        
      
      case 14: // mapping area only
          algoname = "mapping area only";
          noiseScale= P7 * 0.003;
          PN = 1.2* map(noise(fx*noiseScale, fy*noiseScale, fz*noiseScale), 0, 1, -130, 130);
          
          rred = int(map(fa, 0, fAmax, P4, P1));
          ggreen = int(map(fa, 0,fAmax, P5, P2));
          bblue = int(map(fa, 0,fAmax, P6, P3));
          c = color(rred+noisy, ggreen+noisy, bblue+noisy);
          //c = color(rred+int(PN), ggreen+int(PN), bblue+int(PN));
          return c;  
      
      case 13: // mapping height
          algoname = "mapping height";
          rred = int(map(fz, (objectHeight * P8/100), objectHeight, P4, P1));
          ggreen = int(map(fz, (objectHeight * P8/100), objectHeight, P5, P2));
          bblue = int(map(fz, (objectHeight * P8/100), objectHeight, P6, P3));
          c = color(rred+noisy, ggreen+noisy, bblue+noisy);
          return c;    
              
      
      case 12: // HSB color mode
          algoname = "HSB color lerp";
          colorMode(HSB, 255, 255, 255);
          cA = color(P1+(fz/objectHeight * P2), 245,255);
          cB  = color(P4+(fz/objectHeight * P5), P6+(fz/objectHeight),255-noisy);
          colorMode(RGB,255);
          c = lerpColor(cA, cB, 0.5);
          colorMode(RGB,255);
          return c;    
  
      
      case 11: // HSB color mode
          algoname = "HSB color";
          colorMode(HSB, 255, 255, 255);
          c = color(P1+(fz/objectHeight * P2), P3+(fz/objectHeight * P4),P5+(fz/objectHeight * P6)-noisy);
          colorMode(RGB,255);
          return c;    
      
      
      case 10: // algo determined by face area
          algoname = "face area";
          c = color((fa/fAmax * P1)+P4 +noisy,(fa/fAmax * P2)+P5+noisy,(fa/fAmax * P3)+P6+noisy); 
          return c;
          
      
      case 9: //complex glitchy algo of gradient + face swapping
          algoname = "complex face swapper";
          
          redR = (fz/(objectHeight) * P1)+P4+noisy;
          if (redR > 254){redR = 254;}
          greenG = (fz/(objectHeight)  * P2)+P5+noisy;
          if (greenG > 254){greenG = 254;}
          blueB = (fz/(objectHeight)  * P3)+P6+noisy;
          if (blueB > 254){blueB = 254;}
          c = color(redR,greenG,blueB); 
          
          prob = int(random(100));
          if(prob>P7){ 
            redR = (fz/(objectHeight*3) * P1)+P4+noisy;
            if (redR > 254){redR = 254;}
            greenG = (fz/(objectHeight*3)  * P2)+P5+noisy;
            if (greenG > 254){greenG = 254;}
            blueB = (fz/(objectHeight*3)  * P3)+P6+noisy;
           if (blueB > 254){blueB = 254;}
           c = color(redR,greenG,blueB); 
           }
          prob = int(random(100));
          if(prob>P7){ 
            tempColor = oldColor;
            oldColor = c;
            c = tempColor;
           }
          return c;
          
       case 8: //perlin noise algo
          algoname = "perlin noise";
          noiseScale= P7 * 0.002;
          PN = map(noise(fx*noiseScale, fy*noiseScale, fz*noiseScale), 0, 1, -130, 130);
          c = color((fz/objectHeight * P1)+P4+int(PN),(fz/objectHeight * P2)+P5+int(PN),(fz/objectHeight * P3)+P6+int(PN)); 
          return c; 
          
       case 7: // darker gradients using subtraction
          algoname = "darker gradients";
          c = color((fz/heightmap * P1)-P4+noisy,(fz/heightmap * P2)-P5+noisy,(fz/heightmap * P3)-P6+noisy); 
          return c;
        
       case 6: // radius stuff
          algoname = "radius stuff2";
          radus = sqrt(pow(fx,2) + pow(fy,2)); //hacky radius estimations
          objectRadius = (objectWidth + objectDepth)/4; //hacky radius estimations
          c = color((fz/objectHeight * P1)+P4+noisy,(radus/objectRadius * P2)+P5+noisy,(radus/objectRadius * P3)+P6+noisy); 
          return c;
     
       case 5: // radius stuff
          algoname = "radius stuff1";
          radus = sqrt(pow(fx,2) + pow(fy,2)); //hacky radius estimations
          objectRadius = (objectWidth + objectDepth)/4; //hacky radius estimations
          c = color((radus/objectRadius * P1)+P4+noisy,(radus/objectRadius * P2)+P5+noisy,(radus/objectRadius * P3)+P6+noisy); 
          return c;
     
       case 4: // gradient in x - direction
          algoname = "side gradient";
          rred = int(map(fx, (objectDepth), ((objectDepth * P8/100)), P4, P1));
          ggreen = int(map(fx, (objectDepth), ((objectDepth * P8/100)), P5, P2));
          bblue = int(map(fx, (objectDepth), ((objectDepth * P8/100)), P6, P3));
          c = color(rred+noisy, ggreen+noisy, bblue+noisy);
          return c;
     
    
       case 3: //some faces gradient ahead of the other
          algoname = "faces ahead"; 
          if(int(random(100)) >= 90){
             c = color((fz/objectHeight * P1)+P4+noisy,(fz/objectHeight * P2)+P5+noisy,(fz/objectHeight * P3)+P6+noisy); 
             return c;
          }
          else{
             c = color((fz/(heightmap*1.3) * P1)+P4+noisy,(fz/(heightmap*1.3) * P2)+P5+noisy,(fz/(heightmap*1.3) * P3)+P6+noisy);
             return c;
          }
    
       case 2: // Classic gradient with noise
          algoname = "gradient original";
          c = color((fz/heightmap * P1)+P4+noisy,(fz/heightmap * P2)+P5+noisy,(fz/heightmap  * P3)+P6+noisy); 
          return c;
          
       case 1: // Cyan Dapple
          algoname = "cyan dapple";
      
          c = color(random(255)+noisy,random(255)+noisy,255+noisy);
          
          redR = random(255)+noisy;
          if (redR > 255){redR = 255;}
          greenG = random(255)+noisy;
          if (greenG > 255){greenG = 255;}
          blueB = 255+noisy;
          if (blueB > 255){blueB = 255;}
          
          c = color(redR,greenG,blueB); 
          
          
          //c = color(255,255,random(100));
          return c;
       
        case 0: // white
          algoname = "white";
          c = color(255,255,255);
          return c;
     
    
       default: // go all white
          colorMode(RGB,255);
          c = color(255,255,255); 
          return c;
         
     }
  
    
  }
}



