# 🎮 Hyper Shooter - Documentação Completa

## 📋 Visão Geral

**Hyper Shooter** é um jogo hyper-casual roguelike em visão vertical (portrait) onde o jogador controla uma nave que atira automaticamente para cima, enfrentando ondas crescentes de inimigos. O diferencial do jogo está no **sistema de multiplicadores matemáticos** e no **sistema de upgrades roguelike progressivos**.

---

## 🎯 Conceito Central

### O Loop Principal

1. **Inimigos descem** em ondas progressivas
2. **Você atira** automaticamente para destruí-los
3. **Ganhe pontos** ao destruir inimigos
4. **Colete multiplicadores** para aumentar seus ganhos (buffs/debuffs)
5. **Escolha upgrades** a cada marco de pontos
6. **Sobreviva** o máximo possível enquanto sua pontuação cresce

---

## 👾 Tipos de Inimigos

### 1. **Inimigos Normais** (Vermelhos)
- **Vida**: 1 a 5+ hits (aumenta com as ondas)
- **Pontos**: 10 a 30+ (baseado na dificuldade)
- **Comportamento**: Descem em linha reta
- **Penalidade**: Se te atingir, causa dano (-10 HP)

### 2. **Inimigos Rápidos** (Amarelos)
- **Vida**: 1 hit
- **Velocidade**: 2x mais rápido
- **Pontos**: 20
- **Comportamento**: Descem rapidamente
- **Desafio**: Difíceis de acertar

### 3. **Inimigos Tanques** (Roxos Escuros)
- **Vida**: 5+ hits
- **Velocidade**: Mais lento
- **Pontos**: 50+
- **Comportamento**: Descem devagar mas são muito resistentes

---

## ✨ Sistema de Multiplicadores (Power-ups)

Multiplicadores aparecem descendo pela tela. Passe por eles para aplicar efeitos instantâneos!

### 🟢 Multiplicadores Positivos (Raros):
- **x2** → Dobra seus pontos atuais
- **x3** → Triplica seus pontos (muito raro!)
- **+100** → Soma 100 pontos direto
- **+50** → Soma 50 pontos

### 🔴 Debuffs (Mais comuns):
- **÷2** → DIVIDE seus pontos pela metade
- **-50** → Remove 50 pontos
- **-100** → Remove 100 pontos

### ⚡ Multiplicadores Especiais:
- **SHIELD** → Te protege do próximo debuff
- **FREEZE** → Congela inimigos por 3 segundos
- **NUKE** → Destrói todos os inimigos na tela

### Estratégia:
- **Buffs são raros** → Priorize pegar sempre!
- **Debuffs são comuns** → Evite ao máximo
- **Risk/Reward** → Às vezes vale arriscar pegar um debuff para não morrer
- **Timing** → Pegar x2 quando tem muitos pontos = game changer

---

## ⚡ Sistema Roguelike de Upgrades

### Como Funciona:

1. **Acumule pontos** destruindo inimigos
2. A cada **threshold de pontos**, o jogo **PAUSA**
3. Escolha **1 de 3 upgrades aleatórios**
4. Continue jogando mais forte

### Progressão de Upgrades:
```
Upgrade 1:  100 pontos
Upgrade 2:  200 pontos
Upgrade 3:  400 pontos
Upgrade 4:  800 pontos
Upgrade 5:  1600 pontos
...
Fórmula: 100 × (2^nível)
```

---

## 🔧 Tipos de Upgrades

### ⚡ **Cadência de Tiro**
- **Efeito**: Atira mais rápido
- **Níveis**: Reduz intervalo de 0.5s → 0.4s → 0.3s → 0.2s → 0.1s
- **Estratégia**: Essencial para matar inimigos rápido
- **Sinergia**: Combina bem com Dano e Multi-Tiro

### 💥 **Dano**
- **Efeito**: Cada tiro causa mais dano
- **Níveis**: +1 dano por nível (1 → 2 → 3 → 4 → 5)
- **Estratégia**: Crucial para inimigos tanques
- **Sinergia**: Fundamental para qualquer build

### 🎯 **Multi-Tiro**
- **Efeito**: Dispara múltiplas balas simultaneamente
- **Níveis**:
  - Nível 1: 1 bala central
  - Nível 2: 3 balas (centro + laterais ±15°)
  - Nível 3: 5 balas (spread completo ±30°)
  - Nível 4: 7 balas (cobertura total)
