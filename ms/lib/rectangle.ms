
Rect = class
  __type = "Rect"
  constructor = function(x, y, w, h)
    this.x = x
    this.y = y
    this.w = w
    this.h = h
  end
  
  '+' = function(a, b) end
  '-' = function(a, b) end
  '/' = function(a, b) end
  '*' = function(a, b) end
  
  eq = function(b) end
end

rect = function(x, y, w, h) return new Rect(x, y, w, h) end


