rm(list = ls())
library(dplyr)
library(janitor)
library(ggplot2)
library(readxl)
library(stringr)
library(lubridate)

#base original do fabiano
fabiano <- readxl::read_excel(path = '2- base/base_original_fabiano.xlsx') %>% clean_names() %>% filter(oc == 'GERAR OC') %>% 
  mutate(prazo = if_else(data_pgto >= '2022-03-01' & data_pgto <= '2022-04-15', 'marco_2022',
                         if_else(data_pgto >= '2022-04-16' & data_pgto <= '2022-05-15', 'abril_2022',
                                 if_else(data_pgto >= '2022-05-16' & data_pgto <= '2022-06-15', 'maio_2022','outros_periodo'))),
         chave = paste0(fornecedor_ou_descricao,nf_processo,valor),
         caracteres = str_length(chave))
   

adriani <- readxl::read_excel(path = '2- base/adri_Base_Pagamentos ATUAL 09_06 com informação adicional.xlsx',sheet = 'Março (F)') %>% clean_names()
