privaterooms = {}
invites = {}

addSecondaryHook(function(client, id, prot)
	local chan = prot.chan()
	if chan ~= "null" and privaterooms[chan] then
		--Joining an old private channel, clear list
		if not rooms[chan] then privaterooms[chan]=nil return end
		
		if invites[client.nick] ~= chan then
			serverMsg(client, "That channel is invite only, join failed.")
			return true
		end
	end
end,"Join_Chan")


function commandHooks.invite(client, msg, msgsplit)
	local to = msgsplit[1]
	local channel = client.room
	local sent = false
	if to and channel and client.nick and to ~= client.nick then
		for k, otherclient in pairs(clients) do
			if otherclient.nick == to and otherclient.room ~= channel then
				serverMsg(otherclient, client.nick.." has invited you to /join "..channel..".")
				serverMsg(client, "Invite sent.")
				invites[otherclient.nick] = channel
				sent = true
			end
		end
	end
	if not sent then
		serverMsg(client, "Invite not sent.")
	end
	return true
end

function commandHooks.private(client, msg, msgsplit)
	if client.room and client.room ~= "null" and rooms[client.room] and clients[rooms[client.room][1]] and clients[rooms[client.room][1]].nick == client.nick then
		privaterooms[client.room] = not privaterooms[client.room]
		if privaterooms[client.room] then
			serverMsg(client, "This room is now private, use /invite to invite users.")
			invites[client.nick] = client.room
		else
			serverMsg(client, "This room is now joinable by anyone.")
		end
	else
		serverMsg(client, "You can't modify this room's private status.")
	end
	return true
end