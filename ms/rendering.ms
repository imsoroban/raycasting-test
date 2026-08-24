
render_floor_and_ceiling = function()
  local floor_color = "#321"
  local ceil_color = "#111114"
  // local ceil_color ="rgb(0,0,0)"
  
  img_buffer.setBlending("source-atop")  

  img_buffer.setLinearGradient(0, RH/2+20, 0, RH, "#000", floor_color)
  img_buffer.fillRect(0, RH/2, RW, RH/2)
  
  // local x1 = fmod((-player.rot * 320), 320)
  // local x2 = x1-RW
  // img_buffer.drawSprite(map.floor, x1, RH/2, RW, RH/2) 
  // img_buffer.drawSprite(map.floor, x2, RH/2, RW, RH/2)
  
  if map.sky then 
    local x1 = fmod((-player.rot * 320), 320)
    local x2 = x1-RW
    img_buffer.drawSprite(map.sky, x1, 0, RW, RH/2) 
    img_buffer.drawSprite(map.sky, x2, 0, RW, RH/2)
  elsif map.ceiling then 
    img_buffer.setLinearGradient(0, 0, 0, RH/2-20, ceil_color, "#000")
    img_buffer.fillRect(0, 0, RW, RH/2)
  end
end



ray_casting_results = []
objects_to_render = []

draw_debug_ray = function(render_target, ox, oy, depth, sin_a, cos_a)
  local tx = ox*TS
    local ty = oy*TS
    
    render_target.drawLine(
      tx, ty, 
      tx + depth*TS*cos_a, 
      ty + depth*TS*sin_a, 
      "#0f0"
    )
end


directional_shadow_color = "#0005"
render_object = function(render_target, obj)
  local x = obj.scr_coords.x
  local y = obj.scr_coords.y
  local w = obj.scr_coords.w
  local h = obj.scr_coords.h
  
  render_target.drawSpritePart(
    obj.texture,
    obj.tex_coords.x, obj.tex_coords.y, obj.tex_coords.w, obj.tex_coords.h,
    x, y, w, h,
  )

  if not obj.wall then return end 

  // add depth darkness effect
  render_target.setBlending("source-atop")
  render_target.fillRect(x, y-1, w, h+2, obj.color)

  if obj.side == "h" then 
    img_buffer.fillRect(x, y-1, w, h+2, directional_shadow_color)
  end
end

render_blank_wall = function(render_target, x, y, w, h, color)
  render_target.fillRect(x, y, w, h, color)
end




// textures = game.object_renderer.wall_textures

get_objects_to_render = function(render_target)
  objects_to_render = []
  
  // print(ray_casting_results.length)
  for ray=0 to ray_casting_results.length-1 by 1
    local res = ray_casting_results[ray]
    
    // if I had issues with getting stuck when touching walls, this is where
    // I would fix it (in the else clause), according to the tutorial 
    // at 20:28 (https://www.youtube.com/watch?v=ECqUrT7IdqQ)
    if res.proj_h < RH then
      res.wall_pos = vec(ray * SCALE, HALF_H - res.proj_h)
    else
      res.wall_pos = vec(ray * SCALE, 0)
    end
    
    objects_to_render.push(res) 
  end
  for e in map.entities
    e.update()
  end
end
// rendr_sort = function(a, b) a.depth < b.depth and -1 or 1 end
render_game_objects = function(render_target)
  // for go in objects_to_render
  //   if go.type == "number" then print("RES IS NUMBER") end
  // end
  
  objects_to_render.sortList(function(a, b) 
    // print([a, b])
    return a.depth > b.depth and -1 or 1 
  end)
  
  for obj in objects_to_render
    render_object(render_target, obj)
  end
end

// push_render_object = function(dist, )