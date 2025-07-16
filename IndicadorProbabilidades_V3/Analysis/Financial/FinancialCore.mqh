//+------------------------------------------------------------------+
//|                              Analysis/Financial/FinancialCore.mqh |
//|                                    Indicador de Probabilidades V3 |
//|                              Sistema de Análise Financeira Core |
//+------------------------------------------------------------------+

#ifndef ANALYSIS_FINANCIAL_CORE_MQH
#define ANALYSIS_FINANCIAL_CORE_MQH

#include "../../Core/Types.mqh"
#include "../../Core/Defines.mqh"
#include "../../Core/Globals.mqh"

//+------------------------------------------------------------------+
//| Estruturas Específicas de Análise Financeira                   |
//+------------------------------------------------------------------+

/**
 * Estrutura de configuração de análise financeira
 */
struct FinancialAnalysisConfig
{
    double initial_balance;            // Saldo inicial
    double entry_value;                // Valor de entrada padrão
    double payout_percentage;          // Percentual de payout
    double martingale_factor;          // Fator do martingale
    int max_martingale_levels;         // Máximo de níveis de martingale
    bool enable_compound_interest;     // Habilitar juros compostos
    double compound_percentage;        // Percentual para juros compostos
    bool enable_stop_loss;             // Habilitar stop loss
    double stop_loss_amount;           // Valor do stop loss
    bool enable_stop_win;              // Habilitar stop win
    double stop_win_amount;            // Valor do stop win
    double daily_goal;                 // Meta diária
    double max_daily_loss;             // Perda máxima diária
    int max_operations_per_day;        // Máximo de operações por dia
    bool enable_risk_management;       // Habilitar gestão de risco
    double max_risk_percentage;        // Percentual máximo de risco
};

/**
 * Estrutura de operação financeira
 */
struct FinancialOperation
{
    datetime timestamp;                // Timestamp da operação
    PatternType pattern_type;          // Tipo de padrão
    bool is_call;                      // CALL ou PUT
    double entry_value;                // Valor de entrada
    double payout_value;               // Valor do payout
    OperationResult result;            // Resultado da operação
    int martingale_level;              // Nível de martingale
    double profit_loss;                // Lucro/Prejuízo
    double balance_before;             // Saldo antes
    double balance_after;              // Saldo depois
    double roi_operation;              // ROI da operação
    string notes;                      // Observações
};

/**
 * Estrutura de estatísticas financeiras
 */
struct FinancialStatistics
{
    datetime period_start;             // Início do período
    datetime period_end;               // Fim do período
    double initial_balance;            // Saldo inicial
    double final_balance;              // Saldo final
    double total_invested;             // Total investido
    double total_profit;               // Lucro total
    double total_loss;                 // Perda total
    double net_profit;                 // Lucro líquido
    double roi_percentage;             // ROI em percentual
    double roi_annualized;             // ROI anualizado
    int total_operations;              // Total de operações
    int winning_operations;            // Operações vencedoras
    int losing_operations;             // Operações perdedoras
    double win_rate;                   // Taxa de vitória
    double average_win;                // Vitória média
    double average_loss;               // Perda média
    double profit_factor;              // Fator de lucro
    double sharpe_ratio;               // Índice Sharpe
    double max_drawdown;               // Máximo drawdown
    double max_drawdown_percentage;    // Máximo drawdown em %
    double recovery_factor;            // Fator de recuperação
    double calmar_ratio;               // Índice Calmar
    int max_consecutive_wins;          // Máximo de vitórias consecutivas
    int max_consecutive_losses;        // Máximo de perdas consecutivas
    int current_consecutive_wins;      // Vitórias consecutivas atuais
    int current_consecutive_losses;    // Perdas consecutivas atuais
    double largest_win;                // Maior vitória
    double largest_loss;               // Maior perda
    double average_operation_time;     // Tempo médio de operação
    double volatility;                 // Volatilidade dos retornos
};

/**
 * Estrutura de simulação de martingale
 */
struct MartingaleSimulation
{
    double initial_value;              // Valor inicial
    double martingale_factor;          // Fator de multiplicação
    int max_levels;                    // Máximo de níveis
    double payout_percentage;          // Percentual de payout
    double total_investment[];         // Investimento total por nível
    double potential_profit[];         // Lucro potencial por nível
    double break_even_rate[];          // Taxa de break-even por nível
    double risk_percentage[];          // Percentual de risco por nível
    double expected_value[];           // Valor esperado por nível
};

/**
 * Estrutura de análise de risco
 */
