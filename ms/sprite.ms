function()
// sprite_buffers = object end

// add_sprite_buffer = function(name, w, h)
//   if not sprite_buffers[name] then 
//     sprite_buffers[name] = new Image(w, h)
//   end
// end

SpriteObj = class
  constructor = function(name, x, y, scale=1, shift=0.1)
    this.x = x + 0.5 
    this.y = y + 0.5
    this.sprite = sprites[name]
    this.w = this.sprite.width
    this.h = this.sprite.height
    this.dx = 0
    this.dy = 0
    this.theta = 0
    this.half_w = floor(this.w/2)
    this.norm_dist = 0
    this.screen_x = 0
    this.img_ratio = this.w / this.h
    this.dist = 0
    this.scale = scale
    this.shift = shift
    
    // this is used for rendering with darkening effect
    this.buffer = new Image(this.w, this.h)
  end
  
  // as the name doesn't indicate, this finishes the calculations
  // started in 'get_sprite'
  get_sprite_projection = function()
    local proj_h = SCR_DIST / this.norm_dist * this.scale
    local proj_w = proj_h * this.img_ratio
    
    this.proj_half_w = floor(proj_w/2)
    local y_shift = proj_h * this.shift
    local pos_x = this.screen_x - this.proj_half_w 
    local pos_y = HALF_H - floor(proj_h/2) + y_shift     
    
    // color component
    local ccp = 1 - (1 / (1 + this.norm_dist ^ 9 * 0.0000010))
    local color = fmt("rgba(0,0,0,%s)", [ccp])
    
    // coords
    local tex_coords = rect(0, 0, this.w, this.h)
    local scr_coords = rect(pos_x, pos_y, proj_w, proj_h)
    
    // apply darkening
    this.buffer.clear("#0000") 
    this.buffer.drawSprite(this.sprite, 0, 0)
    this.buffer.setBlending("source-atop")
    this.buffer.fillRect(0, 0, this.w, this.h, color)
    
    objects_to_render.push(object
      wall = false
      depth = this.norm_dist
      proj_h = proj_h
      texture = this.buffer
      color = color
      tex_coords = tex_coords
      scr_coords = scr_coords
    end)
  end
  
  // as the name doesn't indicate, this calculates the sprite's
  // rendering position and scale
  get_sprite = function()
    local dx = this.x - player.x
    local dy = this.y - player.y
    this.dx = dx
    this.dy = dy
    this.theta = atan2(dy, dx)
    
    local delta = this.theta - player.rot
    if (dx > 0 and player.rot > PI)
    or (dx < 0 and dy < 0) then
      delta += PI*2
    end
    
    local delta_rays = delta / DELTA_ANGLE
    this.screen_x = (HALF_NUM_RAYS + delta_rays) * SCALE 
    
    this.dist = sqrt(dx*dx + dy*dy)
    this.norm_dist = this.dist * cos(delta)
    
    if -this.half_w < this.screen_x < (RW + this.half_w)
    and this.norm_dist > 0.5 then
      this.get_sprite_projection()
    end 
  end
  
  update = function()
    this.get_sprite()
  end
end


// --- Enemies ---

Enemy = class extends SpriteObj
  constructor = function(name, x, y)
    super(name, x, y, 1, 0.0)
    this.is_enemy = true
    this.health = 30
    this.max_health = 30
    this.speed = 0.9
    this.state = "chase"       // "chase", "attack", "dead"
    this.attack_cooldown = 0
    this.attack_damage = 10
    this.attack_range = 1.0
    this.chase_range = 8
  end

  take_damage = function(amount)
    if this.state == "dead" then return end
    this.health -= amount
    if this.health <= 0 then
      this.health = 0
      this.state = "dead"
      this.speed = 0
    end
  end

  chase_player = function()
    local dx = player.x - this.x
    local dy = player.y - this.y
    local dist = sqrt(dx*dx + dy*dy)

    if dist > this.chase_range then return end

    if dist < this.attack_range then
      this.state = "attack"
      return
    end

    local step = this.speed * system.dt
    local nx = (dx/dist) * step
    local ny = (dy/dist) * step

    if not map.is_wall(this.x+nx, this.y) then this.x += nx end
    if not map.is_wall(this.x, this.y+ny) then this.y += ny end
  end

  attack_player = function()
    this.attack_cooldown -= system.dt

    local dx = player.x - this.x
    local dy = player.y - this.y
    local dist = sqrt(dx*dx + dy*dy)

    if dist > this.attack_range * 1.3 then
      this.state = "chase"
      return
    end

    if this.attack_cooldown <= 0 then
      audio.playSound("npc_attack")
      player.take_damage(this.attack_damage)
      this.attack_cooldown = 1.0
    end
  end

  update = function()
    if this.state == "chase" then
      this.chase_player()
    elsif this.state == "attack" then
      this.attack_player()
    end

    super.update()   // still handles the sprite screen-projection math
  end
end
end()
