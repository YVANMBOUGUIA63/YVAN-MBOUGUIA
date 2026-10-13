
library(tidyverse)
library(questionr)
library(haven)
library(readxl)
library(countrycode)
library(FactoMineR)
library(Factoshiny)
library(factoextra)
library(corrplot)
library(patchwork)
library(ggplot2)
install.packages("writexl")
library(writexl)
library(rmarkdown)
library(tinytex)
library(knitr)



gvc <- read_dta("C:/cours magistère 2/rapport économétrie/base de données/pièces jointes (1)/gvc1.dta")

A1 <- read_excel("C:/cours magistère 2/rapport économétrie/base de données/pièces jointes (1)/s.xlsx")

A2 <- read_excel("C:/cours magistère 2/rapport économétrie/base de données/pièces jointes (1)/IS_database.xlsx")

A3 <- read_excel("C:/cours magistère 2/rapport économétrie/base de données/pièces jointes (1)/indicateurs de gov(0-100).xlsx")


A4 <- read_dta("C:/cours magistère 2/rapport économétrie/base de données/pièces jointes (1)/capital humain1.dta")


A5 <- read_excel("C:/cours magistère 2/rapport économétrie/base de données/pièces jointes (1)/gdp.xlsx")

A6 <- read_excel("C:/cours magistère 2/rapport économétrie/base de données/pièces jointes (1)/donnees annees de scol.xls")

A7 <- read_excel("C:/cours magistère 2/rapport économétrie/base de données/pièces jointes (1)/data-infra.xlsx")

A8 <- read_dta("C:/cours magistère 2/rapport économétrie/base de données/pièces jointes (1)/type.dta")

A9 <- read_dta("C:/cours magistère 2/rapport économétrie/base de données/pièces jointes (1)/capital humain2.dta")


A10 <- read_dta("C:/cours magistère 2/rapport économétrie/base de données/pièces jointes (1)/exportation.dta")

A11 <- read_dta("C:/cours magistère 2/rapport économétrie/base de données/pièces jointes (1)/importation.dta")


ide <- read_excel("C:/cours magistère 2/rapport économétrie/base de données/pièces jointes (1)/dt.xls")


A12 <- read_dta("C:/cours magistère 2/rapport économétrie/base de données/pièces jointes (1)/A1.dta")
A13 <- read_dta("C:/cours magistère 2/rapport économétrie/base de données/pièces jointes (1)/A2.dta")



A9$ISO <- countrycode(A9$cname, "country.name", "iso3c", warn = TRUE)

ide$ISO <- countrycode(ide$pays, "country.name.fr", "iso3c", warn = TRUE)
names(A10)

A1 <- select(A1, year, ISO, remittances, natural_rents
             ,gdp_usd, gdp_growth, gcf_gdp, credit_private)


A4 <- select(A4, year, countrycode, country, HC, HCQ, HCQ2)
A5 <- rename(A5, GDP_per_capita = `GDP per capita`)
A5 <- select(A5, year, ISO, GDP_per_capita)

A9 <- select(A9, year, ISO, cname, ccode_qog, pwt_hci)

gvc <- select(gvc, v1, year, ISO, dvx, fva, gvc)

ide <- select(ide, year, pays, ISO, flux_entr, stock_entr)
names(A5)

A4 <- rename(A4, ISO = countrycode)
A5 <- rename(A5, year = Time)


A5 <- A5 |>
  rename(year = Time , ISO = "Country Code")

data <- merge(gvc, A1, by = c("ISO", "year"), all.x = TRUE)

data <- merge(data, A2, by = c("ISO", "year"), all.x = TRUE)

data <- merge(data, A3, by = c("ISO", "year"), all.x = TRUE)

data <- merge(data, A4, by = c("ISO", "year"), all.x = TRUE)

data <- merge(data, A5, by = c("ISO", "year"), all.x = TRUE)

data <- merge(data, A6, by = c("ISO", "year"), all.x = TRUE)

data <- merge(data, A7, by = c("ISO", "year"), all.x = TRUE)

