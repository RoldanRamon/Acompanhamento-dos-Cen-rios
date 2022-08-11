
library(rsconnect)
result <- rpubsUpload(title = "Acompanhamento do Cenário 3", contentFile = "4- relatorio/11.Agosto-Acompanhamento.html",originalDoc = "Acompanhamento.html")
browseURL(result$continueUrl)
rm(list = ls())