- **Estratégia**: Cobertura de área massiva
- **Sinergia**: Extremamente poderoso com Cadência

### ➡️ **Perfuração**
- **Efeito**: Balas atravessam múltiplos inimigos
- **Níveis**: +1 perfuração por nível (atravessa 1 → 2 → 3 → 4 inimigos)
- **Estratégia**: Destrói linhas de inimigos
- **Sinergia**: Incrível com Multi-Tiro e Dano

### 💨 **Velocidade da Bala**
- **Efeito**: Projéteis mais rápidos
- **Níveis**: +200 velocidade por nível
- **Estratégia**: Acerta inimigos antes que cheguem
- **Sinergia**: Combina com tudo

### 🛡️ **Escudo**
- **Efeito**: Adiciona HP extra
- **Níveis**: +20 HP por nível
- **Estratégia**: Sobrevivência pura
- **Sinergia**: Permite builds mais arriscadas

### 🔥 **Shockwave Damage**
- **Efeito**: Aumenta o dano do shockwave especial
- **Níveis**: +2 dano por nível (5 → 7 → 9 → 11)
- **Estratégia**: Transforma shockwave em arma devastadora
- **Sinergia**: Essencial para late game

---

## 🎲 Builds e Sinergias

### Build "Spray and Pray" 🌧️
```
Multi-Tiro (4) + Cadência (4) + Perfuração (2)
→ Tempestade de balas que atravessam tudo
```

### Build "Sniper" 🎯
```
Dano (5) + Velocidade (3) + Perfuração (3)
→ Tiros devastadores ultra-rápidos
```

### Build "Tank" 🛡️
```
Escudo (5) + Shockwave (4) + Dano (2)
→ Sobrevivência extrema com shockwave devastador
```

### Build "Machine Gun" 🔫
```
Cadência (5) + Multi-Tiro (3) + Velocidade (3)
→ Rajada infinita de projéteis
```

---

## 📈 Sistema de Progressão

### Ondas (Waves)
- Aumentam a cada 20-30 segundos
- Inimigos ficam mais fortes (mais vida)
- Mais inimigos por spawn
- Velocidade aumenta
- Mais multiplicadores negativos aparecem

### Pontuação
- **+10 a +50 pontos** por inimigo destruído (baseado na dificuldade)
- **Multiplicadores** podem aumentar dramaticamente
- **Combo system**: Matar inimigos rapidamente dá bonus (futuro)

### Curva de Dificuldade
```
Waves 1-3:   Tutorial suave (1-2 inimigos, vida baixa)
Waves 4-7:   Acelerando (2-3 inimigos, vida média)
Waves 8-12:  Desafio real (3-4 inimigos, tanques aparecem)
Waves 13+:   Sobrevivência extrema (4+ inimigos, velocidade alta)
```

---

## 🎮 Controles

### Desktop:
- **Mouse**: Move a nave horizontalmente
- **ESPAÇO**: Ativa shockwave especial (quando carregado)
- Tiros são **automáticos**

### Mobile:
- **Toque e arraste**: Controla a nave
- **Tap duplo**: Ativa shockwave (futuro)
- Tiros são **automáticos**

---

## ⚡ Habilidade Especial: Shockwave

### Como Funciona:
- Barra de carga que enche **matando inimigos** (15% por kill)
- Também carrega **passivamente** (100% em 5 segundos)
- Aperte **ESPAÇO** quando 100% carregado
- **Explosão circular** que causa dano em área (raio 600px)

### Mecânica:
- Dano base: 5 (matável por upgrades)
- Se dano ≥ vida do inimigo: **Mata** (pontos 2x)
- Se dano < vida: **Empurra** e causa dano parcial
- Visual: Explosão animada com 3 camadas rotacionando

### Estratégia:
- Use quando **cercado** de inimigos
- Timing é crucial: maximize kills
- Com upgrades, vira arma principal

---

## 🎯 Objetivos e Vitória

### Objetivo Principal:
**Sobreviver o máximo possível e fazer a maior pontuação**

### Condições de Derrota:
- **HP chega a 0** (inimigos te atingem)
- Não há "game over" por tempo

### Meta de Longo Prazo:
- Bater seu próprio **High Score**
- Descobrir **builds poderosas**
- Dominar o **timing de multiplicadores**
- Maximizar **eficiência de upgrades**

