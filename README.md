# Shopping List App

![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![iOS](https://img.shields.io/badge/iOS-16+-blue)
![UIKit](https://img.shields.io/badge/UIKit-ViewCode-green)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Gráficos-lightblue)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-purple)
![Persistence](https://img.shields.io/badge/Persistence-UserDefaults-yellow)
![Export](https://img.shields.io/badge/Export-PDF-red)
![Tests](https://img.shields.io/badge/Unit_Tests-Passing-brightgreen)

Aplicativo iOS desenvolvido com **UIKit + ViewCode**, focado em boas práticas, arquitetura limpa e aprendizado progressivo.

Este projeto simula um app real de **lista de compras**, permitindo criar compras, finalizar, consultar histórico, visualizar detalhes imutáveis, visualizar gráficos de gastos e exportar informações.

---

## 🎯 Objetivo do Projeto

- Praticar UIKit sem Storyboard
- Aplicar arquitetura **MVVM**
- Organizar regras de negócio fora da ViewController
- Trabalhar com persistência local
- Integrar SwiftUI de forma pontual
- Implementar e manter **testes unitários**
- Evoluir o app de forma incremental e profissional

---

## 🧱 Arquitetura e Padrões

- UIKit
- ViewCode (Auto Layout programático)
- MVVM
- Repository Pattern
- **SwiftUI (uso pontual para gráficos)**
- Sem Storyboard
- Sem Combine (por enquanto)

---

## 📦 Modelos

### MarketItem
Representa um item da lista de compras.

- Nome do produto
- Preço unitário
- Quantidade
- Valor total calculado

### Purchase
Representa uma compra finalizada.

- Data da compra
- Lista imutável de itens
- Total da compra
- Quantidade de itens
- Quantidade total de unidades

---

## 🗄 Persistência

- Persistência local com **UserDefaults**
- Repositórios separados para:
  - Lista ativa de compras
  - Histórico de compras

---

## 📱 Funcionalidades

### ✅ Lista de Compras (Tela Principal)

- Adicionar itens
- Editar itens
- Remover itens
- Atualizar quantidade via stepper
- Swipe actions (editar / remover)
- Footer com:
  - Valor total
  - Total de itens
  - Total de unidades

---

### ✅ Finalizar Compra

- Gera uma compra imutável
- Salva no histórico
- Limpa a lista ativa

---

### ✅ Histórico de Compras

- Lista de compras finalizadas
- Exibe:
  - Data da compra
  - Valor total
  - Quantidade de itens
  - Quantidade total de unidades
- **Header com gráfico de gastos**
  - Gráfico implementado em **SwiftUI**
  - Integrado ao `tableHeaderView` da `UITableView`
  - Exibe o **total gasto nos últimos 6 meses**
  - Atualizado dinamicamente conforme o histórico
- **Filtros de histórico configurados**
  - Busca e refinamento conforme critérios definidos no app

---

### ✅ Detalhes da Compra

- Lista imutável dos itens da compra
- Exibe por item:
  - Nome
  - Preço unitário
  - Quantidade
  - Total por item
- Footer fixo com:
  - Valor total da compra
  - Total de itens
  - Total de unidades

---

### 🔍 Busca nos Detalhes da Compra

- SearchController integrado à navigation bar
- Busca inteligente que:
  - **Ignora acentuação**
  - **Não diferencia letras maiúsculas e minúsculas**
- Busca por:
  - Nome do produto
  - Preço unitário
  - Quantidade
- Resultados consistentes mesmo com termos digitados parcialmente
- Reset correto ao limpar ou fechar a busca

---

### 📤 Exportar Compra

- Exportação dos detalhes da compra
- Opções disponíveis:
  - **Texto formatado via UIActivityViewController**
  - **Exportação em PDF**
- PDF gerado com layout e conteúdo personalizados
- Compartilhamento nativo do iOS

---

## 🧪 Qualidade e Testes

- Código organizado e legível
- Responsabilidades bem definidas
- ViewModels sem dependência de UIKit
- Integração clara entre UIKit e SwiftUI
- **Testes unitários implementados**
  - Foco em regras de negócio
  - Validação de cálculos e estados
  -  Repositórios isolados

---

## 📌 Observações

Este projeto tem foco educacional, mas segue **padrões próximos ao mercado profissional**, priorizando clareza, manutenção, testabilidade e evolução contínua.
