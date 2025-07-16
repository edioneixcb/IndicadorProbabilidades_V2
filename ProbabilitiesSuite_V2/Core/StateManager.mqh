//+------------------------------------------------------------------+
//|                                    Core/StateManager.mqh |
//|                        Copyright 2024, Quant Genius (Refactoring) |
//|                                      https://www.google.com |
//|                                    VERSÃO CORRIGIDA v2.0        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quant Genius (Refactoring)"
#property link      "https://www.google.com"

#ifndef CORE_STATEMANAGER_MQH
#define CORE_STATEMANAGER_MQH

#include "Defines.mqh"
#include "Globals.mqh"

// ==================================================================
// GERENCIADOR DE ESTADO CENTRALIZADO - CORREÇÃO CRÍTICA
// ==================================================================

//+------------------------------------------------------------------+
//| Classe Singleton para gerenciamento de estado                   |
//+------------------------------------------------------------------+
class StateManager 
{
private:
    static StateManager* instance;
    
    // Controle de acesso thread-safe
    bool is_locked;
    datetime lock_time;
    string lock_owner;
    int lock_timeout_ms;
    
    // Estado encapsulado do sistema
    struct SystemState 
    {
        // Estado do Cache
        bool cache_initialized;
        int cache_size;
        datetime cache_last_update;
        string cache_integrity_hash;
        
        // Estado da SuperVarredura
        PatternType best_pattern;
        bool best_inverted;
        bool supervarredura_success;
        double best_win_rate;
        double best_balance;
        int best_operations;
        datetime sv_last_execution;
        
        // Estado de Controle
        datetime last_new_bar;
        bool telegram_cycle_active;
        int consecutive_losses;
        datetime system_start_time;
        
        // Estado de Notificações
        datetime telegram_last_signal;
        datetime mx2_last_signal;
        int signals_sent_today;
        
        // Metadados
        datetime last_state_update;
        string last_updater;
        int state_version;
    } current_state;
    
    // Histórico de mudanças para debugging
    struct StateChange 
    {
        datetime timestamp;
        string field_name;
        string old_value;
        string new_value;
        string updater;
        int state_version;
    };
    
    StateChange change_history[100]; // Últimas 100 mudanças
    int history_index;
    int state_version_counter;
    
public:
    //+------------------------------------------------------------------+
    //| Singleton pattern implementation                                |
    //+------------------------------------------------------------------+
    static StateManager* GetInstance()
    {
        if(instance == NULL)
        {
            instance = new StateManager();
            instance.Initialize();
        }
        return instance;
    }
    
    //+------------------------------------------------------------------+
    //| Destructor para limpeza                                         |
    //+------------------------------------------------------------------+
    ~StateManager()
    {
        if(is_locked)
        {
            Print("StateManager: Destruindo com lock ativo - Owner: ", lock_owner);
        }
        
        PrintStateReport();
        Print("StateManager: Destruído");
    }
    
    //+------------------------------------------------------------------+
    //| Inicialização do estado                                         |
    //+------------------------------------------------------------------+
    void Initialize()
    {
        is_locked = false;
        lock_timeout_ms = STATE_LOCK_TIMEOUT_MS;
        history_index = 0;
        state_version_counter = 1;
        
        // Estado inicial
        current_state.cache_initialized = false;
        current_state.cache_size = 0;
        current_state.cache_last_update = 0;
        current_state.cache_integrity_hash = "";
        
        current_state.best_pattern = PatternMHI1_3C_Minoria;
        current_state.best_inverted = false;
        current_state.supervarredura_success = false;
        current_state.best_win_rate = 0.0;
        current_state.best_balance = 0.0;
        current_state.best_operations = 0;
        current_state.sv_last_execution = 0;
        
        current_state.last_new_bar = 0;
        current_state.telegram_cycle_active = false;
        current_state.consecutive_losses = 0;
        current_state.system_start_time = TimeCurrent();
        
        current_state.telegram_last_signal = 0;
        current_state.mx2_last_signal = 0;
        current_state.signals_sent_today = 0;
        
        current_state.last_state_update = TimeCurrent();
        current_state.last_updater = "Initialize";
        current_state.state_version = state_version_counter++;
        
        Print("StateManager: Inicializado com sucesso (Versão ", current_state.state_version, ")");
    }
    
