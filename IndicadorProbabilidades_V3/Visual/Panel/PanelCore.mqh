//+------------------------------------------------------------------+
//|                                    Visual/Panel/PanelCore.mqh |
//|                                    Indicador de Probabilidades V3 |
//|                                Sistema de Painel Visual Core |
//+------------------------------------------------------------------+

#ifndef VISUAL_PANEL_CORE_MQH
#define VISUAL_PANEL_CORE_MQH

#include "../../Core/Types.mqh"
#include "../../Core/Defines.mqh"
#include "../../Core/Globals.mqh"
#include "../../Analysis/Financial/FinancialCore.mqh"

//+------------------------------------------------------------------+
//| Estruturas do Painel Visual                                     |
//+------------------------------------------------------------------+

/**
 * Estrutura de configuração do painel
 */
struct PanelConfiguration
{
    bool enabled;                      // Painel habilitado
    PanelPosition position;            // Posição do painel
    int offset_x;                      // Offset horizontal
    int offset_y;                      // Offset vertical
    int width;                         // Largura do painel
    int height;                        // Altura do painel
    color background_color;            // Cor de fundo
    color border_color;                // Cor da borda
    color text_color;                  // Cor do texto
    color header_color;                // Cor do cabeçalho
    color positive_color;              // Cor para valores positivos
    color negative_color;              // Cor para valores negativos
    color neutral_color;               // Cor neutra
    int font_size;                     // Tamanho da fonte
    string font_name;                  // Nome da fonte
    bool show_balance;                 // Mostrar saldo
    bool show_operations;              // Mostrar operações
    bool show_winrate;                 // Mostrar winrate
    bool show_martingale;              // Mostrar martingale
    bool show_patterns;                // Mostrar padrões
    bool show_filters;                 // Mostrar filtros
    bool show_notifications;           // Mostrar notificações
    bool show_performance;             // Mostrar performance
    bool show_risk;                    // Mostrar risco
    bool auto_resize;                  // Redimensionar automaticamente
    int update_interval_ms;            // Intervalo de atualização
    bool enable_animations;            // Habilitar animações
    double transparency;               // Transparência (0-1)
};

/**
 * Estrutura de elemento do painel
 */
struct PanelElement
{
    string name;                       // Nome do elemento
    ElementType type;                  // Tipo do elemento
    int x;                             // Posição X
    int y;                             // Posição Y
    int width;                         // Largura
    int height;                        // Altura
    string text;                       // Texto
    color text_color;                  // Cor do texto
    color background_color;            // Cor de fundo
    int font_size;                     // Tamanho da fonte
    bool visible;                      // Visível
    bool clickable;                    // Clicável
    string tooltip;                    // Tooltip
    datetime last_update;              // Última atualização
};

/**
 * Estrutura de seção do painel
 */
struct PanelSection
{
    string title;                      // Título da seção
    int start_y;                       // Y inicial
    int height;                        // Altura da seção
    bool collapsed;                    // Seção colapsada
    bool visible;                      // Seção visível
    PanelElement elements[];           // Elementos da seção
};

//+------------------------------------------------------------------+
//| Variáveis Globais do Painel                                     |
//+------------------------------------------------------------------+
PanelConfiguration g_panel_config;    // Configuração do painel
PanelSection g_panel_sections[];      // Seções do painel
datetime g_last_panel_update = 0;     // Última atualização
bool g_panel_needs_redraw = true;     // Precisa redesenhar
int g_panel_total_height = 0;         // Altura total calculada
string g_panel_prefix = "ProbV3_Panel_"; // Prefixo dos objetos

// Índices das seções
int g_section_header = 0;
int g_section_balance = 1;
int g_section_operations = 2;
int g_section_martingale = 3;
int g_section_patterns = 4;
int g_section_filters = 5;
int g_section_notifications = 6;
int g_section_performance = 7;
int g_section_risk = 8;
int g_section_controls = 9;

//+------------------------------------------------------------------+
//| Funções de Inicialização do Painel                              |
//+------------------------------------------------------------------+

/**
 * Inicializa o sistema de painel visual
 * @return true se inicializado com sucesso
 */
bool InitializePanel()
{
    // Carrega configuração
    LoadPanelConfiguration();
    
    // Verifica se está habilitado
    if(!g_panel_config.enabled)
    {
        Print("Painel Visual: Desabilitado");
        return true;
    }
    
    // Remove objetos existentes
    RemoveAllPanelObjects();
    
    // Inicializa seções
    InitializePanelSections();
    
    // Calcula layout
    CalculatePanelLayout();
    
    // Cria elementos visuais
    CreatePanelElements();
    
    // Primeira atualização
    UpdatePanelData();
    
    g_panel_initialized = true;
    Print("Painel Visual: Inicializado com sucesso");
    
    return true;
}

