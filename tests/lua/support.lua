local M = {}

-- Records the (name -> value) pairs passed to token.set_macro since the last
-- install_tex_stubs, so tests can observe macros set by e.g. set_pgf_rgb.
M.set_macros = {}

-- Install the minimal TeX/LuaTeX globals dichromacy.lua expects when loaded outside a
-- real LuaTeX run. `opts.status` fields are merged over the defaults, letting a
-- test flip e.g. shell_escape or output_directory without affecting others.
function M.install_tex_stubs(opts)
	opts = opts or {}

	_G.texio = {
		write_nl = function()
			return nil
		end,
	}

	_G.tex = {
		error = function(message)
			error(message, 0)
		end,
	}

	local status = { shell_escape = 0 }
	for key, value in pairs(opts.status or {}) do
		status[key] = value
	end
	_G.status = status

	_G.luatexbase = {
		add_to_callback = function()
			return nil
		end,
	}
	_G.pdf = {
		setrecompress = function()
			return nil
		end,
	}

	M.set_macros = {}
	_G.token = {
		set_macro = function(name, value)
			M.set_macros[name] = value
		end,
	}
end

function M.load_dichromacy(opts)
	M.install_tex_stubs(opts)
	return dofile("src/dichromacy.lua")
end

function M.assert_equal(actual, expected, message)
	if actual ~= expected then
		error((message or "assert_equal failed") .. string.format("\nexpected: %q\nactual:   %q", expected, actual), 0)
	end
end

function M.assert_match(value, pattern, message)
	if not string.match(value, pattern) then
		error((message or "assert_match failed") .. string.format("\npattern: %q\nvalue:   %q", pattern, value), 0)
	end
end

function M.assert_not_equal(actual, unexpected, message)
	if actual == unexpected then
		error((message or "assert_not_equal failed") .. string.format("\nvalue: %q", actual), 0)
	end
end

function M.assert_not_match(value, pattern, message)
	if string.match(value, pattern) then
		error((message or "assert_not_match failed") .. string.format("\npattern: %q\nvalue:   %q", pattern, value), 0)
	end
end

-- Assert that calling fn raises an error. When `pattern` is given, the raised
-- message must also match it. Returns the captured error message.
function M.assert_error(fn, pattern, message)
	local ok, err = pcall(fn)
	if ok then
		error((message or "assert_error failed") .. "\nexpected an error but none was raised", 0)
	end
	err = tostring(err)
	if pattern and not string.match(err, pattern) then
		error((message or "assert_error failed") .. string.format("\npattern: %q\nmessage: %q", pattern, err), 0)
	end
	return err
end

function M.assert_unchanged(input, output, message)
	M.assert_equal(output, input, message or "value should be unchanged")
end

function M.assert_changed(input, output, message)
	M.assert_not_equal(output, input, message or "value should be changed")
end

function M.with_dichromacy(options, callback)
	local dichromacy = M.load_dichromacy()

	if options.type then
		dichromacy.set_type(options.type)
	end

	if options.severity ~= nil then
		dichromacy.set_severity(options.severity)
	end

	if options.enabled == false then
		dichromacy.disable()
	else
		dichromacy.enable()
	end

	return callback(dichromacy)
end

function M.make_case_tests(cases, runner)
	local tests = {}
	for _, case in ipairs(cases) do
		tests[#tests + 1] = {
			name = case.name,
			run = function()
				runner(case)
			end,
		}
	end

	return tests
end

function M.run_tests(tests)
	local failed = 0
	for i, test in ipairs(tests) do
		local ok, err = pcall(test.run)
		if ok then
			io.write(string.format("ok %d - %s\n", i, test.name))
		else
			failed = failed + 1
			io.write(string.format("not ok %d - %s\n%s\n", i, test.name, err))
		end
	end

	io.write(string.format("1..%d\n", #tests))

	if failed > 0 then
		os.exit(1)
	end
end

return M
