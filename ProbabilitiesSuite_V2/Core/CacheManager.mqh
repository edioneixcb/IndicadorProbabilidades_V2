//+------------------------------------------------------------------+
//|                                    Core/CacheManager.mqh |
//|                        Copyright 2024, Quant Genius (Refactoring) |
//|                                      https://www.google.com |
//|                                    VERSÃO CORRIGIDA v2.0        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quant Genius (Refactoring)"
#property link      "https://www.google.com"

#ifndef CORE_CACHEMANAGER_MQH
#define CORE_CACHEMANAGER_MQH

#include "Defines.mqh"
#include "Globals.mqh"
#include "Utilities.mqh"
#include "Logger.mqh"
#include "StateManager.mqh"

// ==================================================================
// GERENCIADOR DE CACHE ROBUSTO - CORREÇÃO CRÍTICA
// ==================================================================

//+------------------------------------------------------------------+
//| Função principal de atualização de cache - VERSÃO CORRIGIDA     |
//+------------------------------------------------------------------+
bool AtualizarCachesDeDadosRobusta(
    int velas_para_analise,
    bool ativar_filtro_volatilidade,
    int periodo_atr,
    double multiplo_bb,
    int periodo_bb,
    bool usar_media_movel,
    int periodo_ma,
    ENUM_MA_METHOD metodo_ma
)
{
    AUTO_PERFORMANCE_LOG("CacheManager", "AtualizarCachesDeDadosRobusta");
    
    Logger::Info("CacheManager", "Iniciando atualização robusta de cache", 
                 "Velas: " + IntegerToString(velas_para_analise));
    
    StateManager* state = StateManager::GetInstance();
    if(state == NULL)
    {
        Logger::Critical("CacheManager", "StateManager não disponível");
        return false;
    }
    
    // Validação de parâmetros
    if(!ValidateInputParameter(velas_para_analise, MIN_CACHE_SIZE, MAX_CACHE_SIZE, "velas_para_analise"))
        return false;
    
    if(!ValidateInputParameter(periodo_atr, 5, 100, "periodo_atr"))
        return false;
    
    if(!ValidateInputParameter(multiplo_bb, 1.0, 5.0, "multiplo_bb"))
        return false;
    
    if(!ValidateInputParameter(periodo_bb, 5, 100, "periodo_bb"))
        return false;
    
    // Verifica disponibilidade de dados
    int available_bars = Bars(_Symbol, _Period);
    if(available_bars < velas_para_analise)
    {
        Logger::Warning("CacheManager", "Dados insuficientes", 
                       "Disponível: " + IntegerToString(available_bars) + 
                       ", Solicitado: " + IntegerToString(velas_para_analise));
        velas_para_analise = available_bars - 10; // Margem de segurança
        
        if(velas_para_analise < MIN_CACHE_SIZE)
        {
            Logger::Error("CacheManager", "Dados insuficientes mesmo após ajuste");
            return false;
        }
    }
    
    // Inicialização de handles de indicadores
    if(!InitializeIndicatorHandles(periodo_atr, periodo_bb, multiplo_bb, 
                                  usar_media_movel, periodo_ma, metodo_ma))
    {
        Logger::Error("CacheManager", "Falha na inicialização de handles");
        return false;
    }
    
    // Aguarda dados dos indicadores
    if(!WaitForIndicatorData())
    {
        Logger::Error("CacheManager", "Timeout aguardando dados dos indicadores");
        return false;
    }
    
    // Redimensiona arrays de cache
    if(!ResizeCacheArrays(velas_para_analise))
    {
        Logger::Error("CacheManager", "Falha no redimensionamento de arrays");
        return false;
    }
    
    // Preenche cache de cores das velas
    if(!FillCandleColorsCache(velas_para_analise))
    {
        Logger::Error("CacheManager", "Falha no preenchimento de cores das velas");
        return false;
    }
    
    // Preenche cache de indicadores técnicos
    if(ativar_filtro_volatilidade)
    {
        if(!FillTechnicalIndicatorsCache(velas_para_analise))
        {
            Logger::Error("CacheManager", "Falha no preenchimento de indicadores técnicos");
            return false;
        }
    }
    
    // Valida integridade dos dados
    if(!ValidateCacheIntegrity(velas_para_analise))
    {
        Logger::Error("CacheManager", "Falha na validação de integridade");
        return false;
    }
    
    // Calcula hash de integridade
    string integrity_hash = CalculateSimpleHash(g_cache_candle_colors, 100);
    
    // Atualiza estado global
    g_cache_initialized = true;
    g_cache_size = velas_para_analise;
    g_cache_last_update = TimeCurrent();
    
    // Atualiza StateManager
    state.UpdateCacheState(true, velas_para_analise, "AtualizarCachesDeDadosRobusta");
    state.SetCacheIntegrityHash(integrity_hash, "AtualizarCachesDeDadosRobusta");
    
    // Atualiza configuração de filtros
    UpdateFilterConfig(ativar_filtro_volatilidade, periodo_atr, multiplo_bb, 
                      periodo_bb, usar_media_movel, periodo_ma, metodo_ma);
    
    Logger::LogCacheOperation("Atualização", true, velas_para_analise, 
                             "Hash: " + StringSubstr(integrity_hash, 0, 8));
    
    IncrementCounter(g_cache_updates_count);
    
    return true;
}

