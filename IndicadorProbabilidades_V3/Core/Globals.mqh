//+------------------------------------------------------------------+
//|                                    Core/Globals.mqh |
//|                                    Indicador de Probabilidades V3 |
//|                                Variáveis Globais do Sistema |
//+------------------------------------------------------------------+

#ifndef CORE_GLOBALS_MQH
#define CORE_GLOBALS_MQH

#include "Types.mqh"

//+------------------------------------------------------------------+
//| Variáveis de Estado do Sistema                                  |
//+------------------------------------------------------------------+
SystemState g_system_state = STATE_INITIALIZING;
datetime g_last_bar_time = 0;
datetime g_system_start_time = 0;
bool g_system_initialized = false;

//+------------------------------------------------------------------+
//| Configuração Global                                             |
//+------------------------------------------------------------------+
SystemConfig g_config;

//+------------------------------------------------------------------+
//| Variáveis de Padrões                                            |
//+------------------------------------------------------------------+
PatternDetectionResult g_last_pattern_result;
SignalInfo g_last_signal;
PatternType g_current_pattern = PATTERN_MHI1;
bool g_pattern_inversion_enabled = false;

//+------------------------------------------------------------------+
//| Variáveis de Filtros                                            |
//+------------------------------------------------------------------+
MarketFilters g_market_filters;
int g_atr_handle = INVALID_HANDLE;
int g_bollinger_handle = INVALID_HANDLE;
int g_ma_handle = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| Variáveis Financeiras                                           |
//+------------------------------------------------------------------+
double g_current_balance = 1000.0;
double g_starting_balance = 1000.0;
double g_daily_profit = 0.0;
double g_total_profit = 0.0;
int g_total_operations = 0;
int g_total_wins = 0;
int g_total_losses = 0;
int g_daily_operations = 0;
int g_daily_wins = 0;
int g_daily_losses = 0;

//+------------------------------------------------------------------+
//| Variáveis de Martingale                                         |
//+------------------------------------------------------------------+
MartingaleSimulation g_martingale_sim;
int g_current_martingale_level = 0;
double g_current_entry_value = 10.0;
bool g_martingale_sequence_active = false;

//+------------------------------------------------------------------+
//| Variáveis de Análise de Risco                                   |
//+------------------------------------------------------------------+
RiskAnalysis g_risk_analysis;
DailyStatistics g_daily_stats;
double g_max_drawdown_value = 0.0;
double g_max_drawdown_percentage = 0.0;
double g_current_drawdown = 0.0;

//+------------------------------------------------------------------+
//| Variáveis de Painel Visual                                      |
//+------------------------------------------------------------------+
bool g_panel_initialized = false;
datetime g_last_panel_update = 0;
string g_panel_objects[];
int g_panel_object_count = 0;

//+------------------------------------------------------------------+
//| Variáveis de Notificações                                       |
//+------------------------------------------------------------------+
bool g_telegram_initialized = false;
bool g_mx2_initialized = false;
datetime g_last_telegram_send = 0;
datetime g_last_mx2_send = 0;
int g_telegram_send_count = 0;
int g_mx2_send_count = 0;

//+------------------------------------------------------------------+
//| Variáveis de SuperVarredura                                     |
//+------------------------------------------------------------------+
bool g_superscan_running = false;
datetime g_last_superscan = 0;
SuperScanResult g_superscan_result;
bool g_superscan_completed = false;

//+------------------------------------------------------------------+
//| Variáveis de Performance                                        |
//+------------------------------------------------------------------+
datetime g_last_performance_update = 0;
int g_performance_update_count = 0;
double g_average_execution_time = 0.0;
double g_max_execution_time = 0.0;

//+------------------------------------------------------------------+
//| Variáveis de Cache                                              |
//+------------------------------------------------------------------+
datetime g_cache_last_update = 0;
bool g_cache_valid = false;
int g_cache_hit_count = 0;
int g_cache_miss_count = 0;

//+------------------------------------------------------------------+
//| Variáveis de Log                                                |
//+------------------------------------------------------------------+
bool g_logging_initialized = false;
LogLevel g_current_log_level = LOG_INFO;
int g_log_entry_count = 0;
datetime g_last_log_cleanup = 0;

//+------------------------------------------------------------------+
//| Arrays de Dados Históricos                                      |
//+------------------------------------------------------------------+
double g_close_prices[];
double g_open_prices[];
double g_high_prices[];
double g_low_prices[];
datetime g_bar_times[];

