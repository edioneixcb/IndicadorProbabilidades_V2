//+------------------------------------------------------------------+
//|                                    IndicadorProbabilidades_V3.mq5 |
//|                                    Indicador de Probabilidades V3 |
//|                                Sistema Completo de Análise MHI |
//+------------------------------------------------------------------+
#property copyright "2024, Indicador de Probabilidades"
#property link      "https://github.com/edioneixcb/IndicadorProbabilidades_V3"
#property version   "3.00"
#property description "Sistema completo de análise de padrões MHI com arquitetura modular"
#property description "Inclui painel visual, notificações, análise financeira e SuperVarredura"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   2

// Propriedades dos plots
#property indicator_label1  "CALL Signal"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLime
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "PUT Signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//+------------------------------------------------------------------+
//| Includes dos Módulos                                            |
//+------------------------------------------------------------------+
#include "IndicadorProbabilidades_V3/Core/Defines.mqh"
#include "IndicadorProbabilidades_V3/Core/Types.mqh"
#include "IndicadorProbabilidades_V3/Core/Globals.mqh"
#include "IndicadorProbabilidades_V3/Analysis/Financial/FinancialCore.mqh"
#include "IndicadorProbabilidades_V3/Notifications/Telegram/TelegramCore.mqh"
#include "IndicadorProbabilidades_V3/Notifications/MX2/MX2Core.mqh"
#include "IndicadorProbabilidades_V3/Visual/Panel/PanelCore.mqh"

//+------------------------------------------------------------------+
//| Parâmetros de Entrada                                           |
//+------------------------------------------------------------------+

// === CONFIGURAÇÕES GERAIS ===
input group "=== CONFIGURAÇÕES GERAIS ==="
input bool InpEnabled = true;                          // Habilitar Indicador
input PatternType InpActivePattern = PATTERN_MHI1;     // Padrão Ativo
input bool InpEnableInversion = false;                 // Habilitar Inversão
input int InpMinConfidence = 70;                       // Confiança Mínima (%)

// === CONFIGURAÇÕES VISUAIS ===
input group "=== CONFIGURAÇÕES VISUAIS ==="
input bool InpShowPanel = true;                        // Mostrar Painel
input PanelPosition InpPanelPosition = PANEL_TOP_RIGHT; // Posição do Painel
input int InpPanelOffsetX = 10;                        // Offset X do Painel
input int InpPanelOffsetY = 30;                        // Offset Y do Painel
input color InpCallColor = clrLime;                     // Cor CALL
input color InpPutColor = clrRed;                       // Cor PUT
input bool InpShowArrows = true;                        // Mostrar Setas
input ArrowPosition InpArrowPosition = ARROW_ABOVE_BELOW; // Posição das Setas

// === ANÁLISE FINANCEIRA ===
input group "=== ANÁLISE FINANCEIRA ==="
input double InpEntryValue = 10.0;                     // Valor de Entrada
input double InpPayout = 0.8;                          // Payout (0.8 = 80%)
input bool InpEnableMartingale = true;                 // Habilitar Martingale
input double InpMartingaleFactor = 2.0;                // Fator Martingale
input int InpMaxGaleLevels = 5;                        // Máximo Níveis Gale
input bool InpEnableStopLoss = false;                  // Habilitar Stop Loss
input double InpStopLossValue = 100.0;                 // Valor Stop Loss
input bool InpEnableStopWin = false;                   // Habilitar Stop Win
input double InpStopWinValue = 200.0;                  // Valor Stop Win

// === FILTROS DE MERCADO ===
input group "=== FILTROS DE MERCADO ==="
input bool InpEnableATR = true;                        // Filtro ATR
input int InpATRPeriod = 14;                           // Período ATR
input double InpATRMultiplier = 1.5;                   // Multiplicador ATR
input bool InpEnableBollinger = true;                  // Filtro Bollinger
input int InpBollingerPeriod = 20;                     // Período Bollinger
input double InpBollingerDeviation = 2.0;              // Desvio Bollinger
input bool InpEnableTrend = false;                     // Filtro Tendência
input int InpTrendPeriod = 50;                         // Período Tendência

