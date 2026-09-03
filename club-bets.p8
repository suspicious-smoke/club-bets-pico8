pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--race club bets
--by olivander65
function _init()
	version,t=0,0
	debug={"","","",""}

	categories={
		"movement",
		"precise"
	}
	obs={
		{"hairpine",1,2},
	}
	bets={}
	for i=1,10 do
		add(bets,{})
		for j=1,16 do
			add(bets[i],false)
		end
	end
	-- for i=1,4 do
	-- 	bets[1][i*4]=true
	-- end
	players={
		--{name,abreiv,strength,{categories}}
		{"slime","slm",10},
		{"knight","knt",11},
		{"dk knight","dkt",12},
		{"dragon","dgn",13},
		{"pegasus","pgs",14},
		{"demon","dmn",15},
		{"imp","imp",16},
		{"wizard","wzd",17},
		{"goblin","gbn",10},
		{"thief","thf",11},
		{"hero","hro",12},
		{"ghost","ght",13},
		{"quibble","qbl",14},
		{"chao","cho",15},
		{"behold","bhd",16},
		{"king","kng",17},
	}
	arenas={}
	odds={}
	bet_odds={}
	bet_amounts=reset_num_array(10,4)
	--used the helpful table from https://gurpsland.no-ip.org/articles/d6chance.htm
	d6x3={
		0,0,.0046,.0139,.0278,.0463,.0694,.0972,.1157,.1250,
			.1250,.1157,.0972,.0694,.0463,.0278,.0139,.0046
	}
	--prob of 3d6 from 3-18
	bet_sel=1--the currently selected bet (betpage/quickbetpage)
	arena_sel=1
	_upd=blank
	_drw=blank
	fill_arenas()
	dummy_bets()

	--init_quickbetpage()
	--init_ticket()
	--init_betpage()
	init_confirm()
end

function blank() end

function _update()
	t+=1
	_upd()
	
	--update_fx()--particles
end

function reset_bet_amounts()
	bet_amounts={}
	for i=1,10 do
		add(bet_amounts,{0,0,0,0})
	end
end

function reset_num_array(_size,_items)
	_num_arr={}
	for i=1,_size do
		add(_num_arr,reset_array(_items))
	end
	return _num_arr
end

function reset_array(_items)
	_arr={}
	for i=1,_items do
		add(_arr,0)
	end
	return _arr
end

function odds_debug()
	local gc={1,4,2,3}--arena text colors
	gc_ind=1--color index
	g_off=0--space between arenas
	for i=1,16 do
		print(bet_odds[i]..":1",24,i*8-6,gc[gc_ind])
		print(players[arenas[i]][1],50,i*8-6,gc[gc_ind])
		print(odds[i].."%",10,i*8-6,gc[gc_ind])
		if i%4==0 then
			gc_ind+=1
			g_off+=2
		end
	end
end

function dummy_bets()
	for _bet=1,10 do
		for _arena=1,4 do
			local _arloc=(_arena-1)*4	
			_r=rnd_rng(1,5)
			if _r!= 5 then
				bets[_bet][_arloc+_r]=true
			end
		end
	end
end

function _draw()
	cls()
	
	_drw()

	--debug
	offst=0
	for txt in all(debug) do
		print(txt,10,offst,8)
		offst+=8
	end
end
-->8
--bet page
function init_betpage()
	_upd=upd_betpage
	_drw=drw_betpage
	_bet_amt_tmr,bet_off=0,0
	plyr_menu_sel=1
	
	bet_mode=1--main,plyr sel,amt sel
	i_amt=1
end

