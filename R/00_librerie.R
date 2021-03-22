# Caricamento librerie -------------------------------------------------------------
library(tidyverse)
library(openxlsx)
library(rstudioapi)
library(pool)
library(DBI)
library(lubridate)

current_date <- format(Sys.Date(), "%Y%m%d")

round2 = function(x, n) {
  posneg = sign(x)
  z = abs(x)*10^n
  z = z + 0.5
  z = trunc(z)
  z = z/10^n
  z*posneg
}

options(OutDec = ",")