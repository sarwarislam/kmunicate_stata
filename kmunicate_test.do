clear all

capture program drop pmcalplotcr
qui include "\\uol.le.ac.uk\root\staff\home\s\sim15\My Documents\Stata\ado\personal\kmunicate.ado"

sysuse cancer

* Make up value labels for the three arms
lab def drug 1 "Ctrl" 2 "Another" 3 "One thing"
lab val drug drug

stset studytime, fail(died = 1)

// kmunicate [sts graph options], [kmunicate options]
// groupvar() and timerange() are compulsory options
kmunicate ///
	by(drug) plot1opts(lc(navy)) plot2opts(lc(maroon)) plot3opts(lc(dkgreen)) ///
    ci ci1opts(fc(navy%30)) ci2opts(fc(maroon%30)) ci3opts(fc(dkgreen%30)) ///
	ytitle("Proportion surviving") plotregion(margin(medsmall)) ///
    legend(order(9 "One thing" 8 "Another" 7 "Ctrl") ring(100) cols(1) pos(9))  ///
	title("Kmunicate Magic") ///
	, ///
	groupvar(drug) ///
	timerange(0(5)40) ///
	xtitle("Time since randomization")