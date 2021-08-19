
--// API
--[[

Methods:
	.copysign(number x, number y) -> number
	.fabs(number x) -> number
	.factorial(integer x) -> integer
	.fsum(number[] iterable) -> number
	.gcd(...integer) -> integer
	.isclose(number a, number b, number relTol, number absTol) -> bool
	.isfinite(number x) -> bool
	.isinf(number x) -> bool
	.isnan(number x) -> bool
	.isqrt(number n) -> integer
	.lcm(...integer) -> integer
	.nextafter(number x, number y) -> number
	.prod(number[] iterable, integer start) -> number
	.trunc(float x) -> integer

Docs:
	https://docs.python.org/3/library/math.html

]]

--// Variables

local Math = {}
Math.closest = 1/(2^53) -- Closest number to 0 (with reasonable precision)
Math.largest = 9e307 -- Largest natural number (non-inf)

--// Methods

function Math.copysign(x, y)
	return Math.abs(x) * (y/Math.abs(y))
end


function Math.fabs(x)
	return math.abs(x)
end


function Math.factorial(x)
	assert(type(x) == "number" and math.floor(x) == x, tostring(x) .. " is not a valid integer! <Math.factorial()>")
	local N = x
	for n = x - 1, 1 do
		N *= n
	end
	return N
end


function Math.fsum(iterable)
	local n = 0
	for _,f in pairs(iterable) do
		assert(type(f) == "number", tostring(f) .. " is not a valid number! <Math.fsum()>")
		n += f
	end
	return n
end


function Math.gcd(...)
	local nums, lowest, nonzerofound = {...}, math.huge, false
	if #nums <= 0 then return 0 end
	for _,n in pairs(nums) do
		assert(type(n) == "number" and math.floor(n) == n, tostring(n) .. " is not a valid integer! <Math.gcd()>")
		if n < lowest then lowest = n end
		if n ~= 0 then nonzerofound = true end
	end
	if (not nonzerofound) then return 0 end
	for n = lowest, 2, -1 do
		local is = true
		for _,N in pairs(nums) do
			if math.floor(N / n) ~= N / n then is = false break end
		end
		if is then return n end
	end
	return 0
end


function Math.isclose(a, b, relTol, absTol)
	relTol, absTol = relTol or 1e-09, absTol or 0.0
	return Math.abs(a - b) <= Math.max(relTol * Math.max(Math.abs(a), Math.abs(b)), absTol)
end


function Math.isfinite(x)
	return x < math.huge and x > -math.huge
end


function Math.isinf(x)
	return x == math.huge or x == -math.huge
end


function Math.isnan(x)
	if x <= math.huge and x >= -math.huge then return false end
	return true
end


function Math.isqrt(n)
	return Math.floor(Math.sqrt(n))
end


function Math.lcm(...)
	local nums = {...}
	if #nums <= 0 then return 1 end
	local sum = nums[1]
	for o,n in pairs(nums) do
		assert(type(n) == "number" and math.floor(n) == n, tostring(n) .. " is not a valid integer! <Math.lcm()>")
		if n == 0 then return 0 end
		if o == 1 then continue end
		sum *= n
	end
	
	return math.abs(sum) / Math.gcd(...)
end


function Math.nextafter(x, y)
	if x == y then return y end
	if y < x then return x - Math.closest end
	return x + Math.closest
end


function Math.prod(iterable, start)
	start = start or 1
	
	if #iterable <= 0 then return start end
	local product = iterable[1]
	for o,r in pairs(iterable) do
		assert(type(r) == "number", tostring(r) .. " is not a number! <Math.prod()>")
		if o == 1 then continue end
		product *= r
	end
	return product
end


function Math.trunc(x)
	return Math.floor(x)
end

--// Return

return setmetatable(Math, {__index = math})
