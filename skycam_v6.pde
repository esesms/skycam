// This is a final version of the file

// libraries for detecting blobs and printing them out
import blobDetection.*;
import processing.pdf.*;
import java.util.Calendar;
import java.util.TimeZone;
//import com.hamoid.*;
//VideoExport videoExport;

// stuff for loading in the sky images
int city_no = 435;
String city_name = "New Mexico";
int trail = 6;
int image_num = 0;
String[] imageNames = new String[6];
PImage[] frames = new PImage[imageNames.length];
PImage[] section = new PImage[imageNames.length];

//date and time values
int day;    // Values from 1 - 31
int month;  // Values from 1 - 12
int year;
int hour;
int minute;
int second;
Calendar c;

// section variables and multiplier
float m = 3.4;
int sectionx = 180;
int sectiony = 180;

// general counting
int num = 0;
int whichFrame = 0;
int nextTimer = 0;
int delay = 2000;
int counter = 0;
int pastFrame;
boolean drawPDF;
int currentMillis = 0;
int pastMillis = 0;
int timeDifference = 0;
int randFrame;

// for text scroll
int x = 1024;
float yrand;
String[] result = null;
String[] new_result = new String[3];
boolean ln1_compare, ln2_compare, ln3_compare;

// for text
float txt_width;
PFont sky_font;
String[] html_code = {"&#39;", "&amp;"};
String[] plain_txt = {"'", "&"};
PFont pdf_font;

// blob draw and print to pdf variables
BlobDetection theBlobDetection;
PGraphics img;
PGraphics pdf;
PImage skyimg;
float blobThreshold = 0.0;

// for loop counters
int i = 0;
int j = 0;
int p = 0;
int q = 0;

//EdgeVertex past_eA, past_eB;

void setup() {
    // Load image from a web server

  for (i = 0; i < trail; i=i+1) {
    if (i == 0) {
      imageNames[i] = "http://www.allskycam.com/u/" + str(city_no) + "/latest_full.jpg";
      println(imageNames[i]);
      if(loadImage(imageNames[i]) != null){
        frames[i] = loadImage(imageNames[i]);
        if(frames[i] != null){
          section[i] = frames[i].get(sectionx, sectiony, int(1024/m), int(600/m)); // crop the image // decrease the width and height if i want to crop more
        }
      }else{
        // in case it is unable to load in an image from online, load one from folder
        frames[i] = loadImage("assets/latest_full.jpg");
        section[i] = frames[i].get(sectionx, sectiony, int(1024/m), int(600/m)); // crop the image // decrease the width and height if i want to crop more
      }
    }else {
      image_num = i + 1;
      imageNames[i] = "http://www.allskycam.com/u/" + str(city_no) + "/latest_full"+ str(image_num) + ".jpg";
      println(imageNames[i]);
      if(loadImage(imageNames[i]) != null){
        frames[i] = loadImage(imageNames[i]);
        if(frames[i] != null){
          section[i] = frames[i].get(sectionx, sectiony, int(1024/m), int(600/m)); // crop the image
        }
      }else{
        frames[i] = loadImage("assets/latest_full" + str(image_num) + ".jpg");
        section[i] = frames[i].get(sectionx, sectiony, int(1024/m), int(600/m)); // crop the image // decrease the width and height if i want to crop more
      }
    }
  }
  
  img = createGraphics(1024, 600);
  //pdf = createGraphics(1024, 600, PDF, "cloudprints/output"+ num + ".pdf");
  
  // Screen size
  //size(1024, 600);
  fullScreen(1);
  
  // code to export a video
  /*
  videoExport = new VideoExport(this);
  videoExport.startMovie();
  */

  sky_font = loadFont("Monaco-48.vlw");
  
  pdf_font = createFont("Futura", 8);
  textFont(pdf_font);

  println("Section length is " + section.length);
}