/**
 * Carrega configuração do painel
 */
void LoadPanelConfiguration()
{
    g_panel_config.enabled = g_config.visual.show_panel;
    g_panel_config.position = g_config.visual.panel_position;
    g_panel_config.offset_x = g_config.visual.panel_offset_x;
    g_panel_config.offset_y = g_config.visual.panel_offset_y;
    g_panel_config.width = 280;
    g_panel_config.height = 600;
    g_panel_config.background_color = g_config.visual.panel_background_color;
    g_panel_config.border_color = g_config.visual.panel_border_color;
    g_panel_config.text_color = g_config.visual.panel_text_color;
    g_panel_config.header_color = clrDodgerBlue;
    g_panel_config.positive_color = g_config.visual.call_color;
    g_panel_config.negative_color = g_config.visual.put_color;
    g_panel_config.neutral_color = clrGray;
    g_panel_config.font_size = 8;
    g_panel_config.font_name = "Arial";
    g_panel_config.show_balance = true;
    g_panel_config.show_operations = true;
    g_panel_config.show_winrate = true;
    g_panel_config.show_martingale = true;
    g_panel_config.show_patterns = true;
    g_panel_config.show_filters = true;
    g_panel_config.show_notifications = true;
    g_panel_config.show_performance = true;
    g_panel_config.show_risk = true;
    g_panel_config.auto_resize = true;
    g_panel_config.update_interval_ms = 1000;
    g_panel_config.enable_animations = false;
    g_panel_config.transparency = 0.9;
}

/**
 * Inicializa seções do painel
 */
void InitializePanelSections()
{
    ArrayResize(g_panel_sections, 10);
    
    // Seção Header
    g_panel_sections[g_section_header].title = "INDICADOR PROBABILIDADES V3";
    g_panel_sections[g_section_header].visible = true;
    g_panel_sections[g_section_header].collapsed = false;
    
    // Seção Balance
    g_panel_sections[g_section_balance].title = "SALDO E FINANCEIRO";
    g_panel_sections[g_section_balance].visible = g_panel_config.show_balance;
    g_panel_sections[g_section_balance].collapsed = false;
    
    // Seção Operations
    g_panel_sections[g_section_operations].title = "OPERAÇÕES HOJE";
    g_panel_sections[g_section_operations].visible = g_panel_config.show_operations;
    g_panel_sections[g_section_operations].collapsed = false;
    
    // Seção Martingale
    g_panel_sections[g_section_martingale].title = "MARTINGALE";
    g_panel_sections[g_section_martingale].visible = g_panel_config.show_martingale;
    g_panel_sections[g_section_martingale].collapsed = false;
    
    // Seção Patterns
    g_panel_sections[g_section_patterns].title = "PADRÕES";
    g_panel_sections[g_section_patterns].visible = g_panel_config.show_patterns;
    g_panel_sections[g_section_patterns].collapsed = false;
    
    // Seção Filters
    g_panel_sections[g_section_filters].title = "FILTROS";
    g_panel_sections[g_section_filters].visible = g_panel_config.show_filters;
    g_panel_sections[g_section_filters].collapsed = false;
    
    // Seção Notifications
    g_panel_sections[g_section_notifications].title = "NOTIFICAÇÕES";
    g_panel_sections[g_section_notifications].visible = g_panel_config.show_notifications;
    g_panel_sections[g_section_notifications].collapsed = false;
    
    // Seção Performance
    g_panel_sections[g_section_performance].title = "PERFORMANCE";
    g_panel_sections[g_section_performance].visible = g_panel_config.show_performance;
    g_panel_sections[g_section_performance].collapsed = false;
    
    // Seção Risk
    g_panel_sections[g_section_risk].title = "ANÁLISE DE RISCO";
    g_panel_sections[g_section_risk].visible = g_panel_config.show_risk;
    g_panel_sections[g_section_risk].collapsed = false;
    
    // Seção Controls
    g_panel_sections[g_section_controls].title = "CONTROLES";
    g_panel_sections[g_section_controls].visible = true;
    g_panel_sections[g_section_controls].collapsed = false;
}

/**
 * Calcula layout do painel
 */
