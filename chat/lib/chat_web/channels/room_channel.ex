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
        push(socket, "Login", %{status: "success",response: "Login Successfull",username: username})
        #TODO display the tweets when logging in
      else
        push(socket,"Login",%{status: "failed",response: "Incorrect Password"})
      end
    end
    {:noreply,socket}
  end


  def handle_in("tweet",payload,socket) do

  end

  def handle_in("retweet",payload,socket) do

  end

  def handle_in("addFollower",payload,socket) do

  end

  def handle_in("getAllTweets",payload,socket) do

  end

  def handle_in("hashtagsAnd mentions",payload,socket) do

  end



end
