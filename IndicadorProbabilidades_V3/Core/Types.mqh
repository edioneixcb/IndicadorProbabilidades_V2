//+------------------------------------------------------------------+
//|                                    Core/Types.mqh |
//|                                    Indicador de Probabilidades V3 |
//|                                Tipos e Estruturas do Sistema |
//+------------------------------------------------------------------+

#ifndef CORE_TYPES_MQH
#define CORE_TYPES_MQH

//+------------------------------------------------------------------+
//| Enumerações do Sistema                                          |
//+------------------------------------------------------------------+

/**
 * Estados do sistema
 */
enum SystemState
{
    STATE_INITIALIZING,     // Sistema inicializando
    STATE_RUNNING,          // Sistema em execução
    STATE_PAUSED,           // Sistema pausado
    STATE_ERROR,            // Sistema com erro
    STATE_STOPPED           // Sistema parado
};

/**
 * Tipos de padrões MHI
 */
enum PatternType
{
    PATTERN_NONE = 0,       // Nenhum padrão
    PATTERN_MHI1,           // Padrão MHI1
    PATTERN_MHI2,           // Padrão MHI2
    PATTERN_MHI3,           // Padrão MHI3
    PATTERN_MHI4,           // Padrão MHI4
    PATTERN_MHI5,           // Padrão MHI5
    PATTERN_MHI6            // Padrão MHI6
};

/**
 * Posições do painel visual
 */
enum PanelPosition
{
    PANEL_TOP_LEFT,         // Superior esquerdo
    PANEL_TOP_RIGHT,        // Superior direito
    PANEL_BOTTOM_LEFT,      // Inferior esquerdo
    PANEL_BOTTOM_RIGHT      // Inferior direito
};

/**
 * Posições das setas
 */
enum ArrowPosition
{
    ARROW_ABOVE_BELOW,      // Acima e abaixo das velas
    ARROW_FIXED_HEIGHT      // Altura fixa
};

/**
 * Níveis de log
 */
enum LogLevel
{
    LOG_ERROR = 0,          // Apenas erros
    LOG_WARNING,            // Avisos e erros
    LOG_INFO,               // Informações, avisos e erros
    LOG_DEBUG               // Todos os logs
};

/**
 * Corretoras MX2
 */
enum BrokerMX2
{
    MX2_QUOTEX = 0,         // Quotex
    MX2_POCKET = 1,         // Pocket Option
    MX2_OLYMP = 2,          // Olymp Trade
    MX2_EXPERT = 3,         // Expert Option
    MX2_SPECTRE = 4         // Spectre
};

//+------------------------------------------------------------------+
//| Estruturas de Dados                                             |
//+------------------------------------------------------------------+

/**
 * Configuração geral do sistema
 */
struct GeneralConfig
{
    bool enabled;                   // Sistema habilitado
    LogLevel log_level;             // Nível de log
    bool enable_debug;              // Modo debug
    int update_interval_ms;         // Intervalo de atualização (ms)
};

/**
 * Configuração de padrões
 */
struct PatternConfig
{
    PatternType active_pattern;     // Padrão ativo
    bool enable_inversion;          // Habilitar inversão
    int min_confidence;             // Confiança mínima (%)
};

/**
 * Configuração visual
 */
struct VisualConfig
{
    bool show_panel;                // Mostrar painel
    PanelPosition panel_position;   // Posição do painel
    int panel_offset_x;             // Offset X do painel
    int panel_offset_y;             // Offset Y do painel
    color call_color;               // Cor CALL
    color put_color;                // Cor PUT
    bool show_arrows;               // Mostrar setas
    ArrowPosition arrow_position;   // Posição das setas
};

/**
 * Configuração financeira
 */
struct FinancialConfig
{
    double entry_value;             // Valor de entrada
    double payout;                  // Payout
    bool enable_martingale;         // Habilitar martingale
    double martingale_factor;       // Fator martingale
    int max_gale_levels;            // Máximo níveis gale
    bool enable_stop_loss;          // Habilitar stop loss
    double stop_loss_value;         // Valor stop loss
    bool enable_stop_win;           // Habilitar stop win
    double stop_win_value;          // Valor stop win
};

