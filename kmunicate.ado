program kmunicate, eclass byable(onecall)

version 16

syntax [anything] [if] [in],  ///
							 groupvar(varname) ///
							 timerange(numlist) /// times at which you want to summarise
							 [ ///
							 timevar(varname) ///
							 eventvar(varname) ///
							 eventlabel(string) ///
							 xtitle(string) ///
							 xlabelopts(string) ///
							 xscale(string) ///
							 lmargin(int 0) ///
							 bmargin(int 15) ///
							 justsize(int -4) ///
							 labsize(string) ///
							 ]
if "`timerange'" == "" {
	di in red "Must specify time-range e.g. timerange(0(2)10)"
	exit 198
}

if "`timevar'" == "" {
	local timevar _t
}

if "`eventvar'" == "" {
	local eventvar _d
}

if "`eventlabel'" == "" {
	local eventlabel "Event"
}

if "`labsize'" == "" {
	local labsize "vsmall"
}

// extract label num from var
qui levelsof `groupvar', local(levels)

// extract labels from var
local vlname: value label `groupvar'
local vl_list
foreach L of local levels {
   local vl: label `vlname' `L'
   //local vl_list "`vl_list' `vl'"
   local labelname_`L' `vl'
}

foreach j in `timerange' {
    foreach i in `levels' {
        quietly count if `groupvar' == `i' & _t >= `j' // need to change 'drug' to whatever the by() var is
            local risk_`i'_`j' = r(N)
         quietly count if `groupvar'==`i' & _t < `j' & !_d
           local cens_`i'_`j' = r(N)
        quietly count if `groupvar'==`i' & _t < `j' & _d
            local ev_`i'_`j' = r(N)
    }
	local opt `opt' `j' `" " "  " " "`risk_1_`j''" "`cens_1_`j''" "`ev_1_`j''" " " "`risk_2_`j''" "`cens_2_`j''" "`ev_2_`j''" " " "`risk_3_`j''" "`cens_3_`j''" "`ev_3_`j''" "'
}

local options = subinstr(`"`0'"', `"`anything'"', "", .)

if strpos(`"`anything'"', "xtitle") != 0 {
	di in red "Please use the xtitle() option in kmunicate, rather than in sts graph syntax e.g. do kmunicate ..., xtitle(Some Text)"
	exit 198
}
if strpos(`"`anything'"', "risktable") != 0 {
	di in red "Please omit risktable option from kmunicate syntax i.e. remove as an sts graph option"
	exit 198
}
if strpos(`"`anything'"', "xscale") != 0 {
	di in red "Please use the xscale() option in kmunicate, rather than in sts graph syntax e.g. do kmunicate ..., xscale()"
	exit 198
}
if strpos(`"`anything'"', "xlabel") != 0 {
	di in red "Please omit xlabel() option in sts graph syntax within kmunicate. Instead use xlabelopts() option in kmunicate e.g. do kmunicate ..., xlabelopts()."
	di in red "Time range on x axis is defined using timerange() option in kmunicate e.g. kmunicate ..., timerange(0(2)10))"
	exit 198
}

if "`bmargin'" != "0" {
	 local bmargin graphregion(margin(b-`bmargin'))
}
else {
	local bmargin 
}

if "`lmargin'" == "0" {
 local lmargin xoverhang
}

if "`lmargin'" != "0" {
 local lmargin `lmargin'
}

local risktext xlabel(`justsize'  `" " "
foreach L of local levels {

	local risktext  `risktext' `"{bf:`labelname_`L''} "' `"At-risk "' `"Censored"' `"`eventlabel' "'
	
}
local risktext `risktext'  "' `opt', notick custom norescale labsize(`labsize') axis(2) labjustification(right))


sts graph, /// 
		   `anything' xaxis(1 2 3) ///
			xtitle("`xtitle'", axis(1)) ///
			xtitle("", axis(3)) ///
			xtitle("", axis(2))	///
			xscale(lstyle(none) off axis(3)) ///
		    xscale(lstyle(none) axis(2)) ///
			xscale(`xscale' axis(1)) ///
			xlabel(`timerange', axis(1) `xlabelopts') ///
			xlabel(, nolabels axis(3)) ///
			`risktext' ///
			`lmargin' ///
	        `bmargin'
			
		   
end
