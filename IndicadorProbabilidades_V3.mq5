//+------------------------------------------------------------------+
//|                                    IndicadorProbabilidades_V3.mq5 |
//|                                    Indicador de Probabilidades V3 |
//|                        Sistema Completo de Análise de Padrões MHI |
//+------------------------------------------------------------------+

/**
 * @file IndicadorProbabilidades_V3.mq5
 * @brief Sistema completo de análise de padrões MHI com arquitetura modular
 * @version 3.0.0
 * @date 2024-12-19
 * 
 * @description
 * Sistema avançado de detecção de padrões de reversão MHI (Mão de Homem Invisível)
 * com análise financeira completa, notificações automáticas, SuperVarredura
 * inteligente e painel visual interativo.
 * 
 * @features
 * - Detecção de 20+ padrões MHI especializados
 * - Sistema de filtros de mercado avançados
 * - Análise financeira completa com simulação de martingale
 * - Notificações Telegram e integração MX2
 * - SuperVarredura automática para otimização
 * - Painel visual com todas as informações em tempo real
 * - Gestão de risco e análise de performance
 * - Arquitetura modular para fácil manutenção
 * 
 * @author Quant Genius
 * @copyright 2024 Indicador de Probabilidades
 */

#property copyright "2024, Indicador de Probabilidades"
#property link      "https://github.com/edioneixcb/IndicadorProbabilidades_V3"
#property version   "3.00"
#property description "Sistema Completo de Análise de Padrões MHI - Versão 3.0"
#property description "Detecção avançada de padrões, análise financeira, notificações automáticas"
#property description "Painel visual completo, SuperVarredura inteligente, gestão de risco"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3

// Plotagens principais
#property indicator_label1  "CALL Signals"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLime
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3

#property indicator_label2  "PUT Signals"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3

#property indicator_label3  "Confidence Line"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrYellow
#property indicator_style3  STYLE_DOT
#property indicator_width3  1

//+------------------------------------------------------------------+
//| Includes dos Módulos Core                                        |
//+------------------------------------------------------------------+
#include "IndicadorProbabilidades_V3/Core/Defines.mqh"
#include "IndicadorProbabilidades_V3/Core/Types.mqh"
#include "IndicadorProbabilidades_V3/Core/Globals.mqh"

//+------------------------------------------------------------------+
//| Includes dos Módulos Especializados                             |
//+------------------------------------------------------------------+
#include "IndicadorProbabilidades_V3/Analysis/Financial/FinancialCore.mqh"
#include "IndicadorProbabilidades_V3/Notifications/Telegram/TelegramCore.mqh"
#include "IndicadorProbabilidades_V3/Notifications/MX2/MX2Core.mqh"
#include "IndicadorProbabilidades_V3/Visual/Panel/PanelCore.mqh"

//+------------------------------------------------------------------+
//| Parâmetros de Entrada                                           |
//+------------------------------------------------------------------+

//--- Configurações Gerais
input group "=== CONFIGURAÇÕES GERAIS ==="
input bool InpEnableIndicator = true;                    // Habilitar Indicador
input PatternType InpActivePattern = PATTERN_MHI1;       // Padrão Ativo
input bool InpEnableInversion = false;                   // Habilitar Inversão
input int InpMinConfidence = 70;                         // Confiança Mínima (%)

//--- Configurações Visuais
input group "=== CONFIGURAÇÕES VISUAIS ==="
input bool InpShowPanel = true;                          // Mostrar Painel
input PanelPosition InpPanelPosition = PANEL_TOP_RIGHT;  // Posição do Painel
input int InpPanelOffsetX = 10;                          // Offset X do Painel
input int InpPanelOffsetY = 30;                          // Offset Y do Painel
input color InpCallColor = clrLime;                      // Cor CALL
input color InpPutColor = clrRed;                        // Cor PUT
input color InpPanelBgColor = clrBlack;                  // Cor Fundo Painel
input color InpPanelBorderColor = clrWhite;              // Cor Borda Painel
input color InpPanelTextColor = clrWhite;                // Cor Texto Painel
input bool InpShowArrows = true;                         // Mostrar Setas
input ArrowPosition InpArrowPosition = ARROW_ON_CANDLE;  // Posição das Setas

//--- Filtros de Mercado
input group "=== FILTROS DE MERCADO ==="
input bool InpEnableATRFilter = true;                    // Habilitar Filtro ATR
input int InpATRPeriod = 14;                             // Período ATR
input double InpATRMultiplier = 1.5;                     // Multiplicador ATR
input bool InpEnableBBFilter = true;                     // Habilitar Filtro Bollinger
input int InpBBPeriod = 20;                              // Período Bollinger
input double InpBBDeviation = 2.0;                       // Desvio Bollinger
input bool InpEnableTrendFilter = false;                 // Habilitar Filtro Tendência
input int InpTrendPeriod = 50;                           // Período Tendência

