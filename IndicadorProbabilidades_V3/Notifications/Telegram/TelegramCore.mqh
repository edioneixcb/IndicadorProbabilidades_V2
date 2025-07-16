//+------------------------------------------------------------------+
//|                              Notifications/Telegram/TelegramCore.mqh |
//|                                    Indicador de Probabilidades V3 |
//|                            Sistema de Notificações Telegram Core |
//+------------------------------------------------------------------+

#ifndef NOTIFICATIONS_TELEGRAM_CORE_MQH
#define NOTIFICATIONS_TELEGRAM_CORE_MQH

#include "../../Core/Types.mqh"
#include "../../Core/Defines.mqh"
#include "../../Core/Globals.mqh"

//+------------------------------------------------------------------+
//| Estruturas Específicas do Telegram                              |
//+------------------------------------------------------------------+

/**
 * Estrutura de configuração do Telegram
 */
struct TelegramConfiguration
{
    bool enabled;                      // Telegram habilitado
    string bot_token;                  // Token do bot
    string chat_id;                    // ID do chat
    string title;                      // Título das mensagens
    bool send_signals;                 // Enviar sinais
    bool send_results;                 // Enviar resultados
    bool send_statistics;              // Enviar estatísticas
    bool send_images;                  // Enviar imagens
    bool send_charts;                  // Enviar gráficos
    bool enable_markdown;              // Habilitar markdown
    bool enable_html;                  // Habilitar HTML
    int message_timeout;               // Timeout das mensagens
    int max_retries;                   // Máximo de tentativas
    bool enable_logging;               // Habilitar logging
    string custom_template;            // Template customizado
};

/**
 * Estrutura de mensagem Telegram
 */
struct TelegramMessage
{
    string chat_id;                    // ID do chat
    string text;                       // Texto da mensagem
    string parse_mode;                 // Modo de parsing (HTML/Markdown)
    bool disable_web_page_preview;     // Desabilitar preview
    bool disable_notification;         // Desabilitar notificação
    string reply_markup;               // Markup de resposta
    string image_path;                 // Caminho da imagem
    string image_caption;              // Legenda da imagem
};

/**
 * Estrutura de resposta do Telegram
 */
struct TelegramResponse
{
    bool success;                      // Sucesso no envio
    int status_code;                   // Código de status HTTP
    string response_body;              // Corpo da resposta
    string error_message;              // Mensagem de erro
    datetime timestamp;                // Timestamp da resposta
    double processing_time_ms;         // Tempo de processamento
    int message_id;                    // ID da mensagem enviada
};

/**
 * Estrutura de template de mensagem
 */
struct MessageTemplate
{
    string signal_template;            // Template para sinais
    string result_template;            // Template para resultados
    string statistics_template;        // Template para estatísticas
    string superscan_template;         // Template para SuperVarredura
    string error_template;             // Template para erros
    string status_template;            // Template para status
};

//+------------------------------------------------------------------+
//| Variáveis Globais do Telegram                                   |
//+------------------------------------------------------------------+
TelegramConfiguration g_telegram_config; // Configuração do Telegram
TelegramResponse g_last_telegram_response; // Última resposta
MessageTemplate g_message_templates;     // Templates de mensagem
int g_telegram_messages_sent = 0;        // Mensagens enviadas
int g_telegram_messages_success = 0;     // Mensagens enviadas com sucesso
int g_telegram_messages_failed = 0;      // Mensagens que falharam
datetime g_last_telegram_message_time = 0; // Última mensagem enviada
string g_telegram_base_url = "";         // URL base da API

//+------------------------------------------------------------------+
//| Funções de Inicialização do Telegram                            |
//+------------------------------------------------------------------+

/**
 * Inicializa o sistema Telegram
 * @return true se inicializado com sucesso
 */
