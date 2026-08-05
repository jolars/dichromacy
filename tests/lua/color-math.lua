-- Exercises M.transform across the full type x model x severity space, mixing
-- exact-value anchors with mathematical invariants (identity at severity 0,
-- gamut clamping, severity interpolation, monotonicity). The anchor values are
-- each independently derivable: transforming a basis vector e_j returns the
-- (clamped) j-th column of the Machado matrix at that severity grid point, so
-- the expected numbers below are read straight off the matrix tables in
-- src/dichromacy.lua rather than produced by the code under test.
local support = dofile("tests/lua/support.lua")

local types = { "protanopia", "deuteranopia", "tritanopia" }
local models = { "rgb", "cmy" }

local function fmt(v)
	return string.format("%.6f", v)
end

local function transformed(opts, model, v)
	return support.with_dichromacy(opts, function(dichromacy)
		return { dichromacy.transform(model, v[1], v[2], v[3]) }
	end)
end

local tests = {}

-- 1. Exact anchors: transform of a basis vector = clamped matrix column.
local column_cases = {
	{
		type = "deuteranopia",
		model = "rgb",
		severity = 1.0,
		input = { 1, 0, 0 },
		expect = { "0.265135", "0.420471", "0.000000" },
	},
	{
		type = "deuteranopia",
		model = "cmy",
		severity = 1.0,
		input = { 0, 1, 0 },
		expect = { "0.256394", "0.174226", "0.160300" },
	},
	{
		type = "tritanopia",
		model = "rgb",
		severity = 1.0,
		input = { 1, 0, 0 },
		expect = { "1.000000", "0.000000", "0.014249" },
	},
	{
		type = "protanopia",
		model = "rgb",
		severity = 1.0,
		input = { 1, 0, 0 },
		expect = { "0.127399", "0.203000", "0.000000" },
	},
	{
		type = "protanopia",
		model = "cmy",
		severity = 1.0,
		input = { 0, 0, 1 },
		expect = { "0.000000", "0.578809", "0.856450" },
	},
	{
		type = "deuteranopia",
		model = "rgb",
		severity = 0.1,
		input = { 1, 0, 0 },
		expect = { "0.924223", "0.043016", "0.000000" },
	},
	{
		type = "deuteranopia",
		model = "rgb",
		severity = 0.3,
		input = { 1, 0, 0 },
		expect = { "0.774227", "0.128388", "0.000000" },
	},
	-- Severity 0.1 tritanopia cmy has a deliberately wild matrix; this column
	-- drives one component above 1 and two below 0, proving clamp fires both ways.
	{
		type = "tritanopia",
		model = "cmy",
		severity = 0.1,
		input = { 0, 1, 0 },
		expect = { "0.000000", "1.000000", "0.000000" },
	},
}

for _, c in ipairs(column_cases) do
	tests[#tests + 1] = {
		name = string.format(
			"%s %s sev %.2f basis %s,%s,%s",
			c.type,
			c.model,
			c.severity,
			c.input[1],
			c.input[2],
			c.input[3]
		),
		run = function()
			local out = transformed({ type = c.type, severity = c.severity }, c.model, c.input)
			support.assert_equal(fmt(out[1]), c.expect[1], "component 1 mismatch")
			support.assert_equal(fmt(out[2]), c.expect[2], "component 2 mismatch")
			support.assert_equal(fmt(out[3]), c.expect[3], "component 3 mismatch")
		end,
	}
end

-- 2. Identity invariant: at severity 0 every matrix is the identity, so any
-- in-gamut input is returned exactly unchanged.
local identity_inputs = { { 0, 0, 0 }, { 1, 1, 1 }, { 0.2, 0.3, 0.9 }, { 0.5, 0.5, 0.5 }, { 0.01, 0.99, 0.5 } }
for _, t in ipairs(types) do
	for _, model in ipairs(models) do
		tests[#tests + 1] = {
			name = string.format("identity at severity 0 (%s %s)", t, model),
			run = function()
				for _, v in ipairs(identity_inputs) do
					local out = transformed({ type = t, severity = 0.0 }, model, v)
					support.assert_equal(out[1], v[1], "c1 should be identity at severity 0")
					support.assert_equal(out[2], v[2], "c2 should be identity at severity 0")
					support.assert_equal(out[3], v[3], "c3 should be identity at severity 0")
				end
			end,
		}
	end
