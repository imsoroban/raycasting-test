/*
        Debugger v0.41
      
      
      
    Quick usage reference:
        
        update = function()
          debug.update()  // call this before everything
          
          debug.print("foo", foo)
        end
        
        draw = function()
          debug.print("bar", bar)
          
          debug.bm("map_drawing", function()
            draw_map()
          end)
          
          debug.draw()  // call this after everything
        end
*/



// This array makes it easier to try out different fonts while the game 
// is running. It has a selection of fonts that work well enough for 
// vertical text alignment (very few fonts are monospaced).
__fonts = [
  "AESystematic", "AlphaBeta", "Comicoro", "Commodore64", "Edunline",
  "EnchantedSword", "EnterCommand", "GenericMobileSystem", "JupiterCrash",
  "ModernDos", "PressStart2P", "Revolute", "Squarewave", "Thixel",
  "ZXSpectrum",
  
  /* monospaced fonts */
  // "AESystematic", "Commodore64", "Edunline", "JupiterCrash", "ModernDos", 
  // "PressStart2P","ZXSpectrum", 
  
  /* complete list of fonts */
  // "AESystematic",        "Alkhemikal",     "AlphaBeta",        "Arpegius",      "Awesome", 
  // "BitCell",             "Blocktopia",     "Comicoro",         "Commodore64",   "DigitalDisco", 
  // "Edunline",            "EnchantedSword", "EnterCommand",     "Euxoi",         "FixedBold", 
  // "GenericMobileSystem", "GrapeSoda",      "JupiterCrash",     "Kapel",         "KiwiSoda", 
  // "Litebulb8bit",        "LycheeSoda",     "MisterPixel",      "ModernDos",     "NokiaCellPhone", 
  // "PearSoda",            "PixAntiqua",     "PixChicago",       "PixelArial",    "PixelOperator", 
  // "Pixellari",           "Pixolde",        "PlanetaryContact", "PressStart2P",  "RainyHearts", 
  // "RetroGaming",         "Revolute",       "Romulus",          "Scriptorium",   "Squarewave", 
  // "Thixel",              "Unbalanced",     "UpheavalPro",      "VeniceClassic", "ZXSpectrum", 
  // "Zepto"
]


debug = object
  active = true
  active_drawing = false
  
  // -------------------------------------
  //   user settings
  // -------------------------------------
  key1 = '\\'
  key2 = '~'
  
  text_font = __fonts[6]
  
  text_font_default = "BitCell"
  text_font_size = 10
  text_line_spacing = 1
  text_outlined = true
  text_outline_width = 3
  text_background = true
  
  text_color = "#eee"
  back_color = "#433a"
  frame_color = "#877a"
  text_outline_color = "#000"
  shape_outline_color = "#000"
  
  shape_font = "BitCell"
  shape_dash = [4, 6]
  shape_line_width = 1
  shape_outline_width = 4
  
  display_as_table = true  // only works with monospaced-ish fonts
  align_width = 14
  float_precision = 2
  time_in_secs = false  // secs or millisecs
  render_target = screen
  manual_input_handling = false
  
  
  // -------------------------------------
  //   internal stuff
  // -------------------------------------
  
  _lines = []
  _longest_line = 0
  _bm_cache = object end
  _con_upd_interval = 1.0
  _draw_commands = object
    line   = []
    rline  = []
    rect   = []
    frect  = []
    point  = []
    fpoint = []
    text   = []
  end
  
  _t1 = system.time()
  _dt = 0
  _update_dt = function()
    local t2 = system.time()
    this._dt = (t2-this._t1)/1000
    this._t1 = t2
  end
end


debug._reset = function()
  this._lines = []
	this._longest_line = ""
end

debug._reset_drawing = function()
  for kind in this._draw_commands
	  this._draw_commands[kind] = []
	end
end

debug.toggle = function()
  this.active = not this.active
end

debug.toggle_drawing = function()
  this.active_drawing = not this.active_drawing
end
debug.toggleDrawing = debug.toggle_drawing


