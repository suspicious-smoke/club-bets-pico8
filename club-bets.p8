pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--galaxy club bets
--by olivander65
function _init()
	version,t=0,0
	debug={"","","",""}

	arena_category={
		"movement",
		"obstacle",
		"powerup",
		"weather",
		"terrain",
		"ship-mod",
		"event",
		"section",
		"physics",
		"visibility",
		"condition",
		"hazard"
	}
	arena_features={
		{"hairpin",{1,2}},
		{"u-turn",{1,2}},
		{"long_straight",{1}},
		{"jump",{1,9}},
		{"lava_pit",{2,12}},
		{"spike_trap",{2,12}},
		{"falling_rocks",{2,7}},
		{"boost_pad",{3,1}},
		{"oil_slick",{3,11}},
		{"cannon_shot",{3,12}},
		{"rain",{4,11}},
		{"high_wind",{4,9}},
		{"extreme_heat",{4,12}},
		{"off-road",{5,11}},
		{"ice",{5,11}},
		{"glass",{5,11}},
		{"extra_boosters",{6,1}},
		{"glider",{6,9}},
		{"meteor_shower",{7,12}},
		{"kaiju_attack",{7,12}},
		{"wormhole",{7,9}},
		{"castle",{8,5}},
		{"crystal_caves",{8,10}},
		{"volcano",{8,4}},
		{"zero-g",{9,1}},
		{"reverse_gravity",{9,1}},
		{"darkness",{10}},
		{"fog",{10,4}},
		{"narrow_path",{11,1}},
		{"crumbling_track",{11,2}},
		{"electric_field",{12,9}},
		{"fire",{12,4}},
	}

	--build initial bets
	--a single bet for example is bet={amount(4char array), { {t,f,f,f},... }} 
	-- where { {t,f,f,f},... } is the arenas and selected players
	bets={}
	for i=1,10 do
		local _bet={{0,1,0,0},{}}
		for j=1,4 do
			local _selected_player={false,false,false,false}
			add(_bet[2],_selected_player)	
		end
		add(bets,_bet)
	end

	--{name,abreiv,base,{strengths category},weakness category}
	players={
    {"bosco","bco",10,{1,3},8},
    {"admiral","adm",11,{1,4},10},
    {"dexter","dxt",12,{2,7,12},5},
    {"pontoon","ptn",14,{4,8},2},
    {"sailer","slr",15,{5},7},
    {"bucket","bkt",16,{6},11},
    {"pod eng","pde",17,{1,6,9},10},
    {"merchant","mch",10,{2,3},8},
    {"scuttle","sct",11,{4,9},6},
    {"beluga","blg",12,{9},3},
    {"ant","ant",13,{10},5},
    {"turtle","trt",14,{2,11},4},
    {"beholder","bhd",15,{9},1},
    {"trident","trd",16,{12},6},
    {"kingshot","kng",17,{8},5},
    {"ufo","ufo",13,{1},4},
}
	arenas={}
	arena_features={}
	odds={}
	bet_odds={}
	money={1,0,0,0}
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
	init_betpage()
	--init_confirm()
end

function dummy_bets()
	for i_bet=1,10 do
		for i_arena=1,4 do
			_r=rnd_rng(1,5)
			if _r!= 5 then
				bets[i_bet][2][i_arena][_r]=true
			end
		end
	end
end


function blank() end

function _update()
	t+=1
	_upd()
	
	--update_fx()--particles
end

function reset_num_array(_size,_items,_val)
	_num_arr={}
	for i=1,_size do
		add(_num_arr,reset_array(_items,_val))
	end
	return _num_arr
end

function reset_array(_items,_val)
	_arr={}
	for i=1,_items do
		add(_arr,_val)
	end
	return _arr
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
	_bet_amt_tmr,bet_off=0,0
	plyr_menu_sel=1
	
	bet_mode=1--main,plyr sel,amt sel
	i_amt=1
	_upd=upd_betpage
	_drw=drw_betpage
end