function upd_betpage()
	get_total_odds_and_pay(bet_sel)
	--player select mode
	if bet_mode==2 then
		if btnp(⬆️) then
			plyr_menu_sel=(plyr_menu_sel-2)%4+1
		elseif btnp(⬇️) then
			plyr_menu_sel=(plyr_menu_sel%4)+1
		elseif btnp(🅾️) then
			player_sel=plyr_menu_sel+(arena_sel-1)*4
			toggle_bet()
			bet_mode=1
		elseif btnp(❎) then
			bet_mode=1
		end
	--bet select mode
	elseif bet_mode==3 then
		if btnp(⬆️) then
			bet_amounts[bet_sel][i_amt]=(bet_amounts[bet_sel][i_amt]+1)%10
		elseif btnp(⬇️) then
			bet_amounts[bet_sel][i_amt]=(bet_amounts[bet_sel][i_amt]-1)%10
		elseif btnp(➡️) then
			i_amt=(i_amt%4)+1
		elseif btnp(⬅️) then
			i_amt=(i_amt-2)%4+1
		elseif btnp(🅾️) or btnp(❎) then
			bet_mode=1
		end
	else
		if btnp(⬆️) then
			arena_sel=(arena_sel-2)%6+1
		elseif btnp(⬇️) then
			arena_sel=(arena_sel%6)+1
		elseif btnp(➡️) then
			_bet_amt_tmr=10
			bet_sel=(bet_sel%10)+1
		elseif btnp(⬅️) then
			_bet_amt_tmr=10
			bet_sel=(bet_sel-2)%10+1
		elseif btnp(🅾️) then
			if arena_sel==6 then
				--complete bets
				init_confirm()
			elseif arena_sel==5 then
				--change money
				i_amt=1
				bet_mode=3
			else
				bet_mode=2--player sel
				plyr_menu_sel=1
			end
		elseif btnp(❎) then
			--open up window to see
			--more info or switch menus
		end
	end
	bet_off=0
	if _bet_amt_tmr>0 then
		_bet_amt_tmr-=1
		bet_off=-1
	end
end

function drw_betpage()
	print("round:#",4,3,6)	
	print("bet:\f9#"..bet_sel,52,3+bet_off,6+3*bet_off)	
	spr(108,83,1)--money
	print("100",92,3,9)
	rrectfill(4,10,120,74,0,7)--ticket
	rrect(3,9,122,75,0,1)--outline
	rrectfill(4,10,120,9,0,2)--red area
	print("place a bet",42,12,7)
	rrectfill(4,20,120,8,0,5)--grey area
	line(3,19,124,19,1)--hline
	line(39,19,39,83,1)--vline
	print("arena",12,21,0)
	print("player",72,21,0)
	--selection area
	for i=1,4 do
		line(3,13+i*14,124,13+i*14,1)
		rrectfill(42,16+i*14,80,9,1,6)
		if arena_sel==i and bet_mode!=2 then
			rrect(42,16+i*14,80,9,1,9)
		end
		print(i,18,18+i*14,0)
		spr(101+i,27,16+i*14)--planet
		--get player
		chk_spr=106
		local plyr_str="who to bet on?"
		for plyr=1,4 do 
			local _arloc=(i-1)*4+plyr
			if bets[bet_sel][_arloc] then
				plyr_str=get_player_string(_arloc)
				chk_spr=107
			end
		end
		spr(chk_spr,8,16+i*14)--check mark
		print(plyr_str,52,18+i*14,0)
		spr(68,115,19+i*14)
	end
	
	draw_winning_calc()
	--player select area
	if bet_mode==2 then
		draw_dropdown()
	end
end

function draw_dropdown()
	--draw sel player menu
	rrectfill(42,26+arena_sel*14,80,40,1,6)
	for plyr=1,4 do
		local _arloc=(arena_sel-1)*4+plyr
		if plyr_menu_sel==plyr then
			rrectfill(44,20+arena_sel*14+plyr*9,76,9,1,5)	
		end
		print(get_player_string(_arloc),52,22+arena_sel*14+plyr*9,0)
	end
end

function get_player_string(_arloc)
	return players[arenas[_arloc]][1].." "..bet_odds[_arloc]..":1"
end