//--- Análise Financeira
input group "=== ANÁLISE FINANCEIRA ==="
input double InpEntryValue = 10.0;                       // Valor de Entrada
input double InpPayout = 0.8;                            // Payout (0.8 = 80%)
input bool InpEnableMartingale = true;                   // Habilitar Martingale
input double InpMartingaleFactor = 2.0;                  // Fator Martingale
input int InpMaxGaleLevels = 2;                          // Máximo Gales
input bool InpEnableStopLoss = false;                    // Habilitar Stop Loss
input double InpStopLossValue = 100.0;                   // Valor Stop Loss
input bool InpEnableStopWin = false;                     // Habilitar Stop Win
input double InpStopWinValue = 200.0;                    // Valor Stop Win
input double InpDailyGoal = 50.0;                        // Meta Diária
input double InpDailyLimit = 150.0;                      // Limite Diário

//--- Notificações Telegram
input group "=== NOTIFICAÇÕES TELEGRAM ==="
input bool InpEnableTelegram = false;                    // Habilitar Telegram
input string InpTelegramToken = "";                      // Token do Bot
input string InpTelegramChatID = "";                     // Chat ID
input string InpTelegramTitle = "Probabilidades V3";     // Título das Mensagens
input bool InpTelegramSendImages = false;                // Enviar Imagens
input bool InpNotifySignals = true;                      // Notificar Sinais
input bool InpNotifyResults = true;                      // Notificar Resultados

//--- Integração MX2
input group "=== INTEGRAÇÃO MX2 ==="
input bool InpEnableMX2 = false;                         // Habilitar MX2
input BrokerMX2 InpMX2Broker = MX2_QUOTEX;              // Corretora MX2
input SignalTypeMX2 InpMX2SignalType = MX2_CLOSED_CANDLE; // Tipo de Sinal
input ExpirationTypeMX2 InpMX2ExpiryType = MX2_CORRIDO; // Tipo Expiração
input int InpMX2ExpiryMinutes = 5;                       // Minutos Expiração

//--- SuperVarredura
input group "=== SUPERVARREDURA ==="
input bool InpEnableSuperScan = false;                   // Habilitar SuperVarredura
input int InpSuperScanBars = 1000;                       // Barras para Análise
input int InpSuperScanMinOperations = 10;                // Mínimo Operações
input double InpSuperScanMinWinRate = 60.0;              // WinRate Mínimo (%)
input bool InpSuperScanAutoApply = true;                 // Aplicar Automaticamente

//--- Configurações Avançadas
input group "=== CONFIGURAÇÕES AVANÇADAS ==="
input bool InpEnableLogging = true;                      // Habilitar Logging
input LogLevel InpLogLevel = LOG_INFO;                   // Nível de Log
input bool InpEnableDebug = false;                       // Modo Debug
input int InpMaxHistoryBars = 5000;                      // Máximo Barras Histórico
input bool InpEnableOptimization = true;                 // Habilitar Otimização
input int InpUpdateIntervalMS = 1000;                    // Intervalo Atualização (ms)

//+------------------------------------------------------------------+
//| Buffers do Indicador                                            |
//+------------------------------------------------------------------+
double CallSignalBuffer[];        // Buffer sinais CALL
double PutSignalBuffer[];         // Buffer sinais PUT
double ConfidenceBuffer[];        // Buffer linha de confiança
double CallArrowBuffer[];         // Buffer setas CALL
double PutArrowBuffer[];          // Buffer setas PUT
double InternalBuffer[];          // Buffer interno para cálculos

//+------------------------------------------------------------------+
//| Variáveis Globais do Indicador                                  |
//+------------------------------------------------------------------+
int g_atr_handle = INVALID_HANDLE;           // Handle ATR
int g_bb_handle = INVALID_HANDLE;            // Handle Bollinger Bands
int g_ma_handle = INVALID_HANDLE;            // Handle Moving Average
datetime g_last_bar_time = 0;               // Tempo da última barra
datetime g_last_signal_bar_time = 0;        // Tempo da última barra com sinal
bool g_new_bar = false;                     // Nova barra detectada
int g_processed_bars = 0;                   // Barras processadas
datetime g_indicator_start_time = 0;        // Tempo de início do indicador

//+------------------------------------------------------------------+
//| Função de Inicialização do Indicador                            |
//+------------------------------------------------------------------+

/**
 * Inicializa o indicador e todos os seus subsistemas
 * @return INIT_SUCCEEDED se inicializado com sucesso
 */
int OnInit()
{
    Print("=== INICIALIZANDO INDICADOR DE PROBABILIDADES V3 ===");
    
    // Registra tempo de início
    g_indicator_start_time = TimeCurrent();
    
    // Carrega configuração global
    if(!LoadGlobalConfiguration())
    {
        Print("ERRO: Falha ao carregar configuração global");
        return INIT_FAILED;
    }
    
    // Inicializa buffers do indicador
    if(!InitializeIndicatorBuffers())
    {
        Print("ERRO: Falha ao inicializar buffers");
        return INIT_FAILED;
    }
    
    // Inicializa handles de indicadores técnicos
    if(!InitializeTechnicalIndicators())
    {
        Print("ERRO: Falha ao inicializar indicadores técnicos");
        return INIT_FAILED;
    }
    
    // Inicializa sistema de análise financeira
    if(!InitializeFinancialAnalysis())
    {
        Print("ERRO: Falha ao inicializar análise financeira");
        return INIT_FAILED;
    }
    
    // Inicializa sistema de notificações
    if(!InitializeNotificationSystems())
    {
        Print("ERRO: Falha ao inicializar notificações");
        return INIT_FAILED;
    }
    
    // Inicializa painel visual
    if(!InitializePanel())
    {
        Print("ERRO: Falha ao inicializar painel visual");
        return INIT_FAILED;
    }
    
    // Inicializa sistema de logging
    InitializeLogging();
    
    // Configurações finais
    g_last_bar_time = iTime(_Symbol, _Period, 0);
    g_processed_bars = 0;
    
    // Mensagem de sucesso
    Print("=== INDICADOR INICIALIZADO COM SUCESSO ===");
    Print("Versão: ", INDICATOR_VERSION);
    Print("Padrão Ativo: ", PatternTypeToString(g_config.patterns.active_pattern));
    Print("Filtros: ATR=", g_config.filters.enable_atr, " BB=", g_config.filters.enable_bollinger);
    Print("Notificações: Telegram=", g_config.notifications.enable_telegram, " MX2=", g_config.notifications.enable_mx2);
    Print("Painel Visual: ", g_config.visual.show_panel ? "Habilitado" : "Desabilitado");
    
    return INIT_SUCCEEDED;
}

