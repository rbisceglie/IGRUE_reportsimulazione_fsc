# caricamento dump igrue ------------------------------------------------------------
igrue_old <- dbPool(
  drv = odbc::odbc(),
  dsn = dsn_igrue_old
  #drv = RSQLite::SQLite(),
  #dbname = choose.files(caption="Seleziona Dump IGRUE")
  #host = choose.files(caption="Seleziona Dump IGRUE"),
  #username = "guest",
  #password = "guest"
)

# caricamento dump igrue ------------------------------------------------------------
igrue_new <- dbPool(
  drv = odbc::odbc(),
  dsn = dsn_igrue_new
  #drv = RSQLite::SQLite(),
  #dbname = choose.files(caption="Seleziona Dump IGRUE")
  #host = choose.files(caption="Seleziona Dump IGRUE"),
  #username = "guest",
  #password = "guest"
)
# caricamento dump TC ---------------------------------------------------------------
tc <- dbPool(
  drv = odbc::odbc(),
  dsn = "IGRUE_TC"
  #drv = RSQLite::SQLite(),
  #dbname = choose.files(caption="Seleziona Dump TC")
  #host = choose.files(caption="Seleziona Dump TC"),
  #username = "guest",
  #password = "guest"
)

# caricamento tabelle da dump --------------------------
OLD <- list()  
for (i in dbListTables(igrue_old)) {
  OLD[[i]] <- as.data.frame(tbl(igrue_old, i))
}

NEW <- list()
for (i in dbListTables(igrue_new)) {
  NEW[[i]] <- as.data.frame(tbl(igrue_new, i))
}

TC <- list()
for (i in dbListTables(tc)) {
  TC[[i]] <- as.data.frame(tbl(tc, i))
}

IGRUE <- list(OLD = OLD, NEW = NEW, TC = TC)

poolClose(igrue_old)
poolClose(igrue_new)
poolClose(tc)

rm(OLD, NEW, TC, igrue_new, igrue_old, tc, i, dsn_igrue_new, dsn_igrue_old)

