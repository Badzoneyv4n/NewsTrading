//+------------------------------------------------------------------+
//|                                                      NEWSTRADing |
//|                                          Copyright 2023, BADZONE |
//|                                           http://www.badzone.net |
//+------------------------------------------------------------------+

/**
   -------Description------------

   1.Trade based on the specified time
   2.when time reach the start time open two opposite stop orders at the same time
   3.Once an order is executed close the opposite trade
   4.Buy stop = Ask + pip difference
   5.Sell stop = Bid - Pip difference
   6.Loose 1% or 2% per trade <Risk()>
   7.Set target TP

**/

#include <Trade\Trade.mqh>
CTrade trade;

input string StartTime = "05:29:50"; //Time to place trades
input string Pipdiff = "5"; //Pip difference
input string TargetProfit = "10"; //Target Profit in pips
input string StopLoss = "0"; //Stop Loss in pips
input int Number_trades = 0;//How many trades 0 = 2trades, 2= 4 trades, 4 = 6 trades
input int rsk = 1;//Risk 1% or 2% Per trade


/**------------- Global variables--------------**/
string NowTimeL; //Local Time                    |
string NowTimeC; //Server Time                   |
double Balance; //Hold the account balance       |
double Equity; //Hold the account equity         |
double Ask; //Hold the Current Ask of a pair     |
double Bid; //Hold the current Bid of a pair     |
//+--------------------------------------------+

//+------------------------------------------------------------------+
//|                          NEWS HANDLER                            |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK), _Digits); //Bid
   Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID), _Digits); //Ask

   datetime timeL = TimeLocal(); //Get the local (PC's) time
   datetime timeC = TimeCurrent(); //Get the Server's time

   NowTimeL = TimeToString(timeL, TIME_SECONDS); //Local time in HH:MM:SS format
   NowTimeC = TimeToString(timeC, TIME_SECONDS); //Server time in HH:MM:SS format

   Balance = AccountInfoDouble(ACCOUNT_BALANCE); //Get the current Balance of the account
   Equity = AccountInfoDouble(ACCOUNT_EQUITY); //Get the current Equity of the account

   Risk(rsk); // Close All trades wich are losing 1% of my balance

   for(int i = 0; i <= 9; i++)
     {

      //Close all Orders and positions before starting time
      if(NowTimeL == SecHandler(-i))
        {
         closeTrades();
        }

      //Close unexecuted Orders when time is reached
      if(NowTimeL == SecHandler(i+20))
        {
         CloseOrders();
        }

      //Open stop orders of opposite directions
      if((OrdersTotal() <= Number_trades) && NowTimeL == SecHandler(i))
        {
         trade.SellStop(LotCal(), Entry("sell"),NULL,SL("sell"),Tp("sell"),ORDER_TIME_GTC,0,NULL);
         trade.BuyStop(LotCal(),Entry("buy"),NULL,SL("buy"),Tp("buy"),ORDER_TIME_GTC,0,NULL);
         break;
        }
     }

   Comment(
      "|| Start Time    = ", StartTime,
      "\n|| Local Time    = ", NowTimeL,
      "\n*********************************",
      "\n|| Server Time    = ", NowTimeC,
      "\n*********************************",
      "\n|| Bid     = ", Bid,
      "\n|| Ask     = ", Ask,
      "\n*********************************",
      "\n|| BALANCE    = ", Balance,
      "\n|| EQUITY    = ", Equity,
      "\n*********************************",
      "\n|| Target Profit    = ", TargetProfit,
      "\n|| Stop Loss    = ", "1%",
      "\n*********************************"
   );

  }//OnTick End


