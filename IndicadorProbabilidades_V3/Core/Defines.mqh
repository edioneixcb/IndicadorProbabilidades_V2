//+------------------------------------------------------------------+
//|                                    Core/Defines.mqh |
//|                                    Indicador de Probabilidades V3 |
//|                                Definições e Constantes do Sistema |
//+------------------------------------------------------------------+

#ifndef CORE_DEFINES_MQH
#define CORE_DEFINES_MQH

//+------------------------------------------------------------------+
//| Informações do Indicador                                        |
//+------------------------------------------------------------------+
#define INDICATOR_NAME "Indicador de Probabilidades V3"
#define INDICATOR_VERSION "3.0.0"
#define INDICATOR_COPYRIGHT "2024, Indicador de Probabilidades"
#define INDICATOR_LINK "https://github.com/edioneixcb/IndicadorProbabilidades_V3"

//+------------------------------------------------------------------+
//| Constantes Gerais                                               |
//+------------------------------------------------------------------+
#define MAX_BARS_HISTORY 10000
#define MAX_PATTERNS 50
#define MAX_SIGNALS_PER_DAY 100
#define MAX_MARTINGALE_LEVELS 10
#define MAX_CACHE_SIZE 1000
#define MAX_LOG_ENTRIES 500

//+------------------------------------------------------------------+
//| Constantes de Tempo                                             |
//+------------------------------------------------------------------+
#define SECONDS_IN_MINUTE 60
#define SECONDS_IN_HOUR 3600
#define SECONDS_IN_DAY 86400
#define MILLISECONDS_IN_SECOND 1000

//+------------------------------------------------------------------+
//| Constantes de Precisão                                          |
//+------------------------------------------------------------------+
#define PRICE_PRECISION 5
#define PERCENTAGE_PRECISION 2
#define RATIO_PRECISION 3
#define CURRENCY_PRECISION 2

//+------------------------------------------------------------------+
//| Constantes de Validação                                         |
//+------------------------------------------------------------------+
#define MIN_CONFIDENCE 0.0
#define MAX_CONFIDENCE 100.0
#define MIN_PAYOUT 0.1
#define MAX_PAYOUT 10.0
#define MIN_ENTRY_VALUE 1.0
#define MAX_ENTRY_VALUE 10000.0

//+------------------------------------------------------------------+
//| Constantes de Performance                                       |
//+------------------------------------------------------------------+
#define DEFAULT_UPDATE_INTERVAL 1000
#define MIN_UPDATE_INTERVAL 100
#define MAX_UPDATE_INTERVAL 10000
#define CACHE_EXPIRY_SECONDS 300

//+------------------------------------------------------------------+
//| Constantes de Filtros                                           |
//+------------------------------------------------------------------+
#define DEFAULT_ATR_PERIOD 14
#define DEFAULT_ATR_MULTIPLIER 1.5
#define DEFAULT_BB_PERIOD 20
#define DEFAULT_BB_DEVIATION 2.0
#define DEFAULT_TREND_PERIOD 50

//+------------------------------------------------------------------+
//| Constantes de Notificações                                      |
//+------------------------------------------------------------------+
#define MAX_TELEGRAM_MESSAGE_LENGTH 4096
#define MAX_MX2_SIGNAL_LENGTH 256
#define NOTIFICATION_RETRY_COUNT 3
#define NOTIFICATION_TIMEOUT_MS 5000

//+------------------------------------------------------------------+
//| Constantes de Painel                                            |
//+------------------------------------------------------------------+
#define PANEL_MIN_WIDTH 200
#define PANEL_MAX_WIDTH 500
#define PANEL_MIN_HEIGHT 300
#define PANEL_MAX_HEIGHT 800
#define PANEL_ELEMENT_HEIGHT 15
#define PANEL_SECTION_SPACING 5

