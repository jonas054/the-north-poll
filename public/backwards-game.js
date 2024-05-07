const canvas = document.getElementById('gameCanvas');
const ctx = canvas.getContext('2d');

// Set canvas dimensions to fit the entire page
canvas.width = window.innerWidth;
canvas.height = window.innerHeight;

const CANVAS_DIAGONAL_LENGTH = Math.sqrt(canvas.width * canvas.width + canvas.height * canvas.height);
const START_DISTANCE = Math.max(canvas.width, canvas.height);
const CENTER = { x: canvas.width / 2, y: canvas.height / 2 };
const INITIAL_OBJECT_SIZE = 80;
const INITIAL_NUMBER_OF_OBJECTS = 1;
const SPAWN = 0.5;
const MAX_BRIGHTNESS = 200;
const SKEW_FACTOR = 20;
const SLOWNESS = 20;

let objects = [];

const random = max => Math.random() * max;
const randomBrightness = () => random(MAX_BRIGHTNESS);

function createObject() {
  let obj = getRandomXYFromCenter(CENTER);
  const s = () => (Math.random() - 0.5) * SKEW_FACTOR;
  obj.skew = { x: s(), y: s() };

  objects.push({
    ...obj,
    direction: setDirection(obj),
    radius: INITIAL_OBJECT_SIZE / 2,
    color: `rgb(${randomBrightness()}, ${randomBrightness()}, ${randomBrightness()})`,
  });
}

const setDirection = obj => ({
  x: (CENTER.x - obj.x) / (SLOWNESS + obj.skew.x),
  y: (CENTER.y - obj.y) / (SLOWNESS + obj.skew.y)
});

function draw() {
  ctx.clearRect(0, 0, canvas.width, canvas.height); // Clear canvas before redrawing

  objects.forEach(obj => {
    obj.x += obj.direction.x;
    obj.y += obj.direction.y;
    obj.direction = setDirection(obj);
    obj.radius = INITIAL_OBJECT_SIZE * Math.sqrt(distanceSquared(obj, CENTER)) / CANVAS_DIAGONAL_LENGTH;
  });

  objects = objects.filter(obj => obj.radius > 0.1);
  objects.forEach(obj => drawOnCanvas(obj));

  for (let i = 0; Math.random() < SPAWN; i++) {
     createObject();
  }

  if (objects.length > 0) {
    window.requestAnimationFrame(draw); // Call draw again for animation
  } else {
    console.log('Game over!');
  }
}

function drawOnCanvas(obj) {
  ctx.beginPath();
  ctx.arc(obj.x, obj.y, obj.radius, 0, Math.PI * 2, true); // Use 0 and 2*PI for a full circle
  ctx.fillStyle = obj.color;
  ctx.fill();
}

function distanceSquared(a, b) {
  const distanceX = a.x - b.x;
  const distanceY = a.y - b.y;
  return distanceX * distanceX + distanceY * distanceY;
}

function getRandomXYFromCenter(center) {
  const angle = random(2 * Math.PI);
  const x = center.x + START_DISTANCE * Math.cos(angle);
  const y = center.y + START_DISTANCE * Math.sin(angle);
  return { x, y };
}

for (let i = 0; i < INITIAL_NUMBER_OF_OBJECTS; i++) {
  createObject();
}
draw(); // Start the animation loop