bool InitializeTelegram()
{
    // Carrega configuração
    LoadTelegramConfiguration();
    
    // Verifica se está habilitado
    if(!g_telegram_config.enabled)
    {
        Print("Telegram: Sistema desabilitado");
        return true; // Não é erro, apenas desabilitado
    }
    
    // Valida configuração
    if(!ValidateTelegramConfiguration())
    {
        Print("Telegram: Configuração inválida");
        return false;
    }
    
    // Constrói URL base
    g_telegram_base_url = "https://api.telegram.org/bot" + g_telegram_config.bot_token;
    
    // Testa conectividade
    if(!TestTelegramConnectivity())
    {
        Print("Telegram: Falha na conectividade");
        return false;
    }
    
    // Carrega templates
    LoadMessageTemplates();
    
    // Reset contadores
    g_telegram_messages_sent = 0;
    g_telegram_messages_success = 0;
    g_telegram_messages_failed = 0;
    
    g_telegram_initialized = true;
    Print("Telegram: Sistema inicializado com sucesso");
    
    return true;
}

/**
 * Carrega configuração do Telegram
 */
void LoadTelegramConfiguration()
{
    g_telegram_config.enabled = g_config.notifications.enable_telegram;
    g_telegram_config.bot_token = g_config.notifications.telegram_token;
    g_telegram_config.chat_id = g_config.notifications.telegram_chat_id;
    g_telegram_config.title = g_config.notifications.telegram_title;
    g_telegram_config.send_images = g_config.notifications.telegram_send_images;
    g_telegram_config.send_signals = g_config.notifications.notify_signals;
    g_telegram_config.send_results = g_config.notifications.notify_results;
    g_telegram_config.send_statistics = true;
    g_telegram_config.send_charts = false;
    g_telegram_config.enable_markdown = true;
    g_telegram_config.enable_html = false;
    g_telegram_config.message_timeout = 30;
    g_telegram_config.max_retries = 3;
    g_telegram_config.enable_logging = true;
    g_telegram_config.custom_template = "";
}

/**
 * Valida configuração do Telegram
 * @return true se configuração é válida
 */
bool ValidateTelegramConfiguration()
{
    if(StringLen(g_telegram_config.bot_token) == 0)
    {
        Print("Telegram: Token do bot não configurado");
        return false;
    }
    
    if(StringLen(g_telegram_config.chat_id) == 0)
    {
        Print("Telegram: Chat ID não configurado");
        return false;
    }
    
    // Valida formato do token (deve ter formato: 123456789:ABC-DEF...)
    if(StringFind(g_telegram_config.bot_token, ":") < 0)
    {
        Print("Telegram: Formato do token inválido");
        return false;
    }
    
    // Valida chat ID (deve ser numérico ou começar com @)
    if(StringGetCharacter(g_telegram_config.chat_id, 0) != '@' && 
       !IsNumericString(g_telegram_config.chat_id))
    {
        Print("Telegram: Formato do Chat ID inválido");
        return false;
    }
    
    return true;
}

/**
 * Testa conectividade com o Telegram
 * @return true se conectividade OK
 */
bool TestTelegramConnectivity()
{
    string test_url = g_telegram_base_url + "/getMe";
    
    char data[];
    char result[];
    string headers = "Content-Type: application/json\r\n";
    
    int timeout = g_telegram_config.message_timeout * 1000;
    int res = WebRequest("GET", test_url, headers, timeout, data, result, headers);
    
    if(res == 200)
    {
        string response = CharArrayToString(result);
        if(StringFind(response, "\"ok\":true") >= 0)
        {
            Print("Telegram: Conectividade OK");
            return true;
        }
    }
    
    Print("Telegram: Falha na conectividade - Código: ", res);
    return false;
}

/**
 * Carrega templates de mensagem
 */
