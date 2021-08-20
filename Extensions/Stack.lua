
----- BEGIN GITHUB NOTE -----[[

THIS FILE IS A MODULESCRIPT.

----- END GITHUB NOTE -----]]

--// API
--[[

Methods:
	.new(...any) -> Stack
		>	Generates a new Stack object using the values passed.

Objects:
	Stack => {
	public:
		:Pop() -> any, integer
			>	Pops the top element off of the Stack. Returns the element that was popped and the new size of the Stack.
		
		:Push(any toPush) -> integer
			>	Pushes 'toPush' to the top of the Stack and returns the new size of the Stack.
		
		:Size() -> integer
			>	Returns the size of the Stack.
		
	private:
		_stack -> any[]
	}

]]

--// Variables

local Stack = {}

--// Methods

function Stack.new(...)
	return {
		_stack = {...},
		
		Pop = function(self)
			local e = self._stack[#self._stack]
			table.remove(self._stack, #self._stack)
			return e, #self._stack
		end,
		
		Push = function(self, toPush)
			table.insert(self._stack, toPush)
			return #self._stack
		end,
		
		Size = function(self)
			return #self._stack
		end,
	}
end

--// Return

return Stack
