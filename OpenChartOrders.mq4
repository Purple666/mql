//+------------------------------------------------------------------+
//|                                                     OrdersPA.mq4 |
//|                                  Copyright 2017, Maverus FXT LLC |
//|                                                                  |
//+------------------------------------------------------------------+
//#include "..\include\cmdexe.mqh";

#property copyright "Copyright 2017, Maverus FXT LLC"
#property link      ""
#property version   "1.00"
#property strict

#import "shell32.dll"
   int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

datetime dt = TimeLocal();

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  if (dt > D'2017.10.25') {
    MessageBox( "Use of script will expire Oct 31.\nClick OK to continue running the script.", "Script Use Expiration");
  }
  if (dt > D'2017.10.31') {
    MessageBox( "Use of script has expired.", "Script Use Expiration");
    return;
  }
  string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);
  string fileName=terminal_data_path+"\\MQL4\\Files\\OrdersReport.txt";
  int handle=FileOpen( "OrdersReport.txt",FILE_WRITE|FILE_TXT);
  if(handle<0) {
    Print("Operation FileOpen failed, error ",GetLastError());
    return;
  }
  // write header
  //FileWrite(handle,"#","open price","open time","symbol","lots");
  int total=OrdersTotal();
  string message, orderType, chartSymbol;
  
  chartSymbol = ChartSymbol();
  
  // loop through the open orders and display message windows afterward
  for(int pos=0; pos<total; pos++) {
    if (OrderSelect(pos,SELECT_BY_POS)==false) continue; // didn’t return order so loop again
    if ( OrderSymbol() != chartSymbol) continue;
    int ot = OrderType();
    switch( ot) { 
      case OP_BUY: 
        orderType = "Buy market";
        break;
      case OP_BUYLIMIT: 
        orderType = "Buy Limit";
        break;
      case OP_BUYSTOP: 
        orderType = "Buy Stop";
        break;
      case OP_SELL: 
        orderType = "Sell market";
        break;
      case OP_SELLLIMIT: 
        orderType = "Sell Limit";
        break;
      case OP_SELLSTOP: 
        orderType = "Sell Stop";
    }

    message += "Order Opened at: " + OrderOpenTime() 
      + "\n" + OrderSymbol() + " " + orderType + " at " + DoubleToString(OrderOpenPrice(),Digits)
      + "\nStop Loss: " + DoubleToString(OrderStopLoss(),Digits)
      + "\nTake Profit: " + DoubleToString(OrderTakeProfit(),Digits) + "\n====================\n\n";
  } // for loop
  if (message == NULL) {
   message = "No Orders found for the open chart, " + chartSymbol + ".";
  }
  FileWrite( handle, message);
  FileClose(handle);
  ShellExecuteW(0, "Open", "notepad.exe", fileName, "", 1);
//  ObjectCreate("ObjName", OBJ_LABEL, 0, 0, 0);
//  ObjectSetText("ObjName",message,7, "Verdana", Yellow);
//  ObjectSet("ObjName", OBJPROP_CORNER, 0);
//  ObjectSet("ObjName", OBJPROP_XDISTANCE, 20);
//  ObjectSet("ObjName", OBJPROP_YDISTANCE, 100);
} // End OnStart