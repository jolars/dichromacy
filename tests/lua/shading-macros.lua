-- Exercises set_pgf_rgb / set_pgf_cmyk, which were previously unobservable
-- because token.set_macro was a no-op. The harness now records macro writes in
-- support.set_macros, letting us assert that each setter writes both the
-- space-separated tuple (consumed by the pdf/luatex driver) and the
-- brace-grouped form (consumed by the dvisvgm driver), and that the two agree.
local support = dofile("tests/lua/support.lua")

local tests = {
	{
		name = "set_pgf_rgb sets pgf@rgb and a matching brace-grouped pgf@sys@rgb",
		run = function()
			support.with_dichromacy({ type = "deuteranopia", severity = 1.0 }, function(dichromacy)
				dichromacy.set_pgf_rgb("1", "0", "0")
			end)
			support.assert_equal(support.set_macros["pgf@rgb"], "0.265135 0.420471 0.000000", "pgf@rgb tuple")
			support.assert_equal(
				support.set_macros["pgf@sys@rgb"],
				"{0.265135}{0.420471}{0.000000}",
				"pgf@sys@rgb brace form"
			)
		end,
	},
	{
		name = "set_pgf_cmyk sets pgf@cmyk and pgf@sys@cmyk, preserving K",
		run = function()
			support.with_dichromacy({ type = "deuteranopia", severity = 1.0 }, function(dichromacy)
				dichromacy.set_pgf_cmyk("0", "1", "0", "0.5")
			end)
			support.assert_equal(support.set_macros["pgf@cmyk"], "0.256394 0.174226 0.160300 0.5", "pgf@cmyk tuple")
			support.assert_equal(
				support.set_macros["pgf@sys@cmyk"],
				"{0.256394}{0.174226}{0.160300}{0.5}",
				"pgf@sys@cmyk brace form"
			)
		end,
	},
	{
		name = "set_pgf_rgb passes the original tuple through when disabled",
		run = function()
			support.with_dichromacy({ type = "deuteranopia", severity = 1.0, enabled = false }, function(dichromacy)
				dichromacy.set_pgf_rgb("1", "0", "0")
			end)
			support.assert_equal(support.set_macros["pgf@rgb"], "1 0 0", "disabled pgf@rgb tuple")
			support.assert_equal(support.set_macros["pgf@sys@rgb"], "{1}{0}{0}", "disabled pgf@sys@rgb brace form")
		end,
	},
	{
		name = "set_pgf_cmyk passes the original tuple through when disabled",
		run = function()
			support.with_dichromacy({ type = "deuteranopia", severity = 1.0, enabled = false }, function(dichromacy)
				dichromacy.set_pgf_cmyk("0", "1", "0", "0.5")
			end)
			support.assert_equal(support.set_macros["pgf@cmyk"], "0 1 0 0.5", "disabled pgf@cmyk tuple")
			support.assert_equal(
				support.set_macros["pgf@sys@cmyk"],
				"{0}{1}{0}{0.5}",
				"disabled pgf@sys@cmyk brace form"
			)
		end,
	},
}

support.run_tests(tests)
