//+------------------------------------------------------------------+
//|                                                 Core/Defines.mqh |
//|                                    Indicador de Probabilidades V3 |
//|                                   Sistema de Definições e Macros |
//+------------------------------------------------------------------+

#ifndef CORE_DEFINES_MQH
#define CORE_DEFINES_MQH

//+------------------------------------------------------------------+
//| Informações da Versão                                           |
//+------------------------------------------------------------------+
#define INDICATOR_VERSION       "3.0"
#define INDICATOR_NAME          "Indicador de Probabilidades V3"
#define INDICATOR_COPYRIGHT     "Copyright 2024, Quant Genius"
#define INDICATOR_LINK          "https://www.google.com"

//+------------------------------------------------------------------+
//| Constantes de Sistema                                           |
//+------------------------------------------------------------------+
#define EMPTY_VALUE             EMPTY_VALUE
#define INVALID_HANDLE          INVALID_HANDLE
#define INVALID_INDEX           -1

// Limites de Performance
#define MAX_BARS_TO_PROCESS     1000
#define MIN_BARS_REQUIRED       200
#define MAX_CACHE_SIZE          5000
#define DEFAULT_CACHE_SIZE      1000

// Intervalos de Atualização
#define TIMER_INTERVAL_MS       1000
#define PANEL_UPDATE_INTERVAL   5
#define CACHE_UPDATE_INTERVAL   10

//+------------------------------------------------------------------+
//| Prefixos para Objetos Gráficos                                  |
//+------------------------------------------------------------------+
#define PANEL_PREFIX            "ProbV3_Panel_"
#define ARROW_PREFIX            "ProbV3_Arrow_"
#define DRAWING_PREFIX          "ProbV3_Draw_"
#define TIMER_PREFIX            "ProbV3_Timer_"
#define CHART_PREFIX            "ProbV3_Chart_"
#define BUTTON_PREFIX           "ProbV3_Btn_"

//+------------------------------------------------------------------+
//| Configurações Visuais                                           |
//+------------------------------------------------------------------+
// Cores Padrão
#define DEFAULT_CALL_COLOR      clrLime
#define DEFAULT_PUT_COLOR       clrRed
#define DEFAULT_PANEL_BG        clrDarkSlateGray
#define DEFAULT_PANEL_BORDER    clrSilver
#define DEFAULT_TEXT_COLOR      clrWhite
#define DEFAULT_TITLE_COLOR     clrYellow
#define DEFAULT_SUCCESS_COLOR   clrLimeGreen
#define DEFAULT_ERROR_COLOR     clrCrimson
#define DEFAULT_WARNING_COLOR   clrOrange
#define DEFAULT_INFO_COLOR      clrCornflowerBlue

// Dimensões do Painel
#define PANEL_WIDTH             350
#define PANEL_HEIGHT            450
#define PANEL_MARGIN            10
#define PANEL_LINE_HEIGHT       18
#define PANEL_PADDING           8

// Configurações de Fonte
#define DEFAULT_FONT_NAME       "Consolas"
#define DEFAULT_FONT_SIZE       9
#define TITLE_FONT_SIZE         12
#define SMALL_FONT_SIZE         8

//+------------------------------------------------------------------+
//| Configurações de Setas e Marcadores                             |
//+------------------------------------------------------------------+
#define DEFAULT_ARROW_CALL      233
#define DEFAULT_ARROW_PUT       234
#define DEFAULT_ARROW_SIZE      2
#define ARROW_OFFSET_POINTS     10

// Marcadores de Resultado
#define MARKER_WIN              "✓"
#define MARKER_LOSS             "✗"
#define MARKER_GALE1            "G1"
#define MARKER_GALE2            "G2"

//+------------------------------------------------------------------+
//| Configurações de Performance                                    |
//+------------------------------------------------------------------+
#define MAX_EXECUTION_TIME_MS   100
#define MAX_MEMORY_USAGE_MB     50
#define MAX_CPU_USAGE_PERCENT   5

//+------------------------------------------------------------------+
//| Configurações de Log                                            |
//+------------------------------------------------------------------+
#define LOG_FILE_PREFIX         "ProbV3_"
#define LOG_MAX_FILE_SIZE       10485760  // 10MB
#define LOG_MAX_FILES           5
#define LOG_DATE_FORMAT         "%Y%m%d"

//+------------------------------------------------------------------+
//| Níveis de Log                                                   |
//+------------------------------------------------------------------+
#define LOG_LEVEL_DEBUG         0
#define LOG_LEVEL_INFO          1
#define LOG_LEVEL_WARNING       2
#define LOG_LEVEL_ERROR         3
#define LOG_LEVEL_CRITICAL      4

