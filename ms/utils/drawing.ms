draw_text_outlined = function(draw_target, text, x, y, size, color, shadow_color="#000")
  local thickness  = 2      // shadow thickness (more than 3 doesn't realy work)
  
  // orthogonals
  draw_target.drawText(text, x,           y-thickness, size, shadow_color)
  draw_target.drawText(text, x-thickness, y,           size, shadow_color)
  draw_target.drawText(text, x+thickness, y,           size, shadow_color)
  draw_target.drawText(text, x,           y+thickness, size, shadow_color)
  
  // diagonals
  draw_target.drawText(text, x-thickness, y-thickness, size, shadow_color)
  draw_target.drawText(text, x+thickness, y-thickness, size, shadow_color)
  draw_target.drawText(text, x-thickness, y+thickness, size, shadow_color)
  draw_target.drawText(text, x+thickness, y+thickness, size, shadow_color)
  
  draw_target.drawText(text, x, y, size, "#fff")
end



// for when drawing on images (top-left origin)

draw_circle = function(draw_target, x, y, rad, color)
  draw_target.drawRound(x-rad, y-rad, rad*2, rad*2, color)
end

fill_circle = function(draw_target, x, y, rad, color)
  draw_target.fillRound(x-rad, y-rad, rad*2, rad*2, color)
end