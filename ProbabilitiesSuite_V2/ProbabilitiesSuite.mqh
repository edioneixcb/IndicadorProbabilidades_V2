//+------------------------------------------------------------------+
//|                                    ProbabilitiesSuite.mqh |
//|                        Copyright 2024, Quant Genius (Refactoring) |
//|                                      https://www.google.com |
//|                                    VERSÃO CORRIGIDA v2.0        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quant Genius (Refactoring)"
#property link      "https://www.google.com"
#property version   "2.00"
#property description "Suíte de Probabilidades Corrigida - Sistema Completo"

#ifndef PROBABILITIESSUITE_MQH
#define PROBABILITIESSUITE_MQH

// ==================================================================
// INCLUDES PRINCIPAIS - ORDEM HIERÁRQUICA CORRIGIDA
// ==================================================================

// Core System (Base)
#include "Core/Defines.mqh"
#include "Core/Globals.mqh"
#include "Core/Utilities.mqh"
#include "Core/Logger.mqh"
#include "Core/StateManager.mqh"
#include "Core/CacheManager.mqh"

// Logic Modules
#include "Logic/PatternEngine.mqh"
#include "Logic/SuperScan.mqh"

// Filter Modules
#include "Filter/Market.mqh"

// Visual Modules
#include "Visual/Drawing.mqh"
#include "Visual/Panel.mqh"

// Notification Modules
#include "Notification/Telegram.mqh"

// Buffer Manager
#include "BufferManager.mqh"

// ==================================================================
// CLASSE PRINCIPAL DA SUÍTE - VERSÃO 2.0
// ==================================================================

class ProbabilitiesSuiteV2
{
private:
    StateManager* m_state_manager;
    TelegramNotificationManager* m_telegram_manager;
    bool m_initialized;
    datetime m_last_update;
    
public:
    //+------------------------------------------------------------------+
    //| Construtor                                                       |
    //+------------------------------------------------------------------+
    ProbabilitiesSuiteV2()
    {
        m_state_manager = NULL;
        m_telegram_manager = NULL;
        m_initialized = false;
        m_last_update = 0;
    }
    
    //+------------------------------------------------------------------+
    //| Destrutor                                                        |
    //+------------------------------------------------------------------+
    ~ProbabilitiesSuiteV2()
    {
        Cleanup();
    }
    