//+------------------------------------------------------------------+
//| Inicializa handles de indicadores técnicos                      |
//+------------------------------------------------------------------+
bool InitializeIndicatorHandles(int periodo_atr, int periodo_bb, double multiplo_bb,
                               bool usar_ma, int periodo_ma, ENUM_MA_METHOD metodo_ma)
{
    Logger::Debug("CacheManager", "Inicializando handles de indicadores");
    
    // Libera handles existentes
    ReleaseIndicatorHandles();
    
    // Cria handle ATR
    g_atr_handle = iATR(_Symbol, _Period, periodo_atr);
    if(!IsValidIndicatorHandle(g_atr_handle))
    {
        Logger::Error("CacheManager", "Falha ao criar handle ATR");
        return false;
    }
    
    // Cria handle Bollinger Bands
    g_bb_handle = iBands(_Symbol, _Period, periodo_bb, 0, multiplo_bb, PRICE_CLOSE);
    if(!IsValidIndicatorHandle(g_bb_handle))
    {
        Logger::Error("CacheManager", "Falha ao criar handle Bollinger Bands");
        return false;
    }
    
    // Cria handle Média Móvel se necessário
    if(usar_ma)
    {
        g_ma_handle = iMA(_Symbol, _Period, periodo_ma, 0, metodo_ma, PRICE_CLOSE);
        if(!IsValidIndicatorHandle(g_ma_handle))
        {
            Logger::Error("CacheManager", "Falha ao criar handle Média Móvel");
            return false;
        }
    }
    
    Logger::Debug("CacheManager", "Handles inicializados com sucesso");
    return true;
}

//+------------------------------------------------------------------+
//| Aguarda dados dos indicadores ficarem disponíveis               |
//+------------------------------------------------------------------+
bool WaitForIndicatorData()
{
    Logger::Debug("CacheManager", "Aguardando dados dos indicadores");
    
    int max_attempts = 50; // 5 segundos máximo
    int attempts = 0;
    
    while(attempts < max_attempts)
    {
        bool atr_ready = (BarsCalculated(g_atr_handle) > 0);
        bool bb_ready = (BarsCalculated(g_bb_handle) > 0);
        bool ma_ready = (g_ma_handle == INVALID_HANDLE || BarsCalculated(g_ma_handle) > 0);
        
        if(atr_ready && bb_ready && ma_ready)
        {
            Logger::Debug("CacheManager", "Dados dos indicadores disponíveis", 
                         "Tentativas: " + IntegerToString(attempts));
            return true;
        }
        
        Sleep(100);
        attempts++;
    }
    
    Logger::Error("CacheManager", "Timeout aguardando dados dos indicadores");
    return false;
}

//+------------------------------------------------------------------+
//| Redimensiona arrays de cache                                    |
//+------------------------------------------------------------------+
bool ResizeCacheArrays(int size)
{
    Logger::Debug("CacheManager", "Redimensionando arrays de cache", 
                 "Tamanho: " + IntegerToString(size));
    
    if(ArrayResize(g_cache_candle_colors, size) != size)
    {
        Logger::Error("CacheManager", "Falha ao redimensionar g_cache_candle_colors");
        return false;
    }
    
    if(ArrayResize(g_cache_atr_values, size) != size)
    {
        Logger::Error("CacheManager", "Falha ao redimensionar g_cache_atr_values");
        return false;
    }
    
    if(ArrayResize(g_cache_bb_upper, size) != size)
    {
        Logger::Error("CacheManager", "Falha ao redimensionar g_cache_bb_upper");
        return false;
    }
    
    if(ArrayResize(g_cache_bb_lower, size) != size)
    {
        Logger::Error("CacheManager", "Falha ao redimensionar g_cache_bb_lower");
        return false;
    }
    
    if(ArrayResize(g_cache_bb_middle, size) != size)
    {
        Logger::Error("CacheManager", "Falha ao redimensionar g_cache_bb_middle");
        return false;
    }
    
    if(ArrayResize(g_cache_ma_values, size) != size)
    {
        Logger::Error("CacheManager", "Falha ao redimensionar g_cache_ma_values");
        return false;
    }
    
    // Configura arrays como séries temporais
    ArraySetAsSeries(g_cache_candle_colors, true);
    ArraySetAsSeries(g_cache_atr_values, true);
    ArraySetAsSeries(g_cache_bb_upper, true);
    ArraySetAsSeries(g_cache_bb_lower, true);
    ArraySetAsSeries(g_cache_bb_middle, true);
    ArraySetAsSeries(g_cache_ma_values, true);
    
    Logger::Debug("CacheManager", "Arrays redimensionados com sucesso");
    return true;
}

//+------------------------------------------------------------------+
//| Preenche cache de cores das velas                               |
//+------------------------------------------------------------------+
bool FillCandleColorsCache(int size)
{
    Logger::Debug("CacheManager", "Preenchendo cache de cores das velas");
    
    for(int i = 0; i < size; i++)
    {
        double open_price = iOpen(_Symbol, _Period, i);
        double close_price = iClose(_Symbol, _Period, i);
        
        if(open_price == 0 || close_price == 0)
        {
            Logger::Warning("CacheManager", "Preço inválido detectado", 
                           "Shift: " + IntegerToString(i));
            g_cache_candle_colors[i] = VISUAL_DOJI;
            continue;
        }
        
        double diff = close_price - open_price;
        double threshold = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 2;
        
        if(diff > threshold)
            g_cache_candle_colors[i] = VISUAL_GREEN;
        else if(diff < -threshold)
            g_cache_candle_colors[i] = VISUAL_RED;
        else
            g_cache_candle_colors[i] = VISUAL_DOJI;
    }
    
    // Validação rápida
    if(!ValidateArray(g_cache_candle_colors, size, "g_cache_candle_colors"))
    {
        Logger::Error("CacheManager", "Validação falhou para cores das velas");
        return false;
    }
    
    Logger::Debug("CacheManager", "Cache de cores preenchido com sucesso");
    return true;
}

//+------------------------------------------------------------------+
//| Preenche cache de indicadores técnicos                          |
//+------------------------------------------------------------------+
bool FillTechnicalIndicatorsCache(int size)
{
    Logger::Debug("CacheManager", "Preenchendo cache de indicadores técnicos");
    
    // Copia dados ATR
    if(!SafeCopyBuffer(g_atr_handle, 0, 0, size, g_cache_atr_values))
    {
        Logger::Error("CacheManager", "Falha ao copiar dados ATR");
        return false;
    }
    
    // Copia dados Bollinger Bands
    if(!SafeCopyBuffer(g_bb_handle, 0, 0, size, g_cache_bb_upper))
    {
        Logger::Error("CacheManager", "Falha ao copiar banda superior BB");
        return false;
    }
    
    if(!SafeCopyBuffer(g_bb_handle, 1, 0, size, g_cache_bb_middle))
    {
        Logger::Error("CacheManager", "Falha ao copiar banda média BB");
        return false;
    }
    
    if(!SafeCopyBuffer(g_bb_handle, 2, 0, size, g_cache_bb_lower))
    {
        Logger::Error("CacheManager", "Falha ao copiar banda inferior BB");
        return false;
    }
    
    // Copia dados Média Móvel se disponível
    if(IsValidIndicatorHandle(g_ma_handle))
    {
        if(!SafeCopyBuffer(g_ma_handle, 0, 0, size, g_cache_ma_values))
        {
            Logger::Error("CacheManager", "Falha ao copiar dados MA");
            return false;
        }
    }
    else
    {
        // Preenche com valores neutros se MA não estiver ativa
        ArrayInitialize(g_cache_ma_values, 0.0);
    }
    
    // Validação dos arrays
    if(!ValidateDataIntegrity(g_cache_atr_values, size, "ATR"))
        return false;
    
    if(!ValidateDataIntegrity(g_cache_bb_upper, size, "BB_Upper"))
        return false;
    
    if(!ValidateDataIntegrity(g_cache_bb_middle, size, "BB_Middle"))
        return false;
    
    if(!ValidateDataIntegrity(g_cache_bb_lower, size, "BB_Lower"))
        return false;
    
    Logger::Debug("CacheManager", "Cache de indicadores preenchido com sucesso");
    return true;
}

//+------------------------------------------------------------------+
//| Valida integridade completa do cache                            |
//+------------------------------------------------------------------+
bool ValidateCacheIntegrity(int expected_size)
{
    Logger::Debug("CacheManager", "Validando integridade do cache");
    
    // Verifica tamanhos dos arrays
    if(ArraySize(g_cache_candle_colors) != expected_size)
    {
        Logger::Error("CacheManager", "Tamanho incorreto: g_cache_candle_colors");
        return false;
    }
    
    if(ArraySize(g_cache_atr_values) != expected_size)
    {
        Logger::Error("CacheManager", "Tamanho incorreto: g_cache_atr_values");
        return false;
    }
    
    if(ArraySize(g_cache_bb_upper) != expected_size)
    {
        Logger::Error("CacheManager", "Tamanho incorreto: g_cache_bb_upper");
        return false;
    }
    
    // Verifica consistência dos dados
    int invalid_colors = 0;
    int invalid_atr = 0;
    
    for(int i = 0; i < MathMin(expected_size, 100); i += 10) // Amostragem
    {
        // Verifica cores válidas
        int color = g_cache_candle_colors[i];
        if(color != VISUAL_GREEN && color != VISUAL_RED && color != VISUAL_DOJI)
        {
            invalid_colors++;
        }
        
        // Verifica ATR válido
        double atr = g_cache_atr_values[i];
        if(!MathIsValidNumber(atr) || atr < 0)
        {
            invalid_atr++;
        }
        
        // Verifica consistência das Bandas de Bollinger
        if(g_cache_bb_upper[i] <= g_cache_bb_middle[i] || 
           g_cache_bb_middle[i] <= g_cache_bb_lower[i])
        {
            Logger::Warning("CacheManager", "Inconsistência nas Bandas de Bollinger", 
                           "Shift: " + IntegerToString(i));
        }
    }
    
    if(invalid_colors > 5)
    {
        Logger::Error("CacheManager", "Muitas cores inválidas detectadas", 
                     "Count: " + IntegerToString(invalid_colors));
        return false;
    }
    
    if(invalid_atr > 5)
    {
        Logger::Error("CacheManager", "Muitos valores ATR inválidos", 
                     "Count: " + IntegerToString(invalid_atr));
        return false;
    }
    
    Logger::Debug("CacheManager", "Validação de integridade concluída com sucesso");
    return true;
}

//+------------------------------------------------------------------+
//| Atualiza configuração de filtros                                |
//+------------------------------------------------------------------+
void UpdateFilterConfig(bool volatility_filter, int atr_period, double bb_multiplier,
                       int bb_period, bool use_ma, int ma_period, ENUM_MA_METHOD ma_method)
{
    g_filter_config.volatility_filter_active = volatility_filter;
    g_filter_config.atr_period = atr_period;
    g_filter_config.bb_multiplier = bb_multiplier;
    g_filter_config.bb_period = bb_period;
    g_filter_config.use_moving_average = use_ma;
    g_filter_config.ma_period = ma_period;
    g_filter_config.ma_method = ma_method;
    
    Logger::Debug("CacheManager", "Configuração de filtros atualizada");
}

//+------------------------------------------------------------------+
//| Libera handles de indicadores                                   |
//+------------------------------------------------------------------+
void ReleaseIndicatorHandles()
{
    if(IsValidIndicatorHandle(g_atr_handle))
    {
        IndicatorRelease(g_atr_handle);
        g_atr_handle = INVALID_HANDLE;
        Logger::Debug("CacheManager", "Handle ATR liberado");
    }
    
    if(IsValidIndicatorHandle(g_bb_handle))
    {
        IndicatorRelease(g_bb_handle);
        g_bb_handle = INVALID_HANDLE;
        Logger::Debug("CacheManager", "Handle BB liberado");
    }
    
    if(IsValidIndicatorHandle(g_ma_handle))
    {
        IndicatorRelease(g_ma_handle);
        g_ma_handle = INVALID_HANDLE;
        Logger::Debug("CacheManager", "Handle MA liberado");
    }
}

