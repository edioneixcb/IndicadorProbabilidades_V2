//+------------------------------------------------------------------+
//|                                    Core/Defines.mqh |
//|                        Copyright 2024, Quant Genius (Refactoring) |
//|                                      https://www.google.com |
//|                                    VERSÃO CORRIGIDA v2.0        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quant Genius (Refactoring)"
#property link      "https://www.google.com"

#ifndef CORE_DEFINES_MQH
#define CORE_DEFINES_MQH

// ==================================================================
// DEFINIÇÕES FUNDAMENTAIS DO SISTEMA - VERSÃO CORRIGIDA
// ==================================================================

//+------------------------------------------------------------------+
//| Enumerações de Padrões                                          |
//+------------------------------------------------------------------+
enum PatternType
{
    PatternMHI1_3C_Minoria = 0,
    PatternMHI2_3C_Confirmado = 1,
    PatternMHI3_Unanime_Base = 2,
    PatternM5_Variação_6C_Maioria = 3,
    PatternMilhao_6C_Maioria = 4,
    PatternFiveInARow_Base = 5,
    PatternThreeInARow_Base = 6,
    PatternFourInARow_Base = 7,
    PatternImpar_3C_Maioria = 8,
    PatternMelhorDe3_Maioria = 9,
    Pattern3X1_ContinuacaoOposta = 10,
    PatternSevenInARow_Base = 11,
    Pattern23_ContinuacaoOposta = 12,
    Pattern5Elemento_Base = 13,
    PatternUU_Base = 14,
    PatternDD_Base = 15,
    PatternUD_Base = 16,
    PatternDU_Base = 17,
    PatternC3_SeguirCor = 18,                    // CORREÇÃO: Padrão corrigido
    PatternTorresGemeas_SeguirCor3 = 19,
    PatternMHI_Potencializada_Core = 20,
    PatternGABA_Placeholder = 21,
    PatternR7_Placeholder = 22,
    LAST_PATTERN_ENUM = 22
};

//+------------------------------------------------------------------+
//| Enumerações de Cores Visuais                                    |
//+------------------------------------------------------------------+
enum VisualCandleColor
{
    VISUAL_GREEN = 1,
    VISUAL_RED = -1,
    VISUAL_DOJI = 0
};

//+------------------------------------------------------------------+
//| Enumerações de Posição de Seta                                  |
//+------------------------------------------------------------------+
enum ENUM_POSICAO_SETA
{
    POS_VELA_DE_SINAL = 0,      // Na vela onde o padrão foi detectado
    POS_VELA_DE_ENTRADA = 1     // Na vela de entrada (padrão)
};

//+------------------------------------------------------------------+
//| Enumerações de Critério da SuperVarredura                       |
//+------------------------------------------------------------------+
enum ENUM_CRITERIO_SV
{
    SV_MELHOR_WINRATE = 0,      // Melhor Winrate
    SV_MELHOR_FINANCEIRO = 1,   // Melhor Resultado Financeiro
    SV_MELHOR_EQUILIBRIO = 2    // Melhor Equilíbrio (Winrate + Financeiro)
};

//+------------------------------------------------------------------+
//| Níveis de Log                                                   |
//+------------------------------------------------------------------+
enum LogLevel 
{
    LOG_DEBUG = 0,
    LOG_INFO = 1,
    LOG_WARNING = 2,
    LOG_ERROR = 3,
    LOG_CRITICAL = 4
};

//+------------------------------------------------------------------+
//| Estruturas de Dados Corrigidas                                  |
//+------------------------------------------------------------------+

// CORREÇÃO: Estrutura para coordenadas unificadas de sinal
struct SignalCoordinate 
{
    int detection_shift;        // Onde o padrão foi detectado
    int plot_shift;            // Onde a seta deve ser plotada
    double plot_price;         // Preço calculado para plotagem
    datetime plot_time;        // Tempo da vela de plotagem
    bool is_valid;             // Se as coordenadas são válidas
    string debug_info;         // Informações de debug
};

// CORREÇÃO: Estrutura para cache de resultados da SuperVarredura
struct SuperVarreduraCache 
{
    PatternType pattern;
    bool inverted;
    int loss_threshold;
    double win_rate;
    double balance;
    int total_operations;
    datetime calculation_time;
    bool is_valid;
    string additional_info;
};

// CORREÇÃO: Metadados do cache para controle de integridade
struct CacheMetadata 
{
    datetime last_update;
    int expected_size;
    int actual_size;
    string integrity_hash;
    bool is_complete;
    string last_error;
    int validation_failures;
    int recovery_attempts;
};

// Estrutura para análise financeira
struct AnaliseFinanceira 
{
    double winrate;
    double balance;
    int total_operations;
    int wins;
    int losses;
    double profit_factor;
    double max_drawdown;
    bool is_valid;
};

// Estrutura para estatísticas de padrão
struct PatternStatistics 
{
    PatternType pattern;
    bool inverted;
    int occurrences;
    double success_rate;
    double avg_profit;
    double avg_loss;
    datetime last_occurrence;
    bool has_sufficient_data;
};

