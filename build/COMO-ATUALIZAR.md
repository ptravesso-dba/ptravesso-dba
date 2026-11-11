# Como atualizar o perfil

O README do perfil (`github.com/ptravesso-dba`) é gerado. A fonte de tudo que muda com o tempo está em **um arquivo só**: `build/build.pl`. Edite lá, rode o build e faça o push.

```bash
cd build
perl build.pl
```

O build regera as imagens em `assets/` e o bloco de relíquias do `README.md`. Não edite à mão os arquivos de `assets/` nem o trecho do README entre `<!--RELICS:START-->` e `<!--RELICS:END-->`: o próximo build sobrescreve.

## Adicionar um projeto novo (relíquia)

1. Torne o repositório público no GitHub.
2. Em `build/build.pl`, procure `my @relics = (` e copie um bloco existente para o fim da lista:

   ```perl
   { repo => 'nome-do-repo', name => 'Ashen Ledger', kind => 'Python · Oracle',
     lore => ['Primeira linha: o que o projeto faz,', 'em até 4 linhas de ~40 caracteres.', 'Termine com uma frase de efeito,', 'no tom de descrição de item.'],
     alt  => 'frase simples dizendo o que o repositório faz.' },
   ```

   | Campo | O que é | Limite |
   |---|---|---|
   | `repo` | nome exato do repositório em `github.com/ptravesso-dba/` | — |
   | `name` | nome do item, no estilo souls ("Scroll of…", "Eye of…", "…Rite", "…Ledger") | ~26 caracteres |
   | `kind` | linguagem · tema, ou `★ N` para estrelas | ~30 caracteres |
   | `lore` | descrição em tom de item: o que faz e uma frase de fechamento | 4 linhas de ~40 caracteres |
   | `alt` | frase simples para leitor de tela | — |

3. Rode `perl build.pl`. Se algum texto passar do limite do card, o build avisa com uma linha `WARN`.
4. Confira o resultado (veja "Pré-visualizar" abaixo), faça o commit e o push.

Os cards ficam três por linha; o quarto projeto abre uma linha nova sozinho.

Para tirar um projeto, apague o bloco dele, rode o build e apague o `assets/relic-<repo>.svg` que sobrou.

## Outras partes que mudam com o tempo

Tudo também em `build/build.pl`, perto do topo da seção "status sheet data":

| O quê | Onde | Observação |
|---|---|---|
| Atributos (barras) | `my @attrs` | escala souls: a barra cheia vale 60 |
| Equipamento | `my @equip` | slot e itens |
| Certificações (anéis) | `my @rings` | nome curto e nível: `PRO`, `ASSOC`, `LPI`; 4 por coluna, 3 colunas (12 cabem) |

Os campos fixos da ficha (Class, Level 26ai, Covenant, Origin, Since, Gift) ficam em `build/status.src.svg`, no bloco "column 1: identity". O texto do banner fica em `build/banner.src.svg`.

## Caracteres

As fontes vão embutidas só com os caracteres usados (ASCII, acentos do português e `· ● — – − ▸ █ ✦ ★ “ ” ’`). Um caractere fora disso aparece numa fonte substituta. Para usar outro, é preciso baixar de novo o recorte da fonte em `build/fonts/` com o caractere incluído.

## Pré-visualizar

Com o servidor local do perfil rodando, abra `http://localhost:8766/build/preview.html`. Ele mostra o README como o GitHub mostra, com botão para alternar claro e escuro.

## Publicar

```bash
git add -A
git commit -m "Add relic: nome-do-repo"
git push
```

O GitHub atualiza o perfil em um ou dois minutos. Se a imagem não mudar, é cache do GitHub: espere alguns minutos.
