/*
* Class to do pathplanning, and store previously calculated paths
*/
public class PathPlanner
{
  // RoadNetwork is a graph of nodes and edges (Roads)
  public RoadNetwork roads;
  // List of all paths already calculated (each path is a list of Roads)
  public ArrayList<ArrayList<Road>> paths = new ArrayList<ArrayList<Road>>();
  // The start and end node of each path
  // corresponding by indicies
  // (so the path at index i has the ith start node and the ith end node
  public ArrayList<Node> startNode = new ArrayList<Node>();
  public ArrayList<Node> endNode = new ArrayList<Node>();
  
  // Initializes and saves the road network
  // but doesn't do the pathplanning until method is called by agents
  public PathPlanner(RoadNetwork roadNetwork)
  {
    this.roads = roadNetwork;
  }
  
  
  ////////////////////////////////////////////////////////////// PATHFINDING
  
  /*
  * Returns a path from the start to the end
  * startPt: lat and lon of starting point
  * endPt: lat and lon of end point
  * returns: list of roads from start to finish
  */
  public ArrayList<Road> getPath(PVector startPt, PVector endPt)
  {
    // Get the nodes of the graph (road network) closest to the given lat lon
    Node start = roads.getClosestNode(startPt.x, startPt.y);
    Node end = roads.getClosestNode(endPt.x, endPt.y);
    
    // Check if path already exists, to reduce computational load
    for (int i = 0; i < paths.size(); i++)
    {
      // If there is already a path between the same start and end nodes
      if (startNode.get(i).equals(start) && endNode.get(i).equals(end))
      {
        return paths.get(i);
      }
      
    }
    
    // If the path hasn't been calculated already, create a path
    ArrayList<Node> pathNode = makePath(start, end);
    ArrayList<Road> pathRoad = nodesToRoads(pathNode);
    
    // Add path to memory
    paths.add(pathRoad);
    startNode.add(start);
    endNode.add(end);
    
    // Return path
    return pathRoad;
    
  }
  
  /* 
  * Helper function for pathfinding that sets the weights for each node
  * in the graph from start to finish
  */
  public Integer[] setWeights(Node start, Node end)
  {
    // In terms of the index in the road network graph
    int startIndex = roads.nodes.indexOf(start);
    int endIndex = roads.nodes.indexOf(end);

    // Initialize arrays
    int networkSize = roads.nodes.size();
    float[] totalDist = new float[networkSize];
    Integer[] previous = new Integer[networkSize];
    boolean[] visited = new boolean[networkSize];

    // Set initial distances to infinity and not visited
    for (int i = 0; i < networkSize; i++)
    {
      totalDist[i] = Float.MAX_VALUE;
      visited[i] = false;
    }

    // Distance from start to start is 0
    totalDist[startIndex] = 0;

    // Go through all nodes in the the network
    for (int i = 0; i < networkSize; i++)
    {
      // Select the next node to use as a starting point
      float dist = Float.MAX_VALUE;
      int nextIndex = -1;
      for (int j = 0; j < networkSize; j++)
      {
        // Find the node with least distance out of those not visited yet
        if (!visited[j] && totalDist[j]<=dist)
        {
          nextIndex = j; // changed i to j
          dist = totalDist[j];
        }
      }
      
      visited[nextIndex] = true;

      // Loop through neighbors of that node
      for (int j = 0; j < roads.nodes.get (nextIndex).adjNodes.size(); j++)
      {
        Node neighbor = roads.nodes.get(nextIndex).adjNodes.get(j);
        int neighborIndex = roads.nodes.indexOf(neighbor);
        // Find distance between the nodes
        float d = totalDist[nextIndex] + roads.nodes.get(nextIndex).getConnectingRoad(neighbor).roadLength;
        // Whichever neighbor gives the least distance, set that to previous
        if (totalDist[neighborIndex] >= d && !visited[neighborIndex])
        {
          totalDist[neighborIndex] = d;
          previous[neighborIndex] = nextIndex;
        }
      }
    }
    return previous;
  }

  /* 
  * Make the path between two nodes of the graph
  * returns: a list of nodes from start to finish
  */
  public ArrayList<Node> makePath(Node start, Node end)
  {
    int startIndex = roads.nodes.indexOf(start);
    int endIndex = roads.nodes.indexOf(end);
    Integer[] previous = setWeights(start, end);

    ArrayList<Integer> pathIndex = new ArrayList<Integer>();
    ArrayList<Node> pathNode = new ArrayList<Node>();

    // Go through the weighted list and build a path backwards
    // Based on the index of the previous node
    int prevIndex = endIndex;
    while (prevIndex != startIndex)
    {
      pathIndex.add(0,prevIndex);
      prevIndex = previous[prevIndex];
    }
    pathIndex.add(0,startIndex);
    
    // Turn the indices into node
    for (int i = 0; i < pathIndex.size(); i++)
    {
      pathNode.add(roads.nodes.get(pathIndex.get(i)));
    }

      return pathNode;
  }


  // Takes an arraylist of nodes and converts it to the roads between each
  public ArrayList<Road> nodesToRoads(ArrayList<Node> nodes)
  {
    ArrayList<Road> pathRoad = new ArrayList<Road>();
    // Loop throught all nodes in path
    for (int i = 0; i < nodes.size ()-1; i++)
    {
      Node n = nodes.get(i);
      // Loop through all roads connected to that node
      for (Road r : n.adjRoads)
      {
        // Check whether that road correctly connects to the next node in the path
        if (r.nodes[1].equals(nodes.get(i+1)))
        {
          pathRoad.add(r);
          break;
        }
      }
    }
    return pathRoad;
  }
  
  
  
}
