//+------------------------------------------------------------------+
//|                                    Core/Utilities.mqh |
//|                        Copyright 2024, Quant Genius (Refactoring) |
//|                                      https://www.google.com |
//|                                    VERSÃO CORRIGIDA v2.0        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quant Genius (Refactoring)"
#property link      "https://www.google.com"

#ifndef CORE_UTILITIES_MQH
#define CORE_UTILITIES_MQH

#include "Defines.mqh"
#include "Globals.mqh"

// ==================================================================
// FUNÇÕES UTILITÁRIAS CORRIGIDAS - VERSÃO 2.0
// ==================================================================

//+------------------------------------------------------------------+
//| CORREÇÃO #1: Função de validação segura para acesso ao cache    |
//+------------------------------------------------------------------+
bool ValidateShiftAccess(int shift, int additional_history = 0, const string function_name = "")
{
    // Verificação de inicialização do cache
    if(!g_cache_initialized) 
    {
        if(function_name != "") 
            Print("ERRO [", function_name, "]: Cache não inicializado");
        RegisterSystemError("Cache não inicializado em " + function_name);
        return false;
    }
    
    // Verificação de shift negativo
    if(shift < 0) 
    {
        if(function_name != "") 
            Print("ERRO [", function_name, "]: Shift negativo (", shift, ")");
        RegisterSystemError("Shift negativo em " + function_name);
        return false;
    }
    
    // Verificação de limites superiores
    int required_size = shift + additional_history;
    if(required_size >= g_cache_size) 
    {
        if(function_name != "") 
            Print("ERRO [", function_name, "]: Acesso fora dos limites (", 
                  required_size, " >= ", g_cache_size, ")");
        RegisterSystemError("Acesso fora dos limites em " + function_name);
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #2: Versão segura de GetVisualCandleColor              |
//+------------------------------------------------------------------+
int GetVisualCandleColorSafe(int shift, const string caller = "")
{
    if(!ValidateShiftAccess(shift, 0, caller))
        return VISUAL_DOJI; // Valor seguro padrão
    
    if(shift >= ArraySize(g_cache_candle_colors))
        return VISUAL_DOJI;
    
    return g_cache_candle_colors[shift];
}

//+------------------------------------------------------------------+
//| CORREÇÃO #3: Função para calcular coordenadas consistentes      |
//+------------------------------------------------------------------+
SignalCoordinate CalculateSignalCoordinate(
    int detection_shift, 
    int direction, 
    ENUM_POSICAO_SETA position_type
)
{
    SignalCoordinate coord;
    coord.detection_shift = detection_shift;
    coord.is_valid = false;
    coord.debug_info = "";
    
    // Determina shift de plotagem baseado na configuração
    switch(position_type)
    {
        case POS_VELA_DE_SINAL:
            coord.plot_shift = detection_shift + 1; // Vela do padrão
            coord.debug_info = "Posição: Vela de Sinal";
            break;
        case POS_VELA_DE_ENTRADA:
        default:
            coord.plot_shift = detection_shift; // Vela de entrada
            coord.debug_info = "Posição: Vela de Entrada";
            break;
    }
    
    // Validação de limites para plotagem
    int total_bars = Bars(_Symbol, _Period);
    if(coord.plot_shift >= total_bars || coord.plot_shift < 0)
    {
        Print("AVISO: Shift de plotagem inválido (", coord.plot_shift, 
              "), usando shift de detecção");
        coord.plot_shift = detection_shift;
        coord.debug_info += " | Ajustado para shift de detecção";
    }
    
    // Validação final
    if(coord.plot_shift >= total_bars || coord.plot_shift < 0)
    {
        Print("ERRO: Impossível calcular coordenadas válidas");
        coord.debug_info += " | ERRO: Coordenadas inválidas";
        return coord; // is_valid permanece false
    }
    
    // Cálculo de tempo e preço
    coord.plot_time = iTime(_Symbol, _Period, coord.plot_shift);
    
    double point_value = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    if(point_value == 0) point_value = _Point;
    
    if(direction > 0) // CALL
    {
        coord.plot_price = iLow(_Symbol, _Period, coord.plot_shift) - (point_value * 10);
        coord.debug_info += " | CALL";
    }
    else // PUT
    {
        coord.plot_price = iHigh(_Symbol, _Period, coord.plot_shift) + (point_value * 10);
        coord.debug_info += " | PUT";
    }
    
    // Validação final do preço
    if(coord.plot_price <= 0)
    {
        Print("ERRO: Preço de plotagem inválido: ", coord.plot_price);
        coord.debug_info += " | ERRO: Preço inválido";
        return coord;
    }
    
    coord.is_valid = true;
    return coord;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #4: Função de validação de integridade de dados        |
//+------------------------------------------------------------------+
bool ValidateDataIntegrity(const double &array[], int expected_size, string array_name = "")
{
    if(ArraySize(array) != expected_size)
    {
        Print("ERRO: Tamanho inconsistente em ", array_name, 
              " - Esperado: ", expected_size, ", Atual: ", ArraySize(array));
        return false;
    }
    
    // Verifica valores inválidos (NaN, infinito)
    for(int i = 0; i < MathMin(expected_size, 100); i += 10) // Amostragem
    {
        if(!MathIsValidNumber(array[i]))
        {
            Print("ERRO: Valor inválido em ", array_name, "[", i, "]: ", array[i]);
            return false;
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #5: Função de limpeza segura de objetos                |
//+------------------------------------------------------------------+
void LimpaObjetosPorPrefixo(string prefixo, int tipo_objeto = -1)
{
    int total_objetos = ObjectsTotal(0);
    
    for(int i = total_objetos - 1; i >= 0; i--)
    {
        string nome_objeto = ObjectName(0, i);
        
        if(StringFind(nome_objeto, prefixo) == 0)
        {
            if(tipo_objeto == -1 || ObjectGetInteger(0, nome_objeto, OBJPROP_TYPE) == tipo_objeto)
            {
                if(!ObjectDelete(0, nome_objeto))
                {
                    Print("AVISO: Falha ao deletar objeto: ", nome_objeto);
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| CORREÇÃO #6: Função de conversão segura de string para double   |
//+------------------------------------------------------------------+
double SafeStringToDouble(string str, double default_value = 0.0)
{
    if(str == "" || str == NULL)
        return default_value;
    
    double result = StringToDouble(str);
    
    if(!MathIsValidNumber(result))
        return default_value;
    
    return result;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #7: Função de conversão segura de string para int      |
//+------------------------------------------------------------------+
int SafeStringToInteger(string str, int default_value = 0)
{
    if(str == "" || str == NULL)
        return default_value;
    
    int result = (int)StringToInteger(str);
    return result;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #8: Função de formatação segura de double              |
//+------------------------------------------------------------------+
string SafeDoubleToString(double value, int digits = 2)
{
    if(!MathIsValidNumber(value))
        return "N/A";
    
    return DoubleToString(value, digits);
}

//+------------------------------------------------------------------+
//| CORREÇÃO #9: Função de validação de handle de indicador         |
//+------------------------------------------------------------------+
bool IsValidIndicatorHandle(int handle)
{
    return (handle != INVALID_HANDLE && handle > 0);
}

//+------------------------------------------------------------------+
//| CORREÇÃO #10: Função de cópia segura de dados de indicador      |
//+------------------------------------------------------------------+
bool SafeCopyBuffer(int handle, int buffer_index, int start, int count, double &array[])
{
    if(!IsValidIndicatorHandle(handle))
    {
        Print("ERRO: Handle de indicador inválido");
        return false;
    }
    
    if(count <= 0 || start < 0)
    {
        Print("ERRO: Parâmetros de cópia inválidos - Start: ", start, ", Count: ", count);
        return false;
    }
    
    int copied = CopyBuffer(handle, buffer_index, start, count, array);
    
    if(copied != count)
    {
        Print("AVISO: Cópia incompleta - Solicitado: ", count, ", Copiado: ", copied);
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #11: Função de validação de símbolo e timeframe        |
//+------------------------------------------------------------------+
bool ValidateSymbolAndTimeframe(string symbol, ENUM_TIMEFRAMES timeframe)
{
    if(symbol == "" || symbol == NULL)
    {
        Print("ERRO: Símbolo inválido");
        return false;
    }
    
    if(!SymbolSelect(symbol, true))
    {
        Print("ERRO: Símbolo não disponível: ", symbol);
        return false;
    }
    
    if(timeframe == PERIOD_CURRENT)
        timeframe = _Period;
    
    if(timeframe < PERIOD_M1 || timeframe > PERIOD_MN1)
    {
        Print("ERRO: Timeframe inválido: ", EnumToString(timeframe));
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #12: Função de cálculo de hash simples                 |
//+------------------------------------------------------------------+
string CalculateSimpleHash(const int &array[], int sample_size = 100)
{
    if(ArraySize(array) == 0)
        return "";
    
    int hash = 0;
    int size = ArraySize(array);
    int step = MathMax(1, size / sample_size);
    
    for(int i = 0; i < size; i += step)
    {
        hash += array[i] * (i + 1);
    }
    
    return IntegerToString(hash) + "_" + IntegerToString(size);
}

//+------------------------------------------------------------------+
//| CORREÇÃO #13: Função de validação de período de tempo           |
//+------------------------------------------------------------------+
bool IsValidTimePeriod(datetime start_time, datetime end_time)
{
    if(start_time <= 0 || end_time <= 0)
        return false;
    
    if(start_time >= end_time)
        return false;
    
    // Verifica se não é muito no futuro (mais de 1 ano)
    if(end_time > TimeCurrent() + 365 * 24 * 3600)
        return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #14: Função de formatação de tempo para logs           |
//+------------------------------------------------------------------+
string FormatTimeForLog(datetime time)
{
    if(time <= 0)
        return "INVALID_TIME";
    
    return TimeToString(time, TIME_DATE | TIME_SECONDS);
}

//+------------------------------------------------------------------+
//| CORREÇÃO #15: Função de validação de parâmetros de entrada      |
//+------------------------------------------------------------------+
bool ValidateInputParameter(double value, double min_val, double max_val, string param_name)
{
    if(!MathIsValidNumber(value))
    {
        Print("ERRO: Parâmetro ", param_name, " contém valor inválido: ", value);
        return false;
    }
    
    if(value < min_val || value > max_val)
    {
        Print("ERRO: Parâmetro ", param_name, " fora do intervalo [", min_val, ", ", max_val, "]: ", value);
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #16: Função de backup de configuração                  |
//+------------------------------------------------------------------+
bool BackupConfiguration(string backup_name = "")
{
    if(backup_name == "")
        backup_name = "config_backup_" + TimeToString(TimeCurrent(), TIME_DATE);
    
    // Esta função seria expandida para salvar configurações em arquivo
    // Por simplicidade, apenas registra a tentativa
    Print("Backup de configuração solicitado: ", backup_name);
    return true;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #17: Função de restauração de configuração             |
//+------------------------------------------------------------------+
bool RestoreConfiguration(string backup_name)
{
    if(backup_name == "")
    {
        Print("ERRO: Nome de backup não especificado");
        return false;
    }
    
    // Esta função seria expandida para carregar configurações de arquivo
    // Por simplicidade, apenas registra a tentativa
    Print("Restauração de configuração solicitada: ", backup_name);
    return true;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #18: Função de medição de performance                  |
//+------------------------------------------------------------------+
class PerformanceMeasurer
{
private:
    ulong start_time;
    string operation_name;
    
public:
    PerformanceMeasurer(string name)
    {
        operation_name = name;
        start_time = GetTickCount64();
    }
    
    ~PerformanceMeasurer()
    {
        ulong elapsed = GetTickCount64() - start_time;
        RegisterCalculationTime(elapsed);
        
        if(elapsed > 1000) // Log se demorar mais de 1 segundo
        {
            Print("PERFORMANCE: ", operation_name, " executado em ", elapsed, "ms");
        }
    }
    
    ulong GetElapsedTime()
    {
        return GetTickCount64() - start_time;
    }
};

//+------------------------------------------------------------------+
//| CORREÇÃO #19: Função de validação de array                      |
//+------------------------------------------------------------------+
bool ValidateArray(const double &array[], int min_size = 1, string array_name = "")
{
    int size = ArraySize(array);
    
    if(size < min_size)
    {
        Print("ERRO: Array ", array_name, " muito pequeno - Tamanho: ", size, ", Mínimo: ", min_size);
        return false;
    }
    
    // Verifica alguns valores para detectar corrupção
    int check_count = MathMin(size, 10);
    for(int i = 0; i < check_count; i++)
    {
        if(!MathIsValidNumber(array[i]))
        {
            Print("ERRO: Valor inválido em ", array_name, "[", i, "]: ", array[i]);
            return false;
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #20: Função de normalização de valores                 |
//+------------------------------------------------------------------+
double NormalizeValue(double value, double min_val, double max_val)
{
    if(!MathIsValidNumber(value) || !MathIsValidNumber(min_val) || !MathIsValidNumber(max_val))
        return 0.0;
    
    if(max_val <= min_val)
        return 0.0;
    
    if(value <= min_val)
        return 0.0;
    
    if(value >= max_val)
        return 1.0;
    
    return (value - min_val) / (max_val - min_val);
}

//+------------------------------------------------------------------+
//| CORREÇÃO #21: Função de verificação de recursos do sistema      |
//+------------------------------------------------------------------+
bool CheckSystemResources()
{
    // Verifica memória disponível (estimativa)
    int estimated_memory = g_system_metrics.memory_usage_kb;
    
    if(estimated_memory > 50000) // 50MB
    {
        Print("AVISO: Alto uso de memória detectado: ", estimated_memory, " KB");
        RegisterSystemWarning();
        return false;
    }
    
    // Verifica se há muitos objetos no gráfico
    int total_objects = ObjectsTotal(0);
    if(total_objects > 1000)
    {
        Print("AVISO: Muitos objetos no gráfico: ", total_objects);
        RegisterSystemWarning();
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #22: Função de limpeza de emergência                   |
//+------------------------------------------------------------------+
void EmergencyCleanup()
{
    Print("EXECUTANDO LIMPEZA DE EMERGÊNCIA...");
    
    // Limpa objetos visuais
    LimpaObjetosPorPrefixo(painelPrefix);
    LimpaObjetosPorPrefixo(arrowPrefix);
    LimpaObjetosPorPrefixo(timerPrefix);
    LimpaObjetosPorPrefixo(resultPrefix);
    LimpaObjetosPorPrefixo(buttonPrefix);
    
    // Reset de contadores de erro
    ResetConsecutiveErrors();
    
    // Força garbage collection (se disponível)
    // Em MQL5, isso é feito automaticamente
    
    Print("Limpeza de emergência concluída");
}

//+------------------------------------------------------------------+
//| CORREÇÃO #23: Função de diagnóstico do sistema                  |
//+------------------------------------------------------------------+
void SystemDiagnostic()
{
    Print("=== DIAGNÓSTICO DO SISTEMA ===");
    
    // Estado do cache
    Print("Cache: ", g_cache_initialized ? "OK" : "FALHA", 
          " (", g_cache_size, " velas)");
    
    // Estado da SuperVarredura
    Print("SuperVarredura: ", g_rodouSuperVarreduraComSucesso ? "OK" : "PENDENTE");
    
    // Métricas de performance
    SystemMetrics metrics = GetCurrentSystemMetrics();
    Print("Uptime: ", metrics.uptime_seconds, "s");
    Print("Sinais gerados: ", metrics.total_signals_generated);
    Print("Erros: ", metrics.errors_count);
    Print("Warnings: ", metrics.warnings_count);
    Print("Tempo médio de cálculo: ", SafeDoubleToString(metrics.avg_calculation_time_ms, 2), "ms");
    Print("Uso de memória: ", metrics.memory_usage_kb, " KB");
    
    // Estado de handles
    Print("ATR Handle: ", IsValidIndicatorHandle(g_atr_handle) ? "OK" : "INVÁLIDO");
    Print("BB Handle: ", IsValidIndicatorHandle(g_bb_handle) ? "OK" : "INVÁLIDO");
    Print("MA Handle: ", IsValidIndicatorHandle(g_ma_handle) ? "OK" : "INVÁLIDO");
    
    Print("=== FIM DO DIAGNÓSTICO ===");
}

//+------------------------------------------------------------------+
//| Função de inicialização de utilitários                          |
//+------------------------------------------------------------------+
void InitializeUtilities()
{
    Print("Utilitários do sistema inicializados");
}

#endif // CORE_UTILITIES_MQH

