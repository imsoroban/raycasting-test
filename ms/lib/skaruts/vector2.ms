/*
    
        Vector2 v0.8.1
  
*/

DEG2RAD = PI/180    // multiply degrees by DEG2RAD to convert to radians
RAD2DEG = 180/PI    // multiply randians by RAD2DEG to convert to degrees


Vector2 = class
  __type = "vector2"  // personal convention from lua
  constructor = function(x, y)
    if x.type == "list" then   // only x given as list
      this.x = x[0]
      this.y = x[1]
    elsif x.type == "object" then // only x given as object (another vec)
      this.x = x.x
      this.y = x.y
    else
      this.x = x
      this.y = y
    end
  end
  
  __str = function()
    return "(" 
         + this.x + ", "
         + this.y + ")"
  end
  
  '+' = function(a, b) 
    return b.type != "number" 
       and new Vector2(a.x + b.x, a.y + b.y)
        or new Vector2(a.x + b, a.y + b)
  end
  
  "-" = function( a, b )
    if a.type == "object" then
      return new Vector2( a.x-b.x, a.y-b.y, a.z-b.z )
    elsif b.type == "number" then 
      return new Vector2(a.x - b, a.y - b)
    else
      return new Vector2( -b.x, -b.y, -b.z )
    end
  end

  '/' = function(a, b)
    return b.type != "number" 
       and new Vector2(a.x / b.x, a.y / b.y)
        or new Vector2(a.x / b, a.y / b)
  end
  
  '*' = function(a, b)
    return b.type != "number" 
       and new Vector2(a.x * b.x, a.y * b.y)
        or new Vector2(a.x * b, a.y * b)
  end
  
  equals = function(b) 
    return this.x == b.x and this.y == b.y 
  end
end




// I like to use this function to make vectors because I'm lazy :)
vec = function(x, y) 
  return new Vector2(x, y) 
end




Vector2.length = function()
	return sqrt(this.x*this.x + this.y*this.y)
end
Vector2.magnitude = Vector2.length
Vector2.size = Vector2.length


Vector2.dot = function(o)
	return this.x*o.x + this.y*o.y
end


// Vector2.cross = function(o)
  // TODO
// end


Vector2.dist = function(o)
	return sqrt((this.x-o.x)*(this.x-o.x) + (this.y-o.y)*(this.y-o.y))
end


// square distance
Vector2.sdist = function(o) 
	return (this.x-o.x)*(this.x-o.x) + (this.y-o.y)*(this.y-o.y)
end


Vector2.pow = function(o)
	if type(o) == "number" then
		if o == 2 then new Vector2(this.x*this.x, this.y*this.y) end  // TODO: is this worth it?
		return new Vector2(this.x^o, this.y^o)
	end
	return new Vector2(this.x ^ o.x, this.y ^ o.y)
end



Vector2.angle_to = function(o)
  return (o-this).angle()
end
Vector2.angle_deg_to = function(o)
  return (o-this).angle_deg()
end



Vector2.angle = function()
	return atan2(this.y, this.x)
end
Vector2.angle_deg = function()
	return atan2d(this.y, this.x)
end
Vector2.rotation = Vector2.angle
Vector2.rotation_deg = Vector2.angle_deg



Vector2.negate = function()
	this.x = -this.x
	this.y = -this.y
end
Vector2.negated = function()
	return new Vector2(-this.x, -this.y)
end



Vector2.abs = function()
	this.x = abs(this.x)
	this.y = abs(this.y)
end
Vector2.absed = function()
	return new Vector2(abs(this.x), abs(this.y))
end




Vector2.clamp = function(mn, mx) // 2 vector args
  if mn.type == "number" then
    this.x = max(mn, min(this.x, mx))
		this.y = max(mn, min(this.y, mx))
  else
  	this.x = max(mn.x, min(this.x, mx.x))
  	this.y = max(mn.y, min(this.y, mx.y))
	end
end
Vector2.clamped = function(mn, mx) // 2 vector args
  if mn.type == "number" then
    return new Vector2(
      max(mn, min(this.x, mx)),
		  max(mn, min(this.y, mx))
    )
  end
	return new Vector2(
		max(mn.x, min(this.x, mx.x)),
		max(mn.y, min(this.y, mx.y))
	)
end



Vector2.floor = function()
	this.x = floor(this.x)
	this.y = floor(this.y)
end

Vector2.floored = function()
	return new Vector2(floor(this.x), floor(this.y))
end



Vector2.ceil = function()
	this.x = ceil(this.x)
	this.y = ceil(this.y)
end
Vector2.ceiled = function()
	return new Vector2(ceil(this.x), ceil(this.y))
end



Vector2.round = function()
	this.x = round(this.x)
	this.y = round(this.y)
end
Vector2.rounded = function()
	return new Vector2(round(this.x), round(this.y))
end



Vector2.normalize = function()
  local len = sqrt(this.x*this.x + this.y*this.y)
  this.x = this.x/len
  this.y = this.y/len
end
Vector2.normalized = function()
  local len = sqrt(this.x*this.x + this.y*this.y)
	return new Vector2(this.x/len, this.y/len)
end



Vector2.rotate = function(degs)
  local x = this.x
  local y = this.y
  this.x = cos(degs)*x - sin(degs)*y
  this.y = sin(degs)*x + cos(degs)*y
end
Vector2.rotated = function(rads)
  return new Vector2(
    cos(rads)*this.x - sin(rads)*this.y
    sin(rads)*this.x + cos(rads)*this.y
  )
end

Vector2.rotate_deg = function(degs)
  local x = this.x
  local y = this.y
  this.x = cosd(degs)*x - sind(degs)*y
  this.y = sind(degs)*x + cosd(degs)*y
end
Vector2.rotated_deg = function(degs)
  return new Vector2(
    cosd(degs)*this.x - sind(degs)*this.y
    sind(degs)*this.x + cosd(degs)*this.y
  )
end


// camelCase version of the API, for consistency with the engine's
Vector2.angleTo = Vector2.angle_to
Vector2.angleDegTo = Vector2.angle_deg_to
Vector2.rotationDeg = Vector2.angle_deg
Vector2.angleDeg = Vector2.angle_deg
Vector2.rotateDeg = Vector2.rotate_deg
Vector2.rotatedDeg = Vector2.rotated_deg










// tests
if 0 then 
  local a = new Vector2(0, 0)
  local b = new Vector2(-1, -1)
  
  
  print(a.dist(b))  
end