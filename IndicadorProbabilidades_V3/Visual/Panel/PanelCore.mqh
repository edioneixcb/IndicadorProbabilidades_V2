//+------------------------------------------------------------------+
//|                                    Visual/Panel/PanelCore.mqh |
//|                                    Indicador de Probabilidades V3 |
//|                                Sistema de Painel Visual |
//+------------------------------------------------------------------+

#ifndef VISUAL_PANEL_CORE_MQH
#define VISUAL_PANEL_CORE_MQH

#include "../../Core/Types.mqh"
#include "../../Core/Globals.mqh"

//+------------------------------------------------------------------+
//| Constantes do Painel                                            |
//+------------------------------------------------------------------+
#define PANEL_WIDTH 280
#define PANEL_HEIGHT 400
#define PANEL_MARGIN 10
#define LINE_HEIGHT 18
#define FONT_SIZE 9
#define FONT_NAME "Arial"

//+------------------------------------------------------------------+
//| Cores do Painel                                                 |
//+------------------------------------------------------------------+
#define PANEL_BG_COLOR clrDarkSlateGray
#define PANEL_BORDER_COLOR clrSilver
#define PANEL_TEXT_COLOR clrWhite
#define PANEL_TITLE_COLOR clrGold
#define PANEL_POSITIVE_COLOR clrLimeGreen
#define PANEL_NEGATIVE_COLOR clrRed
#define PANEL_NEUTRAL_COLOR clrSilver

//+------------------------------------------------------------------+
//| Funções de Inicialização do Painel                              |
//+------------------------------------------------------------------+

/**
 * Inicializa o painel visual
 * @return true se inicializado com sucesso
 */
bool InitializePanel()
{
    if(!g_config.visual.show_panel)
    {
        return true; // Não habilitado, mas não é erro
    }
    
    // Limpar objetos existentes
    CleanupPanelObjects();
    
    // Calcular posição do painel
    int panel_x, panel_y;
    CalculatePanelPosition(panel_x, panel_y);
    
    // Criar fundo do painel
    if(!CreatePanelBackground(panel_x, panel_y))
    {
        Print("ERRO: Falha ao criar fundo do painel");
        return false;
    }
    
    // Criar elementos do painel
    if(!CreatePanelElements(panel_x, panel_y))
    {
        Print("ERRO: Falha ao criar elementos do painel");
        return false;
    }
    
    g_panel_initialized = true;
    g_last_panel_update = TimeCurrent();
    
    Print("Painel visual inicializado com sucesso");
    return true;
}

/**
 * Calcula posição do painel baseado na configuração
 */
void CalculatePanelPosition(int &x, int &y)
{
    int chart_width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
    int chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
    
    switch(g_config.visual.panel_position)
    {
        case PANEL_TOP_LEFT:
            x = PANEL_MARGIN + g_config.visual.panel_offset_x;
            y = PANEL_MARGIN + g_config.visual.panel_offset_y;
            break;
            
        case PANEL_TOP_RIGHT:
            x = chart_width - PANEL_WIDTH - PANEL_MARGIN + g_config.visual.panel_offset_x;
            y = PANEL_MARGIN + g_config.visual.panel_offset_y;
            break;
            
        case PANEL_BOTTOM_LEFT:
            x = PANEL_MARGIN + g_config.visual.panel_offset_x;
            y = chart_height - PANEL_HEIGHT - PANEL_MARGIN + g_config.visual.panel_offset_y;
            break;
            
        case PANEL_BOTTOM_RIGHT:
            x = chart_width - PANEL_WIDTH - PANEL_MARGIN + g_config.visual.panel_offset_x;
            y = chart_height - PANEL_HEIGHT - PANEL_MARGIN + g_config.visual.panel_offset_y;
            break;
            
        default:
            x = PANEL_MARGIN;
            y = PANEL_MARGIN;
            break;
    }
}

/**
 * Cria fundo do painel
 */
bool CreatePanelBackground(int x, int y)
{
    string obj_name = "ProbPanel_Background";
    
    if(!ObjectCreate(0, obj_name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
    {
        return false;
    }
    
    ObjectSetInteger(0, obj_name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, obj_name, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, obj_name, OBJPROP_XSIZE, PANEL_WIDTH);
    ObjectSetInteger(0, obj_name, OBJPROP_YSIZE, PANEL_HEIGHT);
    ObjectSetInteger(0, obj_name, OBJPROP_BGCOLOR, PANEL_BG_COLOR);
    ObjectSetInteger(0, obj_name, OBJPROP_BORDER_COLOR, PANEL_BORDER_COLOR);
    ObjectSetInteger(0, obj_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, obj_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, obj_name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
    ObjectSetInteger(0, obj_name, OBJPROP_BACK, false);
    ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, obj_name, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, obj_name, OBJPROP_HIDDEN, true);
    
    AddPanelObject(obj_name);
    return true;
}

/**
 * Cria elementos do painel
 */
bool CreatePanelElements(int x, int y)
{
    int current_y = y + 10;
    
    // Título
    if(!CreatePanelLabel("ProbPanel_Title", "INDICADOR DE PROBABILIDADES V3", x + 10, current_y, PANEL_TITLE_COLOR, 10, true))
        return false;
    current_y += 25;
    
    // Linha separadora
    if(!CreatePanelLine("ProbPanel_Separator1", x + 10, current_y, x + PANEL_WIDTH - 10, current_y))
        return false;
    current_y += 15;
    
    // Seção: Sistema
    if(!CreatePanelLabel("ProbPanel_SystemTitle", "SISTEMA", x + 10, current_y, PANEL_TITLE_COLOR, FONT_SIZE, true))
        return false;
    current_y += LINE_HEIGHT;
    
    if(!CreatePanelLabel("ProbPanel_Status", "Status: Inicializando...", x + 15, current_y, PANEL_TEXT_COLOR))
        return false;
    current_y += LINE_HEIGHT;
    
    if(!CreatePanelLabel("ProbPanel_Pattern", "Padrão: MHI1", x + 15, current_y, PANEL_TEXT_COLOR))
        return false;
    current_y += LINE_HEIGHT;
    
    if(!CreatePanelLabel("ProbPanel_LastSignal", "Último Sinal: Nenhum", x + 15, current_y, PANEL_TEXT_COLOR))
        return false;
    current_y += 20;
    
    // Seção: Financeiro (SALDO SEMPRE VISÍVEL)
    if(!CreatePanelLabel("ProbPanel_FinancialTitle", "FINANCEIRO", x + 10, current_y, PANEL_TITLE_COLOR, FONT_SIZE, true))
        return false;
    current_y += LINE_HEIGHT;
    
    if(!CreatePanelLabel("ProbPanel_Balance", "Saldo: R$ 1.000,00", x + 15, current_y, PANEL_POSITIVE_COLOR, FONT_SIZE, true))
        return false;
    current_y += LINE_HEIGHT;
    
    if(!CreatePanelLabel("ProbPanel_Profit", "Lucro: R$ 0,00", x + 15, current_y, PANEL_TEXT_COLOR))
        return false;
    current_y += LINE_HEIGHT;
    
    if(!CreatePanelLabel("ProbPanel_EntryValue", "Valor Entrada: R$ 10,00", x + 15, current_y, PANEL_TEXT_COLOR))
        return false;
    current_y += LINE_HEIGHT;
    
    if(!CreatePanelLabel("ProbPanel_Martingale", "Martingale: Nível 0", x + 15, current_y, PANEL_TEXT_COLOR))
        return false;
    current_y += 20;
    
    // Seção: Operações
    if(!CreatePanelLabel("ProbPanel_OperationsTitle", "OPERAÇÕES", x + 10, current_y, PANEL_TITLE_COLOR, FONT_SIZE, true))
        return false;
    current_y += LINE_HEIGHT;
    
    if(!CreatePanelLabel("ProbPanel_TotalOps", "Total: 0", x + 15, current_y, PANEL_TEXT_COLOR))
        return false;
    current_y += LINE_HEIGHT;
    
    if(!CreatePanelLabel("ProbPanel_Wins", "Vitórias: 0", x + 15, current_y, PANEL_POSITIVE_COLOR))
        return false;
    current_y += LINE_HEIGHT;
    
    if(!CreatePanelLabel("ProbPanel_Losses", "Perdas: 0", x + 15, current_y, PANEL_NEGATIVE_COLOR))
        return false;
    current_y += LINE_HEIGHT;
    
    if(!CreatePanelLabel("ProbPanel_Winrate", "WinRate: 0.0%", x + 15, current_y, PANEL_TEXT_COLOR))
        return false;
    current_y += 20;
    
    // Seção: Análise de Risco
    if(!CreatePanelLabel("ProbPanel_RiskTitle", "ANÁLISE DE RISCO", x + 10, current_y, PANEL_TITLE_COLOR, FONT_SIZE, true))
        return false;
    current_y += LINE_HEIGHT;
    
    if(!CreatePanelLabel("ProbPanel_Drawdown", "Max Drawdown: R$ 0,00", x + 15, current_y, PANEL_TEXT_COLOR))
        return false;
    current_y += LINE_HEIGHT;
    
    if(!CreatePanelLabel("ProbPanel_Sharpe", "Sharpe Ratio: 0.00", x + 15, current_y, PANEL_TEXT_COLOR))
        return false;
    current_y += LINE_HEIGHT;
    
    if(!CreatePanelLabel("ProbPanel_Volatility", "Volatilidade: 0.00%", x + 15, current_y, PANEL_TEXT_COLOR))
        return false;
    current_y += 20;
    
    // Seção: Notificações
    if(!CreatePanelLabel("ProbPanel_NotificationsTitle", "NOTIFICAÇÕES", x + 10, current_y, PANEL_TITLE_COLOR, FONT_SIZE, true))
        return false;
    current_y += LINE_HEIGHT;
    
    if(!CreatePanelLabel("ProbPanel_Telegram", "Telegram: Desabilitado", x + 15, current_y, PANEL_TEXT_COLOR))
        return false;
    current_y += LINE_HEIGHT;
    
    if(!CreatePanelLabel("ProbPanel_MX2", "MX2: Desabilitado", x + 15, current_y, PANEL_TEXT_COLOR))
        return false;
    
    return true;
}

/**
 * Cria label do painel
 */
bool CreatePanelLabel(string name, string text, int x, int y, color clr, int font_size = FONT_SIZE, bool bold = false)
{
    if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
    {
        return false;
    }
    
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, font_size);
    ObjectSetString(0, name, OBJPROP_FONT, bold ? "Arial Bold" : FONT_NAME);
    ObjectSetString(0, name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
    ObjectSetInteger(0, name, OBJPROP_BACK, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
    
    AddPanelObject(name);
    return true;
}

/**
 * Cria linha do painel
 */
bool CreatePanelLine(string name, int x1, int y1, int x2, int y2)
{
    if(!ObjectCreate(0, name, OBJ_HLINE, 0, 0))
    {
        // Se não conseguir criar HLINE, criar como TREND
        if(!ObjectCreate(0, name, OBJ_TREND, 0, 0, 0))
        {
            return false;
        }
        
        ObjectSetInteger(0, name, OBJPROP_TIME1, 0);
        ObjectSetInteger(0, name, OBJPROP_TIME2, 0);
        ObjectSetDouble(0, name, OBJPROP_PRICE1, 0);
        ObjectSetDouble(0, name, OBJPROP_PRICE2, 0);
    }
    
    ObjectSetInteger(0, name, OBJPROP_COLOR, PANEL_BORDER_COLOR);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, name, OBJPROP_BACK, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
    
    AddPanelObject(name);
    return true;
}

/**
 * Adiciona objeto à lista do painel
 */
void AddPanelObject(string name)
{
    ArrayResize(g_panel_objects, g_panel_object_count + 1);
    g_panel_objects[g_panel_object_count] = name;
    g_panel_object_count++;
}

/**
 * Atualiza painel com dados atuais
 */
void UpdatePanel()
{
    if(!g_panel_initialized || !g_config.visual.show_panel)
        return;
    
    // Verificar se precisa atualizar (máximo 1x por segundo)
    datetime current_time = TimeCurrent();
    if(current_time - g_last_panel_update < 1)
        return;
    
    // Atualizar seção Sistema
    UpdateSystemSection();
    
    // Atualizar seção Financeiro (SALDO SEMPRE ATUALIZADO)
    UpdateFinancialSection();
    
    // Atualizar seção Operações
    UpdateOperationsSection();
    
    // Atualizar seção Análise de Risco
    UpdateRiskSection();
    
    // Atualizar seção Notificações
    UpdateNotificationsSection();
    
    g_last_panel_update = current_time;
}

/**
 * Atualiza seção do sistema
 */
void UpdateSystemSection()
{
    // Status do sistema
    string status_text = "Status: ";
    switch(g_system_state)
    {
        case STATE_INITIALIZING: status_text += "Inicializando"; break;
        case STATE_RUNNING: status_text += "Executando"; break;
        case STATE_PAUSED: status_text += "Pausado"; break;
        case STATE_ERROR: status_text += "Erro"; break;
        case STATE_STOPPED: status_text += "Parado"; break;
        default: status_text += "Desconhecido"; break;
    }
    ObjectSetString(0, "ProbPanel_Status", OBJPROP_TEXT, status_text);
    
    // Padrão atual
    string pattern_text = "Padrão: " + PatternTypeToString(g_current_pattern);
    ObjectSetString(0, "ProbPanel_Pattern", OBJPROP_TEXT, pattern_text);
    
    // Último sinal
    string signal_text = "Último Sinal: ";
    if(g_last_signal.signal_time > 0)
    {
        signal_text += (g_last_signal.is_call ? "CALL" : "PUT");
        signal_text += " (" + TimeToString(g_last_signal.signal_time, TIME_MINUTES) + ")";
    }
    else
    {
        signal_text += "Nenhum";
    }
    ObjectSetString(0, "ProbPanel_LastSignal", OBJPROP_TEXT, signal_text);
}

/**
 * Atualiza seção financeiro (SALDO SEMPRE VISÍVEL)
 */
void UpdateFinancialSection()
{
    // SALDO - SEMPRE DESTACADO
    string balance_text = "Saldo: " + FormatCurrency(g_current_balance);
    ObjectSetString(0, "ProbPanel_Balance", OBJPROP_TEXT, balance_text);
    
    // Cor do saldo baseada no lucro/prejuízo
    color balance_color = PANEL_POSITIVE_COLOR;
    if(g_current_balance < g_starting_balance)
    {
        balance_color = PANEL_NEGATIVE_COLOR;
    }
    ObjectSetInteger(0, "ProbPanel_Balance", OBJPROP_COLOR, balance_color);
    
    // Lucro total
    string profit_text = "Lucro: " + FormatCurrency(g_total_profit);
    ObjectSetString(0, "ProbPanel_Profit", OBJPROP_TEXT, profit_text);
    
    color profit_color = (g_total_profit >= 0) ? PANEL_POSITIVE_COLOR : PANEL_NEGATIVE_COLOR;
    ObjectSetInteger(0, "ProbPanel_Profit", OBJPROP_COLOR, profit_color);
    
    // Valor de entrada atual
    string entry_text = "Valor Entrada: " + FormatCurrency(g_current_entry_value);
    ObjectSetString(0, "ProbPanel_EntryValue", OBJPROP_TEXT, entry_text);
    
    // Martingale
    string martingale_text = "Martingale: Nível " + IntegerToString(g_current_martingale_level);
    if(g_martingale_sequence_active)
    {
        martingale_text += " (Ativo)";
    }
    ObjectSetString(0, "ProbPanel_Martingale", OBJPROP_TEXT, martingale_text);
    
    color martingale_color = (g_current_martingale_level > 0) ? PANEL_NEGATIVE_COLOR : PANEL_TEXT_COLOR;
    ObjectSetInteger(0, "ProbPanel_Martingale", OBJPROP_COLOR, martingale_color);
}

/**
 * Atualiza seção de operações
 */
void UpdateOperationsSection()
{
    // Total de operações
    string total_text = "Total: " + IntegerToString(g_total_operations);
    ObjectSetString(0, "ProbPanel_TotalOps", OBJPROP_TEXT, total_text);
    
    // Vitórias
    string wins_text = "Vitórias: " + IntegerToString(g_total_wins);
    ObjectSetString(0, "ProbPanel_Wins", OBJPROP_TEXT, wins_text);
    
    // Perdas
    string losses_text = "Perdas: " + IntegerToString(g_total_losses);
    ObjectSetString(0, "ProbPanel_Losses", OBJPROP_TEXT, losses_text);
    
    // WinRate
    double winrate = 0.0;
    if(g_total_operations > 0)
    {
        winrate = ((double)g_total_wins / g_total_operations) * 100.0;
    }
    
    string winrate_text = "WinRate: " + FormatPercentage(winrate);
    ObjectSetString(0, "ProbPanel_Winrate", OBJPROP_TEXT, winrate_text);
    
    color winrate_color = PANEL_TEXT_COLOR;
    if(winrate >= 60.0)
        winrate_color = PANEL_POSITIVE_COLOR;
    else if(winrate < 50.0)
        winrate_color = PANEL_NEGATIVE_COLOR;
    
    ObjectSetInteger(0, "ProbPanel_Winrate", OBJPROP_COLOR, winrate_color);
}

/**
 * Atualiza seção de análise de risco
 */
void UpdateRiskSection()
{
    // Max Drawdown
    string drawdown_text = "Max Drawdown: " + FormatCurrency(g_max_drawdown_value);
    ObjectSetString(0, "ProbPanel_Drawdown", OBJPROP_TEXT, drawdown_text);
    
    color drawdown_color = (g_max_drawdown_value < 0) ? PANEL_NEGATIVE_COLOR : PANEL_TEXT_COLOR;
    ObjectSetInteger(0, "ProbPanel_Drawdown", OBJPROP_COLOR, drawdown_color);
    
    // Sharpe Ratio
    string sharpe_text = "Sharpe Ratio: " + DoubleToString(g_daily_stats.sharpe_ratio, 2);
    ObjectSetString(0, "ProbPanel_Sharpe", OBJPROP_TEXT, sharpe_text);
    
    // Volatilidade
    string volatility_text = "Volatilidade: " + FormatPercentage(g_daily_stats.volatility);
    ObjectSetString(0, "ProbPanel_Volatility", OBJPROP_TEXT, volatility_text);
}

/**
 * Atualiza seção de notificações
 */
void UpdateNotificationsSection()
{
    // Telegram
    string telegram_text = "Telegram: ";
    if(g_telegram_initialized && g_config.notifications.enable_telegram)
    {
        telegram_text += "Ativo (" + IntegerToString(g_telegram_messages_success) + " enviadas)";
    }
    else
    {
        telegram_text += "Desabilitado";
    }
    ObjectSetString(0, "ProbPanel_Telegram", OBJPROP_TEXT, telegram_text);
    
    // MX2
    string mx2_text = "MX2: ";
    if(g_mx2_initialized && g_config.notifications.enable_mx2)
    {
        mx2_text += "Ativo (" + BrokerMX2ToString(g_config.notifications.mx2_broker) + ")";
    }
    else
    {
        mx2_text += "Desabilitado";
    }
    ObjectSetString(0, "ProbPanel_MX2", OBJPROP_TEXT, mx2_text);
}

/**
 * Limpa objetos do painel
 */
void CleanupPanelObjects()
{
    for(int i = 0; i < g_panel_object_count; i++)
    {
        if(g_panel_objects[i] != "")
        {
            ObjectDelete(0, g_panel_objects[i]);
        }
    }
    
    g_panel_object_count = 0;
    ArrayResize(g_panel_objects, 0);
}

#endif // VISUAL_PANEL_CORE_MQH