struct RiskAnalysis
{
    double var_95;                     // Value at Risk 95%
    double var_99;                     // Value at Risk 99%
    double expected_shortfall;         // Expected Shortfall
    double beta;                       // Beta do portfólio
    double correlation_market;         // Correlação com mercado
    double tracking_error;             // Erro de rastreamento
    double information_ratio;          // Índice de informação
    double sortino_ratio;              // Índice Sortino
    double omega_ratio;                // Índice Omega
    double tail_ratio;                 // Índice de cauda
    double skewness;                   // Assimetria
    double kurtosis;                   // Curtose
    double downside_deviation;         // Desvio negativo
};

//+------------------------------------------------------------------+
//| Variáveis Globais de Análise Financeira                         |
//+------------------------------------------------------------------+
FinancialAnalysisConfig g_financial_config;  // Configuração financeira
FinancialOperation g_operations_log[];       // Log de operações
FinancialStatistics g_daily_stats;           // Estatísticas diárias
FinancialStatistics g_weekly_stats;          // Estatísticas semanais
FinancialStatistics g_monthly_stats;         // Estatísticas mensais
FinancialStatistics g_yearly_stats;          // Estatísticas anuais
MartingaleSimulation g_martingale_sim;       // Simulação de martingale
RiskAnalysis g_risk_analysis;               // Análise de risco
double g_balance_history[];                  // Histórico de saldo
datetime g_balance_timestamps[];             // Timestamps do histórico
double g_daily_returns[];                   // Retornos diários
int g_current_martingale_level = 0;         // Nível atual de martingale
bool g_stop_loss_active = false;            // Stop loss ativo
bool g_stop_win_active = false;             // Stop win ativo
double g_session_high_balance = 0.0;        // Maior saldo da sessão
double g_session_low_balance = 0.0;         // Menor saldo da sessão

//+------------------------------------------------------------------+
//| Funções de Inicialização                                        |
//+------------------------------------------------------------------+

/**
 * Inicializa sistema de análise financeira
 * @return true se inicializado com sucesso
 */
bool InitializeFinancialAnalysis()
{
    // Carrega configuração
    LoadFinancialConfiguration();
    
    // Inicializa arrays
    ArrayResize(g_operations_log, 0);
    ArrayResize(g_balance_history, 0);
    ArrayResize(g_balance_timestamps, 0);
    ArrayResize(g_daily_returns, 0);
    
    // Inicializa estatísticas
    InitializeStatistics();
    
    // Inicializa simulação de martingale
    InitializeMartingaleSimulation();
    
    // Define saldo inicial
    g_current_balance = g_financial_config.initial_balance;
    g_starting_balance = g_financial_config.initial_balance;
    g_session_high_balance = g_current_balance;
    g_session_low_balance = g_current_balance;
    
    // Adiciona primeiro ponto no histórico
    AddBalanceToHistory(g_current_balance);
    
    Print("Sistema de análise financeira inicializado");
    return true;
}

/**
 * Carrega configuração financeira
 */
void LoadFinancialConfiguration()
{
    g_financial_config.initial_balance = g_config.financial.entry_value * 100; // 100x valor de entrada
    g_financial_config.entry_value = g_config.financial.entry_value;
    g_financial_config.payout_percentage = g_config.financial.payout;
    g_financial_config.martingale_factor = g_config.financial.martingale_factor;
    g_financial_config.max_martingale_levels = g_config.financial.max_gale_levels;
    g_financial_config.enable_compound_interest = false;
    g_financial_config.compound_percentage = 5.0;
    g_financial_config.enable_stop_loss = g_config.financial.enable_stop_loss;
    g_financial_config.stop_loss_amount = g_config.financial.stop_loss_value;
    g_financial_config.enable_stop_win = g_config.financial.enable_stop_win;
    g_financial_config.stop_win_amount = g_config.financial.stop_win_value;
    g_financial_config.daily_goal = g_config.financial.daily_goal;
    g_financial_config.max_daily_loss = g_config.financial.daily_limit;
    g_financial_config.max_operations_per_day = 100;
    g_financial_config.enable_risk_management = true;
    g_financial_config.max_risk_percentage = 10.0;
}

/**
 * Inicializa estruturas de estatísticas
 */
