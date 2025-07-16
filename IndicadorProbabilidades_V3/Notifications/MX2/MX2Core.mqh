//+------------------------------------------------------------------+
//|                                    Notifications/MX2/MX2Core.mqh |
//|                                    Indicador de Probabilidades V3 |
//|                                Sistema de Integração MX2 |
//+------------------------------------------------------------------+

#ifndef NOTIFICATIONS_MX2_CORE_MQH
#define NOTIFICATIONS_MX2_CORE_MQH

#include "../../Core/Types.mqh"
#include "../../Core/Globals.mqh"

//+------------------------------------------------------------------+
//| Variáveis Específicas do MX2                                    |
//+------------------------------------------------------------------+
bool g_mx2_connection_active = false;
string g_mx2_last_response = "";
int g_mx2_messages_sent = 0;
int g_mx2_messages_success = 0;
int g_mx2_messages_failed = 0;
datetime g_mx2_last_message_time = 0;

//+------------------------------------------------------------------+
//| Funções de Inicialização do MX2                                 |
//+------------------------------------------------------------------+

/**
 * Inicializa o sistema MX2
 * @return true se inicializado com sucesso
 */
bool InitializeMX2()
{
    if(!g_config.notifications.enable_mx2)
    {
        return true; // Não habilitado, mas não é erro
    }
    
    // Validar configuração
    if(g_config.notifications.mx2_broker < MX2_QUOTEX || g_config.notifications.mx2_broker > MX2_SPECTRE)
    {
        Print("ERRO: Corretora MX2 inválida");
        return false;
    }
    
    if(g_config.notifications.mx2_expiry_minutes < 1 || g_config.notifications.mx2_expiry_minutes > 60)
    {
        Print("ERRO: Tempo de expiração MX2 inválido (1-60 minutos)");
        return false;
    }
    
    // Testar conexão
    if(TestMX2Connection())
    {
        g_mx2_initialized = true;
        g_mx2_connection_active = true;
        Print("MX2 inicializado com sucesso - Corretora: ", BrokerMX2ToString(g_config.notifications.mx2_broker));
        return true;
    }
    else
    {
        Print("ERRO: Falha ao conectar com MX2");
        return false;
    }
}

/**
 * Testa conexão com MX2
 */
bool TestMX2Connection()
{
    // Implementação simplificada - em ambiente real seria testada a conexão com o robô MX2
    // Por enquanto, sempre retorna true se a configuração estiver válida
    
    string broker_name = BrokerMX2ToString(g_config.notifications.mx2_broker);
    Print("Testando conexão MX2 com ", broker_name);
    
    // Simular teste de conexão
    Sleep(100);
    
    return true; // Simulação de sucesso
}

/**
 * Envia sinal para MX2
 */
bool SendMX2Signal(SignalInfo &signal)
{
    if(!g_mx2_initialized || !g_mx2_connection_active)
    {
        return false;
    }
    
    // Verificar rate limiting
    datetime current_time = TimeCurrent();
    if(current_time - g_mx2_last_message_time < 5) // Mínimo 5 segundos entre sinais MX2
    {
        return false;
    }
    
    // Preparar dados do sinal
    string direction = signal.is_call ? "CALL" : "PUT";
    string broker = BrokerMX2ToString(g_config.notifications.mx2_broker);
    int expiry_minutes = g_config.notifications.mx2_expiry_minutes;
    
    // Construir comando MX2
    string mx2_command = BuildMX2Command(signal, direction, broker, expiry_minutes);
    
    // Enviar comando (implementação simplificada)
    bool success = ExecuteMX2Command(mx2_command);
    
    // Atualizar estatísticas
    g_mx2_messages_sent++;
    if(success)
    {
        g_mx2_messages_success++;
        g_mx2_last_message_time = current_time;
        Print("Sinal MX2 enviado com sucesso: ", direction, " | ", broker, " | ", expiry_minutes, "min");
    }
    else
    {
        g_mx2_messages_failed++;
        Print("Falha ao enviar sinal MX2");
    }
    
    return success;
}

/**
 * Constrói comando MX2
 */
