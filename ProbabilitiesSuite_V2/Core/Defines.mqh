//+------------------------------------------------------------------+
//|                                    Core/Defines.mqh |
//|                        Copyright 2024, Quant Genius (Refactoring) |
//|                                      https://www.google.com |
//|                                    VERSÃO SIMPLIFICADA v2.0     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quant Genius (Refactoring)"
#property link      "https://www.google.com"

#ifndef CORE_DEFINES_MQH
#define CORE_DEFINES_MQH

// ==================================================================
// DEFINIÇÕES BÁSICAS - VERSÃO SIMPLIFICADA
// ==================================================================

// Constantes básicas
#define EMPTY_VALUE         EMPTY_VALUE
#define INVALID_HANDLE      INVALID_HANDLE

// Prefixos para objetos
#define PANEL_PREFIX        "ProbV2_"
#define DRAWING_PREFIX      "ProbV2_Draw_"

// Configurações de cache
#define DEFAULT_CACHE_SIZE  1000
#define MIN_BARS_REQUIRED   100

// Configurações de performance
#define MAX_PROCESSING_BARS 100
#define UPDATE_INTERVAL     60

// Cores padrão
#define DEFAULT_CALL_COLOR  clrLime
#define DEFAULT_PUT_COLOR   clrRed
#define DEFAULT_PANEL_COLOR clrDarkSlateGray

// Enums básicos
enum PatternType
{
    PatternMHI1_3C_Minoria = 0,
    PatternMHI2_3C_Maioria = 1,
    PatternMHI3_2C_Minoria = 2,
    PatternMHI4_2C_Maioria = 3,
    PatternMHI5_1C_Minoria = 4,
    PatternMHI6_1C_Maioria = 5
};

enum ENUM_POSICAO_SETA
{
    PosicaoSeta_Automatica = 0,
    PosicaoSeta_Acima = 1,
    PosicaoSeta_Abaixo = 2,
    PosicaoSeta_Centro = 3
};

// Estruturas básicas
struct SignalInfo
{
    datetime time;
    double price;
    PatternType pattern;
    bool is_call;
    string description;
};

struct MarketCondition
{
    double atr_value;
    double bb_width;
    double spread;
    bool is_consolidation;
    bool is_trending;
};

// Macros úteis
#define SAFE_ARRAY_ACCESS(array, index, default_value) \
    ((index >= 0 && index < ArraySize(array)) ? array[index] : default_value)

#define VALIDATE_HANDLE(handle) \
    (handle != INVALID_HANDLE)

#define IS_NEW_BAR(current_time, last_time) \
    (current_time != last_time)

// Funções inline básicas
inline bool IsValidPrice(double price)
{
    return (price > 0 && price != EMPTY_VALUE && !MathIsInf(price) && !MathIsNaN(price));
}

inline bool IsValidIndex(int index, int array_size)
{
    return (index >= 0 && index < array_size);
}

inline double NormalizePrice(double price)
{
    return NormalizeDouble(price, _Digits);
}

inline string BoolToString(bool value)
{
    return value ? "true" : "false";
}

// Constantes de log (simplificadas)
#define LOG_DEBUG    0
#define LOG_INFO     1
#define LOG_WARNING  2
#define LOG_ERROR    3
#define LOG_CRITICAL 4

#endif // CORE_DEFINES_MQH

