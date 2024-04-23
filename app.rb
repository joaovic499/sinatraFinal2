require 'sinatra'
require 'sqlite3'

# Conecta-se ao banco de dados
DB = SQLite3::Database.new('usuarios.db')

# Rota para exibir todos os usuários
get '/usuarios' do
  @usuarios = DB.execute('SELECT * FROM usuarios')
  erb :usuarios
end

# Rota para exibir o formulário de criação de usuário
get '/usuarios/novo' do
  erb :novo_usuario
end

# Rota para lidar com a criação de um novo usuário
post '/usuarios' do
  nome = params['nome']
  senha = params['senha']
  codigo = params['codigo']
  DB.execute('INSERT INTO usuarios (nome, senha, codigo) VALUES (?, ?, ?)', [nome, senha, codigo])
  redirect '/usuarios'
end

# Rota para exibir os detalhes de um usuário
get '/usuarios/:id' do
  id = params['id']
  @usuario = DB.execute('SELECT * FROM usuarios WHERE id = ?', id).first
  erb :detalhes_usuario
end

# Rota para exibir o formulário de edição de um usuário
get '/usuarios/:id/editar' do
  id = params['id']
  @usuario = DB.execute('SELECT * FROM usuarios WHERE id = ?', id).first
  erb :editar_usuario
end

# Rota para lidar com a atualização de um usuário
put '/usuarios/:id' do
  id = params['id']
  nome = params['nome']
  senha = params['senha']
  codigo = params['codigo']
  DB.execute('UPDATE usuarios SET nome = ?, senha = ?, codigo = ? WHERE id = ?', [nome, senha, codigo, id])
  redirect "/usuarios/#{id}"
end

# Rota para lidar com a exclusão de um usuário
delete '/usuarios/:id' do
  id = params['id']
  DB.execute('DELETE FROM usuarios WHERE id = ?', id)
  redirect '/usuarios'
end

# Configure a pasta de visualizações
set :views, File.dirname(__FILE__) + '/views'