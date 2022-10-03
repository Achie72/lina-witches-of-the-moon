pico-8 cartridge // http://www.pico-8.com -- luacheck: ignore
version 38 -- luacheck: ignore
__lua__
player = {
	x = 8,
	y = 64,
	moving = false,
	life = 3,
	maxLife = 4,
	shooting = false,
	collisionWidth = 8,
	collisionHeigth = 8,
	flashTime = 0,
	invTime = 0,
	attackType = 0,
	cats = 0
}

ax, ay = 0,0

mode = 0 --0 menu, 1 game, 3 wave clear, 4 game over, 5 tutorial
score = 0
attackFreq = 2
started, canSpawnMoon, won, musicOn = false, false, false, true
stage,wave,splashScreenTime,nextAttack,nextShoot,offset,freeze,catTimer,catZeroIndicator,scoreThousands,highScore, highScoreThousands, moonSpawn, moonGlitch, wonTime, moonX, moonY, boom, propX, propY, propRnd, starTime = 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

bg_elements, scores, player_bullets, pickups, enemy_bullets, enemies, particles, shockwaves, pPos = {}, {}, {}, {}, {}, {}, {}, {}, {}
catX, catY, forceShield, shotCooldown, tutorialChapter, tutorialCd, gauge, t = 0, 0, 0, 0, 0, 0, 0, 0

tutorialBackWard = {
	x = 36,
	y = 10,
	collisionWidth = 8,
	collisionHeigth = 8
}

tutorialForward = {
	x = 84,
	y = 10,
	collisionWidth = 8,
	collisionHeigth = 8
}
hyper = false


mapString = {
    "1, 1, 1, 1, 1, 1, 1, 1, 1           | 1, 1, 1, 1, 1, 1, 1, 1, 1            | 1, 1, 1, 1, 1, 1, 1, 1, 1             | 1, 1, 1, 1, 1, 1, 1, 1, 1 ",
    "1, 0, 2, 1, 1, 1, 2, 0, 1           | 1, 0, 2, 1, 1, 1, 2, 0, 1            | 1, 2, 2, 1, 2, 1, 2, 2, 1             | 1, 2, 2, 1, 2, 1, 2, 2, 1 ",
    "0, 0, 0, 0, 0, 0, 0, 0, 0           | 0, 0, 0, 0, 0, 0, 0, 0, 0            | 0, 5, 0, 0, 0, 0, 5, 0, 0             | 0, 0, 0, 0, 0, 0, 0, 0, 0 ",
    "1, 1, 1, 1, 1, 1, 1, 1, 1           | 2, 0, 0, 1, 2, 1, 0, 0, 2            | 2, 5, 0, 1, 2, 1, 5, 0, 2             | 2, 0, 0, 2, 2, 2, 0, 0, 2 ",
    "0, 0, 0, 0, 0, 0, 0, 0, 0           | 0, 0, 0, 0, 0, 0, 0, 0, 0            | 0, 0, 0, 0, 6, 0, 0, 0, 0             | 0, 0, 0, 0, 0, 0, 0, 0, 0 ",
    "7, 7, 7, 7, 7, 7, 7, 7, 7           | 7, 3, 3, 7, 7, 7, 3, 3, 7            | 7, 3, 0, 3, 7, 3, 0, 3, 7             | 7, 0, 3, 0, 7, 0, 3, 0, 7 ",
    "7, 0, 8, 0, 7, 0, 8, 0, 7           | 7, 0, 8, 0, 7, 0, 8, 0, 7            | 7, 7, 8, 8, 7, 8, 8, 7, 7             | 7, 7, 8, 8, 7, 8, 8, 7, 7 ",
    "0, 0, 0, 0, 0, 0, 0, 0, 0           | 0, 0, 0, 0, 0, 0, 0, 0, 0            | 0, 10, 0, 0, 0, 0, 0, 10, 0           | 0, 0, 0, 0, 0, 0, 0, 0, 0 ",
    "7, 7, 7, 7, 7, 7, 7, 7	, 7          | 7, 0, 0, 8, 8, 8, 0, 7, 7            | 0, 8, 0, 7, 10, 7, 0, 8, 0            | 0, 8, 8, 7, 7, 7, 8, 8, 0 ",
    "0, 0, 0, 0, 0, 0, 0, 0	, 0          | 0, 0, 0, 0, 0, 0, 0, 0, 0            | 0, 0, 0, 0, 9, 0, 0, 0, 0             | 0, 0, 0, 0, 0, 0, 0, 0, 0 ",
    "11, 11, 11, 11, 11, 11, 11, 11, 11  | 11, 11, 11, 11, 11, 11, 11, 11, 11   | 11, 11, 11, 11, 11, 11, 11, 11, 11    | 11, 11, 11, 11, 11, 11, 11, 11, 11 ",
    "11, 13, 13, 11, 11, 11, 13, 13, 11  | 11, 13, 13, 11, 11, 11, 13, 13, 11   | 11, 13, 13, 13, 13, 13, 13, 13, 11    | 11, 13, 13, 13, 13, 13, 13, 13, 11 ",
    "0,  0, 0, 0, 0, 0, 0,  0, 0         | 0,  0, 0, 0, 0, 0, 0,  0, 0          | 0, 14, 0, 0, 0, 0, 0, 14, 0           | 0, 0, 0, 0, 0, 0, 0, 0, 0",
    "11, 11, 0, 13, 13, 13, 0, 11, 11    | 11, 11, 0, 13, 13, 13, 0, 11, 11     | 0 , 14, 0, 13, 13, 13, 0, 14,  0      | 0, 0, 0, 0, 0, 0, 0, 0, 0",
    "0, 0, 0, 0, 0, 0, 0, 0, 0           | 0, 0, 0, 0, 0, 0, 0, 0, 0            | 0, 0, 0, 0, 12, 0, 0, 0, 0            | 0, 0, 0, 0, 0, 0, 0, 0, 0",
    "0, 0, 0, 0, 0, 0, 0, 0, 0           | 0, 0, 0, 0, 0, 0, 0, 0, 0            | 0, 0, 0, 0, 15, 0, 0, 0, 0            | 0, 0, 0, 0, 0, 0, 0, 0, 0"
}


function toggle_music()
	musicOn = not musicOn
	if musicOn then
		music(0)
	else
		music(-1,300)
	end
end

function _init()
	cartdata("lina_witches_of_the_moon")
	menuitem(2, "toggle music", toggle_music)
	music(0)
	for i=1,25 do
		local star = {
			x = rnd(128),
			y = 10+flr(rnd(90)),
			clr = 1+flr(rnd(2))*5,
			spd = 2,
			spr = nil
		}
		add(bg_elements, star)
		local tree = {
			x = rnd(128),
			y = 120,
			clr = nil,
			spd = 4,
			spr = 60 + (flr(rnd(4)))
		}
		add(bg_elements, tree)
		local pTree = {
			x = rnd(128),
			y = 116,
			clr = nil,
			spd = 3,
			spr = 58 + (flr(rnd(2)))
		}
		add(bg_elements, pTree)
	end
end

function animate(object,starterframe,framecount,animspeed,flipped,isplayer,isBig,shake)
	if isBig == nil then isBig = false end
	if shake == nil then shake = false end
	if(not object.tickcount) then
		object.tickcount=0
	end
	if(not object.spriteoffset) then
		object.spriteoffset=0
	end

	object.tickcount+=1

	if(object.tickcount%(flr(60/animspeed))==0) then	
		if isBig then
			object.spriteoffset+=2
			if (object.spriteoffset>=framecount*2) then
			 	object.spriteoffset=0
			end
		else	
			object.spriteoffset+=1
			if (object.spriteoffset>=framecount) then
			 	object.spriteoffset=0
			end
		end
	end

	object.actualframe=starterframe+object.spriteoffset

	if not isBig then
		if object.actualframe >= starterframe+framecount then
			object.actualframe = starterframe
		end
	else
		if object.actualframe >= (starterframe+framecount)*2 then
			object.actualframe = starterframe
		end
	end

	local offsetX = 0
	local offsetY = 0
	if shake then
		offsetX = rnd()*3
		offsetY = rnd()*3
	end
		
	if isBig then
		spr(object.actualframe, object.x+offsetX, object.y+offsetY, 2, 2, flipped)
	else
		spr(object.actualframe, object.x+offsetX, object.y+offsetY, 1, 1, flipped)
	end
end

function add_score(_x, _y, _value)
	local s = {
		x = _x,
		y = _y,
		value = _value
	}
	add(scores, s)
end

function add_pickup(_x, _y, _tpe)
	local p = {
		x = _x,
		y = _y,
		tpe = _tpe,
		collisionWidth = 8,
		collisionHeigth = 8
	}
	add(pickups, p)
end

function add_shockwave(_x, _y, _size, _clr, _spd)
	local sw = {
		x = _x,
		y = _y,
		size = 1,
		targetSize = _size,
		clr = _clr,
		spd = _spd
	}
	add(shockwaves, sw)
end

function add_enemy(_x, _y, _tpe, _wait)
	local lives = split("8, 12, 24, 2, 140, 360, 16, 24, 400, 140, 24, 440, 16, 160, 200, 900",",")
	local sprites = split("64, 66, 68, 70, 80, 0, 72, 74, 0, 84, 76, 0, 78, 88, 0, 0",",")
	local sizes = split("1,1,1, 1, 2, 1, 1, 1, 1, 2, 1, 1, 1, 2, 1, 4",",")
	-- "up-down", "stationary", "forward-back", "circle", "spawning"
	local bossPhases = { {"up-down", "stationary", "forward-back"}, {"forward-back", "circle", "up-down", "forward-back"}, {"spawning", "up-down", "circle", "spawning"}, {"circle", "up-down", "circle", "spawning"}, {"up-down", "circle", "forward-back", "spawning"} }
	-- "single", "double", "trio", "cross", "diagonal", "ortogonal", "aimed", "spiral"
	-- spawnrules follow: { number, type, times}
	local bossPhaseAttackPattern = {{"single", "trio", "cross"},    {"circle", "aimed", "spiral", "circle"},                  {{6, 7, 2}, "spiral", "aimed", {4, 8, 7}},     {"circle", "trio", "aimed", {2, 11, 2}},      {"circle", "aimed", "spiral", {2, 14, 2}}}

	local enemy = {
		x = _x+40,
		y = 110 ,
		sx = 0,
		sy = 0,
		posx = _x,
		posy = _y,
		life = lives[_tpe],
		tpe = _tpe,
		spr = sprites[_tpe],
		size = sizes[_tpe],

		animFrames = 2,
		animSpeed = 6,
		collisionWidth = sizes[_tpe]*8,
		collisionHeigth = sizes[_tpe]*8,
		flash = 0,
		shoot = 0,
		mission = "flyin",
		submission = "",
		wait = _wait,
		isWitch = false,
		phaseBegin = 0,
		shake = 0,
		bossIndex = 0,
		phases = nil,
		attackPattern = nil,
		attackPatterns = nil,
		phaseNumber = 0,
		indicator = 0,
		falling = false,
		spawnTime = 0
	}
	-- small ghost, do not return to spawn
	if (_tpe == 4) then
		enemy.x = _x-4
		enemy.y = _y
	end
	if (_tpe == 6) or (_tpe == 9) or (_tpe == 12) or (_tpe == 15) or (_tpe == 16) then
		enemy.isWitch = true
		enemy.bossIndex = _tpe/3-1
		if (_tpe == 16) then enemy.bossIndex = 5 end
		if (not _tpe == 16) enemy.collisionHeigth = 10
	end
	if enemy.isWitch then
		enemy.phases = bossPhases[enemy.bossIndex]
		enemy.attackPatterns = bossPhaseAttackPattern[enemy.bossIndex]
		enemy.phaseNumber = #enemy.attackPatterns
		enemy.indicator = 0
	end
	add(enemies, enemy)
end

