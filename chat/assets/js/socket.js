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
    channel.push('tweet',{username: username, tweet: tweet});
});

document.getElementById("follow").addEventListener("click",function(){
    let tofollowUsernmae = $('#toFollowUsername').val();
    $('#toFollowUsername').val("");
    channel.push('addFollower',{username: username,toFollow: tofollowUsernmae});
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

channel.on("Registered",function(payload){
    if (payload["status"] == true) {
        $(".login").hide();
        $(".rest").show();
    } else {
        window.alert(payload["response"])
    }
});

channel.on("updateFollowersList",function(payload){

});

channel.on("updateFollowingList",function(payload){

})



//  join the channel.

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket
