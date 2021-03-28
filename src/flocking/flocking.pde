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

boolean show_collision_circles = false;
boolean show_perception_circles = false;

String current_species = "orange"; // The species currently being added/removed to/from.

void setup() {
  size(1350, 850);
  surface.setTitle("BOIDS!");
  clear_paths();
  for (int i = 0; i < initial_size; i++) {
    flock.spawn(current_species);
  }
  for (int i = 0; i < toggle_dimensions.length; i++) {
    toggle_dimensions[i][0] = max_cx - 25;
    toggle_dimensions[i][1] = starting_cy + int(text_spacing*(i+1) - 14);
    toggle_dimensions[i][2] = font_size;
  }
  for (int i = 0; i < button_dimensions.length; i++) {
    button_dimensions[i][0] = starting_cx;
    button_dimensions[i][1] = button_start_y + button_spacing*i - 14;
    button_dimensions[i][2] = max_cx - 25 + font_size - starting_cx;
    button_dimensions[i][3] = button_size;
  }
  strokeWeight(2);
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

int font_size = 16;
int text_spacing = font_size + 5;
int starting_cx = min_cx + 10;
int starting_cy = min_cy + 20;

String[] toggle_texts = {"flock centering", "velocity matching", "collision avoidance", "wander", "show paths", "show collision circles", "show perception"};
int[][] toggle_dimensions = new int[toggle_texts.length][4];

int button_size = font_size + 5;
int button_spacing = button_size + 5;
int button_start_y = starting_cy + text_spacing * (toggle_texts.length + 1);

String[][] button_texts = {{"clear", "clear"}, {"scatter", "scatter"}, {"set mouse to repulse", "set mouse to attract"}, {"play", "pause"}, {"spawn", "spawn"}, {"kill", "kill"}};
int[][] button_dimensions = new int[button_texts.length][4];

void show_controls() {
  fill(white);
  stroke(black);
  rect(min_cx, min_cy, max_cx - min_cx, max_cy);
  
  fill(black);
  textSize(font_size);
  text("CONTROLS", starting_cx, starting_cy);
  
  boolean[] toggles = {flock_centering, velocity_matching, collision_avoidance, wander, pathing, show_collision_circles, show_perception_circles};
  for (int i = 0; i < toggles.length; i++) {
    text(toggle_texts[i], starting_cx, starting_cy + text_spacing*(i+1));
    fill(toggles[i]? black: white);
    stroke(black);
    square(toggle_dimensions[i][0], toggle_dimensions[i][1], toggle_dimensions[i][2]);
    fill(black);
  }
  
  boolean[] buttons = {true, true, attraction, !running, true, true};
  for (int i = 0; i < buttons.length; i++) {
    int text_index = buttons[i]? 0: 1;
    if (mousePressed && mouse_in(button_dimensions[i])) fill(light_grey); else noFill();
    rect(button_dimensions[i][0], button_dimensions[i][1], button_dimensions[i][2], button_dimensions[i][3]);
    fill(black);
    text(button_texts[i][text_index], starting_cx + 5, button_start_y + int(button_spacing*i) + 3);  
  }
}

void mousePressed() {
  for (int i = 0; i < toggle_dimensions.length; i++) {
    if (mouse_in(toggle_dimensions[i])) {
      switch (toggle_texts[i]) {     
        case "flock centering":
          flock_centering = !flock_centering;
          break;
        case "velocity matching":
          velocity_matching = !velocity_matching;
          break;
        case "collision avoidance":
          collision_avoidance = !collision_avoidance;
          break;
        case "wander":
          wander = !wander;
          break;
        case "show paths":
          pathing = !pathing;
          break;
        case "show collision circles":
          show_collision_circles = !show_collision_circles;
          break;
        case "show perception":
          show_perception_circles = !show_perception_circles;
          break;
        default:
          break;
      }
    }
  }

  for (int i = 0; i < button_dimensions.length; i++) {
    if (mouse_in(button_dimensions[i])) {
      switch (button_texts[i][0]) {   
        case "clear":
          clear_paths();
          break;
        case "scatter":
          flock.scatter();
          break;
        case "set mouse to repulse":
          attraction = !attraction;
          break;
        case "play":
          running = !running;
          break;
        case "spawn":
          flock.spawn(current_species);
          break;
        case "kill":
          flock.kill(current_species);
          break;
        default:
          break;
      }
    }
  }
}

// Ctrl = min x, min y, x size/size, y size (optional)
boolean mouse_in(int[] dimensions) {
  int min_x = dimensions[0];
  int max_x = min_x + dimensions[2];
  int min_y = dimensions[1];
  int max_y = dimensions[1] + (dimensions[3] > 0? dimensions[3] : dimensions[2]);
  return (mouseX >= min_x && mouseX <= max_x && mouseY >= min_y && mouseY <= max_y);
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
      flock.spawn(current_species);
      println("Spawn");
      break;
    case '-':
      flock.kill(current_species);
      println("Kill");
      break;
    default:
      break;
  }
}
