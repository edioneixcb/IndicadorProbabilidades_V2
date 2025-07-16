//+------------------------------------------------------------------+
//|                                                Core/Globals.mqh |
//|                                    Indicador de Probabilidades V3 |
//|                                Sistema de Variáveis Globais |
//+------------------------------------------------------------------+

#ifndef CORE_GLOBALS_MQH
#define CORE_GLOBALS_MQH

#include "Types.mqh"
#include "Defines.mqh"

//+------------------------------------------------------------------+
//| Configuração Principal do Sistema                               |
//+------------------------------------------------------------------+
IndicatorConfig g_config;               // Configuração principal do sistema

//+------------------------------------------------------------------+
//| Estado e Status do Sistema                                      |
//+------------------------------------------------------------------+
SystemStatus g_system_status;           // Status atual do sistema
datetime g_last_bar_time = 0;          // Tempo da última barra processada
datetime g_last_update_time = 0;       // Última atualização do sistema
bool g_is_new_bar = false;             // Flag de nova barra
bool g_system_ready = false;           // Sistema pronto para operação
bool g_initialization_complete = false; // Inicialização completa
string g_last_error_message = "";      // Última mensagem de erro
int g_error_count = 0;                 // Contador de erros

//+------------------------------------------------------------------+
//| Buffers do Indicador                                           |
//+------------------------------------------------------------------+
double g_buffer_call[];                // Buffer para sinais CALL
double g_buffer_put[];                 // Buffer para sinais PUT
double g_buffer_confidence[];          // Buffer para confiança dos sinais
double g_buffer_results[];             // Buffer para resultados

//+------------------------------------------------------------------+
//| Handles de Indicadores Técnicos                                |
//+------------------------------------------------------------------+
int g_handle_atr = INVALID_HANDLE;     // Handle do ATR
int g_handle_bb = INVALID_HANDLE;      // Handle das Bollinger Bands
int g_handle_ema = INVALID_HANDLE;     // Handle da EMA
int g_handle_rsi = INVALID_HANDLE;     // Handle do RSI
int g_handle_macd = INVALID_HANDLE;    // Handle do MACD
int g_handle_stoch = INVALID_HANDLE;   // Handle do Stochastic

//+------------------------------------------------------------------+
//| Arrays de Cache de Dados                                       |
//+------------------------------------------------------------------+
double g_cache_atr[];                  // Cache do ATR
double g_cache_bb_upper[];             // Cache da banda superior
double g_cache_bb_middle[];            // Cache da banda média
double g_cache_bb_lower[];             // Cache da banda inferior
double g_cache_ema[];                  // Cache da EMA
double g_cache_rsi[];                  // Cache do RSI
double g_cache_macd_main[];            // Cache do MACD principal
double g_cache_macd_signal[];          // Cache do sinal MACD
double g_cache_stoch_main[];           // Cache do Stochastic principal
double g_cache_stoch_signal[];         // Cache do sinal Stochastic

//+------------------------------------------------------------------+
//| Arrays de Dados de Mercado                                     |
//+------------------------------------------------------------------+
datetime g_time_cache[];              // Cache de tempo
double g_open_cache[];                // Cache de abertura
double g_high_cache[];                // Cache de máxima
double g_low_cache[];                 // Cache de mínima
double g_close_cache[];               // Cache de fechamento
long g_volume_cache[];                // Cache de volume
int g_spread_cache[];                 // Cache de spread

//+------------------------------------------------------------------+
//| Estatísticas e Contadores                                      |
//+------------------------------------------------------------------+
int g_total_signals_today = 0;        // Total de sinais hoje
int g_total_operations_today = 0;     // Total de operações hoje
int g_total_wins_today = 0;           // Total de vitórias hoje
int g_total_losses_today = 0;         // Total de perdas hoje
double g_daily_profit = 0.0;          // Lucro diário
double g_daily_winrate = 0.0;         // Winrate diário
double g_current_balance = 0.0;       // Saldo atual simulado
double g_starting_balance = 0.0;      // Saldo inicial