void LoadMessageTemplates()
{
    // Template para sinais
    g_message_templates.signal_template = 
        "🎯 *SINAL DETECTADO*\n\n" +
        "📊 *Símbolo:* {SYMBOL}\n" +
        "📈 *Direção:* {DIRECTION}\n" +
        "🔍 *Padrão:* {PATTERN}\n" +
        "⚡ *Confiança:* {CONFIDENCE}%\n" +
        "💰 *Valor:* {ENTRY_VALUE}\n" +
        "⏰ *Horário:* {TIME}\n" +
        "🎲 *Expiração:* {EXPIRY} min\n\n" +
        "📋 *Filtros:* {FILTERS}\n" +
        "📊 *ATR:* {ATR}\n\n" +
        "🤖 _{TITLE}_";
    
    // Template para resultados
    g_message_templates.result_template = 
        "{RESULT_ICON} *RESULTADO*\n\n" +
        "📊 *Símbolo:* {SYMBOL}\n" +
        "📈 *Direção:* {DIRECTION}\n" +
        "🔍 *Padrão:* {PATTERN}\n" +
        "💰 *Valor:* {ENTRY_VALUE}\n" +
        "💵 *Resultado:* {PROFIT_LOSS}\n" +
        "📊 *Saldo:* {BALANCE}\n\n" +
        "📈 *WinRate Hoje:* {DAILY_WINRATE}%\n" +
        "💰 *Lucro Hoje:* {DAILY_PROFIT}\n" +
        "🎯 *Operações:* {OPERATIONS}\n\n" +
        "🤖 _{TITLE}_";
    
    // Template para estatísticas
    g_message_templates.statistics_template = 
        "📊 *ESTATÍSTICAS DIÁRIAS*\n\n" +
        "🎯 *Sinais:* {TOTAL_SIGNALS}\n" +
        "💼 *Operações:* {TOTAL_OPERATIONS}\n" +
        "✅ *Vitórias:* {TOTAL_WINS}\n" +
        "❌ *Perdas:* {TOTAL_LOSSES}\n" +
        "📈 *WinRate:* {WINRATE}%\n\n" +
        "💰 *Lucro Total:* {TOTAL_PROFIT}\n" +
        "💵 *Saldo Atual:* {CURRENT_BALANCE}\n" +
        "📊 *ROI:* {ROI}%\n\n" +
        "🔍 *Padrão Ativo:* {ACTIVE_PATTERN}\n" +
        "⚡ *Status:* {STATUS}\n\n" +
        "🤖 _{TITLE}_";
    
    // Template para SuperVarredura
    g_message_templates.superscan_template = 
        "🔍 *SUPERVARREDURA CONCLUÍDA*\n\n" +
        "🏆 *Melhor Padrão:* {BEST_PATTERN}\n" +
        "📈 *WinRate:* {BEST_WINRATE}%\n" +
        "💰 *Lucro:* {BEST_PROFIT}\n" +
        "🎯 *Operações:* {BEST_OPERATIONS}\n" +
        "⚡ *Confiança:* {CONFIDENCE_SCORE}%\n\n" +
        "🔄 *Invertido:* {INVERTED}\n" +
        "⏱️ *Duração:* {SCAN_DURATION}s\n" +
        "📊 *Padrões Testados:* {PATTERNS_TESTED}\n\n" +
        "🤖 _{TITLE}_";
    
    // Template para erros
    g_message_templates.error_template = 
        "⚠️ *ERRO DETECTADO*\n\n" +
        "🔴 *Tipo:* {ERROR_TYPE}\n" +
        "📝 *Mensagem:* {ERROR_MESSAGE}\n" +
        "⏰ *Horário:* {TIME}\n" +
        "🔧 *Função:* {FUNCTION}\n\n" +
        "🤖 _{TITLE}_";
    
    // Template para status
    g_message_templates.status_template = 
        "ℹ️ *STATUS DO SISTEMA*\n\n" +
        "⚡ *Estado:* {STATE}\n" +
        "🔍 *Padrão:* {ACTIVE_PATTERN}\n" +
        "📊 *Sinais Hoje:* {SIGNALS_TODAY}\n" +
        "💼 *Operações:* {OPERATIONS_TODAY}\n" +
        "📈 *WinRate:* {WINRATE}%\n" +
        "💰 *Lucro:* {PROFIT}\n\n" +
        "🕐 *Uptime:* {UPTIME}\n" +
        "💾 *Memória:* {MEMORY_USAGE}MB\n" +
        "⚡ *CPU:* {CPU_USAGE}%\n\n" +
        "🤖 _{TITLE}_";
}

//+------------------------------------------------------------------+
//| Funções de Envio de Mensagens                                   |
//+------------------------------------------------------------------+

/**
 * Envia sinal para o Telegram
 * @param signal_info Informações do sinal
 * @return true se enviado com sucesso
 */
