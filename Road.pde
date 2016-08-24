/*
* Class for each road, which are each an edge of the graph of roads
* Each road controls the queueing model behavior for the cars on itself
*/

import java.util.Iterator;

public class Road
{

  int speedLimit;
  int roadLength;
  int numLanes;
  int capacity;
  float oneCarLength = 7.5;
  float carLength; //meters
  int minTravelTime; // when everyone is at the speed limit, and no traffic, seconds
  ArrayList<Car> cars = new ArrayList<Car>();
  ArrayList<Car> waitlist = new ArrayList<Car>();
  Node[] nodes; // [start, end]

  public Road(Node start, Node end, int speedLimit, int numLanes, int carsPerAgent)
  {
//    this.timeStep = timeStep;t
    this.carLength = oneCarLength * carsPerAgent; // one agent Car represents multiple actual cars 
    this.speedLimit = speedLimit;
    this.numLanes = numLanes;
    this.roadLength = (int)MercatorMap.latlonToDistance(start.node, end.node);
    this.minTravelTime = roadLength / speedLimit; //seconds
    // Calculate capacity from http://svn.vsp.tu-berlin.de/repos/public-svn/publications/kn-old/queue/queue.pdf
    this.capacity = (int) (roadLength * numLanes / carLength);
    if (capacity == 0)
    {
      // TODO find a better way to deal with this
      capacity = 1;
    }

    this.nodes = new Node[] {
      start, end
    };
  }

  /* 
  * When a car wants to go onto a road, it has to wait in a waitlist before it can enter
  */
  public void addCar(Car car)
  {
    // Checks whether the car is already on the waitlist
    if (!car.getNextRoad().waitlist.contains(car))
    {
      waitlist.add(car);
    }
  }

  public int getStorageCapacity()
  {
    return capacity - cars.size();
  }

  /*
  * Contains main functionality of queueing model
  * In every time step, first process the waitlist to accept as many cars as possible onto road
  * Then move cars along road
  * When cars reach the end of the road, add them to the waitlist of the next road
  */
  // TODO add if one lane get stuck, the others can still move 
  public void moveCars(float timeStep, boolean print)
  {
    // Accept as many cars from the waitlist onto the road as possible 
    processWaitlist(timeStep, print);
    
    // Variables used for drawing
    PVector nextLoc = nodes[1].node; // The next place the car wants to move to
    // The maximum distance along the road that the car can move, based on the congestion conditions
    float maxMovingDist = speedLimit*timeStep - carLength; 
    
    // Iterator object because removing cars
    for (Iterator<Car> it = cars.iterator (); it.hasNext(); )
    {
      Car c = it.next(); // Cars moving along the queue
      c.totalTime += timeStep;

      // Change time information as car moves
      c.setTimeRemaining(c.getTimeRemaining() - timeStep);

      // If it is at the end of the road and the destination
      // at end of road: nodes[1].closeTo(c.current.x, c.current.y, int(carLength))
      if (c.getTimeRemaining() < 0 && c.getNextRoad() == null)
      {
        // Remove from road
        it.remove();
      } 
      // If it's not at the destination but is at the end of the road
//      else if (c.getTimeRemaining() < 0 && cars.indexOf(c) < numLanes)
//      {
//        // Add to the waitlist of the next road
//        c.getNextRoad().addCar(c);
//      } 
      // Otherwise, it is still moving along the road.
      // This calculates a location along the road for drawing purposes
      else // still on road
      {
        // The numlanes part is to allow theoretical passing from other lanes
        if (c.getTimeRemaining() < 0 && cars.indexOf(c) < numLanes*10)
        {
          // Add to the waitlist of the next road
          c.getNextRoad().addCar(c);
        }
        
        
        // The fraction between two points that the car will move
        float fraction;
        // The distance bewteen where it is, and where it wants to be
        float distToNextCar = MercatorMap.latlonToDistance(c.current, nextLoc);
        
        // If the car is immediately stuck behind the next car, it can't move
        if (distToNextCar < carLength)
        {
          // Do nothing
        } 
        // If car is able to continue at speed limit
        else if (distToNextCar > maxMovingDist)
        {
          fraction = speedLimit*timeStep / MercatorMap.latlonToDistance(c.current, nodes[1].node);
          c.current = MercatorMap.intermediate(c.current, nodes[1].node, fraction);
        } 
        // Conjested, moves just until the next car location
        else
        {
          fraction = (distToNextCar - carLength) / distToNextCar;
          c.current = MercatorMap.intermediate(c.current, nextLoc, fraction);
        }

      }
      nextLoc = c.current;
    }
  }

  /*
  * In every time step, allow as many cars to enter the road as possible
  * Accept them off the waitlist in the order they were added to the waitlist
  */
  public void processWaitlist(float timeStep, boolean print)
  {
    // Calculate number of cars that can enter the road in 1 timestep
    int numSpaces = (int)(timeStep*speedLimit/carLength);
    numSpaces = max(1, numSpaces); // Because of int rounding issues, change 0 to 1
    
    if (print && (waitlist.size()>0 || cars.size() >0))
    {
      println("[Road] capacity: " + capacity + " cars: " + cars.size() + " waitlist: " + waitlist.size());
    }

    // Loop through waitlist for entire list or number of allowed spaces, whichever is smaller
    for (int i = 0; i < min(numSpaces, waitlist.size()); i++)
    {
      // Check that the road as not yet reached its capacity
      if (cars.size() < capacity && waitlist.size()>0)
      {
        if (print)
        {
          println("[Road] numspaces: " + numSpaces);
        }
        Car c = waitlist.get(0);
        this.cars.add(c); // Add the car to the main road
        waitlist.remove(0); // Remove it from the waitlist
        c.moveOntoNextRoad(); // Calls the method in the car object to update agent on its own position
        c.setTimeRemaining(this.minTravelTime); // Set the travel time for the road
      }
    }
  }

  /* 
  * Draw the road on the main map
  */
  public void drawRoad(MercatorMap mercatorMap)
  { 
    stroke(#00aaff);
    strokeWeight(1);
    PVector Start = mercatorMap.getScreenLocation(nodes[0].node);
    PVector End = mercatorMap.getScreenLocation(nodes[1].node);
    line(Start.x, Start.y, End.x, End.y);
  }
  
  // Draws the lines to a PGraphic rather than screen
  public void drawRoadPGraphic(MercatorMap mercatorMap, PGraphics pg, color c, int opacity, int lineWeight)
  { 
    pg.stroke(c, opacity);
    pg.strokeWeight(lineWeight);
    PVector Start = mercatorMap.getScreenLocation(nodes[0].node);
    PVector End = mercatorMap.getScreenLocation(nodes[1].node);
    pg.line(Start.x, Start.y, End.x, End.y);
  }
}