---

## 💡 Dicas Avançadas

### 1. **Gestão de Multiplicadores**
- **x2/x3 são RAROS** → Pegue sempre!
- **Divisores são COMUNS** → Evite religiosamente
- Use shockwave para limpar caminho até um buff
- Priorize multiplicadores no late game quando pontos são altos

### 2. **Escolha de Upgrades**
- **Early (0-500pts)**: Cadência + Multi-Tiro (DPS)
- **Mid (500-2000pts)**: Dano + Perfuração (Eficiência)
- **Late (2000+pts)**: Escudo + Shockwave (Sobrevivência)

### 3. **Posicionamento**
- Fique no **centro** para ter mobilidade
- Antecipe spawns de multiplicadores
- Use bordas para evitar debuffs
- Shockwave funciona melhor quando centralizado

### 4. **Economia de Shockwave**
- Não gaste cedo demais
- Espere ter 3+ inimigos no raio
- Use para "comprar tempo" quando overwhelmed
- Combine com multiplicadores para max value

---

## 🏆 Mecânicas Roguelike

### Por que é Roguelike?

1. **Cada run é única**
   - Upgrades aleatórios (3 opções)
   - Spawns variáveis
   - Multiplicadores imprevisíveis

2. **Progressão de skill**
   - Aprende timing de multiplicadores
   - Domina builds e sinergias
   - Melhora posicionamento

3. **Escalabilidade crescente**
   - Thresholds dobram a cada nível
   - Dificuldade aumenta constantemente
   - Decisões ficam mais críticas

4. **Build crafting**
   - Múltiplas estratégias viáveis
   - Combos inesperados
   - Meta-jogo profundo

---

## 🎨 Design Visual

### Código de Cores:
- **🔴 Vermelho**: Inimigos normais
- **🟡 Amarelo**: Inimigos rápidos
- **🟣 Roxo Escuro**: Tanques
- **🟢 Verde**: Multiplicadores positivos
- **🔴 Vermelho**: Debuffs
- **🔵 Azul**: Especiais (Shield, Freeze, Nuke)
- **⚪ Branco/Cyan**: Projéteis do player

### Feedback Visual:
- **Partículas** ao matar inimigos (explosão cyan)
- **Shockwave animado** (3 camadas expansivas)
- **Flash** no player ao usar shockwave
- **Barra de progresso** para próximo upgrade
- **Indicador visual** de HP do player

---

## 📊 Estatísticas na UI

### Durante o Jogo:
- **WAVE X**: Nível de dificuldade atual
- **Power**: Pontuação acumulada
- **SHOCKWAVE**: % de carga (verde = pronto)
- **HP**: Vida restante (futuro)

### No Game Over (futuro):
- **Pontuação Final**
- **High Score**
- **Wave alcançada**
- **Upgrades coletados**
- **Tempo sobrevivido**

---

## 🚀 Por que Hyper Shooter é Viciante?

1. **Loop imediato**: Ação constante, sem downtime
2. **Decisões de split-second**: Multiplicadores exigem reações rápidas
3. **Progressão clara**: Upgrades a cada X pontos
4. **Risk/Reward**: Debuffs vs Buffs cria tensão
5. **"Só mais uma"**: Sempre quer tentar nova build
6. **Skill ceiling alto**: Sempre há como otimizar

---


## 📱 Características Mobile-First

- **Portrait**: Joga com uma mão
- **Controles simples**: Só mover o dedo (+ tap para shockwave)
- **Sessões curtas**: 5-15 minutos por run
- **Progresso visual**: Sempre sabe quanto falta pro próximo upgrade
- **Feedback instantâneo**: Partículas, sons, screenshake

---

## 🎬 Diferencial Competitivo

**Hyper Shooter** se diferencia de outros bullet hell roguelikes por:

1. **Sistema de Multiplicadores**: Elemento de risco/recompensa único
2. **Debuffs frequentes**: Cria tensão constante
3. **Shockwave Carregável**: Skill timing crucial
4. **Upgrades claros**: Sem RNG excessivo, skill-based
5. **Mobile-first**: Otimizado para uma mão
6. **Runs curtas**: Respeitoso com tempo do jogador

**"Fácil de aprender, difícil de masterizar, impossível de largar."**
