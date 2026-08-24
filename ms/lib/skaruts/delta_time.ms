
system.dt = 0  // delta time
system.frame = 0

_t1_ = system.time()

// call inside update, before everything else
dt_update = function()
  system.frame += 1
  local t2 = system.time()
  system.dt = (t2-_t1_)/1000
  _t1_ = t2
end