bool SendSignalToTelegram(const SignalInfo &signal_info)
{
    if(!g_telegram_initialized || !g_telegram_config.enabled || !g_telegram_config.send_signals)
    {
        return false;
    }
    
    // Cria mensagem do sinal
    TelegramMessage message;
    if(!CreateSignalMessage(signal_info, message))
    {
        Print("Telegram: Falha ao criar mensagem de sinal");
        return false;
    }
    
    // Envia mensagem
    return SendTelegramMessage(message);
}

/**
 * Envia resultado para o Telegram
 * @param operation_info Informações da operação
 * @return true se enviado com sucesso
 */
bool SendResultToTelegram(const OperationInfo &operation_info)
{
    if(!g_telegram_initialized || !g_telegram_config.enabled || !g_telegram_config.send_results)
    {
        return false;
    }
    
    // Cria mensagem do resultado
    TelegramMessage message;
    if(!CreateResultMessage(operation_info, message))
    {
        Print("Telegram: Falha ao criar mensagem de resultado");
        return false;
    }
    
    // Envia mensagem
    return SendTelegramMessage(message);
}

/**
 * Envia estatísticas para o Telegram
 * @return true se enviado com sucesso
 */
bool SendStatisticsToTelegram()
{
    if(!g_telegram_initialized || !g_telegram_config.enabled || !g_telegram_config.send_statistics)
    {
        return false;
    }
    
    // Cria mensagem de estatísticas
    TelegramMessage message;
    if(!CreateStatisticsMessage(message))
    {
        Print("Telegram: Falha ao criar mensagem de estatísticas");
        return false;
    }
    
    // Envia mensagem
    return SendTelegramMessage(message);
}

/**
 * Envia resultado de SuperVarredura para o Telegram
 * @param superscan_result Resultado da SuperVarredura
 * @return true se enviado com sucesso
 */
bool SendSuperScanToTelegram(const SuperScanResult &superscan_result)
{
    if(!g_telegram_initialized || !g_telegram_config.enabled)
    {
        return false;
    }
    
    // Cria mensagem da SuperVarredura
    TelegramMessage message;
    if(!CreateSuperScanMessage(superscan_result, message))
    {
        Print("Telegram: Falha ao criar mensagem de SuperVarredura");
        return false;
    }
    
    // Envia mensagem
    return SendTelegramMessage(message);
}

/**
 * Envia erro para o Telegram
 * @param error_message Mensagem de erro
 * @param function_name Nome da função
 * @return true se enviado com sucesso
 */
bool SendErrorToTelegram(const string error_message, const string function_name = "")
{
    if(!g_telegram_initialized || !g_telegram_config.enabled)
    {
        return false;
    }
    
    // Cria mensagem de erro
    TelegramMessage message;
    if(!CreateErrorMessage(error_message, function_name, message))
    {
        Print("Telegram: Falha ao criar mensagem de erro");
        return false;
    }
    
    // Envia mensagem
    return SendTelegramMessage(message);
}

//+------------------------------------------------------------------+
//| Funções de Criação de Mensagens                                 |
//+------------------------------------------------------------------+

/**
 * Cria mensagem de sinal
 * @param signal_info Informações do sinal
 * @param message Estrutura de mensagem a ser preenchida
 * @return true se criado com sucesso
 */
bool CreateSignalMessage(const SignalInfo &signal_info, TelegramMessage &message)
{
    string text = g_message_templates.signal_template;
    
    // Substitui placeholders
    StringReplace(text, "{SYMBOL}", _Symbol);
    StringReplace(text, "{DIRECTION}", signal_info.is_call ? "🟢 CALL" : "🔴 PUT");
    StringReplace(text, "{PATTERN}", PatternTypeToString(signal_info.pattern_type));
    StringReplace(text, "{CONFIDENCE}", DoubleToString(signal_info.confidence, 1));
    StringReplace(text, "{ENTRY_VALUE}", FormatCurrency(g_config.financial.entry_value));
    StringReplace(text, "{TIME}", TimeToString(signal_info.signal_time, TIME_DATE|TIME_SECONDS));
    StringReplace(text, "{EXPIRY}", IntegerToString(g_config.notifications.mx2_expiry_minutes));
    StringReplace(text, "{FILTERS}", signal_info.filter_passed ? "✅ Aprovado" : "❌ Reprovado");
    StringReplace(text, "{ATR}", DoubleToString(signal_info.atr_value, 5));
    StringReplace(text, "{TITLE}", g_telegram_config.title);
    
    // Preenche estrutura da mensagem
    message.chat_id = g_telegram_config.chat_id;
    message.text = text;
    message.parse_mode = g_telegram_config.enable_markdown ? "Markdown" : "";
    message.disable_web_page_preview = true;
    message.disable_notification = false;
    
    return true;
}

/**
 * Cria mensagem de resultado
 * @param operation_info Informações da operação
 * @param message Estrutura de mensagem a ser preenchida
 * @return true se criado com sucesso
 */
bool CreateResultMessage(const OperationInfo &operation_info, TelegramMessage &message)
{
    string text = g_message_templates.result_template;
    
    // Ícone do resultado
    string result_icon = "";
    switch(operation_info.result)
    {
        case RESULT_WIN: result_icon = "✅"; break;
        case RESULT_LOSS: result_icon = "❌"; break;
        case RESULT_GALE1_WIN: result_icon = "🟡"; break;
        case RESULT_GALE2_WIN: result_icon = "🟠"; break;
        case RESULT_GALE_LOSS: result_icon = "🔴"; break;
        default: result_icon = "❓"; break;
    }
    
    // Substitui placeholders
    StringReplace(text, "{RESULT_ICON}", result_icon);
    StringReplace(text, "{SYMBOL}", _Symbol);
    StringReplace(text, "{DIRECTION}", operation_info.is_call ? "🟢 CALL" : "🔴 PUT");
    StringReplace(text, "{PATTERN}", PatternTypeToString(operation_info.pattern_used));
    StringReplace(text, "{ENTRY_VALUE}", FormatCurrency(operation_info.entry_value));
    StringReplace(text, "{PROFIT_LOSS}", FormatCurrency(operation_info.profit_loss));
    StringReplace(text, "{BALANCE}", FormatCurrency(g_current_balance));
    StringReplace(text, "{DAILY_WINRATE}", DoubleToString(g_daily_winrate, 1));
    StringReplace(text, "{DAILY_PROFIT}", FormatCurrency(g_daily_profit));
    StringReplace(text, "{OPERATIONS}", IntegerToString(g_total_operations_today));
    StringReplace(text, "{TITLE}", g_telegram_config.title);
    
    // Preenche estrutura da mensagem
    message.chat_id = g_telegram_config.chat_id;
    message.text = text;
    message.parse_mode = g_telegram_config.enable_markdown ? "Markdown" : "";
    message.disable_web_page_preview = true;
    message.disable_notification = false;
    
    return true;
}

/**
 * Cria mensagem de estatísticas
 * @param message Estrutura de mensagem a ser preenchida
 * @return true se criado com sucesso
 */
bool CreateStatisticsMessage(TelegramMessage &message)
{
    string text = g_message_templates.statistics_template;
    
    // Calcula ROI
    double roi = 0.0;
    if(g_starting_balance > 0)
    {
        roi = (g_current_balance - g_starting_balance) / g_starting_balance * 100.0;
    }
    
    // Substitui placeholders
    StringReplace(text, "{TOTAL_SIGNALS}", IntegerToString(g_total_signals_today));
    StringReplace(text, "{TOTAL_OPERATIONS}", IntegerToString(g_total_operations_today));
    StringReplace(text, "{TOTAL_WINS}", IntegerToString(g_total_wins_today));
    StringReplace(text, "{TOTAL_LOSSES}", IntegerToString(g_total_losses_today));
    StringReplace(text, "{WINRATE}", DoubleToString(g_daily_winrate, 1));
    StringReplace(text, "{TOTAL_PROFIT}", FormatCurrency(g_daily_profit));
    StringReplace(text, "{CURRENT_BALANCE}", FormatCurrency(g_current_balance));
    StringReplace(text, "{ROI}", DoubleToString(roi, 2));
    StringReplace(text, "{ACTIVE_PATTERN}", PatternTypeToString(g_active_pattern));
    StringReplace(text, "{STATUS}", SystemStateToString(g_system_status.current_state));
    StringReplace(text, "{TITLE}", g_telegram_config.title);
    
    // Preenche estrutura da mensagem
    message.chat_id = g_telegram_config.chat_id;
    message.text = text;
    message.parse_mode = g_telegram_config.enable_markdown ? "Markdown" : "";
    message.disable_web_page_preview = true;
    message.disable_notification = false;
    
    return true;
}