void InitializeStatistics()
{
    datetime current_time = TimeCurrent();
    
    // Estatísticas diárias
    g_daily_stats.period_start = StringToTime(TimeToString(current_time, TIME_DATE));
    g_daily_stats.period_end = g_daily_stats.period_start + 86400; // +24 horas
    g_daily_stats.initial_balance = g_financial_config.initial_balance;
    g_daily_stats.final_balance = g_financial_config.initial_balance;
    
    // Estatísticas semanais
    MqlDateTime dt;
    TimeToStruct(current_time, dt);
    dt.day_of_week = 1; // Segunda-feira
    dt.hour = 0;
    dt.min = 0;
    dt.sec = 0;
    g_weekly_stats.period_start = StructToTime(dt);
    g_weekly_stats.period_end = g_weekly_stats.period_start + 604800; // +7 dias
    g_weekly_stats.initial_balance = g_financial_config.initial_balance;
    
    // Estatísticas mensais
    dt.day = 1;
    g_monthly_stats.period_start = StructToTime(dt);
    dt.mon++;
    if(dt.mon > 12) { dt.mon = 1; dt.year++; }
    g_monthly_stats.period_end = StructToTime(dt);
    g_monthly_stats.initial_balance = g_financial_config.initial_balance;
    
    // Estatísticas anuais
    TimeToStruct(current_time, dt);
    dt.mon = 1;
    dt.day = 1;
    dt.hour = 0;
    dt.min = 0;
    dt.sec = 0;
    g_yearly_stats.period_start = StructToTime(dt);
    dt.year++;
    g_yearly_stats.period_end = StructToTime(dt);
    g_yearly_stats.initial_balance = g_financial_config.initial_balance;
}

/**
 * Inicializa simulação de martingale
 */
void InitializeMartingaleSimulation()
{
    g_martingale_sim.initial_value = g_financial_config.entry_value;
    g_martingale_sim.martingale_factor = g_financial_config.martingale_factor;
    g_martingale_sim.max_levels = g_financial_config.max_martingale_levels;
    g_martingale_sim.payout_percentage = g_financial_config.payout_percentage;
    
    int max_levels = g_martingale_sim.max_levels + 1; // +1 para incluir nível 0
    
    ArrayResize(g_martingale_sim.total_investment, max_levels);
    ArrayResize(g_martingale_sim.potential_profit, max_levels);
    ArrayResize(g_martingale_sim.break_even_rate, max_levels);
    ArrayResize(g_martingale_sim.risk_percentage, max_levels);
    ArrayResize(g_martingale_sim.expected_value, max_levels);
    
    // Calcula valores para cada nível
    double cumulative_investment = 0.0;
    
    for(int level = 0; level < max_levels; level++)
    {
        double entry_value = g_martingale_sim.initial_value * MathPow(g_martingale_sim.martingale_factor, level);
        cumulative_investment += entry_value;
        
        g_martingale_sim.total_investment[level] = cumulative_investment;
        g_martingale_sim.potential_profit[level] = entry_value * g_martingale_sim.payout_percentage;
        
        // Taxa de break-even (quantas vitórias são necessárias para cobrir as perdas)
        if(g_martingale_sim.potential_profit[level] > 0)
        {
            g_martingale_sim.break_even_rate[level] = cumulative_investment / g_martingale_sim.potential_profit[level];
        }
        
        // Percentual de risco em relação ao saldo
        if(g_current_balance > 0)
        {
            g_martingale_sim.risk_percentage[level] = (cumulative_investment / g_current_balance) * 100.0;
        }
        
        // Valor esperado (considerando 50% de chance de vitória)
        double win_probability = 0.5;
        double loss_probability = 1.0 - win_probability;
        g_martingale_sim.expected_value[level] = (win_probability * g_martingale_sim.potential_profit[level]) - 
                                               (loss_probability * cumulative_investment);
    }
}

//+------------------------------------------------------------------+
//| Funções de Processamento de Operações                           |
//+------------------------------------------------------------------+

/**
 * Processa nova operação financeira
 * @param signal_info Informações do sinal
 * @param result Resultado da operação
 * @return true se processado com sucesso
 */
bool ProcessFinancialOperation(const SignalInfo &signal_info, OperationResult result)
{
    // Cria estrutura da operação
    FinancialOperation operation;
    operation.timestamp = TimeCurrent();
    operation.pattern_type = signal_info.pattern_type;
    operation.is_call = signal_info.is_call;
    operation.result = result;
    operation.martingale_level = g_current_martingale_level;
    operation.balance_before = g_current_balance;
    
    // Calcula valor de entrada baseado no nível de martingale
    operation.entry_value = CalculateEntryValue(g_current_martingale_level);
    
    // Calcula resultado financeiro
    CalculateOperationResult(operation);
    
    // Atualiza saldo
    g_current_balance = operation.balance_after;
    
    // Atualiza histórico de saldo
    AddBalanceToHistory(g_current_balance);
    
    // Atualiza estatísticas globais
    UpdateGlobalCounters(operation);
    
    // Atualiza estatísticas detalhadas
    UpdateDetailedStatistics(operation);
    
    // Verifica stop loss/win
    CheckStopConditions();
    
    // Atualiza nível de martingale
    UpdateMartingaleLevel(result);
    
    // Adiciona ao log de operações
    AddOperationToLog(operation);
    
    // Atualiza análise de risco
    UpdateRiskAnalysis();
    
    return true;
}

