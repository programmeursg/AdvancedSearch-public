# AdvancedSearch
Main description:
-----------------
Search on multiple words in a choosen storedprocedure with AND and OR with weight and words counter.

Warning!
-----------------
This program let you choosen a stored procedure from a list after you have build the connectionstring.
I am not responsible for the content of the content of the stored procdure you choose.
It is possible that the stored procedure you choose contains harmfull code such as DELETE and INSERT statements.
I don't deliver any stored procedure code with my code.

Usage
-----------------
After you have choosen a server,database and table connection with the "Build connectionstring" you can choose a stored procedure from a dropdownbox and press the "Open" button
![afbeelding](https://github.com/user-attachments/assets/01ab98d0-6e87-4d27-87e2-599fb90ef5b1)
If it is a large dataset you see a progressbar and the progress text in the titlebar.
First it loads the data from the stored procedure in steps so that a progress indicator is possible.

If it is the first time the stored procedure is opened it skips step 3, 4 and 5
1 While loading the stored procedure it clones te data to a search dataset.
2 It appends some calculated fields which is necessary for advanced searching.

3 First it calculates the calculated fields. 
4 Then it applies filters.
5 And at last it applies the index.




