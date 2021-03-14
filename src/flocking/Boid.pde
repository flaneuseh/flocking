class Boid {
  point p;    // point x, y at center
  vector v;     // vector x, y
  color fill;    
  color outline;
  float r;  // radius of bounding circle
  float a;  // angle of triangle
  
  Boid() {
    p = p(0, 0);
  }
  
  Boid(point p, vector v, float r) {
    this.p = p;
    this.v = v;
    this.r = r;
  }
  
  // Draw boid at current point facing in the direction of vector.
  void show() {
    // Bounding circle.
    noFill();
    stroke(light_grey);
    circle(p.x, p.y, r);
    
    // Boid.
    fill(fill);
    stroke(outline);
    
    // Calculate boid triangle.
    vector u = u(v);
    int x1 = round(p.x + r * v.x);
    int y1 = round(p.y + r * v.y);
    vector iu = i(u);
    float a = this.a/2;
    vector u2 = r(iu, a);
    int x2 = round(p.x + r * v.x);
    int y2 = 
    a = -a;
    int x3 = 
    int y3 = 
    triangle(x1, y1, x2, y2, x3, y3);
  }
  
  // Update point and vector by 1 timestep.
  void update() {}
  
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
    return spawn(random_valid_point(r), r);
  }
  
  Boid spawn(Boid b) {
    flock.add(b);
    return b;
  }
  
  Boid spawn(point p, float r) {
    if (this.contains(p)) return null; // Don't spawn a boid over an existing boid.
    Boid b = new Boid(p, v(), r);
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
  
  void update() {
    for (Boid b : flock){
      b.update();
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
