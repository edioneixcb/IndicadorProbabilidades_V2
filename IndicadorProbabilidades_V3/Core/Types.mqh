//+------------------------------------------------------------------+
//|                                                  Core/Types.mqh |
//|                                    Indicador de Probabilidades V3 |
//|                              Sistema de Tipos e Estruturas de Dados |
//+------------------------------------------------------------------+

#ifndef CORE_TYPES_MQH
#define CORE_TYPES_MQH

#include "Defines.mqh"

//+------------------------------------------------------------------+
//| Enumeração Completa de Padrões de Análise                       |
//+------------------------------------------------------------------+
enum PatternType
{
    // Padrões MHI Básicos
    PatternMHI1_3C_Minoria = 0,         // MHI1: 3 Candles - Minoria
    PatternMHI2_3C_Maioria = 1,         // MHI2: 3 Candles - Maioria
    PatternMHI3_2C_Minoria = 2,         // MHI3: 2 Candles - Minoria
    PatternMHI4_2C_Maioria = 3,         // MHI4: 2 Candles - Maioria
    PatternMHI5_1C_Minoria = 4,         // MHI5: 1 Candle - Minoria
    PatternMHI6_1C_Maioria = 5,         // MHI6: 1 Candle - Maioria
    
    // Padrões Avançados
    PatternC3_SeguirCor = 6,            // C3: Seguir Cor
    PatternTorresGemeas_SeguirCor3 = 7, // Torres Gêmeas: Seguir Cor 3
    PatternMHI_Potencializada_Core = 8, // MHI Potencializada Core
    PatternMHI2_3C_Confirmado = 9,      // MHI2: 3C Confirmado
    PatternMHI3_Unanime_Base = 10,      // MHI3: Unânime Base
    
    // Padrões de Múltiplas Velas
    PatternM5_Variação_6C_Maioria = 11, // M5: Variação 6C Maioria
    PatternMilhao_6C_Maioria = 12,      // Milhão: 6C Maioria
    PatternFiveInARow_Base = 13,        // Five in a Row Base
    PatternThreeInARow_Base = 14,       // Three in a Row Base
    PatternFourInARow_Base = 15,        // Four in a Row Base
    PatternSevenInARow_Base = 16,       // Seven in a Row Base
    
    // Padrões de Maioria/Minoria
    PatternImpar_3C_Maioria = 17,       // Ímpar: 3C Maioria
    PatternMelhorDe3_Maioria = 18,      // Melhor de 3: Maioria
    Pattern3X1_ContinuacaoOposta = 19,  // 3x1: Continuação Oposta
    
    // Padrões Especiais
    PatternCustom1 = 20,                // Padrão Customizado 1
    PatternCustom2 = 21,                // Padrão Customizado 2
    PatternCustom3 = 22                 // Padrão Customizado 3
};

//+------------------------------------------------------------------+
//| Posicionamento de Setas                                         |
//+------------------------------------------------------------------+
enum ENUM_POSICAO_SETA
{
    POS_VELA_DE_ENTRADA = 0,            // Na vela de entrada
    POS_ACIMA_MAXIMA = 1,               // Acima da máxima
    POS_ABAIXO_MINIMA = 2,              // Abaixo da mínima
    POS_CENTRO_VELA = 3,                // Centro da vela
    POS_AUTOMATICA = 4                  // Posição automática
};

//+------------------------------------------------------------------+
//| Cores Visuais de Velas                                          |
//+------------------------------------------------------------------+
enum VisualCandleColor
{
    VISUAL_GREEN = 1,                   // Vela verde (alta)
    VISUAL_RED = -1,                    // Vela vermelha (baixa)
    VISUAL_DOJI = 0,                    // Vela doji
    VISUAL_INVALID = 999                // Vela inválida
};

//+------------------------------------------------------------------+
//| Estrutura de Informações de Sinal                               |
//+------------------------------------------------------------------+
struct SignalInfo
{
    datetime signal_time;               // Tempo do sinal
    double signal_price;                // Preço do sinal
    PatternType pattern_type;           // Tipo de padrão detectado
    bool is_call;                       // True para CALL, False para PUT
    double confidence;                  // Confiança do sinal (0-100)
    string description;                 // Descrição do sinal
    int bar_index;                      // Índice da barra
    bool inverted;                      // Sinal invertido
    double atr_value;                   // Valor do ATR no momento
    double bb_width;                    // Largura das Bandas de Bollinger
    bool filter_passed;                 // Passou pelos filtros
    string filter_details;              // Detalhes dos filtros
};

