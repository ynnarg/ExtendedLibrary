
--// API
--[[

Methods:
	.new(function func, ...any) -> Thread
		>	Creates and runs a new Thread object.
	
	.join(variant<Thread, ...Thread>) -> variant<any[], any[][]>
		>	Yields until the Thread/s have all stopped executing. If only one Thread was provided, it will return 'Thread.Return', if more than one was provided,
			it will return an array of all the Threads' 'Thread.Return' values in consecutive order.

Objects:
	Thread => {
	public:
		Finished -> bool
			>	Indicates whether or not the Thread has finished executing.
			
		OnFinished -> RBXScriptSignal<...any>
			>	Fires when the Thread has finished executing, fires with the return of the function the Thread executed.
		
		Return -> any[]
			>	Contains an array of the returns from the function executed.
		
	private:
		_bind -> BindableEvent
			>	BindableEvent used internally.
	}

]]

--// Variables

local Thread = {}

--// Methods

function Thread.new(func, ...)
	local bind = Instance.new("BindableEvent")
	local ret = {
		_bind = bind,

		Finished = false,
		OnFinished = bind.Event,
		Return = {}
	}
	
	coroutine.wrap(function(...)
		local f = table.pack(func(...))
		bind:Fire(unpack(f))
		ret.Return = f
		ret.Finished = true
	end)(...)
	
	return ret
end


function Thread.join(...)
	local threads = {...}
	if #threads == 1 then
		local thread = threads[1]
		if (not thread.Finished) then return thread.OnFinished:Wait() end
		return thread.Return
	end
	
	local rets = {}
	for o,thread in pairs(threads) do
		if (not thread.Finished) then thread.OnFinished:Wait() end
		rets[o] = thread.Return
	end
	
	return rets
end

--// Return

return Thread
