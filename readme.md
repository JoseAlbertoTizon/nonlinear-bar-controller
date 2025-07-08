# Controlador Não Linear de Barra Articulada

Projeto desenvolvido para a disciplina CMC-12 do Instituto Tecnológico de Aeronáutica (ITA), trabalha a implementação e a análise de um controlador não linear para o sistema de barra articulada com argola deslizante.

## Descrição do Sistema

O sistema físico consiste em uma barra rígida articulada na posição x = 0, sobre a qual uma argola pode deslizar livremente sem atrito. O controle é realizado através da aplicação de um torque τ(t) na base da barra, alterando seu ângulo θ(t) em relação à vertical. O objetivo é posicionar a argola em uma posição desejada x_r ao longo da barra, utilizando apenas a força gravitacional como força externa.

### Características do Sistema
- **Barra**: Rígida com momento de inércia J = 8.5 kg·m²
- **Argola**: Massa m, desliza sem atrito
- **Controle**: Torque aplicado na base da barra
- **Força externa**: Apenas gravidade (g = 9.81 m/s²)

## Estrutura do Projeto

### Arquivos Principais

- `simularBarra.m` - Função principal de simulação do sistema
- `simularBarraRequisitosEstabilidade.m` - Simulação com ajuste automático de requisitos para estabilidade
- `ajustarRequisitosEstabilidade.m` - Algoritmo de otimização para encontrar requisitos que garantam estabilidade
- `gerarAnimacao.m` - Geração de animação visual do sistema
- `controladorBarra.slx` - Modelo Simulink com as malhas de posição e ângulo

### Controladores

- `obterMalhaAngular.m` - Controlador da malha interna (controle do ângulo θ)
- `obterMalhaTangencial.m` - Controlador da malha externa (controle da posição x)

### Configuração

- `obterPlanta.m` - Parâmetros físicos do sistema
- `obterRequisitos.m` - Requisitos de desempenho padrão
- `obterSaturacao.m` - Limites de saturação do sistema

### Arquivos de Teste e Análise

- `testeComparacaoControladores.m` - Compara diferentes tipos de controladores para uma mesma referência
- `testeDiferentesReferencias.m` - Testa um controlador específico com diferentes valores de referência

## Arquitetura de Controle

O sistema utiliza uma estratégia de controle hierárquica com duas malhas:

### Malha Interna (Controle Angular)
- **Controlador**: P+V (Proporcional + Velocidade)
- **Função**: Controla o ângulo θ da barra
- **Dinâmica**: Mais rápida
- **Requisitos**: tr = 0.1s, Mp = 0.05

### Malha Externa (Controle Tangencial)
- **Controladores disponíveis**: P, PI, PD, DI, PID
- **Função**: Controla a posição x da argola
- **Dinâmica**: Mais lenta
- **Requisitos padrão**: tr = 1.0s, Mp = 0.1, ts = 3.0s, tp = 2.0s

## Tipos de Controlador

A malha externa suporta cinco tipos de controladores:

1. **P** - Proporcional
2. **PI** - Proporcional-Integral
3. **PD** - Proporcional-Derivativo
4. **DI** - Derivativo-Integral
5. **PID** - Proporcional-Integral-Derivativo

## Requisitos de Tempo

O sistema permite especificar requisitos baseados em três critérios:

- **Tipo A**: Mp e tr (tempo de subida)
- **Tipo B**: Mp e tp (tempo de pico)
- **Tipo C**: Mp e ts (tempo de acomodação)

## Como Usar

### Simulação Básica

```matlab
% Definir posição desejada
xr = 2.0; % metros

% Escolher tipo de controlador
tipo = 'PID'; % ou 'P', 'PI', 'PD', 'DI'

% Escolher tipo de requisito
tipoRequisito = 'A'; % ou 'B', 'C'

% Definir os requisitos (pode não ser incluído)
requisitos.x.tr = 1.0;
requisitos.x.Mp = 0.1;
requisitos.x.ts = 3.0;
requisitos.x.tp = 2.0;
requisitos.theta.tr = 0.1;
requisitos.theta.Mp = 0.05;

% Executar simulação
simulacao = simularBarra(xr, tipo, tipoRequisito, plotarGraficos, requisitos);
```

### Simulação com Ajuste Automático de Estabilidade

```matlab
% Para sistemas que podem ser instáveis com os requisitos padrão, pode-se obter requisitos válidos usando
simulacao = simularBarraRequisitosEstabilidade(xr, tipo, tipoRequisito);
```

### Gerar Animação

```matlab
% Visualizar o comportamento do sistema
gerarAnimacao(xr, tipo, tipoRequisito);
```

### Análise Comparativa de Controladores

```matlab
% Comparar o desempenho de diferentes controladores para uma mesma referência
testeComparacaoControladores();
```

Este script executa automaticamente simulações para todos os tipos de controladores disponíveis (P, PI, PD, DI, PID) com uma referência fixa e gera:

- Gráficos comparativos de posição x(t), ângulo θ(t) e torque τ(t)
- Arquivo de imagem `comparacao_controladores.png`
- Métricas de desempenho para cada controlador

### Análise de Sensibilidade à Referência

```matlab
% Testar como diferentes valores de referência afetam o desempenho de um controlador
testeDiferentesReferencias();
```

Este script:

- Testa um controlador específico (configurável) com múltiplas referências
- Analisa como Mp, tr, ts e erro em regime permanente variam com a referência
- Gera gráficos mostrando:
  - Respostas temporais para diferentes referências
  - Métricas de desempenho vs. valor da referência
- Salva os resultados em `diferentes_referencias.png`
- Exibe tabela resumo com todas as métricas

## Funcionalidades Avançadas

### Ajuste Automático de Requisitos

O sistema inclui um algoritmo de otimização (Nelder-Mead) que automaticamente ajusta os requisitos de desempenho quando os valores originais resultam em um sistema instável. O algoritmo:

1. Busca o par (Mp, tr/tp/ts) mais próximo dos requisitos desejados
2. Garante estabilidade do sistema
3. Realiza até 10 tentativas dobrando o tempo a cada iteração
4. Informa as modificações realizadas

### Ferramentas de Análise

#### Comparação de Controladores
- **Função**: `testeComparacaoControladores()`
- **Objetivo**: Avaliar qual controlador oferece melhor desempenho para uma aplicação específica
- **Saída**: Gráficos comparativos e arquivo PNG

#### Análise de Sensibilidade
- **Função**: `testeDiferentesReferencias()`
- **Objetivo**: Verificar como o desempenho do controlador varia com diferentes valores de referência
- **Saída**: Gráficos de tendência e tabela de métricas

Ambas as ferramentas calculam automaticamente as métricas de desempenho:
- **Mp**: Sobressinal percentual
- **tr**: Tempo de subida (10% a 90% do valor final)
- **ts**: Tempo de acomodação (±2% do valor final)
- **tp**: Tempo de pico
- **ess**: Erro em regime permanente

## Dependências

- MATLAB/Simulink
- Control System Toolbox

## Autores

- Danilo Miranda Oliveira
- Geison Vasconcelos Lira Filho
- José Alberto Feijão Tizon