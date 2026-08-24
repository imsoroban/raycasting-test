/*
  
      Input Mapper 0.3.1
  
  
  Quick usage reference:
  
    init = function()
      input.bind("shoot", ["space", "gp_x"])
    end
    
    update = function
      input.update()
      
      if input.actionPressed("shoot") then 
        spaceship.shoot()
      end
    end
  
*/


/*******************************************************************************

      Public input API

*******************************************************************************/
input = object end
  
input.action_pressed = function(action_id)
  return __im.actions_pressed[action_id] == 1
end


input.action_released = function(action_id) 
  return __im.actions_released[action_id]
end


input.action_down = function(action_id) 
  return __im.actions_pressed[action_id] > 1
end


// camelCase versions
input.actionPressed  = input.action_pressed
input.actionReleased = input.action_released
input.actionDown     = input.action_down


input.update = function()
  __im.update_mouse()
  
  __im.actions_released = object end
  
  __im.increase_action_timers()

  for id in __im.actions
    local action =  __im.actions[id]
    __im.check_action_is_pressed(action)
    __im.check_action_is_released(action)
  end
end


input.bind = function(action_id, keys)
  local action = __im.new_action(action_id)

  for k in keys
    local b_arr = __im.get_corrected_bind(k)
    local input_type = b_arr[0]
    local key  = b_arr[1]
    local mods = b_arr[2]
    
    
    
    local bind = object
      key = key
      mods = object end
    end
    
    for mod in mods
      mod = mod.toUpperCase()
      if __im.is_valid_mod_key[mod] then 
        local lmod = 0
        local rmod = 0
        if __im.is_dual_mod_key[mod] then
          lmod = __im.check_key_conversion("L" + mod)
          rmod = __im.check_key_conversion("R" + mod)
        elsif __im.is_left_mod_key[mod] then 
          lmod = __im.check_key_conversion(mod)
        elsif __im.is_right_mod_key[mod] then 
          rmod = __im.check_key_conversion(mod)
        end

        if lmod then bind.mods[lmod] = true end
  			if rmod then bind.mods[rmod] = true end
  		end
    end
    // printt(input_type, key)
    action[input_type].push(bind)
  end
end




/*******************************************************************************

      internal input stuff

*******************************************************************************/
__im = object 
  actions = object end
  actions_pressed = object end  
  actions_released = object end
  actions_by_key = object end
  
  // lookup tables for checking modifier keys
  is_dual_mod_key  = object CTRL =true CONTROL=true SHIFT=true ALT=true end
  is_left_mod_key  = object LCTRL=true LALT=true LSHIFT=true CONTROL_LEFT=true SHIFT_LEFT=true ALT_LEFT=true end
  is_right_mod_key = object RCTRL=true RALT=true RSHIFT=true CONTROL_RIGHT=true SHIFT_RIGHT=true ALT_RIGHT=true end
  is_valid_mod_key = object
  	LCTRL=true  LSHIFT=true  LALT=true
  	RCTRL=true  RSHIFT=true  RALT=true
  	CTRL =true  CONTROL=true SHIFT =true  ALT =true
  	CONTROL_LEFT =true  SHIFT_LEFT =true  ALT_LEFT =true
  	CONTROL_RIGHT=true  SHIFT_RIGHT=true  ALT_RIGHT=true
  end
  is_ctrl_key  = object CTRL =true  CONTROL=true LCTRL=true RCTRL=true CONTROL_LEFT =true CONTROL_RIGHT=true end
  is_shift_key = object SHIFT =true LSHIFT=true RSHIFT=true SHIFT_LEFT =true SHIFT_RIGHT=true end
  is_alt_key   = object ALT =true LALT=true RALT=true ALT_LEFT =true ALT_RIGHT=true end
end


