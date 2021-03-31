# BOIDS! (Craig Reynolds' Flocking)

## An implementation in Processing by Kaylah Facey

### Commands

* space bar - Start or stop the simulation (default stopped).
* left mouse held down - continuous attraction (in attraction mode) or repulsion (in repulsion mode):
  * a - Switch to attraction mode (default).
  * r - Switch to repulsion mode.
* s - Cause all boids to be instantly scattered to random positions in the window, and with random directions.
* p - Toggle whether to have creatures leave a path, that is, whether the window is cleared each display step or not (default off).
* c - Clear the screen, but do not delete any boids. (This can be useful when creatures are leaving paths.)
* 1-4 - Toggle forces on/off (default on):
  * 1 - flock centering
  * 2 - velocity matching
  * 3 - collision avoidance
  * 4 - wandering
* Spawn and Kill:
  * +/= - Spawn (add one new boid to the simulation)
  * (minus sign) - Kill (Remove one boid from the simulation) (down to 0).

### Custom Commands

* right mouse held down - do the opposite of the left mouse (repulsion in attraction mode, attraction in repulsion mode)

## Extras

* Multiple boid species:
  * "Active" species controls what species appear on screen (inactive species don't affect the simulation)
  * "+/-" species is the species that the "spawn" and "kill" buttons (or +/- keys) control the population of.
  * Initially there are no blue or grey boids, those must be activated and added to to use.
  * Blue boids don't flock with orange boids but otherwise don't behave differently.
  * Grey boids are bigger and chase blue and orange boids. Blue and orange boids flee them, for a predator/prey dynamic.

## FUTURE IDEAS

* Implement 3D flocking.
* Allow predators to eat prey.
* Include fixed collision objects for the creatures to steer around.
* food/resources/shelter
* Use a grid or Voronoi/Dalauney triangles to only consider the closest neighborhood of boids.
* boid colour variation
