/*
* Class describing the agents in this model
* Each car contains information about its origin, destination, and path
* For the queueing model, each car also knows how much time left on the road
*/
public class Car
{
//  RoadNetwork roads;

  // Pathfinding information
  Node start;  
  Node end;
  // Stores path information as a list of roads, in order, that the car must move along
  ArrayList<Road> path = new ArrayList<Road>();

  // Queueing Model information
  // Keep track of current road and time left on road
  int currentIndex;
  float timeRemaining; // time left on road
  
  // For drawing
  boolean draw; // whether this car will be drawn
  color c;
  // PVector that will be updated with ever time step to show movement
  // This will also contain approximate information about location along road,
  // for visualization purposes
  PVector current = null;
  
  // Agent parameters information
  public int hurrCat; // Minimum category of hurricane which will require evacuation
  
  // Timing info (for validation)
  float startTime;
  float endTime;
  float totalTime = 0;
   
  
  public Car(PathPlanner pathPlanner, float startLat, float startLon, int hurrCat, boolean draw)
  {
    // Choose destination based on starting latitude
    // For each of the latitude ranges, choose randomly out of a few possible locations
    // Each of the destinations is a moderate city, 
    // which might be able to accomodate a large influx
    PVector end;
//    end = new PVector(42.226, -71.717); // for testing, if they all go to the same point
    if (startLat > 42.5) // North 
    {
      int randNum = int(random(0,4));
      switch (randNum)
      {
        case 0: // Lawrence
          end = new PVector(42.7070, -71.1631);
          break;
        case 1: // Haverhill
          end = new PVector(42.7762, -71.0773);
          break;
        default: // Lowell - slighly higher weighted because it is a large city
          end = new PVector(42.6334, -71.3162);
          break;
      }
    }
    else if (startLat > 42.35 && startLat < 42.5) // Middle 
    {
      int randNum = int(random(0,3));
      switch (randNum)
      {
        case 0: // Framingham
          end = new PVector(42.742, -71.207);
          break;
        case 1: // Fitchburg
          end = new PVector(42.5834, -71.8023);
          break;
        case 2: 
          if (startLat > 42.35) // Lowell
          {
            end = new PVector(42.6334, -71.3162);
          }
          else // Brockton
          {
            end = new PVector(42.0834, -71.0184);
          }
          break;
        default: // Worcester - slighly higher weighted because it is a large city
          end = new PVector(42.2626, -71.8023);
          break;
      }
    }
    else // South
    {
      int randNum = int(random(0,4));
      switch (randNum)
      {
        case 0: // Brockton
          end = new PVector(42.0834, -71.0184);
          break;
        case 1: // Franklin
          end = new PVector(42.0834, -71.3967);
          break;
        default: // Worcester
          end = new PVector(42.2626, -71.8023);
          break;
      }
    }
    
    this.path = pathPlanner.getPath(new PVector(startLat, startLon), end);
    this.draw = draw;
    this.hurrCat = hurrCat;
    
    // Variation in shades of the color, 
    // to make it easier for the eye to distinguish between points
    // and follow one point more easily
    int rand = int(random(150,235));
    this.c = color(rand);
//    this.c = color(255, int(random(100,255)), 0);
  }
  
  
  public Car(PathPlanner pathPlanner, PVector start, PVector end)
  {    
    this.path = pathPlanner.getPath(start, end);
    this.draw = true;
    this.hurrCat = 1;
    this.c = color(255, 255, 0);
    this.restart();
  }
  
  /*
  * Start cars from the origin again, for restarting the simulation
  * Reset path planning information
  */
  public void restart()
  {
    this.currentIndex = -1;
    if (path.size() > 0) // Make sure that a path exists, prevents errors
    {
      this.current = path.get(0).nodes[0].node;
      this.path.get(0).addCar(this);
    }
    this.startTime = millis();
    totalTime = 0;
  }

  ////////////////////////////////////////////////////////////// QUEUEING MODEL

  /*
  * Return the next road in the path, or null if the car is at the end
  */
  public Road getNextRoad()
  {
    if (this.currentIndex + 1 < this.path.size())
    {
      return path.get(this.currentIndex + 1);
    }
    else
    {
      return null;
    }
  }

  // Behavior for when the car gets accepted onto the next road
  public void moveOntoNextRoad()
  {
    // If already along the path, the remove the car from the current road
    if (currentIndex > -1)
    {
      path.get(currentIndex).cars.remove(this);
    }
    else // at end of path
    {
      this.endTime = millis();
    }
    // Update the index for the next road
    currentIndex++;
    // Update location for drawing
    current = path.get(this.currentIndex).nodes[0].node;
  }

  // Called by the road, to set the time left on that road until it reaches the end
  public void setTimeRemaining(float time)
  {
    this.timeRemaining = time;
  }

  // Return time remaining
  public float getTimeRemaining()
  {
    return this.timeRemaining;
  }
  
  ////////////////////////////////////////////////////////////// VISUALIZATION
  
  // Draw the car as a circle on the main map
  public void drawCar(MercatorMap mercatorMap)
  {
    if (draw)
    {
      stroke(c);
      strokeWeight(2.5);
      PVector point = mercatorMap.getScreenLocation(this.current);
      ellipse(point.x, point.y, 2.5, 2.5);
    }
  }
  
  // Draw the car using graphics
  public void drawCar(MercatorMap mercatorMap, PGraphics pg)
  {
    if (draw)
    {
      pg.fill(c);
      pg.noStroke();
      PVector point = mercatorMap.getScreenLocation(this.current);
      pg.ellipse(point.x, point.y, 5, 5);
    }
  }

}