data <- merge(gvc, A8, by = c("ISO", "year"), all.x = TRUE)

data <- merge(data, A9, by = c("ISO", "year"), all.x = TRUE)

data <- merge(data, A10, by = c("ISO", "year"), all.x = TRUE)

data <- merge(data, A11, by = c("ISO", "year"), all.x = TRUE)

data <- merge(data, ide, by = c("ISO", "year"), all.x = TRUE)

data <- merge(A12, A13, by = c("ISO", "year"), all.x = TRUE)


str(data)

data <- read_dta("C:/cours magistère 2/rapport économétrie/base de données/pièces jointes (1)/base finale/base4.dta")

data$type <- data$type |>
  fct_recode(
    "High" = "High income",
    "Low" = "Low income",
    "LMI" = "Lower middle income",
    "UMI" = "Upper middle income"
  )

data1 <- select(data, -c(va_exp, dva, VA, RL, RQ, PS, Gov_eff, CC, "mobile_subs", "imports_gdp", "exports_gdp", "gfcf_private", "tariff_all", "hc", "electricity_access", "internet_users", "stock_entr", "stock_sort", "flux_sort", "pays", "Economy", "FDI"))
str(data1)
data$type <- as.character(data$type)
data1 <- select(data, -c("VA", "RL", "RQ", "PS", "Gov_eff", "CC"))
str(data1)

## Recodage de data1$year
data1$year <- data1$year |>
  as.character() |>
  fct_recode(
    "1990" = "1991",
    "1990" = "1992",
    "1990" = "1993",
    "1995" = "1994",
    "1995" = "1996",
    "1995" = "1997",
    "1995" = "1998",
    "2000" = "1999",
    "2000" = "2001",
    "2000" = "2002",
    "2000" = "2003",
    "2005" = "2004",
    "2005" = "2006",
    "2005" = "2007",
    "2005" = "2008",
    "2010" = "2009",
    "2010" = "2011",
    "2010" = "2012",
    "2010" = "2013",
    "2015" = "2014",
    "2015" = "2016",
    "2015" = "2017",
    "2015" = "2018"
  ) |>
  as.character() |>
  as.numeric()


base_d <- data1 |>
  arrange(v1, year) |>
  group_by(v1, year) |>
  summarise(ISO = first(ISO), type = first(type), flux_entr1 = first(flux_entr),
            stock_entr1 = first(stock_entr),
            across(where(is.numeric), mean, na.rm = TRUE),
            .groups = "drop")
base_d <- mutate(base_d, VA = ifelse(VA != "NaN" & VA != "-Inf", VA, "NA"),
                 RL = ifelse(RL != "NaN" & RL != "-Inf", RL, "NA"),
                 RQ = ifelse(RQ != "NaN" & RQ != "-Inf", RQ, "NA"),
                 PS = ifelse(PS != "NaN" & PS != "-Inf", PS, "NA"),
                 Gov_eff = ifelse(Gov_eff != "NaN" & Gov_eff != "-Inf", Gov_eff, "NA"),
                 CC = ifelse(CC != "NaN" & CC != "-Inf", CC, "NA")
                 )
                 


str(data1)

