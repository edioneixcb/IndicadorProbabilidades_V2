//+------------------------------------------------------------------+
//|                                    Core/Utilities.mqh |
//|                        Copyright 2024, Quant Genius (Refactoring) |
//|                                      https://www.google.com |
//|                                    VERSÃO SIMPLIFICADA v2.0     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quant Genius (Refactoring)"
#property link      "https://www.google.com"

#ifndef CORE_UTILITIES_MQH
#define CORE_UTILITIES_MQH

#include "Defines.mqh"

// ==================================================================
// FUNÇÕES UTILITÁRIAS SIMPLIFICADAS
// ==================================================================

//+------------------------------------------------------------------+
//| Valida acesso seguro a array                                    |
//+------------------------------------------------------------------+
bool ValidateArrayAccess(int index, int array_size, string context = "")
{
    if(index < 0 || index >= array_size)
    {
        if(context != "")
            Print("ERRO: Acesso inválido ao array em ", context, " - Index: ", index, ", Size: ", array_size);
        return false;
    }
    return true;
}

//+------------------------------------------------------------------+
//| Valida parâmetro de entrada                                     |
//+------------------------------------------------------------------+
bool ValidateInputParameter(double value, double min_val, double max_val, string param_name)
{
    if(value < min_val || value > max_val)
    {
        Print("ERRO: Parâmetro ", param_name, " fora do range [", min_val, ", ", max_val, "] - Valor: ", value);
        return false;
    }
    return true;
}

//+------------------------------------------------------------------+
//| Valida handle de indicador                                      |
//+------------------------------------------------------------------+
bool ValidateIndicatorHandle(int handle, string indicator_name)
{
    if(handle == INVALID_HANDLE)
    {
        Print("ERRO: Handle inválido para ", indicator_name, " - Erro: ", GetLastError());
        return false;
    }
    return true;
}

//+------------------------------------------------------------------+
//| Copia buffer de indicador com validação                         |
//+------------------------------------------------------------------+
bool SafeCopyBuffer(int handle, int buffer_num, int start_pos, int count, double &array[])
{
    if(handle == INVALID_HANDLE)
        return false;
    
    int copied = CopyBuffer(handle, buffer_num, start_pos, count, array);
    if(copied <= 0)
    {
        Print("ERRO: Falha ao copiar buffer - Handle: ", handle, ", Buffer: ", buffer_num, ", Erro: ", GetLastError());
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Calcula tamanho do corpo da vela                                |
//+------------------------------------------------------------------+
double GetCandleBodySize(double open, double close)
{
    return MathAbs(close - open);
}

//+------------------------------------------------------------------+
//| Calcula tamanho da sombra superior                              |
//+------------------------------------------------------------------+
double GetUpperShadowSize(double open, double close, double high)
{
    return high - MathMax(open, close);
}

//+------------------------------------------------------------------+
//| Calcula tamanho da sombra inferior                              |
//+------------------------------------------------------------------+
double GetLowerShadowSize(double open, double close, double low)
{
    return MathMin(open, close) - low;
}

//+------------------------------------------------------------------+
//| Verifica se vela é de alta                                      |
//+------------------------------------------------------------------+
bool IsBullishCandle(double open, double close)
{
    return close > open;
}

//+------------------------------------------------------------------+
//| Verifica se vela é de baixa                                     |
//+------------------------------------------------------------------+
bool IsBearishCandle(double open, double close)
{
    return close < open;
}

//+------------------------------------------------------------------+
//| Calcula range total da vela                                     |
//+------------------------------------------------------------------+
double GetCandleRange(double high, double low)
{
    return high - low;
}

//+------------------------------------------------------------------+
//| Verifica se é uma vela doji                                     |
//+------------------------------------------------------------------+
bool IsDojiCandle(double open, double close, double high, double low, double threshold = 0.1)
{
    double body = GetCandleBodySize(open, close);
    double range = GetCandleRange(high, low);
    
    if(range == 0) return false;
    
    return (body / range) < threshold;
}

//+------------------------------------------------------------------+
//| Limpa objetos por prefixo                                       |
//+------------------------------------------------------------------+
void CleanObjectsByPrefix(string prefix)
{
    int total_objects = ObjectsTotal(0);
    
    for(int i = total_objects - 1; i >= 0; i--)
    {
        string obj_name = ObjectName(0, i);
        if(StringFind(obj_name, prefix) >= 0)
        {
            ObjectDelete(0, obj_name);
        }
    }
}

//+------------------------------------------------------------------+
//| Converte timeframe para string                                  |
//+------------------------------------------------------------------+
string TimeframeToString(ENUM_TIMEFRAMES timeframe)
{
    switch(timeframe)
    {
        case PERIOD_M1:  return "M1";
        case PERIOD_M5:  return "M5";
        case PERIOD_M15: return "M15";
        case PERIOD_M30: return "M30";
        case PERIOD_H1:  return "H1";
        case PERIOD_H4:  return "H4";
        case PERIOD_D1:  return "D1";
        case PERIOD_W1:  return "W1";
        case PERIOD_MN1: return "MN1";
        default:         return "UNKNOWN";
    }
}

//+------------------------------------------------------------------+
//| Formata preço para exibição                                     |
//+------------------------------------------------------------------+
string FormatPrice(double price)
{
    return DoubleToString(price, _Digits);
}

//+------------------------------------------------------------------+
//| Formata tempo para exibição                                     |
//+------------------------------------------------------------------+
string FormatTime(datetime time, bool include_seconds = false)
{
    if(include_seconds)
        return TimeToString(time, TIME_DATE|TIME_SECONDS);
    else
        return TimeToString(time, TIME_DATE|TIME_MINUTES);
}

//+------------------------------------------------------------------+
//| Calcula distância em pontos                                     |
//+------------------------------------------------------------------+
double PointsDistance(double price1, double price2)
{
    return MathAbs(price1 - price2) / _Point;
}

//+------------------------------------------------------------------+
//| Verifica se preço está dentro do range                          |
//+------------------------------------------------------------------+
bool IsPriceInRange(double price, double min_price, double max_price)
{
    return (price >= min_price && price <= max_price);
}

//+------------------------------------------------------------------+
//| Calcula média de array                                          |
//+------------------------------------------------------------------+
double CalculateArrayAverage(const double &array[], int start = 0, int count = -1)
{
    int array_size = ArraySize(array);
    if(array_size == 0) return 0.0;
    
    if(count == -1) count = array_size - start;
    if(start + count > array_size) count = array_size - start;
    
    double sum = 0.0;
    for(int i = start; i < start + count; i++)
    {
        sum += array[i];
    }
    
    return sum / count;
}

//+------------------------------------------------------------------+
//| Encontra valor máximo em array                                  |
//+------------------------------------------------------------------+
double FindArrayMaximum(const double &array[], int start = 0, int count = -1)
{
    int array_size = ArraySize(array);
    if(array_size == 0) return 0.0;
    
    if(count == -1) count = array_size - start;
    if(start + count > array_size) count = array_size - start;
    
    double max_value = array[start];
    for(int i = start + 1; i < start + count; i++)
    {
        if(array[i] > max_value)
            max_value = array[i];
    }
    
    return max_value;
}

//+------------------------------------------------------------------+
//| Encontra valor mínimo em array                                  |
//+------------------------------------------------------------------+
double FindArrayMinimum(const double &array[], int start = 0, int count = -1)
{
    int array_size = ArraySize(array);
    if(array_size == 0) return 0.0;
    
    if(count == -1) count = array_size - start;
    if(start + count > array_size) count = array_size - start;
    
    double min_value = array[start];
    for(int i = start + 1; i < start + count; i++)
    {
        if(array[i] < min_value)
            min_value = array[i];
    }
    
    return min_value;
}

//+------------------------------------------------------------------+
//| Função de log simplificada                                      |
//+------------------------------------------------------------------+
void SimpleLog(int level, string context, string message)
{
    string level_str = "";
    switch(level)
    {
        case LOG_DEBUG:    level_str = "DEBUG"; break;
        case LOG_INFO:     level_str = "INFO"; break;
        case LOG_WARNING:  level_str = "WARNING"; break;
        case LOG_ERROR:    level_str = "ERROR"; break;
        case LOG_CRITICAL: level_str = "CRITICAL"; break;
        default:           level_str = "UNKNOWN"; break;
    }
    
    Print("[", level_str, "] ", context, ": ", message);
}

#endif // CORE_UTILITIES_MQH

