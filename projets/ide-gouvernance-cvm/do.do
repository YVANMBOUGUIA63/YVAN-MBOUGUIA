clear all
set more off
set matsize 800
cd "C:\cours magistère 2\rapport économétrie\estimation"

*capture log close						 
*log using fichier_log.log, text replace   

use base3

egen id = group(v1)

xtset id year

drop if year == 1990

gen produit = flux_entr*indice
tab year, gen(dum)
tab type, gen(typ)
gen group = 1 if typ1 ==1 | typ4 == 1
replace group = 0 if group == .
gen nt = natural_rents*group
gen ft = remittances*group
gen flt = flux_entr*group 
replace tr1 = typ1*remittances
replace tr2 = typ2*remittances
replace tr4 = typ4*remittances


xtreg lnfva produit remittances natural_rents gcf_gdp credit_private HC ouverture  lngdppc  dum2 dum3 dum4 dum5 , fe ro

xtivreg2 lndvx (produit = flux_entr1) indice remittances natural_rents gcf_gdp credit_private HC ouverture  lngdppc  dum2 dum3 dum4 dum5  , fe robust ffirst

egen type2 = group(type)

xtreg lndvx produit remittances natural_rents gcf_gdp credit_private HC ouverture  lngdppc   mean_credi mean_gcf mean_gdp mean_hc mean_nat2 mean_ouv mean_rem1 lngdp mean_prod i.type, fe robust

xtivreg2 lnfva (flux_entr = flux_entr1) remittances indice HC ouverture natural_rents gcf_gdp dum2 dum3 dum4 dum5 , fe robust

replace type = 5 if type == 1


bys id: egen mean_rem1 = mean(remittances)
bys id: egen mean_nat2 = mean(natural_rents)
bys id: egen mean_gcf = mean(gcf_gdp)
bys id: egen mean_credi = mean(credit_private)
bys id: egen mean_hc = mean(HC)
bys id: egen mean_ouv = mean(ouverture)
bys id: egen mean_gdp = mean(GDP_per_capita)
bys id: egen mean_prod = mean(produit)
bys id: egen mean_growth = mean(gdp_growth)
bys id: egen mean_growth = mean(gdp_growth)
bys id: egen mean_pro_stand = mean(produit_stand)

bys year: egen min_ind = min(indice)
bys year: egen max_ind = max(indice)
gen pr = 100 * (indice - min_ind) / (max_ind - min_ind)
gen produit_stand = flux_entr*pr


xtreg dvx produit_stand remittances natural_rents gdp_growth typ1 typ2 typ4 HC i.year credit_private , re vce(cluster id)

xtreg gvc produit_stand remittances natural_rents gdp_growth HC  ouverture i.year , fe vce(cluster id)