data1 <- mutate(base_d, 
                 lndvx = ifelse(log(dvx) != "NaN" & log(dvx) != "-Inf", log(dvx), "NA"), 
                 lnfva = ifelse(log(fva) != "NaN" & log(fva) != "-Inf", log(fva), "NA"), 
                 lngvc = ifelse(log(gvc) != "NaN" & log(gvc) != "-Inf", log(gvc), "NA"),
                 dvx = ifelse(dvx != "NaN" & dvx != "-Inf", dvx, "NA"),
                 fva = ifelse(fva != "NaN" & fva != "-Inf", fva, "NA"),
                 gvc = ifelse(gvc != "NaN" & gvc != "-Inf", gvc, "NA"),
                 remittances = ifelse(remittances != "NaN" & remittances != "-Inf", remittances, "NA"),
                 natural_rents = ifelse(natural_rents != "NaN" & natural_rents != "-Inf", natural_rents, "NA"),
                 gcf_gdp = ifelse(gcf_gdp != "NaN" & gcf_gdp != "-Inf", gcf_gdp, "NA"),
                 credit_private = ifelse(credit_private != "NaN" & credit_private != "-Inf", credit_private, "NA"),
                 GDP_per_capita = ifelse(GDP_per_capita != "NaN" & GDP_per_capita != "-Inf", GDP_per_capita, "NA"),
                 flux_entr = ifelse(flux_entr != "NaN" & flux_entr != "-Inf", flux_entr, "NA"),
                 ouverture = ifelse(ouverture != "NaN" & ouverture != "-Inf", ouverture, "NA"),
                 flux_entr1 = ifelse(flux_entr1 != "NaN" & flux_entr1 != "-Inf", flux_entr1, "NA"),
                 stock_entr = ifelse(stock_entr != "NaN" & stock_entr != "-Inf", stock_entr, "NA"),
                 stock_entr1 = ifelse(stock_entr1 != "NaN" & stock_entr1 != "-Inf", stock_entr1, "NA"),
                 gdp_usd = ifelse(gdp_usd != "NaN" & gdp_usd != "-Inf", gdp_usd, "NA"),
                 gdp_growth = ifelse(gdp_growth != "NaN" & gdp_growth != "-Inf", gdp_growth, "NA"),
                 HC = ifelse(HC != "NaN" & HC != "-Inf", HC, "NA"),
                 HCQ = ifelse(HCQ != "NaN" & HCQ != "-Inf", HCQ, "NA"),
                 HCQ2 = ifelse(HCQ2 != "NaN" & HCQ2 != "-Inf", HCQ2, "NA"),
                 ccode_qog = ifelse(ccode_qog != "NaN" & ccode_qog != "-Inf", ccode_qog, "NA"),
                 pwt_hci = ifelse(pwt_hci != "NaN" & pwt_hci != "-Inf", pwt_hci, "NA"),
                 exportation = ifelse(exportation != "NaN" & exportation != "-Inf", exportation, "NA"),
                 importation = ifelse(importation != "NaN" & importation != "-Inf", importation, "NA"),
                 gdp_millier = ifelse(gdp_millier != "NaN" & gdp_millier != "-Inf", gdp_millier, "NA"))
                 
                 
                 
                 


data1 <- data1 |>
  mutate(across(flux_entr1:ouverture, as.numeric))  
                 
                 
data1 <- mutate(data1, gdp_millier = gdp_usd/1000,
                ouverture = ((importation + exportation)/gdp_millier)*100
)


data1 %>%
  filter(is.na(as.numeric(flux_entr1)))










base_d <- data1 |>
  group_by(v1, year) |>
  summarise(ISO = first(ISO), type = first(type), 
            across(where(is.numeric), mean, na.rm = TRUE),
            .groups = "drop")
base_d <- mutate(base_d, 
  lndvx = ifelse(log(dvx) != "NaN" & log(dvx) != "-Inf", log(dvx), "NA"), 
  lnfva = ifelse(log(fva) != "NaN" & log(fva) != "-Inf", log(fva), "NA"), 
  lngvc = ifelse(log(gvc) != "NaN" & log(gvc) != "-Inf", log(gvc), "NA"),
  dvx = ifelse(dvx != "NaN" & dvx != "-Inf", dvx, "NA"),
   fva = ifelse(fva != "NaN" & fva != "-Inf", fva, "NA"),
   gvc = ifelse(gvc != "NaN" & gvc != "-Inf", gvc, "NA"),
   remittances = ifelse(remittances != "NaN" & remittances != "-Inf", remittances, "NA"),
    natural_rents = ifelse(natural_rents != "NaN" & natural_rents != "-Inf", natural_rents, "NA"),
     gcf_gdp = ifelse(gcf_gdp != "NaN" & gcf_gdp != "-Inf", gcf_gdp, "NA"),
     credit_private = ifelse(credit_private != "NaN" & credit_private != "-Inf", credit_private, "NA"),
     GDP_per_capita = ifelse(GDP_per_capita != "NaN" & GDP_per_capita != "-Inf", GDP_per_capita, "NA"),
      mean_year_schooling = ifelse(mean_year_schooling != "NaN" & mean_year_schooling != "-Inf", mean_year_schooling, "NA"),
      flux_entr = ifelse(flux_entr != "NaN" & flux_entr != "-Inf", flux_entr, "NA"),
     open = ifelse(open != "NaN" & open != "-Inf", open, "NA"),
  natural_rents_percent = ifelse(natural_rents_percent != "NaN" & natural_rents_percent != "-Inf", natural_rents_percent, "NA"),
  flux_entr_varia = ifelse(flux_entr_varia != "NaN" & flux_entr_varia != "-Inf", flux_entr_varia, "NA")
  
)