void CalculatePanelLayout()
{
    int current_y = 10;
    int section_spacing = 5;
    int element_height = 15;
    int header_height = 20;
    
    for(int i = 0; i < ArraySize(g_panel_sections); i++)
    {
        if(!g_panel_sections[i].visible)
        {
            continue;
        }
        
        g_panel_sections[i].start_y = current_y;
        
        // Altura do cabeçalho da seção
        current_y += header_height;
        
        if(!g_panel_sections[i].collapsed)
        {
            // Calcula altura baseada no conteúdo
            int section_elements = GetSectionElementCount(i);
            g_panel_sections[i].height = header_height + (section_elements * element_height);
            current_y += (section_elements * element_height);
        }
        else
        {
            g_panel_sections[i].height = header_height;
        }
        
        current_y += section_spacing;
    }
    
    g_panel_total_height = current_y + 10;
    
    // Ajusta altura do painel se auto-resize estiver habilitado
    if(g_panel_config.auto_resize)
    {
        g_panel_config.height = g_panel_total_height;
    }
}

/**
 * Obtém número de elementos de uma seção
 * @param section_index Índice da seção
 * @return Número de elementos
 */
int GetSectionElementCount(int section_index)
{
    switch(section_index)
    {
        case 0: return 3; // Header: Título, Status, Tempo
        case 1: return 6; // Balance: Saldo Atual, Inicial, Lucro, ROI, Stop Loss, Stop Win
        case 2: return 5; // Operations: Total, Vitórias, Perdas, WinRate, Lucro Diário
        case 3: return 4; // Martingale: Nível, Próximo Valor, Investimento Total, Risco
        case 4: return 3; // Patterns: Ativo, Confiança, Último Sinal
        case 5: return 4; // Filters: ATR, Bollinger, Tendência, Status
        case 6: return 3; // Notifications: Telegram, MX2, Último Envio
        case 7: return 5; // Performance: Sharpe, Volatilidade, Max DD, Recovery, Calmar
        case 8: return 4; // Risk: VaR 95%, VaR 99%, Expected Shortfall, Beta
        case 9: return 4; // Controls: SuperScan, Reset, Pause, Config
        default: return 0;
    }
}

/**
 * Cria elementos visuais do painel
 */
void CreatePanelElements()
{
    // Calcula posição base do painel
    int base_x, base_y;
    CalculatePanelPosition(base_x, base_y);
    
    // Cria fundo do painel
    CreatePanelBackground(base_x, base_y);
    
    // Cria seções
    for(int i = 0; i < ArraySize(g_panel_sections); i++)
    {
        if(g_panel_sections[i].visible)
        {
            CreateSectionElements(i, base_x, base_y);
        }
    }
}

/**
 * Calcula posição do painel na tela
 * @param base_x Posição X calculada
 * @param base_y Posição Y calculada
 */
void CalculatePanelPosition(int &base_x, int &base_y)
{
    int chart_width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
    int chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
    
    switch(g_panel_config.position)
    {
        case PANEL_TOP_LEFT:
            base_x = g_panel_config.offset_x;
            base_y = g_panel_config.offset_y;
            break;
            
        case PANEL_TOP_RIGHT:
            base_x = chart_width - g_panel_config.width - g_panel_config.offset_x;
            base_y = g_panel_config.offset_y;
            break;
            
        case PANEL_BOTTOM_LEFT:
            base_x = g_panel_config.offset_x;
            base_y = chart_height - g_panel_config.height - g_panel_config.offset_y;
            break;
            
        case PANEL_BOTTOM_RIGHT:
            base_x = chart_width - g_panel_config.width - g_panel_config.offset_x;
            base_y = chart_height - g_panel_config.height - g_panel_config.offset_y;
            break;
            
        case PANEL_CENTER:
            base_x = (chart_width - g_panel_config.width) / 2 + g_panel_config.offset_x;
            base_y = (chart_height - g_panel_config.height) / 2 + g_panel_config.offset_y;
            break;
            
        default:
            base_x = g_panel_config.offset_x;
            base_y = g_panel_config.offset_y;
            break;
    }
}

/**
 * Cria fundo do painel
 * @param base_x Posição X base
 * @param base_y Posição Y base
 */
