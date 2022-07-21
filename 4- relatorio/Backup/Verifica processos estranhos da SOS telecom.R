rm(list = ls())
library(dplyr)
library(janitor)
library(ggplot2)
library(readxl)
library(stringr)

#Março
base_marco <- read_excel(path = '2- base/adri_Base_Pagamentos ATUAL 09_06 com informação adicional.xlsx',sheet = 'Março (F)') %>%
  clean_names() %>% distinct(nova_oc) %>%
  mutate(nova_oc =  str_trim(as.character(nova_oc)), mes_referencia = 'marco', caracteres = str_length(nova_oc),
         tipo = if_else(caracteres > 8 | caracteres <6 | is.na(nova_oc),'verificar',
                        if_else(caracteres == 8 & str_sub(string = nova_oc, end = 1)!=2 | caracteres == 6 & str_sub(string = nova_oc, end = 1)!=3,'verificar',
                                if_else(caracteres == 8 & str_sub(string = nova_oc, end = 1)==2,'oc',
                                        if_else(caracteres == 6 & str_sub(string = nova_oc, end = 1)==3,'solicitacao','verificar')))))


#Abril
base_abril <- read_excel(path = '2- base/adri_Base_Pagamentos ATUAL 09_06 com informação adicional.xlsx',sheet = 'Abril (F)') %>%
  clean_names() %>% distinct(nova_oc) %>%
  mutate(nova_oc =  str_trim(as.character(nova_oc)), mes_referencia = 'abril', caracteres = str_length(nova_oc),
         tipo = if_else(caracteres > 8 | caracteres <6 | is.na(nova_oc),'verificar',
                        if_else(caracteres == 8 & str_sub(string = nova_oc, end = 1)!=2 | caracteres == 6 & str_sub(string = nova_oc, end = 1)!=3,'verificar',
                                if_else(caracteres == 8 & str_sub(string = nova_oc, end = 1)==2,'oc',
                                        if_else(caracteres == 6 & str_sub(string = nova_oc, end = 1)==3,'solicitacao','verificar')))))


#Maio
base_maio <- read_excel(path = '2- base/adri_Base_Pagamentos ATUAL 09_06 com informação adicional.xlsx',sheet = 'Maio (F)') %>%
  clean_names() %>% distinct(nova_oc) %>%
  mutate(nova_oc =  str_trim(as.character(nova_oc)), mes_referencia = 'maio', caracteres = str_length(nova_oc),
         tipo = if_else(caracteres > 8 | caracteres <6 | is.na(nova_oc),'verificar',
                        if_else(caracteres == 8 & str_sub(string = nova_oc, end = 1)!=2 | caracteres == 6 & str_sub(string = nova_oc, end = 1)!=3,'verificar',
                                if_else(caracteres == 8 & str_sub(string = nova_oc, end = 1)==2,'oc',
                                        if_else(caracteres == 6 & str_sub(string = nova_oc, end = 1)==3,'solicitacao','verificar')))))

#outros
base_outros <- read_excel(path = '2- base/adri_Base_Pagamentos ATUAL 09_06 com informação adicional.xlsx',sheet = 'Outros (F)') %>%
  clean_names() %>% distinct(nova_oc) %>%
  mutate(nova_oc =  str_trim(as.character(nova_oc)), mes_referencia = 'Outros', caracteres = str_length(nova_oc),
         tipo = if_else(caracteres > 8 | caracteres <6 | is.na(nova_oc),'verificar',
                        if_else(caracteres == 8 & str_sub(string = nova_oc, end = 1)!=2 | caracteres == 6 & str_sub(string = nova_oc, end = 1)!=3,'verificar',
                                if_else(caracteres == 8 & str_sub(string = nova_oc, end = 1)==2,'oc',
                                        if_else(caracteres == 6 & str_sub(string = nova_oc, end = 1)==3,'solicitacao','verificar')))))


#Consolida bases
base_consolidada <- bind_rows(base_marco,base_abril,base_maio,base_outros)
rm(base_maio,base_abril,base_marco,base_outros)

#base completa
base <- readxl::read_excel('2- base/solicitacoes_dentro_do_benner.xlsx') %>% clean_names() %>% mutate(num_sol_pai = as.character(num_sol_pai)) %>% 
  left_join(base_consolidada %>% filter(tipo=='solicitacao'),by=c('num_sol_pai'='nova_oc'))

#SOS Verificar
verificar <- anti_join(x = base_consolidada,y = base, by=c('nova_oc'='num_sol_pai')) %>% 
  filter(tipo %in% c('solicitacao','verificar')) %>% select(-'caracteres') %>%
  mutate(mes_referencia = factor(mes_referencia, levels = c("marco", "abril", "maio"))) %>% arrange(mes_referencia)

duplicados <- base_consolidada %>% filter(tipo=='solicitacao') %>% count(nova_oc,sort = TRUE) %>% filter(n>1) %>% pull(nova_oc)
duplicados <- base_consolidada %>% filter(nova_oc %in% duplicados) %>% select(-caracteres) %>% arrange(nova_oc)

#Exporta para Excel
writexl::write_xlsx(list(verificar,duplicados),'sos_verificar.xlsx')