end

-- 3. Clamping invariant: every output component stays in [0,1] for any in-gamut
-- input, across all types, models, and severities (sampled densely).
local sweep_inputs = {
	{ 0, 0, 0 },
	{ 1, 1, 1 },
	{ 1, 0, 0 },
	{ 0, 1, 0 },
	{ 0, 0, 1 },
	{ 1, 1, 0 },
	{ 0, 1, 1 },
	{ 1, 0, 1 },
	{ 0.2, 0.3, 0.9 },
	{ 0.8, 0.1, 0.4 },
}
for _, t in ipairs(types) do
	for _, model in ipairs(models) do
		tests[#tests + 1] = {
			name = string.format("outputs stay in [0,1] (%s %s)", t, model),
			run = function()
				for sev = 0, 10 do
					for _, v in ipairs(sweep_inputs) do
						local out = transformed({ type = t, severity = sev / 10 }, model, v)
						for i = 1, 3 do
							if not (out[i] >= 0 and out[i] <= 1) then
								error(
									string.format(
										"out of gamut: %s %s sev %.1f input (%s,%s,%s) -> component %d = %s",
										t,
										model,
										sev / 10,
										v[1],
										v[2],
										v[3],
										i,
										tostring(out[i])
									),
									0
								)
							end
						end
					end
				end
			end,
		}
	end
end

-- 4a. Grid-point exactness already covered by the severity 0.1/0.3 anchors above.
-- 4b. Midpoint interpolation: within a segment the matrix is linear in the
-- interpolation parameter, so for an in-gamut input transform(0.05) equals the
-- average of transform(0.0) and transform(0.10). Computed at runtime against the
-- segment endpoints rather than hard-coded.
tests[#tests + 1] = {
	name = "severity 0.05 is the midpoint of the [0.0, 0.1] segment",
	run = function()
		local input = { 0.2, 0.3, 0.9 }
		local lo = transformed({ type = "deuteranopia", severity = 0.0 }, "rgb", input)
		local hi = transformed({ type = "deuteranopia", severity = 0.1 }, "rgb", input)
		local mid = transformed({ type = "deuteranopia", severity = 0.05 }, "rgb", input)
		for i = 1, 3 do
			local expected = (lo[i] + hi[i]) / 2
			if math.abs(mid[i] - expected) > 1e-9 then
				error(string.format("component %d: midpoint %.9f != average %.9f", i, mid[i], expected), 0)
			end
		end
	end,
}

-- 5. Monotonicity: for deuteranopia on pure red the red channel decreases and
-- the green channel increases as severity rises from 0 to 1.
tests[#tests + 1] = {
	name = "deuteranopia on red: r decreases, g increases with severity",
	run = function()
		local prev_r, prev_g
		for sev = 0, 10 do
			local out = transformed({ type = "deuteranopia", severity = sev / 10 }, "rgb", { 1, 0, 0 })
			if prev_r then
				if out[1] > prev_r + 1e-9 then
					error(string.format("r not monotonically decreasing at severity %.1f", sev / 10), 0)
				end
				if out[2] < prev_g - 1e-9 then
					error(string.format("g not monotonically increasing at severity %.1f", sev / 10), 0)
				end
			end
			prev_r, prev_g = out[1], out[2]
		end
	end,
}

-- 6. Black is a fixed point of every matrix (M * 0 = 0).
tests[#tests + 1] = {
	name = "black maps to black for every type, model, and severity",
	run = function()
		for _, t in ipairs(types) do
			for _, model in ipairs(models) do
				for sev = 0, 10 do
					local out = transformed({ type = t, severity = sev / 10 }, model, { 0, 0, 0 })
					support.assert_equal(out[1], 0, "black c1")
					support.assert_equal(out[2], 0, "black c2")
					support.assert_equal(out[3], 0, "black c3")
				end
			end
		end
	end,
}

support.run_tests(tests)