debug.update = function()
  debug._update_dt()
  
  if this.active then
    this._reset()
  end
  
  if this.active_drawing then
    this._reset_drawing()
  end
  
  if not manual_input_handling then 
    if keyboard.press[this.key1] or keyboard.press[this.key2] then 
      if keyboard["CONTROL"] then 
        this.toggle_drawing()
      else
        this.toggle()
      end
    end
  end
end


debug.commit_deferred = function()
  this._process_draw_commands()
end
debug.commitDeferred = debug.commit_deferred


debug.draw = function()
  this._process_print_commands()
end


debug._process_print_commands = function()
  if not this.active then return end
  screen.setDrawAnchor(-1, 1)
  screen.setFont(this.text_font)

	local lines = this._lines
	local fs = this.text_font_size
	
	local rx = -screen.width/2
	local ry = screen.height/2
	local rw = screen.textWidth(this._longest_line, fs)+6
	local rh = lines.length*(fs+this.text_line_spacing)+2
	
	if this.text_background then 
  	screen.setLineWidth(1)
  	screen.setLineDash()
  	screen.fillRect(rx, ry, rw, rh, this.back_color)
  	screen.drawRect(rx, ry, rw, rh, this.frame_color)
  end
	
	for i=0 to lines.length-1 by 1
    local x = -screen.width/2+4
    local y = screen.height/2-i*(fs+this.text_line_spacing)
    if this.text_outlined then 
      screen.setLineWidth(this.text_outline_width)
      screen.drawTextOutline(lines[i], x, y, fs, this.text_outline_color)
    end
    screen.drawText(lines[i], x, y, fs, this.text_color)
  end
  
  screen.setFont(this.text_font_default)
	screen.setDrawAnchor()
	screen.setLineWidth()
end




debug._ftrunc = function(val, num_decimals)
  return round(val*10^num_decimals)/10^num_decimals
end
  
debug._is_float = function(num)
  return num.type == "number" and num % 1 != 0
end


_NOARG_ = object end

debug.print = function(key, val=_NOARG_, precision=_NOARG_)
  if not this.active then return end
  
  if val == _NOARG_ then // 1 arg given
    precision = this.float_precision
  else   // 2 or 3 args given
    if val.type == "number" and this._is_float(key) then 
      precision = val
      val = _NOARG_
    elsif precision == _NOARG_ then 
      precision = this.float_precision 
    end
  end
  
	local line = ""
  
  // TODO: this can probably be simplified 	
	
  if val != _NOARG_ then
    if this._is_float(val) then
      // line = debug.__fmt("%s: %" + floor(precision) + "f", [key, val])
      val = this._ftrunc(val, floor(precision)) 
    end
    
    if key == "" then
      if this.display_as_table then
        key = ' '.repeat(this.align_width)
      end
      line = debug.__fmt("%s%s", [key, val])  
    else
      if this.display_as_table then
        if key.length < this.align_width then
          key += ' '.repeat(this.align_width-key.length)
        end
        line = debug.__fmt("%s%s", [key, val])
      else
        line = debug.__fmt("%s: %s", [key, val])
      end
    end
  else
    if this._is_float(key) then
      line = debug.__fmt("%" + floor(precision) + "f", [key])
    else
      line = debug.__fmt("%s", [key])
    end
  end
	

  if line.length > this._longest_line.length then
    this._longest_line = line
  end

	this._lines.push(line)
end
  


debug._check_cache = function(name)
  if not this._bm_cache[name] then 
    this._bm_cache[name] = object
      frames = 0
      time = 0
      timer = this._con_upd_interval
    end
  end
  return this._bm_cache[name]
end


debug._count_frame = function(cached)
  cached.frames += 1
	if cached.frames > 500 then 
    cached.frames = 1
    cached.time = 0
	end
end


// benchmarks and prints results on screen 
// optionally also prints to the console periodically

// debug.bm(string, [boolean,] function)

