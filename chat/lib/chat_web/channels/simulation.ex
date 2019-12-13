defmodule Sim do
  require Logger

  def start(numUsers,nTweets) do
    numToFollow = round(numUsers/2)
    userList = Enum.to_list(1..numUsers)
    listToFollow = getRandomList(userList, numToFollow)

    #Simulation functions
    startTime = System.system_time(:millisecond)
    create_users(numUsers,nTweets)
    timeDiff = System.system_time(:millisecond) - startTime
    stat1 = "Created #{numUsers}users in #{timeDiff}ms.\n"

    startTime = System.system_time(:millisecond)
    subscribeAllUsersTo(userList, listToFollow)
    timeDiff = System.system_time(:millisecond) - startTime
    stat2 = "Every user followed #{numToFollow} users. Completed in #{timeDiff}ms.\n"

    startTime = System.system_time(:millisecond)
    tweetRandom(userList,nTweets-2)
    tweetwithHashtag(userList,"#COP5615 is great")
    _usersMentioned = tweetToRandUser(userList,userList)
    timeDiff = System.system_time(:millisecond) - startTime
    stat3 = "Every user tweeted #{nTweets} times.Total number of tweets: #{(numUsers)*nTweets}. Completed in #{timeDiff}ms"
    [stat1,stat2,stat3]
  end

  def create_users(0,_nTweets) do
   "Created all the users"
  end

  def create_users(numUsers,nTweets) do
    userId =  Integer.to_string(numUsers)
    :ets.insert(:userTable,{userId,"a"})
    :ets.insert(:userSockets,{userId,[]})
    :ets.insert(:allUsers,{userId})
    :ets.insert(:following,{userId,[]})
    :ets.insert(:followers,{userId,[]})
    :ets.insert(:tweetsMade,{userId,[]})
    :ets.insert(:myHome,{userId,[]})

    create_users(numUsers-1,nTweets)
  end

  def getRandomList(_userList, 0) do
    []
  end

  def getRandomList(userList, numberLeft) do
    curUser = getRandomUser(nil,userList)
    [curUser|getRandomList(List.delete(userList,curUser), numberLeft-1)]
  end

  def getRandomUser(userId, userList) do
    cond do
      userId == nil -> Enum.random(userList)
      true -> List.delete(userList, userId)
    end
  end

  def subscribeAllUsersTo([], _listToSubscribe) do
    []
  end

  def subscribeAllUsersTo(userList, listToSubscribe) do
    [head|tail] = userList
    simulateSubscribe(head, listToSubscribe)
    subscribeAllUsersTo(tail, listToSubscribe)
  end

  def simulateSubscribe(_userId, []) do
    []
  end

  def simulateSubscribe(userId, listToSubscribe) do
      [toFollowId|tail] = listToSubscribe
      if toFollowId !=userId do
        DDHandler.add_followers(Integer.to_string(userId),Integer.to_string(toFollowId))
      end
      simulateSubscribe(userId, tail)
  end

  def tweetRandom([],_nTweets) do
    []
  end

  def tweetRandom(userList,nTweets) do
    [userId|tail] = userList
    simulateRandTweetsFor(userId,nTweets)
    tweetRandom(tail,nTweets)
  end

  def simulateRandTweetsFor(_userId,0) do
    []
  end

  def simulateRandTweetsFor(userId,nTweetsLeft) do
    tweet = "Random tweet No #{nTweetsLeft}."
    DDHandler.handle_tweet(Integer.to_string(userId), tweet<>" -Tweet by #{userId}")
    simulateRandTweetsFor(userId,nTweetsLeft-1)
  end

  def tweetwithHashtag([],_tweet) do
    []
  end

  def tweetwithHashtag(userList,tweet) do
    [userId|tail] = userList
    DDHandler.handle_tweet(Integer.to_string(userId), tweet<>" -Tweet by #{userId}")
    tweetwithHashtag(tail,tweet)
  end

  def tweetToRandUser([],_userList) do
    []
  end

  def tweetToRandUser(usersLeft,userList) do
    [userId|tail] = usersLeft
    toUser = Enum.random(userList)
    tweet = "Hello there, @#{toUser}."
    DDHandler.handle_tweet(Integer.to_string(userId), tweet<>" -Tweet by #{userId}")
    [toUser|tweetToRandUser(tail,usersLeft)]
  end
end
