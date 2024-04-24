require 'sinatra'
require 'sqlite3'
require'bcrypt'

DB = SQLite3::Database.new('usuarios.db', results_as_hash: true)

# Rota para exibir todos os usuários
get '/usuarios' do
  @usuarios = DB.execute('SELECT * FROM usuarios')
  erb :usuarios
end

get '/' do
    erb :index
end

# Rota para alterar apenas a Senha
get '/usuarios/:id/trocarSenha' do
    @usuario = DB.execute('SELECT * FROM usuarios WHERE id = ?', params['id']).first
    erb :nova_senha
end


# Rota para exibir o formulário de criação de usuário
get '/usuarios/novo' do
  erb :novo_usuario
end

# Rota para lidar com a criação de um novo usuário
post '/usuarios' do
  nome = params['nome']
  senha = BCrypt::Password.create(['senha']).to_s
  codigo = params['codigo']
  DB.execute('INSERT INTO usuarios (nome, senha, codigo) VALUES (?, ?, ?)', [nome, senha, codigo])
  redirect '/usuarios'
end

# Rota para exibir os detalhes de um usuário
get '/usuarios/:id' do
  id = params['id']
  @usuario = DB.execute('SELECT * FROM usuarios WHERE id = ?', id).first
  erb :detalhes_usuarios
end

# Rota para exibir o formulário de edição de um usuário
get '/usuarios/:id/editar' do
  id = params['id']
  @usuario = DB.execute('SELECT * FROM usuarios WHERE id = ?', id).first
  erb :editar_usuarios
end

# Rota para lidar com a atualização de um usuário
put '/usuarios/:id' do
  id = params['id']
  nome = params['nome']
  senha_atual_do_banco = DB.execute('SELECT senha FROM usuarios WHERE id = ?', id).first
  puts senha_atual_do_banco
  senha_atual_do_usuario = params['senha_atual_do_usuario']
  nova_senha = params['nova_senha']
  confirmar_senha = params['confirmar_senha']

  if nova_senha != confirmar_senha
    redirect "/usuarios/#{id}/trocarSenha?erro= Senhas não correspondentes"
  end


  if BCrypt::Password.new(senha_atual_do_banco['senha']) == senha_atual_do_usuario
    nova_senha_criptografada = BCrypt::Password.create(nova_senha)
    DB.execute('UPDATE usuarios SET nome= ?, codigo= ?, senha=? WHERE id = ?', [nome, codigo, nova_senha_criptografada, id])
    redirect "/usuarios/#{id}"
  else
    redirect "/usuarios/#{id}/trocarSenha?erro= Senha atual Incorreta"
  end


end

# Rota para lidar com a exclusão de um usuário
delete '/usuarios/:id/excluir' do
  id = params['id']
  DB.execute('DELETE FROM usuarios WHERE id = ?', id)
  redirect '/usuarios'
end

# Configure a pasta de visualizações
set :views, File.dirname(__FILE__) + '/views'