str(base_d)
base_d <- mutate(base_d, year = as.numeric(as.character(year)),
                 across(flux_entr_varia:natural_rents_percent, as.numeric))


base_d <- as.data.frame(base_d)


base_d <- mutate(base_d, type = as.character(type))


data1 <- arrange(data1, v1, year)

data <- mutate(data, open = imports_gdp + exports_gdp)


write_dta(AA, "C:/cours magistère 2/rapport économétrie/base de données/pièces jointes (1)/base finale/tarrif.dta")
statdim(count(group_by(data, v1)))


gouvernance2 <- read_dta("C:/cours magistère 2/rapport économétrie/base de données/pièces jointes (1)/base finale/gouvernance2.dta")


## Statistiques descriptive ----



summary(data)


# matrice de corrélation
Matrice_de_correlation <- cor(data, use = "complete.obs")
corrplot(Matrice_de_correlation, method = "color", type = "upper", order = "hclust",
         tl.col = "black", tl.srt = 45,
         addCoef.col = "black",
         cl.pos = "n",
         cl.cex = 1.2,
         addCoefasPercent = TRUE, 
         number.cex = 1)





## période 2014 - 2018



str(gouvernance2)


gouvernance2 <- gouvernance2 |>
  mutate(across(VA:CC, as.numeric))

base1 <- select(gouvernance2, v1, ISO, type,  year, VA, RL, RQ, PS, Gov_eff, CC)

base <- filter(base1, year == 2015)

base <- base[complete.cases(base),]

base2 <- filter(base1, year != 2015, year != 1990)

base2 <- base2[complete.cases(base2),]

n_t <- nrow(base)

base3 <- rbind(base, base2)

base3 <- as.data.frame(base3)

rownames(base3) <- paste(base3$ISO, base3$year, sep = ".")





n_distinct(gouvernance2$ISO)
acpind15$eig

acpind15 <- PCA(base3[,3:10],
                scale.unit = TRUE,
                quali.sup = 1 ,
                quanti.sup = 2, 
                ind.sup = (n_t + 1):nrow(base3) ,
                graph = FALSE)
a <- as.data.frame(acpind15$ind.sup$coord[,1]) 
a$v1 <- base2$v1
a$year <- base2$year


coord_ind = as.data.frame(acpind15$ind$coord)
coord_ind$v1 = base$v1
coord_ind$year = base$year

coord_ind_sup = as.data.frame(acpind15$ind.sup$coord)
coord_ind_sup$v1 = base2$v1
coord_ind_sup$year = base2$year


# barycentres des individus supplémentaires par année
coord_sup_annee = coord_ind_sup |>
  group_by(year) |>
  summarise(Dim.1 = mean(Dim.1),
            Dim.2 = mean(Dim.2),
            .groups = "drop")


coord_sup_ind = coord_ind_sup |>
  group_by(v1) |>
  summarise(Dim.1 = mean(Dim.1),
            Dim.2 = mean(Dim.2),
            .groups = "drop")


# représentation des axes
 fviz_eig(acpind15,
         addlabels = TRUE,
         ylim = c(0, 100),
         main = "Pourcentage d'information expliqué par les axes")



 acpind15$eig

ggplot(coord_ind_sup, aes(x = Dim.1, y = Dim.2)) +
  geom_point(alpha = 0.10, color = "grey70") +
  geom_point(data = coord_sup_annee, color = "black", size = 2) +
  geom_text(data = coord_sup_annee, aes(label = year),
            size = 3, vjust = -0.5) +
  labs(title = "ACP sur les moyennes par État",
       subtitle = "Années réelles projetées comme individus supplémentaires",
       x = "Dim1 (52.1%)",
       y = "Dim2 (17.6%)") +
  theme_minimal()



# graph individus supp et cercle des corr

 ggplot(coord_ind_sup, aes(x = Dim.1, y = Dim.2)) +
  geom_point(alpha = 0.10, color = "grey70") +
  geom_point(data = coord_sup_ind, color = "red", size = 2) +
  geom_text(data = coord_sup_ind, aes(label = v1),
            color = "red", size = 2.5, vjust = -0.4) +
  labs(title = "ACP panel - Plan 1-2",
       subtitle = "Points nommés par état",
       x = "Dim1 (88.9%)",
       y = "Dim2 (4.6%)") +
  theme_minimal()

 fviz_pca_var(acpind15,
                  repel = TRUE,
                  title = "Cercle des corrélations gouvernance")

p1 + p2 + plot_layout(ncol = 2, widths = c(1.2, 1))


p1

acpind15$var$cos2



# graphique de la contribution des variables
fviz_pca_var(acpind15, axes = c(1,2), col.var = "cos2",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE)

# Cercle des corrélations pour les axes 1 et 3
fviz_pca_var(acpind15, axes = c(1,3), col.var = "cos2",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE)

# Cercle des corrélations pour les axes 2 et 3
fviz_pca_var(acpind15, axes = c(2,3), col.var = "cos2",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE)

# graphique des individus

fviz_pca_ind(acpind15,
            # col.ind = "blue",
             select.ind = list(contrib = 50),
             #col.ind.sup = "red",
             habillage = "type",
             repel = TRUE  )




# contribution et représentation
fviz_contrib(acpind15, choice = "var", axes = 1)
fviz_contrib(acpind15, choice = "var", axes = 2)



fviz_cos2(acpind15, choice = "var", axes = 1)
fviz_cos2(acpind15, choice = "var", axes = 2)


# graphique des individus et des variables
fviz_pca_biplot(acpind15,
                select.ind = c(list(cos2 =40) ),  
                select_var = list(cos2 = 0.5),
                col.ind = "blue",
                col.var ="red",
                repel = TRUE
               # col.quanti.sup = "blue"
              
)


fviz_pca_biplot(acpind15,
                select.ind = list(contrib = 20),
                select.var = list(contrib = 5),
                col.ind = "blue",
                col.var = "red",
                col.quanti.sup = "green",
                repel = TRUE)



fviz_pca_biplot(acpind15,
                select.ind = list(cos2 = 0.5),
                select_var = list(cos2 = 0.5),
                col.ind = "blue",
                col.var = "red",
                repel = TRUE)

fviz_pca_biplot(acpind15,
                select.ind = list(name = setdiff(rownames(acpind15$ind$coord),
                                                 rownames(acpind15$ind.sup$coord))))



fviz_pca_biplot(acpind15,
                habillage = 1,
               # addEllipses = TRUE,
                repel = TRUE,
               col.var = "red",
                select.ind = list(name = setdiff(rownames(acpind15$ind$coord),
                                                 rownames(acpind15$ind.sup$coord))))














## Panels déséquilibré


indice <- select(rbind(coord_ind_sup, coord_ind), Dim.1, v1, year)

data2 <- merge(data1, indice, by = c("v1", "year"), all.x = TRUE)

data2 <- rename(data2, indice = Dim.1)