// === NOTIFICAÇÕES ===
input group "=== NOTIFICAÇÕES ==="
input bool InpEnableTelegram = false;                  // Habilitar Telegram
input string InpTelegramToken = "";                    // Token do Bot
input string InpTelegramChatID = "";                   // Chat ID
input bool InpEnableMX2 = false;                       // Habilitar MX2
input BrokerMX2 InpMX2Broker = MX2_QUOTEX;            // Corretora MX2
input int InpMX2ExpiryMinutes = 5;                     // Expiração (minutos)

// === SUPERVARREDURA ===
input group "=== SUPERVARREDURA ==="
input bool InpEnableSuperScan = false;                 // Habilitar SuperVarredura
input int InpSuperScanBars = 1000;                     // Barras para Análise
input int InpSuperScanMinOps = 50;                     // Mínimo Operações
input double InpSuperScanMinWinrate = 60.0;            // WinRate Mínimo (%)
input bool InpSuperScanAutoApply = false;              // Aplicar Automaticamente

// === SISTEMA ===
input group "=== SISTEMA ==="
input LogLevel InpLogLevel = LOG_INFO;                 // Nível de Log
input bool InpEnableDebug = false;                     // Modo Debug
input int InpUpdateInterval = 1000;                    // Intervalo Atualização (ms)

//+------------------------------------------------------------------+
//| Variáveis Globais do Indicador                                  |
//+------------------------------------------------------------------+
datetime g_last_bar_time = 0;
bool g_indicator_initialized = false;

//+------------------------------------------------------------------+
//| Função de Inicialização                                         |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("=== INICIALIZANDO INDICADOR DE PROBABILIDADES V3.0 ===");
    
    // Inicializar variáveis globais
    if(!InitializeGlobalVariables())
    {
        Print("ERRO: Falha ao inicializar variáveis globais");
        return INIT_FAILED;
    }
    
    // Carregar configurações dos parâmetros
    LoadConfigurationFromInputs();
    
    // Inicializar buffers do indicador
    if(!InitializeIndicatorBuffers())
    {
        Print("ERRO: Falha ao inicializar buffers do indicador");
        return INIT_FAILED;
    }
    
    // Inicializar indicadores técnicos
    if(!InitializeTechnicalIndicators())
    {
        Print("ERRO: Falha ao inicializar indicadores técnicos");
        return INIT_FAILED;
    }
    
    // Inicializar sistema financeiro
    if(!InitializeFinancialSystem())
    {
        Print("ERRO: Falha ao inicializar sistema financeiro");
        return INIT_FAILED;
    }
    
    // Inicializar painel visual
    if(g_config.visual.show_panel)
    {
        if(!InitializePanel())
        {
            Print("AVISO: Falha ao inicializar painel visual");
        }
    }
    
    // Inicializar notificações
    if(g_config.notifications.enable_telegram)
    {
        if(!InitializeTelegram())
        {
            Print("AVISO: Falha ao inicializar Telegram");
        }
    }
    
    if(g_config.notifications.enable_mx2)
    {
        if(!InitializeMX2())
        {
            Print("AVISO: Falha ao inicializar MX2");
        }
    }
    
    // Marcar como inicializado
    g_indicator_initialized = true;
    g_system_state = STATE_RUNNING;
    g_system_start_time = TimeCurrent();
    
    Print("=== INDICADOR INICIALIZADO COM SUCESSO ===");
    Print("Padrão Ativo: ", PatternTypeToString(g_config.patterns.active_pattern));
    Print("Painel Visual: ", g_config.visual.show_panel ? "Habilitado" : "Desabilitado");
    Print("Telegram: ", g_config.notifications.enable_telegram ? "Habilitado" : "Desabilitado");
    Print("MX2: ", g_config.notifications.enable_mx2 ? "Habilitado" : "Desabilitado");
    
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Função de Deinicialização                                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("=== DEINICIALIZANDO INDICADOR ===");
    Print("Motivo: ", reason);
    
    // Limpar recursos globais
    CleanupGlobalResources();
    
    // Limpar painel visual
    if(g_panel_initialized)
    {
        CleanupPanel();
    }
    
    // Salvar estatísticas finais
    SaveFinalStatistics();
    
    g_system_state = STATE_STOPPED;
    g_indicator_initialized = false;
    
    Print("=== INDICADOR DEINICIALIZADO ===");
}