//+------------------------------------------------------------------+
//| Estrutura de Resultado de Operação                              |
//+------------------------------------------------------------------+
struct OperationInfo
{
    datetime entry_time;                // Tempo de entrada
    datetime expiry_time;               // Tempo de expiração
    double entry_price;                 // Preço de entrada
    double exit_price;                  // Preço de saída
    bool is_call;                       // Tipo de operação
    OperationResult result;             // Resultado da operação
    PatternType pattern_used;           // Padrão utilizado
    double entry_value;                 // Valor apostado
    double profit_loss;                 // Lucro/Prejuízo
    int gale_level;                     // Nível de gale (0, 1, 2)
    bool is_simulated;                  // Operação simulada
    string notes;                       // Observações
};

//+------------------------------------------------------------------+
//| Estrutura de Estatísticas por Padrão                            |
//+------------------------------------------------------------------+
struct PatternStatistics
{
    PatternType pattern_type;           // Tipo de padrão
    int total_signals;                  // Total de sinais
    int total_wins;                     // Total de vitórias
    int total_losses;                   // Total de perdas
    double winrate;                     // Taxa de acerto
    double total_profit;                // Lucro total
    double average_profit;              // Lucro médio
    double max_profit;                  // Maior lucro
    double max_loss;                    // Maior perda
    double confidence_avg;              // Confiança média
    datetime last_signal;               // Último sinal
    bool is_active;                     // Padrão ativo
    string performance_grade;           // Classificação (A, B, C, D, F)
};

//+------------------------------------------------------------------+
//| Estrutura de Condições de Mercado                               |
//+------------------------------------------------------------------+
struct MarketCondition
{
    datetime timestamp;                 // Timestamp da análise
    double atr_value;                   // Valor atual do ATR
    double atr_average;                 // ATR médio
    double bb_upper;                    // Banda superior
    double bb_middle;                   // Banda média
    double bb_lower;                    // Banda inferior
    double bb_width;                    // Largura das bandas
    double ema_value;                   // Valor da EMA
    double current_price;               // Preço atual
    double spread;                      // Spread atual
    long volume;                        // Volume
    bool is_consolidation;              // Em consolidação
    bool is_trending;                   // Em tendência
    bool is_volatile;                   // Volátil
    string market_phase;                // Fase do mercado
};

//+------------------------------------------------------------------+
//| Estrutura de Configuração de Filtros                            |
//+------------------------------------------------------------------+
struct FilterConfig
{
    // Filtro de Volatilidade
    bool enable_volatility_filter;      // Ativar filtro de volatilidade
    double atr_min;                     // ATR mínimo
    double atr_max;                     // ATR máximo
    int atr_period;                     // Período do ATR
    
    // Filtro de Consolidação
    bool enable_consolidation_filter;   // Ativar filtro de consolidação
    bool bb_only_consolidation;         // Apenas em consolidação
    int bb_period;                      // Período das Bandas
    double bb_deviation;                // Desvio das Bandas
    
    // Filtro de Tendência
    bool enable_trend_filter;           // Ativar filtro de tendência
    int ema_period;                     // Período da EMA
    ENUM_MA_METHOD ema_method;          // Método da EMA
    
    // Filtro de Horário
    bool enable_time_filter;            // Ativar filtro de horário
    string start_time;                  // Horário de início
    string end_time;                    // Horário de fim
    
    // Filtro de Spread
    bool enable_spread_filter;          // Ativar filtro de spread
    double max_spread;                  // Spread máximo
};

//+------------------------------------------------------------------+
//| Estrutura de Configuração Financeira                            |
//+------------------------------------------------------------------+
struct FinancialConfig
{
    double entry_value;                 // Valor de entrada
    double payout;                      // Payout da corretora
    double martingale_factor;           // Fator do martingale
    int max_gale_levels;                // Máximo de gales
    bool enable_martingale;             // Ativar martingale
    bool enable_stop_loss;              // Ativar stop loss
    double stop_loss_value;             // Valor do stop loss
    bool enable_stop_win;               // Ativar stop win
    double stop_win_value;              // Valor do stop win
    double daily_goal;                  // Meta diária
    double daily_limit;                 // Limite diário de perda
};