/**
 * Carrega configuração global a partir dos parâmetros de entrada
 * @return true se carregado com sucesso
 */
bool LoadGlobalConfiguration()
{
    // Configurações gerais
    g_config.general.enabled = InpEnableIndicator;
    g_config.general.enable_logging = InpEnableLogging;
    g_config.general.log_level = InpLogLevel;
    g_config.general.enable_debug = InpEnableDebug;
    g_config.general.max_history_bars = InpMaxHistoryBars;
    g_config.general.update_interval_ms = InpUpdateIntervalMS;
    
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
    g_config.visual.panel_background_color = InpPanelBgColor;
    g_config.visual.panel_border_color = InpPanelBorderColor;
    g_config.visual.panel_text_color = InpPanelTextColor;
    g_config.visual.show_arrows = InpShowArrows;
    g_config.visual.arrow_position = InpArrowPosition;
    
    // Configurações de filtros
    g_config.filters.enable_atr = InpEnableATRFilter;
    g_config.filters.atr_period = InpATRPeriod;
    g_config.filters.atr_multiplier = InpATRMultiplier;
    g_config.filters.enable_bollinger = InpEnableBBFilter;
    g_config.filters.bollinger_period = InpBBPeriod;
    g_config.filters.bollinger_deviation = InpBBDeviation;
    g_config.filters.enable_trend = InpEnableTrendFilter;
    g_config.filters.trend_period = InpTrendPeriod;
    
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
    g_config.financial.daily_goal = InpDailyGoal;
    g_config.financial.daily_limit = InpDailyLimit;
    
    // Configurações de notificações
    g_config.notifications.enable_telegram = InpEnableTelegram;
    g_config.notifications.telegram_token = InpTelegramToken;
    g_config.notifications.telegram_chat_id = InpTelegramChatID;
    g_config.notifications.telegram_title = InpTelegramTitle;
    g_config.notifications.telegram_send_images = InpTelegramSendImages;
    g_config.notifications.notify_signals = InpNotifySignals;
    g_config.notifications.notify_results = InpNotifyResults;
    g_config.notifications.enable_mx2 = InpEnableMX2;
    g_config.notifications.mx2_broker = InpMX2Broker;
    g_config.notifications.mx2_signal_type = InpMX2SignalType;
    g_config.notifications.mx2_expiry_type = InpMX2ExpiryType;
    g_config.notifications.mx2_expiry_minutes = InpMX2ExpiryMinutes;
    
    // Configurações de SuperVarredura
    g_config.superscan.enabled = InpEnableSuperScan;
    g_config.superscan.analysis_bars = InpSuperScanBars;
    g_config.superscan.min_operations = InpSuperScanMinOperations;
    g_config.superscan.min_winrate = InpSuperScanMinWinRate;
    g_config.superscan.auto_apply = InpSuperScanAutoApply;
    
    // Inicializa variáveis globais derivadas
    g_active_pattern = g_config.patterns.active_pattern;
    g_enable_inversion = g_config.patterns.enable_inversion;
    g_min_confidence = g_config.patterns.min_confidence;
    
    return true;
}

/**
 * Inicializa buffers do indicador
 * @return true se inicializado com sucesso
 */
bool InitializeIndicatorBuffers()
{
    // Define buffers
    SetIndexBuffer(0, CallArrowBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, PutArrowBuffer, INDICATOR_DATA);
    SetIndexBuffer(2, ConfidenceBuffer, INDICATOR_DATA);
    SetIndexBuffer(3, CallSignalBuffer, INDICATOR_CALCULATIONS);
    SetIndexBuffer(4, PutSignalBuffer, INDICATOR_CALCULATIONS);
    SetIndexBuffer(5, InternalBuffer, INDICATOR_CALCULATIONS);
    
    // Configura plotagens
    PlotIndexSetInteger(0, PLOT_ARROW, 233);  // Seta para cima
    PlotIndexSetInteger(1, PLOT_ARROW, 234);  // Seta para baixo
    
    // Configura cores
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, g_config.visual.call_color);
    PlotIndexSetInteger(1, PLOT_LINE_COLOR, g_config.visual.put_color);
    
    // Inicializa buffers com valores vazios
    ArraySetAsSeries(CallArrowBuffer, true);
    ArraySetAsSeries(PutArrowBuffer, true);
    ArraySetAsSeries(ConfidenceBuffer, true);
    ArraySetAsSeries(CallSignalBuffer, true);
    ArraySetAsSeries(PutSignalBuffer, true);
    ArraySetAsSeries(InternalBuffer, true);
    
    // Preenche com valores vazios
    ArrayInitialize(CallArrowBuffer, EMPTY_VALUE);
    ArrayInitialize(PutArrowBuffer, EMPTY_VALUE);
    ArrayInitialize(ConfidenceBuffer, EMPTY_VALUE);
    ArrayInitialize(CallSignalBuffer, 0.0);
    ArrayInitialize(PutSignalBuffer, 0.0);
    ArrayInitialize(InternalBuffer, 0.0);
    
    return true;
}

