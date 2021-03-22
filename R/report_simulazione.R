# configurazioni -------------------------------------------------------------
fondo = "FSC"
dsn_igrue_old = "FSC_official" #FESR_official
dsn_igrue_new = "FSC_official"#"FESR_simulazione"
x <- c("OLD", "NEW")
pvl03 <- "G:\\Il Mio Drive\\Monitoraggio\\IGRUE\\FESR\\Invio\\2021_01\\validazione\\VLD-03_XLS_311551.xls" # path e file excel del report di prevalidazione/validazione 03

# carica sorgenti ------------------------------------------------------------

source("R/00_librerie.R")
source("R/01a_connessioni_igrue.R")
#source("R/01b_connessioni_siage.R")
#source("R/certificato_gen_2021.R")
source("R/02_dataframe.R")
source("R/report_stili_excel.R")

# genera reports -------------------------------------------------------------
source("R/report_economics.R")
source("R/report_indicatori.R")
source("R/report_procedurale.R")
source("R/report_beneficiari.R")
source("R/report_percettori.R")
source("R/report_percettori_impegni.R")
