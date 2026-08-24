
t1 = system.time()/1000
dt = 0  // delta time
f = -1
// call inside update, before everything else
t_update = function()
  f += 1
  local t2 = system.time()/1000
  dt = t2-t1
  t1 = t2
end
