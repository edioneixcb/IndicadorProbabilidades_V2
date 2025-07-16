//+------------------------------------------------------------------+
//|                                        Notifications/MX2/MX2Core.mqh |
//|                                    Indicador de Probabilidades V3 |
//|                                Sistema de Integração MX2 Core |
//+------------------------------------------------------------------+

#ifndef NOTIFICATIONS_MX2_CORE_MQH
#define NOTIFICATIONS_MX2_CORE_MQH

#include "../../Core/Types.mqh"
#include "../../Core/Defines.mqh"
#include "../../Core/Globals.mqh"

//+------------------------------------------------------------------+
//| Estruturas Específicas do MX2                                   |
//+------------------------------------------------------------------+

/**
 * Estrutura de configuração específica do MX2
 */
struct MX2Configuration
{
    bool enabled;                       // MX2 habilitado
    BrokerMX2 broker;                  // Corretora selecionada
    SignalTypeMX2 signal_type;         // Tipo de sinal
    ExpirationTypeMX2 expiry_type;     // Tipo de expiração
    int expiry_minutes;                // Minutos de expiração
    double entry_value;                // Valor de entrada
    bool enable_martingale;            // Habilitar martingale
    double martingale_factor;          // Fator do martingale
    int max_gale_levels;               // Máximo de gales
    string webhook_url;                // URL do webhook
    string api_key;                    // Chave da API
    int timeout_seconds;               // Timeout em segundos
    bool send_screenshots;             // Enviar screenshots
    bool enable_logging;               // Habilitar logging
};

/**
 * Estrutura de sinal para envio ao MX2
 */
struct MX2Signal
{
    string symbol;                     // Símbolo
    bool is_call;                      // CALL ou PUT
    datetime signal_time;              // Tempo do sinal
    datetime expiry_time;              // Tempo de expiração
    double entry_price;                // Preço de entrada
    double confidence;                 // Confiança do sinal
    PatternType pattern_type;          // Tipo de padrão
    string pattern_name;               // Nome do padrão
    BrokerMX2 target_broker;          // Corretora alvo
    SignalTypeMX2 signal_type;        // Tipo de sinal
    ExpirationTypeMX2 expiry_type;    // Tipo de expiração
    int expiry_minutes;               // Minutos de expiração
    double entry_value;               // Valor de entrada
    int gale_level;                   // Nível de gale
    string additional_info;           // Informações adicionais
};

/**
 * Estrutura de resposta do MX2
 */
struct MX2Response
{
    bool success;                      // Sucesso no envio
    int status_code;                   // Código de status HTTP
    string response_body;              // Corpo da resposta
    string error_message;              // Mensagem de erro
    datetime timestamp;                // Timestamp da resposta
    double processing_time_ms;         // Tempo de processamento
};

//+------------------------------------------------------------------+
//| Variáveis Globais do MX2                                        |
//+------------------------------------------------------------------+
MX2Configuration g_mx2_config;        // Configuração do MX2
MX2Response g_last_mx2_response;      // Última resposta do MX2
int g_mx2_signals_sent = 0;           // Sinais enviados
int g_mx2_signals_success = 0;        // Sinais enviados com sucesso
int g_mx2_signals_failed = 0;         // Sinais que falharam
datetime g_last_mx2_signal_time = 0;  // Último sinal enviado
string g_mx2_session_id = "";         // ID da sessão MX2

//+------------------------------------------------------------------+
//| Funções de Inicialização do MX2                                 |
//+------------------------------------------------------------------+

/**
 * Inicializa o sistema MX2
 * @return true se inicializado com sucesso
 */
bool InitializeMX2()
{
    // Carrega configuração do MX2
    LoadMX2Configuration();
    
    // Verifica se está habilitado
    if(!g_mx2_config.enabled)
    {
        Print("MX2: Sistema desabilitado");
        return true; // Não é erro, apenas desabilitado
    }
    
    // Valida configuração
    if(!ValidateMX2Configuration())
    {
        Print("MX2: Configuração inválida");
        return false;
    }
    
    // Testa conectividade
    if(!TestMX2Connectivity())
    {
        Print("MX2: Falha na conectividade");
        return false;
    }
    
    // Gera ID da sessão
    g_mx2_session_id = GenerateSessionId();
    
    // Reset contadores
    g_mx2_signals_sent = 0;
    g_mx2_signals_success = 0;
    g_mx2_signals_failed = 0;
    
    g_mx2_initialized = true;
    Print("MX2: Sistema inicializado com sucesso");
    
    return true;
}

