cap program drop ppp2
*! version 1.00 May 8, 2017
*! Victoria Nyaga 

program define ppp2
version 10.1

#delimit ;
syntax anything [if] [in], [bands(string) bandcolor(string) noLR
	LEGENDopts(string) YSIZE(integer 6) XSIZE(integer 5) dp(string) * ];
#delimit cr
	 
tempname prev PLR2 NLR3 PLR4 NLR5 PLR6 NLR7  upbound lowbound max min x band1 ///
		 PLR8 NLR9 PLR10 NLR11 PLR12 NLR13 PLR14 NLR15
qui{

	local k: word count `anything'
	tokenize "`anything'"
	
	scalar `prev' = `1'
	
	if "`lr'" == ""{
		scalar `PLR2' = `2'
		scalar `NLR3' = `3' 
	}
	else{
		scalar `PLR2' = `2'/(1 - `3')
		scalar `NLR3' = (1 - `2')/`3'
	}
	
	if "`dp'" == "" {
		local dp = "2"
	}
	
	local lprprob = log((`prev')/(1 - `prev'))
	local priorprob = 100*`prev' 
	local noteprior: di "("%4.`dp'f `priorprob' "%)"
	
	local lpostprob2 = `lprprob' + log(`PLR2')
	local postprob2 = 100*invlogit(`lpostprob2')
	local notepost2: di "(" %4.`dp'f `postprob2' "%)"
	
	local lpostprob3 = `lprprob' + log(`NLR3')	
	local postprob3 = 100*invlogit(`lpostprob3')
	local notepost3: di "("  %4.`dp'f `postprob3' "%)"
		
	local segment =  `""'
	local vertikal =  `""'
	local vertikali =  `""'
	
	local maxl = log(99.9/(100-99.9))
	local minl = log(0.01/(100-0.01))
	
	
	/*Generate statements for the other branches*/
	local c = 4	
	while `c' <= `k'{
		
		local o = floor(`c'/2)
		local fstep = `c' + 1
		local bstep = `c' - 1

		if mod(`c', 2) == 0 {
			if "`lr'" == ""{
				local PLR`c' = ``c''
			}
			else{
				local PLR`c' = ``c''/(1 - ``fstep'')
			}
			
			local lpostprob`c' = `lpostprob`o'' + log(`PLR`c'')
			local postprob`c' = 100*invlogit(`lpostprob`c'')
			local notepost`c': di "(" %4.`dp'f `postprob`c'' ")%"
			
			if (`c' > 3 & `c' < 8)  {			
				local segmenti = `"(pcarrowi `lpostprob`o'' 0 `lpostprob`c'' 4, lcolor(red) mcolor(red)	yaxis(2) lpat(dash) lwidth(thin))"'
			}
			else if (`c' > 7)  {
				local segmenti = `"(pcarrowi `lpostprob`o'' 4 `lpostprob`c'' 8, lcolor(red)	mcolor(red) yaxis(2) lpat(dash) lwidth(thin)) "'
			}
		}
		else {
			if "`lr'" == ""{
				local NLR`c' = ``c''
			}
			else{
				local NLR`c' = (1 - ``bstep'')/``c''
			}
			local lpostprob`c' = `lpostprob`o'' + log(`NLR`c'')
			local postprob`c' = 100*invlogit(`lpostprob`c'')
			local notepost`c': di "(" %4.`dp'f `postprob`c'' ")%"
			
			if (`c' > 3 & `c' < 8)  {			
				local segmenti = `"(pcarrowi `lpostprob`o'' 0 `lpostprob`c'' 4, lcolor(green) mcolor(green) yaxis(2) lpat(dash) lwidth(thin))"'
			}
			else if (`c' > 7)  {
				local segmenti = `"(pcarrowi `lpostprob`o'' 4 `lpostprob`c'' 8, lcolor(green) mcolor(green) yaxis(2) lpat(dash) lwidth(thin))"'
			}
		}
		
		if ``c'' == 1 & "`lr'" == ""{
			if `c' < 8  {			
				local segmenti = `"(pcarrowi `lpostprob`o'' 0 `lpostprob`c'' 4, lcolor(gs5) mcolor(gs5) yaxis(2) lpat(dash) lwidth(thin))"'
			}
			else {
				local segmenti = `"(pcarrowi `lpostprob`o'' 4 `lpostprob`c'' 8, lcolor(gs5) mcolor(gs5) yaxis(2) lpat(dash) lwidth(thin))"'
			}
		}
		if ``c'' == 0.5 & "`lr'" != ""{
			if `c' < 8  {			
				local segmenti = `"(pcarrowi `lpostprob`o'' 0 `lpostprob`c'' 4, lcolor(gs5) mcolor(gs5) yaxis(2) lpat(dash) lwidth(thin))"'
			}
			else {
				local segmenti = `"(pcarrowi `lpostprob`o'' 4 `lpostprob`c'' 8, lcolor(gs5) mcolor(gs5) yaxis(2) lpat(dash) lwidth(thin))"'
			}
		}
		
		if `c' == 4{
			local vertikali = `"(pci `minl' 0 `maxl' 0, recast(pcspike) lcolor(gs5) mcolor(gs5) plotregion(margin(zero)))"'
			local vertikal = "`vertikal' `vertikali'"
		}
		
		if `c' == 8{
			local vertikali = `"(pci `minl' 4 `maxl' 4, recast(pcspike) lcolor(gs5) mcolor(gs5) plotregion(margin(zero)))"'
			local vertikal = "`vertikal' `vertikali'"
		}
		
		local segment = " `segment' `segmenti'"
		
		
		local ++c
	} 
	
	if `k' < 4 {
		local maxx = 0
	}
	else if (`k' > 3 & `k' < 8) {
		local maxx = 4
	}
	else{
		local maxx = 8
	}
	
	foreach p in 0.01 0.05 0.1 0.5 1 5 10 20 50 80 90 95 99 99.5 99.9 {   
			 local ylab `"`ylab' `=ln(`p' / (100 - `p'))' "`p'" "'
	}

	foreach lr in 0.0001 0.0002 0.0003 0.0005 0.0007 0.001 0.002 0.005 0.01 ///
				0.02 0.05 0.1 0.2 0.5 1 2 5 10 20   ///
				   50 100 200 500 1000 {
			 local PLRts `"`PLRts' `=-.5*ln(`lr')' 0 "`lr'" "'
	}
	
	if ("`bands'" != "" ){
		if `k' == 3 {
			set obs 5
			egen  `x' = seq(),f(-4) to(0)
		}
		else if (`k' > 4 & `k' < 8){
			set obs 9
			egen  `x' = seq(),f(-4) to(4)
		}
		else {
			set obs 13
			egen  `x' = seq(),f(-4) to(8)
		}	
	}
	
	local area =  `""'
	if "`bands'" != ""{
	
		local countbands = wordcount("`bands'")
		
		forvalues band=1/`countbands'{	
			local value = word("`bands'", `band')
			cap assert (`value'> 0 & `value' < 1)
			if _rc!=0 {
				di as err "Band values should be between 0 and 1"
				exit _rc
			}
		}
		
		if "`bandcolor'" == ""{
			if 	`countbands' < 3{
				local bandcolor = "green orange red"
			}
			else if `countbands' == 3{
				local bandcolor = "blue green orange red"
			}
		}
		local countbands = `countbands' + 1
		forvalues band=1/`countbands'{
		
			tempname upbound`band'
			
			if `band' == 1 {
				local lowbound = log(0.01/(100-0.01))
			} 
			else {
				local value = word("`bands'", `band' - 1)
				local lowbound = log(`value'/(1 -`value'))
			}
			
			if `band' == `countbands' {
				gen `upbound`band'' = log(99.9/(100-99.9))
			} 
			else {
				local value = word("`bands'", `band')
				gen `upbound`band'' = log(`value'/(1 -`value'))
			}
			local colorb = word("`bandcolor'", `band')
			local area`band' "(area `upbound`band'' `x', fcolor(`colorb') fintensity(25) base(`lowbound'))"
			
			local area  `area' `area`band''
		}
	}		
			
	if "`legendopts'" != "off" {
	
		if "`bands'" != "" {
			local keycount = wordcount("`bands'") 
		}

		if `k' == 3{
			if "`legendopts'" == "" { // default legend options
				local legendopts `" colf pos(6)  col(2) rowgap(2) region(lcolor(none)) "'
			}
			if `keycount' == 2{
				local legendopts `" order(- "Pre"  "`noteprior'" - " " 8 "Post(+)" "`notepost2'" 9 "Post(-)" "`notepost3'") `legendopts'"'
			}
			else{
			local legendopts `" order(- "Pre"  "`noteprior'" - " " 9 "Post(+)" "`notepost2'" 10 "Post(-)" "`notepost3'") `legendopts'"'
			}
		}
		
		if (`k' > 3) & (`k' < 8){
			if "`legendopts'" == "" { // default legend options
				local legendopts `" pos(6)  colf col(3) rowgap(2) region(lcolor(none)) "'
			}
			if `keycount' == 2 {
				local legendopts `" order(- "Pre"  "`noteprior'" - " " - " " - " " 9 "Post(+)" "`notepost2'" 10 "Post(-)" "`notepost3'" - " " - " "  11 "Post(+)" "`notepost4'" 12 "Post(+)" "`notepost5'" 13 "Post(+)" "`notepost6'" 14 "Post(-)" "`notepost7'") `legendopts'"'
			}
			else{
				local legendopts `" order(- "Pre"  "`noteprior'" - " " - " " - " " 10 "Post(+)" "`notepost2'" 11 "Post(-)" "`notepost3'" - " " - " "  12 "Post(+)" "`notepost4'" 13 "Post(+)" "`notepost5'" 14 "Post(+)" "`notepost6'" 15 "Post(-)" "`notepost7'") `legendopts'"'

			}
		}
		
		if (`k' > 7) {
			if "`legendopts'" == "" { // default legend options
				local legendopts `" pos(6)  colf col(4) rowgap(2)  colgap(20) region(lcolor(none)) "'
			}
			if `keycount' == 3 { 
				local legendopts `" order(- "Pre"  "`noteprior'" - " " - " " - " " - " " - " " - " " - " " 11 "Post(+)" "`notepost2'" 12 "Post(-)" "`notepost3'" - " " - "  " - "  " - " "  - " " - " " 13 "Post(+)" "`notepost4'" 14 "Post(+)" "`notepost5'" 15 "Post(+)" "`notepost6'" 16 "Post(-)" "`notepost7'"   - " "  - " "  - " "  - " " 17 "Post(-)" "`notepost8'" 18 "Post(-)" "`notepost9'" 19 "Post(-)" "`notepost10'" 20 "Post(-)" "`notepost11'" 21 "Post(-)" "`notepost12'" 22 "Post(-)" "`notepost13'" 23 "Post(-)" "`notepost14'" 24 "Post(-)" "`notepost15'" ) `legendopts'"'
			} 
			else {
				local legendopts `" order(- "Pre"  "`noteprior'" - " " - " " - " " - " " - " " - " " - " " 10 "Post(+)" "`notepost2'" 11 "Post(-)" "`notepost3'" - " " - "  " - "  " - " "  - " " - " " 12 "Post(+)" "`notepost4'" 13 "Post(+)" "`notepost5'" 14 "Post(+)" "`notepost6'" 15 "Post(-)" "`notepost7'"   - " "  - " "  - " "  - " " 16 "Post(-)" "`notepost8'" 17 "Post(-)" "`notepost9'" 18 "Post(-)" "`notepost10'" 19 "Post(-)" "`notepost11'" 20 "Post(-)" "`notepost12'" 21 "Post(-)" "`notepost13'" 22 "Post(-)" "`notepost14'" 23 "Post(-)" "`notepost15'" ) `legendopts'"'
			}
		}
	}
		
	#delimit;
	tw 
	
		(scatteri 0 0, mcolor(none) xlab(none) yaxis(1) ylab( `ylab', angle(0) 
		tpos(cross)) yscale(axis(1)) ytitle("Pre-test Probability (%)", axis(1) suffix ))

		(scatteri 0 0, mcolor(none) yaxis(2) ylab(`ylab', angle(0) tpos(cross) axis(2))
		ytitle("Post-test Probability (%)", axis(2) suffix))
 
		(pci 0 0 0 0, recast(pcspike) lcolor(white) 
		xscale(range(-4 `maxx')) plotregion(margin(zero)) xsize(2) ysize(6)
		xscale(on) ylab(, nogrid))

		(scatteri `lprprob' -4, msym(D) yaxis(2))

		(pcarrowi `lprprob' -4 `lpostprob2' 0,lcolor(red) mcolor(red)
		yaxis(2) lpat(solid) lwidth(thin))
 
		(pcarrowi `lprprob' -4 `lpostprob3' 0, lcolor(green) mcolor(green) 
		yaxis(2) lpat(solid) lwidth(thin))
			
		`segment'
		`area'
		`vertikal'
			
 
		, legend(`legendopts') `options'; 
	#delimit cr 
}
end                                                                
               
