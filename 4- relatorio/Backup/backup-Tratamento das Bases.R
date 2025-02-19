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
todos <- bind_rows(base_marco,base_abril,base_maio,base_outros)
base_consolidada_sol <- todos %>% filter(tipo=='solicitacao')
base_consolidada_oc <- todos %>% filter(tipo=='oc')
rm(base_maio,base_abril,base_marco,base_outros)

#Exporta base consolidada
writexl::write_xlsx(todos,'2- base/base_consolidada.xlsx')

codigo <- c("SELECT DISTINCT A.DATAINCLUSAO AS DATA_INCLUSAO,
H.NOME AS NOME_EMPRESA,
I.NOME AS NOME_FILIAL,
A.NUMERO AS ORDEM_COMPRA,
SOLICITACAO.NUMERO AS NUM_SOL_PAI,
B.TOTALGERAL AS GASTO,
CASE WHEN A.STATUS = '1' THEN 'CADASTRADA' ELSE
    CASE WHEN A.STATUS = '2' THEN 'CONFIRMADA' ELSE
        CASE WHEN A.STATUS = '3' THEN 'RECEBENDO' ELSE
            CASE WHEN A.STATUS = '4' THEN 'ENCERRADA' ELSE
                CASE WHEN A.STATUS = '5' THEN 'CANCELADA' ELSE 'RECUSADA'
                END
            END
        END
    END
END AS STATUS,
CASE WHEN UPPER(C.APELIDO) NOT IN ('SETOR.COMPRAS', 'SUPRIMENTOS_OC_AUTOMATICA') THEN UPPER(C.APELIDO) ELSE
     CASE WHEN UPPER(D.APELIDO) IS NOT NULL THEN UPPER(D.APELIDO) ELSE
         CASE WHEN UPPER(E.APELIDO) IS NOT NULL THEN UPPER(E.APELIDO) END
     END
END AS COMPRADOR,
F.CGCCPF AS CNPJ_FORNECEDOR,
F.NOME AS NOME_FORNECEDOR,
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CASE WHEN G.TELEFONE IS NOT NULL THEN UPPER(CONCAT('(',G.DDD,')',' - ',G.TELEFONE,' - ','RAMAL: ',G.RAMAL)) ELSE '' END ,char(13),''),char(34),''),char(9),''),char(10),''),'/N','/ N'),'/R','/ R') AS TELEFONE_DO_FORNECEDOR,

REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(F.EMAIL) ,char(13),''),char(34),''),char(9),''),char(10),''),'/N','/ N'),'/R','/ R') AS EMAIL_DO_FORNECEDOR


FROM CP_ORDENSCOMPRA A
INNER JOIN  CP_ORDENSCOMPRAITENS B ON A.HANDLE = B.ORDEMCOMPRA
LEFT JOIN Z_GRUPOUSUARIOS C ON A.USUARIOINCLUIU = C.HANDLE
LEFT JOIN CP_SOLICITACOES SOLICITACAO ON SOLICITACAO.NUMERO = A.NUMERODOCUMENTOORIGEM
LEFT JOIN Z_GRUPOUSUARIOS D ON SOLICITACAO.SOLICITANTE = D.HANDLE
LEFT JOIN CP_REQUISICOES REQ ON REQ.ORDEMCOMPRA = A.HANDLE
LEFT JOIN Z_GRUPOUSUARIOS E on REQ.REQUISITANTE = E.HANDLE
LEFT JOIN GN_PESSOAS F ON F.HANDLE = A.FORNECEDOR
LEFT JOIN GN_PESSOATELEFONES G ON G.PESSOA = F.HANDLE
LEFT JOIN EMPRESAS H ON H.HANDLE = A.EMPRESA
LEFT JOIN FILIAIS I ON I.HANDLE = A.FILIAL
WHERE A.NUMERO IN (")

lista <- paste0('"',paste(unique(base_consolidada_oc$nova_oc),collapse = '","'),'"')

#Exporta codigo das ocs
writeLines(text = paste0(codigo, lista,")"),'1- select/ocs.sql')

codigo <- c("SELECT DISTINCT A.DATAINCLUSAO AS DATA_INCLUSAO_SOL_PAI,
EMP.NOME AS NOME_EMPRESA,
FIL.NOME AS NOME_FILIAL,

CASE WHEN A.STATUS = 1 THEN 'CADASTRADA' ELSE
   CASE WHEN A.STATUS = 2 THEN 'CONFIRMADA' ELSE
       CASE WHEN A.STATUS = 3 THEN 'EM ATENDIMENTO' ELSE
          CASE WHEN A.STATUS = 4 THEN 'ENCERRADA' ELSE
             CASE WHEN A.STATUS = 5 THEN 'RECUSADA' ELSE
                CASE WHEN A.STATUS = 6 THEN 'CANCELADA' ELSE 'ATENDIMENTO DIVERGENTE'
                END
             END
          END
       END
   END
END AS STATUS_SOL_PAI,

CASE WHEN SOL_ITENS.STATUS = 1 THEN 'CADASTRADA' ELSE
   CASE WHEN SOL_ITENS.STATUS = 2 THEN 'ATENDIMENTO DIVERGENTE' ELSE
       CASE WHEN SOL_ITENS.STATUS = 3 THEN 'EM ATENDIMENTO' ELSE
          CASE WHEN SOL_ITENS.STATUS = 4 THEN 'ENCERRADA' ELSE
             CASE WHEN SOL_ITENS.STATUS = 5 THEN 'CANCELADA'
             END
          END
       END
   END
END AS STATUS_SOL_FILHO,

CASE WHEN A.MODALIDADE = 'R' THEN 'REGULARIZAÇÃO' ELSE
    CASE WHEN A.MODALIDADE = 'C' THEN 'CATALOGO' ELSE 'NORMAL' END
END AS MODALIDADE,
A.NUMERO AS NUM_SOL_PAI,
SOL_ITENS.NUMERO AS NUM_SOL_FILHO,
OCS.NUMERO AS ORDEM_DE_COMPRA,
UPPER(SOL.APELIDO) AS NOME_DO_SOLICITANTE,
UPPER(SOL.EMAIL) AS EMAIL_DO_SOLICITANTE,

CASE WHEN UPPER(SOL_APROVA.APELIDO) IS NOT NULL THEN UPPER(SOL_APROVA.APELIDO) ELSE
UPPER(APR.APELIDO) END AS NOME_DO_APROVADOR,
CASE WHEN UPPER(SOL_APROVA.EMAIL) IS NOT NULL THEN UPPER(SOL_APROVA.EMAIL) ELSE
UPPER(APR.EMAIL) END AS EMAIL_DO_APROVADOR,

REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(A.MOTIVOSTATUS ,char(13),''),char(9),''),char(10),''),'/N','/ N'),'/R','/ R') AS MOTIVO_STATUS,

