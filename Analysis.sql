USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/


-- Segment 1:


-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:


-- Solution of Q1

SELECT table_name,
       table_rows
FROM   information_schema.tables
WHERE  table_schema = 'imdb'
	-- lets the order the table-names based on its size
ORDER  BY table_rows DESC;

-- End of the solution of Q1


-- Q2. Which columns in the movie table have null values?
-- Type your code below:

-- Solution of Q2

SELECT 

SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS ID_nulls, 
SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS title_nulls, 
SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS year_nulls,
SUM(CASE WHEN date_published IS NULL THEN 1 ELSE 0 END) AS date_published_nulls,
SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS duration_nulls,
SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_nulls,
SUM(CASE WHEN worlwide_gross_income IS NULL THEN 1 ELSE 0 END) AS worlwide_gross_income_nulls,
SUM(CASE WHEN languages IS NULL THEN 1 ELSE 0 END) AS languages_nulls,
SUM(CASE WHEN production_company IS NULL THEN 1 ELSE 0 END) AS production_company_nulls

FROM movie;

-- 4 colums have null values in movie table, those are  : country, world_wide_gross_income, languages, production_company 

-- End of the solution of Q2


-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- Solution of Q3 - Part 1

SELECT year AS Year,
       Count(*) AS number_of_movies
FROM   movie
GROUP  BY year
ORDER  BY year ASC; 

-- Solution of Q3 - Part 2

SELECT Month(date_published) AS month_num,
       Count(*) AS number_of_movies
FROM   movie
GROUP  BY Month(date_published)
ORDER  BY month_num ASC;

-- End of the solution of Q3 


/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

-- Solution of Q4

SELECT Count(*) as number_of_movies
FROM   movie
/*In the country column of the movie table, there are multiple contries are mapped to the same movie.
that is the reason why i went for like operator(for pattern matching) rather than using the = symbol in the where clause*/
WHERE  ( Upper(country) LIKE '%USA%'
          OR Upper(country) LIKE '%INDIA%' )
       AND year = 2019; 
       
-- End of the solution of Q4

/*below given is an extra code (not part of the solution) to justify the above explanation : 
this code will show that, many items have got multiple countries tagged to it, in the movie table*/

select distinct country
from movie;

-- End of extra code


/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

-- Solution of Q5

SELECT DISTINCT genre
FROM   genre
-- lets order by genre names in ascending order
ORDER  BY genre ASC; 

-- End of the solution of Q5


/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

-- Solution of Q6

/* Drama is the genre of having highest movies produced overall. 
I am not including the count of movies with genre_name in the select statement, 
since the question demands, only the genre_name to be displayed as the output*/

SELECT genre
FROM   genre
GROUP  BY genre
ORDER  BY Count(movie_id) DESC
LIMIT  1; 

-- End of the solution of Q6


/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

-- Solution of Q7

WITH single_genre_movie
     AS (SELECT movie_id
         FROM   genre
         GROUP  BY movie_id
         HAVING Count(movie_id) = 1)
SELECT Count(*)
FROM   single_genre_movie; 

-- End of the solution of Q7


/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- Solution of Q8

SELECT g.genre,
       Round(Avg(m.duration), 2) AS avg_duration
FROM   movie AS m
       INNER JOIN genre AS g
               ON m.id = g.movie_id
GROUP  BY g.genre
-- lets order by the genre name which is not part of the question
ORDER  BY g.genre ASC; 

-- End of the solution of Q8


/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

-- Solution of Q9

WITH genre_ranking AS 
		(SELECT genre,
                Count(movie_id) AS movie_count,
                Rank()OVER(ORDER BY Count(movie_id) DESC) AS genre_rank
         FROM   genre
         GROUP  BY genre)
SELECT *
FROM   genre_ranking
WHERE  genre = 'Thriller'; 

-- End of the solution of Q9



/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/


-- Segment 2:


-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|max_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

-- Solution of Q10

SELECT Min(avg_rating) AS min_avg_rating,
       Max(avg_rating) AS max_avg_rating,
       Min(total_votes) AS min_total_votes,
       Max(total_votes) AS max_total_votes,
       Min(median_rating) AS min_median_rating,
       Max(median_rating) AS max_median_rating
FROM   ratings;  

-- End of the solution of Q10
    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too


-- Solution of Q11

SELECT     m.title,
           r.avg_rating,
           DENSE_RANK() OVER(ORDER BY r.avg_rating DESC) AS movie_rank
FROM       movie AS m
INNER JOIN ratings AS r
ON         m.id = r.movie_id 
LIMIT 10; 

-- End of the solution of Q11


/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

-- Solution of Q12

SELECT median_rating,
       Count(*) AS movie_count
FROM   ratings
GROUP  BY median_rating
ORDER  BY median_rating;  

-- End of the solution of Q12


/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

-- Solution of Q13

SELECT     m.production_company,
           Count(*) AS movie_count,
           RANK() OVER(ORDER BY count(*) DESC ) AS prod_company_rank
FROM       movie AS m
INNER JOIN ratings AS r
ON         m.id = r.movie_id
WHERE      r.avg_rating > 8
AND        m.production_company IS NOT NULL
GROUP BY   m.production_company
LIMIT      1;

-- End of the solution of Q13

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- Solution of Q14

SELECT g.genre,
       Count(*) AS movie_count
FROM   movie AS m
       INNER JOIN genre AS g
               ON m.id = g.movie_id
       INNER JOIN ratings AS r
               ON m.id = r.movie_id
WHERE  m.country LIKE '%USA%'
       AND Year(m.date_published) = 2017
       AND Month(m.date_published) = 3
       AND r.total_votes > 1000
/* in the movie table, country column may contain multiple country names separated by commas for the same movie (or for a single row)
that is the reason why is used like operator (for pattern matching) instead of using the '=' symbol 
in the where clause associated with country column*/
GROUP  BY g.genre
-- lets order by genre
ORDER  BY g.genre;  

-- End of the solution of Q14


-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

-- Solution of Q15

SELECT m.title,
       r.avg_rating,
       g.genre
FROM   movie AS m
       INNER JOIN genre AS g
               ON m.id = g.movie_id
       INNER JOIN ratings AS r
               ON m.id = r.movie_id
WHERE  m.title LIKE 'The %'
       AND r.avg_rating > 8
       -- lets order the table by genre and avg_rating
ORDER  BY g.genre ASC, r.avg_rating DESC;  

-- End of the solution of Q15


-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:


-- Solution of Q16

SELECT Count(*) AS movies_count
FROM   movie AS m
       INNER JOIN ratings AS r
               ON m.id = r.movie_id
WHERE  m.date_published BETWEEN '2018-04-01' AND '2019-04-01'
       AND r.median_rating = 8; 

-- End of the solution of Q16


-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

-- Solution of Q17

WITH german_italian_movies
     AS (SELECT r.total_votes,
                CASE WHEN Upper(m.languages) LIKE '%GERMAN%' THEN r.total_votes ELSE 0
                END AS German_Movie_Votes,
                CASE WHEN Upper(m.languages) LIKE '%ITALIAN%' THEN r.total_votes ELSE 0
                END AS Italian_Movie_Votes
         FROM   movie AS m
                INNER JOIN ratings AS r
                        ON m.id = r.movie_id)

SELECT Sum(german_movie_votes) AS German_movie_total_votes,
       Sum(italian_movie_votes) AS Italian_movie_total_votes,
       Sum(german_movie_votes) > Sum(italian_movie_votes) AS
       Is_Geman_moive_get_more_votes
FROM   german_italian_movies; 

-- Answer is Yes , German movies gets more votes than italian movies

-- End of the solution of Q17

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

-- Solution of Q18

SELECT 
    SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name_nulls,
    SUM(CASE WHEN height IS NULL THEN 1 ELSE 0 END) AS height_nulls,
    SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS date_of_birth_nulls,
    SUM(CASE WHEN known_for_movies IS NULL THEN 1 ELSE 0 END) AS known_for_movies_nulls
FROM
    names; 

-- End of the solution of Q18


/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- Solution of Q19

 WITH top3_genre AS
(
           SELECT     genre
           FROM       genre   AS g
           INNER JOIN ratings AS r
           ON         g.movie_id = r.movie_id
           WHERE      r.avg_rating > 8
           GROUP BY   genre
           ORDER BY   Count(*) DESC limit 3)
SELECT     n.name,
           Count(*)AS movie_count
FROM       movie AS m
INNER JOIN director_mapping AS d
ON         m.id = d.movie_id
INNER JOIN names AS n
ON         n.id = d.name_id
INNER JOIN ratings AS r
ON         m.id = r.movie_id
INNER JOIN genre AS g
ON         m.id = g.movie_id
WHERE      g.genre IN
                       (
                       SELECT DISTINCT genre
                       FROM top3_genre)
AND        r.avg_rating > 8
GROUP BY   n.NAME
ORDER BY   movie_count DESC,n.name ASC 
LIMIT 3; 

-- End of the solution of Q19

/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


-- Solution of Q20

SELECT n.name,
       Count(*) AS movie_count
FROM   movie AS m
       INNER JOIN role_mapping AS rm
               ON m.id = rm.movie_id
       INNER JOIN names AS n
               ON rm.name_id = n.id
       INNER JOIN ratings AS rt
               ON m.id = rt.movie_id