data1 <- select(data, v1, ISO,
        , HCQ,HCQ2 , ccode_qog, pwt_hci, exportation, importation,
        stock_entr, gdp_millier, lngvc, type, year, credit_private, HC, lndvx, lnfva, 
        gdp_growth, HCQ2, everything())



data1 <- select(data1, -c("lndvx", "lnfva", "lngvc", "flux_entr1", "stock_entr1",
            "HCQ", "HCQ2", "ccode_qog", "pwt_hci", "exportation", "importation",
    "stock_entr", "gdp_millier", "gdp_usd", "credit_private",
    "gcf_gdp", "GDP_per_capita", "gvc"))

data6 <- arrange(data5, v1, year)


data1 <- data1 %>%
  group_by(year) %>%
  mutate(
    min_ind = min(indice, na.rm = TRUE),
    max_ind = max(indice, na.rm = TRUE),
    indice1 = 100 * (indice - min_ind) / (max_ind - min_ind)
  ) %>%
  ungroup()
data1 <- select(data1, -min_ind, -max_ind, -indice)


data3 <- filter(data1, year == 2015)


data3 <- data3[complete.cases(data3),]



data4 <- filter(data1, year != 2015, year != 1990)

data4 <- data4[complete.cases(data4),]

n_t <- nrow(data3)


data5 <- rbind(data3, data4)


data5 <- as.data.frame(data5)

rownames(data5) <- paste(data5$ISO, data5$year, sep = ".")

nrow(base)
dim(data5)

acppan <- PCA(data5[,3:13],
                scale.unit = TRUE,
                quali.sup = 1,
                quanti.sup = 2, 
                ind.sup = (n_t + 1):nrow(data5) ,
                graph = FALSE)


coord_indi = as.data.frame(acppan$ind$coord)
coord_indi$v1 = data3$v1
coord_indi$year = data3$year

coord_indi_sup = as.data.frame(acppan$ind.sup$coord)
coord_indi_sup$v1 = data4$v1
coord_indi_sup$year = data4$year


# barycentres des individus supplémentaires par année
coord_supe_annee <- coord_indi_sup |>
  group_by(year) |>
  summarise(Dim.1 = mean(Dim.1),
            Dim.2 = mean(Dim.2),
            .groups = "drop")


coord_sup_indi <- coord_indi_sup |>
  group_by(v1) |>
  summarise(Dim.1 = mean(Dim.1),
            Dim.2 = mean(Dim.2),
            .groups = "drop")


# Pourcentage d'information expliqué par les axes
fviz_eig(acppan,
         addlabels = TRUE,
         ylim = c(0, 100),
         main = "Pourcentage d'information expliqué par les axes")

acppan$eig

# Cercle des corrélations pour les axes 1 et 2
fviz_pca_var(acppan,
             axes = c(1,2),
             col.var = "cos2",
             gradient.cols = c("lightblue", "blue", "darkblue"),
             #col.quanti.sup = "blue",
             #select.var = list(cos2 =  0.5),
             repel = TRUE)

# Cercle des corrélations pour les axes 1 et 2
fviz_pca_var(acppan,
             axes = c(2,3),
             col.var = "cos2",
             gradient.cols = c("lightblue", "blue", "darkblue"),
             repel = TRUE)

# Cercle des corrélations pour les axes 2 et 3
fviz_pca_var(acppan,
             axes = c(1,3),
             col.var = "cos2",
             gradient.cols = c("lightblue", "blue", "darkblue"),
             repel = TRUE)



# Graphique des individus en nommant les points par état
fviz_pca_ind(
  acppan,
  axes = c(1,2),
  habillage = "type",
  #geom = "point",
  #pointshape = 16
)


fviz_pca_biplot(acppan,
                col.ind = "black",
                col.ind.sup = "red",
                col.var = "blue",
                col.quanti.sup = "green")


# graphique individu variable
fviz_pca_biplot(acppan,
                select.ind = c(list(contrib =45) ),  
                select_var = list(cos2 = 0.5),
                col.ind = "blue",
                col.var ="black",
                repel = TRUE,
                habillage = "type",
                #label = "none"
                # col.quanti.sup = "blue"
                
)

acppan$var$cos2



# Graphique avec quali supplem
fviz_pca_ind(acppan,
  label = "none",
  axes = c(1,2),
  col.ind = data3$type,
  palette = "jco",
  addEllipses = T,
  geom = "point",
  pointshape = 16
)



fviz_pca_var(acppan,
             axes = c(1,2),
             col.var = "cos2",
             col.quanti.sup = "red",
             gradient.cols = c("lightblue", "blue", "darkblue"),
             repel = TRUE)



fviz_pca_var(acppan,
             axes = c(1,2),
             col.var = "cos2",
             gradient.cols = c("lightblue", "blue", "darkblue"),
             repel = TRUE) +
  geom_point(data = as.data.frame(acppan$quanti.sup$coord),
             aes(x = Dim.1, y = Dim.2),
             color = "red", size = 3)

# graph année

ggplot(coord_indi_sup, aes(x = Dim.1, y = Dim.2)) +
  geom_point(alpha = 0.10, color = "grey70") +
  geom_point(data = coord_supe_annee, color = "black", size = 2) +
  geom_text(data = coord_supe_annee, aes(label = year),
            size = 3, vjust = -0.5) +
  labs(title = "ACP sur les moyennes par État",
       subtitle = "Années réelles projetées comme individus supplémentaires",
       x = "Dim1 ()",
       y = "Dim2 ()") +
  theme_minimal()

acppan$var$cos2

# graph individu et variable

fviz_pca_biplot(acppan,
                habillage = 1,
                # addEllipses = TRUE,
                repel = TRUE,
                col.var = "black",
                select.ind = list(name = setdiff(rownames(acpind15$ind$coord),
                                                 rownames(acpind15$ind.sup$coord))))




# graph individus supp et cercle des corr

ggplot(coord_indi_sup, aes(x = Dim.1, y = Dim.2)) +
  geom_point(alpha = 0.10, color = "grey70") +
  geom_point(data = coord_sup_indi, color = "red", size = 2) +
  geom_text(data = coord_sup_indi, aes(label = v1),
            color = "red", size = 2.5, vjust = -0.4) +
  labs(title = "ACP panel - Plan 1-2",
       subtitle = "Points nommés par état",
       x = "Dim1 ()",
       y = "Dim2 ()") +
  theme_minimal()

fviz_pca_var(acppan,
             repel = TRUE,
             title = "Cercle des corrélations - Panel complet")

p1 + p2 + plot_layout(ncol = 2, widths = c(1.2, 1))











#  graph variable supplémentaire


# coordonnées des variables actives
coord_var = as.data.frame(acppan$var$coord)
coord_var$var = rownames(coord_var)

# coordonnées de year
coord_year = as.data.frame(acppan$quanti.sup$coord)
coord_year$var = c("year", "lndvx", "lngvc", "lnfva")

ggplot() +
  geom_segment(data = coord_var,
               aes(x = 0, y = 0, xend = Dim.1, yend = Dim.2),
               arrow = arrow(length = unit(0.2, "cm")),
               color = "black") +
  geom_text(data = coord_var,
            aes(x = Dim.1, y = Dim.2, label = var),
            color = "black", size = 4, vjust = -0.4) +
  geom_segment(data = coord_year,
               aes(x = 0, y = 0, xend = Dim.1, yend = Dim.2),
               arrow = arrow(length = unit(0.2, "cm")),
               color = "red") +
  geom_text(data = coord_year,
            aes(x = Dim.1, y = Dim.2, label = var),
            color = "red", size = 4, vjust = -0.4) +
  annotate("path",
           x = cos(seq(0, 2*pi, length.out = 200)),
           y = sin(seq(0, 2*pi, length.out = 200)),
           color = "grey60") +
  coord_fixed() +
  xlim(-1, 1) +
  ylim(-1, 1) +
  labs(title = "Cercle des corrélations avec year comme variable supplémentaire",
       x = "Dim1",
       y = "Dim2") +
  theme_minimal()







