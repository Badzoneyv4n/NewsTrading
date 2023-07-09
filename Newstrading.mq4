//+------------------------------------------------------------------+
//|                                                  Newstrading.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

input string StartTime = "14:29:50"; //Time to place trades
input string Pipdiff = "5"; //Pip difference
input string TargetProfit = "0"; //Target Profit in pips
input string StopLoss = "0"; //Stop Loss in pips remember to - Stop Levels
input int Number_trades = 0;//How many trades 0 = 2trades, 2= 4 trades, 4 = 6trades

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double ask = SymbolInfoDouble(Symbol(),SYMBOL_ASK) + 0.0005;
   double bid = SymbolInfoDouble(Symbol(),SYMBOL_BID) - 0.0005;

   datetime timeL = TimeLocal(); //Get the local (PC's) time
   datetime timeC = TimeCurrent(); //Get the Server's time

   string Local  = TimeToString(timeL, TIME_SECONDS);
   string Current = TimeToString(timeC, TIME_SECONDS);

   for(int i = 0; i<=9; i++)
     {
      if((StringCompare(Local, SecHandler(i)) == 0) && (OrdersTotal() <= Number_trades))
        {
         int ticket1 = OrderSend(_Symbol,OP_BUYSTOP,0.1,Entry("buy"),3,SL("buy"),TP("buy"),"",clrGreen);

         int ticket2 = OrderSend(_Symbol,OP_SELLSTOP,0.1,Entry("sell"),3,SL("sell"),TP("sell"),"",clrRed);
        }
     }

   Comment(
      "|| Bid :    ", bid,
      "\n|| Ask :    ", ask,
      "\n***********************",
      "\n|| Local time :    ", Local,
      "\n|| Starting time :    ", StartTime,
      "\n********************************",
      "\n|| Server time:    ", Current,
      "\n*******************************",
      "\n|| BALANCE :    ", AccountBalance(),
      "\n|| EQUITY :    ", AccountEquity(),
      "\n*******************************",
      "\n*******************************",
      "\n|| Target Profit :    ", TargetProfit,
      "\n|| Stop Loss (-Stop levels) :    ", StopLoss,
      "\n*******************************"
   );



  }


//+------------------------------------------------------------------+
//| FUNCTION FOR HANDLING SECONDS BY ADDING Secs as parameters       |
//+------------------------------------------------------------------+
string SecHandler(int sec)
  {

   long Hours = StringToInteger(StringSubstr(StartTime,0,2)); //Get the hours from startTime
   long Minutes = StringToInteger(StringSubstr(StartTime,3,2)); //Get the minutes from startTime
   long Second = StringToInteger(StringSubstr(StartTime,6,2)); //Get the Seconds from startTime

   Second = Second + sec;

   if(Second >= 60)
     {
      Second = Second - 60; //If seconds exceeds 60

      Minutes++;

      if(Minutes >= 60)
        {
         Minutes = Minutes - 60; //If Minutes exceeds 60

         Hours++;

         if(Hours >= 24)
           {
            Hours = 0;
           }
        }
     }

   string ModTime = StringFormat("%02d:%02d:%02d",Hours,Minutes,Second);

   return ModTime;
  }

//End SecHandler


//+------------------------------------------------------------------+
//|                   Calculate The entry price                      |
//+------------------------------------------------------------------+
double Entry(string type)
  {

   double dec,enter=0;
   double pips = StringToDouble(Pipdiff); //convert Pipdiff to string

//Get the digits for converting pips
   if((_Digits == 2) || (_Digits == 3))
      dec = pips/100; // For 2 / 3 digits Currency pairs with
   else
      dec = pips/10000; // For all other 5 digits currenciens

//If the value of parameter "type"

   if(type == "buy")
     {
      enter =+ NormalizeDouble((Ask + dec),_Digits); // return Buy Entry
     }
   else
      if(type == "sell")
        {
         enter =+ NormalizeDouble((Bid - dec),_Digits); // return Sell Entry
        }
      else
        {
         Print("Failed to get the entry point");
        }


   return enter;
  }
//End .........

//+------------------------------------------------------------------+
//|                CALCULATE THE TARGET PROFIT                       |
//+------------------------------------------------------------------+
double TP(string type)
  {
   double dec,tp=0;
   double pips = StringToDouble(Pipdiff) + StringToDouble(TargetProfit); //convert Pipdiff & TargetProfit to string

//Get the digits for converting pips
   if((_Digits == 2) || (_Digits == 3))
      dec = pips/100; // For 2 / 3 digits Currency pairs with
   else
      dec = pips/10000; // For all other 5 digits currenciens

//If the value of parameter "type"

   if(type == "buy")
     {
      tp =+ NormalizeDouble((Ask + dec),_Digits); // return Buy Target Profit Price
     }
   else
      if(type == "sell")
        {
         tp =+ NormalizeDouble((Bid - dec),_Digits); // return Sell Target Profit Price
        }
      else
        {
         Print("Failed to get the entry point");
        }


   return tp;
  }

//+------------------------------------------------------------------+
//|              CALCULATE THE STOPLOSS                              |
//+------------------------------------------------------------------+
double SL(string type)
  {
   double dec,sl=0;
   double pips = StringToDouble(Pipdiff) + StringToDouble(StopLoss); //convert Pipdiff & StopLoss to string

//Get the digits for converting pips
   if((_Digits == 2) || (_Digits == 3))
      dec = pips/100; // For 2 / 3 digits Currency pairs with
   else
      dec = pips/10000; // For all other 5 digits currenciens

//If the value of parameter "type"

   if(type == "buy")
     {
      sl =+ NormalizeDouble((Ask - dec),_Digits); // return Buy StopLoss price
     }
   else
      if(type == "sell")
        {
         sl =+ NormalizeDouble((Bid + dec),_Digits); // return Sell StopLoss price
        }
      else
        {
         Print("Failed to get the entry point");
        }


   return sl;
  }
//End .....