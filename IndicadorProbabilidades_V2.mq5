//+------------------------------------------------------------------+
//|                                    IndicadorProbabilidades_V2.mq5 |
//|                        Copyright 2024, Quant Genius (Refactoring) |
//|                                      https://www.google.com |
//|                                    VERSÃO CORRIGIDA v2.0        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quant Genius (Refactoring)"
#property link      "https://www.google.com"
#property version   "2.00"
#property description "Indicador de Probabilidades - Versão Corrigida e Otimizada"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

// Plotagem dos sinais
#property indicator_label1  "Sinais CALL"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLime
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3

#property indicator_label2  "Sinais PUT"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3

// ==================================================================
// ENUMS E ESTRUTURAS NECESSÁRIAS
// ==================================================================

// Enum para tipos de padrões
enum PatternType
{
    PatternMHI1_3C_Minoria = 0,
    PatternMHI2_3C_Maioria = 1,
    PatternMHI3_2C_Minoria = 2,
    PatternMHI4_2C_Maioria = 3,
    PatternMHI5_1C_Minoria = 4,
    PatternMHI6_1C_Maioria = 5
};

// Enum para posição das setas
enum ENUM_POSICAO_SETA
{
    PosicaoSeta_Automatica = 0,
    PosicaoSeta_Acima = 1,
    PosicaoSeta_Abaixo = 2,
    PosicaoSeta_Centro = 3
};

// ==================================================================
// PARÂMETROS DE ENTRADA ORGANIZADOS
// ==================================================================

// --- CONFIGURAÇÕES PRINCIPAIS ---
input group "=== CONFIGURAÇÕES PRINCIPAIS ==="
input PatternType InpPadraoSelecionado = PatternMHI1_3C_Minoria; // Padrão de Análise
input bool InpInverterPadrao = false; // Inverter Lógica do Padrão
input int InpVelasAnalise = 1000; // Velas para Análise
input ENUM_POSICAO_SETA InpPosicaoSeta = PosicaoSeta_Automatica; // Posição das Setas

// --- FILTROS DE MERCADO ---
input group "=== FILTROS DE MERCADO ==="
input bool InpAtivarFiltroVolatilidade = true; // Ativar Filtro de Volatilidade
input double InpATRMinimo = 0.0001; // ATR Mínimo
input double InpATRMaximo = 0.0005; // ATR Máximo
input bool InpBBApenasCons = true; // BB: Apenas em Consolidação
input bool InpAtivarFiltroTendencia = false; // Ativar Filtro de Tendência

// --- CONFIGURAÇÕES VISUAIS ---
input group "=== CONFIGURAÇÕES VISUAIS ==="
input bool InpMostrarPainel = true; // Mostrar Painel Informativo
input bool InpMostrarEstatisticas = true; // Mostrar Estatísticas em Tempo Real
input color InpCorSinalCall = clrLime; // Cor dos Sinais CALL
input color InpCorSinalPut = clrRed; // Cor dos Sinais PUT

// --- NOTIFICAÇÕES ---
input group "=== NOTIFICAÇÕES ==="
input bool InpAtivarTelegram = false; // Ativar Notificações Telegram
input string InpTelegramToken = ""; // Token do Bot Telegram
input string InpTelegramChatID = ""; // Chat ID do Telegram

// --- SUPERVARREDURA ---
input group "=== SUPERVARREDURA ==="
input bool InpExecutarSuperScan = false; // Executar SuperVarredura na Inicialização
input int InpSuperScanVelas = 500; // Velas para SuperVarredura

// --- CONFIGURAÇÕES AVANÇADAS ---
input group "=== CONFIGURAÇÕES AVANÇADAS ==="
input bool InpHabilitarLogging = true; // Habilitar Sistema de Logs
input bool InpModoDebug = false; // Modo Debug (Logs Detalhados)
input int InpCacheSize = 1000; // Tamanho do Cache de Dados

// ==================================================================
// BUFFERS DO INDICADOR
// ==================================================================
double BufferCall[];
double BufferPut[];

// ==================================================================
// VARIÁVEIS GLOBAIS
// ==================================================================
datetime g_last_bar_time = 0;
int g_total_signals_today = 0;
datetime g_today_start = 0;
bool g_system_initialized = false;

