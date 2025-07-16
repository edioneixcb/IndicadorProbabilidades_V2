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
// INCLUDES DA SUÍTE CORRIGIDA
// ==================================================================
#include "ProbabilitiesSuite_V2/ProbabilitiesSuite.mqh"

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
ProbabilitiesSuiteV2* g_suite = NULL;
datetime g_last_bar_time = 0;
int g_total_signals_today = 0;
datetime g_today_start = 0;

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
    
    // Inicializa a suíte de probabilidades
    bool init_success = InitializeProbabilitiesSuite(
        InpCacheSize,
        InpHabilitarLogging,
        InpAtivarTelegram,
        InpTelegramToken,
        InpTelegramChatID
    );
    
    if(!init_success)
    {
        Print("ERRO: Falha na inicialização da suíte de probabilidades");
        return INIT_FAILED;
    }
    
    g_suite = GetProbabilitiesSuite();
    if(g_suite == NULL)
    {
        Print("ERRO: Não foi possível obter instância da suíte");
        return INIT_FAILED;
    }
    
    // Configura logging
    if(InpModoDebug)
    {
        Logger::SetLogLevel(LOG_DEBUG);
    }
    
    // Executa SuperVarredura se solicitado
    if(InpExecutarSuperScan)
    {
        Print("Executando SuperVarredura inicial...");
        
        int best_pattern;
        double best_score;
        string detailed_result;
        
        if(g_suite.RunSuperScan(InpSuperScanVelas, true, best_pattern, best_score, detailed_result))
        {
            Print("SuperVarredura concluída:");
            Print("Melhor padrão: ", best_pattern);
            Print("Score: ", DoubleToString(best_score, 2), "%");
            Print("Detalhes: ", StringSubstr(detailed_result, 0, 200), "...");
        }
        else
        {
            Print("SuperVarredura falhou: ", detailed_result);
        }
    }
    
    // Inicializa contadores diários
    g_today_start = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
    g_total_signals_today = 0;
    
    // Configura cores dos sinais
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, InpCorSinalCall);
    PlotIndexSetInteger(1, PLOT_LINE_COLOR, InpCorSinalPut);
    
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
    
    // Executa diagnóstico final se em modo debug
    if(InpModoDebug && g_suite != NULL)
    {
        g_suite.RunFullDiagnostic();
    }
    
    // Limpa a suíte
    CleanupProbabilitiesSuite();
    g_suite = NULL;
    
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
    // Verifica se a suíte está inicializada
    if(g_suite == NULL || !g_suite.IsInitialized())
    {
        return prev_calculated;
    }
    
    // Verifica se há dados suficientes
    if(rates_total < 100)
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
        // Chama processamento principal da suíte
        g_suite.OnTick(
            InpPadraoSelecionado,
            InpInverterPadrao,
            InpAtivarFiltroVolatilidade,
            InpATRMinimo,
            InpATRMaximo,
            InpBBApenasCons,
            InpAtivarFiltroTendencia,
            InpPosicaoSeta
        );
        
        // Atualiza painel visual se habilitado
        if(InpMostrarPainel)
        {
            g_suite.UpdateVisualPanel();
        }
    }
    
    return rates_total;
}

//+------------------------------------------------------------------+
//| Função de tratamento de eventos de timer                        |
//+------------------------------------------------------------------+
void OnTimer()
{
    if(g_suite != NULL && g_suite.IsInitialized())
    {
        // Atualiza painel a cada timer
        if(InpMostrarPainel)
        {
            g_suite.UpdateVisualPanel();
        }
    }
}

//+------------------------------------------------------------------+
//| Função de tratamento de eventos do gráfico                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    if(g_suite == NULL)
        return;
    
    // Processa cliques em botões do painel
    if(id == CHARTEVENT_OBJECT_CLICK)
    {
        string button_id = ProcessarCliqueBotao(sparam);
        
        if(button_id == "superscan")
        {
            Print("Executando SuperVarredura via painel...");
            
            int best_pattern;
            double best_score;
            string detailed_result;
            
            if(g_suite.RunSuperScan(InpSuperScanVelas, true, best_pattern, best_score, detailed_result))
            {
                Print("SuperVarredura concluída via painel");
                
                // Atualiza painel com resultado
                g_suite.UpdateVisualPanel();
            }
        }
        else if(button_id == "diagnostic")
        {
            Print("Executando diagnóstico completo...");
            g_suite.RunFullDiagnostic();
        }
        else if(button_id == "reset")
        {
            Print("Reinicializando sistema...");
            
            // Reinicializa a suíte
            CleanupProbabilitiesSuite();
            
            bool success = InitializeProbabilitiesSuite(
                InpCacheSize,
                InpHabilitarLogging,
                InpAtivarTelegram,
                InpTelegramToken,
                InpTelegramChatID
            );
            
            if(success)
            {
                g_suite = GetProbabilitiesSuite();
                Print("Sistema reinicializado com sucesso");
            }
            else
            {
                Print("Falha na reinicialização do sistema");
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Função de tratamento de novos ticks                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Processa apenas em nova barra para otimização
    datetime current_bar_time = iTime(_Symbol, _Period, 0);
    
    if(current_bar_time != g_last_bar_time)
    {
        g_last_bar_time = current_bar_time;
        
        if(g_suite != NULL && g_suite.IsInitialized())
        {
            // Força recálculo do indicador
            EventSetTimer(1);
        }
    }
}

//+------------------------------------------------------------------+
//| Função de informações do indicador                              |
//+------------------------------------------------------------------+
string GetIndicatorInfo()
{
    string info = "Indicador de Probabilidades V2.0\n";
    info += "Copyright 2024, Quant Genius (Refactoring)\n";
    info += "Versão Corrigida e Otimizada\n\n";
    
    if(g_suite != NULL && g_suite.IsInitialized())
    {
        info += "Status: ATIVO\n";
        info += "Última atualização: " + TimeToString(g_suite.GetLastUpdate()) + "\n";
        info += "Telegram: " + (g_suite.HasTelegram() ? "ATIVO" : "INATIVO") + "\n";
        info += "Sinais hoje: " + IntegerToString(g_total_signals_today) + "\n";
    }
    else
    {
        info += "Status: INATIVO\n";
    }
    
    info += "\nParâmetros atuais:\n";
    info += "Padrão: " + EnumToString(InpPadraoSelecionado) + "\n";
    info += "Invertido: " + BoolToString(InpInverterPadrao) + "\n";
    info += "Filtros: " + BoolToString(InpAtivarFiltroVolatilidade) + "\n";
    info += "Cache: " + IntegerToString(InpCacheSize) + " velas\n";
    
    return info;
}

//+------------------------------------------------------------------+
//| Função de comentário do indicador                               |
//+------------------------------------------------------------------+
void UpdateComment()
{
    string comment = "Probabilidades V2.0 | ";
    
    if(g_suite != NULL && g_suite.IsInitialized())
    {
        comment += "ATIVO | ";
        comment += "Sinais: " + IntegerToString(g_total_signals_today) + " | ";
        comment += TimeToString(TimeCurrent(), TIME_MINUTES);
    }
    else
    {
        comment += "INATIVO";
    }
    
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