void CreatePanelBackground(int base_x, int base_y)
{
    string bg_name = g_panel_prefix + "Background";
    
    // Remove objeto existente
    ObjectDelete(0, bg_name);
    
    // Cria retângulo de fundo
    ObjectCreate(0, bg_name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, bg_name, OBJPROP_XDISTANCE, base_x);
    ObjectSetInteger(0, bg_name, OBJPROP_YDISTANCE, base_y);
    ObjectSetInteger(0, bg_name, OBJPROP_XSIZE, g_panel_config.width);
    ObjectSetInteger(0, bg_name, OBJPROP_YSIZE, g_panel_config.height);
    ObjectSetInteger(0, bg_name, OBJPROP_BGCOLOR, g_panel_config.background_color);
    ObjectSetInteger(0, bg_name, OBJPROP_BORDER_COLOR, g_panel_config.border_color);
    ObjectSetInteger(0, bg_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, bg_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, bg_name, OBJPROP_BACK, false);
    ObjectSetInteger(0, bg_name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, bg_name, OBJPROP_HIDDEN, true);
}

/**
 * Cria elementos de uma seção
 * @param section_index Índice da seção
 * @param base_x Posição X base
 * @param base_y Posição Y base
 */
void CreateSectionElements(int section_index, int base_x, int base_y)
{
    PanelSection &section = g_panel_sections[section_index];
    
    // Cria cabeçalho da seção
    CreateSectionHeader(section_index, base_x, base_y);
    
    if(!section.collapsed)
    {
        // Cria elementos específicos da seção
        switch(section_index)
        {
            case 0: CreateHeaderElements(base_x, base_y); break;
            case 1: CreateBalanceElements(base_x, base_y); break;
            case 2: CreateOperationsElements(base_x, base_y); break;
            case 3: CreateMartingaleElements(base_x, base_y); break;
            case 4: CreatePatternsElements(base_x, base_y); break;
            case 5: CreateFiltersElements(base_x, base_y); break;
            case 6: CreateNotificationsElements(base_x, base_y); break;
            case 7: CreatePerformanceElements(base_x, base_y); break;
            case 8: CreateRiskElements(base_x, base_y); break;
            case 9: CreateControlsElements(base_x, base_y); break;
        }
    }
}

/**
 * Cria cabeçalho de uma seção
 * @param section_index Índice da seção
 * @param base_x Posição X base
 * @param base_y Posição Y base
 */
void CreateSectionHeader(int section_index, int base_x, int base_y)
{
    PanelSection &section = g_panel_sections[section_index];
    string header_name = g_panel_prefix + "Header_" + IntegerToString(section_index);
    
    // Remove objeto existente
    ObjectDelete(0, header_name);
    
    // Cria label do cabeçalho
    ObjectCreate(0, header_name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, header_name, OBJPROP_XDISTANCE, base_x + 5);
    ObjectSetInteger(0, header_name, OBJPROP_YDISTANCE, base_y + section.start_y);
    ObjectSetString(0, header_name, OBJPROP_TEXT, section.title);
    ObjectSetString(0, header_name, OBJPROP_FONT, g_panel_config.font_name);
    ObjectSetInteger(0, header_name, OBJPROP_FONTSIZE, g_panel_config.font_size + 1);
    ObjectSetInteger(0, header_name, OBJPROP_COLOR, g_panel_config.header_color);
    ObjectSetInteger(0, header_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, header_name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, header_name, OBJPROP_HIDDEN, true);
}

/**
 * Cria elementos da seção Header
 * @param base_x Posição X base
 * @param base_y Posição Y base
 */
void CreateHeaderElements(int base_x, int base_y)
{
    int start_y = g_panel_sections[g_section_header].start_y + 20;
    
    CreateLabel("Status", "Status: Operacional", base_x + 10, base_y + start_y, g_panel_config.positive_color);
    CreateLabel("Version", "Versão: " + INDICATOR_VERSION, base_x + 10, base_y + start_y + 15, g_panel_config.text_color);
    CreateLabel("Time", "Tempo: " + TimeToString(TimeCurrent(), TIME_SECONDS), base_x + 10, base_y + start_y + 30, g_panel_config.text_color);
}

/**
 * Cria elementos da seção Balance
 * @param base_x Posição X base
 * @param base_y Posição Y base
 */
