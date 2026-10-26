HEC_FromFacelist fromStl(String localpath) { 
  println("Start Build");
  WETriangleMesh wemesh = (WETriangleMesh) new STLReader().loadBinary(localpath, STLReader.WEMESH);
  //convert toxi mesh to a hemesh. Thanks to wblut for personally coding this part during #GX30
  int n=wemesh.getVertices().size();
  ArrayList<WB_Point3d> points=new ArrayList<WB_Point3d>(n);
  for (Vec3D v : wemesh.getVertices()) { 
      points.add(new WB_Point3d(v.x,v.y,v.z));
  }
  int[] toxiFaces=wemesh.getFacesAsArray();
  int nf=toxiFaces.length/3;
  int[][] faces=new int[nf][3];
  for(int i=0;i<nf;i++){
   faces[i][0]=toxiFaces[i*3];
   faces[i][1]=toxiFaces[i*3+1];
   faces[i][2]=toxiFaces[i*3+2]; 
  }
  HEC_FromFacelist ff=new HEC_FromFacelist().setVertices(points).setFaces(faces);
  return ff;
}



void appendMesh(){
  
  limbomesh.clear();
  limbomesh = colormesh.get();
  display_limbomesh = true;
  
  selectInput("Select a file to corrupt or repair:", "openFile");
  colormesh.getObjectDims();
  colormesh.selectAll();
  
}


void addMesh(){
   colormesh.add(limbomesh);
   display_limbomesh = false;
   colormesh.selectAll();
   colormesh.getObjectDims();
   colormesh.selectAll();
  
}