/**
 * Calcula valor de entrada baseado no nível de martingale
 * @param martingale_level Nível de martingale
 * @return Valor de entrada calculado
 */
double CalculateEntryValue(int martingale_level)
{
    if(martingale_level < 0 || martingale_level > g_financial_config.max_martingale_levels)
    {
        martingale_level = 0;
    }
    
    double entry_value = g_financial_config.entry_value * MathPow(g_financial_config.martingale_factor, martingale_level);
    
    // Verifica se não excede o saldo disponível
    if(entry_value > g_current_balance * 0.5) // Máximo 50% do saldo
    {
        entry_value = g_current_balance * 0.1; // Reduz para 10% do saldo
    }
    
    return entry_value;
}

/**
 * Calcula resultado da operação
 * @param operation Estrutura da operação a ser preenchida
 */
void CalculateOperationResult(FinancialOperation &operation)
{
    switch(operation.result)
    {
        case RESULT_WIN:
        case RESULT_GALE1_WIN:
        case RESULT_GALE2_WIN:
            // Vitória - recebe payout
            operation.payout_value = operation.entry_value * g_financial_config.payout_percentage;
            operation.profit_loss = operation.payout_value;
            operation.balance_after = operation.balance_before + operation.profit_loss;
            break;
            
        case RESULT_LOSS:
        case RESULT_GALE_LOSS:
            // Perda - perde valor investido
            operation.payout_value = 0.0;
            operation.profit_loss = -operation.entry_value;
            operation.balance_after = operation.balance_before + operation.profit_loss;
            break;
            
        default:
            // Resultado desconhecido - sem alteração
            operation.payout_value = 0.0;
            operation.profit_loss = 0.0;
            operation.balance_after = operation.balance_before;
            break;
    }
    
    // Calcula ROI da operação
    if(operation.entry_value > 0)
    {
        operation.roi_operation = (operation.profit_loss / operation.entry_value) * 100.0;
    }
    
    // Adiciona observações
    operation.notes = StringFormat("Nível: %d | ROI: %.2f%% | Saldo: %.2f", 
                                  operation.martingale_level,
                                  operation.roi_operation,
                                  operation.balance_after);
}

/**
 * Atualiza contadores globais
 * @param operation Operação processada
 */
void UpdateGlobalCounters(const FinancialOperation &operation)
{
    g_total_operations_today++;
    
    switch(operation.result)
    {
        case RESULT_WIN:
        case RESULT_GALE1_WIN:
        case RESULT_GALE2_WIN:
            g_total_wins_today++;
            break;
            
        case RESULT_LOSS:
        case RESULT_GALE_LOSS:
            g_total_losses_today++;
            break;
    }
    
    g_daily_profit += operation.profit_loss;
    
    // Recalcula winrate
    if(g_total_operations_today > 0)
    {
        g_daily_winrate = ((double)g_total_wins_today / g_total_operations_today) * 100.0;
    }
    
    // Atualiza máximos e mínimos da sessão
    if(g_current_balance > g_session_high_balance)
    {
        g_session_high_balance = g_current_balance;
    }
    
    if(g_current_balance < g_session_low_balance)
    {
        g_session_low_balance = g_current_balance;
    }
}

/**
 * Atualiza estatísticas detalhadas
 * @param operation Operação processada
 */
void UpdateDetailedStatistics(const FinancialOperation &operation)
{
    // Atualiza estatísticas diárias
    UpdatePeriodStatistics(g_daily_stats, operation);
    
    // Atualiza estatísticas semanais
    UpdatePeriodStatistics(g_weekly_stats, operation);
    
    // Atualiza estatísticas mensais
    UpdatePeriodStatistics(g_monthly_stats, operation);
    
    // Atualiza estatísticas anuais
    UpdatePeriodStatistics(g_yearly_stats, operation);
}

/**
 * Atualiza estatísticas de um período específico
 * @param stats Estrutura de estatísticas
 * @param operation Operação processada
 */
