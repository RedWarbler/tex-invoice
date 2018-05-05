The invoice-calc class file was adapted from the 2015 work of Michael Kropat
 by John Condoluci. 

This software is redistributable under the MIT license. 

Known Issues:

1)
The large balance shown before the itemized list must be manually input. 
\hours and \expense change the global variable \FinalBalance and are called
later in the document. As a result, calling \FinalBalance earlier returns
0.00. If you have a solution or insight, please comment.

2)
The length of the "\hline"s drawn in the itemized tables depend on 
the length of the "date" argument [#1] in \hours and \expense. This 
is ignorable, especially if you use a date formatted like "1/1/2000".