void CreateBalanceElements(int base_x, int base_y)
{
    int start_y = g_panel_sections[g_section_balance].start_y + 20;
    
    CreateLabel("BalanceCurrent", "Saldo Atual: " + FormatCurrency(g_current_balance), base_x + 10, base_y + start_y, g_panel_config.text_color);
    CreateLabel("BalanceInitial", "Saldo Inicial: " + FormatCurrency(g_starting_balance), base_x + 10, base_y + start_y + 15, g_panel_config.text_color);
    
    double profit = g_current_balance - g_starting_balance;
    color profit_color = profit >= 0 ? g_panel_config.positive_color : g_panel_config.negative_color;
    CreateLabel("Profit", "Lucro/Prejuízo: " + FormatCurrency(profit), base_x + 10, base_y + start_y + 30, profit_color);
    
    double roi = g_starting_balance > 0 ? (profit / g_starting_balance) * 100.0 : 0.0;
    CreateLabel("ROI", "ROI: " + DoubleToString(roi, 2) + "%", base_x + 10, base_y + start_y + 45, profit_color);
    
    string stop_loss_text = g_stop_loss_active ? "ATIVO" : "Inativo";
    color stop_loss_color = g_stop_loss_active ? g_panel_config.negative_color : g_panel_config.neutral_color;
    CreateLabel("StopLoss", "Stop Loss: " + stop_loss_text, base_x + 10, base_y + start_y + 60, stop_loss_color);
    
    string stop_win_text = g_stop_win_active ? "ATIVO" : "Inativo";
    color stop_win_color = g_stop_win_active ? g_panel_config.positive_color : g_panel_config.neutral_color;
    CreateLabel("StopWin", "Stop Win: " + stop_win_text, base_x + 10, base_y + start_y + 75, stop_win_color);
}

/**
 * Cria elementos da seção Operations
 * @param base_x Posição X base
 * @param base_y Posição Y base
 */
void CreateOperationsElements(int base_x, int base_y)
{
    int start_y = g_panel_sections[g_section_operations].start_y + 20;
    
    CreateLabel("OpTotal", "Total: " + IntegerToString(g_total_operations_today), base_x + 10, base_y + start_y, g_panel_config.text_color);
    CreateLabel("OpWins", "Vitórias: " + IntegerToString(g_total_wins_today), base_x + 10, base_y + start_y + 15, g_panel_config.positive_color);
    CreateLabel("OpLosses", "Perdas: " + IntegerToString(g_total_losses_today), base_x + 10, base_y + start_y + 30, g_panel_config.negative_color);
    
    color winrate_color = g_daily_winrate >= 60.0 ? g_panel_config.positive_color : 
                         g_daily_winrate >= 40.0 ? g_panel_config.neutral_color : g_panel_config.negative_color;
    CreateLabel("WinRate", "WinRate: " + DoubleToString(g_daily_winrate, 1) + "%", base_x + 10, base_y + start_y + 45, winrate_color);
    
    color daily_profit_color = g_daily_profit >= 0 ? g_panel_config.positive_color : g_panel_config.negative_color;
    CreateLabel("DailyProfit", "Lucro Diário: " + FormatCurrency(g_daily_profit), base_x + 10, base_y + start_y + 60, daily_profit_color);
}

/**
 * Cria elementos da seção Martingale
 * @param base_x Posição X base
 * @param base_y Posição Y base
 */
void CreateMartingaleElements(int base_x, int base_y)
{
    int start_y = g_panel_sections[g_section_martingale].start_y + 20;
    
    color level_color = g_current_martingale_level == 0 ? g_panel_config.positive_color : 
                       g_current_martingale_level <= 2 ? g_panel_config.neutral_color : g_panel_config.negative_color;
    CreateLabel("MartLevel", "Nível: " + IntegerToString(g_current_martingale_level), base_x + 10, base_y + start_y, level_color);
    
    double next_value = CalculateEntryValue(g_current_martingale_level);
    CreateLabel("MartNext", "Próximo: " + FormatCurrency(next_value), base_x + 10, base_y + start_y + 15, g_panel_config.text_color);
    
    if(g_current_martingale_level < ArraySize(g_martingale_sim.total_investment))
    {
        double total_investment = g_martingale_sim.total_investment[g_current_martingale_level];
        CreateLabel("MartTotal", "Total Inv.: " + FormatCurrency(total_investment), base_x + 10, base_y + start_y + 30, g_panel_config.text_color);
        
        double risk_percentage = g_martingale_sim.risk_percentage[g_current_martingale_level];
        color risk_color = risk_percentage <= 5.0 ? g_panel_config.positive_color : 
                          risk_percentage <= 15.0 ? g_panel_config.neutral_color : g_panel_config.negative_color;
        CreateLabel("MartRisk", "Risco: " + DoubleToString(risk_percentage, 1) + "%", base_x + 10, base_y + start_y + 45, risk_color);
    }
}

/**
 * Cria elementos da seção Patterns
 * @param base_x Posição X base
 * @param base_y Posição Y base
 */
