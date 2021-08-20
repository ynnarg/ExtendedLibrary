
----- BEGIN GITHUB NOTE -----[[

EVERY FILE AND FOLDER IN THIS DIRECTORY SHOULD BE A CHILD OF THIS FILE IN ROBLOX.
THIS FILE IS A MODULESCRIPT.

-----  END GITHUB NOTE  ------]]

--// API
--[[

Methods:
	:GetService(string serviceName) -> Service
		>	Returns a required Service called 'serviceName'. Will error if there is not a service named 'serviceName'.
	
	:GetExtension(string extensionName) -> Extension
		>	Returns a required Extension called 'extensionName'. Will error if there is not an extension called 'extensionName'.
	
	:GetGlobal(string globalName) -> Global
		>	Returns a required Global called 'globalName'. Will error if there is not a global called 'globalName'.

]]

--// Variables

local ExtendedLibrary = {}

local services = script:WaitForChild("Services")
local extensions = script:WaitForChild("Extensions")
local globals = script:WaitForChild("Globals")

--// Public Methods

function ExtendedLibrary:GetService(serviceName)
	assert(services:FindFirstChild(serviceName), serviceName .. " is not a valid service of ExtendedLibrary! <ExtendedLibrary:GetService()>")
	
	return require(services[serviceName])	
end


function ExtendedLibrary:GetExtension(extensionName)
	assert(extensions:FindFirstChild(extensionName), extensionName .. " is not a valid extension of ExtendedLibrary! <ExtendedLibrary:GetExtension()>")
	
	return require(extensions[extensionName])
end


function ExtendedLibrary:GetGlobal(globalName)
	assert(globals:FindFirstChild(globalName), globalName .. " is not a valid global of ExtendedLibrary! <ExtendedLibrary:GetGlobal()>")
	
	return require(globals[globalName])
end

--// Return

return ExtendedLibrary
