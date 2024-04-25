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
  senha = BCrypt::Password.create(params['senha']).to_s
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
  codigo = params['codigo']

  DB.execute('UPDATE usuarios SET nome = ?, codigo = ? WHERE id = ?', nome, codigo, id)
  redirect "/usuarios/#{id}"

end

#ROTA PARA ATUALIZAR A SENHA
put '/usuarios/:id/trocarSenha' do
  id = params['id']
  senha_atual = params['senha_atual']
  nova_senha = params['nova_senha']
  confirmar_senha = params['confirmar_senha']

  usuario = DB.execute('SELECT senha FROM usuarios WHERE id = ?', id, senha).first


  if BCrypt::Password.new(usuario['senha']) == senha_atual
    if nova_senha == confirmar_senha
    nova_senha_criptografada = BCrypt::Password.create(nova_senha)
    DB.execute('UPDATE usuarios SET senha = ? WHERE id = ?', nova_senha_criptografada, id)
    redirect "/usuarios/#{id}"
  else
    redirect "/usuarios/#{id}/trocarSenha?erro=Senhas nao correpondem"
  end
else
  redirect "/usuarios/#{id}/trocarSenha?erro=Senhas Atual nao correspondem"
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