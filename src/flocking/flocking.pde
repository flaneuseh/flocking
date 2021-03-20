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
// Extras:
// 
// * Implement 3D flocking.
// * Introduce a predator that chases after your flocking creatures and eats them.
// * Add on-screen widgets that control the simulation.
// * Include fixed collision objects for the creatures to steer around.
// * food/resources/shelter
// * another species of non predatory boids.
// * Use a grid or Voronoi/Dalauney triangles to only consider the closest neighborhood of boids.
// * ### Custom Commands:
// * right mouse held down - do the opposite of the left mouse (repulsion in attraction mode, attraction in repulsion mode)
// * left click (or s?) - spawn a boid at the mouse's position
// * right click (or k?) - delete the boid at the mouse's position
// 

// Simulation Parameters
boolean running = false;
boolean attraction = true;
boolean pathing = false;

// Colours.
color black = #000000;
color white = #ffffff;
color orange = #ff6600;
color dark_orange = #993d00;
color light_grey = #cccccc;
color aqua = #00ffff;

// Flock
Flock flock = new Flock();
int initial_size = 1;

int max_x = 1150;
int max_y = 850;

boolean flock_centering = true;
float fc = 0;
boolean velocity_matching = true;
float vm = 0;
boolean collision_avoidance = true;
float ca = 0;
boolean wandering = true;
float w = 0;

float min_v = 0;
float max_v = 50;

void setup() {
  size(1350, 850);
  surface.setTitle("BOIDS!");
  fill(white);
  noStroke();
  rect(1150, 0, 200, 850);
  clear_paths();
  for (int i = 0; i < initial_size; i++) {
    flock.spawn(boid_r);
  }
}

void draw() {
  if (!pathing) {
    clear_paths();
  }
  flock.show();
  if (running) {
    float dt = 1;
    flock.update(dt);
  }
}

void mousePressed() {}

void mouseClicked() {}

void clear_paths() {
  noStroke();
  fill(aqua);
  rect(0, 0, max_x, max_y);
}


void keyPressed() {
  switch (key) {
    case ' ':
      running = !running;
      break;
    case 'a':
      attraction = true;
      break;
    case 'r':
      attraction = false;
      break;
    case 's':
      flock.scatter();
      break;
    case 'p':
      pathing = !pathing;
      break;
    case 'c':
      clear_paths();
      break;
    case '1':
      flock_centering = !flock_centering;
      break;
    case '2':
      velocity_matching = !velocity_matching;
      break;
    case '3':
      collision_avoidance = !collision_avoidance;
      break;
    case '4':
      wandering = !wandering;
      break;
    case '+':
    case '=':
      flock.spawn(boid_r);
    case '-':
      flock.kill();
    default:
      break;
  }
}
