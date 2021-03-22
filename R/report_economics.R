# crea report simulazione economica --------------------------------------------
wb <- createWorkbook()

foglio1 <- addWorksheet(wb, "Analitico per Asse")
foglio2 <- addWorksheet(wb, "Analitico per Bando")
foglio3 <- addWorksheet(wb, "Analitico per Pratica Validato")
foglio4 <- addWorksheet(wb, "Analitico per Pratica Simulato")

# scrivi Asse ===================================================================

writeData(wb, 1, "Validazione precedente", xy = c(1,1), rowNames = F)
writeData(wb, 1, dataframe$report_asse$OLD, xy = c(1,2), rowNames = F)
addStyle(wb, sheet = 1, headerStyle, rows = c(1:2,10), cols = 1:ncol(dataframe$report_asse$OLD), gridExpand = T)
addStyle(wb, sheet = 1, numberStyle, rows = 3:9, cols = 2:ncol(dataframe$report_asse$OLD), gridExpand = T)
addStyle(wb, sheet = 1, totalStyle, rows = 10, cols = 2:ncol(dataframe$report_asse$OLD), gridExpand = T)
setColWidths(wb, 1, cols = 1:ncol(dataframe$report_asse$OLD), widths = "20")

writeData(wb, 1, "Simulazione in corso", xy = c(1,12), rowNames = F)
writeData(wb, 1, dataframe$report_asse$NEW, xy = c(1,13), rowNames = F)
addStyle(wb, sheet = 1, headerStyle, rows = c(12:13,21), cols = 1:ncol(dataframe$report_asse$NEW), gridExpand = T)
addStyle(wb, sheet = 1, numberStyle, rows = 14:20, cols = 2:ncol(dataframe$report_asse$NEW), gridExpand = T)
addStyle(wb, sheet = 1, totalStyle, rows = 21, cols = 2:ncol(dataframe$report_asse$OLD), gridExpand = T)
setColWidths(wb, 1, cols = 1:ncol(dataframe$report_asse$OLD), widths = "20")

# scrivi Bando =====================================================================
delta <- dataframe$report_bando$NEW %>%
  left_join(dataframe$report_bando$OLD, by = c("ASSE", "COD_BANDO", "BANDO"))

intestazione <- data.frame(x = "ASSE", y = "COD_BANDO", z = "BANDO")
etichette <- data.frame(k = "CONCESSO", J = "IMPEGNATO", W = "CERTIFICATO", x = "LIQUIDATO", y = "IMPEGNATO_TR", z = "LIQUIDATO_TR")
sim <- "Simulazione in corso"
val <- "Validazione precedente"
del <- "Delta"
num_righe <- as.character(nrow(delta)+3)

writeData(wb, 2, sim, xy = c(4,2), rowNames = F, colNames = F)
writeData(wb, 2, val, xy = c(10,2), rowNames = F, colNames = F)
writeData(wb, 2, del, xy = c(16,2), rowNames = F, colNames = F)
writeData(wb, 2, intestazione, xy = c(1,3), rowNames = F, colNames = F)
writeData(wb, 2, etichette, xy = c(4,3), rowNames = F, colNames = F)
writeData(wb, 2, etichette, xy = c(10,3), rowNames = F, colNames = F)
writeData(wb, 2, etichette, xy = c(16,3), rowNames = F, colNames = F)


addStyle(wb, sheet = 2, totalStyle, rows = 1, cols = 1:21, gridExpand = T)
addStyle(wb, sheet = 2, headercenteredStyle, rows = 2, cols = 1:21, gridExpand = T)
addStyle(wb, sheet = 2, headerStyle, rows = 3, cols = 1:21, gridExpand = T)

mergeCells(wb,2, cols = 4:9, rows = 2)
mergeCells(wb,2, cols = 10:15, rows = 2)
mergeCells(wb,2, cols = 16:21, rows = 2)

writeData(wb, 2, delta, xy = c(1,4), rowNames = F, colNames = F)

for (i in LETTERS[4:21]) {
  n <- which(i == LETTERS[4:21]) + 3
  writeFormula(wb, 2, x = paste0("=SUBTOTAL(9,",i ,"4:", i, num_righe, ")"), xy = c(n,1))
}

for (i in LETTERS[16:21]) {
  for (j in 4:num_righe) {  
    n <- which(i == LETTERS[16:21]) + 15
    f <- LETTERS[(n-12)]
    s <- LETTERS[(n-6)]
    writeFormula(wb, 2, x = paste0("=(",f,j,"-",s,j,")"), xy = c(n,j))
  }
}
rm(i,j,n,f,s)

setColWidths(wb, 2, cols = 1, widths = "6")
setColWidths(wb, 2, cols = 2, widths = "20")
setColWidths(wb, 2, cols = 3, widths = "30")
setColWidths(wb, 2, cols = 4:21, widths = "20")

addStyle(wb, sheet = 2, simulazioneStyle, rows = 4:num_righe, cols = 4:9, gridExpand = T)
addStyle(wb, sheet = 2, validazioneStyle, rows = 4:num_righe, cols = 10:15, gridExpand = T)
addStyle(wb, sheet = 2, deltaStyle, rows = 4:num_righe, cols = 16:21, gridExpand = T)

# scrivi Pratica ===================================================================
writeData(wb, 3, dataframe$report_pratica$OLD, xy = c(1,1), rowNames = F)
addStyle(wb, sheet = 3, headerStyle, rows = 1, cols = 1:ncol(dataframe$report_pratica$OLD), gridExpand = T)
addStyle(wb, sheet = 3, numberStyle, rows = 2:nrow(dataframe$report_pratica$NEW)+1, cols = 6:11, gridExpand = T)
setColWidths(wb, 3, cols = 1:ncol(dataframe$report_pratica$OLD), widths = "20")

writeData(wb, 4, dataframe$report_pratica$NEW, xy = c(1,1), rowNames = F)
addStyle(wb, sheet = 4, headerStyle, rows = 1, cols = 1:ncol(dataframe$report_pratica$NEW), gridExpand = T)
addStyle(wb, sheet = 4, numberStyle, rows = 2:nrow(dataframe$report_pratica$NEW)+1, cols = 6:11, gridExpand = T)
setColWidths(wb, 4 , cols = 1:ncol(dataframe$report_pratica$OLD), widths = "20")

# scrivi xlsx ======================================================================
saveWorkbook(wb, paste0("output/", fondo, "_simulazione_finanziario_",current_date ,".xlsx"), overwrite = T)
