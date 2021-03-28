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
  if (mouse_active()) {
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

boolean mouse_active() {
  return mousePressed && mouseX <= max_x && mouseY <= max_y;
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
int font_size = 20;
int text_spacing = font_size + 10;
int starting_cx = min_cx + 10;
int starting_cy = min_cy + 30;

// Ctrl = min x, min y, size
int[] ctrl_fc = {starting_cx, starting_cy + int(text_spacing*2.25), font_size};
int[] ctrl_vm = {starting_cx, starting_cy + int(text_spacing*4.25), font_size};
int[] ctrl_ca = {starting_cx, starting_cy + int(text_spacing*6.25), font_size};
int[] ctrl_w = {starting_cx, starting_cy + int(text_spacing*8.25), font_size};
int[] ctrl_attr = {starting_cx + 70, starting_cy + text_spacing*10 - 15, font_size};
int[] ctrl_repl = {ctrl_attr[0] + font_size, ctrl_attr[1], ctrl_attr[2]};

void show_controls() {
  fill(white);
  stroke(black);
  rect(min_cx, min_cy, max_cx - min_cx, max_cy);
  
  fill(black);
  textSize(font_size);
  text("CONTROLS", starting_cx, starting_cy);
  
  // Force controls
  text("flock centering", starting_cx, starting_cy + text_spacing*2);
  show_force_controls(ctrl_fc[0], ctrl_fc[1], flock_centering);
  text("velocity matching", starting_cx, starting_cy + text_spacing*4);
  show_force_controls(ctrl_vm[0], ctrl_vm[1], velocity_matching);
  text("collision avoidance", starting_cx, starting_cy + text_spacing*6);
  show_force_controls(ctrl_ca[0], ctrl_ca[1], collision_avoidance);
  text("wander", starting_cx, starting_cy + text_spacing*8);
  show_force_controls(ctrl_w[0], ctrl_w[1], wander);
  
  int y = starting_cy + text_spacing*10;
  stroke(black);
  text("attract", starting_cx, y);
  fill(attraction? black: white);
  square(ctrl_attr[0], ctrl_attr[1], ctrl_attr[2]);
  fill(!attraction? black: white);
  square(ctrl_repl[0], ctrl_repl[1], ctrl_repl[2]);
  fill(black);
  text("repel", starting_cx + 120, y);
}

void show_force_controls(int x, int y, boolean on) {
  fill(on? black: white);
  stroke(black);
  square(x, y, font_size);
  fill(black);
}

void mousePressed() {
  int[][] ctrls = {ctrl_fc, ctrl_vm, ctrl_ca, ctrl_w, ctrl_attr, ctrl_repl};
  for (int[] ctrl : ctrls) {
    int min_x = ctrl[0];
    int max_x = min_x + ctrl[2];
    int min_y = ctrl[1];
    int max_y = ctrl[1] + ctrl[2];
    if (mouseX >= min_x && mouseX <= max_x && mouseY >= min_y && mouseY <= max_y) {
      if (ctrl == ctrl_fc) flock_centering = !flock_centering;
      else if (ctrl == ctrl_vm) velocity_matching = !velocity_matching;
      else if (ctrl == ctrl_ca) collision_avoidance = !collision_avoidance;
      else if (ctrl == ctrl_w) wander = !wander;
      else if (ctrl == ctrl_attr || ctrl == ctrl_repl) attraction = !attraction;
    }
  }
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
