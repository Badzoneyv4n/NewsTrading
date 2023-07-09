# NewsTrading Expert Advisor 

Here you will find a simple forex news trading Expert Advisor made with mql5 and mql4. This EAs help you catch the volatility by placing pending orders (Buy & Sell) at the same time before the real news comes out. 

To understand how they work suppose at 15:30 Local time ,the Fed will release their interest rate , usually at this time the market will be volatile. 

The EA will help you to send orders before 15:30. 10 seconds before is best so that your orders won't be triggered before the release of the news. At 15:29:50 pending orders (Buy and Sell Stop orders) will be send so that at 15:30:00 the volatility will hit our entry and gives us profit 🤑🤑🤑.

requirements : MT5/MT4 for windows / mac / linux and a broker which accept Experts Advisors.
    
Download 2 files of the same type (mq4&ex4 or mq5&ex5), navigate to your download folder then copy those 2 files.
  Open MT5/MT4, click on 

MT5 : file >> Open Data Folder >> MQL 5 >> Experts then paste the 2 files.

MT4 : file >> Open Data Folder >> MQL 5 >> Experts then paste the 2 files.

1.Trade based on the specified time

2.when time reach the start time open two opposite stop orders at the same time

3.Once an order is executed close the opposite trade

4.Buy stop = Ask + pip difference

5.Sell stop = Bid - Pip difference

6.Loose 1% or 2% per trade <Risk()>

7.Set target TP
