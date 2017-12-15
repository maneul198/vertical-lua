local cjson = require("cjson")
local http = require("socket.http")
local table = require('table')
local ltn12 = require('ltn12')
--local log = require("log")

local cliente = { mt = {} }

function cliente:find_libro(titulo)
	local tab  = self.json_table['Libreria'][1]['Libros']
	for key, lib in pairs(tab) do
		if titulo == lib['Titulo'] then
			return key, lib
		end
	end
end

function cliente:add_libro(titulo, autores)
	local _autores = {}
	if type(autores) == 'table' then
		for _, v in pairs(autores) do
			table.insert(_autores, {Nombre = v})
		end
	else
		table.insert(_autores, {Nombre = autores})
	end

	local tab = self.json_table['Libreria'][1]['Libros']
	table.insert(tab, { Titulo = titulo, Autores = _autores, Resenias = { {} } })
	log.info("Libro:", titulo, "agregado exitosamente")
end

function cliente:delete_libro(titulo)
	local tab  = self.json_table['Libreria'][1]['Libros']
	local key, lib = self:find_libro(titulo)
	table.remove(tab, key) 
	log.info("Libro:", titulo, "removido exitosamente")
end

function cliente:add_autor(autores, libro)
	local _, lib = self:find_libro(libro)

	if type(autores) == 'table' then
		for _, v in pairs(autores) do
			table.insert(lib["Autores"], {Nombre = v})
		end
	else
		table.insert(lib['Autores'], {Nombre = autores})
	end
	log.info("Autores agregados exitosamente al libro:", libro)
end

function cliente:delete_autor(autor, libro)
	local _, lib = self:find_libro(libro)
	local _tab = lib['Autores']

	for key, aut in pairs(_tab) do
		if autor == aut['Nombre'] then
			table.remove(_tab, key)
		end
	end
	log.info("Autor:", autor, "removido exitosamente")
end

function cliente:add_resenia(libro, titulo_resenia, autor_resenia, texto_resenia)
	local _, lib = self:find_libro(libro)
	table.insert(lib['Resenias'], { Titulo = titulo_resenia,
		Autor = autor_resenia, Texto = texto_resenia })
	log.info("Resenia agregada exitosamente")
end

function cliente:delete_resenia(libro, titulo_resenia)
	local _, lib = self:find_libro(libro)
	for k, v in pairs(lib['Resenias']) do
		if titulo_resenia == v['Titulo'] then
			table.remove(lib['Resenias'], k)
		end
	end
	log.info("Resenia removida exitosamente")
end

function cliente:get_json_file()
	self.body, self.code, self.headers, self.status =


		http.request(self.host)
	
	if(self.body) then
		self.json_table = cjson.decode(self.body)
		log.info("Archivo json obtenido exitosamente")
	else
		log.error("Ocurrio un error al tratar de obtener el archivo json")
	end
	--self.crud_operations = {}
end

function cliente:save()
	local data = cjson.encode(self.json_table)
	self.body, self.code, self.headers, self.status = 
		http.request{
			url = self.host,
			method = "POST",
			headers = {
				["content-length"] = string.len(data)
			},
			source = ltn12.source.string(data)
		}
	if(self.status) then
		log.info("Cambios guardados exitosamente")
	else
		log.info("Ocurrio un error al tratar de guardar los cambios")
	end
end

local function new(args)
	local cli = {}
	for name, prop in pairs(cliente) do
		cli[name] = prop
	end

	cli.host = args.host or 'http://localhost:8080'
	return cli
end

function cliente.mt:__call(...)
	return new(...)
end

return setmetatable(cliente, cliente.mt)