void draw() {
  background(255);
  
  // refreshes images in 2 second segment every 1 minutes
  if((millis())%60000 > 59000 || (millis())%60000 < 1000){
    for (i = 0; i < trail; i=i+1) {
      if (i == 0) {
        imageNames[i] = "http://www.allskycam.com/u/" + str(city_no) + "/latest_full.jpg";
        println(imageNames[i]);
        if(loadImage(imageNames[i]) != null){
          frames[i] = loadImage(imageNames[i]);
          section[i] = frames[i].get(sectionx, sectiony, int(1024/m), int(600/m)); // crop the image // decrease the width and height if i want to crop more
        }
    } else {
        image_num = i + 1;
        imageNames[i] = "http://www.allskycam.com/u/" + str(city_no) + "/latest_full"+ str(image_num) + ".jpg";
        println(imageNames[i]);
        if(loadImage(imageNames[i]) != null){
          frames[i] = loadImage(imageNames[i]);
          section[i] = frames[i].get(sectionx, sectiony, int(1024/m), int(600/m)); // crop the image
        }
      }
    }
  }
  
  if(section[whichFrame] != null){
    theBlobDetection = new BlobDetection(section[whichFrame].width, section[whichFrame].height);
    theBlobDetection.setPosDiscrimination(false);
    theBlobDetection.setThreshold(blobThreshold);
    println("---Blob threshold currently set at", nf(blobThreshold, 1, 1));
    theBlobDetection.computeBlobs(section[whichFrame].pixels);
   
    //resizes the image
    //frames[whichFrame].resize(round(768*2.5), round(576*2.5));
    
    section[whichFrame].resize(1024, 600);
    //section[whichFrame].resize(4000, 3000);
    
    //draws the image
    image(section[whichFrame], 0, 0);
  }
  
  EdgeVertex[] edges = drawBlobsAndEdges(false, true);
  
  //draws the blob
  image(img, 0, 0);
  
  // checks if enough time has passed
  // since we last changed the frame and we
  // need to do it again.
  
  if (millis() > nextTimer) {
    whichFrame = whichFrame + 1;
    println("---whichFrame is " + whichFrame);
    if (whichFrame >= section.length) {
      whichFrame = 0;
      println("---whichFrame is " + whichFrame);
      counter ++;
      println("---counter is " + counter);
      randFrame = int(random(0,5));
      println("---randFrame is " + randFrame);
      currentMillis = millis();
      timeDifference = currentMillis - pastMillis;
      pastMillis = currentMillis;
      println("---time difference " + timeDifference);
    }
    // reset the timer for the next frame.
    nextTimer = millis() + delay;
  }

  // If there is no result currently
  if (result==null) {
    println("Array is null");

    // Run the python code HERE

    // Loads in a poem from the text file
    if(loadStrings("http://esems.pythonanywhere.com/poem1") != null){
      if ((loadStrings("http://esems.pythonanywhere.com/poem1").length) > 0) {
        result = loadStrings("http://esems.pythonanywhere.com/poem1");
        println("Loaded result");
        //go through each loaded line and check if there are any special chars to replace
        for(p = 0; p < 3; p++){
          for(q = 0; q < html_code.length; q++){
            if(result[p].contains(html_code[q])){
              result[p] = result[p].replace(html_code[q], plain_txt[q]);
              //println("--", new_result[p]);
            }
          }
        }
      } else {
        println("No length");
      }
    }

    textFont(sky_font);
    noStroke();
    fill(0, 255, 0);

    yrand = random(30, 570);
    println("Random Y is", yrand);
    textSize(50);
    if(result != null){
      text(result[0] + " / " + result[1] + " / " + result[2], x, yrand);
      x = x-1;
    }
  } else {

    // If there is an existing result
    println("Array is not null");

    // If there is a file, loads in a poem from the text file. Otherwise, states that the file does not exist.
    printArray(new_result);

    if(loadStrings("http://esems.pythonanywhere.com/poem1") != null){
      if ((loadStrings("http://esems.pythonanywhere.com/poem1").length) > 0) {
        println(loadStrings("http://esems.pythonanywhere.com/poem1").length);
        new_result = loadStrings("http://esems.pythonanywhere.com/poem1");
        println("Loaded new result");
        //go through each loaded line and check if there are any special chars to replace
        if(new_result.length > 0){
          for(p = 0; p < 3; p++){
            for(q = 0; q < html_code.length; q++){
              if(new_result[p].contains(html_code[q])){
                new_result[p] = new_result[p].replace(html_code[q], plain_txt[q]);
                
              }
            }
          }
        }
      } else {
        println("No length");
      }
    }
    
    if(new_result.length > 0){
      // Check if the new poem matches the existing poem in the result array
      ln1_compare = new_result[0].equals(result[0]);
      println("Check 1");
      ln2_compare = new_result[1].equals(result[1]);
      println("Check 2");
      ln3_compare = new_result[2].equals(result[2]);
      println("Check 3");
    

      // Get text width
      txt_width = textWidth(result[0]);
      txt_width = txt_width + textWidth(result[1]);
      txt_width = txt_width + textWidth(result[2]);

      // If the new result is equal to the past result then output the same text
      if (ln1_compare == true && ln2_compare == true && ln3_compare == true || x > -(txt_width)) {
        println("Results are equal or poem is scrolling");
        println("x is", x);
        println("y is", yrand);
        textFont(sky_font);
        noStroke();
        //blendMode(ADD);
        fill(0, 255, 0, 170);
        text(result[0] + " / " + result[1] + " / " + result[2], x, yrand);
        //blendMode(BLEND);
        x = x-1;
      } else {
  
        // Otherwise, replace with the new poem and reset x
        println("Results are not equal or poem has completed scroll");
        arrayCopy(new_result, result);
        yrand = random(30, 570);
        println("y is", yrand);
        x = 1024;
      }
    }
  }
//code to export video
//videoExport.saveFrame();
}

