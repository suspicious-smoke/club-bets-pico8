pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--galaxy club bets
--by olivander65
function _init()
	version,t=0,0
	debug={"","","",""}
	category={
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
	features={
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
	round_features={{},{},{},{}}--ids of arena features for current round
	round_winners={}
	--build initial bets
	--a single bet for example is bet={amount(4char array), { {t,f,f,f},... }} 
	-- where { {t,f,f,f},... } is the arenas and selected players

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
	init_ticket()
	--init_betpage()
	--calculate_winners()
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
				sfx(0)
			plyr_menu_sel=(plyr_menu_sel-2)%4+1
		elseif btnp(⬇️) then
			sfx(0)
			plyr_menu_sel=(plyr_menu_sel%4)+1
		elseif btnp(🅾️) then
			sfx(4)
			toggle_bet()
			bet_mode=1
		elseif btnp(❎) then
			sfx(3)
			bet_mode=1
		end
	--money amount mode
	elseif bet_mode==3 then
		if btnp(⬆️) then
			sfx(0)
			bets[bet_sel][1][i_amt]=(bets[bet_sel][1][i_amt]+1)%10			
		elseif btnp(⬇️) then
			sfx(0)
			bets[bet_sel][1][i_amt]=(bets[bet_sel][1][i_amt]-1)%10
		elseif btnp(➡️) then
			sfx(0)
			i_amt=(i_amt%4)+1
		elseif btnp(⬅️) then
			sfx(0)
			i_amt=(i_amt-2)%4+1
		elseif btnp(❎) then
			sfx(3)
			bet_mode=1
		end
	else
		if btnp(⬆️) then
			sfx(0)
			arena_sel=(arena_sel-2)%6+1
		elseif btnp(⬇️) then
			sfx(0)
			arena_sel=(arena_sel%6)+1
		elseif btnp(➡️) then
			sfx(1)
			_bet_amt_tmr=10
			bet_sel=(bet_sel%10)+1
		elseif btnp(⬅️) then
			sfx(1)
			_bet_amt_tmr=10
			bet_sel=(bet_sel-2)%10+1
		elseif btnp(🅾️) then
			if arena_sel==6 then
				sfx(4)
				init_confirm()
			elseif arena_sel==5 then
				--change money
				sfx(2)
				i_amt=1
				bet_mode=3
			else
				sfx(2)
				bet_mode=2--player sel
				plyr_menu_sel=1
			end
		elseif btnp(❎) then
			sfx(3)
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
				plyr_str="  "..get_player_string(i_arena,i_aplyr)
				spr(47+arenas[i_arena][i_aplyr][1],48,16+i_arena*14+bet_off)--ship spr
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
		print("  "..get_player_string(arena_sel,a_plyr),52,22+arena_sel*14+a_plyr*9,0)
		spr(47+arenas[arena_sel][a_plyr][1],48,20+arena_sel*14+a_plyr*9)
	end
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
		--digit selection colors
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
	o_pcount=0
	bet_title="current bets"
	get_bet_summary()
	show_winners=false
	get_bet_costs()
	prep_draw_bet_summary()
	has_money=arr_greater_equal(money,total_bet)
	made_bets=arr_to_str(total_winnings)!="0"
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
	elseif btnp(🅾️) then
		if has_money and made_bets then
			init_end_of_round()
		end
	end
end

function get_bet_costs()
	total_bet={}
	for i_bet=1,10 do
		has_bet=false
		for i_arena=1,4 do
			for i_plyr=1,4 do
				if bets[i_bet][2][i_arena][i_plyr] then
					has_bet=true
				end
			end
		end
		if has_bet then
			total_bet=arr_add(total_bet,bets[i_bet][1])
		end
	end
	return total_bet
end

--confirm bet page
function drw_confirm()
	draw_bet_summary()
	--total winnings box
	rrectfill(3,27+o_pcount-scroller,122,20,0,7)--ticket
	rrect(3,27+o_pcount-scroller,122,20,0,1)--ticket
	print("possible winnings",10,34+o_pcount-scroller,0)
	line(79,27+o_pcount-scroller,79,46+o_pcount-scroller,1)
	tw_str=arr_to_str(total_winnings)
	spr(108,96-#tw_str*2,32+o_pcount-scroller)--coin
	print(tw_str,104-#tw_str*2,34+o_pcount-scroller,0)
	if not has_money then
		print("not enough cash. press ❎",16,50+o_pcount-scroller,8)
	elseif not made_bets then
		print("no bets placed. press ❎",18,50+o_pcount-scroller,8)
	else
		print("press 🅾️ to confirm",28,50+o_pcount-scroller,7)
	end
end

function prep_draw_bet_summary()
	bet_offsets=reset_array(10,0)
	o_pcount=0--old_player_count
	for i_bet=1,10 do
		p_count=1
		_cbet=bets[i_bet]
		if show_winners==false or (show_winners==true and is_winning_bet(_cbet)) then
			for i_arena=1,4 do
				for i_aplyr=1,4 do
					if _cbet[2][i_arena][i_aplyr] then
						p_count+=1		
					end
				end
			end
			if p_count>1 then
				pc_mult=8
				if p_count==2 then
					pc_mult=9
				end
				bet_offsets[i_bet]=o_pcount
				o_pcount+=p_count*pc_mult-1--next bets bet_offset
			end
		end
	end
	max_scroll=o_pcount-60
end

function draw_bet_summary()
	print("round:#",4,3-scroller,6)	
	spr(108,83,1-scroller)--coin
	print(arr_to_str(money,true),92,3-scroller,9)--my money
	rrectfill(4,10-scroller,120,max_scroll+97,0,7)--ticket
	rrect(3,9-scroller,122,10,0,1)--outline
	rrectfill(4,10-scroller,120,9,0,2)--red area

	print(bet_title,hcenter(bet_title),12-scroller,7)
	rrectfill(4,20-scroller,120,8,0,5)--grey area
	rrect(3,19-scroller,122,9,0,1)--grey outline

	print("bet",5,21-scroller,0)
	line(17,20-scroller,17,max_scroll+106-scroller,1)--bet/player v-line
	print("player",31,21-scroller,0)
	line(70,20-scroller,70,max_scroll+106-scroller,1)--end plyr line
	print("odds/winnings",72,21-scroller,0)
	for i_bet=1,10 do
		p_count=1
		_cbet=bets[i_bet]
		if show_winners==false or (show_winners==true and is_winning_bet(_cbet)) then
			local _offy=bet_offsets[i_bet]-scroller
			--draw players from bet
			for i_arena=1,4 do
				for i_aplyr=1,4 do
					if _cbet[2][i_arena][i_aplyr] then
						spr(101+i_arena,19,12+p_count*9+_offy+8)--planet
						print(players[arenas[i_arena][i_aplyr][1]][1],28,14+p_count*9+_offy+8,0)--player name
						p_count+=1		
					end
				end
			end

			if p_count>1 then
				print(i_bet,6,21+_offy+8,0)
				pc_mult=8
				if p_count==2 then
					pc_mult=9
				end
				rrect(3,19+_offy+8,122,p_count*pc_mult,0,1)
				_p_odds=print_bet_odds(bets_odds[i_bet])
				print(_p_odds,98-#_p_odds*2,30+_offy,0)
				winnings_str=arr_to_str(bets_winnings[i_bet])
				spr(108,90-#winnings_str*2,36+_offy)--coin
				print(winnings_str,98-#winnings_str*2,38+_offy,0)
			end
		end
	end
end

function init_end_of_round()
	calculate_winners()
		--pay for bets
	money=arr_sub(money,total_bet)
	_upd=upd_end_of_round
	_drw=drw_end_of_round
end

function upd_end_of_round()
	if btnp(🅾️) then
		--winnings page
		init_winning_bets()
	end
end

function drw_end_of_round()
	print("winners",hcenter("winners"),10,7)
	for i_arena=1,4 do
		local w_pid=arenas[i_arena][round_winners[i_arena]][1]
		spr(101+i_arena,30,16+i_arena*10)--planet
		spr(47+w_pid,40,16+i_arena*10)
		print(get_player_string(i_arena,round_winners[i_arena]),50,17+i_arena*10)
	end
end

function init_winning_bets()
	scroller=0
	max_scroll=0
	o_pcount=0
	bet_title="collect winnings"
	get_bet_summary()	
	get_winning_cash()
	show_winners=true
	prep_draw_bet_summary()
	_upd=upd_winning_bets
	_drw=drw_winning_bets
end

function upd_winning_bets()
	if max_scroll>0 then
		if btn(⬇️) then
			scroller=min(scroller+7,max_scroll)
		elseif btn(⬆️) then
			scroller=max(scroller-7,0)
		end
	end
	if btnp(🅾️) then
		finish_round()
	end
end

function drw_winning_bets()
	draw_bet_summary()
	--total winnings box
	rrectfill(3,27+o_pcount-scroller,122,20,0,7)--ticket
	rrect(3,27+o_pcount-scroller,122,20,0,1)--ticket
	print("winnings",45,34+o_pcount-scroller,0)
	line(79,27+o_pcount-scroller,79,46+o_pcount-scroller,1)
	tw_str=arr_to_str(winning_cash,true)
	if #tw_str==0 then
		tw_str="0"
	end
	spr(108,96-#tw_str*2,32+o_pcount-scroller)--coin
	print(tw_str,104-#tw_str*2,34+o_pcount-scroller,0)
	print("press 🅾️ to continue",25,50+o_pcount-scroller,7)
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
			print(players[a_plyr[1]][2].." "..a_plyr[4]..":1",3,_py-5,arena_clr[i_arena])
			-- print(a_plyr[4]..":1",14,_py-5,arena_clr[i_arena])
			-- spr(47+a_plyr[1],3,_py-7)--ship spr
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
	tx={}
	ty={}
	for i=1,1 do
		tx[i]=i*5
		ty[i]=9+i
	end
	

	get_bet_summary()
	get_bet_costs()
	prep_draw_bet_summary()

	_upd=upd_ticket
	_drw=drw_ticket
end

function upd_ticket()
	
end

function drw_ticket()
	for i_bet=1,#tx do
		local _tx,_ty=tx[i_bet],ty[i_bet]
		--ticket
		rrect(_tx-5+5,_ty-1,3,1,0,5)--shadow
		for i=1,15 do
			rrect(_tx-5+6*i,_ty-1,3,1,0,7)
		end
		rrectfill(_tx-1,_ty,90,81,0,5)--shadow
		rrectfill(_tx,_ty,90,81,0,7)--ticket
		rrectfill(_tx+6,_ty+81,84,24,0,7)--lwr ticket
		spr(128,_tx-2,_ty+81,1,3)--left leaf
		spr(129,_tx+89,_ty+81,1,3)--right leaf
		for i=1,3 do
			_wmoff=0
			if i==3 then
				_wmoff=1
			end
			print("★galaxy club★",_tx+15,_ty-13+i*32+_wmoff,6)	
		end
		--text
		rrectfill(_tx+2,_ty+2,86,10,0,2)--red area
		print("★galaxy club bets★",_tx+5,_ty+5,7)
		print("round #1784",_tx+22,_ty+15,0)
		print("----------------------",_tx+2,_ty+22,0)
		print("arena",_tx+2,_ty+28,0)
		print("player",_tx+30,_ty+28,0)
		print("odds",_tx+66,_ty+28,0)
		print("----------------------",_tx+2,_ty+35,0)
		p_count=1
		for i_arena=1,4 do
			for i_aplyr=1,4 do
				if bets[i_bet][2][i_arena][i_aplyr] then
					print(i_arena,_tx+10,_ty+34+8*p_count,0)
					local arena_player=arenas[i_arena][i_aplyr]
					print(players[arena_player[1]][1],_tx+26,_ty+34+8*p_count,0)
					print(arena_player[4]..":1",_tx+66,_ty+34+8*p_count,0)
					p_count+=1		
				end
			end
		end
		print("----------------------",_tx+3,_ty+80,0)
		print("bet",_tx+6,_ty+85)
		print(arr_to_str(bets[i_bet][1],true),_tx+22,_ty+85,0)
		print("odds",_tx+46,_ty+85)
		print(print_bet_odds(bets_odds[i_bet]),_tx+66,_ty+85,0)
		print("payout ",_tx+8,_ty+94)
		print(arr_to_str(bets_winnings[i_bet]),_tx+38,_ty+94,0)
	end
end

-->8
--calculations
function calculate_odds()
	--each of 4 arenas looks like arena={p_id,p_odds}
	for i_arena=1,4 do
		for i_a_player=1,4 do
			local _arena=arenas[i_arena]
			local _arena_plyr=_arena[i_a_player]
			local total_prob=0
			for die=3,18 do
				local p_prob=d6x3[die]
				local p_score=_arena_plyr[2]+_arena_plyr[3]+die--base+p_mod
				--we have our die roll
				--opponent probabilities
				for _copp=1,4 do
					local _opp_id=_arena[_copp][1]
					if _opp_id!=_arena_plyr[1] then
						local o_prob=0
						for o_die=3,18 do
							--get player scores that beat opponent's score
							if _arena[_copp][2]+_arena[_copp][3]+o_die<p_score then
								o_prob+=d6x3[o_die]
							end
						end
						--multiply opponent prob to player prob
						p_prob=p_prob*o_prob
					end 
				end
				total_prob+=p_prob
			end
			local col_format=bet_colon_format(ceil(total_prob*100))
			_arena[i_a_player][4]=col_format
		end
	end
end

function fill_arenas()
	arenas={{},{},{},{}}
	round_features={{},{},{},{}}
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
			add(round_features[i_arena],_rnd_feature)
			del(_rnd_features,_rnd_feature)
		end
	end
	reset_bets()
	get_player_mods()
	calculate_odds()
end

function get_player_mods()
	--get player base
	for i_arena=1,4 do
		for i_a_player=1,4 do
			local _plyr_id=arenas[i_arena][i_a_player][1]
			local p_mod=0
			for feature_index=1,8 do
				--get categories for feature
				categories=features[round_features[i_arena][feature_index]][2]
				for c=1,#categories do
					--for each category, see if the player has them as a strength/weakness
					if players[_plyr_id][5]==categories[c] then--weakness check
						p_mod-=1
					end
					local strengths=players[_plyr_id][4]--strengths
					for s_i=1,#strengths do
						if strengths[s_i]==categories[c] then
							p_mod+=1
						end
					end
				end
			end
			--add to arena info
			arenas[i_arena][i_a_player][2]=players[_plyr_id][3]--base
			arenas[i_arena][i_a_player][3]=p_mod
		end
	end
end

function reset_bets()
	bets={}
	for i=1,10 do
		local _bet={{0,1,0,0},{}}
		for j=1,4 do
			local _selected_player={false,false,false,false}
			add(_bet[2],_selected_player)	
		end
		add(bets,_bet)
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
					bets_odds[i_bet]*=arenas[i_arena][i_aplyr][4]
				end
			end
		end
		bets_odds[i_bet]=min(bets_odds[i_bet],999)--clamp bets_odds
		if bets_odds[i_bet]==1 then
			bets_odds[i_bet]=0
		end
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
	if str_odds=="0" then return "" end
	return_str=return_str..str_odds..":1"
	return return_str
end

function get_player_string(i_arena,i_aplyr)
	local arena_player=arenas[i_arena][i_aplyr]
	return players[arena_player[1]][1].." "..arena_player[4]..":1"
end

function calculate_winners()
	round_winners={}
	for i_arena=1,4 do
		scores={}
		for i_a_player=1,4 do
			local _arena_plyr=arenas[i_arena][i_a_player]
			local p_score=_arena_plyr[2]+_arena_plyr[3]+explode_d6()+explode_d6()+explode_d6()
			add(scores,p_score)
		end
		_rwinner=1
		for s=1,4 do
			if scores[s]==scores[_rwinner] then
				if d6()>3 then--roll to beat ties
					_rwinner=s
				end
			elseif scores[s]>scores[_rwinner] then
				_rwinner=s
			end
		end
		round_winners[i_arena]=_rwinner
	end
end

function is_winning_bet(_bet)
	for i_arena=1,4 do
		for i_plyr=1,4 do
			if _bet[2][i_arena][i_plyr] then--player was bet on
				if i_plyr!=round_winners[i_arena] then
					return false
				end
			end
		end
	end
	return true
end

function get_winning_cash()
	winning_cash=reset_array(10,0)
	--debug[1]=round_winners[1].." "..round_winners[2].." "..round_winners[3].." "..round_winners[4]
	for i_bet=1,10 do
		_cbet=bets[i_bet]
		if is_winning_bet(_cbet) then
			winning_cash=arr_add(winning_cash,bets_winnings[i_bet])		
		end
	end
end

function finish_round()
	--give player winnings
	money=arr_add(winning_cash,money)
	winning_cash={}
	--refill arena
	fill_arenas()
	--start next bet round/bet page
	init_betpage()
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
	return total
end

function hcenter(s)
	return 64-#s*2
end

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
	if anum=="" then 
		anum="0"
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
		local n=a[i]-(j>0 and b[j] or 0)-borrow
		-- borrow from the next digit if needed
		if n<0 then
			n+=10
			borrow=1
		else
			borrow=0
		end
		add(r,n)
		i-=1
		j-=1
	end
	-- reverse result
	for i=1,#r\2 do
		r[i],r[#r-i+1]=r[#r-i+1],r[i]
	end
	-- remove leading zeroes
	while #r>1 and r[1]==0 do
		deli(r,1)
	end
	return r
end

function arr_greater_equal(a,b)--is a>=b?
	-- more digits means bigger number
	if #a>#b then
		return true
	elseif #a<#b then
		return false
	end
	-- same number of digits
	-- compare from left to right
	for i=1,#a do
		if a[i]>b[i] then
			return true
		elseif a[i]<b[i] then
			return false
		end
	end
	-- numbers are equal
	return true
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
00000000000000000000000000000000047047000ddddd00000000000000000000000000cc000000000000000000000000000000000000000000000000000000
0000000002b00000000000000444440004074070ddddd1d0000008d6d0000000840000000c1ccc700000000c86330000028282800000999a0000aa0000000000
00000000222b00001dddcc0084441140047040708dccd1d0490cccdd0dddddd0044494c000c11cc70cc00cc00b6bb0300028880009ac9000089999a000ccc000
1cccdd008222222d8ddd77c004994414040047008d66d1d044c000000dd22dcd0494444400ccc7cccccccce0339393230028cc009996c99a9999cc9a0ddddd00
8cc77cd0223232001d77ddd08444944008419144ddddd1d0000cccd608dddddc8400d0000cc07000ccdccdc0bbbbbbbb002888008aa96000089999a0d7e227d0
1c7ccccc8222222d00dddd0004444400049449400ddddd00000008dd0d1ddd1d00000dd0cc0000008dd8dd0003003000028282800000999a0000aa000ddddd00
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
00577777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00577777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00577777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00577777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00577777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00577777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00577777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00577777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00577777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00577777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00057777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00057777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00057777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00057777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00057777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00057777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00057777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00057777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000577777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000577777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000057777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000057777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0002000017050170502300022000170001e0001800015000100000b000160001400011000120000f0000c0000a0000d0000e0000c0000a0000d000100000e0000a00000000000000000000000000000000000000
000200001b05021050260501f05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002c4402744023440214001f4001b4001b4000e4001f400234001f4001c4001e400244001c4000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
000000000b4500d450104501245000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001e050200502205024050270502b0503105031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000090500105001050020500305006050080500b0500e0501205015050190501d0501e0501f0502105023050250500000000000000000000000000000000000000000000000000000000000000000000000
3606000008650086500a6500c6500d6500f650126501465017650196501c6501f650216502365026650286502a6502c6502d6502d6502b6502965026650216501b650126500d6500965006650056500365000650
__music__
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944
00 414a4944

