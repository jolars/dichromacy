-- Exercises process_pdf_image_content beyond the RGB cases in parsing.lua:
-- CMYK operators, the out-of-gamut guard, fill+stroke and mixed-model streams,
-- format_short trailing-zero stripping, and the graphics-hook gate. Expected
-- outputs were confirmed against the implementation in src/dichromacy.lua.
local support = dofile("tests/lua/support.lua")

-- All cases use deuteranopia at full severity. Each declares one expectation:
-- expect (exact output), expect_unchanged, or expect_match (plus optional
-- expect_changed). disable_hook flips the graphics-hook gate before running.
local cases = {
	{
		name = "transforms CMYK fill and preserves the K component",
		input = "\n0 1 0 0.5 k \n",
		expect = "\n0.2564 0.1742 0.1603 0.5 k \n",
	},
	{
		name = "black CMYK keeps its original formatting",
		input = "\n0 0 0 0 k \n",
		expect_unchanged = true,
	},
	{
		name = "out-of-gamut RGB (value > 1) is left unchanged",
		input = "\n2 0 0 rg \n",
		expect_unchanged = true,
	},
	{
		name = "transforms both fill and stroke RGB in one stream",
		input = "\n1 0 0 rg\nf\n0 1 0 RG\nS\n",
		expect = "\n0.2651 0.4205 0 rg\nf\n0.4817 0.728 0.0174 RG\nS\n",
	},
	{
		name = "transforms mixed RGB and CMYK operators in one stream",
		input = "\n1 0 0 rg\nf\n0 1 0 0.3 k\nF\n",
		expect = "\n0.2651 0.4205 0 rg\nf\n0.2564 0.1742 0.1603 0.3 k\nF\n",
	},
	-- The cases below use the exact byte layouts pgf/TikZ emits: a fill and an
	-- immediately following stroke operator separated by a single space. Earlier
	-- this left the stroke untransformed (the leading fill match consumed the
	-- delimiter the stroke needed); both must now transform. See the end-to-end
	-- check in tests/pdf/.
	{
		name = "transforms an adjacent RGB fill+stroke pair (pgf layout)",
		input = "\nq 1 0 0 rg 1 0 0 RG Q\n",
		expect = "\nq 0.2651 0.4205 0 rg 0.2651 0.4205 0 RG Q\n",
	},
	{
		name = "transforms an adjacent CMYK fill+stroke pair, preserving K (pgf layout)",
		input = "\nq 0 1 0 0.3 k 0 1 0 0.3 K Q\n",
		expect = "\nq 0.2564 0.1742 0.1603 0.3 k 0.2564 0.1742 0.1603 0.3 K Q\n",
	},
	{
		name = "transforms operands separated by multiple spaces",
		input = "\nq 1  0   0 rg Q\n",
		expect = "\nq 0.2651 0.4205 0 rg Q\n",
	},
	{
		name = "transforms operands separated by newlines",
		input = "\nq 1\n0\n0 rg Q\n",
		expect = "\nq 0.2651 0.4205 0 rg Q\n",
	},
	{
		name = "format_short strips trailing zeros and bare decimal points",
		input = "\n1 0 0 rg \n",
		-- 0.420471 -> 0.4205, and 0.000000 collapses to a bare 0 (no "0.0000").
		expect = "\n0.2651 0.4205 0 rg \n",
		expect_no_match = "%.%d-0 ", -- no trailing-zero artifacts in the numbers
	},
	{
		name = "graphics hook disabled leaves the stream untouched",
		input = "\n1 0 0 rg \n",
		disable_hook = true,
		expect_unchanged = true,
	},
}

local tests = {}
for _, case in ipairs(cases) do
	tests[#tests + 1] = {
		name = case.name,
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("deuteranopia")
			dichromacy.set_severity(1.0)
			dichromacy.enable()
			if case.disable_hook then
				dichromacy.disable_graphics_hook()
			end

			local out = dichromacy.process_pdf_image_content(case.input)

			if case.expect then
				support.assert_equal(out, case.expect, "unexpected transformed stream")
			end
			if case.expect_unchanged then
				support.assert_unchanged(case.input, out)
			end
			if case.expect_match then
				support.assert_match(out, case.expect_match)
			end
			if case.expect_no_match then
				support.assert_not_match(out, case.expect_no_match)
			end
		end,
	}
end

support.run_tests(tests)
