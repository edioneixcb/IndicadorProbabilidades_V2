//+------------------------------------------------------------------+
//|                                    Visual/Drawing.mqh |
//|                        Copyright 2024, Quant Genius (Refactoring) |
//|                                      https://www.google.com |
//|                                    VERSÃO CORRIGIDA v2.0        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quant Genius (Refactoring)"
#property link      "https://www.google.com"

#ifndef VISUAL_DRAWING_MQH
#define VISUAL_DRAWING_MQH

#include "../Core/Defines.mqh"
#include "../Core/Globals.mqh"
#include "../Core/Utilities.mqh"
#include "../Core/Logger.mqh"

// ==================================================================
// SISTEMA DE DESENHO VISUAL CORRIGIDO - VERSÃO 2.0
// ==================================================================

//+------------------------------------------------------------------+
//| CORREÇÃO #1: Função de plotagem de seta robusta                 |
//+------------------------------------------------------------------+
bool PlotarSetaRobusta(
    const SignalCoordinate &coord,
    int direction,
    color arrow_color,
    int arrow_size = 3,
    string prefix = ""
)
{
    if(!IsValidSignalCoordinate(coord))
    {
        Logger::Warning("Drawing", "Tentativa de plotar seta com coordenadas inválidas");
        return false;
    }
    
    // Gera nome único para o objeto
    string object_name = (prefix != "" ? prefix : arrowPrefix) + 
                        "arrow_" + IntegerToString(coord.plot_shift) + "_" + 
                        IntegerToString(GetTickCount());
    
    // Determina código da seta baseado na direção
    int arrow_code = (direction > 0) ? 233 : 234; // 233 = seta para cima, 234 = seta para baixo
    
    // Cria objeto de seta
    if(!ObjectCreate(0, object_name, OBJ_ARROW, 0, coord.plot_time, coord.plot_price))
    {
        int error = GetLastError();
        Logger::Error("Drawing", "Falha ao criar objeto de seta", 
                     "Erro: " + IntegerToString(error) + 
                     ", Nome: " + object_name);
        return false;
    }
    
    // Configura propriedades da seta
    ObjectSetInteger(0, object_name, OBJPROP_ARROWCODE, arrow_code);
    ObjectSetInteger(0, object_name, OBJPROP_COLOR, arrow_color);
    ObjectSetInteger(0, object_name, OBJPROP_WIDTH, arrow_size);
    ObjectSetInteger(0, object_name, OBJPROP_BACK, false);
    ObjectSetInteger(0, object_name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, object_name, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, object_name, OBJPROP_HIDDEN, true);
    
    // Define tooltip informativo
    string tooltip = "Sinal " + (direction > 0 ? "CALL" : "PUT") + 
                    " | Tempo: " + TimeToString(coord.plot_time) + 
                    " | Preço: " + DoubleToString(coord.plot_price, _Digits);
    
    ObjectSetString(0, object_name, OBJPROP_TOOLTIP, tooltip);
    
    Logger::Debug("Drawing", "Seta plotada com sucesso", 
                 "Nome: " + object_name + 
                 ", Direção: " + (direction > 0 ? "CALL" : "PUT") + 
                 ", Coordenadas: " + coord.debug_info);
    
    return true;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #2: Função de desenho de linha de resultado             |
//+------------------------------------------------------------------+
bool DesenharLinhaResultado(
    datetime start_time,
    double start_price,
    datetime end_time,
    double end_price,
    bool is_win,
    string prefix = ""
)
{
    // Validação de entrada
    if(!IsValidTimePeriod(start_time, end_time))
    {
        Logger::Warning("Drawing", "Período de tempo inválido para linha de resultado");
        return false;
    }
    
    if(start_price <= 0 || end_price <= 0)
    {
        Logger::Warning("Drawing", "Preços inválidos para linha de resultado");
        return false;
    }
    
    // Gera nome único para a linha
    string line_name = (prefix != "" ? prefix : resultPrefix) + 
                      "line_" + IntegerToString(start_time) + "_" + 
                      IntegerToString(GetTickCount());
    
    // Cria linha
    if(!ObjectCreate(0, line_name, OBJ_TREND, 0, start_time, start_price, end_time, end_price))
    {
        int error = GetLastError();
        Logger::Error("Drawing", "Falha ao criar linha de resultado", 
                     "Erro: " + IntegerToString(error));
        return false;
    }
    
    // Configura propriedades da linha
    color line_color = is_win ? clrGreen : clrRed;
    ENUM_LINE_STYLE line_style = is_win ? STYLE_SOLID : STYLE_DOT;
    
    ObjectSetInteger(0, line_name, OBJPROP_COLOR, line_color);
    ObjectSetInteger(0, line_name, OBJPROP_STYLE, line_style);
    ObjectSetInteger(0, line_name, OBJPROP_WIDTH, 2);
    ObjectSetInteger(0, line_name, OBJPROP_BACK, true);
    ObjectSetInteger(0, line_name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, line_name, OBJPROP_RAY_RIGHT, false);
    ObjectSetInteger(0, line_name, OBJPROP_HIDDEN, true);
    
    // Tooltip informativo
    string result_text = is_win ? "WIN" : "LOSS";
    double pips_diff = MathAbs(end_price - start_price) / _Point;
    
    string tooltip = "Resultado: " + result_text + 
                    " | Pips: " + DoubleToString(pips_diff, 1) + 
                    " | Início: " + TimeToString(start_time) + 
                    " | Fim: " + TimeToString(end_time);
    
    ObjectSetString(0, line_name, OBJPROP_TOOLTIP, tooltip);
    
    Logger::Debug("Drawing", "Linha de resultado desenhada", 
                 "Resultado: " + result_text + 
                 ", Pips: " + DoubleToString(pips_diff, 1));
    
    return true;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #3: Função de desenho de texto informativo              |
//+------------------------------------------------------------------+
bool DesenharTextoInformativo(
    datetime time,
    double price,
    string text,
    color text_color = clrWhite,
    int font_size = 10,
    string font_name = "Arial",
    string prefix = ""
)
{
    // Validação de entrada
    if(time <= 0 || price <= 0)
    {
        Logger::Warning("Drawing", "Coordenadas inválidas para texto");
        return false;
    }
    
    if(text == "")
    {
        Logger::Warning("Drawing", "Texto vazio fornecido");
        return false;
    }
    
    // Gera nome único para o texto
    string text_name = (prefix != "" ? prefix : "text_") + 
                      IntegerToString(time) + "_" + 
                      IntegerToString(GetTickCount());
    
    // Cria objeto de texto
    if(!ObjectCreate(0, text_name, OBJ_TEXT, 0, time, price))
    {
        int error = GetLastError();
        Logger::Error("Drawing", "Falha ao criar texto", 
                     "Erro: " + IntegerToString(error));
        return false;
    }
    
    // Configura propriedades do texto
    ObjectSetString(0, text_name, OBJPROP_TEXT, text);
    ObjectSetString(0, text_name, OBJPROP_FONT, font_name);
    ObjectSetInteger(0, text_name, OBJPROP_FONTSIZE, font_size);
    ObjectSetInteger(0, text_name, OBJPROP_COLOR, text_color);
    ObjectSetInteger(0, text_name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
    ObjectSetInteger(0, text_name, OBJPROP_BACK, false);
    ObjectSetInteger(0, text_name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, text_name, OBJPROP_HIDDEN, true);
    
    Logger::Debug("Drawing", "Texto informativo desenhado", 
                 "Texto: " + text + ", Posição: " + TimeToString(time));
    
    return true;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #4: Função de desenho de retângulo de destaque          |
//+------------------------------------------------------------------+
bool DesenharRetanguloDestaque(
    datetime start_time,
    double start_price,
    datetime end_time,
    double end_price,
    color fill_color = clrLightGray,
    color border_color = clrGray,
    bool fill = true,
    string prefix = ""
)
{
    // Validação de entrada
    if(!IsValidTimePeriod(start_time, end_time))
    {
        Logger::Warning("Drawing", "Período inválido para retângulo");
        return false;
    }
    
    if(start_price <= 0 || end_price <= 0)
    {
        Logger::Warning("Drawing", "Preços inválidos para retângulo");
        return false;
    }
    
    // Gera nome único
    string rect_name = (prefix != "" ? prefix : "rect_") + 
                      IntegerToString(start_time) + "_" + 
                      IntegerToString(GetTickCount());
    
    // Cria retângulo
    if(!ObjectCreate(0, rect_name, OBJ_RECTANGLE, 0, start_time, start_price, end_time, end_price))
    {
        int error = GetLastError();
        Logger::Error("Drawing", "Falha ao criar retângulo", 
                     "Erro: " + IntegerToString(error));
        return false;
    }
    
    // Configura propriedades
    ObjectSetInteger(0, rect_name, OBJPROP_COLOR, border_color);
    ObjectSetInteger(0, rect_name, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, rect_name, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, rect_name, OBJPROP_FILL, fill);
    ObjectSetInteger(0, rect_name, OBJPROP_BGCOLOR, fill_color);
    ObjectSetInteger(0, rect_name, OBJPROP_BACK, true);
    ObjectSetInteger(0, rect_name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, rect_name, OBJPROP_HIDDEN, true);
    
    Logger::Debug("Drawing", "Retângulo de destaque desenhado");
    
    return true;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #5: Função de limpeza seletiva de objetos              |
//+------------------------------------------------------------------+
int LimparObjetosPorTipo(ENUM_OBJECT tipo, string prefix_filter = "", int max_age_seconds = 0)
{
    int objects_removed = 0;
    datetime current_time = TimeCurrent();
    
    // Percorre todos os objetos do gráfico
    int total_objects = ObjectsTotal(0);
    
    for(int i = total_objects - 1; i >= 0; i--)
    {
        string object_name = ObjectName(0, i);
        
        // Verifica tipo do objeto
        if(ObjectGetInteger(0, object_name, OBJPROP_TYPE) != tipo)
            continue;
        
        // Aplica filtro de prefixo se especificado
        if(prefix_filter != "" && StringFind(object_name, prefix_filter) != 0)
            continue;
        
        // Aplica filtro de idade se especificado
        if(max_age_seconds > 0)
        {
            datetime object_time = (datetime)ObjectGetInteger(0, object_name, OBJPROP_TIME);
            if(object_time > 0 && (current_time - object_time) < max_age_seconds)
                continue;
        }
        
        // Remove objeto
        if(ObjectDelete(0, object_name))
        {
            objects_removed++;
            Logger::Debug("Drawing", "Objeto removido", "Nome: " + object_name);
        }
        else
        {
            Logger::Warning("Drawing", "Falha ao remover objeto", "Nome: " + object_name);
        }
    }
    
    if(objects_removed > 0)
    {
        Logger::Info("Drawing", "Limpeza de objetos concluída", 
                    "Removidos: " + IntegerToString(objects_removed) + 
                    " do tipo " + EnumToString(tipo));
    }
    
    return objects_removed;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #6: Função de otimização de objetos visuais             |
//+------------------------------------------------------------------+
void OtimizarObjetosVisuais(int max_objects_per_type = 100)
{
    Logger::Info("Drawing", "Iniciando otimização de objetos visuais");
    
    int total_objects = ObjectsTotal(0);
    
    if(total_objects < max_objects_per_type * 3) // 3 tipos principais
    {
        Logger::Debug("Drawing", "Otimização desnecessária", 
                     "Total: " + IntegerToString(total_objects));
        return;
    }
    
    // Remove setas antigas (mantém apenas as últimas)
    int arrows_removed = LimparObjetosPorTipo(OBJ_ARROW, arrowPrefix, 3600); // Mais de 1 hora
    
    // Remove linhas de resultado antigas
    int lines_removed = LimparObjetosPorTipo(OBJ_TREND, resultPrefix, 7200); // Mais de 2 horas
    
    // Remove textos antigos
    int texts_removed = LimparObjetosPorTipo(OBJ_TEXT, "text_", 1800); // Mais de 30 minutos
    
    int total_removed = arrows_removed + lines_removed + texts_removed;
    
    Logger::Info("Drawing", "Otimização concluída", 
                "Objetos removidos: " + IntegerToString(total_removed));
}

//+------------------------------------------------------------------+
//| CORREÇÃO #7: Função de desenho de indicador de status            |
//+------------------------------------------------------------------+
bool DesenharIndicadorStatus(
    string status_text,
    color status_color = clrWhite,
    int corner = CORNER_LEFT_UPPER,
    int x_offset = 10,
    int y_offset = 20
)
{
    string status_name = "status_indicator";
    
    // Remove indicador anterior se existir
    ObjectDelete(0, status_name);
    
    // Cria novo indicador
    if(!ObjectCreate(0, status_name, OBJ_LABEL, 0, 0, 0))
    {
        Logger::Error("Drawing", "Falha ao criar indicador de status");
        return false;
    }
    
    // Configura propriedades
    ObjectSetString(0, status_name, OBJPROP_TEXT, status_text);
    ObjectSetString(0, status_name, OBJPROP_FONT, "Arial Bold");
    ObjectSetInteger(0, status_name, OBJPROP_FONTSIZE, 12);
    ObjectSetInteger(0, status_name, OBJPROP_COLOR, status_color);
    ObjectSetInteger(0, status_name, OBJPROP_CORNER, corner);
    ObjectSetInteger(0, status_name, OBJPROP_XDISTANCE, x_offset);
    ObjectSetInteger(0, status_name, OBJPROP_YDISTANCE, y_offset);
    ObjectSetInteger(0, status_name, OBJPROP_BACK, false);
    ObjectSetInteger(0, status_name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, status_name, OBJPROP_HIDDEN, true);
    
    Logger::Debug("Drawing", "Indicador de status atualizado", "Status: " + status_text);
    
    return true;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #8: Função de desenho de grade de análise              |
//+------------------------------------------------------------------+
bool DesenharGradeAnalise(
    datetime start_time,
    datetime end_time,
    double price_center,
    double price_range,
    int grid_lines = 5,
    color grid_color = clrDarkGray
)
{
    // Validação de entrada
    if(!IsValidTimePeriod(start_time, end_time))
        return false;
    
    if(price_range <= 0 || grid_lines < 2)
        return false;
    
    string grid_prefix = "grid_";
    
    // Remove grade anterior
    LimparObjetosPorTipo(OBJ_HLINE, grid_prefix);
    LimparObjetosPorTipo(OBJ_VLINE, grid_prefix);
    
    // Desenha linhas horizontais
    double price_step = price_range / (grid_lines - 1);
    double start_price = price_center - (price_range / 2);
    
    for(int i = 0; i < grid_lines; i++)
    {
        double line_price = start_price + (i * price_step);
        string line_name = grid_prefix + "h_" + IntegerToString(i);
        
        if(ObjectCreate(0, line_name, OBJ_HLINE, 0, 0, line_price))
        {
            ObjectSetInteger(0, line_name, OBJPROP_COLOR, grid_color);
            ObjectSetInteger(0, line_name, OBJPROP_STYLE, STYLE_DOT);
            ObjectSetInteger(0, line_name, OBJPROP_WIDTH, 1);
            ObjectSetInteger(0, line_name, OBJPROP_BACK, true);
            ObjectSetInteger(0, line_name, OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, line_name, OBJPROP_HIDDEN, true);
        }
    }
    
    Logger::Debug("Drawing", "Grade de análise desenhada", 
                 "Linhas: " + IntegerToString(grid_lines));
    
    return true;
}

//+------------------------------------------------------------------+
//| Função de diagnóstico do sistema de desenho                     |
//+------------------------------------------------------------------+
void DiagnosticDrawingSystem()
{
    Logger::Info("Drawing", "=== DIAGNÓSTICO DO SISTEMA DE DESENHO ===");
    
    int total_objects = ObjectsTotal(0);
    Logger::Info("Drawing", "Total de objetos no gráfico: " + IntegerToString(total_objects));
    
    // Conta objetos por tipo
    int arrows = 0, lines = 0, texts = 0, labels = 0, others = 0;
    
    for(int i = 0; i < total_objects; i++)
    {
        string obj_name = ObjectName(0, i);
        ENUM_OBJECT obj_type = (ENUM_OBJECT)ObjectGetInteger(0, obj_name, OBJPROP_TYPE);
        
        switch(obj_type)
        {
            case OBJ_ARROW: arrows++; break;
            case OBJ_TREND: lines++; break;
            case OBJ_TEXT: texts++; break;
            case OBJ_LABEL: labels++; break;
            default: others++; break;
        }
    }
    
    Logger::Info("Drawing", "Setas: " + IntegerToString(arrows));
    Logger::Info("Drawing", "Linhas: " + IntegerToString(lines));
    Logger::Info("Drawing", "Textos: " + IntegerToString(texts));
    Logger::Info("Drawing", "Labels: " + IntegerToString(labels));
    Logger::Info("Drawing", "Outros: " + IntegerToString(others));
    
    // Verifica objetos do indicador
    int indicator_objects = 0;
    for(int i = 0; i < total_objects; i++)
    {
        string obj_name = ObjectName(0, i);
        if(StringFind(obj_name, arrowPrefix) >= 0 || 
           StringFind(obj_name, resultPrefix) >= 0 ||
           StringFind(obj_name, painelPrefix) >= 0)
        {
            indicator_objects++;
        }
    }
    
    Logger::Info("Drawing", "Objetos do indicador: " + IntegerToString(indicator_objects));
    
    Logger::Info("Drawing", "=== FIM DO DIAGNÓSTICO ===");
}

//+------------------------------------------------------------------+
//| Função de limpeza completa do sistema de desenho                |
//+------------------------------------------------------------------+
void LimpezaCompletaDesenho()
{
    Logger::Info("Drawing", "Iniciando limpeza completa do sistema de desenho");
    
    // Remove todos os objetos do indicador
    LimpaObjetosPorPrefixo(arrowPrefix);
    LimpaObjetosPorPrefixo(resultPrefix);
    LimpaObjetosPorPrefixo(painelPrefix);
    LimpaObjetosPorPrefixo("text_");
    LimpaObjetosPorPrefixo("grid_");
    LimpaObjetosPorPrefixo("rect_");
    
    // Remove indicador de status
    ObjectDelete(0, "status_indicator");
    
    Logger::Info("Drawing", "Limpeza completa concluída");
}

#endif // VISUAL_DRAWING_MQH