//+------------------------------------------------------------------+
//| Estrutura de Análise Financeira                                 |
//+------------------------------------------------------------------+
struct FinancialAnalysis
{
    datetime analysis_date;             // Data da análise
    double starting_balance;            // Saldo inicial
    double current_balance;             // Saldo atual
    double total_invested;              // Total investido
    double total_profit;                // Lucro total
    double total_loss;                  // Perda total
    double net_profit;                  // Lucro líquido
    double roi_percent;                 // ROI em percentual
    int total_operations;               // Total de operações
    int winning_operations;             // Operações vencedoras
    int losing_operations;              // Operações perdedoras
    double winrate;                     // Taxa de acerto
    double average_win;                 // Vitória média
    double average_loss;                // Perda média
    double profit_factor;               // Fator de lucro
    double max_drawdown;                // Máximo drawdown
    double recovery_factor;             // Fator de recuperação
    string performance_summary;         // Resumo da performance
};

//+------------------------------------------------------------------+
//| Estrutura de Configuração de SuperVarredura                     |
//+------------------------------------------------------------------+
struct SuperScanConfig
{
    bool enable_superscan;              // Ativar SuperVarredura
    bool auto_superscan;                // SuperVarredura automática
    int scan_interval_seconds;          // Intervalo de varredura
    SuperScanCriteria criteria;         // Critério de seleção
    double min_winrate;                 // Winrate mínimo
    int min_operations;                 // Operações mínimas
    int max_patterns_to_test;           // Máximo de padrões a testar
    int analysis_bars;                  // Barras para análise
    bool save_results;                  // Salvar resultados
    string results_file;                // Arquivo de resultados
};

//+------------------------------------------------------------------+
//| Estrutura de Resultado de SuperVarredura                        |
//+------------------------------------------------------------------+
struct SuperScanResult
{
    datetime scan_time;                 // Tempo da varredura
    PatternType best_pattern;           // Melhor padrão encontrado
    bool best_inverted;                 // Melhor configuração invertida
    double best_winrate;                // Melhor winrate
    double best_profit;                 // Melhor lucro
    int best_operations;                // Operações do melhor
    double confidence_score;            // Pontuação de confiança
    FilterConfig best_filters;          // Melhores filtros
    string analysis_summary;            // Resumo da análise
    PatternStatistics pattern_stats[];  // Estatísticas de todos os padrões
    bool scan_completed;                // Varredura concluída
    int scan_duration_ms;               // Duração da varredura
};

//+------------------------------------------------------------------+
//| Estrutura de Configuração de Notificações                       |
//+------------------------------------------------------------------+
struct NotificationConfig
{
    // Telegram
    bool enable_telegram;               // Ativar Telegram
    string telegram_token;              // Token do bot
    string telegram_chat_id;            // ID do chat
    string telegram_title;              // Título das mensagens
    bool telegram_send_images;          // Enviar imagens
    
    // MX2
    bool enable_mx2;                    // Ativar MX2
    BrokerMX2 mx2_broker;              // Corretora MX2
    SignalTypeMX2 mx2_signal_type;     // Tipo de sinal
    ExpirationTypeMX2 mx2_expiry_type; // Tipo de expiração
    int mx2_expiry_minutes;            // Minutos de expiração
    
    // Alertas do Terminal
    bool enable_alerts;                 // Ativar alertas
    bool enable_sound;                  // Ativar som
    bool enable_email;                  // Ativar email
    bool enable_push;                   // Ativar push
    
    // Configurações Gerais
    bool notify_signals;                // Notificar sinais
    bool notify_results;                // Notificar resultados
    bool notify_superscan;              // Notificar SuperVarredura
    bool notify_errors;                 // Notificar erros
};