//+------------------------------------------------------------------+
//| Estatísticas por Padrão                                        |
//+------------------------------------------------------------------+
PatternStatistics g_pattern_stats[];   // Estatísticas de todos os padrões
int g_pattern_signals_count[];         // Contador de sinais por padrão
double g_pattern_winrates[];           // Winrates por padrão
double g_pattern_profits[];            // Lucros por padrão

//+------------------------------------------------------------------+
//| Histórico de Operações                                         |
//+------------------------------------------------------------------+
OperationInfo g_operations_history[];  // Histórico de operações
SignalInfo g_signals_history[];        // Histórico de sinais
int g_max_history_size = 1000;        // Tamanho máximo do histórico

//+------------------------------------------------------------------+
//| SuperVarredura                                                 |
//+------------------------------------------------------------------+
SuperScanResult g_superscan_result;    // Resultado da última SuperVarredura
bool g_superscan_running = false;      // SuperVarredura em execução
datetime g_last_superscan_time = 0;    // Última execução da SuperVarredura
PatternType g_superscan_best_pattern = PatternMHI1_3C_Minoria; // Melhor padrão encontrado
bool g_superscan_best_inverted = false; // Melhor configuração invertida
double g_superscan_best_winrate = 0.0; // Melhor winrate encontrado

//+------------------------------------------------------------------+
//| Análise Financeira                                             |
//+------------------------------------------------------------------+
FinancialAnalysis g_financial_analysis; // Análise financeira atual
double g_current_entry_value = 0.0;    // Valor de entrada atual
int g_current_gale_level = 0;          // Nível de gale atual
double g_session_profit = 0.0;         // Lucro da sessão
double g_session_loss = 0.0;           // Perda da sessão
bool g_stop_loss_triggered = false;    // Stop loss acionado
bool g_stop_win_triggered = false;     // Stop win acionado

//+------------------------------------------------------------------+
//| Condições de Mercado                                           |
//+------------------------------------------------------------------+
MarketCondition g_market_condition;    // Condição atual do mercado
bool g_market_is_open = false;         // Mercado aberto
bool g_market_is_volatile = false;     // Mercado volátil
bool g_market_is_trending = false;     // Mercado em tendência
bool g_market_is_consolidating = false; // Mercado em consolidação
string g_market_session = "";          // Sessão do mercado (Asian, European, American)

//+------------------------------------------------------------------+
//| Filtros de Mercado                                             |
//+------------------------------------------------------------------+
bool g_volatility_filter_passed = true; // Filtro de volatilidade passou
bool g_consolidation_filter_passed = true; // Filtro de consolidação passou
bool g_trend_filter_passed = true;     // Filtro de tendência passou
bool g_time_filter_passed = true;      // Filtro de horário passou
bool g_spread_filter_passed = true;    // Filtro de spread passou
bool g_volume_filter_passed = true;    // Filtro de volume passou

//+------------------------------------------------------------------+
//| Notificações                                                   |
//+------------------------------------------------------------------+
bool g_telegram_initialized = false;   // Telegram inicializado
bool g_mx2_initialized = false;        // MX2 inicializado
datetime g_last_telegram_sent = 0;     // Última mensagem Telegram enviada
datetime g_last_mx2_sent = 0;          // Último sinal MX2 enviado
int g_telegram_message_count = 0;      // Contador de mensagens Telegram
int g_mx2_signal_count = 0;            // Contador de sinais MX2

//+------------------------------------------------------------------+
//| Interface Visual                                               |
//+------------------------------------------------------------------+
bool g_panel_created = false;          // Painel criado
bool g_panel_visible = true;           // Painel visível
datetime g_last_panel_update = 0;      // Última atualização do painel
int g_panel_update_counter = 0;        // Contador de atualizações do painel
bool g_charts_created = false;         // Gráficos criados
bool g_timer_created = false;          // Timer criado

//+------------------------------------------------------------------+
//| Performance e Monitoramento                                    |
//+------------------------------------------------------------------+
uint g_performance_start_time = 0;     // Tempo de início para medição
uint g_total_execution_time = 0;       // Tempo total de execução
uint g_max_execution_time = 0;         // Maior tempo de execução
uint g_min_execution_time = UINT_MAX;  // Menor tempo de execução
uint g_execution_count = 0;            // Contador de execuções
double g_average_execution_time = 0.0; // Tempo médio de execução
long g_memory_usage = 0;               // Uso de memória
double g_cpu_usage = 0.0;              // Uso de CPU

