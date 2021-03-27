float boid_r = 20;   // radius of the boids
float boid_a = PI/8; // angle of boid triangle.
float boid_p = 150;  // radius of boid perception

float min_v = 5; // Prevent boids from becoming stuck anywhere by setting a low minimum velocity to help them to jiggle out of place.
float max_v = 10;

float w_fc = .2; // weight for flock centering
float w_vm = .00001; // weight for velocity matching
float w_ca = 15; // weight for collision avoidance
float w_wa = 25; // weight for wall avoidance
float w_w = .1;  // weight for wander

class Boid {
  point p;    // point x, y at center
  vector v;     // velocity x, y
  color fill = orange;    
  color outline = dark_orange;
  float r = boid_r;  // radius of bounding circle
  float o;  // angle of triangle
  
  Boid() {
    p = p(0, 0);
  }
  
  Boid(point p) {
    this.p = p;
    this.v = v(); // Initialize to random velocity.
    this.o = boid_a;
  }
  
  // Draw boid at current vector facing in the direction of vector.
  void show() {
    // Bounding circle.
    //noFill();
    //stroke(light_grey);
    //circle(p.x, p.y, r*2);
    
    // Perception circle.
    stroke(white);
    noFill();
    circle(p.x, p.y, boid_p*2);
    
    // True location (center of boid)
    //stroke(black);
    //fill(black);
    //circle(p.x, p.y, 10);
    
    // Boid representation.
    vector u = u(v);
    vector a = sum(p, prod(u, r));
    vector iu = i(u);
    vector u2 = r(iu, o);
    vector b = sum(p, prod(u2, r));
    o = -o;
    vector u3 = r(iu, o);
    vector c = sum(p, prod(u3, r));
    
    fill(fill);
    stroke(outline);
    triangle(a.x, a.y, b.x, b.y, c.x, c.y);
  }
  
  // Does the boid contain this vector?
  boolean contains(point p) {
    return d(this.p, p) <= r;
  }
}

float dt = .5;
class Flock {
  ArrayList<Boid> flock;
  
  Flock() {
    flock = new ArrayList<Boid>();
  }
  
  Flock(ArrayList<Boid> boids){
    flock = boids;
  }
  
  // Spawn a random boid.
  Boid spawn(float r) {
    return spawn(random_valid_point(r));
  }
  
  Boid spawn(Boid b) {
    flock.add(b);
    return b;
  }
  
  Boid spawn(point p) {
    if (this.contains(p)) return null; // Don't spawn a boid over an existing boid.
    Boid b = new Boid(p);
    return spawn(b);
  }
  
  // Kill a random boid.
  Boid kill() {
    return flock.remove(floor(random(flock.size())));
  }
  
  Boid kill(int i) {
    return flock.remove(i);
  }
  
  boolean kill(Boid b) {
    return flock.remove(b);
  }
  
  boolean kill(int x, int y) {
    for (Boid b: flock) {
      if (b.contains(p(x, y))) {
        return flock.remove(b);
      }
    }
    return false;
  }
  
  void scatter() {
    for (Boid b : flock) {
      b.p = random_valid_point(b.r);
    }
  }
  
  void show() {
    for (Boid b : flock){
      b.show();
      
      //vector force_on_b = calculate_forces(b);
      //vector force_from_b = sum(b.p, force_on_b);
      //stroke(black);
      //line(b.p.x, b.p.y, force_from_b.x, force_from_b.y);
      //vector velocity_from_b = sum(b.p, b.v);
      //line(b.p.x, b.p.y, velocity_from_b.x, velocity_from_b.y);
    }
  }
  
  void update(float dt) {
    for (Boid b : flock){
      update(b, dt);
    }
  }
  
