//+------------------------------------------------------------------+
//|                                    Notifications/Telegram/TelegramCore.mqh |
//|                                    Indicador de Probabilidades V3 |
//|                                Sistema de Notificações Telegram |
//+------------------------------------------------------------------+

#ifndef NOTIFICATIONS_TELEGRAM_CORE_MQH
#define NOTIFICATIONS_TELEGRAM_CORE_MQH

#include "../../Core/Types.mqh"
#include "../../Core/Globals.mqh"

//+------------------------------------------------------------------+
//| Funções de Inicialização do Telegram                            |
//+------------------------------------------------------------------+

/**
 * Inicializa o sistema Telegram
 * @return true se inicializado com sucesso
 */
bool InitializeTelegram()
{
    if(!g_config.notifications.enable_telegram)
    {
        return true; // Não habilitado, mas não é erro
    }
    
    // Configurar dados do Telegram
    g_telegram_config.bot_token = g_config.notifications.telegram_token;
    g_telegram_config.chat_id = g_config.notifications.telegram_chat_id;
    g_telegram_config.enabled = true;
    
    // Validar configuração
    if(StringLen(g_telegram_config.bot_token) == 0 || StringLen(g_telegram_config.chat_id) == 0)
    {
        Print("ERRO: Token ou Chat ID do Telegram não configurados");
        return false;
    }
    
    // Construir URL base
    g_telegram_base_url = "https://api.telegram.org/bot" + g_telegram_config.bot_token + "/";
    
    // Testar conexão
    if(TestTelegramConnection())
    {
        g_telegram_initialized = true;
        Print("Telegram inicializado com sucesso");
        return true;
    }
    else
    {
        Print("ERRO: Falha ao conectar com Telegram");
        return false;
    }
}

/**
 * Testa conexão com Telegram
 */
bool TestTelegramConnection()
{
    string url = g_telegram_base_url + "getMe";
    string response = "";
    
    // Fazer requisição HTTP
    if(SendHTTPRequest(url, "", response))
    {
        // Verificar se resposta contém "ok":true
        if(StringFind(response, "\"ok\":true") >= 0)
        {
            return true;
        }
    }
    
    return false;
}

/**
 * Envia requisição HTTP
 */
bool SendHTTPRequest(string url, string data, string &response)
{
    // Implementação simplificada usando WebRequest
    char post_data[];
    char result[];
    string headers = "Content-Type: application/json\r\n";
    
    if(StringLen(data) > 0)
    {
        StringToCharArray(data, post_data, 0, StringLen(data));
    }
    
    int timeout = 5000; // 5 segundos
    int res = WebRequest("POST", url, headers, timeout, post_data, result, headers);
    
    if(res == 200)
    {
        response = CharArrayToString(result);
        return true;
    }
    
    Print("Erro HTTP: ", res);
    return false;
}

/**
 * Envia mensagem para Telegram
 */
bool SendTelegramMessage(string message)
{
    if(!g_telegram_initialized || !g_telegram_config.enabled)
    {
        return false;
    }
    
    // Verificar rate limiting
    datetime current_time = TimeCurrent();
    if(current_time - g_last_telegram_message_time < 1) // Mínimo 1 segundo entre mensagens
    {
        return false;
    }
    
    // Preparar dados da mensagem
    string json_data = "{";
    json_data += "\"chat_id\":\"" + g_telegram_config.chat_id + "\",";
    json_data += "\"text\":\"" + EscapeJsonString(message) + "\",";
    json_data += "\"parse_mode\":\"HTML\"";
    json_data += "}";
    
    string url = g_telegram_base_url + "sendMessage";
    string response = "";
    
    // Tentar enviar com retry
    bool success = false;
    for(int attempt = 0; attempt < g_telegram_config.retry_attempts; attempt++)
    {
        if(SendHTTPRequest(url, json_data, response))
        {
            if(StringFind(response, "\"ok\":true") >= 0)
            {
                success = true;
                break;
            }
        }
        
        if(attempt < g_telegram_config.retry_attempts - 1)
        {
            Sleep(g_telegram_config.retry_delay_ms);
        }
    }
    
    // Atualizar estatísticas
    g_telegram_messages_sent++;
    if(success)
    {
        g_telegram_messages_success++;
        g_last_telegram_message_time = current_time;
    }
    else
    {
        g_telegram_messages_failed++;
        Print("Falha ao enviar mensagem Telegram: ", response);
    }
    
    g_last_telegram_response = response;
    return success;
}

/**
 * Escapa string para JSON
 */