    //+------------------------------------------------------------------+
    //| Controle de acesso thread-safe                                  |
    //+------------------------------------------------------------------+
    bool AcquireLock(string owner, int timeout_ms = 0)
    {
        if(timeout_ms == 0) timeout_ms = lock_timeout_ms;
        
        ulong start_time = GetTickCount64();
        
        while(is_locked && (GetTickCount64() - start_time) < timeout_ms)
        {
            Sleep(10);
        }
        
        if(is_locked)
        {
            Print("StateManager: Timeout ao adquirir lock para ", owner, 
                  " (atual owner: ", lock_owner, ", tempo: ", 
                  (TimeCurrent() - lock_time), "s)");
            return false;
        }
        
        is_locked = true;
        lock_time = TimeCurrent();
        lock_owner = owner;
        return true;
    }
    
    void ReleaseLock(string owner)
    {
        if(lock_owner == owner || !is_locked)
        {
            is_locked = false;
            lock_owner = "";
        }
        else
        {
            Print("StateManager: Tentativa de liberação de lock por owner incorreto: ", 
                  owner, " (atual: ", lock_owner, ")");
        }
    }
    
    //+------------------------------------------------------------------+
    //| Logging de mudanças de estado                                   |
    //+------------------------------------------------------------------+
    void LogStateChange(string field_name, string old_value, string new_value, string updater)
    {
        change_history[history_index].timestamp = TimeCurrent();
        change_history[history_index].field_name = field_name;
        change_history[history_index].old_value = old_value;
        change_history[history_index].new_value = new_value;
        change_history[history_index].updater = updater;
        change_history[history_index].state_version = current_state.state_version;
        
        history_index = (history_index + 1) % 100;
    }
    
    //+------------------------------------------------------------------+
    //| Métodos de acesso ao estado do cache                           |
    //+------------------------------------------------------------------+
    bool UpdateCacheState(bool initialized, int size, string caller)
    {
        if(!AcquireLock(caller)) return false;
        
        // Log das mudanças
        if(current_state.cache_initialized != initialized)
        {
            LogStateChange("cache_initialized", 
                          BoolToString(current_state.cache_initialized),
                          BoolToString(initialized), caller);
        }
        
        if(current_state.cache_size != size)
        {
            LogStateChange("cache_size", 
                          IntegerToString(current_state.cache_size),
                          IntegerToString(size), caller);
        }
        
        current_state.cache_initialized = initialized;
        current_state.cache_size = size;
        current_state.cache_last_update = TimeCurrent();
        current_state.last_state_update = TimeCurrent();
        current_state.last_updater = caller;
        current_state.state_version = state_version_counter++;
        
        ReleaseLock(caller);
        return true;
    }
    
    bool GetCacheState(bool &initialized, int &size, datetime &last_update)
    {
        if(is_locked) return false;
        
        initialized = current_state.cache_initialized;
        size = current_state.cache_size;
        last_update = current_state.cache_last_update;
        return true;
    }
    
    bool SetCacheIntegrityHash(string hash, string caller)
    {
        if(!AcquireLock(caller)) return false;
        
        if(current_state.cache_integrity_hash != hash)
        {
            LogStateChange("cache_integrity_hash", 
                          current_state.cache_integrity_hash, hash, caller);
        }
        
        current_state.cache_integrity_hash = hash;
        current_state.last_state_update = TimeCurrent();
        current_state.last_updater = caller;
        current_state.state_version = state_version_counter++;
        
        ReleaseLock(caller);
        return true;
    }
    
    string GetCacheIntegrityHash()
    {
        return current_state.cache_integrity_hash;
    }
    
