//+------------------------------------------------------------------+
//|                                    Analysis/Financial/FinancialCore.mqh |
//|                                    Indicador de Probabilidades V3 |
//|                                Sistema de Análise Financeira |
//+------------------------------------------------------------------+

#ifndef ANALYSIS_FINANCIAL_CORE_MQH
#define ANALYSIS_FINANCIAL_CORE_MQH

#include "../../Core/Types.mqh"
#include "../../Core/Globals.mqh"

//+------------------------------------------------------------------+
//| Funções de Inicialização do Sistema Financeiro                  |
//+------------------------------------------------------------------+

/**
 * Inicializa o sistema financeiro
 * @return true se inicializado com sucesso
 */
bool InitializeFinancialSystem()
{
    // Configurar valores iniciais
    g_current_balance = g_config.financial.entry_value * 100; // Saldo inicial baseado no valor de entrada
    g_starting_balance = g_current_balance;
    g_daily_profit = 0.0;
    g_total_profit = 0.0;
    
    // Resetar contadores
    g_total_operations = 0;
    g_total_wins = 0;
    g_total_losses = 0;
    g_daily_operations = 0;
    g_daily_wins = 0;
    g_daily_losses = 0;
    
    // Inicializar martingale
    g_current_martingale_level = 0;
    g_current_entry_value = g_config.financial.entry_value;
    g_martingale_sequence_active = false;
    
    // Calcular simulação de martingale
    CalculateMartingaleSimulation();
    
    Print("Sistema financeiro inicializado - Saldo inicial: ", FormatCurrency(g_current_balance));
    return true;
}

/**
 * Calcula simulação de martingale
 */
void CalculateMartingaleSimulation()
{
    double base_value = g_config.financial.entry_value;
    double factor = g_config.financial.martingale_factor;
    double payout = g_config.financial.payout;
    
    for(int i = 0; i < g_config.financial.max_gale_levels && i < 10; i++)
    {
        // Calcular valor de entrada para este nível
        g_martingale_sim.entry_values[i] = base_value * MathPow(factor, i);
        
        // Calcular investimento total acumulado
        g_martingale_sim.total_investment[i] = 0.0;
        for(int j = 0; j <= i; j++)
        {
            g_martingale_sim.total_investment[i] += base_value * MathPow(factor, j);
        }
        
        // Calcular lucro potencial
        g_martingale_sim.potential_profit[i] = (g_martingale_sim.entry_values[i] * payout) - g_martingale_sim.total_investment[i];
        
        // Calcular percentual de risco
        if(g_current_balance > 0)
        {
            g_martingale_sim.risk_percentage[i] = (g_martingale_sim.total_investment[i] / g_current_balance) * 100.0;
        }
    }
}

/**
 * Processa sinal financeiramente
 */
void ProcessFinancialSignal(SignalInfo &signal)
{
    // Verificar se pode operar
    if(!CanOperate())
    {
        Print("Operação bloqueada por stop loss/win ou saldo insuficiente");
        return;
    }
    
    // Determinar valor de entrada baseado no martingale
    double entry_value = GetCurrentEntryValue();
    signal.entry_value = entry_value;
    signal.martingale_level = g_current_martingale_level;
    
    // Simular operação (em ambiente real, seria executada na corretora)
    SimulateOperation(signal);
    
    // Atualizar estatísticas
    UpdateOperationStatistics(signal);
    
    // Atualizar martingale
    UpdateMartingaleLevel(signal);
    
    // Verificar stops
    CheckStopConditions();
    
    // Recalcular simulação de martingale
    CalculateMartingaleSimulation();
}

/**
 * Verifica se pode operar
 */
bool CanOperate()
{
    // Verificar stop loss
    if(g_config.financial.enable_stop_loss)
    {
        double loss = g_starting_balance - g_current_balance;
        if(loss >= g_config.financial.stop_loss_value)
        {
            return false;
        }
    }
    
    // Verificar stop win
    if(g_config.financial.enable_stop_win)
    {
        if(g_total_profit >= g_config.financial.stop_win_value)
        {
            return false;
        }
    }
    
    // Verificar saldo suficiente
    double required_value = GetCurrentEntryValue();
    if(g_current_balance < required_value)
    {
        return false;
    }
    
    return true;
}

/**
 * Obtém valor de entrada atual baseado no martingale
 */
double GetCurrentEntryValue()
{
    if(!g_config.financial.enable_martingale || g_current_martingale_level >= 10)
    {
        return g_config.financial.entry_value;
    }
    
    return g_martingale_sim.entry_values[g_current_martingale_level];
}

/**
 * Simula operação (para backtesting)
 */
void SimulateOperation(SignalInfo &signal)
{
    // Em ambiente real, aqui seria feita a operação na corretora
    // Para simulação, vamos usar uma taxa de acerto baseada na confiança
    
    double win_probability = signal.confidence / 100.0;
    double random_value = (double)MathRand() / 32767.0;
    
    bool operation_win = (random_value <= win_probability);
    
    // Calcular resultado financeiro
    double profit_loss = 0.0;
    if(operation_win)
    {
        profit_loss = signal.entry_value * g_config.financial.payout;
    }
    else
    {
        profit_loss = -signal.entry_value;
    }
    
    // Atualizar saldo
    g_current_balance += profit_loss;
    g_total_profit += profit_loss;
    g_daily_profit += profit_loss;
    
    // Salvar resultado
    if(g_total_operations < 1000)
    {
        g_operation_results[g_total_operations] = profit_loss;
        g_operation_times[g_total_operations] = signal.signal_time;
        g_operation_patterns[g_total_operations] = signal.pattern_type;
    }
    
    // Log
    Print("Operação simulada: ", operation_win ? "WIN" : "LOSS", 
          " | Lucro: ", FormatCurrency(profit_loss),
          " | Saldo: ", FormatCurrency(g_current_balance));
}

/**
 * Atualiza estatísticas de operação
 */
void UpdateOperationStatistics(SignalInfo &signal)
{
    // Incrementar contadores
    g_total_operations++;
    g_daily_operations++;
    
    // Determinar se foi vitória ou derrota baseado no último resultado
    bool was_win = false;
    if(g_total_operations > 0 && g_total_operations <= 1000)
    {
        was_win = (g_operation_results[g_total_operations-1] > 0);
    }
    
    if(was_win)
    {
        g_total_wins++;
        g_daily_wins++;
    }
    else
    {
        g_total_losses++;
        g_daily_losses++;
    }
    
    // Atualizar drawdown
    UpdateDrawdownAnalysis();
    
    // Atualizar análise de risco
    UpdateRiskAnalysis();
}

/**
 * Atualiza nível de martingale
 */
void UpdateMartingaleLevel(SignalInfo &signal)
{
    if(!g_config.financial.enable_martingale)
        return;
    
    // Determinar se foi vitória baseado no último resultado
    bool was_win = false;
    if(g_total_operations > 0 && g_total_operations <= 1000)
    {
        was_win = (g_operation_results[g_total_operations-1] > 0);
    }
    
    if(was_win)
    {
        // Vitória - resetar martingale
        g_current_martingale_level = 0;
        g_martingale_sequence_active = false;
    }
    else
    {
        // Derrota - avançar martingale
        if(g_current_martingale_level < g_config.financial.max_gale_levels - 1)
        {
            g_current_martingale_level++;
            g_martingale_sequence_active = true;
        }
        else
        {
            // Máximo de gales atingido - resetar
            g_current_martingale_level = 0;
            g_martingale_sequence_active = false;
        }
    }
}

/**
 * Verifica condições de stop
 */
void CheckStopConditions()
{
    // Verificar stop loss
    if(g_config.financial.enable_stop_loss)
    {
        double loss = g_starting_balance - g_current_balance;
        if(loss >= g_config.financial.stop_loss_value)
        {
            Print("STOP LOSS ATIVADO - Perda: ", FormatCurrency(loss));
            // Em ambiente real, pausaria o sistema
        }
    }
    
    // Verificar stop win
    if(g_config.financial.enable_stop_win)
    {
        if(g_total_profit >= g_config.financial.stop_win_value)
        {
            Print("STOP WIN ATIVADO - Lucro: ", FormatCurrency(g_total_profit));
            // Em ambiente real, pausaria o sistema
        }
    }
}