/**
 * Carrega configuração do MX2 dos parâmetros de entrada
 */
void LoadMX2Configuration()
{
    g_mx2_config.enabled = g_config.notifications.enable_mx2;
    g_mx2_config.broker = g_config.notifications.mx2_broker;
    g_mx2_config.signal_type = g_config.notifications.mx2_signal_type;
    g_mx2_config.expiry_type = g_config.notifications.mx2_expiry_type;
    g_mx2_config.expiry_minutes = g_config.notifications.mx2_expiry_minutes;
    g_mx2_config.entry_value = g_config.financial.entry_value;
    g_mx2_config.enable_martingale = g_config.financial.enable_martingale;
    g_mx2_config.martingale_factor = g_config.financial.martingale_factor;
    g_mx2_config.max_gale_levels = g_config.financial.max_gale_levels;
    g_mx2_config.timeout_seconds = 30;
    g_mx2_config.send_screenshots = false;
    g_mx2_config.enable_logging = true;
    
    // URLs específicas por corretora
    switch(g_mx2_config.broker)
    {
        case MX2_QUOTEX:
            g_mx2_config.webhook_url = "https://api.mx2.com/quotex/signal";
            break;
        case MX2_POCKET:
            g_mx2_config.webhook_url = "https://api.mx2.com/pocket/signal";
            break;
        case MX2_BINOMO:
            g_mx2_config.webhook_url = "https://api.mx2.com/binomo/signal";
            break;
        case MX2_OLYMP:
            g_mx2_config.webhook_url = "https://api.mx2.com/olymp/signal";
            break;
        case MX2_EXPERT:
            g_mx2_config.webhook_url = "https://api.mx2.com/expert/signal";
            break;
        case MX2_SPECTRE:
            g_mx2_config.webhook_url = "https://api.mx2.com/spectre/signal";
            break;
        default:
            g_mx2_config.webhook_url = "https://api.mx2.com/all/signal";
            break;
    }
}

/**
 * Valida a configuração do MX2
 * @return true se configuração é válida
 */
bool ValidateMX2Configuration()
{
    if(StringLen(g_mx2_config.webhook_url) == 0)
    {
        Print("MX2: URL do webhook não configurada");
        return false;
    }
    
    if(g_mx2_config.expiry_minutes <= 0 || g_mx2_config.expiry_minutes > 60)
    {
        Print("MX2: Tempo de expiração inválido: ", g_mx2_config.expiry_minutes);
        return false;
    }
    
    if(g_mx2_config.entry_value <= 0)
    {
        Print("MX2: Valor de entrada inválido: ", g_mx2_config.entry_value);
        return false;
    }
    
    if(g_mx2_config.timeout_seconds <= 0 || g_mx2_config.timeout_seconds > 120)
    {
        Print("MX2: Timeout inválido: ", g_mx2_config.timeout_seconds);
        return false;
    }
    
    return true;
}

/**
 * Testa conectividade com o MX2
 * @return true se conectividade OK
 */
bool TestMX2Connectivity()
{
    string test_url = StringSubstr(g_mx2_config.webhook_url, 0, StringFind(g_mx2_config.webhook_url, "/signal")) + "/ping";
    
    char data[];
    char result[];
    string headers = "Content-Type: application/json\r\n";
    
    int timeout = g_mx2_config.timeout_seconds * 1000;
    int res = WebRequest("GET", test_url, headers, timeout, data, result, headers);
    
    if(res == 200)
    {
        Print("MX2: Conectividade OK");
        return true;
    }
    else
    {
        Print("MX2: Falha na conectividade - Código: ", res);
        return false;
    }
}

/**
 * Gera ID único para a sessão
 * @return ID da sessão
 */
string GenerateSessionId()
{
    return "ProbV3_" + TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS) + "_" + IntegerToString(MathRand());
}

//+------------------------------------------------------------------+
//| Funções de Envio de Sinais                                      |
//+------------------------------------------------------------------+

/**
 * Envia sinal para o MX2
 * @param signal_info Informações do sinal
 * @return true se enviado com sucesso
 */
bool SendSignalToMX2(const SignalInfo &signal_info)
{
    if(!g_mx2_initialized || !g_mx2_config.enabled)
    {
        return false;
    }
    
    // Cria estrutura do sinal MX2
    MX2Signal mx2_signal;
    if(!CreateMX2Signal(signal_info, mx2_signal))
    {
        Print("MX2: Falha ao criar sinal");
        return false;
    }
    
    // Converte para JSON
    string json_data = SignalToJSON(mx2_signal);
    if(StringLen(json_data) == 0)
    {
        Print("MX2: Falha ao converter sinal para JSON");
        return false;
    }
    
    // Envia via HTTP
    MX2Response response;
    if(!SendHTTPRequest(json_data, response))
    {
        Print("MX2: Falha no envio HTTP");
        g_mx2_signals_failed++;
        return false;
    }
    
    // Processa resposta
    bool success = ProcessMX2Response(response);
    
    // Atualiza contadores
    g_mx2_signals_sent++;
    if(success)
    {
        g_mx2_signals_success++;
        g_last_mx2_signal_time = TimeCurrent();
    }
    else
    {
        g_mx2_signals_failed++;
    }
    
    // Log da operação
    if(g_mx2_config.enable_logging)
    {
        LogMX2Operation(mx2_signal, response, success);
    }
    
    return success;
}

/**
 * Cria estrutura de sinal MX2 a partir do sinal do indicador
 * @param signal_info Informações do sinal original
 * @param mx2_signal Estrutura de sinal MX2 a ser preenchida
 * @return true se criado com sucesso
 */
bool CreateMX2Signal(const SignalInfo &signal_info, MX2Signal &mx2_signal)
{
    // Informações básicas
    mx2_signal.symbol = _Symbol;
    mx2_signal.is_call = signal_info.is_call;
    mx2_signal.signal_time = signal_info.signal_time;
    mx2_signal.entry_price = signal_info.signal_price;
    mx2_signal.confidence = signal_info.confidence;
    mx2_signal.pattern_type = signal_info.pattern_type;
    mx2_signal.pattern_name = PatternTypeToString(signal_info.pattern_type);
    
    // Configurações do MX2
    mx2_signal.target_broker = g_mx2_config.broker;
    mx2_signal.signal_type = g_mx2_config.signal_type;
    mx2_signal.expiry_type = g_mx2_config.expiry_type;
    mx2_signal.expiry_minutes = g_mx2_config.expiry_minutes;
    mx2_signal.entry_value = g_mx2_config.entry_value;
    mx2_signal.gale_level = g_current_gale_level;
    
    // Calcula tempo de expiração
    datetime expiry_time = CalculateExpiryTime(signal_info.signal_time, g_mx2_config.expiry_type, g_mx2_config.expiry_minutes);
    mx2_signal.expiry_time = expiry_time;
    
    // Informações adicionais
    mx2_signal.additional_info = StringFormat("Confiança: %.1f%% | Filtros: %s | ATR: %.5f", 
                                             signal_info.confidence,
                                             signal_info.filter_passed ? "OK" : "FALHOU",
                                             signal_info.atr_value);
    
    return true;
}

/**
 * Calcula tempo de expiração baseado no tipo
 * @param signal_time Tempo do sinal
 * @param expiry_type Tipo de expiração
 * @param expiry_minutes Minutos de expiração
 * @return Tempo de expiração calculado
 */
datetime CalculateExpiryTime(datetime signal_time, ExpirationTypeMX2 expiry_type, int expiry_minutes)
{
    datetime expiry_time = 0;
    
    switch(expiry_type)
    {
        case MX2_CORRIDO:
            // Expiração corrida - adiciona minutos ao tempo do sinal
            expiry_time = signal_time + expiry_minutes * 60;
            break;
            
        case MX2_EXATO:
            // Expiração exata - próximo horário exato
            MqlDateTime dt;
            TimeToStruct(signal_time, dt);
            
            // Zera segundos
            dt.sec = 0;
            
            // Adiciona minutos
            dt.min += expiry_minutes;
            
            // Ajusta se passou de 60 minutos
            if(dt.min >= 60)
            {
                dt.hour += dt.min / 60;
                dt.min = dt.min % 60;
            }
            
            // Ajusta se passou de 24 horas
            if(dt.hour >= 24)
            {
                dt.day += dt.hour / 24;
                dt.hour = dt.hour % 24;
            }
            
            expiry_time = StructToTime(dt);
            break;
    }
    
    return expiry_time;
}

