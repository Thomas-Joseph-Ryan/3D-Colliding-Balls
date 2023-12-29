ArrayList<Ball> balls;
ArrayList<PImage> textures;

// 0 being perfect, 1 being no bounce
float elasticity = 0.2;
int ballRadius = 100;

// Includes air and ground friction (basically a constant force moving against the ball) 
// 0 means no friction, 1 means infinite friction
float friction = 0.001;

void setup() {
  fullScreen(P3D);
  frameRate(60);
  balls = new ArrayList<Ball>();
  textures = new ArrayList<PImage>();
  PImage temp = loadImage("textures/peace.jpg");
  temp.resize(512, 512);
  textures.add(temp);
  temp = loadImage("textures/swirl.jpg");
  temp.resize(512, 512);
  textures.add(temp);
  temp = loadImage("textures/donut.png");
  temp.resize(512, 512);
  textures.add(temp);
  temp = loadImage("textures/triangles.png");
  temp.resize(512, 512);
  textures.add(temp);
}

void draw() {
  drawBackground();
  // translate(width/2, height/2, -width/2);
  drawBox();
  for (int i = 0; i < balls.size(); i++) {
    balls.get(i).update();
  }
  collide(balls);
}

void drawBackground() {
  background(0);
}

void drawBox() {
  pushMatrix();
  stroke(128);
  strokeWeight(5);
  noFill();
  translate(width/2, height/2, -width/2);
  box(width, height, width);
  popMatrix();
}

// Add a new ball to the list each time the mouse is clicked at mouseX and mouseY
void mousePressed() {
  createBall(mouseX, mouseY);
}

private void collide(ArrayList<Ball> balls) {
  for (int i = 0; i < balls.size(); i++) {
    Ball ball1 = balls.get(i);
    for (int j = i + 1; j < balls.size(); j++) {
      Ball ball2 = balls.get(j);
      float distance = dist(ball1.x, ball1.y, ball1.z, ball2.x, ball2.y, ball2.z);
      if (distance < ball1.radius + ball2.radius) {
        // Collision detected, apply simplistic kinematics
        float vX1 = ball1.vX;
        float vY1 = ball1.vY;
        float vZ1 = ball1.vZ;
        float vX2 = ball2.vX;
        float vY2 = ball2.vY;
        float vZ2 = ball2.vZ;
        float m1 = ball1.mass;
        float m2 = ball2.mass;
        float x1 = ball1.x;
        float y1 = ball1.y;
        float z1 = ball1.z;
        float x2 = ball2.x;
        float y2 = ball2.y;
        float z2 = ball2.z;
        // Calculate new velocities
        ball1.vX = ((m1 - m2) * vX1 + 2 * m2 * vX2) / (m1 + m2);
        ball1.vY = ((m1 - m2) * vY1 + 2 * m2 * vY2) / (m1 + m2);
        ball1.vZ = ((m1 - m2) * vZ1 + 2 * m2 * vZ2) / (m1 + m2);
        ball2.vX = ((m2 - m1) * vX2 + 2 * m1 * vX1) / (m1 + m2);
        ball2.vY = ((m2 - m1) * vY2 + 2 * m1 * vY1) / (m1 + m2);
        ball2.vZ = ((m2 - m1) * vZ2 + 2 * m1 * vZ1) / (m1 + m2);
        // Move balls out of each other
        float overlap = ball1.radius + ball2.radius - distance;
        float angle = atan2(y2 - y1, x2 - x1);
        ball1.x -= overlap * cos(angle);
        ball1.y -= overlap * sin(angle);
        ball2.x += overlap * cos(angle);
        ball2.y += overlap * sin(angle);
        
         
      }
    }
    // Check for collision with bounding box
    if (ball1.x - ball1.radius < 0 || ball1.x + ball1.radius > width) {
      ball1.vX *= -1 * (1 - elasticity);
      ball1.x = constrain(ball1.x, ball1.radius, width - ball1.radius);
    }
    if (ball1.y - ball1.radius < 0 || ball1.y + ball1.radius > height) {
      ball1.vY *= -1 * (1 - elasticity);
      ball1.y = constrain(ball1.y, ball1.radius, height - ball1.radius);
    }
    if (ball1.z - ball1.radius < -width || ball1.z + ball1.radius > 0) {
      ball1.vZ *= -1 * (1 - elasticity);
      ball1.z = constrain(ball1.z, -width + ball1.radius, -ball1.radius);
    }
  }
}

