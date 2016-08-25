
 clear all
*Obtenido de algún lugar de stata forums.

********************************************************************
*Elige usuario
if c(username)=="XXXX" {
cd \\XXXX\
}
else {
cd P:\
}
 
 use Panelv6.dta // in 1/100
 /*egen id_time=group(fecorte)
 keep if tpersona==1
 xtset id_number id_time 
 */
su id_time, meanonly
local max = r(max)
local min = r(min)
local range = r(max) - r(min) + 1
 local miss : di _dup(`range') "."
 bysort id_number (fecorte) : gen this = substr("`miss'", 1, id_time[1]-`min') +"1" if _n == 1
 by id_number : replace this = substr("`miss'", 1, id_time- id_time[_n-1] - 1) +"1" if _n > 1
 by id_number : replace this = this + substr("`miss'", 1, `max'-id_time[_N]) if _n == _N
 by id_number : gen pattern = this[1]
 by id_number : replace pattern = pattern[_n-1] + this if _n > 1
 by id_number : replace pattern = pattern[_N]
 *table pattern
 xtdes
 generate missing=(strmatch(pattern, "*1*.*1*"))
table fecorte missing, row col
