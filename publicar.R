
library(rsconnect)
result <- rpubsUpload(title = "Acompanhamento do Cenário 3", contentFile = "18.Julho-Acompanhamento.html",originalDoc = "Acompanhamento.html")
browseURL(result$continueUrl)
rm(list = ls())