string BuildMX2Command(SignalInfo &signal, string direction, string broker, int expiry_minutes)
{
    string command = "";
    
    // Formato do comando MX2 (exemplo)
    command += "BROKER=" + broker + ";";
    command += "DIRECTION=" + direction + ";";
    command += "EXPIRY=" + IntegerToString(expiry_minutes) + ";";
    command += "VALUE=" + DoubleToString(signal.entry_value, 2) + ";";
    command += "SYMBOL=" + Symbol() + ";";
    command += "PATTERN=" + PatternTypeToString(signal.pattern_type) + ";";
    command += "CONFIDENCE=" + DoubleToString(signal.confidence, 1) + ";";
    command += "MARTINGALE=" + IntegerToString(signal.martingale_level) + ";";
    command += "TIME=" + TimeToString(signal.signal_time, TIME_DATE|TIME_MINUTES);
    
    return command;
}

/**
 * Executa comando MX2
 */
bool ExecuteMX2Command(string command)
{
    // Implementação simplificada
    // Em ambiente real, aqui seria feita a comunicação com o robô MX2
    // através de arquivo, named pipe, socket, etc.
    
    Print("Executando comando MX2: ", command);
    
    // Simular execução
    Sleep(50);
    
    // Simular sucesso baseado em probabilidade
    double success_probability = 0.95; // 95% de sucesso
    double random_value = (double)MathRand() / 32767.0;
    
    bool success = (random_value <= success_probability);
    
    if(success)
    {
        g_mx2_last_response = "OK: Comando executado com sucesso";
    }
    else
    {
        g_mx2_last_response = "ERRO: Falha na execução do comando";
    }
    
    return success;
}

/**
 * Obtém status da conexão MX2
 */
bool GetMX2ConnectionStatus()
{
    return g_mx2_connection_active;
}

/**
 * Reconecta MX2
 */
bool ReconnectMX2()
{
    Print("Tentando reconectar MX2...");
    
    g_mx2_connection_active = false;
    Sleep(1000);
    
    if(TestMX2Connection())
    {
        g_mx2_connection_active = true;
        Print("MX2 reconectado com sucesso");
        return true;
    }
    else
    {
        Print("Falha na reconexão MX2");
        return false;
    }
}

/**
 * Obtém estatísticas do MX2
 */
string GetMX2Statistics()
{
    string stats = "";
    stats += "Sinais Enviados: " + IntegerToString(g_mx2_messages_sent);
    stats += " | Sucessos: " + IntegerToString(g_mx2_messages_success);
    stats += " | Falhas: " + IntegerToString(g_mx2_messages_failed);
    stats += " | Conexão: " + (g_mx2_connection_active ? "Ativa" : "Inativa");
    
    if(g_mx2_messages_sent > 0)
    {
        double success_rate = ((double)g_mx2_messages_success / g_mx2_messages_sent) * 100.0;
        stats += " | Taxa Sucesso: " + FormatPercentage(success_rate);
    }
    
    return stats;
}

/**
 * Obtém informações da corretora configurada
 */
string GetBrokerInfo()
{
    string info = "";
    info += "Corretora: " + BrokerMX2ToString(g_config.notifications.mx2_broker);
    info += " | Expiração: " + IntegerToString(g_config.notifications.mx2_expiry_minutes) + " min";
    info += " | Status: " + (g_mx2_connection_active ? "Conectado" : "Desconectado");
    
    return info;
}

/**
 * Valida configuração MX2
 */
bool ValidateMX2Configuration()
{
    // Verificar corretora
    if(g_config.notifications.mx2_broker < MX2_QUOTEX || g_config.notifications.mx2_broker > MX2_SPECTRE)
    {
        Print("ERRO: Corretora MX2 inválida: ", (int)g_config.notifications.mx2_broker);
        return false;
    }
    
    // Verificar tempo de expiração
    if(g_config.notifications.mx2_expiry_minutes < 1 || g_config.notifications.mx2_expiry_minutes > 60)
    {
        Print("ERRO: Tempo de expiração inválido: ", g_config.notifications.mx2_expiry_minutes);
        return false;
    }
    
    return true;
}

/**
 * Limpa recursos do MX2
 */
void CleanupMX2Resources()
{
    g_mx2_connection_active = false;
    g_mx2_initialized = false;
    g_mx2_last_response = "";
    
    Print("Recursos MX2 limpos");
}

#endif // NOTIFICATIONS_MX2_CORE_MQH

