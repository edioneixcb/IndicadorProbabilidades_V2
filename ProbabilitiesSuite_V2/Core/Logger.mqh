//+------------------------------------------------------------------+
//|                                    Core/Logger.mqh |
//|                        Copyright 2024, Quant Genius (Refactoring) |
//|                                      https://www.google.com |
//|                                    VERSÃO CORRIGIDA v2.0        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quant Genius (Refactoring)"
#property link      "https://www.google.com"

#ifndef CORE_LOGGER_MQH
#define CORE_LOGGER_MQH

#include "Defines.mqh"

// ==================================================================
// SISTEMA DE LOGGING ROBUSTO - CORREÇÃO CRÍTICA
// ==================================================================

//+------------------------------------------------------------------+
//| Classe Logger para sistema de logging centralizado              |
//+------------------------------------------------------------------+
class Logger 
{
private:
    static LogLevel current_level;
    static bool log_to_file;
    static bool log_to_console;
    static string log_file_path;
    static int log_file_handle;
    static bool initialized;
    static int max_file_size_kb;
    static int rotation_count;
    static datetime last_rotation_check;
    
    // Buffer para logs em memória (para casos de falha de arquivo)
    struct LogEntry 
    {
        datetime timestamp;
        LogLevel level;
        string module;
        string message;
        string details;
    };
    
