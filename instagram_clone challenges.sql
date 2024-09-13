use ig_clone;
/*Reward users who have been around the longest. */ 

select * from users;

select  username , created_at from users order by created_at
limit 4;

/*What day of the week do most users register on?*/
select date_format(created_at,'%W') as 'day of the week',
count(*) as 'total number of users' from users
group by 1
 order by 2 desc limit 2;


/*We want to target our inactive users with an email campaign.*/
select username from users  left join photos on users.id = photos.user_id
where photos.user_id is not null group by users.username;

/*We're running a new contest to see who can get the most likes on a single photo WHO WON??*/
select users.username ,photos.image_url, photos.id,count(*) as 'most likes' from photos
inner  join likes  on photos.id = likes.photo_id
inner join users on photos.user_id = users.id
group  by 3
order by 4 desc
limit 3;

/*Our Investors want to know...How many times does the average user post?*/
/*total number of photos/total number of users*/

SELECT ROUND((SELECT COUNT(*)FROM photos)/(SELECT COUNT(*) FROM users),2);

/*user ranking by postings higher to lower*/
select users.username ,count(*) as 'total post' from photos
inner join users on photos.user_id = users.id 
group by 1
order by 2 desc; 

/*Total Posts by users */
select sum(total.total_post)
from (select users.username ,count(*) as total_post from photos
inner join users on photos.user_id = users.id 
group by 1) as total;

/*0r */
select count(users.id) as posts  from users 
inner join photos on users.id = photos.user_id
;

/*total numbers of users who have posted at least one time */
select username,count(distinct(users.id)) as posts  from users 
inner join photos on users.id = photos.user_id
group by 1
;

/*A brand wants to know which hashtags to use in a post What are the top 5 most commonly used hashtags?*/
SELECT t.tag_name, COUNT(*) AS total
FROM tags t
LEFT JOIN photo_tags pt ON t.id = pt.tag_id
GROUP BY t.tag_name
ORDER BY total DESC
LIMIT 5;



/*We have a small problem with bots on our site...Find users who have liked every single photo on the site*/

select distinct id, username
from users
where users.id in (
    select user_id from likes
);

/*We also have a problem with celebrities --Find users who have never commented on a photo*/
select distinct(id) ,username from users 
where users.id NOT in (select user_id from comments);



/*Are we overrun with bots and celebrity accounts?
Find the percentage of our users who have either never commented on a photo or have commented on photos before*/
SELECT 
    tableA.total_A AS 'Number Of Users who never commented',
    (tableA.total_A / (SELECT COUNT(*) FROM users)) * 100 AS '% Never Commented',
    tableB.total_B AS 'Number of Users who commented on photos',
    (tableB.total_B / (SELECT COUNT(*) FROM users)) * 100 AS '% Commented'
FROM
    (SELECT COUNT(*) AS total_A
     FROM users
     LEFT JOIN comments ON users.id = comments.user_id
     GROUP BY users.id
     HAVING COUNT(comments.id) = 0) AS tableA
JOIN
    (SELECT COUNT(*) AS total_B
     FROM users
     LEFT JOIN comments ON users.id = comments.user_id
     GROUP BY users.id
     HAVING COUNT(comments.id) > 0) AS tableB;