EdgeVertex[] drawBlobsAndEdges(boolean drawBlobs, boolean drawEdges)
{
  // this section sets the blobs on an img layer
  img.beginDraw();
  img.noFill();
   
  //10 count in 1 minute? 120 count is approximately 1.5 hours
  if(counter % 30 == 0 && counter != 0){
    println("---Counter in the function is ", counter);
    if(pastFrame != whichFrame && randFrame == whichFrame){
      drawPDF = true;
      println("---" + city_no + nf(year) + nf(month, 2) +nf(day, 2) + nf(hour, 2) + nf(minute, 2) + nf(second, 2) + "-SUE_HUANG.pdf");
      printImage("/Users/suehuang/Documents/Processing/skycam_v6/cloudprints/" + city_no + nf(year) + nf(month, 2) +nf(day, 2) + nf(hour, 2) + nf(minute, 2) + nf(second, 2) + "-SUE_HUANG.pdf");
      println("---pastFrame in the function is ", pastFrame);
      println("---whichFrame in the function is ", whichFrame);
      println("---randFrame in the function is ", randFrame);
      pastFrame = whichFrame;
      if(counter > 30){
        num++;
      }
    }
    
  }else{
    drawPDF = false;
  }
  
  Blob b;
  EdgeVertex eA, eB;

  EdgeVertex[] edges = new EdgeVertex[2];
  if(theBlobDetection != null){
    println("There is a blob");
    for (int n=0 ; n<theBlobDetection.getBlobNb() ; n++)
    {
      b=theBlobDetection.getBlob(n);
      if (b!=null && b.w*width > 100) // if the blob has a width bigger than 200
      {
        println("There is a big blob");
        // if the blob is bigger than 100 width than, create a pdf to capture it
        if(drawPDF == true){
          
          //get the calendar info
          c = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
          year = c.get(Calendar.YEAR);
          month = c.get(Calendar.MONTH) + 1;
          day = c.get(Calendar.DAY_OF_MONTH);
          hour = c.get(Calendar.HOUR_OF_DAY);
          minute = c.get(Calendar.MINUTE);
          second = c.get(Calendar.SECOND);
          
          textFont(pdf_font);
          
          println("---Drawing the cloud...");
          pdf = createGraphics(1024, 600, PDF, "cloudprints/" + city_no + nf(year) + nf(month, 2) +nf(day, 2) + nf(hour, 2) + nf(minute, 2) + nf(second, 2) + "-SUE_HUANG.pdf");
          
 
          
          pdf.beginDraw();
          
          //text on PDF
          pdf.fill(0);
          
          pdf.pushMatrix();
          //vertical text
          /*
          pdf.translate(974, 300);
          pdf.rotate(-HALF_PI);
          */
          pdf.translate(799, 570);
          pdf.textSize(6);
          pdf.text("IN_THE_TIME_OF_CLOUDS-" + city_no + nf(year) + nf(month, 2) +nf(day, 2) + nf(hour, 2) + nf(minute, 2) + nf(second, 2) + "-SUE_HUANG", 0, 0);
          pdf.popMatrix();
          
          
          pdf.noFill();
          pdf.strokeWeight(1);
          pdf.stroke(0, 0, 0);
        }
        // Edges
        if (drawEdges){
          if(counter % 10 == 0){
            img.strokeWeight(.01);
            img.stroke(255, 255, 255, 10);
          }else{
            img.noStroke();
          }
          for (int m=0;m<b.getEdgeNb();m++){
            eA = b.getEdgeVertexA(m);
            edges[0] = eA;
            eB = b.getEdgeVertexB(m);
            edges[1] = eA;
            if (eA !=null && eB !=null){
              img.line(
                eA.x*width, eA.y*height, 
                eB.x*width, eB.y*height
                );
              if(drawPDF == true){
                pdf.line(
                  eA.x*width, eA.y*height, 
                  eB.x*width, eB.y*height
                  );
              }
            }
          }
        }

        
        // Blobs
        if (drawBlobs)
        {
          img.strokeWeight(1);
          img.stroke(255, 0, 0);

          img.rect(
            b.xMin*width, b.yMin*height, 
            b.w*width, b.h*height
           );   
        }
        if(drawPDF == true) {
          
          pdf.dispose();
          pdf.endDraw();
          
        }
      }
    }
    drawPDF = false;
    
    
  }else{
    println("There is no blob");
  }
  img.endDraw();


  return edges;
}

