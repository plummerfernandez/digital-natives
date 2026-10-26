// All coloring algorithms are placed here 
// so face colors can be fetched by HE_MeshColor

class Algocolor {
  //Parameters
  float noisy;
  color c;
  int P1, P2, P3, P4, P5, P6, P7, P8, algo;
  //from object
  float objectDepth, objectHeight, objectWidth;
  String algoname;

  //constructor
  Algocolor(){
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
    algoname = "gradient original";
    c = color((fz/heightmap * P1)+P4+noisy,(fz/heightmap * P2)+P5+noisy,(fz/heightmap  * P3)+P6+noisy); 
    return c;

  }
}



