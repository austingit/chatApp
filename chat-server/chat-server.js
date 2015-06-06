/*
 *
 * chat-server.js
 *
 */

module.exports = function(io) {
    
    var users = {};
    
    io.sockets.on('connection', function(socket) {

        socket.on('get usernames', function(data, callback) {
            updateNicknames();
        });

        socket.on('new user', function(data, callback) {
            //if (nicknames.indexOf(data) != -1) {
                if (data in users) {
                    callback(false);
                } else {
                    callback(true);

                    // store the username in socket.nickname because it will be available to other functions
                    socket.nickname = data;

                    //nicknames.push(socket.nickname);
                    users[socket.nickname] = socket;
            
                    //io.sockets.emit('usernames', nicknames);
                    updateNicknames();
                }
            });

            function updateNicknames() {
                //io.sockets.emit('usernames', nicknames);
                io.sockets.emit('usernames', Object.keys(users));
            }

            socket.on('send message', function(data, callback) {
        
                var msg = data.trim();
                if (msg.substr(0,3) === '/w ') {
                    msg = msg.substr(3);
                    var ind = msg.indexOf(' ');
                    if (ind !== -1) {
                        var name = msg.substr(0, ind);
                        var msg = msg.substr(ind + 1);
                        if (name in users) {
                            users[name].emit('whisper', { msg:msg, nick: socket.nickname });
                    
                            // also send the message to myself
                            users[socket.nickname].emit('whisper', { msg:msg, nick: socket.nickname });
                    
                            //console.log("whisper");                    
                        } else {
                            callback('Error! Enter a valid user.');
                        }
                    } else {
                        callback('Error! Please enter a message for your whisper.');
                    }
                } else {
        
                    // send message to everyone including me
                    //io.sockets.emit('new message', { msg:data, nick: socket.nickname });
                    io.sockets.emit('new message', { msg:msg, nick: socket.nickname });

                    // send mesasge to everyone except me
                    //socket.broadcast.emit('new message', data);
                }
            });
    
            socket.on('disconnect', function(data) {
                if(!socket.nickname) return;
        
                //nicknames.splice(nicknames.indexOf(socket.nickname), 1);
                delete users[socket.nickname];
                
                updateNicknames();
            });
        });
}