WHERE  rt.median_rating >= 8
       AND rm.category = 'actor'
GROUP  BY n.name
ORDER  BY movie_count DESC
LIMIT  2;  

-- End of the solution of Q20


/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

-- Solution of Q21

WITH production_company_rank
     AS (SELECT m.production_company,
                Sum(rt.total_votes) AS vote_count,
                RANK() OVER(ORDER BY Sum(rt.total_votes) DESC) AS prod_comp_rank
         FROM   movie AS m
                INNER JOIN ratings AS rt
                        ON m.id = rt.movie_id
         GROUP  BY m.production_company)
SELECT *
FROM   production_company_rank
WHERE  prod_comp_rank <= 3;  

-- End of the solution of Q21


/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Solution of Q22

SELECT     n.name,
           Sum(rt.total_votes) AS total_votes,
           Count(m.id) AS movie_count,
           Round(Sum(rt.avg_rating * rt.total_votes)/Sum(rt.total_votes),2) AS actor_avg_rating,
           Rank() OVER(ORDER BY Round(Sum(rt.avg_rating * total_votes)/Sum(total_votes),2) DESC, Sum(rt.total_votes) DESC) AS actor_rank
FROM       names AS n
INNER JOIN role_mapping AS rm
ON         n.id = rm.name_id
INNER JOIN movie AS m
ON         m.id = rm.movie_id
INNER JOIN ratings AS rt
ON         rt.movie_id = m.id
WHERE      rm.category = 'actor'
AND        Upper(m.country) LIKE '%INDIA%'
GROUP BY   n.name
HAVING     Count(m.id) >=5 
LIMIT 1;

-- End of the solution of Q22

-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:


-- Solution of Q23

 SELECT     n.name,
           Sum(rt.total_votes) AS total_votes,
           Count(m.id) AS movie_count,
           Round(Sum(rt.avg_rating * rt.total_votes)/Sum(rt.total_votes),2)AS actress_avg_rating,
           Rank() OVER(ORDER BY Round(Sum(rt.avg_rating * total_votes)/Sum(total_votes),2) DESC, Sum(rt.total_votes) DESC) AS actress_rank
FROM       names AS n
INNER JOIN role_mapping AS rm
ON         n.id = rm.name_id
INNER JOIN movie AS m
ON         m.id = rm.movie_id
INNER JOIN ratings AS rt
ON         rt.movie_id = m.id
WHERE      rm.category = 'actress'
AND        Upper(m.country) LIKE '%INDIA%'
AND        Upper(m.languages) LIKE '%HINDI%'
GROUP BY   n.name
HAVING     Count(m.id) >=3
LIMIT 5; 

-- End of the solution of Q23


/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:


-- Solution of Q24

SELECT m.id,
       m.title,
       m.year,
       rt.avg_rating,
       CASE
         WHEN rt.avg_rating > 8 THEN 'Superhit movies'
         WHEN rt.avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
         WHEN rt.avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
         ELSE 'Flop movies'
       END AS 'avg_rating_category'
FROM   movie AS m
       INNER JOIN ratings AS rt
               ON m.id = rt.movie_id
       INNER JOIN genre AS gn
               ON rt.movie_id = gn.movie_id
WHERE  gn.genre = 'Thriller'; 

-- End of the solution of Q24


/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:


-- Solution of Q25


 SELECT gn.genre,
       Round(Avg(duration), 2)AS avg_duration,
       
       /* since the order for the running total calculation is not specified in the question,
          assuming that running total shall be calculated in ascending order of genre ascending
          as shown in the following step*/
       
       Round(SUM(Avg(duration)) over(ORDER BY gn.genre ASC ROWS unbounded preceding),2)
       AS running_total_duration,
       
       /* since the frame for moving average calculation is not specified in question, 
          assuming a frame of 5 rows including the current row for the calculation
          as shown in the following step*/
       
       Round(Avg(Avg(duration)) over(ORDER BY gn.genre ROWS 4 preceding),2)            
       AS moving_avg_duration

FROM   movie AS m
       inner join genre AS gn
               ON m.id = gn.movie_id
GROUP  BY gn.genre;  

-- End of the solution of Q25


-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies

-- Solution of Q26

 WITH top3_genre AS
  (
           SELECT   genre
           FROM     genre
           GROUP BY genre
           ORDER BY count(*) DESC
           LIMIT    3 ),
  