__im.key_conversion_map = object
  CTRL   = "CONTROL"
  LCTRL  = "CONTROL_LEFT"
  RCTRL  = "CONTROL_RIGHT"
  LALT   = "ALT_LEFT"
  RALT   = "ALT_RIGHT"
  RSHIFT = "SHIFT_RIGHT"
  LSHIFT = "SHIFT_LEFT"

  NP_0 = "NUMPAD_0"
  NP_1 = "NUMPAD_1"
  NP_2 = "NUMPAD_2"
  NP_3 = "NUMPAD_3"
  NP_4 = "NUMPAD_4"
  NP_5 = "NUMPAD_5"
  NP_6 = "NUMPAD_6"
  NP_7 = "NUMPAD_7"
  NP_8 = "NUMPAD_8"
  NP_9 = "NUMPAD_9"
  NP_DEC = "NUMPAD_DECIMAL"
  NP_DIV = "NUMPAD_DIVIDE"
  NP_MUL = "NUMPAD_MULTIPLY"
  NP_SUB = "NUMPAD_SUBTRACT"
  NP_ADD = "NUMPAD_ADD"
  NP_ENTER = "NUMPAD_ENTER"

  GP_LEFT = "LEFT"
  GP_RIGHT = "RIGHT"
  GP_UP = "UP"
  GP_DOWN = "DOWN"
  GP_A = "A"
  GP_B = "B"
  GP_X = "X"
  GP_Y = "Y"
  GP_VIEW = "VIEW"
  GP_MENU = "MENU"
  GP_LB = "LB"
  GP_RB = "RB"
  GP_LT = "LT"
  GP_RT = "RT"
  GP_LSL = "LEFT_STICK_LEFT"
  GP_LSR = "LEFT_STICK_RIGHT"
  GP_LSU = "LEFT_STICK_UP"
  GP_LSD = "LEFT_STICK_DOWN"
  // TODO: is the right stick supported? It doesn't work on my gamepad
  GP_RSL = "RIGHT_STICK_LEFT"
  GP_RSR = "RIGHT_STICK_RIGHT"
  GP_RSU = "RIGHT_STICK_UP"
  GP_RSD = "RIGHT_STICK_DOWN"

  MOUSE1 = "left"
  MOUSE2 = "right"
  MOUSE3 = "middle"
end

__im.update_mouse = function()
  mouse.any_pressed = mouse.press
  mouse.any_released = mouse.release
  mouse.any_down = mouse.pressed
  
  // printt(mouse.any_pressed, mouse.any_released, mouse.any_down)
  
  mouse.release = object
    left   = mouse.last_left and not mouse.left
    right  = mouse.last_right and not mouse.right
    middle = mouse.last_middle and not mouse.middle
  end
  
  mouse.press = object
    left   = mouse.left and not mouse.last_left
    right  = mouse.right and not mouse.last_right
    middle = mouse.middle and not mouse.last_middle
  end
  
  mouse.rel_x = mouse.x - mouse.last_x
  mouse.rel_y = mouse.y - mouse.last_y
  
  mouse.last_x = mouse.x
  mouse.last_y = mouse.y
  mouse.last_left   = mouse.left
  mouse.last_right  = mouse.right
  mouse.last_middle = mouse.middle
end


__im.new_action = function(id)
  local action = object
    id    = id 
    keyb  = []
    gpad  = []
    mouse = []
  end
  this.actions[id] = action
  return action
end


__im.check_key_conversion = function(key)
  if not this.key_conversion_map[key] then return key end
  return this.key_conversion_map[key]
end


__im.get_corrected_bind = function(bind) 
	
  local input_type = 0 
  local keys = bind.split(' ')
  local key  = keys.pop().toUpperCase()
  local mods = keys
  
  if key.startsWith("GP_") then 
    input_type = "gpad"
  elsif key.startsWith("MOUSE") then 
    input_type = "mouse"
  else                             
    input_type = "keyb"
  end
  
  key = this.check_key_conversion(key)
  return [input_type, key, mods]
end


__im.increase_action_timers = function()
  for id in this.actions_pressed
    if this.actions_pressed[id] > 0 then 
      this.actions_pressed[id] += 1
    end
  end
end