//+------------------------------------------------------------------+
//| Cache e Otimização                                             |
//+------------------------------------------------------------------+
bool g_cache_initialized = false;      // Cache inicializado
datetime g_cache_last_update = 0;      // Última atualização do cache
int g_cache_hit_count = 0;             // Contador de cache hits
int g_cache_miss_count = 0;            // Contador de cache misses
double g_cache_hit_ratio = 0.0;        // Taxa de acerto do cache
bool g_cache_needs_refresh = false;    // Cache precisa ser atualizado

//+------------------------------------------------------------------+
//| Eventos e Timers                                               |
//+------------------------------------------------------------------+
datetime g_last_timer_event = 0;       // Último evento de timer
int g_timer_event_count = 0;           // Contador de eventos de timer
bool g_chart_event_active = false;     // Evento de gráfico ativo
string g_last_chart_event = "";        // Último evento de gráfico
datetime g_last_signal_time = 0;       // Tempo do último sinal
int g_signal_event_count = 0;          // Contador de eventos de sinal

//+------------------------------------------------------------------+
//| Configurações de Debug e Log                                   |
//+------------------------------------------------------------------+
bool g_debug_mode = false;             // Modo debug ativo
int g_log_level = LOG_LEVEL_INFO;      // Nível de log atual
string g_log_file_name = "";           // Nome do arquivo de log
int g_log_message_count = 0;           // Contador de mensagens de log
datetime g_last_log_rotation = 0;      // Última rotação de log

//+------------------------------------------------------------------+
//| Padrões Ativos e Configurações                                 |
//+------------------------------------------------------------------+
PatternType g_active_pattern = PatternMHI1_3C_Minoria; // Padrão ativo atual
bool g_pattern_inverted = false;       // Padrão invertido
double g_pattern_confidence_threshold = 70.0; // Limite de confiança
bool g_pattern_auto_select = false;    // Seleção automática de padrão
PatternType g_backup_patterns[];       // Padrões de backup

//+------------------------------------------------------------------+
//| Dados de Sessão                                                |
//+------------------------------------------------------------------+
datetime g_session_start_time = 0;     // Início da sessão
datetime g_session_end_time = 0;       // Fim da sessão
int g_session_duration_minutes = 0;    // Duração da sessão em minutos
bool g_session_active = false;         // Sessão ativa
string g_session_summary = "";         // Resumo da sessão

//+------------------------------------------------------------------+
//| Configurações de Timeframe                                     |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES g_current_timeframe = PERIOD_CURRENT; // Timeframe atual
int g_timeframe_multiplier = 1;        // Multiplicador do timeframe
bool g_multi_timeframe_analysis = false; // Análise multi-timeframe
ENUM_TIMEFRAMES g_analysis_timeframes[]; // Timeframes para análise

//+------------------------------------------------------------------+
//| Dados de Correlação                                            |
//+------------------------------------------------------------------+
string g_correlated_symbols[];         // Símbolos correlacionados
double g_correlation_coefficients[];   // Coeficientes de correlação
bool g_correlation_analysis_enabled = false; // Análise de correlação ativa

//+------------------------------------------------------------------+
//| Configurações de Risco                                         |
//+------------------------------------------------------------------+
double g_max_daily_loss = 0.0;         // Perda máxima diária
double g_max_consecutive_losses = 0.0; // Perdas consecutivas máximas
int g_max_operations_per_day = 0;      // Operações máximas por dia
bool g_risk_management_active = true;  // Gestão de risco ativa
double g_current_risk_level = 0.0;     // Nível de risco atual

//+------------------------------------------------------------------+
//| Dados de Backtesting                                           |
//+------------------------------------------------------------------+
bool g_backtesting_mode = false;       // Modo backtesting
datetime g_backtest_start_date = 0;    // Data de início do backtest
datetime g_backtest_end_date = 0;      // Data de fim do backtest
double g_backtest_initial_balance = 0.0; // Saldo inicial do backtest
OperationInfo g_backtest_operations[]; // Operações do backtest

