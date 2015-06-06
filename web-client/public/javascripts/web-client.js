/*
 *
 * chat-client-web.js
 *
 */

//
// TODO - emits keeps emitting if the chat server is down
//

jQuery(function($) {
    var socket = io.connect('http://localhost:8080');
    var $nickForm = $('#setNick');
    var $nickError = $('#nickError');
    var $nickBox = $('#nickname');
    var $users = $('#users');
    var $messageForm = $('#send-message');
    var $messageBox = $('#message');
    var $chat = $('#chat');
    
    $nickForm.submit(function(e) {
        e.preventDefault();
        socket.emit('new user', $nickBox.val(), function(data) {
            if (data) {
                $('#nickWrap').hide();
                $('#contentWrap').show();
            } else {
                $nickError.html('That username is already taken! Try again.');
            }
        });
        $nickBox.val('');
    });
    
    $messageForm.submit(function(e) {
        e.preventDefault();
        socket.emit('send message', $messageBox.val(), function(data) {
            $chat.append('<span class="error"><b>' + data + '</span><br/>');
        });
        $messageBox.val('');
    });
    
    socket.on('usernames', function(data) {
        var html = '';
        for (i = 0; i < data.length; i++) {
            html += data[i] + '<br/>';
        }
        $users.html(html);
    });
    
    socket.on('new message', function(data) {
        $chat.append('<span class="msg"><b>' + data.nick + ':</b> ' + data.msg + '</span><br/>');
    });
    
    socket.on('whisper', function(data) {
        $chat.append('<span class="whisper"><b>' + data.nick + "[whisper]:</b> " + data.msg + '</span><br/>');
    });
});