    static LogEntry memory_buffer[1000];
    static int buffer_index;
    static int total_logs_written;
    
public:
    //+------------------------------------------------------------------+
    //| Inicialização do sistema de logging                             |
    //+------------------------------------------------------------------+
    static bool Initialize(LogLevel level = LOG_INFO, 
                          bool to_file = true, 
                          bool to_console = true,
                          string file_path = "")
    {
        current_level = level;
        log_to_file = to_file;
        log_to_console = to_console;
        max_file_size_kb = MAX_LOG_FILE_SIZE_KB;
        rotation_count = LOG_ROTATION_COUNT;
        last_rotation_check = TimeCurrent();
        buffer_index = 0;
        total_logs_written = 0;
        
        if(file_path == "")
        {
            log_file_path = "Logs\\ProbabilitiesSuite_V2_" + 
                           TimeToString(TimeCurrent(), TIME_DATE) + ".log";
        }
        else
        {
            log_file_path = file_path;
        }
        
        log_file_handle = INVALID_HANDLE;
        
        if(log_to_file)
        {
            if(!OpenLogFile())
            {
                Print("ERRO: Falha ao abrir arquivo de log: ", log_file_path);
                log_to_file = false; // Fallback para console apenas
            }
        }
        
        initialized = true;
        
        // Log inicial
        Info("Logger", "Sistema de logging inicializado", 
             "Nível: " + EnumToString(level) + 
             ", Arquivo: " + BoolToString(log_to_file) + 
             ", Console: " + BoolToString(log_to_console));
        
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Finalização do sistema de logging                               |
    //+------------------------------------------------------------------+
    static void Shutdown()
    {
        if(!initialized) return;
        
        Info("Logger", "Finalizando sistema de logging", 
             "Total de logs: " + IntegerToString(total_logs_written));
        
        if(log_file_handle != INVALID_HANDLE)
        {
            FileClose(log_file_handle);
            log_file_handle = INVALID_HANDLE;
        }
        
        initialized = false;
    }
    
    //+------------------------------------------------------------------+
    //| Métodos de logging por nível                                    |
    //+------------------------------------------------------------------+
    static void Debug(string module, string message, string details = "")
    {
        if(current_level <= LOG_DEBUG)
            WriteLog(LOG_DEBUG, module, message, details);
    }
    
    static void Info(string module, string message, string details = "")
    {
        if(current_level <= LOG_INFO)
            WriteLog(LOG_INFO, module, message, details);
    }
    
    static void Warning(string module, string message, string details = "")
    {
        if(current_level <= LOG_WARNING)
            WriteLog(LOG_WARNING, module, message, details);
    }
    
    static void Error(string module, string message, string details = "")
    {
        if(current_level <= LOG_ERROR)
            WriteLog(LOG_ERROR, module, message, details);
    }
    
    static void Critical(string module, string message, string details = "")
    {
        if(current_level <= LOG_CRITICAL)
            WriteLog(LOG_CRITICAL, module, message, details);
    }
    
    //+------------------------------------------------------------------+
    //| Logging especializado para diferentes contextos                 |
    //+------------------------------------------------------------------+
    static void LogPerformance(string module, string operation, ulong time_ms)
    {
        string message = "Performance: " + operation;
        string details = "Tempo: " + IntegerToString(time_ms) + "ms";
        
        if(time_ms > 1000) // Mais de 1 segundo
            Warning(module, message, details);
        else if(time_ms > 100) // Mais de 100ms
            Info(module, message, details);
        else
            Debug(module, message, details);
    }
    
    static void LogSystemState(string module, string state, string details = "")
    {
        Info(module, "Estado do sistema: " + state, details);
    }
    
    static void LogCacheOperation(string operation, bool success, int size = 0, string details = "")
    {
        string message = "Cache " + operation + ": " + (success ? "SUCESSO" : "FALHA");
        if(size > 0) details += " | Tamanho: " + IntegerToString(size);
        
        if(success)
            Info("Cache", message, details);
        else
            Error("Cache", message, details);
    }
    
    static void LogSuperVarredura(string phase, PatternType pattern, bool inverted, 
                                 double winrate, int operations, string details = "")
    {
        string message = "SuperVarredura " + phase;
        string full_details = "Padrão: " + EnumToString(pattern) + 
                             (inverted ? " (Inv)" : "") +
                             " | WR: " + DoubleToString(winrate, 1) + "%" +
                             " | Ops: " + IntegerToString(operations);
        if(details != "") full_details += " | " + details;
        
        Info("SuperVarredura", message, full_details);
    }
    
    static void LogSignal(string signal_type, PatternType pattern, bool inverted, 
                         double price, string details = "")
    {
        string message = "Sinal " + signal_type + " gerado";
        string full_details = "Padrão: " + EnumToString(pattern) + 
                             (inverted ? " (Inv)" : "") +
                             " | Preço: " + DoubleToString(price, _Digits);
        if(details != "") full_details += " | " + details;
        
        Info("Signal", message, full_details);
    }
    
    static void LogNotification(string type, bool success, string details = "")
    {
        string message = "Notificação " + type + ": " + (success ? "ENVIADA" : "FALHA");
        
        if(success)
            Info("Notification", message, details);
        else
            Error("Notification", message, details);
    }
    
    //+------------------------------------------------------------------+
    //| Métodos de configuração                                         |
    //+------------------------------------------------------------------+
    static void SetLevel(LogLevel level)
    {
        LogLevel old_level = current_level;
        current_level = level;
        Info("Logger", "Nível de log alterado", 
             "De: " + EnumToString(old_level) + " Para: " + EnumToString(level));
    }
    
    static LogLevel GetCurrentLevel()
    {
        return current_level;
    }
    
    static void SetFileLogging(bool enabled)
    {
        if(log_to_file == enabled) return;
        
        log_to_file = enabled;
        
        if(enabled && log_file_handle == INVALID_HANDLE)
        {
            OpenLogFile();
        }
        else if(!enabled && log_file_handle != INVALID_HANDLE)
        {
            FileClose(log_file_handle);
            log_file_handle = INVALID_HANDLE;
        }
        
        Info("Logger", "Log em arquivo " + (enabled ? "ativado" : "desativado"));
    }
    
    static void SetConsoleLogging(bool enabled)
    {
        log_to_console = enabled;
        Info("Logger", "Log no console " + (enabled ? "ativado" : "desativado"));
    }
    
    //+------------------------------------------------------------------+
    //| Métodos de diagnóstico                                          |
    //+------------------------------------------------------------------+
    static void PrintStatistics()
    {
        Print("=== ESTATÍSTICAS DO LOGGER ===");
        Print("Nível atual: ", EnumToString(current_level));
        Print("Log em arquivo: ", BoolToString(log_to_file));
        Print("Log no console: ", BoolToString(log_to_console));
        Print("Arquivo: ", log_file_path);
        Print("Total de logs: ", total_logs_written);
        Print("Buffer index: ", buffer_index);
        Print("Inicializado: ", BoolToString(initialized));
        Print("=== FIM DAS ESTATÍSTICAS ===");
    }
    
    static void DumpMemoryBuffer(int last_n = 50)
    {
        Print("=== ÚLTIMOS ", last_n, " LOGS EM MEMÓRIA ===");
        
        int start_index = (buffer_index - last_n + 1000) % 1000;
        for(int i = 0; i < last_n; i++)
        {
            int idx = (start_index + i) % 1000;
            if(memory_buffer[idx].timestamp > 0)
            {
                Print("[", TimeToString(memory_buffer[idx].timestamp), "] ",
                      GetLevelString(memory_buffer[idx].level), " [",
                      memory_buffer[idx].module, "] ",
                      memory_buffer[idx].message,
                      memory_buffer[idx].details != "" ? " | " + memory_buffer[idx].details : "");
            }
        }
        Print("=== FIM DO DUMP ===");
    }
    
    //+------------------------------------------------------------------+
    //| Rotação de arquivos de log                                      |
    //+------------------------------------------------------------------+
    static void CheckLogRotation()
    {
        if(!log_to_file || log_file_handle == INVALID_HANDLE) return;
        
        // Verifica apenas a cada 5 minutos
        if(TimeCurrent() - last_rotation_check < 300) return;
        
        last_rotation_check = TimeCurrent();
        
        // Verifica tamanho do arquivo
        long file_size = FileSize(log_file_handle);
        if(file_size > max_file_size_kb * 1024)
        {
            RotateLogFile();
        }
    }
    
private:
    //+------------------------------------------------------------------+
    //| Implementação interna do sistema de logging                     |
    //+------------------------------------------------------------------+
    static void WriteLog(LogLevel level, string module, string message, string details)
    {
        if(!initialized) return;
        
        datetime timestamp = TimeCurrent();
        
        // Armazena no buffer de memória
        memory_buffer[buffer_index].timestamp = timestamp;
        memory_buffer[buffer_index].level = level;
        memory_buffer[buffer_index].module = module;
        memory_buffer[buffer_index].message = message;
        memory_buffer[buffer_index].details = details;
        buffer_index = (buffer_index + 1) % 1000;
        
        // Formata a mensagem
        string formatted_message = FormatLogMessage(timestamp, level, module, message, details);
        
        // Escreve no console
        if(log_to_console)
        {
            Print(formatted_message);
        }
        
        // Escreve no arquivo
        if(log_to_file && log_file_handle != INVALID_HANDLE)
        {
            FileWrite(log_file_handle, formatted_message);
            FileFlush(log_file_handle);
            
            // Verifica rotação periodicamente
            if(total_logs_written % 100 == 0)
            {
                CheckLogRotation();
            }
        }
        
        total_logs_written++;
    }
    
    static string FormatLogMessage(datetime timestamp, LogLevel level, 
                                  string module, string message, string details)
    {
        string formatted = "[" + TimeToString(timestamp, TIME_DATE | TIME_SECONDS) + "] " +
                          GetLevelString(level) + " [" + module + "] " + message;
        
        if(details != "")
        {
            formatted += " | " + details;
        }
        
        return formatted;
    }
    
    static string GetLevelString(LogLevel level)
    {
        switch(level)
        {
            case LOG_DEBUG: return "DEBUG";
            case LOG_INFO: return "INFO ";
            case LOG_WARNING: return "WARN ";
            case LOG_ERROR: return "ERROR";
            case LOG_CRITICAL: return "CRIT ";
            default: return "UNKN ";
        }
    }
    
    static bool OpenLogFile()
    {
        if(log_file_handle != INVALID_HANDLE)
        {
            FileClose(log_file_handle);
        }
        
        log_file_handle = FileOpen(log_file_path, FILE_WRITE | FILE_TXT | FILE_ANSI);
        
        if(log_file_handle == INVALID_HANDLE)
        {
            Print("ERRO: Não foi possível abrir arquivo de log: ", log_file_path);
            return false;
        }
        
        // Escreve cabeçalho
        FileWrite(log_file_handle, "=== INDICADOR DE PROBABILIDADES V2.0 - LOG INICIADO ===");
        FileWrite(log_file_handle, "Timestamp: " + TimeToString(TimeCurrent()));
        FileWrite(log_file_handle, "Símbolo: " + _Symbol);
        FileWrite(log_file_handle, "Timeframe: " + EnumToString(_Period));
        FileWrite(log_file_handle, "========================================================");
        FileFlush(log_file_handle);
        
        return true;
    }
    
    static void RotateLogFile()
    {
        Info("Logger", "Iniciando rotação de arquivo de log");
        
        // Fecha arquivo atual
        if(log_file_handle != INVALID_HANDLE)
        {
            FileWrite(log_file_handle, "=== ROTAÇÃO DE LOG - ARQUIVO FECHADO ===");
            FileClose(log_file_handle);
            log_file_handle = INVALID_HANDLE;
        }
        
        // Renomeia arquivo atual
        string backup_name = log_file_path + "." + TimeToString(TimeCurrent(), TIME_DATE) + ".bak";
        // Em MQL5, não há função nativa para renomear arquivos
        // Então criamos um novo arquivo
        
        // Abre novo arquivo
        log_file_path = "Logs\\ProbabilitiesSuite_V2_" + 
                       TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + ".log";
        
        if(OpenLogFile())
        {
            Info("Logger", "Rotação de log concluída", "Novo arquivo: " + log_file_path);
        }
        else
        {
            Error("Logger", "Falha na rotação de log");
        }
    }
};

// Inicialização das variáveis estáticas
LogLevel Logger::current_level = LOG_INFO;
bool Logger::log_to_file = true;
bool Logger::log_to_console = true;
string Logger::log_file_path = "";
int Logger::log_file_handle = INVALID_HANDLE;
bool Logger::initialized = false;
int Logger::max_file_size_kb = MAX_LOG_FILE_SIZE_KB;
int Logger::rotation_count = LOG_ROTATION_COUNT;
datetime Logger::last_rotation_check = 0;
Logger::LogEntry Logger::memory_buffer[1000];
int Logger::buffer_index = 0;
int Logger::total_logs_written = 0;

//+------------------------------------------------------------------+
//| Macros de conveniência para logging                             |
//+------------------------------------------------------------------+
#define LOG_DEBUG_IF(condition, module, message) if(condition) Logger::Debug(module, message)
#define LOG_INFO_IF(condition, module, message) if(condition) Logger::Info(module, message)
#define LOG_WARNING_IF(condition, module, message) if(condition) Logger::Warning(module, message)
#define LOG_ERROR_IF(condition, module, message) if(condition) Logger::Error(module, message)

#define LOG_PERFORMANCE_START(name) ulong __perf_start_##name = GetTickCount64()
#define LOG_PERFORMANCE_END(module, name) Logger::LogPerformance(module, #name, GetTickCount64() - __perf_start_##name)

#define LOG_FUNCTION_ENTRY(module) Logger::Debug(module, "Entrando em " + __FUNCTION__)
#define LOG_FUNCTION_EXIT(module) Logger::Debug(module, "Saindo de " + __FUNCTION__)

//+------------------------------------------------------------------+
//| Classe auxiliar para logging automático de performance          |
//+------------------------------------------------------------------+
class AutoPerformanceLogger
{
private:
    ulong start_time;
    string module_name;
    string operation_name;
    
public:
    AutoPerformanceLogger(string module, string operation)
    {
        module_name = module;
        operation_name = operation;
        start_time = GetTickCount64();
        Logger::Debug(module, "Iniciando " + operation);
    }
    
    ~AutoPerformanceLogger()
    {
        ulong elapsed = GetTickCount64() - start_time;
        Logger::LogPerformance(module_name, operation_name, elapsed);
    }
};

#define AUTO_PERFORMANCE_LOG(module, operation) AutoPerformanceLogger __auto_perf(module, operation)

#endif // CORE_LOGGER_MQH

