float boid_r = 50; // radius of the boids
float boid_a = PI/8; // angle of boid triangle.
class Boid {
  point p;    // point x, y at center
  vector v;     // velocity x, y
  color fill = orange;    
  color outline = dark_orange;
  float r = boid_r;  // radius of bounding circle
  float o;  // angle of triangle
  vector a = v(0, 0); // acceleration x, y
  
  Boid() {
    p = p(0, 0);
  }
  
  Boid(point p) {
    this.p = p;
    this.v = v(); // Initialize to random velocity.
    this.o = boid_a;
  }
  
  // Draw boid at current point facing in the direction of vector.
  void show() {
    // Bounding circle.
    noFill();
    stroke(light_grey);
    circle(p.x, p.y, r*2);
    
    stroke(black);
    fill(black);
    circle(p.x, p.y, 10);
    
    // Calculate boid triangle.
    vector u = u(v);
    point a = sum(p, product(u, r));
    vector iu = i(u);
    vector u2 = r(iu, o);
    point b = sum(p, product(u2, r));
    o = -o;
    vector u3 = r(iu, o);
    point c = sum(p, product(u3, r));
    
    fill(fill);
    stroke(outline);
    triangle(a.x, a.y, b.x, b.y, c.x, c.y);
  }
  
  // Update point and vector by 1 timestep.
  void update(float dt) {
    v = sum(v, product(a, dt));
    p = sum(p, product(v, dt));
  }
  
  // Does the boid contain this point?
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
    }
  }
  
  void update(float dt) {
    for (Boid b : flock){
      b.update(dt);
    }
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