/**
 * Configuração de filtros
 */
struct FilterConfig
{
    bool enable_atr;                // Filtro ATR
    int atr_period;                 // Período ATR
    double atr_multiplier;          // Multiplicador ATR
    bool enable_bollinger;          // Filtro Bollinger
    int bollinger_period;           // Período Bollinger
    double bollinger_deviation;     // Desvio Bollinger
    bool enable_trend;              // Filtro tendência
    int trend_period;               // Período tendência
};

/**
 * Configuração de notificações
 */
struct NotificationConfig
{
    bool enable_telegram;           // Habilitar Telegram
    string telegram_token;          // Token do bot
    string telegram_chat_id;        // Chat ID
    bool enable_mx2;                // Habilitar MX2
    BrokerMX2 mx2_broker;          // Corretora MX2
    int mx2_expiry_minutes;         // Expiração (minutos)
};

/**
 * Configuração de SuperVarredura
 */
struct SuperScanConfig
{
    bool enabled;                   // Habilitado
    int analysis_bars;              // Barras para análise
    int min_operations;             // Mínimo operações
    double min_winrate;             // WinRate mínimo (%)
    bool auto_apply;                // Aplicar automaticamente
};

/**
 * Configuração completa do sistema
 */
struct SystemConfig
{
    GeneralConfig general;          // Configuração geral
    PatternConfig patterns;         // Configuração de padrões
    VisualConfig visual;            // Configuração visual
    FinancialConfig financial;      // Configuração financeira
    FilterConfig filters;           // Configuração de filtros
    NotificationConfig notifications; // Configuração de notificações
    SuperScanConfig superscan;      // Configuração de SuperVarredura
};

/**
 * Resultado de detecção de padrão
 */
struct PatternDetectionResult
{
    bool pattern_detected;          // Padrão detectado
    PatternType pattern_type;       // Tipo do padrão
    bool is_call;                   // É CALL (true) ou PUT (false)
    double confidence;              // Confiança (0-100)
    double signal_price;            // Preço do sinal
    datetime detection_time;        // Tempo de detecção
};

/**
 * Informações do sinal
 */
struct SignalInfo
{
    datetime signal_time;           // Tempo do sinal
    PatternType pattern_type;       // Tipo do padrão
    bool is_call;                   // É CALL
    double signal_price;            // Preço do sinal
    double confidence;              // Confiança
    bool filter_passed;             // Passou pelos filtros
    double entry_value;             // Valor de entrada
    int martingale_level;           // Nível de martingale
};

/**
 * Filtros de mercado
 */
struct MarketFilters
{
    bool atr_filter_passed;         // Filtro ATR passou
    bool bollinger_filter_passed;   // Filtro Bollinger passou
    bool trend_filter_passed;       // Filtro tendência passou
    bool all_filters_passed;        // Todos os filtros passaram
    int trend_direction;            // Direção da tendência (-1, 0, 1)
    bool bollinger_bands_active;    // Bandas de Bollinger ativas
};

/**
 * Simulação de martingale
 */
struct MartingaleSimulation
{
    double entry_values[10];        // Valores de entrada por nível
    double total_investment[10];    // Investimento total por nível
    double potential_profit[10];    // Lucro potencial por nível
    double risk_percentage[10];     // Percentual de risco por nível
};

/**
 * Análise de risco
 */
struct RiskAnalysis
{
    double var_95;                  // VaR 95%
    double var_99;                  // VaR 99%
    double expected_shortfall;      // Expected Shortfall
    double beta;                    // Beta
    double alpha;                   // Alpha
    double correlation;             // Correlação
};

/**
 * Estatísticas diárias
 */
struct DailyStatistics
{
    double sharpe_ratio;            // Sharpe Ratio
    double volatility;              // Volatilidade
    double max_drawdown_value;      // Máximo drawdown (valor)
    double max_drawdown_percentage; // Máximo drawdown (%)
    double recovery_factor;         // Fator de recuperação
    double calmar_ratio;            // Calmar Ratio
    double sortino_ratio;           // Sortino Ratio
};

/**
 * Resultado de SuperVarredura
 */
