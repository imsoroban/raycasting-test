Weapon = class
  constructor = function(sprite, sound, scale=0.4)
    this.spr_idle = sprite + ".0"
    this.spr_shooting = sprite
    
    this.sound = sound
    this.x = HALF_W - floor(sprites[sprite].width/2*scale)
    this.y = RH - floor(sprites[sprite].height*scale)
    this.shooting = false
    this.scale = scale
  end
  
  draw = function(draw_target)
    local spr = not this.shooting and this.spr_idle or this.spr_shooting
    // print(sprites[this.spr_shooting])
    local w = sprites[this.spr_shooting].width
    local h = sprites[this.spr_shooting].height
    draw_target.drawSprite(spr, this.x, this.y, w*this.scale, h*this.scale)
  end
  
  update = function()
    if this.shooting then
      local spr = sprites[this.spr_shooting]
      if spr.getFrame() == spr.frames.length-1 then
        this.shooting = false 
      end
    end
  end
  
  shoot = function()
    if this.shooting then return end
    this.shooting = true
    sprites[this.spr_shooting].setFrame(0)
    audio.playSound(this.sound)//, volume, pitch, pan, loop )
  end
end



// TODO: this could just be a function
Shotgun = class extends Weapon
  constructor = function()
    super("gui/shotgun", "shotgun", SS)
    sprites["gui/shotgun"].fps = 7
  end
end