//+------------------------------------------------------------------+
//| FUNCTION FOR HANDLING SECONDS BY ADDING Secs as parameters       |
//+------------------------------------------------------------------+
string SecHandler(int sec)
  {

   long Hours = StringToInteger(StringSubstr(StartTime,0,2)); //Get the hours from startTime
   long Minutes = StringToInteger(StringSubstr(StartTime,3,2)); //Get the minutes from startTime
   long Seconds = StringToInteger(StringSubstr(StartTime,6,2)); //Get the Seconds from startTime

   Seconds = Seconds + sec;

   if(Seconds >= 60)
     {
      Seconds = Seconds - 60; //If seconds exceeds 60

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

   string ModTime = StringFormat("%02d:%02d:%02d",Hours,Minutes,Seconds);

   return ModTime;
  }

//

//+------------------------------------------------------------------+
//|  FUNCTION FOR CLOSING ORDERS AND OPEN POSITIONS                  |
//+------------------------------------------------------------------+

// Close All Positions and Orders
void closeTrades()
  {
   if(PositionsTotal() != 0)
     {
      for(int ii = PositionsTotal()-1; ii>=0 ; ii--)
        {
         trade.PositionClose(PositionGetTicket(ii));
        }
     }
   if(OrdersTotal() != 0)
     {
      for(int yy = OrdersTotal()-1; yy>=0; yy--)
        {
         trade.OrderDelete(OrderGetTicket(yy));
        }
     }
  }

//Close Opposite Orders based on open positions
void CloseOrders()
  {

   for(int i = PositionsTotal()-1; i>=0 ; i--)
     {
      //ulong P_tickets = PositionGetTicket(i);
      ulong P_direction = PositionGetInteger(POSITION_TYPE);

      //If BUY positions are running close all SELL orders

      if(P_direction == POSITION_TYPE_BUY)
        {
         for(int j = OrdersTotal()-1; j>=0; j--)
           {
            ulong O_tickets = OrderGetTicket(j);
            ulong O_direction = OrderGetInteger(ORDER_TYPE);
            if(O_direction == ORDER_TYPE_SELL_STOP)
              {
               trade.OrderDelete(O_tickets);
              }
           }
        }

      //If SELL positions are running close all BUY orders

      if(P_direction == POSITION_TYPE_SELL)
        {
         for(int y = OrdersTotal()-1; y>=0; y--)
           {
            ulong O_tickets = OrderGetTicket(y);
            ulong O_direction = OrderGetInteger(ORDER_TYPE);

            if(O_direction == ORDER_TYPE_BUY_STOP)
              {
               trade.OrderDelete(O_tickets);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//                 RISK MANAGEMENT PLAN                              |
//+------------------------------------------------------------------+

//CALCULATE THE LOT TO TRADE BASED ON THE ACCOUNT's BALANCE
double LotCal()
  {

   double lot;

   if((Balance >= 1) && (Balance <= 99))
     {
      lot = 0.01;
     }
   else
      if((Balance >= 100) && (Balance <= 999))
        {
         lot = 0.05;
        }
      else
         if((Balance >= 1000) && (Balance <= 4999))
           {
            lot = 0.1;
           }
         else
            if((Balance >= 5000) && (Balance <=9999))
              {
               lot = 0.5;
              }
            else
               if((Balance >= 10000) && (Balance <= 99999))
                 {
                  lot = 1;
                 }
               else
                 {
                  lot = 0.01;
                 }
   return lot;
  }
//+------------------------------------------------------------------+
//CALCULATE THE SL (AMOUNT TO RISK = 1%/2%) BASED ON THE BALANCE     |
//+------------------------------------------------------------------+
int Risk(int risk)
  {
   double SL;

   (risk == 2)? SL = (Balance*2)/100 : SL = (Balance*1)/100;   // Risk 1% or 2% on every trade

   if(PositionsTotal() != 0)
     {

      for(int i = PositionsTotal()-1; i>=0 ; i--)
        {
         ulong P_ticket = PositionGetTicket(i);
         double P_Profit = PositionGetDouble(POSITION_PROFIT);

         if(P_Profit == (-1*SL))
           {
            trade.PositionClose(P_ticket);
           }

         Comment(
            "The SL is : ", SL,
            "The Number of Tickets is : ", PositionsTotal(),
            "The Position's Tickets is : ", PositionGetTicket(i),
            "The Profit is : ", PositionGetDouble(POSITION_PROFIT)
         );
        }
     }

   return risk;
  }
//+------------------------------------------------------------------+

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
         Print("****Failed to get the entry point*****");
        }


   return enter;
  }

//+------------------------------------------------------------------+

//========Target Profit Convert =============
double Tp(string type2)
  {

   double dec2,target=0;
   double pips2 = StringToDouble(TargetProfit) + StringToDouble(Pipdiff); //convert Pipdiff to string

//Get the digits for converting pips
   if((_Digits == 2) || (_Digits == 3))
      dec2 = pips2/100; // For 2 / 3 digits Currency pairs with
   else
      dec2 = pips2/10000; // For all other 5 digits currenciens

//If the value of parameter "type"

   if(type2 == "buy")
     {
      target =+ NormalizeDouble((Ask + dec2),_Digits); // return Buy Target Profit Price
     }
   else
      if(type2 == "sell")
        {
         target =+ NormalizeDouble((Bid - dec2),_Digits); // return Sell Target Profit Price
        }
      else
        {
         Print("*****Failed to get the Target Profit*****");
        }


   return target;
  }
// End of Tp()

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