void UpdatePeriodStatistics(FinancialStatistics &stats, const FinancialOperation &operation)
{
    // Verifica se operação está no período
    if(operation.timestamp < stats.period_start || operation.timestamp >= stats.period_end)
    {
        return;
    }
    
    // Atualiza contadores básicos
    stats.total_operations++;
    stats.total_invested += operation.entry_value;
    
    if(operation.profit_loss > 0)
    {
        stats.winning_operations++;
        stats.total_profit += operation.profit_loss;
        
        // Atualiza maior vitória
        if(operation.profit_loss > stats.largest_win)
        {
            stats.largest_win = operation.profit_loss;
        }
        
        // Atualiza sequência de vitórias
        stats.current_consecutive_wins++;
        stats.current_consecutive_losses = 0;
        
        if(stats.current_consecutive_wins > stats.max_consecutive_wins)
        {
            stats.max_consecutive_wins = stats.current_consecutive_wins;
        }
    }
    else if(operation.profit_loss < 0)
    {
        stats.losing_operations++;
        stats.total_loss += MathAbs(operation.profit_loss);
        
        // Atualiza maior perda
        if(MathAbs(operation.profit_loss) > stats.largest_loss)
        {
            stats.largest_loss = MathAbs(operation.profit_loss);
        }
        
        // Atualiza sequência de perdas
        stats.current_consecutive_losses++;
        stats.current_consecutive_wins = 0;
        
        if(stats.current_consecutive_losses > stats.max_consecutive_losses)
        {
            stats.max_consecutive_losses = stats.current_consecutive_losses;
        }
    }
    
    // Atualiza saldo final
    stats.final_balance = operation.balance_after;
    
    // Calcula métricas derivadas
    CalculateDerivedMetrics(stats);
}

/**
 * Calcula métricas derivadas das estatísticas
 * @param stats Estrutura de estatísticas
 */
void CalculateDerivedMetrics(FinancialStatistics &stats)
{
    // Lucro líquido
    stats.net_profit = stats.total_profit - stats.total_loss;
    
    // ROI
    if(stats.initial_balance > 0)
    {
        stats.roi_percentage = ((stats.final_balance - stats.initial_balance) / stats.initial_balance) * 100.0;
    }
    
    // Win rate
    if(stats.total_operations > 0)
    {
        stats.win_rate = ((double)stats.winning_operations / stats.total_operations) * 100.0;
    }
    
    // Vitória e perda médias
    if(stats.winning_operations > 0)
    {
        stats.average_win = stats.total_profit / stats.winning_operations;
    }
    
    if(stats.losing_operations > 0)
    {
        stats.average_loss = stats.total_loss / stats.losing_operations;
    }
    
    // Fator de lucro
    if(stats.total_loss > 0)
    {
        stats.profit_factor = stats.total_profit / stats.total_loss;
    }
    
    // Máximo drawdown
    CalculateMaxDrawdown(stats);
    
    // Fator de recuperação
    if(stats.max_drawdown > 0)
    {
        stats.recovery_factor = stats.net_profit / stats.max_drawdown;
    }
}

/**
 * Calcula máximo drawdown
 * @param stats Estrutura de estatísticas
 */
void CalculateMaxDrawdown(FinancialStatistics &stats)
{
    if(ArraySize(g_balance_history) < 2)
    {
        return;
    }
    
    double peak = g_balance_history[0];
    double max_dd = 0.0;
    
    for(int i = 1; i < ArraySize(g_balance_history); i++)
    {
        if(g_balance_history[i] > peak)
        {
            peak = g_balance_history[i];
        }
        
        double drawdown = peak - g_balance_history[i];
        if(drawdown > max_dd)
        {
            max_dd = drawdown;
        }
    }
    
    stats.max_drawdown = max_dd;
    
    if(peak > 0)
    {
        stats.max_drawdown_percentage = (max_dd / peak) * 100.0;
    }
}

/**
 * Verifica condições de stop loss/win
 */
