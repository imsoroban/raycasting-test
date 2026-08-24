
/*
  
  String format / print v0.8b

  
    Functions
    
      fmt( string, list )
      printf( string, list )
      printc( list, int )
    
    
    Format hints:
      
      %s  - converts anything to string
      %d  - integer (if it's float, gets floored; if not number, gets 'NAN')
      %o  - parse object (if value is an object, otherwise act like %s)
      %f  - float, but acts like '%s' due to no precision given
      %#f - float where '#' is a number specifying the precision (no dots)
      
*/


// TODO: would be nice to convert number strings, but I can't tell 
// when 'arg' is not a valid number string, because there's no 'nil' 
// So NAN is given when not number, so that hopefully the bugs/errors 
// caused by it are easier to catch than they would if 'Number.parse' would
// return 0 or some different number.




___fmt___ = object
  // helper lookup tables
  // TODO: test if using table is faster than using strings for LUTs
  VALID = ['s', 'd', 'f', 'o', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
  DIGITS = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
  
  // used to replace escaped or invalid '%'s, to mark where they are
  // because 'indexOf' always finds the first occurrence
  TEMP = "__(@^€!$~@]__"  // (just an unlikely pattern to exist in any string)
  
  // truncate floats
  ftrunc = function(val, num_decimals)
    return round(val*10^num_decimals)/10^num_decimals
  end
  
  is_float = function(num)
    // return num-floor(num) > 0
    return num % 1 != 0
  end
  // parse objects, recursively, and expand their properties
  // 'obj.__str' should be an instance function that returns 
  // a string representing the object
  parse_obj = function(obj, level=0)
    if obj.__str then return obj.__str() end
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

fmt = function(str, args)
  if args.type != "list" or args.length == 0 then return str end
  local index = str.indexOf('%')
  local i = 0

  // local j = 0  // temp safety
  while index != -1 //and j < 100
    // j += 1
    local ch = str.substring(index+1, min(index+2, str.length))
    
    // if '%' is escaped, continue
    if str.substring(index-1, index, str.length) == '\\' then
      str = str.substring(0, index-1) + str.substring(index, str.length)
      str = str.replace('%', ___fmt___.TEMP)
      index = str.indexOf('%')
      continue
    end
    
    if ___fmt___.VALID.contains(ch) then
      local arg = args[i]
      
      // not a float or no precision specified
      if not ___fmt___.DIGITS.contains(ch) then
        if    ch == 'd' then
          arg = if arg.type == "number" then floor(arg) else "NAN" end
        
        elsif ch == 'f' then
          arg = if arg.type == "number" then arg else "NAN" end
        
        elsif ch == 'o'and arg.type == "object" then
          arg = ___fmt___.parse_obj(arg)
        
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
            str = str.replace('%', ___fmt___.TEMP)
            index = str.indexOf('%')
            continue
          end
          tmp = tmp.substring(0, ending+1)
          
          local prec = Number.parse(tmp.substring(0, ending))
          str = str.replace('%'+tmp, ___fmt___.ftrunc(arg, prec))
        end
      end
      
      index = str.indexOf('%')
      i += 1
    else
      str = str.replace('%', ___fmt___.TEMP)
      index = str.indexOf('%')
    end
    // print(j + " | " + str)
  end
  
  
  // j = 0  // temp safety
  while true// and j < 100
    // j += 1
    local idx = str.indexOf(___fmt___.TEMP)
    if idx < 0 then break end
    str = str.replace(___fmt___.TEMP, '%')
  end
  
  return str
end


printf = function(str, args)
  print( fmt(str, args) )
end


printc = function(args, floatp=2)
  local str = ""
  floatp = "%" + floatp + "f"
  
  for i=0 to args.length-1 by 1
    local hint = "%s"
    local arg = args[i]
    
    if arg.type == "number"
    and ___fmt___.is_float(arg) then
      hint = floatp
    end

    if i != args.length-1 then hint += ", " end
    
    str += hint
    
    // if the current value is an object/class that has an '__str' 
    // method, use it and replace it with its resulting string
    if arg.__str then args[i] = arg.__str() end
  end
  
  printf(str, args)
end

