
 
cast_rays = function(render_target)
  ray_casting_results = []
  
  local ray_angle = player.rot - HALF_FOV + 0.0001
  local start_ang = player.rot - HALF_FOV + 0.0001
  
  local ox = player.x
  local oy = player.y
  local x_map = floor(ox)
  local y_map = floor(oy)
  
  local tex_name_hor = 1
  local tex_name_vert = 1
  
  
  for ray=0 to NUM_RAYS-1 by 1
    local sin_a = sin(ray_angle)
    local cos_a = cos(ray_angle)
    
    /* 
          horizontals 
    */
    
    local y_hor = if sin_a > 0 then y_map+1 else y_map-0.000001 end
    local dy    = if sin_a > 0 then 1       else -1             end
    
    local depth_hor = (y_hor - oy) / sin_a
    local x_hor = ox + depth_hor * cos_a
    
    local delta_depth = dy / sin_a
    local dx = delta_depth * cos_a
    
    for i=0 to MAX_DEPTH-1 by 1
      local tile_hor_x = floor(x_hor) 
      local tile_hor_y = floor(y_hor) 
      
      if map.is_wall(tile_hor_x, tile_hor_y) then 
        tex_name_hor = map.get_tile(tile_hor_x, tile_hor_y)
        break
      end
      
      x_hor += dx
      y_hor += dy
      depth_hor += delta_depth
    end
    
    /*
          verticals
    */
    
    // local x_vert = if cos_a > 0 then x_map+1 else x_map-1e-6 end
    local x_vert = if cos_a > 0 then x_map+1 else x_map-0.000001 end
    dx           = if cos_a > 0 then 1       else -1             end
    
    local depth_vert = (x_vert - ox) / cos_a
    local y_vert = oy + depth_vert * sin_a
    
    delta_depth = dx / cos_a
    dy = delta_depth * sin_a
    
    for i=0 to MAX_DEPTH-1 by 1
      local tile_vert_x = floor(x_vert)
      local tile_vert_y = floor(y_vert)
      
      if map.is_wall(tile_vert_x, tile_vert_y) then
        tex_name_vert = map.get_tile(tile_vert_x, tile_vert_y)
        break 
      end
      
      x_vert += dx
      y_vert += dy
      depth_vert += delta_depth
    end
    
    
    /*
          wrap up
    */
    
    local depth = 0 // min(depth_vert, depth_hor)
    local offset = 0
    local side = 0
    // local tex_name = ""
    if depth_vert < depth_hor then
      side = "v"
      depth = depth_vert
      tex_name = tex_name_vert
      y_vert = mod(y_vert, 1)
      offset = cos_a > 0 and y_vert or 1-y_vert 
    else
      side = "h"
      depth = depth_hor 
      tex_name = tex_name_hor
      x_hor = mod(-x_hor, 1) // use -x_hor to prevent flipped textures
      offset = sin_a > 0 and x_hor or 1-x_hor 
    end 
    
    
    // fix for peripheral distortions: don't use fixed angle increments
    // (https://stackoverflow.com/questions/24173966/raycasting-engine-rendering-creating-slight-distortion-increasing-towards-edges)
    // and multiply ray by the scale, to allow drawing in different column sizes
    if fix_distortions then 
      ray_angle = atan( (ray*SCALE-HALF_W) / SCR_DIST ) + player.rot 
    else
      ray_angle += DELTA_ANGLE
    end

    // remove fish-bowl effect 
    depth *= cos(player.rot - ray_angle)


    // projection
    local proj_h = SCR_DIST / (depth + 0.0001)
    
    
    // TODO: organize and streamline the following mess
    
    // render walls    
    
    // color component
    local ccp = 1 - (1 / (1 + depth ^ 9 * 0.0000010))
    local color = "rgba(0,0,0," + ccp + ")"
    local tex_size = sprites[tex_name].width
    local tex_coords = rect(
      // floor(offset*(tex_size-SCALE)),
      floor(offset*(tex_size-(SCALE/tex_size))), // texture coords
      0,
      SCALE/tex_size,
      tex_size,
    )
    local scr_coords = rect(
      ray*SCALE,               // screen coords
      HALF_H - (proj_h/2),
      SCALE,
      proj_h
    )
    
    ray_casting_results.push(object
      side = side
      wall = true
      depth = depth
      proj_h = proj_h
      texture = tex_name //"wood" + TEX_SIZE
      offset = offset
      
      color = color
      tex_coords = tex_coords
      scr_coords = scr_coords
    end)
    
    // render_wall(render_target, "test" + TEX_SIZE, tex_coords, scr_coords, color)
    if not draw_3d then
      draw_debug_ray(render_target, ox, oy, depth, sin_a, cos_a)
    end
    
  end 
  // print(ray_casting_results.length)
end

