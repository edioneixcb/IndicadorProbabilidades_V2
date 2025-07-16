//+------------------------------------------------------------------+
//|                                    IndicadorProbabilidades_V3.mq5 |
//|                                    Indicador de Probabilidades V3 |
//|                                Sistema Completo de Trading |
//+------------------------------------------------------------------+

#property copyright "Indicador de Probabilidades V3"
#property link      "https://github.com/edioneixcb/IndicadorProbabilidades_V2"
#property version   "3.00"
#property description "Sistema completo de detecção de padrões MHI com análise financeira, notificações e painel visual"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   2

// Plotagem CALL
#property indicator_label1  "CALL Signal"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

// Plotagem PUT
#property indicator_label2  "PUT Signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//+------------------------------------------------------------------+
//| Includes dos Módulos                                             |
//+------------------------------------------------------------------+
#include "IndicadorProbabilidades_V3/Core/Types.mqh"
#include "IndicadorProbabilidades_V3/Core/Globals.mqh"
#include "IndicadorProbabilidades_V3/Analysis/Financial/FinancialCore.mqh"
#include "IndicadorProbabilidades_V3/Notifications/Telegram/TelegramCore.mqh"
#include "IndicadorProbabilidades_V3/Notifications/MX2/MX2Core.mqh"
#include "IndicadorProbabilidades_V3/Visual/Panel/PanelCore.mqh"

//+------------------------------------------------------------------+
//| Parâmetros de Entrada                                           |
//+------------------------------------------------------------------+

// Configurações Gerais
input group "=== CONFIGURAÇÕES GERAIS ==="
input bool InpSystemEnabled = true;                    // Sistema Habilitado
input LogLevel InpLogLevel = LOG_INFO;                 // Nível de Log
input bool InpEnableDebug = false;                     // Modo Debug

// Configurações de Padrões
input group "=== PADRÕES MHI ==="
input PatternType InpActivePattern = PATTERN_MHI1;     // Padrão Ativo
input bool InpEnableInversion = false;                 // Habilitar Inversão
input int InpMinConfidence = 70;                       // Confiança Mínima (%)

// Configurações Visuais
input group "=== CONFIGURAÇÕES VISUAIS ==="
input bool InpShowPanel = true;                        // Mostrar Painel
input PanelPosition InpPanelPosition = PANEL_TOP_RIGHT; // Posição do Painel
input int InpPanelOffsetX = 0;                         // Offset X do Painel
input int InpPanelOffsetY = 0;                         // Offset Y do Painel
input color InpCallColor = clrBlue;                    // Cor CALL
input color InpPutColor = clrRed;                      // Cor PUT
input bool InpShowArrows = true;                       // Mostrar Setas
input ArrowPosition InpArrowPosition = ARROW_ABOVE_BELOW; // Posição das Setas

// Configurações Financeiras
input group "=== CONFIGURAÇÕES FINANCEIRAS ==="
input double InpEntryValue = 10.0;                     // Valor de Entrada (R$)
input double InpPayout = 0.80;                         // Payout (0.80 = 80%)
input bool InpEnableMartingale = true;                 // Habilitar Martingale
input double InpMartingaleFactor = 2.2;                // Fator Martingale
input int InpMaxGaleLevels = 3;                        // Máximo Níveis Gale
input bool InpEnableStopLoss = true;                   // Habilitar Stop Loss
input double InpStopLossValue = 100.0;                 // Valor Stop Loss (R$)
input bool InpEnableStopWin = true;                    // Habilitar Stop Win
input double InpStopWinValue = 200.0;                  // Valor Stop Win (R$)

// Configurações de Filtros
input group "=== FILTROS DE MERCADO ==="
input bool InpEnableATR = true;                        // Filtro ATR
input int InpATRPeriod = 14;                           // Período ATR
input double InpATRMultiplier = 1.5;                   // Multiplicador ATR
input bool InpEnableBollinger = true;                  // Filtro Bollinger
input int InpBollingerPeriod = 20;                     // Período Bollinger
input double InpBollingerDeviation = 2.0;              // Desvio Bollinger
input bool InpEnableTrend = false;                     // Filtro Tendência
input int InpTrendPeriod = 50;                         // Período Tendência