void createBall(float x, float y) {
  // Randomly select a texture
  int textureIndex = (int) random(textures.size());
  balls.add(new Ball(x, y, ballRadius, textures.get(textureIndex)));
}

class Ball
{
  private float x;
  private float y;
  private float z;
  private int radius;
  private float vX;
  private float vY;
  private float vZ;
  private float spinX;
  private float spinY;
  private float spinZ;
  
  private float initialVelocityScaler = 10;
  // Interacts with initialVelocityScaler aswell
  private float initialZVelocityScale = 0.5;
  
// This velocity is used to bring the ball to a halt to reduce jumpyness.
  private float stopVelocity = 5;
  
  private float spinFactor = 0.01;

  private float gravity = 0.2;
  private float mass = 1;
  
  PShape sphere;

  Ball(float x, float y, int radius, PImage texture) {
  this.x = x;
  this.y = y;
  this.z = - radius - 1;
  this.radius = radius;
  this.vX = random(-initialVelocityScaler, initialVelocityScaler);
  this.vY = random(-initialVelocityScaler, initialVelocityScaler);
  this.vZ = -initialVelocityScaler * initialZVelocityScale;
  this.spinX = 0;
  this.spinY = 0;
  this.spinZ = 0;
  this.sphere = createShape(SPHERE, radius);
  this.sphere.setTexture(texture);
  this.sphere.setStroke(false);
  }

  private boolean touchingGround() {
    int errorMargin = 10;
    return this.y + this.radius + errorMargin >= height;
  }


  public void update()
  {
    tick();
    draw();
  }
  
  private void draw() {
   pushMatrix();
   translate(this.x, this.y, this.z);
   this.sphere.rotateX(this.spinX);
   this.sphere.rotateY(this.spinY);
   this.sphere.rotateZ(this.spinZ);
   shape(this.sphere);
   popMatrix();
  }
  
  private void tick() {
    this.x += this.vX;
    this.y += this.vY;
    this.z += this.vZ;

    
    
     // Update spin based on velocity in each direction
    this.spinX = this.vX * this.spinFactor;
    this.spinY = this.vY * this.spinFactor;
    this.spinZ = this.vZ * this.spinFactor;
    
    this.vX *= 1 - friction;
    this.vY *= 1 - friction;
    this.vZ *= 1 - friction;

    // if (!touchingGround()) {
      // Apply gravity
    this.vY += this.gravity;
    // }

    if ((abs(this.vX) + abs(this.vY) + abs(this.vZ)) < this.stopVelocity && touchingGround()) {
      // Decrement velocities by a small amount to bring the ball to a halt

      // Make it so if the ball has a negative velocity, we add 0.5, and if it has a positive velocity, we subtract 0.5
      if (this.vX < 0) {
        this.vX += 0.5;
      } else if (this.vX > 0) {
        this.vX -= 0.5;
      }
      if (this.vY < 0) {
        this.vY += 0.5;
      } else if (this.vY > 0) {
        this.vY -= 0.5;
      }
      if (this.vZ < 0) {
        this.vZ += 0.5;
      } else if (this.vZ > 0) {
        this.vZ -= 0.5;
      }

      // If the velocities are small enough, set them to 0
      if (abs(this.vX) < 0.15) {
        this.vX = 0;
      }
      if (abs(this.vY) < 0.15) {
        this.vY = 0;
      }
      if (abs(this.vZ) < 0.15) {
        this.vZ = 0;
      }
    }
  }
}