// Handles de indicadores
int g_atr_handle = INVALID_HANDLE;
int g_bb_handle = INVALID_HANDLE;
int g_ma_handle = INVALID_HANDLE;

// Cache de dados
double g_atr_buffer[];
double g_bb_upper[];
double g_bb_lower[];
double g_bb_middle[];
double g_ma_buffer[];

// Configurações do painel
string g_panel_prefix = "ProbV2_";

//+------------------------------------------------------------------+
//| Função de inicialização do indicador                            |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("=== INICIALIZANDO INDICADOR DE PROBABILIDADES V2.0 ===");
    
    // Configura buffers
    SetIndexBuffer(0, BufferCall, INDICATOR_DATA);
    SetIndexBuffer(1, BufferPut, INDICATOR_DATA);
    
    // Configura propriedades dos buffers
    PlotIndexSetInteger(0, PLOT_ARROW, 233); // Seta para cima
    PlotIndexSetInteger(1, PLOT_ARROW, 234); // Seta para baixo
    
    PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 10);
    PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -10);
    
    // Inicializa buffers com valores vazios
    ArraySetAsSeries(BufferCall, true);
    ArraySetAsSeries(BufferPut, true);
    ArrayInitialize(BufferCall, EMPTY_VALUE);
    ArrayInitialize(BufferPut, EMPTY_VALUE);
    
    // Configura cores dos sinais
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, InpCorSinalCall);
    PlotIndexSetInteger(1, PLOT_LINE_COLOR, InpCorSinalPut);
    
    // Inicializa indicadores técnicos
    if(!InitializeTechnicalIndicators())
    {
        Print("ERRO: Falha na inicialização dos indicadores técnicos");
        return INIT_FAILED;
    }
    
    // Inicializa cache de dados
    ArraySetAsSeries(g_atr_buffer, true);
    ArraySetAsSeries(g_bb_upper, true);
    ArraySetAsSeries(g_bb_lower, true);
    ArraySetAsSeries(g_bb_middle, true);
    ArraySetAsSeries(g_ma_buffer, true);
    
    // Inicializa contadores diários
    g_today_start = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
    g_total_signals_today = 0;
    
    // Cria painel informativo se habilitado
    if(InpMostrarPainel)
    {
        CreateInformationPanel();
    }
    
    g_system_initialized = true;
    
    Print("=== INDICADOR INICIALIZADO COM SUCESSO ===");
    Print("Versão: 2.0 | Cache: ", InpCacheSize, " | Padrão: ", EnumToString(InpPadraoSelecionado));
    
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Função de desinicialização                                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("=== DESINICIALIZANDO INDICADOR ===");
    Print("Motivo: ", reason);
    
    // Libera handles de indicadores
    if(g_atr_handle != INVALID_HANDLE)
        IndicatorRelease(g_atr_handle);
    if(g_bb_handle != INVALID_HANDLE)
        IndicatorRelease(g_bb_handle);
    if(g_ma_handle != INVALID_HANDLE)
        IndicatorRelease(g_ma_handle);
    
    // Remove objetos do painel
    RemoveAllPanelObjects();
    
    g_system_initialized = false;
    
    Print("=== DESINICIALIZAÇÃO CONCLUÍDA ===");
}

//+------------------------------------------------------------------+
//| Função principal de cálculo                                     |
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
    // Verifica se o sistema está inicializado
    if(!g_system_initialized)
    {
        return prev_calculated;
    }
    
    // Verifica se há dados suficientes
    if(rates_total < 100)
    {
        return prev_calculated;
    }
    
    // Atualiza cache de indicadores
    if(!UpdateIndicatorCache())
    {
        return prev_calculated;
    }
    
    // Detecta nova barra
    bool new_bar = false;
    if(rates_total > prev_calculated)
    {
        new_bar = true;
        
        // Verifica se é um novo dia
        datetime current_day = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
        if(current_day > g_today_start)
        {
            g_today_start = current_day;
            g_total_signals_today = 0;
        }
    }
    
    // Calcula limite de processamento
    int limit = rates_total - prev_calculated;
    if(limit > 100) limit = 100; // Limita para performance
    
    // Processa apenas se houver nova barra ou for primeira execução
    if(new_bar || prev_calculated == 0)
    {
        // Processa detecção de padrões
        ProcessPatternDetection(rates_total, time, open, high, low, close);
        
        // Atualiza painel visual se habilitado
        if(InpMostrarPainel)
        {
            UpdateInformationPanel();
        }
    }
    
    return rates_total;
}