// Configurações de Notificações
input group "=== NOTIFICAÇÕES ==="
input bool InpEnableTelegram = false;                  // Habilitar Telegram
input string InpTelegramToken = "";                    // Token do Bot
input string InpTelegramChatID = "";                   // Chat ID
input bool InpEnableMX2 = false;                       // Habilitar MX2
input BrokerMX2 InpMX2Broker = MX2_QUOTEX;            // Corretora MX2
input int InpMX2ExpiryMinutes = 5;                     // Expiração (minutos)

// Configurações de SuperVarredura
input group "=== SUPERVARREDURA ==="
input bool InpEnableSuperScan = false;                 // Habilitar SuperVarredura
input int InpAnalysisBars = 1000;                      // Barras para Análise
input int InpMinOperations = 50;                       // Mínimo Operações
input double InpMinWinrate = 60.0;                     // WinRate Mínimo (%)
input bool InpAutoApply = false;                       // Aplicar Automaticamente

//+------------------------------------------------------------------+
//| Variáveis Globais do Indicador                                  |
//+------------------------------------------------------------------+
double CallBuffer[];
double PutBuffer[];
double ConfidenceBuffer[];

//+------------------------------------------------------------------+
//| Função de Inicialização                                         |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("=== INICIALIZANDO INDICADOR DE PROBABILIDADES V3 ===");
    
    // Configurar buffers do indicador
    if(!SetupIndicatorBuffers())
    {
        Print("ERRO: Falha ao configurar buffers do indicador");
        return INIT_FAILED;
    }
    
    // Carregar configurações dos parâmetros
    if(!LoadConfiguration())
    {
        Print("ERRO: Falha ao carregar configurações");
        return INIT_FAILED;
    }
    
    // Inicializar variáveis globais
    if(!InitializeGlobalVariables())
    {
        Print("ERRO: Falha ao inicializar variáveis globais");
        return INIT_FAILED;
    }
    
    // Inicializar sistema financeiro
    if(!InitializeFinancialSystem())
    {
        Print("ERRO: Falha ao inicializar sistema financeiro");
        return INIT_FAILED;
    }
    
    // Inicializar notificações
    if(!InitializeNotifications())
    {
        Print("ERRO: Falha ao inicializar notificações");
        return INIT_FAILED;
    }
    
    // Inicializar painel visual
    if(!InitializePanel())
    {
        Print("ERRO: Falha ao inicializar painel visual");
        return INIT_FAILED;
    }
    
    // Inicializar indicadores técnicos
    if(!InitializeTechnicalIndicators())
    {
        Print("ERRO: Falha ao inicializar indicadores técnicos");
        return INIT_FAILED;
    }
    
    // Marcar sistema como inicializado
    g_system_state = STATE_RUNNING;
    g_system_initialized = true;
    g_system_start_time = TimeCurrent();
    
    Print("=== INDICADOR INICIALIZADO COM SUCESSO ===");
    Print("Padrão Ativo: ", PatternTypeToString(g_current_pattern));
    Print("Saldo Inicial: ", FormatCurrency(g_current_balance));
    
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Função de Desinicialização                                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("=== FINALIZANDO INDICADOR DE PROBABILIDADES V3 ===");
    
    // Limpar recursos
    CleanupGlobalResources();
    CleanupPanelObjects();
    
    // Mostrar estatísticas finais
    if(g_total_operations > 0)
    {
        Print("=== ESTATÍSTICAS FINAIS ===");
        Print("Total de Operações: ", g_total_operations);
        Print("Vitórias: ", g_total_wins, " | Perdas: ", g_total_losses);
        Print("WinRate: ", FormatPercentage(GetCurrentWinrate()));
        Print("Lucro Total: ", FormatCurrency(g_total_profit));
        Print("Saldo Final: ", FormatCurrency(g_current_balance));
    }
    
    Print("=== INDICADOR FINALIZADO ===");
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
    // Verificar se sistema está habilitado
    if(!g_config.general.enabled || g_system_state != STATE_RUNNING)
    {
        return rates_total;
    }
    
    // Verificar se há dados suficientes
    if(rates_total < 100)
    {
        return rates_total;
    }
    
    // Verificar nova barra
    if(!IsNewBar(time))
    {
        // Atualizar painel mesmo sem nova barra
        UpdatePanel();
        return rates_total;
    }
    
    // Atualizar dados de preços
    if(!UpdatePriceData(rates_total, time, open, high, low, close))
    {
        return rates_total;
    }
    
    // Processar detecção de padrões
    ProcessPatternDetection(rates_total);
    
    // Atualizar análise financeira
    UpdateFinancialAnalysis();
    
    // Atualizar painel visual
    UpdatePanel();
    
    return rates_total;
}

