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
    
    // Arrays
    ArrayResize(g_close_prices, MAX_BARS_HISTORY);
    ArrayResize(g_open_prices, MAX_BARS_HISTORY);
    ArrayResize(g_high_prices, MAX_BARS_HISTORY);
    ArrayResize(g_low_prices, MAX_BARS_HISTORY);
    ArrayResize(g_bar_times, MAX_BARS_HISTORY);
    
    ArrayResize(g_call_buffer, MAX_BARS_HISTORY);
    ArrayResize(g_put_buffer, MAX_BARS_HISTORY);
    ArrayResize(g_confidence_buffer, MAX_BARS_HISTORY);
    
    ArrayResize(g_daily_profits, 365);
    ArrayResize(g_operation_results, MAX_SIGNALS_PER_DAY);
    ArrayResize(g_operation_times, MAX_SIGNALS_PER_DAY);
    ArrayResize(g_operation_patterns, MAX_SIGNALS_PER_DAY);
    
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
    for(int i = 0; i < MAX_MARTINGALE_LEVELS; i++)
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

//+------------------------------------------------------------------+
//| Funções de Atualização de Estatísticas                          |
//+------------------------------------------------------------------+

/**
 * Atualiza estatísticas globais
 */
void UpdateGlobalStatistics()
{
    // Calcular winrate
    double winrate = 0.0;
    if(g_total_operations > 0)
    {
        winrate = (double)g_total_wins / g_total_operations * 100.0;
    }
    
    // Calcular winrate diário
    double daily_winrate = 0.0;
    if(g_daily_operations > 0)
    {
        daily_winrate = (double)g_daily_wins / g_daily_operations * 100.0;
    }
    
    // Atualizar saldo atual
    g_current_balance = g_starting_balance + g_total_profit;
    
    // Calcular drawdown atual
    g_current_drawdown = g_current_balance - g_starting_balance;
    if(g_current_drawdown < g_max_drawdown_value)
    {
        g_max_drawdown_value = g_current_drawdown;
        g_max_drawdown_percentage = (g_max_drawdown_value / g_starting_balance) * 100.0;
    }
    
    // Atualizar análise de risco
    UpdateRiskAnalysis();
    
    // Atualizar estatísticas diárias
    UpdateDailyStatistics();
}

/**
 * Atualiza análise de risco
 */
void UpdateRiskAnalysis()
{
    // Implementação simplificada - pode ser expandida
    if(g_total_operations > 10)
    {
        // Calcular volatilidade baseada nos resultados
        double sum_squared_deviations = 0.0;
        double average_result = g_total_profit / g_total_operations;
        
        for(int i = 0; i < MathMin(g_total_operations, MAX_SIGNALS_PER_DAY); i++)
        {
            double deviation = g_operation_results[i] - average_result;
            sum_squared_deviations += deviation * deviation;
        }
        
        g_daily_stats.volatility = MathSqrt(sum_squared_deviations / g_total_operations);
        
        // Calcular Sharpe Ratio simplificado
        if(g_daily_stats.volatility > 0)
        {
            g_daily_stats.sharpe_ratio = average_result / g_daily_stats.volatility;
        }
    }
}

/**
 * Atualiza estatísticas diárias
 */
void UpdateDailyStatistics()
{
    // Calcular recovery factor
    if(g_max_drawdown_value < 0)
    {
        g_daily_stats.recovery_factor = g_total_profit / MathAbs(g_max_drawdown_value);
    }
    
    // Calcular Calmar Ratio
    if(g_max_drawdown_percentage < 0)
    {
        double annual_return = g_total_profit; // Simplificado
        g_daily_stats.calmar_ratio = annual_return / MathAbs(g_max_drawdown_percentage);
    }
    
    // Atualizar valores de drawdown
    g_daily_stats.max_drawdown_value = g_max_drawdown_value;
    g_daily_stats.max_drawdown_percentage = g_max_drawdown_percentage;
}

/**
 * Reseta estatísticas diárias
 */
void ResetDailyStatistics()
{
    g_daily_operations = 0;
    g_daily_wins = 0;
    g_daily_losses = 0;
    g_daily_profit = 0.0;
    g_current_martingale_level = 0;
    g_martingale_sequence_active = false;
    
    // Limpar arrays diários
    ArrayInitialize(g_operation_results, 0.0);
    ArrayInitialize(g_operation_times, 0);
    ArrayInitialize(g_operation_patterns, PATTERN_NONE);
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