  // Update vector and vector by 1 timestep.
  void update(Boid b, float dt) {
    vector f = calculate_forces(b);
    b.v = sum(b.v, prod(f, dt));
    
    float m = m(b.v);
    if (m < min_v) {
      b.v = prod(u(b.v), min_v);
    }
    else if (m > max_v) {
      b.v = prod(u(b.v), max_v);
    }
    
    b.p = p(sum(b.p, prod(b.v, dt)));
    
    // Force boid back into boundaries if it escapes.
    if (b.p.x < 0) b.p.x = b.r*2;
    if (b.p.y < 0) b.p.y = b.r*2;
    if (b.p.x > max_x) b.p.x = max_x - b.r*2;
    if (b.p.y > max_y) b.p.y = max_y - b.r*2;
  }
  
  // Calculate forces acting on b.
  vector calculate_forces(Boid b) {
    vector f =v(0, 0);
    
    vector sum_fc = v(0, 0);
    float sum_w = 0;
    vector f_vm = v(0, 0); // velocity matching
    vector f_ca = v(0, 0); // collision avoidance
    
    for (Boid n: neighbors(b)) {
      float w = weight(n, b);
      sum_w += w;
      sum_fc = sum(sum_fc, prod(sum(n.p, i(b.p)), w)); // sum_fc += w(pi - p)
      f_vm = sum(f_vm, prod(sum(n.v, i(b.v)), weight_vm(n, b)));     // f_vm += w(vi - v)
      f_ca = sum(f_ca, prod(sum(b.p, i(n.p)), w));     // f_ca += w(p - pi)
    }
    
    vector f_fc = prod(sum_fc, 1 / sum_w); // flock centering
    vector f_w = v(random(-1, 1), random(-1, 1)); // wander
    
    if (flock_centering)     f = sum(f, prod(f_fc, w_fc));
    if (velocity_matching)   f = sum(f, prod(f_vm, w_vm));
    if (collision_avoidance) f = sum(f, prod(f_ca, w_ca));
    if (wander)              f = sum(f, prod(f_w, w_w));
    
    // avoid walls
    f = sum(f, prod(wall_force(b), w_wa));
    return f;
  }
  
  // vector representing the force away from the nearest wall.
  vector wall_force(Boid b) {
    point p = b.p;
    
    boolean closer_to_x0 = abs(p.x - 0) < abs(p.x - max_x);
    float wall_x = closer_to_x0? 0 : max_x;
    
    boolean closer_to_y0 = abs(p.y - 0) < abs(p.y - max_y);
    float wall_y = closer_to_y0? 0 : max_y;
    
    float d_x = abs(p.x - wall_x);
    float d_y = abs(p.y - wall_y);
    
    float min_d = min(d_x, d_y);
    float wall_w = (min_d <= boid_p)? 1./sq(min_d) : 0;
    
    vector wall_f = v(0, 0);
    wall_f.x = (d_x <= boid_p)? p.x - wall_x : 0;
    wall_f.y = (d_y <= boid_p)? p.y - wall_y : 0;
    
    return prod(wall_f, wall_w);
  }
  
  // Get neighbors in b's perception.
  ArrayList<Boid> neighbors(Boid b) {
    ArrayList<Boid> neighbors = new ArrayList<Boid>();
    for (Boid n: flock) {
      if (n != b && d(n.p, b.p) <= boid_p + n.r) {
        // Is any part of n in b's perception radius?
        neighbors.add(n);
      }
    }
    return neighbors;
  }
  
  // The weight to give a influencing b or vice versa.
  // 1/distance^2
  float weight(Boid a, Boid b) {
    return 1./sq(d(a.p, b.p)); // boid_p - d(a.p, b.p);
  }
  
  float weight_vm(Boid a, Boid b) {
    return boid_p - d(a.p, b.p);
  }
  
  boolean contains(point p) {
    for (Boid b : flock) {
      if (b.contains(p)) return true;
    }
    return false;
  }
  
  // Random point within the boundaries and respecting the r of the boid.
  point random_valid_point(float r) {
    return p(
      floor(random(0 + r, max_x - r)),
      floor(random(0 + r, max_y - r))
    );
  }
}