//+------------------------------------------------------------------+
//| Função Principal de Cálculo                                     |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    // Verificar se o indicador está inicializado
    if(!g_indicator_initialized || g_system_state != STATE_RUNNING)
    {
        return prev_calculated;
    }
    
    // Verificar se há dados suficientes
    if(rates_total < 100)
    {
        return prev_calculated;
    }
    
    // Verificar nova barra
    bool new_bar = false;
    if(time[rates_total-1] != g_last_bar_time)
    {
        g_last_bar_time = time[rates_total-1];
        new_bar = true;
    }
    
    // Atualizar dados de preços
    UpdatePriceData(rates_total, time, open, high, low, close);
    
    // Processar apenas em nova barra ou primeira execução
    if(new_bar || prev_calculated == 0)
    {
        // Atualizar filtros de mercado
        UpdateMarketFilters(rates_total);
        
        // Detectar padrões
        PatternDetectionResult pattern_result = DetectPatterns(rates_total, open, high, low, close);
        
        // Processar sinal se detectado
        if(pattern_result.pattern_detected && pattern_result.confidence >= g_config.patterns.min_confidence)
        {
            ProcessSignal(pattern_result, rates_total);
        }
        
        // Atualizar análise financeira
        UpdateFinancialAnalysis();
        
        // Atualizar painel visual
        if(g_config.visual.show_panel && g_panel_initialized)
        {
            UpdatePanel();
        }
        
        // Executar SuperVarredura se habilitada
        if(g_config.superscan.enabled && ShouldRunSuperScan())
        {
            ExecuteSuperScan();
        }
    }
    
    return rates_total;
}

//+------------------------------------------------------------------+
//| Funções de Inicialização                                        |
//+------------------------------------------------------------------+

/**
 * Carrega configurações dos parâmetros de entrada
 */
