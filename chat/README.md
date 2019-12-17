# Project 4.2 - Twitter-Clone using phoenix

## Members
Jayan, Milind - 8168 9617
Jayanth Shetty, Sagar - 4351 7929

## How to run
- Extract the project from 'Jayan_JayanthShetty.zip' and go to the home folder 'Jayan_JayanthShetty\chat'
- Install dependencies with 'mix deps.get'
- Create and migrate your database with 'mix ecto.setup'
- Install Node.js dependencies with 'cd assets' && 'npm install'
- Start Phoenix endpoint with 'mix phx.server'

- Now you can visit localhost:4000 from your browser.

## What is working
- Twitter Engine
- Twitter Clients using WebSockets
- Users following users and following and followers list getting updated
- Users sending tweets
- Tweets displayed live when the user is connected
- Querying tweets based on mentions and hashtags and subscribed to tweets
- Retweets
- Simulation of users taking number_of_users and number_of_tweets as input.

## Simulation details
- Creates as many users as mentioned
- The username for these users is a running sequence of consecutive numbers starting from 1
- The default password for all of these users is 'a'
- Every user follows a random list of number_of_users/2 users
- Every user makes the required number of random tweets that include tweets with hashtag #COP5615 and mentioning other random users

## Demo Video Link
- Please make sure to watch the demo video at the following link:
- https://www.youtube.com/watch?v=QjtvuMouZeI