//+------------------------------------------------------------------+
//| Arrays de Buffers do Indicador                                  |
//+------------------------------------------------------------------+
double g_call_buffer[];
double g_put_buffer[];
double g_confidence_buffer[];

//+------------------------------------------------------------------+
//| Arrays de Estatísticas                                          |
//+------------------------------------------------------------------+
double g_daily_profits[];
double g_operation_results[];
datetime g_operation_times[];
PatternType g_operation_patterns[];

//+------------------------------------------------------------------+
//| Variáveis Específicas do Telegram                               |
//+------------------------------------------------------------------+
TelegramConfig g_telegram_config;
string g_last_telegram_response = "";
MessageTemplates g_message_templates;
int g_telegram_messages_sent = 0;
int g_telegram_messages_success = 0;
int g_telegram_messages_failed = 0;
datetime g_last_telegram_message_time = 0;
string g_telegram_base_url = "";

//+------------------------------------------------------------------+
//| Funções de Inicialização de Variáveis Globais                   |
//+------------------------------------------------------------------+

/**
 * Inicializa todas as variáveis globais
 * @return true se inicializado com sucesso
 */
bool InitializeGlobalVariables()
{
    // Estado do sistema
    g_system_state = STATE_INITIALIZING;
    g_system_start_time = TimeCurrent();
    g_system_initialized = false;
    
    // Padrões
    InitializePatternDetectionResult(g_last_pattern_result);
    InitializeSignalInfo(g_last_signal);
    g_current_pattern = PATTERN_MHI1;
    g_pattern_inversion_enabled = false;
    
    // Filtros
    InitializeMarketFilters(g_market_filters);
    g_atr_handle = INVALID_HANDLE;
    g_bollinger_handle = INVALID_HANDLE;
    g_ma_handle = INVALID_HANDLE;
    
    // Financeiro
    g_current_balance = 1000.0;
    g_starting_balance = 1000.0;
    g_daily_profit = 0.0;
    g_total_profit = 0.0;
    g_total_operations = 0;
    g_total_wins = 0;
    g_total_losses = 0;
    g_daily_operations = 0;
    g_daily_wins = 0;
    g_daily_losses = 0;
    
    // Martingale
    InitializeMartingaleSimulation();
    g_current_martingale_level = 0;
    g_current_entry_value = 10.0;
    g_martingale_sequence_active = false;
    
    // Análise de risco
    InitializeRiskAnalysis();
    InitializeDailyStatistics();
    g_max_drawdown_value = 0.0;
    g_max_drawdown_percentage = 0.0;
    g_current_drawdown = 0.0;
    
    // Painel
    g_panel_initialized = false;
    g_last_panel_update = 0;
    g_panel_object_count = 0;
    
    // Notificações
    g_telegram_initialized = false;
    g_mx2_initialized = false;
    g_last_telegram_send = 0;
    g_last_mx2_send = 0;
    g_telegram_send_count = 0;
    g_mx2_send_count = 0;
    
    // SuperVarredura
    g_superscan_running = false;
    g_last_superscan = 0;
    g_superscan_completed = false;
    InitializeSuperScanResult();
    
    // Performance
    g_last_performance_update = 0;
    g_performance_update_count = 0;
    g_average_execution_time = 0.0;
    g_max_execution_time = 0.0;
    
    // Cache
    g_cache_last_update = 0;
    g_cache_valid = false;
    g_cache_hit_count = 0;
    g_cache_miss_count = 0;
    
    // Log
    g_logging_initialized = false;
    g_current_log_level = LOG_INFO;
    g_log_entry_count = 0;
    g_last_log_cleanup = 0;
    
    // Telegram
    InitializeTelegramConfig();
    g_last_telegram_response = "";
    InitializeMessageTemplates();
    g_telegram_messages_sent = 0;
    g_telegram_messages_success = 0;
    g_telegram_messages_failed = 0;
    g_last_telegram_message_time = 0;
    g_telegram_base_url = "";
    
    // Arrays
    ArrayResize(g_close_prices, 1000);
    ArrayResize(g_open_prices, 1000);
    ArrayResize(g_high_prices, 1000);
    ArrayResize(g_low_prices, 1000);
    ArrayResize(g_bar_times, 1000);
    
    ArrayResize(g_call_buffer, 1000);
    ArrayResize(g_put_buffer, 1000);
    ArrayResize(g_confidence_buffer, 1000);
    
    ArrayResize(g_daily_profits, 365);
    ArrayResize(g_operation_results, 1000);
    ArrayResize(g_operation_times, 1000);
    ArrayResize(g_operation_patterns, 1000);
    
    // Inicializar arrays com valores padrão
    ArrayInitialize(g_call_buffer, EMPTY_VALUE);
    ArrayInitialize(g_put_buffer, EMPTY_VALUE);
    ArrayInitialize(g_confidence_buffer, 0.0);
    
    return true;
}

