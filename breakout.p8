--breakout clone
--cakejamble (jake campbell)

function _init()
	mode = "start"
end

function _update60()
	if mode == "game" then
		update_game()
	elseif mode == "start" then
		update_start()
	elseif mode == "gameover" then
		update_gameover()
	end
end

function update_start()
	if btn(5) then 
	 startgame() 
	end
end

function startgame()
	mode="game"
	col=10
	
	--ball properties
	ball_x  = 20
	ball_y  = 10
	ball_dx = 1
	ball_dy = 1
	ball_r  = 2
	ball_dr = 0.5
	
	--paddle properties
	pad_x  = 52
	pad_y  = 120
	pad_dx = 0
	pad_dy = 0
	pad_w  = 24
	pad_h  = 3
	pad_c  = 7

	--brick properties
--brick_y  = 20
	brick_w  = 10
	brick_h  = 4
	buildbricks()  
	
	--player stats
	lives =3	
	points=0
	
	serveball()
end

function buildbricks()
 local i
	brick_x={}
	brick_y={}
	brick_v={}
	
	for i=1,10 do
		add(brick_x,5+(i-1)*(brick_w+2))
		add(brick_y,20)
		add(brick_v,true)
	end
end

function serveball()
	ball_x  = 5
	ball_y  = 33
	ball_dx = 1
	ball_dy = 1
end

function gameover()
	mode="gameover"	
end

function update_gameover()
	if btn(5) then startgame() end
end

function update_game()
	local btnpress=false
	local nextx,nexty
	
	--paddle speed left
	if btn(0) and pad_x > 0 then
		pad_dx=-2.5
		btnpress=true
	end
	--paddle speed right
	if btn(1) and pad_x+pad_w < 128 then
		pad_dx=2.5
		btnpress=true
	end
	
	--paddle deceleration
	if not btnpress then
		pad_dx/=2.25
	end
	
	--paddle movement
	pad_x+=pad_dx
	pad_x=mid(0,pad_x,127-pad_w)
	
	--compute ball movement
	nextx = ball_x + ball_dx
 nexty = ball_y + ball_dy
	
	--ball boundary detect x
	if nextx > 124 or nextx < 3 then
		nextx=mid(0,nextx,127)
		
		ball_dx = -ball_dx
		sfx(0)
	end

	--ball boundary detect y
	if nexty < 10 then
		nexty=mid(0,nexty,127)

		ball_dy = -ball_dy 
	 sfx(0)
	end
	
	--handling ball/pad collision
	if ball_box(nextx,nexty,pad_x,pad_y,pad_w,pad_h) then
		--set direction for deflection
		if deflx_ballbox(ball_x,ball_y,ball_dx,ball_dy,pad_x,pad_y,pad_w,pad_h) then
			ball_dx = -ball_dx
		
		else
			ball_dy = -ball_dy
		end				
		sfx(1)
		points+=1
	end
	
	--update ball coords
	ball_x=nextx
	ball_y=nexty
	
	--handling ball/brick collision
	local i	
	for i=1,#brick_x do
		if brick_v[i] and ball_box(nextx,nexty,brick_x[i],brick_y[i],brick_w,brick_h) then
			--set direction for deflection
			if deflx_ballbox(ball_x,ball_y,ball_dx,ball_dy,brick_x[i],brick_y[i],brick_w,brick_h) then
				ball_dx = -ball_dx		
			else
				ball_dy = -ball_dy
			end				
		 sfx(6)
			brick_v[i]=false
			points+=10
		end
	end
	

	
	--check for fail-state
	if nexty > 124 then
		sfx(5)
		lives-=1
		if lives < 0 then
			gameover()	
		end
		
		serveball()
	end
end

function _draw()
	if mode == "game" then
		draw_game()
	elseif mode == "start" then
		draw_start()
	elseif mode == "gameover" then
		draw_gameover()
	end
end

function draw_start()
	cls()
	print("breakout clone ♥", 30, 40, 7)
	print("press ❎ to start", 32, 80, 11)
end

function draw_gameover()
	rectfill(0,60,128,75,0)
	print("game over",46,62,7)
	print("press ❎ to restart",25,68,11)
end

function draw_game()
	cls(1)
	circfill(ball_x,ball_y, ball_r,col)
	rectfill(pad_x,pad_y,pad_x+pad_w,pad_y+pad_h,pad_c)

	--drawing bricks
	local i	
	for i=1,#brick_x do
		if brick_v[i] then 
			rectfill(brick_x[i],brick_y[i],
												brick_x[i]+brick_w,
												brick_y[i]+brick_h,14)
		end
	end
		
	rectfill(0,0,128,6,0)
	print("lives: "..lives,1,1,7)
	print("score: "..points,40,1,7)
end

--checks for ball collision with rect
function ball_box(bx,by,box_x,box_y,box_w,box_h)
	if by-ball_r > box_y+box_h then	return false end
	if by+ball_r < box_y then	return false	end
	if bx-ball_r > box_x+box_w then	return false	end
	if bx+ball_r < box_x then	return false	end
	return true
end

function hit_ballbox(bx,by,tx,ty,tw,th)
 if bx+ball_r < tx then return false end
 if by+ball_r < ty then return false end
 if bx-ball_r > tx+tw then return false end
 if by-ball_r > ty+th then return false end
 return true
end

function deflx_ballbox(bx,by,bdx,bdy,tx,ty,tw,th)
 -- calculate wether to deflect the ball
 -- horizontally or vertically when it hits a box
 if bdx == 0 then
  -- moving vertically
  return false
 elseif bdy == 0 then
  -- moving horizontally
  return true
 else
  -- moving diagonally
  -- calculate slope
  local slp = bdy / bdx
  local cx, cy
  -- check variants
  if slp > 0 and bdx > 0 then
   -- moving down right
   debug1="q1"
   cx = tx-bx
   cy = ty-by
   if cx<=0 then
    return false
   elseif cy/cx < slp then
    return true
   else
    return false
   end
  elseif slp < 0 and bdx > 0 then
   debug1="q2"
   -- moving up right
   cx = tx-bx
   cy = ty+th-by
   if cx<=0 then
    return false
   elseif cy/cx < slp then
    return false
   else
    return true
   end
  elseif slp > 0 and bdx < 0 then
   debug1="q3"
   -- moving left up
   cx = tx+tw-bx
   cy = ty+th-by
   if cx>=0 then
    return false
   elseif cy/cx > slp then
    return false
   else
    return true
   end
  else
   -- moving left down
   debug1="q4"
   cx = tx+tw-bx
   cy = ty-by
   if cx>=0 then
    return false
   elseif cy/cx < slp then
    return false
   else
    return true
   end
  end
 end
 return false
end