//+------------------------------------------------------------------+
//| Constantes de Cores                                             |
//+------------------------------------------------------------------+
#define COLOR_CALL_DEFAULT clrLime
#define COLOR_PUT_DEFAULT clrRed
#define COLOR_NEUTRAL_DEFAULT clrGray
#define COLOR_POSITIVE_DEFAULT clrGreen
#define COLOR_NEGATIVE_DEFAULT clrRed
#define COLOR_WARNING_DEFAULT clrOrange
#define COLOR_INFO_DEFAULT clrBlue

//+------------------------------------------------------------------+
//| Constantes de Arquivos                                          |
//+------------------------------------------------------------------+
#define LOG_FILE_PREFIX "ProbV3_"
#define CONFIG_FILE_NAME "ProbV3_Config.ini"
#define CACHE_FILE_NAME "ProbV3_Cache.dat"
#define STATS_FILE_NAME "ProbV3_Stats.csv"

//+------------------------------------------------------------------+
//| Macros de Validação                                             |
//+------------------------------------------------------------------+
#define IS_VALID_HANDLE(h) ((h) != INVALID_HANDLE)
#define IS_VALID_PRICE(p) ((p) > 0.0)
#define IS_VALID_CONFIDENCE(c) ((c) >= MIN_CONFIDENCE && (c) <= MAX_CONFIDENCE)
#define IS_VALID_PAYOUT(p) ((p) >= MIN_PAYOUT && (p) <= MAX_PAYOUT)
#define IS_VALID_ENTRY_VALUE(v) ((v) >= MIN_ENTRY_VALUE && (v) <= MAX_ENTRY_VALUE)

//+------------------------------------------------------------------+
//| Macros de Conversão                                             |
//+------------------------------------------------------------------+
#define PERCENTAGE_TO_DECIMAL(p) ((p) / 100.0)
#define DECIMAL_TO_PERCENTAGE(d) ((d) * 100.0)
#define POINTS_TO_PRICE(pts) ((pts) * Point())
#define PRICE_TO_POINTS(price) ((price) / Point())

//+------------------------------------------------------------------+
//| Macros de Formatação                                            |
//+------------------------------------------------------------------+
#define FORMAT_PRICE(p) DoubleToString((p), PRICE_PRECISION)
#define FORMAT_PERCENTAGE(p) DoubleToString((p), PERCENTAGE_PRECISION) + "%"
#define FORMAT_RATIO(r) DoubleToString((r), RATIO_PRECISION)
#define FORMAT_CURRENCY(c) DoubleToString((c), CURRENCY_PRECISION)

//+------------------------------------------------------------------+
//| Funções Utilitárias de Formatação                               |
//+------------------------------------------------------------------+

/**
 * Formata valor monetário com símbolo
 * @param value Valor a ser formatado
 * @return String formatada
 */
string FormatCurrency(double value)
{
    return "R$ " + DoubleToString(value, CURRENCY_PRECISION);
}

/**
 * Formata percentual com símbolo
 * @param value Valor percentual
 * @return String formatada
 */
string FormatPercentage(double value)
{
    return DoubleToString(value, PERCENTAGE_PRECISION) + "%";
}

/**
 * Formata preço com precisão adequada
 * @param price Preço a ser formatado
 * @return String formatada
 */
string FormatPrice(double price)
{
    return DoubleToString(price, PRICE_PRECISION);
}

/**
 * Formata timestamp para exibição
 * @param timestamp Timestamp a ser formatado
 * @return String formatada
 */
string FormatTimestamp(datetime timestamp)
{
    return TimeToString(timestamp, TIME_DATE | TIME_SECONDS);
}

//+------------------------------------------------------------------+
//| Funções de Validação                                            |
//+------------------------------------------------------------------+

/**
 * Valida se um handle é válido
 * @param handle Handle a ser validado
 * @return true se válido
 */
bool IsValidHandle(int handle)
{
    return handle != INVALID_HANDLE;
}

/**
 * Valida se um preço é válido
 * @param price Preço a ser validado
 * @return true se válido
 */
bool IsValidPrice(double price)
{
    return price > 0.0 && price != EMPTY_VALUE;
}

/**
 * Valida se uma confiança é válida
 * @param confidence Confiança a ser validada
 * @return true se válida
 */
