ArrayList<Lines> vectorField = new ArrayList<Lines>();
ArrayList<Interaction> interactionField = new ArrayList<Interaction>();
int lineSize = 10;
float interactDist = lineSize*0.65;
float boxsize = 0.1;

float VirusCoef = 0.15;
float recoveryCoeff = 0.05;

float viscosity = 0.01;
float IntCoeff = 0.001;
int w = 1040;
int h = 1040;
int mousePressedInt = 0;
int mousePressedPrev = 0;

// emulateMouse
boolean emulate = false;
boolean mousePressedBool = false;
float emulateMouseX;
float emulateMouseY;
float pemulateMouseX;
float pemulateMouseY;

float xoff = 0;
float yoff = 0;
float yinit = 0;
float index = 0;


import processing.pdf.*;

void setup() {
  noLoop();
  //fullScreen();
  size(1040,1040,P3D);
  background(255);
  for (int i = 0; i < w/lineSize; i++) {
    yoff += 0.05;
    for (int j = 0; j < h/lineSize; j++) {
      xoff += 0.005;
      //float rx = random(width);
      //float ry = random(height);
      float rx = -width*0.2 + noise(xoff,yoff)*width*1.4;
      float ry = -height*0.2 + noise(xoff+10,yoff+5)*height*1.4;
      if (sq(rx-w/2) + sq(ry - h/2) < sq(w/2)) {
        Lines l = new Lines(rx,ry);
        vectorField.add(l);
      } 
    }
    xoff = 0;
  }
  for (Lines l : vectorField) {
    for (Lines k : vectorField) {
      if (l.ax <= k.ax + interactDist && l.ax >= k.ax - interactDist && 
          l.ay <= k.ay + interactDist && l.ay >= k.ay - interactDist) {
            Interaction a = new Interaction(l,k);    
            interactionField.add(a);
          }
    }
  }
}

void draw() {
  //stroke(255);
 // beginRecord(PDF, "perlin-vector-10.pdf"); // Start recording to the file
  
  background(255);
  //lights();
  //camera(width/10*cos(index/512*PI*2),width/10*sin(index/512*PI*2),width*2/3,
 //        width/2,width/2,width/2,
  //       0,1,0);
  emulateMouse();
  if (mousePressedBool) {
    mousePressedInt = 1;
  } else {
    mousePressedInt = 0;
  }
  
  for (Lines l : vectorField) {
    //l.update();
    l.display();
  }
  
  for (Interaction I : interactionField) {
    //I.update(); 
    I.display();
  }
  yoff = yinit;
  noFill();
  //noStroke();
  //beginShape(TRIANGLE_STRIP);
  /*
  for (int i = 1; i < w/lineSize; i++) {
    yoff += 0.025;
    for (int j = 0; j < h/lineSize; j++) {
      xoff += 0.005;
      float rx = noise(xoff,yoff)*width;
      float ry = noise(xoff+10,yoff+5)*height;
      float c = noise(yinit);
      vectorField.get(i*j).ax = rx;
      vectorField.get(i*j).ay = ry;
      stroke(c*255,0,(1-c)*255);
      //vertex(noise(xoff,yoff)*width,noise(xoff+10,yoff+5)*height,noise(xoff+3,yoff+8)*height);      
      //vertex(noise(xoff,yoff-0.05)*width,noise(xoff+10,yoff+5-0.05)*height,noise(xoff+3,yoff+8-0.05)*height);
      
      line(vectorField.get(i*j).ax,vectorField.get(i*j).ay,vectorField.get((i-1)*j).ax,vectorField.get((i-1)*j).ay);
    }
    xoff = 0;
  }
  //endShape();
  //yinit = yinit+0.015;
  */

  mousePressedPrev = mousePressedInt;
  if (keyPressed) {
    if (key == ' ') {
      saveFrame("perlin_noise_strip_still-####.tiff");      
    }
    if (key == 'a') {
      yinit = yinit + 5;
    }
  }
  //saveFrame("perlin_noise_strip-####.tiff");
  index++;
  if (index > 512) index = 0;
  println(index);
  
 // endRecord();
}