void CheckStopConditions()
{
    // Verifica stop loss
    if(g_financial_config.enable_stop_loss && !g_stop_loss_active)
    {
        double loss_amount = g_starting_balance - g_current_balance;
        if(loss_amount >= g_financial_config.stop_loss_amount)
        {
            g_stop_loss_active = true;
            Print("STOP LOSS ATIVADO - Perda: ", FormatCurrency(loss_amount));
        }
    }
    
    // Verifica stop win
    if(g_financial_config.enable_stop_win && !g_stop_win_active)
    {
        double profit_amount = g_current_balance - g_starting_balance;
        if(profit_amount >= g_financial_config.stop_win_amount)
        {
            g_stop_win_active = true;
            Print("STOP WIN ATIVADO - Lucro: ", FormatCurrency(profit_amount));
        }
    }
    
    // Verifica meta diária
    if(g_financial_config.daily_goal > 0)
    {
        double daily_profit = g_current_balance - g_starting_balance;
        if(daily_profit >= g_financial_config.daily_goal)
        {
            Print("META DIÁRIA ATINGIDA - Lucro: ", FormatCurrency(daily_profit));
        }
    }
    
    // Verifica perda máxima diária
    if(g_financial_config.max_daily_loss > 0)
    {
        double daily_loss = g_starting_balance - g_current_balance;
        if(daily_loss >= g_financial_config.max_daily_loss)
        {
            Print("PERDA MÁXIMA DIÁRIA ATINGIDA - Perda: ", FormatCurrency(daily_loss));
        }
    }
}

/**
 * Atualiza nível de martingale
 * @param result Resultado da operação
 */
void UpdateMartingaleLevel(OperationResult result)
{
    switch(result)
    {
        case RESULT_WIN:
        case RESULT_GALE1_WIN:
        case RESULT_GALE2_WIN:
            // Vitória - reset martingale
            g_current_martingale_level = 0;
            break;
            
        case RESULT_LOSS:
            // Perda - aumenta nível se habilitado
            if(g_financial_config.enable_risk_management && g_current_martingale_level < g_financial_config.max_martingale_levels)
            {
                g_current_martingale_level++;
            }
            break;
            
        case RESULT_GALE_LOSS:
            // Perda após gales - reset martingale
            g_current_martingale_level = 0;
            break;
    }
}

/**
 * Adiciona operação ao log
 * @param operation Operação a ser adicionada
 */
void AddOperationToLog(const FinancialOperation &operation)
{
    int size = ArraySize(g_operations_log);
    ArrayResize(g_operations_log, size + 1);
    g_operations_log[size] = operation;
    
    // Limita tamanho do log
    if(size > 1000)
    {
        // Remove operações mais antigas
        for(int i = 0; i < size - 500; i++)
        {
            g_operations_log[i] = g_operations_log[i + 500];
        }
        ArrayResize(g_operations_log, 500);
    }
}

/**
 * Adiciona saldo ao histórico
 * @param balance Saldo a ser adicionado
 */
void AddBalanceToHistory(double balance)
{
    int size = ArraySize(g_balance_history);
    ArrayResize(g_balance_history, size + 1);
    ArrayResize(g_balance_timestamps, size + 1);
    
    g_balance_history[size] = balance;
    g_balance_timestamps[size] = TimeCurrent();
    
    // Limita tamanho do histórico
    if(size > 10000)
    {
        // Remove dados mais antigos
        for(int i = 0; i < size - 5000; i++)
        {
            g_balance_history[i] = g_balance_history[i + 5000];
            g_balance_timestamps[i] = g_balance_timestamps[i + 5000];
        }
        ArrayResize(g_balance_history, 5000);
        ArrayResize(g_balance_timestamps, 5000);
    }
}

/**
 * Atualiza análise de risco
 */
void UpdateRiskAnalysis()
{
    if(ArraySize(g_daily_returns) < 30) // Precisa de pelo menos 30 observações
    {
        return;
    }
    
    // Calcula retornos diários
    CalculateDailyReturns();
    
    // Calcula VaR
    CalculateValueAtRisk();
    
    // Calcula outras métricas de risco
    CalculateRiskMetrics();
}

/**
 * Calcula retornos diários
 */
void CalculateDailyReturns()
{
    if(ArraySize(g_balance_history) < 2)
    {
        return;
    }
    
    ArrayResize(g_daily_returns, 0);
    
    for(int i = 1; i < ArraySize(g_balance_history); i++)
    {
        if(g_balance_history[i-1] > 0)
        {
            double return_rate = (g_balance_history[i] - g_balance_history[i-1]) / g_balance_history[i-1];
            
            int size = ArraySize(g_daily_returns);
            ArrayResize(g_daily_returns, size + 1);
            g_daily_returns[size] = return_rate;
        }
    }
}

/**
 * Calcula Value at Risk
 */