    //+------------------------------------------------------------------+
    //| Inicialização completa do sistema                               |
    //+------------------------------------------------------------------+
    bool Initialize(
        int cache_size = 1000,
        bool enable_logging = true,
        bool enable_telegram = false,
        string telegram_token = "",
        string telegram_chat = ""
    )
    {
        Logger::Info("Suite", "Inicializando ProbabilitiesSuite V2.0");
        
        // Inicializa StateManager
        m_state_manager = StateManager::GetInstance();
        if(m_state_manager == NULL)
        {
            Logger::Critical("Suite", "Falha ao inicializar StateManager");
            return false;
        }
        
        // Configura logging
        if(enable_logging)
        {
            Logger::SetLogLevel(LOG_DEBUG);
            Logger::EnableFileLogging(true);
        }
        
        // Inicializa cache
        if(!AtualizarCachesDeDadosRobusta(cache_size, true, 20, 2.0, 14, false, 100, MODE_EMA))
        {
            Logger::Error("Suite", "Falha na inicialização do cache");
            return false;
        }
        
        // Configura Telegram se habilitado
        if(enable_telegram && telegram_token != "" && telegram_chat != "")
        {
            m_telegram_manager = new TelegramNotificationManager(telegram_token, telegram_chat);
            
            if(!TestarConfiguracaoTelegram(telegram_token, telegram_chat))
            {
                Logger::Warning("Suite", "Configuração Telegram falhou, continuando sem notificações");
                delete m_telegram_manager;
                m_telegram_manager = NULL;
            }
        }
        
        // Cria painel visual
        if(!CriarPainelInformativoRobusto())
        {
            Logger::Warning("Suite", "Falha ao criar painel visual");
        }
        
        if(!AdicionarTituloPainel("Probabilidades V2.0"))
        {
            Logger::Warning("Suite", "Falha ao adicionar título do painel");
        }
        
        m_initialized = true;
        m_last_update = TimeCurrent();
        
        Logger::Info("Suite", "ProbabilitiesSuite V2.0 inicializada com sucesso");
        
        // Envia notificação de inicialização
        if(m_telegram_manager != NULL)
        {
            m_telegram_manager.SendSignalNotification("SISTEMA", 0, "Sistema Inicializado");
        }
        
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Processamento principal do tick                                 |
    //+------------------------------------------------------------------+
    void OnTick(
        PatternType selected_pattern,
        bool invert_pattern,
        bool use_filters,
        double atr_min,
        double atr_max,
        bool bb_consolidation,
        bool trend_filter,
        ENUM_POSICAO_SETA arrow_position
    )
    {
        if(!m_initialized)
            return;
        
        AUTO_PERFORMANCE_LOG("Suite", "OnTick");
        
        // Atualiza estado
        m_state_manager.UpdateLastActivity("OnTick");
        
        // Processa buffers
        PreencheSinalBuffers(
            1, // Apenas a última vela
            selected_pattern,
            invert_pattern,
            use_filters,
            bb_consolidation,
            atr_min,
            atr_max,
            trend_filter,
            arrow_position
        );
        
        // Atualiza painel a cada minuto
        if((TimeCurrent() - m_last_update) >= 60)
        {
            UpdateVisualPanel();
            m_last_update = TimeCurrent();
        }
    }
    
    //+------------------------------------------------------------------+
    //| Executa SuperVarredura                                          |
    //+------------------------------------------------------------------+
    bool RunSuperScan(
        int analysis_bars = 500,
        bool use_filters = true,
        int &best_pattern,
        double &best_score,
        string &detailed_result
    )
    {
        if(!m_initialized)
        {
            detailed_result = "Sistema não inicializado";
            return false;
        }
        
        Logger::Info("Suite", "Executando SuperVarredura");
        
        bool success = ExecutarSuperVarreduraOtimizada(
            analysis_bars,
            use_filters,
            0.0001, 0.0005, // ATR range
            true, // BB consolidation
            true, // Trend filter
            best_pattern,
            best_score,
            detailed_result
        );
        
        if(success)
        {
            Logger::Info("Suite", "SuperVarredura concluída", 
                        "Melhor padrão: " + IntegerToString(best_pattern) + 
                        ", Score: " + DoubleToString(best_score, 2));
            
            // Envia resultado via Telegram
            if(m_telegram_manager != NULL)
            {
                string message = "SuperVarredura concluída\nMelhor padrão: " + 
                               IntegerToString(best_pattern) + 
                               "\nScore: " + DoubleToString(best_score, 2) + "%";
                
                EnviarNotificacaoTelegramRobusta(
                    "", "", message, false // Usar configuração do manager
                );
            }
        }
        
        return success;
    }
    
    //+------------------------------------------------------------------+
    //| Atualiza painel visual                                          |
    //+------------------------------------------------------------------+
    void UpdateVisualPanel()
    {
        if(!m_initialized)
            return;
        
        // Obtém estatísticas atuais
        string status = g_cache_initialized ? "Ativo" : "Inativo";
        int total_signals = g_signals_generated_count;
        double spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point / _Point;
        double atr = (ArraySize(g_cache_atr_values) > 0) ? g_cache_atr_values[0] : 0.0;
        
        // Atualiza painel principal
        AtualizarInformacoesPainel(
            status,
            total_signals,
            0, // Sinais corretos (implementar contador)
            0.0, // Taxa de acerto (implementar cálculo)
            "N/A", // Último padrão
            0 // Último sinal
        );
        
        // Atualiza estatísticas em tempo real
        AtualizarEstatisticasTempoReal(
            spread,
            atr,
            0, // Sinais hoje
            0.0, // Performance hoje
            g_cache_initialized ? "OK" : "ERRO"
        );
    }
    
    //+------------------------------------------------------------------+
    //| Diagnóstico completo do sistema                                 |
    //+------------------------------------------------------------------+
    void RunFullDiagnostic()
    {
        Logger::Info("Suite", "=== DIAGNÓSTICO COMPLETO DO SISTEMA ===");
        
        // Diagnóstico dos módulos
        DiagnosticCache();
        DiagnosticPatternEngine();
        DiagnosticMarketFilters();
        DiagnosticSuperScan();
        DiagnosticDrawingSystem();
        DiagnosticPanelSystem();
        
        if(m_telegram_manager != NULL)
        {
            DiagnosticTelegram("", ""); // Usar configuração do manager
        }
        
        // Diagnóstico do StateManager
        if(m_state_manager != NULL)
        {
            m_state_manager.PrintDiagnostic();
        }
        
        Logger::Info("Suite", "=== FIM DO DIAGNÓSTICO COMPLETO ===");
    }
    
    //+------------------------------------------------------------------+
    //| Limpeza completa do sistema                                     |
    //+------------------------------------------------------------------+
    void Cleanup()
    {
        Logger::Info("Suite", "Limpando ProbabilitiesSuite V2.0");
        
        // Limpa cache
        CleanupCache();
        
        // Limpa objetos visuais
        LimpezaCompletaDesenho();
        RemoverTodosPaineis();
        
        // Libera managers
        if(m_telegram_manager != NULL)
        {
            delete m_telegram_manager;
            m_telegram_manager = NULL;
        }
        
        // StateManager é singleton, não deletar
        m_state_manager = NULL;
        
        m_initialized = false;
        
        Logger::Info("Suite", "Limpeza concluída");
    }
    
    //+------------------------------------------------------------------+
    //| Getters para status                                             |
    //+------------------------------------------------------------------+
    bool IsInitialized() const { return m_initialized; }
    datetime GetLastUpdate() const { return m_last_update; }
    bool HasTelegram() const { return (m_telegram_manager != NULL); }
    
    //+------------------------------------------------------------------+
    //| Configuração dinâmica                                           |
    //+------------------------------------------------------------------+
    bool UpdateConfiguration(
        bool enable_telegram,
        string telegram_token,
        string telegram_chat,
        bool enable_visual_panel,
        bool enable_debug_logging
    )
    {
        Logger::Info("Suite", "Atualizando configuração do sistema");
        
        // Atualiza logging
        Logger::SetLogLevel(enable_debug_logging ? LOG_DEBUG : LOG_INFO);
        
        // Atualiza Telegram
        if(enable_telegram && telegram_token != "" && telegram_chat != "")
        {
            if(m_telegram_manager != NULL)
                delete m_telegram_manager;
            
            m_telegram_manager = new TelegramNotificationManager(telegram_token, telegram_chat);
        }
        else if(!enable_telegram && m_telegram_manager != NULL)
        {
            delete m_telegram_manager;
            m_telegram_manager = NULL;
        }
        
        // Atualiza painel visual
        if(!enable_visual_panel)
        {
            RemoverTodosPaineis();
        }
        else if(enable_visual_panel && ObjectFind(0, painelPrefix + "main_panel") < 0)
        {
            CriarPainelInformativoRobusto();
            AdicionarTituloPainel("Probabilidades V2.0");
        }
        
        Logger::Info("Suite", "Configuração atualizada com sucesso");
        return true;
    }
};

// ==================================================================
// INSTÂNCIA GLOBAL DA SUÍTE
// ==================================================================
ProbabilitiesSuiteV2* g_suite_instance = NULL;

//+------------------------------------------------------------------+
//| Função de inicialização global                                  |
//+------------------------------------------------------------------+
bool InitializeProbabilitiesSuite(
    int cache_size = 1000,
    bool enable_logging = true,
    bool enable_telegram = false,
    string telegram_token = "",
    string telegram_chat = ""
)
{
    if(g_suite_instance != NULL)
    {
        delete g_suite_instance;
    }
    
    g_suite_instance = new ProbabilitiesSuiteV2();
    
    return g_suite_instance.Initialize(
        cache_size,
        enable_logging,
        enable_telegram,
        telegram_token,
        telegram_chat
    );
}

//+------------------------------------------------------------------+
//| Função de limpeza global                                        |
//+------------------------------------------------------------------+
void CleanupProbabilitiesSuite()
{
    if(g_suite_instance != NULL)
    {
        g_suite_instance.Cleanup();
        delete g_suite_instance;
        g_suite_instance = NULL;
    }
}

//+------------------------------------------------------------------+
//| Função de acesso à instância global                             |
//+------------------------------------------------------------------+
ProbabilitiesSuiteV2* GetProbabilitiesSuite()
{
    return g_suite_instance;
}

#endif // PROBABILITIESSUITE_MQH