movie_with_unified_curreny AS
  (
         SELECT *,
                CASE
                       WHEN worlwide_gross_income LIKE '%$%' THEN 
                            cast(trim(REPLACE(worlwide_gross_income,'$','')) AS FLOAT)
                       WHEN worlwide_gross_income LIKE '%INR%' THEN 
                            cast(trim(REPLACE(worlwide_gross_income,'INR','')) AS FLOAT)/75.78
                END AS worlwide_gross_income_in_usd
         
         /* the world_wide_gross_income column basically holds string values in both '$' and 'INR'
         it is important to convert them to a unified corrency (say $) before applying the rank() on the world_wide_gross_income column.
         Here the case when constrauct unifies the currency string into dollars as a standard with float data type.
         to achive this goal, a combination of replace, trim, and cast functions are used*/
         
         FROM   movie),

movie_ranking AS
  (
             SELECT     gn.genre,
                        muc.year,
                        muc.title,
                        concat('$',muc.worlwide_gross_income_in_usd)AS worldwide_gross_income,
                        -- for the purpose of the display(as given in the format) the income_value is concatinated with $ symbol
                        rank() over(ORDER BY muc.worlwide_gross_income_in_usd DESC) AS movie_rank
             
             FROM       movie_with_unified_curreny AS muc
             INNER JOIN genre AS gn
             ON         muc.id = gn.movie_id
             WHERE      gn.genre IN
                                     (
                                     SELECT DISTINCT genre
                                     FROM top3_genre))

SELECT *
FROM   movie_ranking
WHERE  movie_rank <=5; 

-- End of the solution of Q26


-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:


-- Solution of Q27


SELECT     m.production_company,
           Count(*) AS movie_count,
           Row_number() OVER(ORDER BY Count(*) DESC) AS prod_comp_rank
FROM       movie AS m
INNER JOIN ratings AS rt
ON         m.id = rt.movie_id
WHERE      rt.median_rating >=8
AND        m.production_company IS NOT NULL
AND        position(',' IN m.languages)>0
GROUP BY   m.production_company 
LIMIT 2;

-- End of the solution of Q27


-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:


-- Solution of Q28


SELECT     n.name,
           Sum(rt.total_votes) AS total_votes,
           Count(*) AS movie_count,
           Sum(rt.avg_rating * rt.total_votes)/Sum(rt.total_votes) AS actress_avg_rating,
           DENSE_RANK() OVER(ORDER BY Sum(rt.avg_rating * rt.total_votes)/Sum(rt.total_votes) DESC, Sum(rt.total_votes) DESC) AS actress_rank
           
		   /* To get the aggregated 'average-rating' of the actress, 
           we have find out the 'weighted-average' of the 'avg_rating' of movie with total_votes casted against the movie as the weight.
           the above mentioned calculation is applied in the 1)actress_avg_rating and 2)actress_rank columns*/
           
FROM       movie AS m
INNER JOIN ratings AS rt
ON         m.id = rt.movie_id
INNER JOIN role_mapping AS rm
ON         m.id = rm.movie_id
INNER JOIN names AS n
ON         rm.name_id = n.id
INNER JOIN genre AS gn
ON         m.id = gn.movie_id
WHERE      rm.category = 'actress'
AND        rt.avg_rating > 8
AND        gn.genre LIKE '%Drama%'
GROUP BY   n.id,n.name 
LIMIT 3;

-- End of the solution of Q28


/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

-- Solution of Q29

WITH director_movie_dates AS
(
           SELECT     d.name_id,
                      m.id,
                      m.date_published,
                      LEAD(m.date_published,1) OVER(partition BY d.name_id ORDER BY m.date_published, m.id) AS next_movie_date
           FROM       director_mapping AS d
           INNER JOIN movie AS m
           ON         m.id = d.movie_id 

), 

avg_date_diff_for_director AS

(
         SELECT   name_id,
                  Avg(Datediff(next_movie_date,date_published)) AS avg_diff_date
         FROM     director_movie_dates
         GROUP BY name_id 
)

SELECT     d.name_id,
           n.name,
           Count(m.id) AS number_of_movies,
           Round(Avg(avg_dd.avg_diff_date),0) AS avg_inter_movie_days,
           Round(Avg(r.avg_rating),2) AS avg_rating,
           Sum(r.total_votes) AS total_votes,
           Min(r.avg_rating) AS min_rating,
           Max(r.avg_rating) AS max_rating,
           Sum(m.duration) AS total_duration

FROM       director_mapping AS d
INNER JOIN names AS n
ON         d.name_id = n.id
INNER JOIN movie AS m
ON         m.id = d.movie_id
INNER JOIN ratings AS r
ON         m.id = r.movie_id
LEFT JOIN  avg_date_diff_for_director AS avg_dd
ON         d.name_id = avg_dd.name_id
GROUP BY   d.name_id,
           n.name
ORDER BY   Count(m.id) DESC,
           avg_rating DESC 
LIMIT 9;

-- End of the solution of Q29

-- Thank you so much