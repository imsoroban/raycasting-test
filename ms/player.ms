spinning = false

Player = class
  constructor = function(x, y, dir=0)
    this.x = x + 0.5 // 1.5
    this.y = y + 0.5 // 5
    this.rot = fmod(dir, 2*PI)
    this.rot_speed = 0
    this.max_rot_speed = 4
    this.speed = 1.35
    this.target_rot = 'nil'
    this.weapon = new Shotgun()
  end
  
  // get_pos = function()
  //   return vec(this.x, this.y)
  // end
  
  // get_map_pos = function()
  //   return this.get_pos().floored()
  // end

  movement = function()
    local sin_a = sin(this.rot)
    local cos_a = cos(this.rot)
    local dx = 0
    local dy = 0
    
    local speed = this.speed * system.dt
    local speed_sin = speed * sin_a
    local speed_cos = speed * cos_a
    
    if mouse.locked then
      if input.action_pressed("shoot") then
        this.weapon.shoot()
      end
      
      if input.action_down("move_forward") then
        dx += speed_cos
        dy += speed_sin
      end
      
      if input.action_down("move_backward") then
        dx += -speed_cos
        dy += -speed_sin
      end
      print(input.action_down("move_left"))
      
      if input.action_down("move_left") then
        dx += speed_sin
        dy += -speed_cos
      end
      
      if input.action_down("move_right") then
        dx += -speed_sin
        dy += speed_cos
      end
    end
    
    // printc([dx, dy])
    
    this.check_wall_collision(PLAYER_SCALE/system.dt/1000, dx, dy)

    local turning = false    
    local turn_rate = 0.06
    local halt_rate = 0.5
    
    if mouse.locked then 
      if input.action_down("turn_left") then 
        this.rot_speed = lerp(this.rot_speed, -this.max_rot_speed, turn_rate)
        turning = true
      end
      if input.action_down("turn_right") then
        this.rot_speed = lerp(this.rot_speed, this.max_rot_speed, turn_rate)
        turning = true
      end
      
      if input.action_pressed("turn_around") then
      	// TODO: fix the spinning bug here
      	
        // spinning = true
        // this.target_rot = (this.rot+deg2rad(180))// % (PI*2)
      end
    end
    
    if not turning then 
      this.rot_speed = lerp(this.rot_speed, 0, halt_rate)
    end

    if not spinning then
      this.rot_speed = clamp(this.rot_speed, -this.max_rot_speed, this.max_rot_speed)
      this.rot += this.rot_speed * system.dt  
    else
      this.rot = lerp(this.rot, this.target_rot, 0.25)
      
      if within_range(this.rot, this.target_rot, 0.01) then
        spinning = false
        this.rot = this.target_rot
      end
    end
    // printc([this.rot, this.target_rot])    
  end

  mouse_control = function()
    // printc(["mouse deltas", mouse_dx, mouse_dy])
    this.rot += (mouse.relx * MOUSE_SENS * system.dt)// % (2*PI)
  end

  update = function()
    this.movement()
    this.mouse_control()
    
    // keep rotation within 360º
    this.rot = fmod(this.rot, 2*PI)
    
    this.weapon.update()
  end
  
  draw = function(draw_target)
    this.weapon.draw(draw_target)
  end
  
  check_wall_collision = function(scale, dx, dy)
    
    if map.is_exit(this.x+dx*scale, this.y+dy*scale) then 
      end_level()
      return 
    end
    
    if not map.is_wall(this.x+dx*scale, this.y) then
      this.x += dx
    end
    
    if not map.is_wall(this.x, this.y+dy*scale) then
      this.y += dy
    end
    
  end
    
  draw2d = function(draw_target)
    draw_target.drawLine(
      this.x*TS, this.y*TS, 
      this.x*TS + map.w*cos(this.rot), 
      this.y*TS + map.w*sin(this.rot), 
      "#444"
    )
    
    fill_circle(draw_target, this.x*TS, this.y*TS, 4, "#f00")
  end
end


within_range = function(a, b, range)
  return a > b-range and a < b+range 
end