debug.bm = function(name, con_prt, func)
  if con_prt.type == "function" then 
      func = con_prt
      con_prt = false
  end
  
  if not this.active and not con_prt then 
    func()
    return 
  end
  
  local cached = this._check_cache(name)
  this._count_frame(cached)
	
	local t1 = system.time()
	func()
	local t2 = (system.time() - t1)
	if time_in_secs then
	  t2 /= 1000
	end
  
  cached.time += t2
	local avg = cached.time/cached.frames
	
	local times_str = time_in_secs 
	                  and debug.__fmt("avg %4f s  |  tm %4f s", [avg, t2])
	                   or debug.__fmt("avg %d ms |  tm %d ms", [avg, t2])
	
	if this.active then 
	  this.print("> " + name, times_str)
	end
	
	if con_prt then
    local str = debug.__fmt("%s: " + times_str, [name])
    
    cached.timer -= debug._dt
    if cached.timer <= 0 then 
      global.print(str)
      cached.timer = this._con_upd_interval
    end  
  end
  return str
end




/*******************************************************************************

      Internal Drawing API

*******************************************************************************/
debug._process_draw_commands = function()
  if not this.active_drawing then return end
  
  // lines
  for c in this._draw_commands.line
    this.line(c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7])
  end
  
  for c in this._draw_commands.rline
    this.line(c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7])
  end
  
  for c in this._draw_commands.rect
    this.rect(c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8])
  end

  for c in this._draw_commands.frect
    this.frect(c[0], c[1], c[2], c[3], c[4], c[5], c[6])
  end
  
  for c in this._draw_commands.point
    this.point(c[0], c[1], c[2], c[3], c[4], c[5], c[6])
  end
  
  for c in this._draw_commands.fpoint
    this.fpoint(c[0], c[1], c[2], c[3], c[4])
  end
  
  for c in this._draw_commands.text
    this.text(c[0], c[1], c[2], c[3], c[4], c[5], c[6])
  end
end


debug._add_draw_command = function(kind, params)
  if not this.active_drawing then return end
  this._draw_commands[kind].push(params)    
end

  



/*******************************************************************************


      Public Drawing API


*******************************************************************************

/*******************************************************************************
      Deferred Drawing API
*******************************************************************************/
debug.dline = function(x1, y1, x2, y2, color, thickness=0, outline=false, dash=false)
  this._add_draw_command("line", [x1, y1, x2, y2, color, thickness, outline, dash])    
end

debug.drline = function(x, y, rx, ry, color, thickness=0, outline=false, dash=false)
  this._add_draw_command("rline", [x, y, x+rx, y+ry, color, thickness, outline, dash])    
end

debug.drect = function(x, y, w, h, color, thickness=0, radius=0, outline=false, dash=false)
  this._add_draw_command("rect", [x, y, w, h, color, thickness, radius, outline, dash])
end

debug.dfrect = function(x, y, w, h, color, radius=0, outline=false)
  this._add_draw_command("frect", [x, y, w, h, color, radius, outline])
end

debug.dpoint = function(x, y, radius, color, thickness=0, outline=false, dash=false)
  this._add_draw_command("point", [x, y, radius, color, thickness, outline, dash])
end

debug.dfpoint = function(x, y, radius, color, outline=false)
  this._add_draw_command("fpoint", [x, y, radius, color, outline])
end

debug.dtext = function(text, x, y, size, color, outline=false, font=0)
  this._add_draw_command("text", [text, x, y, size, color, outline, font])
end



/*******************************************************************************      
      Immediate Drawing API
*******************************************************************************/
debug.line = function(x1, y1, x2, y2, color, thickness=0, outline=false, dash=false)
  if not this.active_drawing then return end
  
  thickness = thickness or this.shape_line_width
  if dash then this.render_target.setLineDash(dash.type == "number" and this.shape_dash or dash) end
  
  if outline then 
    this.render_target.setLineWidth(thickness+this.shape_outline_width)  
    this.render_target.drawLine(x1, y1, x2, y2, this.shape_outline_color)
  end  
  
  this.render_target.setLineWidth(thickness)
  this.render_target.drawLine(x1, y1, x2, y2, color)
  
  this.render_target.setLineWidth()
  if dash then this.render_target.setLineDash() end