void CreatePatternsElements(int base_x, int base_y)
{
    int start_y = g_panel_sections[g_section_patterns].start_y + 20;
    
    CreateLabel("PatternActive", "Ativo: " + PatternTypeToString(g_active_pattern), base_x + 10, base_y + start_y, g_panel_config.text_color);
    CreateLabel("PatternConf", "Confiança: " + DoubleToString(g_last_signal_confidence, 1) + "%", base_x + 10, base_y + start_y + 15, g_panel_config.text_color);
    
    string last_signal_text = g_last_signal_time > 0 ? TimeToString(g_last_signal_time, TIME_SECONDS) : "Nenhum";
    CreateLabel("PatternLast", "Último: " + last_signal_text, base_x + 10, base_y + start_y + 30, g_panel_config.text_color);
}

/**
 * Cria elementos da seção Filters
 * @param base_x Posição X base
 * @param base_y Posição Y base
 */
void CreateFiltersElements(int base_x, int base_y)
{
    int start_y = g_panel_sections[g_section_filters].start_y + 20;
    
    CreateLabel("FilterATR", "ATR: " + DoubleToString(g_current_atr, 5), base_x + 10, base_y + start_y, g_panel_config.text_color);
    
    string bb_status = g_market_filters.bollinger_bands_active ? "Ativo" : "Inativo";
    color bb_color = g_market_filters.bollinger_bands_active ? g_panel_config.positive_color : g_panel_config.neutral_color;
    CreateLabel("FilterBB", "Bollinger: " + bb_status, base_x + 10, base_y + start_y + 15, bb_color);
    
    string trend_text = g_market_filters.trend_direction == 1 ? "Alta" : 
                       g_market_filters.trend_direction == -1 ? "Baixa" : "Lateral";
    CreateLabel("FilterTrend", "Tendência: " + trend_text, base_x + 10, base_y + start_y + 30, g_panel_config.text_color);
    
    string filter_status = g_market_filters.all_filters_passed ? "APROVADO" : "REPROVADO";
    color filter_color = g_market_filters.all_filters_passed ? g_panel_config.positive_color : g_panel_config.negative_color;
    CreateLabel("FilterStatus", "Status: " + filter_status, base_x + 10, base_y + start_y + 45, filter_color);
}

/**
 * Cria elementos da seção Notifications
 * @param base_x Posição X base
 * @param base_y Posição Y base
 */
void CreateNotificationsElements(int base_x, int base_y)
{
    int start_y = g_panel_sections[g_section_notifications].start_y + 20;
    
    string telegram_status = IsTelegramOperational() ? "Ativo" : "Inativo";
    color telegram_color = IsTelegramOperational() ? g_panel_config.positive_color : g_panel_config.negative_color;
    CreateLabel("NotifTelegram", "Telegram: " + telegram_status, base_x + 10, base_y + start_y, telegram_color);
    
    string mx2_status = IsMX2Operational() ? "Ativo" : "Inativo";
    color mx2_color = IsMX2Operational() ? g_panel_config.positive_color : g_panel_config.negative_color;
    CreateLabel("NotifMX2", "MX2: " + mx2_status, base_x + 10, base_y + start_y + 15, mx2_color);
    
    datetime last_notification = MathMax(g_last_telegram_message_time, g_last_mx2_signal_time);
    string last_text = last_notification > 0 ? TimeToString(last_notification, TIME_SECONDS) : "Nenhum";
    CreateLabel("NotifLast", "Último: " + last_text, base_x + 10, base_y + start_y + 30, g_panel_config.text_color);
}

/**
 * Cria elementos da seção Performance
 * @param base_x Posição X base
 * @param base_y Posição Y base
 */
void CreatePerformanceElements(int base_x, int base_y)
{
    int start_y = g_panel_sections[g_section_performance].start_y + 20;
    
    CreateLabel("PerfSharpe", "Sharpe: " + DoubleToString(g_daily_stats.sharpe_ratio, 3), base_x + 10, base_y + start_y, g_panel_config.text_color);
    CreateLabel("PerfVol", "Volatilidade: " + DoubleToString(g_daily_stats.volatility * 100, 2) + "%", base_x + 10, base_y + start_y + 15, g_panel_config.text_color);
    CreateLabel("PerfDD", "Max DD: " + DoubleToString(g_daily_stats.max_drawdown_percentage, 2) + "%", base_x + 10, base_y + start_y + 30, g_panel_config.text_color);
    CreateLabel("PerfRecovery", "Recovery: " + DoubleToString(g_daily_stats.recovery_factor, 2), base_x + 10, base_y + start_y + 45, g_panel_config.text_color);
    CreateLabel("PerfCalmar", "Calmar: " + DoubleToString(g_daily_stats.calmar_ratio, 3), base_x + 10, base_y + start_y + 60, g_panel_config.text_color);
}

