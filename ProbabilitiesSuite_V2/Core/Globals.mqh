//+------------------------------------------------------------------+
//|                                    Core/Globals.mqh |
//|                        Copyright 2024, Quant Genius (Refactoring) |
//|                                      https://www.google.com |
//|                                    VERSÃO CORRIGIDA v2.0        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quant Genius (Refactoring)"
#property link      "https://www.google.com"

#ifndef CORE_GLOBALS_MQH
#define CORE_GLOBALS_MQH

#include "Defines.mqh"

// ==================================================================
// VARIÁVEIS GLOBAIS DO SISTEMA - VERSÃO CORRIGIDA
// ==================================================================

//+------------------------------------------------------------------+
//| CORREÇÃO: Variáveis de Cache com Controle de Estado             |
//+------------------------------------------------------------------+

// Estado do cache principal
bool g_cache_initialized = false;
int g_cache_size = 0;
datetime g_cache_last_update = 0;

// Arrays de cache - CORREÇÃO: Inicializados adequadamente
int g_cache_candle_colors[];           // Cores das velas
double g_cache_atr_values[];           // Valores ATR
double g_cache_bb_upper[];             // Banda superior Bollinger
double g_cache_bb_lower[];             // Banda inferior Bollinger
double g_cache_bb_middle[];            // Banda média Bollinger
double g_cache_ma_values[];            // Valores da média móvel

// Metadados do cache
CacheMetadata g_cache_metadata;

//+------------------------------------------------------------------+
//| CORREÇÃO: Variáveis da SuperVarredura com Estado Consistente    |
//+------------------------------------------------------------------+

// Estado da SuperVarredura
bool g_rodouSuperVarreduraComSucesso = false;
PatternType g_superVarredura_MelhorPadrao = PatternMHI1_3C_Minoria;
bool g_superVarredura_MelhorInvertido = false;
double g_superVarredura_MelhorWinrate = 0.0;
double g_superVarredura_MelhorBalance = 0.0;
int g_superVarredura_MelhorOperacoes = 0;
datetime g_superVarredura_UltimaExecucao = 0;

// Cache de resultados da SuperVarredura
SuperVarreduraCache g_sv_cache[];
datetime g_sv_last_full_calculation = 0;

//+------------------------------------------------------------------+
//| CORREÇÃO: Variáveis de Controle de Estado                       |
//+------------------------------------------------------------------+

// Estado de notificações
bool s_telegram_signal_cycle_active = false;
datetime s_telegram_last_signal_time = 0;
int s_telegram_signals_sent_today = 0;

// Estado de controle de tempo
datetime g_last_new_bar_time = 0;
datetime g_system_start_time = 0;
int g_total_calculations = 0;

// Estado de erro e recuperação
int g_consecutive_errors = 0;
datetime g_last_error_time = 0;
string g_last_error_message = "";
bool g_auto_recovery_active = false;

//+------------------------------------------------------------------+
//| CORREÇÃO: Variáveis de Performance e Monitoramento              |
//+------------------------------------------------------------------+

// Métricas de performance
SystemMetrics g_system_metrics;
ulong g_last_calculation_time_ms = 0;
ulong g_max_calculation_time_ms = 0;
ulong g_total_calculation_time_ms = 0;

// Contadores de operação
int g_cache_updates_count = 0;
int g_supervarredura_executions_count = 0;
int g_signals_generated_count = 0;
int g_notifications_sent_count = 0;

//+------------------------------------------------------------------+
//| CORREÇÃO: Variáveis de Configuração do Sistema                  |
//+------------------------------------------------------------------+

// Configuração atual do sistema
SystemConfig g_system_config;
FilterConfig g_filter_config;
DebugState g_debug_state;

// Handles de indicadores técnicos
int g_atr_handle = INVALID_HANDLE;
int g_bb_handle = INVALID_HANDLE;
int g_ma_handle = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| CORREÇÃO: Variáveis de Estado Visual                            |
//+------------------------------------------------------------------+

// Estado do painel visual
bool g_panel_initialized = false;
bool g_timer_initialized = false;
datetime g_panel_last_update = 0;

// Configurações visuais
color g_current_call_color = COR_CALL_DEFAULT;
color g_current_put_color = COR_PUT_DEFAULT;
int g_current_arrow_size = 3;

