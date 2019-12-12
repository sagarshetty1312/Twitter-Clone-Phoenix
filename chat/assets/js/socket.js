import {Socket} from "phoenix"

let socket = new Socket("/socket", { params: { token: window.userToken } })

socket.connect()

let channel = socket.channel('room:lobby', {}); // connect to chat "room"


//testing how this works
let ul = document.getElementById('msg-list');        // list of messages.
let name = document.getElementById('name');          // name of message sender
let msg = document.getElementById('msg');            // message input field

// "listen" for the [Enter] keypress event to send a message:
msg.addEventListener('keypress', function (event) {

    if (event.keyCode == 13 && msg.value.length > 0) { // don't sent empty msg.
        channel.push('shout', { // send the message to the server on "shout" channel
            name: name.value,     // get value of "name" of person sending the message
            message: msg.value    // get message text (value) from msg input field.
        });
        msg.value = '';         // reset the message input field for next message.
    }
});

channel.on('shout', function (payload) { // listen to the 'shout' event
    let li = document.createElement("li"); // create new list item DOM element
    let name = payload.name || 'guest';    // get name from payload or set default
    li.innerHTML = '<b>' + name + '</b>: ' + payload.message; // set li contents
    ul.appendChild(li);                    // append to list
});
//testing hos this works

var username = '';
//functionality
$(".rest").hide();

//calls to server

//eventlisteners

document.getElementById("login").addEventListener("click", function () {
    username = $("#inUsername").val()
    channel.push('loginUser', { username: $("#inUsername").val(), password:$("#inPassword").val()})
});

document.getElementById("register").addEventListener("click", function () {
    username = $("#inUsername").val();
    channel.push('registerUser', { username: $("#inUsername").val(), password: $("#inPassword").val() });
});

document.getElementById("tweet").addEventListener("click", function(){
    let tweet = $("#tweetText").val();
    $("#tweetText").val('')
    channel.push('tweet',{username: username, tweet: tweet});
});

document.getElementById("follow").addEventListener("click",function(){
    let tofollowUsernmae = $('#toFollowUsername').val();
    $('#toFollowUsername').val('')
    channel.push('addFollower',{username: username,toFollow: tofollowUsernmae});
});

document.getElementById('queryButton').addEventListener('click',function(){
    let query = $('#queryTweet').val();
    $('#queryTweet').val('')
    channel.push('searchQuery', {username: username, query: query});
});





//responses
channel.on("Login",function(payload){
    if(payload["status"] == "success"){
        $(".login").hide();
        $(".rest").show();
    } else {
        window.alert(payload["response"])
    }
});

channel.on("displayAllfoll",function(payload){
    let followersList = payload["followersList"]
    let followingList = payload["followingList"]
    followersList.map(function(follower){
        add_follower(follower)
    });
    followingList.map(function(following){
        add_following(following)
    });

});

channel.on("Registered",function(payload){
    if (payload["status"] == true) {
        $(".login").hide();
        $(".rest").show();
    } else {
        window.alert(payload["response"])
    }
});

function add_follower(newUser){
    var followingList = document.getElementById("followersDisplay");
    var entry = document.createElement('li');
    entry.appendChild(document.createTextNode(newUser));
    followingList.appendChild(entry);
}

function addTweet(tweet){
  var tweetList = document.getElementById("tweetsDisplay");
  var entry = document.createElement('li');
  entry.appendChild(document.createTextNode(tweet));
  tweetList.appendChild(entry);
}

function add_following(newUser){
    var followingList = document.getElementById("followingDisplay");
    var entry = document.createElement('li');
    entry.appendChild(document.createTextNode(newUser));
    followingList.appendChild(entry);
}

channel.on("updateFollowersList",function(payload){
    add_follower(payload["newuser"]);
});

channel.on("LiveTweet",function(payload){
  addTweet(payload["tweet"])
});

function add_query_results(result) {
    var followingList = document.getElementById("query_display");
    var entry = document.createElement('li');
    entry.appendChild(document.createTextNode(result));
    followingList.appendChild(result);
}

channel.on("updateFollowingList",function(payload){
    add_following(payload["newuser"]);
    // let newUser = payload["newuser"]
    // var followingList = document.getElementById("followingDisplay");
    // var entry = document.createElement('li');
    // entry.appendChild(document.createTextNode(newUser));
    // followingList.appendChild(entry);
})

channel.on("queryResult",function(payload){
    let queryStatus = payload["status"];
    if (queryStatus == "success") {
        //success logic
        console.log(payload["result"]);
        add_query_results(payload["result"])
    } else {
        window.alert(payload["response"])
    }
});





//  join the channel.

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket
