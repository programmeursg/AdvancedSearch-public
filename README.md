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

First Usage
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

If it is the next time you open a stored procedure it calculates the calculated fields and filters out the necessary recors and sorts on the calculated fields in a particular order.
The reason it skips the three steps when loading for the first time is that the dataset is shown in its entirety and it is then unnecessary to perform all the steps. This results in a speed gain.

Searching in a stored procedure
-----------------
The are four checkboxes which can change te search behaviour.
1 Strict, 
          If you want to show all records where all search terms appear in one record.  (AND search) 
          else it shows al the records that contain one of more of the search terms. (OR search)
2 Include excluded
          This was for debugging purposes. If this is checked it show al the records where the Weight is 0. 0 Means it is not included in the normal result set.
          else it shows only the normal result set.
3 Refresh 
          If this is checked the stored procedure data is reloaded from te database so that al recent changes are included.
          else it shows the earlier requested data from the search datasset. This is results in a speed gain.
4 Show calculated 
          If this is checked it shows the normally hidden calculated field. Now you can see what data is used to create the search results.
