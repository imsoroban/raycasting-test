mod = function(x, y)
  pos = x - y*floor(x / y)
end


fmod = function(x,y)
  local i = floor(x/y)
  return x-i*y
end

ease_in = function(a, b, percent)
  return a + (b-a) * pow(percent, 2)
end

ease_out = function(a, b, percent)
  return a + (b-a) * (1-pow(1-percent, 2))
end

ease_in_out = function(a, b, percent)
  return a + (b-a) * ((-cos(percent*PI)/2.0) + 0.5)
end

wrap = function(val, low, high)
	if val >= high then return low + (val-high) end
	if val < low then return high - (low-val) end
	return val
end

clamp = function(val, min, max)
  return if val > max then max elsif val < min then min else val end
end

percent_remaining = function(n, total)
	return (n%total) / total
end

lerp = function(a, b, percent)
	return a + (b-a) * percent
end

deg2rad = function(deg) return deg * PI/180 end
rad2deg = function(rad) return rad * 180/PI end

// truncate floats
ftrunc = function(val, digit)
  return round(val*10^digit)/10^digit
end