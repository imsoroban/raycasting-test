

init_settings = function()
  input.bind("move_forward",  ["key_w",       "gp_lsu",          ])
  input.bind("move_backward", ["key_s",       "gp_lsd",          ])
  input.bind("move_left",     ["key_a",       "gp_lsl",          ])
  input.bind("move_right",    ["key_d",       "gp_lsr",          ])
  input.bind("turn_left",     ["arrow_left",  "gp_rsl",          ])
  input.bind("turn_right",    ["arrow_right", "gp_rsr",          ])
  input.bind("turn_around",   ["arrow_down",  "gp_a",            ])
  input.bind("shoot",         ["ctrl",        "space", "mouse1", "gp_x", "gp_rb" ])
  input.bind("debug",         ['\\',          '~',     "gp_view"])
  
  debug.active = true
  debug.manual_input = true
  draw_3d = true // you can switch this in the console for debugging
  use_mouse = true
  
  
  // TODO: this makes sprites drift on the floor while player is turning
  // at higher FOVs
  fix_distortions = false
  
  
  SS = 1     // screen scale (use '2' to double the resolution)
  
  
  // The tile size calculations were meant to make the screen fit an exact 
  // number of tiles to better display the 2D map during the first steps 
  // in development, but I decided to keep it. 
  TS = 10     // tile size (should also use SS)
  SW = 32*TS  // screen width
  SH = 20*TS  // screen height
  
  
  RW = SW*SS // resolution width
  RH = SH*SS // resolution height
  
  FOV = deg2rad(70)
  HALF_FOV = FOV/2 // theta
  
  
  printf("resolution: %s, %s", [RW, RH] )
  
  HALF_W = floor(RW/2)
  HALF_H = floor(RH/2)
  
  // res = object
  //   w = RW
  //   h = RH
  // end
  
  FPS = 60
  
  img_buffer = new Image(RW, RH)
  
  
  NUM_RAYS = floor((RW)/2) // ideally RW?
  HALF_NUM_RAYS = floor(NUM_RAYS/2)
  DELTA_ANGLE = FOV / NUM_RAYS
  MAX_DEPTH = 20
  
  SCR_DIST = HALF_W / tan(HALF_FOV)
  SCALE = floor(RW / NUM_RAYS)
  
  
  TEX_SIZE = 32
  HALF_TEX_SIZE = floor(TEX_SIZE/2)
  PLAYER_SCALE = 90
  
  MOUSE_SENS = 0.1 / SS
  // MOUSE_MAX_REL = 40
  // MOUSE_BORDER = 100

  // last_mouse_x = 0
  // mouse_visible = true
  
  sky_offset = 0
  
  // img_buffer.setPixelated(false)
  // screen.setPixelated(false)
end


// to change the fov at runtime use this
// (can be typed in the console)
set_fov = function(new_fov)
  FOV = deg2rad(new_fov)
  HALF_FOV = FOV/2 // theta
  SCR_DIST = HALF_W / tan(HALF_FOV)
  
  DELTA_ANGLE = FOV / NUM_RAYS
end