bool IsValidConfidence(double confidence)
{
    return confidence >= MIN_CONFIDENCE && confidence <= MAX_CONFIDENCE;
}

/**
 * Valida se um payout é válido
 * @param payout Payout a ser validado
 * @return true se válido
 */
bool IsValidPayout(double payout)
{
    return payout >= MIN_PAYOUT && payout <= MAX_PAYOUT;
}

/**
 * Valida se um valor de entrada é válido
 * @param entry_value Valor de entrada a ser validado
 * @return true se válido
 */
bool IsValidEntryValue(double entry_value)
{
    return entry_value >= MIN_ENTRY_VALUE && entry_value <= MAX_ENTRY_VALUE;
}

//+------------------------------------------------------------------+
//| Funções de Conversão                                            |
//+------------------------------------------------------------------+

/**
 * Converte percentual para decimal
 * @param percentage Percentual a ser convertido
 * @return Valor decimal
 */
double PercentageToDecimal(double percentage)
{
    return percentage / 100.0;
}

/**
 * Converte decimal para percentual
 * @param decimal Decimal a ser convertido
 * @return Valor percentual
 */
double DecimalToPercentage(double decimal)
{
    return decimal * 100.0;
}

/**
 * Converte pontos para preço
 * @param points Pontos a serem convertidos
 * @return Valor em preço
 */
double PointsToPrice(int points)
{
    return points * Point();
}

/**
 * Converte preço para pontos
 * @param price Preço a ser convertido
 * @return Valor em pontos
 */
int PriceToPoints(double price)
{
    return (int)(price / Point());
}

//+------------------------------------------------------------------+
//| Funções de Comparação                                           |
//+------------------------------------------------------------------+

/**
 * Compara dois valores double com tolerância
 * @param value1 Primeiro valor
 * @param value2 Segundo valor
 * @param tolerance Tolerância para comparação
 * @return true se são iguais dentro da tolerância
 */
bool DoubleEquals(double value1, double value2, double tolerance = 0.00001)
{
    return MathAbs(value1 - value2) <= tolerance;
}

/**
 * Verifica se um valor está dentro de um range
 * @param value Valor a ser verificado
 * @param min_value Valor mínimo
 * @param max_value Valor máximo
 * @return true se está dentro do range
 */
bool IsInRange(double value, double min_value, double max_value)
{
    return value >= min_value && value <= max_value;
}

//+------------------------------------------------------------------+
//| Funções de Matemática                                           |
//+------------------------------------------------------------------+

/**
 * Calcula média de um array
 * @param values Array de valores
 * @param count Número de elementos
 * @return Média calculada
 */
double CalculateAverage(const double &values[], int count)
{
    if(count <= 0) return 0.0;
    
    double sum = 0.0;
    for(int i = 0; i < count; i++)
    {
        sum += values[i];
    }
    
    return sum / count;
}

/**
 * Calcula desvio padrão de um array
 * @param values Array de valores
 * @param count Número de elementos
 * @return Desvio padrão calculado
 */
double CalculateStandardDeviation(const double &values[], int count)
{
    if(count <= 1) return 0.0;
    
    double average = CalculateAverage(values, count);
    double sum_squares = 0.0;
    
    for(int i = 0; i < count; i++)
    {
        double diff = values[i] - average;
        sum_squares += diff * diff;
    }
    
    return MathSqrt(sum_squares / (count - 1));
}

/**
 * Normaliza um valor para um range específico
 * @param value Valor a ser normalizado
 * @param min_input Mínimo do range de entrada
 * @param max_input Máximo do range de entrada
 * @param min_output Mínimo do range de saída
 * @param max_output Máximo do range de saída
 * @return Valor normalizado
 */
double NormalizeValue(double value, double min_input, double max_input, double min_output, double max_output)
{
    if(max_input == min_input) return min_output;
    
    double normalized = (value - min_input) / (max_input - min_input);
    return min_output + normalized * (max_output - min_output);
}

#endif // CORE_DEFINES_MQH

