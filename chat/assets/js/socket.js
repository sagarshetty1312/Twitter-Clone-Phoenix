import {Socket} from "phoenix"

let socket = new Socket("/socket", { params: { token: window.userToken } })

socket.connect()
 
let channel = socket.channel('room:lobby', {}); // connect to chat "room"

var username = '';

$(".rest").hide();

//calls to server

//eventlisteners

if (document.getElementById("login")){
    document.getElementById("login").addEventListener("click", function () {
        username = $("#inUsername").val()
        channel.push('loginUser', { username: $("#inUsername").val(), password: $("#inPassword").val() })
    });
}

if (document.getElementById("register")) {
    document.getElementById("register").addEventListener("click", function () {
    username = $("#inUsername").val();
    channel.push('registerUser', { username: $("#inUsername").val(), password: $("#inPassword").val() });
    });
}

if (document.getElementById("tweet")){
    document.getElementById("tweet").addEventListener("click", function () {
        let tweet = $("#tweetText").val();
        $("#tweetText").val('');
        channel.push('tweet', { username: username, tweet: tweet });
    });
}

if (document.getElementById("follow")){
    document.getElementById("follow").addEventListener("click", function () {
        let tofollowUsernmae = $('#toFollowUsername').val();
        $('#toFollowUsername').val('')
        channel.push('addFollower', { username: username, toFollow: tofollowUsernmae });
    });
}

if (document.getElementById("queryButton")){
    document.getElementById('queryButton').addEventListener('click', function () {
        let query = $('#queryTweet').val();
        $('#queryTweet').val('')
        // console.log(query);
        channel.push('searchQuery', { username: username, query: query });
    });
}

if (document.getElementById("simulate")){
    document.getElementById("simulate").addEventListener("click", function () {
        let numberUsers = $('#numberUsers').val();
        let numberTweets = $('#numberTweets').val();
        channel.push('simulate', { nUsers: numberUsers, nTweets: numberTweets });
    });
}



   


//responses
channel.on("Login",function(payload){
    if(payload["status"] == "success"){
        $(".login").hide();
        $(".rest").show();
        let username = payload["username"];
        let heading = document.getElementById("mainHeading");
        var t = document.createTextNode(username);
        heading.appendChild(t);
    } else {
        window.alert(payload["response"])
    }
});

channel.on("displayAllfoll",function(payload){
    let followersList = payload["followersList"]
    let followingList = payload["followingList"]
    let tweetsList = payload["tweetsList"]
    let username = payload["username"]
    followersList.map(function(follower){
        add_follower(follower)
    });
    followingList.map(function(following){
        add_following(following)
    });
    tweetsList.map(function(tweet){
        addTweet(username,tweet)
    });

});

channel.on("Registered",function(payload){
    if (payload["status"] == true) {
        // window.location.href = "/home/" + payload["username"]
        $(".login").hide();
        $(".rest").show();
        let username = payload["username"];
        let heading = document.getElementById("mainHeading");                
        var t = document.createTextNode(username);   
        heading.appendChild(t);
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

function add_following(newUser){
    var followingList = document.getElementById("followingDisplay");
    var entry = document.createElement('li');
    entry.appendChild(document.createTextNode(newUser));
    followingList.appendChild(entry);
}

channel.on("updateFollowersList",function(payload){
    add_follower(payload["newuser"]);
});

function add_query_results(results) {

    var followingList = document.getElementById("query_display");
    var check_list = document.getElementById("check")
    if (check_list) {
        followingList.removeChild(check_list);
    }
    results.map(function (result) {
        var entry = document.createElement('li');
        entry.setAttribute("id", "check");
        entry.appendChild(document.createTextNode(result));
        followingList.appendChild(entry);
    });

    
}


channel.on("updateFollowingList",function(payload){
    add_following(payload["newuser"]); 
});

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


function addTweet(myUsername, tweet) {
    var tweetList = document.getElementById("tweetsDisplay");
    var entry = document.createElement('li');
    var button = document.createElement("button");
    button.innerHTML = "Retweet";
    button.setAttribute("id","retweetButton");
    button.setAttribute("tweet",tweet);
    button.setAttribute("class", "btn btn-default btn-sm glyphicon glyphicon-retweet");
    button.addEventListener("click",function(){
        channel.push("retweet", { tweet: tweet, username: myUsername})
    });
    entry.appendChild(document.createTextNode(tweet));
    entry.appendChild(button);
    tweetList.appendChild(entry);    
}

channel.on("LiveTweet", function (payload) {
    let myUsername = payload["username"];
    let tweetText = payload["tweet"];
    addTweet(myUsername, tweetText);
});


channel.on("simulation",function(payload) {
    let responseList = payload["response"];
    console.log(responseList)
    var simDisplay = document.getElementById("simResult");
    responseList.map(function (stat) {
        var entry = document.createElement('li');
        entry.appendChild(document.createTextNode(stat));
        simDisplay.appendChild(entry)
    });
    document.getElementById("simulate").disabled = true;
});





//  join the channel.

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket
