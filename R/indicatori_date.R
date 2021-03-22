# configurazioni -------------------------------------------------------------
fondo = "FESR"
dsn_igrue_old = "FESR_official" #FESR_official
dsn_igrue_new = "FESR_official"#"FESR_simulazione"
x <- c("OLD", "NEW")
pvl03 <- "G:\\Il Mio Drive\\Monitoraggio\\IGRUE\\FESR\\Invio\\2020_09\\prevalidazione\\PVL-03_XLS_302399.xls" # path e file excel del report di prevalidazione/validazione 03

# carica sorgenti ------------------------------------------------------------

source("R/00_librerie.R")
source("R/01a_connessioni_igrue.R")
source("R/02_dataframe.R")
library(xlsx)

indicatori <- dataframe$report_indicatori$NEW %>%
  left_join(dataframe$report_procedurale$NEW, by = c("ASSE","COD_BANDO","ID_PRATICA", "BANDO", "TITOLO_PROGETTO")) 

write.xlsx(indicatori, "output/indicatori_date.xlsx", sheetName = "indicatori", row.names = F)