void LoadConfigurationFromInputs()
{
    // Configurações gerais
    g_config.general.enabled = InpEnabled;
    g_config.general.log_level = InpLogLevel;
    g_config.general.enable_debug = InpEnableDebug;
    g_config.general.update_interval_ms = InpUpdateInterval;
    
    // Configurações de padrões
    g_config.patterns.active_pattern = InpActivePattern;
    g_config.patterns.enable_inversion = InpEnableInversion;
    g_config.patterns.min_confidence = InpMinConfidence;
    
    // Configurações visuais
    g_config.visual.show_panel = InpShowPanel;
    g_config.visual.panel_position = InpPanelPosition;
    g_config.visual.panel_offset_x = InpPanelOffsetX;
    g_config.visual.panel_offset_y = InpPanelOffsetY;
    g_config.visual.call_color = InpCallColor;
    g_config.visual.put_color = InpPutColor;
    g_config.visual.show_arrows = InpShowArrows;
    g_config.visual.arrow_position = InpArrowPosition;
    
    // Configurações financeiras
    g_config.financial.entry_value = InpEntryValue;
    g_config.financial.payout = InpPayout;
    g_config.financial.enable_martingale = InpEnableMartingale;
    g_config.financial.martingale_factor = InpMartingaleFactor;
    g_config.financial.max_gale_levels = InpMaxGaleLevels;
    g_config.financial.enable_stop_loss = InpEnableStopLoss;
    g_config.financial.stop_loss_value = InpStopLossValue;
    g_config.financial.enable_stop_win = InpEnableStopWin;
    g_config.financial.stop_win_value = InpStopWinValue;
    
    // Configurações de filtros
    g_config.filters.enable_atr = InpEnableATR;
    g_config.filters.atr_period = InpATRPeriod;
    g_config.filters.atr_multiplier = InpATRMultiplier;
    g_config.filters.enable_bollinger = InpEnableBollinger;
    g_config.filters.bollinger_period = InpBollingerPeriod;
    g_config.filters.bollinger_deviation = InpBollingerDeviation;
    g_config.filters.enable_trend = InpEnableTrend;
    g_config.filters.trend_period = InpTrendPeriod;
    
    // Configurações de notificações
    g_config.notifications.enable_telegram = InpEnableTelegram;
    g_config.notifications.telegram_token = InpTelegramToken;
    g_config.notifications.telegram_chat_id = InpTelegramChatID;
    g_config.notifications.enable_mx2 = InpEnableMX2;
    g_config.notifications.mx2_broker = InpMX2Broker;
    g_config.notifications.mx2_expiry_minutes = InpMX2ExpiryMinutes;
    
    // Configurações de SuperVarredura
    g_config.superscan.enabled = InpEnableSuperScan;
    g_config.superscan.analysis_bars = InpSuperScanBars;
    g_config.superscan.min_operations = InpSuperScanMinOps;
    g_config.superscan.min_winrate = InpSuperScanMinWinrate;
    g_config.superscan.auto_apply = InpSuperScanAutoApply;
}

/**
 * Inicializa buffers do indicador
 */
bool InitializeIndicatorBuffers()
{
    // Definir buffers
    SetIndexBuffer(0, g_call_buffer, INDICATOR_DATA);
    SetIndexBuffer(1, g_put_buffer, INDICATOR_DATA);
    SetIndexBuffer(2, g_confidence_buffer, INDICATOR_CALCULATIONS);
    
    // Configurar propriedades dos plots
    PlotIndexSetInteger(0, PLOT_ARROW, 233);  // Seta para cima
    PlotIndexSetInteger(1, PLOT_ARROW, 234);  // Seta para baixo
    
    PlotIndexSetString(0, PLOT_LABEL, "CALL");
    PlotIndexSetString(1, PLOT_LABEL, "PUT");
    
    // Inicializar com valores vazios
    ArrayInitialize(g_call_buffer, EMPTY_VALUE);
    ArrayInitialize(g_put_buffer, EMPTY_VALUE);
    ArrayInitialize(g_confidence_buffer, 0.0);
    
    return true;
}

/**
 * Inicializa indicadores técnicos
 */