//+------------------------------------------------------------------+
//| CORREÇÃO: Variáveis de Notificação                              |
//+------------------------------------------------------------------+

// Configuração de Telegram
string g_telegram_bot_token = "";
string g_telegram_chat_id = "";
bool g_telegram_configured = false;
datetime g_telegram_last_message_time = 0;

// Configuração de MX2
string g_mx2_api_key = "";
bool g_mx2_configured = false;
datetime g_mx2_last_signal_time = 0;

//+------------------------------------------------------------------+
//| Funções de Inicialização de Variáveis Globais                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Inicializa todas as variáveis globais                           |
//+------------------------------------------------------------------+
void InitializeGlobalVariables()
{
    // Inicializa estado do cache
    g_cache_initialized = false;
    g_cache_size = 0;
    g_cache_last_update = 0;
    
    // Inicializa metadados do cache
    g_cache_metadata.last_update = 0;
    g_cache_metadata.expected_size = 0;
    g_cache_metadata.actual_size = 0;
    g_cache_metadata.integrity_hash = "";
    g_cache_metadata.is_complete = false;
    g_cache_metadata.last_error = "";
    g_cache_metadata.validation_failures = 0;
    g_cache_metadata.recovery_attempts = 0;
    
    // Inicializa estado da SuperVarredura
    g_rodouSuperVarreduraComSucesso = false;
    g_superVarredura_MelhorPadrao = PatternMHI1_3C_Minoria;
    g_superVarredura_MelhorInvertido = false;
    g_superVarredura_MelhorWinrate = 0.0;
    g_superVarredura_MelhorBalance = 0.0;
    g_superVarredura_MelhorOperacoes = 0;
    g_superVarredura_UltimaExecucao = 0;
    g_sv_last_full_calculation = 0;
    
    // Inicializa estado de notificações
    s_telegram_signal_cycle_active = false;
    s_telegram_last_signal_time = 0;
    s_telegram_signals_sent_today = 0;
    
    // Inicializa estado de controle
    g_last_new_bar_time = 0;
    g_system_start_time = TimeCurrent();
    g_total_calculations = 0;
    
    // Inicializa estado de erro
    g_consecutive_errors = 0;
    g_last_error_time = 0;
    g_last_error_message = "";
    g_auto_recovery_active = false;
    
    // Inicializa métricas de sistema
    g_system_metrics.start_time = TimeCurrent();
    g_system_metrics.uptime_seconds = 0;
    g_system_metrics.total_signals_generated = 0;
    g_system_metrics.cache_updates = 0;
    g_system_metrics.supervarredura_executions = 0;
    g_system_metrics.notification_sent = 0;
    g_system_metrics.errors_count = 0;
    g_system_metrics.warnings_count = 0;
    g_system_metrics.avg_calculation_time_ms = 0.0;
    g_system_metrics.max_calculation_time_ms = 0.0;
    g_system_metrics.memory_usage_kb = 0;
    
    // Inicializa contadores
    g_cache_updates_count = 0;
    g_supervarredura_executions_count = 0;
    g_signals_generated_count = 0;
    g_notifications_sent_count = 0;
    
    // Inicializa configuração do sistema
    InitializeSystemConfig();
    
    // Inicializa handles
    g_atr_handle = INVALID_HANDLE;
    g_bb_handle = INVALID_HANDLE;
    g_ma_handle = INVALID_HANDLE;
    
    // Inicializa estado visual
    g_panel_initialized = false;
    g_timer_initialized = false;
    g_panel_last_update = 0;
    
    // Inicializa configurações visuais
    g_current_call_color = COR_CALL_DEFAULT;
    g_current_put_color = COR_PUT_DEFAULT;
    g_current_arrow_size = 3;
    
    // Inicializa configuração de notificações
    g_telegram_bot_token = "";
    g_telegram_chat_id = "";
    g_telegram_configured = false;
    g_telegram_last_message_time = 0;
    
    g_mx2_api_key = "";
    g_mx2_configured = false;
    g_mx2_last_signal_time = 0;
    
    Print("Variáveis globais inicializadas com sucesso");
}