/**
 * Cria mensagem de SuperVarredura
 * @param superscan_result Resultado da SuperVarredura
 * @param message Estrutura de mensagem a ser preenchida
 * @return true se criado com sucesso
 */
bool CreateSuperScanMessage(const SuperScanResult &superscan_result, TelegramMessage &message)
{
    string text = g_message_templates.superscan_template;
    
    // Substitui placeholders
    StringReplace(text, "{BEST_PATTERN}", PatternTypeToString(superscan_result.best_pattern));
    StringReplace(text, "{BEST_WINRATE}", DoubleToString(superscan_result.best_winrate, 1));
    StringReplace(text, "{BEST_PROFIT}", FormatCurrency(superscan_result.best_profit));
    StringReplace(text, "{BEST_OPERATIONS}", IntegerToString(superscan_result.best_operations));
    StringReplace(text, "{CONFIDENCE_SCORE}", DoubleToString(superscan_result.confidence_score, 1));
    StringReplace(text, "{INVERTED}", superscan_result.best_inverted ? "Sim" : "Não");
    StringReplace(text, "{SCAN_DURATION}", DoubleToString(superscan_result.scan_duration_ms / 1000.0, 1));
    StringReplace(text, "{PATTERNS_TESTED}", IntegerToString(ArraySize(superscan_result.pattern_stats)));
    StringReplace(text, "{TITLE}", g_telegram_config.title);
    
    // Preenche estrutura da mensagem
    message.chat_id = g_telegram_config.chat_id;
    message.text = text;
    message.parse_mode = g_telegram_config.enable_markdown ? "Markdown" : "";
    message.disable_web_page_preview = true;
    message.disable_notification = false;
    
    return true;
}

/**
 * Cria mensagem de erro
 * @param error_message Mensagem de erro
 * @param function_name Nome da função
 * @param message Estrutura de mensagem a ser preenchida
 * @return true se criado com sucesso
 */
bool CreateErrorMessage(const string error_message, const string function_name, TelegramMessage &message)
{
    string text = g_message_templates.error_template;
    
    // Substitui placeholders
    StringReplace(text, "{ERROR_TYPE}", "Sistema");
    StringReplace(text, "{ERROR_MESSAGE}", error_message);
    StringReplace(text, "{TIME}", TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS));
    StringReplace(text, "{FUNCTION}", function_name);
    StringReplace(text, "{TITLE}", g_telegram_config.title);
    
    // Preenche estrutura da mensagem
    message.chat_id = g_telegram_config.chat_id;
    message.text = text;
    message.parse_mode = g_telegram_config.enable_markdown ? "Markdown" : "";
    message.disable_web_page_preview = true;
    message.disable_notification = false;
    
    return true;
}

/**
 * Envia mensagem para o Telegram
 * @param message Mensagem a ser enviada
 * @return true se enviado com sucesso
 */
bool SendTelegramMessage(const TelegramMessage &message)
{
    uint start_time = GetTickCount();
    
    // Constrói URL
    string url = g_telegram_base_url + "/sendMessage";
    
    // Constrói JSON
    string json_data = MessageToJSON(message);
    
    // Prepara dados
    char data[];
    StringToCharArray(json_data, data, 0, StringLen(json_data));
    
    // Prepara headers
    string headers = "Content-Type: application/json\r\n";
    
    // Envia requisição
    char result[];
    string response_headers;
    int timeout = g_telegram_config.message_timeout * 1000;
    
    int status_code = WebRequest("POST", url, headers, timeout, data, result, response_headers);
    
    // Processa resposta
    TelegramResponse response;
    response.status_code = status_code;
    response.timestamp = TimeCurrent();
    response.processing_time_ms = GetTickCount() - start_time;
    response.response_body = CharArrayToString(result);
    
    if(status_code == 200)
    {
        response.success = true;
        response.error_message = "";
        
        // Extrai message_id da resposta se possível
        int pos = StringFind(response.response_body, "\"message_id\":");
        if(pos >= 0)
        {
            string temp = StringSubstr(response.response_body, pos + 13);
            int end_pos = StringFind(temp, ",");
            if(end_pos > 0)
            {
                response.message_id = (int)StringToInteger(StringSubstr(temp, 0, end_pos));
            }
        }
    }
    else
    {
        response.success = false;
        response.error_message = "HTTP Error " + IntegerToString(status_code);
    }
    
    g_last_telegram_response = response;
    
    // Atualiza contadores
    g_telegram_messages_sent++;
    if(response.success)
    {
        g_telegram_messages_success++;
        g_last_telegram_message_time = TimeCurrent();
    }
    else
    {
        g_telegram_messages_failed++;
    }
    
    // Log da operação
    if(g_telegram_config.enable_logging)
    {
        LogTelegramOperation(message, response);
    }
    
    return response.success;
}

