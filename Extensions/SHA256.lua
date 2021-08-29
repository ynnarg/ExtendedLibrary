
--// Config

local BITS = 32
local BLOCK_SIZE = 512
local K = {
	[0] = 0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
	0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
	0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
	0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
	0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
	0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
	0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
	0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
}

--// Services

local HttpService = game:GetService("HttpService")

--// Variables

local SHA256 = {}

--// Functions

local function toBinary(M, n)
	local bin = ""
	if type(M) == "number" then
		local b = ""
		while M > 0 do
			local rem = math.fmod(M, 2)
			b ..= tostring(rem)
			M = math.floor(M / 2)
		end
		b = b:reverse()
		
		if (not n) then
			local n = 8
			while n <= 64 do
				if #b < n and #b > n - (n / 2) then b = string.rep("0", n - #b) .. b break end
				n *= 2
			end
		else
			if #b < n then b = string.rep("0", n - #b) .. b end
		end
		return b
	end
	
	for c = 1, #M do
		local char = string.byte(M:sub(c,c))
		local b = ""
		while char > 0 do
			local rem = math.fmod(char, 2)
			b ..= tostring(rem)
			char = math.floor(char / 2)
		end
		b = b:reverse()
		
		if (not n) then
			local n = 8
			while n <= 64 do
				if #b < n and #b > n - (n / 2) then b = string.rep("0", n - #b) .. b break end
				n *= 2
			end
		else
			if #b < n then b = string.rep("0", n - #b) .. b end
		end
		bin ..= b
	end
	return bin
end

local function AND(a, b)
	local ret = ""
	for n = 1, #a do
		local c = a:sub(n,n)
		local d = b:sub(n,n)
		if c == "1" and d == "1" then ret ..= "1" else ret ..= "0" end
	end
	return ret
end

local function OR(a, b)
	local ret = ""
	for n = 1, #a do
		local c = a:sub(n,n)
		local d = b:sub(n,n)
		if c == "1" or d == "1" then ret ..= "1" else ret ..= "0" end
	end
	return ret
end

local function XOR(a, b)
	local ret = ""
	for n = 1, #a do
		local c = a:sub(n,n)
		local d = b:sub(n,n)
		if (c == "1" and d ~= "1") or (c ~= "1" and d == "1") then ret ..= "1" else ret ..= "0" end
	end
	return ret
end

local function NOT(a)
	local ret = ""
	for n = 1, #a do
		local c = a:sub(n,n)
		if c == "1" then ret ..= "0" else ret ..= "1" end
	end
	return ret
end

local function ADD(...)
	local args = {...}
	for o,a in pairs(args) do
		if type(a) ~= "number" then args[o] = tonumber(a, 2) end
	end
	local n = 0
	for _,a in pairs(args) do
		n = math.fmod(n + a, 2^BITS)
	end
	return toBinary(n)
end

local function SHL(a, n)
	a = a:sub(n + 1)
	return a .. string.rep("0", n)
end

local function SHR(a, n)
	a = a:sub(1, #a - n)
	return string.rep("0", n) .. a
end

local function ROTL(a, n)
	return OR(SHL(a, n), SHR(a, BITS - n))
end

local function ROTR(a, n)
	return OR(SHR(a, n), SHL(a, BITS - n))
end

local function Ch(x, y, z)
	return XOR(AND(x, y), AND(NOT(x), z))
end

local function Maj(x, y, z)
	return XOR(XOR(AND(x, y), AND(x, z)), AND(y, z))
end

local function Sig0(x)
	return XOR(XOR(ROTR(x, 2), ROTR(x, 13)), ROTR(x, 22))
end

local function Sig1(x)
	return XOR(XOR(ROTR(x, 6), ROTR(x, 11)), ROTR(x, 25))
end

local function sig0(x)
	return XOR(XOR(ROTR(x, 7), ROTR(x, 18)), SHR(x, 3))
end

local function sig1(x)
	return XOR(XOR(ROTR(x, 17), ROTR(x, 19)), SHR(x, 10))
end

--// Methods

function SHA256.digest(message)
	if type(message) == "table" then
		message = HttpService:JSONEncode(message)
	end
	message = tostring(message)
	assert(type(message) == "string" and #message > 0, message .. " is not a valid message! <SHA256.digest()>")
	
	--[[-- INITIAL VALUES --]]--
	
	local M = toBinary(message)
	local H = {
		[0] = {
			[0] = toBinary(0x6a09e667, BITS),
			[1] = toBinary(0xbb67ae85, BITS),
			[2] = toBinary(0x3c6ef372, BITS),
			[3] = toBinary(0xa54ff53a, BITS),
			[4] = toBinary(0x510e527f, BITS),
			[5] = toBinary(0x9b05688c, BITS),
			[6] = toBinary(0x1f83d9ab, BITS),
			[7] = toBinary(0x5be0cd19, BITS)
		}
	}
	local W = {}
	local T1, T2
	
	--[[-- PREPROCESSING --]]--
	
	local l = #M
	local k = BLOCK_SIZE
	while k - 64 < l do
		k += BLOCK_SIZE
	end
	k -= 64
	
	M ..= "1" .. string.rep("0", k - (l + 1))
	M ..= toBinary(l, 64)
	
	local BLOCKS = {}
	for n = 1, #M, BLOCK_SIZE do
		table.insert(BLOCKS, M:sub(n, n + BLOCK_SIZE - 1))
	end
	
	--[[-- HASH COMPUTATION --]]--
	
	for i = 1, #BLOCKS do
		local ha = H[i-1]
		for t = 0, 63 do
			if t >= 0 and t <= 15 then
				W[t] = BLOCKS[i]:sub((t * BITS) + 1, (t * BITS) + BITS)
			elseif t >= 16 then
				W[t] = ADD(sig1(W[t - 2]), W[t - 7], sig0(W[t - 15]), W[t - 16])
			end
		end
		
		local a, b, c, d, e, f, g, h = ha[0], ha[1], ha[2], ha[3], ha[4], ha[5], ha[6], ha[7]
		for t = 0, 63 do
			T1 = ADD(h, Sig1(e), Ch(e, f, g), K[t], W[t])
			T2 = ADD(Sig0(a), Maj(a, b, c))
			h = g
			g = f
			f = e
			e = ADD(d, T1)
			d = c
			c = b
			b = a
			a = ADD(T1, T2)
		end
		
		H[i] = {
			[0] = ADD(a, ha[0]),
			ADD(b, ha[1]),
			ADD(c, ha[2]),
			ADD(d, ha[3]),
			ADD(e, ha[4]),
			ADD(f, ha[5]),
			ADD(g, ha[6]),
			ADD(h, ha[7])
		}
	end
	
	local ha = H[#H]
	return {
		_hash = ha[0] .. ha[1] .. ha[2] .. ha[3] .. ha[4] .. ha[5] .. ha[6] .. ha[7],
		
		ToHex = function(self)
			local assign = "0123456789ABCDEF"
			local ret = ""
			for i = 1, #self._hash, 4 do
				local c = self._hash:sub(i, i + 3)
				c = tonumber(c, 2) + 1
				ret ..= assign:sub(c, c)
			end
			return ret
		end,
	}
end

--// Return

return SHA256
