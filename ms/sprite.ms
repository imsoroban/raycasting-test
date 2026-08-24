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
    // printc([pos_x, pos_y])
    
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
      // offset = offset
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
    
    // ray_angle = atan( (ray*SCALE-HALF_W) / SCR_DIST ) + player.rot 
    // DELTA_ANGLE = FOV / NUM_RAYS
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