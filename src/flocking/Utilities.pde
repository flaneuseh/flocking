class point {
  float x;
  float y;
  
  point(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

class vector {
  float x;
  float y;
  
  // Random vector
  vector() {
    this.x = random(min_v, max_v);
    this.y = random(min_v, max_v);
  }
  
  vector(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

vector v() {
  return new vector();
}

vector v(float x, float y) {
  return new vector(x, y);
}

// Unit vector.
vector u(vector v) {
  float m = m(v);
  return v(v.x/m, v.y/m);
}

// Magnitude of vector.
float m(vector v) {
  return sqrt(sq(v.x) + sq(v.y));
}

// Inverse of vector.
vector i(vector v) {
  return v(-v.x, -v.y);
}

// vector rotated by a.
// https://matthew-brett.github.io/teaching/rotation_2d.html
vector r(vector v, float a) {
  float cos = cos(a);
  float sin = sin(a);
  float x = cos * v.x - sin * v.y; // x2=cosβx1−sinβy1
  float y = sin * v.x + cos * v.y; // y2=sinβx1+cosβy1
  return v(x, y);
}

// vector scaled by s.
vector s(vector v, float s) {
  return v(v.x * s, v.y * s);
}

point p(float x, float y) {
  return new point(x, y);
}

// Distance between a and b.
float d(point a, point b) {
  return sqrt(sq(a.x - b.x) + sq(a.y - b.y));
}

point add(point p, vector v) {
  return p(p.x + v.x, p.y + v.y);
}

vector add(vector a, vector b) {
  return v(a.x + b.x, a.y + b.y);
}
