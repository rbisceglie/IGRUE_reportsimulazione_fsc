# connessione siage =============================================

jdbcDriver <- RJDBC::JDBC(driverClass="oracle.jdbc.OracleDriver", classPath="lib/ojdbc8.jar")

agora <- dbConnect(jdbcDriver, 
                   "jdbc:oracle:thin:@//10.220.128.10:1535/AGORAP",
                   "rbisceglie", 
                   "password01*",
                   default.schemas = "AGORA")

query <- "SELECT MON_PRAT_ID, MON_AZ_RICH_DENOM, MON_AZ_RICH_COD_FISC 
FROM AGORA.MV_AG_MON_RICHIEDENTE
LEFT JOIN AGORA.MV_AG_MON_ANAGRAFICA USING(MON_STR_ATT, MON_INST_ID)"

richiedente <- as_tibble(dbGetQuery(agora, query))

dbDisconnect(agora)
