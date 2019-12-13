defmodule DDHandler do
  require Logger

  def get_followers(userId) do
    [tuple] = :ets.lookup(:followers, userId)
    elem(tuple,1)
  end

  def update_followers_list(toFollowId,userId) do
    followersList = get_followers(toFollowId)
    updatedFollowersList = [userId|followersList]
    :ets.insert(:followers,{toFollowId,updatedFollowersList})
  end

  def get_following(userId) do
    [tuple] =:ets.lookup(:following, userId)
    elem(tuple,1)
  end

  def update_following_list(userId,tofollowID) do
    followingList = get_following(userId)
    updatedFollowingList = [tofollowID|followingList]
    :ets.insert(:following,{userId,updatedFollowingList})
  end


  def getTweetsMade(userId) do
    [tuple] = :ets.lookup(:tweetsMade, userId)
    elem(tuple,1)
  end

  def getHomePageTweets(username) do
    check = :ets.lookup(:myHome, username)
    if check != [] do
      [tuple] = :ets.lookup(:myHome, username)
      elem(tuple,1)
    end
  end

  def insert_tag(tag,tweet) do
    [tuple] =
      if :ets.lookup(:mentionsHashtags, tag) == [] do
        [nil]
      else
        :ets.lookup(:mentionsHashtags, tag)
      end
    if tuple ==nil do
      :ets.insert(:mentionsHashtags,{tag,[tweet]})
    else
      list = elem(tuple,1)
      newList = [tweet|list]
      :ets.insert(:mentionsHashtags,{tag,newList})
    end
  end

  def fetchAllMentionsAndHashtags(key) do
    if :ets.lookup(:mentionsHashtags, key) != [] do
      [{_,list}] = :ets.lookup(:mentionsHashtags, key)
      list
    else
      []
    end
  end

  def find_matches(current_followers,userId) do
    Enum.filter(current_followers,fn(follower)->
      follower == userId
    end)
  end


  def add_followers(userId,tofollowID) do
    if :ets.lookup(:allUsers, tofollowID) != []  do
      #check if follower is already present
      current_followers = get_followers(tofollowID)
      if find_matches(current_followers, userId) == [] do
        update_followers_list(tofollowID,userId)
        update_following_list(userId,tofollowID)
        "yes"
      else
        "no"
      end
    else
      "no"
    end
  end

  def getSocket(username) do
    if :ets.lookup(:userSockets, username) != [] do
      [user_socket_info] = :ets.lookup(:userSockets, username)
      usernameSocket = elem(user_socket_info,1)
      usernameSocket
    else
      nil
    end
  end


<<<<<<< Updated upstream


  # def handle_cast({:tweet,userId,tweet},state) do
  #   [tuple] = :ets.lookup(:tweetsMade, userId)
  #   tweetsList = elem(tuple,1)
  #   updatedTweetsList = [tweet | tweetsList]
  #   :ets.insert(:tweetsMade,{userId,updatedTweetsList})

  #   followers = get_followers(userId)
  #   tweetLive(tweet, followers, userId)
  # #  Enum.each(followers, fn(follower) ->
  # #       send(follower , {:tweet, [tweet] ++ ["-Tweet from user: "] ++ [user_pid] ++ ["forwarded to follower: "] ++ [follower_pid] })
  # #      end)

  #   #hashtags in tweet
  #   hashtagsList = Regex.scan(~r/\B#[a-zA-Z0-9_]+/, tweet) |> Enum.concat
  #   Enum.each(hashtagsList, fn(hashtag)->
  #     insert_tag(hashtag,tweet)
  #   end)

  #   mentionsList = Regex.scan(~r/\B@User[0-9]+/, tweet) |> Enum.concat
  #   Enum.each(mentionsList, fn(mention) ->
  #     insert_tag(mention,tweet)
  #   end)
  #   mentionedUserIds = Enum.map(mentionsList,fn x -> String.slice(x,5..-1) |> String.to_integer end)
  #   validUserIds = checkForExistence(mentionedUserIds)
  #   tweetLive(tweet, validUserIds, userId)
  #   sendAcknowledgement(:userTweet)
  #   {:noreply,state}
  # end


  # def tweetLive(tweet, userList, _userId) do
  #   Enum.each(userList, fn(toUser) ->
  #     [{_,_,state}] = :ets.lookup(:allUsers, toUser)
  #     if state == :online do
  #       GenServer.cast(String.to_atom("User"<>Integer.to_string(toUser)),{:tweetLive,"User#{toUser} received: "<>tweet})
  #     end
  #   end)
  # end

=======
    mentionsList = Regex.scan(~r/\B@[a-zA-Z0-9_]+/, tweet) |> Enum.concat
    mentionedUserIds = Enum.map(mentionsList,fn x -> String.slice(x,1..-1) end)
    Enum.each(mentionsList, fn(mention) ->
      # IO.puts "Inside mention list "<>mention
      insert_tag(mention,tweet)
    end)

    validUserIds = checkForExistence(mentionedUserIds)
    Enum.each(validUserIds, fn(toUser) ->
      updateHome(toUser,tweet)
    end)
    ChatWeb.RoomChannel.tweetLive(tweet, validUserIds, userId)
  end

  def checkForExistence([]) do
    []
  end

  def checkForExistence(mentionedUserIds) do
    [head|tail] = mentionedUserIds
    cond do
      :ets.lookup(:allUsers, head) == [] -> checkForExistence(tail)
      true -> [head | checkForExistence(tail)]
    end
  end


>>>>>>> Stashed changes
end
