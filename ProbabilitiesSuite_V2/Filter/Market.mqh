//+------------------------------------------------------------------+
//|                                    Filter/Market.mqh |
//|                        Copyright 2024, Quant Genius (Refactoring) |
//|                                      https://www.google.com |
//|                                    VERSÃO CORRIGIDA v2.0        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quant Genius (Refactoring)"
#property link      "https://www.google.com"

#ifndef FILTER_MARKET_MQH
#define FILTER_MARKET_MQH

#include "../Core/Defines.mqh"
#include "../Core/Globals.mqh"
#include "../Core/Utilities.mqh"
#include "../Core/Logger.mqh"

// ==================================================================
// FILTROS DE MERCADO CORRIGIDOS - VERSÃO 2.0
// ==================================================================

//+------------------------------------------------------------------+
//| CORREÇÃO #1: Filtro de Volatilidade Robusto                     |
//+------------------------------------------------------------------+
bool FiltroVolatilidadeRobusto(int shift, double atr_min, double atr_max)
{
    // Validação de entrada
    if(!ValidateInputParameter(atr_min, 0.0, 1.0, "atr_min"))
        return false;
    
    if(!ValidateInputParameter(atr_max, atr_min, 1.0, "atr_max"))
        return false;
    
    // Validação de acesso ao cache
    if(!ValidateShiftAccess(shift, 0, "FiltroVolatilidadeRobusto"))
        return false;
    
    if(shift >= ArraySize(g_cache_atr_values))
    {
        Logger::Warning("Market", "ATR não disponível para shift", 
                       "Shift: " + IntegerToString(shift));
        return false;
    }
    
    // Obtém valor ATR
    double atr_value = g_cache_atr_values[shift];
    
    // Validação do valor ATR
    if(!MathIsValidNumber(atr_value) || atr_value < 0)
    {
        Logger::Warning("Market", "Valor ATR inválido", 
                       "Shift: " + IntegerToString(shift) + 
                       ", ATR: " + DoubleToString(atr_value, 5));
        return false;
    }
    
    // Aplica filtro
    bool passed = (atr_value >= atr_min && atr_value <= atr_max);
    
    Logger::Debug("Market", "Filtro de volatilidade", 
                 "Shift: " + IntegerToString(shift) + 
                 ", ATR: " + DoubleToString(atr_value, 5) + 
                 ", Min: " + DoubleToString(atr_min, 5) + 
                 ", Max: " + DoubleToString(atr_max, 5) + 
                 ", Resultado: " + BoolToString(passed));
    
    return passed;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #2: Filtro de Consolidação (Bollinger Bands) Robusto   |
//+------------------------------------------------------------------+
bool FiltroConsolidacaoRobusto(int shift, double threshold_percent = 50.0)
{
    // Validação de entrada
    if(!ValidateInputParameter(threshold_percent, 0.0, 100.0, "threshold_percent"))
        return false;
    
    // Validação de acesso ao cache
    if(!ValidateShiftAccess(shift, 0, "FiltroConsolidacaoRobusto"))
        return false;
    
    if(shift >= ArraySize(g_cache_bb_upper) || 
       shift >= ArraySize(g_cache_bb_lower) || 
       shift >= ArraySize(g_cache_bb_middle))
    {
        Logger::Warning("Market", "Dados BB não disponíveis para shift", 
                       "Shift: " + IntegerToString(shift));
        return false;
    }
    
    // Obtém valores das Bandas de Bollinger
    double bb_upper = g_cache_bb_upper[shift];
    double bb_lower = g_cache_bb_lower[shift];
    double bb_middle = g_cache_bb_middle[shift];
    double current_price = iClose(_Symbol, _Period, shift);
    
    // Validação dos valores
    if(!MathIsValidNumber(bb_upper) || !MathIsValidNumber(bb_lower) || 
       !MathIsValidNumber(bb_middle) || current_price == 0)
    {
        Logger::Warning("Market", "Valores BB inválidos", 
                       "Shift: " + IntegerToString(shift));
        return false;
    }
    
    // Verifica consistência das bandas
    if(bb_upper <= bb_middle || bb_middle <= bb_lower)
    {
        Logger::Warning("Market", "Bandas BB inconsistentes", 
                       "Shift: " + IntegerToString(shift) + 
                       ", Upper: " + DoubleToString(bb_upper, _Digits) + 
                       ", Middle: " + DoubleToString(bb_middle, _Digits) + 
                       ", Lower: " + DoubleToString(bb_lower, _Digits));
        return false;
    }
    
    // Calcula posição do preço dentro das bandas
    double bb_width = bb_upper - bb_lower;
    double price_distance_from_middle = MathAbs(current_price - bb_middle);
    double max_distance = bb_width / 2.0;
    
    if(max_distance == 0)
    {
        Logger::Warning("Market", "Largura das bandas BB é zero", 
                       "Shift: " + IntegerToString(shift));
        return false;
    }
    
    double price_position_percent = (price_distance_from_middle / max_distance) * 100.0;
    
    // Considera consolidação se o preço está próximo ao centro
    bool is_consolidation = (price_position_percent <= threshold_percent);
    
    Logger::Debug("Market", "Filtro de consolidação", 
                 "Shift: " + IntegerToString(shift) + 
                 ", Posição: " + DoubleToString(price_position_percent, 1) + "%" + 
                 ", Threshold: " + DoubleToString(threshold_percent, 1) + "%" + 
                 ", Consolidação: " + BoolToString(is_consolidation));
    
    return is_consolidation;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #3: Filtro de Tendência Robusto                        |
//+------------------------------------------------------------------+
bool FiltroTendenciaRobusto(int shift, int lookback_periods = 5, double min_trend_strength = 0.0001)
{
    // Validação de entrada
    if(!ValidateInputParameter(lookback_periods, 2, 20, "lookback_periods"))
        return false;
    
    if(!ValidateInputParameter(min_trend_strength, 0.0, 0.01, "min_trend_strength"))
        return false;
    
    // Validação de acesso ao cache
    if(!ValidateShiftAccess(shift, lookback_periods, "FiltroTendenciaRobusto"))
        return false;
    
    // Verifica se média móvel está disponível
    if(!IsValidIndicatorHandle(g_ma_handle) || ArraySize(g_cache_ma_values) == 0)
    {
        Logger::Debug("Market", "Média móvel não disponível para filtro de tendência");
        return true; // Permite sinal se MA não estiver configurada
    }
    
    if(shift + lookback_periods >= ArraySize(g_cache_ma_values))
    {
        Logger::Warning("Market", "Dados MA insuficientes para filtro de tendência", 
                       "Shift: " + IntegerToString(shift) + 
                       ", Lookback: " + IntegerToString(lookback_periods));
        return false;
    }
    
    // Calcula força da tendência usando média móvel
    double ma_current = g_cache_ma_values[shift];
    double ma_past = g_cache_ma_values[shift + lookback_periods];
    
    // Validação dos valores
    if(!MathIsValidNumber(ma_current) || !MathIsValidNumber(ma_past))
    {
        Logger::Warning("Market", "Valores MA inválidos para filtro de tendência", 
                       "Shift: " + IntegerToString(shift));
        return false;
    }
    
    // Calcula diferença e força da tendência
    double ma_diff = ma_current - ma_past;
    double trend_strength = MathAbs(ma_diff);
    
    // Normaliza pela volatilidade se ATR estiver disponível
    if(shift < ArraySize(g_cache_atr_values))
    {
        double atr_value = g_cache_atr_values[shift];
        if(MathIsValidNumber(atr_value) && atr_value > 0)
        {
            trend_strength = trend_strength / atr_value;
        }
    }
    
    bool has_trend = (trend_strength >= min_trend_strength);
    
    Logger::Debug("Market", "Filtro de tendência", 
                 "Shift: " + IntegerToString(shift) + 
                 ", MA Diff: " + DoubleToString(ma_diff, _Digits) + 
                 ", Força: " + DoubleToString(trend_strength, 5) + 
                 ", Min: " + DoubleToString(min_trend_strength, 5) + 
                 ", Tem Tendência: " + BoolToString(has_trend));
    
    return has_trend;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #4: Filtro de Horário de Negociação                    |
//+------------------------------------------------------------------+
bool FiltroHorarioNegociacao(datetime start_hour = 8, datetime end_hour = 18, bool use_server_time = true)
{
    datetime current_time = use_server_time ? TimeCurrent() : TimeLocal();
    
    MqlDateTime time_struct;
    TimeToStruct(current_time, time_struct);
    
    int current_hour = time_struct.hour;
    
    // Validação de horários
    if(start_hour < 0 || start_hour > 23 || end_hour < 0 || end_hour > 23)
    {
        Logger::Warning("Market", "Horários de negociação inválidos", 
                       "Start: " + IntegerToString(start_hour) + 
                       ", End: " + IntegerToString(end_hour));
        return true; // Permite se configuração inválida
    }
    
    bool is_trading_hours;
    
    if(start_hour <= end_hour)
    {
        // Horário normal (ex: 8h às 18h)
        is_trading_hours = (current_hour >= start_hour && current_hour <= end_hour);
    }
    else
    {
        // Horário que cruza meia-noite (ex: 22h às 6h)
        is_trading_hours = (current_hour >= start_hour || current_hour <= end_hour);
    }
    
    Logger::Debug("Market", "Filtro de horário", 
                 "Hora atual: " + IntegerToString(current_hour) + 
                 ", Permitido: " + IntegerToString(start_hour) + "-" + IntegerToString(end_hour) + 
                 ", Resultado: " + BoolToString(is_trading_hours));
    
    return is_trading_hours;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #5: Filtro de Spread                                   |
//+------------------------------------------------------------------+
bool FiltroSpread(double max_spread_points = 3.0)
{
    // Validação de entrada
    if(!ValidateInputParameter(max_spread_points, 0.0, 100.0, "max_spread_points"))
        return false;
    
    // Obtém spread atual
    double spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
    double point_value = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    
    if(point_value == 0)
    {
        Logger::Warning("Market", "Point value inválido para símbolo", 
                       "Símbolo: " + _Symbol);
        return true; // Permite se não conseguir obter dados
    }
    
    double spread_points = spread * point_value / _Point;
    
    bool spread_ok = (spread_points <= max_spread_points);
    
    Logger::Debug("Market", "Filtro de spread", 
                 "Spread: " + DoubleToString(spread_points, 1) + " pontos" + 
                 ", Máximo: " + DoubleToString(max_spread_points, 1) + 
                 ", Resultado: " + BoolToString(spread_ok));
    
    return spread_ok;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #6: Filtro de Volume (se disponível)                   |
//+------------------------------------------------------------------+
bool FiltroVolume(int shift, double min_volume_ratio = 0.5)
{
    // Validação de entrada
    if(!ValidateInputParameter(min_volume_ratio, 0.1, 10.0, "min_volume_ratio"))
        return false;
    
    // Validação de shift
    if(!ValidateShiftAccess(shift, 20, "FiltroVolume"))
        return false;
    
    // Obtém volume atual
    long current_volume = iVolume(_Symbol, _Period, shift);
    
    if(current_volume <= 0)
    {
        Logger::Debug("Market", "Volume não disponível ou zero", 
                     "Shift: " + IntegerToString(shift));
        return true; // Permite se volume não estiver disponível
    }
    
    // Calcula volume médio dos últimos 20 períodos
    long total_volume = 0;
    int valid_periods = 0;
    
    for(int i = shift + 1; i <= shift + 20; i++)
    {
        long vol = iVolume(_Symbol, _Period, i);
        if(vol > 0)
        {
            total_volume += vol;
            valid_periods++;
        }
    }
    
    if(valid_periods < 10)
    {
        Logger::Debug("Market", "Dados de volume insuficientes");
        return true; // Permite se dados insuficientes
    }
    
    double avg_volume = (double)total_volume / valid_periods;
    double volume_ratio = current_volume / avg_volume;
    
    bool volume_ok = (volume_ratio >= min_volume_ratio);
    
    Logger::Debug("Market", "Filtro de volume", 
                 "Volume atual: " + IntegerToString(current_volume) + 
                 ", Média: " + DoubleToString(avg_volume, 0) + 
                 ", Ratio: " + DoubleToString(volume_ratio, 2) + 
                 ", Mínimo: " + DoubleToString(min_volume_ratio, 2) + 
                 ", Resultado: " + BoolToString(volume_ok));
    
    return volume_ok;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #7: Filtro Combinado de Mercado                        |
//+------------------------------------------------------------------+
bool FiltroCombinadoMercado(
    int shift,
    bool usar_volatilidade,
    double atr_min,
    double atr_max,
    bool usar_consolidacao,
    double consolidacao_threshold,
    bool usar_tendencia,
    int tendencia_lookback,
    double tendencia_min_strength,
    bool usar_horario,
    int horario_start,
    int horario_end,
    bool usar_spread,
    double spread_max,
    bool usar_volume,
    double volume_min_ratio
)
{
    Logger::Debug("Market", "Aplicando filtro combinado", 
                 "Shift: " + IntegerToString(shift));
    
    // Contador de filtros aplicados e aprovados
    int filtros_aplicados = 0;
    int filtros_aprovados = 0;
    
    // Filtro de volatilidade
    if(usar_volatilidade)
    {
        filtros_aplicados++;
        if(FiltroVolatilidadeRobusto(shift, atr_min, atr_max))
        {
            filtros_aprovados++;
            Logger::Debug("Market", "Filtro de volatilidade: APROVADO");
        }
        else
        {
            Logger::Debug("Market", "Filtro de volatilidade: REJEITADO");
            return false; // Falha em qualquer filtro rejeita o sinal
        }
    }
    
    // Filtro de consolidação
    if(usar_consolidacao)
    {
        filtros_aplicados++;
        if(FiltroConsolidacaoRobusto(shift, consolidacao_threshold))
        {
            filtros_aprovados++;
            Logger::Debug("Market", "Filtro de consolidação: APROVADO");
        }
        else
        {
            Logger::Debug("Market", "Filtro de consolidação: REJEITADO");
            return false;
        }
    }
    
    // Filtro de tendência
    if(usar_tendencia)
    {
        filtros_aplicados++;
        if(FiltroTendenciaRobusto(shift, tendencia_lookback, tendencia_min_strength))
        {
            filtros_aprovados++;
            Logger::Debug("Market", "Filtro de tendência: APROVADO");
        }
        else
        {
            Logger::Debug("Market", "Filtro de tendência: REJEITADO");
            return false;
        }
    }
    
    // Filtro de horário
    if(usar_horario)
    {
        filtros_aplicados++;
        if(FiltroHorarioNegociacao(horario_start, horario_end))
        {
            filtros_aprovados++;
            Logger::Debug("Market", "Filtro de horário: APROVADO");
        }
        else
        {
            Logger::Debug("Market", "Filtro de horário: REJEITADO");
            return false;
        }
    }
    
    // Filtro de spread
    if(usar_spread)
    {
        filtros_aplicados++;
        if(FiltroSpread(spread_max))
        {
            filtros_aprovados++;
            Logger::Debug("Market", "Filtro de spread: APROVADO");
        }
        else
        {
            Logger::Debug("Market", "Filtro de spread: REJEITADO");
            return false;
        }
    }
    
    // Filtro de volume
    if(usar_volume)
    {
        filtros_aplicados++;
        if(FiltroVolume(shift, volume_min_ratio))
        {
            filtros_aprovados++;
            Logger::Debug("Market", "Filtro de volume: APROVADO");
        }
        else
        {
            Logger::Debug("Market", "Filtro de volume: REJEITADO");
            return false;
        }
    }
    
    Logger::Info("Market", "Filtro combinado concluído", 
                "Aplicados: " + IntegerToString(filtros_aplicados) + 
                ", Aprovados: " + IntegerToString(filtros_aprovados) + 
                ", Resultado: APROVADO");
    
    return true; // Todos os filtros aplicados foram aprovados
}

//+------------------------------------------------------------------+
//| Função de diagnóstico dos filtros de mercado                    |
//+------------------------------------------------------------------+
void DiagnosticMarketFilters(int test_shift = 1)
{
    Logger::Info("Market", "=== DIAGNÓSTICO DOS FILTROS DE MERCADO ===");
    
    if(!g_cache_initialized)
    {
        Logger::Warning("Market", "Cache não inicializado para diagnóstico");
        return;
    }
    
    Logger::Info("Market", "Testando filtros no shift: " + IntegerToString(test_shift));
    
    // Testa filtro de volatilidade
    if(test_shift < ArraySize(g_cache_atr_values))
    {
        double atr = g_cache_atr_values[test_shift];
        Logger::Info("Market", "ATR[" + IntegerToString(test_shift) + "]: " + DoubleToString(atr, 5));
        
        bool vol_result = FiltroVolatilidadeRobusto(test_shift, 0.0001, 0.0005);
        Logger::Info("Market", "Filtro volatilidade (0.0001-0.0005): " + BoolToString(vol_result));
    }
    
    // Testa filtro de consolidação
    if(test_shift < ArraySize(g_cache_bb_upper))
    {
        bool cons_result = FiltroConsolidacaoRobusto(test_shift, 50.0);
        Logger::Info("Market", "Filtro consolidação (50%): " + BoolToString(cons_result));
    }
    
    // Testa filtro de tendência
    bool trend_result = FiltroTendenciaRobusto(test_shift, 5, 0.0001);
    Logger::Info("Market", "Filtro tendência (5 períodos): " + BoolToString(trend_result));
    
    // Testa filtro de horário
    bool time_result = FiltroHorarioNegociacao(8, 18);
    Logger::Info("Market", "Filtro horário (8h-18h): " + BoolToString(time_result));
    
    // Testa filtro de spread
    bool spread_result = FiltroSpread(3.0);
    Logger::Info("Market", "Filtro spread (3.0 pontos): " + BoolToString(spread_result));
    
    Logger::Info("Market", "=== FIM DO DIAGNÓSTICO ===");
}

//+------------------------------------------------------------------+
//| Função para obter configuração atual dos filtros               |
//+------------------------------------------------------------------+
FilterConfig GetCurrentFilterConfig()
{
    return g_filter_config;
}

//+------------------------------------------------------------------+
//| Função para atualizar configuração dos filtros                 |
//+------------------------------------------------------------------+
void UpdateFilterConfiguration(const FilterConfig &new_config)
{
    g_filter_config = new_config;
    Logger::Info("Market", "Configuração de filtros atualizada");
}

#endif // FILTER_MARKET_MQH