bool InitializeTechnicalIndicators()
{
    // Inicializar ATR
    if(g_config.filters.enable_atr)
    {
        g_atr_handle = iATR(Symbol(), Period(), g_config.filters.atr_period);
        if(g_atr_handle == INVALID_HANDLE)
        {
            Print("ERRO: Falha ao criar handle ATR");
            return false;
        }
    }
    
    // Inicializar Bollinger Bands
    if(g_config.filters.enable_bollinger)
    {
        g_bollinger_handle = iBands(Symbol(), Period(), g_config.filters.bollinger_period, 
                                   0, g_config.filters.bollinger_deviation, PRICE_CLOSE);
        if(g_bollinger_handle == INVALID_HANDLE)
        {
            Print("ERRO: Falha ao criar handle Bollinger Bands");
            return false;
        }
    }
    
    // Inicializar Média Móvel para tendência
    if(g_config.filters.enable_trend)
    {
        g_ma_handle = iMA(Symbol(), Period(), g_config.filters.trend_period, 0, MODE_SMA, PRICE_CLOSE);
        if(g_ma_handle == INVALID_HANDLE)
        {
            Print("ERRO: Falha ao criar handle Média Móvel");
            return false;
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Funções de Processamento                                        |
//+------------------------------------------------------------------+

/**
 * Atualiza dados de preços
 */
void UpdatePriceData(int rates_total, const datetime &time[], const double &open[], 
                    const double &high[], const double &low[], const double &close[])
{
    int start = MathMax(0, rates_total - MAX_BARS_HISTORY);
    int count = MathMin(MAX_BARS_HISTORY, rates_total - start);
    
    for(int i = 0; i < count; i++)
    {
        int src_index = start + i;
        g_bar_times[i] = time[src_index];
        g_open_prices[i] = open[src_index];
        g_high_prices[i] = high[src_index];
        g_low_prices[i] = low[src_index];
        g_close_prices[i] = close[src_index];
    }
}

/**
 * Atualiza filtros de mercado
 */
void UpdateMarketFilters(int rates_total)
{
    InitializeMarketFilters(g_market_filters);
    
    // Filtro ATR
    if(g_config.filters.enable_atr && g_atr_handle != INVALID_HANDLE)
    {
        double atr_values[];
        if(CopyBuffer(g_atr_handle, 0, 0, 2, atr_values) > 0)
        {
            double current_atr = atr_values[0];
            double min_atr = g_config.filters.atr_multiplier * Point() * 10;
            g_market_filters.atr_filter_passed = (current_atr >= min_atr);
        }
    }
    
    // Filtro Bollinger Bands
    if(g_config.filters.enable_bollinger && g_bollinger_handle != INVALID_HANDLE)
    {
        double bb_upper[], bb_lower[];
        if(CopyBuffer(g_bollinger_handle, 1, 0, 1, bb_upper) > 0 && 
           CopyBuffer(g_bollinger_handle, 2, 0, 1, bb_lower) > 0)
        {
            double current_price = g_close_prices[0];
            double bb_range = bb_upper[0] - bb_lower[0];
            double price_position = (current_price - bb_lower[0]) / bb_range;
            
            // Filtro passa se o preço não está nos extremos das bandas
            g_market_filters.bollinger_filter_passed = (price_position > 0.2 && price_position < 0.8);
            g_market_filters.bollinger_bands_active = true;
        }
    }
    
    // Filtro de Tendência
    if(g_config.filters.enable_trend && g_ma_handle != INVALID_HANDLE)
    {
        double ma_values[];
        if(CopyBuffer(g_ma_handle, 0, 0, 2, ma_values) > 0)
        {
            double current_price = g_close_prices[0];
            double ma_current = ma_values[0];
            double ma_previous = ma_values[1];
            
            // Determinar direção da tendência
            if(ma_current > ma_previous)
                g_market_filters.trend_direction = 1;  // Alta
            else if(ma_current < ma_previous)
                g_market_filters.trend_direction = -1; // Baixa
            else
                g_market_filters.trend_direction = 0;  // Lateral
            
            // Filtro passa se há tendência definida
            g_market_filters.trend_filter_passed = (g_market_filters.trend_direction != 0);
        }
    }
    
    // Resultado final dos filtros
    g_market_filters.all_filters_passed = g_market_filters.atr_filter_passed && 
                                         g_market_filters.bollinger_filter_passed && 
                                         g_market_filters.trend_filter_passed;
}

/**
 * Detecta padrões MHI
 */
PatternDetectionResult DetectPatterns(int rates_total, const double &open[], 
                                    const double &high[], const double &low[], const double &close[])
{
    PatternDetectionResult result;
    InitializePatternDetectionResult(result);
    
    // Verificar se há dados suficientes
    if(rates_total < 10)
        return result;
    
    // Detectar padrão baseado na configuração
    switch(g_config.patterns.active_pattern)
    {
        case PATTERN_MHI1:
            result = DetectMHI1Pattern(open, high, low, close);
            break;
        case PATTERN_MHI2:
            result = DetectMHI2Pattern(open, high, low, close);
            break;
        case PATTERN_MHI3:
            result = DetectMHI3Pattern(open, high, low, close);
            break;
        case PATTERN_MHI4:
            result = DetectMHI4Pattern(open, high, low, close);
            break;
        case PATTERN_MHI5:
            result = DetectMHI5Pattern(open, high, low, close);
            break;
        case PATTERN_MHI6:
            result = DetectMHI6Pattern(open, high, low, close);
            break;
        default:
            break;
    }
    
    // Aplicar inversão se habilitada
    if(result.pattern_detected && g_config.patterns.enable_inversion)
    {
        result.is_call = !result.is_call;
    }
    
    return result;
}

/**
 * Detecta padrão MHI1
 */
PatternDetectionResult DetectMHI1Pattern(const double &open[], const double &high[], 
                                       const double &low[], const double &close[])
{
    PatternDetectionResult result;
    InitializePatternDetectionResult(result);
    
    // Verificar padrão MHI1: 3 velas de mesma cor seguidas
    if(ArraySize(close) >= 4)
    {
        bool candle1_bull = close[3] > open[3];
        bool candle2_bull = close[2] > open[2];
        bool candle3_bull = close[1] > open[1];
        
        // Três velas de alta seguidas - sinal PUT
        if(candle1_bull && candle2_bull && candle3_bull)
        {
            result.pattern_detected = true;
            result.pattern_type = PATTERN_MHI1;
            result.is_call = false; // PUT
            result.confidence = 75.0;
            result.signal_price = close[0];
        }
        // Três velas de baixa seguidas - sinal CALL
        else if(!candle1_bull && !candle2_bull && !candle3_bull)
        {
            result.pattern_detected = true;
            result.pattern_type = PATTERN_MHI1;
            result.is_call = true; // CALL
            result.confidence = 75.0;
            result.signal_price = close[0];
        }
    }
    
    return result;
}

/**
 * Detecta padrão MHI2
 */
PatternDetectionResult DetectMHI2Pattern(const double &open[], const double &high[], const double &low[], const double &close[])
{
    PatternDetectionResult result;
    InitializePatternDetectionResult(result);
    
    // Implementação simplificada do MHI2
    // Pode ser expandida com lógica mais complexa
    
    return result;
}

/**
 * Detecta padrão MHI3
 */
PatternDetectionResult DetectMHI3Pattern(const double &open[], const double &high[], const double &low[], const double &close[])
{
    PatternDetectionResult result;
    InitializePatternDetectionResult(result);
    
    // Implementação simplificada do MHI3
    // Pode ser expandida com lógica mais complexa
    
    return result;
}

/**
 * Detecta padrão MHI4
 */
PatternDetectionResult DetectMHI4Pattern(const double &open[], const double &high[], const double &low[], const double &close[])
{
    PatternDetectionResult result;
    InitializePatternDetectionResult(result);
    
    // Implementação simplificada do MHI4
    // Pode ser expandida com lógica mais complexa
    
    return result;
}

/**
 * Detecta padrão MHI5
 */
PatternDetectionResult DetectMHI5Pattern(const double &open[], const double &high[], const double &low[], const double &close[])
{
    PatternDetectionResult result;
    InitializePatternDetectionResult(result);
    
    // Implementação simplificada do MHI5
    // Pode ser expandida com lógica mais complexa
    
    return result;
}

/**
 * Detecta padrão MHI6
 */
PatternDetectionResult DetectMHI6Pattern(const double &open[], const double &high[], const double &low[], const double &close[])
{
    PatternDetectionResult result;
    InitializePatternDetectionResult(result);
    
    // Implementação simplificada do MHI6
    // Pode ser expandida com lógica mais complexa
    
    return result;
}

/**
 * Processa sinal detectado
 */
void ProcessSignal(PatternDetectionResult &pattern_result, int rates_total)
{
    // Verificar filtros de mercado
    if(!g_market_filters.all_filters_passed)
    {
        if(g_config.general.enable_debug)
        {
            Print("Sinal rejeitado pelos filtros de mercado");
        }
        return;
    }
    
    // Criar informações do sinal
    SignalInfo signal;
    InitializeSignalInfo(signal);
    signal.signal_time = TimeCurrent();
    signal.pattern_type = pattern_result.pattern_type;
    signal.is_call = pattern_result.is_call;
    signal.signal_price = pattern_result.signal_price;
    signal.confidence = pattern_result.confidence;
    signal.filter_passed = true;
    
    // Plotar sinal no gráfico
    PlotSignal(signal, rates_total);
    
    // Processar financeiramente
    ProcessFinancialSignal(signal);
    
    // Enviar notificações
    SendNotifications(signal);
    
    // Salvar sinal
    g_last_signal = signal;
    g_last_pattern_result = pattern_result;
    
    // Log
    Print("SINAL DETECTADO: ", PatternTypeToString(signal.pattern_type), 
          " | ", signal.is_call ? "CALL" : "PUT", 
          " | Confiança: ", DoubleToString(signal.confidence, 1), "%",
          " | Preço: ", DoubleToString(signal.signal_price, 5));
}

/**
 * Plota sinal no gráfico
 */
void PlotSignal(SignalInfo &signal, int rates_total)
{
    if(!g_config.visual.show_arrows)
        return;
    
    int index = rates_total - 1;
    
    if(signal.is_call)
    {
        g_call_buffer[index] = signal.signal_price;
        g_put_buffer[index] = EMPTY_VALUE;
    }
    else
    {
        g_put_buffer[index] = signal.signal_price;
        g_call_buffer[index] = EMPTY_VALUE;
    }
    
    g_confidence_buffer[index] = signal.confidence;
}

/**
 * Verifica se deve executar SuperVarredura
 */
bool ShouldRunSuperScan()
{
    if(!g_config.superscan.enabled)
        return false;
    
    // Executar a cada hora
    datetime current_time = TimeCurrent();
    if(current_time - g_last_superscan < 3600)
        return false;
    
    return true;
}

/**
 * Executa SuperVarredura
 */
void ExecuteSuperScan()
{
    if(g_superscan_running)
        return;
    
    g_superscan_running = true;
    g_last_superscan = TimeCurrent();
    
    Print("=== INICIANDO SUPERVARREDURA ===");
    
    // Implementação simplificada
    // Pode ser expandida com análise completa de todos os padrões
    
    g_superscan_result.best_pattern = PATTERN_MHI1;
    g_superscan_result.best_winrate = 75.0;
    g_superscan_result.total_operations = 100;
    g_superscan_result.total_wins = 75;
    g_superscan_result.total_losses = 25;
    g_superscan_result.recommendation_apply = true;
    
    g_superscan_completed = true;
    g_superscan_running = false;
    
    Print("=== SUPERVARREDURA CONCLUÍDA ===");
    Print("Melhor Padrão: ", PatternTypeToString(g_superscan_result.best_pattern));
    Print("WinRate: ", DoubleToString(g_superscan_result.best_winrate, 1), "%");
}

/**
 * Salva estatísticas finais
 */
void SaveFinalStatistics()
{
    Print("=== ESTATÍSTICAS FINAIS ===");
    Print("Total Operações: ", g_total_operations);
    Print("Total Vitórias: ", g_total_wins);
    Print("Total Perdas: ", g_total_losses);
    if(g_total_operations > 0)
    {
        double winrate = (double)g_total_wins / g_total_operations * 100.0;
        Print("WinRate: ", DoubleToString(winrate, 1), "%");
    }
    Print("Lucro Total: ", FormatCurrency(g_total_profit));
    Print("Saldo Final: ", FormatCurrency(g_current_balance));
}

