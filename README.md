# MultiWormTracker

A repository of the codes for tracking multiple c elegans worms. See https://doi.org/10.1101/248369 for more details.

1- Put all the codes in the same folder as the captured movie(s).

2- Run Remove.m to remove the background from the movies to facilitate tracking. The code saves the necessary output automatically.

3- Change line 4 of MultiTracker.m to the name of the movie to be analyzed and run the code. 

4- Left-click on the worms to be tracked one by one and then close the figure. 

5- Watch the tracking in progress.

6- The results are saved on the disk. The (x,y) for the centroid of worm “n” at frame “t” is saved in (Worm(n).W(t).X,Worm(n).W(t).Y). The binary skeleton of worm ”n” at frame “t” can be accessed from Worm(n).W(t).I.