/**
 * Cria elementos da seção Risk
 * @param base_x Posição X base
 * @param base_y Posição Y base
 */
void CreateRiskElements(int base_x, int base_y)
{
    int start_y = g_panel_sections[g_section_risk].start_y + 20;
    
    CreateLabel("RiskVaR95", "VaR 95%: " + FormatCurrency(g_risk_analysis.var_95), base_x + 10, base_y + start_y, g_panel_config.text_color);
    CreateLabel("RiskVaR99", "VaR 99%: " + FormatCurrency(g_risk_analysis.var_99), base_x + 10, base_y + start_y + 15, g_panel_config.text_color);
    CreateLabel("RiskES", "Exp. Shortfall: " + FormatCurrency(g_risk_analysis.expected_shortfall), base_x + 10, base_y + start_y + 30, g_panel_config.text_color);
    CreateLabel("RiskBeta", "Beta: " + DoubleToString(g_risk_analysis.beta, 3), base_x + 10, base_y + start_y + 45, g_panel_config.text_color);
}

/**
 * Cria elementos da seção Controls
 * @param base_x Posição X base
 * @param base_y Posição Y base
 */
void CreateControlsElements(int base_x, int base_y)
{
    int start_y = g_panel_sections[g_section_controls].start_y + 20;
    
    string superscan_text = g_superscan_running ? "EXECUTANDO" : "Parado";
    color superscan_color = g_superscan_running ? g_panel_config.positive_color : g_panel_config.neutral_color;
    CreateLabel("CtrlSuperScan", "SuperScan: " + superscan_text, base_x + 10, base_y + start_y, superscan_color);
    
    CreateLabel("CtrlReset", "Reset Diário: Manual", base_x + 10, base_y + start_y + 15, g_panel_config.text_color);
    
    string pause_text = g_system_paused ? "PAUSADO" : "Ativo";
    color pause_color = g_system_paused ? g_panel_config.negative_color : g_panel_config.positive_color;
    CreateLabel("CtrlPause", "Sistema: " + pause_text, base_x + 10, base_y + start_y + 30, pause_color);
    
    CreateLabel("CtrlConfig", "Config: OK", base_x + 10, base_y + start_y + 45, g_panel_config.positive_color);
}

/**
 * Cria um label
 * @param name Nome do objeto
 * @param text Texto do label
 * @param x Posição X
 * @param y Posição Y
 * @param color Cor do texto
 */
void CreateLabel(string name, string text, int x, int y, color text_color)
{
    string full_name = g_panel_prefix + name;
    
    // Remove objeto existente
    ObjectDelete(0, full_name);
    
    // Cria novo label
    ObjectCreate(0, full_name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, full_name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, full_name, OBJPROP_YDISTANCE, y);
    ObjectSetString(0, full_name, OBJPROP_TEXT, text);
    ObjectSetString(0, full_name, OBJPROP_FONT, g_panel_config.font_name);
    ObjectSetInteger(0, full_name, OBJPROP_FONTSIZE, g_panel_config.font_size);
    ObjectSetInteger(0, full_name, OBJPROP_COLOR, text_color);
    ObjectSetInteger(0, full_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, full_name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, full_name, OBJPROP_HIDDEN, true);
}

//+------------------------------------------------------------------+
//| Funções de Atualização do Painel                                |
//+------------------------------------------------------------------+

/**
 * Atualiza dados do painel
 */
void UpdatePanelData()
{
    if(!g_panel_initialized || !g_panel_config.enabled)
    {
        return;
    }
    
    datetime current_time = TimeCurrent();
    
    // Verifica intervalo de atualização
    if(current_time - g_last_panel_update < g_panel_config.update_interval_ms / 1000)
    {
        return;
    }
    
    // Atualiza elementos dinâmicos
    UpdateDynamicElements();
    
    g_last_panel_update = current_time;
}

/**
 * Atualiza elementos dinâmicos
 */