function add_player_bullet(_x, _y, _tpe, _sx, _sy)
	local damages = split("3, 4, 4, 8, 3, 7, 2, 3")

	local bul = {
		x = _x,
		y = _y,
		sx = _sx,
		sy = _sy,
		tpe = _tpe,
		speed = _speed,
		dmg = damages[_tpe],
		collisionWidth = 2,
		collisionHeigth = 2
	}
	add(player_bullets, bul)

end

function add_enemy_bullet(_x, _y, _sx, _sy, _tpe, _speed)
	local bul = {
		x = _x,
		y = _y,
		sx = _sx*_speed,
		sy = _sy*_speed,
		spr = 10+_tpe,
		tpe = _tpe,
		speed = _speed,
		collisionWidth = 3,
		collisionHeigth = 3,
		spr = 112 + _tpe*2,
		animFrames = 2,
		animSpeed = 6
	}
	add(enemy_bullets, bul)

end

function load_wave_string (_idx)
    return split(mapString[_idx], "|")
end

function spawn_wave_waves(_wave)
    for lineIdx=1,#_wave do
        local waveLine = split(_wave[lineIdx], ",", true)
        for enemyNumber=1,#waveLine do
            if not (waveLine[enemyNumber] == 0) then
                add_enemy(80+lineIdx*10, 12+enemyNumber*10,waveLine[enemyNumber], enemyNumber*6)
            end
        end
    end
end

function spawn_wave()
	sfx(1)
	started = true
    stage = 1 + flr(wave/6)
    spawn_wave_waves(split(mapString[wave], "|"))
end

function place_enemies(lvl)
	for x=1,4 do
		for y=1,9 do
			if not (lvl[x][y] == 0) then
				add_enemy(80+x*10, 12+y*10,lvl[x][y], y*6)
			end
		end
	end
end


function collide(a, b)
	if (a.collisionWidth == nil)  a.collisionWidth = 0 
	if (a.collisionHeigth == nil)  a.collisionHeigth = 0 
	if (b.collisionWidth == nil)  b.collisionWidth = 0 
	if (b.collisionHeigth == nil)  b.collisionHeigth = 0 

	local aLeft = a.x
	local aTop = a.y
	local aRigth = a.x+a.collisionWidth-1
	local aBottom = a.y+a.collisionHeigth-1

	local bLeft = b.x
	local bTop = b.y
	local bRigth = b.x+b.collisionWidth-1
	local bBottom = b.y+b.collisionHeigth-1

	if (aTop > bBottom)  return false 
	if (bTop > aBottom)  return false 
	if (aLeft > bRigth)  return false 
	if (bLeft > aRigth)  return false 

	return true
end

function add_bg(_tick,_speed)
	if (t%_tick*2 == 0) then
		local star = {
			x = 128,
			y = 10+flr(rnd(90)),
			clr = 1+flr(rnd(2))*5,
			spd = 2*_speed,
			spr = nil
		}
		add(bg_elements, star)
		local tree = {
			x = 128,
			y = 120,
			clr = nil,
			spd = 4*_speed,
			spr = 60 + (flr(rnd(4)))
		}
		add(bg_elements, tree)
		local pTree = {
			x = 128,
			y = 116,
			clr = nil,
			spd = 3*_speed,
			spr = 58 + (flr(rnd(2)))
		}
		add(bg_elements, pTree)
	end
end

function start_game()
	mode = 1
	player = {
		x = 8,
		y = 64,
		moving = false,
		life = 4,
		maxLife = 4,
		shooting = false,
		collisionWidth = 8,
		collisionHeigth = 8,
		flashTime = 0,
		invTime = 0,
		cats = 0,
		attackType = 0
	}

	wave, nextAttack, moonSpawn, moonGlitch, t, offset, boom, score, scoreThousands, stage, forceShield, catX, catY, attackFreq, gauge = 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, player.x+8, player.y, 2, 0
	started, canSpawnMoon, won = false, false, false
	
	player_bullets, enemy_bullets, pickups, scores, enemies, particles, pPos = {}, {}, {}, {}, {}, {}, {}
end

function count_down(_var)
	return max(_var-1, 0)
end

function _update60()
	add_bg(4, 0.5)
	t+=1
	if t>=60 then
		t = 0
	end
	
	if mode == 0 then
		update_menu()
	elseif mode == 1 then
		update_game()
	elseif mode == 2 then
		update_splash_screen()
	elseif mode == 3 then
		update_game_over()
	elseif mode == 4 then
		start_game()
	elseif mode == 5 then
		update_tutorial()
	end
	update_stars()
end

