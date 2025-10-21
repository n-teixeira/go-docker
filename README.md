# go-docker: Imagens Docker Otimizadas com Go+

## Explicação Teórica: Docker + Go
   - O objetivo é criar imagens Docker pequenas e seguras para aplicações Go, utilizando técnicas avançadas de compilação e Multi-Stage Builds.

## Image
# Link image: https://hub.docker.com/r/teixeirahub/fullcycle
# Comando: docker run teixeirahub/fullcycle

## Multi-Stage Build
### O que é?
- Um único Dockerfile com múltiplos estágios (FROM).

- Cada FROM cria um stage (etapa) independente.

- Você pode copiar arquivos entre stages.

- A imagem final contém apenas o último stage.

### Por que usar?

- Sem Multi-Stage Build
    Imagem tem compilador Go
    Imagem tem código fonte
    Imagem tem ferramentas de build
    Tamanho: ~800MB

- Com Multi-Stage Build
    Imagem só tem o binário
    Sem código fonte
    Sem ferramentas
    Tamanho: ~2.0MB 

## Stage 1: Otimização e Compilação (Builder)
- Base: golang:1.25-alpine (AS builder)

### Comandos
FROM golang:1.25-alpine AS builder
- Ambiente para compilar o código.

WORKDIR /app	
- Define diretório de trabalho dentro do container (criado automaticamente).

COPY main.go .	
- Copia main.go do host para /app/ no container.

RUN CGO_ENABLED=0 
- CGO Permite Go chamar código C.
- Desabilitado pois cria um binário estaticamente linkado (não precisa de bibliotecas C dinâmicas, como  libc). Pode rodar em scratch!
   
GOOS=linux 
- O Sistema Operacional alvo.
- Garante que a compilação é para Linux (o ambiente dos containers).     
    
go build 
- Compila o código Go em um binário executável.

ldflags="-s -w" (Linker Flags)
- -s Remove a tabela de símbolos (debug info).	~2.5MB → ~1.8MB
- -w Remove a DWARF debug info.	~1.8MB → ~1.5MB
# obs: Imagem menor, mas não é possível debugar com ferramentas como gdb ou delve.

-o desafio-1
- Define o nome do binário de saída como fullcycle.

## Stage 2: Imagem Final (Produção)
### Base: scratch
- Definição: Imagem especial do Docker, um placeholder vazio.

- Tamanho: 0 bytes.

- O binário Go é estaticamente compilado (autocontido). Go tem seu próprio runtime embutido. 

- Binário + Kernel do Host = Container funcional!


## Ação: Pega o binário /app/desafio-1 do estágio builder e copia para /desafio-1 na imagem final, descartando todo o resto do estágio builder.

## Beneficios
- Imagens Pequenas (1.5MB vs 800MB)

- Deploy mais Rápido: Menos dados para transferir.

- Segurança: Menos código = menos vetores de ataque. Sem shell (bash, sh) ou ferramentas de sistema.

- Custo: Economia em armazenamento e transferência de dados (Cloud).

- Performance: Container inicia e faz pull mais rápido.
