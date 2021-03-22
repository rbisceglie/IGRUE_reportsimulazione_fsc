# inizializzo architettura dataframe --------------------------------------------
df <- list(OLD = tibble(), NEW = tibble())

dataframe <- list(
  progetti_attivi = df,
  progetti_non_attivi = df,
  mappa_livello_gerarchico = df,
  bandi = df,
  mappa_pratica_pratt = df,
  mappa_pratica_bando = df,
  mappa_pratica_asse = df,
  stato_progetto = df,
  concesso = df,
  impegnato = df,
  liquidato = df,
  certificato = df
)

rm(df)

# dataframe generali indicatori -------------------------------------------------
dataframe$indicatori_comuni <- IGRUE$TC$TC44 %>%
  mutate(
    COD_INDICATORE_OUT=
      case_when(
        str_length(COD_INDICATORE) <= 4 & (str_sub(COD_INDICATORE,1,1) == "1" | str_sub(COD_INDICATORE,1,1) == "2") ~ str_replace(COD_INDICATORE,"[:digit:]","CO"), 
        TRUE ~ "")) %>%
  mutate(COD_INDICATORE_OUT = case_when(COD_INDICATORE_OUT == "" ~ COD_INDICATORE, TRUE ~ COD_INDICATORE_OUT)) %>%
  select(COD_INDICATORE, COD_INDICATORE_OUT, DESCRIZIONE_INDICATORE, UNITA_MISURA, DESC_UNITA_MISURA)

dataframe$indicatori_specifici <- IGRUE$TC$TC45 %>%
  select(COD_INDICATORE, COD_INDICATORE_OUT, DESCRIZIONE_INDICATORE, UNITA_MISURA, DESC_UNITA_MISURA)

dataframe$indicatori_descrizioni <- rbind(dataframe$indicatori_specifici, dataframe$indicatori_comuni)