function upd_betpage()
	get_bet_summary()
	--player select mode
	if bet_mode==2 then
		if btnp(⬆️) then
			plyr_menu_sel=(plyr_menu_sel-2)%4+1
		elseif btnp(⬇️) then
			plyr_menu_sel=(plyr_menu_sel%4)+1
		elseif btnp(🅾️) then
			toggle_bet()
			bet_mode=1
		elseif btnp(❎) then
			bet_mode=1
		end
	--bet select mode
	elseif bet_mode==3 then
		if btnp(⬆️) then
			bets[bet_sel][1][i_amt]=(bets[bet_sel][1][i_amt]+1)%10
		elseif btnp(⬇️) then
			bets[bet_sel][1][i_amt]=(bets[bet_sel][1][i_amt]-1)%10
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
	print("round:#",4,3+bet_off,6)	
	print("bet:#"..bet_sel,52,3+bet_off,6+3*bet_off)	
	spr(108,85,1+bet_off)--coin
	print(arr_to_str(money,true),94,3+bet_off,9)
	rrectfill(4,10+bet_off,120,74,0,7)--ticket
	rrect(3,9+bet_off,122,75,0,1)--outline
	rrectfill(4,10+bet_off,120,9,0,2)--red area
	print("place a bet",42,12+bet_off,7)
	rrectfill(4,20+bet_off,120,8,0,5)--grey area
	line(3,19+bet_off,124,19+bet_off,1)--hline
	line(39,19+bet_off,39,83+bet_off,1)--vline
	print("arena",12,21+bet_off,0)
	print("player",72,21+bet_off,0)
	--arenas
	for i_arena=1,4 do
		line(3,13+i_arena*14+bet_off,124,13+i_arena*14+bet_off,1)
		rrectfill(42,16+i_arena*14+bet_off,80,9,1,6)
		if arena_sel==i_arena and bet_mode!=2 then
			rrect(42,16+i_arena*14+bet_off,80,9,1,9)
		end
		print(i_arena,18,18+i_arena*14+bet_off,0)
		spr(101+i_arena,27,16+i_arena*14+bet_off)--planet
		--get player
		chk_spr=106
		local plyr_str="who to bet on?"
		for i_aplyr=1,4 do 
			if bets[bet_sel][2][i_arena][i_aplyr] then
				plyr_str=get_player_string(i_arena,i_aplyr)
				chk_spr=107
			end
		end
		spr(chk_spr,8,16+i_arena*14+bet_off)--check mark
		print(plyr_str,52,18+i_arena*14+bet_off,0)
		spr(68,115,19+i_arena*14+bet_off)
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
	for a_plyr=1,4 do
		if plyr_menu_sel==a_plyr then
			rrectfill(44,20+arena_sel*14+a_plyr*9,76,9,1,5)	
		end
		print(get_player_string(arena_sel,a_plyr),52,22+arena_sel*14+a_plyr*9,0)
	end
end