//+------------------------------------------------------------------+
//| Funções de Configuração                                         |
//+------------------------------------------------------------------+

/**
 * Configura buffers do indicador
 */
bool SetupIndicatorBuffers()
{
    // Configurar buffers
    SetIndexBuffer(0, CallBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, PutBuffer, INDICATOR_DATA);
    SetIndexBuffer(2, ConfidenceBuffer, INDICATOR_CALCULATIONS);
    
    // Configurar propriedades dos buffers
    PlotIndexSetInteger(0, PLOT_ARROW, 233); // Seta para cima
    PlotIndexSetInteger(1, PLOT_ARROW, 234); // Seta para baixo
    
    // Configurar cores
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, InpCallColor);
    PlotIndexSetInteger(1, PLOT_LINE_COLOR, InpPutColor);
    
    // Inicializar buffers
    ArraySetAsSeries(CallBuffer, true);
    ArraySetAsSeries(PutBuffer, true);
    ArraySetAsSeries(ConfidenceBuffer, true);
    
    ArrayInitialize(CallBuffer, EMPTY_VALUE);
    ArrayInitialize(PutBuffer, EMPTY_VALUE);
    ArrayInitialize(ConfidenceBuffer, 0.0);
    
    return true;
}

/**
 * Carrega configurações dos parâmetros
 */
bool LoadConfiguration()
{
    // Configurações gerais
    g_config.general.enabled = InpSystemEnabled;
    g_config.general.log_level = InpLogLevel;
    g_config.general.enable_debug = InpEnableDebug;
    g_config.general.update_interval_ms = 1000;
    
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
    g_config.superscan.analysis_bars = InpAnalysisBars;
    g_config.superscan.min_operations = InpMinOperations;
    g_config.superscan.min_winrate = InpMinWinrate;
    g_config.superscan.auto_apply = InpAutoApply;
    
    // Configurar variáveis globais baseadas na configuração
    g_current_pattern = g_config.patterns.active_pattern;
    g_pattern_inversion_enabled = g_config.patterns.enable_inversion;
    g_current_entry_value = g_config.financial.entry_value;
    
    return true;
}

/**
 * Inicializa notificações
 */
bool InitializeNotifications()
{
    bool telegram_ok = true;
    bool mx2_ok = true;
    
    // Inicializar Telegram
    if(g_config.notifications.enable_telegram)
    {
        telegram_ok = InitializeTelegram();
    }
    
    // Inicializar MX2
    if(g_config.notifications.enable_mx2)
    {
        mx2_ok = InitializeMX2();
    }
    
    return telegram_ok && mx2_ok;
}

/**
 * Inicializa indicadores técnicos
 */
