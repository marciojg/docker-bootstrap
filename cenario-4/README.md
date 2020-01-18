Criando uma nova aplicação rails com:
  - Docker
  - Docker-compose
  - ruby 2.7
  - rails 6
  - npm
  - yarn
  - webpack
  - postgres


Rodar o comando
```
docker run --rm -it -v "$PWD":/usr/src/app -w /usr/src/app ruby:2.7 bash
```

Dentro do container instale o node, nodejs e yarn que são dependências para a parte web rails a partir da vesão 5:
```
curl -sL https://deb.nodesource.com/setup_8.x | bash \
 && apt-get update && apt-get install -y nodejs && rm -rf /var/lib/apt/lists/* \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update && apt-get install -y yarn && rm -rf /var/lib/apt/lists/*
```

Depois das dependências de ambiente instalados, instale o rails
```
gem install rails
```

Com o rails instalado crie um novo projeto
```
rails new cad_product --database=postgresql
```

Vá até dentro do projeto, ainda dentro do container
```
cd cad_product
```

Instalar as configurações do webpack na aplicação
```
bundle exec rails webpacker:install
OU
bundle exec rails webpacker:install:typescript # pode ser com vue, react e etc.. ele gera o webpack prepareado para esses caras e com exemplo
```

Saia do container
```
exit
```

Se de acesso aos arquivos e va para a pasta da aplicação
```
sudo chown -R vagrant:vagrant ./cad_product/* && cd ./cad_product
```

Mova o arquivo docker e docker-compose para o projeto
```
mv Docker ./cad_product
mv docker-compose.yml ./cad_product
```

Crie o arquivo "config/initializers/content_security_policy.rb" e cole o conteúdo abaixo, para as portas do webpack-dev-server ficarem disponibilizadas externamente no container
```
Rails.application.config.content_security_policy do |policy|
  policy.connect_src :self, :https, 'http://localhost:3009', 'ws://localhost:3009', 'http://localhost:3035', 'ws://localhost:3035' if Rails.env.development?
end
```

Copie a chave que está dentro do config/master.key para onde esta XXXXX no docker-compose
```
echo $(cat config/master.key)
```

arrumar as credenciais
```
  database: cad_product_development
  username: postgres
  password: postgres
  host: database
  port: 5432
```

Sobe a aplicação
```
docker-compose up --build
```

criar o banco
```
rails db:drop db:create db:migrate db:seed
```

Enjoy!
