# Resumo: View de Orçamentos

## Visão Geral
A view de orçamentos é um módulo completo de gerenciamento de orçamentos para uma aplicação de oficina mecânica desenvolvida em Ruby on Rails. O sistema permite criar, visualizar, editar e gerenciar orçamentos de serviços automotivos.

## Estrutura do Sistema

### Model (Quote)
O modelo `Quote` é o núcleo do sistema de orçamentos:

- **Campos principais:**
  - `total_amount_cents`: Valor total do orçamento (monetizado)
  - `status`: Status do orçamento (draft, sent, approved, rejected, expired)
  - `notes`: Observações do orçamento
  - `expires_at`: Data de expiração
  - `created_at/updated_at`: Controle de timestamps

- **Relacionamentos:**
  - `belongs_to :vehicle` - Veículo associado
  - `belongs_to :user` - Usuário criador
  - `has_many :quote_items` - Itens do orçamento
  - `has_many :work_orders` - Ordens de serviço geradas

- **Funcionalidades:**
  - Cálculo automático do valor total
  - Validação de data de expiração
  - Conversão para ordem de serviço
  - Status de aprovação/rejeição

### Controller (QuotesController)
O controller gerencia todas as operações CRUD e ações específicas:

**Ações principais:**
- `index` - Lista todos os orçamentos
- `show` - Exibe detalhes de um orçamento
- `new/create` - Criação de novos orçamentos
- `edit/update` - Edição de orçamentos existentes
- `destroy` - Exclusão de orçamentos

**Ações específicas:**
- `approve` - Aprova um orçamento
- `reject` - Rejeita um orçamento
- `send_quote` - Marca orçamento como enviado
- `convert_to_work_order` - Converte orçamento em ordem de serviço

## Views e Interface

### 1. Página Principal (index.html.erb)
- **Localização**: `app/views/quotes/index.html.erb`
- **Funcionalidades:**
  - Título da página com ícone
  - Botão "Novo Orçamento"
  - Renderiza a lista de orçamentos via partial

### 2. Lista de Orçamentos (_list.html.erb)
- **Localização**: `app/views/quotes/_list.html.erb`
- **Recursos:**
  - **Responsivo**: Tabela desktop e cards mobile
  - **Informações exibidas:**
    - ID do orçamento
    - Nome do cliente (com link)
    - Dados do veículo (com link)
    - Status com badge colorido
    - Valor total formatado
    - Data de criação
  - **Ações disponíveis:**
    - Visualizar (ícone olho)
    - Editar (ícone lápis)
    - Criar OS (se aprovado)
    - Excluir (com confirmação)

### 3. Detalhes do Orçamento (_details.html.erb)
- **Localização**: `app/views/quotes/_details.html.erb`
- **Layout em duas colunas:**
  
  **Coluna principal (8/12):**
  - Card com informações básicas
  - Card com lista de itens do orçamento
  - Visualização responsiva (tabela/cards)
  
  **Sidebar de ações (4/12):**
  - Botão "Editar Orçamento"
  - Botões de aprovação/rejeição (se pendente)
  - Botão "Criar OS" (se aprovado)
  - Botão "Excluir" (com confirmação)

### 4. Visualização Individual (show.html.erb)
- **Localização**: `app/views/quotes/show.html.erb`
- **Funcionalidades:**
  - Cabeçalho com ID do orçamento
  - Botões "Editar" e "Voltar"
  - Renderiza o partial `_details`

### 5. Formulário de Criação/Edição
- **Localização**: `app/views/quotes/new.html.erb` e `edit.html.erb`
- **Recursos:**
  - Formulário em steps
  - Suporte a Turbo Streams
  - Validação em tempo real
  - Criação de clientes e veículos inline

## Funcionalidades Especiais

### 1. Sistema de Status
- **draft**: Rascunho (inicial)
- **sent**: Enviado ao cliente
- **approved**: Aprovado pelo cliente
- **rejected**: Rejeitado pelo cliente
- **expired**: Expirado

### 2. Badges de Status
- **Localização**: `app/views/quotes/_status_badge.html.erb`
- Cores diferenciadas para cada status
- Atualização dinâmica via Turbo

### 3. Integração com Turbo Streams
- Atualizações em tempo real sem reload
- Feedback visual imediato
- Mensagens de sucesso/erro dinâmicas

### 4. Responsividade
- **Desktop**: Tabelas com todas as informações
- **Mobile**: Cards otimizados para toque
- **Adaptativo**: Layout se ajusta automaticamente

## Integrações

### 1. Dashboard
- Exibição de orçamentos recentes
- Contadores de orçamentos ativos
- Links rápidos para criação

### 2. Veículos
- Botão "Novo Orçamento" na página do veículo
- Listagem de orçamentos por veículo
- Criação contextual de orçamentos

### 3. Clientes
- Visualização de orçamentos do cliente
- Histórico de orçamentos por cliente

### 4. Ordens de Serviço
- Conversão automática de orçamentos aprovados
- Manutenção do vínculo entre orçamento e OS
- Transferência de itens e valores

## Tecnologias Utilizadas

- **Backend**: Ruby on Rails
- **Frontend**: Bootstrap 5
- **JavaScript**: Turbo Streams
- **Ícones**: Font Awesome
- **Formatação**: Money gem para valores monetários
- **Responsive**: Bootstrap Grid System

## Fluxo de Trabalho

1. **Criação**: Usuário cria orçamento para um veículo
2. **Edição**: Adiciona itens de serviço e valores
3. **Envio**: Marca como enviado ao cliente
4. **Aprovação**: Cliente aprova ou rejeita
5. **Conversão**: Orçamento aprovado vira ordem de serviço

## Características de UX

- **Feedback visual**: Cores e ícones intuitivos
- **Confirmações**: Diálogos para ações destrutivas
- **Navegação**: Links contextuais entre entidades
- **Acessibilidade**: Suporte a teclado e leitores de tela
- **Performance**: Carregamento otimizado com includes

Este sistema oferece uma experiência completa para gerenciamento de orçamentos, desde a criação até a conversão em ordens de serviço, com interface moderna e responsiva.