/**
 * Converte sinal MX2 para formato JSON
 * @param mx2_signal Sinal MX2
 * @return String JSON
 */
string SignalToJSON(const MX2Signal &mx2_signal)
{
    string json = "{";
    
    // Informações básicas
    json += "\"symbol\":\"" + mx2_signal.symbol + "\",";
    json += "\"direction\":\"" + (mx2_signal.is_call ? "CALL" : "PUT") + "\",";
    json += "\"signal_time\":\"" + TimeToString(mx2_signal.signal_time, TIME_DATE|TIME_SECONDS) + "\",";
    json += "\"expiry_time\":\"" + TimeToString(mx2_signal.expiry_time, TIME_DATE|TIME_SECONDS) + "\",";
    json += "\"entry_price\":" + DoubleToString(mx2_signal.entry_price, _Digits) + ",";
    json += "\"confidence\":" + DoubleToString(mx2_signal.confidence, 1) + ",";
    
    // Padrão
    json += "\"pattern_type\":\"" + mx2_signal.pattern_name + "\",";
    
    // Configurações
    json += "\"broker\":\"" + BrokerMX2ToString(mx2_signal.target_broker) + "\",";
    json += "\"signal_type\":\"" + SignalTypeMX2ToString(mx2_signal.signal_type) + "\",";
    json += "\"expiry_type\":\"" + ExpirationTypeMX2ToString(mx2_signal.expiry_type) + "\",";
    json += "\"expiry_minutes\":" + IntegerToString(mx2_signal.expiry_minutes) + ",";
    json += "\"entry_value\":" + DoubleToString(mx2_signal.entry_value, 2) + ",";
    json += "\"gale_level\":" + IntegerToString(mx2_signal.gale_level) + ",";
    
    // Informações da sessão
    json += "\"session_id\":\"" + g_mx2_session_id + "\",";
    json += "\"indicator_version\":\"" + INDICATOR_VERSION + "\",";
    
    // Informações adicionais
    json += "\"additional_info\":\"" + mx2_signal.additional_info + "\"";
    
    json += "}";
    
    return json;
}

/**
 * Envia requisição HTTP para o MX2
 * @param json_data Dados em formato JSON
 * @param response Estrutura de resposta
 * @return true se enviado com sucesso
 */
bool SendHTTPRequest(const string json_data, MX2Response &response)
{
    uint start_time = GetTickCount();
    
    // Prepara dados
    char data[];
    StringToCharArray(json_data, data, 0, StringLen(json_data));
    
    // Prepara headers
    string headers = "Content-Type: application/json\r\n";
    if(StringLen(g_mx2_config.api_key) > 0)
    {
        headers += "Authorization: Bearer " + g_mx2_config.api_key + "\r\n";
    }
    headers += "User-Agent: IndicadorProbabilidades_V3/" + INDICATOR_VERSION + "\r\n";
    
    // Envia requisição
    char result[];
    string response_headers;
    int timeout = g_mx2_config.timeout_seconds * 1000;
    
    int status_code = WebRequest("POST", g_mx2_config.webhook_url, headers, timeout, data, result, response_headers);
    
    // Preenche resposta
    response.status_code = status_code;
    response.timestamp = TimeCurrent();
    response.processing_time_ms = GetTickCount() - start_time;
    
    if(status_code == 200 || status_code == 201)
    {
        response.success = true;
        response.response_body = CharArrayToString(result);
        response.error_message = "";
    }
    else
    {
        response.success = false;
        response.response_body = CharArrayToString(result);
        response.error_message = "HTTP Error " + IntegerToString(status_code);
    }
    
    g_last_mx2_response = response;
    
    return response.success;
}

/**
 * Processa resposta do MX2
 * @param response Resposta recebida
 * @return true se processamento OK
 */
