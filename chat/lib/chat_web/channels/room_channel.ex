defmodule ChatWeb.RoomChannel do
  use ChatWeb, :channel

  def join("room:lobby", _payload, socket) do
    {:ok,socket}
  end


  def handle_in("registerUser",payload,socket) do
    username = payload["username"]
    password = payload["password"]
    bool = :ets.insert_new(:userTable,{username,password})
    response=
      if bool do
        :ets.insert(:userSockets,{username,socket})
        :ets.insert(:allUsers,{username})
        :ets.insert(:following,{username,[]})
        :ets.insert(:followers,{username,[]})
        :ets.insert(:tweetsMade,{username,[]})
        :ets.insert(:myHome,{username,[]})
        "User Registered"
      else
        "User already present"
      end
    push(socket,"Registered",%{status: bool, username: username,response: response})
    {:noreply,socket}
  end

  def handle_in("loginUser",payload,socket) do
    username = payload["username"]
    password = payload["password"]
    check = :ets.lookup(:userTable, username)
    if check == [] do
      push(socket, "Login", %{status: "failed", response: "User not found. Login failed."})
    else
      [{username,dbpassword}] = check
      if password == dbpassword do
        :ets.insert(:userSockets,{username,socket})
        push(socket, "Login", %{status: "success",response: "Login Successfull",username: username})
        #TODO display the tweets when logging in
        allFollowers = DDHandler.get_followers(username)
        allFollowing = DDHandler.get_following(username)
        allTweets = DDHandler.getHomePageTweets(username)
        push(socket, "displayAllfoll", %{followersList: allFollowers,followingList: allFollowing,tweetsList: allTweets,username: username})
      else
        push(socket,"Login",%{status: "failed",response: "Incorrect Password"})
      end
    end
    {:noreply,socket}
  end


  def handle_in("tweet",payload,socket) do
    username = payload["username"]
    tweet = payload["tweet"]
    IO.inspect tweet
    DDHandler.handle_tweet(username, tweet<>" -Tweet by #{username}")
    {:noreply,socket}
  end

  def handle_in("retweet",payload,socket) do
    username = payload["username"]
    tweet = payload["tweet"]
    DDHandler.handle_tweet(username, tweet<>" -Retweet by #{username}")
    {:noreply,socket}
  end

  def handle_in("addFollower",payload,socket) do
    username = payload["username"]
    toFollowUsername = payload["toFollow"]
    response = DDHandler.add_followers(username,toFollowUsername)
    #fix bug
    if response == "yes" do
      usernameSocket = DDHandler.getSocket(username)
      toFollowUsernameSocket =  DDHandler.getSocket(toFollowUsername)
      if usernameSocket != nil do
        IO.inspect toFollowUsername
        push(usernameSocket,"updateFollowingList",%{newuser: toFollowUsername})
      end
      if toFollowUsernameSocket != nil do
        IO.inspect username
        push(toFollowUsernameSocket,"updateFollowersList",%{newuser: username})
      end
    end
    {:noreply,socket}
  end


  def handle_in("searchQuery",payload,socket) do
    query = payload["query"]
    cond do
      String.at(query,0) in ["@","#"]  ->
        #@n# logic
        queryResult = DDHandler.fetchAllMentionsAndHashtags(query)
        push(socket,"queryResult",%{status: "success",response: "Correct query",result: queryResult})
      true ->
        push(socket,"queryResult",%{status: "fail",response: "Invalid Query. Please enter a query with a hashtag or mention"})
    end
    {:noreply,socket}
  end

  def handle_in("simulate",payload,socket) do
    nUsers = String.to_integer(payload["nUsers"])
    nTweets = String.to_integer(payload["nTweets"])
    responseString = Sim.start(nUsers, nTweets)
    IO.inspect responseString
    push(socket,"simulation",%{response: responseString})
    {:noreply,socket}
  end

  def tweetLive(tweet, userList, _userId) do
    Enum.each(userList, fn(toUser) ->
      [tuple] =
        if :ets.lookup(:userSockets, toUser) == [] do
          [nil]
        else
          :ets.lookup(:userSockets, toUser)
        end
      if tuple !=nil do
        userSocket = elem(tuple,1)
        if userSocket !=[] do
          push(userSocket,"LiveTweet",%{username: toUser,tweet: tweet})
        end
      end
    end)
  end

end