void CalculateValueAtRisk()
{
    if(ArraySize(g_daily_returns) < 30)
    {
        return;
    }
    
    // Ordena retornos
    double sorted_returns[];
    ArrayCopy(sorted_returns, g_daily_returns);
    ArraySort(sorted_returns);
    
    int size = ArraySize(sorted_returns);
    
    // VaR 95% (5º percentil)
    int index_95 = (int)(size * 0.05);
    if(index_95 < size)
    {
        g_risk_analysis.var_95 = sorted_returns[index_95] * g_current_balance;
    }
    
    // VaR 99% (1º percentil)
    int index_99 = (int)(size * 0.01);
    if(index_99 < size)
    {
        g_risk_analysis.var_99 = sorted_returns[index_99] * g_current_balance;
    }
    
    // Expected Shortfall (média das perdas além do VaR 95%)
    double sum_tail = 0.0;
    int count_tail = 0;
    
    for(int i = 0; i <= index_95; i++)
    {
        sum_tail += sorted_returns[i];
        count_tail++;
    }
    
    if(count_tail > 0)
    {
        g_risk_analysis.expected_shortfall = (sum_tail / count_tail) * g_current_balance;
    }
}

/**
 * Calcula métricas de risco
 */
void CalculateRiskMetrics()
{
    if(ArraySize(g_daily_returns) < 30)
    {
        return;
    }
    
    // Calcula média e desvio padrão
    double mean_return = 0.0;
    double sum_returns = 0.0;
    
    for(int i = 0; i < ArraySize(g_daily_returns); i++)
    {
        sum_returns += g_daily_returns[i];
    }
    
    mean_return = sum_returns / ArraySize(g_daily_returns);
    
    double sum_squared_diff = 0.0;
    double sum_negative_squared_diff = 0.0;
    int negative_count = 0;
    
    for(int i = 0; i < ArraySize(g_daily_returns); i++)
    {
        double diff = g_daily_returns[i] - mean_return;
        sum_squared_diff += diff * diff;
        
        if(g_daily_returns[i] < 0)
        {
            sum_negative_squared_diff += g_daily_returns[i] * g_daily_returns[i];
            negative_count++;
        }
    }
    
    // Volatilidade (desvio padrão)
    g_daily_stats.volatility = MathSqrt(sum_squared_diff / (ArraySize(g_daily_returns) - 1));
    
    // Desvio negativo (downside deviation)
    if(negative_count > 0)
    {
        g_risk_analysis.downside_deviation = MathSqrt(sum_negative_squared_diff / negative_count);
    }
    
    // Índice Sharpe (assumindo taxa livre de risco = 0)
    if(g_daily_stats.volatility > 0)
    {
        g_daily_stats.sharpe_ratio = mean_return / g_daily_stats.volatility;
    }
    
    // Índice Sortino
    if(g_risk_analysis.downside_deviation > 0)
    {
        g_risk_analysis.sortino_ratio = mean_return / g_risk_analysis.downside_deviation;
    }
    
    // Calcula assimetria e curtose
    CalculateSkewnessKurtosis();
}

/**
 * Calcula assimetria e curtose
 */
void CalculateSkewnessKurtosis()
{
    if(ArraySize(g_daily_returns) < 30)
    {
        return;
    }
    
    // Calcula média
    double mean_return = 0.0;
    for(int i = 0; i < ArraySize(g_daily_returns); i++)
    {
        mean_return += g_daily_returns[i];
    }
    mean_return /= ArraySize(g_daily_returns);
    
    // Calcula momentos
    double sum_cubed = 0.0;
    double sum_fourth = 0.0;
    double sum_squared = 0.0;
    
    for(int i = 0; i < ArraySize(g_daily_returns); i++)
    {
        double diff = g_daily_returns[i] - mean_return;
        double diff_squared = diff * diff;
        
        sum_squared += diff_squared;
        sum_cubed += diff_squared * diff;
        sum_fourth += diff_squared * diff_squared;
    }
    
    int n = ArraySize(g_daily_returns);
    double variance = sum_squared / (n - 1);
    double std_dev = MathSqrt(variance);
    
    if(std_dev > 0)
    {
        // Assimetria (skewness)
        g_risk_analysis.skewness = (sum_cubed / n) / MathPow(std_dev, 3);
        
        // Curtose (kurtosis)
        g_risk_analysis.kurtosis = (sum_fourth / n) / MathPow(std_dev, 4) - 3.0;
    }
}

//+------------------------------------------------------------------+
//| Funções de Consulta e Relatórios                                |
//+------------------------------------------------------------------+

/**
 * Obtém estatísticas financeiras formatadas
 * @return String com estatísticas formatadas
 */
