//+------------------------------------------------------------------+
//|                                    Logic/PatternEngine.mqh |
//|                        Copyright 2024, Quant Genius (Refactoring) |
//|                                      https://www.google.com |
//|                                    VERSÃO CORRIGIDA v2.0        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quant Genius (Refactoring)"
#property link      "https://www.google.com"

#ifndef LOGIC_PATTERNENGINE_MQH
#define LOGIC_PATTERNENGINE_MQH

#include "../Core/Defines.mqh"
#include "../Core/Globals.mqh"
#include "../Core/Utilities.mqh"
#include "../Core/Logger.mqh"

// ==================================================================
// MOTOR DE DETECÇÃO DE PADRÕES CORRIGIDO - VERSÃO 2.0
// ==================================================================

//+------------------------------------------------------------------+
//| CORREÇÃO #1: Padrão MHI1 3C Minoria - Implementação Corrigida   |
//+------------------------------------------------------------------+
bool DetectMHI1_3C_Minoria(int shift, int &direction)
{
    direction = 0;
    
    // Validação de acesso seguro
    if(!ValidateShiftAccess(shift, 3, "DetectMHI1_3C_Minoria"))
        return false;
    
    // Obtém cores das últimas 3 velas de forma segura
    int cor1 = GetVisualCandleColorSafe(shift + 1, "MHI1_3C");
    int cor2 = GetVisualCandleColorSafe(shift + 2, "MHI1_3C");
    int cor3 = GetVisualCandleColorSafe(shift + 3, "MHI1_3C");
    
    // Verifica se todas as cores são válidas
    if(!IsValidPatternCandle(cor1) || !IsValidPatternCandle(cor2) || !IsValidPatternCandle(cor3))
    {
        Logger::Debug("PatternEngine", "MHI1_3C: Cores inválidas detectadas", 
                     "Shift: " + IntegerToString(shift));
        return false;
    }
    
    // Lógica MHI1: Minoria das 3 velas (2 de uma cor, 1 de outra)
    int green_count = 0;
    int red_count = 0;
    
    if(cor1 == VISUAL_GREEN) green_count++;
    else if(cor1 == VISUAL_RED) red_count++;
    
    if(cor2 == VISUAL_GREEN) green_count++;
    else if(cor2 == VISUAL_RED) red_count++;
    
    if(cor3 == VISUAL_GREEN) green_count++;
    else if(cor3 == VISUAL_RED) red_count++;
    
    // Verifica padrão de minoria
    if(green_count == 1 && red_count == 2)
    {
        direction = 1; // CALL (seguir a minoria verde)
        Logger::Debug("PatternEngine", "MHI1_3C CALL detectado", 
                     "Shift: " + IntegerToString(shift) + 
                     " | Cores: " + IntegerToString(cor3) + "," + 
                     IntegerToString(cor2) + "," + IntegerToString(cor1));
        return true;
    }
    else if(red_count == 1 && green_count == 2)
    {
        direction = -1; // PUT (seguir a minoria vermelha)
        Logger::Debug("PatternEngine", "MHI1_3C PUT detectado", 
                     "Shift: " + IntegerToString(shift) + 
                     " | Cores: " + IntegerToString(cor3) + "," + 
                     IntegerToString(cor2) + "," + IntegerToString(cor1));
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #2: Padrão MHI2 3C Confirmado - Implementação Corrigida|
//+------------------------------------------------------------------+
bool DetectMHI2_3C_Confirmado(int shift, int &direction)
{
    direction = 0;
    
    // Validação de acesso seguro
    if(!ValidateShiftAccess(shift, 3, "DetectMHI2_3C_Confirmado"))
        return false;
    
    // Obtém cores das últimas 3 velas
    int cor1 = GetVisualCandleColorSafe(shift + 1, "MHI2_3C");
    int cor2 = GetVisualCandleColorSafe(shift + 2, "MHI2_3C");
    int cor3 = GetVisualCandleColorSafe(shift + 3, "MHI2_3C");
    
    // Verifica validade das cores
    if(!IsValidPatternCandle(cor1) || !IsValidPatternCandle(cor2) || !IsValidPatternCandle(cor3))
        return false;
    
    // MHI2: Confirmação da minoria (minoria + confirmação na vela seguinte)
    // Primeiro detecta se há minoria nas 3 velas
    int green_count = 0;
    int red_count = 0;
    
    if(cor1 == VISUAL_GREEN) green_count++;
    else if(cor1 == VISUAL_RED) red_count++;
    
    if(cor2 == VISUAL_GREEN) green_count++;
    else if(cor2 == VISUAL_RED) red_count++;
    
    if(cor3 == VISUAL_GREEN) green_count++;
    else if(cor3 == VISUAL_RED) red_count++;
    
    // Verifica se há minoria e se a vela atual (shift) confirma
    int cor_atual = GetVisualCandleColorSafe(shift, "MHI2_3C");
    if(!IsValidPatternCandle(cor_atual))
        return false;
    
    if(green_count == 1 && red_count == 2 && cor_atual == VISUAL_GREEN)
    {
        direction = 1; // CALL confirmado
        Logger::Debug("PatternEngine", "MHI2_3C CALL confirmado", 
                     "Shift: " + IntegerToString(shift));
        return true;
    }
    else if(red_count == 1 && green_count == 2 && cor_atual == VISUAL_RED)
    {
        direction = -1; // PUT confirmado
        Logger::Debug("PatternEngine", "MHI2_3C PUT confirmado", 
                     "Shift: " + IntegerToString(shift));
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #3: Padrão MHI3 Unânime - Implementação Corrigida      |
//+------------------------------------------------------------------+
bool DetectMHI3_Unanime_Base(int shift, int &direction)
{
    direction = 0;
    
    // Validação de acesso seguro
    if(!ValidateShiftAccess(shift, 3, "DetectMHI3_Unanime_Base"))
        return false;
    
    // Obtém cores das últimas 3 velas
    int cor1 = GetVisualCandleColorSafe(shift + 1, "MHI3_Unanime");
    int cor2 = GetVisualCandleColorSafe(shift + 2, "MHI3_Unanime");
    int cor3 = GetVisualCandleColorSafe(shift + 3, "MHI3_Unanime");
    
    // Verifica validade das cores
    if(!IsValidPatternCandle(cor1) || !IsValidPatternCandle(cor2) || !IsValidPatternCandle(cor3))
        return false;
    
    // MHI3: Todas as 3 velas da mesma cor (unanimidade)
    if(cor1 == cor2 && cor2 == cor3)
    {
        if(cor1 == VISUAL_GREEN)
        {
            direction = -1; // PUT (contra a unanimidade verde)
            Logger::Debug("PatternEngine", "MHI3_Unanime PUT detectado", 
                         "Shift: " + IntegerToString(shift) + " | 3 verdes");
            return true;
        }
        else if(cor1 == VISUAL_RED)
        {
            direction = 1; // CALL (contra a unanimidade vermelha)
            Logger::Debug("PatternEngine", "MHI3_Unanime CALL detectado", 
                         "Shift: " + IntegerToString(shift) + " | 3 vermelhas");
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #4: Padrão 3 Seguidas - Implementação Corrigida        |
//+------------------------------------------------------------------+
bool DetectThreeInARow_Base(int shift, int &direction)
{
    direction = 0;
    
    // Validação de acesso seguro
    if(!ValidateShiftAccess(shift, 3, "DetectThreeInARow_Base"))
        return false;
    
    // Obtém cores das últimas 3 velas
    int cor1 = GetVisualCandleColorSafe(shift + 1, "ThreeInARow");
    int cor2 = GetVisualCandleColorSafe(shift + 2, "ThreeInARow");
    int cor3 = GetVisualCandleColorSafe(shift + 3, "ThreeInARow");
    
    // Verifica validade das cores
    if(!IsValidPatternCandle(cor1) || !IsValidPatternCandle(cor2) || !IsValidPatternCandle(cor3))
        return false;
    
    // 3 Seguidas: 3 velas da mesma cor, entrada na direção oposta
    if(cor1 == cor2 && cor2 == cor3)
    {
        if(cor1 == VISUAL_GREEN)
        {
            direction = -1; // PUT (contra 3 verdes seguidas)
            Logger::Debug("PatternEngine", "ThreeInARow PUT detectado", 
                         "Shift: " + IntegerToString(shift));
            return true;
        }
        else if(cor1 == VISUAL_RED)
        {
            direction = 1; // CALL (contra 3 vermelhas seguidas)
            Logger::Debug("PatternEngine", "ThreeInARow CALL detectado", 
                         "Shift: " + IntegerToString(shift));
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #5: Padrão 5 Seguidas - Implementação Corrigida        |
//+------------------------------------------------------------------+
bool DetectFiveInARow_Base(int shift, int &direction)
{
    direction = 0;
    
    // Validação de acesso seguro
    if(!ValidateShiftAccess(shift, 5, "DetectFiveInARow_Base"))
        return false;
    
    // Obtém cores das últimas 5 velas
    int cores[5];
    for(int i = 0; i < 5; i++)
    {
        cores[i] = GetVisualCandleColorSafe(shift + i + 1, "FiveInARow");
        if(!IsValidPatternCandle(cores[i]))
            return false;
    }
    
    // Verifica se todas as 5 velas são da mesma cor
    bool all_same = true;
    for(int i = 1; i < 5; i++)
    {
        if(cores[i] != cores[0])
        {
            all_same = false;
            break;
        }
    }
    
    if(all_same)
    {
        if(cores[0] == VISUAL_GREEN)
        {
            direction = -1; // PUT (contra 5 verdes seguidas)
            Logger::Debug("PatternEngine", "FiveInARow PUT detectado", 
                         "Shift: " + IntegerToString(shift));
            return true;
        }
        else if(cores[0] == VISUAL_RED)
        {
            direction = 1; // CALL (contra 5 vermelhas seguidas)
            Logger::Debug("PatternEngine", "FiveInARow CALL detectado", 
                         "Shift: " + IntegerToString(shift));
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #6: Padrão C3 Seguir Cor - Implementação Corrigida     |
//+------------------------------------------------------------------+
bool DetectC3_SeguirCor(int shift, int &direction)
{
    direction = 0;
    
    // Validação de acesso seguro
    if(!ValidateShiftAccess(shift, 3, "DetectC3_SeguirCor"))
        return false;
    
    // Obtém cores das últimas 3 velas
    int cor1 = GetVisualCandleColorSafe(shift + 1, "C3_SeguirCor");
    int cor2 = GetVisualCandleColorSafe(shift + 2, "C3_SeguirCor");
    int cor3 = GetVisualCandleColorSafe(shift + 3, "C3_SeguirCor");
    
    // Verifica validade das cores
    if(!IsValidPatternCandle(cor1) || !IsValidPatternCandle(cor2) || !IsValidPatternCandle(cor3))
        return false;
    
    // C3: Seguir a cor da terceira vela (mais antiga)
    if(cor3 == VISUAL_GREEN)
    {
        direction = 1; // CALL (seguir verde)
        Logger::Debug("PatternEngine", "C3_SeguirCor CALL detectado", 
                     "Shift: " + IntegerToString(shift) + " | Seguindo verde");
        return true;
    }
    else if(cor3 == VISUAL_RED)
    {
        direction = -1; // PUT (seguir vermelho)
        Logger::Debug("PatternEngine", "C3_SeguirCor PUT detectado", 
                     "Shift: " + IntegerToString(shift) + " | Seguindo vermelho");
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #7: Padrão 4 Seguidas - Implementação Corrigida        |
//+------------------------------------------------------------------+
bool DetectFourInARow_Base(int shift, int &direction)
{
    direction = 0;
    
    // Validação de acesso seguro
    if(!ValidateShiftAccess(shift, 4, "DetectFourInARow_Base"))
        return false;
    
    // Obtém cores das últimas 4 velas
    int cores[4];
    for(int i = 0; i < 4; i++)
    {
        cores[i] = GetVisualCandleColorSafe(shift + i + 1, "FourInARow");
        if(!IsValidPatternCandle(cores[i]))
            return false;
    }
    
    // Verifica se todas as 4 velas são da mesma cor
    bool all_same = true;
    for(int i = 1; i < 4; i++)
    {
        if(cores[i] != cores[0])
        {
            all_same = false;
            break;
        }
    }
    
    if(all_same)
    {
        if(cores[0] == VISUAL_GREEN)
        {
            direction = -1; // PUT (contra 4 verdes seguidas)
            Logger::Debug("PatternEngine", "FourInARow PUT detectado", 
                         "Shift: " + IntegerToString(shift));
            return true;
        }
        else if(cores[0] == VISUAL_RED)
        {
            direction = 1; // CALL (contra 4 vermelhas seguidas)
            Logger::Debug("PatternEngine", "FourInARow CALL detectado", 
                         "Shift: " + IntegerToString(shift));
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #8: Padrão Ímpar 3C Maioria - Implementação Corrigida  |
//+------------------------------------------------------------------+
bool DetectImpar_3C_Maioria(int shift, int &direction)
{
    direction = 0;
    
    // Validação de acesso seguro
    if(!ValidateShiftAccess(shift, 3, "DetectImpar_3C_Maioria"))
        return false;
    
    // Obtém cores das últimas 3 velas
    int cor1 = GetVisualCandleColorSafe(shift + 1, "Impar_3C");
    int cor2 = GetVisualCandleColorSafe(shift + 2, "Impar_3C");
    int cor3 = GetVisualCandleColorSafe(shift + 3, "Impar_3C");
    
    // Verifica validade das cores
    if(!IsValidPatternCandle(cor1) || !IsValidPatternCandle(cor2) || !IsValidPatternCandle(cor3))
        return false;
    
    // Ímpar: Maioria das 3 velas (2 de uma cor, 1 de outra)
    int green_count = 0;
    int red_count = 0;
    
    if(cor1 == VISUAL_GREEN) green_count++;
    else if(cor1 == VISUAL_RED) red_count++;
    
    if(cor2 == VISUAL_GREEN) green_count++;
    else if(cor2 == VISUAL_RED) red_count++;
    
    if(cor3 == VISUAL_GREEN) green_count++;
    else if(cor3 == VISUAL_RED) red_count++;
    
    // Segue a maioria
    if(green_count == 2 && red_count == 1)
    {
        direction = 1; // CALL (seguir a maioria verde)
        Logger::Debug("PatternEngine", "Impar_3C CALL detectado", 
                     "Shift: " + IntegerToString(shift) + " | Maioria verde");
        return true;
    }
    else if(red_count == 2 && green_count == 1)
    {
        direction = -1; // PUT (seguir a maioria vermelha)
        Logger::Debug("PatternEngine", "Impar_3C PUT detectado", 
                     "Shift: " + IntegerToString(shift) + " | Maioria vermelha");
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| CORREÇÃO #9: Padrão Melhor de 3 - Implementação Corrigida       |
//+------------------------------------------------------------------+
bool DetectMelhorDe3_Maioria(int shift, int &direction)
{
    direction = 0;
    
    // Validação de acesso seguro
    if(!ValidateShiftAccess(shift, 3, "DetectMelhorDe3_Maioria"))
        return false;
    
    // Obtém cores das últimas 3 velas
    int cor1 = GetVisualCandleColorSafe(shift + 1, "MelhorDe3");
    int cor2 = GetVisualCandleColorSafe(shift + 2, "MelhorDe3");
    int cor3 = GetVisualCandleColorSafe(shift + 3, "MelhorDe3");
    
    // Verifica validade das cores
    if(!IsValidPatternCandle(cor1) || !IsValidPatternCandle(cor2) || !IsValidPatternCandle(cor3))
        return false;
    
    // Melhor de 3: Maioria simples (2 de 3)
    int green_count = 0;
    int red_count = 0;
    
    if(cor1 == VISUAL_GREEN) green_count++;
    else if(cor1 == VISUAL_RED) red_count++;
    
    if(cor2 == VISUAL_GREEN) green_count++;
    else if(cor2 == VISUAL_RED) red_count++;
    
    if(cor3 == VISUAL_GREEN) green_count++;
    else if(cor3 == VISUAL_RED) red_count++;
    
    // Segue a maioria
    if(green_count > red_count)
    {
        direction = 1; // CALL
        Logger::Debug("PatternEngine", "MelhorDe3 CALL detectado", 
                     "Shift: " + IntegerToString(shift) + 
                     " | Verdes: " + IntegerToString(green_count));
        return true;
    }
    else if(red_count > green_count)
    {
        direction = -1; // PUT
        Logger::Debug("PatternEngine", "MelhorDe3 PUT detectado", 
                     "Shift: " + IntegerToString(shift) + 
                     " | Vermelhas: " + IntegerToString(red_count));
        return true;
    }
    
    return false; // Empate
}

//+------------------------------------------------------------------+
//| CORREÇÃO #10: Padrão 3x1 Continuação Oposta                     |
//+------------------------------------------------------------------+
bool Detect3X1_ContinuacaoOposta(int shift, int &direction)
{
    direction = 0;
    
    // Validação de acesso seguro
    if(!ValidateShiftAccess(shift, 4, "Detect3X1_ContinuacaoOposta"))
        return false;
    
    // Obtém cores das últimas 4 velas
    int cor1 = GetVisualCandleColorSafe(shift + 1, "3X1_Continuacao");
    int cor2 = GetVisualCandleColorSafe(shift + 2, "3X1_Continuacao");
    int cor3 = GetVisualCandleColorSafe(shift + 3, "3X1_Continuacao");
    int cor4 = GetVisualCandleColorSafe(shift + 4, "3X1_Continuacao");
    
    // Verifica validade das cores
    if(!IsValidPatternCandle(cor1) || !IsValidPatternCandle(cor2) || 
       !IsValidPatternCandle(cor3) || !IsValidPatternCandle(cor4))
        return false;
    
    // 3x1: 3 velas de uma cor + 1 vela de cor oposta
    // Entrada na direção da vela isolada
    
    // Verifica padrão: 3 iguais + 1 diferente
    if(cor2 == cor3 && cor3 == cor4 && cor1 != cor2)
    {
        if(cor1 == VISUAL_GREEN)
        {
            direction = 1; // CALL (seguir a vela verde isolada)
            Logger::Debug("PatternEngine", "3X1_Continuacao CALL detectado", 
                         "Shift: " + IntegerToString(shift) + " | Verde isolada");
            return true;
        }
        else if(cor1 == VISUAL_RED)
        {
            direction = -1; // PUT (seguir a vela vermelha isolada)
            Logger::Debug("PatternEngine", "3X1_Continuacao PUT detectado", 
                         "Shift: " + IntegerToString(shift) + " | Vermelha isolada");
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Função auxiliar para validar sequência de cores                 |
//+------------------------------------------------------------------+
bool ValidateColorSequence(const int &colors[], int size, string pattern_name)
{
    for(int i = 0; i < size; i++)
    {
        if(!IsValidPatternCandle(colors[i]))
        {
            Logger::Warning("PatternEngine", "Cor inválida em sequência", 
                           "Padrão: " + pattern_name + 
                           ", Posição: " + IntegerToString(i) + 
                           ", Cor: " + IntegerToString(colors[i]));
            return false;
        }
    }
    return true;
}

//+------------------------------------------------------------------+
//| Função para contar cores em uma sequência                       |
//+------------------------------------------------------------------+
void CountColorsInSequence(const int &colors[], int size, int &green_count, int &red_count, int &doji_count)
{
    green_count = 0;
    red_count = 0;
    doji_count = 0;
    
    for(int i = 0; i < size; i++)
    {
        switch(colors[i])
        {
            case VISUAL_GREEN:
                green_count++;
                break;
            case VISUAL_RED:
                red_count++;
                break;
            case VISUAL_DOJI:
                doji_count++;
                break;
        }
    }
}

//+------------------------------------------------------------------+
//| Função de diagnóstico do motor de padrões                       |
//+------------------------------------------------------------------+
void DiagnosticPatternEngine(int test_shift = 1)
{
    Logger::Info("PatternEngine", "=== DIAGNÓSTICO DO MOTOR DE PADRÕES ===");
    
    if(!g_cache_initialized)
    {
        Logger::Warning("PatternEngine", "Cache não inicializado para diagnóstico");
        return;
    }
    
    Logger::Info("PatternEngine", "Testando padrões no shift: " + IntegerToString(test_shift));
    
    // Testa cada padrão
    int direction;
    
    if(DetectMHI1_3C_Minoria(test_shift, direction))
        Logger::Info("PatternEngine", "MHI1_3C detectado: " + (direction > 0 ? "CALL" : "PUT"));
    
    if(DetectMHI2_3C_Confirmado(test_shift, direction))
        Logger::Info("PatternEngine", "MHI2_3C detectado: " + (direction > 0 ? "CALL" : "PUT"));
    
    if(DetectMHI3_Unanime_Base(test_shift, direction))
        Logger::Info("PatternEngine", "MHI3_Unanime detectado: " + (direction > 0 ? "CALL" : "PUT"));
    
    if(DetectThreeInARow_Base(test_shift, direction))
        Logger::Info("PatternEngine", "ThreeInARow detectado: " + (direction > 0 ? "CALL" : "PUT"));
    
    if(DetectC3_SeguirCor(test_shift, direction))
        Logger::Info("PatternEngine", "C3_SeguirCor detectado: " + (direction > 0 ? "CALL" : "PUT"));
    
    // Mostra cores das últimas velas para referência
    Logger::Info("PatternEngine", "Cores das últimas 5 velas:");
    for(int i = 1; i <= 5; i++)
    {
        if(ValidateShiftAccess(test_shift, i, "Diagnostic"))
        {
            int cor = GetVisualCandleColorSafe(test_shift + i, "Diagnostic");
            string cor_str = (cor == VISUAL_GREEN) ? "Verde" : 
                            (cor == VISUAL_RED) ? "Vermelha" : "Doji";
            Logger::Info("PatternEngine", "Vela[" + IntegerToString(i) + "]: " + cor_str);
        }
    }
    
    Logger::Info("PatternEngine", "=== FIM DO DIAGNÓSTICO ===");
}

#endif // LOGIC_PATTERNENGINE_MQH

