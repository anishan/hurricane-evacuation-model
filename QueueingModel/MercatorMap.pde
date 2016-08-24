/*
 * Utility class to convert between geo-locations and Cartesian screen coordinates.
 * Can be used with a bounding box defining the map section.
 
 * (c) 2011 Till Nagel, tillnagel.com
 */
public static class MercatorMap {
  
  public static final float DEFAULT_TOP_LATITUDE = 80;
  public static final float DEFAULT_BOTTOM_LATITUDE = -80;
  public static final float DEFAULT_LEFT_LONGITUDE = -180;
  public static final float DEFAULT_RIGHT_LONGITUDE = 180;
  
  /** Horizontal dimension of this map, in pixels. */
  protected float mapScreenWidth;
  /** Vertical dimension of this map, in pixels. */
  protected float mapScreenHeight;

  /** Northern border of this map, in degrees. */
  protected float topLatitude;
  /** Southern border of this map, in degrees. */
  protected float bottomLatitude;
  /** Western border of this map, in degrees. */
  protected float leftLongitude;
  /** Eastern border of this map, in degrees. */
  protected float rightLongitude;

  private float topLatitudeRelative;
  private float bottomLatitudeRelative;
  private float leftLongitudeRadians;
  private float rightLongitudeRadians;

  public MercatorMap(float mapScreenWidth, float mapScreenHeight) {
    this(mapScreenWidth, mapScreenHeight, DEFAULT_TOP_LATITUDE, DEFAULT_BOTTOM_LATITUDE, DEFAULT_LEFT_LONGITUDE, DEFAULT_RIGHT_LONGITUDE);
  }
  
  /**
   * Creates a new MercatorMap with dimensions and bounding box to convert between geo-locations and screen coordinates.
   *
   * @param mapScreenWidth Horizontal dimension of this map, in pixels.
   * @param mapScreenHeight Vertical dimension of this map, in pixels.
   * @param topLatitude Northern border of this map, in degrees.
   * @param bottomLatitude Southern border of this map, in degrees.
   * @param leftLongitude Western border of this map, in degrees.
   * @param rightLongitude Eastern border of this map, in degrees.
   */
  public MercatorMap(float mapScreenWidth, float mapScreenHeight, float topLatitude, float bottomLatitude, float leftLongitude, float rightLongitude) {
    this.mapScreenWidth = mapScreenWidth;
    this.mapScreenHeight = mapScreenHeight;
    this.topLatitude = topLatitude;
    this.bottomLatitude = bottomLatitude;
    this.leftLongitude = leftLongitude;
    this.rightLongitude = rightLongitude;

    this.topLatitudeRelative = getScreenYRelative(topLatitude);
    this.bottomLatitudeRelative = getScreenYRelative(bottomLatitude);
    this.leftLongitudeRadians = getRadians(leftLongitude);
    this.rightLongitudeRadians = getRadians(rightLongitude);
  }

  /**
   * Projects the geo location to Cartesian coordinates, using the Mercator projection.
   *
   * @param geoLocation Geo location with (latitude, longitude) in degrees.
   * @returns The screen coordinates with (x, y).
   */
   
   
  public PVector getScreenLocation(PVector geoLocation) {
    float latitudeInDegrees = geoLocation.x;
    float longitudeInDegrees = geoLocation.y;
    return new PVector(getScreenX(longitudeInDegrees), getScreenY(latitudeInDegrees));
  }
  
  private float getScreenYRelative(float latitudeInDegrees) {
    return log(tan(latitudeInDegrees / 360f * PI + PI / 4));
  }

  protected float getScreenY(float latitudeInDegrees) {
    return mapScreenHeight * (getScreenYRelative(latitudeInDegrees) - topLatitudeRelative) / (bottomLatitudeRelative - topLatitudeRelative);
  }
  
  private float getRadians(float deg) {
    return deg * PI / 180;
  }

  protected float getScreenX(float longitudeInDegrees) {
    float longitudeInRadians = getRadians(longitudeInDegrees);
    return mapScreenWidth * (longitudeInRadians - leftLongitudeRadians) / (rightLongitudeRadians - leftLongitudeRadians);
  }

  
  // Added by Anisha
  // Find distance between two points from their lat lon coordinates
  // Using haversine from http://www.movable-type.co.uk/scripts/latlong.html
  public static float latlonToDistance(PVector p1, PVector p2)
  {
    int R = 6371000; // meters
    float phi1 = radians(p1.x); // convert to radians
    float phi2 = radians(p2.x); // convert to radians
    float deltaPhi = radians(p2.x - p1.x);
    float deltaLambda = radians(p2.y - p1.y);

    float a = sin(deltaPhi/2) * sin(deltaPhi/2) + cos(phi1) * cos(phi2) * sin(deltaLambda/2) * sin(deltaLambda/2);
    float c = 2 * atan2(sqrt(a), sqrt(1-a));

    float d = R * c;
    return d;    
  }
  
  // Find an intermediate point at a given fraction between two points
  // Smaller fractions are closer to p1
  public static PVector intermediate(PVector p1, PVector p2, float fraction)
  {
    int R = 6371000; // meters

    float angularDist = latlonToDistance(p1, p2)/R;
    float phi1 = radians(p1.x); // convert to radians
    float phi2 = radians(p2.x); // convert to radians
    float lambda1 = radians(p1.y); // convert to radians
    float lambda2 = radians(p2.y); // convert to radians
    
    float a = sin((1-fraction)*angularDist)/sin(angularDist);
    float b = sin(fraction*angularDist)/sin(angularDist);
    float x = (a*cos(phi1)*cos(lambda1)) + (b*cos(phi2)*cos(lambda2));
    float y = (a*cos(phi1)*sin(lambda1)) + (b*cos(phi2)*sin(lambda2));
    float z = (a*sin(phi1)) + (b*sin(phi2));
    
    float phiNew = atan2(z, sqrt(x*x + y*y));
    float lambdaNew = atan2(y,x);
    
    float xNew = degrees(phiNew);
    float yNew = degrees(lambdaNew);
    
    return new PVector(xNew, yNew);
    
  }
  
  // Find a point a distance (in meters away) in the direction given by the bearing
  // from the point p1
  public static PVector endpoint(PVector p1, float distance, float bearing)
  {
    int R = 6371000; // meters

    float angularDist = distance/R;
    float phi1 = radians(p1.x); // convert to radians
    float lambda1 = radians(p1.y); // convert to radians
    
    bearing = radians(bearing);
    
    float phi2 = asin(sin(phi1)*cos(angularDist) + cos(phi1)*sin(angularDist)*cos(bearing));
    float lambda2 = lambda1 + atan2(sin(bearing)*sin(angularDist)*cos(phi1), cos(angularDist) - sin(phi1)*sin(phi2));
  
    
    float xNew = degrees(phi2);
    float yNew = degrees(lambda2);
    
    return new PVector(xNew, yNew);
  }

}
