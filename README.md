# NewsTrading

//Simple forex news trading Expert Advisor made with mql5

requirements : MT5 for windows / mac / linux and a broker which accept Experts Advisors
    
  Download this 2 files, navigate to your download folder then copy those 2 files.
  Open MT5, click on file >> Open Data Folder >> MQL 5 >> Experts then paste the 2 files 

1.Trade based on the specified time

2.when time reach the start time open two opposite stop orders at the same time

3.Once an order is executed close the opposite trade

4.Buy stop = Ask + pip difference

5.Sell stop = Bid - Pip difference

6.Loose 1% or 2% per trade <Risk()>

7.Set target TP