// Estrutura para configuração de filtros
struct FilterConfig 
{
    bool volatility_filter_active;
    double atr_min;
    double atr_max;
    bool bb_consolidation_only;
    bool trend_filter_active;
    int atr_period;
    double bb_multiplier;
    int bb_period;
    bool use_moving_average;
    int ma_period;
    ENUM_MA_METHOD ma_method;
};

// Estrutura para resultado de detecção
struct DetectionResult 
{
    bool should_plot;
    int direction;              // 1 = CALL, -1 = PUT, 0 = Nenhum
    PatternType pattern_used;
    bool was_inverted;
    SignalCoordinate coordinates;
    string detection_info;
    datetime detection_time;
};

//+------------------------------------------------------------------+
//| Constantes do Sistema                                           |
//+------------------------------------------------------------------+

// Constantes de Cache
const int MAX_CACHE_SIZE = 10000;
const int MIN_CACHE_SIZE = 100;
const int DEFAULT_CACHE_SIZE = 1000;

// Constantes de Performance
const int MAX_SUPERVARREDURA_ITERATIONS = 50000;
const int SUPERVARREDURA_TIMEOUT_SECONDS = 60;
const int CACHE_UPDATE_INTERVAL_SECONDS = 300;

// Constantes de Validação
const double MIN_ATR_VALUE = 0.000001;
const double MAX_ATR_VALUE = 1.0;
const double MIN_WINRATE = 0.0;
const double MAX_WINRATE = 100.0;

// Constantes Visuais
const string painelPrefix = "ProbPanel_";
const string arrowPrefix = "ProbArrow_";
const string timerPrefix = "ProbTimer_";
const string resultPrefix = "ProbResult_";
const string buttonPrefix = "ProbBtn_";

// Constantes de Cores
const color COR_PAINEL_FUNDO = clrBlack;
const color COR_PAINEL_TEXTO = clrWhite;
const color COR_PAINEL_BORDA = clrGray;
const color COR_CALL_DEFAULT = clrLime;
const color COR_PUT_DEFAULT = clrRed;
const color COR_NEUTRO = clrYellow;

// Constantes de Notificação
const int TELEGRAM_CYCLE_DURATION_SECONDS = 300; // 5 minutos
const int MAX_MESSAGE_LENGTH = 4096;
const int MAX_RETRY_ATTEMPTS = 3;

//+------------------------------------------------------------------+
//| Macros Utilitárias                                              |
//+------------------------------------------------------------------+

// Macro para validação de padrão
#define IsValidPatternCandle(color) ((color) == VISUAL_GREEN || (color) == VISUAL_RED)

// Macro para conversão segura de string
#define SafeStringToDouble(str, default_val) (StringToDouble(str) != 0.0 ? StringToDouble(str) : default_val)

// Macro para validação de shift
#define IsValidShift(shift, max_size) ((shift) >= 0 && (shift) < (max_size))

// Macro para logging condicional
#define LOG_IF_DEBUG(module, message) if(Logger::GetCurrentLevel() <= LOG_DEBUG) Logger::Debug(module, message)

//+------------------------------------------------------------------+
//| Funções Utilitárias Inline                                      |
//+------------------------------------------------------------------+

// Função para obter histórico necessário por padrão
int GetNeededHistoryForPattern(PatternType pattern)
{
    switch(pattern)
    {
        case PatternMHI1_3C_Minoria:
        case PatternMHI2_3C_Confirmado:
        case PatternMHI3_Unanime_Base:
        case PatternImpar_3C_Maioria:
        case PatternMelhorDe3_Maioria:
        case PatternThreeInARow_Base:
        case PatternC3_SeguirCor:                    // CORREÇÃO: Agora realmente usa 3 velas
        case PatternTorresGemeas_SeguirCor3:
        case Pattern23_ContinuacaoOposta:
            return 3;
            
        case Pattern3X1_ContinuacaoOposta:
        case PatternFourInARow_Base:
            return 4;
            
        case PatternFiveInARow_Base:
        case Pattern5Elemento_Base:
            return 5;
            
        case PatternM5_Variação_6C_Maioria:
        case PatternMilhao_6C_Maioria:
            return 6;
            
        case PatternSevenInARow_Base:
            return 7;
            
        case PatternUU_Base:
        case PatternDD_Base:
        case PatternUD_Base:
        case PatternDU_Base:
            return 2;
            
        case PatternMHI_Potencializada_Core:
            return 3;
            
        default:
            return 3; // Padrão seguro
    }
}

// Função para validar tipo de padrão
bool IsValidPatternType(PatternType pattern)
{
    return (pattern >= 0 && pattern <= LAST_PATTERN_ENUM && 
            pattern != PatternGABA_Placeholder && 
            pattern != PatternR7_Placeholder);
}