struct SuperScanResult
{
    PatternType best_pattern;       // Melhor padrão
    double best_winrate;            // Melhor winrate
    int total_operations;           // Total de operações
    int total_wins;                 // Total de vitórias
    int total_losses;               // Total de perdas
    double total_profit;            // Lucro total
    double max_drawdown;            // Máximo drawdown
    bool recommendation_apply;      // Recomendação para aplicar
};

/**
 * Informações de operação
 */
struct OperationInfo
{
    datetime operation_time;        // Tempo da operação
    PatternType pattern_used;       // Padrão usado
    bool is_call;                   // É CALL
    double entry_price;             // Preço de entrada
    double entry_value;             // Valor de entrada
    int martingale_level;           // Nível de martingale
    bool result_win;                // Resultado (vitória)
    double profit_loss;             // Lucro/Prejuízo
    double balance_after;           // Saldo após operação
};

/**
 * Configuração do Telegram
 */
struct TelegramConfig
{
    string bot_token;               // Token do bot
    string chat_id;                 // Chat ID
    bool enabled;                   // Habilitado
    int retry_attempts;             // Tentativas de retry
    int retry_delay_ms;             // Delay entre tentativas (ms)
    bool send_signals;              // Enviar sinais
    bool send_results;              // Enviar resultados
    bool send_statistics;           // Enviar estatísticas
};

/**
 * Templates de mensagem
 */
struct MessageTemplates
{
    string signal_template;         // Template de sinal
    string result_template;         // Template de resultado
    string statistics_template;     // Template de estatísticas
    string error_template;          // Template de erro
};

//+------------------------------------------------------------------+
//| Funções de Inicialização de Estruturas                          |
//+------------------------------------------------------------------+

/**
 * Inicializa resultado de detecção de padrão
 */
void InitializePatternDetectionResult(PatternDetectionResult &result)
{
    result.pattern_detected = false;
    result.pattern_type = PATTERN_NONE;
    result.is_call = false;
    result.confidence = 0.0;
    result.signal_price = 0.0;
    result.detection_time = 0;
}

/**
 * Inicializa informações do sinal
 */
void InitializeSignalInfo(SignalInfo &signal)
{
    signal.signal_time = 0;
    signal.pattern_type = PATTERN_NONE;
    signal.is_call = false;
    signal.signal_price = 0.0;
    signal.confidence = 0.0;
    signal.filter_passed = false;
    signal.entry_value = 0.0;
    signal.martingale_level = 0;
}

/**
 * Inicializa filtros de mercado
 */
void InitializeMarketFilters(MarketFilters &filters)
{
    filters.atr_filter_passed = true;
    filters.bollinger_filter_passed = true;
    filters.trend_filter_passed = true;
    filters.all_filters_passed = true;
    filters.trend_direction = 0;
    filters.bollinger_bands_active = false;
}

//+------------------------------------------------------------------+
//| Funções de Conversão                                            |
//+------------------------------------------------------------------+

/**
 * Converte PatternType para string
 */
string PatternTypeToString(PatternType pattern)
{
    switch(pattern)
    {
        case PATTERN_MHI1: return "MHI1";
        case PATTERN_MHI2: return "MHI2";
        case PATTERN_MHI3: return "MHI3";
        case PATTERN_MHI4: return "MHI4";
        case PATTERN_MHI5: return "MHI5";
        case PATTERN_MHI6: return "MHI6";
        default: return "NONE";
    }
}

/**
 * Converte BrokerMX2 para string
 */
string BrokerMX2ToString(BrokerMX2 broker)
{
    switch(broker)
    {
        case MX2_QUOTEX: return "Quotex";
        case MX2_POCKET: return "Pocket Option";
        case MX2_OLYMP: return "Olymp Trade";
        case MX2_EXPERT: return "Expert Option";
        case MX2_SPECTRE: return "Spectre";
        default: return "Unknown";
    }
}

/**
 * Formata valor monetário
 */
string FormatCurrency(double value)
{
    return "R$ " + DoubleToString(value, 2);
}

/**
 * Formata percentual
 */
string FormatPercentage(double value)
{
    return DoubleToString(value, 1) + "%";
}

#endif // CORE_TYPES_MQH

