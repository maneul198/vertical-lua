#! /bin/lua

local cliente = require('cliente')
local readline = require('readline')
local pl = require('pl.pretty')
log = require("log")

c = cliente({})
c:get_json_file({})

local function call_function(f, ...)
	cliente[f](c, ...)
end

while true do
	local argv = {}
	local line_command = readline.readline('->>')
	for i in string.gmatch(line_command, "%S*") do
		table.insert(argv, i)
	end
	
	local func = argv[1]
	table.remove(argv, 1)

	if pcall(call_function, func, table.unpack(argv)) then
		log.info("Operacion:", func, "efectuada exitosamente")
	else
		log.error("Ocurrio un error al tratar de fectuar la operacion '", func, "'")
		print("Error")
	end

	--pcall(cliente[command]
end

--c:delete_resenia("Libro2", "Segunda resenia")
--c:add_resenia("Libro2", "Segunda resenia", "Manuel", "Esta es otra resenia de prueba")
--c:add_autor({"Autor 8", "Autor 9", "Autor 10"}, "Libro3")
--c:add_libro("El quijote", {"Miguelito", "en prision"})
--c:delete_autor("Autor 8", "Libro3")
--c:delete_autor("Autor 9", "Libro3")
--c:delete_autor("Autor 10", "Libro3")
--c:delete_autor("Senior autor", "Libro2")
--c:delete_libro("El quijote")
--c.json_table = {}

c:save()
