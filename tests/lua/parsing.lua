local support = dofile("tests/lua/support.lua")

local stream_cases = {
	{
		name = "process_pdf_image_content transforms RG with newline prefix",
		type = "protanopia",
		severity = 1.0,
		input = "\n0 1 0 RG \n",
		expect_changed = true,
		expect_match = "RG%s*$",
	},
	{
		name = "process_pdf_image_content leaves start-of-stream rgb unchanged",
		type = "protanopia",
		severity = 1.0,
		input = "1 0 0 rg \n",
		expect_unchanged = true,
	},
	{
		name = "process_pdf_image_content handles tab whitespace",
		type = "protanopia",
		severity = 1.0,
		input = "\n0\t1\t0 RG \n",
		expect_changed = true,
		expect_match = "RG%s*$",
	},
	{
		name = "process_pdf_image_content keeps malformed floats unchanged",
		type = "protanopia",
		severity = 1.0,
		input = "\n1..2 0 0 rg \n",
		expect_unchanged = true,
	},
}

local tests = support.make_case_tests(stream_cases, function(case)
	support.with_dichromacy({ type = case.type, severity = case.severity }, function(dichromacy)
		local output = dichromacy.process_pdf_image_content(case.input)

		if case.expect_unchanged then
			support.assert_unchanged(case.input, output)
		end

		if case.expect_changed then
			support.assert_changed(case.input, output)
		end

		if case.expect_match then
			support.assert_match(output, case.expect_match)
		end

		if case.expect_not_match then
			support.assert_not_match(output, case.expect_not_match)
		end
	end)
end)

support.run_tests(tests)