string EscapeJsonString(string input)
{
    string output = input;
    StringReplace(output, "\\", "\\\\");
    StringReplace(output, "\"", "\\\"");
    StringReplace(output, "\n", "\\n");
    StringReplace(output, "\r", "\\r");
    StringReplace(output, "\t", "\\t");
    return output;
}

/**
 * Envia notificação de sinal
 */
bool SendSignalNotification(SignalInfo &signal)
{
    if(!g_telegram_config.send_signals)
        return true;
    
    string message = g_message_templates.signal_template;
    
    // Substituir placeholders
    StringReplace(message, "{PATTERN}", PatternTypeToString(signal.pattern_type));
    StringReplace(message, "{DIRECTION}", signal.is_call ? "CALL ⬆️" : "PUT ⬇️");
    StringReplace(message, "{VALUE}", FormatCurrency(signal.entry_value));
    StringReplace(message, "{CONFIDENCE}", DoubleToString(signal.confidence, 1));
    
    // Adicionar informações extras
    message += "\n⏰ " + TimeToString(signal.signal_time, TIME_DATE|TIME_MINUTES);
    message += "\n💰 Preço: " + DoubleToString(signal.signal_price, 5);
    message += "\n🎯 Martingale: Nível " + IntegerToString(signal.martingale_level);
    
    return SendTelegramMessage(message);
}

/**
 * Envia notificação de resultado
 */
bool SendResultNotification(OperationInfo &operation)
{
    if(!g_telegram_config.send_results)
        return true;
    
    string message = g_message_templates.result_template;
    
    // Determinar ícone e texto do resultado
    string result_icon = operation.result_win ? "✅" : "❌";
    string result_text = operation.result_win ? "VITÓRIA" : "DERROTA";
    
    // Substituir placeholders
    StringReplace(message, "{RESULT_ICON}", result_icon);
    StringReplace(message, "{RESULT}", result_text);
    StringReplace(message, "{PROFIT}", FormatCurrency(operation.profit_loss));
    StringReplace(message, "{BALANCE}", FormatCurrency(operation.balance_after));
    
    // Adicionar informações extras
    message += "\n📊 Padrão: " + PatternTypeToString(operation.pattern_used);
    message += "\n🎲 Direção: " + (operation.is_call ? "CALL" : "PUT");
    message += "\n🎯 Martingale: Nível " + IntegerToString(operation.martingale_level);
    
    return SendTelegramMessage(message);
}

/**
 * Envia notificação de estatísticas
 */
bool SendStatisticsNotification()
{
    if(!g_telegram_config.send_statistics)
        return true;
    
    string message = g_message_templates.statistics_template;
    
    // Calcular winrate
    double winrate = 0.0;
    if(g_total_operations > 0)
    {
        winrate = ((double)g_total_wins / g_total_operations) * 100.0;
    }
    
    // Substituir placeholders
    StringReplace(message, "{OPERATIONS}", IntegerToString(g_total_operations));
    StringReplace(message, "{WINS}", IntegerToString(g_total_wins));
    StringReplace(message, "{LOSSES}", IntegerToString(g_total_losses));
    StringReplace(message, "{WINRATE}", DoubleToString(winrate, 1));
    
    // Adicionar informações extras
    message += "\n💰 Lucro Total: " + FormatCurrency(g_total_profit);
    message += "\n💳 Saldo Atual: " + FormatCurrency(g_current_balance);
    message += "\n📉 Max Drawdown: " + FormatCurrency(g_max_drawdown_value);
    message += "\n📊 Sharpe Ratio: " + DoubleToString(g_daily_stats.sharpe_ratio, 2);
    
    return SendTelegramMessage(message);
}

/**
 * Envia notificação de erro
 */
bool SendErrorNotification(string error_message)
{
    string message = g_message_templates.error_template;
    StringReplace(message, "{ERROR_MESSAGE}", error_message);
    
    return SendTelegramMessage(message);
}

/**
 * Obtém estatísticas do Telegram
 */
string GetTelegramStatistics()
{
    string stats = "";
    stats += "Mensagens Enviadas: " + IntegerToString(g_telegram_messages_sent);
    stats += " | Sucessos: " + IntegerToString(g_telegram_messages_success);
    stats += " | Falhas: " + IntegerToString(g_telegram_messages_failed);
    
    if(g_telegram_messages_sent > 0)
    {
        double success_rate = ((double)g_telegram_messages_success / g_telegram_messages_sent) * 100.0;
        stats += " | Taxa Sucesso: " + FormatPercentage(success_rate);
    }
    
    return stats;
}

#endif // NOTIFICATIONS_TELEGRAM_CORE_MQH

