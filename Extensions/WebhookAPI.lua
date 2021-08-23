
----- BEGIN GITHUB NOTE -----[[

THIS FILE IS A MODULESCRIPT.

----- END GITHUB NOTE -----]]

--// API
--[[

Methods:
	.new(string webhook) -> Webhook
		>	Creates a new Webhook object using the 'webhook' string argument.
	
	.Embed(string title, string description, string url, variant<number, Color3> color, ...dict<string name, string value>) -> Embed
		>	Creates a new Embed.

Objects:
	Webhook => {
	Public:
		:Fire(...variant<string, Embed>)
		
	Private:
		string _url
		
	}

]]

--// Services

local HttpService = game:GetService("HttpService")

--// Variables

local WebhookAPI = {}
WebhookAPI.__index = WebhookAPI

--// Methods

function WebhookAPI.new(url)
	assert(type(url) == "string", tostring(url) .. " is not a valid Webhook URL! <WebhookAPI.new()>")
	
	return {
		_url = url,
		
		Fire = function(self, ...)
			local send = {}
			local args = {...}
			for _,sendover in pairs(args) do
				if type(sendover) == "table" then
					assert(sendover._TYPE == "EMBED", tostring(sendover) .. " is not a valid sendover message! <WebhookAPI.Webhook:Fire()>")
				else
					assert(type(sendover) == "string", tostring(sendover) .. " is not a valid sendover message! <WebhookAPI.Webhook:Fire()>")
				end
				
				if type(sendover) == "table" then
					send.embeds = send.embeds or {}
					table.insert(send.embeds, sendover)
				else
					send.content = sendover
				end
			end
			
			send = HttpService:JSONEncode(send)
			assert(type(send) == "string", tostring(send) .. " is not a valid sendover message! <WebhookAPI.Webhook:Fire()>")
			
			HttpService:PostAsync(self._url, HttpService:JSONEncode(send))
		end,
	}
end


function WebhookAPI.Embed(title, description, url, color, ...)
	local fields = {...}
	
	assert(type(title) == "string", tostring(title) .. " is not a valid Embed title! <WebhookAPI.Embed()>")
	assert(type(description) == "string", tostring(description) .. " is not a valid Embed description! <WebhookAPI.Embed()>")
	assert(type(url) == "string", tostring(url) .. " is not a valid Embed url! <WebhookAPI.Embed()>")
	
	if typeof(color) == "Color3" then
		
	end
	
	color = tonumber(color)
	assert(type(color) == "number", tostring(color) .. " is not a valid Embed color! <WebhookAPI.Embed()>")
	
	for _,field in pairs(fields) do
		assert(type(field.name) == "string", tostring(field.name) .. " is not a valid Field name! <WebhookAPI.Embed()>")
		field.value = tostring(field.value)
		assert(type(field.value) == "string", tostring(field.value) .. " is not a valid Field value! <WebhookAPI.Embed()>")
	end
	
	return {
		title = title,
		description = description,
		url = url,
		color = color,
		fields = fields
	}
end

--// Return

assert(game:GetService("RunService"):IsServer(), "WebhookAPI can only be required from the server.")

return WebhookAPI