/**
 * Atualiza análise de drawdown
 */
void UpdateDrawdownAnalysis()
{
    // Calcular drawdown atual
    g_current_drawdown = g_current_balance - g_starting_balance;
    
    // Atualizar máximo drawdown
    if(g_current_drawdown < g_max_drawdown_value)
    {
        g_max_drawdown_value = g_current_drawdown;
        g_max_drawdown_percentage = (g_max_drawdown_value / g_starting_balance) * 100.0;
    }
    
    // Atualizar estatísticas diárias
    g_daily_stats.max_drawdown_value = g_max_drawdown_value;
    g_daily_stats.max_drawdown_percentage = g_max_drawdown_percentage;
}

/**
 * Atualiza análise de risco
 */
void UpdateRiskAnalysis()
{
    if(g_total_operations < 10)
        return;
    
    // Calcular volatilidade baseada nos resultados
    double sum_squared_deviations = 0.0;
    double average_result = g_total_profit / g_total_operations;
    
    int operations_to_analyze = MathMin(g_total_operations, 1000);
    for(int i = 0; i < operations_to_analyze; i++)
    {
        double deviation = g_operation_results[i] - average_result;
        sum_squared_deviations += deviation * deviation;
    }
    
    g_daily_stats.volatility = MathSqrt(sum_squared_deviations / operations_to_analyze);
    
    // Calcular Sharpe Ratio simplificado
    if(g_daily_stats.volatility > 0)
    {
        g_daily_stats.sharpe_ratio = average_result / g_daily_stats.volatility;
    }
    
    // Calcular recovery factor
    if(g_max_drawdown_value < 0)
    {
        g_daily_stats.recovery_factor = g_total_profit / MathAbs(g_max_drawdown_value);
    }
    
    // Calcular Calmar Ratio
    if(g_max_drawdown_percentage < 0)
    {
        double annual_return = g_total_profit; // Simplificado
        g_daily_stats.calmar_ratio = annual_return / MathAbs(g_max_drawdown_percentage);
    }
}

/**
 * Atualiza análise financeira geral
 */
void UpdateFinancialAnalysis()
{
    // Recalcular simulação de martingale
    CalculateMartingaleSimulation();
    
    // Atualizar análise de risco
    UpdateRiskAnalysis();
    
    // Atualizar drawdown
    UpdateDrawdownAnalysis();
}

/**
 * Reseta estatísticas diárias
 */
void ResetDailyStatistics()
{
    g_daily_operations = 0;
    g_daily_wins = 0;
    g_daily_losses = 0;
    g_daily_profit = 0.0;
    g_current_martingale_level = 0;
    g_martingale_sequence_active = false;
    
    Print("Estatísticas diárias resetadas");
}

/**
 * Obtém winrate atual
 */
double GetCurrentWinrate()
{
    if(g_total_operations == 0)
        return 0.0;
    
    return ((double)g_total_wins / g_total_operations) * 100.0;
}

/**
 * Obtém winrate diário
 */
double GetDailyWinrate()
{
    if(g_daily_operations == 0)
        return 0.0;
    
    return ((double)g_daily_wins / g_daily_operations) * 100.0;
}

/**
 * Obtém próximo valor de martingale
 */
double GetNextMartingaleValue()
{
    int next_level = g_current_martingale_level;
    if(g_martingale_sequence_active && next_level < g_config.financial.max_gale_levels - 1)
    {
        next_level++;
    }
    
    if(next_level >= 10)
        return g_config.financial.entry_value;
    
    return g_martingale_sim.entry_values[next_level];
}

/**
 * Obtém informações de operação formatadas
 */
string GetOperationSummary()
{
    string summary = "";
    summary += "Total: " + IntegerToString(g_total_operations);
    summary += " | Vitórias: " + IntegerToString(g_total_wins);
    summary += " | Perdas: " + IntegerToString(g_total_losses);
    summary += " | WinRate: " + FormatPercentage(GetCurrentWinrate());
    summary += " | Lucro: " + FormatCurrency(g_total_profit);
    summary += " | Saldo: " + FormatCurrency(g_current_balance);
    
    return summary;
}

#endif // ANALYSIS_FINANCIAL_CORE_MQH