end


debug.rline = function(x, y, rx, ry, color, thickness=0, outline=false, dash=false)
  if not this.active_drawing then return end
  
  thickness = thickness or this.shape_line_width
  if dash then this.render_target.setLineDash(dash.type == "number" and this.shape_dash or dash) end
  
  local x2 = x+rx
  local y2 = y+ry
  
  if outline then 
    this.render_target.setLineWidth(thickness+this.shape_outline_width)  
    this.render_target.drawLine(x, y, x2, y2, this.shape_outline_color)
  end  
  
  this.render_target.setLineWidth(thickness)
  this.render_target.drawLine(x, y, x2, y2, color)
  
  this.render_target.setLineWidth()
  if dash then this.render_target.setLineDash() end
end


debug.vec = function(px, py, dx, dy, color, thickness=0, outline=false, dash=false)
  // this is an ongoing experiment, disregard
  
  local x2 = px+dx 
  local y2 = py+dy
  
  this.line(px, py, x2, y2, color, thickness, outline, dash)
  this.fpoint(px, py, thickness*2, color, outline)
  
end


debug.rect = function(x, y, w, h, color, thickness=0, radius=0, outline=false, dash=false)
  if not this.active_drawing then return end
  
  thickness = thickness or this.shape_line_width

  if dash then this.render_target.setLineDash(dash.type == "number" and this.shape_dash or dash) end
  if outline then 
    this.render_target.setLineWidth(thickness+(owidth or this.shape_outline_width))  
    this.render_target.drawRoundRect(x, y, w, h, radius, this.shape_outline_color)
  end
  this.render_target.setLineWidth(thickness)
  this.render_target.drawRoundRect(x, y, w, h, radius, color)
  
  this.render_target.setLineWidth()
  if dash then this.render_target.setLineDash() end
end


debug.frect = function(x, y, w, h, color, radius=0, outline=false)
  if not this.active_drawing then return end
  if outline then 
    this.render_target.setLineWidth(this.shape_outline_width/2)  
    this.render_target.drawRoundRect(x, y, w+this.shape_outline_width/2, h+this.shape_outline_width/2, radius, this.shape_outline_color)
    this.render_target.setLineWidth()
  end
  this.render_target.fillRoundRect(x, y, w, h, radius, color)
end


debug.point = function(x, y, radius, color, thickness=0, outline=false, dash=false)
  if not this.active_drawing then return end

  if dash then this.render_target.setLineDash(dash.type == "number" and this.shape_dash or dash) end
  if outline then 
    this.render_target.setLineWidth(thickness+(owidth or this.shape_outline_width))  
    this.render_target.drawRound(x, y, radius*2, radius*2, this.shape_outline_color)  
  end
  this.render_target.setLineWidth(thickness or this.shape_line_width)
  this.render_target.drawRound(x, y, radius*2, radius*2, color)

  this.render_target.setLineWidth()
  if dash then this.render_target.setLineDash() end
end


debug.fpoint = function(x, y, radius, color, outline=false)
  if not this.active_drawing then return end
  
  if outline then 
    this.render_target.setLineWidth(this.shape_outline_width/2)
    this.render_target.drawRound(x, y, radius*2+this.shape_outline_width/2, radius*2+this.shape_outline_width/2, this.shape_outline_color)  
    this.render_target.setLineWidth()
  end
  this.render_target.fillRound(x, y, radius*2, radius*2, color)
end



debug.text = function(text, x, y, size, color, outline=false, font=0)
  if not this.active_drawing then return end
  
  local rtarget = this.render_target
  
  rtarget.setFont(font or this.shape_font)
  
  if outline then 
    rtarget.setLineWidth(this.shape_outline_width)
    rtarget.drawTextOutline(text, x, y, size, this.shape_outline_color)
    rtarget.setLineWidth()
  end
  
  rtarget.drawText(text, x, y, size, color)

  if font then rtarget.setFont(this.text_font_default) end
end
