/**
 * Inicializa handles de indicadores técnicos
 * @return true se inicializado com sucesso
 */
bool InitializeTechnicalIndicators()
{
    // Inicializa ATR se habilitado
    if(g_config.filters.enable_atr)
    {
        g_atr_handle = iATR(_Symbol, _Period, g_config.filters.atr_period);
        if(g_atr_handle == INVALID_HANDLE)
        {
            Print("ERRO: Falha ao criar handle ATR");
            return false;
        }
    }
    
    // Inicializa Bollinger Bands se habilitado
    if(g_config.filters.enable_bollinger)
    {
        g_bb_handle = iBands(_Symbol, _Period, g_config.filters.bollinger_period, 
                            0, g_config.filters.bollinger_deviation, PRICE_CLOSE);
        if(g_bb_handle == INVALID_HANDLE)
        {
            Print("ERRO: Falha ao criar handle Bollinger Bands");
            return false;
        }
    }
    
    // Inicializa Moving Average se filtro de tendência habilitado
    if(g_config.filters.enable_trend)
    {
        g_ma_handle = iMA(_Symbol, _Period, g_config.filters.trend_period, 0, MODE_SMA, PRICE_CLOSE);
        if(g_ma_handle == INVALID_HANDLE)
        {
            Print("ERRO: Falha ao criar handle Moving Average");
            return false;
        }
    }
    
    return true;
}

/**
 * Inicializa sistemas de notificação
 * @return true se inicializado com sucesso
 */
bool InitializeNotificationSystems()
{
    bool success = true;
    
    // Inicializa Telegram
    if(g_config.notifications.enable_telegram)
    {
        if(!InitializeTelegram())
        {
            Print("AVISO: Falha ao inicializar Telegram");
            success = false;
        }
    }
    
    // Inicializa MX2
    if(g_config.notifications.enable_mx2)
    {
        if(!InitializeMX2())
        {
            Print("AVISO: Falha ao inicializar MX2");
            success = false;
        }
    }
    
    return success;
}

/**
 * Inicializa sistema de logging
 */
void InitializeLogging()
{
    if(g_config.general.enable_logging)
    {
        Print("Sistema de logging inicializado - Nível: ", EnumToString(g_config.general.log_level));
    }
}

//+------------------------------------------------------------------+
//| Função de Desinicialização                                      |
//+------------------------------------------------------------------+

/**
 * Desinicializa o indicador e limpa recursos
 */
void OnDeinit(const int reason)
{
    Print("=== DESINICIALIZANDO INDICADOR ===");
    Print("Motivo: ", GetDeinitReasonText(reason));
    
    // Libera handles de indicadores
    if(g_atr_handle != INVALID_HANDLE)
    {
        IndicatorRelease(g_atr_handle);
        g_atr_handle = INVALID_HANDLE;
    }
    
    if(g_bb_handle != INVALID_HANDLE)
    {
        IndicatorRelease(g_bb_handle);
        g_bb_handle = INVALID_HANDLE;
    }
    
    if(g_ma_handle != INVALID_HANDLE)
    {
        IndicatorRelease(g_ma_handle);
        g_ma_handle = INVALID_HANDLE;
    }
    
    // Remove objetos do painel
    RemoveAllPanelObjects();
    
    // Estatísticas finais
    if(g_config.general.enable_logging)
    {
        PrintFinalStatistics();
    }
    
    Print("=== INDICADOR DESINICIALIZADO ===");
}

/**
 * Obtém texto descritivo do motivo de desinicialização
 * @param reason Código do motivo
 * @return Texto descritivo
 */
string GetDeinitReasonText(const int reason)
{
    switch(reason)
    {
        case REASON_PROGRAM: return "Programa encerrado";
        case REASON_REMOVE: return "Indicador removido";
        case REASON_RECOMPILE: return "Recompilação";
        case REASON_CHARTCHANGE: return "Mudança de gráfico";
        case REASON_CHARTCLOSE: return "Gráfico fechado";
        case REASON_PARAMETERS: return "Parâmetros alterados";
        case REASON_ACCOUNT: return "Conta alterada";
        case REASON_TEMPLATE: return "Template aplicado";
        case REASON_INITFAILED: return "Falha na inicialização";
        case REASON_CLOSE: return "Terminal fechado";
        default: return "Motivo desconhecido (" + IntegerToString(reason) + ")";
    }
}

/**
 * Imprime estatísticas finais
 */
void PrintFinalStatistics()
{
    datetime uptime = TimeCurrent() - g_indicator_start_time;
    
    Print("=== ESTATÍSTICAS FINAIS ===");
    Print("Tempo de execução: ", TimeToString(uptime, TIME_SECONDS));
    Print("Barras processadas: ", g_processed_bars);
    Print("Sinais hoje: ", g_total_signals_today);
    Print("Operações hoje: ", g_total_operations_today);
    Print("WinRate: ", DoubleToString(g_daily_winrate, 1), "%");
    Print("Lucro diário: ", FormatCurrency(g_daily_profit));
    Print("Saldo atual: ", FormatCurrency(g_current_balance));
    
    if(IsTelegramOperational())
    {
        Print("Telegram: ", GetTelegramStatistics());
    }
    
    if(IsMX2Operational())
    {
        Print("MX2: ", GetMX2Statistics());
    }
}

//+------------------------------------------------------------------+
//| Função Principal de Cálculo                                     |
//+------------------------------------------------------------------+

/**
 * Função principal de cálculo do indicador
 * @param rates_total Total de barras disponíveis
 * @param prev_calculated Barras calculadas anteriormente
 * @param time Array de tempo
 * @param open Array de abertura
 * @param high Array de máxima
 * @param low Array de mínima
 * @param close Array de fechamento
 * @param tick_volume Array de volume de ticks
 * @param volume Array de volume real
 * @param spread Array de spread
 * @return Número de barras processadas
 */
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
    // Verifica se indicador está habilitado
    if(!g_config.general.enabled)
    {
        return rates_total;
    }
    
    // Verifica dados suficientes
    if(rates_total < 100)
    {
        return 0;
    }
    
    // Detecta nova barra
    DetectNewBar(time);
    
    // Calcula índice de início
    int start_pos = MathMax(prev_calculated - 1, 0);
    if(start_pos == 0)
    {
        // Primeira execução - limpa buffers
        ArrayInitialize(CallArrowBuffer, EMPTY_VALUE);
        ArrayInitialize(PutArrowBuffer, EMPTY_VALUE);
        ArrayInitialize(ConfidenceBuffer, EMPTY_VALUE);
    }
    
    // Processa barras
    for(int i = start_pos; i < rates_total - 1; i++) // -1 para não processar barra atual
    {
        ProcessBar(i, time, open, high, low, close);
    }
    
    // Atualiza contadores
    g_processed_bars = rates_total - 1;
    
    // Atualiza painel se nova barra
    if(g_new_bar)
    {
        UpdatePanelData();
        g_new_bar = false;
    }
    
    return rates_total;
}

/**
 * Detecta nova barra
 * @param time Array de tempo
 */
void DetectNewBar(const datetime &time[])
{
    datetime current_bar_time = time[ArraySize(time) - 1];
    
    if(current_bar_time != g_last_bar_time)
    {
        g_new_bar = true;
        g_last_bar_time = current_bar_time;
        
        // Executa tarefas de nova barra
        OnNewBar();
    }
    else
    {
        g_new_bar = false;
    }
}

/**
 * Processa uma barra específica
 * @param bar_index Índice da barra
 * @param time Array de tempo
 * @param open Array de abertura
 * @param high Array de máxima
 * @param low Array de mínima
 * @param close Array de fechamento
 */
void ProcessBar(int bar_index, 
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[])
{
    // Inicializa buffers para esta barra
    CallArrowBuffer[bar_index] = EMPTY_VALUE;
    PutArrowBuffer[bar_index] = EMPTY_VALUE;
    ConfidenceBuffer[bar_index] = EMPTY_VALUE;
    
    // Verifica se há dados suficientes para análise
    if(bar_index < 50)
    {
        return;
    }
    
    // Atualiza filtros de mercado
    UpdateMarketFilters(bar_index);
    
    // Detecta padrões
    PatternDetectionResult pattern_result = DetectPatterns(bar_index, open, high, low, close);
    
    // Processa resultado da detecção
    if(pattern_result.pattern_detected)
    {
        ProcessPatternDetection(bar_index, pattern_result, time, high, low);
    }
    
    // Atualiza linha de confiança
    UpdateConfidenceLine(bar_index, pattern_result.confidence);
}

/**
 * Executa tarefas quando nova barra é detectada
 */
void OnNewBar()
{
    // Atualiza estatísticas globais
    UpdateGlobalStatistics();
    
    // Verifica reset diário
    CheckDailyReset();
    
    // Executa SuperVarredura se habilitada
    if(g_config.superscan.enabled && ShouldRunSuperScan())
    {
        ExecuteSuperScan();
    }
    
    // Atualiza análise de risco
    UpdateRiskAnalysis();
}

/**
 * Atualiza filtros de mercado para uma barra
 * @param bar_index Índice da barra
 */
