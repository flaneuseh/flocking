// README
// 
// # BOIDS! (Craig Reynolds' Flocking)
// 
// ## An implementation in Processing by Kaylah Facey.
//
// ### Commands:
// 
// * space bar - Start or stop the simulation (default stopped).
// * left mouse held down - continuous attraction (in attraction mode) or repulsion (in repulsion mode):
// -   a - Switch to attraction mode (default).
// -   r - Switch to repulsion mode.
// * s - Cause all boids to be instantly scattered to random positions in the window, and with random directions.
// * p - Toggle whether to have creatures leave a path, that is, whether the window is cleared each display step or not (default off).
// When pathing leave a trail of dots or fading trail. Do not preserve the entire path, as that quickly clutters the window.
// * c - Clear the screen, but do not delete any boids. (This can be useful when creatures are leaving paths.)
// * 1-4 - Toggle forces on/off (default on):
//   - 1 - flock centering 
//   - 2 - velocity matching 
//   - 3 - collision avoidance 
//   - 4 - wandering 
// * Spawn and Kill:
//   - +/= - Spawn (add one new boid to the simulation) (up to 100)
//   - (minus sign) - Kill (Remove one boid from the simulation) (down to 0).
// 
// ## Custom Commands:
// * right mouse held down - do the opposite of the left mouse (repulsion in attraction mode, attraction in repulsion mode)
// 
// TODO:
// 
// * Implement 3D flocking.
// * Introduce a predator that chases after your flocking creatures and eats them.
// * Add on-screen widgets that control the simulation.
// * Include fixed collision objects for the creatures to steer around.
// * food/resources/shelter
// * another species of non predatory boids.
// * Use a grid or Voronoi/Dalauney triangles to only consider the closest neighborhood of boids.
// * ### Custom Commands:
// 
// * left click (or s?) - spawn a boid at the mouse's position
// * right click (or k?) - delete the boid at the mouse's position
// * boid colour variation
// 

// Simulation Parameters
boolean running = false;
boolean attraction = true;
boolean pathing = false;
int alpha_p = 20; // the alpha value to use when pathing.

// Colours.
color black = #000000;
color white = #ffffff;
color orange = #ff6600;
color dark_orange = #993d00;
color light_grey = #cccccc;
color aqua = #00ffff;
color red = #ff0000;
color green = #00802b;

// Flock
Flock flock = new Flock();
int initial_size = 16;

int max_x = 1150;
int max_y = 850;

boolean flock_centering = false;
boolean velocity_matching = false;
boolean collision_avoidance = false;
boolean wander = false;

void setup() {
  size(1350, 850);
  surface.setTitle("BOIDS!");
  clear_paths();
  for (int i = 0; i < initial_size; i++) {
    flock.spawn(boid_r);
  }
}

void draw() {
  paint_background(pathing);
  show_mouse();
  show_controls();
  flock.show();
  if (running) {
    flock.update(dt);
  }
}

void show_mouse() {
  if (mousePressed) {
    color c;
    if (attracting()) { 
      // attraction left or repulsion right: attraction
      c = green;
    }
    else { // repulsion left or attraction right: repulsion
      c = red;
    }
    
    int alpha = pathing? 20 : 130;
    fill(c, alpha);
    noStroke();
    circle(mouseX, mouseY, boid_p*2);
  }
}

boolean attracting() {
  // attraction left or repulsion right: attraction
  // repulsion left or attraction right: repulsion
  return (attraction && mouseButton == LEFT) || (!attraction && mouseButton == RIGHT);
}

void paint_background (boolean pathing) {
  noStroke();
  if (pathing) fill(aqua, alpha_p);
  else fill(aqua);
  rect(0, 0, max_x, max_y);
}

int min_cx = max_x;
int min_cy = 0;
int max_cx = 1350;
int max_cy = max_y;
void show_controls() {
  fill(white);
  stroke(black);
  rect(min_cx, min_cy, max_cx - min_cx, max_cy);
  
  fill(black);
  textSize(16);
  text("CONTROLS", min_cx + 10, min_cy + 30);
}

void clear_paths() {
  paint_background(false);
}


void keyPressed() {
  switch (key) {
    case ' ':
      running = !running;
      println(running? "Play" : "Pause");
      break;
    case 'a':
      attraction = true;
      println("Toggle left mouse attraction (right mouse repulsion)");
      break;
    case 'r':
      attraction = false;
      println("Toggle left mouse repulsion (right mouse attraction)");
      break;
    case 's':
      flock.scatter();
      println("Scatter");
      break;
    case 'p':
      pathing = !pathing;
      println("Toggle pathing " + (pathing? "on" : "off"));
      break;
    case 'c':
      clear_paths();
      println("Clear");
      break;
    case '1':
      flock_centering = !flock_centering;
      println("Toggle flock centering " + (flock_centering? "on" : "off"));
      break;
    case '2':
      velocity_matching = !velocity_matching;
      println("Toggle velocity matching " + (velocity_matching? "on" : "off"));
      break;
    case '3':
      collision_avoidance = !collision_avoidance;
      println("Toggle collision avoidance " + (collision_avoidance? "on" : "off"));
      break;
    case '4':
      wander = !wander;
      println("Toggle wander " + (wander? "on" : "off"));
      break;
    case '+':
    case '=':
      flock.spawn(boid_r);
      println("Spawn");
      break;
    case '-':
      flock.kill();
      println("Kill");
      break;
    default:
      break;
  }
}
