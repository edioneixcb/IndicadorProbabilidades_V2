//+------------------------------------------------------------------+
//|                                    BufferManager.mqh |
//|                        Copyright 2024, Quant Genius (Refactoring) |
//|                                      https://www.google.com |
//|                                    VERSÃO CORRIGIDA v2.0        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quant Genius (Refactoring)"
#property link      "https://www.google.com"

#ifndef BUFFERMANAGER_MQH
#define BUFFERMANAGER_MQH

#include "ProbabilitiesSuite_V2/Core/Defines.mqh"
#include "ProbabilitiesSuite_V2/Core/Globals.mqh"
#include "ProbabilitiesSuite_V2/Core/Utilities.mqh"
#include "ProbabilitiesSuite_V2/Core/Logger.mqh"
#include "ProbabilitiesSuite_V2/Core/StateManager.mqh"
#include "ProbabilitiesSuite_V2/Logic/PatternEngine.mqh"
#include "ProbabilitiesSuite_V2/Filter/Market.mqh"

// ==================================================================
// GERENCIADOR DE BUFFERS CORRIGIDO - VERSÃO 2.0
// ==================================================================

//+------------------------------------------------------------------+
//| Função principal de preenchimento de buffers - CORRIGIDA        |
//+------------------------------------------------------------------+
void PreencheSinalBuffers(
    int limit,
    PatternType padrao_selecionado,
    bool inverter_padrao,
    bool ativar_filtro_volatilidade,
    bool bb_apenas_consolidacao,
    double atr_min,
    double atr_max,
    bool ativar_filtro_tendencia,
    ENUM_POSICAO_SETA posicao_seta
)
{
    AUTO_PERFORMANCE_LOG("BufferManager", "PreencheSinalBuffers");
    
    Logger::Debug("BufferManager", "Iniciando preenchimento de buffers", 
                 "Limit: " + IntegerToString(limit) + 
                 ", Padrão: " + EnumToString(padrao_selecionado));
    
    // Validação de entrada
    if(!ValidateBufferInputs(limit, padrao_selecionado))
    {
        Logger::Error("BufferManager", "Validação de entrada falhou");
        return;
    }
    
    // Verifica estado do cache
    if(!g_cache_initialized || g_cache_size < 10)
    {
        Logger::Warning("BufferManager", "Cache não inicializado ou muito pequeno");
        return;
    }
    
    // Obtém referência aos buffers externos
    extern double bufferCall[];
    extern double bufferPut[];
    
    // Calcula histórico necessário para o padrão
    int needed_history = GetNeededHistoryForPattern(padrao_selecionado);
    
    // Processa cada barra no limite especificado
    for(int i = 0; i < limit; i++)
    {
        // Verifica se há histórico suficiente
        if(i + needed_history >= g_cache_size)
        {
            Logger::Debug("BufferManager", "Histórico insuficiente", 
                         "Shift: " + IntegerToString(i) + 
                         ", Necessário: " + IntegerToString(needed_history));
            continue;
        }
        
        // Inicializa buffers para esta posição
        bufferCall[i] = EMPTY_VALUE;
        bufferPut[i] = EMPTY_VALUE;
        
        // Detecta padrão
        DetectionResult result = DetectPatternAtShift(i, padrao_selecionado, 
                                                     inverter_padrao, needed_history);
        
        if(!result.should_plot)
            continue;
        
        // Aplica filtros de mercado
        if(!ApplyMarketFilters(i, ativar_filtro_volatilidade, bb_apenas_consolidacao,
                              atr_min, atr_max, ativar_filtro_tendencia))
        {
            Logger::Debug("BufferManager", "Sinal filtrado", 
                         "Shift: " + IntegerToString(i));
            continue;
        }
        
        // Calcula coordenadas de plotagem
        SignalCoordinate coord = CalculateSignalCoordinate(i, result.direction, posicao_seta);
        
        if(!IsValidSignalCoordinate(coord))
        {
            Logger::Warning("BufferManager", "Coordenadas inválidas", 
                           "Shift: " + IntegerToString(i) + " | " + coord.debug_info);
            continue;
        }
        
        // Plota sinal no buffer apropriado
        if(PlotSignalInBuffer(coord, result.direction, bufferCall, bufferPut))
        {
            Logger::LogSignal(result.direction > 0 ? "CALL" : "PUT", 
                             result.pattern_used, result.was_inverted, 
                             coord.plot_price, coord.debug_info);
            
            IncrementCounter(g_signals_generated_count);
        }
    }
    
    Logger::Debug("BufferManager", "Preenchimento de buffers concluído");
}