void printImage(String path) {  
  Process p = exec("lp", "-o fit-to-page -o landscape", path); 
  //Process p = exec("lp", path); 
  try {
    println(p);
    int result = p.waitFor();
    println("the process returned " + result);
  } 
  catch (InterruptedException e) {
    println("error : " + e);
  }
}

void keyPressed(){
  if(blobThreshold > 0.0 && blobThreshold < 1.0){
    if(key == CODED) {
      if(keyCode == UP) {
        blobThreshold = blobThreshold + 0.1;
      }else if(keyCode == DOWN){
        blobThreshold = blobThreshold - 0.1;
      }
    }
  }else if(blobThreshold >= 1.0){
    if(key == CODED) {
      if(keyCode == UP) {
        blobThreshold = 1.0;
      }else if(keyCode == DOWN){
        blobThreshold = blobThreshold - 0.1;
      }
    }
  }else if(blobThreshold <= 0.0){
    if(key == CODED) {
      if(keyCode == UP) {
        blobThreshold = blobThreshold + 0.1;
      }else if(keyCode == DOWN){
        blobThreshold = 0.0;
      }
    }
  }
  println("---Key code is", keyCode); 
  println("---Blob threshold changed to", nf(blobThreshold, 1, 1)); 
  
  // code to export video
  /*
  if (key == 'q') {
    videoExport.endMovie();
    exit();
  }
  */
}