bool ProcessMX2Response(const MX2Response &response)
{
    if(!response.success)
    {
        Print("MX2: Erro na resposta - ", response.error_message);
        return false;
    }
    
    // Analisa corpo da resposta se necessário
    if(StringLen(response.response_body) > 0)
    {
        // Aqui poderia fazer parsing do JSON de resposta
        // Por simplicidade, apenas verifica se contém "success"
        if(StringFind(response.response_body, "success") >= 0 || 
           StringFind(response.response_body, "ok") >= 0)
        {
            Print("MX2: Sinal enviado com sucesso em ", response.processing_time_ms, "ms");
            return true;
        }
    }
    
    Print("MX2: Resposta recebida mas sem confirmação de sucesso");
    return false;
}

/**
 * Registra operação MX2 no log
 * @param mx2_signal Sinal enviado
 * @param response Resposta recebida
 * @param success Sucesso da operação
 */
void LogMX2Operation(const MX2Signal &mx2_signal, const MX2Response &response, bool success)
{
    string log_message = StringFormat("MX2: %s | %s | %s | Confiança: %.1f%% | Status: %s | Tempo: %dms",
                                     mx2_signal.symbol,
                                     mx2_signal.is_call ? "CALL" : "PUT",
                                     mx2_signal.pattern_name,
                                     mx2_signal.confidence,
                                     success ? "SUCESSO" : "FALHA",
                                     response.processing_time_ms);
    
    Print(log_message);
    
    // Aqui poderia salvar em arquivo de log específico do MX2
}

//+------------------------------------------------------------------+
//| Funções de Conversão                                            |
//+------------------------------------------------------------------+

/**
 * Converte BrokerMX2 para string
 */
string BrokerMX2ToString(BrokerMX2 broker)
{
    switch(broker)
    {
        case MX2_QUOTEX: return "Quotex";
        case MX2_POCKET: return "Pocket Option";
        case MX2_BINOMO: return "Binomo";
        case MX2_OLYMP: return "Olymp Trade";
        case MX2_EXPERT: return "Expert Option";
        case MX2_SPECTRE: return "Spectre";
        default: return "Todas";
    }
}

/**
 * Converte SignalTypeMX2 para string
 */
string SignalTypeMX2ToString(SignalTypeMX2 signal_type)
{
    switch(signal_type)
    {
        case MX2_CLOSED_CANDLE: return "Vela Fechada";
        case MX2_OPEN_CANDLE: return "Vela Aberta";
        case MX2_IMMEDIATE: return "Imediato";
        default: return "Vela Fechada";
    }
}

/**
 * Converte ExpirationTypeMX2 para string
 */
string ExpirationTypeMX2ToString(ExpirationTypeMX2 expiry_type)
{
    switch(expiry_type)
    {
        case MX2_CORRIDO: return "Corrido";
        case MX2_EXATO: return "Exato";
        default: return "Corrido";
    }
}

//+------------------------------------------------------------------+
//| Funções de Status e Estatísticas                                |
//+------------------------------------------------------------------+

/**
 * Obtém estatísticas do MX2
 * @return String com estatísticas formatadas
 */
string GetMX2Statistics()
{
    if(!g_mx2_initialized)
        return "MX2: Não inicializado";
    
    if(!g_mx2_config.enabled)
        return "MX2: Desabilitado";
    
    double success_rate = 0.0;
    if(g_mx2_signals_sent > 0)
    {
        success_rate = (double)g_mx2_signals_success / g_mx2_signals_sent * 100.0;
    }
    
    return StringFormat("MX2: %d enviados | %d sucesso | %.1f%% taxa",
                       g_mx2_signals_sent,
                       g_mx2_signals_success,
                       success_rate);
}

/**
 * Verifica se MX2 está operacional
 * @return true se operacional
 */
bool IsMX2Operational()
{
    return g_mx2_initialized && g_mx2_config.enabled;
}

/**
 * Obtém última resposta do MX2
 * @return Estrutura da última resposta
 */
MX2Response GetLastMX2Response()
{
    return g_last_mx2_response;
}

/**
 * Reset estatísticas do MX2
 */
void ResetMX2Statistics()
{
    g_mx2_signals_sent = 0;
    g_mx2_signals_success = 0;
    g_mx2_signals_failed = 0;
    g_last_mx2_signal_time = 0;
}

#endif // NOTIFICATIONS_MX2_CORE_MQH

