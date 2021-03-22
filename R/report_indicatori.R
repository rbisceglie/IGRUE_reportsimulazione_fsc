# crea report indicatori --------------------------------------------
wb <- createWorkbook()

foglio1 <- addWorksheet(wb, "Validazione")
foglio2 <- addWorksheet(wb, "Simulazione")

for (i in x) {
  n <- which(i == x)
  writeData(wb, n, dataframe$report_indicatori[[i]], rowNames = F)
  addStyle(wb, n, headerStyle, rows = 1, cols = 1:ncol(dataframe$report_indicatori[[i]]), gridExpand = T)
  setColWidths(wb, n, cols = 1:ncol(dataframe$report_indicatori[[i]]), widths = "25")
}


#writeData(wb, 1, dataframe$report_indicatori$NEW, rowNames = F)
#writeData(wb, 2, dataframe$report_indicatori$OLD, rowNames = F)
#
#addStyle(wb, 1, headerStyle, rows = 1, cols = 1:ncol(dataframe$report_indicatori$NEW), gridExpand = T)
#addStyle(wb, 2, headerStyle, rows = 1, cols = 1:ncol(dataframe$report_indicatori$OLD), gridExpand = T)
#setColWidths(wb, 1, cols = 1:ncol(dataframe$report_indicatori$NEW), widths = "auto")
#setColWidths(wb, 2, cols = 1:ncol(dataframe$report_indicatori$OLD), widths = "auto")

# scrivi xlsx ======================================================================
saveWorkbook(wb, paste0("output/", fondo, "_simulazione_indicatori_",current_date ,".xlsx"), overwrite = T)