function get_player_string(i_arena,i_aplyr)
	local arena_player=arenas[i_arena][i_aplyr]
	return players[arena_player[1]][1].." "..bet_colon_format(arena_player[2])..":1"
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
		print(bets[bet_sel][1][i] or 0,9+i*4,105,i_clr)
	end

	if arena_sel==5 then
		rrect(4,103,36,10,0,9)
	end
	line(40,94,40,112,1)--vline1
	print("odds",45,96,0)
	line(64,94,64,112,1)--vline2
	total_odds=print_bet_odds(bets_odds[bet_sel],true)
	print(total_odds,57-#total_odds*2,105,0)
	print("payout",83,96,0)
	_winnings=arr_to_str(bets_winnings[bet_sel])
	print(_winnings,94-#_winnings*2,105,0)
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
	get_bet_summary()
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
		end
	end
	if btnp(❎) then
		init_betpage()
	end
end

--confirm bet page
function drw_confirm()
	print("round:#",4,3-scroller,6)	
	
	spr(108,83,1-scroller)--coin
	print(arr_to_str(money,true),92,3-scroller,9)--my money
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
	bet_count=0
	p_count=1
	o_pcount=0
	for i_bet=1,10 do
		p_count=1
		_cbet_odds=1
		_cbet=bets[i_bet]
		print(i_bet,6,21+o_pcount-scroller+8,0)

		for i_arena=1,4 do
			for i_aplyr=1,4 do
				if _cbet[2][i_arena][i_aplyr] then
					spr(101+i_arena,19,12+p_count*9+o_pcount-scroller+8)--planet
					print(players[arenas[i_arena][i_aplyr][1]][1],28,14+p_count*9+o_pcount-scroller+8,0)--player name
					p_count+=1		
				end
			end
		end

		if p_count>1 then
			pc_mult=8
			if p_count==2 then
				pc_mult=9
			end
			rrect(3,19+o_pcount-scroller+8,122,p_count*pc_mult,0,1)
			_p_odds=print_bet_odds(bets_odds[i_bet])
			print(_p_odds,98-#_p_odds*2,30+o_pcount-scroller,0)
			winnings_str=arr_to_str(bets_winnings[i_bet])
			spr(108,90-#winnings_str*2,36+o_pcount-scroller)--coin
			print(winnings_str,98-#winnings_str*2,38+o_pcount-scroller,0)
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
	
	tw_str=arr_to_str(total_winnings)
	spr(108,96-#tw_str*2,32+o_pcount-scroller)--coin
	print(tw_str,104-#tw_str*2,34+o_pcount-scroller,0)

	-- spr(108,81,32+o_pcount-scroller)--coin
	-- for i=1,#total_winnings do
	-- 	print(total_winnings[i],86+i*4,34+o_pcount-scroller,0)
	-- end
	
	print("press 🅾️ to confirm",28,50+o_pcount-scroller,7)
end

-->8
--quick bet page

function init_quickbetpage()
	bet_sel=1--1-10
	plyr_menu_sel=1--select player for each arena 1-16
	total_odds=0
	total_pay=0
	_upd=upd_quickbetpage
	_drw=drw_quickbetpage
end

function upd_quickbetpage()
	get_bet_summary()
	if btnp(➡️) then
		bet_sel=(bet_sel%10)+1
	elseif btnp(⬅️) then
		bet_sel=(bet_sel-2)%10+1

	elseif btnp(⬆️) then
		if plyr_menu_sel==1 then
			arena_sel=(arena_sel-2)%4+1
		end
		plyr_menu_sel=(plyr_menu_sel-2)%4+1
	elseif btnp(⬇️) then
		if plyr_menu_sel==4 then
			arena_sel=(arena_sel%4)+1
		end
		plyr_menu_sel=(plyr_menu_sel%4)+1
	elseif btnp(🅾️) then
		toggle_bet()
	elseif btnp(❎) then
		--open up window to see
		--more info or switch menus
	end
end

function drw_quickbetpage()
	local arena_clr={1,4,2,3}--arena text colors
	g_off=0--space between arenas

	for i_arena=1,4 do
		for i_aplyr=1,4 do
			_py=((i_arena-1)*4+i_aplyr)*7+g_off
			rrectfill(1,_py-6,126,7,0,6+i_aplyr%2)--row background
			local a_plyr=arenas[i_arena][i_aplyr]
			print(players[a_plyr[1]][2].." "..bet_colon_format(a_plyr[2])..":1",3,_py-5,arena_clr[i_arena])
			--bet buttons
			for k=1,10 do
				bet_clr=5
				--bet is checked
				if bets[k][2][i_arena][i_aplyr] then
					bet_clr=3
				end
				--bet selected
				if bet_sel==k and plyr_menu_sel==i_aplyr and arena_sel==i_arena then
					print("\f7\^oc5a●",29+k*9,_py-5)
				end
				print("●",29+k*9,_py-5,bet_clr)
			end
		end
		g_off+=2
	end
	--bet selector
	rrect(28+bet_sel*9,0,9,120,0,12)
	--info area
	rrectfill(1,120,126,7,0,5)
	print("bet \f9#"..bet_sel,2,121,7)
	line(31,120,31,126,8)
	print(bets_odds[bet_sel]..":1",34,121,7)
	line(55,120,55,126,8)
	spr(108,57,119)--coin
	print(arr_to_str(bets[bet_sel][1],true),64,121,9)
	line(81,120,81,126,8)
	spr(108,83,119)--coin
	print(arr_to_str(bets_winnings[bet_sel]),90,121,9)
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
	--each of 4 arenas looks like arena={p_id,p_odds}
	for i_arena=1,4 do
		for i_a_player=1,4 do
			local _arena=arenas[i_arena]
			local _plyr_id=_arena[i_a_player][1]
			local total_prob=0
			p_base=players[_plyr_id][3]
			for die=3,18 do
				local p_prob=d6x3[die]
				local p_score=p_base+die
				--we have our die roll
				--opponent probabilities
				for _copp=1,4 do
					local _opp_id=_arena[_copp][1]
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
			_arena[i_a_player][2]=ceil(total_prob*100)
		end
	end
end

function fill_arenas()
	arenas={{},{},{},{}}
	arena_features={{},{},{},{}}
	--array of 1,2,...,16 for random players
	local _rplrs={}
	for i=1,16 do
		add(_rplrs,i)
	end
	i_arena=1
	--fill players in arenas
	for i=1,16 do
		local _rp=rnd(_rplrs)
		add(arenas[i_arena],{_rp})
		del(_rplrs,_rp)
		if i%4==0 then--next arena
			i_arena+=1
		end 
	end
	--give each arena 8 items
	local _rnd_features={}
	for i=1,32 do
		add(_rnd_features,i)
	end
	for i_arena=1,4 do
		for i_feature=1,8 do
			local _rnd_feature=rnd(_rnd_features)
			add(arena_features[i_arena],_rnd_feature)
			del(_rnd_features,_rnd_feature)
		end
	end

	calculate_odds()
end

function get_player_mods()
	--get player base

	for i_arena=1,4 do
		for i_a_player=1,4 do
			local _arena=arenas[i_arena]
			local _plyr_id=_arena[i_a_player][1]
			local p_mod=players[_plyr_id][3]

			for i_feature=1,8 do
				--plus for str, minus for weakness
				local p_strs=players[_plyr_id][4]
				for stri=1,#p_strs do
					arenafeature=arena_features[i_feature][2]
					for afi=1,#arenafeature do
						if p_strs[stri]==arenafeature[afi] then
							p_mod+=1
						elseif players[_plyr_id][5]==arenafeature[afi]--weakness
							p_mod-=1
						end
					end
					
				end
			end
		end
	end
end

--turns percentage into number x used in x:1 format.
function bet_colon_format(_bet_perc)
	local _percs={40,30,25,20,15,10,7, 5, 3, 4, 0}
	local _podds={2, 3, 4, 5, 6, 7, 8,10,11,12,13}
	for i=1,#_percs do
		if _bet_perc>=_percs[i] then
			return add(bet_odds,_podds[i])
		end
	end
end

--gets odds and winnings for each bet and total payout
function get_bet_summary()
	--global summary arrays to use elsewhere
	bets_odds=reset_array(10,1)--array follows the bet_id
	bets_winnings=reset_array(10,7,0)
	total_winnings={0}
	--get bets and odds
	for i_bet=1,10 do
		_bet_arena=bets[i_bet][2]
		for i_arena=1,4 do
			for i_aplyr=1,4 do
				if _bet_arena[i_arena][i_aplyr] then
					bets_odds[i_bet]*=bet_colon_format(arenas[i_arena][i_aplyr][2])
				end
			end
		end
		bets_odds[i_bet]=min(bets_odds[i_bet],999)--clamp bets_odds
		bets_winnings[i_bet]=arr_mult(int_to_arr(bets_odds[i_bet]),bets[i_bet][1])
		if #bets_winnings[i_bet] >= 7 then
			bets_winnings[bet_sel]={1,0,0,0,0,0,0}
		end
	end
	--calculate total payout
	for i_bet=1,10 do
		total_winnings=arr_add(total_winnings,bets_winnings[i_bet])
	end
end

function toggle_bet()
	--toggle bet if already selected
	if bets[bet_sel][2][arena_sel][plyr_menu_sel] then
		bets[bet_sel][2][arena_sel][plyr_menu_sel]=false
		return
	end
	--turn off other bets
	for i_plyr=1,4 do
		bets[bet_sel][2][arena_sel][i_plyr]=false
	end
	bets[bet_sel][2][arena_sel][plyr_menu_sel]=true
end

function print_bet_odds(_odds,dynamic_color)
	local return_str=""
	if dynamic_color then
		return_str="\f9"
		if _odds==999 then
			return_str="\f8"
		end
	end
	str_odds=tostr(_odds)
	return_str=return_str..str_odds..":1"
	return return_str
end



function run_race()
	
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

--_0clean means get ride of leading zero when printing. Defaults to false.
function arr_to_str(_arr,_0clean)
	anum=""
	if _arr then
		leading_zero=true
		for i=1,#_arr do
			if leading_zero and _0clean then
				if _arr[i]!=0 then
					anum=anum.._arr[i]
					leading_zero=false
				end
			else
				anum=anum.._arr[i]
			end
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006660000006660000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006600000000660000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555666666666655500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555666600666655500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555666000066655500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000470470000555550000000000000000000000000cc000000000000000000000000000000000000000000000000000000
0000000002800000000000000444440004074070055555150000000060000000840000000cdccc700000000c86330000002828280000999a0000aa0000000000
00000000222800001555dd008444114004704070085cc5150000000006666660044494d000cddcc70cc00cc00b6bb0300002888009ac9000089999a000ccc000
1cccdd005222222d855566d00499441404004700085dd51541008550066556c60494444400ccc6ccccccccd03393932300028cc09996c99a9999cc9a06666600
8cc66cd022e2e2001566555084449440084595440555551544ccc5550866666c840050000cc06000cc6cc6c0bbbbbbbb000288808aa96000089999a06757d760
1c6ccccc5222222d005555000444440004944940005555500000855506d666d600000550cc0000008668660003003000002828280000999a0000aa0006666600
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
