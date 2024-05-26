const canvas = document.getElementById('gameCanvas');
const ctx = canvas.getContext('2d');

// Set canvas dimensions to fit the entire page
canvas.width = window.innerWidth;
canvas.height = window.innerHeight;

const CANVAS_DIAGONAL_LENGTH = Math.sqrt(canvas.width * canvas.width + canvas.height * canvas.height);
const START_DISTANCE = Math.max(canvas.width, canvas.height);
const CENTER = { x: canvas.width / 2, y: canvas.height / 2 };
let initialObjectSize = 80;
let spawn = 0.5;
let maxBrightness = 255;
let centerMessage = { text: '' };
let skewFactor = 20;
let slowness = 20;

let objects = [];
let timer = null;

const random = max => Math.random() * max;
const randomBrightness = () => random(maxBrightness);

function createObject() {
  let obj = getRandomXYFromCenter(CENTER);
  const s = () => (Math.random() - 0.5) * skewFactor;
  obj.skew = { x: s(), y: s() };

  objects.push({
    ...obj,
    direction: setDirection(obj),
    initialSize: initialObjectSize,
    radius: initialObjectSize / 2,
    color: `rgb(${randomBrightness()}, ${randomBrightness()}, ${randomBrightness()})`,
  });
}

function showMessage(message) {
  centerMessage = { text: message, brightness: 255 };
  if (timer) {
    clearInterval(timer);
  }
  timer = setInterval(() => {
    if (centerMessage.brightness > 10) {
      centerMessage.brightness -= 5;
    } else {
      centerMessage.text = '';
      clearInterval(timer);
    }
  }, 50);
}

const roundTo3DecimalPlaces = number => Math.round(number * 1000) / 1000;
const increase = value => Math.round(value * 3 / 2);
const decrease = value => Math.round(value * 2 / 3);

const adjustments = {
  '1': () => `1: Darker (${maxBrightness = decrease(maxBrightness)})`,
  '2': () => `2: Brighter (${maxBrightness += Math.round((255 - maxBrightness) / 3)})`,
  '3': () => `3: Smaller (${initialObjectSize = decrease(initialObjectSize)})`,
  '4': () => `4: Larger (${initialObjectSize = increase(initialObjectSize)})`,
  '5': () => `5: Fewer (${spawn = roundTo3DecimalPlaces(spawn * 2 / 3)})`,
  '6': () => `6: More (${spawn = roundTo3DecimalPlaces(spawn + (0.99 - spawn) / 3)})`,
  '7': () => `7: Less skew (${skewFactor = decrease(skewFactor)})`,
  '8': () => `8: More skew (${skewFactor = increase(skewFactor)})`,
  '9': () => `9: Slower (${slowness = increase(slowness)})`,
  '0': () => `0: Faster (${slowness = decrease(slowness)})`
};
const titles = {
  1: 'Darker',
  2: 'Brighter',
  3: 'Smaller',
  4: 'Larger',
  5: 'Fewer',
  6: 'More',
  7: 'Less skew',
  8: 'More skew',
  9: 'Slower',
  10: 'Faster'
};

document.addEventListener('keydown', function(event) {
  const textFn = adjustments[event.key];
  if (textFn) {
    showMessage(textFn());
  }
});

canvas.addEventListener('click', function(event) {
  // Show a table of plus and minus buttons that will have the same effects as the keyboard keys 0-9.
  // The table should be centered in the canvas and have a background color of rgba(0, 0, 0, 0.5).
  // The table should be removed when the user clicks anywhere on the canvas.
  const table = document.createElement('table');
  table.style.position = 'absolute';
  table.style.top = `${canvas.height / 2 - 100}px`;
  table.style.left = `${canvas.width / 2 - 100}px`;
  table.style.backgroundColor = 'rgba(0, 0, 0, 0.4)';
  table.style.color = 'white';
  table.style.padding = '20px';
  table.style.borderRadius = '10px';
  table.style.zIndex = '1';
  table.style.cursor = 'pointer';
  table.addEventListener('click', function() {
    table.remove();
  });
  // Add buttons inside the table.
  for (let i = 1; i <= 5; i++) {
    const tr = document.createElement('tr');

    // Create minus td
    const tdMinus = document.createElement('td');
    tdMinus.textContent = titles[(i - 1) * 2 + 1];
    tdMinus.style.padding = '5px';
    tdMinus.style.textAlign = 'left';
    tdMinus.style.cursor = 'pointer';
    tdMinus.addEventListener('click', function() {
      const textFn = adjustments[((i % 10 - 1) * 2 + 1).toString()];
      showMessage(textFn());
    });
    tr.appendChild(tdMinus);

    // Create plus td
    const tdPlus = document.createElement('td');
    tdPlus.textContent = titles[i * 2];
    tdPlus.style.padding = '5px';
    tdPlus.style.textAlign = 'left';
    tdPlus.style.cursor = 'pointer';
    tdPlus.addEventListener('click', function() {
      const textFn = adjustments[((i % 10) * 2).toString()];
      showMessage(textFn());
    });
    tr.appendChild(tdPlus);

    table.appendChild(tr);
  }
  // Show the table on the canvas
  canvas.parentElement.appendChild(table);
});

function draw() {
  const drawOnCanvas = obj => {
    ctx.beginPath();
    ctx.arc(obj.x, obj.y, obj.radius, 0, Math.PI * 2, true); // Use 0 and 2*PI for a full circle
    ctx.fillStyle = obj.color;
    ctx.fill();
  };

  ctx.clearRect(0, 0, canvas.width, canvas.height); // Clear canvas before redrawing

  objects.forEach(obj => {
    obj.x += obj.direction.x;
    obj.y += obj.direction.y;
    obj.direction = setDirection(obj);
    obj.radius = obj.initialSize * Math.sqrt(distanceSquared(obj, CENTER)) / CANVAS_DIAGONAL_LENGTH;
  });

  const withinLimit = coordinate => Math.abs(coordinate) < START_DISTANCE * 3 / 2;

  objects = objects.filter(obj => obj.radius > 0.1 && withinLimit(obj.x) && withinLimit(obj.y));
  objects.forEach(obj => drawOnCanvas(obj));

  if (random(100) < 1) {
    console.log('number of objects: ', objects.length);
  }

  for (let i = 0; Math.random() < spawn; i++) {
    createObject();
  }

  if (centerMessage.text) {
    ctx.font = '48px serif';
    ctx.textAlign = 'center';
    ctx.fillStyle = `rgb(${centerMessage.brightness}, ${centerMessage.brightness}, ${centerMessage.brightness})`
    ctx.fillText(centerMessage.text, canvas.width / 2, canvas.height / 2);
  }

  if (objects.length > 0) {
    window.requestAnimationFrame(draw); // Call draw again for animation
  } else {
    console.log('Game over!');
  }
}

const setDirection = obj => ({
  x: (CENTER.x - obj.x) / (slowness + obj.skew.x),
  y: (CENTER.y - obj.y) / (slowness + obj.skew.y)
});

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

showMessage('Space Balls');
createObject(); // Initial object
draw(); // Start the animation loop
