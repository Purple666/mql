//+------------------------------------------------------------------+
//|                                                  GECloseOpen.mq4 |
//|                                  Copyright 2017, Maverus FXT LLC |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Maverus FXT LLC"
#property link      ""
#property version   "1.00"
#property strict
#property script_show_inputs // Show input prompt window.

input double              Risk         = 1.0;              // Account Risk
input string              OrderType    = "AUTO";              // Order Type (AUTO=Opposite of prior trade)
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
int start() {
  int total=OrdersTotal(), Mode = OP_BUY;
  string prvOrderType, chartSymbol;
  double LotSize = 0;

   //--- Checks the input parameters
  if(OrderType != "AUTO" && OrderType != "BUY" && OrderType != "SELL") {
    Alert("Please select Order Type (AUTO, BUY, SELL)."); return(0);
  }
  
  chartSymbol = ChartSymbol();
  
  // loop through the open orders find the previous trade to close.
  for(int pos=0; pos<total; pos++) {
    if ( OrderSelect(pos,SELECT_BY_POS)==false) continue; // didn’t return order so loop again
    string oc = OrderComment();
    if ( OrderComment() != "GE Trade") continue; // Comment didn't match order placed by script
    if ( OrderSymbol() != chartSymbol) continue; // trade doesn't match current chart.
    int ot = OrderType();
    if ( ot == OP_BUY || ot == OP_BUYLIMIT || ot == OP_BUYSTOP) {
      prvOrderType = "Buy";
    }
    if ( ot == OP_SELL || ot == OP_SELLLIMIT || ot == OP_SELLSTOP) {
      prvOrderType = "Sell";
    }
    bool closeSuccess = OrderClose( OrderTicket(), OrderLots(), Ask, 2, CLR_NONE);
    if (!closeSuccess) {
     MessageBox("Close of order failed. ",GetLastError());
    }
    break;
  } // end search for order to close
  
  // Prep info for new order.
  if (prvOrderType == "Buy") {
    Mode = OP_SELL;
  } else if (prvOrderType == "Sell") {
    Mode = OP_BUY;
  } else {
    if (OrderType == "SELL") { Mode = OP_SELL;}
    if (OrderType == "BUY") { Mode = OP_BUY;}
  }
  LotSize = round(AccountFreeMargin() * (Risk / 100)) * .01;
  if(LotSize > 0) {
   int newOrderNbr = OrderSend( Symbol(), Mode, LotSize, Ask, 2, 0, 0, "GE Trade", 0, NULL, CLR_NONE);
   if (newOrderNbr == -1) { // order failed
     MessageBox("Creation of new order failed. ",GetLastError());
   }
  }
  return(0);
 }