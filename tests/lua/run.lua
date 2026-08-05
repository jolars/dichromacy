local support = dofile("tests/lua/support.lua")

local tests = {
	{
		name = "transform_current_color transforms rgb when enabled",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("deuteranopia")
			dichromacy.set_severity(1.0)
			dichromacy.enable()

			local out = dichromacy.transform_current_color("1 0 0 rg")
			support.assert_equal(out, "0.265135 0.420471 0.000000 rg", "unexpected transformed rgb value")
		end,
	},
	{
		name = "transform_current_color keeps malformed floats unchanged",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("deuteranopia")
			dichromacy.set_severity(1.0)
			dichromacy.enable()

			local input = "1..2 0 0 rg"
			local out = dichromacy.transform_current_color(input)
			support.assert_equal(out, input, "malformed float input should not be transformed")
		end,
	},
	{
		name = "process_pdf_image_content transforms newline-prefixed rgb",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("protanopia")
			dichromacy.set_severity(1.0)
			dichromacy.enable()

			local input = "\n1 0 0 rg \n"
			local out = dichromacy.process_pdf_image_content(input)
			support.assert_not_equal(out, input, "newline-prefixed rgb token was not transformed")
			support.assert_match(out, "rg%s*$", "transformed stream should still end in rg operator")
		end,
	},
	{
		name = "process_pdf_image_content preserves black formatting",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("deuteranopia")
			dichromacy.set_severity(1.0)
			dichromacy.enable()

			local input = "\n0 0 0 rg \n"
			local out = dichromacy.process_pdf_image_content(input)
			support.assert_equal(out, input, "black rgb should preserve original number formatting")
		end,
	},
	{
		name = "process_pdf_image_content does not touch text operators",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("deuteranopia")
			dichromacy.set_severity(1.0)
			dichromacy.enable()

			local input = "\nBT /F1 12 Tf (rg is text) Tj ET\n"
			local out = dichromacy.process_pdf_image_content(input)
			support.assert_equal(out, input, "text content should remain untouched")
		end,
	},
	{
		name = "transform_current_color transforms cmyk when enabled",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("deuteranopia")
			dichromacy.set_severity(1.0)
			dichromacy.enable()

			local out = dichromacy.transform_current_color("0 1 0 0 k")
			support.assert_equal(out, "0.256394 0.174226 0.160300 0 k", "unexpected transformed cmyk value")
		end,
	},
	{
		name = "transform_current_color transforms cmyk with K operator",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("deuteranopia")
			dichromacy.set_severity(1.0)
			dichromacy.enable()

			local out = dichromacy.transform_current_color("1 0 0 0 K")
			support.assert_equal(
				out,
				"0.998143 0.074525 0.000000 0 K",
				"unexpected transformed CMYK value with uppercase K"
			)
		end,
	},
	{
		name = "transform_current_color preserves K value in cmyk",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("deuteranopia")
			dichromacy.set_severity(1.0)
			dichromacy.enable()

			local out = dichromacy.transform_current_color("0 1 0 0.5 k")
			support.assert_match(out, "0%.256394 0%.174226 0%.160300 0.5 k$", "K value should be preserved")
		end,
	},
	{
		name = "transform_current_color transforms both fill and stroke cmyk",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("deuteranopia")
			dichromacy.set_severity(1.0)
			dichromacy.enable()

			local output = dichromacy.transform_current_color("0 1 0 0 k 1 0 0 0 K")
			support.assert_match(
				output,
				"0%.256394 0%.174226 0%.160300 0 k 0%.998143 0%.074525 0%.000000 0 K$",
				"both fill and stroke CMYK values should be transformed"
			)
		end,
	},
	{
		name = "transform_current_color transforms both fill and stroke rgb triples",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("deuteranopia")
			dichromacy.set_severity(1.0)
			dichromacy.enable()

			local output = dichromacy.transform_current_color("1 0 0 rg 0 1 0 RG")
			support.assert_match(output, "0%.265135 0%.420471 0%.000000 rg 0%.481724 0%.728023 0%.017445 RG$")
		end,
	},
	{
		name = "transform with rgb color model",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("deuteranopia")
			dichromacy.set_severity(1.0)
			dichromacy.enable()

			local r, g, b = dichromacy.transform("rgb", 1.0, 0.0, 0.0)
			support.assert_equal(string.format("%.6f", r), "0.265135", "unexpected rgb r value")
			support.assert_equal(string.format("%.6f", g), "0.420471", "unexpected rgb g value")
			support.assert_equal(string.format("%.6f", b), "0.000000", "unexpected rgb b value")
		end,
	},
	{
		name = "transform with cmy color model",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("deuteranopia")
			dichromacy.set_severity(1.0)
			dichromacy.enable()

			local c, m, y = dichromacy.transform("cmy", 0.0, 1.0, 0.0)
			support.assert_equal(string.format("%.6f", c), "0.256394", "unexpected cmy c value")
			support.assert_equal(string.format("%.6f", m), "0.174226", "unexpected cmy m value")
			support.assert_equal(string.format("%.6f", y), "0.160300", "unexpected cmy y value")
		end,
	},
	{
		name = "transform_current_color with tritanopia",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("tritanopia")
			dichromacy.set_severity(1.0)
			dichromacy.enable()

			local out = dichromacy.transform_current_color("1 0 0 rg")
			support.assert_equal(out, "1.000000 0.000000 0.014249 rg", "tritanopia should transform rgb")
		end,
	},
	{
		name = "transform_current_color with tritanopia and cmyk",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("tritanopia")
			dichromacy.set_severity(1.0)
			dichromacy.enable()

			local out = dichromacy.transform_current_color("0 1 0 0 k")
			support.assert_equal(out, "0.140349 0.000000 0.246554 0 k", "tritanopia should transform cmyk")
		end,
	},
	{
		name = "transform_current_color with severity 0.0 does not transform",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("deuteranopia")
			dichromacy.set_severity(0.0)
			dichromacy.enable()

			local input = "1 0 0 rg"
			local out = dichromacy.transform_current_color(input)
			-- At severity 0.0, values should be unchanged but may be reformatted
			support.assert_match(out, "1%.0+ 0%.0+ 0%.0+ rg$", "severity 0.0 should not transform colors")
		end,
	},
	{
		name = "transform_current_color with severity 0.5 transforms partially",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("deuteranopia")
			dichromacy.set_severity(0.5)
			dichromacy.enable()

			local out = dichromacy.transform_current_color("1 0 0 rg")
			-- Values should be between original (1,0,0) and full (0.265135,0.420471,0.000000)
			local r = tonumber(string.match(out, "^(%S+)"))
			if not (r > 0.265135 and r < 0.999) then
				error("r value should be partially transformed at severity 0.5, got " .. r, 0)
			end
		end,
	},
	{
		name = "transform_pgf_rgb transforms shading tuple when enabled",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("deuteranopia")
			dichromacy.set_severity(1.0)
			dichromacy.enable()

			local out = dichromacy.transform_pgf_rgb("1", "0", "0")
			support.assert_equal(out, "0.265135 0.420471 0.000000", "unexpected transformed shading rgb tuple")
		end,
	},
	{
		name = "transform_pgf_rgb disabled returns original tuple",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("deuteranopia")
			dichromacy.set_severity(1.0)
			dichromacy.disable()

			support.assert_equal(
				dichromacy.transform_pgf_rgb("1", "0", "0"),
				"1 0 0",
				"disabled state should not transform"
			)
		end,
	},
	{
		name = "transform_pgf_cmyk transforms tuple and preserves K",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("deuteranopia")
			dichromacy.set_severity(1.0)
			dichromacy.enable()

			local out = dichromacy.transform_pgf_cmyk("0", "1", "0", "0.5")
			support.assert_equal(out, "0.256394 0.174226 0.160300 0.5", "unexpected transformed shading cmyk tuple")
		end,
	},
	{
		name = "transform_pgf_cmyk disabled returns original tuple",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("deuteranopia")
			dichromacy.set_severity(1.0)
			dichromacy.disable()

			support.assert_equal(
				dichromacy.transform_pgf_cmyk("0", "1", "0", "0.5"),
				"0 1 0 0.5",
				"disabled state should not transform"
			)
		end,
	},
	{
		name = "transform_pgf_rgb passes unparseable component through unchanged",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("deuteranopia")
			dichromacy.set_severity(1.0)
			dichromacy.enable()

			-- A non-numeric component must not be coerced to 0 (which would emit
			-- a wrong color); the original strings pass through untouched.
			support.assert_equal(
				dichromacy.transform_pgf_rgb("1", "bogus", "0"),
				"1 bogus 0",
				"unparseable component should not be transformed"
			)
		end,
	},
	{
		name = "transform_current_color disabled returns unchanged",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("deuteranopia")
			dichromacy.set_severity(1.0)
			dichromacy.disable()

			local input = "1 0 0 rg"
			local out = dichromacy.transform_current_color(input)
			support.assert_equal(out, input, "disabled state should not transform")
		end,
	},
}

support.run_tests(tests)
