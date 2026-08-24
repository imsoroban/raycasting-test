
init_floor_casting = function()
  local tex_w = sprites[map.floor].width
  local tex_h = sprites[map.floor].height
  local floor_texture = sprites[map.floor].frames[0]
  
  floor_buffer = List.new_2d(tex_w, tex_h, 0)
  
  for j=0 to tex_h-1 by 1
    for i=0 to tex_w-1 by 1
      local c = floor_texture.getRGB(i, j)
      floor_buffer[j][i] = [c.R, c.G, c.B]
    end
  end
  
  // every 250 milliseconds do
  //   do_floor_ceil_casting(img_buffer)
  // end
end



do_floor_ceil_casting = function(draw_target)
  // choose texture and draw the pixel
  // local floor_texture = sprites["tiles/ceiling"].frames[0]
  // local floor_texture = sprites[map.floor].frames[0]
  local floor_texture = map.floor
  
  debug.print("! drawing floor")
  local floor_buf = floor_buffer
  // local ceiling_texture = sprites["tiles/ceiling"].frames[0]
  
  // print(floor_texture)//.getRGB(0, 0))
  
  
  // local ftex = new Image(floor_texture.width, floor_texture.height)
  // local ctex = new Image(ceiling_texture.width, ceiling_texture.height)
  
  // local ray_dir_x1 = dirX - SCR_DIST;
  // local ray_dir_y1 = dirY - SCR_DIST;
  // local ray_dir_x2 = dirX + SCR_DIST;
  // local ray_dir_y2 = dirY + SCR_DIST;
  
  local ray_dir_x1 = sin(player.rot) - SCR_DIST
  local ray_dir_y1 = cos(player.rot) - SCR_DIST
  local ray_dir_x2 = sin(player.rot) + SCR_DIST
  local ray_dir_y2 = cos(player.rot) + SCR_DIST
  
  local color = 0
  
  // print("gonna loop")
  for y=RH/2 to RH-1 by 1
    // print("loop y: " + y)
    // rayDir for leftmost ray (x = 0) and rightmost ray (x = w)
    
   

    // Current y position compared to the center of the screen (the horizon)
    local p = y-HALF_H

    // Vertical position of the camera.
    local pos_z = RH*0.5

    // Horizontal distance from the camera to the floor for the current row.
    // 0.5 is the z position exactly in the middle between floor and ceiling.
    local row_distance = pos_z / p

    // calculate the real world step vector we have to add for each x (parallel to camera plane)
    // adding step by step avoids multiplications with a weight in the inner loop
    local floor_step_x = row_distance * (ray_dir_x2 - ray_dir_x1) / RW
    local floor_step_y = row_distance * (ray_dir_y2 - ray_dir_y1) / RW

    // real world coordinates of the leftmost column. This will be updated 
    // as we step to the right.
    local floor_x = player.x + row_distance * ray_dir_x1
    local floor_y = player.y + row_distance * ray_dir_y1
    
    for x=0 to RW-1 by 1
      // print("loop y: " + y + "  loop x: " + x)
      // the cell coord is simply got from the integer parts of floor_x and floor_y
      local cell_x = floor(floor_x)
      local cell_y = floor(floor_y)

      // get the texture coordinate from the fractional part
      local tx = floor(((TEX_SIZE-1) * (floor_x - cell_x)) & (TEX_SIZE - 1))
      local ty = floor(((TEX_SIZE-1) * (floor_y - cell_y)) & (TEX_SIZE - 1))
      
      floor_x += floor_step_x
      floor_y += floor_step_y

      // screen.drawSpritePart
      draw_target.drawImagePart(
        floor_texture,
        tx, ty, 1, 1,
        x, y, 1, 1
      )

      // if x == 0 then print(floor_texture) end
      
      // floor
      // color = floor_texture.getRGB(tx, ty)
      // color = floor_buf[ty][tx]
      // print(color.R + ", " + color.G + ", " + color.B)
      // color = (color >> 1) & 8355711; // make a bit darker
      
      // draw_target.setRGB(x,y, color.R, color.G, color.B)
      // draw_target.setRGB(x,y, color[0], color[1], color[2])
      // draw_target.setRGB(x, y, 255, 255, 255)

      // //ceiling (symmetrical, at RH - y - 1 instead of y)
      // color = ctex.getRGB(tx, ty)
      // // color = (color >> 1) & 8355711; // make a bit darker
      // draw_target.setRGB(x, RH-y-1, color.r, color.g, color.b)
    end
  end
  
  // print("done looping")
end