/**
 * Inicializa simulação de martingale
 */
void InitializeMartingaleSimulation()
{
    for(int i = 0; i < 10; i++)
    {
        g_martingale_sim.entry_values[i] = 0.0;
        g_martingale_sim.total_investment[i] = 0.0;
        g_martingale_sim.potential_profit[i] = 0.0;
        g_martingale_sim.risk_percentage[i] = 0.0;
    }
}

/**
 * Inicializa análise de risco
 */
void InitializeRiskAnalysis()
{
    g_risk_analysis.var_95 = 0.0;
    g_risk_analysis.var_99 = 0.0;
    g_risk_analysis.expected_shortfall = 0.0;
    g_risk_analysis.beta = 0.0;
    g_risk_analysis.alpha = 0.0;
    g_risk_analysis.correlation = 0.0;
}

/**
 * Inicializa estatísticas diárias
 */
void InitializeDailyStatistics()
{
    g_daily_stats.sharpe_ratio = 0.0;
    g_daily_stats.volatility = 0.0;
    g_daily_stats.max_drawdown_value = 0.0;
    g_daily_stats.max_drawdown_percentage = 0.0;
    g_daily_stats.recovery_factor = 0.0;
    g_daily_stats.calmar_ratio = 0.0;
    g_daily_stats.sortino_ratio = 0.0;
}

/**
 * Inicializa resultado de SuperVarredura
 */
void InitializeSuperScanResult()
{
    g_superscan_result.best_pattern = PATTERN_NONE;
    g_superscan_result.best_winrate = 0.0;
    g_superscan_result.total_operations = 0;
    g_superscan_result.total_wins = 0;
    g_superscan_result.total_losses = 0;
    g_superscan_result.total_profit = 0.0;
    g_superscan_result.max_drawdown = 0.0;
    g_superscan_result.recommendation_apply = false;
}

/**
 * Inicializa configuração do Telegram
 */
void InitializeTelegramConfig()
{
    g_telegram_config.bot_token = "";
    g_telegram_config.chat_id = "";
    g_telegram_config.enabled = false;
    g_telegram_config.retry_attempts = 3;
    g_telegram_config.retry_delay_ms = 1000;
    g_telegram_config.send_signals = true;
    g_telegram_config.send_results = true;
    g_telegram_config.send_statistics = false;
}

/**
 * Inicializa templates de mensagem
 */
void InitializeMessageTemplates()
{
    g_message_templates.signal_template = "🎯 SINAL DETECTADO\n📊 Padrão: {PATTERN}\n🎲 Direção: {DIRECTION}\n💰 Valor: {VALUE}\n📈 Confiança: {CONFIDENCE}%";
    g_message_templates.result_template = "📊 RESULTADO\n{RESULT_ICON} {RESULT}\n💰 Lucro: {PROFIT}\n💳 Saldo: {BALANCE}";
    g_message_templates.statistics_template = "📈 ESTATÍSTICAS\n🎯 Operações: {OPERATIONS}\n✅ Vitórias: {WINS}\n❌ Perdas: {LOSSES}\n📊 WinRate: {WINRATE}%";
    g_message_templates.error_template = "⚠️ ERRO\n{ERROR_MESSAGE}";
}

/**
 * Limpa recursos globais
 */
void CleanupGlobalResources()
{
    // Liberar handles de indicadores
    if(g_atr_handle != INVALID_HANDLE)
    {
        IndicatorRelease(g_atr_handle);
        g_atr_handle = INVALID_HANDLE;
    }
    
    if(g_bollinger_handle != INVALID_HANDLE)
    {
        IndicatorRelease(g_bollinger_handle);
        g_bollinger_handle = INVALID_HANDLE;
    }
    
    if(g_ma_handle != INVALID_HANDLE)
    {
        IndicatorRelease(g_ma_handle);
        g_ma_handle = INVALID_HANDLE;
    }
    
    // Limpar objetos do painel
    for(int i = 0; i < g_panel_object_count; i++)
    {
        if(g_panel_objects[i] != "")
        {
            ObjectDelete(0, g_panel_objects[i]);
        }
    }
    
    g_panel_object_count = 0;
    ArrayResize(g_panel_objects, 0);
}

#endif // CORE_GLOBALS_MQH

