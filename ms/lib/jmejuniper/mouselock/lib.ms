// init some variables
mouse.relx = 0
mouse.rely = 0
mouse.locked = 0

// js
system.javascript("
  // get the canvas
  var canvas = document.querySelector('canvas');
  
  // callback functions
  function updatePosition(mse) {
    global.mouse.relx = mse.movementX;
    // negative movementY because of microstudio's coordinate grid
    global.mouse.rely = -mse.movementY;
  }
  function toggleMove() {
    // handle lock toggling
    if (document.pointerLockElement == canvas) {
      global.mouse.locked = 1
      canvas.addEventListener('mousemove', updatePosition);
    } else {
      global.mouse.locked = 0
      canvas.removeEventListener('mousemove', updatePosition);
    }
  }
  
  // lock mouse pointer
  canvas.onclick = function() {
    canvas.requestPointerLock();
  };
  document.addEventListener('pointerlockchange', toggleMove);
")

// stop relx and rely when mouse stops
every 24 milliseconds do
  mouse.relx = 0
  mouse.rely = 0
end