class Lines {
  float ax,ay,dx,dy;
  float arot, arotspeedX,arotspeedY;
  color colorStroke = 255;
  float speedCoeff = 0.45;
  float gravity = 0.0;
  boolean mouseInteract;
  float Virus;
  float transmission;
  
  Lines(float x1, float y1) {
    ax = x1;
    ay = y1;
  }
  
  void update() {
    
    //if (mousePressedBool) {
    if (mousePressedInt - mousePressedPrev == 1) {  
      if (emulateMouseX < ax + lineSize/2 && emulateMouseX > ax - lineSize/2 && 
          emulateMouseY < ay + lineSize/2 && emulateMouseY > ay - lineSize/2) {        
          mouseInteract = true;
          Virus = 1;
          }
    }
    if (!mousePressedBool) {
      mouseInteract = false;
    }
    /*
    if (mouseInteract) {
      ax = emulateMouseX;
      ay = emulateMouseY;
    }
    */              
   Virus += transmission - Virus*recoveryCoeff;
   arotspeedX -= viscosity*arotspeedX;
   arotspeedY -= viscosity*arotspeedY;
   ax += arotspeedX;
   ay += arotspeedY;

  }
  
  void display() {
    float colorIntens = map((abs(arotspeedX)+abs(arotspeedX)),0,5,0,200);
    //float colorIntens = map(abs(arot),0,5,200,0);
    
    //colorStroke = color(map(ax,0,width,0,255),map(ax,width,0,0,255),colorIntens,255);
    colorStroke = color(Virus*55,10,Virus*255);
    fill(colorStroke);
    //strokeWeight(5);
    noStroke();
    //stroke(0,0,colorIntens);
    pushMatrix();
    translate(ax,ay);
    //translate(ax,ay,dx);
    //translate(dx,dy);
    rect(-boxsize*lineSize/2,-boxsize*lineSize/2,boxsize*lineSize,boxsize*lineSize);
    //ellipse(0,0,0.8*lineSize,0.8*lineSize);
    //line(-lineSize/2,0,lineSize/2,0);
    popMatrix();
  }
}



class Interaction {
  Lines l1;
  Lines l2;
  boolean transmission;

  float maxNoInteraction = lineSize/5;
  float modul;
  
  Interaction(Lines Line1, Lines Line2) {
    l1 = Line1;
    l2 = Line2;
  }
  
  void update() {
    if ((l1.Virus - l2.Virus) > 0.9) {   
      //l1.transmission = -VirusCoef*(l1.Virus - l2.Virus);
      l2.transmission = -VirusCoef*(l2.Virus - l1.Virus)*abs(l2.ax - l1.ax)/lineSize;
    }
    
    if ((l1.ax - l2.ax) > maxNoInteraction || (l1.ay - l2.ay) > maxNoInteraction) {
      
      l1.arotspeedX += IntCoeff*(l2.ax - l1.ax);
      l2.arotspeedX += IntCoeff*(l1.ax - l2.ax);
      l1.arotspeedY += IntCoeff*(l2.ay - l1.ay);
      l2.arotspeedY += IntCoeff*(l1.ay - l2.ay);
      
      //l1.arot += IntCoeff*(l2.dx - l1.dx);
      //l2.arot += IntCoeff*(l1.dx - l2.dx);
      }
    
  }
  
  void display() {
    modul = map(abs(l2.ax - l1.ax) + abs(l2.ay - l1.ay),0,30,0,200);
    //color colorStroke = color(l1.Virus*55,10,l1.Virus*255);    
    color colorStroke = color(modul,modul,modul);
    stroke(0);
    line(l1.ax,l1.ay,l2.ax,l2.ay);
    //beginShape();
    //vertex(l1.ax + l1.dx,l1.dy + l1.ay);
    //vertex(l2.ax + l2.dx,l1.dy + l1.ay);
    //endShape();
  }
}

void emulateMouse() {
  
  emulateMouseX = map(mouseX,0,width,0,width);
  emulateMouseY = map(mouseY,0,height,0,height);
  pemulateMouseX = map(pmouseX,0,width,0,width);
  pemulateMouseY = map(pmouseY,0,height,0,height);
  if (mousePressed) {
    mousePressedBool = true;
  } else {
    mousePressedBool = false;
  }

}