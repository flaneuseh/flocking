float boid_r = 50;   // radius of the boids
float boid_a = PI/8; // angle of boid triangle.
float boid_p = 500;  // radius of boid perception
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
    noFill();
    stroke(light_grey);
    circle(p.x, p.y, r*2);
    
    // Perception circle.
    stroke(white);
    circle(p.x, p.y, boid_p*2);
    
    stroke(black);
    fill(black);
    circle(p.x, p.y, 10);
    
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
      
      vector force_on_b = calculate_forces(b);
      vector force_from_b = sum(b.p, force_on_b);
      stroke(red);
      line(b.p.x, b.p.y, force_from_b.x, force_from_b.y);
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
      f_vm = sum(f_vm, prod(sum(n.v, i(b.v)), w));     // f_vm += w(vi - v)
      f_ca = sum(f_ca, prod(sum(b.p, i(n.p)), w));     // f_ca += w(p - pi)
    }
    
    vector f_fc = prod(sum_fc, 1 / sum_w); // flock centering
    vector f_w = v(random(-1, 1), random(-1, 1)); // wander
    
    if (flock_centering)     f = sum(f, prod(f_fc, w_fc));
    if (velocity_matching)   f = sum(f, prod(f_vm, w_vm));
    if (collision_avoidance) f = sum(f, prod(f_ca, w_ca));
    if (wander)              f = sum(f, prod(f_w, w_w));
    
    // avoid walls
    f = sum(f, prod(wall_force(b), w_ca));
    
    return f;
  }
  
  // vector representing the force away from the nearest wall.
  vector wall_force(Boid b) {
    point p = b.p;
    
    boolean closer_to_x0 = abs(p.x - 0) < abs(p.x - max_x);
    float wall_x = closer_to_x0? 0 : max_x;
    
    boolean closer_to_y0 = abs(p.x - 0) < abs(p.x - max_y);
    float wall_y = closer_to_y0? 0 : max_y;
    
    float d_x = abs(p.x - wall_x);
    float d_y = abs(p.y - wall_y);
    
    float min_d = min(d_x, d_y);
    float wall_w = (min_d <= boid_p)? min_d : 0;
    
    vector wall_f = v(0, 0);
    wall_f.x = (d_x <= boid_p)? p.x - wall_x : 0;
    wall_f.y = (d_y <= boid_p)? p.y - wall_y : 0;
    
    return prod(wall_f, wall_w);
  }
  
  // Get neighbors in b's perception.
  ArrayList<Boid> neighbors(Boid b) {
    ArrayList<Boid> neighbors = new ArrayList<Boid>();
    for (Boid n: flock) {
      if (d(n.p, b.p) <= boid_p + n.r) {
        neighbors.add(n);
      }
    }
    return neighbors;
  }
  
  // The weight to give a influencing b or vice versa.
  // 1/distance^2
  float weight(Boid a, Boid b) {
    return d(a.p, b.p);
  }
  
  boolean contains(point p) {
    for (Boid b : flock) {
      if (b.contains(p)) return true;
    }
    return false;
  }
  
  // Random point that does not overlap with any boids.
  point random_valid_point(float r) {
    int x;
    int y;
    point p;
    do {
      x = floor(random(0 + r, max_x - r));
      y = floor(random(0 + r, max_y - r));
      p = p(x, y);
    } while (this.contains(p));
    return p;
  }
}
