init_floor_casting = fuction()
local tex_w = sprites[map.floor].width
local tex_h = sprites[map.floor].height
local floor_texture = sprites[map.floor].frames[0]

floor_buffer = List.new_2d(tex_w, tex_h, 0)

for j=0 to tex_h-1 by 1