function update_tutorial()
	control_player()
	update_bullets()
	update_particles()
	update_pickups()
	update_enemies()
	tutorialCd = count_down(tutorialCd)

	if tutorialCd == 0 then
		if collide(player, tutorialForward) then
			enemies = {}
			tutorialChapter += 1
			tutorialCd = 120
		end
		if collide(player, tutorialBackWard) then
			enemies = {}
			tutorialChapter -= 1
			tutorialCd = 120
		end
		if tutorialChapter < 0 then
			tutorialChapter = 3
		end

		if tutorialChapter > 2 then
			tutorialChapter = 0
		end
	end


	--[[
		0 - Main Hub
		1 - HP Hub
		2 - Shooting Hub
		3 - Special Hub
	]]--

	if (time()%0.5 == 0) then
		if tutorialChapter == 1 then
			add_pickup(10, 40, 0)
			add_pickup(10, 66, 7)
			add_pickup(10, 80, 6)
		end

		if tutorialChapter == 2 then
			for i=0,3 do
				add_pickup(10, 38+i*10, 1+i)
			end
			add_pickup(10,78, 8)
			add_pickup(10, 88, 5)
		end

		add_enemy_bullet(127, 104, -1, 0, 0, 1)
	end

	if (#enemies == 0) then
		add_enemy(100, 40, 1, 2)
		add_enemy(100, 48, 1, 10)
		add_enemy(100, 56, 1, 20)
	end

	if tutorialChapter == 0 then
		if player.x > 120 then
			mode = 4
		end
	end

	--[[
	0 -> Potion
	1 -> Shield
	2 -> simple atk
	3 -> 2x atk
	4 -> 3x atk
	5 -> cat bomb
	6 -> star
	]]--

	
end


function update_splash_screen()
	player.moving = true
	splashScreenTime -= 1
	if splashScreenTime <= 0 then
		mode = 1
		spawn_wave()
	end

end

function update_menu()
	highScore = dget(0)
	highScoreThousands = dget(1)
	if btnp(4) then
		player.x, player.y, catX, catY = 64, 64, 50, 50
		mode = 5
	end

	if propX <= 0 then
		propX, propY, propRnd = 130, 20+rnd(90), flr(rnd(2))
	else
		propX -= 1
	end

	propY += sin(t)
end

function update_game_over()
	if btnp(5) then
		start_game()
		mode = 0
		music(0)
	end
	update_particles()
end
	

function update_game()

	moonSpawn = count_down(moonSpawn)
	moonGlitch = count_down(moonGlitch)
	wonTime = count_down(wonTime)
	

	if score > 9999 then
		score = score - 9999
		scoreThousands+= 1
	end

	if gauge >= 128 then
		hyper = true
	end

	if gauge <= 0 then
		if (hyper) then
			starTime = 90
			forceShield = 0
		end
		hyper = false
		
	end

	if (hyper) then
		if (t%20 == 0) offset = 0.1
		forceShield = 100
		starTime = 100
		gauge -= 0.9
	end

	update_particles()

	if (won) and (wonTime > 0) then
		if t%6 == 0 then
			explode_part(moonX+rnd(10), moonY+rnd(10), "circle", 7, boom)
			sfx(2)
			offset=0.2
			boom += 0.05
		end
	end

	if (won) and (wonTime == 0) then
		mode = 3
	end
 
	if freeze > 0 then
		freeze -= 1
		if freeze <= 0 then
			mode = 3
		end
		player.x += ax
		ax = ax * 0.99
		player.y += ay
		ay = ay * 1.05

	else
		if ((#enemies == 0) and (#pickups == 0) and (not won)) then
			wave+= 1
			splashScreenTime = 180
			mode = 2
			enemy_bullets = {}
			particles = {}
			shockwaves = {}
			player_bullets = {}
			pickups = {}
			if (wave % 5 == 0) then 
				music(31)
			elseif (wave % 6 == 0) then
				music(0)
				sfx(5)
			end
		end

		control_player()
		update_bullets()
		update_enemies()

		--select attacker
		if (time() > nextAttack) and (#enemies > 0) then
			trigger_next_attack()
		end
		if (time() > nextShoot) and (#enemies > 0) then
			local maximum = min(10, #enemies)
			-- picker algo
			local myIndex = flr(rnd(maximum)+1)
			local enemy = enemies[myIndex]
			if enemy.mission == "protect" then
				enemy.shoot = 10
				local pattern = "single"
				local ang = 0
				if (wave > 5) then
					pattern = "double"
					angle = 0.5
				end
				if (wave > 10) pattern = "trio"
				attack_with_pattern(enemy, pattern, angle, 0.8)			
				
				
				sfx(4)
			end
			nextShoot = time() + (attackFreq*0.3)
		end

		if player.life <= 0 then
			freeze = 360
			ay = 1
			if ax == 0 then
				ax = 1
			end
		end

		update_pickups()
		for s in all(scores) do
			local ang = atan2(s.y, s.x-60)
			if (s.y <= 10) then
				score += s.value
				del(scores,s)
			end
			s.x -= sin(ang)*2
			s.y -= cos(ang)*2
		end

      
        
	end
end

function trigger_next_attack()
	local maximum = min(10, #enemies)
	-- picker algo
	local myIndex = flr(rnd(maximum)+1)
	local enemy = enemies[myIndex]
	if enemy.mission == "protect" then
		enemy.mission = "attack"
		enemy.shake = 16
		enemy.wait = 16
		if enemy.tpe == 2 then
			enemy.changed = false
		end
	end
	nextAttack = time() + attackFreq*2
end

function control_player()

	local px, py = player.x, player.y
	catTimer = count_down(catTimer)
	catZeroIndicator = count_down(catZeroIndicator)
	player.invTime = count_down(player.invTime)
	player.flashTime = count_down(player.flashTime)
	starTime = count_down(starTime)
	forceShield = count_down(forceShield)

	ax = 0
	ay = 0

	player.shooting = false
	player.moving = false

	if(btn(⬅️)) then 
		ax-=1.5 
		player.moving = true
	end
	if(btn(➡️)) then 
		ax+=1.5 
		player.moving = true
	end
	if(btn(⬆️)) then 
		ay-=1.5 
		player.moving = true
	end
	if(btn(⬇️)) then 
		ay+=1.5 
		player.moving = true
	end

	if (player.moving) then
		local p = {
			x = player.x,
			y = player.y
		}
		add(pPos, p)
	end

	
	if (#pPos > 10) then
		catX = pPos[1].x
		catY = pPos[1].y
		del(pPos, pPos[1])
	end
	
	-- normalize speed
	if (ay < 0) and (ay < -2) then ay = -2 end
	if (ay > 0) and (ay > 2) then ay = 2 end
	if (ax < 0) and (ax < -2) then ax = -2 end
	if (ax > 0) and (ax > 2) then ax = 2 end

	px += ax
	py += ay

	if px < 0 then
		px = 0
	end
	if px > 124 then
		px = 124
	end
	if py < 0 then 
		py = 0
	end
	if py > 120 then
		py = 120
	end

	if btn(4) then
		if (t%10 == 0) add_player_bullet(catX, catY, 1, 2, 0)
		if (time() > shotCooldown) then
			local damage = player.attackType + 1
			local coolDown = 0
			if (hyper) damage = 6
			local posX, posY = px+6, py+6
			if (player.attackType == 0) then
				add_player_bullet(posX, posY, damage, 2, 0)
				coolDown = 0.05
			elseif player.attackType == 1 then
				add_player_bullet(posX, posY, damage, 2, 0.15)
				add_player_bullet(posX, posY, damage, 2, -0.15)
				coolDown = 0.1
			elseif player.attackType == 2 then
				for i=-0.5,0.5,0.5 do
					add_player_bullet(posX, posY, damage, 2, i/2)
				end
				coolDown = 0.15
			elseif player.attackType == 4 then
				--for i=-1,1, 0.0625 do
					local a = sin((60-t)/50)*2
					local b = cos((60-t)/50)*2
					add_player_bullet(posX, posY, damage, a, b)
					add_player_bullet(posX, posY, damage, -a, -b)
				coolDown = 0.02
			else
				local w = t/10
				for i=-w,w,w/4 do
					add_player_bullet(posX, posY, damage, cos(i), sin(i/2))
				end
				coolDown = 0.2
			end
			
			sfx(0)
			if (hyper) coolDown = coolDown/2
			shotCooldown = time() + coolDown
			player.shooting = true
		end
	end

	if btnp(5) then
		if (player.cats >= 1) and (catTimer <= 0) then
			offset = 0.4
			for i=0.6,0.9,0.01 do
				add_player_bullet(px+6, py+6, 4, sin(i)*4, cos(i)*3)
				sfx(7)
				player.shooting = true
				catTimer = 180
			end
			for b in all(enemy_bullets) do
				explode_part(b.x, b.y, "circle", 3)
				del(enemy_bullets, b)
			end
		else
			catZeroIndicator = 20
		end
	end
	player.x, player.y = px, py
end


--[[
0 -> Potion
1 -> Shield
2 -> simple atk
3 -> 2x atk
4 -> 3x atk
5 -> cat bomb
6 -> star
]]--
function update_pickups()
	for p in all(pickups) do
		if collide(p, player) then
			local mult = 1
			local pType = p.tpe
			if pType == 0 then
				if player.life < player.maxLife then
					player.life +=1
				end
				if player.life == player.maxLife then 
					mult = 10 
				end
			end
			if pType == 1 then
				player.attackType = 0
			end
			if pType == 2 then
				player.attackType = 1
			end
			if pType == 3 then
				player.attackType = 2
			end
			if pType == 4 then
				player.attackType = 4
			end
			if pType == 5 then
				player.cats += 1
			end
			if pType == 6 then
				starTime = 280
			end
			if pType == 7 then
				forceShield = 360
			end
			if pType == 8 then
				player.attackType = 7
			end
			sfx(6)
			del(pickups, p)
			add_score(p.x+4, p.y+4, (pType+1) * 100 * mult)
		end
		p.x -= 0.5
		if p.x <= -8 then
			del(pickups,p)
		end
	end
end

--[[
0 -> Potion
1 -> simple atk
2 -> 2x atk
3 -> 3x atk
4 -> waves
5 -> frog bomb
6 -> star
7 -> shield
8 -> spiral
]]--
function spawn_pickup(_x, _y)
	local picks = split("0,0,0,0,0,0,1,1,2,2,3,3,4,4,5,6,7,8,8",",")
	local dupes = {}

	if (player.life == player.maxLife) then
		add(dupes, 0)
	end

	for i=0,4-player.life do
		add(picks, 0)
	end


	add(dupes, player.attackType)

	local randomDrop;
	local isDupe = false
	repeat
		isDupe = false
		randomDrop = rnd(picks)
		for e in all(dupes) do
			if (e == randomDrop) isDupe = true
		end
	until(not isDupe)

	add_pickup(_x, _y, randomDrop)
end

function update_stars()
	for element in all(bg_elements) do
		if mode == 2 then
			element.x -= element.spd*2
		else
			element.x -= element.spd
		end
		if element.x < 0 then
			del(bg_elements, element)
		end
	end
end

function player_hit()
	player.flashTime = 90
	player.invTime = 90
	player.life -= 1
	offset = 0.2
	gauge = 0
	explode_part(player.x, player.y, "circle", 14, 1)
		--player.shields -= 1
		--player.shieldTime = 40
	sfx(3)
end

function update_enemies()
	for enemy in all(enemies) do
		enemy.shake = count_down(enemy.shake)
		--[[
		if enemy.shake > 0 then
			enemy.shake -= 1
		end
		]]
		if enemy.wait > 0 then
			enemy.wait -=1
			if enemy.tpe == 16 then
				sfx(2)
			end
		else

			fulfill_mission(enemy)

			-- DEAD
			if enemy.life <= 0 then
				-- split ghosts
				if enemy.tpe == 3 then
					add_enemy(enemy.x, enemy.y - 8, 4, 30)
					add_enemy(enemy.x, enemy.y + 8, 4, 30)
					add_enemy(enemy.x+8, enemy.y, 4, 30)
				end


				if enemy.isWitch then
					if (not (enemy.tpe == 15)) then
						enemy.falling = true
						enemy.mission = "falling"
						enemy.sx = -1
						enemy.sy = 0.5
					elseif (moonSpawn == 0) and (not enemy.falling) and (enemy.tpe == 15) then
						moonSpawn = 180
						enemy.falling = true
						enemy.mission = "flyin"
						canSpawnMoon = true
					elseif moonSpawn == 0 then
						add_enemy(80, enemy.y, 16, 0)
						music(39)
						del(enemies, enemy)
						moonGlitch = 60
					else
						if (t%10 == 0) then
							explode_part(enemy.x, enemy.y, "circle", 7, 10-(moonSpawn/20))
							--enemy.shake = true
							offset = 0.45-(moonSpawn/400)
							sfx(2)
						end
					end
				end

				if not enemy.isWitch then
					del(enemies, enemy)
				end
				
				if not enemy.falling then
					death_trigger(enemy)
				end

				if (enemy.tpe == 16) then
					won = true
					wonTime = 400
					del(enemies, enemy)
					enemy_bullets={}
					moonX, moonY = enemy.x+16, enemy.y+16
					ax, ay = 0,0
				end
			end

			enemy.flash = count_down(enemy.flash)

			--[[ FLASH
			if enemy.flash > 0 then
				enemy.flash-=1
			end
			]]

			if not (enemy.mission == "flyin") then
				if (#player_bullets >= 1) then
					local colObj = {
						x = enemy.x,
						y = enemy.y,
						collisionHeigth = enemy.collisionHeigth,
						collisionWidth = enemy.collisionWidth

					}
					for bul in all(player_bullets) do
						local size = enemy.size * 8
						if abs(bul.x - enemy.x) < size and abs(bul.y - enemy.y) < size then
							if (collide(colObj, bul)) then
								
								if not ((enemy.mission == "spawning") and (not (#enemies == 1))) then
									explode_part(bul.x, bul.y, "dot", 12)
									enemy.life -= bul.dmg
									enemy.flash = 6
								end
								del(player_bullets, bul)
							end
						end
					end
				end
			end
		end


		if enemy.isWitch then
			enemy.spawnTime = count_down(enemy.spawnTime)
			--[[
			if enemy.spawnTime > 0 then
				enemy.spawnTime -= 1
				if enemy.spawnTime < 0 then
					enemy.spawnTime = 0
				end
			end
			]]
		end

		if (enemy.x < 0) or (enemy.y > 128) then
			del(enemies, enemy)
		end
		enemy.shoot = count_down(enemy.shoot)
		--[[
		if enemy.shoot > 0 then
			enemy.shoot -= 1
		end
		]]
        local playerColl = {
            x = player.x+2,
            y = player.y+5,
            collisionHeigth = 3,
            collisionWidth = 3
        }
		if collide(enemy, playerColl) and (player.invTime <= 0) then
			if (starTime > 0) and (not(enemy.isWitch)) then
				death_trigger(enemy)
			else
				player_hit()
			end
		end
	end
end

function death_trigger(_enemy)
	if rnd() < (0.1+(4-player.life)*0.03) then
		spawn_pickup(_enemy.x, _enemy.y)
	end
	explode_part(_enemy.x, _enemy.y, "circle", 12)
	sfx(2)
	add_score(_enemy.x+4, _enemy.y+4, _enemy.tpe * 100)
	del(enemies, _enemy)
	if (not hyper) gauge += 4
	nextAttack -= 0.2
end

function get_phase_direction(phase)
	local phaseDirections = { {"up-down", "up" }, {"stationary", "nil"}, {"forward-back", "forward"}, {"circle", "up"}, {"spawning", "up"} }
	for valuePair in all(phaseDirections) do
		--printh("searching direction for phase:"..phase.." checking against: "..valuePair[1])
		if (valuePair[1] == phase) then
			--printh("found direction: "..valuePair[2])
			return valuePair[2]
		end
	end
	return nil
end

function check_for_next_phase(enemy)
	if (time() > (enemy.phaseBegin + 16)) then
		enemy.indicator += 1
		if enemy.indicator > enemy.phaseNumber then
			enemy.indicator = 1
		end
		enemy.mission = enemy.phases[enemy.indicator]
		--printh(enemy.phases[enemy.indicator].." with ap of: "..tostr(enemy.attackPatterns[enemy.indicator]))
		enemy.attackPattern = enemy.attackPatterns[enemy.indicator]
		enemy.dir = get_phase_direction(enemy.mission)
		enemy.phaseBegin = time()
		enemy.sx = 0
		enemy.sy = 0
		return true
	end
	return false
end

function fulfill_mission(enemy)

	if (enemy.tpe == 4) then
		enemy.mission = "attack"
	end

	local enemyMission = enemy.mission
	local enemyTpe = enemy.tpe
	local sx, sy, dir = enemy.sx, enemy.sy,enemy.dir



	if enemyMission == "flyin" then
		if enemy.tpe == 16 then
			enemy.x = enemy.posx
			enemy.y = enemy.posy
			enemy.wait = 60
		end

		-- easing -> x+=(target.x-x)/n
		enemy.x-=(enemy.x - enemy.posx)/12
		enemy.y-=(enemy.y - enemy.posy)/12
		if abs(enemy.x-enemy.posx) < 0.5 then
			enemy.x = enemy.posx
			enemy.mission = "protect"
			if (enemyTpe == 5) or (enemyTpe == 10) or (enemyTpe == 14) then 
				enemy.mission = "attack" 
				dir = "up"
			end
			if enemy.isWitch then
				--enemy.phases, 	enemy.phaseTimes, 	enemy.attackPatterns,
				enemy.indicator = 1
				enemy.mission = enemy.phases[enemy.indicator]
				enemy.attackPattern = enemy.attackPatterns[enemy.indicator]
				dir = get_phase_direction(enemy.mission)
				enemy.phaseBegin = time()
			end

			if (enemy.tpe == 15) and (enemy.falling) then
				enemy.mission = "idle"
			end
		end
	elseif enemyMission == "protect" then
		sx, sy = 0, 0
	elseif enemyMission == "idle" then
		sx, sy = 0, 0
	elseif enemyMission == "attack" then
		
		if enemyTpe == 1 then
			--bat
			sx = -0.85
			sy = sin(t/40)


			-- trend toward center from top
			if enemy.y < 40 then
				sy += 0.5 
			end
			-- trend toward center from bot
			if enemy.y > 88 then
				sy -= 0.5
			end

		elseif enemyTpe == 2 then
			--crow
			sx = -1.3

			if (not enemy.changed) then
				sy = sin(t/20)
				if enemy.y < 20 then
					sy +=  0.25
				end
			end

			if ((enemy.x < player.x + 20) and (not enemy.changed)) then
				if enemy.y < 64 then
					sy = 1.35
				else
					sy = -1.35
				end
				enemy.changed = true	
			end

		elseif enemyTpe == 3 then
			--ghost
			sx = -0.2
			sy = sin(t/60)	

			-- trend toward center from top
			if enemy.y < 32 then
				sy += 0.5 -(enemy.y/32)
			end
			-- trend toward center from bot
			if enemy.y > 88 then
				sy -= ((enemy.y - 88)/32)/2
			end
			if (t%60 == 0) then
				attack_with_pattern(enemy, "diagonal")
			end
		elseif enemyTpe == 4 then
			sx = -0.85
			sy = sin(t/40)


			-- trend toward center from top
			if enemy.y < 40 then
				sy += 0.5 
			end
			-- trend toward center from bot
			if enemy.y > 88 then
				sy -= 0.5
			end
		elseif enemyTpe == 5 then
			-- owl
			if (t%50 == 0) then
				attack_with_pattern(enemy, "double", 0.5)			
			end
		elseif enemyTpe == 7 then
			-- eye bat
			if (time()%1 == 0) then
				attack_with_pattern(enemy, "double", 0.5)			
			end
			sx = -1
		elseif enemyTpe == 8 then
			-- eye
			if (time()%2 == 0) then
				attack_with_pattern(enemy, "aimed", 0, 0.8)			
			end
			sx = -0.25
		elseif enemyTpe == 10 then
			-- eye guard
			if dir == "up" then
				sy = -0.25
				if enemy.y <= 20 then
					dir = "down"
				end
			end

			if dir == "down" then
				sy = 0.25
				if enemy.y >= 100 then
					dir = "up"
				end
			end
			if t%30 == 0 then
				attack_with_pattern(enemy, "aimed", 0, 0.8)			
			end
			if t%40 < 1 then
				attack_with_pattern(enemy, "aimed", 0, 0.8)			
			end
		elseif enemyTpe == 11 then
			if t%60 == 0 then
				attack_with_pattern(enemy, "double", 0.7)			
			end
			sx = -0.5
		elseif enemyTpe == 13 then
			if time()%2 == 0 then
				attack_with_pattern(enemy, "circle", nil, 1)			
			end
			sx = -0.25
		elseif enemyTpe == 14 then
			if t%60 == 0 then
				-- attack_with_pattern(enemy, attack_pattern, angle, speed, exploding)
				attack_with_pattern(enemy, "aimed", nil, 1.5, 1)			
			end
		end

	elseif enemyMission == "up-down" then
		sx = 0
		if dir == "up" then
			sy = -0.25
			if enemy.y <= 20 then
				dir = "down"
			end
		end

		if dir == "down" then
			sy = 0.25
			if enemy.y >= (108-enemy.collisionHeigth) then
				dir = "up"
			end
		end
		if ((t%60 > 12) and (t%10 == 0)) then
			attack_with_pattern(enemy, enemy.attackPattern)		
		end

		if check_for_next_phase(enemy) then
			dir = enemy.dir
		end
	elseif enemyMission == "stationary" then
		local check = t%50
		sx, sy = 0,0
		if enemyTpe == 6 then check = t%60 end
		if (t%30 == 0) then
			attack_with_pattern(enemy, enemy.attackPattern, t/30)		
		end

		if (check==0) then
			attack_with_pattern(enemy, enemy.attackPattern)
		end
		
		if check_for_next_phase(enemy) then
			dir = enemy.dir
		end
	elseif enemyMission == "forward-back" then
		sy = 0
		if dir == "forward" then
			sx = -0.25
			if enemy.x <= 2 then
				dir = "backward"
			end
		end

		if dir == "backward" then
			sx = 0.25
			if enemy.x >= (118-enemy.collisionWidth) then
				dir = "forward"
				if check_for_next_phase(enemy) then
					dir = enemy.dir
				end
			end
		end
		if (enemy.tpe == 16) then
			if (t%3 == 1) then
				attack_with_pattern(enemy, enemy.attackPattern, 0, 1, 0)	
			end
		else
			if (t%60 > 40) and (t%6 == 0) then
				attack_with_pattern(enemy, enemy.attackPattern)	
			end
		end
	elseif enemyMission == "circle" then
		if dir == "up" then
			sy = -0.5
			sx = 0
			
			if (enemy.y <= 65) then
				check_for_next_phase(enemy)
				dir = enemy.dir
			end
			if enemy.y <= 20 then
				dir = "forward"
			end
		end
		if dir == "forward" then
			sy = 0
			sx = -0.5
			if enemy.x <= 2 then
				dir = "downward"
			end
		end
		if dir == "downward" then
			sx = 0
			sy = 0.5
			if enemy.y >= (108-enemy.collisionHeigth) then
				dir = "backwards"
			end
		end
		if dir == "backwards" then
			sy = 0
			sx = 0.5
			if enemy.x >= (118-enemy.collisionWidth) then
				dir = "up"
			end
		end
		if (t%30 == 0) then
			
			if (enemy.tpe == 16) then
				attack_with_pattern(enemy, enemy.attackPattern, 0, 1.5, 1)
			else
				attack_with_pattern(enemy, enemy.attackPattern, 0, 1.5)
			end
		end
	elseif enemyMission == "falling" then
		sx = sx * 0.4
		sy = sy * 0.55
		if time()%1 == 0	 then
			enemy.flash = 20
		end
		if t%30 == 0 then
			for i=1,4 do
				explode_part(enemy.x+sin(rnd(2)), enemy.y+sin(rnd(2))+10, "circle", 14)
			end
			offset = 0.1
		end
	elseif enemyMission == "spawning" then
		sx = 0
		sy = 0
		local spawnNumber = enemy.attackPattern[3]
		local offset = 1
		if (enemy.attackPattern[2] == 5) or (enemy.attackPattern[2] == 14) then
			offset = 2
		end
		if (#enemies == 1) and (enemy.spawnTime <= 0) then
			enemy.spawnTime = 600
			--function add_enemy(_x, _y, _tpe, _wait)
			local firstPosToSpawn = flr((10-enemy.attackPattern[1])/2)+1
			for i=1,enemy.attackPattern[1] do
				add_enemy(80, 10+firstPosToSpawn*8+i*8*offset, enemy.attackPattern[2], 20)
			end
		end

		if dir == "up" then
			sy = -0.25
			if enemy.y <= 20 then
				dir = "down"
			end
		end

		if dir == "down" then
			sy = 0.25
			if enemy.y >= 100 then
				dir = "up"
			end
		end

		if (#enemies == 1) then
			if t%40 == 0 then
				attack_with_pattern(enemy, "circle")
			end
		end
		check_for_next_phase(enemy)
	end

	enemy.dir = dir
	enemy.sx = sx
	enemy.sy = sy
	move(enemy)
end

function attack_with_pattern(enemy, attack_pattern, angle, speed, exploding)
	if (speed == nil) and (attack_pattern == "aimed") then speed = 1.5 end
	if angle == nil then angle = 0 end
	if speed == nil then speed = 0.5 else speed = speed end
	if exploding == nil then exploding = 0 end
	if enemy.tpe == 9 then
		angle = 0.3
	end

	local upCorrect = 0
	if enemy.sy < 0 then
		upCorrect = enemy.sy
	end
	local downCorrect = 0
	if enemy.sy > 0 then
		downCorrect = enemy.sy
	end

	local enemyXpos = enemy.x
	local enemyYpos = enemy.y
	local enemySpeed = enemy.sx
	if enemy.tpe == 16 then
		enemyXpos+=12
		enemyYpos+=16
	end

	-- function add_enemy_bullet(_x, _y, _sx, _sy, _tpe, _speed)
	if attack_pattern == "single" then
		add_enemy_bullet(enemyXpos-4, enemyYpos+4, -1+enemySpeed, 0, exploding, speed)
	elseif attack_pattern == "double" then
		add_enemy_bullet(enemyXpos, enemyYpos+4, -1+enemySpeed, angle, exploding, speed)
		add_enemy_bullet(enemyXpos, enemyYpos+4, -1+enemySpeed, -angle, exploding, speed)
	elseif attack_pattern == "trio" then
		add_enemy_bullet(enemyXpos, enemyYpos+4, -1+enemySpeed, angle-upCorrect, exploding, speed)
		add_enemy_bullet(enemyXpos-4, enemyYpos+4, -1+enemySpeed, 0, exploding, speed)
		add_enemy_bullet(enemyXpos, enemyYpos+4, -1+enemySpeed, -angle-downCorrect, exploding, speed)
	elseif	attack_pattern == "cross" then
		add_enemy_bullet(enemyXpos, enemyYpos+4, 0, -1.5, exploding, speed)
		add_enemy_bullet(enemyXpos, enemyYpos+4, 0, 1.5, exploding, speed)
		add_enemy_bullet(enemyXpos, enemyYpos+4, 1.5, 0, exploding, speed)
		add_enemy_bullet(enemyXpos, enemyYpos+4, -1.5, 0, exploding, speed)
	elseif attack_pattern == "diagonal" then
        add_enemy_bullet(enemyXpos, enemyYpos+4, -1.5, -1.5, exploding, speed)
        add_enemy_bullet(enemyXpos, enemyYpos+4, 1.5, -1.5, exploding, speed)
        add_enemy_bullet(enemyXpos, enemyYpos+4, 1.5, 1.5, exploding, speed)
        add_enemy_bullet(enemyXpos, enemyYpos+4, -1.5, 1.5, exploding, speed)
	elseif attack_pattern == "aimed" then

		local ang = atan2(player.y - enemyYpos, player.x - enemyXpos)	
		add_enemy_bullet(enemyXpos, enemyYpos+4, sin(ang), cos(ang), exploding, speed)

	elseif attack_pattern == "circle" then
		for i=-1,1, 0.1 do
			add_enemy_bullet(enemyXpos, enemyYpos+4, sin(i), cos(i), 0, speed)
		end
	elseif attack_pattern == "exploding" then
		add_enemy_bullet(enemyXpos, enemyYpos+4, -1, 0, 1, 2)
	elseif attack_pattern == "spiral" then
		local a = sin((60-t)/50)*2
		local b = cos((60-t)/50)*2
		add_enemy_bullet(enemyXpos, enemyYpos,  a, b, exploding, speed/2)
		add_enemy_bullet(enemyXpos, enemyYpos,  -a, -b, exploding, speed/2)
	end
	if (attack_pattern == "spiral") then
		if (t%15==0) then
			sfx(4)
		end
	else
		sfx(4)
	end
	enemy.shoot = 10
end

function move(obj)
	obj.x+=obj.sx
	obj.y+=obj.sy
end

function out_of_bounds(_x, _y)
	if (_x > 128) or (_x < 0) or (_y > 128) or (_y < 0) then return true else return false end
end

function update_bullets()
	for bul in all(player_bullets) do
		bul.x += bul.sx
		bul.y += bul.sy
		if out_of_bounds(bul.x, bul.y) then
			del(player_bullets, bul)
		end
	end

	for enemy_bul in all(enemy_bullets) do
		enemy_bul.x += enemy_bul.sx
		enemy_bul.y += enemy_bul.sy
		if out_of_bounds(enemy_bul.x, enemy_bul.y) then
			del(enemy_bullets, enemy_bul)
		end

		local of = 0
		local w = 3
		if forceShield > 0 then
			of = 10
			w = of*2+1
		end
        -- player.x+2, player.y+6
        local playerColl = {
          	x = player.x+2-of,
            y = player.y+5-of,
            collisionHeigth = w,
            collisionWidth = w
        }
		if (player.invTime <= 0) and (starTime <= 0) and (collide(enemy_bul, playerColl)) then
			if forceShield > 0 then
				--function add_player_bullet(_x, _y, _tpe, _sx, _sy)
				add_player_bullet(enemy_bul.x, enemy_bul.y, 2, -enemy_bul.sx*2, -enemy_bul.sy*2)
			else
				player_hit()
			end
			del(enemy_bullets, enemy_bul)
		end

		if enemy_bul.tpe == 1 then
			enemy_bul.sx = enemy_bul.sx * 0.96
			enemy_bul.sy = enemy_bul.sy * 0.96
			local diffX = 0-abs(enemy_bul.sx)
			local diffY = 0-abs(enemy_bul.sy)
			if (diffX > -0.1) and (diffY > -0.1) then
				for i=-1,1,.18 do
					add_enemy_bullet(enemy_bul.x, enemy_bul.y+4, sin(i), cos(i), 0, 1)
				end
				del(enemy_bullets, enemy_bul)
			end
		end
	end
end

function update_particles()
	-- pink and blue part colors shades, 14, 12, 7, 9, 14
	local partColors = {{8,2}, {1, 11}, {6,5}} 
	local index = 1
	for part in all(particles) do
		if (part.sclr == 7) index = 2
		if (part.sclr == 9) index = 3
		if (part.sclr == 12) index = 2

		part.x += part.sx
		part.y += part.sy
		part.age+=1

		if part.age >= part.maxAge then
			if not (part.tpe == "circle") then
				del(particles, part)
			else
				part.size=part.size*0.9
				if part.size <= 1 then
					del(particles, part)
				end
			end
		end


		if (part.tpe == "dot") or (part.tpe == "circle") then
			if part.age > 10 then
				part.clr = partColors[index][1]
			end
			if part.age > 20 then
				part.clr = partColors[index][2]
			end
		end

		part.sx = part.sx * 0.9
		part.sy = part.sy * 0.9
	end
	for sw in all(shockwaves) do
		sw.size += sw.spd
		if sw.size > sw.targetSize then
			del(shockwaves, sw)
		end
	end
end

function _draw()
	if mode == 0 then
		draw_menu()
	elseif mode == 1 then
		draw_game()
	elseif mode == 2 then
		draw_splash_screen()
	elseif mode == 3 then
		draw_game_over()
	elseif mode == 5 then
		draw_tutorial()
	end
end


function cprint(_txt, _y, _clr)
	print(_txt,64-#_txt*2, _y, _clr)
end

function draw_menu()
	cls()

	draw_bg()


	-- LINA
	draw_lina(8, 28+sin(time())*2)

	local propSprOffset = 0
	if (t%20 > 5) then
		cprint("press c to start", 26, 6)
		propSprOffset = 1
	end
	
	spr(64+propRnd*2+propSprOffset, propX, propY)
	spr(213, 16, 0, 11, 3)

	cprint("highscore", 78, 1)
	local scoreString = tostr(highScore)
	if #scoreString < 4 then
		scoreString = pad(scoreString, 4)
	end

	cprint(highScoreThousands..scoreString, 84, 6)

	if time()%8 >= 2 then
		cprint("code/art by: bELA tOTH-aCHIE", 98, 1)
	else
		cprint("music/sfx by:", 98, 1)
		cprint("bEFOREyOUcLOSEyOURmIND", 106, 1)
	end


end

function draw_lina(_x, _y)
	spr(132, _x, _y, 11, 5)
	spr(208, _x, _y+39, 5, 1)
	spr(143,_x+40, _y+39)
end

function draw_splash_screen()
	cls()
	draw_bg()
	draw_player()
	local moonStages = {"sOMETHING IS ODD TONIGHT...", "tHE mOON IS ... SHAKING?", "iT'S GETTING WORSE?!", "tHE MOON TURNED INTO ... hER?!", ""}
	if (time()%1 > 0.4) then
		if (wave%5 == 0) and (wave > 0) then
			if (t%8 < 4) then
				rect(-10, 46, 130, 54, 8)
				cprint("! ! !", 38, 8)
				cprint("------ a witch is approaching ------", 48, 8)
			end
		elseif (wave == 16) then
			cprint("the moon ... witch?", 48, 8)
		else
			cprint("forest: "..stage, 48, 12)
			cprint("clearing: "..wave, 56, 12)
		end
	end

	if (((wave%5) == 1)) then
		local idx = stage+1
		if (wave == 1) idx=1
		cprint(moonStages[idx], 80, rnd(15))
	end
end

function draw_game_over()
	cls()
	draw_bg()
	if (not won) then
		cprint("game over", 24, 8)

		cprint("reached clearing: "..wave, 48, 12)
	else
		cprint("you survived the journey", 40, 14)
		spr(32, 55, 57)
		spr(48, 60, 57)
		spr(1, 60, 50, 1, 2)
		if (t%6 == 0) then
			for i=0,1 do
				local broomline = {
					x = 55,
					y = 59+i*2,
					clr = flr(rnd(16)),
					spd = 4,
					spr = nil
				}
				add(bg_elements, broomline)
			end
		end
	end

	if (time()%2 < 1) then
		cprint("press x to menu", 68, 6)
	end
	if (scoreThousands > highScoreThousands) or ((score > highScore) and (not (scoreThousands < highScoreThousands))) then
		dset(0, score)
		dset(1, scoreThousands)
		cprint("new high score!", 80, 12)
		local scoreString = tostr(score)
		if #scoreString < 4 then
			scoreString = pad(scoreString, 4)
		end

		cprint(scoreThousands..scoreString, 88,  rnd(15))
	end
	draw_particles()
end

--[[
0 -> Potion
1 -> Shield
2 -> simple atk
3 -> 2x atk
4 -> 3x atk
5 -> cat bomb
6 -> star
]]--

function draw_tutorial()
	cls()
	--draw_clouds()
	pal(11, 129, 1)
	draw_bg()
	
	local txt = "tUTORIAL"

	if tutorialChapter == 0 then
		print("fLY FORWARD TO START -->", 2, 110, 12)
		print("<- mANA bURST gAUGE", 2, 90, 12)
	end

	if tutorialChapter == 1 then
		txt="hEALTH"
		print(txt, 64-#txt*2, 11, 14)
		print("hP & hITBOX", 2, 32, 14)
		local protect = "<- hITBOX HERE"
		if (t%30 > 7) then
			spr(43, 0, 50)
			print("<- hEALTH", 14, 40, 12)
			print("<- hITBOX", 14, 50, 12)
			print("<-", player.x+8, player.y+5, 12)
		end
		print("tEST HERE ON ENEMY BULLETS", 2, 110, 14)
		print("eFFECTS", 2, 32, 14)


		local shield = "<- bOUNCES BULLETS BACK"
		local star = "<- sUPER sTAR"
		local eff = "iNVINCIBILITY + rAMMING"

		print(shield, 14, 68, 12)
		print(star, 14, 80, 12)
		print(eff, 20, 88, 5)
		print("dOESN'T kILL wITCHES", 20, 96, 5)
	end
	
	if tutorialChapter == 2 then
		txt="sHOOTING"
		print(txt, 64-#txt*2, 11, 14)
		print("pICKCUPS", 2, 32, 14)
		if (t%30 > 7) then
			print("<- pRESS X", 14, 88, 12)
			print("<- PRESS C", 14, 62, 12)
			print("dESTROYS eNEMY bULLETS", 20, 96, 5)
		end
	end
	
	if tutorialChapter == 3 then
		
	end

	if tutorialChapter == 0 then
		print(txt, 64-#txt*2, 11, 14)
		cprint("fLY INTO ARROWS TO SWITCH", 19, 14)
	end
	spr(6, tutorialBackWard.x, tutorialBackWard.y)
	spr(7, tutorialForward.x, tutorialForward.y)


	draw_player()


	draw_ui()
	draw_particles()
	draw_enemies()
	draw_bullets()
	
	
	

	for p in all(pickups) do
		spr(49+p.tpe, p.x, p.y)
	end


end

function draw_game()

	cls()
	--draw_clouds()
	pal(11, 129, 1)
	draw_bg()
	
	draw_player()



	draw_particles()
	draw_enemies()
	draw_bullets()
	--line(0,64,128,64)

	for p in all(pickups) do
		spr(49+p.tpe, p.x, p.y)
	end

	if (player.flashTime > 70) or (moonGlitch > 0) then
		for i=1,100 do
			o1 = flr(rnd(0x1F00)) + 0x6040
			o2 = o1 + flr(rnd(0x4)-0x2)
			len = flr(rnd(0x40))

			memcpy(o1,o2,len)
		end
	end

	if (moonSpawn > 120) then
		cprint("you cannot stop me!", 48, 8)
	elseif (moonSpawn > 30) then
		cprint("this is your end!", 48, 8)
	elseif (moonSpawn > 0) then
		cprint("witch!", 48, 8)
	end

	if (freeze > 0) and (not won) then
		local defeated = "overwhelmed"
		if (wave == 16) then
			defeated = "ended by the wicked moon"
		end
		palt(0, false)
		rectfill(64-#defeated*2+2, 40, 64+#defeated*2+2, 50, 0)
		if (t%4 == 0) then
			cprint(defeated, 42, 8)
		else
			cprint(defeated, 42, 2)
		end
		palt(0, true)
	end

	for s in all(scores) do
		print(s.value, s.x, s.y, rnd(15))
	end

	if offset > 0 then
		screen_shake()
	end
	draw_ui()
end

function screen_shake()
	local fade = 0.95
	local offset_x = 16-rnd(32)
	local offset_y = 16-rnd(32)


	offset_x*=offset
	offset_y*=offset

	camera(offset_x, offset_y)

	offset*=fade
	if offset < 0.05 then
		offset = 0
	end
end

function draw_player()
	local px, py = player.x, player.y
	-- draw broom
	spr(32, px-7, py+7, 2, 1)

	if (player.flashTime > 0) and (sin(time()*10) < 0.5) then
		for i=1,15 do
			pal(i,7)
		end
	end

	if (starTime > 0) and (sin(time()*10) < 0.5) then
		for i=1,15 do
			pal(i,flr(rnd(15)+1))
		end
	end

	-- draw witch
	if not (player.moving) then
		spr(1, px, py, 1, 2)
	else
		spr(2, px, py, 1, 2)
	end

	pal()

    if (t%30 > 7) spr(43, px, py+2)

	if (t%6 == 0) then
		for i=0,1 do
			local broomline = {
				x = px-6,
				y = py+9+i*2,
				clr = flr(rnd(16)),
				spd = 4,
				spr = nil
			}
			add(bg_elements, broomline)
		end
	end
	pal(11, 129, 1)
    spr(47, catX, catY)

	if catTimer > 150 then
		spr(42, px+8, py+2)
	end

	

		--rect(forceX, forceY, forceX+forceW, forceY+forceH, 12)
end


function draw_ui()
	for i=1,player.maxLife do
		if (player.life == 1) and (t%5>0) then
			pal(2,1)
		end
		spr(46, 2+i*8, 2)
		pal()
	end
	for i=1,player.life do
		if (player.life == 1) and (t%5>0) then
			pal(7,5)
			pal(8,2)
		end
		spr(45, 2+i*8, 2)
		pal()
	end

	if (catZeroIndicator > 0) and (t%3 == 0) then
		pal(7, 5)
		pal(1, 0)
		pal(9, 5)
	end
	spr(54, 108, 2)
	print(player.cats, 118, 4, 7)
	pal()

	local scoreString = tostr(score)
	if #scoreString < 4 then
		scoreString = pad(tostr(score), 4)
	end

	cprint(scoreThousands..scoreString, 3, 7)

	pal(11, 129, 1)

	if (starTime < 100) and (starTime > 0) and (not hyper) then
		cprint("star ends in: "..starTime, 64, rnd(15))
	end

	if (forceShield > 0) then
		circ(player.x+3, player.y+5, 12+sin(rnd(2)-1), rnd(15))
		if (forceShield < 100) and (not hyper) then
			cprint("shield ends in: "..forceShield, 64, rnd(15))
		end
	end
	
	if (hyper)	cprint("mana burst", 64, rnd(15))
	

	rectfill(0, 128-gauge, 0, 128, rnd(15))
end

function pad(stringToPad, len)
	if (#stringToPad == len) then
		return stringToPad
	end

	return "0"..pad(stringToPad, len-1)
end

function draw_bg()
	for element in all(bg_elements) do
		if (element.spr == nil) then
			pset(element.x, element.y, element.clr)
		else
			pal(11, 129, 1)
			spr(element.spr, element.x, element.y)
		end

		if (element.y == 116) and (element.spr == 59) then
			rectfill(element.x+4, element.y+8, element.x+5, 128, 2)
		end
	end

	if (not (wave > 15)) and (not (won)) then
		local stageMoonOffset = stage-1
		spr(24+(stageMoonOffset*2), 108, 12+sin(time())*stageMoonOffset, 2, 1)
		spr(24+(stageMoonOffset*2), 108, 20+sin(time())*stageMoonOffset, 2, 1, false, true)
	end
	if (won) then
		spr(24, 108, 12, 2, 1)
		spr(24, 108, 20, 2, 1, false, true)
	end
	pal(11, 129, 1)
end


function draw_bullets()
	if player.shooting then
		spr(9,player.x+4, player.y+4)
	end	
	for bul in all(player_bullets) do
		spr(10, bul.x, bul.y)
	end
	for enemy_bul in all(enemy_bullets) do
		animate(enemy_bul, enemy_bul.spr, enemy_bul.animFrames, 12, false, false)
		--xrect(enemy_bul.x, enemy_bul.y, enemy_bul.x+enemy_bul.collisionWidth, enemy_bul.y + enemy_bul.collisionHeigth, 12)
	end
end

--function animate(object,starterframe,framecount,animspeed,flipped,isplayer)
function draw_enemies()
	for enemy in all(enemies) do
		local sh = enemy.shake > 0
		if enemy.tpe == 16 then
			-- head
			spr(128, enemy.x, enemy.y, 4, 3, false, false)
			-- mouth
			spr(224, enemy.x+sin(rnd(3)), enemy.y+18+sin(rnd(3)), 4, 2, false, false)
			-- eyes
			local eyeposX = enemy.x + 6
			local eyePosY = enemy.y + 11

			local offsetY = 0
			if player.y < enemy.y then
				offsetY = -2
			end

			local offsetX = 0
			if player.x > enemy.x then offsetX = 2 end
			circfill(eyeposX+offsetX, eyePosY+offsetY, 1, 9)
			circfill(eyeposX+14+offsetX, eyePosY+offsetY, 1, 9)

		elseif enemy.isWitch then
			if enemy.tpe == 6 then
				pal(2, 8)
				pal(14, 13)
				pal(1, 3)
			elseif enemy.tpe == 9 then
				pal(14, 1)
				pal(2, 9)
				pal(1, 2)
			elseif enemy.tpe == 12 then
				pal(1, 5)
				pal(14, 2)
				pal(2, 8)
			elseif enemy.tpe == 15 then
				pal(1, 7)
				pal(2, 14)
				pal(14, 9)

			end
			spr(34, enemy.x-2, enemy.y+7, 2, 1)

			local obj = {
				x = enemy.x,
				y = enemy.y + 8
			}

			if enemy.flash > 0 then
				for i=1,15 do
					pal(i,7)
				end
			end
			animate(obj, 17, 2,enemy.animSpeed,true,false, sh)
			animate(enemy, 1, 2,enemy.animSpeed,true,false, sh)
			if (enemy.mission == "spawning") and (enemy.spawnTime == 0) or (enemy.spawnTime > 240) then
				if t%3 == 0 then
					print("!", enemy.x+4, enemy.y-8, 8)
				end
			end

			if (enemy.mission == "spawning") and (not (#enemies == 1)) then
				circ(enemy.x+4, enemy.y+4, 12+sin(time()), 7)
				circ(enemy.x+4, enemy.y+4, 15+sin(time()), 2)
			end

		else
			if enemy.flash > 0 then
				for i=1,15 do
					pal(i,7)
				end
			end
			animate(enemy,enemy.spr,enemy.animFrames,enemy.animSpeed,false,false, enemy.size > 1, sh)
		end
		if enemy.shoot > 0 then
			if enemy.size == 1 then
				spr(8, enemy.x-8, enemy.y)
			else
				spr(8, enemy.x-8, enemy.y+8)
			end
		end
	
		pal()
		pal(11, 129, 1)
	end
end

function explode_part(_x, _y, _tpe, _clr, _size)
	if (_size == nil) then _size = 1 end
	local part = {
		x = _x,
		y = _y,
		sx = 0*_size, 
		sy = 0*_size,
		age = 0+rnd(10),
		size = 3+rnd(3)*_size,
		maxAge = 5 + rnd(10),
		tpe = _tpe,
		clr = 7,
		sclr = 7
	}
	add(particles, part)
	for i=1,15 do
		local part = {
			x = _x,
			y = _y,
			sx = rnd(_size)*4-2*_size, 
			sy = rnd(_size)*4-2*_size,
			age = 0+rnd(10),
			size= 1+rnd(2)*_size,
			maxAge = 30 + rnd(10),
			tpe = _tpe,
			clr = _clr,
			sclr = _clr
		}
		add(particles, part)
	end
end

function draw_particles()
	for part in all(particles) do
		if part.tpe == "circle" then
			circfill(part.x, part.y, part.size, part.clr)
		elseif part.tpe == "dot" then
			pset(part.x, part.y, part.clr)
		end
	end
	for sw in all(shockwaves) do
		circ(sw.x+rnd()*5, sw.y+rnd()*5, sw.size, sw.clr)
	end
end


__gfx__
000000000110000000000000000000000000000000000000077777700777777000000000000070000cd00000099000000ee00000033000000ff000000ee00000
0000000000110000000000000000000000000000000000007111c117711c11170000700000077700c66d000097790000e77e000037730000f77f0000ee7c0000
007007000012210001110000000000000000000000000000711cc117711cc1170007770000777770d66d000097790000e77e000037730000f77f0000e7cc0000
00077000002111111012210000000000000000000000000071ccc117711ccc1700777770077777770dd00000099000000ee00000033000000ff000000cc00000
000770000111ffe0002111110000000000000000000000007cccccc77cccccc70007770000777770000000000000000000000000000000000000000000000000
0070070011efff000111ffe000000000000000000000000071111117711111170000700000077700000000000000000000000000000000000000000000000000
00000000eee1110011efff0000000000000000000000000007777770077777700000000000007000000000000000000000000000000000000000000000000000
00000000eee111f0eee1110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000e11f1000e11f1f00000000000000000000000000dd000000dd000000000066666600000000006666660000000000666666000000000099999900000
001100000111100001111000000000000000000000000000d6cd0000d77d0000000667777776600000066777777660000006677777766000000994bbbb499000
001221000112200011122000000000000000000000000000dccd0000d77d00000067777777777600006777777777760000677777777776000094bbbbbbbb4900
0021111110000000000000000000000000000000000000000dd000000dd00000067776000777776006777777777777600677777777777760094bbbbbbbbbb490
0111ffe00000000000000000000000000000000000000000000000000000000007760000007777700776000777777770067777777777776009bbbbbbbbbbbb90
11efff000000000000000000000000000000000000000000000000000000000007000000000777760700000077777776677777777777777694bbbbbbbbbbbb49
0ee00000000000000000000000000000000000000000000000000000000000000000000000007777000000000777777767777777777777769bbbbbbbbbbbbbb9
00000000000000000000000000000000000000000000000000000000000000000000000000007777000000000777777767777777777777769bbbbbbbbbbbbbb9
0000000000000000000000000000000000000000000000000000000000000000c0000000c00c0000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000c00000001c0000001c01c000033003300000000000dd0dd0007707700022022000000000
909090000000449449440000000909090000000000000000000000000c00000001c0000001c01c0006633660000000000dccdccd078878870200200201010010
099449444444000000004444449449900000000000000000000000000c00000001c0000001c01c0006033600000770000dcdddcd078888870202000210011110
909090000000000000000000000909090000000000000000000000000c00000001c0000001c01c00033333300077e70000dcdcd0007888700020002011119191
000000000000000000000000000000000000000000000000000000000c00000001c0000001c01c00033f8830007ee700000dcd0000078700000202001b111110
00000000000000000000000000000000000000000000000000000000c00000001c0000001c01c00003ff88f0000770000000d000000070000000200010100001
0000000000000000000000000000000000000000000000000000000000000000c0000000c00c0000333003330000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000007700770000000000000000000000000000000000000000000000000000d00000000000000000000
000000000000000000000000000000000000000000000000733773370007000000000000000000000000000000bbb1100000000000010000001dd00000111dd0
00004494000000000000000000000000000000000000000076633667077977000077700000000000000000000bbbbbb1000000000011d00000111d000111111d
444400000000074000777700007777000077770000777700760336077999997007ee970000777700000000000bbbbbb1000000000011100001111d000111111d
000000000007747007111170071cc1700711c17007111c70733333370799970007e7c7000711cc70000000000bbbbbbb0000000001111d0001111d0001111111
0000000000708700071cc17007111170071c1170071cc170733f8f3707979700079cc70007c11c70000000000bbbbbbb0000000001111100011111d001111111
000000000078870007111170071cc1700711c17007c1117073ffff3700707000007770000711cc700000000000bbbbb000000000111111d00111111000111110
00000000000770000077770000777700007777000077770007777770000000000000000000777700000000000000220000000000111111100004400000004400
00000000005050000000000000000010008080000000000000000000000000000000000000800800080008000000000000000000000000000000002260505000
50505050005550000000000000000121002220000080800000000000000000008080080800277200027772000800080000000220000000006050528055855000
56555650558585500111000000001221027772000022200000778080000000008827728800789700878987800277720000002800005050005585222255555222
55858550565556500181110001111210078987200277720007897800007780808278972882788728278987208777778000528800558550005555288000022880
00555500560006505511221001812210078987200789872087887800878978000078870088277288278887202789872055852822555522000006622200528222
0000000050000050000122215511d212027772008789872000778000078878000007700080000008027772002788872055555280000282200050650000028800
0000000000000000000012220000dd20802020800277720008000000807780000000000000000000002820808277720000050022002828220000650005222220
00000000000000000000000000000050000000000020208000000000000000000000000000000000800800000028200800000500022020200005500000550000
20000000000000000000000000000000000000000000000000000000000000000000000666660002000000066666000000000000000000000000000000000000
22000000000000220000040000000000000800000000800000080000000080000000066660000020000006666000000000000000000000000000000000000000
02200400000022220000060000000000000200222200200000020000000020006005555600000022600555560000000000000000000000000000000000000000
22225600000522200000664400000000800022222222000880020222222020005558855556000288555885555600000000000000000000000000000000000000
02256644002552220006664440000000020228888822802002002222222200805555555550000222555555555000000000000000000000000000000000000000
22566664405255200006876440000000008287777788880000822888882228808220555556002888000055555600000000000000000000000000000000000000
02568764455525220029766442000000022872222778822800288777778888082882005550028288000000555000000000000000000000000000000000000000
22597664445525200029664422200000028778998777820002287777777888208888255550288822000225555000000000000000000000000000000000000000
02596644445525220222244425520000028778998777820002877222277782008882555502828880022855550000055000000000000000000000000000000000
22522444444525200252266255520000022878888778222802877899877782082228555228882880282855522000605500000000000000000000000000000000
02252664444452220252262555552000002287777782220000287888877822200885522882888222282555282200005500000000000000000000000000000000
00225666644002200255262255552200002228888828220000228777778822000025552288288850288652828220065500000000000000000000000000000000
00000066662000000225562522225220002082222228020000228888882822000006655558822800282062828282255500000000000000000000000000000000
00000026692200000022522255552220008080222208080000202222222802000000666555555220220028288288222500000000000000000000000000000000
00000295295520000000220222222200000000200200000008008020020200800000066666655500020288282828288200000000000000000000000000000000
00002052022052000000000020202020000000800800000000000800008000000000000000005560000202000020020200000000000000000000000000000000
08800000022000000808000002020000000000000000000002200000078000000000000000000000000000000000000000000000000000000000000000000000
87780000277200008777800027772000000000000000000027820000722800000000000000000000000000000000000000000000000000000000000000000000
87780000277200000777000007270000000000000000000028820000822800000000000000000000000000000000000000000000000000000000000000000000
08800000022000008777800027772000000000000000000002200000088000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000808000002020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000666666660000000000000000000000000000ddddd000000000000000000000000000000000000000000000000000000000000000000011100040
00000000066677777777666000000000000000000000000511115dd0000000000000000000000000000000000000000000000000000000000000000011b04444
0000000667777777766677766000000000000000000000511111115dd00000000000000050000000000000000000000000000000000000000000000014444244
000000677776677766666777760000000000000000000051000511115dd0000000000005d0000000000000000000000000000000000000000000000014442440
00000677777666776666677777600000000000000000000500005111115ddd0000000051d0000000000000000000000000000000000000000000000012444400
000067777777667776677777777600000000000000000000000051111111154400000d11d0000000000000000000000000000000000000000000000000220000
0006776667777777777766677777600000000000000000000000511111111444ddddd11d00000000000000000000000000000000000000000000000000000000
00676600066777777766000667777600000000000000000000000511111424411111115d00000000000000000000000000000000000000000000000000000000
0067600000677777776000006777760000000000000000000000051114224111111115d000000000000000000000000000000000000000000000000000000000
06760000000677777600000006777760000000000000000000000511224211111115dd0000000000000ccccccc00000000000000000000000000000000000000
067600000006777676000000067677600000000000000000000005222211115ddddd20000000000000cccccccccc000000000000000000000000000000000000
0676000000067777760000000676676000000000000000000000522211115dd22222ee00000000000cccccccccccc00000000000000000000000000000000000
67776000006777777760000067766776000000000000000000002221115dd22eeeeeeee000000000cccc6777776ccc000000ccc0000000000000000000000000
677766000667706777660006677767760000000000000000000021115dd22eeef22f22e000000000ccc677777776cc00000c776c000000000000000000000000
6777776667770006777766677777777600000000000000511111115dd22ee22f27cffe2e000000c00c67770007700c0000c77776c00000000000000000000000
67777777777700067777777777667776000000000000000511115dd22eee27cffccffe00000000cc0077700000006c000c777776c00000000000000000000000
677777777677706777777777777667760000000000000000ddddd22eeee2fccffccffe00000000067007000000700000c777776c000000000000000000000000
677777766667777777776677777667760000000000ef000002222eeeee2ffccffffffed0000000000700000000000c0c7776ccc0000000000000000000000000
67777677666776777776006776777776990000000ef00000feeeeeeeee2ffffffffffe00000000c700000000000070077ccc0000000000000000000000000000
677660677677606777600067606777760999000002eff0ffeeeeeeee22e2ffff77ffeeddd00000c7707000077000007700000cccc00000000000000000000000
0660000677760006760000060006776009999000002eefeeeeeeeee2eee2ffdf22fee1114f777cc777777777cc0000000cccc7666c0000000000000000000000
0000000067600000600000000000666009999990000eeeeeeeeeeeeeee2ddd1ffff11114fffffcc67ffff077cc000007777777776c0000000000000000000000
000000000600000000000000000000609499499900eeeeeeeeeeeeee2211111fff11114ffffff9cc6f000007700000000cccc7776c0000000000000000000000
0000000000000000000000000000000009449999900022eeeeeeee2205000011791114fffff99000077700000000777c00000cccc00000000000000000000000
000000000000000000000000000000000099494990000022eee222005115d100991119ff99900000c777000000007776cc000000000000000000000000000000
0000000000000000000000000000000099999499990000002220000511115d15dddd11991000000cc677000000700c7776ccc000000000000000000000000000
0000000000000000000000000000000009494944999900000000000511111d1ddddd11221000000ccc677000007600c777776c00000000000000000000000000
000000000000000000000000000000000994994944999000000000511111151dddddd112100000000cc670770000c00c777776c0000000000000000000000000
000000000000000000000000000000000099499499449400000005111114411dddddd111000000000ccc077776c00000c77776c0000000000000000000000000
00000000000000000000000000000000994494499449944400000111114ff4ddddddd1010000000000c007776ccc00000c766c00000000000000000000000000
00000000000000000000000000000000099999944499224444051111019ff7dddddd5000001001000000ccccccc0000000ccc000000000000000000000000000
00000000000000000000000000000000009999999990002244511111019fffddddd500000011011000000cccc000000000000000000000000000000000000000
000000000000000000000000000000000000999000000000251111110119ff7dd550000000111110000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000005555555511111110019fff75011000001119191000000000000000000000000000000000000000000000000
0000000000000000000000000000000000005555511111111111111110159fff0101100000111110000000000000000000000000000000000000000000000000
00000000000000000000000000000000000001111115111111111111105529ff7000110001111111000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000100155011111111111ddd02449ff700111000b11100000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000005500111111111115097112449ff711111111bb000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000111111111111509ff7112449941111111110000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001011111111155009ff70000224411bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000111111155001109ff700000e2112990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000011011105101111109ff7e00e20100990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000001110000111111009ff2ee220000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000001110000022222200000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000002222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000777000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000007c7000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000007c7000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000007c7007770000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000007c7007c70000000000000000000700700000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000007c7007777777777777700000007177170007000000000000
000006000000000000000000000000000000000000000000000000000000000000000000000000007c7777c7cc777cc77c700000007111170071700000000000
000067600000060000000060000000000000000000000000000000000000000000000000000000007c77c7c7c7c7c7c777700000071919117007170000000000
066667760000676600000676000660000000000000000000000000000000000000000000000000007cccc7c7c7c77ccc7c700000007111170007170000000000
00677777600677776000677760677600000000000000000000000777777777777777777777777777777777777777777777777777771777717777777777777770
00067777766777777606677776776000000000000000000000007777c7c7ccc7ccc77cc7c7c7ccc77cc7777cc7ccc777ccc7c7c7ccc777ccc77cc77cc7cc7777
00006777677777777767666777760000000000000000000000007777c7c77c777c77c777c7c7c777c77777c7c7c777777c77c7c7c77777ccc7c7c7c7c7c7c777
00000677777776677777766777600000000000000000000000007777c7c77c777c77c777ccc7cc77ccc777c7c7cc77777c77ccc7cc7777c7c7c7c7c7c7c7c777
00000067777777677777776676000000000000000000000000007777ccc77c777c77c777c7c7c77777c777c7c7c777777c77c7c7c77777c7c7c7c7c7c7c7c777
00000006677777777777776660000000000000000000000000007777ccc7ccc77c777cc7c7c7ccc7cc7777cc77c777777c77c7c7ccc777c7c7cc77cc77c7c777
00000000066677777777666000000000000000000000000000007777777777777777777777777777777777777777777777777777777777777777777777777777
00000000000066666666000000000000000000000000000000000666666666666666666666666666666666666666666666666666666666666666666666666660
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000777000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000007c7000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000007c7000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000007c7007770000000000000000000000000000000000000000000000000000000000010000
000000000000000000000000000000000000000000000000000000007c7007c70000000000000000000700700000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000007c7007777777777777700000007177170007000000000000000000000666666000000000
000000000000000000000000000000000000000000000000000000007c7777c7cc777cc77c700000007111170071700000000000000000066777777660000000
000000000000000000000000000000000000000000000000000000007c77c7c7c7c7c7c777700000071919117007170000000000000000677777777776000000
000000000000000000000000000000000000000000000000000000007cccc7c7c7c77ccc7c700000007111170007170000000000000006777600077777600000
00000000000000000000000000000777777777777777777777777777777777777777777777777777771777717777777777777770000007760000007777700000
00000000000000000000000000007777c7c7ccc7ccc77cc7c7c7ccc77cc7777cc7ccc777ccc7c7c7ccc777ccc77cc77cc7cc7777000007000000000777760000
00010000000000000000000000007777c7c77c777c77c777c7c7c777c77777c7c7c777777c77c7c7c77777ccc7c7c7c7c7c7c777000000000000000077770000
00000000000000000000000000007777c7c77c777c77c777ccc7cc77ccc777c7c7cc77777c77ccc7cc7777c7c7c7c7c7c7c7c777000000000000000077770000
00000000000000000000000000007777ccc77c777c77c777c7c7c77777c777c7c7c777777c77c7c7c77777c7c7c7c7c7c7c7c777000000000000000077770000
00000000000000000000000000007777ccc7ccc77c777cc7c7c7ccc7cc7777cc77c777777c77c7c7ccc777c7c7cc77cc77c7c777000000000000000077770000
00000000000000000000000000007777777777777777777777777777777777777777777777777777777777777777777777777777000007000000000777760000
00000000000000000000000000000666666666666666666666666666666666666666666666666666666666666666666666666660000007760000007777700000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006777601077777600000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000677777777776000000
00000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066777777660000006
00000000012100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000666666000000000
000000001221000000000000ddddd000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000
00000111121000000000000511115dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000018122110000000000511111115dd00000000000000050000000000000000000000600000000000000000000000000000000000000060000000000000000
00005511d212000000000051000511115dd0000000000005d0000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dd2000000000000500005111115ddd0000000051d0000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000050000000000000000051111111154400000d11d0000000000000000000000000000000000600000000000000000000000000000000000000000000
0000000000000000000000000000511111111444ddddd11d00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000511111424411111115d00000000000000000000000000000000000000000000000100000000000000000000000000000000
0000000000000000000000000000051114224111111115d000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000511224211111115dd0000000000000ccccccc00000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000005222211115ddddd20000000000000cccccccccc000000000000000000000000000000000000000000000000000000000000
0000000000000000000100000000522211115dd22222ee00000000000cccccccccccc00000000000000000000000000000000000000000000000000000000000
00000000000000000000000000062221115dd22eeeeeeee000000000cccc6777776ccc000000ccc0000000000000000000000000000000000000000000000000
000000000000000000000000000021115dd22eeef22f22e000000000ccc677777776cc00000c776c000000000000000000000000000000000000000000000000
0000000000000000000000511111115dd22ee22f27cffe2e000000c00c67770007700c0000c77776c00000010000000000000000000000000000000000000000
00000000000000000000000511115dd22eee27cffccffe00000000cc0077700000006c000c777776c00000000000000000000000000000000000000000000000
000000000000000000000000ddddd22eeee2fccffccffe00000000067007000000700000c777776c000000000000000000000000000000000000000000000000
000000000000000000ef000002222eeeee2ffccffffffed0000000000700000000000c0c7776ccc0000000000000000000000000000000000000000000000000
00000000990000000ef00000feeeeeeeee2ffffffffffe06000000c700000000000070077ccc0000000000000000000000000000000000000000000000000000
000000000999000002eff0ffeeeeeeee22e2ffff77ffeeddd00000c7707000077000007700000cccc00000000000000000000000000000000000000000000000
0000000009999000002eefeeeeeeeee2eee2ffdf22fee1114f777cc777777777cc0000000cccc7666c0000000000000000000000000000000000000000000000
0000000009999990000eeeeeeeeeeeeeee2ddd1ffff11114fffffcc67ffff077cc000007777777776c0000000000000000000000000000000000000000000000
000000009499499900eeeeeeeeeeeeee2211111fff11114ffffff9cc6f000007700000000cccc7776c0000000000000000000000000000000000000000000000
0000000009449999900022eeeeeeee2205000011791114fffff99000077700000000777c00000cccc00000000000000000000000000000000000000000000000
000000000099494990000022eee222005115d100991119ff99900000c777000000007776cc000000000000000000000000000000000000000000000000000000
0000000099999499990000002220000511115d15dddd11991000000cc677000000700c7776ccc000000000000000000000000000000000000000000000000000
0000000009494944999900000000000511111d1ddddd11221000000ccc677000007600c777776c00000000000000000000000000000000000000000000000000
000000000994994944999000000000511111151dddddd112100000000cc670770000c00c777776c0000000000000000000000000000000000000000000000000
000000000099499494449400000005111114411dddddd111000000010ccc077776c00000c77776c0000000000000000000000000000000000000000000000000
00000000994494444449944400000111114ff4ddddddd1010000000000c007776ccc00000c766c00000000000000000000000000000000000000000000000000
00000000099949944499224444051111019ff7dddddd5000001001000000ccccccc0000000ccc000000000000000000000000000000000000000000000000000
00000000009994499990002244511111019fffddddd500000011011000000cccc000000000000000000000000000000000000000000000000000000000000000
000000000000999000000000251111110119ff7dd550000000111110000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000005555555511111110019fff75011000001119191000000000000000000000000000000000000000000000000000000000000000000000000
0000000000005555511111111111111110159fff0101100000111110000000000000000000000000000000000000000000000000000000000000000000000000
00000000000001111115111111111111105529ff7000110001111111000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000100155011111111111ddd02449ff700111000h11100000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000005500111111111115097112449ff711111111hh000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000111111111111509ff7112449941111111110000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001011111111155009ff70000224411hhh11100040000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000111111155001109ff700000e21129911h04444000000000000000000000000000000000000000000000001000100000000000000000000
0000000000000000011011105101111109ff7e00e201009914444244000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000001110000111111009ff2ee2200000914442440000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000011100000222222000009012444400000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000022220000000000220000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000002200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000
00000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000600000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000011001101100111000101110111011100000111010100000000011110000000000000000111000000000000000001110000000000000000000000000
00000000100010101010100001001010101001000000101010100100000010101110100001100000010001101110101000001010011010101110111000000000
00000000100010101010110001001110110001000000110011100000000011001100100010100000010010100100101011101110100010100100110000000000
00000000100010101010100001001010101001000000101000100100000010101000100011100000010010100100111000001010100011100100100000000000
00000000011011001110111010001010101001000000111011100000000011100110011010100000010011000100101000001010011010101110011000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000hhh110hhh110000000000000hhh110000000hhh110000000hhh110000000hhh110hhh110hhh110000000000000000000hhh110000000
0000000000000000000hhhhhhhhhhhh100000000000hhhhhh100000hhhhhh100000hhhhhh100000hhhhhhhhhhhhhhhhhh100000000000000000hhhhhh100000h
0000000000000000000hhhhhhhhhhhh100000000000hhhhhh100000hhhhhh100000hhhhhh100000hhhhhhhhhhhhhhhhhh100000000000000000hhhhhh100000h
000000000d000000000hhhhhhdhhhhhh00000000000hhhhhhh00000hhdhhhh000d0hhhhhhd00000hhhhhhhhhhdhhhhhhhh0000000d000000000hhhhhhh00000h
0000000001000000111ddhhhh1hhhhhh111dd0001ddhhhhhhh00000hh1hhhh00010hhhhhh100000h1ddhhhhhh1hhhhhh1dd0000001000000111hhhhh1dd0000h
0000000011d0000111111dhh11dhhhh111111d00111dhhhhh000000011dhh00011d0hhhh11d00000111dh0hh11d0hhhh111d000011d000011111hhhh111d0000
000000001110000111111d221110220111111d01111d002200000000111200001110002211100001111d000011100021111d00001110000111111d21111d0001
00000001111d000111111121111d220111111101111d002200000001111d0001111d0021111d0001111d0001111d0021111d0001111d000111111121111d0001
00000001111100011111112111112201111111011111d022000000011111000111110021111100011111d001111100211111d00111110001111111211111d001
000000111111d000111110111111d2001111100111111022000000111111d0111111d0111111d001111110111111d021111110111111d0001111102111111001
00000011111110000044001111111200004400000440002200000011111110111111101111111000044200111111102204400011111110000044002204400000

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffff00000000ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0101000038030360303503033030320302f0302d0302c0302a0302803027030250302103003000020000200000000000000000000000000000000000000000000000000000000000000000000000000000000000
10070000195521b5521d5421f5422153223532255322752228522295222a5222a5222a5222a5222a5222a5222a51229512295122a5122a5522a5022a5522a502295522750225552225521f5021d5521950216552
10040000002532b51032630266301a6201a6151861500600006000060000600006000060000600006000060000600006000060000000000000000000000000000000000000000000000000000000000000000000
000100001c5401d5401e5401f540205402154021540205401f5401e5401d5401d5400050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000600001c3501834014330113200f3200c3100b3100a310003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000600000c5500d5500d5500e5501055014550175501a5501d55020550235502455027550295002c5002a5502a5002f5502a500305502a500315502a500325502a50034550005000050000500005000050000500
000200000d5500f5500f5500e5500e5500f55012550175501c55023550295502b5502b55029550265502555025550285502e55033550005000050000500005000050000500005000050000500005000050000500
0002000011110171101c1201f1202113023140241402615026150271502715028150231501c150181501515012150101500e1500d150091500815006150061500515000100001000010000100001000010000100
011000200000000000103401032010340103201030010300153001530010340103201134011320183001830018300183001134011320113401132013300133001830018300113400000000000000000000000000
00010000155501655017550195501a5501b5501b5500f500185000f5001150014500195001c500205000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c143000000000000000246250000000000000000c143000000000000000246250000000000000000c143000000000000000246250000000000000000c14300000000000000024625000000000000000
011000200c1433f215000003f215246250c1433f215000000c1433f2150c1433f21524625000003f215000000c1433f215000000000024625000003f215000000c143246250c1432461524625000000000000000
010800200c1433f2003f2153f300246253f3003f2153f3003f2153f3000c1433f20024625102003f2153f2000c1433f2003f2153f20024625192003f2153f2000c1433f200246253f2003f2153f2000000000000
010700200c143000003f21500000246250000024625000003f215000000c14300000246250000024625000000c143000003f21500000246250000024625000003f215000000c1430000024625000002462500000
010700200c143000003f21500000246250000024625000003f215000000c14300000246250000024625000000c143000003f21500000246250000024625000003f215000000c1430000024625000002462524615
011000000211302143021230211302143021230211302143021130214302123021130214302123021130214302113021430212302113021430212302113021430211302143021230211302143021230211302143
011000000912009120091200912002120021200012000120001200012000120001200012000120001200012000120001200012000120051200512007120071200012000120001200012004120041200512005120
011000200912009120091200912007120071200912009120021230211300000000000000000000000000000002123021130000000000021230211300000000000000000000000000000002123021130000000000
012000000513005130051300513005130051300513005130051300513005130051300513005130051300513003130031300313003130031300313003130031300313003130031300313003130031300313003130
012000000113001130011300113001130011300113001130011300113001130011300113001130011300113003130031300313003130031300313003130031300313003130031300313003130031300313003130
01100020153401530015300153001a3401a3001834018300183401830018300183001832018300183001830018300183001830018300183201830018300183001832009300093000930018320093000930009300
01100000153401530015300153001f3401f3202134021320093400932009320093200932009320093200932009320093200932009320093200932009320093200932009320093200932009320093200932009320
01100000153401532015320153401a3401a3201834018320183401832018320183201832018320183201832018320183201832018320183201832018320183201832018320183201832018320183201832018320
01100000153401532015320153401f3401f3202134021320093400932009320093200932009320093200932009320093200932009320093200932009320093200932009320093200932009320093200932009320
011000201034010320153401532015300153001530015300103401134015340153201830018300183001830010340103201534015320133401332018300183001134011320183001830010340103201830018300
01100020103401032010340103201030010300153001530010340103201134011320183001830018300183001134011320183001134011320183000000000000113401132000000000000e3400e3200e32300000
011000201b1401b1201d1401d1201d1201d120221402212022120221201b1401b1201d1401d1201b1401b120221402212022120221201b1401b1201d1401d120241402412024120241201b1401b1201b1201b120
0110002024140241202314023120231202312020140201202012020120241402412023140231202014020120241402412023140231202312023120201402012020120201201d1401d1201d1201d1201d1201d120
012000200516500000051650510005100051000516505100051000510005100051000516505100051000510003165031000316503100031000310003165031000310003100031000310003165031000310003100
012000000116501100011650110001100011000116501100011000110001100011000116501100011000110003165031000316503100031000310003165000000310003100031000310003165031000310003100
011000002634028340293402b3402d3402b34029340283402634028340293402b3402d3402b34029340283402634028340293402b3402d3402b34029340283402634028340293402b3402d3402b3402934028340
011000200514005120051200512024240242200514005120242402422022240222201d2401d22022240222200514005120051200512024240242200514005120242402422022240222201d2401d2201d2201d220
011000200814008120081200812024240242200814008120242402422022240222200814008120222402222008140081200812008120242402422008140081202424024220222402222008140081202224022220
011000200714007120071200712024240242200714007120242402422022240222200714007120222402222007140071200712007120242402422007140071202424024220222402222007140071202224022220
0110002007140071201d2401d220071200712020240202201c2421c22207140071201f2421f22207120071201c2421c2221c2221c2221c2421c2221c2221c2221d2421d2221d2221d2221d2421d2221d2221d222
011000200414004120212402122004140041201d240041201d2421d2221d2221d22204140041201c2421c2221c2221c2221d2421d22204140041201d2421d2221f2401f2201d2401d2201c2401c2200414004120
010e00201b2401b2201b2201b220182401822019240192201c240000001c240000001b000280001b000000001b240280001b2400000000000000000000000000192400000019240000001b240000001b24000000
010e00201b2401b2201b2201b220182401822015240152201c240000001c240000001b000280001b000000001e240280001e24000000000000000000000000001e240000001b2400000019240000001824000000
0110002022040220202004020020200402002220022200221e0401e0201b0401b0201d0401d0201e0401e020220402202023040230201d0421d0221d0221d0221e0401e0201b0401b0201d0401d0201e0401e020
0110000022040220202004020020200402002220022200221e0401e0201b0401b0201d0401d0201e0401e020220402202023040230201d0421d0221d0221d0221e0401e0201b0401b0201a0401a0201704017020
010e00201b1201b1201b1201b1221b1221b1201b1221b1221b1201b1201b1201b1251b1251b1201b1221b1221c1201c1201c1201c1201c1201c1201c1201c1201c1201c1201c1201c1251c1251c1201c1201c120
010e00201e1201e1201e1201e1221e1221e1201e1221e1221e1201e1201e1201e1251e1251e1201e1221e1221c1201c1201c1201c1201c1201c1201c1221c1221c1201c1201c1201c1251c1251c1201c1201c120
010e00201b1201b1201b1201b1221b1221b1201b1221b1221b1201b1201b1201b125221201f1201e1201d1201c1201c1201c1201c1201c1201c1201c1201c1201c1201c1201c1201c125221201f1201e1201d120
010e00201e1201e1201e1201e1221e1221e1201e1221e1221e1201e1201e1201e125221201f1251e1201d1201c1201c1201c1201c1201c1201c1201c1221c1221c1201c1201c1201c125221201f1251e1201d120
011000001b2201b2201b2201b220182201822019220192201c220002001c220002001b200282001b200002001b220282001b2200020000200002000020000200192200020019220002001b220002001b22000200
__music__
01 14584344
00 14194344
00 15191e44
00 15191f44
00 151a2044
00 151b2168
00 151a2868
00 151b2868
00 151a2044
00 151b2168
00 151a2868
00 151b2868
00 14584344
00 15192244
00 15192268
00 15192368
00 15192368
00 151a2044
00 151b2168
00 15192244
00 15192268
00 15192368
00 15192368
00 151a2044
00 151b2168
00 151a2868
00 151b2868
00 151a2044
00 151b2168
00 151a2868
02 151b2868
01 16296444
00 162a6444
00 162b6444
00 16296444
00 162c6444
00 162d6444
00 162c6444
02 162d6444
01 172e6444
00 182f6444
00 172e3244
00 182f3344
00 172e3444
02 182f3544

