
----- BEGIN GITHUB NOTE -----[[

EVERY FILE AND FOLDER IN THIS DIRECTORY SHOULD BE A CHILD OF THIS FILE IN ROBLOX.

-----  END GITHUB NOTE  ------]]

--// API
--[[

Methods:
	:GetService(string serviceName) -> Service
		>	Returns a required Service called 'serviceName'. Will error if there is not a service named 'serviceName'.
	
	:GetExtension(string extensionName) -> Extension
		>	Returns a required Extension called 'extensionName'. Will error if there is not an extension called 'extensionName'.

]]

--// Variables

local ExtendedLibrary = {}

local services = script:WaitForChild("Services")
local extensions = script:WaitForChild("Extensions")

--// Public Methods

function ExtendedLibrary:GetService(serviceName)
	assert(services:FindFirstChild(serviceName), serviceName .. " is not a valid service of the ExtendedLibrary services! <ExtendedLibrary:GetService()>")
	
	return require(services[serviceName])	
end


function ExtendedLibrary:GetExtension(extensionName)
	assert(extensions:FindFirstChild(extensionName), extensionName .. " is not a valid extension of the ExtendedLibrary extensions! <ExtendedLibrary:GetService()>")
	
	return require(extensions[extensionName])
end

--// Return

return ExtendedLibrary
