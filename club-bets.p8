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
	cur_round=1
	--build initial bets
	--a single bet for example is bet={amount(4char array), { {t,f,f,f},... }} 
	-- where { {t,f,f,f},... } is the arenas and selected players

	--{name,abreiv,base,{strengths category},weakness category}
	players={
    {"bosco","bco",10,{1,3},8},
    {"admiral","adm",11,{1,4},10},
    {"dexter","dxt",12,{2,7,12},5},
    {"pontoon","ptn",14,{4,8},2},
    {"sailor","slr",15,{5},7},
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
	fade_tmr,fade_state,fade_r=0,0,0

	--starfield
	starx={}
	stary={}
	starspd={}
	for i=1,100 do
		add(starx,flr(rnd(128)))
		add(stary,flr(rnd(128)))
		add(starspd,rnd(2)+0.5)		
	end
	effects={}
	--two flame effects
	f1c={8,9,10,5}--red effect
	f2c={7,6,6,5}--white to grey
	f3c={7,12,12,1}--blue flame

	_upd=blank
	_drw=blank
	fill_arenas()
	dummy_bets()
	--init_quickbetpage()
	--init_gameover()
	init_betpage()
	--calculate_winners()
	--init_confirm()
	--init_watch_race()
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
	drw_and_upd_fade()
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
	submenu_off,submenu_sel,qm_mode=0,1,1
	submenu_txts={"quick bet","copy bet amt","","","confirm bets"}
	bet_mode=1--main,plyr sel,amt sel
	i_amt=1
	_upd=upd_betpage
	_drw=drw_betpage
end

function upd_betpage()
	get_bet_summary()
	if bet_mode==1 then--main select mode
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
			--submenu
			sfx(3)
			submenu_sel=1
			bet_mode=4
		end
	elseif bet_mode==2 then--player select
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
			clear_arena_bet(bet_sel,arena_sel)
			bet_mode=1
		end
	elseif bet_mode==3 then--amount select
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
	elseif bet_mode==4 then--submenu
		submenu_mode()
	end
	if bet_mode!=4 and submenu_off>0 then
		submenu_off=max(submenu_off-10,0)
	end
	bet_off=0
	if _bet_amt_tmr>0 then
		_bet_amt_tmr-=1
		bet_off=-1
	end
end

function drw_betpage()
	print("round:#"..cur_round,4,3+bet_off,6)	
	print("bet:#"..bet_sel,52,3+bet_off,6+3*bet_off)	
	spr(37,85,1+bet_off)--coin
	print(arr_to_str(money,true),94,3+bet_off,9)
	brdr_rect(3,9+bet_off,122,75,0,7,1)
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
		if arena_sel==i_arena and bet_mode==1 then
			rrect(42,16+i_arena*14+bet_off,80,9,1,9)
		end
		print(i_arena,18,18+i_arena*14+bet_off,0)
		spr(32+i_arena,27,16+i_arena*14+bet_off)--planet
		--get player
		chk_spr=38
		local plyr_str="who to bet on?"
		for i_aplyr=1,4 do 
			if bets[bet_sel][2][i_arena][i_aplyr] then
				plyr_str="  "..get_player_string(i_arena,i_aplyr)
				spr(47+arenas[i_arena][i_aplyr][1],48,16+i_arena*14+bet_off)--ship spr
				chk_spr=39
			end
		end
		spr(chk_spr,8,16+i_arena*14+bet_off)--check mark
		print(plyr_str,52,18+i_arena*14+bet_off,0)
		spr(32,115,19+i_arena*14+bet_off)
	end
	draw_winning_calc()
	draw_submenu()
	if bet_mode==2 then--dropdown mode
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

function submenu_mode()
	submenu_off=min(submenu_off+10,60)
	if btnp(⬆️) then
		sfx(0)
		submenu_sel=(submenu_sel-2)%5+1
	elseif btnp(⬇️) then
		sfx(0)
		submenu_sel=(submenu_sel%5)+1
	elseif btnp(❎) then
		sfx(3)
		bet_mode=1
	elseif btnp(🅾️) then
		if qm_mode==1 then--on regular bet page
			if submenu_sel==1 then
				sfx(9)
				trn_state(init_quickbetpage)
			elseif submenu_sel==3 then
			elseif submenu_sel==4 then
			end
		else--qm_mode==2--on quick bet page
			if submenu_sel==1 then
				sfx(9)
				trn_state(init_betpage)
			elseif submenu_sel==3 then--duplicate player
				select_player_row()
				sfx(3)
				bet_mode=1
			elseif submenu_sel==4 then--duplicate player
				for ibet=1,10 do
					clear_arena_bet(ibet,arena_sel)
				end
				sfx(3)
				bet_mode=1
			end
		end
		if submenu_sel==2 then--copy bets
			sfx(2)
			copy_bets()
			bet_mode=1
		elseif submenu_sel==5 then--confirm page
			sfx(4)
			init_confirm()
		end
	end
end

function draw_submenu()
	_y=128-submenu_off
	rrectfill(2,_y,124,60,0,5)
	for i=1,#submenu_txts do
		print("●"..submenu_txts[i],4,_y-5+i*9,7)
	end
	if bet_mode==4 then
		rrect(2,_y+(submenu_sel-1)*9+2,60,9,1,9)
	end
end


function draw_winning_calc()
	--winning calculator
	brdr_rect(3,86,122,28,0,7,1)--ticket area

	rrectfill(4,87,120,8,0,5)--grey title
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
	print(total_odds,57-#total_odds*2,105,0)--center odds
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
		if qm_mode==1 then
			init_betpage()
		else
			init_quickbetpage()
		end
	elseif btnp(🅾️) then
		if has_money and made_bets then
			trn_state(init_watch_race)
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
	print("possible winnings",10,34+o_pcount-scroller,0)
	line(79,27+o_pcount-scroller,79,46+o_pcount-scroller,1)
	tw_str=arr_to_str(total_winnings)
	spr(37,96-#tw_str*2,32+o_pcount-scroller)--coin
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
	print("round:#"..cur_round,4,3-scroller,6)	
	spr(37,83,1-scroller)--coin
	print(arr_to_str(money,true),92,3-scroller,9)--my money
	brdr_rect(3,9-scroller,122,max_scroll+97,0,7,1)--ticket area
	rrectfill(4,10-scroller,120,9,0,2)--red area
	print(bet_title,hcenter(bet_title),12-scroller,7)
	brdr_rect(3,19-scroller,122,9,0,5,1)--grey area
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
					local a_plyr=arenas[i_arena][i_aplyr]
					if _cbet[2][i_arena][i_aplyr] then
						spr(32+i_arena,19,12+p_count*9+_offy+8)--planet
						spr(47+a_plyr[1],28,12+p_count*9+_offy+8)--ship spr
						print(players[a_plyr[1]][1],37,14+p_count*9+_offy+8,0)--player name
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
				spr(37,90-#winnings_str*2,36+_offy)--coin
				print(winnings_str,98-#winnings_str*2,38+_offy,0)
			end
		end
	end
	brdr_rect(3,27+o_pcount-scroller,122,20,0,7,1)--ticket area
end

function init_race_results()
	sfx(13)
	_upd=upd_race_results
	_drw=drw_race_results
end

function upd_race_results()
	if btnp(🅾️) then
		--winnings page
		trn_state(init_winning_bets)
	end
end

function drw_race_results()
	print("\^twinners!",48,10,9)
	for i_arena=1,4 do
		local w_pid=arenas[i_arena][round_winners[i_arena]][1]
		spr(32+i_arena,30,16+i_arena*12)--planet
		spr(47+w_pid,41,15+i_arena*12)
		print(get_player_string(i_arena,round_winners[i_arena]),52,17+i_arena*12,7)
	end
	print("press 🅾️ to continue",25,120,7)
end

function init_winning_bets()
	scroller=0
	max_scroll=0
	o_pcount=0
	sfx(14)
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
		trn_state(finish_round)
	end
end

function drw_winning_bets()
	draw_bet_summary()
	--total winnings box
	print("winnings",45,34+o_pcount-scroller,0)
	line(79,27+o_pcount-scroller,79,46+o_pcount-scroller,1)
	tw_str=arr_to_str(winning_cash,true)
	if #tw_str==0 then
		tw_str="0"
	end
	spr(37,96-#tw_str*2,32+o_pcount-scroller)--coin
	print(tw_str,104-#tw_str*2,34+o_pcount-scroller,0)
	print("press 🅾️ to continue",25,50+o_pcount-scroller,7)
end


-->8
--quick bet/submenu pages
function init_quickbetpage()
	bet_sel=1--1-10
	plyr_menu_sel,arena_sel=1,1--select player for each arena 1-16
	bet_mode=1
	submenu_off,submenu_sel,qm_mode=0,1,2
	submenu_txts={"normal bet","copy bet amt","select row","clear arena","confirm bets"}
	total_odds=0
	total_pay=0
	_upd=upd_quickbetpage
	_drw=drw_quickbetpage
end

function upd_quickbetpage()
	get_bet_summary()
	if bet_mode==1 then
		if btnp(➡️) then
			sfx(0)
			bet_sel=(bet_sel%10)+1
		elseif btnp(⬅️) then
			sfx(0)
			bet_sel=(bet_sel-2)%10+1
		elseif btnp(⬆️) then
			sfx(0)
			if plyr_menu_sel==1 then
				arena_sel=(arena_sel-2)%4+1
			end
			plyr_menu_sel=(plyr_menu_sel-2)%4+1
		elseif btnp(⬇️) then
			sfx(0)
			if plyr_menu_sel==4 then
				arena_sel=(arena_sel%4)+1
			end
			plyr_menu_sel=(plyr_menu_sel%4)+1
		elseif btnp(🅾️) then
			sfx(8)
			toggle_bet()
		elseif btnp(❎) then
			--submenu
			sfx(3)
			submenu_sel=1
			bet_mode=4
		end
	elseif bet_mode==4 then
		submenu_mode()
	end
	if bet_mode!=4 and submenu_off>0 then
		submenu_off=max(submenu_off-10,0)
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
	spr(37,57,119)--coin
	print(arr_to_str(bets[bet_sel][1],true),64,121,9)
	line(81,120,81,126,8)
	spr(37,83,119)--coin
	print(arr_to_str(bets_winnings[bet_sel]),90,121,9)
	draw_submenu()
end
-->8
--ticket
function init_gameover()
	gameover_mode=1
	ty_off,t_tmr,t_sep=0,0,0
	get_bet_summary()
	get_bet_costs()
	prep_draw_bet_summary()
	lost_bet_ind=1
	for i_bet=1,10 do
		for i_arena=1,4 do
			for i_plyr=1,4 do
				if bets[i_bet][2][i_arena][i_plyr] then
					lost_bet_ind=i_bet
				end
			end
		end
	end

	_upd=upd_gameover
	_drw=drw_gameover
end

function upd_gameover()
	if gameover_mode==1 then
		if lerp_ticket() then
			t_tmr=0
			sfx(7)
			gameover_mode=2
		end
	elseif gameover_mode==2 then
		t_tmr=min(t_tmr+0.07,1)
		local _t=easeinquad(t_tmr)
		t_sep=lerp(0,11,_t)
		if t_tmr==1 then
			gameover_mode=3
			
		end
	end

end

function drw_gameover()
	draw_ticket(lost_bet_ind,20,140-ty_off)
	if gameover_mode==3 then
		print("\^t\^o280gameover",48,54,8)
	end
end

function lerp_ticket()
	t_tmr=min(t_tmr+0.01,1)
	local _t=easeoutquart(t_tmr)
	ty_off=lerp(0,128,_t)
	
	if t_tmr==1 then
		return true
	end
	return false
end

function draw_ticket(i_bet,_tx,_ty)
	--ticket
	local _sy_u,_sy_d=_ty-t_sep,_ty+t_sep
	--upper ticket
	for i=1,15 do
		rrect(_tx-6+6*i,_sy_u-1,3,1,0,5)--shadow
		rrect(_tx-5+6*i,_sy_u-1,3,1,0,7)--top perf
	end
	line(_tx-1,_sy_u,_tx-1,_sy_u+43,5)--shadow
	rrectfill(_tx,_sy_u,88,50,0,7)--ticket
	palt(0, false)
	spr(192,_tx,_sy_u+42,11,1)--top tear
	palt()
	spr(208,_tx,_sy_d+42,11,1)--bottom tear
	--lower ticket
	rrectfill(_tx,_sy_d+50,88,31,0,7)--ticket2
	line(_tx-1,_sy_d+44,_tx-1,_sy_d+80,5)--shadow2
	rrectfill(_tx+6,_sy_d+81,82,24,0,7)--lwr ticket
	spr(203,_tx-2,_sy_d+81,1,3)--left leaf
	spr(204,_tx+87,_sy_d+81,1,3)--right leaf
	--ticket text
	for i=1,3 do
		local t_off=_sy_u
		if i>1 then
			t_off=_sy_d
		end
		print("★galaxy club★",_tx+15,t_off-13+i*32,6)	
	end
	--text
	
	rrectfill(_tx+2,_sy_u+2,86,10,0,2)--red area
	print("★galaxy club bets★",_tx+5,_sy_u+5,7)
	print("round:#"..cur_round,_tx+28,_sy_u+15,0)
	print("---------------------",_tx+2,_sy_u+22,0)
	print("arena",_tx+2,_sy_u+28,0)
	print("player",_tx+32,_sy_u+28,0)
	print("odds",_tx+66,_sy_u+28,0)
	print("---------------------",_tx+2,_sy_u+34,0)
	p_count=1
	for i_arena=1,4 do
		for i_aplyr=1,4 do
			if bets[i_bet][2][i_arena][i_aplyr] then
				local t_off=_sy_u
				if p_count>1 then
					t_off=_sy_d
				end
				print(i_arena,_tx+10,t_off+33+8*p_count,0)
				local arena_player=arenas[i_arena][i_aplyr]
				local _p_name=players[arena_player[1]][1]
				print(_p_name,_tx-#_p_name*4+56,t_off+33+8*p_count,0)
				local _odds=arena_player[4]..":1"
				print(_odds,_tx+82-#_odds*4,t_off+33+8*p_count,0)
				p_count+=1		
			end
		end
	end
	print("---------------------",_tx+3,_sy_d+80,0)
	print("bet:",_tx+6,_sy_d+85)
	print(arr_to_str(bets[i_bet][1],true),_tx+24,_sy_d+85,0)
	print("odds:",_tx+46,_sy_d+85)
	print(print_bet_odds(bets_odds[i_bet]),_tx+68,_sy_d+85,0)
	print("payout:",_tx+18,_sy_d+96)
	print(arr_to_str(bets_winnings[i_bet]),_tx+48,_sy_d+96,0)
end

function init_watch_race()
	calculate_winners()
		--pay for bets
	money=arr_sub(money,total_bet)
	race_px=reset_num_array(4,4,0)
	race_over=reset_array(4,false)
	for i_arena=1,4 do
		for i_plyr=1,4 do
			race_px[i_arena][i_plyr]=rnd_rng(1,20)
		end
	end
	r_tmr=0
	state_tmr=0
	sn=1.5*sin(time())
	f_line_x=reset_array(4,0)
	music(0)
	_upd=upd_watch_race
	_drw=drw_watch_race
end

function upd_watch_race()
	animatestars()
	update_fx()
	r_tmr+=1
	state_tmr+=1
	if r_tmr>4 then
		r_tmr=0
		change_ship_pos()
	end
	for i_arena=1,4 do
		if race_px[i_arena][round_winners[i_arena]]==34 and race_over[i_arena]==false then
			race_over[i_arena]=true
			sfx(11)
		end
	end
	if btnp(🅾️) then
		trn_state(init_race_results)
		music(-1)
	end
	--stop crowd after race and turn of bg noise
	if race_over[1] and race_over[2] and race_over[3] and race_over[4] then
		sn=0
		music(-1)
		if state_tmr==300 then
			trn_state(init_race_results)
		end
	else
		sn=1.5*sin(time())--crowd sin wave
	end
end

function change_ship_pos()
	for i_arena=1,4 do
		for i_plyr=1,4 do
			if state_tmr>60 and round_winners[i_arena]==i_plyr then
				--move winner to finish line
				race_px[i_arena][i_plyr]=min(race_px[i_arena][i_plyr]+1,34)
				if race_px[i_arena][i_plyr]>30 then
					f_line_x[i_arena]=min(f_line_x[i_arena]+1,4)
				end
			else
				if rnd(1)<0.5 then
					race_px[i_arena][i_plyr]=min(race_px[i_arena][i_plyr]+1,20)
				else
					race_px[i_arena][i_plyr]=max(race_px[i_arena][i_plyr]-1,0)
				end
			end
		end
	end
end

function drw_watch_race()
	draw_starfield()
	draw_fx()
	--star covers
	rectfill(0,0,14,128,0)
	rectfill(111,0,128,128,0)
	rectfill(0,0,128,2,0)
	rectfill(0,100,128,110,0)
	rectfill(0,49,128,52,0)
	rectfill(61,0,64,128,0)
	--screens
	-- local _sz=48
	-- for i=0,1 do
	-- 	for j=0,1 do
	-- 		rrect(14+i*(_sz+2),2+j*(_sz+2),_sz,_sz,0,7)
	-- 	end
	-- end
	--players
	for i_arena=1,4 do 
		_lx=(i_arena+1)%2*50
		_ly=flr((i_arena-1)/2)*50
		rrect(14+_lx,2+_ly,48,48,0,7)
		--finish line
		if f_line_x[i_arena]>0 then
			line(_lx+61-f_line_x[i_arena],_ly+3,_lx+61-f_line_x[i_arena],_ly+48,8)
		end
		--player
		for i_plyr=1,4 do
			fire(20+race_px[i_arena][i_plyr]+_lx,i_plyr*10+_ly+5,-1,0,1,6,f1c)
			p_spr=47+arenas[i_arena][i_plyr][1]
			spr(p_spr,18+race_px[i_arena][i_plyr]+_lx,i_plyr*10+_ly)
		end

		if race_over[i_arena] then
			win_spr=47+arenas[i_arena][round_winners[i_arena]][1]
			rrectfill(15+_lx,3+_ly,46,46,0,1)
			print("winner!",_lx+24,_ly+14,9)
			local winner=players[arenas[i_arena][round_winners[i_arena]][1]][1]
			print(winner,_lx+38-#winner*2,_ly+24,9)

			spr(win_spr,_lx+34,_ly+31)
		end
		rrectfill(15+_lx,3+_ly,10,10,1,1)--planet bg
		spr(32+i_arena,16+_lx,4+_ly)--planet
	end

	rrectfill(0,110,128,30,0,1)--blue bg
	spr(6,-1,100+sn,9,2)--crowd1
	spr(6,66,100-sn,9,2)--crowd2
	rrectfill(0,114,128,10,0,4)--brown cover
	print("press 🅾️ to skip",34,116,7)
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
			local _selected_player=reset_array(4,false)
			add(_bet[2],_selected_player)	
		end
		add(bets,_bet)
	end
end

function copy_bets()
	local _bet_amt=bets[bet_sel][1]
	for i_bet=1,10 do
		bets[i_bet][1]=copy_list(_bet_amt)
	end
end

function select_player_row()
	for b=1,10 do
		clear_arena_bet(b,arena_sel)
		bets[b][2][arena_sel][plyr_menu_sel]=true
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
	clear_arena_bet(bet_sel,arena_sel)
	--select bet
	bets[bet_sel][2][arena_sel][plyr_menu_sel]=true
end

function clear_arena_bet(_ibet,_iarena)
	for i_plyr=1,4 do
		bets[_ibet][2][_iarena][i_plyr]=false
	end
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
	if arr_to_str(money,true)=="0" then
		init_gameover()
	else
		--refill arena
		fill_arenas()
		--start next bet round/bet page
		if qm_mode==1 then
			init_betpage()
		else
			init_quickbetpage()
		end
	end


	
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

function copy_list(t)
  local out={}
  for i=1,#t do
    out[i]=t[i]
  end
  return out
end

--fade stuff
--initiate a pause on all player updates until fade is over
function trn_state(fn)--transition state
	init_fade()
	new_fn = fn
	_upd=upd_fade_pause
end
--for trn_state 
function upd_fade_pause()--don't call directly
	if fade_state==2 then
		_upd=new_fn
	end
end

function init_fade()
	fade_tmr=0
	fade_state=1
	fade_r=0
	finc,famt=40,160
end

function fade_tmr_upd()
	fade_tmr+=1
	if fade_tmr>3 then
		fade_state+=1
		fade_tmr=0
	end
end

function drw_and_upd_fade()
	--update fade
	
	if fade_state==1 then
		fade_r=min(fade_r+finc,famt)
		if fade_r==famt then
			fade_tmr_upd()
		end
	elseif fade_state==2 then
		fade_tmr_upd()
	--fade in
	elseif fade_state==3 then
		fade_r=max(fade_r-finc,0)
		if fade_r==0 then
			fade_tmr+=1
			if fade_tmr>12 then
				fade_state=0
			end
		end
	end
	--draw fade
	if fade_r>0 then
		if fade_state==1 then
			rrectfill(0,0,fade_r,128,0,0)
		else
			rrectfill(famt-fade_r,0,famt,128,0,0)
		end
	end
end

--do not use a changing
--value for a silly boi
function lerp(a,b,t)
	return a+(b-a)*t
end


function easeinquad(t)
	return t*t
end

function easeoutquad(t)
	t-=1
	return 1-t*t
end

function easeoutquart(t)
	t-=1
	return 1-t*t*t*t
end

function easeinovershoot(t)
	return 2.7*t*t*t-1.7*t*t
end

function easeoutovershoot(t)
	t-=1
	return 1+2.7*t*t*t+1.7*t*t
end

function easeinoutovershoot(t)
	if t<.5 then
		return (2.7*8*t*t*t-1.7*4*t*t)/2
	else
		t-=1
		return 1+(2.7*8*t*t*t+1.7*4*t*t)/2
	end
end

function easeoutinovershoot(t)
	if t<.5 then
		t-=.5
		return (2.7*8*t*t*t+1.7*4*t*t)/2+.5
	else
		t-=.5
		return (2.7*8*t*t*t-1.7*4*t*t)/2+.5
	end
end

function easeoutelastic(t)
	if(t==1) return 1
	return 1-2^(-10*t)*cos(2*t)
end

function brdr_rect(_x,_y,_w,_h,_r,_ci,_co)
	rrectfill(_x,_y,_w,_h,_r,_ci)
	rrect(_x,_y,_w,_h,_r,_co)
end

-->8
--starfield

--starfield
function draw_starfield()
	scols={6,13,1}--star colors
	for i=1,#starx do
		local scol=scols[1]
		
		if starspd[i] < 1 then
			scol=scols[3]
		elseif starspd[i] < 1.5 then
			scol=scols[2]
		end
		
		if starspd[i] <= 1.5 then
			pset(starx[i],stary[i],scol)
			else
			line(starx[i],stary[i],starx[i]+1,stary[i],scol)
		end
		
	end
end

function animatestars()
	for i=1,#starx do
		local _starx=starx[i]
		_starx-=starspd[i]
		if _starx<0 then
			_starx+=128
		end
		starx[i]=_starx
	end
end

--particles
function add_fx(x,y,die,dx,dy,grav,grow,shrink,r,c_table,shwave)
    local fx={
        x=x,
        y=y,
        t=0,
        die=die,
        dx=dx,
        dy=dy,
        grav=grav,
        grow=grow,
        shrink=shrink,
        r=r,
        c=0,
        c_table=c_table,
        shwave=shwave
    }
    add(effects,fx)
end

function update_fx()
 for fx in all(effects) do
  --lifetime
  fx.t+=1
  if fx.t>fx.die then del(effects,fx) end

  --color depends on lifetime
  if fx.t/fx.die < 1/#fx.c_table then
      fx.c=fx.c_table[1]

  elseif fx.t/fx.die < 2/#fx.c_table then
      fx.c=fx.c_table[2]

  elseif fx.t/fx.die < 3/#fx.c_table then
      fx.c=fx.c_table[3]

  else
      fx.c=fx.c_table[4]
  end

  --physics
  if fx.grav then fx.dy+=.5 end
  if fx.grow then fx.r+=.1 end
  if fx.shrink then fx.r-=.1 end
		if fx.shwave then fx.r+=1 end
  --move
  fx.x+=fx.dx
  fx.y+=fx.dy
 end
end

function draw_fx()
 for fx in all(effects) do
  --draw pixel for size 1, draw circle for larger
  if fx.r<=1 then
      pset(fx.x,fx.y,fx.c)
  else
  	 circfill(fx.x,fx.y,fx.r,fx.c)
  	 
  end
 end
end

-- fire effect
--dx/dy should be mults of -+.5
function fire(x,y,dx,dy,r,l,c_table)
 for i=0, 1 do
  --settings
  add_fx(
   x+rnd(1)-1/2,--x
   y+rnd(1)-1/2,--y
   l+rnd(l),--die
   dx,--dx
   dy,--dy
   false,--gravity
   false,--grow
   true,--shrink
   r,--radius
   c_table,--color_table
   false--shwave
      
  )
 end
end



__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000003bbb1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000003bbbbb100000000000000000000000000000000000000000555000000000000000066660555566660000000000000000000000000000000000000000000
00003bbb10bb10000000000000000000000000000000000000005555500000005550000666665555556666000055550066660000000000006666000000000000
0003bbbb100be8000000ddd0000ddd00b3310000b331000000055555566600055555006666655555555666600555555666666005555000066666600000000000
003bbbbbb1008800000d000d00d000d00b3310000b33100000055555666660555555506666655555555666605555555566666655555500666666660000000000
03bbbbbbbb10000000dc100000dc10000b3331000b33310000066556666666555555506666655555555655605555555566556555555550666666660000000000
3bbbbbbbbbb100000ecccc10ccccc100b33333003333310000066556666666555555506666655555555655605555555566556555555550666666660000000000
3bbbf4bbf4bb1000ecccccccccccc100b33333333333310000006556666666555555500666665555556665505555555566566555555550666666660600000000
3bbbf4bbf4bb1000eccc65ccc65cc1000b33f4333f43100000056655666660655555000666665555566660500555555665566555555550066666600600000000
3bbbbbe8bbbb10000ecc65ccc65c1000b333f4333f43310000555656666606555550006666655555556666500555550055660055555560006666006600000000
03bbbb888bbb10000ecccccccccc1000b33333333333310005555666666665555555506666555555555666550555555656666055555066006666666000000000
03bbbb888bb100000ecccccc6ccc1000b33333333633310005555566666665555555555666555555556566655555555556666655555506666666600000000000
03bbbbbbbbb100000ecccccccccc10000b3333666333100055555566666655555555065566555555555566655555555566666555555550666666600000000000
003bbbb66b10000000ecccccccc1000000b333333331000055555566666655555555665565555555555566655555555556666555555550666666660000000000
0003bbbbb1000000000eccccc1000000000b33333310000055555566666555555555666665555555555666655555555556666555555550666666660000000000
1000100000c33c0000000000002e2200003333000000000000000000000003100000000000000000000000000000000000000000000000000000000000000000
010100000cc6cc60000066500228285003bab3500000000000000000000003100000000000000000000000000000000000000000000000000000000000000000
00100000c3ccc3c606506d5022822285333ba335009a950000666000316631000000000000000000000000000000000000000000000000000000000000666000
00000000c3cc33c60d5055002e2228e53b3b33b509a9a95006000600331316000000000000000000000000000000000000000000000000000000000000660000
00000000c36c36c600000065822e82253ba3bab509a9995006000600033316000000000000000000000000000000000000000000000000000000000055566666
00000000c33cccc600d650008228228533b33b3509a9a95006000600063106000000000000000000000000000000000000000000000000000000000055566660
000000000ccc33600065065002822e5003333350009a950000666000006660000000000000000000000000000000000000000000000000000000000055566600
00000000006666000000000000555500005555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000002b0000000000000000000004f04f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000222b0000000000000444440040f40f000ddddd0000000000d000000000000000cc0000000000000c8d330000282828000000999a0000aa0000ccc000
1cccdd008222222d1dddcc00844411404f040f00ddddd1d0000008d70dddddd0840000000c1cccf00cc00cc00bdbb0300288800009ac9000089999a00ddddd00
8cc77cd0223232008ddd77c0049944144004f0008dccd1d0490cccdd0dd22dcd044494c000c11ccfcccccce033939323028cc000899dc99a9999cc9ad78827d0
1c7ccccc8222222d1d77ddd084449440841914408d66d1d044c0000008dddddc0494444400cccfccccdccdc0bbbbbbbb028880009aa9d000089999a00ddddd00
000000000000000000dddd000444440049449400ddddd1d0000cccd70d1ddd1d8400d0000cc0f0008dd8dd0003003000282828000000999a0000aa0000000000
00000000000000000000000000000000000000000ddddd00000008dd0000000000000dd0cc000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777770057777777000000000000000000000000000000
77777777777777777777777777777775557777777777777777777777777777777777777777777777777777770057777777000000000000000000000000000000
57777777777777757777777757777750005777777777777757777777777777755777777777777770777777770057777777000000000000000000000000000000
57777775777777505777777557777750000577777777777505777777777775505777777557777700577777700057777777000000000000000000000000000000
05777750577755005777775005777500000057777777775005777777777750000577775000577700577777000057777777000000000000000000000000000000
05777500055500000577750005777500000005777777750000577777775500000577750000577000057770000057777777000000000000000000000000000000
00577500000000000577500000575000000000577775000000057777750000000057750000057000057700000057777777000000000000000000000000000000
00575000000000000057500000000000000000007750000000005777000000000000000000000000005700000057777777000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000057777777000000000000000000000000000000
00000000000000000000000000000007770000000000000000000000000000000000000000000000000000000057777777700000000000000000000000000000
70000000000000070000000070000077777000000000000070000000000000077000000000000007000000000005777777700000000000000000000000000000
70000007000000777000000770000077777700000000000777000000000007777000000770000077700000070005777777700000000000000000000000000000
77000077700077777000007777000777777770000000007777000000000077777700007777700077700000770005777777700000000000000000000000000000
77000777777777777700077777000777777777000000077777700000007777777700077777700777770007770005777777700000000000000000000000000000
77700777777777777700777777707777777777700007777777770000077777777770077777770777770077770005777777700000000000000000000000000000
77707777777777777770777777777777777777770077777777777000777777777777777777777777777077770005777777700000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005777777700000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005777777770000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000577777770000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000577777777000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000057777777000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000057777777700000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005777777700000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005777777770000000000000000000000000
__sfx__
0002000017050170502300022000170001e0001800015000100000b000160001400011000120000f0000c0000a0000d0000e0000c0000a0000d000100000e0000a00000000000000000000000000000000000000
000200001b05021050260501f05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002c4402744023440214001f4001b4001b4000e4001f400234001f4001c4001e400244001c4000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
000000000b4500d450104501245000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001e050200502205024050270502b0503105031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002b2500020000200002002b240002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
000100002d2500020000200002002d240002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
000300001b6302863532635396353d6353e6300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000b0500c0500b0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000090500105001050020500305006050080500b0500e0501205015050190501d0501e0501f0502105023050250500000000000000000000000000000000000000000000000000000000000000000000000
3606000008650086500a6500c6500d6500f650126501465017650196501c6501f650216502365026650286502a6502c6502d6502d6502b6502965026650216501b650126500d6500965006650056500365000650
36020000196501c6501f65023650276502a6502d6502f6502f6502c65027650236501f6501d650196501465011650106500c6500b6500a6500a6500b6500c6500f6500d6500d6500c6500c6500c6500c6500c650
931000000963009630096300c63009630096300963010630096300963009630096300f6300963009630096300b63009630096300963010630096300963009630096300f6300963009630096300c6300963009630
01100000220552705522055240551f055240551f0552e0522e0422e032290052b0052700529005270052900529005290052b005290052b0052b0052b005000050000500005000050000500005000050000500005
000600001b550135501155011550165501b5501f550275502b5503055033550215002250000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
__music__
03 0c4a4944
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

