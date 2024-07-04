#Bibliotecas
require 'csv'
require 'cpf_cnpj'
require 'securerandom'

#Classe que atribui o número para o nome
class UrnaEletronica
  CANDIDATOS = {
    1 => :candidato_a,
    2 => :candidato_b,
    3 => :candidato_c,
    4 => :candidato_d,
    5 => :branco,
    6 => :nulo
  }.freeze


  def initialize
    @votos = Hash.new(0) #Verifica se o cpf já foi votado
    @cpfs_ja_votaram = [] #Armazena o cpf votado
    @usuarios_autorizados = ['12345678909', '10202169480'] #CPF autorizado
  end

  #Sistema de votação
  def iniciar
    autenticar_usuario
    loop do
      limpar_tela
      case menu_principal
      when 1
        votar
      when 2
        mostrar_resultados_final
        puts("Finalizando registro...")
        sleep(2)
        break
      when 3
        exibir_resultados_parciais
      when 4
        puts "Encerrando a urna..."
        sleep(2)
        break
      else
        puts "Opção inválida. Tente novamente."
        sleep(2)
      end
      puts "\nPressione Enter para continuar..."
      gets
    end
  end


  #Função que autentica o usuário para entrar no sistema.
  private

  def autenticar_usuario
    puts "Digite seu CPF para acessar o sistema:"
    cpf = gets.chomp
    unless @usuarios_autorizados.include?(cpf) && validar_cpf(cpf)
      puts "Usuário não autorizado."
      exit
    end
  end

  #Menu principal
  def menu_principal
    puts "Selecione uma das opções abaixo:"
    puts "1. Votar"
    puts "2. Resultado Final"
    puts "3. Resultados Parciais"
    puts "4. Encerrar"
    gets.chomp.to_i
  end

  #Menu para selecionar o candidato
  def menu_candidatos
    loop do
      puts "Digite o número do candidato para votar:"
      CANDIDATOS.each do |num, nome|
        puts "#{num}. #{nome.to_s.tr('_', ' ')}"
      end
      input = gets.chomp
      if input.match?(/^\d+$/) && CANDIDATOS.key?(input.to_i)
        return input.to_i
      else
        puts "Entrada inválida. Por favor, digite um número válido."
        sleep(2)
        limpar_tela
      end
    end
  end

  #Menu para adicionar o CPF do usuário
  def votar
    puts "Digite seu CPF:"
    cpf = gets.chomp
    if validar_cpf(cpf)
      if @cpfs_ja_votaram.include?(cpf)
        puts "Este CPF já votou. Tente novamente com outro CPF."
        sleep(2)
      else
        limpar_tela
        voto = menu_candidatos
        @votos[CANDIDATOS[voto]] += 1 #Hash
        registrar_voto(cpf, CANDIDATOS[voto])
        @cpfs_ja_votaram << cpf #Array
        puts "Voto registrado com sucesso!"
        sleep(2)
      end
    else
      puts "CPF inválido. Tente novamente."
      sleep(2)
    end
  end

  #Registra os votos e manda para uma arquivo CSV
  def registrar_voto(cpf, candidato)
    CSV.open("historico_votos.csv", "a+") do |csv|
      csv << [cpf, candidato, Time.now]
    end
  end

  #Mostra o resultado final da votação
  def mostrar_resultados_final
    salvar_resultados("resultado_final.csv")
    puts "Resultados finais salvos em resultado_final.csv"
    sleep(2)
  end

  #Mostra o resultado parcial da votação
  def exibir_resultados_parciais
    salvar_resultados("resultados_parciais.csv")
    puts "Resultados parciais salvos em resultados_parciais.csv"
    sleep(2)
  end

  #Função salva os resultados no file CSV
  def salvar_resultados(filename)
    return if @votos.empty?
  
    # Encontrar o maior e o menor número de votos
    max_votos = @votos.values.max
    min_votos = @votos.values.min
  
    # Inicializa arrays vazios para armazenar os candidatos mais e menos votados
    candidatos_mais_votados = []
    candidatos_menos_votados = []
  
    # Percorre todos os candidatos e seus respectivos votos
    @votos.each do |candidato, votos|
      if votos == max_votos
        candidatos_mais_votados << candidato
      end
      if votos == min_votos
        candidatos_menos_votados << candidato
      end
    end
    CSV.open(filename, "wb") do |csv|
      csv << ["Candidato", "Votos"]
      @votos.each do |candidato, votos|
        csv << [candidato.to_s.tr('_', ' '), votos]
      end
      csv << []
     
      #Verifica se teve empate e se tiver mostra os candidatos empatados
      if candidatos_mais_votados > 1 
        csv << ["Resultado", "Vai ter Segundo Turno"]
        csv << ["Candidatos que estão empatados."]
        candidatos_menos_votados.each do |candidato|
            csv << [candidato.to_s.tr('_', ' '), max_votos]
        end
    else 
        # Escreve os candidatos mais votados
        csv << ["Candidato(s) mais votado(s)", "Votos"]
       candidatos_mais_votados.each do |candidato|
      csv << [candidato.to_s.tr('_', ' '), max_votos]
      end

    # Adiciona uma linha em branco para separar as seções
     csv << []
  
    # Escreve os candidatos menos votados
      csv << ["Candidato(s) menos votado(s)", "Votos"]
     candidatos_menos_votados.each do |candidato|
       csv << [candidato.to_s.tr('_', ' '), min_votos]
      end
    end
  end

  #Função para validar CPF
  def validar_cpf(cpf)
    CPF.valid?(cpf)
  end

  #Função para limpar a tela
  def limpar_tela
    system('clear') || system('cls')
  end
end

#Inicia o sistema da urna
urna = UrnaEletronica.new 
urna.iniciar