//+------------------------------------------------------------------+
//| Estrutura de Estado do Sistema                                  |
//+------------------------------------------------------------------+
struct SystemStatus
{
    SystemState current_state;          // Estado atual
    datetime last_update;               // Última atualização
    datetime initialization_time;       // Tempo de inicialização
    bool is_initialized;                // Sistema inicializado
    bool is_running;                    // Sistema executando
    bool has_errors;                    // Tem erros
    string last_error;                  // Último erro
    int total_signals_today;            // Sinais hoje
    int total_operations_today;         // Operações hoje
    double daily_profit;                // Lucro diário
    double daily_winrate;               // Winrate diário
    PatternType active_pattern;         // Padrão ativo
    bool superscan_running;             // SuperVarredura executando
    double cpu_usage;                   // Uso de CPU
    double memory_usage;                // Uso de memória
    string version;                     // Versão do sistema
};

//+------------------------------------------------------------------+
//| Estrutura de Configuração Visual                                |
//+------------------------------------------------------------------+
struct VisualConfig
{
    // Painel
    bool show_panel;                    // Mostrar painel
    int panel_x;                        // Posição X do painel
    int panel_y;                        // Posição Y do painel
    color panel_bg_color;               // Cor de fundo
    color panel_border_color;           // Cor da borda
    color panel_text_color;             // Cor do texto
    
    // Setas
    bool show_arrows;                   // Mostrar setas
    ENUM_POSICAO_SETA arrow_position;   // Posição das setas
    uchar arrow_code_call;              // Código da seta CALL
    uchar arrow_code_put;               // Código da seta PUT
    color arrow_color_call;             // Cor da seta CALL
    color arrow_color_put;              // Cor da seta PUT
    int arrow_size;                     // Tamanho das setas
    
    // Marcadores
    bool show_result_markers;           // Mostrar marcadores de resultado
    bool show_statistics;               // Mostrar estatísticas
    bool show_timer;                    // Mostrar timer
    color timer_color;                  // Cor do timer
    
    // Gráficos
    bool show_charts;                   // Mostrar gráficos
    bool show_performance_chart;        // Mostrar gráfico de performance
    bool show_winrate_chart;            // Mostrar gráfico de winrate
    
    // Fonte
    string font_name;                   // Nome da fonte
    int font_size;                      // Tamanho da fonte
    int title_font_size;                // Tamanho da fonte do título
};

//+------------------------------------------------------------------+
//| Estrutura Principal de Configuração                             |
//+------------------------------------------------------------------+
struct IndicatorConfig
{
    // Configurações Básicas
    PatternType selected_pattern;       // Padrão selecionado
    bool invert_pattern;                // Inverter padrão
    int analysis_bars;                  // Barras para análise
    
    // Configurações de Módulos
    FilterConfig filters;               // Configuração de filtros
    FinancialConfig financial;          // Configuração financeira
    SuperScanConfig superscan;          // Configuração de SuperVarredura
    NotificationConfig notifications;   // Configuração de notificações
    VisualConfig visual;                // Configuração visual
    
    // Estado do Sistema
    SystemStatus status;                // Status do sistema
    
    // Configurações Avançadas
    bool enable_logging;                // Ativar logging
    int log_level;                      // Nível de log
    bool enable_cache;                  // Ativar cache
    int cache_size;                     // Tamanho do cache
    bool enable_performance_monitor;    // Ativar monitor de performance
};

//+------------------------------------------------------------------+
//| Funções de Conversão e Utilidade                                |
//+------------------------------------------------------------------+

// Converte PatternType para string
string PatternTypeToString(PatternType pattern)
{
    switch(pattern)
    {
        case PatternMHI1_3C_Minoria: return "MHI1 (3C Minoria)";
        case PatternMHI2_3C_Maioria: return "MHI2 (3C Maioria)";
        case PatternMHI3_2C_Minoria: return "MHI3 (2C Minoria)";
        case PatternMHI4_2C_Maioria: return "MHI4 (2C Maioria)";
        case PatternMHI5_1C_Minoria: return "MHI5 (1C Minoria)";
        case PatternMHI6_1C_Maioria: return "MHI6 (1C Maioria)";
        case PatternC3_SeguirCor: return "C3 Seguir Cor";
        case PatternTorresGemeas_SeguirCor3: return "Torres Gêmeas";
        case PatternMHI_Potencializada_Core: return "MHI Potencializada";
        case PatternMHI2_3C_Confirmado: return "MHI2 Confirmado";
        case PatternMHI3_Unanime_Base: return "MHI3 Unânime";
        case PatternM5_Variação_6C_Maioria: return "M5 Variação 6C";
        case PatternMilhao_6C_Maioria: return "Milhão 6C";
        case PatternFiveInARow_Base: return "Five in a Row";
        case PatternThreeInARow_Base: return "Three in a Row";
        case PatternFourInARow_Base: return "Four in a Row";
        case PatternSevenInARow_Base: return "Seven in a Row";
        case PatternImpar_3C_Maioria: return "Ímpar 3C";
        case PatternMelhorDe3_Maioria: return "Melhor de 3";
        case Pattern3X1_ContinuacaoOposta: return "3x1 Continuação";
        case PatternCustom1: return "Customizado 1";
        case PatternCustom2: return "Customizado 2";
        case PatternCustom3: return "Customizado 3";
        default: return "Desconhecido";
    }
}