void UpdateDynamicElements()
{
    // Atualiza tempo
    UpdateLabel("Time", "Tempo: " + TimeToString(TimeCurrent(), TIME_SECONDS));
    
    // Atualiza saldo
    UpdateLabel("BalanceCurrent", "Saldo Atual: " + FormatCurrency(g_current_balance));
    
    double profit = g_current_balance - g_starting_balance;
    color profit_color = profit >= 0 ? g_panel_config.positive_color : g_panel_config.negative_color;
    UpdateLabel("Profit", "Lucro/Prejuízo: " + FormatCurrency(profit), profit_color);
    
    double roi = g_starting_balance > 0 ? (profit / g_starting_balance) * 100.0 : 0.0;
    UpdateLabel("ROI", "ROI: " + DoubleToString(roi, 2) + "%", profit_color);
    
    // Atualiza operações
    UpdateLabel("OpTotal", "Total: " + IntegerToString(g_total_operations_today));
    UpdateLabel("OpWins", "Vitórias: " + IntegerToString(g_total_wins_today));
    UpdateLabel("OpLosses", "Perdas: " + IntegerToString(g_total_losses_today));
    
    color winrate_color = g_daily_winrate >= 60.0 ? g_panel_config.positive_color : 
                         g_daily_winrate >= 40.0 ? g_panel_config.neutral_color : g_panel_config.negative_color;
    UpdateLabel("WinRate", "WinRate: " + DoubleToString(g_daily_winrate, 1) + "%", winrate_color);
    
    color daily_profit_color = g_daily_profit >= 0 ? g_panel_config.positive_color : g_panel_config.negative_color;
    UpdateLabel("DailyProfit", "Lucro Diário: " + FormatCurrency(g_daily_profit), daily_profit_color);
    
    // Atualiza martingale
    color level_color = g_current_martingale_level == 0 ? g_panel_config.positive_color : 
                       g_current_martingale_level <= 2 ? g_panel_config.neutral_color : g_panel_config.negative_color;
    UpdateLabel("MartLevel", "Nível: " + IntegerToString(g_current_martingale_level), level_color);
    
    double next_value = CalculateEntryValue(g_current_martingale_level);
    UpdateLabel("MartNext", "Próximo: " + FormatCurrency(next_value));
    
    // Atualiza filtros
    string filter_status = g_market_filters.all_filters_passed ? "APROVADO" : "REPROVADO";
    color filter_color = g_market_filters.all_filters_passed ? g_panel_config.positive_color : g_panel_config.negative_color;
    UpdateLabel("FilterStatus", "Status: " + filter_status, filter_color);
    
    // Atualiza notificações
    string telegram_status = IsTelegramOperational() ? "Ativo" : "Inativo";
    color telegram_color = IsTelegramOperational() ? g_panel_config.positive_color : g_panel_config.negative_color;
    UpdateLabel("NotifTelegram", "Telegram: " + telegram_status, telegram_color);
    
    string mx2_status = IsMX2Operational() ? "Ativo" : "Inativo";
    color mx2_color = IsMX2Operational() ? g_panel_config.positive_color : g_panel_config.negative_color;
    UpdateLabel("NotifMX2", "MX2: " + mx2_status, mx2_color);
}

/**
 * Atualiza texto de um label
 * @param name Nome do label
 * @param text Novo texto
 * @param text_color Nova cor (opcional)
 */
void UpdateLabel(string name, string text, color text_color = clrNONE)
{
    string full_name = g_panel_prefix + name;
    
    if(ObjectFind(0, full_name) >= 0)
    {
        ObjectSetString(0, full_name, OBJPROP_TEXT, text);
        
        if(text_color != clrNONE)
        {
            ObjectSetInteger(0, full_name, OBJPROP_COLOR, text_color);
        }
    }
}

/**
 * Remove todos os objetos do painel
 */
void RemoveAllPanelObjects()
{
    int total_objects = ObjectsTotal(0, -1, -1);
    
    for(int i = total_objects - 1; i >= 0; i--)
    {
        string obj_name = ObjectName(0, i, -1, -1);
        
        if(StringFind(obj_name, g_panel_prefix) == 0)
        {
            ObjectDelete(0, obj_name);
        }
    }
}

/**
 * Força redesenho do painel
 */
void RedrawPanel()
{
    if(!g_panel_initialized || !g_panel_config.enabled)
    {
        return;
    }
    
    RemoveAllPanelObjects();
    CreatePanelElements();
    UpdatePanelData();
    
    ChartRedraw(0);
}

/**
 * Verifica se painel está operacional
 * @return true se operacional
 */
bool IsPanelOperational()
{
    return g_panel_initialized && g_panel_config.enabled;
}

#endif // VISUAL_PANEL_CORE_MQH