/**
 * Converte mensagem para JSON
 * @param message Mensagem
 * @return String JSON
 */
string MessageToJSON(const TelegramMessage &message)
{
    string json = "{";
    
    json += "\"chat_id\":\"" + message.chat_id + "\",";
    json += "\"text\":\"" + EscapeJSONString(message.text) + "\"";
    
    if(StringLen(message.parse_mode) > 0)
    {
        json += ",\"parse_mode\":\"" + message.parse_mode + "\"";
    }
    
    if(message.disable_web_page_preview)
    {
        json += ",\"disable_web_page_preview\":true";
    }
    
    if(message.disable_notification)
    {
        json += ",\"disable_notification\":true";
    }
    
    json += "}";
    
    return json;
}

/**
 * Escapa string para JSON
 * @param str String a ser escapada
 * @return String escapada
 */
string EscapeJSONString(const string str)
{
    string result = str;
    StringReplace(result, "\\", "\\\\");
    StringReplace(result, "\"", "\\\"");
    StringReplace(result, "\n", "\\n");
    StringReplace(result, "\r", "\\r");
    StringReplace(result, "\t", "\\t");
    return result;
}

/**
 * Registra operação Telegram no log
 * @param message Mensagem enviada
 * @param response Resposta recebida
 */
void LogTelegramOperation(const TelegramMessage &message, const TelegramResponse &response)
{
    string log_message = StringFormat("Telegram: %s | Status: %s | Tempo: %dms | ID: %d",
                                     StringSubstr(message.text, 0, 50) + "...",
                                     response.success ? "SUCESSO" : "FALHA",
                                     response.processing_time_ms,
                                     response.message_id);
    
    Print(log_message);
}

//+------------------------------------------------------------------+
//| Funções Auxiliares                                              |
//+------------------------------------------------------------------+

/**
 * Verifica se string é numérica
 * @param str String a ser verificada
 * @return true se é numérica
 */
bool IsNumericString(const string str)
{
    for(int i = 0; i < StringLen(str); i++)
    {
        ushort char_code = StringGetCharacter(str, i);
        if(char_code < '0' || char_code > '9')
        {
            if(i == 0 && char_code == '-') continue; // Permite números negativos
            return false;
        }
    }
    return true;
}

/**
 * Obtém estatísticas do Telegram
 * @return String com estatísticas formatadas
 */
string GetTelegramStatistics()
{
    if(!g_telegram_initialized)
        return "Telegram: Não inicializado";
    
    if(!g_telegram_config.enabled)
        return "Telegram: Desabilitado";
    
    double success_rate = 0.0;
    if(g_telegram_messages_sent > 0)
    {
        success_rate = (double)g_telegram_messages_success / g_telegram_messages_sent * 100.0;
    }
    
    return StringFormat("Telegram: %d enviadas | %d sucesso | %.1f%% taxa",
                       g_telegram_messages_sent,
                       g_telegram_messages_success,
                       success_rate);
}

/**
 * Verifica se Telegram está operacional
 * @return true se operacional
 */
bool IsTelegramOperational()
{
    return g_telegram_initialized && g_telegram_config.enabled;
}

/**
 * Reset estatísticas do Telegram
 */
void ResetTelegramStatistics()
{
    g_telegram_messages_sent = 0;
    g_telegram_messages_success = 0;
    g_telegram_messages_failed = 0;
    g_last_telegram_message_time = 0;
}

#endif // NOTIFICATIONS_TELEGRAM_CORE_MQH

