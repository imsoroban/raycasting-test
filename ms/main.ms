

init = function()
  level_ended = true
  
  // print (sprites["gui/shotgun"])
  // init_mouse_lock()
  init_settings()
  init_maps()
  
  game_maps = [
    // maps["test"],
    maps["map2"],
    maps["map3"],
  ]
  map_index = 1 
  
 
  
  
  // map = new GameMap(maps["map2"])
  // local spawn = map.get_spawn_pos()
  // if spawn then 
  //   player = new Player(spawn.x, spawn.y, spawn.dir)
  // else
  //   player = new Player(5, 5)
  // end
  // set_mouse_visibility(not use_mouse)
  
  // init_floor_casting()
end



end_level = function()
  print("level_ending")
  level_ended = true
  map_index = wrap(map_index+1, 0, game_maps.length)
end


update = function()
  // system.pause()
  // dt_update()
  debug.update()
  input.update()
  
  	
  debug.print("fps", system.fps)
  // debug.print("dt", system.dt, 3)
  // debug.print("real fps", floor(1/system.dt))


  if level_ended then
    // map = new GameMap(maps["map2"])
    map = new GameMap(game_maps[map_index].clone())
    local spawn = map.get_spawn_pos()
    if spawn then 
      player = new Player(spawn.x, spawn.y, spawn.dir)
    // else
    //   player = new Player(5, 5)
    end
    
    level_ended = false
    return
  end
  
  
  player.update()
  
  
  img_buffer.clear("#000")
  if not draw_3d then
    map.draw2d(img_buffer)
  end
  
  cast_rays(img_buffer)
end




draw = function()
  screen.clear()
  screen.drawSprite("sprite2", 0, 0, 100, 100)
  if draw_3d then
    
    render_floor_and_ceiling()
    
    // THIS SLOWS THE GAME TO A FRAME PER CENTURY
    // do_floor_ceil_casting(img_buffer)
    
    
    get_objects_to_render(img_buffer)
    render_game_objects(img_buffer)
    
    player.draw(img_buffer)
  else
    player.draw2d(img_buffer)
  end
  
  
  
  screen.drawSprite(img_buffer, 0, 0, 200*RW/RH, 200) 
  // screen.drawSprite(img_buffer, 0, 0, SW, SH) 
  //   screen.width,
  //   screen.height
  // )
  
  if not mouse.locked then
  	screen.drawTextOutline("Click mouse to enable controls", 0, 0, 15, "#000")
  	screen.drawText("Click mouse to enable controls", 0, 0, 15, "#fff")
  end
  
  debug.line(0,screen.height, 0, -screen.height, "#eee")
  // debug.point(mouse.x, mouse.y, 5, "#fff")

  debug.draw()
  dt_update()
end