//+------------------------------------------------------------------+
//| Inicializa configuração do sistema                              |
//+------------------------------------------------------------------+
void InitializeSystemConfig()
{
    // Configurações de Cache
    g_system_config.cache_size = DEFAULT_CACHE_SIZE;
    g_system_config.cache_auto_update = true;
    g_system_config.cache_update_interval = CACHE_UPDATE_INTERVAL_SECONDS;
    
    // Configurações de Performance
    g_system_config.max_iterations = MAX_SUPERVARREDURA_ITERATIONS;
    g_system_config.timeout_seconds = SUPERVARREDURA_TIMEOUT_SECONDS;
    g_system_config.enable_optimization = true;
    
    // Configurações de Log
    g_system_config.log_level = LOG_INFO;
    g_system_config.log_to_file = true;
    g_system_config.log_to_console = true;
    g_system_config.log_file_path = "";
    
    // Configurações de Notificação
    g_system_config.telegram_enabled = false;
    g_system_config.mx2_enabled = false;
    g_system_config.notification_interval = TELEGRAM_CYCLE_DURATION_SECONDS;
    
    // Configurações Visuais
    g_system_config.panel_enabled = true;
    g_system_config.timer_enabled = true;
    g_system_config.debug_panel_enabled = false;
    
    // Configurações de Validação
    g_system_config.strict_validation = true;
    g_system_config.auto_recovery = true;
    g_system_config.max_recovery_attempts = MAX_CACHE_RECOVERY_ATTEMPTS;
    
    // Inicializa configuração de filtros
    InitializeFilterConfig();
    
    // Inicializa estado de debug
    InitializeDebugState();
}

//+------------------------------------------------------------------+
//| Inicializa configuração de filtros                              |
//+------------------------------------------------------------------+
void InitializeFilterConfig()
{
    g_filter_config.volatility_filter_active = false;
    g_filter_config.atr_min = MIN_ATR_VALUE;
    g_filter_config.atr_max = MAX_ATR_VALUE;
    g_filter_config.bb_consolidation_only = false;
    g_filter_config.trend_filter_active = false;
    g_filter_config.atr_period = 20;
    g_filter_config.bb_multiplier = 2.0;
    g_filter_config.bb_period = 14;
    g_filter_config.use_moving_average = false;
    g_filter_config.ma_period = 100;
    g_filter_config.ma_method = MODE_EMA;
}

//+------------------------------------------------------------------+
//| Inicializa estado de debug                                      |
//+------------------------------------------------------------------+
void InitializeDebugState()
{
    g_debug_state.debug_mode_active = false;
    g_debug_state.current_log_level = LOG_INFO;
    g_debug_state.debug_flags = 0;
    g_debug_state.last_error_message = "";
    g_debug_state.last_error_time = 0;
    g_debug_state.consecutive_errors = 0;
    g_debug_state.auto_recovery_active = false;
}

//+------------------------------------------------------------------+
//| Atualiza métricas de sistema                                    |
//+------------------------------------------------------------------+
void UpdateSystemMetrics()
{
    g_system_metrics.uptime_seconds = (int)(TimeCurrent() - g_system_metrics.start_time);
    
    // Atualiza média de tempo de cálculo
    if(g_total_calculations > 0)
    {
        g_system_metrics.avg_calculation_time_ms = 
            (double)g_total_calculation_time_ms / g_total_calculations;
    }
    
    // Atualiza contadores das métricas
    g_system_metrics.total_signals_generated = g_signals_generated_count;
    g_system_metrics.cache_updates = g_cache_updates_count;
    g_system_metrics.supervarredura_executions = g_supervarredura_executions_count;
    g_system_metrics.notification_sent = g_notifications_sent_count;
    
    // Estima uso de memória (aproximado)
    int estimated_memory = 0;
    estimated_memory += ArraySize(g_cache_candle_colors) * sizeof(int);
    estimated_memory += ArraySize(g_cache_atr_values) * sizeof(double);
    estimated_memory += ArraySize(g_cache_bb_upper) * sizeof(double);
    estimated_memory += ArraySize(g_cache_bb_lower) * sizeof(double);
    estimated_memory += ArraySize(g_cache_bb_middle) * sizeof(double);
    estimated_memory += ArraySize(g_cache_ma_values) * sizeof(double);
    estimated_memory += ArraySize(g_sv_cache) * sizeof(SuperVarreduraCache);
    
    g_system_metrics.memory_usage_kb = estimated_memory / 1024;
}

