/*
* Node of the graph of the road network
* Contains functionality to help with path planning
*/
public class Node
{
  PVector node; // lat lon coordinates of the node
  // List of all roads that have this node as one endpoint
  ArrayList<Road> adjRoads = new ArrayList<Road>(); 
  // List of all adjacent nodes, that are connected to this node by a road
  ArrayList<Node> adjNodes = new ArrayList<Node>();
  
  public Node(PVector p)
  {
    this.node = p;
  }
  
  public Node(float x, float y)
  {
    this.node = new PVector(x, y);
  }
  
  // Check whether this node is located at the x,y coordinates given
  public boolean equals(float x, float y)
  {
    if (node.x == x && node.y == y)
    {
      return true;
    }
    else
    {
      return false;
    }
  }
  
  // Check whether this node is equal to the node n
  public boolean equals(Node n)
  {
    if (node.x == n.node.x && node.y == n.node.y)
    {
      return true;
    }
    else
    {
      return false;
    }
  }

  /*
  * Checks whether the lat lon coordinates are close to this node
  * threshold is the distance, in meters, that constitues as close enough
  */
  public boolean closeTo(float x, float y, int threshold)
  {
    if (MercatorMap.latlonToDistance(node, new PVector(x,y)) < threshold) // kind of arbitraty number of meters
    {
      return true;
    }
    else
    {
      return false;
    }
  }
  
  // From the list of adjacent roads, extract all the adjacent nodes
  public void calcAdjNodes()
  {
    for (Road r: adjRoads)
    {
      for (int i = 0; i < r.nodes.length; i++)
      {
        // If the node is not this, and has not already been added to adjNodes
        if (!r.nodes[i].equals(this) && !adjNodes.contains(r.nodes[i]))
        {
          this.adjNodes.add(r.nodes[i]);
        }
      }
    }
  }
  
  // Draw the node on the main map
  public void drawNode(MercatorMap mercatorMap)
  {
    stroke(#ff0000);
    strokeWeight(2);
    PVector point = mercatorMap.getScreenLocation(node);
    ellipse(point.x, point.y, 2, 2);  
  }
  
  // Get the road between this node and the n2
  public Road getConnectingRoad(Node n2)
  {
    for (Road r: adjRoads)
    {
      if (r.nodes[0].equals(n2) || r.nodes[1].equals(n2))
      {
        return r;
      }
    }
    return null;
  }
  
}