//+------------------------------------------------------------------+
//| Configurações de Otimização                                    |
//+------------------------------------------------------------------+
bool g_optimization_mode = false;      // Modo otimização
string g_optimization_criteria = "";   // Critério de otimização
double g_optimization_target = 0.0;    // Meta de otimização
bool g_genetic_algorithm_enabled = false; // Algoritmo genético ativo

//+------------------------------------------------------------------+
//| Funções de Inicialização de Variáveis Globais                  |
//+------------------------------------------------------------------+

/**
 * Inicializa todas as variáveis globais com valores padrão
 */
void InitializeGlobalVariables()
{
    // Inicializa configuração padrão
    InitializeDefaultConfig(g_config);
    
    // Inicializa status do sistema
    g_system_status.current_state = STATE_UNINITIALIZED;
    g_system_status.initialization_time = TimeCurrent();
    g_system_status.is_initialized = false;
    g_system_status.is_running = false;
    g_system_status.has_errors = false;
    g_system_status.version = INDICATOR_VERSION;
    
    // Inicializa arrays de cache
    ArraySetAsSeries(g_cache_atr, true);
    ArraySetAsSeries(g_cache_bb_upper, true);
    ArraySetAsSeries(g_cache_bb_middle, true);
    ArraySetAsSeries(g_cache_bb_lower, true);
    ArraySetAsSeries(g_cache_ema, true);
    ArraySetAsSeries(g_cache_rsi, true);
    ArraySetAsSeries(g_cache_macd_main, true);
    ArraySetAsSeries(g_cache_macd_signal, true);
    ArraySetAsSeries(g_cache_stoch_main, true);
    ArraySetAsSeries(g_cache_stoch_signal, true);
    
    // Inicializa arrays de dados de mercado
    ArraySetAsSeries(g_time_cache, true);
    ArraySetAsSeries(g_open_cache, true);
    ArraySetAsSeries(g_high_cache, true);
    ArraySetAsSeries(g_low_cache, true);
    ArraySetAsSeries(g_close_cache, true);
    ArraySetAsSeries(g_volume_cache, true);
    ArraySetAsSeries(g_spread_cache, true);
    
    // Inicializa buffers do indicador
    ArraySetAsSeries(g_buffer_call, true);
    ArraySetAsSeries(g_buffer_put, true);
    ArraySetAsSeries(g_buffer_confidence, true);
    ArraySetAsSeries(g_buffer_results, true);
    
    // Inicializa arrays de estatísticas
    ArrayResize(g_pattern_stats, 25); // Para todos os padrões
    ArrayResize(g_pattern_signals_count, 25);
    ArrayResize(g_pattern_winrates, 25);
    ArrayResize(g_pattern_profits, 25);
    
    // Inicializa histórico
    ArrayResize(g_operations_history, 0);
    ArrayResize(g_signals_history, 0);
    
    // Inicializa condição de mercado
    g_market_condition.timestamp = TimeCurrent();
    g_market_condition.market_phase = "Inicializando";
    
    // Inicializa análise financeira
    g_financial_analysis.analysis_date = TimeCurrent();
    g_financial_analysis.starting_balance = g_config.financial.entry_value * 10; // 10x valor de entrada
    g_financial_analysis.current_balance = g_financial_analysis.starting_balance;
    g_current_balance = g_financial_analysis.starting_balance;
    g_starting_balance = g_financial_analysis.starting_balance;
    
    // Inicializa SuperVarredura
    g_superscan_result.scan_time = 0;
    g_superscan_result.best_pattern = PatternMHI1_3C_Minoria;
    g_superscan_result.scan_completed = false;
    
    // Inicializa contadores
    g_total_signals_today = 0;
    g_total_operations_today = 0;
    g_total_wins_today = 0;
    g_total_losses_today = 0;
    g_daily_profit = 0.0;
    g_daily_winrate = 0.0;
    
    // Inicializa sessão
    g_session_start_time = TimeCurrent();
    g_session_active = true;
    
    // Inicializa timeframe
    g_current_timeframe = _Period;
    
    // Marca inicialização como completa
    g_initialization_complete = true;
    
    Print("Variáveis globais inicializadas com sucesso");
}

/**
 * Limpa e libera recursos das variáveis globais
 */
