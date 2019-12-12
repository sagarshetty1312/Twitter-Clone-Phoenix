defmodule ChatWeb.RoomChannel do
  use ChatWeb, :channel

  def join("room:lobby", _payload, socket) do
    {:ok,socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # # Add authorization logic here as required.
  # defp authorized(_payload) do
  #   true
  # end

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
        push(socket, "displayAllfoll", %{followersList: allFollowers,followingList: allFollowing})
      else
        push(socket,"Login",%{status: "failed",response: "Incorrect Password"})
      end
    end
    {:noreply,socket}
  end


  def handle_in("tweet",payload,socket) do
    username = payload["username"]
    tweet = payload["tweet"]

    {:noreply,socket}
  end

  def handle_in("retweet",payload,socket) do

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

  def handle_in("getAllTweets",payload,socket) do

  end

  def handle_in("searchQuery",payload,socket) do
    query = payload["query"]
    if String.at(query,0) == "@" do
      #@ logic
      IO.inspect query
    end
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



end
