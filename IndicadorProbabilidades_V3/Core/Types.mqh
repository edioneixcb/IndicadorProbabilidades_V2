//+------------------------------------------------------------------+
//|                                    Core/Types.mqh |
//|                                    Indicador de Probabilidades V3 |
//|                                Tipos, Estruturas e Enumerações |
//+------------------------------------------------------------------+

#ifndef CORE_TYPES_MQH
#define CORE_TYPES_MQH

//+------------------------------------------------------------------+
//| Enumerações de Padrões                                          |
//+------------------------------------------------------------------+

/**
 * Tipos de padrões MHI disponíveis
 */
enum PatternType
{
    PATTERN_NONE = 0,           // Nenhum padrão
    PATTERN_MHI1 = 1,           // Padrão MHI1
    PATTERN_MHI2 = 2,           // Padrão MHI2
    PATTERN_MHI3 = 3,           // Padrão MHI3
    PATTERN_MHI4 = 4,           // Padrão MHI4
    PATTERN_MHI5 = 5,           // Padrão MHI5
    PATTERN_MHI6 = 6            // Padrão MHI6
};

//+------------------------------------------------------------------+
//| Enumerações de Interface                                        |
//+------------------------------------------------------------------+

/**
 * Posições disponíveis para o painel
 */
enum PanelPosition
{
    PANEL_TOP_LEFT = 0,         // Superior esquerdo
    PANEL_TOP_RIGHT = 1,        // Superior direito
    PANEL_BOTTOM_LEFT = 2,      // Inferior esquerdo
    PANEL_BOTTOM_RIGHT = 3,     // Inferior direito
    PANEL_CENTER = 4            // Centro
};

/**
 * Posições das setas de sinal
 */
enum ArrowPosition
{
    ARROW_ON_CANDLE = 0,        // Na vela
    ARROW_ABOVE_BELOW = 1,      // Acima/abaixo da vela
    ARROW_ON_EXTREME = 2        // Nas extremidades (high/low)
};

/**
 * Tipos de elementos do painel
 */
enum ElementType
{
    ELEMENT_LABEL = 0,          // Label de texto
    ELEMENT_BUTTON = 1,         // Botão clicável
    ELEMENT_PROGRESS = 2,       // Barra de progresso
    ELEMENT_SEPARATOR = 3       // Separador visual
};

//+------------------------------------------------------------------+
//| Enumerações de Sistema                                          |
//+------------------------------------------------------------------+

/**
 * Estados do sistema
 */
enum SystemState
{
    STATE_INITIALIZING = 0,     // Inicializando
    STATE_RUNNING = 1,          // Executando
    STATE_PAUSED = 2,           // Pausado
    STATE_ERROR = 3,            // Erro
    STATE_STOPPED = 4           // Parado
};

/**
 * Níveis de log
 */
enum LogLevel
{
    LOG_ERROR = 0,              // Apenas erros
    LOG_WARNING = 1,            // Avisos e erros
    LOG_INFO = 2,               // Informações gerais
    LOG_DEBUG = 3               // Debug detalhado
};

/**
 * Resultados de operações
 */
enum OperationResult
{
    RESULT_UNKNOWN = 0,         // Resultado desconhecido
    RESULT_WIN = 1,             // Vitória
    RESULT_LOSS = 2,            // Perda
    RESULT_DRAW = 3             // Empate
};

//+------------------------------------------------------------------+
//| Enumerações de Notificações                                     |
//+------------------------------------------------------------------+

/**
 * Corretoras suportadas pelo MX2
 */
enum BrokerMX2
{
    MX2_QUOTEX = 0,             // Quotex
    MX2_IQOPTION = 1,           // IQ Option
    MX2_BINOMO = 2,             // Binomo
    MX2_OLYMPTRADE = 3,         // Olymp Trade
    MX2_EXPERTOPTION = 4        // Expert Option
};

/**
 * Tipos de sinal MX2
 */
enum SignalTypeMX2
{
    MX2_CLOSED_CANDLE = 0,      // Vela fechada
    MX2_OPEN_CANDLE = 1,        // Vela aberta
    MX2_IMMEDIATE = 2           // Imediato
};

/**
 * Tipos de expiração MX2
 */
enum ExpirationTypeMX2
{
    MX2_CORRIDO = 0,            // Corrido
    MX2_EXATO = 1               // Exato
};

//+------------------------------------------------------------------+
//| Estruturas de Configuração                                      |
//+------------------------------------------------------------------+

/**
 * Configurações gerais do sistema
 */
struct GeneralConfig
{
    bool enabled;                       // Sistema habilitado
    bool enable_logging;                // Logging habilitado
    LogLevel log_level;                 // Nível de log
    bool enable_debug;                  // Modo debug
    int max_history_bars;               // Máximo de barras históricas
    int update_interval_ms;             // Intervalo de atualização (ms)
};

/**
 * Configurações de padrões
 */
struct PatternsConfig
{
    PatternType active_pattern;         // Padrão ativo
    bool enable_inversion;              // Inversão habilitada
    int min_confidence;                 // Confiança mínima
};

/**
 * Configurações visuais
 */
struct VisualConfig
{
    bool show_panel;                    // Mostrar painel
    PanelPosition panel_position;       // Posição do painel
    int panel_offset_x;                 // Offset X do painel
    int panel_offset_y;                 // Offset Y do painel
    color call_color;                   // Cor CALL
    color put_color;                    // Cor PUT
    color panel_background_color;       // Cor fundo painel
    color panel_border_color;           // Cor borda painel
    color panel_text_color;             // Cor texto painel
    bool show_arrows;                   // Mostrar setas
    ArrowPosition arrow_position;       // Posição das setas
};

/**
 * Configurações de filtros
 */
struct FiltersConfig
{
    bool enable_atr;                    // Filtro ATR habilitado
    int atr_period;                     // Período ATR
    double atr_multiplier;              // Multiplicador ATR
    bool enable_bollinger;              // Filtro Bollinger habilitado
    int bollinger_period;               // Período Bollinger
    double bollinger_deviation;         // Desvio Bollinger
    bool enable_trend;                  // Filtro tendência habilitado
    int trend_period;                   // Período tendência
};

/**
 * Configurações financeiras
 */
struct FinancialConfig
{
    double entry_value;                 // Valor de entrada
    double payout;                      // Payout
    bool enable_martingale;             // Martingale habilitado
    double martingale_factor;           // Fator martingale
    int max_gale_levels;                // Máximo níveis gale
    bool enable_stop_loss;              // Stop loss habilitado
    double stop_loss_value;             // Valor stop loss
    bool enable_stop_win;               // Stop win habilitado
    double stop_win_value;              // Valor stop win
    double daily_goal;                  // Meta diária
    double daily_limit;                 // Limite diário
};

/**
 * Configurações de notificações
 */
struct NotificationsConfig
{
    bool enable_telegram;               // Telegram habilitado
    string telegram_token;              // Token Telegram
    string telegram_chat_id;            // Chat ID Telegram
    string telegram_title;              // Título mensagens
    bool telegram_send_images;          // Enviar imagens
    bool notify_signals;                // Notificar sinais
    bool notify_results;                // Notificar resultados
    bool enable_mx2;                    // MX2 habilitado
    BrokerMX2 mx2_broker;              // Corretora MX2
    SignalTypeMX2 mx2_signal_type;     // Tipo sinal MX2
    ExpirationTypeMX2 mx2_expiry_type; // Tipo expiração MX2
    int mx2_expiry_minutes;             // Minutos expiração
};

/**
 * Configurações de SuperVarredura
 */
struct SuperScanConfig
{
    bool enabled;                       // SuperVarredura habilitada
    int analysis_bars;                  // Barras para análise
    int min_operations;                 // Mínimo operações
    double min_winrate;                 // WinRate mínimo
    bool auto_apply;                    // Aplicar automaticamente
};

/**
 * Configuração global do sistema
 */
struct SystemConfig
{
    GeneralConfig general;              // Configurações gerais
    PatternsConfig patterns;            // Configurações padrões
    VisualConfig visual;                // Configurações visuais
    FiltersConfig filters;              // Configurações filtros
    FinancialConfig financial;          // Configurações financeiras
    NotificationsConfig notifications;  // Configurações notificações
    SuperScanConfig superscan;          // Configurações SuperVarredura
};

//+------------------------------------------------------------------+
//| Estruturas de Dados                                             |
//+------------------------------------------------------------------+

/**
 * Resultado de detecção de padrão
 */
struct PatternDetectionResult
{
    bool pattern_detected;              // Padrão detectado
    PatternType pattern_type;           // Tipo do padrão
    bool is_call;                       // É sinal CALL
    double confidence;                  // Confiança (0-100)
    double signal_price;                // Preço do sinal
};

/**
 * Informações de um sinal
 */
struct SignalInfo
{
    datetime signal_time;               // Tempo do sinal
    PatternType pattern_type;           // Tipo do padrão
    bool is_call;                       // É sinal CALL
    double signal_price;                // Preço do sinal
    double confidence;                  // Confiança
    double atr_value;                   // Valor ATR
    bool filter_passed;                 // Filtros aprovados
};

/**
 * Estado dos filtros de mercado
 */
struct MarketFilters
{
    bool atr_filter_passed;             // Filtro ATR aprovado
    bool bollinger_filter_passed;       // Filtro Bollinger aprovado
    bool bollinger_bands_active;        // Bollinger Bands ativo
    bool trend_filter_passed;           // Filtro tendência aprovado
    int trend_direction;                // Direção tendência (-1, 0, 1)
    bool all_filters_passed;            // Todos filtros aprovados
};

/**
 * Simulação de martingale
 */
struct MartingaleSimulation
{
    double entry_values[MAX_MARTINGALE_LEVELS];     // Valores de entrada
    double total_investment[MAX_MARTINGALE_LEVELS]; // Investimento total
    double potential_profit[MAX_MARTINGALE_LEVELS]; // Lucro potencial
    double risk_percentage[MAX_MARTINGALE_LEVELS];  // Percentual de risco
};

/**
 * Estatísticas diárias
 */
struct DailyStatistics
{
    double sharpe_ratio;                // Sharpe Ratio
    double volatility;                  // Volatilidade
    double max_drawdown_value;          // Valor máximo drawdown
    double max_drawdown_percentage;     // Percentual máximo drawdown
    double recovery_factor;             // Fator de recuperação
    double calmar_ratio;                // Calmar Ratio
    double sortino_ratio;               // Sortino Ratio
};

/**
 * Análise de risco
 */
struct RiskAnalysis
{
    double var_95;                      // VaR 95%
    double var_99;                      // VaR 99%
    double expected_shortfall;          // Expected Shortfall
    double beta;                        // Beta
    double alpha;                       // Alpha
    double correlation;                 // Correlação
};

/**
 * Resultado de SuperVarredura
 */
struct SuperScanResult
{
    PatternType best_pattern;           // Melhor padrão
    double best_winrate;                // Melhor winrate
    int total_operations;               // Total operações
    int total_wins;                     // Total vitórias
    int total_losses;                   // Total perdas
    double total_profit;                // Lucro total
    double max_drawdown;                // Máximo drawdown
    bool recommendation_apply;          // Recomenda aplicar
};

//+------------------------------------------------------------------+
//| Funções de Conversão de Tipos                                   |
//+------------------------------------------------------------------+

/**
 * Converte PatternType para string
 * @param pattern_type Tipo do padrão
 * @return String descritiva
 */
string PatternTypeToString(PatternType pattern_type)
{
    switch(pattern_type)
    {
        case PATTERN_MHI1: return "MHI1";
        case PATTERN_MHI2: return "MHI2";
        case PATTERN_MHI3: return "MHI3";
        case PATTERN_MHI4: return "MHI4";
        case PATTERN_MHI5: return "MHI5";
        case PATTERN_MHI6: return "MHI6";
        case PATTERN_NONE:
        default: return "Nenhum";
    }
}

/**
 * Converte SystemState para string
 * @param state Estado do sistema
 * @return String descritiva
 */
string SystemStateToString(SystemState state)
{
    switch(state)
    {
        case STATE_INITIALIZING: return "Inicializando";
        case STATE_RUNNING: return "Executando";
        case STATE_PAUSED: return "Pausado";
        case STATE_ERROR: return "Erro";
        case STATE_STOPPED: return "Parado";
        default: return "Desconhecido";
    }
}

/**
 * Converte LogLevel para string
 * @param level Nível de log
 * @return String descritiva
 */
string LogLevelToString(LogLevel level)
{
    switch(level)
    {
        case LOG_ERROR: return "ERROR";
        case LOG_WARNING: return "WARNING";
        case LOG_INFO: return "INFO";
        case LOG_DEBUG: return "DEBUG";
        default: return "UNKNOWN";
    }
}

/**
 * Converte OperationResult para string
 * @param result Resultado da operação
 * @return String descritiva
 */