// Converte SystemState para string
string SystemStateToString(SystemState state)
{
    switch(state)
    {
        case STATE_UNINITIALIZED: return "Não Inicializado";
        case STATE_INITIALIZING: return "Inicializando";
        case STATE_READY: return "Pronto";
        case STATE_RUNNING: return "Executando";
        case STATE_SUPERSCAN: return "SuperVarredura";
        case STATE_ERROR: return "Erro";
        case STATE_STOPPING: return "Parando";
        case STATE_STOPPED: return "Parado";
        default: return "Desconhecido";
    }
}

// Inicializa estrutura de configuração com valores padrão
void InitializeDefaultConfig(IndicatorConfig &config)
{
    // Configurações básicas
    config.selected_pattern = PatternMHI1_3C_Minoria;
    config.invert_pattern = false;
    config.analysis_bars = 1000;
    
    // Filtros
    config.filters.enable_volatility_filter = false;
    config.filters.atr_min = DEFAULT_ATR_MIN;
    config.filters.atr_max = DEFAULT_ATR_MAX;
    config.filters.atr_period = DEFAULT_ATR_PERIOD;
    config.filters.enable_consolidation_filter = true;
    config.filters.bb_only_consolidation = true;
    config.filters.bb_period = DEFAULT_BB_PERIOD;
    config.filters.bb_deviation = DEFAULT_BB_DEVIATION;
    config.filters.enable_trend_filter = false;
    config.filters.ema_period = DEFAULT_EMA_PERIOD;
    config.filters.ema_method = MODE_EMA;
    
    // Financeiro
    config.financial.entry_value = DEFAULT_ENTRY_VALUE;
    config.financial.payout = DEFAULT_PAYOUT;
    config.financial.martingale_factor = DEFAULT_MARTINGALE;
    config.financial.max_gale_levels = MAX_GALES_ANALYSIS;
    config.financial.enable_martingale = true;
    
    // SuperVarredura
    config.superscan.enable_superscan = false;
    config.superscan.auto_superscan = false;
    config.superscan.criteria = SUPERSCAN_BALANCED;
    config.superscan.min_winrate = SUPERSCAN_MIN_WINRATE;
    config.superscan.min_operations = SUPERSCAN_MIN_OPERATIONS;
    
    // Visual
    config.visual.show_panel = true;
    config.visual.show_arrows = true;
    config.visual.arrow_position = POS_VELA_DE_ENTRADA;
    config.visual.arrow_code_call = DEFAULT_ARROW_CALL;
    config.visual.arrow_code_put = DEFAULT_ARROW_PUT;
    config.visual.arrow_color_call = DEFAULT_CALL_COLOR;
    config.visual.arrow_color_put = DEFAULT_PUT_COLOR;
    config.visual.arrow_size = DEFAULT_ARROW_SIZE;
    config.visual.show_result_markers = true;
    config.visual.show_statistics = true;
    config.visual.show_timer = true;
    config.visual.font_name = DEFAULT_FONT_NAME;
    config.visual.font_size = DEFAULT_FONT_SIZE;
    
    // Sistema
    config.enable_logging = true;
    config.log_level = LOG_LEVEL_INFO;
    config.enable_cache = true;
    config.cache_size = DEFAULT_CACHE_SIZE;
    config.enable_performance_monitor = true;
    
    // Status
    config.status.current_state = STATE_UNINITIALIZED;
    config.status.is_initialized = false;
    config.status.is_running = false;
    config.status.has_errors = false;
    config.status.version = INDICATOR_VERSION;
}

#endif // CORE_TYPES_MQH

