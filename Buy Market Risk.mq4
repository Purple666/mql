//+------------------------------------------------------------------+
//| Buy, calc lot size based upon acct pct risk
//| Copyright © 2017 Maverus FXT                                     |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017 Maverus FXT"
#property link      ""

#property script_show_inputs // Show input prompt window.

input double              Risk         = 0.5;              // Order Risk
input int StopLossPoints = 500; // Stop Loss Points
input int TakeProfitPoints = 400; // Take Profit Points
extern double Entry = 0.0000;

string Input = " Buy Price ";
double LotSize = 0;

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start() { 
  int Mode = OP_BUYSTOP;
  double tls = MarketInfo(Symbol(),MODE_LOTSIZE);
  if (Ask > Entry && Entry > 0) Mode = OP_BUYLIMIT; 
  if (Entry == 0) {
    Entry = Ask; 
    Mode = OP_BUY;
  }
  double SLB = Entry - (StopLossPoints * Point); // Point is the nbr of decimal places in the currency
  double TPB = Entry + (TakeProfitPoints * Point);
  LotSize = round(AccountFreeMargin() * (Risk / 100)) * .01;
  if(LotSize > 0) {
   OrderSend(Symbol(),Mode, LotSize, Entry, 2, SLB, TPB, "Buy Script", 0, NULL, LimeGreen);
   return(0);
  }
}