# dataframe generali --------------------------------------------------------------------------------------------
# progetti_attivi AP04 dove STATO = 1 --> progetti_attivi ===================================================
for (i in x) {
  dataframe$progetti_attivi[[i]] <- IGRUE[[i]]$AP04 %>%
    filter(STATO == "1" & COD_PROGRAMMA != '2014IT05SFOP007') %>% 
    left_join(IGRUE[[i]]$AP00, by = "COD_LOCALE_PROGETTO") %>%
    filter(FLG_CANCELLAZIONE != "S") %>%
    select(COD_LOCALE_PROGETTO)

    
#  dataframe$progetti_attivi[["NEW"]] <- IGRUE[["NEW"]]$AP04 %>%
#    filter(STATO == "1") %>% 
#    left_join(IGRUE[["NEW"]]$AP00, by = "COD_LOCALE_PROGETTO") %>%
#    filter(FLG_CANCELLAZIONE != "S") %>%
#    select(COD_LOCALE_PROGETTO)


# progetti_non_attivi AP04 dove STATO = 1 --> progetti_attivi ===================================================
  dataframe$progetti_non_attivi[[i]] <- IGRUE[[i]]$AP04 %>%
    filter(STATO != "1" | COD_PROGRAMMA == '2014IT05SFOP007') %>% 
    left_join(IGRUE[[i]]$AP00, by = "COD_LOCALE_PROGETTO") %>%
    filter(FLG_CANCELLAZIONE != "S") %>%
    select(COD_LOCALE_PROGETTO)

# mappa_scarti ===============================================================
  dataframe$mappa_scarti <- readxl::read_excel(pvl03, sheet = 1, skip = 12) %>%
    distinct(`Codice Identificativo`) %>%
    rename(COD_LOCALE_PROGETTO = `Codice Identificativo`) %>%
    mutate(COD_LOCALE_PROGETTO = str_remove(COD_LOCALE_PROGETTO, "LO-6-")) %>%
    mutate(COD_LOCALE_PROGETTO = str_trim(COD_LOCALE_PROGETTO, side = c("both", "left", "right")))

# mappa_livello_gerarchico ===================================================================================
# mappa decodifica COD_LIVELLO_GERARCHICO
  dataframe$mappa_livello_gerarchico[[i]] <- IGRUE[[i]]$FN01 %>%
    filter(COD_LOCALE_PROGETTO %in% dataframe$progetti_attivi[[i]]$COD_LOCALE_PROGETTO & FLG_CANCELLAZIONE != "S") %>%
    select(COD_LOCALE_PROGETTO, COD_LIV_GERARCHICO) %>%
    left_join(IGRUE$TC$TC36, by = "COD_LIV_GERARCHICO") %>%
    separate(VALORE_DATI_RILEVATI,c("COD_PROGRAMMA", "PROGRAMMA", "TIPO_REGIONE", "ASSE", "OT", "PI", "OS"), sep = "#") %>%
    separate(DESCRIZIONE_CODICE_LIVELLO_GERARCHICO, c("COD_PROGRAMMA_DESCRIZIONE", "PROGRAMMA_DESCRIZIONE", "TIPO_REGIONE_DESCRIZIONE", "ASSE_DESCRIZIONE", "OT_DESCRIZIONE", "PI_DESCRIZIONE", "OS_DESCRIZIONE"), sep = "\\\\") %>%
    mutate(ASSE = paste(TIPO_REGIONE, " - ", ASSE), 
           ASSE_DESCRIZIONE = paste(TIPO_REGIONE, " - ", TIPO_REGIONE_DESCRIZIONE ," - ",ASSE_DESCRIZIONE),
           PI_DESCRIZIONE = paste(PI, " - ", PI_DESCRIZIONE)) %>%
    select(COD_LOCALE_PROGETTO, COD_PROGRAMMA, ASSE, ASSE_DESCRIZIONE, PI_DESCRIZIONE, OT, OT_DESCRIZIONE) %>%
    mutate(OT=recode(OT, "N.A." = ""))

# bandi =======================================================================================================
  dataframe$bandi[[i]] <- IGRUE[[i]]$PA00 %>% 
    select(COD_PROC_ATT,COD_PROC_ATT_LOCALE,DESCR_PROCEDURA_ATT, `DATA AVVIO PROCEDURA`, `DATA FINE PROCEDURA`)


# mappa_pratica_pratt =========================================================================================

  dataframe$mappa_pratica_pratt[[i]] <- IGRUE[[i]]$AP01 %>%
    filter(FLG_CANCELLAZIONE != "S" & COD_LOCALE_PROGETTO %in% dataframe$progetti_attivi[[i]]$COD_LOCALE_PROGETTO) %>%
    select(COD_LOCALE_PROGETTO, COD_PROC_ATT)

  
# mappa_pratica_bando ========================================================================================
  dataframe$mappa_pratica_bando[[i]] <- left_join(dataframe$mappa_pratica_pratt[[i]], dataframe$bandi[[i]], by="COD_PROC_ATT")
 
  # cig ========================================================================================
  dataframe$cig[[i]] <- IGRUE[[i]]$PG00 %>%
    filter(FLG_CANCELLAZIONE != "S" & COD_LOCALE_PROGETTO %in% dataframe$progetti_attivi[[i]]$COD_LOCALE_PROGETTO) %>%
    select(COD_LOCALE_PROGETTO, CIG)
  
# mapppa_pratica_asse ===================================================================================================
# mappa decodifica COD_LIVELLO_GERARCHICO rispetto ad [ASSE]
  dataframe$mappa_pratica_asse[[i]] <- IGRUE[[i]]$FN01 %>%
    filter(COD_LOCALE_PROGETTO %in% dataframe$progetti_attivi[[i]]$COD_LOCALE_PROGETTO & FLG_CANCELLAZIONE != "S") %>%
    select(COD_LOCALE_PROGETTO, COD_LIV_GERARCHICO) %>%
    left_join(IGRUE$TC$TC36, by = "COD_LIV_GERARCHICO") %>%
    left_join(IGRUE[[i]]$AP00, by="COD_LOCALE_PROGETTO") %>% 
    separate(VALORE_DATI_RILEVATI,c("COD_PROGRAMMA","PROGRAMMA","TIPO_REGIONE","ASSE","OT","PI","OS"), sep = "#") %>%
    select(COD_LOCALE_PROGETTO, ASSE, OT, PI, OS, TITOLO_PROGETTO)

# stato_progetto ==============================================================
# mappa decodifica STATO_PROGETTO --> [Stato Pratica] 2=Ammesso e Finanziato, 8 =Chiuso
dataframe$stato_progetto[[i]] <- IGRUE[[i]]$PR01 %>% 
    filter(COD_LOCALE_PROGETTO %in% dataframe$progetti_attivi[[i]]$COD_LOCALE_PROGETTO & FLG_CANCELLAZIONE != "S") %>%
    select(COD_LOCALE_PROGETTO, STATO_PROGETTO) %>%
    mutate(STATO_PROGETTO_DESCRIZIONE=recode(STATO_PROGETTO, "2" = "Ammesso e Finanziato", "3"= "Chiuso"))

# finanziamento  ===================================================================================================
# FN00 su progetti_attivi, per quote ERDF+QA+FPREG+PRT non cancellate --> [costo_ammesso]
IGRUE[[i]]$FN00$IMPORTO <- as.double(gsub(",","\\.",IGRUE[[i]]$FN00$IMPORTO))
dataframe$finanziamento[[i]] <- IGRUE[[i]]$FN00 %>%
  filter(COD_LOCALE_PROGETTO %in% dataframe$progetti_attivi[[i]]$COD_LOCALE_PROGETTO & FLG_CANCELLAZIONE != "S") %>%
  group_by(COD_LOCALE_PROGETTO) %>%
  summarise(FINANZIAMENTO = sum(IMPORTO)) %>%
  mutate(FINANZIAMENTO = round2(FINANZIAMENTO, 2))   

# concesso  ===================================================================================================
# FN01 su progetti_attivi
IGRUE[[i]]$FN01$IMPORTO_AMMESSO <- as.double(gsub(",","\\.",IGRUE[[i]]$FN01$IMPORTO_AMMESSO))
  dataframe$concesso[[i]] <- IGRUE[[i]]$FN01 %>%
    filter(COD_LOCALE_PROGETTO %in% dataframe$progetti_attivi[[i]]$COD_LOCALE_PROGETTO & FLG_CANCELLAZIONE != "S") %>%
    group_by(COD_LOCALE_PROGETTO) %>%
    summarise(CONCESSO = sum(IMPORTO_AMMESSO)) %>%
    mutate(CONCESSO = round2(CONCESSO, 2))   

# costo_realizzato  ===================================================================================================
# FN03 su progetti_attivi, 
IGRUE[[i]]$FN03$IMP_REALIZZATO <- as.double(gsub(",","\\.",IGRUE[[i]]$FN03$IMP_REALIZZATO))
dataframe$costo_realizzato[[i]] <- IGRUE[[i]]$FN03 %>%
  filter(COD_LOCALE_PROGETTO %in% dataframe$progetti_attivi[[i]]$COD_LOCALE_PROGETTO & FLG_CANCELLAZIONE != "S") %>%
  group_by(COD_LOCALE_PROGETTO) %>%
  summarise(COSTO_REALIZZATO = sum(IMP_REALIZZATO)) %>%
  mutate(COSTO_REALIZZATO = round2(COSTO_REALIZZATO, 2))   

# impegnato  ===================================================================================================
# impegnato ##################################################################
# FN04 impegni su progetti_attivi, I-D
IGRUE[[i]]$FN04$IMPORTO_IMPEGNO <- as.double(gsub(",","\\.",IGRUE[[i]]$FN04$IMPORTO_IMPEGNO))
dataframe$impegnato[[i]] <- IGRUE[[i]]$FN04 %>% 
  filter(FLG_CANCELLAZIONE !="S" & COD_LOCALE_PROGETTO %in% dataframe$progetti_attivi[[i]]$COD_LOCALE_PROGETTO) %>%
  pivot_wider(names_from = TIPOLOGIA_IMPEGNO, values_from = IMPORTO_IMPEGNO, values_fill = NA, values_fn = sum) %>%
  #spread(TIPOLOGIA_IMPEGNO, IMPORTO_IMPEGNO) %>%
  mutate(
    D = if(exists("D", where = .)) D else NA,
    I = if(exists("I", where = .)) I else NA
  ) %>%
  replace_na(list(I=0,D=0)) %>%
  mutate(IMPEGNATO=I-D) %>%
  group_by(COD_LOCALE_PROGETTO, DATA_IMPEGNO) %>%
  summarise(IMPEGNATO = sum(IMPEGNATO)) %>%
  mutate(IMPEGNATO = round2(IMPEGNATO, 2))

# impegnato_ammesso ##################################################################
# FN05 impegni su progetti_attivi, I-D
  IGRUE[[i]]$FN05$IMPORTO_IMP_AMM <- as.double(gsub(",","\\.",IGRUE[[i]]$FN05$IMPORTO_IMP_AMM))
  dataframe$impegnato_ammesso[[i]] <- IGRUE[[i]]$FN05 %>% 
    filter(FLG_CANCELLAZIONE !="S" & COD_LOCALE_PROGETTO %in% dataframe$progetti_attivi[[i]]$COD_LOCALE_PROGETTO) %>%
    pivot_wider(id_cols = COD_LOCALE_PROGETTO, names_from = TIPOLOGIA_IMPEGNO, values_from = IMPORTO_IMP_AMM, values_fill = NA, values_fn = sum) %>%
    mutate(
      D = if(exists("D", where = .)) D else NA,
      I = if(exists("I", where = .)) I else NA
    ) %>%
    replace_na(list(I = 0, D = 0)) %>%
    mutate(IMPEGNATO_AMMESSO = I-D) %>%
    group_by(COD_LOCALE_PROGETTO) %>%
    summarise(IMPEGNATO_AMMESSO = sum(IMPEGNATO_AMMESSO)) %>%
    mutate(IMPEGNATO_AMMESSO = round2(IMPEGNATO_AMMESSO, 2))

# liquidato  ===================================================================================================
  # liquidato ##################################################################
  # FN06 pagamenti su progetti_attivi, P-R
  IGRUE[[i]]$FN06$IMPORTO_PAG <- as.double(gsub(",","\\.",IGRUE[[i]]$FN06$IMPORTO_PAG))
  dataframe$liquidato[[i]] <- IGRUE[[i]]$FN06 %>% 
    pivot_wider(id_cols = COD_LOCALE_PROGETTO, names_from = TIPOLOGIA_PAG, values_from = IMPORTO_PAG, values_fill = NA, values_fn = sum) %>%
    #spread(TIPOLOGIA_PAG, IMPORTO_PAG) %>%
    mutate(
      P = if(exists("P", where = .)) P else NA,
      R = if(exists("R", where = .)) R else NA
    ) %>%
    replace_na(list(`P`=0,`R`=0)) %>%
    mutate(LIQUIDATO=`P`-`R`) %>%
    group_by(COD_LOCALE_PROGETTO) %>%
    summarise(LIQUIDATO = sum(LIQUIDATO)) %>%
    mutate(LIQUIDATO = round2(LIQUIDATO, 2))

# liquidato ##################################################################
# FN07 pagamenti_ammessi su progetti_attivi, P-R
  IGRUE[[i]]$FN07$IMPORTO_PAG_AMM <- as.double(gsub(",","\\.",IGRUE[[i]]$FN07$IMPORTO_PAG_AMM))
  dataframe$liquidato_ammesso[[i]] <- IGRUE[[i]]$FN07 %>% 
    filter(FLG_CANCELLAZIONE !="S" & COD_LOCALE_PROGETTO %in% dataframe$progetti_attivi[[i]]$COD_LOCALE_PROGETTO) %>%
    pivot_wider(id_cols = COD_LOCALE_PROGETTO, names_from = TIPOLOGIA_PAG_AMM, values_from = IMPORTO_PAG_AMM, values_fill = NA, values_fn = sum) %>%
    mutate(
      P = if(exists("P", where = .)) P else NA,
      R = if(exists("R", where = .)) R else NA
    ) %>%
    replace_na(list(`P`=0,`R`=0)) %>%
    mutate(LIQUIDATO_AMMESSO =`P`-`R`) %>%
    group_by(COD_LOCALE_PROGETTO) %>%
    summarise(LIQUIDATO_AMMESSO = sum(LIQUIDATO_AMMESSO)) %>%
    mutate(LIQUIDATO_AMMESSO = round2(LIQUIDATO_AMMESSO, 2))
  
# economie ========================================================================================================
  # FN10 economie_fsc su progetti_attivi
  IGRUE[[i]]$FN10$IMPORTO <- as.double(gsub(",","\\.",IGRUE[[i]]$FN10$IMPORTO))
  dataframe$economie_fsc[[i]] <- IGRUE[[i]]$FN10 %>% 
    filter(FLG_CANCELLAZIONE !="S" & COD_LOCALE_PROGETTO %in% dataframe$progetti_attivi[[i]]$COD_LOCALE_PROGETTO & COD_FONDO == "FSC") %>%
    group_by(COD_LOCALE_PROGETTO) %>%
    summarise(ECONOMIA_FSC = sum(IMPORTO)) %>%
    mutate(ECONOMIA_FSC = round2(ECONOMIA_FSC, 2))
  
  dataframe$economie_prov[[i]] <- IGRUE[[i]]$FN10 %>% 
    filter(FLG_CANCELLAZIONE !="S" & COD_LOCALE_PROGETTO %in% dataframe$progetti_attivi[[i]]$COD_LOCALE_PROGETTO & COD_FONDO == "FPPROV") %>%
    group_by(COD_LOCALE_PROGETTO) %>%
    summarise(ECONOMIA_PROV = sum(IMPORTO)) %>%
    mutate(ECONOMIA_PROV = round2(ECONOMIA_PROV, 2))  

# report indicatori --------------------------------------------------------------------------------------------
    dataframe$report_indicatori[[i]] <- IGRUE[[i]]$IN01 %>%
      #replace_na(FLG_CANCELLAZIONE = "") %>%
      mutate(VAL_PROGRAMMATO = as.double(str_replace(VAL_PROGRAMMATO, ",", ".")),
             `VALORE_REALIZZATO` = as.double(str_replace({if("VALORE REALIZZATO" %in% names(.)) `VALORE REALIZZATO` else `VALORE_REALIZZATO`}, ",", "."))) %>%
      filter(FLG_CANCELLAZIONE != "S" & COD_LOCALE_PROGETTO %in% dataframe$progetti_attivi[[i]]$COD_LOCALE_PROGETTO) %>%
      left_join(dataframe$mappa_pratica_bando[[i]], by = "COD_LOCALE_PROGETTO") %>%
      left_join(dataframe$mappa_pratica_asse[[i]], by = "COD_LOCALE_PROGETTO") %>%
      left_join(dataframe$indicatori_descrizioni, by = "COD_INDICATORE") %>%
      filter(!COD_LOCALE_PROGETTO %in% dataframe$mappa_scarti$COD_LOCALE_PROGETTO) %>%
      rename(COD_BANDO = COD_PROC_ATT_LOCALE, 
             BANDO = DESCR_PROCEDURA_ATT, 
             ID_PRATICA = COD_LOCALE_PROGETTO, 
             TIPO_INDICATORE = TIPO_INDICATORE_DI_OUTPUT, 
             VALORE_PROGRAMMATO = VAL_PROGRAMMATO, 
             VALORE_REALIZZATO = `VALORE_REALIZZATO`,
             COD_INDICATORE_IGRUE = COD_INDICATORE,
             COD_INDICATORE = COD_INDICATORE_OUT) %>%
      select(ASSE, OT, PI, OS, COD_BANDO, BANDO, ID_PRATICA, TITOLO_PROGETTO, 
             TIPO_INDICATORE, COD_INDICATORE, DESCRIZIONE_INDICATORE, 
             UNITA_MISURA, VALORE_PROGRAMMATO, VALORE_REALIZZATO) %>%
      arrange(ASSE, OT, PI, OS, COD_BANDO, ID_PRATICA, COD_INDICATORE)
  
# report economics ------------------------------------------------------------
  dataframe$report_pratica[[i]] <- dataframe$mappa_pratica_bando[[i]] %>%
    left_join(dataframe$mappa_pratica_asse[[i]], by = "COD_LOCALE_PROGETTO") %>%
    left_join(dataframe$cig[[i]], by = "COD_LOCALE_PROGETTO") %>%
    left_join(dataframe$finanziamento[[i]], by = "COD_LOCALE_PROGETTO") %>%
    left_join(dataframe$concesso[[i]], by = "COD_LOCALE_PROGETTO") %>%
    left_join(dataframe$impegnato[[i]], by = "COD_LOCALE_PROGETTO") %>%
    left_join(dataframe$impegnato_ammesso[[i]], by = "COD_LOCALE_PROGETTO") %>%
    left_join(dataframe$liquidato[[i]], by = "COD_LOCALE_PROGETTO") %>%
    left_join(dataframe$liquidato_ammesso[[i]], by = "COD_LOCALE_PROGETTO") %>%
    left_join(dataframe$economie_fsc[[i]], by = "COD_LOCALE_PROGETTO") %>%
    left_join(dataframe$economie_prov[[i]], by = "COD_LOCALE_PROGETTO") %>%
    left_join(dataframe$costo_realizzato[[i]], by = "COD_LOCALE_PROGETTO") %>%
    filter(!COD_LOCALE_PROGETTO %in% dataframe$mappa_scarti$COD_LOCALE_PROGETTO) %>%
    mutate(
      IMPEGNATO = if(exists("IMPEGNATO", where = .)) IMPEGNATO else NA,
      IMPEGNATO_AMMESSO = if(exists("IMPEGNATO_AMMESSO", where = .)) IMPEGNATO_AMMESSO else NA,
      LIQUIDATO = if(exists("IMPEGNATO_AMMESSO", where = .)) LIQUIDATO else NA,
      LIQUIDATO_AMMESSO = if(exists("LIQUIDATO_AMMESSO", where = .)) LIQUIDATO_AMMESSO else NA,
      COSTO_REALIZZATO = if(exists("COSTO_REALIZZATO", where = .)) COSTO_REALIZZATO else NA,
      ECONOMIE_FSC = if(exists("ECONOMIA_FSC", where = .)) ECONOMIA_FSC else NA,
      ECONOMIE_PROV = if(exists("ECONOMIA_PROV", where = .)) ECONOMIA_PROV else NA
      ) %>%
    mutate_if(is.numeric, replace_na, 0) %>%
    #mutate_if(is.numeric, round2, 0) %>%
    rename(COD_BANDO = COD_PROC_ATT_LOCALE, BANDO = DESCR_PROCEDURA_ATT, ID_PRATICA = COD_LOCALE_PROGETTO) %>%
    select(ASSE, COD_BANDO, BANDO, `DATA AVVIO PROCEDURA`,`DATA FINE PROCEDURA`, ID_PRATICA, TITOLO_PROGETTO, FINANZIAMENTO, CONCESSO, IMPEGNATO, IMPEGNATO_AMMESSO, DATA_IMPEGNO, LIQUIDATO, LIQUIDATO_AMMESSO, ECONOMIE_FSC, ECONOMIE_PROV, COSTO_REALIZZATO) %>%
    arrange(ASSE, COD_BANDO, ID_PRATICA)
  
  
  dataframe$report_bando[[i]] <- dataframe$report_pratica[[i]] %>%
    group_by(ASSE, COD_BANDO, BANDO) %>%
    summarise_if(is.numeric, sum)
  
  dataframe$report_asse[[i]] <- dataframe$report_pratica[[i]] %>%
    group_by(ASSE) %>%
    summarise_if(is.numeric, sum) %>%
    janitor::adorn_totals(name = "Totale", where = "row", fill = "")


# report procedurale -----------------------------------------------------------
    dataframe$report_procedurale[[i]] <- IGRUE[[i]]$PR00 %>%
    #replace_na(FLG_CANCELLAZIONE = "") %>%
    filter(FLG_CANCELLAZIONE != "S" & COD_LOCALE_PROGETTO %in% dataframe$progetti_attivi[[i]]$COD_LOCALE_PROGETTO) %>%
    left_join(dataframe$mappa_pratica_bando[[i]], by = "COD_LOCALE_PROGETTO") %>%
    left_join(dataframe$mappa_pratica_asse[[i]], by = "COD_LOCALE_PROGETTO") %>%
    left_join(IGRUE$TC$TC46, by = "COD_FASE") %>%
    filter(!COD_LOCALE_PROGETTO %in% dataframe$mappa_scarti$COD_LOCALE_PROGETTO) %>%
    rename(COD_BANDO = COD_PROC_ATT_LOCALE, 
           BANDO = DESCR_PROCEDURA_ATT, 
           ID_PRATICA = COD_LOCALE_PROGETTO, 
           ) %>%
    select(ASSE, OT, PI, OS, COD_BANDO, BANDO, ID_PRATICA, TITOLO_PROGETTO, 
           COD_FASE, DESCRIZIONE_FASE, 
           DATA_INIZIO_PREVISTA, DATA_INIZIO_EFFETTIVA,
           DATA_FINE_PREVISTA, DATA_FINE_EFFETTIVA) %>%
    arrange(ASSE, OT, PI, OS, COD_BANDO, ID_PRATICA, COD_FASE)   

# report beneficiari -----------------------------------------------------------
    dataframe$report_beneficiari[[i]] <- IGRUE[[i]]$SC00 %>%
    filter(COD_RUOLO_SOG=="2" & FLG_CANCELLAZIONE != "S") %>%
    left_join(dataframe$mappa_pratica_bando[[i]], by = "COD_LOCALE_PROGETTO") %>%
    left_join(dataframe$mappa_pratica_asse[[i]], by = "COD_LOCALE_PROGETTO") %>%
    filter(!COD_LOCALE_PROGETTO %in% dataframe$mappa_scarti$COD_LOCALE_PROGETTO) %>%
    rename(COD_BANDO = COD_PROC_ATT_LOCALE, 
           BANDO = DESCR_PROCEDURA_ATT, 
           ID_PRATICA = COD_LOCALE_PROGETTO,
           DENOMINAZIONE = DENOMINAZIONE_SOG) %>%
    select(ASSE, OT, PI, OS, COD_BANDO, BANDO, ID_PRATICA, TITOLO_PROGETTO, 
           CODICE_FISCALE, DENOMINAZIONE, FORMA_GIURIDICA) %>%
    arrange(ASSE, OT, PI, OS, COD_BANDO, ID_PRATICA)
  
}   