function draw_winning_calc()
	--winning calculator
	rrectfill(4,87,120,26,0,7)--ticket
	rrect(3,86,122,28,0,1)--outline
	rrectfill(4,87,120,8,0,5)--title
	print("winnings calculator",26,88,0)
	line(3,94,124,94,1)--hline1
	line(3,102,124,102,1)--hline2
	print("bet amt",8,96,0)
	
	for i=1,4 do
		i_clr=0
		if i==i_amt and bet_mode==3 then
			i_clr=9
		end
		print(bet_amounts[bet_sel][i] or 0,9+i*4,105,i_clr)
	end

	if arena_sel==5 then
		rrect(4,103,36,10,0,9)
	end
	line(40,94,40,112,1)--vline1
	print("odds",45,96,0)
	line(64,94,64,112,1)--vline2
	_str=print_bet_odds()
	print(_str,57-#_str*2,105,0)
	print("payout",83,96,0)
	print(total_pay,94-#total_pay*2,105,0)
	--button
	rrectfill(34,116,59,9,1,1)
	print("place all bets",36,118,7)
	if arena_sel==6 then
		rrect(34,116,59,9,1,9)
	end
end

--confirm bet page
function init_confirm()
	scroller=0
	max_scroll=0
	--get total payout
	get_payout()
	_upd=upd_confirm
	_drw=drw_confirm
end

--confirm bet page
function upd_confirm()
	if max_scroll>0 then
		if btn(⬇️) then
			scroller=min(scroller+7,max_scroll)
		elseif btn(⬆️) then
			scroller=max(scroller-7,0)
		elseif btnp(❎) then
			init_betpage()
		end
	end
end

--confirm bet page
function drw_confirm()
	print("round:#",4,3-scroller,6)	
	
	spr(108,83,1-scroller)--money
	print("100",92,3-scroller,9)--my money
	rrectfill(4,10-scroller,120,max_scroll+97,0,7)--ticket
	rrect(3,9-scroller,122,10,0,1)--outline
	rrectfill(4,10-scroller,120,9,0,2)--red area
	print("current bets",42,12-scroller,7)
	rrectfill(4,20-scroller,120,8,0,5)--grey area
	rrect(3,19-scroller,122,9,0,1)--grey outline

	print("bet",5,21-scroller,0)
	line(17,20-scroller,17,max_scroll+106-scroller,1)--bet/player v-line
	print("player",31,21-scroller,0)
	line(70,20-scroller,70,max_scroll+106-scroller,1)--end plyr line
	print("odds/winnings",72,21-scroller,0)
	--selection area
	bet_count=0
	p_count=1
	o_pcount=0
	for _bet=1,10 do
		p_count=1
		_cbet_odds=1
		_cbet=bets[_bet]
		print(_bet,6,21+o_pcount-scroller+8,0)
		for _arloc=1,16 do
			if _cbet[_arloc] then
				print(players[arenas[_arloc]][1],28,14+p_count*9+o_pcount-scroller+8,0)
				spr(101+ceil(_arloc/4),19,12+p_count*9+o_pcount-scroller+8)--planet
				p_count+=1
			end
		end
		if p_count>1 then
			pc_mult=8
			if p_count==2 then
				pc_mult=9
			end
			rrect(3,19+o_pcount-scroller+8,122,p_count*pc_mult,0,1)
			get_total_odds_and_pay(_bet)
			
			print(""..arr_display(clmp_odds)..":1",84,30+o_pcount-scroller,0)
			spr(108,78,36+o_pcount-scroller)--coin
			print(total_pay,86,38+o_pcount-scroller,0)
			o_pcount+=p_count*pc_mult-1
			bet_count+=1
		end
	end
	max_scroll=o_pcount-60
	--total winnings box
	rrectfill(3,27+o_pcount-scroller,122,20,0,7)--ticket
	rrect(3,27+o_pcount-scroller,122,20,0,1)--ticket
	print("possible winnings",10,34+o_pcount-scroller,0)
	line(79,27+o_pcount-scroller,79,46+o_pcount-scroller,1)
	spr(108,81,32+o_pcount-scroller)--coin
	for i=1,#payout do
		print(payout[i],86+i*4,34+o_pcount-scroller,0)
	end
	
	print("press 🅾️ to confirm",28,50+o_pcount-scroller,7)
end

-->8
--quick bet page

function init_quickbetpage()
	bet_sel=1--1-10
	player_sel=1--select player for each arena 1-16
	total_odds=0
	total_pay=0
	_upd=upd_quickbetpage
	_drw=draw_quickbetpage
end

function upd_quickbetpage()
	get_total_odds_and_pay(bet_sel)
	if btnp(➡️) then
		bet_sel=(bet_sel%10)+1
	elseif btnp(⬅️) then
		bet_sel=(bet_sel-2)%10+1
	elseif btnp(⬆️) then
		player_sel=(player_sel-2)%16+1
	elseif btnp(⬇️) then
		player_sel=(player_sel%16)+1
	elseif btnp(🅾️) then
		toggle_bet()
	elseif btnp(❎) then
		--open up window to see
		--more info or switch menus
	end
end

function get_bet_odds(_bet)
	for arena=1,16 do
		if bets[_bet][arena] then
			total_odds[_bet]*=bet_odds[arena]
		end
	end
end

function get_total_odds_and_pay()
	total_payout={0,0,0,0,0,0,0,0,0,0,0}
	for i_bet=1,10 do
		bet_total_odds=reset_array(10)
		bet_pays=reset_num_array(10,4)
		for i_arena=1,16 do
		if bets[i_bet][i_arena] then
			total_odds[i_bet]*=bet_odds[i_arena]
		end
	end
	--bet's total odds
	_odds=min(total_odds,999)
	bet_total_odds[i_bet]=_odds
	--get payout for bet
	clmp_odds=int_to_arr(_odds)--make an array	

	total_payout=arr_mult(clmp_odds,bet_amounts[i])
end


function toggle_bet()
	--toggle bet if already selected
	if bets[bet_sel][player_sel] then
		bets[bet_sel][player_sel]=false
		return
	end
	--switch off other bets in arena
	arena_start=0
	if player_sel<=4 then
		arena_start=1
	elseif player_sel<=8 then
		arena_start=5
	elseif player_sel<=12 then
		arena_start=9
	else
		arena_start=13
	end
	for i=arena_start,arena_start+3 do
		bets[bet_sel][i]=false
	end
	bets[bet_sel][player_sel]=not bets[bet_sel][player_sel]
end

function draw_quickbetpage()
	local gc={1,4,2,3}--arena text colors
	gc_ind=1--color index
	g_off=0--space between arenas
	for ap_id=1,16 do--players in arenas
		local _py=ap_id*7+g_off
		rrectfill(1,_py-6,126,7,0,6+ap_id%2)--row background
		--print player string
		local _pstring=players[arenas[ap_id]][2].." "
		if bet_odds[ap_id] < 10 then
			_pstring=_pstring.." "
		end
		_pstring=_pstring..bet_odds[ap_id]..":1"
		print(_pstring,3,_py-5,gc[gc_ind])
		--bet buttons
		for k=1,10 do
			bet_clr=5
			if bets[k][ap_id] then
				bet_clr=3
			end
			if bet_sel==k and player_sel==ap_id then
				print("\f7\^oc5a●",29+k*9,_py-5)
			end
			print("●",29+k*9,_py-5,bet_clr)
		end

		if ap_id%4==0 then
			gc_ind+=1
			g_off+=2
		end
	end
	--bet selector
	rrect(28+bet_sel*9,0,9,120,0,12)
	--info area
	rrectfill(0,120,128,7,0,5)
	print("bet \f9#"..bet_sel,2,121,7)
	
	print("odds "..print_bet_odds(),34,121,7)
	print("pays \f9$"..total_pay,74,121,7)
end

function print_bet_odds()
	local _odds_clr="\f9"
	int_clmp_odds=arr_display(clmp_odds)
	if int_clmp_odds=="999" then
		_odds_clr="\f8"
	end
	return _odds_clr..int_clmp_odds..":1"
end

-->8
--ticket
function init_ticket()
	tx,ty=20,10
	_upd=upd_ticket
	_drw=drw_ticket
end

function upd_ticket()
	
end

function drw_ticket()
	
	local _arx,_plx,_odx=tx+2,tx+26,tx+66
	--ticket
	for i=1,15 do
		rrect(tx-5+6*i,ty-1,3,1,0,7)
	end
	rrectfill(tx,ty,90,81,0,7)--ticket
	rrectfill(tx+6,ty+81,84,24,0,7)--lwr ticket
	spr(128,tx-2,ty+81,1,3)--left leaf
	spr(129,tx+89,ty+81,1,3)--right leaf
	for i=1,3 do
		_wmoff=0
		if i==3 then
			_wmoff=1
		end
		print("★galaxy club★",tx+15,ty-13+i*32+_wmoff,6)	
	end
	--text
	rrectfill(tx+2,ty+2,86,10,0,2)--red area
	print("★galaxy club bets★",tx+5,ty+5,7)
	print("round #1784",tx+22,ty+15,0)
	print("----------------------",tx+2,ty+22,0)
	print("arena",_arx,ty+28,0)
	print("player",_plx+4,ty+28,0)
	print("odds",_odx,ty+28,0)
	print("----------------------",tx+2,ty+22,0)
	for i=1,4 do
		print(i,_arx+8,ty+34+8*i,0)
		print("the dude",_plx,ty+34+8*i,0)
		print("11:1",_odx,ty+34+8*i,0)
	end
	print("----------------------",tx+3,ty+80,0)
	print("bet:",_arx+1,ty+85)
	print("odds:",tx+41,ty+85)
	print("payout:",_arx+2,ty+93)
end
-->8
--calculations
function calculate_odds()
	--loop through the players
	odds={}
	arena_opp_off=0
	for _arena_index=1,16 do
		local _plyr_id=arenas[_arena_index]
		local total_prob=0
		local p_base=players[_plyr_id][3]
		for die=3,18 do
			local p_prob=d6x3[die]
			local p_score=p_base+die
			--we have our die roll
			--opponent probabilities
			for _copp=1,4 do
				local _opp_id=arenas[arena_opp_off+_copp]
				if _opp_id!=_plyr_id then
					local o_prob=0
					local o_base=players[_opp_id][3]
					for o_die=3,18 do
						--get player scores that beat opponent's score
						if o_base+o_die<p_score then
							o_prob+=d6x3[o_die]
						end
					end
					--multiply opponent prob to player prob
					p_prob=p_prob*o_prob
				end 
			end
			total_prob+=p_prob
		end
		if _arena_index%4==0 then
			arena_opp_off+=4
		end
		add(odds,ceil(total_prob*100))
	end
	get_bet_odds()
end

function get_bet_odds()
	bet_odds={}
	for oi=1,16 do--odds index
		local _percs={40,30,25,20,15,10,7, 5, 3, 4, 0}
		local _podds={2, 3, 4, 5, 6, 7, 8,10,11,12,13}
		local found=false
		for i=1,#_percs do
			if odds[oi]>=_percs[i] and not found then
				add(bet_odds,_podds[i])
				found=true
			end
		end
	end
end

function fill_arenas()
	arenas={}
	--array of 1,2,...,16 for random players
	local _rplrs={}
	for i=1,16 do
		add(_rplrs,i)
	end
	--fill pirates in arenas
	for i=1,16 do
		local _rplyr=rnd(_rplrs)
		add(arenas,_rplyr)
		del(_rplrs,_rplyr)
	end
	calculate_odds()
end

-->8
--helpers
function explode_d6()
	local run_loop=true
	local total=0
	while run_loop do
		local roll=d6()
		total+=roll
		if roll!=6 then
			run_loop=false
		end
	end
end

function hcenter(s)
	return 64-#s*2
end

--function in_list(_l,_val)
--	for _v in all(_l) do
--		if _v == _val then
--		 return true
--		end
--	end
--	return false
--end

--i=2 gives num between 0,1
--rnd never gives the limit
--value. rnd(1) will never
--give 1
function f_rnd(_i)
	return flr(rnd(_i))
end
--gives random number between
--_s and _e
function rnd_rng(_s,_e)
	return f_rnd(_e-_s+1)+_s
end

function d6()
	return rnd_rng(1,6)
end


--array arithmatic
function int_to_arr(n)
 local r={}
 -- handle 0
 if n==0 then
  return {0}
 end
 -- extract digits from right to left
 while n>0 do
  add(r,n%10)
  n=flr(n/10)
 end
 -- reverse the array
 for i=1,#r\2 do
  r[i],r[#r-i+1]=r[#r-i+1],r[i]
 end

 return r
end


function arr_display(_arr)
	anum=""
	if _arr then
		for i=1,#_arr do
			anum=anum.._arr[i]
		end
	end
	return anum
end

function arr_add(a,b)
	local r={} --result array and carry value
	local c=0 --carry variable
	--start at the rightmost digit
	local i=#a
	local j=#b
	--work from right to left
	while i>0 or j>0 do
		--add the two digits plus any carry
		local n=(a[i] or 0)+(b[j] or 0)+c
		--store the ones digit
		add(r,n%10)
		--calculate the carry for the next digit
		c=flr(n/10)
		--move to the next digits
		i-=1
		j-=1
	end
	--add any remaining carry
	if c>0 then add(r,c) end
	--digits were added right-to-left,
	--so reverse the result to normal order
	for i=1,#r\2 do
	r[i],r[#r-i+1]=r[#r-i+1],r[i]
	end
	return r
end

function arr_mult(a,b)
	local r={} --result array
	--create enough space for the result
	for i=1,#a+#b do
		r[i]=0
	end
	--multiply each digit by every digit
	--starting from the right
	for i=#a,1,-1 do
		for j=#b,1,-1 do
			local p=i+j
			--add the product to the correct position
			r[p]+=a[i]*b[j]
		end
	end
	--handle carries from right to left
	for i=#r,2,-1 do
		r[i-1]+=flr(r[i]/10)
		r[i]%=10
	end
	--remove leading zeroes
	while #r>1 and r[1]==0 do
		deli(r,1)
	end
	return r
end

function arr_sub(a,b)--subtraction
 -- result array
 local r={}
 local borrow=0
 local i=#a
 local j=#b
 -- subtract digits from right to left
 while i>0 do
  -- subtract the two digits and any borrow
  local n=a[i]-(b[j] or 0)-borrow
  -- borrow from the next digit if needed
  if n<0 then
   n+=10
   borrow=1
  else
   borrow=0
  end
  -- store the result digit
  add(r,n)
  -- move to the next digits
  i-=1
  j-=1
 end
 -- digits were calculated right-to-left,
 -- so reverse the result
 for i=1,#r\2 do
  r[i],r[#r-i+1]=r[#r-i+1],r[i]
 end
 -- remove leading zeroes
 while #r>1 and r[1]==0 do
  deli(r,1)
 end

 return r
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000003bbb1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000003bbbbb100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00003bbb10bb10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003bbbb100be8000000ddd0000ddd00b3310000b331000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bbbbbb1008800000d000d00d000d00b3310000b33100000000000000000000000000000000000000000000000000000000000000000000000000000000000
03bbbbbbbb10000000dc100000dc10000b3331000b33310000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbbbbbbbbb100000ecccc10ccccc100b33333003333310000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbbf4bbf4bb1000ecccccccccccc100b33333333333310000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbbf4bbf4bb1000eccc65ccc65cc1000b33f4333f43100000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbbbbe8bbbb10000ecc65ccc65c1000b333f4333f43310000000000000000000000000000000000000000000000000000000000000000000000000000000000
03bbbb888bbb10000ecccccccccc1000b33333333333310000000000000000000000000000000000000000000000000000000000000000000000000000000000
03bbbb888bb100000ecccccc6ccc1000b33333333633310000000000000000000000000000000000000000000000000000000000000000000000000000000000
03bbbbbbbbb100000ecccccccccc10000b3333666333100000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bbbb66b10000000ecccccccc1000000b333333331000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003bbbbb1000000000eccccc1000000000b33333310000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000047047000055555000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000028000000000000004444400040740700555551500000000600000000000000000000000000000000000000000000000006660000006660000000000
00000000222800001555dd008444114004704070085cc51500000000066666600000000000000000000000000000000000000000006600000000660000000000
1cccdd005222222d855566d00499441404004700085dd51541008550066556c60000000000000000000000000000000000000000555666666666655500000000
8cc66cd022e2e2001566555084449440084595440555551544ccc5550866666c0000000000000000000000000000000000000000555666600666655500000000
1c6ccccc5222222d005555000444440004944940005555500000855506d666d60000000000000000000000000000000000000000555666000066655500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
840000000cdccc700000000c86330000002828280000999a0000aa00000000000000000000000000000000000000000000000000000000000000000000000000
044494d000cddcc70cc00cc00b6bb0300002888009ac9000089999a000ccc0000000000000000000000000000000000000000000000000000000000000000000
0494444400ccc6ccccccccd03393932300028cc09996c99a9999cc9a066666000000000000000000000000000000000000000000000000000000000000000000
840050000cc06000cc6cc6c0bbbbbbbb000288808aa96000089999a06757d7600000000000000000000000000000000000000000000000000000000000000000
00000550cc0000008668660003003000002828280000999a0000aa00066666000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01000000060000008200000000000000100010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17100000616000002828080000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17710000611600000082828000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17771000611160000082828200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17777100611116008288888200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17711000611660002888882000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01171000066160000288882000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000022220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00222282000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000820000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000c33c0000000000002e220000333300000000000000031000000000000000000000000000000000
0000000000000000000000000000000000000000000000000cc6cc60000066500228285003bab350000000000000031000000000000000000000000000000000
000000000000000000000000000000000000000000000000c3ccc3c606506d5022822285333ba3350066600031663100009a9500000000000000000000000000
000000000000000000000000000000000000000000000000c3cc33c60d5055002e2228e53b3b33b5060006003313160009a9a950000000000000000000000000
000000000000000000000000000000000000000000000000c36c36c600000065822e82253ba3bab5060006000333160009a99950000000000000000000000000
000000000000000000000000000000000000000000000000c33cccc600d650008228228533b33b35060006000631060009a9a950000000000000000000000000
0000000000000000000000000000000000000000000000000ccc33600065065002822e50033333500066600000666000009a9500000000000000000000000000
00000000000000000000000000000000000000000000000000666600000000000055550000555500000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000077777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000077777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000090500105001050020500305006050080500b0500e0501205015050190501d0501e0501f0502105023050250500000000000000000000000000000000000000000000000000000000000000000000000