//+------------------------------------------------------------------+
//| Inicializa indicadores técnicos                                 |
//+------------------------------------------------------------------+
bool InitializeTechnicalIndicators()
{
    // ATR para volatilidade
    g_atr_handle = iATR(_Symbol, _Period, 14);
    if(g_atr_handle == INVALID_HANDLE)
    {
        Print("Erro ao criar handle ATR: ", GetLastError());
        return false;
    }
    
    // Bollinger Bands para consolidação
    g_bb_handle = iBands(_Symbol, _Period, 20, 0, 2.0, PRICE_CLOSE);
    if(g_bb_handle == INVALID_HANDLE)
    {
        Print("Erro ao criar handle Bollinger Bands: ", GetLastError());
        return false;
    }
    
    // Média móvel para tendência
    g_ma_handle = iMA(_Symbol, _Period, 50, 0, MODE_EMA, PRICE_CLOSE);
    if(g_ma_handle == INVALID_HANDLE)
    {
        Print("Erro ao criar handle MA: ", GetLastError());
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Atualiza cache de indicadores                                   |
//+------------------------------------------------------------------+
bool UpdateIndicatorCache()
{
    // Copia dados do ATR
    if(CopyBuffer(g_atr_handle, 0, 0, 50, g_atr_buffer) <= 0)
    {
        return false;
    }
    
    // Copia dados do Bollinger Bands
    if(CopyBuffer(g_bb_handle, 0, 0, 50, g_bb_upper) <= 0 ||
       CopyBuffer(g_bb_handle, 1, 0, 50, g_bb_middle) <= 0 ||
       CopyBuffer(g_bb_handle, 2, 0, 50, g_bb_lower) <= 0)
    {
        return false;
    }
    
    // Copia dados da MA
    if(CopyBuffer(g_ma_handle, 0, 0, 50, g_ma_buffer) <= 0)
    {
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Processa detecção de padrões                                    |
//+------------------------------------------------------------------+
void ProcessPatternDetection(int rates_total, const datetime &time[], 
                           const double &open[], const double &high[], 
                           const double &low[], const double &close[])
{
    // Verifica apenas a última vela completa
    int current_bar = 1;
    
    if(current_bar >= rates_total - 1)
        return;
    
    // Aplica filtros de mercado
    if(!ApplyMarketFilters(current_bar))
        return;
    
    // Detecta padrão selecionado
    bool signal_call = false;
    bool signal_put = false;
    
    switch(InpPadraoSelecionado)
    {
        case PatternMHI1_3C_Minoria:
            DetectMHI1Pattern(current_bar, open, high, low, close, signal_call, signal_put);
            break;
        case PatternMHI2_3C_Maioria:
            DetectMHI2Pattern(current_bar, open, high, low, close, signal_call, signal_put);
            break;
        case PatternMHI3_2C_Minoria:
            DetectMHI3Pattern(current_bar, open, high, low, close, signal_call, signal_put);
            break;
        case PatternMHI4_2C_Maioria:
            DetectMHI4Pattern(current_bar, open, high, low, close, signal_call, signal_put);
            break;
        case PatternMHI5_1C_Minoria:
            DetectMHI5Pattern(current_bar, open, high, low, close, signal_call, signal_put);
            break;
        case PatternMHI6_1C_Maioria:
            DetectMHI6Pattern(current_bar, open, high, low, close, signal_call, signal_put);
            break;
    }
    
    // Inverte sinais se solicitado
    if(InpInverterPadrao)
    {
        bool temp = signal_call;
        signal_call = signal_put;
        signal_put = temp;
    }
    
    // Plota sinais nos buffers
    if(signal_call)
    {
        double arrow_price = GetArrowPrice(current_bar, high, low, true);
        BufferCall[current_bar] = arrow_price;
        g_total_signals_today++;
        
        if(InpModoDebug)
            Print("CALL detectado na barra ", current_bar, " preço: ", arrow_price);
        
        // Envia notificação Telegram se habilitado
        if(InpAtivarTelegram)
            SendTelegramNotification("CALL", arrow_price, time[current_bar]);
    }
    
    if(signal_put)
    {
        double arrow_price = GetArrowPrice(current_bar, high, low, false);
        BufferPut[current_bar] = arrow_price;
        g_total_signals_today++;
        
        if(InpModoDebug)
            Print("PUT detectado na barra ", current_bar, " preço: ", arrow_price);
        
        // Envia notificação Telegram se habilitado
        if(InpAtivarTelegram)
            SendTelegramNotification("PUT", arrow_price, time[current_bar]);
    }
}

//+------------------------------------------------------------------+
//| Aplica filtros de mercado                                       |
//+------------------------------------------------------------------+
bool ApplyMarketFilters(int bar_index)
{
    if(!InpAtivarFiltroVolatilidade)
        return true;
    
    // Verifica se há dados suficientes no cache
    if(ArraySize(g_atr_buffer) <= bar_index)
        return false;
    
    // Filtro de volatilidade (ATR)
    double current_atr = g_atr_buffer[bar_index];
    if(current_atr < InpATRMinimo || current_atr > InpATRMaximo)
        return false;
    
    // Filtro de consolidação (Bollinger Bands)
    if(InpBBApenasCons)
    {
        if(ArraySize(g_bb_upper) <= bar_index || ArraySize(g_bb_lower) <= bar_index)
            return false;
        
        double bb_width = g_bb_upper[bar_index] - g_bb_lower[bar_index];
        double price_range = iHigh(_Symbol, _Period, bar_index) - iLow(_Symbol, _Period, bar_index);
        
        // Considera consolidação se a largura das bandas for pequena
        if(bb_width < price_range * 2.0)
            return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Detecta padrão MHI1 (3 Candles Minoria)                        |
//+------------------------------------------------------------------+
void DetectMHI1Pattern(int bar, const double &open[], const double &high[], 
                      const double &low[], const double &close[], 
                      bool &signal_call, bool &signal_put)
{
    if(bar < 3) return;
    
    // Padrão de 3 velas - minoria
    bool candle1_bull = close[bar+2] > open[bar+2];
    bool candle2_bear = close[bar+1] < open[bar+1];
    bool candle3_bull = close[bar] > open[bar];
    
    // Sinal CALL: Bear entre duas Bulls
    if(candle1_bull && candle2_bear && candle3_bull)
    {
        // Verifica se a vela do meio é menor (minoria)
        double body1 = MathAbs(close[bar+2] - open[bar+2]);
        double body2 = MathAbs(close[bar+1] - open[bar+1]);
        double body3 = MathAbs(close[bar] - open[bar]);
        
        if(body2 < body1 && body2 < body3)
        {
            signal_call = true;
        }
    }
    
    // Sinal PUT: Bull entre duas Bears
    bool candle1_bear = close[bar+2] < open[bar+2];
    bool candle2_bull = close[bar+1] > open[bar+1];
    bool candle3_bear = close[bar] < open[bar];
    
    if(candle1_bear && candle2_bull && candle3_bear)
    {
        double body1 = MathAbs(close[bar+2] - open[bar+2]);
        double body2 = MathAbs(close[bar+1] - open[bar+1]);
        double body3 = MathAbs(close[bar] - open[bar]);
        
        if(body2 < body1 && body2 < body3)
        {
            signal_put = true;
        }
    }
}

//+------------------------------------------------------------------+
//| Detecta padrão MHI2 (3 Candles Maioria)                        |
//+------------------------------------------------------------------+
void DetectMHI2Pattern(int bar, const double &open[], const double &high[], 
                      const double &low[], const double &close[], 
                      bool &signal_call, bool &signal_put)
{
    if(bar < 3) return;
    
    // Similar ao MHI1, mas a vela do meio deve ser maior (maioria)
    bool candle1_bull = close[bar+2] > open[bar+2];
    bool candle2_bear = close[bar+1] < open[bar+1];
    bool candle3_bull = close[bar] > open[bar];
    
    if(candle1_bull && candle2_bear && candle3_bull)
    {
        double body1 = MathAbs(close[bar+2] - open[bar+2]);
        double body2 = MathAbs(close[bar+1] - open[bar+1]);
        double body3 = MathAbs(close[bar] - open[bar]);
        
        if(body2 > body1 && body2 > body3)
        {
            signal_call = true;
        }
    }
    
    bool candle1_bear = close[bar+2] < open[bar+2];
    bool candle2_bull = close[bar+1] > open[bar+1];
    bool candle3_bear = close[bar] < open[bar];
    
    if(candle1_bear && candle2_bull && candle3_bear)
    {
        double body1 = MathAbs(close[bar+2] - open[bar+2]);
        double body2 = MathAbs(close[bar+1] - open[bar+1]);
        double body3 = MathAbs(close[bar] - open[bar]);
        
        if(body2 > body1 && body2 > body3)
        {
            signal_put = true;
        }
    }
}

//+------------------------------------------------------------------+
//| Detecta padrão MHI3 (2 Candles Minoria)                        |
//+------------------------------------------------------------------+
void DetectMHI3Pattern(int bar, const double &open[], const double &high[], 
                      const double &low[], const double &close[], 
                      bool &signal_call, bool &signal_put)
{
    if(bar < 2) return;
    
    // Padrão de 2 velas
    bool candle1_bull = close[bar+1] > open[bar+1];
    bool candle2_bear = close[bar] < open[bar];
    
    if(candle1_bull && candle2_bear)
    {
        double body1 = MathAbs(close[bar+1] - open[bar+1]);
        double body2 = MathAbs(close[bar] - open[bar]);
        
        if(body2 < body1) // Segunda vela menor
        {
            signal_put = true;
        }
    }
    
    bool candle1_bear = close[bar+1] < open[bar+1];
    bool candle2_bull = close[bar] > open[bar];
    
    if(candle1_bear && candle2_bull)
    {
        double body1 = MathAbs(close[bar+1] - open[bar+1]);
        double body2 = MathAbs(close[bar] - open[bar]);
        
        if(body2 < body1) // Segunda vela menor
        {
            signal_call = true;
        }
    }
}

//+------------------------------------------------------------------+
//| Detecta padrão MHI4 (2 Candles Maioria)                        |
//+------------------------------------------------------------------+
void DetectMHI4Pattern(int bar, const double &open[], const double &high[], 
                      const double &low[], const double &close[], 
                      bool &signal_call, bool &signal_put)
{
    if(bar < 2) return;
    
    // Similar ao MHI3, mas segunda vela deve ser maior
    bool candle1_bull = close[bar+1] > open[bar+1];
    bool candle2_bear = close[bar] < open[bar];
    
    if(candle1_bull && candle2_bear)
    {
        double body1 = MathAbs(close[bar+1] - open[bar+1]);
        double body2 = MathAbs(close[bar] - open[bar]);
        
        if(body2 > body1) // Segunda vela maior
        {
            signal_put = true;
        }
    }
    
    bool candle1_bear = close[bar+1] < open[bar+1];
    bool candle2_bull = close[bar] > open[bar];
    
    if(candle1_bear && candle2_bull)
    {
        double body1 = MathAbs(close[bar+1] - open[bar+1]);
        double body2 = MathAbs(close[bar] - open[bar]);
        
        if(body2 > body1) // Segunda vela maior
        {
            signal_call = true;
        }
    }
}

//+------------------------------------------------------------------+
//| Detecta padrão MHI5 (1 Candle Minoria)                         |
//+------------------------------------------------------------------+
void DetectMHI5Pattern(int bar, const double &open[], const double &high[], 
                      const double &low[], const double &close[], 
                      bool &signal_call, bool &signal_put)
{
    if(bar < 1) return;
    
    // Padrão de 1 vela - baseado em tamanho do corpo
    double body = MathAbs(close[bar] - open[bar]);
    double shadow_upper = high[bar] - MathMax(open[bar], close[bar]);
    double shadow_lower = MathMin(open[bar], close[bar]) - low[bar];
    
    // Vela com corpo pequeno (minoria) e sombras grandes
    double total_range = high[bar] - low[bar];
    
    if(body < total_range * 0.3) // Corpo menor que 30% do range
    {
        if(close[bar] > open[bar])
            signal_call = true;
        else
            signal_put = true;
    }
}

//+------------------------------------------------------------------+
//| Detecta padrão MHI6 (1 Candle Maioria)                         |
//+------------------------------------------------------------------+
void DetectMHI6Pattern(int bar, const double &open[], const double &high[], 
                      const double &low[], const double &close[], 
                      bool &signal_call, bool &signal_put)
{
    if(bar < 1) return;
    
    // Padrão de 1 vela - corpo grande (maioria)
    double body = MathAbs(close[bar] - open[bar]);
    double total_range = high[bar] - low[bar];
    
    if(body > total_range * 0.7) // Corpo maior que 70% do range
    {
        if(close[bar] > open[bar])
            signal_call = true;
        else
            signal_put = true;
    }
}

//+------------------------------------------------------------------+
//| Calcula preço da seta baseado na posição configurada            |
//+------------------------------------------------------------------+
double GetArrowPrice(int bar, const double &high[], const double &low[], bool is_call)
{
    double price = 0;
    
    switch(InpPosicaoSeta)
    {
        case PosicaoSeta_Automatica:
            price = is_call ? low[bar] - (10 * _Point) : high[bar] + (10 * _Point);
            break;
        case PosicaoSeta_Acima:
            price = high[bar] + (10 * _Point);
            break;
        case PosicaoSeta_Abaixo:
            price = low[bar] - (10 * _Point);
            break;
        case PosicaoSeta_Centro:
            price = (high[bar] + low[bar]) / 2.0;
            break;
    }
    
    return price;
}

//+------------------------------------------------------------------+
//| Cria painel informativo                                         |
//+------------------------------------------------------------------+
void CreateInformationPanel()
{
    string panel_name = g_panel_prefix + "main_panel";
    
    // Remove painel anterior se existir
    ObjectDelete(0, panel_name);
    
    // Cria painel principal
    if(!ObjectCreate(0, panel_name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
        return;
    
    // Configura propriedades do painel
    ObjectSetInteger(0, panel_name, OBJPROP_XDISTANCE, 20);
    ObjectSetInteger(0, panel_name, OBJPROP_YDISTANCE, 30);
    ObjectSetInteger(0, panel_name, OBJPROP_XSIZE, 300);
    ObjectSetInteger(0, panel_name, OBJPROP_YSIZE, 150);
    ObjectSetInteger(0, panel_name, OBJPROP_BGCOLOR, clrDarkSlateGray);
    ObjectSetInteger(0, panel_name, OBJPROP_BORDER_COLOR, clrSilver);
    ObjectSetInteger(0, panel_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, panel_name, OBJPROP_BACK, false);
    ObjectSetInteger(0, panel_name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, panel_name, OBJPROP_HIDDEN, true);
    
    // Adiciona título
    string title_name = g_panel_prefix + "title";
    ObjectCreate(0, title_name, OBJ_LABEL, 0, 0, 0);
    ObjectSetString(0, title_name, OBJPROP_TEXT, "PROBABILIDADES V2.0");
    ObjectSetString(0, title_name, OBJPROP_FONT, "Arial Bold");
    ObjectSetInteger(0, title_name, OBJPROP_FONTSIZE, 12);
    ObjectSetInteger(0, title_name, OBJPROP_COLOR, clrYellow);
    ObjectSetInteger(0, title_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, title_name, OBJPROP_XDISTANCE, 30);
    ObjectSetInteger(0, title_name, OBJPROP_YDISTANCE, 40);
    ObjectSetInteger(0, title_name, OBJPROP_BACK, false);
    ObjectSetInteger(0, title_name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, title_name, OBJPROP_HIDDEN, true);
}

//+------------------------------------------------------------------+
//| Atualiza painel informativo                                     |
//+------------------------------------------------------------------+
void UpdateInformationPanel()
{
    if(!InpMostrarPainel)
        return;
    
    // Informações a serem exibidas
    string info_lines[] = {
        "Status: " + (g_system_initialized ? "ATIVO" : "INATIVO"),
        "Padrão: " + EnumToString(InpPadraoSelecionado),
        "Sinais Hoje: " + IntegerToString(g_total_signals_today),
        "Filtros: " + (InpAtivarFiltroVolatilidade ? "ON" : "OFF"),
        "Telegram: " + (InpAtivarTelegram ? "ON" : "OFF"),
        "Atualizado: " + TimeToString(TimeCurrent(), TIME_MINUTES)
    };
    
    // Remove informações anteriores
    for(int i = 0; i < 10; i++)
    {
        ObjectDelete(0, g_panel_prefix + "info_" + IntegerToString(i));
    }
    
    // Adiciona novas informações
    for(int i = 0; i < ArraySize(info_lines); i++)
    {
        string info_name = g_panel_prefix + "info_" + IntegerToString(i);
        
        if(!ObjectCreate(0, info_name, OBJ_LABEL, 0, 0, 0))
            continue;
        
        ObjectSetString(0, info_name, OBJPROP_TEXT, info_lines[i]);
        ObjectSetString(0, info_name, OBJPROP_FONT, "Consolas");
        ObjectSetInteger(0, info_name, OBJPROP_FONTSIZE, 9);
        ObjectSetInteger(0, info_name, OBJPROP_COLOR, clrLightGray);
        ObjectSetInteger(0, info_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, info_name, OBJPROP_XDISTANCE, 30);
        ObjectSetInteger(0, info_name, OBJPROP_YDISTANCE, 65 + (i * 15));
        ObjectSetInteger(0, info_name, OBJPROP_BACK, false);
        ObjectSetInteger(0, info_name, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, info_name, OBJPROP_HIDDEN, true);
    }
}

//+------------------------------------------------------------------+
//| Remove todos os objetos do painel                               |
//+------------------------------------------------------------------+
void RemoveAllPanelObjects()
{
    int total_objects = ObjectsTotal(0);
    
    for(int i = total_objects - 1; i >= 0; i--)
    {
        string obj_name = ObjectName(0, i);
        if(StringFind(obj_name, g_panel_prefix) >= 0)
        {
            ObjectDelete(0, obj_name);
        }
    }
}

//+------------------------------------------------------------------+
//| Envia notificação Telegram                                      |
//+------------------------------------------------------------------+
void SendTelegramNotification(string signal_type, double price, datetime signal_time)
{
    if(!InpAtivarTelegram || InpTelegramToken == "" || InpTelegramChatID == "")
        return;
    
    string message = "🎯 SINAL " + signal_type + " DETECTADO\n";
    message += "📊 Símbolo: " + _Symbol + "\n";
    message += "💰 Preço: " + DoubleToString(price, _Digits) + "\n";
    message += "⏰ Tempo: " + TimeToString(signal_time, TIME_DATE|TIME_MINUTES) + "\n";
    message += "🎨 Padrão: " + EnumToString(InpPadraoSelecionado) + "\n";
    message += "\nGerado por Indicador V2.0";
    
    // Aqui seria implementada a função de envio real
    // Por simplicidade, apenas logamos
    if(InpModoDebug)
        Print("Telegram: ", message);
}

//+------------------------------------------------------------------+
//| Função de tratamento de eventos do gráfico                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    // Processa cliques em objetos do painel
    if(id == CHARTEVENT_OBJECT_CLICK)
    {
        if(StringFind(sparam, g_panel_prefix) >= 0)
        {
            Print("Clique no painel: ", sparam);
        }
    }
}

//+------------------------------------------------------------------+
//| Função de comentário do indicador                               |
//+------------------------------------------------------------------+
void UpdateComment()
{
    string comment = "Probabilidades V2.0 | ";
    comment += (g_system_initialized ? "ATIVO" : "INATIVO") + " | ";
    comment += "Sinais: " + IntegerToString(g_total_signals_today) + " | ";
    comment += TimeToString(TimeCurrent(), TIME_MINUTES);
    
    Comment(comment);
}

//+------------------------------------------------------------------+
//| Função auxiliar para debug                                      |
//+------------------------------------------------------------------+
void DebugPrint(string message)
{
    if(InpModoDebug)
    {
        Print("[DEBUG] ", message);
    }
}