//+------------------------------------------------------------------+
//| Limpa todas as variáveis globais                                |
//+------------------------------------------------------------------+
void CleanupGlobalVariables()
{
    // Limpa arrays de cache
    ArrayFree(g_cache_candle_colors);
    ArrayFree(g_cache_atr_values);
    ArrayFree(g_cache_bb_upper);
    ArrayFree(g_cache_bb_lower);
    ArrayFree(g_cache_bb_middle);
    ArrayFree(g_cache_ma_values);
    ArrayFree(g_sv_cache);
    
    // Libera handles de indicadores
    if(g_atr_handle != INVALID_HANDLE)
    {
        IndicatorRelease(g_atr_handle);
        g_atr_handle = INVALID_HANDLE;
    }
    
    if(g_bb_handle != INVALID_HANDLE)
    {
        IndicatorRelease(g_bb_handle);
        g_bb_handle = INVALID_HANDLE;
    }
    
    if(g_ma_handle != INVALID_HANDLE)
    {
        IndicatorRelease(g_ma_handle);
        g_ma_handle = INVALID_HANDLE;
    }
    
    // Reset de variáveis de estado
    g_cache_initialized = false;
    g_cache_size = 0;
    g_rodouSuperVarreduraComSucesso = false;
    s_telegram_signal_cycle_active = false;
    g_panel_initialized = false;
    g_timer_initialized = false;
    g_telegram_configured = false;
    g_mx2_configured = false;
    
    Print("Variáveis globais limpas com sucesso");
}

//+------------------------------------------------------------------+
//| Funções de Acesso Seguro às Variáveis Globais                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Obtém estado atual do cache de forma segura                     |
//+------------------------------------------------------------------+
bool GetCacheState(bool &initialized, int &size, datetime &last_update)
{
    initialized = g_cache_initialized;
    size = g_cache_size;
    last_update = g_cache_last_update;
    return true;
}

//+------------------------------------------------------------------+
//| Obtém estado atual da SuperVarredura de forma segura            |
//+------------------------------------------------------------------+
bool GetSuperVarreduraState(PatternType &pattern, bool &inverted, bool &success)
{
    pattern = g_superVarredura_MelhorPadrao;
    inverted = g_superVarredura_MelhorInvertido;
    success = g_rodouSuperVarreduraComSucesso;
    return true;
}

//+------------------------------------------------------------------+
//| Obtém métricas atuais do sistema                                |
//+------------------------------------------------------------------+
SystemMetrics GetCurrentSystemMetrics()
{
    UpdateSystemMetrics();
    return g_system_metrics;
}

//+------------------------------------------------------------------+
//| Incrementa contador de forma thread-safe                        |
//+------------------------------------------------------------------+
void IncrementCounter(int &counter)
{
    counter++;
}

//+------------------------------------------------------------------+
//| Registra erro no sistema                                        |
//+------------------------------------------------------------------+
void RegisterSystemError(string error_message)
{
    g_consecutive_errors++;
    g_last_error_time = TimeCurrent();
    g_last_error_message = error_message;
    g_system_metrics.errors_count++;
    
    // Ativa recuperação automática se muitos erros consecutivos
    if(g_consecutive_errors >= 3 && g_system_config.auto_recovery)
    {
        g_auto_recovery_active = true;
    }
}

//+------------------------------------------------------------------+
//| Registra warning no sistema                                     |
//+------------------------------------------------------------------+
void RegisterSystemWarning()
{
    g_system_metrics.warnings_count++;
}

//+------------------------------------------------------------------+
//| Reset de erros consecutivos                                     |
//+------------------------------------------------------------------+
void ResetConsecutiveErrors()
{
    g_consecutive_errors = 0;
    g_auto_recovery_active = false;
}

//+------------------------------------------------------------------+
//| Registra tempo de cálculo                                       |
//+------------------------------------------------------------------+
void RegisterCalculationTime(ulong time_ms)
{
    g_last_calculation_time_ms = time_ms;
    g_total_calculation_time_ms += time_ms;
    g_total_calculations++;
    
    if(time_ms > g_max_calculation_time_ms)
    {
        g_max_calculation_time_ms = time_ms;
        g_system_metrics.max_calculation_time_ms = (double)time_ms;
    }
}

#endif // CORE_GLOBALS_MQH