void CleanupGlobalVariables()
{
    // Libera handles de indicadores
    if(g_handle_atr != INVALID_HANDLE) IndicatorRelease(g_handle_atr);
    if(g_handle_bb != INVALID_HANDLE) IndicatorRelease(g_handle_bb);
    if(g_handle_ema != INVALID_HANDLE) IndicatorRelease(g_handle_ema);
    if(g_handle_rsi != INVALID_HANDLE) IndicatorRelease(g_handle_rsi);
    if(g_handle_macd != INVALID_HANDLE) IndicatorRelease(g_handle_macd);
    if(g_handle_stoch != INVALID_HANDLE) IndicatorRelease(g_handle_stoch);
    
    // Limpa arrays
    ArrayFree(g_cache_atr);
    ArrayFree(g_cache_bb_upper);
    ArrayFree(g_cache_bb_middle);
    ArrayFree(g_cache_bb_lower);
    ArrayFree(g_cache_ema);
    ArrayFree(g_cache_rsi);
    ArrayFree(g_cache_macd_main);
    ArrayFree(g_cache_macd_signal);
    ArrayFree(g_cache_stoch_main);
    ArrayFree(g_cache_stoch_signal);
    
    ArrayFree(g_time_cache);
    ArrayFree(g_open_cache);
    ArrayFree(g_high_cache);
    ArrayFree(g_low_cache);
    ArrayFree(g_close_cache);
    ArrayFree(g_volume_cache);
    ArrayFree(g_spread_cache);
    
    ArrayFree(g_pattern_stats);
    ArrayFree(g_pattern_signals_count);
    ArrayFree(g_pattern_winrates);
    ArrayFree(g_pattern_profits);
    
    ArrayFree(g_operations_history);
    ArrayFree(g_signals_history);
    
    // Reset de flags
    g_system_ready = false;
    g_initialization_complete = false;
    g_cache_initialized = false;
    g_panel_created = false;
    g_charts_created = false;
    g_timer_created = false;
    
    Print("Limpeza de variáveis globais concluída");
}

/**
 * Atualiza estatísticas globais
 */
void UpdateGlobalStatistics()
{
    // Atualiza winrate diário
    if(g_total_operations_today > 0)
    {
        g_daily_winrate = (double)g_total_wins_today / g_total_operations_today * 100.0;
    }
    
    // Atualiza análise financeira
    g_financial_analysis.current_balance = g_current_balance;
    g_financial_analysis.total_operations = g_total_operations_today;
    g_financial_analysis.winning_operations = g_total_wins_today;
    g_financial_analysis.losing_operations = g_total_losses_today;
    g_financial_analysis.winrate = g_daily_winrate;
    g_financial_analysis.net_profit = g_daily_profit;
    
    if(g_financial_analysis.starting_balance > 0)
    {
        g_financial_analysis.roi_percent = (g_current_balance - g_financial_analysis.starting_balance) / 
                                          g_financial_analysis.starting_balance * 100.0;
    }
    
    // Atualiza status do sistema
    g_system_status.total_signals_today = g_total_signals_today;
    g_system_status.total_operations_today = g_total_operations_today;
    g_system_status.daily_profit = g_daily_profit;
    g_system_status.daily_winrate = g_daily_winrate;
    g_system_status.last_update = TimeCurrent();
}

/**
 * Verifica se é um novo dia e reseta contadores diários
 */
void CheckNewDay()
{
    static datetime last_day = 0;
    datetime current_day = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
    
    if(last_day != 0 && current_day > last_day)
    {
        // Novo dia - reset contadores
        g_total_signals_today = 0;
        g_total_operations_today = 0;
        g_total_wins_today = 0;
        g_total_losses_today = 0;
        g_daily_profit = 0.0;
        g_daily_winrate = 0.0;
        g_session_profit = 0.0;
        g_session_loss = 0.0;
        g_stop_loss_triggered = false;
        g_stop_win_triggered = false;
        
        // Reset análise financeira para novo dia
        g_financial_analysis.analysis_date = current_day;
        g_financial_analysis.starting_balance = g_current_balance;
        
        Print("Novo dia detectado - contadores resetados");
    }
    
    last_day = current_day;
}

#endif // CORE_GLOBALS_MQH

