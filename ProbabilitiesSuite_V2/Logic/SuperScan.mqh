//+------------------------------------------------------------------+
//|                                    Logic/SuperScan.mqh |
//|                        Copyright 2024, Quant Genius (Refactoring) |
//|                                      https://www.google.com |
//|                                    VERSÃO CORRIGIDA v2.0        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quant Genius (Refactoring)"
#property link      "https://www.google.com"

#ifndef LOGIC_SUPERSCAN_MQH
#define LOGIC_SUPERSCAN_MQH

#include "../Core/Defines.mqh"
#include "../Core/Globals.mqh"
#include "../Core/Utilities.mqh"
#include "../Core/Logger.mqh"
#include "../Core/StateManager.mqh"
#include "PatternEngine.mqh"
#include "../Filter/Market.mqh"

// ==================================================================
// SUPERVARREDURA OTIMIZADA - VERSÃO 2.0
// ==================================================================

//+------------------------------------------------------------------+
//| CORREÇÃO CRÍTICA: SuperVarredura Otimizada                      |
//+------------------------------------------------------------------+
bool ExecutarSuperVarreduraOtimizada(
    int velas_analise,
    bool usar_filtros,
    double atr_min,
    double atr_max,
    bool bb_consolidacao,
    bool filtro_tendencia,
    int &melhor_padrao,
    double &melhor_score,
    string &resultado_detalhado
)
{
    AUTO_PERFORMANCE_LOG("SuperScan", "ExecutarSuperVarreduraOtimizada");
    
    Logger::Info("SuperScan", "Iniciando SuperVarredura otimizada", 
                 "Velas: " + IntegerToString(velas_analise));
    
    // Inicialização
    melhor_padrao = -1;
    melhor_score = 0.0;
    resultado_detalhado = "";
    
    // Validação de entrada
    if(!ValidateInputParameter(velas_analise, 100, 2000, "velas_analise"))
    {
        resultado_detalhado = "Erro: Parâmetro velas_analise inválido";
        return false;
    }
    
    // Verifica cache
    if(!g_cache_initialized || g_cache_size < velas_analise)
    {
        Logger::Error("SuperScan", "Cache insuficiente para SuperVarredura");
        resultado_detalhado = "Erro: Cache não inicializado ou insuficiente";
        return false;
    }
    
    // Array de padrões para testar
    PatternType padroes[] = {
        PatternMHI1_3C_Minoria,
        PatternMHI2_3C_Confirmado,
        PatternMHI3_Unanime_Base,
        PatternThreeInARow_Base,
        PatternFiveInARow_Base,
        PatternC3_SeguirCor,
        PatternFourInARow_Base,
        PatternImpar_3C_Maioria,
        PatternMelhorDe3_Maioria
    };
    
    int total_padroes = ArraySize(padroes);
    
    // Estrutura para armazenar resultados
    struct PatternResult
    {
        PatternType pattern;
        int total_sinais;
        int sinais_corretos;
        double taxa_acerto;
        double score_ponderado;
        bool invertido;
    };
    
    PatternResult resultados[];
    ArrayResize(resultados, total_padroes * 2); // *2 para versões invertidas
    
    int resultado_index = 0;
    
    // Testa cada padrão (normal e invertido)
    for(int p = 0; p < total_padroes; p++)
    {
        for(int inv = 0; inv <= 1; inv++) // 0 = normal, 1 = invertido
        {
            bool invertido = (inv == 1);
            
            Logger::Debug("SuperScan", "Testando padrão", 
                         "Padrão: " + EnumToString(padroes[p]) + 
                         ", Invertido: " + BoolToString(invertido));
            
            // Testa padrão
            PatternResult resultado = TestarPadraoOtimizado(
                padroes[p], 
                invertido, 
                velas_analise, 
                usar_filtros, 
                atr_min, 
                atr_max, 
                bb_consolidacao, 
                filtro_tendencia
            );
            
            resultado.pattern = padroes[p];
            resultado.invertido = invertido;
            
            resultados[resultado_index] = resultado;
            resultado_index++;
            
            // Atualiza melhor resultado
            if(resultado.score_ponderado > melhor_score && resultado.total_sinais >= 10)
            {
                melhor_score = resultado.score_ponderado;
                melhor_padrao = p + (invertido ? 1000 : 0); // Codifica inversão
            }
            
            // Controle de tempo para evitar travamento
            if((GetTickCount() % 100) == 0)
            {
                Sleep(1); // Micro-pausa para não travar
            }
        }
    }
    
    // Gera relatório detalhado
    resultado_detalhado = GerarRelatorioSuperVarredura(resultados, resultado_index);
    
    Logger::Info("SuperScan", "SuperVarredura concluída", 
                "Melhor padrão: " + IntegerToString(melhor_padrao) + 
                ", Score: " + DoubleToString(melhor_score, 2));
    
    return true;
}

//+------------------------------------------------------------------+
//| Testa um padrão específico de forma otimizada                   |
//+------------------------------------------------------------------+
PatternResult TestarPadraoOtimizado(
    PatternType pattern,
    bool invertido,
    int velas_analise,
    bool usar_filtros,
    double atr_min,
    double atr_max,
    bool bb_consolidacao,
    bool filtro_tendencia
)
{
    PatternResult resultado;
    resultado.total_sinais = 0;
    resultado.sinais_corretos = 0;
    resultado.taxa_acerto = 0.0;
    resultado.score_ponderado = 0.0;
    
    int needed_history = GetNeededHistoryForPattern(pattern);
    int expiry_candles = 5; // Velas para verificar resultado
    
    // Amostragem inteligente para otimização
    int step = MathMax(1, velas_analise / 500); // Máximo 500 testes
    
    for(int i = needed_history + expiry_candles; i < velas_analise; i += step)
    {
        // Detecta padrão
        int direction = 0;
        bool pattern_detected = false;
        
        switch(pattern)
        {
            case PatternMHI1_3C_Minoria:
                pattern_detected = DetectMHI1_3C_Minoria(i, direction);
                break;
            case PatternMHI2_3C_Confirmado:
                pattern_detected = DetectMHI2_3C_Confirmado(i, direction);
                break;
            case PatternMHI3_Unanime_Base:
                pattern_detected = DetectMHI3_Unanime_Base(i, direction);
                break;
            case PatternThreeInARow_Base:
                pattern_detected = DetectThreeInARow_Base(i, direction);
                break;
            case PatternC3_SeguirCor:
                pattern_detected = DetectC3_SeguirCor(i, direction);
                break;
            // Adicione outros padrões conforme necessário
        }
        
        if(!pattern_detected)
            continue;
        
        // Aplica inversão se necessário
        if(invertido)
            direction = -direction;
        
        // Aplica filtros se habilitados
        if(usar_filtros)
        {
            if(!FiltroCombinadoMercado(
                i, true, atr_min, atr_max,
                bb_consolidacao, 50.0,
                filtro_tendencia, 5, 0.0001,
                false, 0, 0,
                false, 0.0,
                false, 0.0))
            {
                continue;
            }
        }
        
        resultado.total_sinais++;
        
        // Verifica resultado do sinal
        if(VerificarResultadoSinal(i, direction, expiry_candles))
        {
            resultado.sinais_corretos++;
        }
        
        // Controle de performance
        if(resultado.total_sinais >= 100) // Limite para otimização
            break;
    }
    
    // Calcula métricas
    if(resultado.total_sinais > 0)
    {
        resultado.taxa_acerto = (double)resultado.sinais_corretos / resultado.total_sinais * 100.0;
        
        // Score ponderado considera taxa de acerto e quantidade de sinais
        double peso_quantidade = MathMin(resultado.total_sinais / 50.0, 1.0); // Máximo peso = 1
        resultado.score_ponderado = resultado.taxa_acerto * peso_quantidade;
    }
    
    return resultado;
}

//+------------------------------------------------------------------+
//| Verifica resultado de um sinal                                  |
//+------------------------------------------------------------------+
bool VerificarResultadoSinal(int signal_shift, int direction, int expiry_candles)
{
    if(!ValidateShiftAccess(signal_shift, expiry_candles, "VerificarResultadoSinal"))
        return false;
    
    double entry_price = iClose(_Symbol, _Period, signal_shift);
    double exit_price = iClose(_Symbol, _Period, signal_shift - expiry_candles);
    
    if(entry_price <= 0 || exit_price <= 0)
        return false;
    
    double price_diff = exit_price - entry_price;
    
    // Para CALL (direction > 0): lucro se preço subiu
    // Para PUT (direction < 0): lucro se preço desceu
    if(direction > 0)
        return (price_diff > 0);
    else
        return (price_diff < 0);
}

