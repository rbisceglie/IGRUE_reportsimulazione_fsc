# solo per gennaio 2021
certificato_gennaio21 <- read_delim("data/certificato_gennaio21.csv", 
                                    ";", escape_double = FALSE, 
                                    col_types = cols(PRATICA = col_character(),
                                                     CERTIFICATO = col_number()), 
                                    locale = locale(decimal_mark = ".", grouping_mark = ".,"), 
                                    trim_ws = TRUE)