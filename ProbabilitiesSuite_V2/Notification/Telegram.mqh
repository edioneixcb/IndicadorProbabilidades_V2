//+------------------------------------------------------------------+
//|                                    Notification/Telegram.mqh |
//|                        Copyright 2024, Quant Genius (Refactoring) |
//|                                      https://www.google.com |
//|                                    VERSÃO CORRIGIDA v2.0        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quant Genius (Refactoring)"
#property link      "https://www.google.com"

#ifndef NOTIFICATION_TELEGRAM_MQH
#define NOTIFICATION_TELEGRAM_MQH

#include "../Core/Defines.mqh"
#include "../Core/Globals.mqh"
#include "../Core/Utilities.mqh"
#include "../Core/Logger.mqh"

// ==================================================================
// NOTIFICAÇÕES TELEGRAM CORRIGIDAS - VERSÃO 2.0
// ==================================================================

//+------------------------------------------------------------------+
//| CORREÇÃO: Envio de notificação Telegram robusta                 |
//+------------------------------------------------------------------+
bool EnviarNotificacaoTelegramRobusta(
    string bot_token,
    string chat_id,
    string mensagem,
    bool usar_markdown = false,
    int timeout_seconds = 10
)
{
    // Validação de entrada
    if(bot_token == "" || chat_id == "" || mensagem == "")
    {
        Logger::Error("Telegram", "Parâmetros obrigatórios não fornecidos");
        return false;
    }
    
    if(!ValidateInputParameter(timeout_seconds, 5, 60, "timeout_seconds"))
        return false;
    
    Logger::Debug("Telegram", "Enviando notificação", 
                 "Chat: " + chat_id + ", Tamanho: " + IntegerToString(StringLen(mensagem)));
    
    // Escapa caracteres especiais se necessário
    string mensagem_escapada = usar_markdown ? EscaparMarkdown(mensagem) : mensagem;
    
    // Constrói URL da API
    string api_url = "https://api.telegram.org/bot" + bot_token + "/sendMessage";
    
    // Prepara dados POST
    string post_data = "chat_id=" + chat_id + 
                      "&text=" + UrlEncode(mensagem_escapada);
    
    if(usar_markdown)
        post_data += "&parse_mode=Markdown";
    
    // Headers HTTP
    string headers = "Content-Type: application/x-www-form-urlencoded\r\n";
    
    // Envia requisição
    char post_array[];
    char result_array[];
    string result_headers;
    
    StringToCharArray(post_data, post_array, 0, StringLen(post_data));
    
    int response_code = WebRequest(
        "POST",
        api_url,
        headers,
        timeout_seconds * 1000, // Converte para millisegundos
        post_array,
        result_array,
        result_headers
    );
    
    // Verifica resultado
    if(response_code == -1)
    {
        int error = GetLastError();
        Logger::Error("Telegram", "Falha na requisição HTTP", 
                     "Erro: " + IntegerToString(error));
        return false;
    }
    
    if(response_code != 200)
    {
        string response_text = CharArrayToString(result_array);
        Logger::Error("Telegram", "Resposta HTTP inválida", 
                     "Código: " + IntegerToString(response_code) + 
                     ", Resposta: " + StringSubstr(response_text, 0, 200));
        return false;
    }
    
    // Verifica resposta da API Telegram
    string response_json = CharArrayToString(result_array);
    
    if(StringFind(response_json, "\"ok\":true") == -1)
    {
        Logger::Error("Telegram", "API Telegram retornou erro", 
                     "Resposta: " + StringSubstr(response_json, 0, 200));
        return false;
    }
    
    Logger::Info("Telegram", "Notificação enviada com sucesso", 
                "Chat: " + chat_id);
    
    return true;
}

//+------------------------------------------------------------------+
//| Escapa caracteres especiais para Markdown                       |
//+------------------------------------------------------------------+
string EscaparMarkdown(string texto)
{
    // Caracteres que precisam ser escapados no Markdown do Telegram
    string caracteres_especiais[] = {"_", "*", "[", "]", "(", ")", "~", "`", ">", "#", "+", "-", "=", "|", "{", "}", ".", "!"};
    
    string resultado = texto;
    
    for(int i = 0; i < ArraySize(caracteres_especiais); i++)
    {
        StringReplace(resultado, caracteres_especiais[i], "\\" + caracteres_especiais[i]);
    }
    
    return resultado;
}

//+------------------------------------------------------------------+
//| Codifica URL para envio HTTP                                    |
//+------------------------------------------------------------------+
string UrlEncode(string texto)
{
    string resultado = texto;
    
    // Substitui caracteres especiais
    StringReplace(resultado, " ", "%20");
    StringReplace(resultado, "!", "%21");
    StringReplace(resultado, "\"", "%22");
    StringReplace(resultado, "#", "%23");
    StringReplace(resultado, "$", "%24");
    StringReplace(resultado, "%", "%25");
    StringReplace(resultado, "&", "%26");
    StringReplace(resultado, "'", "%27");
    StringReplace(resultado, "(", "%28");
    StringReplace(resultado, ")", "%29");
    StringReplace(resultado, "*", "%2A");
    StringReplace(resultado, "+", "%2B");
    StringReplace(resultado, ",", "%2C");
    StringReplace(resultado, "/", "%2F");
    StringReplace(resultado, ":", "%3A");
    StringReplace(resultado, ";", "%3B");
    StringReplace(resultado, "<", "%3C");
    StringReplace(resultado, "=", "%3D");
    StringReplace(resultado, ">", "%3E");
    StringReplace(resultado, "?", "%3F");
    StringReplace(resultado, "@", "%40");
    StringReplace(resultado, "[", "%5B");
    StringReplace(resultado, "\\", "%5C");
    StringReplace(resultado, "]", "%5D");
    StringReplace(resultado, "^", "%5E");
    StringReplace(resultado, "`", "%60");
    StringReplace(resultado, "{", "%7B");
    StringReplace(resultado, "|", "%7C");
    StringReplace(resultado, "}", "%7D");
    StringReplace(resultado, "~", "%7E");
    
    return resultado;
}

//+------------------------------------------------------------------+
//| Envia notificação de sinal formatada                            |
//+------------------------------------------------------------------+
bool EnviarSinalTelegram(
    string bot_token,
    string chat_id,
    string tipo_sinal,
    string simbolo,
    double preco_entrada,
    datetime tempo_sinal,
    string padrao_detectado,
    double confianca = 0.0
)
{
    if(bot_token == "" || chat_id == "")
    {
        Logger::Debug("Telegram", "Configuração Telegram não disponível");
        return false;
    }
    
    // Formata mensagem do sinal
    string mensagem = "🎯 *SINAL DETECTADO*\n\n";
    mensagem += "📊 *Símbolo:* " + simbolo + "\n";
    mensagem += "🔄 *Tipo:* " + tipo_sinal + "\n";
    mensagem += "💰 *Preço:* " + DoubleToString(preco_entrada, _Digits) + "\n";
    mensagem += "⏰ *Tempo:* " + TimeToString(tempo_sinal, TIME_DATE|TIME_MINUTES) + "\n";
    mensagem += "🎨 *Padrão:* " + padrao_detectado + "\n";
    
    if(confianca > 0)
    {
        mensagem += "📈 *Confiança:* " + DoubleToString(confianca, 1) + "%\n";
    }
    
    mensagem += "\n_Gerado por Indicador de Probabilidades V2.0_";
    
    return EnviarNotificacaoTelegramRobusta(bot_token, chat_id, mensagem, true);
}

//+------------------------------------------------------------------+
//| Envia relatório de performance                                  |
//+------------------------------------------------------------------+
bool EnviarRelatorioPerformance(
    string bot_token,
    string chat_id,
    int total_sinais,
    int sinais_corretos,
    double taxa_acerto,
    string periodo
)
{
    if(bot_token == "" || chat_id == "")
        return false;
    
    string mensagem = "📊 *RELATÓRIO DE PERFORMANCE*\n\n";
    mensagem += "📅 *Período:* " + periodo + "\n";
    mensagem += "🎯 *Total de Sinais:* " + IntegerToString(total_sinais) + "\n";
    mensagem += "✅ *Sinais Corretos:* " + IntegerToString(sinais_corretos) + "\n";
    mensagem += "📈 *Taxa de Acerto:* " + DoubleToString(taxa_acerto, 1) + "%\n";
    
    // Adiciona emoji baseado na performance
    if(taxa_acerto >= 70)
        mensagem += "🟢 *Status:* Excelente\n";
    else if(taxa_acerto >= 60)
        mensagem += "🟡 *Status:* Bom\n";
    else
        mensagem += "🔴 *Status:* Precisa Melhorar\n";
    
    mensagem += "\n_Relatório automático do Indicador V2.0_";
    
    return EnviarNotificacaoTelegramRobusta(bot_token, chat_id, mensagem, true);
}

//+------------------------------------------------------------------+
//| Testa configuração do Telegram                                  |
//+------------------------------------------------------------------+
bool TestarConfiguracaoTelegram(string bot_token, string chat_id)
{
    if(bot_token == "" || chat_id == "")
    {
        Logger::Warning("Telegram", "Configuração não fornecida para teste");
        return false;
    }
    
    string mensagem_teste = "🔧 *TESTE DE CONFIGURAÇÃO*\n\n";
    mensagem_teste += "✅ Bot Token configurado\n";
    mensagem_teste += "✅ Chat ID configurado\n";
    mensagem_teste += "✅ Conexão estabelecida\n\n";
    mensagem_teste += "_Teste realizado em " + TimeToString(TimeCurrent()) + "_";
    
    bool sucesso = EnviarNotificacaoTelegramRobusta(bot_token, chat_id, mensagem_teste, true, 15);
    
    if(sucesso)
    {
        Logger::Info("Telegram", "Teste de configuração bem-sucedido");
    }
    else
    {
        Logger::Error("Telegram", "Teste de configuração falhou");
    }
    
    return sucesso;
}

//+------------------------------------------------------------------+
//| Envia alerta de erro crítico                                    |
//+------------------------------------------------------------------+
bool EnviarAlertaErroCritico(
    string bot_token,
    string chat_id,
    string descricao_erro,
    string contexto = ""
)
{
    if(bot_token == "" || chat_id == "")
        return false;
    
    string mensagem = "🚨 *ERRO CRÍTICO DETECTADO*\n\n";
    mensagem += "❌ *Erro:* " + descricao_erro + "\n";
    
    if(contexto != "")
        mensagem += "📍 *Contexto:* " + contexto + "\n";
    
    mensagem += "⏰ *Tempo:* " + TimeToString(TimeCurrent()) + "\n";
    mensagem += "💻 *Símbolo:* " + _Symbol + "\n";
    mensagem += "📊 *Timeframe:* " + EnumToString(_Period) + "\n\n";
    mensagem += "🔧 _Verifique o indicador imediatamente_";
    
    return EnviarNotificacaoTelegramRobusta(bot_token, chat_id, mensagem, true);
}

//+------------------------------------------------------------------+
//| Gerenciador de notificações com rate limiting                   |
//+------------------------------------------------------------------+
class TelegramNotificationManager
{
private:
    string m_bot_token;
    string m_chat_id;
    datetime m_last_notification;
    int m_min_interval_seconds;
    int m_notifications_sent;
    
public:
    TelegramNotificationManager(string bot_token, string chat_id, int min_interval = 60)
    {
        m_bot_token = bot_token;
        m_chat_id = chat_id;
        m_min_interval_seconds = min_interval;
        m_last_notification = 0;
        m_notifications_sent = 0;
    }
    
    bool CanSendNotification()
    {
        datetime current_time = TimeCurrent();
        return (current_time - m_last_notification) >= m_min_interval_seconds;
    }
    
    bool SendSignalNotification(string tipo_sinal, double preco, string padrao)
    {
        if(!CanSendNotification())
        {
            Logger::Debug("Telegram", "Notificação bloqueada por rate limiting");
            return false;
        }
        
        bool success = EnviarSinalTelegram(
            m_bot_token, 
            m_chat_id, 
            tipo_sinal, 
            _Symbol, 
            preco, 
            TimeCurrent(), 
            padrao
        );
        
        if(success)
        {
            m_last_notification = TimeCurrent();
            m_notifications_sent++;
        }
        
        return success;
    }
    
    int GetNotificationsSent() { return m_notifications_sent; }
    datetime GetLastNotificationTime() { return m_last_notification; }
};

//+------------------------------------------------------------------+
//| Função de diagnóstico do sistema Telegram                       |
//+------------------------------------------------------------------+
void DiagnosticTelegram(string bot_token, string chat_id)
{
    Logger::Info("Telegram", "=== DIAGNÓSTICO TELEGRAM ===");
    
    if(bot_token == "")
    {
        Logger::Warning("Telegram", "Bot Token não configurado");
        return;
    }
    
    if(chat_id == "")
    {
        Logger::Warning("Telegram", "Chat ID não configurado");
        return;
    }
    
    Logger::Info("Telegram", "Bot Token: " + StringSubstr(bot_token, 0, 10) + "...");
    Logger::Info("Telegram", "Chat ID: " + chat_id);
    
    // Teste de conectividade
    bool teste_ok = TestarConfiguracaoTelegram(bot_token, chat_id);
    Logger::Info("Telegram", "Teste de conectividade: " + BoolToString(teste_ok));
    
    Logger::Info("Telegram", "=== FIM DO DIAGNÓSTICO ===");
}

#endif // NOTIFICATION_TELEGRAM_MQH

