/* @pjs font="OnePiece.ttf"; */

/*
  name: Mohamed Lahkim
  date: May 22
  title: Luffy's Banquet
  description: A game where Luffy eats the falling meat and avoids the falling swords.
  If luffy eats a special fruit he becomes steched making it easier to avoid the falling swords.
*/

// Import the nessesary libraries


// Declare all of the image variables
PImage luffy, luffyOpen, meat, sword, fruit, sea, dock;

// Declare all of the sound effect variables
Object eat, score, slice, powerup, background;

// Declare the custom font variable
PFont OnePiece;

int n = 5;                                // this represents the length of the arrays
int Alpha = 0;                            // this represents the opacity of the background for the end screen
boolean active = true;
boolean hungry = false;                   // checks if food is nearby

// Declare the movement booleans --> they allow you to move instantly with no inital stop
boolean moveRight = false;
boolean moveLeft = false;


int LX = 250;                             // Luffy X position from the bottom left corner
float s = 200;                            // Luffy size
float lHeight, lWidth;                    // Luffy hitbox height and width
float gAndB;                              // Stores the calculated redness of luffy based on how close he is to loosing


int highscore = 0;                        // Highest amount of meat eaten in a single run

float Score = 0;                          // Shows in the total meat eaten text allowing for the number to go up

// speed and positions of each meat and sword
float[] speedM = new float[n];
float[] MY = new float[n];
float[] MX = new float[n];
float[] speedS = new float[n];
float[] SX = new float[n];
float[] SY = new float[n];

float speedF, FX, FY = -500;              // speed and position of the fruit (yes i know -500 is only applied to FY)
float speedMultiplier = 1.0;              // increases all object speeds over time

float sizeMultiplier = 1.0;               // Luffy powerup that makes him stretched
int meatEaten = 0;                        // counter for total meat eaten
int Start, End;                           // Beginning and ending Framecount for counting time


void setup() {
  size(800, 600);
  frameRate(20); 
  // Load all of the images in
  luffy = loadImage("luffy.png");
  luffyOpen = loadImage("luffyOpen.png");
  meat = loadImage("meat.png");
  sword = loadImage("sword.png");
  fruit = loadImage("fruit.png");
  sea = loadImage("sea.jpg");
  dock = loadImage("dock.png");

  // Load all of the sounds in
  eat = new Audio("gulp.mp3");
  score = new Audio("score.wav");
  slice = new Audio("slice.mp3");
  powerup = new Audio("powerup.mp3");
  background = new Audio("background.mp3");

  // Load the custom font in
  OnePiece  = createFont("OnePiece.ttf", 48);
  // Use the custom One Piece font
  textFont(OnePiece);


  /*
  // Read "highscore.txt" to get the saved highscore
  String line = "";
  try {
    BufferedReader read = createReader("highscore.txt"); // Read the file
    if (read == null) {                                    // If the file doesn't exist
      throw new IOException("file does not exist");      // Prevents the NullPointerException error by throwing the error
    }
    line = read.readLine();        // Reads the file for the highscore
    highscore = int(line);         // Save the highscore to the highscore variable
    read.close();
  }
  catch(IOException e) {
    // just doesnt do anything if there is an error
  }
  */
  String savedHighscore = localStorage.getItem("qb_highscore");
  if (savedHighscore != null) {
    highscore = int(savedHighscore);
  } else {
    highscore = 0; 
  }
  
  // Position all of the initial meat and swords and set their speeds
  for (int i = 0; i < n; i++) {
    reset("meat", i);
    reset("sword", i);
  }
}

void draw() {
  // Check if the background music is playing and if it isnt then play the background music
  
  /*
  if (!background.isPlaying()) {
    playSound(background);
    // background.play(); // Start looping
    background.amp(0.5);
  }
  */
  if (background.paused) {
    background.loop = true;
    background.volume = 0.9;
    background.play();
    try {
      background.play();
    } catch(Object e) {
      // Safely catches browser blocks until the user presses a key to move
    }
  }

  
  // Check if playing
  if (active) {

    // Draw the background
    image(sea, 0, 0, width, height);
    image(dock, 0, 300, width, 300);


    // Move Luffy --> doing it this way allows continuous movement
    if (moveRight) {
      LX += 25;
      if (LX > width - lWidth) {
        LX = width - (int)lWidth;
      }
    }
    if (moveLeft) {
      LX -= 25;
      if (LX < 0) {
        LX = 0;
      }
    }



    // Set the dimentions of Luffy's dynamic hitbox
    lWidth = s*sizeMultiplier;
    lHeight = s*0.625/sizeMultiplier;

    // if the fruit powerup is still active and hasnt run out then set the size multiplier
    if (frameCount > Start && frameCount < End) {
      sizeMultiplier = 0.75;
    }
    // if not then no powerup effect
    else
      sizeMultiplier = 1;

    // Draw Luffy
    drawLuffy();

    hungry = false;   // Make sure luffy is hungry(mouth closed) by default
    FY += speedF;     // move the fruit down
    for (int i = 0; i < n; i++) {
      // Move the meat and swords down
      MY[i] += speedM[i];
      SY[i] += speedS[i];

      // Check if any meat is close to Luffy's mouth
      if (dist(MX[i], MY[i], LX+s/2, 600-s/sizeMultiplier) < 200) {
        hungry = true;
      }


      // If meat or a sword goes below the bottom then reset it to the top
      if (MY[i] > height) {
        reset("meat", i);
      }
      if (SY[i] > height) {
        reset("sword", i);
      }

      if (checkSwordCollision(SX[i], SY[i])) {
        slice.cloneNode(true).play(); 
        //slice.play();
        // slice.amp(4);
        reset("sword", i);
        s = s/1.3;          // Shrink Luffy by 30%
      }
      if (checkMeatCollision(MX[i], MY[i])) {
        eat.cloneNode(true).play();  
        //eat.play();
        // eat.amp(4);
        reset("meat", i);
        meatEaten++;
        s += 20;            // Grow luffy by 20 pixels
        // Every other meat eaten increase the overall speed by 5%
        if (meatEaten % 2 == 0) {
          speedMultiplier += 0.05;
          // When conditions are favorable and every 10th meat spawn in a powerup fruit
          if (meatEaten % 10 == 0 && FY == -500 && sizeMultiplier == 1) {
            reset("fruit", 0);
          }
        }
      }
      // Draw the meat and swords at their respective positions
      image(meat, MX[i], MY[i], 100, 100);
      image(sword, SX[i], SY[i], 40, 100);


      // Sword hilt hitbox visual(to nullify the hitbox)
      // noFill();
      // rect(SX[i], SY[i], 40, 40);

      // Meat hitbox visual
      // noFill();
      // circle(MX[i]+50, MY[i]+50, 80);
    }
    // If the fruit goes below the bottom then reset it to the top
    if (FY > height) {
      reset("fruit", 0);
    }

    if (checkFruitCollision(FX, FY)) {
      stopFruit();
      powerup.cloneNode(true).play(); 
      // powerup.play();
      // powerup.amp(2);
      time(150);        // Give the player 150 frames of powerup
    }
    
    // Show powerup time left
    if (sizeMultiplier != 1) {
      fill(0);
      textAlign(RIGHT);
      // Change your power left text line to this:
      text("Power left: " + floor((End - frameCount) / frameRate), width - 20, 30);
    }
    // Fruit hitbox visual
    //noFill();
    //circle(FX+40, FY+40, 80);

    // Luffy mouth hitbox visual
    //noFill();
    //circle(LX+s*sizeMultiplier/1.9, height -(s -s/6)/sizeMultiplier, s/3/sizeMultiplier);
    image(fruit, FX, FY, 80, 80);

    // Meat eaten counter
    fill(0);
    textSize(30);
    textAlign(LEFT);
    text("Meat Eaten: "+meatEaten, 10, 30);

    // Show the current highscore
    if (highscore != 0) {
      text("Highscore: "+highscore, 10, 60);
    }

    // Death logic
    if (s/sizeMultiplier < 150) {
      Score = 0;
      active = false;
      score.cloneNode(true).play(); 
      // score.play();
      // score.amp(5);
      // Set new highscore
      if (meatEaten > highscore) {
        highscore = meatEaten;
        
        // Write the new highscore to "highscore.txt"
        // PrintWriter write = createWriter("highscore.txt");
        // write.println(highscore);
        // write.close();
        localStorage.setItem("qb_highscore", str(highscore));
        
        
      }
    }
  }

  // not active meaning you lose
  else {
    // Set all object speeds to 0
    speedF = 0;
    speedF = 0;
    for (int i = 0; i < n; i++) {
      speedS[i] = 0;
      speedM[i] = 0;
    }


    // Redraw everything in the background so it looks like everything froze
    image(sea, 0, 0, width, height);
    image(dock, 0, 300, width, 300);
    
    // Draw luffy
    drawLuffy();
    
    // Draw all the meat and swords
    for (int i = 0; i < n; i++) {
      image(meat, MX[i], MY[i], 100, 100);
      image(sword, SX[i], SY[i], 40, 100);
    }
    
    // Draw the fruit
    image(fruit, FX, FY, 80, 80);
    
    // Draw the meat eaten counter in the background
    fill(0);
    textSize(30);
    textAlign(LEFT);
    text("Meat Eaten: "+meatEaten, 10, 30);

    // Increase the opacity of the black overlay
    if (Alpha < 175) {
      Alpha += 5;
    }
    fill(0, 0, 0, Alpha);
    noStroke();
    // Black overlay
    rect(0, 0, width, height);


    // Draw the "YOU LOSE" and make it fade in and center it on the screen
    fill(255, 0, 0, Alpha+50);
    textAlign(CENTER);
    textSize(130);
    text("YOU LOSE!", width/2, 200);

    // Draw the death message and make it fade in and center it on the screen
    fill(255, 255, 0, Alpha+50);
    
    // Choose which death message to show
    if (meatEaten >= highscore) {
      // Cool HIGHSCORE effect thing
      noStroke();
      fill(255, 255, 255, 70);
      fill(#FFFF00);
      textSize(15*sin(frameCount/2)+90);
      text("NEW HIGHSCORE!", width/2, 320);
    } else {
      // normal bland text
      textSize(90);
      text("Better luck next time", width/2, 320);
    }
    
    
    // Show final total meat eaten
    textSize(60);
    text("You ate "+round(Score)+" pieces of meat", width/2, 410);
    if (Score < meatEaten) {
      // Play the score increasing sound effect
      // if (!score.isPlaying()) {
      //   playSound(score); 
      //   // score.play(); // Start looping
      //   score.amp(5);
      // }

      if (score.paused) {
        score.loop = true;
        score.volume = 0.3;
        score.play();
      }

      
      Score += 1.5;
    } else {
      Score = meatEaten;
    }

    textSize(40);
    text("Press Enter to Play Again", width/2, 500);
  }
}

boolean checkSwordCollision(float SX, float SY) {
  if (SY + 100 + lHeight >= height && !(SY + 40 > height) && SX+20 > LX && SX+20 < LX+ lWidth) {
    return(true);
  } else
    return(false);
}

boolean checkMeatCollision(float MX, float MY) {
  if (dist(LX+s*sizeMultiplier/1.9, height -(s -s/6)/sizeMultiplier, MX+50, MY+50) < s/6/sizeMultiplier+40) {
    return(true);
  } else
    return(false);
}

boolean checkFruitCollision(float FX, float FY) {
  if (dist(LX+s*sizeMultiplier/1.9, height -(s -s/6)/sizeMultiplier, FX+40, FY+40) < s/6/sizeMultiplier+40) {
    return(true);
  } else
    return(false);
}


// This an item back all the way up
void reset(String s, int i) {
  if (s.equals("meat")) {
    speedM[i] = (random(7)+3)*speedMultiplier;
    MX[i] = random(width-100);
    MY[i] = -300;
  } else if (s.equals("sword")) {
    speedS[i] = (random(7)+3)*speedMultiplier;
    SX[i] = random(width-50);
    SY[i] = -300;
  } else if (s.equals("fruit")) {
    speedF = (random(2)+4)*speedMultiplier;
    FX = random(width-80);
    FY = -300;
  }
}

// this stops the fruit entirely until it is spawned in again
void stopFruit() {
  speedF = 0;
  FY = -500;
}
// Counts time
void time(int duration) {
  Start = frameCount;
  End = Start+duration;
}

void drawLuffy() {
  // This creates a color range. It makes Luffy fully red when his height is 150 and not red when his height is 200
  gAndB = 250 * ((s / sizeMultiplier) - 150) / 50.0;
  //       ^                              ^      ^
  // gAndB at height=200             min height  range

  // Colors Luffy red based on height
  tint(255, gAndB, gAndB);
  // Check if either meat or a fruit is nearby and draw luffy with his mouth open
  if (hungry || dist(FX, FY, LX + s/2, height-s/sizeMultiplier) < 200) {
    image(luffyOpen, LX, (600-s/sizeMultiplier), s*sizeMultiplier, s/sizeMultiplier);
  }
  // If not then just draw regular luffy with his mouth closed
  else
    image(luffy, LX, (600-s/sizeMultiplier), s*sizeMultiplier, s/sizeMultiplier);
  noTint();
}


void keyReleased() {
  if (active) {
    if (keyCode == RIGHT || key == 'd') {
      moveRight = false;
    }
    if (keyCode == LEFT || key == 'a') {
      moveLeft = false;
    }
  }
}


void keyPressed() {
  if (active) {
    if (keyCode == RIGHT || key == 'd') {
      moveRight = true;
    }
    if (keyCode == LEFT || key == 'a') {
      moveLeft = true;
    }
  }
  // Replay game logic
  if ((keyCode == ENTER || key == ' ') && !active) {
    score.pause();
    score.currentTime = 0;
    Score = 0
    active = true;
    moveLeft = false;
    moveRight = false;
    s = 200;
    LX = (int)(width/2 - s/2);
    stopFruit();
    speedMultiplier = 1.0;
    Alpha = 0;
    meatEaten = 0;
    for (int i = 0; i < n; i++) {
      reset("meat", i);
      reset("sword", i);
    }
  }
}


/*
// --- COMPILER-SAFE WEB AUDIO HELPERS ---
void playSound(Object sound) {
  if (sound == null) return;
  String url = (String) sound;
  String slot = getSoundSlot(url);
  window[slot] = new Audio(url);
}

void loopSound(Object sound) {
  if (sound == null) return;
  String url = (String) sound;
  String slot = getSoundSlot(url);
  window[slot] = new Audio(url);
}

void loopSoundClean(Object sound) {
  if (sound == null) return;
  String url = (String) sound;
  String slot = getSoundSlot(url);
  window[slot] = new Audio(url);
}

void stopSound(Object sound) {
  if (sound == null) return;
  String url = (String) sound;
  String slot = getSoundSlot(url);
  window[slot] = new Audio(url);
}

boolean isSoundPlaying(Object sound) {
  if (sound == null) return false;
  String url = (String) sound;
  String slot = getSoundSlot(url);
  window[slot] = new Audio(url);
  return boolean("" + state);
}

String getSoundSlot(String url) {
  // Matches your unique filenames to a safe browser registration variable
  if (url.indexOf("jump") != -1) return "_sndJump";
  if (url.indexOf("Sci-Fi") != -1) return "_sndMusic";
  return "_sndGeneric";
}
*/
