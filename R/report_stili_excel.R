# Definizione stili ------------------------------------------------------------
headerStyle <- createStyle(textDecoration = "bold", 
                           halign = "left",valign = "top")

headercenteredStyle <- createStyle(textDecoration = "bold", 
                                   halign = "center",valign = "top")

textStyle <- createStyle(halign = "left",valign = "top",
                         numFmt = "TEXT")

numberStyle <- createStyle(halign = "left",valign = "top",
                           numFmt = "ACCOUNTING")
totalStyle <- createStyle(halign = "left",valign = "top",
                          numFmt = "ACCOUNTING", textDecoration = "bold")

simulazioneStyle <- createStyle(halign = "left",valign = "top",
                                numFmt = "ACCOUNTING", 
                                fgFill = "#92d050")

validazioneStyle <- createStyle(halign = "left",valign = "top",
                                numFmt = "ACCOUNTING", 
                                fgFill = getOption("openxlsx.borderColour", "orange"))

deltaStyle <- createStyle(halign = "left",valign = "top",
                          numFmt = "ACCOUNTING", 
                          fgFill = "#b8cce4")