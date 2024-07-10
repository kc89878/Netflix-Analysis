------------------------------------------------------------------------------------------------------------------------
--remove duplicates 
--check show_id has duplicates or not
select show_id, COUNT(*) 
from netflix_raw
group by show_id 
having COUNT(*)>1
--no duplicates, set it to primary key

------------------------------------------------------------------------------------------------------------------------
--check title has duplicates or not
select * from netflix_raw
where concat(title, type, duration) in(
select concat(title, type, duration)
from netflix_raw
group by title, type, duration
having COUNT(*)>1
)
order by title
--title have 3 duplicates

------------------------------------------------------------------------------------------------------------------------
--there have multiple value in director, country, cast and listed_in(genre) column, let seperate it in a new table
--create new table

--1. directors
select show_id, trim(value) as director
into netflix_directors
from netflix_raw
cross apply string_split(director,',')

--2. country
select show_id, trim(value) as country
into netflix_country
from netflix_raw
cross apply string_split(country,',')

--3. cast
select show_id, trim(value) as cast
into netflix_cast
from netflix_raw
cross apply string_split(cast,',')

--4. list_in (genre)
select show_id, trim(value) as genre
into netflix_genre
from netflix_raw
cross apply string_split(listed_in,',')

------------------------------------------------------------------------------------------------------------------------
--populate missing values in country columns
insert into netflix_country
select show_id, m.country
from netflix_raw nr

inner join( 
--mapping netflix_country and netflix_directors toghther
select director, country
from netflix_country nc
inner join netflix_directors nd on nc.show_id = nd.show_id
group by director, country
) m on nr.director = m.director --mapping with netflix_raw

where nr.country is NULL

------------------------------------------------------------------------------------------------------------------------
--update the final table by (1.) delete the duplicates (2.) populate missing values (3.)drop columns: director, cast, country, listed_in
with cte as (
select * 
,ROW_NUMBER() over(partition by title, type, duration order by show_id) as rn
from netflix_raw
)
select show_id, type, title, cast(date_added as date) as data_added, release_year, 
rating, case when duration is NULL then rating else duration end as duration, description
into netflix
from cte
where rn = 1
------------------------------------------------------------------------------------------------------------------------
--double check all the table
select * from netflix
select * from netflix_cast
select * from netflix_country
select * from netflix_directors
select * from netflix_genre

--the data cleaning is done
--move on to data analysis
------------------------------------------------------------------------------------------------------------------------