string GetFinancialStatistics()
{
    string stats = "";
    
    stats += "=== ANÁLISE FINANCEIRA ===\n";
    stats += "Saldo Atual: " + FormatCurrency(g_current_balance) + "\n";
    stats += "Saldo Inicial: " + FormatCurrency(g_starting_balance) + "\n";
    stats += "Lucro/Prejuízo: " + FormatCurrency(g_current_balance - g_starting_balance) + "\n";
    
    double roi = 0.0;
    if(g_starting_balance > 0)
    {
        roi = ((g_current_balance - g_starting_balance) / g_starting_balance) * 100.0;
    }
    stats += "ROI: " + DoubleToString(roi, 2) + "%\n";
    
    stats += "\n=== OPERAÇÕES HOJE ===\n";
    stats += "Total: " + IntegerToString(g_total_operations_today) + "\n";
    stats += "Vitórias: " + IntegerToString(g_total_wins_today) + "\n";
    stats += "Perdas: " + IntegerToString(g_total_losses_today) + "\n";
    stats += "WinRate: " + DoubleToString(g_daily_winrate, 1) + "%\n";
    stats += "Lucro Diário: " + FormatCurrency(g_daily_profit) + "\n";
    
    stats += "\n=== MARTINGALE ===\n";
    stats += "Nível Atual: " + IntegerToString(g_current_martingale_level) + "\n";
    stats += "Próximo Valor: " + FormatCurrency(CalculateEntryValue(g_current_martingale_level)) + "\n";
    
    if(g_current_martingale_level < ArraySize(g_martingale_sim.total_investment))
    {
        stats += "Investimento Total: " + FormatCurrency(g_martingale_sim.total_investment[g_current_martingale_level]) + "\n";
        stats += "Lucro Potencial: " + FormatCurrency(g_martingale_sim.potential_profit[g_current_martingale_level]) + "\n";
    }
    
    stats += "\n=== RISCO ===\n";
    stats += "Stop Loss: " + (g_stop_loss_active ? "ATIVO" : "Inativo") + "\n";
    stats += "Stop Win: " + (g_stop_win_active ? "ATIVO" : "Inativo") + "\n";
    
    if(ArraySize(g_daily_returns) >= 30)
    {
        stats += "VaR 95%: " + FormatCurrency(g_risk_analysis.var_95) + "\n";
        stats += "Volatilidade: " + DoubleToString(g_daily_stats.volatility * 100, 2) + "%\n";
        stats += "Sharpe Ratio: " + DoubleToString(g_daily_stats.sharpe_ratio, 3) + "\n";
    }
    
    return stats;
}

/**
 * Obtém informações do martingale
 * @return String com informações do martingale
 */
string GetMartingaleInfo()
{
    string info = "=== SIMULAÇÃO MARTINGALE ===\n";
    
    for(int level = 0; level <= g_financial_config.max_martingale_levels && level < ArraySize(g_martingale_sim.total_investment); level++)
    {
        info += StringFormat("Nível %d: Valor=%.2f | Total=%.2f | Lucro=%.2f | Risco=%.1f%%\n",
                           level,
                           CalculateEntryValue(level),
                           g_martingale_sim.total_investment[level],
                           g_martingale_sim.potential_profit[level],
                           g_martingale_sim.risk_percentage[level]);
    }
    
    return info;
}

/**
 * Verifica se pode operar (não atingiu stops)
 * @return true se pode operar
 */
bool CanOperate()
{
    if(g_stop_loss_active || g_stop_win_active)
    {
        return false;
    }
    
    if(g_financial_config.max_operations_per_day > 0 && g_total_operations_today >= g_financial_config.max_operations_per_day)
    {
        return false;
    }
    
    return true;
}

/**
 * Reset estatísticas diárias
 */
void ResetDailyStatistics()
{
    g_total_operations_today = 0;
    g_total_wins_today = 0;
    g_total_losses_today = 0;
    g_daily_profit = 0.0;
    g_daily_winrate = 0.0;
    g_current_martingale_level = 0;
    g_stop_loss_active = false;
    g_stop_win_active = false;
    g_starting_balance = g_current_balance;
    g_session_high_balance = g_current_balance;
    g_session_low_balance = g_current_balance;
    
    // Reinicializa estatísticas diárias
    g_daily_stats.period_start = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
    g_daily_stats.period_end = g_daily_stats.period_start + 86400;
    g_daily_stats.initial_balance = g_current_balance;
    g_daily_stats.final_balance = g_current_balance;
    g_daily_stats.total_operations = 0;
    g_daily_stats.winning_operations = 0;
    g_daily_stats.losing_operations = 0;
    g_daily_stats.total_profit = 0.0;
    g_daily_stats.total_loss = 0.0;
    g_daily_stats.net_profit = 0.0;
    
    Print("Estatísticas diárias resetadas");
}

#endif // ANALYSIS_FINANCIAL_CORE_MQH

