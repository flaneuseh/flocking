class Boid {
  Position p;    // position x, y at center
  Velocity v;     // velocity x, y
  color fill;    
  color outline;
  float r;  // radius of bounding circle
  
  Boid() {
    p = p(0, 0);
  }
  
  Boid(Position p, Velocity v, float r) {
    this.p = p;
    this.v = v;
    this.r = r;
  }
  
  // Draw boid at current position facing in the direction of velocity.
  void show() {
    //fill(fill);
    //stroke(outline);
    println("px " + p.x + " py " + p.y);
    noFill();
    stroke(light_grey);
    circle(p.x, p.y, r);
  }
  
  // Update position and velocity by 1 timestep.
  void update() {}
  
  // Does the boid contain this point?
  boolean contains(Position p) {
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
    return spawn(random_valid_position(r), r);
  }
  
  Boid spawn(Boid b) {
    flock.add(b);
    return b;
  }
  
  Boid spawn(Position p, float r) {
    if (this.contains(p)) return null; // Don't spawn a boid over an existing boid.
    Boid b = new Boid(p, new Velocity(), r);
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
      if (b.contains(new Position(x, y))) {
        return flock.remove(b);
      }
    }
    return false;
  }
  
  void scatter() {
    for (Boid b : flock) {
      b.p = random_valid_position(b.r);
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
  
  boolean contains(Position p) {
    for (Boid b : flock) {
      if (b.contains(p)) return true;
    }
    return false;
  }
  
  // Random position that does not overlap with any boids.
  Position random_valid_position(float r) {
    int x;
    int y;
    Position p;
    do {
      x = floor(random(0 + r, max_x - r));
      y = floor(random(0 + r, max_y - r));
      p = new Position(x, y);
    } while (this.contains(p));
    return p;
  }
}

class Position {
  float x;
  float y;
  
  Position(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

class Velocity {
  float x;
  float y;
  
  // Random velocity
  Velocity() {
    this.x = random(min_v, max_v);
    this.y = random(min_v, max_v);
  }
  
  Velocity(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

Velocity v() {
  return new Velocity();
}

Velocity v(float x, float y) {
  return new Velocity(x, y);
}

Position p(float x, float y) {
  return new Position(x, y);
}

// Distance between a and b.
float d(Position a, Position b) {
  return sqrt(sq(a.x - b.x) + sq(a.y - b.y));
}
