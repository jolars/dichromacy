-- Error and input-validation paths: the tex.error branches in set_type and
-- set_severity, and the disabled/no-type short-circuit in transform. These are
-- exercised here because the happy-path suites never trip them.
local support = dofile("tests/lua/support.lua")

local valid_types = { "protanopia", "deuteranopia", "tritanopia" }
local invalid_types = { "acromatopsia", "deuteranomaly", "RGB", "", "rgb" }

local invalid_severities = { -0.1, 1.5, 2, -1, "abc", "", nil }
local valid_severities = { 0, 1, 0.5, "0.0", "1.0", "0.5" }

local tests = {}

-- set_type: valid types enable the module and stick; unknown types raise.
for _, t in ipairs(valid_types) do
	tests[#tests + 1] = {
		name = "set_type accepts " .. t,
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type(t)
			support.assert_equal(dichromacy.current_type, t, "current_type should be set")
			support.assert_equal(dichromacy.enabled, true, "set_type should enable the module")
		end,
	}
end

for _, t in ipairs(invalid_types) do
	tests[#tests + 1] = {
		name = "set_type rejects " .. (t == "" and "<empty>" or t),
		run = function()
			local dichromacy = support.load_dichromacy()
			support.assert_error(function()
				dichromacy.set_type(t)
			end, "Unknown CVD type", "unknown type should raise")
			support.assert_equal(dichromacy.current_type, nil, "rejected type should not be stored")
		end,
	}
end

-- set_severity: boundary and string-coercible values accepted; out-of-range
-- and non-numeric values raise.
for _, s in ipairs(valid_severities) do
	tests[#tests + 1] = {
		name = "set_severity accepts " .. tostring(s),
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_severity(s)
			support.assert_equal(dichromacy.current_severity, tonumber(s), "severity should be stored as a number")
		end,
	}
end

-- Iterate by index so an explicit nil entry is still visited (ipairs would stop
-- at the first nil).
local invalid_severity_count = 7
for i = 1, invalid_severity_count do
	local s = invalid_severities[i]
	tests[#tests + 1] = {
		name = "set_severity rejects " .. tostring(s),
		run = function()
			local dichromacy = support.load_dichromacy()
			support.assert_error(function()
				dichromacy.set_severity(s)
			end, "Invalid severity", "out-of-range/non-numeric severity should raise")
		end,
	}
end

-- transform short-circuits to identity when disabled or untyped.
tests[#tests + 1] = {
	name = "transform returns inputs unchanged when disabled",
	run = function()
		local dichromacy = support.load_dichromacy()
		dichromacy.set_type("deuteranopia")
		dichromacy.disable()
		local r, g, b = dichromacy.transform("rgb", 0.2, 0.3, 0.9)
		support.assert_equal(r, 0.2, "r unchanged when disabled")
		support.assert_equal(g, 0.3, "g unchanged when disabled")
		support.assert_equal(b, 0.9, "b unchanged when disabled")
	end,
}

tests[#tests + 1] = {
	name = "transform returns inputs unchanged when no type is set",
	run = function()
		local dichromacy = support.load_dichromacy()
		dichromacy.enable()
		local r, g, b = dichromacy.transform("rgb", 0.2, 0.3, 0.9)
		support.assert_equal(r, 0.2, "r unchanged with no type")
		support.assert_equal(g, 0.3, "g unchanged with no type")
		support.assert_equal(b, 0.9, "b unchanged with no type")
	end,
}

support.run_tests(tests)
