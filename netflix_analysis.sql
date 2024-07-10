--Netflix Data Analysis
------------------------------------------------------------------------------------------------------------------------
/*1. For each director count the no of movies and tv shows created by them in separate columns 
     for directors who have created tv shows and movies both? */
select nd.director 
,COUNT(distinct case when n.type = 'Movie' then n.show_id end) as no_of_movies
,COUNT(distinct case when n.type = 'TV Show' then n.show_id end) as no_of_tvshow
from netflix n
inner join netflix_directors nd on n.show_id=nd.show_id
group by nd.director
having COUNT(distinct n.type) > 1

------------------------------------------------------------------------------------------------------------------------
--2. Which five country has highest number of comedy movies? 
select top 5 nc.country , COUNT(distinct ng.show_id) as no_of_movies
from netflix_genre ng
inner join netflix_country nc on ng.show_id = nc.show_id
inner join netflix n on ng.show_id = nc.show_id
where ng.genre = 'Comedies' and n.type = 'Movie'
group by  nc.country
order by no_of_movies desc

------------------------------------------------------------------------------------------------------------------------
--3. For each year (as per date added to netflix), which director has maximum number of movies released?
with cte as (
select nd.director, YEAR(date_added) as date_year, count(n.show_id) as no_of_movies
from netflix n
inner join netflix_directors nd on n.show_id = nd.show_id
where type = 'Movie'
group by nd.director, YEAR(date_added)
)
, cte2 as (
select *
, ROW_NUMBER() over(partition by date_year order by no_of_movies desc, director) as rn
from cte
)
select * from cte2 where rn = 1

------------------------------------------------------------------------------------------------------------------------
--4. What is average duration of movies in each genre?
select ng.genre , avg(cast(REPLACE(duration,' min','') AS int)) as avg_duration
from netflix n
inner join netflix_genre ng on n.show_id = ng.show_id
where type = 'Movie'
group by ng.genre
order by avg_duration

------------------------------------------------------------------------------------------------------------------------
--5. Find the list of directors who have created horror and comedy movies both?
--   Display director names along with number of comedy and horror movies directed by them 
select nd.director
, count(distinct case when ng.genre = 'Comedies' then n.show_id end) as no_of_comedy 
, count(distinct case when ng.genre = 'Horror Movies' then n.show_id end) as no_of_horror
from netflix n
inner join netflix_genre ng on n.show_id = ng.show_id
inner join netflix_directors nd on n.show_id = nd.show_id
where type = 'Movie' and ng.genre in ('Comedies','Horror Movies')
group by nd.director
having COUNT(distinct ng.genre) = 2;
------------------------------------------------------------------------------------------------------------------------
