commandHooks = {}
local secondaryHooks = {}
local currentHook = nil
local unpack = unpack or table.unpack
--Load all hooks in hooks/ here (copied from Crackbot)
function loadhook(name)
	currentHook = name
	if secondaryHooks[currentHook] then
		for i,v in ipairs(secondaryHooks[currentHook]) do
			removeHook(v["name"], v["func"])
		end
	end
	secondaryHooks[currentHook] = {}
	local succ,err = pcall(dofile, "hooks/"..name)
	local ret = ""
	if not succ then
		ret = "Error loading hooks/"..name..": "..err
	else
		ret = "Loaded hooks/"..name
	end
	print(ret)
	currentHook = nil
	return ret
end
function addSecondaryHook(f, cmd, priority)
	local function h(client,id,prot)
		local s,e = pcall(f,client,id,prot)
		if not s then
			if crackbot then
				crackbot:send("Hook error: "..e.."\n")
			else
				print("Hook error: "..e)
			end
		elseif e then
			return true
		end
	end
	priority = priority or 5
	addHook(cmd, h, priority)
	if currentHook then
		table.insert(secondaryHooks[currentHook], {["name"]=cmd, ["func"]=h})
	end
end

function loadallhooks()
	local listcmd = WINDOWS and "dir /b" or "ls"
	local pluginList = io.popen(listcmd.." \"hooks\"")
	commandHooks = {}
	for file in pluginList:lines() do
		if file:sub(#file-3,#file) == ".lua" then
			loadhook(file)
		end
	end
end
loadallhooks()

--function used in some hooks
function countTable(t)
	local c = 0
	for k,v in pairs(t) do
		c = c + 1
	end
	return c
end

--split a string into words
function getArgs(msg)
	if not msg then
		return {}
	end
	local args = {}
	for word in msg:gmatch("([^%s%c]+)") do
		table.insert(args,word)
	end
	return args
end

--Chat hook for extra commands
addSecondaryHook(function(client, id, prot)
	local msg = prot.msg()
	local split = getArgs(msg)
	if #split > 0 and split[1]:sub(1,1) == "/" then
		local command = split[1]:sub(2)
		local msg = msg:sub(#command+3)
		table.remove(split, 1)
		if commandHooks[command] and type(commandHooks[command]) == "function" and commandHooks[command](client, msg, split) then
			return true
		end
	end
end,"User_Chat")
