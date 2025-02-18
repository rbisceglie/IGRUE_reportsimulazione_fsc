# crea report percettori --------------------------------------------
wb <- createWorkbook()

foglio1 <- addWorksheet(wb, "Validazione")
foglio2 <- addWorksheet(wb, "Simulazione")

for (i in x) {
  n <- which(i == x)
  writeData(wb, n, dataframe$report_percettori[[i]], rowNames = F)
  addStyle(wb, n, headerStyle, rows = 1, cols = 1:ncol(dataframe$report_percettori[[i]]), gridExpand = T)
  setColWidths(wb, n, cols = 1:ncol(dataframe$report_percettori[[i]]), widths = "25")
}

# scrivi xlsx ======================================================================
saveWorkbook(wb, paste0("output/", fondo, "_simulazione_percettori_",current_date ,".xlsx"), overwrite = T)