SOL_ITENS.QUANTIDADE AS QUANTIDADE_SOLICITADA,
SOL_ITENS.VALORESTIMADO AS VALOR_DO_ITEM,
RA.CODIGO AS CENTRO_DE_CUSTO,
CASE WHEN SOL_ITENS.PROJETO IS NULL THEN 'OPEX' ELSE
'CAPEX' END AS PROJETO,
CONCAT(FIN.ESTRUTURA,' - ',FIN.CODIGO) AS FINALIDADE_ESTRUTURA,
FIN.DESCRICAO AS FINALIDADE_DESCRICAO,


REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(A.OBSERVACOES ,char(13),''),char(9),''),char(10),''),'/N','/ N'),'/R','/ R') AS TEXTO_OBSERVACOES,
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(AC.NOME ,char(13),''),char(9),''),char(10),''),'/N','/ N'),'/R','/ R') AS NOME_ITEM,
EA.NOME AS UNIDADE_DE_MEDIDA

FROM CP_SOLICITACOES A
LEFT JOIN EMPRESAS EMP ON EMP.HANDLE = A.EMPRESA
LEFT JOIN FILIAIS FIL ON FIL.HANDLE = A.FILIAL
LEFT JOIN Z_GRUPOUSUARIOS SOL ON SOL.HANDLE = A.SOLICITANTE
LEFT JOIN Z_GRUPOUSUARIOS APR ON APR.HANDLE = A.USUARIOALTERACAO
LEFT JOIN CP_SOLICITACAOITENS SOL_ITENS ON SOL_ITENS.SOLICITACAO = A.HANDLE
LEFT JOIN PD_PRODUTOS AC ON AC.HANDLE = SOL_ITENS.PRODUTO
INNER JOIN CM_UNIDADESMEDIDA EA ON  EA.HANDLE = AC.UNIDADEMEDIDACOMPRAS
LEFT JOIN CP_FINALIDADES FIN ON FIN.HANDLE = SOL_ITENS.FINALIDADE
LEFT JOIN CT_CC RA ON RA.HANDLE = SOL_ITENS.CENTROCUSTO
LEFT JOIN (SELECT * FROM CP_SOLICITACAOHISTORICO WHERE DESCRICAO = 'Aguardando aprovação') SOL_HIST ON SOL_HIST.SOLICITACAO = A.HANDLE
LEFT JOIN Z_GRUPOUSUARIOS SOL_APROVA ON SOL_APROVA.HANDLE=SOL_HIST.USUARIO
LEFT JOIN CP_ORDENSCOMPRA OCS ON OCS.NUMERODOCUMENTOORIGEM = A.NUMERO
WHERE A.NUMERO IN (")

lista <- paste0('"',paste(unique(base_consolidada_sol$nova_oc),collapse = '","'),'"')

#Exporta codigo das ocs
writeLines(text = paste0(codigo, lista,")"),'1- select/solicitacoes_de_compra.sql')
rm(list = ls())