//+------------------------------------------------------------------+
//| Valida parâmetros de entrada para buffers                       |
//+------------------------------------------------------------------+
bool ValidateBufferInputs(int limit, PatternType pattern)
{
    if(limit < 0 || limit > 1000)
    {
        Logger::Error("BufferManager", "Limit fora do intervalo válido", 
                     "Valor: " + IntegerToString(limit));
        return false;
    }
    
    if(!IsValidPatternType(pattern))
    {
        Logger::Error("BufferManager", "Tipo de padrão inválido", 
                     "Padrão: " + EnumToString(pattern));
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Detecta padrão em um shift específico                           |
//+------------------------------------------------------------------+
DetectionResult DetectPatternAtShift(int shift, PatternType pattern, 
                                    bool inverted, int needed_history)
{
    DetectionResult result;
    result.should_plot = false;
    result.direction = 0;
    result.pattern_used = pattern;
    result.was_inverted = inverted;
    result.detection_info = "";
    result.detection_time = iTime(_Symbol, _Period, shift);
    
    // Verifica se há dados suficientes
    if(!ValidateShiftAccess(shift, needed_history, "DetectPatternAtShift"))
    {
        result.detection_info = "Acesso inválido ao shift";
        return result;
    }
    
    // Detecta padrão usando o motor de padrões
    bool pattern_detected = false;
    int pattern_direction = 0;
    
    switch(pattern)
    {
        case PatternMHI1_3C_Minoria:
            pattern_detected = DetectMHI1_3C_Minoria(shift, pattern_direction);
            break;
        case PatternMHI2_3C_Confirmado:
            pattern_detected = DetectMHI2_3C_Confirmado(shift, pattern_direction);
            break;
        case PatternMHI3_Unanime_Base:
            pattern_detected = DetectMHI3_Unanime_Base(shift, pattern_direction);
            break;
        case PatternThreeInARow_Base:
            pattern_detected = DetectThreeInARow_Base(shift, pattern_direction);
            break;
        case PatternFiveInARow_Base:
            pattern_detected = DetectFiveInARow_Base(shift, pattern_direction);
            break;
        case PatternC3_SeguirCor:
            pattern_detected = DetectC3_SeguirCor(shift, pattern_direction);
            break;
        // Adicione outros padrões conforme necessário
        default:
            Logger::Warning("BufferManager", "Padrão não implementado", 
                           "Padrão: " + EnumToString(pattern));
            result.detection_info = "Padrão não implementado";
            return result;
    }
    
    if(pattern_detected)
    {
        // Aplica inversão se necessário
        if(inverted)
        {
            pattern_direction = -pattern_direction;
            result.detection_info = "Padrão detectado (invertido)";
        }
        else
        {
            result.detection_info = "Padrão detectado";
        }
        
        result.should_plot = true;
        result.direction = pattern_direction;
        
        Logger::Debug("BufferManager", "Padrão detectado", 
                     "Shift: " + IntegerToString(shift) + 
                     ", Direção: " + IntegerToString(pattern_direction) + 
                     ", Invertido: " + BoolToString(inverted));
    }
    else
    {
        result.detection_info = "Padrão não detectado";
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| Aplica filtros de mercado                                       |
//+------------------------------------------------------------------+
bool ApplyMarketFilters(int shift, bool volatility_filter, bool bb_consolidation,
                       double atr_min, double atr_max, bool trend_filter)
{
    // Se nenhum filtro está ativo, permite o sinal
    if(!volatility_filter && !bb_consolidation && !trend_filter)
        return true;
    
    // Filtro de volatilidade
    if(volatility_filter)
    {
        if(!ValidateShiftAccess(shift, 0, "ApplyMarketFilters"))
            return false;
        
        if(shift >= ArraySize(g_cache_atr_values))
            return false;
        
        double atr_value = g_cache_atr_values[shift];
        
        if(!MathIsValidNumber(atr_value) || atr_value < atr_min || atr_value > atr_max)
        {
            Logger::Debug("BufferManager", "Filtro de volatilidade rejeitou sinal", 
                         "ATR: " + DoubleToString(atr_value, 5) + 
                         ", Min: " + DoubleToString(atr_min, 5) + 
                         ", Max: " + DoubleToString(atr_max, 5));
            return false;
        }
    }
    
    // Filtro de consolidação (Bollinger Bands)
    if(bb_consolidation)
    {
        if(!ValidateShiftAccess(shift, 0, "ApplyMarketFilters"))
            return false;
        
        if(shift >= ArraySize(g_cache_bb_upper) || shift >= ArraySize(g_cache_bb_lower))
            return false;
        
        double bb_upper = g_cache_bb_upper[shift];
        double bb_lower = g_cache_bb_lower[shift];
        double current_price = iClose(_Symbol, _Period, shift);
        
        if(!MathIsValidNumber(bb_upper) || !MathIsValidNumber(bb_lower) || current_price == 0)
            return false;
        
        double bb_width = bb_upper - bb_lower;
        double bb_middle = (bb_upper + bb_lower) / 2.0;
        double price_position = MathAbs(current_price - bb_middle) / (bb_width / 2.0);
        
        // Considera consolidação se o preço está próximo ao centro das bandas
        if(price_position > 0.5) // Mais de 50% da largura das bandas
        {
            Logger::Debug("BufferManager", "Filtro de consolidação rejeitou sinal", 
                         "Posição: " + DoubleToString(price_position, 2));
            return false;
        }
    }
    
    // Filtro de tendência (usando média móvel se disponível)
    if(trend_filter && IsValidIndicatorHandle(g_ma_handle))
    {
        if(!ValidateShiftAccess(shift, 1, "ApplyMarketFilters"))
            return false;
        
        if(shift >= ArraySize(g_cache_ma_values))
            return false;
        
        double ma_current = g_cache_ma_values[shift];
        double ma_previous = g_cache_ma_values[shift + 1];
        
        if(!MathIsValidNumber(ma_current) || !MathIsValidNumber(ma_previous))
            return false;
        
        // Verifica se há tendência clara
        double ma_diff = ma_current - ma_previous;
        double min_trend = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 5;
        
        if(MathAbs(ma_diff) < min_trend)
        {
            Logger::Debug("BufferManager", "Filtro de tendência rejeitou sinal", 
                         "Diferença MA: " + DoubleToString(ma_diff, _Digits));
            return false;
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Plota sinal no buffer apropriado                                |
//+------------------------------------------------------------------+
bool PlotSignalInBuffer(const SignalCoordinate &coord, int direction, 
                       double &call_buffer[], double &put_buffer[])
{
    if(!IsValidSignalCoordinate(coord))
    {
        Logger::Warning("BufferManager", "Tentativa de plotar com coordenadas inválidas");
        return false;
    }
    
    // Verifica limites do buffer
    int buffer_size = ArraySize(call_buffer);
    if(coord.plot_shift >= buffer_size || coord.plot_shift < 0)
    {
        Logger::Warning("BufferManager", "Shift de plotagem fora dos limites do buffer", 
                       "Shift: " + IntegerToString(coord.plot_shift) + 
                       ", Tamanho: " + IntegerToString(buffer_size));
        return false;
    }
    
    // Plota no buffer apropriado
    if(direction > 0) // CALL
    {
        call_buffer[coord.plot_shift] = coord.plot_price;
        put_buffer[coord.plot_shift] = EMPTY_VALUE;
        
        Logger::Debug("BufferManager", "Sinal CALL plotado", 
                     "Shift: " + IntegerToString(coord.plot_shift) + 
                     ", Preço: " + DoubleToString(coord.plot_price, _Digits));
    }
    else if(direction < 0) // PUT
    {
        put_buffer[coord.plot_shift] = coord.plot_price;
        call_buffer[coord.plot_shift] = EMPTY_VALUE;
        
        Logger::Debug("BufferManager", "Sinal PUT plotado", 
                     "Shift: " + IntegerToString(coord.plot_shift) + 
                     ", Preço: " + DoubleToString(coord.plot_price, _Digits));
    }
    else
    {
        Logger::Warning("BufferManager", "Direção de sinal inválida", 
                       "Direção: " + IntegerToString(direction));
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Limpa buffers de sinais                                         |
//+------------------------------------------------------------------+
void ClearSignalBuffers(double &call_buffer[], double &put_buffer[], int size = -1)
{
    if(size == -1)
    {
        size = MathMin(ArraySize(call_buffer), ArraySize(put_buffer));
    }
    
    for(int i = 0; i < size; i++)
    {
        call_buffer[i] = EMPTY_VALUE;
        put_buffer[i] = EMPTY_VALUE;
    }
    
    Logger::Debug("BufferManager", "Buffers de sinais limpos", 
                 "Tamanho: " + IntegerToString(size));
}

//+------------------------------------------------------------------+
//| Conta sinais ativos nos buffers                                 |
//+------------------------------------------------------------------+
int CountActiveSignals(const double &call_buffer[], const double &put_buffer[], 
                      int lookback = 100)
{
    int count = 0;
    int size = MathMin(ArraySize(call_buffer), ArraySize(put_buffer));
    int limit = MathMin(lookback, size);
    
    for(int i = 0; i < limit; i++)
    {
        if(call_buffer[i] != EMPTY_VALUE || put_buffer[i] != EMPTY_VALUE)
        {
            count++;
        }
    }
    
    return count;
}

//+------------------------------------------------------------------+
//| Obtém último sinal dos buffers                                  |
//+------------------------------------------------------------------+
bool GetLastSignal(const double &call_buffer[], const double &put_buffer[], 
                  int &signal_shift, int &signal_direction, double &signal_price)
{
    int size = MathMin(ArraySize(call_buffer), ArraySize(put_buffer));
    
    for(int i = 0; i < size; i++)
    {
        if(call_buffer[i] != EMPTY_VALUE)
        {
            signal_shift = i;
            signal_direction = 1; // CALL
            signal_price = call_buffer[i];
            return true;
        }
        
        if(put_buffer[i] != EMPTY_VALUE)
        {
            signal_shift = i;
            signal_direction = -1; // PUT
            signal_price = put_buffer[i];
            return true;
        }
    }
    
    return false; // Nenhum sinal encontrado
}

//+------------------------------------------------------------------+
//| Valida consistência dos buffers                                 |
//+------------------------------------------------------------------+
bool ValidateBufferConsistency(const double &call_buffer[], const double &put_buffer[])
{
    int call_size = ArraySize(call_buffer);
    int put_size = ArraySize(put_buffer);
    
    if(call_size != put_size)
    {
        Logger::Error("BufferManager", "Tamanhos de buffer inconsistentes", 
                     "Call: " + IntegerToString(call_size) + 
                     ", Put: " + IntegerToString(put_size));
        return false;
    }
    
    // Verifica se não há sinais conflitantes na mesma posição
    int conflicts = 0;
    for(int i = 0; i < call_size; i++)
    {
        if(call_buffer[i] != EMPTY_VALUE && put_buffer[i] != EMPTY_VALUE)
        {
            conflicts++;
            Logger::Warning("BufferManager", "Conflito de sinais detectado", 
                           "Shift: " + IntegerToString(i));
        }
    }
    
    if(conflicts > 0)
    {
        Logger::Warning("BufferManager", "Conflitos de sinais encontrados", 
                       "Total: " + IntegerToString(conflicts));
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Função de diagnóstico dos buffers                               |
//+------------------------------------------------------------------+
void DiagnosticBuffers(const double &call_buffer[], const double &put_buffer[])
{
    int call_size = ArraySize(call_buffer);
    int put_size = ArraySize(put_buffer);
    
    Logger::Info("BufferManager", "=== DIAGNÓSTICO DOS BUFFERS ===");
    Logger::Info("BufferManager", "Tamanho Call Buffer: " + IntegerToString(call_size));
    Logger::Info("BufferManager", "Tamanho Put Buffer: " + IntegerToString(put_size));
    
    int active_calls = 0;
    int active_puts = 0;
    
    for(int i = 0; i < MathMin(call_size, put_size); i++)
    {
        if(call_buffer[i] != EMPTY_VALUE) active_calls++;
        if(put_buffer[i] != EMPTY_VALUE) active_puts++;
    }
    
    Logger::Info("BufferManager", "Sinais CALL ativos: " + IntegerToString(active_calls));
    Logger::Info("BufferManager", "Sinais PUT ativos: " + IntegerToString(active_puts));
    Logger::Info("BufferManager", "Total de sinais: " + IntegerToString(active_calls + active_puts));
    
    // Verifica último sinal
    int last_shift, last_direction;
    double last_price;
    if(GetLastSignal(call_buffer, put_buffer, last_shift, last_direction, last_price))
    {
        Logger::Info("BufferManager", "Último sinal: " + 
                    (last_direction > 0 ? "CALL" : "PUT") + 
                    " em shift " + IntegerToString(last_shift) + 
                    " preço " + DoubleToString(last_price, _Digits));
    }
    else
    {
        Logger::Info("BufferManager", "Nenhum sinal ativo encontrado");
    }
    
    Logger::Info("BufferManager", "=== FIM DO DIAGNÓSTICO ===");
}

//+------------------------------------------------------------------+
//| Função de otimização de buffers                                 |
//+------------------------------------------------------------------+
void OptimizeBuffers(double &call_buffer[], double &put_buffer[], int keep_last_n = 500)
{
    int size = MathMin(ArraySize(call_buffer), ArraySize(put_buffer));
    
    if(size <= keep_last_n)
        return; // Não precisa otimizar
    
    Logger::Info("BufferManager", "Otimizando buffers", 
                "Tamanho atual: " + IntegerToString(size) + 
                ", Manter últimos: " + IntegerToString(keep_last_n));
    
    // Limpa sinais antigos (mantém apenas os últimos keep_last_n)
    for(int i = keep_last_n; i < size; i++)
    {
        call_buffer[i] = EMPTY_VALUE;
        put_buffer[i] = EMPTY_VALUE;
    }
    
    Logger::Info("BufferManager", "Otimização de buffers concluída");
}

#endif // BUFFERMANAGER_MQH