//+------------------------------------------------------------------+
//| Gera relatório detalhado da SuperVarredura                      |
//+------------------------------------------------------------------+
string GerarRelatorioSuperVarredura(const PatternResult &resultados[], int total_resultados)
{
    string relatorio = "=== RELATÓRIO SUPERVARREDURA ===\n";
    relatorio += "Data/Hora: " + TimeToString(TimeCurrent()) + "\n";
    relatorio += "Total de padrões testados: " + IntegerToString(total_resultados) + "\n\n";
    
    // Ordena resultados por score (implementação simples)
    PatternResult sorted_results[];
    ArrayCopy(sorted_results, resultados, 0, 0, total_resultados);
    
    // Bubble sort simples para ordenar por score
    for(int i = 0; i < total_resultados - 1; i++)
    {
        for(int j = 0; j < total_resultados - i - 1; j++)
        {
            if(sorted_results[j].score_ponderado < sorted_results[j + 1].score_ponderado)
            {
                PatternResult temp = sorted_results[j];
                sorted_results[j] = sorted_results[j + 1];
                sorted_results[j + 1] = temp;
            }
        }
    }
    
    // Top 10 resultados
    int top_count = MathMin(10, total_resultados);
    relatorio += "TOP " + IntegerToString(top_count) + " PADRÕES:\n";
    relatorio += "Rank | Padrão | Inv | Sinais | Acertos | Taxa% | Score\n";
    relatorio += "-----+--------+-----+--------+---------+-------+------\n";
    
    for(int i = 0; i < top_count; i++)
    {
        PatternResult r = sorted_results[i];
        
        if(r.total_sinais == 0)
            continue;
        
        relatorio += StringFormat("%4d | %6s | %3s | %6d | %7d | %5.1f | %5.1f\n",
            i + 1,
            StringSubstr(EnumToString(r.pattern), 7, 6), // Abrevia nome do padrão
            r.invertido ? "SIM" : "NAO",
            r.total_sinais,
            r.sinais_corretos,
            r.taxa_acerto,
            r.score_ponderado
        );
    }
    
    relatorio += "\n=== FIM DO RELATÓRIO ===";
    
    return relatorio;
}

//+------------------------------------------------------------------+
//| SuperVarredura rápida para uso em tempo real                    |
//+------------------------------------------------------------------+
bool SuperVarreduraRapida(
    int velas_limite = 200,
    int &padrao_recomendado,
    double &confianca
)
{
    AUTO_PERFORMANCE_LOG("SuperScan", "SuperVarreduraRapida");
    
    padrao_recomendado = -1;
    confianca = 0.0;
    
    if(!g_cache_initialized)
        return false;
    
    // Testa apenas os 3 padrões mais eficientes
    PatternType padroes_rapidos[] = {
        PatternMHI1_3C_Minoria,
        PatternThreeInARow_Base,
        PatternC3_SeguirCor
    };
    
    double melhor_score = 0.0;
    
    for(int p = 0; p < ArraySize(padroes_rapidos); p++)
    {
        PatternResult resultado = TestarPadraoOtimizado(
            padroes_rapidos[p], 
            false, // Sem inversão para velocidade
            velas_limite, 
            false, // Sem filtros para velocidade
            0, 0, false, false
        );
        
        if(resultado.score_ponderado > melhor_score && resultado.total_sinais >= 5)
        {
            melhor_score = resultado.score_ponderado;
            padrao_recomendado = p;
            confianca = resultado.taxa_acerto;
        }
    }
    
    Logger::Debug("SuperScan", "SuperVarredura rápida concluída", 
                 "Padrão: " + IntegerToString(padrao_recomendado) + 
                 ", Confiança: " + DoubleToString(confianca, 1) + "%");
    
    return (padrao_recomendado >= 0);
}

//+------------------------------------------------------------------+
//| Função de diagnóstico da SuperVarredura                         |
//+------------------------------------------------------------------+
void DiagnosticSuperScan()
{
    Logger::Info("SuperScan", "=== DIAGNÓSTICO SUPERVARREDURA ===");
    
    if(!g_cache_initialized)
    {
        Logger::Warning("SuperScan", "Cache não inicializado");
        return;
    }
    
    Logger::Info("SuperScan", "Cache disponível: " + IntegerToString(g_cache_size) + " velas");
    
    // Teste rápido
    int padrao_rec;
    double confianca;
    
    uint start_time = GetTickCount();
    bool success = SuperVarreduraRapida(100, padrao_rec, confianca);
    uint elapsed = GetTickCount() - start_time;
    
    if(success)
    {
        Logger::Info("SuperScan", "Teste rápido bem-sucedido", 
                    "Padrão: " + IntegerToString(padrao_rec) + 
                    ", Confiança: " + DoubleToString(confianca, 1) + "%" + 
                    ", Tempo: " + IntegerToString(elapsed) + "ms");
    }
    else
    {
        Logger::Warning("SuperScan", "Teste rápido falhou");
    }
    
    Logger::Info("SuperScan", "=== FIM DO DIAGNÓSTICO ===");
}

#endif // LOGIC_SUPERSCAN_MQH