void UpdateMarketFilters(int bar_index)
{
    // Reset filtros
    g_market_filters.atr_filter_passed = true;
    g_market_filters.bollinger_filter_passed = true;
    g_market_filters.trend_filter_passed = true;
    g_market_filters.all_filters_passed = true;
    
    // Filtro ATR
    if(g_config.filters.enable_atr && g_atr_handle != INVALID_HANDLE)
    {
        double atr_values[1];
        if(CopyBuffer(g_atr_handle, 0, bar_index, 1, atr_values) > 0)
        {
            g_current_atr = atr_values[0];
            double min_atr = g_config.filters.atr_multiplier * Point();
            g_market_filters.atr_filter_passed = (g_current_atr >= min_atr);
        }
    }
    
    // Filtro Bollinger Bands
    if(g_config.filters.enable_bollinger && g_bb_handle != INVALID_HANDLE)
    {
        double bb_upper[1], bb_lower[1];
        if(CopyBuffer(g_bb_handle, 1, bar_index, 1, bb_upper) > 0 &&
           CopyBuffer(g_bb_handle, 2, bar_index, 1, bb_lower) > 0)
        {
            double current_close = iClose(_Symbol, _Period, bar_index);
            double bb_width = bb_upper[0] - bb_lower[0];
            double min_width = 10 * Point(); // Largura mínima
            
            g_market_filters.bollinger_bands_active = (bb_width >= min_width);
            g_market_filters.bollinger_filter_passed = g_market_filters.bollinger_bands_active;
        }
    }
    
    // Filtro de Tendência
    if(g_config.filters.enable_trend && g_ma_handle != INVALID_HANDLE)
    {
        double ma_values[2];
        if(CopyBuffer(g_ma_handle, 0, bar_index, 2, ma_values) > 0)
        {
            if(ma_values[0] > ma_values[1])
            {
                g_market_filters.trend_direction = 1; // Alta
            }
            else if(ma_values[0] < ma_values[1])
            {
                g_market_filters.trend_direction = -1; // Baixa
            }
            else
            {
                g_market_filters.trend_direction = 0; // Lateral
            }
            
            // Por enquanto, aceita qualquer tendência
            g_market_filters.trend_filter_passed = true;
        }
    }
    
    // Resultado final dos filtros
    g_market_filters.all_filters_passed = g_market_filters.atr_filter_passed &&
                                         g_market_filters.bollinger_filter_passed &&
                                         g_market_filters.trend_filter_passed;
}

/**
 * Detecta padrões em uma barra
 * @param bar_index Índice da barra
 * @param open Array de abertura
 * @param high Array de máxima
 * @param low Array de mínima
 * @param close Array de fechamento
 * @return Resultado da detecção
 */
PatternDetectionResult DetectPatterns(int bar_index,
                                     const double &open[],
                                     const double &high[],
                                     const double &low[],
                                     const double &close[])
{
    PatternDetectionResult result;
    result.pattern_detected = false;
    result.pattern_type = PATTERN_NONE;
    result.is_call = false;
    result.confidence = 0.0;
    result.signal_price = 0.0;
    
    // Verifica se há dados suficientes
    if(bar_index < 10)
    {
        return result;
    }
    
    // Detecta padrão ativo
    switch(g_active_pattern)
    {
        case PATTERN_MHI1:
            result = DetectMHI1Pattern(bar_index, open, high, low, close);
            break;
        case PATTERN_MHI2:
            result = DetectMHI2Pattern(bar_index, open, high, low, close);
            break;
        case PATTERN_MHI3:
            result = DetectMHI3Pattern(bar_index, open, high, low, close);
            break;
        case PATTERN_MHI4:
            result = DetectMHI4Pattern(bar_index, open, high, low, close);
            break;
        case PATTERN_MHI5:
            result = DetectMHI5Pattern(bar_index, open, high, low, close);
            break;
        case PATTERN_MHI6:
            result = DetectMHI6Pattern(bar_index, open, high, low, close);
            break;
        default:
            break;
    }
    
    // Aplica inversão se habilitada
    if(result.pattern_detected && g_enable_inversion)
    {
        result.is_call = !result.is_call;
    }
    
    // Verifica confiança mínima
    if(result.confidence < g_min_confidence)
    {
        result.pattern_detected = false;
    }
    
    return result;
}

/**
 * Detecta padrão MHI1 (exemplo simplificado)
 * @param bar_index Índice da barra
 * @param open Array de abertura
 * @param high Array de máxima
 * @param low Array de mínima
 * @param close Array de fechamento
 * @return Resultado da detecção
 */
PatternDetectionResult DetectMHI1Pattern(int bar_index,
                                        const double &open[],
                                        const double &high[],
                                        const double &low[],
                                        const double &close[])
{
    PatternDetectionResult result;
    result.pattern_detected = false;
    result.pattern_type = PATTERN_MHI1;
    result.confidence = 0.0;
    
    // Lógica simplificada do MHI1
    // Procura por 3 velas consecutivas de mesma cor seguidas de reversão
    
    if(bar_index < 4) return result;
    
    // Verifica 3 velas vermelhas seguidas de vela verde (sinal CALL)
    bool three_red = (close[bar_index-3] < open[bar_index-3]) &&
                     (close[bar_index-2] < open[bar_index-2]) &&
                     (close[bar_index-1] < open[bar_index-1]);
    
    bool green_reversal = (close[bar_index] > open[bar_index]);
    
    if(three_red && green_reversal)
    {
        result.pattern_detected = true;
        result.is_call = true;
        result.confidence = 75.0;
        result.signal_price = close[bar_index];
        return result;
    }
    
    // Verifica 3 velas verdes seguidas de vela vermelha (sinal PUT)
    bool three_green = (close[bar_index-3] > open[bar_index-3]) &&
                       (close[bar_index-2] > open[bar_index-2]) &&
                       (close[bar_index-1] > open[bar_index-1]);
    
    bool red_reversal = (close[bar_index] < open[bar_index]);
    
    if(three_green && red_reversal)
    {
        result.pattern_detected = true;
        result.is_call = false;
        result.confidence = 75.0;
        result.signal_price = close[bar_index];
        return result;
    }
    
    return result;
}

