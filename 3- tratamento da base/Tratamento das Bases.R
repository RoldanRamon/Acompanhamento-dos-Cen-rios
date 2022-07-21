rm(list = ls())
library(dplyr)
library(janitor)
library(ggplot2)
library(readxl)
library(stringr)

#Março
base_marco <- read_excel(path = '2- base/adri_Base_Pagamentos ATUAL 09_06 com informação adicional.xlsx',sheet = 'MARÇO (F)') %>%
  clean_names() %>% distinct(nova_oc) %>%
  mutate(nova_oc =  str_trim(as.character(nova_oc)), mes_referencia = 'marco', caracteres = str_length(nova_oc),
         tipo = if_else(caracteres > 8 | caracteres <6 | is.na(nova_oc),'verificar',
                        if_else(caracteres == 8 & str_sub(string = nova_oc, end = 1)!=2 | caracteres == 6 & str_sub(string = nova_oc, end = 1)!=3,'verificar',
                                if_else(caracteres == 8 & str_sub(string = nova_oc, end = 1)==2,'oc',
                                        if_else(caracteres == 6 & str_sub(string = nova_oc, end = 1)==3,'solicitacao','verificar')))))


#Abril
base_abril <- read_excel(path = '2- base/adri_Base_Pagamentos ATUAL 09_06 com informação adicional.xlsx',sheet = 'ABRIL (F)') %>%
  clean_names() %>% distinct(nova_oc) %>%
  mutate(nova_oc =  str_trim(as.character(nova_oc)), mes_referencia = 'abril', caracteres = str_length(nova_oc),
         tipo = if_else(caracteres > 8 | caracteres <6 | is.na(nova_oc),'verificar',
                        if_else(caracteres == 8 & str_sub(string = nova_oc, end = 1)!=2 | caracteres == 6 & str_sub(string = nova_oc, end = 1)!=3,'verificar',
                                if_else(caracteres == 8 & str_sub(string = nova_oc, end = 1)==2,'oc',
                                        if_else(caracteres == 6 & str_sub(string = nova_oc, end = 1)==3,'solicitacao','verificar')))))


#Maio
base_maio <- read_excel(path = '2- base/adri_Base_Pagamentos ATUAL 09_06 com informação adicional.xlsx',sheet = 'MAIO (F)') %>%
  clean_names() %>% distinct(nova_oc) %>%
  mutate(nova_oc =  str_trim(as.character(nova_oc)), mes_referencia = 'maio', caracteres = str_length(nova_oc),
         tipo = if_else(caracteres > 8 | caracteres <6 | is.na(nova_oc),'verificar',
                        if_else(caracteres == 8 & str_sub(string = nova_oc, end = 1)!=2 | caracteres == 6 & str_sub(string = nova_oc, end = 1)!=3,'verificar',
                                if_else(caracteres == 8 & str_sub(string = nova_oc, end = 1)==2,'oc',
                                        if_else(caracteres == 6 & str_sub(string = nova_oc, end = 1)==3,'solicitacao','verificar')))))

#Outros
base_outros <- read_excel(path = '2- base/adri_Base_Pagamentos ATUAL 09_06 com informação adicional.xlsx',sheet = 'OUTROS (F)') %>%
  clean_names() %>% distinct(nova_oc) %>%
  mutate(nova_oc =  str_trim(as.character(nova_oc)), mes_referencia = 'Outros', caracteres = str_length(nova_oc),
         tipo = if_else(caracteres > 8 | caracteres <6 | is.na(nova_oc),'verificar',
                        if_else(caracteres == 8 & str_sub(string = nova_oc, end = 1)!=2 | caracteres == 6 & str_sub(string = nova_oc, end = 1)!=3,'verificar',
                                if_else(caracteres == 8 & str_sub(string = nova_oc, end = 1)==2,'oc',
                                        if_else(caracteres == 6 & str_sub(string = nova_oc, end = 1)==3,'solicitacao','verificar')))))

#Consolida as bases
base_consolidada_sol <- bind_rows(base_marco,base_abril,base_maio,base_outros) %>% filter(tipo=='solicitacao')
base_consolidada_oc <- bind_rows(base_marco,base_abril,base_maio,base_outros) %>% filter(tipo=='oc')
rm(base_maio,base_abril,base_marco,base_outros)

#Exporta casos que são solicitações de compra e ocs
writeLines(text = paste0('"',paste(base_consolidada_sol$nova_oc,collapse = '","'),'"'),'1- select/solicitacoes_de_compra.txt')
writeLines(text = paste0('"',paste(base_consolidada_oc$nova_oc,collapse = '","'),'"'),'1- select/ocs.txt')
rm(list = ls())