/*
    
    
    Disregard everything below. It's a partial copy of my String format 
    library (version 0.9). The debugger just uses it for (my) convenience. 
    
    
*/

debug.___fmt___ = object
  // helper lookup tables
  // TODO: test if using table is faster than using strings for LUTs
  VALID = ['s', 'd', 'f', 'o', 't', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
  DIGITS = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
  
  // used to replace escaped or invalid '%'s, to mark where they are
  // because 'indexOf' always finds the first occurrence
  TEMP = "__(@^€!$~@]__"  // (just an unlikely pattern to exist in any other string)
  
  // truncate floats
  ftrunc = function(val, num_decimals)
    return round(val*10^num_decimals)/10^num_decimals
  end
  
  is_float = function(num)
    return num.type == "number" and num % 1 != 0
  end
  // parse objects, recursively, and expand their properties
  // 'obj.__str' should be an instance function that returns 
  // a string representing the object
  parse_obj = function(obj, level=0)
    // if obj.__str then return obj.__str() end
    // and obj.__str.type == "function" then return obj.__str() end
  
    local indent = ""
    local fields_str = ""
    
    for k in obj
      local v = obj[k]
      
      indent = "  "
      for i=0 to level-1 by 1 
        indent += "  " 
      end
      
      if v.type == "object" and k != "class" then 
        v = this.parse_obj(v, level+1) 
      end
      
      fields_str += indent + k + " = " + v + "\n"
    end
    
    indent = ""
    for i=0 to level-1 by 1 
      indent += "  " 
    end
    
    local out_str = "object\n" + fields_str + indent + "end"
    
    return level == 0
       and indent + out_str
        or out_str
  end
end

debug.__fmt = function(str, args)
  if args.type != "list" or args.length == 0 then return str end
  local index = str.indexOf('%')
  local i = 0

  // local j = 0  // temp safety
  while index != -1 //and j < 100
    // j += 1
    local ch = str.substring(index+1, min(index+2, str.length))
    
    // if '%' is escaped, mark it and continue
    if str.substring(index-1, index, str.length) == '\\' then
      str = str.substring(0, index-1) + str.substring(index, str.length)
      str = str.replace('%', debug.___fmt___.TEMP)
      index = str.indexOf('%')
      continue
    end
    
    if debug.___fmt___.VALID.contains(ch) then
      local arg = args[i]
      
      // not a float or no precision specified
      if not debug.___fmt___.DIGITS.contains(ch) then
        if    ch == 'd' then
          arg = if arg.type == "number" then floor(arg) else "NAN" end
        
        elsif ch == 'f' then
          arg = if arg.type == "number" then arg else "NAN" end
        
        elsif ch == 'o'and arg.type == "object" then
          arg = debug.___fmt___.parse_obj(arg)
        
        elsif ch == 't' then
          arg = arg.__type or arg.type
        else
          if arg.__str then arg = arg.__str() end
        end
        
        str = str.replace("%" + ch, arg)
      
      // it's a float with precision
      else
        if arg.type != "number" then
          str = str.replace("%" + ch, "NAN")
        else
          local tmp = str.substring(index+1, str.length)
          local ending = tmp.indexOf('f')
          
          if ending < 0 then
            str = str.replace('%', debug.___fmt___.TEMP)
            index = str.indexOf('%')
            continue
          end
          tmp = tmp.substring(0, ending+1)
          
          local prec = Number.parse(tmp.substring(0, ending))
          str = str.replace('%'+tmp, debug.___fmt___.ftrunc(arg, prec))
        end
      end
      
      index = str.indexOf('%')
      i += 1
    else
      str = str.replace('%', debug.___fmt___.TEMP)
      index = str.indexOf('%')
    end
    // print(j + " | " + str)
  end
  
  
  // j = 0  // temp safety
  while true// and j < 100
    // j += 1
    local idx = str.indexOf(debug.___fmt___.TEMP)
    if idx < 0 then break end
    str = str.replace(debug.___fmt___.TEMP, '%')
  end
  
  return str
end