//+------------------------------------------------------------------+
//| Configurações de Cache                                          |
//+------------------------------------------------------------------+
#define CACHE_VALIDITY_SECONDS  60
#define CACHE_CLEANUP_INTERVAL  300
#define MAX_CACHE_ENTRIES       1000

//+------------------------------------------------------------------+
//| Configurações de Análise Financeira                             |
//+------------------------------------------------------------------+
#define DEFAULT_ENTRY_VALUE     10.0
#define DEFAULT_PAYOUT          0.95
#define DEFAULT_MARTINGALE      2.06
#define MIN_OPERATIONS_FOR_SV   6
#define MAX_GALES_ANALYSIS      2

//+------------------------------------------------------------------+
//| Configurações de Filtros                                        |
//+------------------------------------------------------------------+
#define DEFAULT_ATR_PERIOD      14
#define DEFAULT_ATR_MIN         0.0001
#define DEFAULT_ATR_MAX         0.0005
#define DEFAULT_BB_PERIOD       20
#define DEFAULT_BB_DEVIATION    2.0
#define DEFAULT_EMA_PERIOD      100

//+------------------------------------------------------------------+
//| Configurações de SuperVarredura                                 |
//+------------------------------------------------------------------+
#define SUPERSCAN_MAX_PATTERNS  50
#define SUPERSCAN_MIN_WINRATE   60.0
#define SUPERSCAN_MIN_OPERATIONS 10
#define SUPERSCAN_TIMEOUT_SEC   300

//+------------------------------------------------------------------+
//| Macros de Validação                                             |
//+------------------------------------------------------------------+
#define VALIDATE_POINTER(ptr) \
    if(CheckPointer(ptr) == POINTER_INVALID) { \
        Print("ERRO: Ponteiro inválido em ", __FUNCTION__, ":", __LINE__); \
        return false; \
    }

#define VALIDATE_ARRAY_SIZE(array, min_size) \
    if(ArraySize(array) < min_size) { \
        Print("ERRO: Array muito pequeno em ", __FUNCTION__, ":", __LINE__, " - Size: ", ArraySize(array), " Min: ", min_size); \
        return false; \
    }

#define VALIDATE_INDEX(index, array_size) \
    if(index < 0 || index >= array_size) { \
        Print("ERRO: Índice inválido em ", __FUNCTION__, ":", __LINE__, " - Index: ", index, " Size: ", array_size); \
        return false; \
    }

#define VALIDATE_HANDLE(handle, name) \
    if(handle == INVALID_HANDLE) { \
        Print("ERRO: Handle inválido para ", name, " em ", __FUNCTION__, ":", __LINE__); \
        return false; \
    }

#define VALIDATE_PRICE(price) \
    if(price <= 0 || price == EMPTY_VALUE || !MathIsValidNumber(price)) { \
        Print("ERRO: Preço inválido em ", __FUNCTION__, ":", __LINE__, " - Price: ", price); \
        return false; \
    }

//+------------------------------------------------------------------+
//| Macros de Performance                                           |
//+------------------------------------------------------------------+
#define START_TIMER() \
    uint start_time = GetTickCount();

#define END_TIMER(operation_name) \
    uint end_time = GetTickCount(); \
    uint elapsed = end_time - start_time; \
    if(elapsed > MAX_EXECUTION_TIME_MS) { \
        Print("WARNING: Operação lenta - ", operation_name, ": ", elapsed, "ms"); \
    }

#define SAFE_ARRAY_ACCESS(array, index, default_value) \
    ((index >= 0 && index < ArraySize(array)) ? array[index] : default_value)

//+------------------------------------------------------------------+
//| Macros de Conversão                                             |
//+------------------------------------------------------------------+
#define BOOL_TO_STRING(value) ((value) ? "Sim" : "Não")
#define DOUBLE_TO_CURRENCY(value) (DoubleToString(value, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY))
#define PERCENT_TO_STRING(value) (DoubleToString(value, 2) + "%")

//+------------------------------------------------------------------+
//| Macros de Cores Condicionais                                    |
//+------------------------------------------------------------------+
#define COLOR_BY_RESULT(is_positive) ((is_positive) ? DEFAULT_SUCCESS_COLOR : DEFAULT_ERROR_COLOR)
#define COLOR_BY_WINRATE(winrate) ((winrate >= 60.0) ? DEFAULT_SUCCESS_COLOR : (winrate >= 50.0) ? DEFAULT_WARNING_COLOR : DEFAULT_ERROR_COLOR)

