GameMap = class
  constructor = function(map)
    this.spawn = 0
    this.tiles = map
    this.w = map.width
    this.h = map.height
    this.entities = []
    // printc([map.width, map.height])
    this.exits = []
    this.sky = this.get_tile(0,0)
    this.floor = this.get_tile(map.width-1,map.height-1)
    
    // get spawn position
    // TODO: place map objects (and move this loop elsweyr)  
    for j=0 to map.height by 1
      for i=0 to map.width by 1
        
        local tile = map.get(i, j)
        
        if tile != 0 then
          if tile.startsWith("specials/spawn") then
            this.set_spawn(i, j, tile)
          elsif tile.startsWith("sprites/exit") then
            this.set_exit(i, j, tile)
          elsif tile.startsWith("sprites/candle") then 
            // print("found candle")
            this.entities.push(new SpriteObj("sprites/candle", i, j, 1, 0.0))
            this.tiles.set(i, j, 0)
          elsif tile.startsWith("sprites/anim_candle") then
            // print("found candle")
            this.entities.push(new SpriteObj("sprites/anim_candle", i, j, 1, 0.0))
            this.tiles.set(i, j, 0)
          end
        end
      end
    end
  end
  
  set_spawn = function(x, y, tile)
    if this.spawn then return end
    
    local coords = "0,0"
    
    local colon = tile.indexOf(":")
    if colon != -1 then 
      coords = tile.substring(colon+1)
    end
    
    // print("coords: " + coords)
    this.spawn = object
      x = x
      y = y
      dir = coords == "0,0" and deg2rad(90)
         or coords == "1,0" and 0
         or coords == "1,1" and deg2rad(-90)
         or coords == "0,1" and deg2rad(180)
    end
    
    this.tiles.set(x, y, 0)
  end
  
  set_exit = function(x, y, tile)
    this.exits.push(object
      x = x
      y = y
    end)
    // this.tiles.set(x, y, 0)
  end
  
  is_exit = function(x, y)
    
    for exit in this.exits
      if exit.x == floor(x) and exit.y == floor(y) then return true end
    end
    return false
  end
  
  is_wall = function(x, y)
    return this.tiles.get(floor(x), floor(y)) != 0
    // return this.tiles[floor(y)][floor(x)] != 0
  end
  
  get_tile = function(x, y)
    local name = this.tiles.get(floor(x), floor(y))
    if not name then return 0 end
    
    local colon = name.indexOf(":")
    if colon == -1 then return name end
    
    return name.substring(0, colon)
  end
  
  draw2d = function(target)
    // TODO: center the drawing on the player
    for j=0 to this.h-1 by 1
      for i=0 to this.w-1 by 1
        local tile = this.tiles.get(i, j)
        if tile != 0 then
          local x = (i*TS)
          local y = (j*TS)
          // target.drawRect(x, y, TS, TS, "#eee")
          target.drawSprite(tile, x, y, TS, TS)
        end
      end
    end
  end
  
  get_spawn_pos = function()
    // for j=0 to this.h-1 by 1
    //   for i=0 to this.w-1 by 1
    //     local tile = this.tiles[j][i]
    //     if tile == 9 then 
    //       this.tiles[j][i] = 0
    //       return vec(i, j) 
    //     end
    //   end
    // end
    return this.spawn
  end
end


init_maps = function()
  // _ = false
  
  // map1 = [
  //   [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
  //   [1,_,_,_,_,1,_,_,_,_,_,_,_,_,_,_,_,_,_,1],
  //   [1,_,_,_,_,1,_,_,_,_,_,_,1,1,_,_,_,_,_,1],
  //   [1,_,_,_,_,1,_,_,_,_,_,_,_,1,_,_,_,_,_,1],
  //   [1,1,1,_,1,1,1,1,1,1,1,_,_,_,_,_,_,_,_,1],
  //   [1,9,_,_,_,_,_,_,_,_,1,_,_,_,_,_,_,_,_,1],
  //   [1,_,_,_,_,_,_,_,_,_,1,_,_,_,_,_,_,_,_,1],
  //   [1,_,1,1,1,1,1,1,_,_,1,_,_,_,_,_,_,_,_,1],
  //   [1,_,1,_,_,_,_,1,_,_,1,_,_,_,_,_,_,_,_,1],
  //   [1,_,1,1,_,_,_,1,_,_,1,_,_,_,_,_,_,_,_,1],
  //   [1,_,_,1,_,_,_,1,_,_,1,_,_,_,_,_,_,_,_,1],
  //   [1,1,_,_,1,1,_,1,_,_,1,_,_,_,_,_,_,_,_,1],
  //   [1,_,1,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,1],
  //   [1,_,1,1,1,1,1,1,_,_,_,_,_,_,_,_,_,_,_,1],
  //   [1,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,1],
  //   [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
  // ]
  
  // map = maps["map2"]
  // printf("cell: %s", [map.get(6, 1)])
  
  
  
  
  
end