    //+------------------------------------------------------------------+
    //| Métodos de acesso ao estado da SuperVarredura                  |
    //+------------------------------------------------------------------+
    bool UpdateSuperVarreduraState(PatternType pattern, bool inverted, 
                                   double win_rate, double balance, 
                                   int operations, string caller)
    {
        if(!AcquireLock(caller)) return false;
        
        // Log das mudanças significativas
        if(current_state.best_pattern != pattern)
        {
            LogStateChange("best_pattern", 
                          EnumToString(current_state.best_pattern),
                          EnumToString(pattern), caller);
        }
        
        if(current_state.best_inverted != inverted)
        {
            LogStateChange("best_inverted", 
                          BoolToString(current_state.best_inverted),
                          BoolToString(inverted), caller);
        }
        
        current_state.best_pattern = pattern;
        current_state.best_inverted = inverted;
        current_state.best_win_rate = win_rate;
        current_state.best_balance = balance;
        current_state.best_operations = operations;
        current_state.supervarredura_success = true;
        current_state.sv_last_execution = TimeCurrent();
        current_state.last_state_update = TimeCurrent();
        current_state.last_updater = caller;
        current_state.state_version = state_version_counter++;
        
        ReleaseLock(caller);
        return true;
    }
    
    bool GetSuperVarreduraState(PatternType &pattern, bool &inverted, bool &success)
    {
        if(is_locked) return false;
        
        pattern = current_state.best_pattern;
        inverted = current_state.best_inverted;
        success = current_state.supervarredura_success;
        return true;
    }
    
    bool GetSuperVarreduraDetails(PatternType &pattern, bool &inverted, 
                                  double &win_rate, double &balance, 
                                  int &operations, datetime &last_execution)
    {
        if(is_locked) return false;
        
        pattern = current_state.best_pattern;
        inverted = current_state.best_inverted;
        win_rate = current_state.best_win_rate;
        balance = current_state.best_balance;
        operations = current_state.best_operations;
        last_execution = current_state.sv_last_execution;
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Métodos de controle de telegram                                |
    //+------------------------------------------------------------------+
    bool SetTelegramCycleActive(bool active, string caller)
    {
        if(!AcquireLock(caller)) return false;
        
        if(current_state.telegram_cycle_active != active)
        {
            LogStateChange("telegram_cycle_active", 
                          BoolToString(current_state.telegram_cycle_active),
                          BoolToString(active), caller);
            
            if(active)
            {
                current_state.telegram_last_signal = TimeCurrent();
                current_state.signals_sent_today++;
            }
        }
        
        current_state.telegram_cycle_active = active;
        current_state.last_state_update = TimeCurrent();
        current_state.last_updater = caller;
        current_state.state_version = state_version_counter++;
        
        ReleaseLock(caller);
        return true;
    }
    
    bool IsTelegramCycleActive()
    {
        return current_state.telegram_cycle_active;
    }
    
    datetime GetLastTelegramSignalTime()
    {
        return current_state.telegram_last_signal;
    }
    
    int GetSignalsSentToday()
    {
        return current_state.signals_sent_today;
    }
    
    //+------------------------------------------------------------------+
    //| Métodos de controle de barra                                   |
    //+------------------------------------------------------------------+
    bool UpdateLastNewBar(datetime bar_time, string caller)
    {
        if(!AcquireLock(caller)) return false;
        
        if(current_state.last_new_bar != bar_time)
        {
            LogStateChange("last_new_bar", 
                          TimeToString(current_state.last_new_bar),
                          TimeToString(bar_time), caller);
        }
        
        current_state.last_new_bar = bar_time;
        current_state.last_state_update = TimeCurrent();
        current_state.last_updater = caller;
        current_state.state_version = state_version_counter++;
        
        ReleaseLock(caller);
        return true;
    }
    
    datetime GetLastNewBarTime()
    {
        return current_state.last_new_bar;
    }
    
    //+------------------------------------------------------------------+
    //| Métodos de controle de perdas consecutivas                     |
    //+------------------------------------------------------------------+
    bool IncrementConsecutiveLosses(string caller)
    {
        if(!AcquireLock(caller)) return false;
        
        current_state.consecutive_losses++;
        LogStateChange("consecutive_losses", 
                      IntegerToString(current_state.consecutive_losses - 1),
                      IntegerToString(current_state.consecutive_losses), caller);
        
        current_state.last_state_update = TimeCurrent();
        current_state.last_updater = caller;
        current_state.state_version = state_version_counter++;
        
        ReleaseLock(caller);
        return true;
    }
    
    bool ResetConsecutiveLosses(string caller)
    {
        if(!AcquireLock(caller)) return false;
        
        if(current_state.consecutive_losses > 0)
        {
            LogStateChange("consecutive_losses", 
                          IntegerToString(current_state.consecutive_losses),
                          "0", caller);
        }
        
        current_state.consecutive_losses = 0;
        current_state.last_state_update = TimeCurrent();
        current_state.last_updater = caller;
        current_state.state_version = state_version_counter++;
        
        ReleaseLock(caller);
        return true;
    }
    
    int GetConsecutiveLosses()
    {
        return current_state.consecutive_losses;
    }
    
    //+------------------------------------------------------------------+
    //| Métodos de notificação MX2                                     |
    //+------------------------------------------------------------------+
    bool UpdateMx2LastSignal(string caller)
    {
        if(!AcquireLock(caller)) return false;
        
        current_state.mx2_last_signal = TimeCurrent();
        current_state.last_state_update = TimeCurrent();
        current_state.last_updater = caller;
        current_state.state_version = state_version_counter++;
        
        ReleaseLock(caller);
        return true;
    }
    
    datetime GetMx2LastSignalTime()
    {
        return current_state.mx2_last_signal;
    }
    
    //+------------------------------------------------------------------+
    //| Métodos de informação do sistema                               |
    //+------------------------------------------------------------------+
    int GetSystemUptimeSeconds()
    {
        return (int)(TimeCurrent() - current_state.system_start_time);
    }
    
    int GetCurrentStateVersion()
    {
        return current_state.state_version;
    }
    
    string GetLastUpdater()
    {
        return current_state.last_updater;
    }
    
    datetime GetLastUpdateTime()
    {
        return current_state.last_state_update;
    }
    
    //+------------------------------------------------------------------+
    //| Diagnóstico e debugging                                         |
    //+------------------------------------------------------------------+
    void PrintStateReport()
    {
        Print("=== STATE MANAGER REPORT (v", current_state.state_version, ") ===");
        Print("Cache: ", BoolToString(current_state.cache_initialized), 
              " (", current_state.cache_size, " velas, hash: ", 
              StringSubstr(current_state.cache_integrity_hash, 0, 8), "...)");
        Print("SuperVarredura: ", BoolToString(current_state.supervarredura_success),
              " (", EnumToString(current_state.best_pattern), 
              current_state.best_inverted ? " Inv" : "", 
              ", WR: ", DoubleToString(current_state.best_win_rate, 1), "%)");
        Print("Telegram: ", BoolToString(current_state.telegram_cycle_active),
              " (Sinais hoje: ", current_state.signals_sent_today, ")");
        Print("Perdas consecutivas: ", current_state.consecutive_losses);
        Print("Uptime: ", GetSystemUptimeSeconds(), "s");
        Print("Último update: ", TimeToString(current_state.last_state_update),
              " por ", current_state.last_updater);
        Print("Lock status: ", BoolToString(is_locked), 
              is_locked ? " (owner: " + lock_owner + ")" : "");
        Print("=== FIM DO REPORT ===");
    }
    
    void PrintChangeHistory(int last_n = 10)
    {
        Print("=== ÚLTIMAS ", last_n, " MUDANÇAS DE ESTADO ===");
        
        int start_index = (history_index - last_n + 100) % 100;
        for(int i = 0; i < last_n; i++)
        {
            int idx = (start_index + i) % 100;
            if(change_history[idx].timestamp > 0)
            {
                Print("v", change_history[idx].state_version, " ",
                      TimeToString(change_history[idx].timestamp), " [", 
                      change_history[idx].updater, "] ", 
                      change_history[idx].field_name, ": ",
                      change_history[idx].old_value, " -> ",
                      change_history[idx].new_value);
            }
        }
        Print("=== FIM DO HISTÓRICO ===");
    }
    
    //+------------------------------------------------------------------+
    //| Métodos de validação e integridade                             |
    //+------------------------------------------------------------------+
    bool ValidateStateIntegrity()
    {
        // Verifica consistência básica
        if(current_state.cache_size < 0)
        {
            Print("ERRO: Tamanho de cache inválido: ", current_state.cache_size);
            return false;
        }
        
        if(current_state.best_win_rate < 0 || current_state.best_win_rate > 100)
        {
            Print("ERRO: Winrate inválido: ", current_state.best_win_rate);
            return false;
        }
        
        if(current_state.consecutive_losses < 0)
        {
            Print("ERRO: Perdas consecutivas inválidas: ", current_state.consecutive_losses);
            return false;
        }
        
        if(current_state.signals_sent_today < 0)
        {
            Print("ERRO: Sinais enviados inválidos: ", current_state.signals_sent_today);
            return false;
        }
        
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Métodos de backup e restauração                                |
    //+------------------------------------------------------------------+
    string ExportStateToString()
    {
        string state_data = "";
        state_data += "cache_initialized=" + BoolToString(current_state.cache_initialized) + ";";
        state_data += "cache_size=" + IntegerToString(current_state.cache_size) + ";";
        state_data += "best_pattern=" + EnumToString(current_state.best_pattern) + ";";
        state_data += "best_inverted=" + BoolToString(current_state.best_inverted) + ";";
        state_data += "supervarredura_success=" + BoolToString(current_state.supervarredura_success) + ";";
        state_data += "best_win_rate=" + DoubleToString(current_state.best_win_rate, 2) + ";";
        state_data += "consecutive_losses=" + IntegerToString(current_state.consecutive_losses) + ";";
        state_data += "signals_sent_today=" + IntegerToString(current_state.signals_sent_today) + ";";
        state_data += "state_version=" + IntegerToString(current_state.state_version) + ";";
        
        return state_data;
    }
    
    //+------------------------------------------------------------------+
    //| Reset de emergência                                            |
    //+------------------------------------------------------------------+
    void EmergencyReset(string caller)
    {
        Print("StateManager: RESET DE EMERGÊNCIA solicitado por ", caller);
        
        if(is_locked)
        {
            Print("StateManager: Forçando liberação de lock para reset");
            is_locked = false;
            lock_owner = "";
        }
        
        // Preserva apenas informações críticas
        datetime preserved_start_time = current_state.system_start_time;
        int preserved_signals_today = current_state.signals_sent_today;
        
        // Reinicializa estado
        Initialize();
        
        // Restaura informações preservadas
        current_state.system_start_time = preserved_start_time;
        current_state.signals_sent_today = preserved_signals_today;
        
        LogStateChange("emergency_reset", "FULL_STATE", "RESET", caller);
        
        Print("StateManager: Reset de emergência concluído");
    }
};

// Inicialização do singleton
StateManager* StateManager::instance = NULL;

//+------------------------------------------------------------------+
//| Funções globais de conveniência                                 |
//+------------------------------------------------------------------+

// Função global para obter instância do StateManager
StateManager* GetStateManager()
{
    return StateManager::GetInstance();
}

// Função global para verificar se o sistema está em estado válido
bool IsSystemStateValid()
{
    StateManager* state = StateManager::GetInstance();
    if(state == NULL) return false;
    
    return state.ValidateStateIntegrity();
}

#endif // CORE_STATEMANAGER_MQH