string OperationResultToString(OperationResult result)
{
    switch(result)
    {
        case RESULT_WIN: return "WIN";
        case RESULT_LOSS: return "LOSS";
        case RESULT_DRAW: return "DRAW";
        case RESULT_UNKNOWN:
        default: return "UNKNOWN";
    }
}

/**
 * Converte PanelPosition para string
 * @param position Posição do painel
 * @return String descritiva
 */
string PanelPositionToString(PanelPosition position)
{
    switch(position)
    {
        case PANEL_TOP_LEFT: return "Superior Esquerdo";
        case PANEL_TOP_RIGHT: return "Superior Direito";
        case PANEL_BOTTOM_LEFT: return "Inferior Esquerdo";
        case PANEL_BOTTOM_RIGHT: return "Inferior Direito";
        case PANEL_CENTER: return "Centro";
        default: return "Desconhecido";
    }
}

/**
 * Converte ArrowPosition para string
 * @param position Posição da seta
 * @return String descritiva
 */
string ArrowPositionToString(ArrowPosition position)
{
    switch(position)
    {
        case ARROW_ON_CANDLE: return "Na Vela";
        case ARROW_ABOVE_BELOW: return "Acima/Abaixo";
        case ARROW_ON_EXTREME: return "Extremidades";
        default: return "Desconhecido";
    }
}

/**
 * Converte BrokerMX2 para string
 * @param broker Corretora MX2
 * @return String descritiva
 */
string BrokerMX2ToString(BrokerMX2 broker)
{
    switch(broker)
    {
        case MX2_QUOTEX: return "Quotex";
        case MX2_IQOPTION: return "IQ Option";
        case MX2_BINOMO: return "Binomo";
        case MX2_OLYMPTRADE: return "Olymp Trade";
        case MX2_EXPERTOPTION: return "Expert Option";
        default: return "Desconhecido";
    }
}

//+------------------------------------------------------------------+
//| Funções de Validação de Tipos                                   |
//+------------------------------------------------------------------+

/**
 * Valida se um PatternType é válido
 * @param pattern_type Tipo do padrão
 * @return true se válido
 */
bool IsValidPatternType(PatternType pattern_type)
{
    return pattern_type >= PATTERN_NONE && pattern_type <= PATTERN_MHI6;
}

/**
 * Valida se um SystemState é válido
 * @param state Estado do sistema
 * @return true se válido
 */
bool IsValidSystemState(SystemState state)
{
    return state >= STATE_INITIALIZING && state <= STATE_STOPPED;
}

/**
 * Valida se um LogLevel é válido
 * @param level Nível de log
 * @return true se válido
 */
bool IsValidLogLevel(LogLevel level)
{
    return level >= LOG_ERROR && level <= LOG_DEBUG;
}

/**
 * Valida se um OperationResult é válido
 * @param result Resultado da operação
 * @return true se válido
 */
bool IsValidOperationResult(OperationResult result)
{
    return result >= RESULT_UNKNOWN && result <= RESULT_DRAW;
}

//+------------------------------------------------------------------+
//| Funções de Inicialização de Estruturas                          |
//+------------------------------------------------------------------+

/**
 * Inicializa estrutura PatternDetectionResult
 * @param result Estrutura a ser inicializada
 */
void InitializePatternDetectionResult(PatternDetectionResult &result)
{
    result.pattern_detected = false;
    result.pattern_type = PATTERN_NONE;
    result.is_call = false;
    result.confidence = 0.0;
    result.signal_price = 0.0;
}

/**
 * Inicializa estrutura SignalInfo
 * @param signal Estrutura a ser inicializada
 */
void InitializeSignalInfo(SignalInfo &signal)
{
    signal.signal_time = 0;
    signal.pattern_type = PATTERN_NONE;
    signal.is_call = false;
    signal.signal_price = 0.0;
    signal.confidence = 0.0;
    signal.atr_value = 0.0;
    signal.filter_passed = false;
}

/**
 * Inicializa estrutura MarketFilters
 * @param filters Estrutura a ser inicializada
 */
void InitializeMarketFilters(MarketFilters &filters)
{
    filters.atr_filter_passed = true;
    filters.bollinger_filter_passed = true;
    filters.bollinger_bands_active = false;
    filters.trend_filter_passed = true;
    filters.trend_direction = 0;
    filters.all_filters_passed = true;
}

#endif // CORE_TYPES_MQH