// Função para obter nome amigável do padrão
string GetPatternFriendlyName(PatternType pattern)
{
    switch(pattern)
    {
        case PatternMHI1_3C_Minoria: return "MHI1 3C Minoria";
        case PatternMHI2_3C_Confirmado: return "MHI2 3C Confirmado";
        case PatternMHI3_Unanime_Base: return "MHI3 Unânime";
        case PatternM5_Variação_6C_Maioria: return "M5 Variação 6C";
        case PatternMilhao_6C_Maioria: return "Milhão 6C";
        case PatternFiveInARow_Base: return "5 Seguidas";
        case PatternThreeInARow_Base: return "3 Seguidas";
        case PatternFourInARow_Base: return "4 Seguidas";
        case PatternImpar_3C_Maioria: return "Ímpar 3C";
        case PatternMelhorDe3_Maioria: return "Melhor de 3";
        case Pattern3X1_ContinuacaoOposta: return "3x1 Continuação";
        case PatternSevenInARow_Base: return "7 Seguidas";
        case Pattern23_ContinuacaoOposta: return "2+3 Continuação";
        case Pattern5Elemento_Base: return "5 Elementos";
        case PatternUU_Base: return "UU Base";
        case PatternDD_Base: return "DD Base";
        case PatternUD_Base: return "UD Base";
        case PatternDU_Base: return "DU Base";
        case PatternC3_SeguirCor: return "C3 Seguir Cor";
        case PatternTorresGemeas_SeguirCor3: return "Torres Gêmeas";
        case PatternMHI_Potencializada_Core: return "MHI Potencializada";
        default: return "Padrão Desconhecido";
    }
}

// Função para validar coordenadas de sinal
bool IsValidSignalCoordinate(const SignalCoordinate &coord)
{
    return (coord.is_valid && 
            coord.detection_shift >= 0 && 
            coord.plot_shift >= 0 && 
            coord.plot_price > 0 && 
            coord.plot_time > 0);
}

// Função para criar coordenada inválida
SignalCoordinate CreateInvalidCoordinate(string reason = "")
{
    SignalCoordinate coord;
    coord.detection_shift = -1;
    coord.plot_shift = -1;
    coord.plot_price = 0.0;
    coord.plot_time = 0;
    coord.is_valid = false;
    coord.debug_info = reason;
    return coord;
}

//+------------------------------------------------------------------+
//| Constantes de Configuração Avançada                             |
//+------------------------------------------------------------------+

// Configurações de Performance
const int MAX_CONCURRENT_OPERATIONS = 10;
const int BUFFER_SAFETY_MARGIN = 10;
const int MAX_LOG_FILE_SIZE_KB = 1024;
const int LOG_ROTATION_COUNT = 5;

// Configurações de Timeout
const int STATE_LOCK_TIMEOUT_MS = 5000;
const int CACHE_OPERATION_TIMEOUT_MS = 10000;
const int NOTIFICATION_TIMEOUT_MS = 30000;

// Configurações de Retry
const int MAX_CACHE_RECOVERY_ATTEMPTS = 3;
const int MAX_NOTIFICATION_RETRY_ATTEMPTS = 3;
const int RETRY_DELAY_MS = 1000;

// Configurações de Validação
const double EPSILON = 0.000001;
const int MIN_OPERATIONS_FOR_STATISTICS = 5;
const double MIN_PROFIT_FACTOR = 0.1;
const double MAX_PROFIT_FACTOR = 10.0;

//+------------------------------------------------------------------+
//| Estruturas Avançadas                                            |
//+------------------------------------------------------------------+

// Estrutura para configuração completa do sistema
struct SystemConfig 
{
    // Configurações de Cache
    int cache_size;
    bool cache_auto_update;
    int cache_update_interval;
    
    // Configurações de Performance
    int max_iterations;
    int timeout_seconds;
    bool enable_optimization;
    
    // Configurações de Log
    LogLevel log_level;
    bool log_to_file;
    bool log_to_console;
    string log_file_path;
    
    // Configurações de Notificação
    bool telegram_enabled;
    bool mx2_enabled;
    int notification_interval;
    
    // Configurações Visuais
    bool panel_enabled;
    bool timer_enabled;
    bool debug_panel_enabled;
    
    // Configurações de Validação
    bool strict_validation;
    bool auto_recovery;
    int max_recovery_attempts;
};

// Estrutura para métricas de sistema
struct SystemMetrics 
{
    datetime start_time;
    int uptime_seconds;
    int total_signals_generated;
    int cache_updates;
    int supervarredura_executions;
    int notification_sent;
    int errors_count;
    int warnings_count;
    double avg_calculation_time_ms;
    double max_calculation_time_ms;
    int memory_usage_kb;
};

// Estrutura para estado de debug
struct DebugState 
{
    bool debug_mode_active;
    LogLevel current_log_level;
    int debug_flags;
    string last_error_message;
    datetime last_error_time;
    int consecutive_errors;
    bool auto_recovery_active;
};

#endif // CORE_DEFINES_MQH