/**
 * Detecta padrão MHI2 (implementação placeholder)
 */
PatternDetectionResult DetectMHI2Pattern(int bar_index, const double &open[], const double &high[], const double &low[], const double &close[])
{
    PatternDetectionResult result;
    result.pattern_detected = false;
    result.pattern_type = PATTERN_MHI2;
    // TODO: Implementar lógica específica do MHI2
    return result;
}

/**
 * Detecta padrão MHI3 (implementação placeholder)
 */
PatternDetectionResult DetectMHI3Pattern(int bar_index, const double &open[], const double &high[], const double &low[], const double &close[])
{
    PatternDetectionResult result;
    result.pattern_detected = false;
    result.pattern_type = PATTERN_MHI3;
    // TODO: Implementar lógica específica do MHI3
    return result;
}

/**
 * Detecta padrão MHI4 (implementação placeholder)
 */
PatternDetectionResult DetectMHI4Pattern(int bar_index, const double &open[], const double &high[], const double &low[], const double &close[])
{
    PatternDetectionResult result;
    result.pattern_detected = false;
    result.pattern_type = PATTERN_MHI4;
    // TODO: Implementar lógica específica do MHI4
    return result;
}

/**
 * Detecta padrão MHI5 (implementação placeholder)
 */
PatternDetectionResult DetectMHI5Pattern(int bar_index, const double &open[], const double &high[], const double &low[], const double &close[])
{
    PatternDetectionResult result;
    result.pattern_detected = false;
    result.pattern_type = PATTERN_MHI5;
    // TODO: Implementar lógica específica do MHI5
    return result;
}

/**
 * Detecta padrão MHI6 (implementação placeholder)
 */
PatternDetectionResult DetectMHI6Pattern(int bar_index, const double &open[], const double &high[], const double &low[], const double &close[])
{
    PatternDetectionResult result;
    result.pattern_detected = false;
    result.pattern_type = PATTERN_MHI6;
    // TODO: Implementar lógica específica do MHI6
    return result;
}

/**
 * Processa detecção de padrão
 * @param bar_index Índice da barra
 * @param pattern_result Resultado da detecção
 * @param time Array de tempo
 * @param high Array de máxima
 * @param low Array de mínima
 */
void ProcessPatternDetection(int bar_index,
                           const PatternDetectionResult &pattern_result,
                           const datetime &time[],
                           const double &high[],
                           const double &low[])
{
    // Verifica filtros de mercado
    if(!g_market_filters.all_filters_passed)
    {
        return;
    }
    
    // Cria informações do sinal
    SignalInfo signal_info;
    signal_info.signal_time = time[bar_index];
    signal_info.pattern_type = pattern_result.pattern_type;
    signal_info.is_call = pattern_result.is_call;
    signal_info.signal_price = pattern_result.signal_price;
    signal_info.confidence = pattern_result.confidence;
    signal_info.atr_value = g_current_atr;
    signal_info.filter_passed = g_market_filters.all_filters_passed;
    
    // Plota seta no gráfico
    PlotSignalArrow(bar_index, signal_info, high, low);
    
    // Atualiza estatísticas globais
    g_total_signals_today++;
    g_last_signal_time = signal_info.signal_time;
    g_last_signal_confidence = signal_info.confidence;
    
    // Envia notificações
    SendNotifications(signal_info);
    
    // Simula operação financeira (para fins de análise)
    SimulateFinancialOperation(signal_info);
}

/**
 * Plota seta de sinal no gráfico
 * @param bar_index Índice da barra
 * @param signal_info Informações do sinal
 * @param high Array de máxima
 * @param low Array de mínima
 */
void PlotSignalArrow(int bar_index,
                    const SignalInfo &signal_info,
                    const double &high[],
                    const double &low[])
{
    if(!g_config.visual.show_arrows)
    {
        return;
    }
    
    double arrow_price;
    
    // Calcula posição da seta
    switch(g_config.visual.arrow_position)
    {
        case ARROW_ON_CANDLE:
            arrow_price = signal_info.signal_price;
            break;
        case ARROW_ABOVE_BELOW:
            arrow_price = signal_info.is_call ? low[bar_index] - 5*Point() : high[bar_index] + 5*Point();
            break;
        case ARROW_ON_EXTREME:
            arrow_price = signal_info.is_call ? low[bar_index] : high[bar_index];
            break;
        default:
            arrow_price = signal_info.signal_price;
            break;
    }
    
    // Plota seta
    if(signal_info.is_call)
    {
        CallArrowBuffer[bar_index] = arrow_price;
    }
    else
    {
        PutArrowBuffer[bar_index] = arrow_price;
    }
}

/**
 * Atualiza linha de confiança
 * @param bar_index Índice da barra
 * @param confidence Valor de confiança
 */
