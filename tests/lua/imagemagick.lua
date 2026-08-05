-- Covers the deterministic ImageMagick matrix formatters only. The actual
-- raster conversion path (transform_raster_image, get_image_path,
-- check_imagemagick) shells out and touches the filesystem, so it is out of
-- scope here. Unlike transform, these formatters emit the raw (unclamped)
-- Machado matrix, so negative entries are expected in the output.
local support = dofile("tests/lua/support.lua")

local function field_count(s)
	local n = 0
	for _ in s:gmatch("[^,]+") do
		n = n + 1
	end
	return n
end

local tests = {
	{
		name = "get_imagemagick_matrix returns nil when disabled",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.set_type("deuteranopia")
			dichromacy.disable()
			support.assert_equal(dichromacy.get_imagemagick_matrix(), nil, "disabled should yield nil")
		end,
	},
	{
		name = "get_imagemagick_matrix returns nil with no type set",
		run = function()
			local dichromacy = support.load_dichromacy()
			dichromacy.enable()
			support.assert_equal(dichromacy.get_imagemagick_matrix(), nil, "no type should yield nil")
		end,
	},
	{
		name = "get_imagemagick_matrix emits nine comma-separated row-major values",
		run = function()
			local matrix = support.with_dichromacy({ type = "deuteranopia", severity = 1.0 }, function(dichromacy)
				return dichromacy.get_imagemagick_matrix()
			end)
			support.assert_equal(
				matrix,
				"0.265135,0.481724,0.253141,0.420471,0.728023,-0.148494,-0.027676,0.017445,1.010231",
				"unexpected ImageMagick matrix string"
			)
			support.assert_equal(field_count(matrix), 9, "matrix should have nine fields")
		end,
	},
	{
		name = "get_machado_matrix_for_imagemagick matches the global-state formatter",
		run = function()
			local from_global = support.with_dichromacy({ type = "protanopia", severity = 0.4 }, function(dichromacy)
				return dichromacy.get_imagemagick_matrix()
			end)
			-- Same type/severity, but via the explicit-argument entry point.
			local dichromacy = support.load_dichromacy()
			local from_args = dichromacy.get_machado_matrix_for_imagemagick("protanopia", 0.4)
			support.assert_equal(from_args, from_global, "explicit-arg formatter should match global-state formatter")
		end,
	},
	{
		name = "get_machado_matrix_for_imagemagick returns nil for an unknown type",
		run = function()
			local dichromacy = support.load_dichromacy()
			support.assert_equal(
				dichromacy.get_machado_matrix_for_imagemagick("acromatopsia", 1.0),
				nil,
				"unknown type should yield nil"
			)
		end,
	},
	{
		name = "get_machado_matrix_for_imagemagick interpolates at an off-grid severity",
		run = function()
			local dichromacy = support.load_dichromacy()
			local matrix = dichromacy.get_machado_matrix_for_imagemagick("tritanopia", 0.55)
			support.assert_equal(field_count(matrix), 9, "matrix should have nine fields")
			for field in matrix:gmatch("[^,]+") do
				if not tonumber(field) then
					error("non-numeric field in matrix: " .. field, 0)
				end
			end
		end,
	},
}

support.run_tests(tests)
