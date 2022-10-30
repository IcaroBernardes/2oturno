# 0. Controle de Pacotes e Fontes
## Carrega bibliotecas
library(dplyr)
library(glue)
library(jsonlite)
library(lubridate)
library(rmarkdown)

################################################################################
# 1. Carregamento e manejo dos dados
## Define o código do pleito
# pleito <- 544 ### 1o turno
pleito <- 545 ### 2o turno

## Link para o json de transmissão dos resultados
url <- glue("https://resultados.tse.jus.br/oficial/ele2022/{pleito}/dados-simplificados/br/br-c0001-e000{pleito}-r.json")

## Raspa os resultados e converte a tibble (scrap)
dados <- jsonlite::fromJSON(url, simplifyDataFrame = TRUE) %>%
  .[["cand"]] %>% 
  dplyr::as_tibble()

## Obtém o percentual de urnas apuradas
progresso <- jsonlite::fromJSON(url, simplifyDataFrame = TRUE) %>%
  .[["pst"]]
  
## Insere as datas e traz para o GMT-3
dados <- dados %>%
  dplyr::mutate(data = Sys.time(),
                data = lubridate::ymd_hms(data)-lubridate::dhours(3),
                apuradas = progresso)

## Une com os resultados anteriores
passado <- readRDS("dados.RDS")
dados <- dplyr::bind_rows(passado, dados)

## Salva o que foi obtido
saveRDS(dados, "dados.RDS")

################################################################################
# 2. Produz a página com o gif (render)
rmarkdown::render("index.rmd")