//+------------------------------------------------------------------+
//| Estados do Sistema                                              |
//+------------------------------------------------------------------+
enum SystemState
{
    STATE_UNINITIALIZED = 0,    // Sistema não inicializado
    STATE_INITIALIZING = 1,     // Inicializando
    STATE_READY = 2,            // Pronto para operação
    STATE_RUNNING = 3,          // Executando normalmente
    STATE_SUPERSCAN = 4,        // Executando SuperVarredura
    STATE_ERROR = 5,            // Estado de erro
    STATE_STOPPING = 6,         // Parando sistema
    STATE_STOPPED = 7           // Sistema parado
};

//+------------------------------------------------------------------+
//| Tipos de Resultado de Operação                                  |
//+------------------------------------------------------------------+
enum OperationResult
{
    RESULT_UNKNOWN = 0,         // Resultado desconhecido
    RESULT_WIN = 1,             // Vitória
    RESULT_LOSS = 2,            // Perda
    RESULT_GALE1_WIN = 3,       // Vitória no Gale 1
    RESULT_GALE2_WIN = 4,       // Vitória no Gale 2
    RESULT_GALE_LOSS = 5        // Perda após Gales
};

//+------------------------------------------------------------------+
//| Critérios de SuperVarredura                                     |
//+------------------------------------------------------------------+
enum SuperScanCriteria
{
    SUPERSCAN_WINRATE = 0,      // Maior winrate
    SUPERSCAN_PROFIT = 1,       // Maior lucro
    SUPERSCAN_OPERATIONS = 2,   // Mais operações
    SUPERSCAN_BALANCED = 3      // Balanceado (winrate + lucro)
};

//+------------------------------------------------------------------+
//| Tipos de Notificação                                            |
//+------------------------------------------------------------------+
enum NotificationType
{
    NOTIFY_SIGNAL = 0,          // Sinal de entrada
    NOTIFY_RESULT = 1,          // Resultado de operação
    NOTIFY_SUPERSCAN = 2,       // Resultado de SuperVarredura
    NOTIFY_ERROR = 3,           // Erro do sistema
    NOTIFY_STATUS = 4           // Status do sistema
};

//+------------------------------------------------------------------+
//| Configurações de Broker MX2                                     |
//+------------------------------------------------------------------+
enum BrokerMX2
{
    MX2_TODAS = 0,              // Todas as corretoras
    MX2_QUOTEX = 1,             // Quotex
    MX2_POCKET = 2,             // Pocket Option
    MX2_BINOMO = 3,             // Binomo
    MX2_OLYMP = 4,              // Olymp Trade
    MX2_EXPERT = 5,             // Expert Option
    MX2_SPECTRE = 6             // Spectre
};

//+------------------------------------------------------------------+
//| Tipos de Entrada MX2                                            |
//+------------------------------------------------------------------+
enum SignalTypeMX2
{
    MX2_CLOSED_CANDLE = 0,      // Vela fechada
    MX2_OPEN_CANDLE = 1,        // Vela aberta
    MX2_IMMEDIATE = 2           // Imediato
};

//+------------------------------------------------------------------+
//| Tipos de Expiração MX2                                          |
//+------------------------------------------------------------------+
enum ExpirationTypeMX2
{
    MX2_CORRIDO = 0,            // Corrido
    MX2_EXATO = 1               // Exato
};

//+------------------------------------------------------------------+
//| Funções Inline para Performance                                 |
//+------------------------------------------------------------------+
inline bool IsValidPrice(double price)
{
    return (price > 0 && price != EMPTY_VALUE && MathIsValidNumber(price));
}

inline bool IsValidIndex(int index, int array_size)
{
    return (index >= 0 && index < array_size);
}

inline double NormalizePrice(double price)
{
    return NormalizeDouble(price, _Digits);
}

inline string FormatCurrency(double value)
{
    return DoubleToString(value, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY);
}

inline string FormatPercent(double value)
{
    return DoubleToString(value, 2) + "%";
}

inline color GetResultColor(OperationResult result)
{
    switch(result)
    {
        case RESULT_WIN:
        case RESULT_GALE1_WIN:
        case RESULT_GALE2_WIN:
            return DEFAULT_SUCCESS_COLOR;
        case RESULT_LOSS:
        case RESULT_GALE_LOSS:
            return DEFAULT_ERROR_COLOR;
        default:
            return DEFAULT_TEXT_COLOR;
    }
}

inline string GetResultText(OperationResult result)
{
    switch(result)
    {
        case RESULT_WIN: return "WIN";
        case RESULT_LOSS: return "LOSS";
        case RESULT_GALE1_WIN: return "G1 WIN";
        case RESULT_GALE2_WIN: return "G2 WIN";
        case RESULT_GALE_LOSS: return "G LOSS";
        default: return "UNKNOWN";
    }
}

#endif // CORE_DEFINES_MQH

