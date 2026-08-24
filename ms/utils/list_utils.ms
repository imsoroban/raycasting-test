// a half-assed deepcopy function 
// it's just good enough for the cave generation algorithm
List.deepcopy = function(array)
  local w = array[0].length
  local h = array.length
  
  local out = []
  for j=0 to h-1 by 1
    out.push( [] + array[j] )
  end
  return out
end


// prints out a 1D array as a 2D grid
List.print1d = function(arr, w, h)
  local str = ""
  for j=0 to h-1 by 1
    for i=0 to w-1 by 1
      str += arr[i+j*w]
    end
    str+='\n'
  end
  print(str)
end


// prints out a 2D array as a 2D grid
List.print2d = function(arr, w, h)
  // local w = array[0].length
  // local h = array.length
  local str = "\n"
  
  for j=0 to h-1 by 1
    for i=0 to w-1 by 1
      str += arr[j][i] + ' '
    end
    str+='\n'
  end
  
  print(str)
end



// create a new 1D array, filled with 'def_val'
// 'def_val' can also be a function that returns the intended value
List.new_1d = function(len, def_val)
  local list = []
  if def_val.type == "function" then 
    local func = def_val
    for i=0 to len-1 by 1
      list.push( func() )
    end
  else
    for i=0 to len-1 by 1
      list.push( def_val )
    end
  end
  return list
end


// create a new 2D array, filled with 'def_val'
// 'def_val' can also be a function that returns the intended value
List.new_2d = function(w, h, def_val)
  local list = []
  if def_val.type == "function" then 
    local func = def_val
    for j=0 to h-1 by 1
      list.push([])
      for i=0 to w-1 by 1
        list[j].push( func() )
      end
    end
  else
    for j=0 to h-1 by 1
      list.push([])
      for i=0 to w-1 by 1
        list[j].push( def_val )
      end
    end
  end
  return list
end

// return a random element from the list 'l'
List.rand = function(l)
  return l[ random.nextInt(l.length) ]
end