//+------------------------------------------------------------------+
//| Função de recuperação de cache em caso de falha                 |
//+------------------------------------------------------------------+
bool RecoverCache(int fallback_size = 500)
{
    Logger::Warning("CacheManager", "Iniciando recuperação de cache");
    
    // Tenta recuperação com parâmetros mínimos
    bool success = AtualizarCachesDeDadosRobusta(
        fallback_size,
        false, // Desabilita filtros complexos
        20,    // ATR padrão
        2.0,   // BB padrão
        14,    // BB período padrão
        false, // Sem MA
        100,   // MA período padrão
        MODE_EMA
    );
    
    if(success)
    {
        Logger::Info("CacheManager", "Recuperação de cache bem-sucedida", 
                    "Tamanho: " + IntegerToString(fallback_size));
    }
    else
    {
        Logger::Error("CacheManager", "Falha na recuperação de cache");
    }
    
    return success;
}

//+------------------------------------------------------------------+
//| Função de limpeza de cache                                      |
//+------------------------------------------------------------------+
void CleanupCache()
{
    Logger::Info("CacheManager", "Limpando cache");
    
    // Libera handles
    ReleaseIndicatorHandles();
    
    // Limpa arrays
    ArrayFree(g_cache_candle_colors);
    ArrayFree(g_cache_atr_values);
    ArrayFree(g_cache_bb_upper);
    ArrayFree(g_cache_bb_lower);
    ArrayFree(g_cache_bb_middle);
    ArrayFree(g_cache_ma_values);
    
    // Reset de variáveis globais
    g_cache_initialized = false;
    g_cache_size = 0;
    g_cache_last_update = 0;
    
    // Atualiza StateManager
    StateManager* state = StateManager::GetInstance();
    if(state != NULL)
    {
        state.UpdateCacheState(false, 0, "CleanupCache");
    }
    
    Logger::Info("CacheManager", "Cache limpo com sucesso");
}

//+------------------------------------------------------------------+
//| Função de diagnóstico do cache                                  |
//+------------------------------------------------------------------+
void DiagnosticCache()
{
    Logger::Info("CacheManager", "=== DIAGNÓSTICO DO CACHE ===");
    Logger::Info("CacheManager", "Inicializado: " + BoolToString(g_cache_initialized));
    Logger::Info("CacheManager", "Tamanho: " + IntegerToString(g_cache_size));
    Logger::Info("CacheManager", "Última atualização: " + TimeToString(g_cache_last_update));
    
    if(g_cache_initialized)
    {
        Logger::Info("CacheManager", "Array cores: " + IntegerToString(ArraySize(g_cache_candle_colors)));
        Logger::Info("CacheManager", "Array ATR: " + IntegerToString(ArraySize(g_cache_atr_values)));
        Logger::Info("CacheManager", "Array BB: " + IntegerToString(ArraySize(g_cache_bb_upper)));
        
        // Amostra de dados
        if(ArraySize(g_cache_candle_colors) > 0)
        {
            Logger::Info("CacheManager", "Cor[0]: " + IntegerToString(g_cache_candle_colors[0]));
        }
        
        if(ArraySize(g_cache_atr_values) > 0)
        {
            Logger::Info("CacheManager", "ATR[0]: " + DoubleToString(g_cache_atr_values[0], 5));
        }
    }
    
    Logger::Info("CacheManager", "Handles - ATR: " + IntegerToString(g_atr_handle) + 
                                 ", BB: " + IntegerToString(g_bb_handle) + 
                                 ", MA: " + IntegerToString(g_ma_handle));
    
    Logger::Info("CacheManager", "=== FIM DO DIAGNÓSTICO ===");
}

//+------------------------------------------------------------------+
//| Função de verificação rápida de saúde do cache                  |
//+------------------------------------------------------------------+
bool IsHealthyCache()
{
    if(!g_cache_initialized)
        return false;
    
    if(g_cache_size < MIN_CACHE_SIZE)
        return false;
    
    if(ArraySize(g_cache_candle_colors) != g_cache_size)
        return false;
    
    if((TimeCurrent() - g_cache_last_update) > 3600) // Mais de 1 hora
        return false;
    
    return true;
}

#endif // CORE_CACHEMANAGER_MQH

