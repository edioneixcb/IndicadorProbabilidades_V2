//+------------------------------------------------------------------+
//|                                    Visual/Panel.mqh |
//|                        Copyright 2024, Quant Genius (Refactoring) |
//|                                      https://www.google.com |
//|                                    VERSÃO CORRIGIDA v2.0        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quant Genius (Refactoring)"
#property link      "https://www.google.com"

#ifndef VISUAL_PANEL_MQH
#define VISUAL_PANEL_MQH

#include "../Core/Defines.mqh"
#include "../Core/Globals.mqh"
#include "../Core/Utilities.mqh"
#include "../Core/Logger.mqh"

// ==================================================================
// PAINEL VISUAL CORRIGIDO - VERSÃO 2.0
// ==================================================================

//+------------------------------------------------------------------+
//| CORREÇÃO: Criação de painel informativo robusto                 |
//+------------------------------------------------------------------+
bool CriarPainelInformativoRobusto(
    int x_position = 20,
    int y_position = 30,
    int width = 300,
    int height = 200,
    color background_color = clrDarkSlateGray,
    color border_color = clrSilver
)
{
    string panel_name = painelPrefix + "main_panel";
    
    // Remove painel anterior se existir
    ObjectDelete(0, panel_name);
    
    // Cria painel principal
    if(!ObjectCreate(0, panel_name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
    {
        Logger::Error("Panel", "Falha ao criar painel principal");
        return false;
    }
    
    // Configura propriedades do painel
    ObjectSetInteger(0, panel_name, OBJPROP_XDISTANCE, x_position);
    ObjectSetInteger(0, panel_name, OBJPROP_YDISTANCE, y_position);
    ObjectSetInteger(0, panel_name, OBJPROP_XSIZE, width);
    ObjectSetInteger(0, panel_name, OBJPROP_YSIZE, height);
    ObjectSetInteger(0, panel_name, OBJPROP_BGCOLOR, background_color);
    ObjectSetInteger(0, panel_name, OBJPROP_BORDER_COLOR, border_color);
    ObjectSetInteger(0, panel_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, panel_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, panel_name, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, panel_name, OBJPROP_WIDTH, 2);
    ObjectSetInteger(0, panel_name, OBJPROP_BACK, false);
    ObjectSetInteger(0, panel_name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, panel_name, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, panel_name, OBJPROP_HIDDEN, true);
    
    Logger::Debug("Panel", "Painel principal criado", 
                 "Posição: " + IntegerToString(x_position) + "," + IntegerToString(y_position) + 
                 ", Tamanho: " + IntegerToString(width) + "x" + IntegerToString(height));
    
    return true;
}

//+------------------------------------------------------------------+
//| Adiciona título ao painel                                       |
//+------------------------------------------------------------------+
bool AdicionarTituloPainel(
    string titulo,
    int x_offset = 10,
    int y_offset = 10,
    color text_color = clrWhite,
    int font_size = 12
)
{
    string title_name = painelPrefix + "title";
    
    // Remove título anterior
    ObjectDelete(0, title_name);
    
    // Cria título
    if(!ObjectCreate(0, title_name, OBJ_LABEL, 0, 0, 0))
    {
        Logger::Error("Panel", "Falha ao criar título do painel");
        return false;
    }
    
    // Configura propriedades do título
    ObjectSetString(0, title_name, OBJPROP_TEXT, titulo);
    ObjectSetString(0, title_name, OBJPROP_FONT, "Arial Bold");
    ObjectSetInteger(0, title_name, OBJPROP_FONTSIZE, font_size);
    ObjectSetInteger(0, title_name, OBJPROP_COLOR, text_color);
    ObjectSetInteger(0, title_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, title_name, OBJPROP_XDISTANCE, 20 + x_offset);
    ObjectSetInteger(0, title_name, OBJPROP_YDISTANCE, 30 + y_offset);
    ObjectSetInteger(0, title_name, OBJPROP_BACK, false);
    ObjectSetInteger(0, title_name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, title_name, OBJPROP_HIDDEN, true);
    
    return true;
}

//+------------------------------------------------------------------+
//| Atualiza informações do painel                                  |
//+------------------------------------------------------------------+
bool AtualizarInformacoesPainel(
    string status_sistema,
    int total_sinais,
    int sinais_corretos,
    double taxa_acerto,
    string ultimo_padrao,
    datetime ultimo_sinal_tempo
)
{
    // Informações a serem exibidas
    string info_lines[] = {
        "Status: " + status_sistema,
        "Total Sinais: " + IntegerToString(total_sinais),
        "Sinais Corretos: " + IntegerToString(sinais_corretos),
        "Taxa Acerto: " + DoubleToString(taxa_acerto, 1) + "%",
        "Último Padrão: " + ultimo_padrao,
        "Último Sinal: " + (ultimo_sinal_tempo > 0 ? TimeToString(ultimo_sinal_tempo, TIME_MINUTES) : "Nenhum")
    };
    
    // Remove informações anteriores
    for(int i = 0; i < 10; i++)
    {
        ObjectDelete(0, painelPrefix + "info_" + IntegerToString(i));
    }
    
    // Adiciona novas informações
    for(int i = 0; i < ArraySize(info_lines); i++)
    {
        string info_name = painelPrefix + "info_" + IntegerToString(i);
        
        if(!ObjectCreate(0, info_name, OBJ_LABEL, 0, 0, 0))
            continue;
        
        // Determina cor baseada no conteúdo
        color text_color = clrLightGray;
        if(StringFind(info_lines[i], "Status") >= 0)
        {
            if(StringFind(info_lines[i], "Ativo") >= 0)
                text_color = clrLimeGreen;
            else if(StringFind(info_lines[i], "Erro") >= 0)
                text_color = clrRed;
        }
        else if(StringFind(info_lines[i], "Taxa Acerto") >= 0)
        {
            if(taxa_acerto >= 70)
                text_color = clrLimeGreen;
            else if(taxa_acerto >= 60)
                text_color = clrYellow;
            else
                text_color = clrOrange;
        }
        
        // Configura propriedades
        ObjectSetString(0, info_name, OBJPROP_TEXT, info_lines[i]);
        ObjectSetString(0, info_name, OBJPROP_FONT, "Consolas");
        ObjectSetInteger(0, info_name, OBJPROP_FONTSIZE, 9);
        ObjectSetInteger(0, info_name, OBJPROP_COLOR, text_color);
        ObjectSetInteger(0, info_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, info_name, OBJPROP_XDISTANCE, 30);
        ObjectSetInteger(0, info_name, OBJPROP_YDISTANCE, 55 + (i * 18));
        ObjectSetInteger(0, info_name, OBJPROP_BACK, false);
        ObjectSetInteger(0, info_name, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, info_name, OBJPROP_HIDDEN, true);
    }
    
    Logger::Debug("Panel", "Informações do painel atualizadas");
    return true;
}

//+------------------------------------------------------------------+
//| Adiciona botão ao painel                                        |
//+------------------------------------------------------------------+
bool AdicionarBotaoPainel(
    string button_id,
    string button_text,
    int x_position,
    int y_position,
    int width = 80,
    int height = 25,
    color button_color = clrDarkGray,
    color text_color = clrWhite
)
{
    string button_name = painelPrefix + "btn_" + button_id;
    
    // Remove botão anterior se existir
    ObjectDelete(0, button_name);
    
    // Cria botão
    if(!ObjectCreate(0, button_name, OBJ_BUTTON, 0, 0, 0))
    {
        Logger::Error("Panel", "Falha ao criar botão", "ID: " + button_id);
        return false;
    }
    
    // Configura propriedades do botão
    ObjectSetString(0, button_name, OBJPROP_TEXT, button_text);
    ObjectSetString(0, button_name, OBJPROP_FONT, "Arial");
    ObjectSetInteger(0, button_name, OBJPROP_FONTSIZE, 9);
    ObjectSetInteger(0, button_name, OBJPROP_COLOR, text_color);
    ObjectSetInteger(0, button_name, OBJPROP_BGCOLOR, button_color);
    ObjectSetInteger(0, button_name, OBJPROP_BORDER_COLOR, clrSilver);
    ObjectSetInteger(0, button_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, button_name, OBJPROP_XDISTANCE, x_position);
    ObjectSetInteger(0, button_name, OBJPROP_YDISTANCE, y_position);
    ObjectSetInteger(0, button_name, OBJPROP_XSIZE, width);
    ObjectSetInteger(0, button_name, OBJPROP_YSIZE, height);
    ObjectSetInteger(0, button_name, OBJPROP_BACK, false);
    ObjectSetInteger(0, button_name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, button_name, OBJPROP_HIDDEN, true);
    
    Logger::Debug("Panel", "Botão adicionado", "ID: " + button_id + ", Texto: " + button_text);
    return true;
}

//+------------------------------------------------------------------+
//| Processa clique em botão do painel                              |
//+------------------------------------------------------------------+
string ProcessarCliqueBotao(string object_name)
{
    if(StringFind(object_name, painelPrefix + "btn_") != 0)
        return ""; // Não é um botão do painel
    
    // Extrai ID do botão
    string button_id = StringSubstr(object_name, StringLen(painelPrefix + "btn_"));
    
    Logger::Debug("Panel", "Botão clicado", "ID: " + button_id);
    
    // Feedback visual temporário
    ObjectSetInteger(0, object_name, OBJPROP_BGCOLOR, clrDarkBlue);
    Sleep(100);
    ObjectSetInteger(0, object_name, OBJPROP_BGCOLOR, clrDarkGray);
    
    return button_id;
}

//+------------------------------------------------------------------+
//| Cria painel de estatísticas em tempo real                       |
//+------------------------------------------------------------------+
bool CriarPainelEstatisticas(
    int x_pos = 350,
    int y_pos = 30,
    int width = 250,
    int height = 150
)
{
    string stats_panel = painelPrefix + "stats_panel";
    
    // Remove painel anterior
    ObjectDelete(0, stats_panel);
    
    // Cria painel de estatísticas
    if(!ObjectCreate(0, stats_panel, OBJ_RECTANGLE_LABEL, 0, 0, 0))
        return false;
    
    // Configura painel
    ObjectSetInteger(0, stats_panel, OBJPROP_XDISTANCE, x_pos);
    ObjectSetInteger(0, stats_panel, OBJPROP_YDISTANCE, y_pos);
    ObjectSetInteger(0, stats_panel, OBJPROP_XSIZE, width);
    ObjectSetInteger(0, stats_panel, OBJPROP_YSIZE, height);
    ObjectSetInteger(0, stats_panel, OBJPROP_BGCOLOR, clrDarkSlateBlue);
    ObjectSetInteger(0, stats_panel, OBJPROP_BORDER_COLOR, clrSilver);
    ObjectSetInteger(0, stats_panel, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, stats_panel, OBJPROP_BACK, false);
    ObjectSetInteger(0, stats_panel, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, stats_panel, OBJPROP_HIDDEN, true);
    
    // Adiciona título
    string stats_title = painelPrefix + "stats_title";
    ObjectCreate(0, stats_title, OBJ_LABEL, 0, 0, 0);
    ObjectSetString(0, stats_title, OBJPROP_TEXT, "ESTATÍSTICAS TEMPO REAL");
    ObjectSetString(0, stats_title, OBJPROP_FONT, "Arial Bold");
    ObjectSetInteger(0, stats_title, OBJPROP_FONTSIZE, 10);
    ObjectSetInteger(0, stats_title, OBJPROP_COLOR, clrYellow);
    ObjectSetInteger(0, stats_title, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, stats_title, OBJPROP_XDISTANCE, x_pos + 10);
    ObjectSetInteger(0, stats_title, OBJPROP_YDISTANCE, y_pos + 10);
    ObjectSetInteger(0, stats_title, OBJPROP_BACK, false);
    ObjectSetInteger(0, stats_title, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, stats_title, OBJPROP_HIDDEN, true);
    
    return true;
}

//+------------------------------------------------------------------+
//| Atualiza estatísticas em tempo real                             |
//+------------------------------------------------------------------+
bool AtualizarEstatisticasTempoReal(
    double spread_atual,
    double atr_atual,
    int sinais_hoje,
    double performance_hoje,
    string status_cache
)
{
    string stats_info[] = {
        "Spread: " + DoubleToString(spread_atual, 1) + " pts",
        "ATR: " + DoubleToString(atr_atual, 5),
        "Sinais Hoje: " + IntegerToString(sinais_hoje),
        "Performance: " + DoubleToString(performance_hoje, 1) + "%",
        "Cache: " + status_cache,
        "Atualizado: " + TimeToString(TimeCurrent(), TIME_MINUTES)
    };
    
    // Remove estatísticas anteriores
    for(int i = 0; i < 10; i++)
    {
        ObjectDelete(0, painelPrefix + "stat_" + IntegerToString(i));
    }
    
    // Adiciona novas estatísticas
    for(int i = 0; i < ArraySize(stats_info); i++)
    {
        string stat_name = painelPrefix + "stat_" + IntegerToString(i);
        
        if(!ObjectCreate(0, stat_name, OBJ_LABEL, 0, 0, 0))
            continue;
        
        ObjectSetString(0, stat_name, OBJPROP_TEXT, stats_info[i]);
        ObjectSetString(0, stat_name, OBJPROP_FONT, "Consolas");
        ObjectSetInteger(0, stat_name, OBJPROP_FONTSIZE, 8);
        ObjectSetInteger(0, stat_name, OBJPROP_COLOR, clrLightBlue);
        ObjectSetInteger(0, stat_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, stat_name, OBJPROP_XDISTANCE, 360);
        ObjectSetInteger(0, stat_name, OBJPROP_YDISTANCE, 55 + (i * 15));
        ObjectSetInteger(0, stat_name, OBJPROP_BACK, false);
        ObjectSetInteger(0, stat_name, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, stat_name, OBJPROP_HIDDEN, true);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Remove todos os painéis                                         |
//+------------------------------------------------------------------+
void RemoverTodosPaineis()
{
    Logger::Info("Panel", "Removendo todos os painéis");
    
    // Remove painel principal e componentes
    LimpaObjetosPorPrefixo(painelPrefix);
    
    Logger::Debug("Panel", "Painéis removidos com sucesso");
}

//+------------------------------------------------------------------+
//| Função de diagnóstico do sistema de painéis                    |
//+------------------------------------------------------------------+
void DiagnosticPanelSystem()
{
    Logger::Info("Panel", "=== DIAGNÓSTICO DO SISTEMA DE PAINÉIS ===");
    
    int total_objects = ObjectsTotal(0);
    int panel_objects = 0;
    
    for(int i = 0; i < total_objects; i++)
    {
        string obj_name = ObjectName(0, i);
        if(StringFind(obj_name, painelPrefix) >= 0)
        {
            panel_objects++;
        }
    }
    
    Logger::Info("Panel", "Objetos do painel: " + IntegerToString(panel_objects));
    Logger::Info("Panel", "Total de objetos: " + IntegerToString(total_objects));
    
    // Verifica se painel principal existe
    bool main_panel_exists = ObjectFind(0, painelPrefix + "main_panel") >= 0;
    Logger::Info("Panel", "Painel principal existe: " + BoolToString(main_panel_exists));
    
    Logger::Info("Panel", "=== FIM DO DIAGNÓSTICO ===");
}

#endif // VISUAL_PANEL_MQH