bool InitializeTechnicalIndicators()
{
    // Inicializar ATR
    if(g_config.filters.enable_atr)
    {
        g_atr_handle = iATR(Symbol(), PERIOD_CURRENT, g_config.filters.atr_period);
        if(g_atr_handle == INVALID_HANDLE)
        {
            Print("ERRO: Falha ao criar handle ATR");
            return false;
        }
    }
    
    // Inicializar Bollinger Bands
    if(g_config.filters.enable_bollinger)
    {
        g_bollinger_handle = iBands(Symbol(), PERIOD_CURRENT, g_config.filters.bollinger_period, 
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
        g_ma_handle = iMA(Symbol(), PERIOD_CURRENT, g_config.filters.trend_period, 0, MODE_SMA, PRICE_CLOSE);
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
 * Verifica se é uma nova barra
 */
bool IsNewBar(const datetime &time[])
{
    static datetime last_time = 0;
    
    if(ArraySize(time) == 0)
        return false;
    
    datetime current_time = time[ArraySize(time) - 1];
    
    if(current_time != last_time)
    {
        last_time = current_time;
        g_last_bar_time = current_time;
        return true;
    }
    
    return false;
}

/**
 * Atualiza dados de preços
 */
bool UpdatePriceData(int rates_total, const datetime &time[], const double &open[], 
                    const double &high[], const double &low[], const double &close[])
{
    // Redimensionar arrays se necessário
    int array_size = MathMin(rates_total, 1000);
    
    if(ArraySize(g_close_prices) != array_size)
    {
        ArrayResize(g_close_prices, array_size);
        ArrayResize(g_open_prices, array_size);
        ArrayResize(g_high_prices, array_size);
        ArrayResize(g_low_prices, array_size);
        ArrayResize(g_bar_times, array_size);
    }
    
    // Copiar dados mais recentes
    int start_pos = rates_total - array_size;
    for(int i = 0; i < array_size; i++)
    {
        int src_index = start_pos + i;
        if(src_index >= 0 && src_index < rates_total)
        {
            g_close_prices[i] = close[src_index];
            g_open_prices[i] = open[src_index];
            g_high_prices[i] = high[src_index];
            g_low_prices[i] = low[src_index];
            g_bar_times[i] = time[src_index];
        }
    }
    
    return true;
}

/**
 * Processa detecção de padrões
 */
void ProcessPatternDetection(int rates_total)
{
    // Verificar se há dados suficientes
    if(ArraySize(g_close_prices) < 50)
        return;
    
    // Detectar padrão atual
    PatternDetectionResult result;
    InitializePatternDetectionResult(result);
    
    // Executar detecção baseada no padrão configurado
    bool pattern_found = DetectCurrentPattern(result);
    
    if(pattern_found)
    {
        // Aplicar filtros de mercado
        ApplyMarketFilters(result);
        
        if(g_market_filters.all_filters_passed)
        {
            // Processar sinal
            ProcessDetectedSignal(result, rates_total);
        }
    }
    
    // Salvar último resultado
    g_last_pattern_result = result;
}

/**
 * Detecta padrão atual
 */
bool DetectCurrentPattern(PatternDetectionResult &result)
{
    // Implementação simplificada da detecção de padrões MHI
    // Em ambiente real, aqui seria implementada a lógica específica de cada padrão
    
    int bars_to_analyze = MathMin(ArraySize(g_close_prices), 20);
    if(bars_to_analyze < 10)
        return false;
    
    // Lógica básica de detecção (exemplo para MHI1)
    bool call_pattern = false;
    bool put_pattern = false;
    double confidence = 0.0;
    
    // Analisar últimas barras para padrão
    for(int i = 1; i < bars_to_analyze - 1; i++)
    {
        // Exemplo: detectar reversão de alta (CALL)
        if(g_close_prices[i] < g_open_prices[i] && // Barra vermelha
           g_close_prices[i-1] > g_open_prices[i-1] && // Barra anterior verde
           g_close_prices[i] < g_close_prices[i+1]) // Preço subindo
        {
            call_pattern = true;
            confidence = 75.0;
            break;
        }
        
        // Exemplo: detectar reversão de baixa (PUT)
        if(g_close_prices[i] > g_open_prices[i] && // Barra verde
           g_close_prices[i-1] < g_open_prices[i-1] && // Barra anterior vermelha
           g_close_prices[i] > g_close_prices[i+1]) // Preço descendo
        {
            put_pattern = true;
            confidence = 75.0;
            break;
        }
    }
    
    // Aplicar inversão se habilitada
    if(g_pattern_inversion_enabled)
    {
        bool temp = call_pattern;
        call_pattern = put_pattern;
        put_pattern = temp;
    }
    
    // Verificar se padrão foi encontrado
    if(call_pattern || put_pattern)
    {
        result.pattern_detected = true;
        result.pattern_type = g_current_pattern;
        result.is_call = call_pattern;
        result.confidence = confidence;
        result.signal_price = g_close_prices[0];
        result.detection_time = g_bar_times[0];
        
        return true;
    }
    
    return false;
}

/**
 * Aplica filtros de mercado
 */
void ApplyMarketFilters(PatternDetectionResult &result)
{
    InitializeMarketFilters(g_market_filters);
    
    // Filtro ATR (volatilidade)
    if(g_config.filters.enable_atr && g_atr_handle != INVALID_HANDLE)
    {
        double atr_values[1];
        if(CopyBuffer(g_atr_handle, 0, 0, 1, atr_values) > 0)
        {
            double current_atr = atr_values[0];
            double min_volatility = current_atr * g_config.filters.atr_multiplier;
            
            // Verificar se há volatilidade suficiente
            double price_range = g_high_prices[0] - g_low_prices[0];
            g_market_filters.atr_filter_passed = (price_range >= min_volatility);
        }
    }
    
    // Filtro Bollinger Bands (consolidação)
    if(g_config.filters.enable_bollinger && g_bollinger_handle != INVALID_HANDLE)
    {
        double upper_band[1], lower_band[1];
        if(CopyBuffer(g_bollinger_handle, 1, 0, 1, upper_band) > 0 &&
           CopyBuffer(g_bollinger_handle, 2, 0, 1, lower_band) > 0)
        {
            double band_width = upper_band[0] - lower_band[0];
            double price_position = (g_close_prices[0] - lower_band[0]) / band_width;
            
            // Evitar sinais no meio das bandas (consolidação)
            g_market_filters.bollinger_filter_passed = (price_position < 0.2 || price_position > 0.8);
        }
    }
    
    // Filtro de tendência
    if(g_config.filters.enable_trend && g_ma_handle != INVALID_HANDLE)
    {
        double ma_values[2];
        if(CopyBuffer(g_ma_handle, 0, 0, 2, ma_values) > 0)
        {
            // Determinar direção da tendência
            if(ma_values[0] > ma_values[1])
                g_market_filters.trend_direction = 1; // Alta
            else if(ma_values[0] < ma_values[1])
                g_market_filters.trend_direction = -1; // Baixa
            else
                g_market_filters.trend_direction = 0; // Lateral
            
            // Filtro passa se sinal está na direção da tendência
            if(result.is_call && g_market_filters.trend_direction >= 0)
                g_market_filters.trend_filter_passed = true;
            else if(!result.is_call && g_market_filters.trend_direction <= 0)
                g_market_filters.trend_filter_passed = true;
            else
                g_market_filters.trend_filter_passed = false;
        }
    }
    
    // Verificar se todos os filtros passaram
    g_market_filters.all_filters_passed = 
        g_market_filters.atr_filter_passed &&
        g_market_filters.bollinger_filter_passed &&
        g_market_filters.trend_filter_passed;
}

/**
 * Processa sinal detectado
 */
void ProcessDetectedSignal(PatternDetectionResult &result, int rates_total)
{
    // Verificar confiança mínima
    if(result.confidence < g_config.patterns.min_confidence)
        return;
    
    // Criar informações do sinal
    SignalInfo signal;
    InitializeSignalInfo(signal);
    
    signal.signal_time = result.detection_time;
    signal.pattern_type = result.pattern_type;
    signal.is_call = result.is_call;
    signal.signal_price = result.signal_price;
    signal.confidence = result.confidence;
    signal.filter_passed = g_market_filters.all_filters_passed;
    
    // Processar financeiramente
    ProcessFinancialSignal(signal);
    
    // Plotar sinal no gráfico
    PlotSignalOnChart(signal, rates_total);
    
    // Enviar notificações
    SendNotifications(signal);
    
    // Salvar último sinal
    g_last_signal = signal;
    
    Print("SINAL DETECTADO: ", PatternTypeToString(signal.pattern_type), 
          " | ", (signal.is_call ? "CALL" : "PUT"),
          " | Confiança: ", DoubleToString(signal.confidence, 1), "%",
          " | Valor: ", FormatCurrency(signal.entry_value));
}

/**
 * Plota sinal no gráfico
 */
void PlotSignalOnChart(SignalInfo &signal, int rates_total)
{
    if(!g_config.visual.show_arrows)
        return;
    
    int buffer_index = rates_total - 1;
    
    if(signal.is_call)
    {
        CallBuffer[buffer_index] = signal.signal_price;
        PutBuffer[buffer_index] = EMPTY_VALUE;
    }
    else
    {
        CallBuffer[buffer_index] = EMPTY_VALUE;
        PutBuffer[buffer_index] = signal.signal_price;
    }
    
    ConfidenceBuffer[buffer_index] = signal.confidence;
}

/**
 * Envia notificações
 */
void SendNotifications(SignalInfo &signal)
{
    // Telegram
    if(g_telegram_initialized && g_config.notifications.enable_telegram)
    {
        SendSignalNotification(signal);
    }
    
    // MX2
    if(g_mx2_initialized && g_config.notifications.enable_mx2)
    {
        SendMX2Signal(signal);
    }
}

//+------------------------------------------------------------------+
//| Função de Evento de Timer                                       |
//+------------------------------------------------------------------+
void OnTimer()
{
    // Atualizar painel periodicamente
    UpdatePanel();
    
    // Verificar conexões de notificação
    if(g_config.notifications.enable_telegram && !g_telegram_initialized)
    {
        InitializeTelegram();
    }
    
    if(g_config.notifications.enable_mx2 && !g_mx2_initialized)
    {
        InitializeMX2();
    }
}