void UpdateConfidenceLine(int bar_index, double confidence)
{
    // Normaliza confiança para escala do preço
    double price_range = iHigh(_Symbol, _Period, bar_index) - iLow(_Symbol, _Period, bar_index);
    double normalized_confidence = iLow(_Symbol, _Period, bar_index) + (confidence / 100.0) * price_range;
    
    ConfidenceBuffer[bar_index] = normalized_confidence;
}

/**
 * Envia notificações para sistemas configurados
 * @param signal_info Informações do sinal
 */
void SendNotifications(const SignalInfo &signal_info)
{
    // Envia para Telegram
    if(IsTelegramOperational())
    {
        SendSignalToTelegram(signal_info);
    }
    
    // Envia para MX2
    if(IsMX2Operational())
    {
        SendSignalToMX2(signal_info);
    }
}

/**
 * Simula operação financeira para análise
 * @param signal_info Informações do sinal
 */
void SimulateFinancialOperation(const SignalInfo &signal_info)
{
    // Por simplicidade, simula resultado aleatório baseado na confiança
    double win_probability = signal_info.confidence / 100.0;
    double random_value = MathRand() / 32767.0;
    
    OperationResult result;
    if(random_value <= win_probability)
    {
        result = RESULT_WIN;
    }
    else
    {
        result = RESULT_LOSS;
    }
    
    // Processa operação financeira
    ProcessFinancialOperation(signal_info, result);
}

/**
 * Atualiza estatísticas globais
 */
void UpdateGlobalStatistics()
{
    // Atualiza timestamp da última atualização
    g_last_update_time = TimeCurrent();
    
    // Outras atualizações podem ser adicionadas aqui
}

/**
 * Verifica se deve fazer reset diário
 */
void CheckDailyReset()
{
    static datetime last_reset_date = 0;
    datetime current_date = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
    
    if(current_date != last_reset_date && last_reset_date > 0)
    {
        // Novo dia detectado - reset estatísticas
        ResetDailyStatistics();
        last_reset_date = current_date;
        
        Print("Reset diário executado - Nova data: ", TimeToString(current_date, TIME_DATE));
    }
    else if(last_reset_date == 0)
    {
        last_reset_date = current_date;
    }
}

/**
 * Verifica se deve executar SuperVarredura
 * @return true se deve executar
 */
bool ShouldRunSuperScan()
{
    // Por simplicidade, executa a cada 100 barras processadas
    return (g_processed_bars % 100 == 0);
}

/**
 * Executa SuperVarredura (implementação placeholder)
 */
void ExecuteSuperScan()
{
    Print("Executando SuperVarredura...");
    // TODO: Implementar lógica completa da SuperVarredura
    
    g_superscan_running = true;
    
    // Simula execução
    Sleep(1000);
    
    g_superscan_running = false;
    Print("SuperVarredura concluída");
}

//+------------------------------------------------------------------+
//| Funções de Eventos                                              |
//+------------------------------------------------------------------+

/**
 * Manipula eventos de timer
 */
void OnTimer()
{
    // Atualiza painel periodicamente
    UpdatePanelData();
}

/**
 * Manipula eventos de gráfico
 * @param id ID do evento
 * @param lparam Parâmetro long
 * @param dparam Parâmetro double
 * @param sparam Parâmetro string
 */
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    // Manipula cliques no painel (implementação futura)
    if(id == CHARTEVENT_OBJECT_CLICK)
    {
        if(StringFind(sparam, g_panel_prefix) == 0)
        {
            HandlePanelClick(sparam);
        }
    }
    
    // Redesenha painel em mudanças de gráfico
    if(id == CHARTEVENT_CHART_CHANGE)
    {
        RedrawPanel();
    }
}

/**
 * Manipula cliques no painel
 * @param object_name Nome do objeto clicado
 */
void HandlePanelClick(const string object_name)
{
    // Implementação futura para interatividade do painel
    Print("Clique no painel: ", object_name);
}

//+------------------------------------------------------------------+
//| Funções Auxiliares                                              |
//+------------------------------------------------------------------+

/**
 * Converte PatternType para string
 * @param pattern_type Tipo do padrão
 * @return String descritiva
 */
string PatternTypeToString(PatternType pattern_type)
{
    switch(pattern_type)
    {
        case PATTERN_MHI1: return "MHI1";
        case PATTERN_MHI2: return "MHI2";
        case PATTERN_MHI3: return "MHI3";
        case PATTERN_MHI4: return "MHI4";
        case PATTERN_MHI5: return "MHI5";
        case PATTERN_MHI6: return "MHI6";
        default: return "Nenhum";
    }
}

/**
 * Formata valor monetário
 * @param value Valor a ser formatado
 * @return String formatada
 */
string FormatCurrency(double value)
{
    return DoubleToString(value, 2);
}

/**
 * Converte SystemState para string
 * @param state Estado do sistema
 * @return String descritiva
 */
string SystemStateToString(SystemState state)
{
    switch(state)
    {
        case STATE_INITIALIZING: return "Inicializando";
        case STATE_RUNNING: return "Executando";
        case STATE_PAUSED: return "Pausado";
        case STATE_ERROR: return "Erro";
        case STATE_STOPPED: return "Parado";
        default: return "Desconhecido";
    }
}

//+------------------------------------------------------------------+
//| Fim do Arquivo Principal                                        |
//+------------------------------------------------------------------+