__im.check_action_is_pressed = function(action)
  if this.actions_pressed[action.id] then return end
  
  if this.check_bind_pressed(keyboard, action.keyb) then 
    this.actions_pressed[action.id] = true
    return 
  end
  if this.check_bind_pressed(gamepad, action.gpad) then  
    this.actions_pressed[action.id] = true
    return 
  end
  if this.check_mouse_bind_pressed(action.mouse) then   
    this.actions_pressed[action.id] = true
    return 
  end
end

__im.check_action_is_released = function(action)
  if not this.actions_pressed[action.id] then return end
  if this.check_bind_released(keyboard, action.keyb) then 
    // print("action released: " + action.id)
    this.actions_pressed[action.id] = false
    this.actions_released[action.id] = true
    return
  end
  if this.check_bind_released(gamepad, action.gpad) then  
    this.actions_pressed[action.id] = false
    this.actions_released[action.id] = true
    return
  end
  if this.check_mouse_bind_released(action.mouse) then  
    this.actions_pressed[action.id] = false
    this.actions_released[action.id] = true
    return
  end
end



__im._check_mod_pressed = function(bind, lmod, rmod)
	if bind.mods[lmod] and bind.mods[rmod] then
		if not (keyboard[lmod] or keyboard[rmod]) then
			return false
		end
	elsif bind.mods[lmod] then
		if not keyboard[lmod] then return false end
		if keyboard[rmod] then return false end
	elsif bind.mods[rmod] then
		if not keyboard[rmod] then return false end
		if keyboard[lmod] then return false end
	else
    if lmod != bind.key and keyboard[lmod]
    or rmod != bind.key and keyboard[rmod]
		then
  	  return false
		end
	end
	return true
end


__im.all_mods_pressed = function(bind)
  local mods_ok = true
  if not this.is_ctrl_key[bind.key] and not this._check_mod_pressed(bind, 'CONTROL_LEFT',  'CONTROL_RIGHT') then mods_ok = false end
  if not this.is_shift_key[bind.key] and not this._check_mod_pressed(bind, 'SHIFT_LEFT',  'SHIFT_RIGHT') then mods_ok = false end
  if not this.is_alt_key[bind.key] and not this._check_mod_pressed(bind, 'ALT_LEFT',  'ALT_RIGHT') then mods_ok = false end
  return mods_ok
end


__im.check_mod_released = function(bind, lmod, rmod)
	if bind.mods[lmod] and bind.mods[rmod] then
		if keyboard.released[lmod] or keyboard.released[rmod] then
			return true
		end
	elsif bind.mods[lmod] then
		if keyboard.release[lmod] then return true end
	elsif bind.mods[rmod] then
		if keyboard.release[rmod] then return true end
	end
	return false
end


__im.any_mod_released = function(bind)
  if this.check_mod_released(bind, 'CONTROL_LEFT',  'CONTROL_RIGHT') then return true end
  if this.check_mod_released(bind, 'SHIFT_LEFT',  'SHIFT_RIGHT') then return true end
  if this.check_mod_released(bind, 'ALT_LEFT',  'ALT_RIGHT') then return true end
  return false
end

__im.check_bind_pressed = function(input, binds) 
  for bind in binds
    if input.press[bind.key] and this.all_mods_pressed(bind) then 
      return true 
    end
  end
  
  return false
end

__im.check_bind_released = function(input, binds) 
  for bind in binds
    // TODO: 'any_mod_released' always returns false for some reason
    local mod_released = this.any_mod_released(bind)
    if input.release[bind.key] or mod_released then 
      return true 
    end
  end
  
  return false
end

__im.check_mouse_bind_pressed = function(binds)
  for bind in binds 
    if mouse.press[bind.key] and this.all_mods_pressed(bind) then
      return true
    end
  end
  return false
end


__im.check_mouse_bind_released = function(binds)
  for bind in binds
    // TODO: 'any_mod_released' always returns false for some reason
    local mod_released = this.any_mod_released(bind)
    if mouse.release[bind.key] or mod_released then 
      return true 
    end
  end
  return false
end

