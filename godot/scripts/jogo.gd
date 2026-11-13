# Kravenox: Quadros do Cisma. Todo o jogo num nó só.
#
# O Kravenox anda sem parar por um caminho de quadros. Cada quadro guarda um
# poder comprado na loja; quando ele pisa no quadro, o poder dispara. Os
# monstros do livro chegam em ondas: 15 ondas, chefe na 5, na 10 e na 15.
#
# O visual vem das artes oficiais: o Kravenox e o Thornox são recortes das
# estátuas 3D (kravenox/3d), os monstros são recortes das pinturas
# conceituais (kravenox/arte/conceitos) e o fundo é a pintura da Cratera do
# Cisma. Tudo é desenhado em _draw() a partir de dados simples.
extends Node2D

const LARG := 480.0
const ALT := 820.0
var TAM := 84.0
var PASSO_GRADE := 94.0
var OX := 57.0
var OY := 200.0
const LOJA_Y := 600.0
const NIVEL_MAX := 5
const VERSAO := "2026-11-13f"   # aparece em Ajustes: diz qual versão está no aparelho
const FASES := 4             # ondas por capítulo; a 4ª tem chefe
const DANO_MONSTROS := 1.12
const PESADELO_VIDA := 2.7   # 13/11: era 1.8; quem chega ao Pesadelo já tem as melhorias no máximo
const PESADELO_DANO := 1.7   # era 1.4
const VIDA_MONSTROS := 2.6  # 12/11: monstros mais duros (o jogo estava fácil demais)
const TOTAL_CAPITULOS := 76  # Livro I (35) + Livro II (41)
const CAPS_POR_MUNDO := 4
var CENTRO := Vector2(240, 383)   # meio do anel: onde o Kravenox espera entre as ondas
var ANEL: Array = []   # as casas (quadros) do mundo atual, cada uma uma vez (montado em montar_caminho)
var ROTA: Array = []   # a ordem em que o Kravenox anda: índices de ANEL; num cruzamento a mesma casa aparece 2 vezes

# Caminhos dos mundos: voltas fechadas na grade (x, y), na ordem em que o
# Kravenox anda. Começam pequenos e crescem ao longo dos mundos.
const FORMAS := {
	"cruz": [[1, 0], [2, 0], [3, 0], [3, 1], [4, 1], [4, 2], [3, 2], [3, 3], [2, 3], [1, 3], [1, 2], [0, 2], [0, 1], [1, 1]],
	"degrau": [[0, 0], [1, 0], [2, 0], [2, 1], [3, 1], [4, 1], [4, 2], [4, 3], [3, 3], [2, 3], [1, 3], [0, 3], [0, 2], [0, 1]],
	"dente": [[0, 0], [1, 0], [2, 0], [3, 0], [4, 0], [4, 1], [4, 2], [4, 3], [3, 3], [3, 2], [2, 2], [2, 3], [1, 3], [0, 3], [0, 2], [0, 1]],
	"cruz grande": [[1, 0], [2, 0], [3, 0], [3, 1], [4, 1], [4, 2], [4, 3], [3, 3], [3, 4], [2, 4], [1, 4], [1, 3], [0, 3], [0, 2], [0, 1], [1, 1]],
	"dois dentes": [[0, 0], [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [5, 1], [5, 2], [5, 3], [4, 3], [4, 2], [3, 2], [3, 3], [2, 3], [2, 2], [1, 2], [1, 3], [0, 3], [0, 2], [0, 1]],
	"L pequeno": [[0, 0], [1, 0], [1, 1], [2, 1], [3, 1], [3, 2], [3, 3], [2, 3], [1, 3], [0, 3], [0, 2], [0, 1]],
	"L": [[0, 0], [1, 0], [2, 0], [2, 1], [2, 2], [3, 2], [4, 2], [4, 3], [4, 4], [3, 4], [2, 4], [1, 4], [0, 4], [0, 3], [0, 2], [0, 1]],
	"escada": [[0, 0], [1, 0], [1, 1], [2, 1], [2, 2], [3, 2], [3, 3], [4, 3], [5, 3], [5, 4], [4, 4], [3, 4], [2, 4], [1, 4], [0, 4], [0, 3], [0, 2], [0, 1]],
	"S": [[0, 0], [1, 0], [2, 0], [3, 0], [3, 1], [4, 1], [5, 1], [5, 2], [5, 3], [5, 4], [4, 4], [3, 4], [2, 4], [2, 3], [1, 3], [0, 3], [0, 2], [0, 1]],
	"T": [[0, 0], [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [5, 1], [4, 1], [3, 1], [3, 2], [3, 3], [3, 4], [2, 4], [2, 3], [2, 2], [2, 1], [1, 1], [0, 1]],
	"ampulheta": [[0, 0], [1, 0], [2, 0], [3, 0], [4, 0], [4, 1], [3, 1], [3, 2], [3, 3], [4, 3], [4, 4], [3, 4], [2, 4], [1, 4], [0, 4], [0, 3], [1, 3], [1, 2], [1, 1], [0, 1]],
	"H": [[0, 0], [1, 0], [1, 1], [2, 1], [3, 1], [3, 0], [4, 0], [4, 1], [4, 2], [4, 3], [4, 4], [3, 4], [3, 3], [2, 3], [1, 3], [1, 4], [0, 4], [0, 3], [0, 2], [0, 1]],
	"U": [[0, 0], [1, 0], [1, 1], [1, 2], [2, 2], [3, 2], [3, 1], [3, 0], [4, 0], [4, 1], [4, 2], [4, 3], [4, 4], [3, 4], [2, 4], [1, 4], [0, 4], [0, 3], [0, 2], [0, 1]],
	"laço": [[2, 0], [2, 1], [2, 2], [2, 3], [2, 4], [1, 4], [0, 4], [0, 3], [0, 2], [1, 2], [2, 2], [3, 2], [4, 2], [4, 1], [4, 0], [3, 0]],
	"laço duplo": [[1, 0], [1, 1], [1, 2], [1, 3], [1, 4], [2, 4], [3, 4], [4, 4], [4, 3], [4, 2], [4, 1], [4, 0], [5, 0], [5, 1], [5, 2], [4, 2], [3, 2], [2, 2], [1, 2], [0, 2], [0, 1], [0, 0]],
	"U grande": [[0, 0], [1, 0], [1, 1], [1, 2], [2, 2], [3, 2], [4, 2], [4, 1], [4, 0], [5, 0], [5, 1], [5, 2], [5, 3], [5, 4], [4, 4], [3, 4], [2, 4], [1, 4], [0, 4], [0, 3], [0, 2], [0, 1]],
}
# Um caminho por mundo (19): "anel LxA" é um anel retangular. Espelhado = true vira de lado.
const CAMINHO_DO_MUNDO := [
	["anel 3x3", false], ["anel 4x3", false], ["L pequeno", false], ["anel 4x4", false], ["cruz", false],
	["degrau", false], ["L", false], ["laço", false], ["cruz grande", false], ["escada", false],
	["S", false], ["T", false], ["laço duplo", false], ["H", false], ["U", false],
	["ampulheta", false], ["laço", true], ["escada", true], ["U grande", false],
]
# Os 76 capítulos do livro (títulos do RPG em kravenox-jogar/rpg/js)
const CAPITULOS := [
	"O Despertar no Reino Quebrado", "Ecos do Cisma", "As Sentinelas", "A Vila Sem Nome", "A Primeira Raiz",
	"O Sangue dos Irmãos", "A Coisa que Dormia", "Os Sinos do Vazio", "O Abismo entre os Irmãos", "A Filha Esquecida",
	"O Sétimo Sino", "A Escolha", "A Quarta Essência", "O Reino em Guerra", "A Cidade das Cinzas",
	"O Sangue da Essência", "O Gigante do Vazio", "O que Existia Antes", "O Coração do Primeiro", "A Queda de Valdora",
	"A Sala da Fonte", "O Homem que Kravenox Seria", "As Ruínas do Passado", "O Último Caminho", "A Última Batalha",
	"Depois do Fim", "Além das Montanhas", "A Primeira Cidade", "O Mundo que Virá", "A Queda da Primeira Cidade",
	"O Exército das Sombras", "O Rei dos Espinhos", "O Peso da Escolha", "O Rei do Vazio", "A Nova Essência",
	"A Cidade sem Nome", "O Irmão que Morreu", "O Último Rei", "A Guerra dos Mundos", "O Terceiro Espinho",
	"O Primeiro Mundo", "Aquilo que Sou", "O Nascimento do Caos", "A Cidade que Não Existia", "O Pai dos Devoradores",
	"A Prisão entre Mundos", "A Porta", "A Primeira Origem", "Os Antigos", "O Mundo sem Nome",
	"A Cidade dos Espinhos", "O Homem Antes do Rei", "O Rei do Último Mundo", "A Escolha que Não Foi Sua", "Quando a Fonte Morreu",
	"A Biblioteca do Fim", "O Primeiro Leitor", "O Mundo Depois do Fim", "Aquele que Existia Antes", "O Livro de Thornox",
	"O Destino de Thornox", "A Estrada entre as Estrelas", "A Porta Dentro de Thornox", "O que a Fonte Escondeu", "O Caminho até o Fim",
	"O Começo Depois do Fim", "Um Mundo sem Nome", "A Menina que Lembrava", "Aveline", "A Última Escolha de Aveline",
	"A Estrela Azul", "O Primeiro Kravenox", "A Escolha que Faltava", "O Último Inimigo", "O Mundo Verde",
	"O que Fica Depois do Fim",
]
# Começa simples: cada poder e cada monstro aparece a partir de um capítulo.
const ITEM_DESDE := {"garras": 1, "espinhos": 1, "cristal": 1, "raio": 2, "passo": 3, "esmagamento": 5, "fonte": 7, "rasgo": 9, "escudo": 4, "corrida": 6}
const MONSTRO_DESDE := {"larva": 1, "esfera": 2, "verme": 4, "sentinela": 6}
# Melhorias permanentes, compradas com fragmentos ganhos a cada missão.
const MELHORIAS := [
	{"id": "vida", "nome": "Couraça de Espinhos", "desc": "+20 de vida", "max": 20, "custo": 4},
	{"id": "essencia", "nome": "Essência Guardada", "desc": "+6 de essência no começo", "max": 20, "custo": 4},
	{"id": "forca", "nome": "Fúria do Cisma", "desc": "+10% de dano dos poderes", "max": 20, "custo": 6},
	{"id": "passo", "nome": "Passo Predador", "desc": "+6% de velocidade", "max": 5, "custo": 5},
	{"id": "sorte", "nome": "Olho do Vazio", "desc": "+1 troca grátis por onda", "max": 2, "custo": 10},
	{"id": "defesa", "nome": "Pele de Pedra", "desc": "-3% do dano que ele recebe", "max": 10, "custo": 6},
	{"id": "critico", "nome": "Olhos de Brasa", "desc": "+3% de chance de crítico (dano em dobro)", "max": 10, "custo": 6},
]
# As formas do Kravenox (folha de sprites, universo/personagens/kravenox.md):
# ele muda de forma conforme o nível (1 + a soma das melhorias).
const FORMAS_KX := [
	[1, "Despertar Frágil"], [3, "Essência Retornando"], [6, "Espinhos Aflorados"], [10, "Sede de Poder"],
	[15, "Corrupção Crescente"], [21, "Vontade do Abismo"], [28, "Forma Corrompida"], [36, "Asas do Cisma"],
	[46, "Poder Terrível"], [58, "Soberano do Reino Quebrado"],
]
const CONQUISTAS := [
	{"id": "mundo1", "nome": "Vença o Mundo 1", "tipo": "feitos", "meta": 4, "premio": 10},
	{"id": "caps20", "nome": "Vença 20 capítulos", "tipo": "feitos", "meta": 20, "premio": 25},
	{"id": "livro1", "nome": "Vença o Livro I (35 capítulos)", "tipo": "feitos", "meta": 35, "premio": 50},
	{"id": "fim", "nome": "Vença os 76 capítulos", "tipo": "feitos", "meta": 76, "premio": 120},
	{"id": "m500", "nome": "Espante 500 monstros", "tipo": "mortes", "meta": 500, "premio": 10},
	{"id": "m5000", "nome": "Espante 5000 monstros", "tipo": "mortes", "meta": 5000, "premio": 40},
	{"id": "chefes", "nome": "Derrote 10 chefes", "tipo": "chefes", "meta": 10, "premio": 15},
	{"id": "fusoes", "nome": "Funda itens 30 vezes", "tipo": "fusoes", "meta": 30, "premio": 12},
	{"id": "nv5", "nome": "Leve um item ao nível 5", "tipo": "nivel5", "meta": 1, "premio": 15},
	{"id": "torre", "nome": "Defenda a torre 10 vezes", "tipo": "bonus", "meta": 10, "premio": 20},
	{"id": "pesadelo", "nome": "Vença um capítulo no Pesadelo", "tipo": "feitos_p", "meta": 1, "premio": 15},
	{"id": "asas", "nome": "Alcance a forma Asas do Cisma", "tipo": "nivel", "meta": 36, "premio": 30},
]

# ---- evoluções de 9/11/2026 (ideias-evolucao.md) ----
# Quadros vizinhos no caminho que combinam. "*" = dois poderes iguais lado a lado.
const SINERGIAS := [
	{"a": "garras", "b": "espinhos", "nome": "Sangria", "desc": "os golpes desses quadros fazem o monstro sangrar por 3 s"},
	{"a": "raio", "b": "fonte", "nome": "Raio Faminto", "desc": "o raio dá +1 de essência por monstro atingido; a fonte rende em dobro"},
	{"a": "cristal", "b": "escudo", "nome": "Cristal Blindado", "desc": "a cura também vira escudo e o escudo também cura"},
	{"a": "esmagamento", "b": "rasgo", "nome": "Tremor do Abismo", "desc": "esses golpes deixam os monstros tontos por 1 s"},
	{"a": "passo", "b": "garras", "nome": "Bote", "desc": "o quadro onde o salto cai dispara duas vezes"},
	{"a": "corrida", "b": "espinhos", "nome": "Rastro de Espinhos", "desc": "correndo, cada casa por onde passa solta espinhos"},
	{"a": "raio", "b": "rasgo", "nome": "Fenda Elétrica", "desc": "o raio pula em mais 3 monstros e o corte atravessa mais", "secreta": true},
	{"a": "*", "b": "*", "nome": "Eco", "desc": "dois poderes iguais lado a lado: +25% de dano cada", "secreta": true},
]
# Poder no nível 5 + o poder parceiro em qualquer quadro = vira lendário na onda seguinte.
const LENDARIAS := {
	"garras": {"par": "passo", "nome": "Garras do Predador", "desc": "golpe muito maior, mais forte e que sempre faz sangrar"},
	"espinhos": {"par": "escudo", "nome": "Coroa de Espinhos", "desc": "24 espinhos que atravessam; cada disparo dá escudo"},
	"rasgo": {"par": "fonte", "nome": "Fenda do Vazio", "desc": "cinco cortes em leque, 50% mais fortes"},
	"raio": {"par": "cristal", "nome": "Tempestade da Essência", "desc": "o raio pula em 12 monstros e cura a cada pulo"},
	"esmagamento": {"par": "corrida", "nome": "Terremoto", "desc": "atinge a tela inteira e deixa todos tontos"},
	"fonte": {"par": "cristal", "nome": "Fonte Eterna", "desc": "muito mais essência e cura a cada passo"},
}
const BENCAOS := [
	{"id": "furia", "nome": "Fúria Antiga", "desc": "+12% de dano dos poderes"},
	{"id": "couro", "nome": "Couro de Espinhos", "desc": "+30 de vida máxima"},
	{"id": "ganancia", "nome": "Ganância", "desc": "cada monstro dá +1 de essência"},
	{"id": "ligeiro", "nome": "Pés Ligeiros", "desc": "o Kravenox anda 12% mais rápido"},
	{"id": "certeiro", "nome": "Olho Certeiro", "desc": "+8% de chance de crítico"},
	{"id": "barganha", "nome": "Barganha", "desc": "os itens da loja custam 1 a menos"},
	{"id": "cantos", "nome": "Cantos do Abismo", "desc": "quadros de canto dão +30% de dano"},
	{"id": "espelho", "nome": "Pele Espelhada", "desc": "devolve 40% do dano que ele leva"},
	{"id": "vampiro", "nome": "Sede", "desc": "cada monstro espantado cura 2 de vida"},
	{"id": "troca", "nome": "Olhar do Vazio", "desc": "+1 troca grátis por onda"},
	{"id": "pacto_sangue", "nome": "Pacto de Sangue", "desc": "dano ×1,5, mas −30% de vida máxima", "sombria": true},
	{"id": "avareza", "nome": "Avareza", "desc": "monstros dão o dobro de essência, mas a loja custa +3", "sombria": true},
	{"id": "frenesi", "nome": "Frenesi", "desc": "anda 30% mais rápido, mas leva 20% mais dano", "sombria": true},
]
const TRACOS := {"blindado": ["Blindado", Color8(170, 180, 200)], "veloz": ["Veloz", Color8(255, 160, 60)],
	"vampiro": ["Vampiro", Color8(255, 50, 70)], "divisor": ["Divisor", Color8(120, 230, 120)]}
const PACTOS := [
	{"id": "velozes", "nome": "Monstros Velozes", "desc": "+25% de velocidade", "pts": 1},
	{"id": "cara", "nome": "Loja Cara", "desc": "itens custam +3", "pts": 1},
	{"id": "robustos", "nome": "Monstros Robustos", "desc": "+40% de vida", "pts": 2},
	{"id": "sem_cura", "nome": "Sem Descanso", "desc": "não cura entre as ondas", "pts": 2},
	{"id": "elites", "nome": "Horda de Elite", "desc": "muito mais monstros de elite", "pts": 2},
	{"id": "fragil", "nome": "Kravenox Frágil", "desc": "−30% de vida máxima", "pts": 3},
	{"id": "furiosos", "nome": "Monstros Furiosos", "desc": "+30% de dano dos monstros", "pts": 3},
]
const REGRAS_DESAFIO := [
	{"id": "duas_armas", "nome": "Só Dois Poderes", "desc": "a loja só vende dois poderes"},
	{"id": "chefe_duplo", "nome": "Chefe Duplo", "desc": "a fase 4 tem dois chefes"},
	{"id": "pressa", "nome": "Pressa", "desc": "monstros 30% mais rápidos"},
	{"id": "sem_trocas", "nome": "Sem Trocas", "desc": "a loja não troca: compre o que vier"},
	{"id": "elites", "nome": "Só Elites", "desc": "todo monstro é de elite"},
	{"id": "vidro", "nome": "Vidro", "desc": "−40% de vida, mas +40% de dano"},
]
# Ecos: luzes da Essência que seguem o Kravenox. Abertos pelos baús dos mundos.
const ECOS := [
	{"id": "rubro", "nome": "Eco Rubro", "desc": "ataca um monstro perto a cada 2 s", "bau": 1, "cor": Color8(255, 80, 70)},
	{"id": "verde", "nome": "Eco Verde", "desc": "cura 4 de vida a cada 4 s", "bau": 2, "cor": Color8(110, 230, 140)},
	{"id": "dourado", "nome": "Eco Dourado", "desc": "+1 de essência a cada 4 s de onda", "bau": 3, "cor": Color8(255, 210, 90)},
	{"id": "azul", "nome": "Eco Azul", "desc": "+5 de escudo a cada 4 s", "bau": 4, "cor": Color8(120, 180, 255)},
]
const CONSTRUCOES := [
	{"id": "fogueira", "nome": "Fogueira", "desc": "+5 de cura entre as ondas", "max": 3, "custo": 15},
	{"id": "poco", "nome": "Poço da Essência", "desc": "+1 de essência no fim de cada onda", "max": 3, "custo": 15},
	{"id": "forja", "nome": "Forja", "desc": "começa o capítulo com um poder de nível 2 (3, 4)", "max": 3, "custo": 25},
	{"id": "vigia", "nome": "Torre de Vigia", "desc": "+25% de vida da torre na fase bônus", "max": 3, "custo": 12},
	{"id": "altar", "nome": "Altar dos Ecos", "desc": "os Ecos ficam 25% mais fortes", "max": 3, "custo": 20},
	{"id": "biblioteca", "nome": "Biblioteca", "desc": "+1 fragmento por capítulo vencido", "max": 3, "custo": 20},
]
# Cada novidade aparece num capítulo diferente (as primeiras semanas sempre têm algo novo).
const NOVIDADES := [
	{"id": "bencaos", "desde": 2, "titulo": "BÊNÇÃOS", "texto": "Depois de algumas ondas, escolha 1 de 3 bênçãos. Elas valem até o fim do capítulo."},
	{"id": "sinergias", "desde": 3, "titulo": "COMBINAÇÕES", "texto": "Poderes vizinhos que combinam ganham efeito extra. Veja as descobertas no Grimório (toque no rosto do Kravenox)."},
	{"id": "encruzilhada", "desde": 3, "titulo": "ENCRUZILHADA", "texto": "No meio do capítulo, escolha o caminho: um trecho do livro, uma onda de elite ou a fogueira."},
	{"id": "acampamento", "desde": 4, "titulo": "ACAMPAMENTO", "texto": "Construa a fogueira, o poço, a forja e mais. Aba Acampamento, embaixo."},
	{"id": "furia", "desde": 4, "titulo": "FÚRIA DO KRAVENOX", "texto": "Espantar monstros enche a Fúria. Cheia, toque no botão para um golpe que atinge todos."},
	{"id": "elites", "desde": 5, "titulo": "ELITES", "texto": "Alguns monstros vêm de elite: blindados, velozes, vampiros ou divisores. Valem o dobro."},
	{"id": "terreno", "desde": 5, "titulo": "TERRENO", "texto": "Fendas dão +50% de dano, altares curam, pedras malditas não aceitam poder mas dão essência."},
	{"id": "abismo", "desde": 5, "titulo": "ABISMO SEM FIM", "texto": "Ondas sem fim, cada vez mais fortes. Bata o seu recorde."},
	{"id": "desafio", "desde": 6, "titulo": "DESAFIO DO DIA", "texto": "Um capítulo com regra especial, diferente a cada dia. Prêmio grande uma vez por dia."},
	{"id": "modos", "desde": 5, "titulo": "MODOS", "texto": "Nova aba Modos, embaixo: a Horda já está aberta. Colosso abre no capítulo 10, Refúgio no 15 e Caçada no 20."},
	{"id": "pactos", "desde": 9, "titulo": "PACTOS DO ABISMO", "texto": "Ligue maldições para deixar o jogo mais difícil e ganhar mais fragmentos."},
]
const DESC_MONSTROS := {
	"larva": "Larvas grandes, cinza-arroxeadas, de olhos roxos e boca cheia de dentes. Racham o chão com veios de energia roxa por onde passam.",
	"esfera": "Pequeno autômato redondo de um olho roxo e patas em garra, visto na Cratera do Cisma.",
	"verme": "Vermes esverdeados de boca aberta e dentes afiados, que cercam o Kravenox. (O livro ainda não deu nome a eles.)",
	"sentinela": "Guerreiros de armadura negra rachada por veios roxos, olhos roxos e espadas. Andam em grupo.",
	"larvamae": "A maior das Larvas da Essência. Chefe do Quadros do Cisma: chama larvas menores.",
	"semrosto": "Uma Sentinela do Vazio sem rosto, maior que as outras. Chefe do Quadros do Cisma: chama sentinelas esféricas.",
	"thornox": "O irmão do Kravenox. Chefe do último capítulo de cada mundo.",
}

# Paleta da fantasia sombria: preto azulado, roxo do Vazio, vermelho do
# Kravenox, ouro velho para a interface.
var NOITE := Color8(12, 10, 18)
var PEDRA := Color8(38, 34, 46)
var PEDRA_CLARA := Color8(58, 52, 70)
var PEDRA_ESC := Color8(20, 18, 26)
var PEDRA_BORDA := Color8(74, 66, 90)
var TINTA := Color8(8, 6, 10)
var BRANCO := Color8(232, 226, 236)
var CINZA := Color8(150, 142, 160)
var OURO := Color8(214, 178, 106)
var OURO_ESC := Color8(120, 94, 52)
var ROXO := Color8(160, 100, 255)
var ROXO_ESC := Color8(60, 34, 100)
var VERMELHO := Color8(214, 40, 44)
var SANGUE := Color8(110, 18, 24)
var VERDE := Color8(90, 200, 120)
var AZUL := Color8(120, 160, 205)

# Poderes do Kravenox (os cinco primeiros vêm do Cratera do Cisma)
var ITENS := {
	"garras": {"nome": "Garras", "custo": 8, "cor": Color8(230, 60, 50), "curta": "Golpe em volta", "desc": "arranha e empurra todos os monstros em volta do Kravenox"},
	"espinhos": {"nome": "Espinhos Vorazes", "custo": 10, "cor": Color8(200, 40, 60), "curta": "Espinhos em roda", "desc": "solta espinhos para todos os lados"},
	"raio": {"nome": "Raio da Essência", "custo": 12, "cor": Color8(170, 110, 255), "curta": "Raio em cadeia", "desc": "um raio pula de um monstro para o outro"},
	"esmagamento": {"nome": "Esmagamento", "custo": 14, "cor": Color8(200, 140, 80), "curta": "Dano em área", "desc": "esmaga o chão e fere tudo numa área grande"},
	"rasgo": {"nome": "Rasgo do Abismo", "custo": 12, "cor": Color8(230, 30, 90), "curta": "Corte que atravessa", "desc": "um corte que vai até o monstro mais perto e atravessa a fila"},
	"cristal": {"nome": "Cristal de Vida", "custo": 9, "cor": Color8(90, 220, 170), "curta": "Cura a vida", "desc": "devolve vida ao Kravenox"},
	"passo": {"nome": "Passo Predador", "custo": 7, "cor": Color8(110, 210, 120), "curta": "Pula quadros", "desc": "o Kravenox dá um salto e pula quadros para a frente: 2 no nível 1, 4 no nível 2, 6 no nível 3, e assim por diante; só o quadro onde ele cai dispara"},
	"corrida": {"nome": "Corrida do Cisma", "custo": 9, "cor": Color8(255, 150, 60), "curta": "Corre mais rápido", "desc": "o Kravenox dispara correndo e todas as casas por onde passa disparam: 2x por 2 casas no nível 1, 4x por 4 casas no nível 2, 6x por 6 casas no nível 3, e assim por diante"},
	"escudo": {"nome": "Escudo de Espinhos", "custo": 10, "cor": Color8(110, 170, 255), "curta": "Escudo extra", "desc": "cria um escudo por cima da vida; quanto maior o nível, mais escudo ele guarda"},
	"fonte": {"nome": "Fonte de Essência", "custo": 10, "cor": Color8(190, 130, 255), "curta": "Dá essência", "desc": "rende essência para gastar na loja"},
}

# Monstros do livro e do gibi (universo/inimigos, biblia/personagens).
# "alt" é a altura na tela em pixels; "anda" é o jeito de se mexer.
var MONSTROS := {
	"larva": {"nome": "Larva da Essência", "hp": 22.0, "vel": 34.0, "dano": 5.0, "premio": 2, "img": "larva", "alt": 44.0, "anda": "rasteja"},
	"esfera": {"nome": "Sentinela Esférica", "hp": 14.0, "vel": 70.0, "dano": 4.0, "premio": 2, "img": "esfera", "alt": 46.0, "anda": "flutua"},
	"verme": {"nome": "Verme de Dentes", "hp": 34.0, "vel": 58.0, "dano": 7.0, "premio": 3, "img": "verme", "alt": 50.0, "anda": "morde"},
	"sentinela": {"nome": "Sentinela do Vazio", "hp": 55.0, "vel": 30.0, "dano": 10.0, "premio": 4, "img": "sentinela", "alt": 82.0, "anda": "marcha"},
	"larvamae": {"nome": "Larva-Mãe", "hp": 420.0, "vel": 18.0, "dano": 20.0, "premio": 40, "img": "larva", "alt": 118.0, "anda": "rasteja", "chefe": true, "tinta": Color(1.0, 0.72, 0.95)},
	"semrosto": {"nome": "Sentinela sem Rosto", "hp": 1100.0, "vel": 14.0, "dano": 28.0, "premio": 80, "img": "sentinela", "alt": 150.0, "anda": "marcha", "chefe": true, "tinta": Color(0.8, 0.7, 1.0)},
	"thornox": {"nome": "Thornox", "hp": 2300.0, "vel": 16.0, "dano": 35.0, "premio": 0, "img": "thornox", "alt": 130.0, "anda": "marcha", "chefe": true},
}
const FILHOTES := {"larvamae": "larva", "semrosto": "esfera", "thornox": "verme"}

var fonte: Font          # texto corrido (Alegreya Sans)
var fonte_titulo: Font   # títulos (Cinzel)
var tex := {}            # nome -> Texture2D
var tex_branca := {}     # nome -> silhueta branca (piscar ao levar dano)
var fundo: Texture2D
var vinheta: Texture2D
var robo := false        # modo de teste automático (--robo)
var tempo := 0.0

# estado da partida
var onda := 0
var essencia := 25
var hp_max := 150.0
var hp := 150.0
var quadros := []
var k_pos := 0.0
var k_vel := 1.4
var k_rapido := 0.0       # casas que ainda faltam correndo (Corrida do Cisma)
var k_mult := 1.0         # quantas vezes mais rápido ele corre
var k_ultimo := 0
var k_dir := 1
var k_anim := 0.0
var k_flash := 0.0
var monstros := []
var tiros := []
var efeitos := []
var textos := []
var fila := []
var t_spawn := 0.0
var gap := 1.0
var t_onda := 0.0   # depois de 20 s de onda os monstros ficam mais rápidos
var estado := "loja"   # loja / onda / derrota / vitoria
var selec := []        # [] ou ["loja", i] ou ["quadro", i]
var vender := false
var vel_jogo := 1
var trocas_gratis := 1
var brilho := []
var mortes := 0
var msg := ""
var msg_t := 0.0
var loja := []

# telas e progresso
var tela := "abertura"   # abertura / inicio / mundos / melhorias / bestiario / jogo
var t_tela := 0.0
var capitulo := 1
var premio_fim := 0
var k_vis := Vector2.ZERO  # onde o Kravenox está de fato (entre as ondas ele anda até o meio)
var k_no_anel := false     # já chegou ao quadro e está dando a volta
var k_andando := false
var k_pausa := 0.0
var k_salto := 0.0
var fim_onda_t := -1.0   # o último monstro morreu: um instante em câmera lenta antes da loja
var salvar_logo := -1.0  # grava a partida um pouco depois, com tudo parado (gravar dá uma travadinha no Safari)       # quadros que ainda faltam no salto do Passo Predador
var destaque_cap := 0    # capítulo que acabou de ser vencido (brilha no mapa)       # pausa curta ao sair do caminho, antes de ir ao meio
var escudo := 0.0        # escudo por cima da vida (item Escudo)
var escudo_flash := 0.0
var bonus_pendente := false   # venceu a fase 4: falta a fase bônus
var bonus_res := ""           # "" / "ok" / "caiu"
var premio_bonus := 0
var torre_hp := 0.0
var torre_max := 0.0
var torre_flash := 0.0
var rolagem := 0.0       # rolagem do mapa dos mundos
var toque_ini := Vector2.ZERO
var toque_rola := 0.0
var arrastou := false
var arrasto := {}        # item sendo arrastado com o dedo: {"de": "loja"/"quadro", "i", "p", "moveu"}
var prog := {}
var robo_tentativas := 0
var modo := "normal"          # normal / pesadelo
var efeitos_ligados := true
var vibracao_ligada := true
var PAPEL_C := Color8(230, 215, 180)

# estado das evoluções de 9/11
var tipo_partida := "capitulo"   # capitulo / abismo / desafio
var bencaos := []                # ids das bênçãos escolhidas nesta partida
var escolha := {}                # tela de escolha aberta: {"tipo", "titulo", "texto", "opcoes"}
var onda_elite := false          # a próxima onda é só de elites (Encruzilhada)
var terreno := []                # "" / fenda / altar / maldita, por quadro
var golpe := {}                  # efeitos extras do golpe que está acontecendo (sangra, atordoa)
var pendentes := []              # monstros que nascem no fim do quadro (divisores)
var combo := 0
var combo_t := 0.0
var furia := 0.0
var tremor := 0.0
var lento_t := 0.0
var eco_t := 0.0
var eco_ang := 0.0
var em_risco := false
var risco_n := 0
var risco_pote := 0
var desafio := {}                # {"dia", "regra", "capitulo", "armas"}
var trechos := {}
var cron_cap := 0
var nova_cronica := false

# som: trilhas do RPG 2D (kravenox-jogar/rpg/music) e efeitos do Cratera do Cisma
const TRILHAS_EM_LACO := ["abismo", "batalha", "chefe", "espinhos", "reino"]
# Uma trilha do RPG por mundo: toca na tela inicial, no mapa e entre as ondas.
const MUSICA_MUNDO := ["abismo", "floresta", "antigo", "valdora", "primeiro", "origem", "alem", "guerra", "reiVazio",
	"guerraMundos", "primeiroMundo", "entre", "cidade", "biblioteca", "fortaleza", "estrelas", "semNome", "aster", "vale"]
const EFEITOS := ["acerto", "corte", "raio", "esmagamento", "dano", "gema", "chefe", "nivel", "thornox"]
var musica: AudioStreamPlayer
var faixa := ""
var som_ligado := true
var efeitos_som := {}
var vozes := []
var ultimo_som := {}


func _ready() -> void:
	randomize()
	robo = "--robo" in OS.get_cmdline_user_args() or "--robo" in OS.get_cmdline_args()
	fonte = load("res://fontes/alegreya-sans-bold.ttf")
	var cinzel := FontVariation.new()
	cinzel.base_font = load("res://fontes/cinzel.ttf")
	cinzel.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): 700}
	fonte_titulo = cinzel
	for nome in ["kravenox", "thornox", "larva", "esfera", "verme", "sentinela"]:
		carregar(nome)
	# o andar do Kravenox: os 4 quadros de passo do Cratera do Cisma
	for n in 4:
		carregar("kravenox-passo-%d" % n, "")
	fundo = load("res://assets/arte/cratera.png")
	vinheta = gerar_vinheta()
	preparar_som()
	var ft := FileAccess.open("res://dados/trechos.json", FileAccess.READ)
	if ft:
		var dt = JSON.parse_string(ft.get_as_text())
		if dt is Dictionary:
			trechos = dt
	carregar_idioma()
	carregar_progresso()
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--servidor-duelo="):
			servidor_duelo = a.substr(17)
	if robo:
		tela = "jogo"
		# --cap=60 começa no capítulo 60 com as melhorias no máximo (para testar o fim)
		for a in OS.get_cmdline_user_args():
			if a.begins_with("--cap="):
				capitulo = int(a.substr(6))
				for m in MELHORIAS:
					prog["melhorias"][m["id"]] = m["max"]
				prog["liberado"] = capitulo
		for a in OS.get_cmdline_user_args():
			if a == "--pesadelo":
				modo = "pesadelo"
				prog["liberado"] = TOTAL_CAPITULOS
				prog["liberado_p"] = TOTAL_CAPITULOS
				for c in range(1, TOTAL_CAPITULOS + 1):
					prog["feitos"][str(c)] = true
			if a == "--abismo":
				prog["liberado"] = maxi(capitulo, 8)
				comecar_abismo()
				return
			if a == "--desafio":
				prog["liberado"] = maxi(capitulo, 12)
				comecar_desafio()
				return
	novo_jogo()


func preparar_som() -> void:
	musica = AudioStreamPlayer.new()
	musica.volume_db = -7.0
	add_child(musica)
	for n in EFEITOS:
		efeitos_som[n] = load("res://sons/%s.wav" % n)
	for _i in 8:
		var v := AudioStreamPlayer.new()
		v.volume_db = -9.0
		add_child(v)
		vozes.append(v)


var tw_musica: Tween


func tocar_musica(nome: String) -> void:
	if nome == faixa or robo:
		return
	faixa = nome
	var st: AudioStreamOggVorbis = load("res://musica/%s.ogg" % nome)
	st.loop = nome in TRILHAS_EM_LACO or nome in MUSICA_MUNDO
	st.loop_offset = 0.5   # o mesmo ponto de volta que o RPG usa (music/index.json)
	if not som_ligado:
		musica.stream = st
		return
	# troca com fade: a música que está tocando abaixa, a nova sobe
	if tw_musica and tw_musica.is_valid():
		tw_musica.kill()
	var tw := create_tween()
	tw_musica = tw
	if musica.playing:
		tw.tween_property(musica, "volume_db", -40.0, 0.6)
	tw.tween_callback(func():
		musica.stream = st
		musica.volume_db = -40.0
		musica.play())
	tw.tween_property(musica, "volume_db", -7.0, 0.8)


func som(nome: String) -> void:
	if robo or not efeitos_ligados:
		return
	var agora := Time.get_ticks_msec()
	if agora - int(ultimo_som.get(nome, -1000)) < 70:
		return
	ultimo_som[nome] = agora
	for v in vozes:
		if not v.playing:
			v.stream = efeitos_som[nome]
			v.pitch_scale = randf_range(0.94, 1.06)
			v.play()
			return


func musica_certa() -> String:
	if tela == "abertura":
		return "reino"
	if tela == "especial":
		if esp.get("fim", "") != "":
			return "vitoria" if esp["fim"] == "venceu" else "gameover"
		return {"colosso": "chefe", "refugio": "espinhos", "duelo": "chefe"}.get(esp.get("id", ""), "batalha")
	if tela != "jogo":
		return MUSICA_MUNDO[clampi(mundo_de(cap_atual()) - 1, 0, MUSICA_MUNDO.size() - 1)]
	match estado:
		"onda":
			if onda == FASES:
				return "espinhos" if chefe_do_capitulo() == "thornox" else "chefe"
			return "batalha"
		"vitoria":
			return "vitoria"
		"derrota":
			return "gameover"
	return MUSICA_MUNDO[clampi(mundo_de(capitulo) - 1, 0, MUSICA_MUNDO.size() - 1)]


func ligar_som(sim: bool) -> void:
	som_ligado = sim
	if sim:
		faixa = ""
		tocar_musica(musica_certa())
	else:
		musica.stop()


# As artes são grandes e aparecem pequenas: mipmaps deixam o contorno liso.
func carregar(nome: String, pasta := "arte") -> void:
	var t: Texture2D = load("res://assets/%s/%s.png" % [pasta, nome]) if pasta != "" else load("res://assets/%s.png" % nome)
	var img := t.get_image()
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	var cor := img.duplicate()
	cor.generate_mipmaps()
	tex[nome] = ImageTexture.create_from_image(cor)
	for y in img.get_height():
		for x in img.get_width():
			img.set_pixel(x, y, Color(1, 1, 1, img.get_pixel(x, y).a))
	img.generate_mipmaps()
	tex_branca[nome] = ImageTexture.create_from_image(img)


func gerar_vinheta() -> Texture2D:
	var w := 120
	var h := 205
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in h:
		for x in w:
			var d := Vector2((x - w / 2.0) / (w / 2.0), (y - h * 0.42) / (h / 2.0)).length()
			img.set_pixel(x, y, Color(0.02, 0.01, 0.04, clampf((d - 0.45) * 1.1, 0.0, 0.85)))
	return ImageTexture.create_from_image(img)


# ------------------------------------------------------------ progresso
const ARQUIVO := "user://progresso.json"


func carregar_progresso() -> void:
	prog = {"liberado": 1, "feitos": {}, "fragmentos": 0, "melhorias": {}, "vistos": {}, "bonus": {}}
	if robo or not FileAccess.file_exists(ARQUIVO):
		return
	var f := FileAccess.open(ARQUIVO, FileAccess.READ)
	if f == null:
		return
	var d = JSON.parse_string(f.get_as_text())
	if d is Dictionary:
		for k in d.keys():   # tudo o que estiver salvo (inclusive a partida em andamento)
			prog[k] = d[k]
	prog["liberado"] = clampi(int(prog["liberado"]), 1, TOTAL_CAPITULOS)
	prog["fragmentos"] = int(prog["fragmentos"])
	modo = str(prog.get("modo", "normal"))
	vibracao_ligada = bool(prog.get("vibracao", true))
	idioma = str(prog.get("idioma", idioma_padrao()))
	cache_tx.clear()
	var ultima := float(prog.get("ultima_visita", 0.0))
	if ultima > 0 and agora() - ultima > 3 * 86400:
		# ficou 3 dias ou mais fora: presente maior e Fúria adiantada nas próximas partidas
		prog["volta_pendente"] = true
		prog["furia_presente"] = 3
	prog["ultima_visita"] = agora()
	var pt = prog.get("partida", null)
	if pt is Dictionary:
		# o iPhone recarregou a página no meio de um capítulo: volta nele, no mesmo modo
		modo = str(pt.get("modo", "normal"))
		cap_sel = int(pt.get("capitulo", 0))


func salvar() -> void:
	if robo:
		return
	var f := FileAccess.open(ARQUIVO, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(prog))
		f.close()   # fecha na hora: no navegador é aí que o arquivo vai para o armazenamento do aparelho


func mundo_de(c: int) -> int:
	return (c - 1) / CAPS_POR_MUNDO + 1


func feito(c: int) -> bool:
	return prog["feitos"].has(str(c))


func fim_capitulo(venceu: bool) -> void:
	if tipo_partida == "abismo":
		fim_abismo()
		return
	if tipo_partida == "desafio":
		fim_desafio(venceu)
		return
	var dobro := 2 if pesadelo_ativo() else 1
	nova_cronica = venceu and not feito(capitulo) and trechos.has(str(capitulo))
	if venceu:
		contar_missao("caps")
		if modo == "pesadelo":
			if not prog.has("feitos_p"):
				prog["feitos_p"] = {}
			premio_fim = (3 + mundo_de(capitulo) + (0 if prog["feitos_p"].has(str(capitulo)) else 3)) * dobro
			prog["feitos_p"][str(capitulo)] = true
			prog["liberado_p"] = maxi(int(prog.get("liberado_p", 1)), mini(capitulo + 1, TOTAL_CAPITULOS))
		else:
			premio_fim = 3 + mundo_de(capitulo) + (0 if feito(capitulo) else 3)
			prog["feitos"][str(capitulo)] = true
			prog["liberado"] = maxi(int(prog["liberado"]), mini(capitulo + 1, TOTAL_CAPITULOS))
	else:
		premio_fim = maxi(0, onda - 1) * dobro
	if venceu:
		premio_fim += nivel_obra("biblioteca")
		var pts := pontos_pacto()
		if pts > 0:
			premio_fim = int(round(premio_fim * mult_pacto()))
			var rec: Dictionary = prog.get("pacto_rec", {})
			rec[str(capitulo)] = maxi(int(rec.get(str(capitulo), 0)), pts)
			prog["pacto_rec"] = rec
	prog["fragmentos"] = int(prog["fragmentos"]) + premio_fim
	salvar()


func custo_melhoria(m: Dictionary) -> int:
	return int(m["custo"]) * (nivel_melhoria(m["id"]) + 1)


func comprar_melhoria(i: int) -> bool:
	var m: Dictionary = MELHORIAS[i]
	var lv := nivel_melhoria(m["id"])
	var c := custo_melhoria(m)
	if lv >= int(m["max"]) or int(prog["fragmentos"]) < c:
		return false
	prog["fragmentos"] = int(prog["fragmentos"]) - c
	prog["melhorias"][m["id"]] = lv + 1
	salvar()
	som("nivel")
	return true


func pode_melhorar() -> bool:
	for m in MELHORIAS:
		if nivel_melhoria(m["id"]) < int(m["max"]) and int(prog["fragmentos"]) >= custo_melhoria(m):
			return true
	return false


func comecar_capitulo(c: int) -> void:
	capitulo = clampi(c, 1, TOTAL_CAPITULOS)
	tipo_partida = "capitulo"
	tela = "jogo"
	novo_jogo()
	retomar_partida()


# ------------------------------------------------------------ continuar de onde parou
# O Safari do iPhone às vezes recarrega a página (tela bloqueada, troca de app,
# falta de memória). Entre as ondas o jogo guarda o capítulo, a fase, a vida, a
# essência e os itens dos quadros; ao abrir o capítulo de novo, continua dali.
func salvar_partida() -> void:
	if robo or tela != "jogo" or estado != "loja" or em_risco:
		return
	var qs := []
	for q in quadros:
		qs.append(null if q == null else {"id": q["id"], "nv": int(q["nv"]), "lend": bool(q.get("lend", false))})
	prog["partida"] = {"modo": modo, "capitulo": capitulo, "onda": onda, "essencia": essencia, "hp": hp, "escudo": escudo,
		"quadros": qs, "loja": loja, "trocas": trocas_gratis, "bonus_pendente": bonus_pendente,
		"premio_fim": premio_fim, "mortes": mortes, "tamanho": ANEL.size(), "tipo": tipo_partida,
		"bencaos": bencaos, "escolha": escolha, "onda_elite": onda_elite, "furia": furia, "desafio": desafio}
	salvar()


func limpar_partida() -> void:
	if prog.has("partida"):
		prog.erase("partida")
		salvar()


func partida_guardada() -> Dictionary:
	var pt = prog.get("partida", null)
	return pt if pt is Dictionary else {}


func retomar_partida() -> void:
	var pt := partida_guardada()
	if pt.is_empty() or int(pt["capitulo"]) != capitulo or int(pt.get("tamanho", -1)) != ANEL.size() or str(pt.get("modo", "normal")) != modo:
		return
	if str(pt.get("tipo", "capitulo")) != tipo_partida:
		return
	bencaos = Array(pt.get("bencaos", []))
	var esc = pt.get("escolha", {})
	escolha = esc if esc is Dictionary else {}
	onda_elite = bool(pt.get("onda_elite", false))
	furia = float(pt.get("furia", 0.0))
	hp_max = calc_hp_max()
	k_vel = calc_k_vel()
	onda = int(pt["onda"])
	essencia = int(pt["essencia"])
	hp = minf(hp_max, float(pt["hp"]))
	escudo = float(pt.get("escudo", 0.0))
	trocas_gratis = int(pt.get("trocas", 1))
	bonus_pendente = bool(pt.get("bonus_pendente", false))
	premio_fim = int(pt.get("premio_fim", 0))
	mortes = int(pt.get("mortes", 0))
	for i in mini(ANEL.size(), pt["quadros"].size()):
		var q = pt["quadros"][i]
		quadros[i] = null if q == null else {"id": str(q["id"]), "nv": int(q["nv"]), "lend": bool(q.get("lend", false))}
	var lj: Array = pt.get("loja", [])
	if lj.size() == 3:
		loja = lj.map(func(x): return null if x == null else str(x))
	if tipo_partida == "abismo":
		aviso("Continuando o Abismo: onda %d" % (onda + 1), 3.0)
	elif bonus_pendente:
		aviso("Continuando: falta a fase bônus", 3.0)
	else:
		aviso("Continuando de onde parou: fase %d de %d" % [onda + 1, FASES], 3.0)


func _notification(what: int) -> void:
	# o app foi para segundo plano: guarda (vale entre as ondas)
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		salvar_partida()


func ir_para(t: String) -> void:
	tela = t
	t_tela = 0.0
	if t == "inicio":
		checar_novidades()
	if t == "mundos":
		# vindo de um capítulo, mostra o mundo dele; vindo do início, o próximo capítulo
		var c := capitulo if destaque_cap > 0 else liberado_modo()
		rolagem = clampf((mundo_de(c) - 1) * CARD_ALTO - 60.0, 0.0, rolagem_max())


func nivel_melhoria(id: String) -> int:
	return int(prog["melhorias"].get(id, 0))


# Monta o caminho do mundo do capítulo e calcula o tamanho dos quadros para
# caber na área do tabuleiro (entre o placar e a loja).
func forma_por_nome(nome: String) -> Array:
	if not nome.begins_with("anel "):
		return FORMAS[nome]
	var t := nome.substr(5).split("x")
	var c := int(t[0])
	var l := int(t[1])
	var v := []
	for x in c:
		v.append([x, 0])
	for y in range(1, l):
		v.append([c - 1, y])
	for x in range(c - 2, -1, -1):
		v.append([x, l - 1])
	for y in range(l - 2, 0, -1):
		v.append([0, y])
	return v


func montar_caminho() -> void:
	var w := clampi(mundo_de(capitulo) - 1, 0, CAMINHO_DO_MUNDO.size() - 1)
	var forma := forma_por_nome(CAMINHO_DO_MUNDO[w][0])
	var espelho: bool = CAMINHO_DO_MUNDO[w][1]
	var cols := 0
	var lins := 0
	for c in forma:
		cols = maxi(cols, c[0] + 1)
		lins = maxi(lins, c[1] + 1)
	var seq := []
	for c in forma:
		seq.append(Vector2i(cols - 1 - c[0] if espelho else c[0], c[1]))
	if espelho:
		seq.reverse()   # continua andando no sentido horário
	# casas únicas (ANEL) e a ordem da caminhada (ROTA); num cruzamento a casa repete
	ANEL = []
	ROTA = []
	for g in seq:
		var k := ANEL.find(g)
		if k < 0:
			ANEL.append(g)
			k = ANEL.size() - 1
		ROTA.append(k)
	PASSO_GRADE = minf(94.0, minf(460.0 / cols, 390.0 / lins))
	TAM = PASSO_GRADE - 10.0
	OX = (LARG - (cols - 1) * PASSO_GRADE - TAM) / 2.0
	OY = 196.0 + (390.0 - ((lins - 1) * PASSO_GRADE + TAM)) / 2.0
	# ponto de espera: o meio das casas vazias de dentro do caminho
	var soma := Vector2.ZERO
	var n := 0
	for y in range(1, lins - 1):
		for x in range(1, cols - 1):
			if not ANEL.has(Vector2i(x, y)):
				soma += Vector2(OX + x * PASSO_GRADE + TAM / 2, OY + y * PASSO_GRADE + TAM / 2)
				n += 1
	if n == 0:
		# sem espaço dentro (ex.: o T): espera na casa vazia mais perto do meio
		var meio := Vector2.ZERO
		for i in ANEL.size():
			meio += centro_quadro(i)
		meio /= ANEL.size()
		var melhor := meio
		var md := INF
		for y in lins:
			for x in cols:
				if not ANEL.has(Vector2i(x, y)):
					var c := Vector2(OX + x * PASSO_GRADE + TAM / 2, OY + y * PASSO_GRADE + TAM / 2)
					if c.distance_to(meio) < md:
						md = c.distance_to(meio)
						melhor = c
		soma = melhor
		n = 1
	CENTRO = soma / n
	var cel := Vector2i(int((CENTRO.x - OX) / PASSO_GRADE), int((CENTRO.y - OY) / PASSO_GRADE))
	if ANEL.has(cel):
		var md2 := INF
		var alvo := CENTRO
		for y in lins:
			for x in cols:
				if not ANEL.has(Vector2i(x, y)):
					var c2 := Vector2(OX + x * PASSO_GRADE + TAM / 2, OY + y * PASSO_GRADE + TAM / 2)
					if c2.distance_to(CENTRO) < md2:
						md2 = c2.distance_to(CENTRO)
						alvo = c2
		CENTRO = alvo


func novo_jogo() -> void:
	montar_caminho()
	onda = 0
	essencia = 25 + 6 * nivel_melhoria("essencia") + 3 * (capitulo - 1)
	bencaos = []
	escolha = {}
	onda_elite = false
	combo = 0
	combo_t = 0.0
	em_risco = false
	risco_n = 0
	risco_pote = 0
	pendentes = []
	golpe = {}
	tremor = 0.0
	lento_t = 0.0
	furia = 0.0
	if int(prog.get("furia_presente", 0)) > 0 and liberou("furia"):
		furia = 50.0
		if not robo:
			prog["furia_presente"] = int(prog["furia_presente"]) - 1
	montar_terreno()
	hp_max = calc_hp_max()
	hp = hp_max
	# em caminhos maiores ele anda um pouco mais rápido, para a volta não demorar demais
	k_vel = calc_k_vel()
	k_vis = CENTRO + Vector2(0, -18)
	k_no_anel = false
	k_andando = false
	k_pausa = 0.0
	k_salto = 0.0
	fim_onda_t = -1.0
	escudo = 0.0
	bonus_pendente = false
	bonus_res = ""
	premio_bonus = 0
	torre_hp = 0.0
	quadros = []
	quadros.resize(ANEL.size())
	brilho = []
	brilho.resize(ANEL.size())
	brilho.fill(0.0)
	k_pos = 0.0
	k_rapido = 0.0
	k_mult = 1.0
	k_ultimo = 0
	k_dir = 1
	monstros = []
	tiros = []
	efeitos = []
	textos = []
	fila = []
	estado = "loja"
	selec = []
	vender = false
	trocas_gratis = trocas_por_onda()
	mortes = 0
	if tipo_partida == "abismo":
		aviso("Abismo sem Fim · recorde: onda %d" % int(prog.get("abismo_rec", 0)), 3.0)
	elif tipo_partida == "desafio":
		aviso("Desafio do Dia: %s" % regra_desafio()["nome"], 3.5)
	elif capitulo == 1:
		aviso("Arraste um poder da loja até um quadro", 6.0)
	else:
		aviso("Capítulo %d · %s" % [capitulo, CAPITULOS[capitulo - 1]], 3.0)
	sortear_loja()
	# a Forja do acampamento já deixa um poder no primeiro quadro
	var fj := nivel_obra("forja")
	if fj > 0 and tipo_partida != "desafio":
		var ids := ITENS.keys().filter(func(k): return ITEM_DESDE[k] <= capitulo and not k in ["passo", "corrida"])
		for i in ANEL.size():
			if terreno[i] != "maldita":
				quadros[i] = {"id": ids.pick_random(), "nv": 1 + fj}
				break


# ------------------------------------------------------------ tabuleiro
func centro_quadro(i: int) -> Vector2:
	var g: Vector2i = ANEL[i]
	return Vector2(OX + g.x * PASSO_GRADE + TAM / 2, OY + g.y * PASSO_GRADE + TAM / 2)


func ret_quadro(i: int) -> Rect2:
	var g: Vector2i = ANEL[i]
	return Rect2(OX + g.x * PASSO_GRADE, OY + g.y * PASSO_GRADE, TAM, TAM)


func pos_kravenox() -> Vector2:
	var a := int(k_pos) % ROTA.size()
	var b := (a + 1) % ROTA.size()
	var f := k_pos - floorf(k_pos)
	return centro_quadro(ROTA[a]).lerp(centro_quadro(ROTA[b]), f) + Vector2(0, -18)


func cruzamento(i: int) -> bool:
	return ROTA.count(i) > 1


# ------------------------------------------------------------ loja
func sortear_loja() -> void:
	loja = []
	var ids := ITENS.keys().filter(func(k): return ITEM_DESDE[k] <= capitulo)
	if tipo_partida == "desafio" and regra_desafio()["id"] == "duas_armas":
		ids = Array(desafio.get("armas", ids))
	for _i in 3:
		loja.append(ids.pick_random())


func preco(iid: String) -> int:
	var c: int = ITENS[iid]["custo"] + (capitulo - 1) / 6 - nb("barganha") + 3 * nb("avareza") + (3 if pacto("cara") else 0)
	return maxi(1, c)


func valor_venda(q: Dictionary) -> int:
	return (ITENS[q["id"]]["custo"] * int(pow(2, q["nv"] - 1))) / 2 * (2 if q.get("lend", false) else 1)


func colocar(i: int, item: Dictionary) -> bool:
	var q = quadros[i]
	if terreno[i] == "maldita":
		aviso("Pedra maldita: não aceita poder")
		return false
	if q == null:
		quadros[i] = item
		return true
	if q["id"] == item["id"] and q["nv"] == item["nv"] and q["nv"] < NIVEL_MAX and not q.get("lend", false):
		q["nv"] += 1
		contar_total("fusoes")
		if q["nv"] >= NIVEL_MAX:
			contar_total("nivel5")
		som("nivel")
		anel(centro_quadro(i), 10, 60, 0.4, OURO)
		aviso("Fundiu! %s nível %d" % [ITENS[q["id"]]["nome"], q["nv"]])
		return true
	return false


func aviso(t: String, dur := 2.5) -> void:
	msg = t
	msg_t = dur


# ------------------------------------------------------------ ondas
func iniciar_onda() -> void:
	if quadros.all(func(q): return q == null):
		aviso("Coloque pelo menos um poder num quadro!")
		return
	if not escolha.is_empty():
		return
	if capitulo == 1 and onda >= 1 and not robo:
		prog["tutorial"] = true   # o tutorial curto acaba na segunda onda
	salvar_partida()
	onda += 1
	estado = "onda"
	selec = []
	vender = false
	combo = 0
	evoluir_lendarias()
	var tipos := ["larva", "larva", "larva", "larva"]
	if capitulo >= MONSTRO_DESDE["esfera"]:
		tipos += ["esfera", "esfera", "esfera"]
	if capitulo >= MONSTRO_DESDE["verme"]:
		tipos += ["verme", "verme"]
	if capitulo >= MONSTRO_DESDE["sentinela"]:
		tipos += ["sentinela", "sentinela"]
	if capitulo >= 12:
		tipos += ["verme", "sentinela"]
	fila = []
	for _i in mini(46, 4 + onda * 2 + mini(8, (capitulo - 1) / 3)):
		fila.append(tipos.pick_random())
	if tipo_partida == "abismo":
		if robo:
			print("ROBO abismo onda %d · vida %d/%d · bênçãos %d" % [onda, int(hp), int(hp_max), bencaos.size()])
		if onda % 5 == 0:
			var ch: String = ["larvamae", "semrosto", "thornox"][(onda / 5 - 1) % 3]
			fila.insert(3, ch)
			aviso("Onda %d · Chefe: %s!" % [onda, MONSTROS[ch]["nome"]], 3.0)
		else:
			aviso("Abismo · onda %d" % onda, 1.5)
		t_spawn = 0.8
		t_onda = 0.0
		gap = maxf(0.3, 1.2 - onda * 0.03)
		return
	if em_risco:
		for _i in 6 + risco_n * 4:
			fila.append(tipos.pick_random())
		if risco_n % 2 == 0:
			fila.insert(4, chefe_do_capitulo())
		aviso("Risco %d: vença e o pote cresce!" % risco_n, 2.5)
		t_spawn = 0.8
		t_onda = 0.0
		gap = 0.4
		return
	if onda > FASES:
		# fase bônus: muitos monstros, rápidos, indo para a torre do centro
		bonus_pendente = false
		fila = []
		for _i in mini(30, 10 + capitulo / 2):
			fila.append(tipos.pick_random())
		torre_max = (200.0 + 40.0 * capitulo) * (1.0 + 0.25 * nivel_obra("vigia"))
		torre_hp = torre_max
		aviso("Fase bônus: os monstros vão atrás da torre!", 3.0)
		t_spawn = 0.8
		t_onda = 0.0
		gap = 0.45
		return
	if onda == FASES:
		var c := chefe_do_capitulo()
		fila.insert(3, c)
		if tipo_partida == "desafio" and regra_desafio()["id"] == "chefe_duplo":
			fila.insert(8, "larvamae" if c != "larvamae" else "semrosto")
		aviso("Chefe: %s!" % MONSTROS[c]["nome"], 3.0)
	else:
		aviso("Fase %d de %d" % [onda, FASES], 1.5)
	t_spawn = 0.8
	t_onda = 0.0
	gap = maxf(0.35, 1.3 - onda * 0.1 - capitulo * 0.01)


# Nos dois primeiros capítulos de cada mundo, a Larva-Mãe; no terceiro, a
# Sentinela sem Rosto; no último, o Thornox.
func bonus_ativo() -> bool:
	return onda > FASES and estado == "onda" and not em_risco and tipo_partida == "capitulo"


func chefe_do_capitulo() -> String:
	var j := (capitulo - 1) % CAPS_POR_MUNDO
	return "thornox" if j == 3 else ("semrosto" if j == 2 else "larvamae")


var filho_nasce := false   # o monstro que está nascendo veio de um Divisor


func criar_monstro(tipo: String, p = null) -> void:
	var m: Dictionary = MONSTROS[tipo]
	if p == null:
		match randi_range(0, 2):
			0:
				p = Vector2(-40, randf_range(80, LOJA_Y - 40))
			1:
				p = Vector2(LARG + 40, randf_range(80, LOJA_Y - 40))
			_:
				p = Vector2(randf_range(0, LARG), -40)
	var chefe: bool = m.get("chefe", false)
	if chefe:
		som("thornox" if tipo == "thornox" else "chefe")
	prog["vistos"][tipo] = true
	var cresce := 0.10 * (capitulo - 1) - 0.035 * maxi(0, capitulo - 40)   # cresce mais devagar no Livro II
	var esc := (1.0 + cresce) * (pow(1.09, onda - 1) if tipo_partida == "abismo" else 1.0 + 0.12 * (onda - 1))
	var vida: float = m["hp"] * esc
	if chefe:
		vida = 170.0 * (1.0 + 1.3 * cresce) * {"larvamae": 1.0, "semrosto": 1.4, "thornox": 1.8}[tipo]
		if tipo_partida == "abismo":
			vida *= 1.0 + 0.5 * (onda / 5 - 1)
		elif em_risco:
			vida *= 1.0 + 0.3 * risco_n
	var forte := PESADELO_VIDA if pesadelo_ativo() else 1.0
	vida *= forte * (1.4 if pacto("robustos") else 1.0)
	if tipo_partida != "abismo":
		# o reforço diminui um pouco do capítulo 20 ao 50 (o meio do Livro II já é o trecho mais duro)
		vida *= lerpf(VIDA_MONSTROS, 2.0, clampf((capitulo - 20) / 30.0, 0.0, 1.0))
	var vel: float = m["vel"] * (1.25 if pacto("velozes") else 1.0)
	if tipo_partida == "desafio" and regra_desafio()["id"] == "pressa":
		vel *= 1.3
	var dano: float = m["dano"] * 0.7 * (1.0 + 0.03 * (capitulo - 1) + 0.05 * (onda if tipo_partida == "abismo" else mini(onda, 12))) * (PESADELO_DANO if pesadelo_ativo() else 1.0) * (1.3 if pacto("furiosos") else 1.0)
	if tipo_partida != "abismo":
		dano *= lerpf(DANO_MONSTROS, 1.0, clampf((capitulo - 20) / 30.0, 0.0, 1.0))
	var premio: int = m["premio"] if not chefe else 10 + capitulo
	# elite: um traço especial, o dobro de vida e de prêmio
	var traco := ""
	if not chefe and not filho_nasce and liberou("elites"):
		var chance := 0.06 + 0.002 * capitulo + (0.25 if pacto("elites") else 0.0)
		if onda_elite or (tipo_partida == "desafio" and regra_desafio()["id"] == "elites"):
			chance = 1.0
		if randf() < chance:
			traco = TRACOS.keys().pick_random()
			vida *= 2.0
			premio *= 2
			dano *= 1.2
			if traco == "veloz":
				vel *= 1.6
	if filho_nasce:
		vida *= 0.4
	monstros.append({"tipo": tipo, "pos": p, "hp": vida, "hp_max": vida, "vel": vel, "dano": dano,
		"premio": premio, "t_ataque": 0.0, "traco": traco, "filho": filho_nasce,
		"sangra": 0.0, "sangra_dps": 0.0, "sangra_tick": 0.5, "tonto": 0.0,
		"flash": 0.0, "anim": randf() * 2.0, "chefe": chefe, "t_poder": 4.0})


# ------------------------------------------------------------ poderes
func ativar(i: int, repete := false) -> void:
	brilho[i] = 0.35
	golpe = {}
	var kb := pos_kravenox()
	if not repete:
		# mordida básica: sempre acerta quem está colado nele (evita empate eterno)
		for m in monstros:
			if m["pos"].distance_to(kb) < 60:
				ferir(m, 5.0 + mini(onda, 12))
		match terreno[i]:
			"altar":
				if hp < hp_max:
					hp = minf(hp_max, hp + 3)
					texto_voa(kb + Vector2(0, -40), "+3", VERDE)
			"maldita":
				essencia += 1
				texto_voa(kb + Vector2(0, -40), "+1", OURO)
	var q = quadros[i]
	if q == null:
		combo = 0
		return
	if not repete:
		combo += 1
		combo_t = 2.5
	var nv: int = q["nv"]
	var lend: bool = q.get("lend", false)
	var sins := sinergias_do(i)
	for nome in sins:
		descobrir("S:" + nome, "Nova combinação: %s!" % nome)
	var mult := (1.0 + 0.8 * (nv - 1)) * mult_dano() * mult_quadro(i)
	if "Eco" in sins:
		mult *= 1.25
	if "Sangria" in sins or (lend and q["id"] == "garras"):
		golpe["sangra"] = true
	if "Tremor do Abismo" in sins or (lend and q["id"] == "esmagamento"):
		golpe["tonto"] = true
	var k := pos_kravenox()
	match q["id"]:
		"garras":
			som("corte")
			var r := 105.0 + nv * 10 + (50.0 if lend else 0.0)
			var d_g := 17 * mult * (1.6 if lend else 1.0)
			efeitos.append({"t": "garra", "p": k, "r": r, "vida": 0.3})
			for m in monstros:
				var d: Vector2 = m["pos"] - k
				if d.length() < r:
					ferir(m, d_g)
					if not m["chefe"]:
						m["pos"] += d.normalized() * 16   # o golpe empurra
					efeitos.append({"t": "arranhao", "p": m["pos"] + Vector2(0, -12), "vida": 0.28, "a": randf_range(-1.1, -0.6)})
		"espinhos":
			som("corte")
			var n := 24 if lend else 8 + (nv - 1) * 2
			for j in n:
				var a := float(j) / n * TAU
				tiros.append({"p": k, "v": Vector2.from_angle(a) * 330, "dano": 9 * mult, "fura": 2 if lend else 0,
					"vida": 1.0, "cor": Color8(30, 30, 40), "r": 5.0, "acertos": [], "golpe": golpe.duplicate()})
			if lend:
				escudo = minf(80.0, escudo + 6)
		"raio":
			som("raio")
			var alvos := monstros.duplicate()
			alvos.sort_custom(func(x, y): return x["pos"].distance_to(k) < y["pos"].distance_to(k))
			var de := k
			var n_alvos := 12 if lend else 2 + nv + (3 if "Fenda Elétrica" in sins else 0)
			var pegou := 0
			for m in alvos.slice(0, n_alvos):
				efeitos.append({"t": "raio", "a": de, "b": m["pos"], "vida": 0.2})
				ferir(m, 15 * mult)
				de = m["pos"]
				pegou += 1
			if lend and pegou > 0:
				hp = minf(hp_max, hp + pegou)
			if "Raio Faminto" in sins and pegou > 0:
				essencia += mini(3, pegou)
				texto_voa(k + Vector2(0, -44), "+%d" % mini(3, pegou), OURO)
		"esmagamento":
			som("esmagamento")
			var r := 900.0 if lend else 150.0 + nv * 12
			anel(k + Vector2(0, 18), 20, minf(r, 420.0), 0.35, Color8(200, 150, 90))
			tremer(0.35 if lend else 0.2, 30)
			for m in monstros:
				if m["pos"].distance_to(k) < r:
					ferir(m, 16 * mult * (1.4 if lend else 1.0))
		"rasgo":
			som("corte")
			var alvo = mais_perto(k)
			var a: float = (alvo["pos"] - k).angle() if alvo != null else randf() * TAU
			var desvios := [0.0]
			if lend:
				desvios = [-0.5, -0.25, 0.0, 0.25, 0.5]
			elif nv >= 5:
				desvios = [-0.3, 0.0, 0.3]
			elif nv >= 3:
				desvios = [-0.2, 0.2]
			var d_r := 24 * mult * (1.5 if lend else 1.0) * (1.2 if "Fenda Elétrica" in sins else 1.0)
			for d in desvios:
				tiros.append({"p": k, "v": Vector2.from_angle(a + d) * 480, "dano": d_r, "fura": 99,
					"vida": 1.4, "cor": Color8(220, 30, 90), "r": 12.0 if "Fenda Elétrica" in sins else 9.0, "acertos": [], "golpe": golpe.duplicate()})
		"cristal":
			som("gema")
			var cura := 4 + 3 * nv
			hp = minf(hp_max, hp + cura)
			texto_voa(k + Vector2(0, -40), "+%d" % cura, Color8(90, 220, 160))
			anel(k, 10, 50, 0.3, Color8(90, 220, 160))
			if "Cristal Blindado" in sins:
				escudo = minf(20.0 + 20.0 * nv, escudo + cura)
		"passo":
			# salto: pula 2 quadros por nível sem ativar os do meio
			k_salto = float(mini(2 * nv, ROTA.size() - 1))
			k_bote = "Bote" in sins
			texto_voa(k + Vector2(0, -44), "+%d quadros" % int(k_salto), VERDE)
			anel(k + Vector2(0, 18), 10, 40, 0.25, VERDE)
		"corrida":
			k_mult = 2.0 * nv
			k_rapido = 2.0 * nv
			k_rastro = "Rastro de Espinhos" in sins
			texto_voa(k + Vector2(0, -44), "%dx" % int(k_mult), Color8(255, 170, 90))
			anel(k + Vector2(0, 18), 10, 44, 0.25, Color8(255, 150, 60))
		"escudo":
			var teto := 20.0 + 20.0 * nv
			if escudo < teto:
				som("nivel")
				var ganho := minf(4.0 + 4.0 * nv, teto - escudo)
				escudo += ganho
				texto_voa(k + Vector2(0, -44), "+%d escudo" % int(ganho), AZUL)
				anel(k, 20, 46, 0.3, AZUL)
				if "Cristal Blindado" in sins:
					hp = minf(hp_max, hp + ganho / 2)
		"fonte":
			som("gema")
			var e := nv * (2 if "Raio Faminto" in sins else 1) + (nv + 4 if lend else 0)
			essencia += e
			texto_voa(k + Vector2(0, -40), "+%d" % e, OURO)
			if lend:
				hp = minf(hp_max, hp + 8)
	golpe = {}
	anel(centro_quadro(i), 20, 50, 0.25, OURO if lend else ITENS[q["id"]]["cor"])


func anel(p: Vector2, r0: float, r1: float, vida: float, cor: Color) -> void:
	efeitos.append({"t": "anel", "p": p, "r0": r0, "r1": r1, "vida": vida, "max": vida, "cor": cor})


func mais_perto(p: Vector2):
	var melhor = null
	var md := INF
	for m in monstros:
		var d: float = m["pos"].distance_to(p)
		if d < md:
			md = d
			melhor = m
	return melhor


func texto_voa(p: Vector2, t: String, cor: Color, tam := 18) -> void:
	textos.append({"p": p, "txt": t, "cor": cor, "vida": 0.8, "tam": tam})


func ferir(m: Dictionary, dano: float, critico_ok := true) -> void:
	if m["hp"] <= 0:
		return
	dano *= 1.0 + 0.02 * nivel_caca(m["tipo"])
	if m["traco"] == "blindado":
		dano *= 0.6
	var critico := critico_ok and randf() < chance_critico()
	if critico:
		dano *= 2.0
	m["hp"] -= dano
	m["flash"] = 0.1
	if golpe.has("sangra"):
		m["sangra"] = 3.0
		m["sangra_dps"] = maxf(m["sangra_dps"], dano * 0.3)
	if golpe.has("tonto"):
		m["tonto"] = 0.3 if m["chefe"] else 1.0
	if critico:
		texto_voa(m["pos"] + Vector2(randf_range(-8, 8), -38), "%d!" % int(dano), OURO, 27)
	elif critico_ok:
		texto_voa(m["pos"] + Vector2(randf_range(-8, 8), -30), str(int(dano)), BRANCO)
	else:
		texto_voa(m["pos"] + Vector2(randf_range(-8, 8), -30), str(int(dano)), Color8(255, 90, 90), 14)
	if m["hp"] <= 0:
		contar_total("mortes")
		if not robo:
			var ab: Dictionary = prog.get("abates", {})
			ab[m["tipo"]] = int(ab.get(m["tipo"], 0)) + 1
			prog["abates"] = ab
		if m["chefe"]:
			contar_total("chefes")
			tremer(1.0, 220)
			lento_t = 0.7
		som("acerto")
		mortes += 1
		if m.get("extra", false) and esp.has("mortes_base"):
			esp["mortes_base"] = int(esp["mortes_base"]) + 1
		contar_missao("mortes")
		var premio: int = (m["premio"] + nb("ganancia")) * int(pow(2, nb("avareza")))
		essencia += premio
		if liberou("furia"):
			furia = minf(100.0, furia + (25.0 if m["chefe"] else (6.0 if m["traco"] != "" else 3.0)))
		if nb("vampiro") > 0:
			hp = minf(hp_max, hp + 2 * nb("vampiro"))
		if m["traco"] == "divisor" and not m["filho"]:
			for _i in 2:
				pendentes.append([m["tipo"], m["pos"] + Vector2(randf_range(-24, 24), randf_range(-24, 24))])
		for _i in (40 if m["chefe"] else 10):
			efeitos.append({"t": "part", "p": m["pos"], "v": Vector2.from_angle(randf() * TAU) * randf_range(40, 160), "vida": 0.6})
		if premio > 0:
			texto_voa(m["pos"] + Vector2(0, -10), "+%d" % premio, OURO)


# ------------------------------------------------------------ laço
func _process(delta: float) -> void:
	if robo:
		for _i in 300:
			if not passo_robo():
				return
			atualizar(1.0 / 60.0)
		return
	t_tela += delta
	atualizar_duelo(delta)
	if tela == "duelo":
		atualizar_sala(delta)
	if tela == "jogo" or tela == "especial":
		if tela == "jogo":
			# acelerado (2× ou 4×): vários passos pequenos, para os tiros não atravessarem os monstros
			for _i in vel_jogo:
				atualizar(minf(delta, 0.05))
		else:
			atualizar_esp(minf(delta, 0.05))
		tremor = maxf(0.0, tremor - delta * 2.5)
		position = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * tremor * 7.0 if tremor > 0 else Vector2.ZERO
	else:
		position = Vector2.ZERO
		tempo += delta
	tocar_musica(musica_certa())
	queue_redraw()


var k_bote := false     # Bote: o quadro onde o salto cai dispara duas vezes
var k_rastro := false   # Rastro de Espinhos: correndo, cada casa solta espinhos


func andar_no_anel(dt: float) -> void:
	if k_salto > 0:
		# no salto ele corre bem rápido e só o quadro onde cai dispara
		var antes_s := pos_kravenox().x
		var d := minf(k_salto, k_vel * 7.0 * dt)
		k_pos = fmod(k_pos + d, float(ROTA.size()))
		k_salto -= d
		k_anim += dt * k_vel * 14
		var depois_s := pos_kravenox().x
		if absf(depois_s - antes_s) > 0.01:
			k_dir = 1 if depois_s > antes_s else -1
		if k_salto <= 0.001:
			k_salto = 0.0
			var cai_r := int(k_pos + 0.5) % ROTA.size()
			k_ultimo = cai_r
			var cai: int = ROTA[cai_r]
			anel(centro_quadro(cai), 10, 50, 0.3, VERDE)
			ativar(cai)
			if k_bote:
				k_bote = false
				ativar(cai, true)
		k_vis = pos_kravenox()
		k_andando = true
		return
	# corrida: 2x por 2 casas no nível 1, 4x por 4 casas no nível 2...
	var vel := k_vel * (k_mult if k_rapido > 0 else 1.0)
	if k_rapido > 0:
		k_rapido -= vel * dt
		if k_rapido <= 0:
			k_rapido = 0.0
			k_mult = 1.0
			k_rastro = false
	var antes := pos_kravenox().x
	k_pos = fmod(k_pos + vel * dt, float(ROTA.size()))
	k_anim += dt * vel * 6
	var depois := pos_kravenox().x
	if absf(depois - antes) > 0.01:
		k_dir = 1 if depois > antes else -1
	var atual := int(k_pos + 0.5) % ROTA.size()   # a posição da rota em que ele está pisando
	if atual != k_ultimo:
		k_ultimo = atual
		ativar(ROTA[atual])
		if k_rastro and k_rapido > 0:
			for j in 4:
				tiros.append({"p": pos_kravenox(), "v": Vector2.from_angle(j * TAU / 4 + PI / 4) * 300, "dano": 9 * mult_dano(),
					"fura": 0, "vida": 0.8, "cor": Color8(30, 30, 40), "r": 5.0, "acertos": [], "golpe": {}})

	k_vis = pos_kravenox()
	k_andando = true


func atualizar(dt: float) -> void:
	if lento_t > 0:
		lento_t -= dt
		dt *= 0.3   # câmera lenta (chefe espantado, Fúria)
	if fim_onda_t > 0:
		fim_onda_t -= dt
		if fim_onda_t > 0.45:
			dt *= 0.4   # câmera lenta: dá para ver o último monstro morrer
	tempo += dt
	msg_t -= dt
	for i in ANEL.size():
		brilho[i] = maxf(0.0, brilho[i] - dt)
	var vivos := []
	for e in efeitos:
		e["vida"] -= dt
		if e["t"] == "part":
			e["p"] += e["v"] * dt
		if e["vida"] > 0:
			vivos.append(e)
	efeitos = vivos
	for t in textos:
		t["p"].y -= 40 * dt
		t["vida"] -= dt
	textos = textos.filter(func(t): return t["vida"] > 0)
	# Fora do anel ele anda a pé, no passo normal: para o meio quando a onda
	# acaba e de volta ao seu quadro quando a próxima começa.
	k_flash = maxf(0.0, k_flash - dt)
	combo_t -= dt
	if combo_t <= 0:
		combo = 0
	escudo_flash = maxf(0.0, escudo_flash - dt)
	torre_flash = maxf(0.0, torre_flash - dt)
	if k_no_anel and estado != "onda":
		# a onda acabou: termina o passo até o próximo quadro, sem virar no meio
		var antes := k_vis.x
		var alvo_k := floorf(k_pos) + 1.0
		k_pos += k_vel * 0.8 * dt
		k_anim += dt * k_vel * 6
		if k_pos >= alvo_k:
			k_pos = fmod(alvo_k, float(ROTA.size()))
			k_no_anel = false
			k_pausa = 0.35
		k_vis = pos_kravenox()
		k_andando = true
		if absf(k_vis.x - antes) > 0.01:
			k_dir = 1 if k_vis.x > antes else -1
	elif k_pausa > 0 and estado != "onda":
		k_pausa -= dt
		k_andando = false
	elif not (estado == "onda" and k_no_anel):
		var alvo := pos_kravenox() if estado == "onda" else CENTRO + Vector2(0, -18)
		var d := alvo - k_vis
		# desacelera nos últimos passos, para chegar sem tranco
		var passo_px := k_vel * PASSO_GRADE * dt * clampf(d.length() / 45.0, 0.35, 1.0)
		k_andando = d.length() > 0.5
		if d.length() <= passo_px:
			k_vis = alvo
			k_andando = false
			if estado == "onda":
				k_no_anel = true
				k_ultimo = int(k_pos + 0.5) % ROTA.size()
		else:
			k_vis += d.normalized() * passo_px
			k_anim += dt * k_vel * 6
			if absf(d.x) > 1:
				k_dir = 1 if d.x > 0 else -1
	if estado != "onda":
		for t in tiros:
			t["p"] += t["v"] * dt
			t["vida"] -= dt
		tiros = tiros.filter(func(t): return t["vida"] > 0)
		if salvar_logo > 0:
			salvar_logo -= dt
			if salvar_logo <= 0 and not k_andando:
				salvar_logo = -1.0
				salvar_partida()
			elif salvar_logo <= 0:
				salvar_logo = 0.1
		return

	# o Kravenox anda sem parar (depois de chegar ao anel)
	if k_no_anel:
		andar_no_anel(dt)

	if not fila.is_empty():
		t_spawn -= dt
		if t_spawn <= 0:
			criar_monstro(fila.pop_front())
			t_spawn = gap * randf_range(0.6, 1.3)

	t_onda += dt
	var pressa := 1.0 + maxf(0.0, t_onda - 20.0) * 0.05
	var k := k_vis
	var novos := []
	for m in monstros:
		m["anim"] += dt
		m["flash"] -= dt
		if m["sangra"] > 0:
			m["sangra"] -= dt
			m["sangra_tick"] -= dt
			if m["sangra_tick"] <= 0:
				m["sangra_tick"] = 0.5
				ferir(m, m["sangra_dps"] * 0.5, false)
		if m["tonto"] > 0:
			m["tonto"] -= dt
			continue
		var alvo_m: Vector2 = CENTRO + Vector2(0, -10) if bonus_ativo() else k
		var para: Vector2 = alvo_m - m["pos"]
		var alcance := 70.0 if m["chefe"] else (44.0 if bonus_ativo() else 34.0)
		if para.length() > alcance:
			m["pos"] += para.normalized() * m["vel"] * pressa * dt
		else:
			m["t_ataque"] -= dt
			if m["t_ataque"] <= 0:
				m["t_ataque"] = 1.0
				if bonus_ativo():
					torre_hp -= m["dano"]
					torre_flash = 0.15
					som("esmagamento")
					texto_voa(CENTRO + Vector2(0, -70), "-%d" % int(m["dano"]), VERMELHO)
				else:
					var dano: float = m["dano"] * mult_dano_recebido()
					if m["traco"] == "vampiro":
						m["hp"] = minf(m["hp_max"], m["hp"] + dano * 0.5)
					if nb("espelho") > 0:
						ferir(m, dano * 0.4 * nb("espelho"), false)
					if liberou("furia"):
						furia = minf(100.0, furia + 1.5)
					if dano >= 15:
						tremer(0.25, 40)
					if escudo > 0:
						var tira := minf(escudo, dano)
						escudo -= tira
						dano -= tira
						escudo_flash = 0.2
					hp -= dano
					som("dano")
					k_flash = 0.15
					texto_voa(k + Vector2(0, -50), "-%d" % int(m["dano"]), AZUL if dano <= 0 else VERMELHO)
		if m["chefe"]:
			m["t_poder"] -= dt
			if m["t_poder"] <= 0:
				m["t_poder"] = 5.0
				novos.append(m)
	for m in novos:
		var filhote: String = FILHOTES[m["tipo"]]
		for _i in 2:
			criar_monstro(filhote, m["pos"] + Vector2(randf_range(-40, 40), randf_range(-40, 40)))

	for t in tiros:
		t["p"] += t["v"] * dt
		t["vida"] -= dt
		for m in monstros:
			if m["hp"] <= 0 or t["acertos"].has(m):
				continue
			var raio := 50.0 if m["chefe"] else 18.0
			if m["pos"].distance_to(t["p"]) < raio + t["r"]:
				golpe = t.get("golpe", {})
				ferir(m, t["dano"])
				golpe = {}
				t["acertos"].append(m)
				if t["fura"] <= 0:
					t["vida"] = 0.0
					break
				t["fura"] -= 1
	tiros = tiros.filter(func(t): return t["vida"] > 0)
	monstros = monstros.filter(func(m): return m["hp"] > 0)
	for pn in pendentes:
		filho_nasce = true
		criar_monstro(pn[0], pn[1])
		filho_nasce = false
	pendentes.clear()
	atualizar_eco(dt)

	if hp <= 0 and em_risco:
		# caiu arriscando: o capítulo já estava vencido, fica com metade do pote
		hp = 0.0
		var metade := risco_pote / 2
		prog["fragmentos"] = int(prog["fragmentos"]) + metade
		premio_fim += metade
		risco_pote = 0
		bonus_res = "risco_caiu"
		monstros.clear()
		fila.clear()
		tiros.clear()
		estado = "vitoria"
		salvar()
	elif hp <= 0:
		hp = 0.0
		estado = "derrota"
		fim_capitulo(false)
		limpar_partida()
	elif bonus_ativo() and torre_hp <= 0:
		# a torre caiu: acaba o bônus, o capítulo já estava vencido
		torre_hp = 0.0
		bonus_res = "caiu"
		monstros.clear()
		fila.clear()
		tiros.clear()
		estado = "vitoria"
		limpar_partida()
	elif fila.is_empty() and monstros.is_empty():
		# o último monstro morreu: a onda acaba e o progresso é gravado NA HORA (se o
		# Safari recarregar logo depois, nada se perde); a câmera lenta é só visual
		fim_onda_t = 0.9
		efeitos.append({"t": "anel", "p": k_vis, "r0": 20, "r1": 160, "vida": 0.6, "max": 0.6, "cor": OURO})
		if em_risco:
			risco_pote += (3 + mundo_de(capitulo)) * risco_n * (2 if pesadelo_ativo() else 1)
			bonus_res = "risco"
			estado = "vitoria"
		elif bonus_ativo():
			bonus_res = "ok"
			bau_de_fase()
			if not prog.has("bonus"):
				prog["bonus"] = {}
			prog["bonus"][str(capitulo)] = true
			premio_bonus = int(round((2 + mundo_de(capitulo)) * (2 if pesadelo_ativo() else 1) * mult_pacto()))
			contar_missao("bonus")
			contar_total("bonus")
			premio_fim += premio_bonus
			prog["fragmentos"] = int(prog["fragmentos"]) + premio_bonus
			estado = "vitoria"
			limpar_partida()
		elif tipo_partida == "desafio" and onda >= FASES:
			fim_capitulo(true)
			estado = "vitoria"
			limpar_partida()
		elif tipo_partida == "capitulo" and onda >= FASES:
			fim_capitulo(true)
			bonus_pendente = true
			estado = "loja"
			descanso_entre_ondas()
			essencia += 3 + capitulo / 3
			aviso("Capítulo vencido! Agora a fase bônus: defenda a torre", 4.0)
			oferecer_escolha()
			salvar_partida()
		else:
			estado = "loja"
			var premio := descanso_entre_ondas()
			aviso("Onda vencida! +%d de essência" % premio, 3.0)
			oferecer_escolha()
			salvar_partida()


# Entre as ondas: essência, cura (Fogueira), trocas e loja nova.
func descanso_entre_ondas() -> int:
	bau_de_fase()
	var premio := 4 + mini(onda, 15) + capitulo / 4 + nivel_obra("poco")
	if onda_elite:
		onda_elite = false
		premio += 25
		prog["fragmentos"] = int(prog["fragmentos"]) + 3
		aviso("Elites vencidas! +25 de essência e +3 fragmentos", 3.0)
	essencia += premio
	if not pacto("sem_cura"):
		hp = minf(hp_max, hp + 20 + 5 * nivel_obra("fogueira"))
	trocas_gratis = trocas_por_onda()
	sortear_loja()
	return premio


# ------------------------------------------------------------ toque
func botoes() -> Dictionary:
	var b := {}
	for i in 3:
		b["loja%d" % i] = Rect2(26 + i * 148, LOJA_Y + 52, 132, 104)
	b["trocar"] = Rect2(24, ALT - 62, 130, 46)
	b["lixo"] = Rect2(170, ALT - 62, 60, 46)
	b["onda"] = Rect2(246, ALT - 62, 210, 46)
	b["vel"] = Rect2(LARG - 70, 92, 54, 36)
	b["som"] = Rect2(LARG - 116, 92, 40, 36)
	b["voltar"] = Rect2(10, 10, 36, 32)
	b["denovo"] = Rect2(LARG / 2 - 120, ALT / 2 + 30, 240, 54)
	b["mundos"] = Rect2(LARG / 2 - 120, ALT / 2 + 96, 240, 48)
	b["arriscar"] = Rect2(LARG / 2 - 120, ALT / 2 + 156, 240, 48)
	for i in 3:
		b["esc%d" % i] = Rect2(28, 330 + i * 124, LARG - 56, 112)
	return b


func _unhandled_input(ev: InputEvent) -> void:
	if tela == "especial":
		entrada_esp(ev)
		return
	if ev is InputEventMouseButton:
		var p: Vector2 = make_input_local(ev).position
		if tela == "mundos" and ev.pressed and ev.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			rolagem = clampf(rolagem + (60.0 if ev.button_index == MOUSE_BUTTON_WHEEL_DOWN else -60.0), 0.0, rolagem_max())
			return
		if tela == "loja" and ev.pressed and ev.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			rol_loja = clampf(rol_loja + (60.0 if ev.button_index == MOUSE_BUTTON_WHEEL_DOWN else -60.0), 0.0, rol_loja_max())
			return
		if ev.button_index != MOUSE_BUTTON_LEFT:
			return
		if tela == "jogo":
			if ev.pressed:
				if not comecar_arrasto(p):
					clique(p)
			elif not arrasto.is_empty():
				soltar_arrasto(p)
			return
		# nos menus o toque vale ao soltar, para o mapa poder rolar com o dedo
		if ev.pressed:
			toque_ini = p
			toque_rola = rolagem
			toque_rol_loja = rol_loja
			arrastou = false
		elif not arrastou:
			clique_menu(p)
	elif ev is InputEventMouseMotion and tela == "jogo" and not arrasto.is_empty():
		var p: Vector2 = make_input_local(ev).position
		if p.distance_to(toque_ini) > 10:
			arrasto["moveu"] = true
		arrasto["p"] = p
	elif ev is InputEventMouseMotion and tela == "mundos" and (ev.button_mask & MOUSE_BUTTON_MASK_LEFT):
		var p: Vector2 = make_input_local(ev).position
		if p.distance_to(toque_ini) > 10:
			arrastou = true
		if arrastou:
			rolagem = clampf(toque_rola - (p.y - toque_ini.y), 0.0, rolagem_max())
	elif ev is InputEventMouseMotion and tela == "loja" and (ev.button_mask & MOUSE_BUTTON_MASK_LEFT):
		# a lista da loja rola com o dedo
		var p: Vector2 = make_input_local(ev).position
		if p.distance_to(toque_ini) > 10:
			arrastou = true
		if arrastou:
			rol_loja = clampf(toque_rol_loja - (p.y - toque_ini.y), 0.0, rol_loja_max())
	elif ev is InputEventKey and ev.pressed and ev.keycode == KEY_SPACE and tela == "jogo" and estado == "loja":
		iniciar_onda()


func clique(p: Vector2) -> void:
	clique_jogo(p)
	if tela == "jogo" and estado == "loja":
		salvar_partida()


func clique_jogo(p: Vector2) -> void:
	var b := botoes()
	if estado == "derrota" or estado == "vitoria":
		if estado == "vitoria" and pode_arriscar() and b["arriscar"].has_point(p):
			arriscar()
		elif b["denovo"].has_point(p):
			guardar_pote()
			if tipo_partida == "abismo":
				comecar_abismo()
			elif tipo_partida == "desafio":
				ir_para("inicio")
			elif estado == "vitoria" and capitulo >= TOTAL_CAPITULOS:
				ir_para("inicio")
			else:
				comecar_capitulo(capitulo + (1 if estado == "vitoria" else 0))
		elif b["mundos"].has_point(p):
			guardar_pote()
			if tipo_partida != "capitulo":
				ir_para("modos")
				return
			destaque_cap = capitulo if estado == "vitoria" else 0
			ir_para("mundos")
		return
	if not escolha.is_empty() and estado == "loja":
		for i in escolha["opcoes"].size():
			if b["esc%d" % i].has_point(p):
				escolher(i)
				return
		if not b["voltar"].has_point(p):
			return
	if estado == "onda" and b["onda"].has_point(p):
		if furia >= 100.0:
			soltar_furia()
		return
	if b["voltar"].has_point(p):
		if tipo_partida != "capitulo" or em_risco:
			guardar_pote()
			ir_para("inicio")
			return
		destaque_cap = capitulo   # volta para o mundo deste capítulo
		ir_para("mundos")
		return
	if b["vel"].has_point(p):
		vel_jogo = 2 if vel_jogo == 1 else (4 if vel_jogo == 2 and tem("vel4") else 1)
		return
	if b["som"].has_point(p):
		ligar_som(not som_ligado)
		return
	if estado != "loja":
		return
	for i in 3:
		if b["loja%d" % i].has_point(p) and loja[i] != null:
			if essencia < preco(loja[i]):
				aviso("Essência insuficiente")
				return
			vender = false
			selec = [] if selec == ["loja", i] else ["loja", i]
			return
	if b["trocar"].has_point(p):
		if desafio_regra_ativa("sem_trocas"):
			aviso("Desafio Sem Trocas: a loja não troca")
			return
		var custo := 0 if trocas_gratis > 0 else 2
		if essencia >= custo:
			essencia -= custo
			trocas_gratis = 0
			sortear_loja()
			selec = []
		else:
			aviso("Essência insuficiente")
		return
	if b["lixo"].has_point(p):
		vender = not vender
		selec = []
		aviso("Toque num quadro para vender" if vender else "", 2.0)
		return
	if b["onda"].has_point(p):
		iniciar_onda()
		return
	for i in ANEL.size():
		if ret_quadro(i).has_point(p):
			if quadros[i] == null and cruzamento(i) and selec.is_empty() and not vender:
				aviso("Cruzamento: o Kravenox passa aqui 2 vezes por volta, então o poder dispara 2 vezes", 3.5)
				return
			if quadros[i] == null and terreno[i] != "" and selec.is_empty() and not vender:
				aviso({"fenda": "Fenda: o poder deste quadro dá +50% de dano", "altar": "Altar: cura 3 de vida a cada passo",
					"maldita": "Pedra maldita: não aceita poder, mas dá 1 de essência a cada passo"}[terreno[i]], 3.0)
				return
			clique_quadro(i)
			return
	selec = []


func clique_quadro(i: int) -> void:
	var q = quadros[i]
	if terreno[i] == "maldita" and not selec.is_empty():
		aviso("Pedra maldita: não aceita poder")
		selec = []
		return
	if vender:
		if q != null:
			var v := valor_venda(q)
			essencia += v
			quadros[i] = null
			aviso("Vendido por %d" % v)
		vender = false
		return
	if not selec.is_empty() and selec[0] == "loja":
		var li: int = selec[1]
		var iid: String = loja[li]
		var custo := preco(iid)
		if essencia >= custo and colocar(i, {"id": iid, "nv": 1}):
			essencia -= custo
			som("gema")
			loja[li] = null
		elif essencia >= custo:
			aviso("Quadro ocupado (só funde item igual e de mesmo nível)")
		selec = []
		return
	if not selec.is_empty() and selec[0] == "quadro":
		var de: int = selec[1]
		selec = []
		if de == i:
			return
		var item = quadros[de]
		if q == null:
			quadros[i] = item
			quadros[de] = null
		elif colocar(i, item.duplicate()):
			quadros[de] = null
		else:
			quadros[i] = item   # troca de lugar
			quadros[de] = q
		return
	if q != null:
		selec = ["quadro", i]


# Modo --robo: compra sozinho entre as ondas (prefere fundir) e inicia a próxima.
func passo_robo() -> bool:
	if tipo_partida != "capitulo" and (estado == "vitoria" or estado == "derrota"):
		print("ROBO %s: %s na onda %d · cap %d · bênçãos %s · fragmentos %d" % [tipo_partida, estado, onda, capitulo, str(bencaos), premio_fim])
		get_tree().quit()
		return false
	if estado == "onda" and furia >= 100.0:
		soltar_furia()
	if not escolha.is_empty():
		var ops: Array = escolha["opcoes"]
		var k := 0
		for j in ops.size():
			if not ops[j].get("sombria", false):
				k = j
				break
		escolher(k)
		return true
	if estado == "vitoria" or estado == "derrota":
		var venceu := estado == "vitoria"
		var gastou := true
		while gastou:
			gastou = false
			var melhor := -1
			for i in MELHORIAS.size():
				var m: Dictionary = MELHORIAS[i]
				if nivel_melhoria(m["id"]) < int(m["max"]) and int(prog["fragmentos"]) >= custo_melhoria(m):
					if melhor < 0 or custo_melhoria(m) < custo_melhoria(MELHORIAS[melhor]):
						melhor = i
			if melhor >= 0:
				gastou = comprar_melhoria(melhor)
			elif liberou("acampamento"):
				for i in CONSTRUCOES.size():
					if comprar_obra(i):
						gastou = true
						break
		print("ROBO cap %d: %s na fase %d (tentativa %d) · bônus %s · fragmentos %d · melhorias %s" % [capitulo,
			"venceu" if venceu else "perdeu", onda, robo_tentativas + 1, bonus_res, int(prog["fragmentos"]), str(prog["melhorias"])])
		if venceu:
			robo_tentativas = 0
			if capitulo >= TOTAL_CAPITULOS and modo == "normal" and "--depois-pesadelo" in OS.get_cmdline_user_args():
				print("ROBO: venceu o normal; agora o Pesadelo, com o que juntou")
				modo = "pesadelo"
				comecar_capitulo(1)
				return true
			if capitulo >= TOTAL_CAPITULOS:
				print("ROBO fim: venceu os %d capítulos" % TOTAL_CAPITULOS)
				get_tree().quit()
				return false
			comecar_capitulo(capitulo + 1)
		else:
			robo_tentativas += 1
			if robo_tentativas >= 8:
				print("ROBO fim: parou no capítulo %d" % capitulo)
				get_tree().quit()
				return false
			comecar_capitulo(capitulo)
		return true
	if estado != "loja":
		return true
	var b := botoes()
	for i in 3:
		if loja[i] != null and essencia >= preco(loja[i]):
			clique(b["loja%d" % i].get_center())
			var alvo := -1
			for k in ANEL.size():
				if quadros[k] != null and quadros[k]["id"] == loja[i] and quadros[k]["nv"] == 1:
					alvo = k
					break
			if alvo < 0:
				for k in ANEL.size():
					if quadros[k] == null and terreno[k] != "maldita":
						alvo = k
						break
			if alvo >= 0:
				clique(ret_quadro(alvo).get_center())
			else:
				selec = []
	if essencia >= 14 and quadros.any(func(q): return q == null or q["nv"] < 3):
		clique(b["trocar"].get_center())
		return true
	clique(b["onda"].get_center())
	return true



# ------------------------------------------------------------ desenho
func caixa(r: Rect2, cor: Color, raio := 6, borda := 0, cor_borda := Color.BLACK, centro := true, sombra := 0) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = cor
	sb.draw_center = centro
	sb.set_corner_radius_all(raio)
	# sem suavização nem sombra desfocada: as duas geram muitas formas por caixa e
	# pesavam no celular. A sombra virou uma caixa escura deslocada.
	sb.anti_aliasing = false
	sb.corner_detail = 3
	if borda > 0:
		sb.set_border_width_all(borda)
		sb.border_color = cor_borda
	if sombra > 0 and centro:
		var sb2 := StyleBoxFlat.new()
		sb2.bg_color = Color(0, 0, 0, 0.45)
		sb2.set_corner_radius_all(raio + 1)
		sb2.anti_aliasing = false
		sb2.corner_detail = 3
		draw_style_box(sb2, Rect2(r.position + Vector2(0, 3), r.size + Vector2(0, 1)))
	draw_style_box(sb, r)


# Retângulo com degradê vertical (pedra iluminada de cima)
func degrade(r: Rect2, cima: Color, baixo: Color) -> void:
	draw_polygon(PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]),
		PackedColorArray([cima, cima, baixo, baixo]))


# Brilho redondo: uma imagem pronta de degradê, tingida (antes eram 6 círculos
# por brilho, o que pesava muito no celular).
var tex_brilho: Texture2D


func brilho_suave(c: Vector2, r: float, cor: Color, forca := 1.0) -> void:
	if tex_brilho == null:
		var n := 64
		var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
		for y in n:
			for x in n:
				var d := Vector2(x + 0.5 - n / 2.0, y + 0.5 - n / 2.0).length() / (n / 2.0)
				var a := clampf(1.0 - d, 0.0, 1.0)
				img.set_pixel(x, y, Color(1, 1, 1, a * a * 0.9 + a * 0.1))
		img.generate_mipmaps()
		tex_brilho = ImageTexture.create_from_image(img)
	draw_texture_rect(tex_brilho, Rect2(c - Vector2(r, r), Vector2(r, r) * 2), false, Color(cor, minf(1.0, 0.42 * forca)))


func escrever(t: String, centro: Vector2, tam: int, cor: Color, contorno := true, f: Font = null) -> void:
	t = tx(t)
	if f == null:
		f = fonte
	var w := f.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x
	var p := Vector2(centro.x - w / 2, centro.y + tam * 0.36)
	if contorno:
		draw_string_outline(f, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, 6, Color(TINTA, cor.a * 0.9))
	draw_string(f, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, cor)


func escrever_esq(t: String, p: Vector2, tam: int, cor: Color, f: Font = null) -> void:
	t = tx(t)
	if f == null:
		f = fonte
	draw_string_outline(f, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, 6, Color(TINTA, 0.9))
	draw_string(f, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, cor)


func botao(r: Rect2, t: String, cor: Color, ativo := true, cheio := false) -> void:
	var c := cor if ativo else Color(CINZA, 0.5)
	if cheio and ativo:
		caixa(r, Color(cor.darkened(0.55), 0.95), 7, 2, c, true, 4)
		degrade(Rect2(r.position + Vector2(3, 3), Vector2(r.size.x - 6, r.size.y * 0.4)), Color(1, 1, 1, 0.1), Color(1, 1, 1, 0))
	else:
		caixa(r, Color(0.07, 0.06, 0.09, 0.92), 7, 2, Color(c, 0.85), true, 4)
	escrever(t, r.get_center(), 18, c if not cheio else BRANCO, false)


func cristal(c: Vector2, s: float, cor := Color(0, 0, 0, 0)) -> void:
	if cor.a == 0:
		cor = ROXO
	brilho_suave(c, s * 2.2, cor, 0.8)
	var pts := PackedVector2Array([c + Vector2(0, -s), c + Vector2(s * 0.6, -s * 0.15), c + Vector2(0, s), c + Vector2(-s * 0.6, -s * 0.15)])
	draw_colored_polygon(pts, cor.darkened(0.3))
	draw_colored_polygon(PackedVector2Array([c + Vector2(0, -s), c + Vector2(s * 0.6, -s * 0.15), c + Vector2(0, s * 0.1)]), cor.lightened(0.35))
	pts.append(pts[0])
	draw_polyline(pts, Color(TINTA, 0.8), 1.2, true)


# Desenha uma arte com o pé em "base", altura "alt" na tela.
func desenhar_arte(nome: String, base: Vector2, alt: float, virar: bool, mod := Color.WHITE,
		branco := false, giro := 0.0, esmaga := Vector2.ONE) -> Rect2:
	var t: Texture2D = tex_branca[nome] if branco else tex[nome]
	if not branco and nome.begins_with("kravenox"):
		var sk := skin_atual()
		if sk != "":
			t = textura_skin(sk, nome)
	var esc := alt / t.get_height()
	var tam := t.get_size() * esc
	draw_set_transform(base, giro, Vector2(-esmaga.x if virar else esmaga.x, esmaga.y))
	draw_texture_rect(t, Rect2(Vector2(-tam.x / 2, -tam.y), tam), false, mod)
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
	return Rect2(base.x - tam.x / 2, base.y - tam.y * esmaga.y, tam.x, tam.y * esmaga.y)


# Contorno de luz: a silhueta branca tingida, desenhada em volta da arte.
func contorno(nome: String, base: Vector2, alt: float, virar: bool, cor: Color, giro := 0.0, esmaga := Vector2.ONE) -> void:
	for d in [Vector2(-2, 0), Vector2(2, 0), Vector2(0, -2), Vector2(0, 2)]:
		desenhar_arte(nome, base + d, alt, virar, cor, true, giro, esmaga)


func sombra_chao(c: Vector2, rx: float, a := 0.55) -> void:
	draw_set_transform(c, 0, Vector2(1, 0.28))
	for k in 3:
		draw_circle(Vector2.ZERO, rx * (1.0 - k * 0.2), Color(0, 0, 0, a * 0.4))
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)


func desenhar_fundo(veu := 0.38) -> void:
	# a pintura da Cratera do Cisma, escurecida para o que vem por cima aparecer
	draw_texture_rect(fundo, Rect2(0, 0, LARG, ALT), false)
	draw_rect(Rect2(0, 0, LARG, ALT), Color(0.03, 0.02, 0.06, veu))
	draw_texture_rect(vinheta, Rect2(0, 0, LARG, ALT), false)
	# névoa roxa lenta sobre a cratera
	for k in 3:
		var p := Vector2(LARG / 2 + sin(tempo * 0.2 + k * 2.1) * 120, 390 + cos(tempo * 0.17 + k) * 80)
		brilho_suave(p, 170, ROXO_ESC, 0.5)


func _draw() -> void:
	match tela:
		"abertura":
			desenhar_abertura()
		"inicio":
			desenhar_inicio()
		"mundos":
			desenhar_mundos()
		"melhorias":
			desenhar_melhorias()
		"bestiario":
			desenhar_bestiario()
		"missoes":
			desenhar_missoes()
		"kravenox":
			desenhar_kravenox_tela()
		"formas":
			desenhar_formas()
		"conquistas":
			desenhar_conquistas()
		"ajustes":
			desenhar_ajustes()
		"acampamento":
			desenhar_acampamento()
		"pactos":
			desenhar_pactos()
		"grimorio":
			desenhar_grimorio()
		"cronicas":
			desenhar_cronicas()
		"ecos":
			desenhar_ecos()
		"modos":
			desenhar_modos()
		"loja":
			desenhar_loja_apoiador()
		"jogos":
			desenhar_jogos()
		"beta":
			desenhar_beta()
		"duelo":
			desenhar_duelo()
		"online":
			desenhar_online()
		"ranking":
			desenhar_ranking()
		"ordem":
			desenhar_ordem()
		"especial":
			desenhar_esp()
		_:
			desenhar_jogo()


func desenhar_jogo() -> void:
	desenhar_fundo()
	for i in ANEL.size():
		desenhar_quadro(i)
	desenhar_sinergias()
	desenhar_mundo()
	desenhar_topo()   # por cima dos monstros que entram pelo alto
	desenhar_loja()
	desenhar_tutorial()
	desenhar_skin_ganha()
	desenhar_arrasto()
	if msg_t > 0 and msg != "" and escolha.is_empty():
		var w := fonte.get_string_size(msg, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
		var a := clampf(msg_t * 2, 0, 1)
		caixa(Rect2(LARG / 2 - w / 2 - 14, 158, w + 28, 28), Color(0.05, 0.04, 0.07, 0.9 * a), 14, 1, Color(OURO, 0.7 * a))
		escrever(msg, Vector2(LARG / 2, 172), 18, Color(BRANCO, a), false)
	if not escolha.is_empty() and estado == "loja":
		desenhar_escolha()
	if estado == "derrota" or estado == "vitoria":
		desenhar_fim()


func desenhar_fim() -> void:
	draw_rect(Rect2(0, 0, LARG, ALT), Color(0.02, 0.01, 0.03, 0.84))
	var venceu := estado == "vitoria"
	var final := venceu and capitulo >= TOTAL_CAPITULOS and tipo_partida == "capitulo"
	var base := Vector2(LARG / 2, ALT / 2 - 110)
	brilho_suave(base + Vector2(0, -70), 120, OURO if venceu else VERMELHO, 0.7)
	desenhar_arte("kravenox", base, 140, false, Color.WHITE if venceu else Color(0.45, 0.4, 0.5))
	var titulo := "O REINO É DO KRAVENOX" if final else ("CAPÍTULO CONCLUÍDO" if venceu else "O KRAVENOX CAIU")
	var t2 := "Capítulo %d · %s" % [capitulo, CAPITULOS[capitulo - 1]] if venceu else "Chegou à fase %d de %d" % [onda, FASES]
	if tipo_partida == "abismo":
		titulo = "NOVO RECORDE!" if abismo_novo_rec else "O ABISMO VENCEU"
		t2 = "Venceu %d ondas · recorde: %d" % [maxi(0, onda - 1), int(prog.get("abismo_rec", 0))]
	elif tipo_partida == "desafio":
		titulo = "DESAFIO VENCIDO" if venceu else "DESAFIO PERDIDO"
		t2 = "Desafio do Dia · %s" % regra_desafio()["nome"]
	elif bonus_res == "risco" or bonus_res == "risco_caiu":
		titulo = "O POTE CRESCEU" if bonus_res == "risco" else "CAIU ARRISCANDO"
	escrever(titulo, Vector2(LARG / 2, ALT / 2 - 76), 26, OURO if venceu else VERMELHO, true, fonte_titulo)
	escrever(t2, Vector2(LARG / 2, ALT / 2 - 42), 17, BRANCO)
	cristal(Vector2(LARG / 2 - 58, ALT / 2 - 8), 9, VERMELHO)
	escrever_esq("+%d fragmentos" % premio_fim, Vector2(LARG / 2 - 42, ALT / 2), 19, Color8(255, 170, 160))
	if bonus_res == "ok":
		escrever("Bônus: a torre ficou de pé! (+%d)" % premio_bonus, Vector2(LARG / 2, ALT / 2 + 18), 15, OURO, false)
	elif bonus_res == "caiu":
		escrever("Bônus: a torre caiu", Vector2(LARG / 2, ALT / 2 + 18), 15, CINZA, false)
	elif bonus_res == "risco":
		escrever("Pote do risco: %d fragmentos (cair = perde metade)" % risco_pote, Vector2(LARG / 2, ALT / 2 + 18), 15, OURO, false)
	elif bonus_res == "risco_caiu":
		escrever("Ficou com metade do pote", Vector2(LARG / 2, ALT / 2 + 18), 15, CINZA, false)
	if nova_cronica and venceu and tipo_partida == "capitulo":
		escrever("Nova crônica liberada (tela do Kravenox)", Vector2(LARG / 2, ALT / 2 + 290), 14, Color8(200, 180, 255), false)
	var t_botao := "Início" if final else ("Próximo capítulo" if venceu else "Tentar de novo")
	if tipo_partida == "abismo":
		t_botao = "Tentar de novo"
	elif tipo_partida == "desafio":
		t_botao = "Início"
	elif bonus_res == "risco":
		t_botao = "Guardar e seguir"
	botao(botoes()["denovo"], t_botao, OURO, true, true)
	botao(botoes()["mundos"], "Mundos" if tipo_partida == "capitulo" else "Modos", AZUL)
	if venceu and pode_arriscar():
		botao(botoes()["arriscar"], "Arriscar mais uma onda", VERMELHO)


func desenhar_escolha() -> void:
	draw_rect(Rect2(0, 0, LARG, ALT), Color(0.02, 0.01, 0.04, 0.82))
	var b := botoes()
	var y := 150.0
	escrever(escolha["titulo"], Vector2(LARG / 2, y), 22, OURO, true, fonte_titulo)
	var txt := str(escolha.get("texto", ""))
	if txt != "":
		texto_quebrado(txt, Vector2(34, y + 36), LARG - 68, 16, Color8(232, 222, 205), 6, true)
	var ops: Array = escolha["opcoes"]
	for i in ops.size():
		var op: Dictionary = ops[i]
		var r: Rect2 = b["esc%d" % i]
		var sombria: bool = op.get("sombria", false)
		var cor := VERMELHO if sombria else OURO
		caixa(r, Color8(34, 12, 18) if sombria else Color8(24, 20, 34), 12, 2, cor, true, 8)
		degrade(Rect2(r.position + Vector2(3, 3), Vector2(r.size.x - 6, 40)), Color(1, 1, 1, 0.08), Color(1, 1, 1, 0))
		var c := r.position + Vector2(48, r.size.y / 2)
		brilho_suave(c, 40, cor, 0.8 + 0.2 * sin(tempo * 3 + i))
		if escolha["tipo"] == "bencao":
			cristal(c, 16, Color8(200, 30, 50) if sombria else Color8(255, 210, 120))
		elif escolha["tipo"] == "hab":
			icone(str(op["icone"]), c, 0.75)
		else:
			icone_escolha(str(op["id"]), c)
		escrever_esq(op["nome"], r.position + Vector2(92, 38), 18, Color8(255, 150, 140) if sombria else OURO, fonte_titulo)
		texto_quebrado(str(op["desc"]), r.position + Vector2(92, 52), r.size.x - 108, 15, BRANCO, 3)
		if sombria:
			escrever("SOMBRIA", Vector2(r.end.x - 52, r.position.y + 16), 11, VERMELHO, false, fonte_titulo)


func icone_escolha(id: String, c: Vector2) -> void:
	match id:
		"livro", "seguir":
			poli([c + Vector2(-18, -12), c + Vector2(-1, -9), c + Vector2(-1, 14), c + Vector2(-18, 11)], Color8(150, 110, 70), 1.2)
			poli([c + Vector2(18, -12), c + Vector2(1, -9), c + Vector2(1, 14), c + Vector2(18, 11)], Color8(180, 140, 90), 1.2)
		"elite":
			var e := []
			for k in 10:
				e.append(c + Vector2.from_angle(-PI / 2 + k * TAU / 10) * (18.0 if k % 2 == 0 else 8.0))
			poli(e, VERMELHO, 1.5)
		"fogueira", "descansar":
			poli([c + Vector2(-12, 14), c + Vector2(0, -18), c + Vector2(12, 14)], Color8(255, 140, 40), 1.2)
			poli([c + Vector2(-6, 14), c + Vector2(0, -4), c + Vector2(6, 14)], Color8(255, 230, 120))
		_:
			cristal(c, 16, ROXO)


# Texto em várias linhas, alinhado à esquerda (ou centralizado). Devolve a altura usada.
func texto_quebrado(t: String, p: Vector2, largura: float, tam: int, cor: Color, max_linhas := 12, centro := false) -> float:
	t = tx(t)
	var palavras := t.split(" ")
	var linhas := []
	var atual := ""
	for w in palavras:
		var tenta := (atual + " " + w).strip_edges()
		if fonte.get_string_size(tenta, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x > largura and atual != "":
			linhas.append(atual)
			atual = w
		else:
			atual = tenta
	if atual != "":
		linhas.append(atual)
	if linhas.size() > max_linhas:
		linhas = linhas.slice(0, max_linhas)
		linhas[-1] = encurtar(linhas[-1] + " …", fonte, tam, largura)
	var alt := tam * 1.3
	for i in linhas.size():
		if centro:
			escrever(linhas[i], Vector2(p.x + largura / 2, p.y + i * alt + tam * 0.5), tam, cor, false)
		else:
			draw_string(fonte, Vector2(p.x, p.y + (i + 1) * alt - tam * 0.3), linhas[i], HORIZONTAL_ALIGNMENT_LEFT, -1, tam, cor)
	return linhas.size() * alt


# Correntes de luz entre quadros vizinhos que combinam.
func desenhar_sinergias() -> void:
	if not liberou("sinergias"):
		return
	var n := ROTA.size()
	for p in n:
		var i: int = ROTA[p]
		var j: int = ROTA[(p + 1) % n]
		if j == i:
			continue
		var a = quadros[i]
		var b = quadros[j]
		if a == null or b == null:
			continue
		var nome := nome_sinergia(a["id"], b["id"])
		if nome == "":
			continue
		var pa := centro_quadro(i)
		var pb := centro_quadro(j)
		var meio := (pa + pb) / 2
		var pulsa := 0.6 + 0.4 * sin(tempo * 4 + i)
		draw_line(pa.lerp(pb, 0.3), pa.lerp(pb, 0.7), Color(ROXO, 0.35 * pulsa), 9, true)
		draw_line(pa.lerp(pb, 0.3), pa.lerp(pb, 0.7), Color8(230, 200, 255), 2.5, true)
		var d := PackedVector2Array([meio + Vector2(0, -6), meio + Vector2(6, 0), meio + Vector2(0, 6), meio + Vector2(-6, 0)])
		draw_colored_polygon(d, OURO if nome != "Eco" else Color8(230, 200, 255))


func desenhar_terreno(i: int, r: Rect2) -> void:
	var c := r.get_center()
	match terreno[i]:
		"fenda":
			var pts := PackedVector2Array([r.position + Vector2(10, 14), c + Vector2(-6, -4), c + Vector2(4, 6), r.end - Vector2(10, 12)])
			draw_polyline(pts, Color(VERMELHO, 0.35), 7, true)
			draw_polyline(pts, Color8(255, 120, 90), 2, true)
		"altar":
			draw_arc(c, r.size.x * 0.36, 0, TAU, 30, Color(OURO, 0.45), 2, true)
			for k in 4:
				var a := k * TAU / 4 + tempo * 0.5
				draw_circle(c + Vector2.from_angle(a) * r.size.x * 0.36, 2.5, Color(OURO, 0.8))
		"maldita":
			draw_rect(r.grow(-4), Color(0.1, 0.0, 0.15, 0.55))
			draw_line(c + Vector2(-14, -14), c + Vector2(14, 14), Color(ROXO, 0.7), 4, true)
			draw_line(c + Vector2(14, -14), c + Vector2(-14, 14), Color(ROXO, 0.7), 4, true)
			draw_circle(c, 6, Color8(40, 20, 60))


func desenhar_topo() -> void:
	degrade(Rect2(0, 0, LARG, 150), Color(0.02, 0.01, 0.03, 0.85), Color(0.02, 0.01, 0.03, 0.0))
	var bv: Rect2 = botoes()["voltar"]
	botao(bv, "", OURO)
	draw_polyline(PackedVector2Array([bv.get_center() + Vector2(4, -8), bv.get_center() + Vector2(-4, 0), bv.get_center() + Vector2(4, 8)]), OURO, 2.5, true)
	var t := "FASE %d/%d" % [maxi(onda, 1) if estado == "onda" else mini(onda + 1, FASES), FASES]
	if onda > FASES or bonus_pendente:
		t = "BÔNUS"
	if em_risco:
		t = "RISCO %d" % risco_n
	elif tipo_partida == "abismo":
		t = "ONDA %d" % (onda if estado == "onda" else onda + 1)
	var w := fonte_titulo.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
	escrever_esq(t, Vector2(LARG - 16 - w, 31), 14, BRANCO, fonte_titulo)
	var tit_txt := ("PESADELO · " if pesadelo_ativo() else "") + "CAP. %d · %s" % [capitulo, CAPITULOS[capitulo - 1].to_upper()]
	if tipo_partida == "abismo":
		tit_txt = "ABISMO SEM FIM · RECORDE %d" % int(prog.get("abismo_rec", 0))
	elif tipo_partida == "desafio":
		tit_txt = tx("DESAFIO · ") + tx(regra_desafio()["nome"]).to_upper()
	var tit := encurtar(tit_txt, fonte_titulo, 13, LARG - 80 - w)
	escrever_esq(tit, Vector2(56, 31), 13, OURO, fonte_titulo)
	# trilha das fases
	var y := 60.0
	var x0 := 70.0
	var x1 := LARG - 70.0
	draw_line(Vector2(x0, y), Vector2(x1, y), Color(0, 0, 0, 0.7), 5)
	var feito_x := x0 + (x1 - x0) * clampf((onda - 1) / float(FASES - 1), 0, 1)
	if onda > 1:
		draw_line(Vector2(x0, y), Vector2(feito_x, y), SANGUE, 3)
	# a estrela do bônus, depois da fase do chefe
	var pe := Vector2(x1 + 34, y)
	var no_bonus := onda > FASES or bonus_pendente
	draw_line(Vector2(x1, y), pe, Color(0, 0, 0, 0.7), 3)
	if onda > FASES and estado == "onda":
		brilho_suave(pe, 24, OURO, 1.4)
	var est := []
	for k in 10:
		est.append(pe + Vector2.from_angle(-PI / 2 + k * TAU / 10) * (9.0 if k % 2 == 0 else 4.0))
	poli(est, OURO if no_bonus else PEDRA_CLARA, 1.2)
	for o in range(1, FASES + 1):
		var x := x0 + (x1 - x0) * (o - 1) / (FASES - 1)
		var p := Vector2(x, y)
		var feita := o < onda or (o == onda and estado != "onda")
		var atual := o == onda and estado == "onda"
		if o == FASES:
			var r := 10.0
			var cor := ROXO if not feita else SANGUE
			if atual:
				brilho_suave(p, 26, ROXO, 1.4)
			var d := PackedVector2Array([p + Vector2(0, -r), p + Vector2(r, 0), p + Vector2(0, r), p + Vector2(-r, 0)])
			draw_colored_polygon(d, PEDRA_ESC)
			var d2 := d.duplicate()
			d2.append(d[0])
			draw_polyline(d2, cor, 2, true)
			draw_circle(p, 3, cor)
		else:
			if atual:
				brilho_suave(p, 20, VERMELHO, 1.5)
			draw_circle(p, 8.5, TINTA)
			draw_circle(p, 7, VERMELHO if atual else (SANGUE if feita else PEDRA_CLARA))
	# essência
	caixa(Rect2(16, 84, 122, 40), Color(0.05, 0.04, 0.07, 0.85), 8, 1, Color(ROXO, 0.5))
	cristal(Vector2(38, 104), 11)
	escrever_esq(str(essencia), Vector2(58, 113), 24, BRANCO)
	# vida
	var bw := 196.0
	var bx := 148.0
	caixa(Rect2(bx, 88, bw, 30), Color(0.05, 0.04, 0.07, 0.9), 8, 1, Color(VERMELHO, 0.5))
	var fr := clampf(hp / hp_max, 0, 1)
	if fr > 0:
		var r := Rect2(bx + 4, 92, (bw - 8) * fr, 22)
		degrade(r, Color8(200, 40, 44), Color8(110, 14, 20))
		draw_line(r.position + Vector2(2, 3), Vector2(r.end.x - 2, r.position.y + 3), Color(1, 1, 1, 0.18), 2)
	if escudo > 0:
		var re := Rect2(bx + 4, 110, (bw - 8) * clampf(escudo / hp_max, 0, 1), 5)
		degrade(re, Color8(150, 200, 255), Color8(60, 110, 220))
	var tv := "%d / %d" % [int(maxf(0, hp)), int(hp_max)]
	if escudo > 0:
		tv += "  +%d" % int(escudo)
	escrever(tv, Vector2(bx + bw / 2, 103), 16, BRANCO)
	botao(botoes()["vel"], "x%d" % vel_jogo, OURO)
	var bs: Rect2 = botoes()["som"]
	botao(bs, "", OURO if som_ligado else CINZA)
	var c := bs.get_center() + Vector2(-4, 0)
	var cor := OURO if som_ligado else CINZA
	draw_colored_polygon(PackedVector2Array([c + Vector2(-8, -4), c + Vector2(-3, -4), c + Vector2(3, -10),
		c + Vector2(3, 10), c + Vector2(-3, 4), c + Vector2(-8, 4)]), cor)
	if som_ligado:
		draw_arc(c + Vector2(4, 0), 6, -0.9, 0.9, 8, cor, 2, true)
		draw_arc(c + Vector2(4, 0), 11, -0.9, 0.9, 10, cor, 2, true)
	else:
		draw_line(c + Vector2(7, -5), c + Vector2(15, 5), cor, 2, true)
		draw_line(c + Vector2(15, -5), c + Vector2(7, 5), cor, 2, true)


var tex_laje := {}


# Pinta a laje de pedra uma vez (com borda, degradê, miolo e rachaduras) e a
# reaproveita em todos os quadros. A versão vazia já traz o "+" roxo.
func textura_laje(vazia: bool) -> Texture2D:
	if tex_laje.has(vazia):
		return tex_laje[vazia]
	var n := 100
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var m := 3   # margem para a sombra
	img.fill_rect(Rect2i(m + 1, m + 4, n - 2 * m, n - 2 * m), Color(0, 0, 0, 0.5))   # sombra
	for y in range(m, n - m):
		var t := float(y - m) / (n - 2 * m)
		var cor := PEDRA_CLARA.lerp(PEDRA_ESC, t)
		img.fill_rect(Rect2i(m, y, n - 2 * m, 1), cor)
	var b := PEDRA_BORDA
	img.fill_rect(Rect2i(m, m, n - 2 * m, 2), b)
	img.fill_rect(Rect2i(m, n - m - 2, n - 2 * m, 2), b)
	img.fill_rect(Rect2i(m, m, 2, n - 2 * m), b)
	img.fill_rect(Rect2i(n - m - 2, m, 2, n - 2 * m), b)
	var dentro := Rect2i(m + 8, m + 8, n - 2 * m - 16, n - 2 * m - 16)
	img.fill_rect(dentro, Color(0.06, 0.05, 0.08, 1).lerp(PEDRA_ESC, 0.35))
	img.fill_rect(Rect2i(dentro.position, Vector2i(dentro.size.x, 1)), Color(0, 0, 0, 0.6))
	img.fill_rect(Rect2i(dentro.position, Vector2i(1, dentro.size.y)), Color(0, 0, 0, 0.6))
	for k in [[20, 30, 1, 1], [60, 70, 1, -1], [70, 20, -1, 1]]:
		for j in 12:
			img.set_pixel(k[0] + j * k[2], k[1] + j * k[3] / 2, Color(0, 0, 0, 0.45))
	# cantos arredondados de leve
	for c in [Vector2i(m, m), Vector2i(n - m - 1, m), Vector2i(m, n - m - 1), Vector2i(n - m - 1, n - m - 1)]:
		img.set_pixelv(c, Color(0, 0, 0, 0))
	if vazia:
		var cc := Color(ROXO, 0.3)
		var meio := n / 2
		img.fill_rect(Rect2i(meio - 11, meio - 1, 22, 2), cc)
		img.fill_rect(Rect2i(meio - 1, meio - 11, 2, 22), cc)
		for k in 64:
			var a := k * TAU / 64
			img.set_pixel(meio + int(cos(a) * 17), meio + int(sin(a) * 17), Color(ROXO, 0.2))
	img.generate_mipmaps()
	tex_laje[vazia] = ImageTexture.create_from_image(img)
	return tex_laje[vazia]


func desenhar_quadro(i: int) -> void:
	var r := ret_quadro(i)
	var q = quadros[i]
	var sel := selec == ["quadro", i]
	var luz: float = brilho[i] / 0.35
	# laje de pedra: uma imagem pronta (antes eram várias caixas e linhas por quadro)
	draw_texture_rect(textura_laje(q == null and terreno[i] != "maldita"), r.grow(3), false)
	if terreno[i] != "":
		desenhar_terreno(i, r)
	if cruzamento(i):
		# cruzamento: o Kravenox passa aqui duas vezes por volta
		draw_line(r.position + Vector2(6, r.size.y / 2), r.end - Vector2(6, r.size.y / 2), Color(OURO, 0.18), 3)
		draw_line(r.position + Vector2(r.size.x / 2, 6), r.end - Vector2(r.size.x / 2, 6), Color(OURO, 0.18), 3)
		caixa(Rect2(r.end - Vector2(30, r.size.y - 4), Vector2(26, 18)), Color(0.1, 0.07, 0.02, 0.9), 5, 1, OURO)
		escrever("×2", r.end - Vector2(17, r.size.y - 13), 12, OURO, false)
	var mol := cor_moldura()
	if mol.a > 0 and q != null:
		caixa(r.grow(2), Color(0, 0, 0, 0), 7, 2, Color(mol, 0.85 + 0.15 * sin(tempo * 3 + i)), false)
	var lend: bool = q != null and q.get("lend", false)
	if lend:
		brilho_suave(r.get_center(), 62, OURO, 0.7 + 0.3 * sin(tempo * 3))
		caixa(r.grow(1), Color(0, 0, 0, 0), 7, 2, OURO, false)
	if luz > 0:
		caixa(r.grow(1), Color(0, 0, 0, 0), 7, 3, Color(ROXO, luz), false)
		brilho_suave(r.get_center(), 60, ROXO, luz)
	if sel or (vender and q != null):
		caixa(r.grow(3), Color(0, 0, 0, 0), 8, 3, OURO if sel else VERMELHO, false)
	var c := r.get_center()
	if q == null:
		pass   # o "+" roxo já vem na imagem da laje vazia
	elif not (not arrasto.is_empty() and arrasto["moveu"] and arrasto["de"] == "quadro" and arrasto["i"] == i):
		icone(q["id"], c + Vector2(0, -4), 0.95)
		if lend:
			# coroa dourada: poder lendário
			var cc := c + Vector2(0, -TAM / 2 + 8)
			poli([cc + Vector2(-12, 5), cc + Vector2(-12, -5), cc + Vector2(-6, 0), cc + Vector2(0, -8), cc + Vector2(6, 0), cc + Vector2(12, -5), cc + Vector2(12, 5)], OURO, 1.2)
		# nível em marcas douradas
		var n: int = q["nv"]
		for k in n:
			var px := c.x + (k - (n - 1) / 2.0) * 10
			var p := Vector2(px, r.end.y - 11)
			var d := PackedVector2Array([p + Vector2(0, -4), p + Vector2(3.5, 0), p + Vector2(0, 4), p + Vector2(-3.5, 0)])
			draw_colored_polygon(d, OURO)


func poli(pts: Array, cor: Color, borda := 0.0, cor_borda := Color(0, 0, 0, 0.85)) -> void:
	var p := PackedVector2Array(pts)
	draw_colored_polygon(p, cor)
	if borda > 0:
		p.append(p[0])
		draw_polyline(p, cor_borda, borda, true)


func icone(iid: String, c: Vector2, e: float) -> void:
	var cor: Color = ITENS[iid]["cor"]
	var P := func(x: float, y: float) -> Vector2: return c + Vector2(x, y) * e
	brilho_suave(c, 34 * e, cor, 0.9)
	match iid:
		"garras":
			# três garras curvas, vermelho escuro com fio claro
			for k in [-11.0, 0.0, 11.0]:
				var pts := []
				for j in 7:
					var t := j / 6.0
					pts.append(P.call(k - 5 + t * 9 + sin(t * 2.4) * 4, 18 - t * 38))
				for j in range(6, -1, -1):
					var t := j / 6.0
					pts.append(P.call(k + 1 + t * 5 + sin(t * 2.4) * 4, 18 - t * 38 + t * 2))
				poli(pts, cor.darkened(0.45), 1.5)
				draw_line(P.call(k - 2, 14), P.call(k + 6, -16), Color(1, 0.75, 0.7, 0.7), 1.5, true)
		"espinhos":
			var pts := []
			for j in 24:
				var a := j / 24.0 * TAU
				var rr := 24.0 if j % 2 == 0 else 10.0
				pts.append(P.call(cos(a) * rr, sin(a) * rr))
			poli(pts, Color8(16, 12, 18), 1.0, Color(cor, 0.7))
			draw_circle(c, 7 * e, cor.darkened(0.3))
			draw_circle(c + Vector2(-2, -2) * e, 3 * e, Color(1, 0.6, 0.6, 0.8))
		"raio":
			var pts := [P.call(-3, -26), P.call(11, -26), P.call(3, -6), P.call(12, -6), P.call(-9, 26), P.call(-2, 3), P.call(-11, 3)]
			poli(pts, cor.darkened(0.2), 1.5)
			draw_polyline(PackedVector2Array([P.call(5, -22), P.call(-1, -2), P.call(6, -3), P.call(-4, 16)]), Color(1, 0.92, 1, 0.9), 1.5, true)
		"esmagamento":
			draw_arc(P.call(0, 10), 26 * e, PI * 1.1, PI * 1.9, 20, Color(cor, 0.8), 2, true)
			poli([P.call(-16, 4), P.call(-8, -12), P.call(8, -14), P.call(17, 0), P.call(10, 12), P.call(-10, 12)], Color8(70, 58, 52), 1.5)
			draw_polyline(PackedVector2Array([P.call(-4, -10), P.call(0, -2), P.call(-6, 6)]), Color(0, 0, 0, 0.8), 1.5, true)
			draw_polyline(PackedVector2Array([P.call(0, -2), P.call(9, 3)]), Color(0, 0, 0, 0.8), 1.5, true)
			for k in [-1.0, 1.0]:
				draw_line(P.call(k * 20, 16), P.call(k * 28, 22), Color(cor, 0.8), 2, true)
		"rasgo":
			draw_set_transform(c, 0.35, Vector2(0.34, 1.0))
			draw_circle(Vector2.ZERO, 27 * e, Color(cor, 0.5))
			draw_circle(Vector2.ZERO, 22 * e, cor)
			draw_circle(Vector2.ZERO, 15 * e, Color8(20, 4, 10))
			draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
		"cristal":
			for d in [[-10.0, 6.0, 12.0], [10.0, 8.0, 10.0], [0.0, -2.0, 20.0]]:
				var x: float = d[0]
				var y: float = d[1]
				var s: float = d[2]
				var pts := [P.call(x, y - s), P.call(x + s * 0.45, y), P.call(x, y + s * 0.6), P.call(x - s * 0.45, y)]
				poli(pts, cor.darkened(0.25), 1.2)
				poli([P.call(x, y - s), P.call(x + s * 0.45, y), P.call(x, y + s * 0.1)], Color(cor.lightened(0.4), 0.9))
		"passo":
			# salto: um arco com a ponta de seta
			draw_arc(P.call(0, 14), 20 * e, PI * 1.05, PI * 1.95, 18, Color(0, 0, 0, 0.8), 6, true)
			draw_arc(P.call(0, 14), 20 * e, PI * 1.05, PI * 1.95, 18, cor, 3.5, true)
			poli([P.call(14, 2), P.call(24, 4), P.call(19, 14)], cor, 1.2)
			draw_circle(P.call(-19, 16), 3.5 * e, cor)
			draw_circle(P.call(19, 16), 3.5 * e, Color(cor, 0.5))
		"corrida":
			for k in [-9.0, 5.0]:
				poli([P.call(k - 9, -15), P.call(k + 7, 0), P.call(k - 9, 15), P.call(k - 3, 0)], cor.darkened(0.2), 1.5)
			for y in [-8.0, 0.0, 8.0]:
				draw_line(P.call(-26, y), P.call(-16, y), Color(cor, 0.55), 2)
		"escudo":
			var pts := [P.call(0, -24), P.call(18, -16), P.call(16, 6), P.call(0, 24), P.call(-16, 6), P.call(-18, -16)]
			poli(pts, cor.darkened(0.35), 1.5)
			poli([P.call(0, -18), P.call(12, -12), P.call(10, 4), P.call(0, 16)], Color(cor.lightened(0.3), 0.9))
			for k in [-1.0, 1.0]:
				poli([P.call(k * 18, -16), P.call(k * 26, -24), P.call(k * 14, -20)], Color8(20, 16, 24))
		"fonte":
			cristal(c, 22 * e, cor)
			for k in 3:
				var a := tempo * 1.5 + k * TAU / 3
				draw_circle(c + Vector2(cos(a), sin(a) * 0.6) * 22 * e, 2 * e, Color(1, 0.9, 1, 0.8))


func desenhar_mundo() -> void:
	var k := k_vis
	var itens := []
	for m in monstros:
		itens.append([m["pos"].y, m])
	itens.append([k.y, null])
	if bonus_ativo() or (estado == "vitoria" and bonus_res in ["ok", "caiu"]):
		itens.append([CENTRO.y + 20, "torre"])
	itens.sort_custom(func(a, b): return a[0] < b[0])
	for it in itens:
		var m = it[1]
		if m == null:
			desenhar_kravenox(k)
		elif m is String:
			desenhar_torre()
		else:
			desenhar_monstro(m, k)
	desenhar_efeitos()


func desenhar_efeitos() -> void:
	# tiros: orbes com brilho
	for t in tiros:
		brilho_suave(t["p"], t["r"] * 3, t["cor"], 1.2)
		draw_circle(t["p"], t["r"], t["cor"])
		draw_circle(t["p"], t["r"] * 0.5, Color(1, 0.9, 0.9, 0.9))
	for e in efeitos:
		match e["t"]:
			"poeira":
				var a := clampf(e["vida"] / 0.45, 0, 1)
				draw_circle(e["p"], 3.0 + 4.0 * (1.0 - a), Color(0.55, 0.5, 0.6, 0.35 * a))
			"part":
				var a := clampf(e["vida"] / 0.6, 0, 1)
				draw_circle(e["p"], 2.5, Color(ROXO.lightened(0.3), a))
				draw_circle(e["p"], 6, Color(ROXO, a * 0.2))
			"anel":
				var f := clampf(1.0 - e["vida"] / e["max"], 0, 1)
				var rr := lerpf(e["r0"], e["r1"], f)
				draw_arc(e["p"], rr, 0, TAU, 48, Color(e["cor"], (1.0 - f) * 0.35), 9, true)
				draw_arc(e["p"], rr, 0, TAU, 48, Color(e["cor"], 1.0 - f), 2.5, true)
			"garra":
				# uma varrida rápida em volta dele, que some no fim
				var f: float = 1.0 - e["vida"] / 0.3
				var a0 := -PI / 2 + f * TAU * 0.9
				var alfa := 1.0 - f * f
				var rr: float = e["r"] * (0.75 + 0.25 * f)
				draw_arc(e["p"], rr, a0 - 1.6, a0, 24, Color(0.9, 0.1, 0.1, 0.25 * alfa), 16, true)
				draw_arc(e["p"], rr, a0 - 1.2, a0, 20, Color(1, 0.35, 0.3, 0.7 * alfa), 5, true)
				draw_arc(e["p"], rr, a0 - 0.7, a0, 14, Color(1, 0.9, 0.85, alfa), 2, true)
			"arranhao":
				# três riscos de garra em cima do monstro
				var f: float = clampf(1.0 - e["vida"] / 0.28, 0, 1)
				var dir := Vector2.from_angle(e["a"])
				var lado := dir.orthogonal()
				var alfa := 1.0 if f < 0.6 else (1.0 - f) / 0.4
				var cresce := minf(1.0, f * 3.0)
				for j in 3:
					var o: Vector2 = e["p"] + lado * (j - 1) * 8 - dir * 16
					var fim := o + dir * 32 * cresce
					draw_line(o, fim, Color(0.7, 0.05, 0.08, 0.6 * alfa), 6, true)
					draw_line(o, fim, Color(1, 0.85, 0.8, alfa), 2, true)
			"raio":
				var a: Vector2 = e["a"]
				var b: Vector2 = e["b"]
				var pts := PackedVector2Array([a])
				for j in range(1, 7):
					pts.append(a.lerp(b, j / 7.0) + Vector2(randf_range(-9, 9), randf_range(-9, 9)))
				pts.append(b)
				draw_polyline(pts, Color(ROXO, 0.35), 8, true)
				draw_polyline(pts, Color8(235, 215, 255), 2, true)
	var chefe = null
	for m in monstros:
		if m["chefe"]:
			chefe = m
			break
	if chefe != null:
		var w := LARG - 60
		caixa(Rect2(28, 134, w + 4, 14), Color(0.05, 0.04, 0.07, 0.9), 4, 1, Color(ROXO, 0.6))
		degrade(Rect2(31, 137, (w - 2) * chefe["hp"] / chefe["hp_max"], 8), Color8(170, 90, 255), Color8(80, 30, 140))
		escrever(MONSTROS[chefe["tipo"]]["nome"].to_upper(), Vector2(LARG / 2, 160), 13, Color8(210, 180, 255), true, fonte_titulo)
	for t in textos:
		var cor: Color = t["cor"]
		cor.a = minf(1.0, t["vida"] * 2)
		var tam: int = t.get("tam", 18)
		var pop := 1.0 + 0.6 * clampf((t["vida"] - 0.65) / 0.15, 0, 1) if tam > 20 else 1.0
		escrever(t["txt"], t["p"], int(tam * pop), cor)


func desenhar_kravenox(k: Vector2) -> void:
	# Mesmo andar da primeira versão: troca de quadro de passo, sem balanço.
	var n := (int(k_anim) % 4) if k_andando else 0
	var nome := "kravenox-passo-%d" % n
	var base := k + Vector2(0, 30)
	sombra_chao(base, 30)
	if k_salto > 0:
		# rastro verde do salto
		for j in 3:
			draw_circle(k + Vector2(-k_dir * (12 + j * 12), -4), 14 - j * 3, Color(VERDE, 0.25 - j * 0.07))
	if k_rapido > 0:
		# riscos de velocidade laranja atrás dele
		var laranja := Color8(255, 150, 60)
		for j in 4:
			var y := -20.0 + j * 11
			var tam := 18.0 + 6 * minf(k_mult, 6.0) + (j % 2) * 8
			var ini := k + Vector2(-k_dir * 18, y)
			draw_line(ini, ini + Vector2(-k_dir * tam, 0), Color(laranja, 0.55), 3, true)
	brilho_suave(k + Vector2(0, -4), 48, cor_forma(), 0.4 + (0.6 * (0.5 + 0.5 * sin(tempo * 8)) if furia >= 100.0 else 0.0))
	desenhar_arte(nome, base, 68, k_dir < 0)
	var e := eco_atual()
	if not e.is_empty():
		var pe := pos_eco()
		if eco_estelar():
			for j in 4:
				var a := tempo * 3 + j * TAU / 4
				draw_line(pe + Vector2.from_angle(a) * 7, pe + Vector2.from_angle(a) * 13, Color(1, 1, 1, 0.8), 1.5, true)
		brilho_suave(pe, 22, e["cor"], 1.2)
		draw_circle(pe, 5, e["cor"].lightened(0.3))
		draw_circle(pe, 2.5, Color(1, 1, 1, 0.9))
	if combo >= 3 and estado == "onda":
		var tc := "COMBO x%d" % combo
		escrever(tc, k + Vector2(0, -74), 15 + mini(combo, 12), OURO.lerp(VERMELHO, minf(1.0, combo / 15.0)), true, fonte_titulo)
	if k_flash > 0:
		desenhar_arte(nome, base, 68, k_dir < 0, Color(1, 0.3, 0.3, k_flash * 4), true)
	if escudo > 0:
		# bolha de escudo: mais forte quanto mais escudo
		var a := clampf(escudo / 60.0, 0.25, 0.8) + escudo_flash * 2
		draw_circle(k + Vector2(0, -6), 42, Color(AZUL, 0.08 * a))
		draw_arc(k + Vector2(0, -6), 42, 0, TAU, 40, Color(Color8(150, 200, 255), a), 2, true)
		draw_arc(k + Vector2(0, -6), 42, -2.4, -1.6, 10, Color(1, 1, 1, a), 2, true)


func desenhar_monstro(m: Dictionary, k: Vector2) -> void:
	var info: Dictionary = MONSTROS[m["tipo"]]
	var alt: float = info["alt"]
	var p: Vector2 = m["pos"]
	var t: float = m["anim"]
	var base := p + Vector2(0, alt * 0.4)
	var giro := 0.0
	var esmaga := Vector2.ONE
	var sobe := 0.0
	match info["anda"]:
		"rasteja":
			var s := sin(t * 5)
			esmaga = Vector2(1.0 + 0.07 * s, 1.0 - 0.07 * s)
		"flutua":
			sobe = 10 + sin(t * 3) * 5
			giro = sin(t * 2) * 0.08
		"morde":
			var s := maxf(0.0, sin(t * 6))
			esmaga = Vector2(1.0 + 0.08 * s, 1.0 - 0.05 * s)
			giro = -0.08 * s
		"marcha":
			giro = sin(t * 4) * 0.05
			sobe = absf(sin(t * 4)) * 3
	var virar := p.x > k.x   # as artes olham para a direita
	if info["img"] == "larva" or info["img"] == "verme":
		virar = p.x < k.x     # estas pinturas olham para a esquerda
	sombra_chao(base, alt * 0.42, 0.6)
	if m["chefe"]:
		brilho_suave(p, alt * 0.9, ROXO if m["tipo"] != "thornox" else AZUL, 0.6 + 0.2 * sin(tempo * 2))
	var mod: Color = info.get("tinta", Color.WHITE)
	var luz := AZUL if m["tipo"] == "thornox" else ROXO
	if m["filho"]:
		alt *= 0.75
	if m["traco"] != "":
		luz = TRACOS[m["traco"]][1]
		brilho_suave(p, alt * 0.8, luz, 0.6)
	contorno(info["img"], base - Vector2(0, sobe), alt, virar, Color(luz, 0.9 if m["traco"] != "" else (0.75 if m["chefe"] else 0.5)), giro, esmaga)
	var r := desenhar_arte(info["img"], base - Vector2(0, sobe), alt, virar, mod, false, giro, esmaga)
	if m["flash"] > 0:
		desenhar_arte(info["img"], base - Vector2(0, sobe), alt, virar, Color(1, 1, 1, 0.85), true, giro, esmaga)
	if m["sangra"] > 0:
		for j in 2:
			var f := fmod(tempo * 2 + j * 0.5, 1.0)
			draw_circle(p + Vector2(-6 + j * 12, -4 + f * 22), 2.5, Color(0.8, 0.05, 0.1, 1.0 - f))
	if m["tonto"] > 0:
		for j in 3:
			var a := tempo * 6 + j * TAU / 3
			draw_circle(Vector2(p.x, r.position.y - 4) + Vector2(cos(a) * 14, sin(a) * 4), 3, Color8(255, 230, 120))
	if m["traco"] != "":
		escrever(TRACOS[m["traco"]][0], Vector2(p.x, r.position.y - 18), 11, luz, true)
	if m["hp"] < m["hp_max"] and not m["chefe"]:
		var w := 34.0
		var y := r.position.y - 8
		draw_rect(Rect2(p.x - w / 2 - 1, y - 1, w + 2, 5), Color(0, 0, 0, 0.8))
		draw_rect(Rect2(p.x - w / 2, y, w * m["hp"] / m["hp_max"], 3), VERMELHO)


func desenhar_loja() -> void:
	var b := botoes()
	var painel := Rect2(6, LOJA_Y, LARG - 12, ALT - LOJA_Y - 4)
	caixa(painel, Color(0.04, 0.03, 0.06, 0.94), 10, 2, OURO_ESC, true, 10)
	caixa(painel.grow(-5), Color(0, 0, 0, 0), 7, 1, Color(OURO, 0.18), false)
	# placa do título
	var placa := Rect2(LARG / 2 - 70, LOJA_Y - 15, 140, 32)
	caixa(placa, Color8(26, 20, 34), 6, 2, OURO, true, 6)
	escrever("LOJA", placa.get_center(), 17, OURO, false, fonte_titulo)
	for lado in [-1.0, 1.0]:
		var p := Vector2(LARG / 2 + lado * 92, LOJA_Y + 1)
		draw_line(p, p + Vector2(lado * 120, 0), Color(OURO, 0.4), 1)
		cristal(p, 4, OURO)
	var ativa := estado == "loja"
	for i in 3:
		var r: Rect2 = b["loja%d" % i]
		var iid = loja[i]
		caixa(r, Color8(22, 18, 28), 8, 1, PEDRA_BORDA, true, 4)
		if iid == null:
			escrever("vendido", r.get_center(), 15, Color(CINZA, 0.5), false)
			continue
		var custo := preco(iid)
		var pode := essencia >= custo and ativa
		if selec == ["loja", i]:
			caixa(r.grow(2), Color(0, 0, 0, 0), 9, 3, OURO, false)
		var cx := r.get_center().x
		var area := Rect2(cx - 40, r.position.y + 21, 80, 42)
		degrade(area, Color(0.12, 0.09, 0.16), Color(0.05, 0.04, 0.07))
		icone(iid, area.get_center(), 0.62)
		escrever(ITENS[iid]["nome"], Vector2(cx, r.position.y + 12), 14, BRANCO, false)
		escrever(ITENS[iid]["curta"], Vector2(cx, r.position.y + 71), 12, Color8(200, 190, 210), false)
		cristal(Vector2(cx - 16, r.end.y - 14), 7)
		escrever_esq(str(custo), Vector2(cx - 5, r.end.y - 6), 20, BRANCO if pode else Color8(200, 80, 80))
		if not ativa:
			draw_rect(r, Color(0, 0, 0, 0.45))
	var t_trocar := "Trocar grátis" if trocas_gratis > 0 else "Trocar (2)"
	if desafio_regra_ativa("sem_trocas"):
		botao(b["trocar"], "Sem trocas", CINZA, false)
	else:
		botao(b["trocar"], t_trocar if ativa else "Trocar", AZUL, ativa)
	botao(b["lixo"], "Vender", VERMELHO, ativa, vender)
	var t_onda_b := ("Fase bônus" if bonus_pendente else "Iniciar onda %d" % (onda + 1)) if ativa else "Onda em andamento"
	if ativa and em_risco:
		t_onda_b = "Onda de risco %d" % risco_n
	if estado == "onda" and liberou("furia"):
		var rf: Rect2 = b["onda"]
		var cheia := furia >= 100.0
		caixa(rf, Color(0.07, 0.04, 0.06, 0.95), 7, 2, cor_forma() if cheia else Color(cor_forma(), 0.5), true, 4)
		var fr := rf.grow(-4)
		degrade(Rect2(fr.position, Vector2(fr.size.x * furia / 100.0, fr.size.y)), cor_forma().lightened(0.2), cor_forma().darkened(0.4))
		if cheia:
			brilho_suave(rf.get_center(), 120, cor_forma(), 0.6 + 0.4 * sin(tempo * 8))
		escrever("SOLTAR A FÚRIA!" if cheia else "Fúria %d%%" % int(furia), rf.get_center(), 18 if cheia else 16, BRANCO, true, fonte_titulo if cheia else null)
	else:
		botao(b["onda"], t_onda_b, OURO, ativa, ativa)
	var dica := "Arraste o item até um quadro"
	if estado == "onda":
		dica = "Monstros: %d  ·  na fila: %d" % [monstros.size(), fila.size()]
	elif vender:
		dica = "Toque num quadro para vender o item"
	elif not selec.is_empty() and selec[0] == "loja":
		var it: Dictionary = ITENS[loja[selec[1]]]
		dica = "%s: %s. Toque num quadro." % [it["nome"], it["desc"]]
	elif not selec.is_empty() and selec[0] == "quadro" and quadros[selec[1]] != null:
		var q: Dictionary = quadros[selec[1]]
		dica = "%s nível %d: %s. Toque em outro quadro para mover." % [ITENS[q["id"]]["nome"], q["nv"], ITENS[q["id"]]["desc"]]
		if q.get("lend", false):
			dica = "LENDÁRIO %s: %s." % [LENDARIAS[q["id"]]["nome"], LENDARIAS[q["id"]]["desc"]]
		var sins := sinergias_do(selec[1])
		if not sins.is_empty():
			dica = tx("Combina: %s. ") % ", ".join(sins.map(func(x): return tx(x))) + tx(dica)
	desenhar_dica(dica, Vector2(LARG / 2, LOJA_Y + 32), LARG - 36)


# ============================================================ telas de menu
const MSG_ABERTURA := ["Despertando no Reino Quebrado...", "Ouvindo os ecos do Cisma...", "Juntando a Essência...", "Toque para começar"]
const DURA_ABERTURA := 1.8
const ORDEM_BESTIARIO := ["larva", "esfera", "verme", "sentinela", "larvamae", "semrosto", "thornox"]
const CARD_MUNDO := 168.0
const TOPO_MUNDOS := 118.0


func encurtar(t: String, f: Font, tam: int, largura: float) -> String:
	t = tx(t)
	if f.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x <= largura:
		return t
	while t.length() > 4 and f.get_string_size(t + "…", HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x > largura:
		t = t.substr(0, t.length() - 1)
	return t.strip_edges() + "…"


func total_mundos() -> int:
	return (TOTAL_CAPITULOS + CAPS_POR_MUNDO - 1) / CAPS_POR_MUNDO


func rolagem_max() -> float:
	return maxf(0.0, TOPO_MUNDOS + total_mundos() * CARD_ALTO + 100 - ALT)



const MUNDO_NOMES := [
	"A Cratera do Cisma", "A Floresta das Raízes", "O Abismo dos Sinos", "Valdora em Cinzas", "O Olho do Primeiro",
	"A Sala da Fonte", "Além das Montanhas", "O Exército das Sombras", "O Trono do Vazio", "A Guerra dos Mundos",
	"O Primeiro Mundo", "A Porta entre Mundos", "A Cidade dos Espinhos", "A Biblioteca do Fim", "O Livro de Thornox",
	"A Estrada entre as Estrelas", "O Começo Depois do Fim", "A Estrela Azul", "O Mundo Verde",
]
const MISSOES := [
	{"id": "mortes", "nome": "Espante 150 monstros", "meta": 150, "premio": 6},
	{"id": "caps", "nome": "Vença 2 capítulos", "meta": 2, "premio": 8},
	{"id": "bonus", "nome": "Defenda a torre na fase bônus", "meta": 1, "premio": 6},
]
var tex_mundo := {}
var cap_sel := 0          # capítulo escolhido na tela inicial (0 = o próximo)
var popup := {}           # {"titulo", "texto", "valor", "acao"}
var apagar_confirma := 0.0


func arte_mundo(w: int) -> Texture2D:
	if not tex_mundo.has(w):
		tex_mundo[w] = load("res://assets/mundos/mundo-%02d.png" % w)
	return tex_mundo[w]


# ------------------------------------------------------------ recompensas da tela inicial
func hoje() -> String:
	return Time.get_date_string_from_system()


func agora() -> float:
	return Time.get_unix_time_from_system()


func missoes_do_dia() -> Dictionary:
	var m = prog.get("missoes", null)
	if not (m is Dictionary) or m.get("dia", "") != hoje():
		m = {"dia": hoje(), "mortes": 0, "caps": 0, "bonus": 0, "pegas": []}
		prog["missoes"] = m
	return m


func contar_missao(id: String, n := 1) -> void:
	if robo:
		return
	var m := missoes_do_dia()
	m[id] = int(m.get(id, 0)) + n


func missoes_prontas() -> int:
	var m := missoes_do_dia()
	var n := 0
	for ms in MISSOES:
		if int(m.get(ms["id"], 0)) >= int(ms["meta"]) and not m["pegas"].has(ms["id"]):
			n += 1
	return n


func presente_disponivel() -> bool:
	return prog.get("presente", "") != hoje()


func valor_presente() -> int:
	return 5 + mundo_de(int(prog["liberado"]))


func valor_fora() -> int:
	# enquanto você está fora, o Kravenox junta fragmentos (até 12 horas)
	var ultimo := float(prog.get("coleta_fora", 0.0))
	if ultimo <= 0:
		prog["coleta_fora"] = agora()
		return 0
	var horas := clampf((agora() - ultimo) / 3600.0, 0.0, 24.0 if tem("fora24") else 12.0)
	return int(horas * (1.0 + mundo_de(int(prog["liberado"])) / 5.0))


func baus_prontos() -> Array:
	var v := []
	var pegos: Dictionary = prog.get("baus", {})
	for w in range(1, total_mundos() + 1):
		var c1 := mini(w * CAPS_POR_MUNDO, TOTAL_CAPITULOS)
		var completo := true
		for c in range((w - 1) * CAPS_POR_MUNDO + 1, c1 + 1):
			if not feito(c):
				completo = false
		if completo and not pegos.has(str(w)):
			v.append(w)
	return v


func ganhar(n: int, titulo: String) -> void:
	prog["fragmentos"] = int(prog["fragmentos"]) + n
	salvar()
	som("nivel")
	popup = {"titulo": titulo, "texto": "+%d fragmentos" % n, "valor": n, "t": 0.0}


func poder() -> int:
	var p := 100
	for m in MELHORIAS:
		p += nivel_melhoria(m["id"]) * 35
	p += prog["feitos"].size() * 12 + prog.get("feitos_p", {}).size() * 20
	return p


# ------------------------------------------------------------ modo pesadelo
func pesadelo_liberado() -> bool:
	return feito(CAPS_POR_MUNDO)   # depois de vencer o mundo 1


func liberado_modo() -> int:
	if modo == "pesadelo":
		var c := int(prog.get("liberado_p", 1))
		while c > 1 and not feito(c):
			c -= 1
		return c
	return int(prog["liberado"])


func capitulo_disponivel(c: int) -> bool:
	if modo == "pesadelo":
		return feito(c) and c <= int(prog.get("liberado_p", 1))
	return c <= int(prog["liberado"])


# ------------------------------------------------------------ botões dos menus
func botoes_menu() -> Dictionary:
	var b := {}
	b["voltar"] = Rect2(12, 16, 40, 36)
	b["ajustes"] = Rect2(14, 92, 40, 40)
	b["avatar"] = Rect2(10, 10, 80, 70)
	b["kx_formas"] = Rect2(12, 128, 74, 74)
	b["kx_conquistas"] = Rect2(12, 210, 74, 74)
	b["kx_bestiario"] = Rect2(12, 292, 74, 74)
	for i in 4:
		b["kx_carta%d" % i] = Rect2(14 + i * 114, 532, 110, 196)
	for i in CONQUISTAS.size():
		b["conquista%d" % i] = Rect2(370, TOPO_MUNDOS + 6 + i * 51 + 8, 94, 32)
	b["normal"] = Rect2(110, 150, 128, 40)
	b["pesadelo"] = Rect2(242, 150, 128, 40)
	b["ant"] = Rect2(30, 440, 48, 64)
	b["prox"] = Rect2(402, 440, 48, 64)
	b["jogar"] = Rect2(110, 612, 260, 62)
	b["presente"] = Rect2(LARG - 84, 214, 72, 74)
	b["missoes"] = Rect2(LARG - 84, 296, 72, 74)
	b["baus"] = Rect2(LARG - 84, 378, 72, 74)
	b["fora"] = Rect2(12, 520, 84, 74)
	b["loja"] = Rect2(222, 20, 94, 34)
	b["jogos"] = Rect2(60, 96, 116, 34)
	b["online"] = Rect2(182, 96, 96, 34)
	b["versao"] = Rect2(120, 668, 240, 30)
	b["codigo"] = Rect2(120, 582, 240, 40)
	b["desafio"] = Rect2(12, 200, 72, 74)
	b["abismo"] = Rect2(12, 280, 72, 74)
	b["pactos"] = Rect2(12, 360, 72, 74)
	b["kx_grimorio"] = Rect2(LARG - 86, 128, 74, 74)
	b["kx_cronicas"] = Rect2(LARG - 86, 210, 74, 74)
	b["kx_ecos"] = Rect2(LARG - 86, 292, 74, 74)
	for i in CONSTRUCOES.size():
		b["obra%d" % i] = Rect2(338, 146 + i * 84 + 16, 112, 44)
	for i in PACTOS.size():
		b["pacto%d" % i] = Rect2(LARG - 132, 176 + i * 66 + 12, 112, 40)
	for i in ECOS.size():
		b["eco%d" % i] = Rect2(LARG - 132, 150 + i * 120 + 40, 112, 44)
	b["cr_ant"] = Rect2(16, ALT - 160, 64, 56)
	b["cr_prox"] = Rect2(LARG - 80, ALT - 160, 64, 56)
	b["vibracao"] = Rect2(330, 240, 120, 44)
	var nomes := ["melhorias", "acampamento", "inicio", "modos", "mundos", "ajustes_aba"]
	for i in 6:
		b["aba_" + nomes[i]] = Rect2(i * 80, ALT - 82, 80, 82)
	for i in MELHORIAS.size():
		b["melhoria%d" % i] = Rect2(338, 146 + i * 84 + 16, 112, 44)
	for i in MISSOES.size():
		b["missao%d" % i] = Rect2(338, 160 + i * 110 + 30, 112, 44)
	b["musica"] = Rect2(330, 136, 120, 44)
	b["idioma"] = Rect2(330, 292, 120, 44)
	b["efeitos"] = Rect2(330, 188, 120, 44)
	b["apagar"] = Rect2(40, 360, 400, 50)
	b["copiar_prog"] = Rect2(40, 520, 195, 50)
	b["colar_prog"] = Rect2(245, 520, 195, 50)
	b["popup_ok"] = Rect2(LARG / 2 - 90, ALT / 2 + 30, 180, 50)
	return b


func cap_atual() -> int:
	var lib := liberado_modo()
	if cap_sel <= 0 or not capitulo_disponivel(cap_sel):
		return lib
	return cap_sel


func abas(p: Vector2, b: Dictionary) -> bool:
	if p.y < ALT - 82:
		return false
	if b["aba_melhorias"].has_point(p):
		ir_para("melhorias")
	elif b["aba_acampamento"].has_point(p):
		if liberou("acampamento"):
			ir_para("acampamento")
		else:
			popup = {"titulo": "ACAMPAMENTO", "texto": "Vença o capítulo 3 para montar o acampamento"}
	elif b["aba_inicio"].has_point(p):
		ir_para("inicio")
	elif b["aba_modos"].has_point(p):
		if liberou("modos"):
			ir_para("modos")
		else:
			popup = {"titulo": "MODOS", "texto": "Vença o capítulo 4 para liberar os modos"}
	elif b["aba_mundos"].has_point(p):
		destaque_cap = 0
		ir_para("mundos")
	elif b["aba_ajustes_aba"].has_point(p):
		ir_para("ajustes")
	return true


func clique_menu(p: Vector2) -> void:
	var b := botoes_menu()
	if not popup.is_empty():
		popup = {}
		return
	match tela:
		"abertura":
			if t_tela >= DURA_ABERTURA:
				som("gema")
				ir_para("inicio")
			return
		"duelo":
			if b["voltar"].has_point(p):
				sair_duelo()
				ir_para("online" if online_disponivel() else "modos")
				return
		"ranking", "ordem":
			if b["voltar"].has_point(p):
				ir_para("online")
				return
		"mundos", "melhorias", "missoes", "ajustes", "kravenox", "acampamento", "pactos", "modos", "loja", "jogos", "online":
			if b["voltar"].has_point(p):
				ir_para("inicio")
				return
		"formas", "conquistas", "grimorio", "cronicas", "ecos", "bestiario":
			if b["voltar"].has_point(p):
				ir_para("kravenox")
				return
	if tela != "abertura" and abas(p, b):
		return
	match tela:
		"inicio":
			var c := cap_atual()
			if b["avatar"].has_point(p):
				ir_para("kravenox")
				return
			if b["loja"].has_point(p):
				ir_para("loja")
			elif b["jogos"].has_point(p):
				ir_para("jogos")
			elif b["online"].has_point(p) and online_disponivel():
				reenviar_pendentes()
				ir_para("online")
			elif b["jogar"].has_point(p):
				som("gema")
				comecar_capitulo(c)
			elif b["desafio"].has_point(p) and liberou("desafio"):
				som("gema")
				comecar_desafio()
			elif b["abismo"].has_point(p) and liberou("abismo"):
				som("gema")
				comecar_abismo()
			elif b["pactos"].has_point(p) and liberou("pactos"):
				ir_para("pactos")
			elif b["ajustes"].has_point(p):
				ir_para("ajustes")
			elif b["normal"].has_point(p):
				modo = "normal"
				cap_sel = 0
				prog["modo"] = modo
				salvar()
			elif b["pesadelo"].has_point(p):
				if pesadelo_liberado():
					modo = "pesadelo"
					cap_sel = 0
					prog["modo"] = modo
					salvar()
				else:
					popup = {"titulo": "PESADELO", "texto": "Vença o Mundo 1 para liberar"}
			elif b["ant"].has_point(p):
				var n := c - 1
				while n >= 1 and not capitulo_disponivel(n):
					n -= 1
				if n >= 1:
					cap_sel = n
			elif b["prox"].has_point(p):
				if c + 1 <= TOTAL_CAPITULOS and capitulo_disponivel(c + 1):
					cap_sel = c + 1
			elif b["presente"].has_point(p):
				if presente_disponivel():
					# sequência de dias: cresce a cada dia seguido; faltar um dia volta duas casas
					var seq := int(prog.get("seq", 0))
					seq = (seq % 7) + 1 if prog.get("presente", "") == ontem() else maxi(1, seq - 1)
					prog["seq"] = seq
					prog["presente"] = hoje()
					var v := int(round(valor_presente() * (1.0 + 0.25 * (seq - 1)))) + (30 if seq == 7 else 0)
					ganhar(v, "PRESENTE · DIA %d DE 7" % seq)
				else:
					popup = {"titulo": "PRESENTE DO DIA", "texto": "Volte amanhã para outro presente"}
			elif b["missoes"].has_point(p):
				ir_para("missoes")
			elif b["baus"].has_point(p):
				var bs := baus_prontos()
				if bs.is_empty():
					popup = {"titulo": "BAÚS DOS MUNDOS", "texto": "Vença os 4 capítulos de um mundo para abrir o baú dele"}
				else:
					var w: int = bs[0]
					if not prog.has("baus"):
						prog["baus"] = {}
					prog["baus"][str(w)] = true
					ganhar(10 + 2 * w, "BAÚ DO MUNDO %d" % w)
					for e in ECOS:
						if int(e["bau"]) == w:
							popup["extra"] = "Novo companheiro: %s!" % e["nome"]
							if str(prog.get("eco", "")) == "":
								prog["eco"] = e["id"]
								salvar()
			elif b["fora"].has_point(p):
				var v := valor_fora()
				if v > 0:
					prog["coleta_fora"] = agora()
					ganhar(v, "VIGÍLIA DO KRAVENOX")
				else:
					popup = {"titulo": "VIGÍLIA DO KRAVENOX", "texto": "Enquanto você está longe, o Kravenox fica de vigília e junta os fragmentos que encontra (até %d horas)." % (24 if tem("fora24") else 12)}
		"mundos":
			if p.y < TOPO_MUNDOS:
				return
			for c in range(1, TOTAL_CAPITULOS + 1):
				if no_capitulo_card(c).distance_to(p) < 32:
					if capitulo_disponivel(c):
						som("gema")
						comecar_capitulo(c)
					else:
						som("dano")
					return
		"melhorias":
			for i in MELHORIAS.size():
				if b["melhoria%d" % i].has_point(p):
					if not comprar_melhoria(i):
						som("dano")
					return
		"kravenox":
			if b["kx_grimorio"].has_point(p):
				ir_para("grimorio")
			elif b["kx_cronicas"].has_point(p):
				cron_cap = 0
				ir_para("cronicas")
			elif b["kx_ecos"].has_point(p):
				ir_para("ecos")
			elif b["kx_formas"].has_point(p):
				ir_para("formas")
			elif b["kx_conquistas"].has_point(p):
				ir_para("conquistas")
			elif b["kx_bestiario"].has_point(p):
				ir_para("bestiario")
			else:
				for i in 4:
					if b["kx_carta%d" % i].has_point(p):
						var idx := indice_melhoria(CARTAS_KX[i])
						if not comprar_melhoria(idx):
							som("dano")
						return
		"conquistas":
			for i in CONQUISTAS.size():
				if b["conquista%d" % i].has_point(p):
					var c: Dictionary = CONQUISTAS[i]
					var pegas: Dictionary = prog.get("conquistas", {})
					if progresso_conquista(c) >= int(c["meta"]) and not pegas.has(c["id"]):
						pegas[c["id"]] = true
						prog["conquistas"] = pegas
						ganhar(int(c["premio"]), "CONQUISTA!")
					return
		"missoes":
			var m := missoes_do_dia()
			for i in MISSOES.size():
				var ms: Dictionary = MISSOES[i]
				if b["missao%d" % i].has_point(p) and int(m.get(ms["id"], 0)) >= int(ms["meta"]) and not m["pegas"].has(ms["id"]):
					m["pegas"].append(ms["id"])
					ganhar(int(ms["premio"]) + mundo_de(int(prog["liberado"])) / 2, "MISSÃO CUMPRIDA")
					return
		"loja":
			clique_loja(p)
		"beta":
			clique_beta(p)
		"duelo":
			clique_duelo(p)
		"online":
			clique_online(p)
		"ranking":
			clique_ranking(p)
		"ordem":
			clique_ordem(p)
		"jogos":
			for i in JOGOS_NOSSOS.size():
				if Rect2(14, 152 + i * 132, LARG - 28, 122).has_point(p):
					som("gema")
					abrir_link(JOGOS_NOSSOS[i]["url"])
					return
		"modos":
			var lista := lista_modos()
			for i in lista.size():
				if Rect2(14, 118 + i * 88, LARG - 28, 84).has_point(p):
					if int(prog["liberado"]) >= int(lista[i]["desde"]):
						som("gema")
						if lista[i]["id"] == "duelo":
							ir_para("duelo")
						else:
							comecar_modo(lista[i]["id"])
					else:
						som("dano")
					return
		"acampamento":
			for i in CONSTRUCOES.size():
				if b["obra%d" % i].has_point(p):
					if not comprar_obra(i):
						som("dano")
					return
		"pactos":
			for i in PACTOS.size():
				if b["pacto%d" % i].has_point(p):
					var pc: Dictionary = prog.get("pactos", {})
					pc[PACTOS[i]["id"]] = not bool(pc.get(PACTOS[i]["id"], false))
					prog["pactos"] = pc
					salvar()
					som("gema")
					return
		"ecos":
			for i in ECOS.size():
				if b["eco%d" % i].has_point(p) and eco_liberado(ECOS[i]):
					prog["eco"] = "" if str(prog.get("eco", "")) == ECOS[i]["id"] else ECOS[i]["id"]
					salvar()
					som("gema")
					return
		"cronicas":
			var lista := cronicas()
			if lista.is_empty():
				return
			var k := clampi(lista.find(cron_cap), 0, lista.size() - 1)
			if b["cr_ant"].has_point(p):
				cron_cap = lista[maxi(0, k - 1)]
			elif b["cr_prox"].has_point(p):
				cron_cap = lista[mini(lista.size() - 1, k + 1)]
		"bestiario":
			for i in ORDEM_BESTIARIO.size():
				var tipo: String = ORDEM_BESTIARIO[i]
				var r := Rect2(16 + (i % 2) * 228, TOPO_MUNDOS + 2 + (i / 2) * 154, 220, 146)
				if r.has_point(p) and prog["vistos"].has(tipo):
					var n := int(prog.get("abates", {}).get(tipo, 0))
					var nv := nivel_caca(tipo)
					var prox: int = [10, 50, 100, 100][nv]
					popup = {"titulo": MONSTROS[tipo]["nome"].to_upper(), "texto": "%s Caça nível %d (+%d%% de dano contra ele) · %d espantados%s" % [
						DESC_MONSTROS[tipo], nv, 2 * nv, n, "" if nv >= 3 else " · próximo nível: %d" % prox]}
					return
		"ajustes":
			if b["codigo"].has_point(p):
				pedir_codigo()
			elif b["idioma"].has_point(p):
				trocar_idioma()
			elif b["copiar_prog"].has_point(p):
				copiar_progresso()
			elif b["colar_prog"].has_point(p):
				colar_progresso()
			elif b["versao"].has_point(p):
				toques_versao += 1
				if toques_versao >= 7:
					toques_versao = 0
					prog["teste_compras"] = not bool(prog.get("teste_compras", false))
					salvar()
					popup = {"titulo": "MODO DE TESTE DA LOJA", "texto": "Ligado: tudo da loja liberado para testar." if prog["teste_compras"] else "Desligado."}
			elif b["vibracao"].has_point(p):
				vibracao_ligada = not vibracao_ligada
				prog["vibracao"] = vibracao_ligada
				salvar()
				if vibracao_ligada:
					Input.vibrate_handheld(60)
			elif b["musica"].has_point(p):
				ligar_som(not som_ligado)
			elif b["efeitos"].has_point(p):
				efeitos_ligados = not efeitos_ligados
			elif b["apagar"].has_point(p):
				if apagar_confirma > 0:
					DirAccess.remove_absolute(ProjectSettings.globalize_path(ARQUIVO))
					carregar_progresso()
					apagar_confirma = 0.0
					cap_sel = 0
					modo = "normal"
					popup = {"titulo": "PROGRESSO APAGADO", "texto": "O jogo começa do capítulo 1"}
				else:
					apagar_confirma = 3.0


# ------------------------------------------------------------ desenho da tela inicial
func botao_icone(r: Rect2, tipo: String, rotulo: String, alerta := false) -> void:
	caixa(r, Color(0.05, 0.04, 0.07, 0.82), 12, 2, Color(OURO, 0.75), true, 6)
	var c := r.get_center() + Vector2(0, -9)
	match tipo:
		"presente":
			brilho_suave(c, 30, OURO, 0.8)
			caixa(Rect2(c + Vector2(-16, -6), Vector2(32, 22)), Color8(150, 30, 40), 3, 1, TINTA)
			caixa(Rect2(c + Vector2(-19, -12), Vector2(38, 8)), Color8(190, 40, 50), 2, 1, TINTA)
			draw_rect(Rect2(c + Vector2(-3, -12), Vector2(6, 28)), OURO)
		"missoes":
			brilho_suave(c, 30, AZUL, 0.7)
			caixa(Rect2(c + Vector2(-14, -16), Vector2(28, 32)), PAPEL_C, 3, 1, TINTA)
			for k in 3:
				draw_line(c + Vector2(-8, -8 + k * 8), c + Vector2(9, -8 + k * 8), Color8(90, 70, 50), 2)
		"baus":
			brilho_suave(c, 30, OURO, 0.8)
			caixa(Rect2(c + Vector2(-17, -6), Vector2(34, 20)), Color8(110, 70, 36), 3, 1, TINTA)
			caixa(Rect2(c + Vector2(-17, -15), Vector2(34, 11)), Color8(140, 90, 46), 5, 1, TINTA)
			draw_rect(Rect2(c + Vector2(-3, -7), Vector2(6, 8)), OURO)
		"fora":
			brilho_suave(c, 30, ROXO, 0.8)
			draw_circle(c, 15, Color8(30, 24, 44))
			draw_arc(c, 15, 0, TAU, 24, OURO, 2, true)
			draw_line(c, c + Vector2(0, -10), OURO, 2)
			draw_line(c, c + Vector2(7, 3), OURO, 2)
		"formas":
			brilho_suave(c, 30, cor_forma(), 0.9)
			for k in 5:
				var a := -PI / 2 + (k - 2) * 0.45
				draw_colored_polygon(PackedVector2Array([c + Vector2.from_angle(a) * 18, c + Vector2.from_angle(a - 0.2) * 7, c + Vector2.from_angle(a + 0.2) * 7]), OURO)
			draw_circle(c + Vector2(0, 4), 9, Color8(20, 16, 26))
			draw_circle(c + Vector2(-3, 3), 2, VERMELHO)
			draw_circle(c + Vector2(3, 3), 2, VERMELHO)
		"conquistas":
			brilho_suave(c, 30, OURO, 0.8)
			poli([c + Vector2(-12, -14), c + Vector2(12, -14), c + Vector2(9, 2), c + Vector2(0, 7), c + Vector2(-9, 2)], OURO, 1.2)
			draw_rect(Rect2(c + Vector2(-2, 6), Vector2(4, 6)), OURO)
			draw_rect(Rect2(c + Vector2(-8, 12), Vector2(16, 4)), OURO)
		"bestiario":
			brilho_suave(c, 30, ROXO, 0.7)
			poli([c + Vector2(-14, -11), c + Vector2(-1, -8), c + Vector2(-1, 13), c + Vector2(-14, 10)], Color8(90, 58, 140), 1.2)
			poli([c + Vector2(14, -11), c + Vector2(1, -8), c + Vector2(1, 13), c + Vector2(14, 10)], Color8(110, 70, 160), 1.2)
		"desafio":
			brilho_suave(c, 30, Color8(255, 160, 60), 0.8)
			draw_circle(c, 12, Color8(255, 170, 70))
			for k in 8:
				var a := k * TAU / 8 + tempo * 0.3
				draw_line(c + Vector2.from_angle(a) * 14, c + Vector2.from_angle(a) * 19, Color8(255, 200, 100), 2.5)
			draw_line(c + Vector2(-9, 9), c + Vector2(9, -9), Color8(40, 30, 40), 3)
		"abismo":
			brilho_suave(c, 32, ROXO, 1.0)
			for k in 3:
				draw_arc(c, 16 - k * 5, tempo * (1.0 + k * 0.5), tempo * (1.0 + k * 0.5) + 4.2, 16, Color(Color8(200, 150, 255), 1.0 - k * 0.25), 2.5, true)
		"pactos":
			brilho_suave(c, 30, VERMELHO, 0.8)
			var e := []
			for k in 5:
				e.append(c + Vector2.from_angle(-PI / 2 + k * TAU * 2 / 5) * 16)
			e.append(e[0])
			draw_polyline(PackedVector2Array(e), Color8(230, 60, 70), 2.5, true)
			draw_arc(c, 17, 0, TAU, 24, Color8(150, 30, 40), 1.5, true)
		"grimorio":
			brilho_suave(c, 30, ROXO, 0.8)
			caixa(Rect2(c + Vector2(-14, -16), Vector2(28, 32)), Color8(70, 40, 100), 3, 1, TINTA)
			cristal(c, 7, Color8(230, 200, 255))
		"cronicas":
			brilho_suave(c, 30, OURO, 0.7)
			poli([c + Vector2(-16, -12), c + Vector2(-1, -9), c + Vector2(-1, 14), c + Vector2(-16, 11)], PAPEL_C, 1.2)
			poli([c + Vector2(16, -12), c + Vector2(1, -9), c + Vector2(1, 14), c + Vector2(16, 11)], PAPEL_C.darkened(0.1), 1.2)
			for k in 3:
				draw_line(c + Vector2(-12, -5 + k * 6), c + Vector2(-4, -4 + k * 6), Color8(90, 70, 50), 1.5)
		"ecos":
			var e := eco_atual()
			var ce: Color = e["cor"] if not e.is_empty() else Color8(200, 180, 255)
			brilho_suave(c, 30, ce, 1.0)
			draw_circle(c + Vector2(cos(tempo * 2) * 8, sin(tempo * 2) * 4), 7, ce)
			draw_circle(c + Vector2(cos(tempo * 2) * 8, sin(tempo * 2) * 4), 3, Color(1, 1, 1, 0.9))
		"engrenagem":
			for k in 8:
				var a := k * TAU / 8
				draw_line(c + Vector2.from_angle(a) * 8, c + Vector2.from_angle(a) * 15, OURO, 5)
			draw_circle(c, 10, OURO)
			draw_circle(c, 4, Color8(20, 16, 26))
	if rotulo != "":
		escrever(rotulo, Vector2(r.get_center().x, r.end.y - 11), 12, BRANCO, true)
	if alerta:
		var d := r.position + Vector2(r.size.x - 8, 8)
		draw_circle(d, 8 + sin(tempo * 5), VERMELHO)
		escrever("!", d, 13, BRANCO, false)


func desenhar_abas() -> void:
	draw_rect(Rect2(0, ALT - 82, LARG, 82), Color(0.03, 0.02, 0.05, 0.96))
	draw_line(Vector2(0, ALT - 82), Vector2(LARG, ALT - 82), Color(OURO, 0.5), 2)
	var b := botoes_menu()
	var itens := [["aba_melhorias", "Melhorias", "melhorias"], ["aba_acampamento", "Acampamento", "acampamento"],
		["aba_inicio", "Batalha", "inicio"], ["aba_modos", "Modos", "modos"], ["aba_mundos", "Mundos", "mundos"], ["aba_ajustes_aba", "Ajustes", "ajustes"]]
	for it in itens:
		var r: Rect2 = b[it[0]]
		var ativo: bool = tela == it[2]
		if ativo:
			degrade(r.grow(-4), Color(VERMELHO, 0.35), Color(VERMELHO, 0.05))
			draw_line(Vector2(r.position.x + 10, r.position.y + 3), Vector2(r.end.x - 10, r.position.y + 3), OURO, 3)
		var c := r.get_center() + Vector2(0, -10)
		var cor := OURO if ativo else CINZA
		match it[2]:
			"melhorias":
				poli([c + Vector2(0, -14), c + Vector2(12, 0), c + Vector2(5, 0), c + Vector2(5, 13), c + Vector2(-5, 13), c + Vector2(-5, 0), c + Vector2(-12, 0)], Color(VERMELHO, 0.9 if ativo else 0.6), 1.2)
			"modos":
				for k in 4:
					var q := c + Vector2(-12 + (k % 2) * 14, -12 + (k / 2) * 14)
					draw_rect(Rect2(q, Vector2(10, 10)), Color(OURO if ativo else CINZA, 0.9 if k != 3 else 0.5))
				if not liberou("modos"):
					draw_rect(Rect2(c + Vector2(9, -14), Vector2(10, 8)), CINZA)
			"acampamento":
				# tenda com a porta escura
				poli([c + Vector2(-15, 12), c + Vector2(0, -14), c + Vector2(15, 12)], Color8(150, 60, 50) if ativo else Color8(80, 60, 70), 1.2)
				poli([c + Vector2(-4, 12), c + Vector2(0, 0), c + Vector2(4, 12)], Color8(20, 14, 20))
				if not liberou("acampamento"):
					draw_rect(Rect2(c + Vector2(9, -14), Vector2(10, 8)), CINZA)
			"inicio":
				for k in [-1.0, 1.0]:
					draw_line(c + Vector2(-13 * k, 12), c + Vector2(12 * k, -13), cor, 4, true)
					draw_line(c + Vector2(-9 * k, 3), c + Vector2(-3 * k, 9), cor, 3, true)
			"mundos":
				draw_circle(c, 13, Color(ROXO, 0.5 if ativo else 0.3))
				draw_arc(c, 13, 0, TAU, 24, cor, 2, true)
				draw_line(c + Vector2(-13, 0), c + Vector2(13, 0), cor, 1.5)
				draw_arc(c, 6, -PI / 2, PI / 2, 10, cor, 1.5)
			"ajustes":
				for k in 8:
					var a := k * TAU / 8
					draw_line(c + Vector2.from_angle(a) * 6, c + Vector2.from_angle(a) * 12, cor, 4)
				draw_circle(c, 7, cor)
				draw_circle(c, 3, Color8(20, 16, 26))
		escrever(it[1], Vector2(r.get_center().x, r.end.y - 16), 12, BRANCO if ativo else CINZA, false)
		if it[2] == "melhorias" and pode_melhorar():
			draw_circle(r.position + Vector2(r.size.x - 22, 12), 6, VERMELHO)
		if it[2] == "acampamento" and liberou("acampamento") and pode_construir():
			draw_circle(r.position + Vector2(r.size.x - 22, 12), 6, VERMELHO)


func desenhar_popup() -> void:
	if popup.is_empty():
		return
	popup["t"] = float(popup.get("t", 0.0)) + 0.016
	draw_rect(Rect2(0, 0, LARG, ALT), Color(0, 0, 0, 0.6))
	var r := Rect2(40, ALT / 2 - 110, LARG - 80, 220)
	caixa(r, Color8(20, 16, 28), 12, 2, OURO, true, 10)
	escrever(popup["titulo"], Vector2(LARG / 2, r.position.y + 34), 18, OURO, true, fonte_titulo)
	if popup.has("valor"):
		var a := clampf(float(popup["t"]) * 3, 0, 1)
		brilho_suave(Vector2(LARG / 2, r.position.y + 96), 70 * a, VERMELHO, 1.2)
		cristal(Vector2(LARG / 2 - 50, r.position.y + 96), 16 * a, VERMELHO)
		escrever("+%d" % int(popup["valor"]), Vector2(LARG / 2 + 14, r.position.y + 96), 34, BRANCO)
		escrever("fragmentos", Vector2(LARG / 2, r.position.y + 132), 15, CINZA, false)
		if popup.has("extra"):
			escrever(popup["extra"], Vector2(LARG / 2, r.position.y + 160), 15, Color8(200, 180, 255), false)
	else:
		texto_quebrado(popup["texto"], Vector2(r.position.x + 20, r.position.y + 62), r.size.x - 40, 15, BRANCO, 6, true)
	escrever("Toque para continuar", Vector2(LARG / 2, r.end.y - 26), 14, Color(CINZA, 0.6 + 0.4 * sin(tempo * 4)), false)


func desenhar_inicio() -> void:
	var c := cap_atual()
	var w := mundo_de(c)
	# fundo: a ilustração do mundo do capítulo, cobrindo a tela
	var t := arte_mundo(w)
	var alt := ALT * 0.78
	var larg := alt * t.get_width() / t.get_height()
	draw_texture_rect(t, Rect2(LARG / 2 - larg / 2 + sin(tempo * 0.15) * 20, 0, larg, alt), false)
	degrade(Rect2(0, 0, LARG, 200), Color(0.02, 0.01, 0.04, 0.85), Color(0.02, 0.01, 0.04, 0.0))
	degrade(Rect2(0, alt * 0.55, LARG, alt * 0.45 + 2), Color(0.02, 0.01, 0.04, 0.0), Color(0.03, 0.02, 0.05, 1.0))
	draw_rect(Rect2(0, alt, LARG, ALT - alt), Color(0.03, 0.02, 0.05, 1.0))
	if modo == "pesadelo":
		draw_rect(Rect2(0, 0, LARG, ALT), Color(0.35, 0.0, 0.02, 0.22))
	# barra do alto: o Kravenox, o poder e os fragmentos
	var av := Rect2(12, 12, 66, 66)
	brilho_suave(av.get_center(), 50, cor_forma(), 0.6)
	caixa(av, Color8(28, 20, 30), 10, 2, OURO, true, 6)
	var tk: Texture2D = tex["kravenox"] if skin_atual() == "" else textura_skin(skin_atual(), "kravenox")
	draw_texture_rect_region(tk, av.grow(-5), Rect2(0, 0, tk.get_width(), tk.get_width() * 0.92))
	caixa(Rect2(60, 6, 34, 22), VERMELHO, 11, 1, TINTA)
	escrever(str(prog["feitos"].size()), Vector2(77, 17), 13, BRANCO, false)
	caixa(Rect2(84, 24, 130, 30), Color(0.05, 0.04, 0.07, 0.85), 8, 1, Color(VERMELHO, 0.6))
	escrever_esq("PODER", Vector2(92, 44), 11, Color8(255, 170, 120), fonte_titulo)
	escrever_esq(str(poder()), Vector2(148, 46), 18, OURO)
	pilula_fragmentos(LARG - 14, 16)
	var b := botoes_menu()
	botao(b["loja"], "Loja", OURO, true, true)
	botao(b["jogos"], "Mais jogos", ROXO, true, false)
	if online_disponivel():
		botao(b["online"], "Online", VERDE, true, false)
	if bau_loja_pronto():
		var d: Vector2 = b["loja"].position + Vector2(b["loja"].size.x - 4, 2)
		draw_circle(d, 7 + sin(tempo * 5), VERMELHO)
		escrever("!", d, 12, BRANCO, false)
	botao_icone(b["ajustes"], "engrenagem", "")
	# Normal / Pesadelo
	var mp := pesadelo_liberado()
	botao(b["normal"], "Normal", AZUL, true, modo == "normal")
	botao(b["pesadelo"], "Pesadelo", VERMELHO, mp, modo == "pesadelo")
	if not mp:
		draw_rect(Rect2(b["pesadelo"].end.x - 26, b["pesadelo"].position.y + 14, 12, 10), CINZA)
		draw_arc(Vector2(b["pesadelo"].end.x - 20, b["pesadelo"].position.y + 14), 4, PI, TAU, 8, CINZA, 2)
	# capítulo escolhido, com setas
	escrever("CAPÍTULO %d" % c, Vector2(LARG / 2, 226), 34, BRANCO, true, fonte_titulo)
	escrever(CAPITULOS[c - 1], Vector2(LARG / 2, 262), 18, OURO)
	escrever("Mundo %d · %s" % [w, MUNDO_NOMES[w - 1]], Vector2(LARG / 2, 286), 14, CINZA)
	if feito(c) and modo == "normal" or modo == "pesadelo" and prog.get("feitos_p", {}).has(str(c)):
		escrever("vencido", Vector2(LARG / 2, 306), 13, Color8(120, 230, 140), false)
	var pode_ant := c > 1
	var pode_prox := c + 1 <= TOTAL_CAPITULOS and capitulo_disponivel(c + 1)
	for lado in [["ant", -1.0, pode_ant], ["prox", 1.0, pode_prox]]:
		var r: Rect2 = b[lado[0]]
		var cc := r.get_center()
		var cor := Color(OURO, 0.95 if lado[2] else 0.25)
		var s: float = lado[1]
		draw_polyline(PackedVector2Array([cc + Vector2(-8 * s, -20), cc + Vector2(10 * s, 0), cc + Vector2(-8 * s, 20)]), Color(TINTA, cor.a), 10, true)
		draw_polyline(PackedVector2Array([cc + Vector2(-8 * s, -20), cc + Vector2(10 * s, 0), cc + Vector2(-8 * s, 20)]), cor, 5, true)
	# o Kravenox no centro, sobre o chão do mundo
	var base := Vector2(LARG / 2, 560)
	brilho_suave(base + Vector2(0, -90), 120, VERMELHO, 0.45 + 0.1 * sin(tempo * 1.5))
	sombra_chao(base, 60)
	desenhar_arte("kravenox", base + Vector2(0, -sin(tempo * 1.4) * 3), 200, false)
	# botões laterais
	botao_icone(b["presente"], "presente", "Presente", presente_disponivel())
	botao_icone(b["missoes"], "missoes", "Missões", missoes_prontas() > 0)
	botao_icone(b["baus"], "baus", "Baús", not baus_prontos().is_empty())
	var vf := valor_fora()
	botao_icone(b["fora"], "fora", "Vigília +%d" % vf if vf > 0 else "Vigília", vf >= 1)
	# começar / continuar
	var pt := partida_guardada()
	var continua := not pt.is_empty() and int(pt["capitulo"]) == c and str(pt.get("modo", "normal")) == modo and str(pt.get("tipo", "capitulo")) == "capitulo"
	botao(b["jogar"], "", VERMELHO, true, true)
	escrever("CONTINUAR" if continua else "COMEÇAR", b["jogar"].get_center() + Vector2(0, -6 if continua else 0), 24, BRANCO, false, fonte_titulo)
	if continua:
		var fase_txt := "bônus" if pt.get("bonus_pendente", false) else "fase %d" % (int(pt["onda"]) + 1)
		escrever(fase_txt, b["jogar"].get_center() + Vector2(0, 17), 13, Color8(255, 210, 200), false)
	if modo == "pesadelo":
		escrever("Monstros bem mais fortes · fragmentos em dobro · chance de skin 2x mais rápida", Vector2(LARG / 2, 692), 12, Color8(255, 140, 130), false)
	if pontos_pacto() > 0:
		escrever("Pactos: %d pontos · fragmentos ×%s" % [pontos_pacto(), String.num(mult_pacto(), 2).replace(".", ",")], Vector2(LARG / 2, 710), 13, Color8(220, 150, 255), false)
	if liberou("desafio"):
		botao_icone(b["desafio"], "desafio", "Desafio", not desafio_feito_hoje())
	if liberou("abismo"):
		var ptb := partida_guardada()
		var rot := "Rec. %d" % int(prog.get("abismo_rec", 0))
		if not ptb.is_empty() and str(ptb.get("tipo", "")) == "abismo":
			rot = "Onda %d" % (int(ptb["onda"]) + 1)
		botao_icone(b["abismo"], "abismo", rot)
	if liberou("pactos"):
		botao_icone(b["pactos"], "pactos", "%d pts" % pontos_pacto() if pontos_pacto() > 0 else "Pactos")
	desenhar_abas()
	desenhar_popup()


const CARD_ALTO := 262.0


func no_capitulo_card(c: int) -> Vector2:
	var w := mundo_de(c) - 1
	var j := (c - 1) % CAPS_POR_MUNDO
	return Vector2(84 + j * 104, TOPO_MUNDOS + w * CARD_ALTO - rolagem + 200)


func desenhar_mundos() -> void:
	desenhar_fundo(0.7)
	var lib := liberado_modo()
	for w in total_mundos():
		var y := TOPO_MUNDOS + w * CARD_ALTO - rolagem
		if y > ALT or y + CARD_ALTO < TOPO_MUNDOS - 10:
			continue
		var c0 := w * CAPS_POR_MUNDO + 1
		var c1 := mini(c0 + CAPS_POR_MUNDO - 1, TOTAL_CAPITULOS)
		var aberto := capitulo_disponivel(c0)
		var atual := lib >= c0 and lib <= c1
		var r := Rect2(14, y, LARG - 28, CARD_ALTO - 14)
		caixa(r, Color(0.06, 0.05, 0.08, 0.95), 12, 2 if atual else 1, OURO if atual else Color(PEDRA_BORDA, 0.9), true, 6)
		# a ilustração do mundo
		var ri := Rect2(r.position + Vector2(6, 6), Vector2(r.size.x - 12, 150))
		var tm := arte_mundo(w + 1)
		var fonte_r := Rect2(0, (tm.get_height() - tm.get_width() * ri.size.y / ri.size.x) / 2.0, tm.get_width(), tm.get_width() * ri.size.y / ri.size.x)
		draw_texture_rect_region(tm, ri, fonte_r, Color.WHITE if aberto else Color(0.35, 0.32, 0.4))
		degrade(Rect2(ri.position, Vector2(ri.size.x, 56)), Color(0, 0, 0, 0.75), Color(0, 0, 0, 0))
		degrade(Rect2(ri.position + Vector2(0, ri.size.y - 40), Vector2(ri.size.x, 40)), Color(0, 0, 0, 0), Color(0.06, 0.05, 0.08, 0.9))
		escrever_esq("MUNDO %d" % (w + 1), ri.position + Vector2(12, 24), 14, OURO if aberto else CINZA, fonte_titulo)
		escrever_esq(MUNDO_NOMES[w], ri.position + Vector2(12, 46), 18, BRANCO if aberto else CINZA)
		var livro := "Livro I" if c1 <= 35 else ("Livro II" if c0 > 35 else "Livro I e II")
		var wi := fonte.get_string_size(livro, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
		escrever_esq(livro, Vector2(ri.end.x - 12 - wi, ri.position.y + 22), 13, CINZA)
		if not aberto:
			var cc := ri.get_center()
			draw_rect(Rect2(cc + Vector2(-13, -4), Vector2(26, 20)), CINZA)
			draw_arc(cc + Vector2(0, -5), 9, PI, TAU, 12, CINZA, 3)
		if prog.get("baus", {}).has(str(w + 1)):
			escrever("baú aberto", Vector2(ri.end.x - 44, ri.end.y - 14), 12, OURO, true)
		# os 4 capítulos embaixo
		draw_line(no_capitulo_card(c0), no_capitulo_card(c1), Color(0, 0, 0, 0.7), 6)
		for c in range(c0, c1 + 1):
			var p := no_capitulo_card(c)
			var venceu: bool = prog.get("feitos_p", {}).has(str(c)) if modo == "pesadelo" else feito(c)
			if c < c1 and venceu:
				draw_line(p, no_capitulo_card(c + 1), SANGUE, 3)
			if venceu:
				if c == destaque_cap and t_tela < 3.0:
					brilho_suave(p, 60, OURO, 1.6 * (1.0 - t_tela / 3.0) + 0.3 * sin(tempo * 6))
				draw_circle(p, 24, TINTA)
				draw_circle(p, 21, Color8(120, 94, 52))
				draw_arc(p, 21, 0, TAU, 32, OURO, 2, true)
				escrever(str(c), p + Vector2(0, -3), 16, BRANCO, false)
				draw_polyline(PackedVector2Array([p + Vector2(-6, 9), p + Vector2(-2, 13), p + Vector2(6, 5)]), Color8(120, 230, 140), 2.5, true)
				if prog.get("bonus", {}).has(str(c)):
					var e := []
					var pe := p + Vector2(17, -17)
					for k in 10:
						e.append(pe + Vector2.from_angle(-PI / 2 + k * TAU / 10) * (8.0 if k % 2 == 0 else 3.5))
					poli(e, OURO, 1.2)
			elif capitulo_disponivel(c):
				brilho_suave(p, 44, VERMELHO, 1.0 + 0.4 * sin(tempo * 4))
				draw_circle(p, 24, TINTA)
				draw_circle(p, 21, Color8(150, 26, 30))
				draw_arc(p, 21, 0, TAU, 32, Color8(255, 120, 100), 2, true)
				escrever(str(c), p, 17, BRANCO, false)
			else:
				draw_circle(p, 24, TINTA)
				draw_circle(p, 21, PEDRA_ESC)
				draw_arc(p, 21, 0, TAU, 32, PEDRA_BORDA, 1.5, true)
				draw_rect(Rect2(p + Vector2(-7, -2), Vector2(14, 11)), CINZA)
				draw_arc(p + Vector2(0, -3), 5, PI, TAU, 10, CINZA, 2)
		if atual:
			escrever(encurtar("Próximo: %d · %s" % [lib, CAPITULOS[lib - 1]], fonte, 14, r.size.x - 30), Vector2(LARG / 2, r.end.y - 14), 14, BRANCO, false)
	cabecalho("MUNDOS · PESADELO" if modo == "pesadelo" else "MUNDOS")
	desenhar_abas()


func desenhar_missoes() -> void:
	desenhar_fundo(0.65)
	cabecalho("MISSÕES DO DIA")
	escrever("Renovam todo dia. Cumpra e pegue os fragmentos.", Vector2(LARG / 2, 136), 14, CINZA)
	var m := missoes_do_dia()
	var b := botoes_menu()
	for i in MISSOES.size():
		var ms: Dictionary = MISSOES[i]
		var r := Rect2(16, 160 + i * 110, LARG - 32, 96)
		caixa(r, Color(0.06, 0.05, 0.08, 0.93), 10, 1, Color(PEDRA_BORDA, 0.9), true, 6)
		var feito_n := mini(int(m.get(ms["id"], 0)), int(ms["meta"]))
		escrever_esq(ms["nome"], r.position + Vector2(16, 30), 16, OURO, fonte_titulo)
		var barra := Rect2(r.position + Vector2(16, 48), Vector2(290, 12))
		caixa(barra, Color8(20, 16, 26), 6, 1, PEDRA_BORDA)
		if feito_n > 0:
			degrade(Rect2(barra.position + Vector2(2, 2), Vector2((barra.size.x - 4) * feito_n / float(ms["meta"]), 8)), Color8(236, 80, 60), Color8(140, 20, 26))
		escrever_esq("%d / %d" % [feito_n, int(ms["meta"])], r.position + Vector2(16, 82), 14, CINZA)
		var pego: bool = m["pegas"].has(ms["id"])
		var pronto := feito_n >= int(ms["meta"])
		var bb: Rect2 = b["missao%d" % i]
		if pego:
			botao(bb, "Pego", CINZA, false)
		else:
			botao(bb, "", OURO if pronto else CINZA, pronto, pronto)
			cristal(bb.position + Vector2(34, 22), 8, VERMELHO)
			escrever_esq(str(int(ms["premio"]) + mundo_de(int(prog["liberado"])) / 2), bb.position + Vector2(48, 30), 20, BRANCO if pronto else CINZA)
	desenhar_abas()
	desenhar_popup()


func desenhar_ajustes() -> void:
	desenhar_fundo(0.7)
	cabecalho("AJUSTES")
	var b := botoes_menu()
	apagar_confirma = maxf(0.0, apagar_confirma - 0.016)
	for it in [["Música", b["musica"], som_ligado], ["Efeitos sonoros", b["efeitos"], efeitos_ligados], ["Vibração (app)", b["vibracao"], vibracao_ligada]]:
		var r: Rect2 = it[1]
		escrever_esq(it[0], Vector2(40, r.get_center().y + 7), 20, BRANCO)
		botao(r, "Ligado" if it[2] else "Desligado", VERDE if it[2] else CINZA, true, it[2])
	escrever_esq("Idioma / Language", Vector2(40, b["idioma"].get_center().y + 7), 20, BRANCO)
	botao(b["idioma"], "Português" if idioma == "pt" else "English", OURO, true, true)
	draw_line(Vector2(30, 346), Vector2(LARG - 30, 346), Color(PEDRA_BORDA, 0.7), 1)
	botao(b["apagar"], "Toque de novo para apagar tudo" if apagar_confirma > 0 else "Apagar progresso", VERMELHO, true, apagar_confirma > 0)
	escrever("Apaga capítulos, melhorias e fragmentos deste aparelho.", Vector2(LARG / 2, 428), 13, CINZA)
	escrever("O jogo funciona sem internet depois de aberto uma vez.", Vector2(LARG / 2, 462), 14, Color8(150, 220, 170))
	colar_confirma = maxf(0.0, colar_confirma - 0.016)
	escrever("Continuar em outro celular", Vector2(LARG / 2, 500), 15, OURO, true, fonte_titulo)
	botao(b["copiar_prog"], "Copiar progresso", AZUL, true, false)
	botao(b["colar_prog"], "Toque para trocar" if colar_confirma > 0 else "Colar progresso", VERMELHO if colar_confirma > 0 else AZUL, true, colar_confirma > 0)
	botao(b["codigo"], "Código de presente", OURO, true, false)
	var selos := []
	if prog.get("compras", {}).has("apoiador"):
		selos.append(tx("Apoiador: obrigado!"))
	if str(prog.get("titulo", "")) != "":
		selos.append(str(prog["titulo"]))
	if prog.get("beta", "") != "":
		selos.append(tx("Beta Tester") + (": " + str(prog["beta_nome"]) if str(prog.get("beta_nome", "")) != "" else ""))
	if not selos.is_empty():
		escrever("   ·   ".join(selos), Vector2(LARG / 2, 638), 15, Color8(170, 255, 200), true)
	escrever("Kravenox: Quadros do Cisma", Vector2(LARG / 2, 662), 15, OURO, true, fonte_titulo)
	escrever(tx("versão ") + VERSAO, Vector2(LARG / 2, 684), 13, CINZA, false)
	desenhar_abas()
	desenhar_popup()


func logo(centro: Vector2, tam := 56) -> void:
	brilho_suave(centro + Vector2(0, -6), 170, VERMELHO, 0.55 + 0.1 * sin(tempo * 2))
	escrever("KRAVENOX", centro, tam, Color8(236, 60, 54), true, fonte_titulo)
	escrever("QUADROS DO CISMA", centro + Vector2(0, tam * 0.72), int(tam * 0.36), OURO, true, fonte_titulo)


func pilula_fragmentos(direita: float, y: float) -> void:
	var t := str(int(prog["fragmentos"]))
	var w := fonte.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x + 52
	var r := Rect2(direita - w, y, w, 36)
	caixa(r, Color(0.05, 0.04, 0.07, 0.88), 18, 1, Color(VERMELHO, 0.6))
	cristal(r.position + Vector2(20, 18), 9, VERMELHO)
	escrever_esq(t, r.position + Vector2(36, 26), 22, BRANCO)


func cabecalho(titulo: String) -> void:
	draw_rect(Rect2(0, 0, LARG, TOPO_MUNDOS - 8), Color(0.03, 0.02, 0.05, 0.96))
	draw_line(Vector2(0, TOPO_MUNDOS - 8), Vector2(LARG, TOPO_MUNDOS - 8), Color(OURO, 0.4), 1)
	var bv: Rect2 = botoes_menu()["voltar"]
	botao(bv, "", OURO)
	draw_polyline(PackedVector2Array([bv.get_center() + Vector2(4, -8), bv.get_center() + Vector2(-4, 0), bv.get_center() + Vector2(4, 8)]), OURO, 2.5, true)
	escrever_esq(titulo, Vector2(66, 44), 22, OURO, fonte_titulo)
	pilula_fragmentos(LARG - 14, 16)


func desenhar_abertura() -> void:
	desenhar_fundo(0.55)
	logo(Vector2(LARG / 2, 190), 58)
	var base := Vector2(LARG / 2, 560)
	brilho_suave(base + Vector2(0, -110), 150, VERMELHO, 0.5)
	sombra_chao(base, 70)
	desenhar_arte("kravenox", base, 250, false)
	var fr := clampf(t_tela / DURA_ABERTURA, 0, 1)
	var barra := Rect2(LARG / 2 - 150, 640, 300, 14)
	caixa(barra.grow(3), Color(0.04, 0.03, 0.06, 0.9), 9, 1, Color(OURO, 0.5))
	if fr > 0:
		degrade(Rect2(barra.position, Vector2(barra.size.x * fr, barra.size.y)), Color8(236, 80, 60), Color8(140, 20, 26))
	var i := mini(int(fr * 3), 2) if fr < 1 else 3
	var a := 1.0 if fr < 1 else 0.55 + 0.45 * sin(tempo * 4)
	escrever(MSG_ABERTURA[i], Vector2(LARG / 2, 684), 19, Color(BRANCO, a))


func desenhar_melhorias() -> void:
	desenhar_fundo(0.62)
	cabecalho("MELHORIAS")
	escrever("Cada capítulo dá fragmentos. Gaste aqui para ficar mais forte.", Vector2(LARG / 2, 132), 14, CINZA)
	var b := botoes_menu()
	for i in MELHORIAS.size():
		var m: Dictionary = MELHORIAS[i]
		var r := Rect2(16, 146 + i * 84, LARG - 32, 78)
		caixa(r, Color(0.06, 0.05, 0.08, 0.93), 10, 1, Color(PEDRA_BORDA, 0.9), true, 6)
		var lv := nivel_melhoria(m["id"])
		var mx := int(m["max"])
		escrever_esq(m["nome"], r.position + Vector2(16, 26), 15, OURO, fonte_titulo)
		escrever_esq(m["desc"], r.position + Vector2(16, 47), 14, CINZA)
		for k in mx:
			var p := r.position + Vector2(22 + k * (15 if mx <= 10 else 14), 63)
			var d := PackedVector2Array([p + Vector2(0, -5), p + Vector2(4.5, 0), p + Vector2(0, 5), p + Vector2(-4.5, 0)])
			draw_colored_polygon(d, VERMELHO if k < lv else PEDRA_CLARA)
		var bb: Rect2 = b["melhoria%d" % i]
		if lv >= mx:
			botao(bb, "MÁXIMO", CINZA, false)
		else:
			var custo := custo_melhoria(m)
			var pode := int(prog["fragmentos"]) >= custo
			botao(bb, "", OURO if pode else CINZA, pode, pode)
			cristal(bb.position + Vector2(36, 22), 8, VERMELHO)
			escrever_esq(str(custo), bb.position + Vector2(50, 30), 20, BRANCO if pode else CINZA)
	desenhar_abas()
	desenhar_popup()


func desenhar_bestiario() -> void:
	desenhar_fundo(0.62)
	for i in ORDEM_BESTIARIO.size():
		var tipo: String = ORDEM_BESTIARIO[i]
		var info: Dictionary = MONSTROS[tipo]
		var r := Rect2(16 + (i % 2) * 228, TOPO_MUNDOS + 2 + (i / 2) * 154, 220, 146)
		var visto: bool = prog["vistos"].has(tipo)
		var chefe: bool = info.get("chefe", false)
		caixa(r, Color(0.06, 0.05, 0.08, 0.93), 10, 1, Color(ROXO if chefe else PEDRA_BORDA, 0.8), true, 6)
		var base := r.position + Vector2(r.size.x / 2, 100)
		brilho_suave(base + Vector2(0, -40), 60, AZUL if tipo == "thornox" else ROXO, 0.5 if visto else 0.15)
		sombra_chao(base, 36)
		var mod: Color = info.get("tinta", Color.WHITE) if visto else Color(0, 0, 0, 0.92)
		desenhar_arte(info["img"], base, 82, false, mod)
		escrever(info["nome"] if visto else "???", r.position + Vector2(r.size.x / 2, 118), 16, BRANCO if visto else CINZA, false)
		var nota := "Chefe" if chefe else "Desde o capítulo %d" % MONSTRO_DESDE[tipo]
		if visto:
			nota += " · caça nv %d" % nivel_caca(tipo)
		escrever(nota, r.position + Vector2(r.size.x / 2, 136), 13, Color8(200, 160, 255) if chefe else CINZA, false)
	cabecalho("BESTIÁRIO")
	texto_quebrado("Toque num monstro para ver a ficha e o nível de caça", Vector2(260, 640), 190, 14, CINZA, 3, true)
	desenhar_abas()
	desenhar_popup()


# Dica da loja: cabe em até duas linhas pequenas.
func desenhar_dica(t: String, c: Vector2, largura: float) -> void:
	t = tx(t)
	if fonte.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x <= largura:
		escrever(t, c, 14, CINZA, false)
		return
	var palavras := t.split(" ")
	var l1 := ""
	var i := 0
	while i < palavras.size() and fonte.get_string_size((l1 + " " + palavras[i]).strip_edges(), HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x <= largura:
		l1 = (l1 + " " + palavras[i]).strip_edges()
		i += 1
	var l2 := " ".join(palavras.slice(i))
	escrever(l1, c + Vector2(0, -6), 13, Color8(220, 210, 230), false)
	escrever(encurtar(l2, fonte, 13, largura), c + Vector2(0, 9), 13, Color8(220, 210, 230), false)


# ------------------------------------------------------------ arrastar com o dedo
# Segurar um item da loja (ou de um quadro) e soltar num quadro. Um toque
# rápido, sem arrastar, continua valendo como antes: toca no item e depois no
# quadro.
func comecar_arrasto(p: Vector2) -> bool:
	if estado != "loja" or vender:
		return false
	var b := botoes()
	for i in 3:
		if b["loja%d" % i].has_point(p) and loja[i] != null and essencia >= preco(loja[i]):
			arrasto = {"de": "loja", "i": i, "p": p, "moveu": false}
			toque_ini = p
			return true
	for i in ANEL.size():
		if ret_quadro(i).has_point(p) and quadros[i] != null:
			arrasto = {"de": "quadro", "i": i, "p": p, "moveu": false}
			toque_ini = p
			return true
	return false


func soltar_arrasto(p: Vector2) -> void:
	var a := arrasto
	arrasto = {}
	if not a["moveu"]:
		clique(toque_ini)   # foi só um toque
		return
	var alvo := quadro_em(p)
	if alvo < 0:
		selec = []
		return
	selec = [a["de"], a["i"]]
	clique_quadro(alvo)
	salvar_partida()


func quadro_em(p: Vector2) -> int:
	for i in ANEL.size():
		if ret_quadro(i).grow(6).has_point(p):
			return i
	return -1


func item_arrastado():
	if arrasto.is_empty():
		return null
	if arrasto["de"] == "loja":
		return {"id": loja[arrasto["i"]], "nv": 1}
	return quadros[arrasto["i"]]


func desenhar_arrasto() -> void:
	if arrasto.is_empty() or not arrasto["moveu"]:
		return
	var item = item_arrastado()
	if item == null:
		return
	var alvo := quadro_em(arrasto["p"])
	if alvo >= 0 and not (arrasto["de"] == "quadro" and alvo == arrasto["i"]):
		var q = quadros[alvo]
		var funde: bool = q != null and q["id"] == item["id"] and q["nv"] == item["nv"] and q["nv"] < NIVEL_MAX
		var ok: bool = (q == null or funde or arrasto["de"] == "quadro") and terreno[alvo] != "maldita"
		var cor := OURO if ok else VERMELHO
		caixa(ret_quadro(alvo).grow(4), Color(0, 0, 0, 0), 9, 3, cor, false)
		brilho_suave(ret_quadro(alvo).get_center(), 60, cor, 0.8)
		if funde:
			escrever("Fundir!", ret_quadro(alvo).get_center() + Vector2(0, 30), 15, OURO)
	var c: Vector2 = arrasto["p"] + Vector2(0, -36)   # um pouco acima do dedo, para dar para ver
	caixa(Rect2(c - Vector2(40, 40), Vector2(80, 80)), Color(0.08, 0.06, 0.1, 0.85), 10, 2, OURO, true, 8)
	icone(item["id"], c, 0.95)


# A torre da fase bônus, no meio do caminho: pedra escura com o cristal roxo.
func desenhar_torre() -> void:
	var base := CENTRO + Vector2(0, 30)
	var caiu := torre_hp <= 0
	sombra_chao(base, 40)
	var alt := 30.0 if caiu else 92.0
	var w := 46.0
	var corpo := [base + Vector2(-w / 2, 0), base + Vector2(w / 2, 0), base + Vector2(w / 2 - 6, -alt), base + Vector2(-w / 2 + 6, -alt)]
	poli(corpo, Color8(52, 46, 62) if torre_flash <= 0 else Color8(140, 60, 70), 2)
	for k in int(alt / 14):
		var y := base.y - 10 - k * 14
		draw_line(Vector2(base.x - w / 2 + 4, y), Vector2(base.x + w / 2 - 4, y), Color(0, 0, 0, 0.45), 1)
	if caiu:
		return
	var topo := base + Vector2(0, -alt)
	for k in 3:
		draw_rect(Rect2(topo + Vector2(-20 + k * 15, -10), Vector2(10, 10)), Color8(52, 46, 62))
	brilho_suave(topo + Vector2(0, -24), 40, ROXO, 1.0 + 0.3 * sin(tempo * 3))
	cristal(topo + Vector2(0, -24), 13)
	var wb := 60.0
	var y0 := topo.y - 52
	draw_rect(Rect2(base.x - wb / 2 - 1, y0 - 1, wb + 2, 7), Color(0, 0, 0, 0.8))
	draw_rect(Rect2(base.x - wb / 2, y0, wb * clampf(torre_hp / maxf(1.0, torre_max), 0, 1), 5), ROXO)


# ============================================================ a tela do Kravenox
const CARTAS_KX := ["vida", "forca", "defesa", "critico"]
const CORES_FORMA := [Color8(180, 40, 40), Color8(210, 40, 44), Color8(230, 50, 40), Color8(220, 30, 80),
	Color8(190, 40, 150), Color8(150, 60, 220), Color8(120, 70, 255), Color8(90, 140, 255),
	Color8(255, 120, 60), Color8(255, 200, 80)]


func contar_total(id: String, n := 1) -> void:
	if robo:
		return
	var t: Dictionary = prog.get("total", {})
	t[id] = int(t.get(id, 0)) + n
	prog["total"] = t


func indice_melhoria(id: String) -> int:
	for i in MELHORIAS.size():
		if MELHORIAS[i]["id"] == id:
			return i
	return 0


func nivel_kravenox() -> int:
	var n := 1
	for m in MELHORIAS:
		n += nivel_melhoria(m["id"])
	return n


func forma_atual() -> int:
	var nv := nivel_kravenox()
	var f := 0
	for i in FORMAS_KX.size():
		if nv >= int(FORMAS_KX[i][0]):
			f = i
	return f


func cor_forma() -> Color:
	var a := cor_aura()
	if a.a > 0:
		return a
	return CORES_FORMA[forma_atual()]


func progresso_conquista(c: Dictionary) -> int:
	match c["tipo"]:
		"feitos":
			return prog["feitos"].size()
		"feitos_p":
			return prog.get("feitos_p", {}).size()
		"nivel":
			return nivel_kravenox()
	return int(prog.get("total", {}).get(c["tipo"], 0))


func conquistas_prontas() -> int:
	var n := 0
	var pegas: Dictionary = prog.get("conquistas", {})
	for c in CONQUISTAS:
		if progresso_conquista(c) >= int(c["meta"]) and not pegas.has(c["id"]):
			n += 1
	return n


func icone_pequeno(tipo: String, c: Vector2, cor: Color) -> void:
	match tipo:
		"vida":
			draw_circle(c + Vector2(-7, -4), 9, cor)
			draw_circle(c + Vector2(7, -4), 9, cor)
			draw_colored_polygon(PackedVector2Array([c + Vector2(-15, 0), c + Vector2(15, 0), c + Vector2(0, 16)]), cor)
			draw_circle(c + Vector2(-9, -7), 3, Color(1, 1, 1, 0.6))
		"forca":
			for k in [-1.0, 1.0]:
				draw_line(c + Vector2(-14 * k, 14), c + Vector2(13 * k, -14), Color8(220, 220, 230), 5, true)
				draw_line(c + Vector2(-10 * k, 4), c + Vector2(-3 * k, 11), cor, 4, true)
		"defesa":
			poli([c + Vector2(0, -17), c + Vector2(14, -11), c + Vector2(12, 5), c + Vector2(0, 17), c + Vector2(-12, 5), c + Vector2(-14, -11)], cor, 1.5)
			poli([c + Vector2(0, -12), c + Vector2(8, -8), c + Vector2(7, 3), c + Vector2(0, 11)], Color(1, 1, 1, 0.25))
		"critico":
			var e := []
			for k in 10:
				e.append(c + Vector2.from_angle(-PI / 2 + k * TAU / 10) * (17.0 if k % 2 == 0 else 7.0))
			poli(e, cor, 1.5)


func desenhar_kravenox_tela() -> void:
	desenhar_fundo(0.55)
	var cf := cor_forma()
	var f := forma_atual()
	var nv := nivel_kravenox()
	# poder e forma
	escrever("PODER", Vector2(LARG / 2, 136), 13, Color8(255, 170, 120), true, fonte_titulo)
	escrever(str(poder()), Vector2(LARG / 2, 166), 34, OURO, true)
	escrever(FORMAS_KX[f][1].to_upper(), Vector2(LARG / 2, 202), 16, cf.lightened(0.3), true, fonte_titulo)
	# o Kravenox com a aura da forma
	var base := Vector2(LARG / 2, 418)
	brilho_suave(base + Vector2(0, -95), 150, cf, 0.7 + 0.15 * sin(tempo * 2))
	sombra_chao(base, 64)
	desenhar_arte("kravenox", base + Vector2(0, -sin(tempo * 1.4) * 3), 196, false)
	var b := botoes_menu()
	botao_icone(b["kx_formas"], "formas", "Formas")
	botao_icone(b["kx_conquistas"], "conquistas", "Conquistas", conquistas_prontas() > 0)
	botao_icone(b["kx_bestiario"], "bestiario", "Bestiário")
	botao_icone(b["kx_grimorio"], "grimorio", "Grimório")
	botao_icone(b["kx_cronicas"], "cronicas", "Crônicas")
	botao_icone(b["kx_ecos"], "ecos", "Ecos")
	# barra até a próxima forma
	var ini := int(FORMAS_KX[f][0])
	var prox := int(FORMAS_KX[f + 1][0]) if f + 1 < FORMAS_KX.size() else ini
	var fr := 1.0 if prox == ini else clampf(float(nv - ini) / float(prox - ini), 0, 1)
	var barra := Rect2(30, 442, LARG - 60, 14)
	caixa(barra.grow(2), Color8(20, 16, 26), 8, 1, Color(OURO, 0.6))
	if fr > 0:
		degrade(Rect2(barra.position, Vector2(barra.size.x * fr, barra.size.y)), cf.lightened(0.2), cf.darkened(0.3))
	escrever("Nível %d" % nv, Vector2(LARG / 2, 472), 16, BRANCO)
	if f + 1 < FORMAS_KX.size():
		escrever("Próxima forma: %s (nível %d)" % [FORMAS_KX[f + 1][1], prox], Vector2(LARG / 2, 492), 13, CINZA, false)
	else:
		escrever("Forma final alcançada", Vector2(LARG / 2, 492), 13, OURO, false)
	# atributos
	var atr := [["vida", "%d" % int(150 + 20 * nivel_melhoria("vida")), Color8(230, 60, 70)],
		["forca", "+%d%%" % (10 * nivel_melhoria("forca")), Color8(240, 160, 60)],
		["defesa", "-%d%%" % (3 * nivel_melhoria("defesa")), Color8(110, 170, 255)],
		["critico", "%d%%" % (3 * nivel_melhoria("critico")), Color8(200, 120, 255)]]
	for i in 4:
		var r := Rect2(14 + i * 114, 502, 110, 26)
		caixa(r, Color(0.05, 0.04, 0.07, 0.9), 13, 1, Color(atr[i][2], 0.6))
		draw_set_transform(r.position + Vector2(16, 13), 0, Vector2(0.55, 0.55))
		icone_pequeno(atr[i][0], Vector2.ZERO, atr[i][2])
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
		escrever(atr[i][1], r.get_center() + Vector2(8, 0), 15, BRANCO, false)
	# as quatro cartas de evolução
	var nomes := {"vida": "Vida", "forca": "Ataque", "defesa": "Defesa", "critico": "Crítico"}
	var fundos := {"vida": Color8(40, 110, 60), "forca": Color8(140, 90, 30), "defesa": Color8(40, 80, 150), "critico": Color8(100, 50, 150)}
	for i in 4:
		var id: String = CARTAS_KX[i]
		var m: Dictionary = MELHORIAS[indice_melhoria(id)]
		var r: Rect2 = b["kx_carta%d" % i]
		var lv := nivel_melhoria(id)
		var mx := int(m["max"])
		caixa(r, Color(fundos[id], 0.95), 10, 2, Color(fundos[id].lightened(0.4), 0.9), true, 6)
		degrade(Rect2(r.position + Vector2(3, 3), Vector2(r.size.x - 6, 60)), Color(1, 1, 1, 0.12), Color(1, 1, 1, 0))
		escrever(nomes[id], Vector2(r.get_center().x, r.position.y + 18), 16, BRANCO, true)
		brilho_suave(Vector2(r.get_center().x, r.position.y + 66), 40, Color.WHITE, 0.4)
		icone_pequeno(id, Vector2(r.get_center().x, r.position.y + 66), atr[i][2].lightened(0.15))
		escrever("Nv %d/%d" % [lv, mx], Vector2(r.get_center().x, r.position.y + 104), 14, BRANCO, true)
		var curto := {"vida": "+20 de vida", "forca": "+10% de dano", "defesa": "-3% de dano sofrido", "critico": "+3% de crítico"}
		escrever(curto[id], Vector2(r.get_center().x, r.position.y + 124), 12, Color(1, 1, 1, 0.85), false)
		var bb := Rect2(r.position.x + 8, r.end.y - 50, r.size.x - 16, 40)
		if lv >= mx:
			botao(bb, "MÁX", CINZA, false)
		else:
			var custo := custo_melhoria(m)
			var pode := int(prog["fragmentos"]) >= custo
			botao(bb, "", OURO if pode else CINZA, pode, pode)
			cristal(bb.position + Vector2(24, 20), 7, VERMELHO)
			escrever_esq(str(custo), bb.position + Vector2(36, 27), 18, BRANCO if pode else CINZA)
	cabecalho("KRAVENOX")
	desenhar_abas()
	desenhar_popup()


func desenhar_formas() -> void:
	desenhar_fundo(0.65)
	cabecalho("FORMAS")
	var f := forma_atual()
	var nv := nivel_kravenox()
	for i in FORMAS_KX.size():
		var r := Rect2(16, TOPO_MUNDOS + 4 + i * 61, LARG - 32, 56)
		var tem := nv >= int(FORMAS_KX[i][0])
		var cor: Color = CORES_FORMA[i]
		caixa(r, Color(0.06, 0.05, 0.08, 0.93), 10, 2 if i == f else 1, OURO if i == f else Color(PEDRA_BORDA, 0.8), true, 4)
		var c := r.position + Vector2(32, 28)
		brilho_suave(c, 30, cor, 1.0 if tem else 0.2)
		draw_circle(c, 13, cor if tem else PEDRA_ESC)
		draw_arc(c, 13, 0, TAU, 20, Color(OURO, 0.8 if tem else 0.3), 1.5, true)
		escrever_esq(FORMAS_KX[i][1], r.position + Vector2(60, 25), 16, BRANCO if tem else CINZA, fonte_titulo)
		escrever_esq("Nível %d" % int(FORMAS_KX[i][0]), r.position + Vector2(60, 45), 13, CINZA)
		if i == f:
			escrever("ATUAL", Vector2(r.end.x - 44, r.get_center().y), 13, OURO, false, fonte_titulo)
		elif not tem:
			draw_rect(Rect2(Vector2(r.end.x - 50, r.get_center().y - 4), Vector2(14, 11)), CINZA)
			draw_arc(Vector2(r.end.x - 43, r.get_center().y - 5), 5, PI, TAU, 10, CINZA, 2)
	desenhar_abas()


func desenhar_conquistas() -> void:
	desenhar_fundo(0.65)
	cabecalho("CONQUISTAS")
	var b := botoes_menu()
	var pegas: Dictionary = prog.get("conquistas", {})
	for i in CONQUISTAS.size():
		var c: Dictionary = CONQUISTAS[i]
		var r := Rect2(12, TOPO_MUNDOS + 6 + i * 51, LARG - 24, 47)
		var feito_n := mini(progresso_conquista(c), int(c["meta"]))
		var pronta := feito_n >= int(c["meta"])
		var pega: bool = pegas.has(c["id"])
		caixa(r, Color(0.06, 0.05, 0.08, 0.93), 8, 1, Color(OURO if pronta and not pega else PEDRA_BORDA, 0.9))
		escrever_esq(c["nome"], r.position + Vector2(12, 20), 14, OURO if pronta else BRANCO)
		var barra := Rect2(r.position + Vector2(12, 30), Vector2(220, 7))
		draw_rect(barra, Color8(20, 16, 26))
		draw_rect(Rect2(barra.position, Vector2(barra.size.x * feito_n / float(c["meta"]), barra.size.y)), Color8(200, 60, 50))
		escrever_esq("%d/%d" % [feito_n, int(c["meta"])], r.position + Vector2(242, 39), 12, CINZA)
		var bb: Rect2 = b["conquista%d" % i]
		if pega:
			botao(bb, "Pega", CINZA, false)
		else:
			botao(bb, "", OURO if pronta else CINZA, pronta, pronta)
			cristal(bb.position + Vector2(24, 16), 6, VERMELHO)
			escrever_esq(str(int(c["premio"])), bb.position + Vector2(36, 23), 16, BRANCO if pronta else CINZA)
	desenhar_abas()
	desenhar_popup()


# ============================================================ evoluções de 9/11/2026
# (ideias-evolucao.md: bênçãos, combinações, lendárias, terreno, elites, Fúria,
# Ecos, acampamento, Abismo sem Fim, Desafio do Dia, Pactos, Crônicas)

func nb(id: String) -> int:
	return bencaos.count(id)


func pacto(id: String) -> bool:
	return tipo_partida in ["capitulo", "abismo"] and liberou("pactos") and bool(prog.get("pactos", {}).get(id, false))


func pontos_pacto() -> int:
	var n := 0
	for pc in PACTOS:
		if pacto(pc["id"]):
			n += int(pc["pts"])
	return n


func mult_pacto() -> float:
	return 1.0 + 0.15 * pontos_pacto()


func pesadelo_ativo() -> bool:
	return modo == "pesadelo" and tipo_partida == "capitulo"


func liberou(id: String) -> bool:
	for n in NOVIDADES:
		if n["id"] == id:
			return int(prog["liberado"]) >= int(n["desde"])
	return true


func nivel_obra(id: String) -> int:
	return int(prog.get("obras", {}).get(id, 0))


func nivel_caca(tipo: String) -> int:
	var n := int(prog.get("abates", {}).get(tipo, 0))
	return 3 if n >= 100 else (2 if n >= 50 else (1 if n >= 10 else 0))


func regra_desafio() -> Dictionary:
	return REGRAS_DESAFIO[clampi(int(desafio.get("regra", 0)), 0, REGRAS_DESAFIO.size() - 1)]


func desafio_regra_ativa(id: String) -> bool:
	return tipo_partida == "desafio" and regra_desafio()["id"] == id


func chance_critico() -> float:
	return 0.03 * nivel_melhoria("critico") + 0.08 * nb("certeiro")


func mult_dano() -> float:
	var m := (1.0 + 0.1 * nivel_melhoria("forca")) * (1.0 + 0.12 * nb("furia")) * pow(1.5, nb("pacto_sangue"))
	if desafio_regra_ativa("vidro"):
		m *= 1.4
	return m * (1.0 + 0.02 * mini(combo, 10))


func mult_quadro(i: int) -> float:
	var m := 1.0
	if terreno[i] == "fenda":
		m *= 1.5
	if nb("cantos") > 0 and canto(i):
		m *= 1.0 + 0.3 * nb("cantos")
	return m


func mult_dano_recebido() -> float:
	return (1.0 - 0.03 * nivel_melhoria("defesa")) * pow(1.2, nb("frenesi"))


func calc_hp_max() -> float:
	var v := 150.0 + 20 * nivel_melhoria("vida") + 30 * nb("couro")
	v *= pow(0.7, nb("pacto_sangue"))
	if pacto("fragil"):
		v *= 0.7
	if desafio_regra_ativa("vidro"):
		v *= 0.6
	return roundf(v)


func calc_k_vel() -> float:
	# em caminhos maiores ele anda um pouco mais rápido, para a volta não demorar demais
	return 1.4 * (1.0 + 0.06 * nivel_melhoria("passo")) * sqrt(ROTA.size() / 12.0) * (1.0 + 0.12 * nb("ligeiro")) * pow(1.3, nb("frenesi"))


func trocas_por_onda() -> int:
	if desafio_regra_ativa("sem_trocas"):
		return 0
	return 1 + nivel_melhoria("sorte") + nb("troca")


var ultima_vibra := 0


func tremer(forca: float, ms: int) -> void:
	tremor = maxf(tremor, forca)
	if vibracao_ligada and not robo and ms > 0 and Time.get_ticks_msec() - ultima_vibra > 150:
		ultima_vibra = Time.get_ticks_msec()
		Input.vibrate_handheld(ms)


# ------------------------------------------------------------ terreno
func montar_terreno() -> void:
	terreno = []
	terreno.resize(ANEL.size())
	terreno.fill("")
	if not liberou("terreno") or mundo_de(capitulo) < 2:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = capitulo * 7919 + (17 if tipo_partida == "abismo" else 0) + (hash(str(desafio.get("dia", ""))) if tipo_partida == "desafio" else 0)
	var n := 1 + (1 if mundo_de(capitulo) >= 6 else 0) + (1 if ANEL.size() >= 16 else 0)
	var tipos := ["fenda", "altar", "maldita"]
	for _k in n:
		var i := rng.randi_range(1, ANEL.size() - 1)
		if terreno[i] == "":
			terreno[i] = tipos[rng.randi_range(0, 2)]


func vizinhos(i: int) -> Array:
	var v := []
	var n := ROTA.size()
	for p in n:
		if ROTA[p] == i:
			for q in [ROTA[(p - 1 + n) % n], ROTA[(p + 1) % n]]:
				if q != i and not q in v:
					v.append(q)
	return v


func canto(i: int) -> bool:
	var n := ROTA.size()
	var p := ROTA.find(i)
	if p < 0 or cruzamento(i):
		return false
	var a: Vector2i = ANEL[ROTA[(p - 1 + n) % n]]
	var b: Vector2i = ANEL[i]
	var c: Vector2i = ANEL[ROTA[(p + 1) % n]]
	return (b - a) != (c - b)


# ------------------------------------------------------------ combinações e lendárias
func nome_sinergia(a: String, b: String) -> String:
	if a == b:
		return "Eco"
	for sn in SINERGIAS:
		if (sn["a"] == a and sn["b"] == b) or (sn["a"] == b and sn["b"] == a):
			return sn["nome"]
	return ""


func sinergias_do(i: int) -> Array:
	var v := []
	var q = quadros[i]
	if q == null or not liberou("sinergias"):
		return v
	for j in vizinhos(i):
		var o = quadros[j]
		if o == null:
			continue
		var nome := nome_sinergia(q["id"], o["id"])
		if nome != "" and not nome in v:
			v.append(nome)
	return v


func descobrir(chave: String, texto: String) -> void:
	if robo:
		return
	var g: Dictionary = prog.get("grimorio", {})
	if g.has(chave):
		return
	g[chave] = true
	prog["grimorio"] = g
	if texto != "":
		aviso(texto, 3.0)
		som("nivel")


func evoluir_lendarias() -> void:
	for i in ANEL.size():
		var q = quadros[i]
		if q == null or q.get("lend", false) or int(q["nv"]) < NIVEL_MAX or not LENDARIAS.has(q["id"]):
			continue
		var par: String = LENDARIAS[q["id"]]["par"]
		if quadros.any(func(o): return o != null and o["id"] == par):
			q["lend"] = true
			anel(centro_quadro(i), 10, 140, 0.9, OURO)
			tremer(0.5, 120)
			som("chefe")
			descobrir("L:" + str(q["id"]), "")
			contar_total("lendarias")
			aviso("LENDÁRIO: %s!" % LENDARIAS[q["id"]]["nome"], 3.5)


# ------------------------------------------------------------ escolhas entre as ondas
func oferecer_escolha() -> void:
	if tipo_partida == "abismo":
		if onda % 3 == 0 and liberou("bencaos"):
			abrir_bencaos()
		return
	if onda == 2 and liberou("encruzilhada"):
		escolha = {"tipo": "encruzilhada", "titulo": "ENCRUZILHADA", "texto": "Três caminhos se abrem no meio do capítulo.", "opcoes": [
			{"id": "livro", "nome": "Trilha do Livro", "desc": "um trecho deste capítulo do livro e uma escolha"},
			{"id": "elite", "nome": "Caminho da Elite", "desc": "a próxima onda é só de elites; vencendo, +25 de essência e +3 fragmentos"},
			{"id": "fogueira", "nome": "Fogueira", "desc": "cura toda a vida e dá 20 de escudo"}]}
	elif onda in [1, 3] and liberou("bencaos"):
		abrir_bencaos()


func abrir_bencaos() -> void:
	# cada bênção vale no máximo 3 vezes na mesma partida
	var boas := BENCAOS.filter(func(x): return not x.get("sombria", false) and nb(x["id"]) < 3)
	boas.shuffle()
	var ops := boas.slice(0, 3)
	var sombrias := BENCAOS.filter(func(x): return x.get("sombria", false) and nb(x["id"]) < 3)
	if not sombrias.is_empty():
		if ops.size() < 3:
			ops.append(sombrias.pick_random())
		elif randf() < 0.3:
			ops[2] = sombrias.pick_random()
	if ops.is_empty():
		return
	escolha = {"tipo": "bencao", "titulo": "ESCOLHA UMA BÊNÇÃO", "texto": "Vale até o fim do capítulo.", "opcoes": ops}


func trecho(c: int) -> String:
	return str(trechos.get(str(c), ""))


func escolher(i: int) -> void:
	var op: Dictionary = escolha["opcoes"][i]
	var tipo: String = escolha["tipo"]
	escolha = {}
	som("nivel")
	match tipo:
		"hab":
			aplicar_hab(op["id"])
		"bencao":
			aplicar_bencao(op["id"])
		"encruzilhada":
			match op["id"]:
				"livro":
					var t := trecho(capitulo)
					if t == "":
						t = "O caminho segue pelo capítulo %d." % capitulo
					escolha = {"tipo": "evento", "titulo": CAPITULOS[capitulo - 1].to_upper(), "texto": "“%s”" % t, "opcoes": [
						{"id": "descansar", "nome": "Descansar", "desc": "cura toda a vida"},
						{"id": "vozes", "nome": "Ouvir a Essência", "desc": "ganha uma bênção ao acaso, mas perde 20% da vida"},
						{"id": "seguir", "nome": "Seguir em frente", "desc": "+20 de essência"}]}
				"elite":
					onda_elite = true
					aviso("A próxima onda é só de elites!", 3.0)
				"fogueira":
					hp = hp_max
					escudo = maxf(escudo, 20.0)
					aviso("A fogueira cura toda a vida", 2.5)
		"evento":
			match op["id"]:
				"descansar":
					hp = hp_max
				"vozes":
					var boas := BENCAOS.filter(func(x): return not x.get("sombria", false))
					aplicar_bencao(boas.pick_random()["id"])
					hp = maxf(1.0, hp * 0.8)
				"seguir":
					essencia += 20
	salvar_partida()


func aplicar_bencao(id: String) -> void:
	bencaos.append(id)
	var antes := hp_max
	hp_max = calc_hp_max()
	if hp_max > antes:
		hp += hp_max - antes
	hp = minf(hp, hp_max)
	k_vel = calc_k_vel()
	if id == "troca":
		trocas_gratis += 1
	for b in BENCAOS:
		if b["id"] == id:
			aviso("Bênção: %s" % b["nome"], 2.5)
	contar_total("bencaos")


# ------------------------------------------------------------ Fúria e Ecos
func soltar_furia() -> void:
	furia = 0.0
	var f := forma_atual()
	var dano := (30.0 + 22.0 * f) * (1.0 + 0.1 * nivel_melhoria("forca")) * (1.0 + 0.08 * capitulo)
	for m in monstros.duplicate():
		ferir(m, dano * (0.5 if m["chefe"] else 1.0))
	hp = minf(hp_max, hp + hp_max * 0.1)
	anel(k_vis, 20, 460, 0.7, cor_forma())
	anel(k_vis, 10, 240, 0.5, BRANCO)
	tremer(1.0, 160)
	lento_t = 0.5
	som("thornox")
	texto_voa(k_vis + Vector2(0, -84), tx("FÚRIA: ") + tx(FORMAS_KX[f][1]).to_upper(), cor_forma().lightened(0.35), 22)
	contar_total("furias")


func eco_liberado(e: Dictionary) -> bool:
	return prog.get("baus", {}).has(str(e["bau"]))


func eco_atual() -> Dictionary:
	var id := str(prog.get("eco", ""))
	for e in ECOS:
		if e["id"] == id and eco_liberado(e):
			return e
	return {}


func pos_eco() -> Vector2:
	return k_vis + Vector2(cos(tempo * 2.2) * 40, sin(tempo * 2.2) * 14 - 44)


func atualizar_eco(dt: float) -> void:
	var e := eco_atual()
	if e.is_empty():
		return
	eco_t -= dt
	if eco_t > 0:
		return
	var f := 1.0 + 0.25 * nivel_obra("altar")
	var pe := pos_eco()
	match e["id"]:
		"rubro":
			eco_t = 2.0
			var alvo = mais_perto(pe)
			if alvo != null and alvo["pos"].distance_to(pe) < 280:
				efeitos.append({"t": "raio", "a": pe, "b": alvo["pos"], "vida": 0.2})
				ferir(alvo, (10.0 + 1.5 * capitulo) * f * (1.0 + 0.1 * nivel_melhoria("forca")))
		"verde":
			eco_t = 4.0
			if hp < hp_max:
				var c := 4.0 * f
				hp = minf(hp_max, hp + c)
				texto_voa(pe, "+%d" % int(c), VERDE, 15)
		"dourado":
			eco_t = 4.0
			var g := int(round(f))
			essencia += g
			texto_voa(pe, "+%d" % g, OURO, 15)
		"azul":
			eco_t = 4.0
			escudo = minf(60.0, escudo + 5.0 * f)


# ------------------------------------------------------------ arriscar depois do bônus
func pode_arriscar() -> bool:
	return tipo_partida == "capitulo" and bonus_res in ["ok", "risco"]


func arriscar() -> void:
	em_risco = true
	risco_n += 1
	estado = "loja"
	bonus_res = ""
	limpar_partida()
	monstros.clear()
	fila.clear()
	tiros.clear()
	descanso_entre_ondas()
	aviso("Mais uma onda! Se cair, fica com metade do pote", 3.0)


func guardar_pote() -> void:
	if risco_pote > 0:
		prog["fragmentos"] = int(prog["fragmentos"]) + risco_pote
		premio_fim += risco_pote
		risco_pote = 0
		salvar()
	em_risco = false


# ------------------------------------------------------------ Abismo sem Fim e Desafio do Dia
var abismo_novo_rec := false


func comecar_abismo() -> void:
	tipo_partida = "abismo"
	capitulo = clampi(int(prog["liberado"]), 4, TOTAL_CAPITULOS)
	tela = "jogo"
	novo_jogo()
	retomar_partida()


func fim_abismo() -> void:
	var feitas := maxi(0, onda - 1)
	var rec := int(prog.get("abismo_rec", 0))
	abismo_novo_rec = feitas > rec
	prog["abismo_rec"] = maxi(rec, feitas)
	enviar_recorde("abismo", feitas)
	premio_fim = int(round(feitas * (0.5 + mundo_de(capitulo) / 8.0) * mult_pacto()))
	prog["fragmentos"] = int(prog["fragmentos"]) + premio_fim
	limpar_partida()
	salvar()


func gerar_desafio() -> Dictionary:
	var dia := hoje()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("desafio " + dia)
	var lib := clampi(int(prog["liberado"]), 2, TOTAL_CAPITULOS)
	var cap := rng.randi_range(maxi(2, lib - 10), lib)
	var regra := rng.randi_range(0, REGRAS_DESAFIO.size() - 1)
	var ataques := ["garras", "espinhos", "raio", "esmagamento", "rasgo"].filter(func(k): return ITEM_DESDE[k] <= cap)
	var armas := []
	while armas.size() < mini(2, ataques.size()):
		var a: String = ataques[rng.randi_range(0, ataques.size() - 1)]
		if not a in armas:
			armas.append(a)
	return {"dia": dia, "regra": regra, "capitulo": cap, "armas": armas}


func desafio_feito_hoje() -> bool:
	return prog.get("desafio_dia", "") == hoje()


func comecar_desafio() -> void:
	desafio = gerar_desafio()
	tipo_partida = "desafio"
	capitulo = int(desafio["capitulo"])
	tela = "jogo"
	novo_jogo()
	var pt := partida_guardada()
	if not pt.is_empty() and str(pt.get("tipo", "")) == "desafio" and str(pt.get("desafio", {}).get("dia", "")) == hoje():
		retomar_partida()


func fim_desafio(venceu: bool) -> void:
	if venceu and not desafio_feito_hoje():
		premio_fim = 15 + 3 * mundo_de(capitulo)
		prog["desafio_dia"] = hoje()
		contar_total("desafios")
	elif venceu:
		premio_fim = 2
	else:
		premio_fim = maxi(0, onda - 1)
	prog["fragmentos"] = int(prog["fragmentos"]) + premio_fim
	limpar_partida()
	salvar()


# ============================================================ telas novas
func ontem() -> String:
	var bias := int(Time.get_time_zone_from_system().get("bias", 0))
	return Time.get_date_string_from_unix_time(int(agora()) + bias * 60 - 86400)


# Ao chegar à tela inicial: presente de quem voltou depois de muito tempo e
# o aviso de cada novidade liberada (uma por vez).
func checar_novidades() -> void:
	if robo or not popup.is_empty():
		return
	if prog.get("beta", "") == "escolher":
		tela = "beta"
		return
	if prog.get("volta_pendente", false):
		prog.erase("volta_pendente")
		ganhar(20 + 5 * mundo_de(int(prog["liberado"])), "BEM-VINDO DE VOLTA")
		popup["extra"] = "Fúria pela metade nas próximas 3 partidas"
		return
	var vistas: Dictionary = prog.get("novidades", {})
	for n in NOVIDADES:
		if int(prog["liberado"]) >= int(n["desde"]) and not vistas.has(n["id"]):
			vistas[n["id"]] = true
			prog["novidades"] = vistas
			salvar()
			popup = {"titulo": tx("NOVO: ") + tx(n["titulo"]), "texto": n["texto"]}
			som("nivel")
			return


func custo_obra(o: Dictionary) -> int:
	return int(o["custo"]) * (nivel_obra(o["id"]) + 1) * 2


func comprar_obra(i: int) -> bool:
	var o: Dictionary = CONSTRUCOES[i]
	var lv := nivel_obra(o["id"])
	var c := custo_obra(o)
	if lv >= int(o["max"]) or int(prog["fragmentos"]) < c:
		return false
	prog["fragmentos"] = int(prog["fragmentos"]) - c
	var ob: Dictionary = prog.get("obras", {})
	ob[o["id"]] = lv + 1
	prog["obras"] = ob
	salvar()
	som("nivel")
	return true


func pode_construir() -> bool:
	for o in CONSTRUCOES:
		if nivel_obra(o["id"]) < int(o["max"]) and int(prog["fragmentos"]) >= custo_obra(o):
			return true
	return false


func desenhar_acampamento() -> void:
	desenhar_fundo(0.62)
	cabecalho("ACAMPAMENTO")
	escrever("Construções que valem para todas as partidas.", Vector2(LARG / 2, 132), 14, CINZA)
	var b := botoes_menu()
	for i in CONSTRUCOES.size():
		var o: Dictionary = CONSTRUCOES[i]
		var r := Rect2(16, 146 + i * 84, LARG - 32, 78)
		caixa(r, Color(0.06, 0.05, 0.08, 0.93), 10, 1, Color(PEDRA_BORDA, 0.9), true, 6)
		var lv := nivel_obra(o["id"])
		var mx := int(o["max"])
		escrever_esq(o["nome"], r.position + Vector2(16, 26), 15, OURO, fonte_titulo)
		escrever_esq(o["desc"], r.position + Vector2(16, 47), 13, CINZA)
		for k in mx:
			var pp := r.position + Vector2(22 + k * 15, 63)
			draw_colored_polygon(PackedVector2Array([pp + Vector2(0, -5), pp + Vector2(4.5, 0), pp + Vector2(0, 5), pp + Vector2(-4.5, 0)]), Color8(255, 150, 60) if k < lv else PEDRA_CLARA)
		var bb: Rect2 = b["obra%d" % i]
		if lv >= mx:
			botao(bb, "PRONTA", CINZA, false)
		else:
			var custo := custo_obra(o)
			var pode := int(prog["fragmentos"]) >= custo
			botao(bb, "", OURO if pode else CINZA, pode, pode)
			cristal(bb.position + Vector2(36, 22), 8, VERMELHO)
			escrever_esq(str(custo), bb.position + Vector2(50, 30), 20, BRANCO if pode else CINZA)
	desenhar_abas()
	desenhar_popup()


func desenhar_pactos() -> void:
	desenhar_fundo(0.7)
	draw_rect(Rect2(0, 0, LARG, ALT), Color(0.25, 0.0, 0.03, 0.18))
	cabecalho("PACTOS DO ABISMO")
	escrever("Mais difícil, mais fragmentos. Valem nos capítulos e no Abismo.", Vector2(LARG / 2, 134), 14, CINZA)
	escrever("%d pontos · fragmentos ×%s" % [pontos_pacto(), String.num(mult_pacto(), 2).replace(".", ",")], Vector2(LARG / 2, 160), 18, Color8(255, 150, 160), true)
	var b := botoes_menu()
	for i in PACTOS.size():
		var pc: Dictionary = PACTOS[i]
		var lig := pacto(pc["id"])
		var r := Rect2(16, 176 + i * 66, LARG - 32, 60)
		caixa(r, Color(0.12, 0.03, 0.05, 0.93) if lig else Color(0.06, 0.05, 0.08, 0.93), 10, 2 if lig else 1, VERMELHO if lig else Color(PEDRA_BORDA, 0.9), true, 4)
		escrever_esq("%s  ·  %d pt%s" % [pc["nome"], int(pc["pts"]), "s" if int(pc["pts"]) > 1 else ""], r.position + Vector2(14, 26), 15, Color8(255, 150, 150) if lig else OURO, fonte_titulo)
		escrever_esq(pc["desc"], r.position + Vector2(14, 48), 13, CINZA)
		botao(b["pacto%d" % i], "Ligado" if lig else "Desligado", VERMELHO if lig else CINZA, true, lig)
	desenhar_abas()


func desenhar_grimorio() -> void:
	desenhar_fundo(0.68)
	cabecalho("GRIMÓRIO")
	var g: Dictionary = prog.get("grimorio", {})
	var y := TOPO_MUNDOS + 6
	escrever_esq("COMBINAÇÕES (quadros vizinhos)", Vector2(18, y + 14), 13, Color8(200, 170, 255), fonte_titulo)
	y += 22
	for sn in SINERGIAS:
		var tem := g.has("S:" + sn["nome"])
		var r := Rect2(12, y, LARG - 24, 36)
		caixa(r, Color(0.06, 0.05, 0.08, 0.9), 8, 1, Color(ROXO if tem else PEDRA_BORDA, 0.7))
		var par := tx("dois poderes iguais") if sn["a"] == "*" else "%s + %s" % [tx(ITENS[sn["a"]]["nome"]), tx(ITENS[sn["b"]]["nome"])]
		if tem:
			escrever_esq(sn["nome"], r.position + Vector2(10, 16), 14, OURO)
			escrever_esq(encurtar(par + ": " + tx(sn["desc"]), fonte, 12, r.size.x - 20), r.position + Vector2(10, 32), 12, CINZA)
		else:
			escrever_esq("??? " + (tx("(secreta)") if sn.get("secreta", false) else ""), r.position + Vector2(10, 16), 14, CINZA)
			escrever_esq(tx("dica: ") + (tx("descubra sozinho") if sn.get("secreta", false) else par), r.position + Vector2(10, 32), 12, Color(CINZA, 0.6))
		y += 39
	y += 6
	escrever_esq("LENDÁRIAS (nível 5 + parceiro no caminho)", Vector2(18, y + 14), 13, OURO, fonte_titulo)
	y += 22
	for id in LENDARIAS:
		var ld: Dictionary = LENDARIAS[id]
		var tem := g.has("L:" + id)
		var r := Rect2(12, y, LARG - 24, 36)
		caixa(r, Color(0.06, 0.05, 0.08, 0.9), 8, 1, Color(OURO if tem else PEDRA_BORDA, 0.7))
		escrever_esq(ld["nome"] if tem else "???", r.position + Vector2(10, 16), 14, OURO if tem else CINZA)
		var t := "%s 5 + %s" % [tx(ITENS[id]["nome"]), tx(ITENS[ld["par"]]["nome"])]
		escrever_esq(encurtar(t + (": " + tx(ld["desc"]) if tem else ""), fonte, 12, r.size.x - 20), r.position + Vector2(10, 32), 12, CINZA)
		y += 39
	desenhar_abas()


func cronicas() -> Array:
	var v := []
	for c in range(1, TOTAL_CAPITULOS + 1):
		if feito(c):
			v.append(c)
	return v


func desenhar_cronicas() -> void:
	desenhar_fundo(0.75)
	cabecalho("CRÔNICAS")
	var lista := cronicas()
	if lista.is_empty():
		escrever("Vença um capítulo para liberar a primeira crônica.", Vector2(LARG / 2, 300), 15, CINZA)
		desenhar_abas()
		return
	if not cron_cap in lista:
		cron_cap = lista[-1]
	var c := cron_cap
	var w := mundo_de(c)
	var tm := arte_mundo(w)
	var ri := Rect2(16, TOPO_MUNDOS + 4, LARG - 32, 190)
	var fr := Rect2(0, (tm.get_height() - tm.get_width() * ri.size.y / ri.size.x) / 2.0, tm.get_width(), tm.get_width() * ri.size.y / ri.size.x)
	draw_texture_rect_region(tm, ri, fr)
	degrade(Rect2(ri.position + Vector2(0, ri.size.y - 60), Vector2(ri.size.x, 60)), Color(0, 0, 0, 0), Color(0.03, 0.02, 0.05, 1))
	caixa(ri, Color(0, 0, 0, 0), 8, 2, Color(OURO, 0.6), false)
	escrever("CAPÍTULO %d" % c, Vector2(LARG / 2, ri.end.y + 26), 24, BRANCO, true, fonte_titulo)
	escrever(CAPITULOS[c - 1], Vector2(LARG / 2, ri.end.y + 56), 18, OURO)
	var t := trecho(c)
	if t == "":
		t = "(o trecho deste capítulo ainda não foi guardado)"
	var papel := Rect2(24, ri.end.y + 76, LARG - 48, 230)
	caixa(papel, Color8(36, 30, 26), 10, 1, Color(OURO, 0.4), true, 6)
	var alt_t := texto_quebrado("“" + t + "”", papel.position + Vector2(18, 14), papel.size.x - 36, 17, PAPEL_C, 9)
	if idioma != "pt":
		escrever(tx("(texto em português, a língua do livro)"), papel.position + Vector2(papel.size.x / 2, alt_t + 28), 12, CINZA, false)
	var k := lista.find(c)
	var b := botoes_menu()
	for lado in [["cr_ant", -1.0, k > 0], ["cr_prox", 1.0, k < lista.size() - 1]]:
		var r: Rect2 = b[lado[0]]
		var cc := r.get_center()
		var s: float = lado[1]
		var cor := Color(OURO, 0.95 if lado[2] else 0.25)
		draw_polyline(PackedVector2Array([cc + Vector2(-8 * s, -18), cc + Vector2(10 * s, 0), cc + Vector2(-8 * s, 18)]), cor, 5, true)
	escrever("%d de %d" % [k + 1, lista.size()], Vector2(LARG / 2, ALT - 132), 14, CINZA)
	escrever("Trechos do RPG do livro (kravenox-jogar/rpg)", Vector2(LARG / 2, ALT - 108), 11, Color(CINZA, 0.6), false)
	desenhar_abas()


func desenhar_ecos() -> void:
	desenhar_fundo(0.68)
	cabecalho("ECOS")
	escrever("Luzes da Essência que seguem o Kravenox. Um por vez.", Vector2(LARG / 2, 134), 14, CINZA)
	var b := botoes_menu()
	var atual := str(prog.get("eco", ""))
	for i in ECOS.size():
		var e: Dictionary = ECOS[i]
		var tem := eco_liberado(e)
		var r := Rect2(16, 150 + i * 120, LARG - 32, 110)
		caixa(r, Color(0.06, 0.05, 0.08, 0.93), 10, 2 if atual == e["id"] else 1, OURO if atual == e["id"] else Color(PEDRA_BORDA, 0.9), true, 6)
		var c := r.position + Vector2(50, 55)
		var cor: Color = e["cor"] if tem else PEDRA_CLARA
		brilho_suave(c, 44, cor, 1.0 if tem else 0.2)
		draw_circle(c + Vector2(cos(tempo * 2 + i) * 6, sin(tempo * 2 + i) * 3), 11, cor)
		draw_circle(c + Vector2(cos(tempo * 2 + i) * 6, sin(tempo * 2 + i) * 3), 5, Color(1, 1, 1, 0.9 if tem else 0.2))
		escrever_esq(e["nome"] if tem else "???", r.position + Vector2(96, 40), 17, OURO if tem else CINZA, fonte_titulo)
		escrever_esq(e["desc"] if tem else "Abra o baú do Mundo %d" % int(e["bau"]), r.position + Vector2(96, 66), 14, CINZA)
		if tem:
			botao(b["eco%d" % i], "Em uso" if atual == e["id"] else "Usar", OURO, true, atual == e["id"])
	if nivel_obra("altar") > 0:
		escrever("Altar dos Ecos: +%d%% de força" % (25 * nivel_obra("altar")), Vector2(LARG / 2, 660), 14, Color8(200, 180, 255), false)
	desenhar_abas()


# ============================================================ modos especiais (aba Modos, 9/11)
# Quatro jeitos diferentes de jogar, fora dos capítulos: Horda (defender a
# torre de multidões), Colosso (desviar de um gigante e bater cada vez mais
# forte), Refúgio (fechar-se num quarto e construir até o amanhecer) e Caçada
# (andar pela sala com o dedo; parado, o Kravenox ataca sozinho).
const MODOS := [
	{"id": "horda", "nome": "Horda", "desc": "Multidões atacam a torre. Ande com o controle virtual até elas e use Esmagar e Espinhos. Aguente 10 ondas.", "desde": 5},
	{"id": "colosso", "nome": "Colosso", "desc": "O Gigante do Vazio ataca sem parar. Arraste o Kravenox para desviar; o dano dele cresce com o tempo.", "desde": 10},
	{"id": "refugio", "nome": "Refúgio", "desc": "Corra para o quarto e feche a porta. Construa torres e conserte a porta até o amanhecer.", "desde": 15},
	{"id": "cacada", "nome": "Caçada", "desc": "Ande pela sala com o dedo; parado, o Kravenox ataca sozinho. Atravesse 10 salas.", "desde": 20},
]
const HABS := [
	{"id": "multi", "nome": "Tiro Duplo", "desc": "+1 golpe por ataque", "icone": "espinhos"},
	{"id": "cadencia", "nome": "Fúria Rápida", "desc": "ataca 25% mais rápido", "icone": "corrida"},
	{"id": "fura", "nome": "Golpe Perfurante", "desc": "cada golpe atravessa +1 monstro", "icone": "rasgo"},
	{"id": "forte", "nome": "Golpe Pesado", "desc": "+30% de dano", "icone": "garras"},
	{"id": "explode", "nome": "Estouro da Essência", "desc": "os golpes explodem ao acertar", "icone": "esmagamento"},
	{"id": "raio", "nome": "Raio em Cadeia", "desc": "a cada 3 s um raio pula entre monstros", "icone": "raio"},
	{"id": "anel", "nome": "Anel de Espinhos", "desc": "a cada 3 s solta espinhos em roda", "icone": "espinhos"},
	{"id": "muralha", "nome": "Muralha", "desc": "a torre ganha +25% de vida e é consertada", "icone": "escudo", "modo": "horda"},
	{"id": "vida", "nome": "Cristal de Vida", "desc": "+25% de vida máxima e cura tudo", "icone": "cristal", "modo": "cacada"},
	{"id": "escudo", "nome": "Escudo de Espinhos", "desc": "+40 de escudo a cada sala", "icone": "escudo", "modo": "cacada"},
]
const REF_OBRAS := [
	{"id": "espinhos", "nome": "Torre", "curta": "atira", "custo": 20},
	{"id": "raio", "nome": "Raio", "curta": "em cadeia", "custo": 35},
	{"id": "cristal", "nome": "Cristal", "curta": "conserta", "custo": 25},
	{"id": "fonte", "nome": "Fonte", "curta": "essência", "custo": 15},
]
const SALA := Rect2(24, 150, 432, 540)
const QUARTO := Rect2(90, 300, 300, 250)
const REF_SLOTS := [Vector2(150, 380), Vector2(240, 380), Vector2(330, 380), Vector2(150, 460), Vector2(240, 460), Vector2(330, 460)]
const PORTA_C := Vector2(240, 300)
var esp := {}
var tiros_m := []   # tiros dos monstros (Caçada)


func lista_modos() -> Array:
	var v := MODOS.duplicate()
	v.append({"id": "abismo", "nome": "Abismo sem Fim", "desc": "Ondas sem fim no caminho de quadros, cada vez mais fortes.", "desde": 5})
	v.append({"id": "desafio", "nome": "Desafio do Dia", "desc": "Um capítulo com regra especial, diferente a cada dia.", "desde": 6})
	if not "SUBDOMINIO" in servidor_duelo:   # só aparece quando o servidor estiver no ar
		v.insert(0, {"id": "duelo", "nome": "Duelo ao vivo", "desc": "Você contra um amigo, cada um no seu celular, a mesma horda. Precisa de internet.", "desde": 5})
	return v


func rec_modo(id: String) -> int:
	return int(prog.get("modos", {}).get(id, 0))


func texto_rec(id: String) -> String:
	var r := rec_modo(id)
	match id:
		"horda":
			return "Recorde: %d de 10 ondas" % r
		"cacada":
			return "Recorde: %d de 10 salas" % r
		"colosso":
			return "Recorde: %d de dano" % r
		"refugio":
			return "Recorde: %d:%02d de 2:30" % [r / 60, r % 60]
		"abismo":
			return "Recorde: onda %d" % int(prog.get("abismo_rec", 0))
		"desafio":
			return "Feito hoje!" if desafio_feito_hoje() else "Ainda não feito hoje"
		"duelo":
			return "Vitórias: %d" % int(prog.get("modos", {}).get("duelo_vitorias", 0))
	return ""


func nv_esp() -> int:
	return clampi(int(prog["liberado"]), 1, TOTAL_CAPITULOS)


func cresce_esp() -> float:
	var l := nv_esp()
	return 0.10 * (l - 1) - 0.035 * maxi(0, l - 40)


func dano_base_esp() -> float:
	return 14.0 * (1.0 + cresce_esp()) * mult_dano() * (1.0 + 0.3 * hb("forte"))


func hb(id: String) -> int:
	return Array(esp.get("habs", [])).count(id)


func tipos_monstro() -> Array:
	var l := nv_esp()
	var t := ["larva", "larva", "larva"]
	if l >= MONSTRO_DESDE["esfera"]:
		t += ["esfera", "esfera"]
	if l >= MONSTRO_DESDE["verme"]:
		t += ["verme", "verme"]
	if l >= MONSTRO_DESDE["sentinela"]:
		t += ["sentinela"]
	return t


func nasce(tipo: String, p: Vector2, mult_hp := 1.0, premio := 0) -> Dictionary:
	var m: Dictionary = MONSTROS[tipo]
	var chefe: bool = m.get("chefe", false)
	var c := cresce_esp()
	var vida: float = m["hp"] * (1.0 + c) * mult_hp
	if chefe:
		vida = 170.0 * (1.0 + 1.3 * c) * {"larvamae": 1.0, "semrosto": 1.4, "thornox": 1.8}[tipo] * mult_hp
	prog["vistos"][tipo] = true
	var d := {"tipo": tipo, "pos": p, "hp": vida, "hp_max": vida, "vel": float(m["vel"]),
		"dano": m["dano"] * 0.7 * (1.0 + 0.03 * (nv_esp() - 1)), "premio": premio, "t_ataque": 0.6, "traco": "",
		"filho": false, "sangra": 0.0, "sangra_dps": 0.0, "sangra_tick": 0.5, "tonto": 0.0, "flash": 0.0,
		"anim": randf() * 2.0, "chefe": chefe, "t_poder": 2.5}
	monstros.append(d)
	if chefe:
		som("thornox" if tipo == "thornox" else "chefe")
	return d


func borda(lado: String) -> Vector2:
	match lado:
		"cima":
			return Vector2(randf_range(30, LARG - 30), -30)
		"baixo":
			return Vector2(randf_range(30, LARG - 30), ALT + 30)
		"esq":
			return Vector2(-30, randf_range(140, ALT - 120))
		"dir":
			return Vector2(LARG + 30, randf_range(140, ALT - 120))
		"esq_alto":
			return Vector2(-30, randf_range(120, 280))
		_:
			return Vector2(LARG + 30, randf_range(120, 280))


func comecar_modo(id: String) -> void:
	if id == "abismo":
		comecar_abismo()
		return
	if id == "desafio":
		comecar_desafio()
		return
	tipo_partida = "especial"
	bencaos = []
	combo = 0
	furia = 0.0
	escolha = {}
	monstros = []
	tiros = []
	efeitos = []
	textos = []
	tiros_m = []
	pendentes = []
	golpe = {}
	escudo = 0.0
	essencia = 0
	k_salto = 0.0
	k_rapido = 0.0
	k_flash = 0.0
	k_dir = 1
	lento_t = 0.0
	tremor = 0.0
	msg_t = 0.0
	esp = {"id": id, "t": 0.0, "fim": "", "habs": [], "onda": 0, "fila": [], "t_spawn": 1.5, "t_tiro": 0.6,
		"t_extra": 3.0, "pausa": 1.0, "premio": 0, "pontos": 0, "limpa": true, "acc": 0.0}
	hp_max = calc_hp_max()
	hp = hp_max
	tela = "especial"
	t_tela = 0.0
	if id == "duelo":
		var rng := RandomNumberGenerator.new()
		rng.seed = int(duelo.get("semente", 1))
		esp["rng"] = rng
		esp["t_envio"] = 0.0
		esp["mortes_base"] = mortes
	match id:
		"horda", "duelo":
			CENTRO = Vector2(240, 470)
			torre_max = 420.0 * (1.0 + cresce_esp()) * (1.0 + 0.25 * nivel_obra("vigia"))
			torre_hp = torre_max
			k_vis = CENTRO + Vector2(0, 74)
			esp["cd"] = {"esmagar": 0.0, "espinhos": 0.0}
			esp["alvo"] = null
			aviso("Arraste o Kravenox até a horda!" if id == "horda" else "Duelo! Segure a torre mais tempo que o outro", 3.0)
		"cacada":
			esp["sala"] = 0
			proxima_sala()
		"colosso":
			k_vis = Vector2(240, 640)
			esp["alvo_x"] = 240.0
			esp["dano"] = 0.0
			esp["ataques"] = []
			esp["t_ataque"] = 2.5
			var vida := dano_base_esp() * 1000.0
			esp["boss"] = {"hp": vida, "hp_max": vida, "flash": 0.0}
			aviso("Arraste para os lados para desviar!", 3.0)
		"refugio":
			k_vis = Vector2(240, 780)
			essencia = 40
			esp["slots"] = [null, null, null, null, null, null]
			esp["sel"] = "espinhos"
			esp["porta_max"] = 260.0 * (1.0 + cresce_esp())
			esp["porta"] = esp["porta_max"]
			esp["porta_nv"] = 1
			esp["quebrada"] = false
			esp["t_garra"] = 0.8
			esp["t_spawn"] = 3.0
			aviso("Corra para o quarto! Escolha uma obra e toque num lugar", 4.0)


func abrir_habs() -> void:
	var id: String = esp["id"]
	var ops := HABS.filter(func(h): return (not h.has("modo") or h["modo"] == id) and hb(h["id"]) < 3)
	ops.shuffle()
	escolha = {"tipo": "hab", "titulo": "ESCOLHA UM PODER", "texto": "", "opcoes": ops.slice(0, 3)}


func aplicar_hab(id: String) -> void:
	esp["habs"].append(id)
	match id:
		"muralha":
			torre_max *= 1.25
			torre_hp = minf(torre_max, torre_hp + torre_max * 0.5)
		"vida":
			hp_max = roundf(calc_hp_max() * (1.0 + 0.25 * hb("vida")))
			hp = hp_max
		"escudo":
			escudo += 40.0
	for h in HABS:
		if h["id"] == id:
			aviso(h["nome"], 2.0)


const GOLPES_HORDA := {"esmagar": ["Esmagar", 6.0], "espinhos": ["Espinhos", 5.0]}


func botao_golpe(g: String) -> Rect2:
	return Rect2(16, ALT - 94, 150, 82) if g == "esmagar" else Rect2(LARG - 166, ALT - 94, 150, 82)


func usar_golpe(g: String) -> void:
	if esp["cd"][g] > 0:
		return
	esp["cd"][g] = GOLPES_HORDA[g][1]
	var k := k_vis
	if g == "esmagar":
		som("esmagamento")
		tremer(0.4, 60)
		anel(k + Vector2(0, 18), 20, 170, 0.4, Color8(200, 150, 90))
		golpe = {"tonto": true}
		for m in monstros:
			if m["pos"].distance_to(k) < 170:
				ferir(m, dano_base_esp() * 4.0)
		golpe = {}
	else:
		som("corte")
		for j in 18:
			tiros.append({"p": k, "v": Vector2.from_angle(j * TAU / 18) * 360, "dano": dano_base_esp() * 1.6, "fura": 2,
				"vida": 1.1, "cor": Color8(30, 30, 40), "r": 6.0, "acertos": [], "golpe": {"sangra": true}})


func cadencia_esp() -> float:
	return 0.5 / (1.0 + 0.25 * hb("cadencia"))


# O Kravenox ataca os monstros mais perto (um golpe por alvo; Tiro Duplo = mais golpes).
func disparar(de: Vector2) -> void:
	var vivos := monstros.filter(func(m): return m["hp"] > 0)
	if vivos.is_empty():
		return
	vivos.sort_custom(func(a, b): return a["pos"].distance_to(de) < b["pos"].distance_to(de))
	var n := 1 + hb("multi")
	som("corte")
	for i in n:
		var alvo: Dictionary = vivos[i % vivos.size()]
		var dir: Vector2 = (alvo["pos"] - de).normalized()
		if i >= vivos.size():
			dir = dir.rotated(0.22 * (i - vivos.size() + 1) * (1 if i % 2 == 0 else -1))
		k_dir = 1 if dir.x >= 0 else -1
		tiros.append({"p": de, "v": dir * 480, "dano": dano_base_esp(), "fura": hb("fura"), "vida": 1.6,
			"cor": Color8(230, 40, 70), "r": 7.0, "acertos": [], "golpe": {}, "explode": hb("explode") > 0})


func extras_esp(de: Vector2, dt: float) -> void:
	esp["t_extra"] -= dt
	if esp["t_extra"] > 0:
		return
	esp["t_extra"] = 3.0
	if hb("raio") > 0 and not monstros.is_empty():
		som("raio")
		var alvos := monstros.duplicate()
		alvos.sort_custom(func(x, y): return x["pos"].distance_to(de) < y["pos"].distance_to(de))
		var a := de
		for m in alvos.slice(0, 3 + 2 * hb("raio")):
			efeitos.append({"t": "raio", "a": a, "b": m["pos"], "vida": 0.2})
			ferir(m, dano_base_esp() * 1.2)
			a = m["pos"]
	if hb("anel") > 0:
		var n := 8 + 4 * hb("anel")
		for j in n:
			tiros.append({"p": de, "v": Vector2.from_angle(j * TAU / n) * 330, "dano": dano_base_esp() * 0.8, "fura": 0,
				"vida": 1.0, "cor": Color8(30, 30, 40), "r": 5.0, "acertos": [], "golpe": {}})


func atualizar_tiros(dt: float) -> void:
	for t in tiros:
		t["p"] += t["v"] * dt
		t["vida"] -= dt
		for m in monstros:
			if m["hp"] <= 0 or t["acertos"].has(m):
				continue
			var raio := 50.0 if m["chefe"] else 18.0
			if m["pos"].distance_to(t["p"]) < raio + t["r"]:
				golpe = t.get("golpe", {})
				ferir(m, t["dano"])
				golpe = {}
				t["acertos"].append(m)
				if t.get("explode", false):
					anel(t["p"], 8, 64, 0.25, Color8(255, 150, 80))
					for o in monstros:
						if o != m and o["hp"] > 0 and o["pos"].distance_to(t["p"]) < 64:
							ferir(o, t["dano"] * 0.5, false)
				if t["fura"] <= 0:
					t["vida"] = 0.0
					break
				t["fura"] -= 1
	tiros = tiros.filter(func(t): return t["vida"] > 0)


func atualizar_tiros_m(dt: float) -> void:
	for t in tiros_m:
		t["p"] += t["v"] * dt
		t["vida"] -= dt
		if t["p"].distance_to(k_vis + Vector2(0, -6)) < 22:
			ferir_kx(t["dano"])
			t["vida"] = 0.0
	tiros_m = tiros_m.filter(func(t): return t["vida"] > 0)


func ferir_kx(dano: float) -> void:
	dano *= mult_dano_recebido()
	var antes := dano
	if escudo > 0:
		var tira := minf(escudo, dano)
		escudo -= tira
		dano -= tira
		escudo_flash = 0.2
	hp -= dano
	k_flash = 0.15
	som("dano")
	texto_voa(k_vis + Vector2(0, -50), "-%d" % int(antes), AZUL if dano <= 0 else VERMELHO)
	if antes >= 15:
		tremer(0.25, 40)


# O Kravenox anda com o dedo: acelera e freia aos poucos, mexe as pernas no
# ritmo da velocidade e solta poeira a cada passo. Na Horda a torre é sólida.
func andar_kx(desejada: Vector2, dt: float) -> void:
	var v: Vector2 = esp.get("vel_k", Vector2.ZERO)
	# responde quase na hora (~0,1 s) e para rápido ao soltar
	v = v.lerp(desejada, minf(1.0, dt * (24.0 if desejada.length() > v.length() else 28.0)))
	esp["vel_k"] = v
	var rapidez := v.length()
	if rapidez < 8.0:
		return
	var novo := k_vis + v * dt
	if esp["id"] == "horda":
		# a torre é sólida: o Kravenox desliza pela borda dela
		var c := CENTRO + Vector2(0, 8)
		var raio := 46.0
		var d := novo - c
		d.y *= 1.6   # a base da torre é mais larga que funda
		if d.length() < raio:
			var fora := d.normalized() if d.length() > 0.01 else Vector2.DOWN
			novo = c + Vector2(fora.x * raio, fora.y * raio / 1.6)
			esp["vel_k"] = v.slide(fora.normalized()) * 0.9
	k_vis = novo
	k_andando = true
	k_anim += dt * rapidez / 20.0
	if absf(v.x) > 6:
		k_dir = 1 if v.x > 0 else -1
	esp["t_poeira"] = float(esp.get("t_poeira", 0.0)) - dt
	if esp["t_poeira"] <= 0 and rapidez > 80:
		esp["t_poeira"] = 0.22
		for j in 3:
			efeitos.append({"t": "poeira", "p": k_vis + Vector2(randf_range(-10, 10), 28), "v": Vector2(-v.x * 0.15 + randf_range(-20, 20), randf_range(-24, -8)), "vida": 0.45})


# Anda até o alvo; devolve true quando está perto e pode atacar.
func mover_monstro(m: Dictionary, alvo: Vector2, dt: float, alcance := 34.0) -> bool:
	m["anim"] += dt
	m["flash"] -= dt
	if m["sangra"] > 0:
		m["sangra"] -= dt
		m["sangra_tick"] -= dt
		if m["sangra_tick"] <= 0:
			m["sangra_tick"] = 0.5
			ferir(m, m["sangra_dps"] * 0.5, false)
	if m["tonto"] > 0:
		m["tonto"] -= dt
		return false
	var para: Vector2 = alvo - m["pos"]
	var alc := alcance + (36.0 if m["chefe"] else 0.0)
	if para.length() > alc:
		m["pos"] += para.normalized() * m["vel"] * dt
		return false
	m["t_ataque"] -= dt
	if m["t_ataque"] <= 0:
		m["t_ataque"] = 1.0
		return true
	return false


func envelhecer_efeitos(dt: float) -> void:
	var vivos := []
	for e in efeitos:
		e["vida"] -= dt
		if e["t"] == "part" or e["t"] == "poeira":
			e["p"] += e["v"] * dt
		if e["vida"] > 0:
			vivos.append(e)
	efeitos = vivos
	for t in textos:
		t["p"].y -= 40 * dt
		t["vida"] -= dt
	textos = textos.filter(func(t): return t["vida"] > 0)


func atualizar_esp(dt: float) -> void:
	if lento_t > 0:
		lento_t -= dt
		dt *= 0.3
	tempo += dt
	msg_t -= dt
	envelhecer_efeitos(dt)
	k_flash = maxf(0.0, k_flash - dt)
	escudo_flash = maxf(0.0, escudo_flash - dt)
	torre_flash = maxf(0.0, torre_flash - dt)
	if esp.get("fim", "") != "" or not escolha.is_empty():
		k_andando = false
		return
	esp["t"] += dt
	k_andando = false
	match esp["id"]:
		"horda", "duelo":
			atualizar_horda(dt)
		"cacada":
			atualizar_cacada(dt)
		"colosso":
			atualizar_colosso(dt)
		"refugio":
			atualizar_refugio(dt)
	atualizar_tiros(dt)
	atualizar_tiros_m(dt)
	monstros = monstros.filter(func(m): return m["hp"] > 0)
	pendentes.clear()
	atualizar_eco(dt)
	if hp <= 0 and esp["fim"] == "":
		hp = 0.0
		terminar_modo(false)


# ------------------------------------------------------------ Horda
func atualizar_horda(dt: float) -> void:
	var w: int = esp["onda"]
	if esp["fila"].is_empty() and monstros.all(func(m): return m.get("extra", false)):
		if not esp["limpa"]:
			esp["limpa"] = true
			esp["pontos"] = w
			var e_duelo: bool = esp["id"] == "duelo"
			if w >= 10 and not e_duelo:
				terminar_modo(true)
				return
			torre_hp = minf(torre_max, torre_hp + torre_max * 0.15)
			if e_duelo:
				# no duelo o poder vem sozinho (o mesmo para os dois, pela semente)
				if w > 0 and w % 2 == 0:
					var ops := HABS.filter(func(h): return (not h.has("modo") or h["modo"] == "horda") and hb(h["id"]) < 3)
					if not ops.is_empty():
						aplicar_hab(ops[esp["rng"].randi() % ops.size()]["id"])
			else:
				abrir_habs()
			esp["pausa"] = 1.2
			return
		esp["pausa"] -= dt
		if esp["pausa"] <= 0:
			w += 1
			esp["onda"] = w
			esp["limpa"] = false
			var lados: Array = [["cima"], ["baixo"], ["esq", "dir"], ["cima", "baixo"], ["cima", "baixo", "esq", "dir"]][(w - 1) % 5]
			esp["lados"] = lados
			var tipos := tipos_monstro()
			var fila := []
			if esp["id"] == "duelo":
				var rng: RandomNumberGenerator = esp["rng"]
				lados = [["cima"], ["baixo"], ["esq", "dir"], ["cima", "baixo"], ["cima", "baixo", "esq", "dir"]][rng.randi() % 5]
				esp["lados"] = lados
				for _i in mini(90, 16 + 7 * w):
					fila.append(tipos[rng.randi() % tipos.size()])
				if w % 5 == 0:
					fila.insert(8, ["larvamae", "semrosto", "thornox"][(w / 5 - 1) % 3])
			else:
				for _i in 18 + 8 * w:
					fila.append(tipos.pick_random())
				if w == 5:
					fila.insert(10, "larvamae")
				if w == 10:
					fila.insert(10, "thornox")
			esp["fila"] = fila
			esp["t_spawn"] = 0.3
			var nomes := {"cima": "de cima", "baixo": "de baixo", "esq": "da esquerda", "dir": "da direita"}
			var de_onde: String = (" e " if idioma == "pt" else " and ").join(lados.map(func(x): return tx(nomes[x])))
			if esp["id"] == "duelo":
				aviso(tx("Onda %d · vem %s") % [w, de_onde], 2.5)
			else:
				aviso(tx("Onda %d de 10 · vem %s") % [w, de_onde], 2.5)
		return
	esp["t_spawn"] -= dt
	if esp["t_spawn"] <= 0 and not esp["fila"].is_empty():
		esp["t_spawn"] = maxf(0.08, 0.34 - w * 0.022)
		var tipo: String = esp["fila"].pop_front()
		if esp["id"] == "duelo":
			# no duelo a horda cresce sem parar: alguém cai em poucos minutos
			var md := nasce(tipo, borda(esp["lados"].pick_random()), (1.0 if not MONSTROS[tipo].get("chefe", false) else 1.2) * 0.8 * pow(1.16, w - 1))
			md["dano"] *= 1.0 + 0.12 * (w - 1)
		else:
			nasce(tipo, borda(esp["lados"].pick_random()), (1.0 if not MONSTROS[tipo].get("chefe", false) else 1.2) * (1.0 + 0.12 * w))
	for m in monstros:
		if mover_monstro(m, CENTRO + Vector2(0, -10), dt, 46.0):
			torre_hp -= m["dano"]
			torre_flash = 0.15
			som("esmagamento")
			texto_voa(CENTRO + Vector2(0, -70), "-%d" % int(m["dano"]), VERMELHO)
	# o Kravenox vai até onde o dedo está
	# controle virtual: o dedo arrasta a partir de onde tocou (como na Caçada)
	var desejada := Vector2.ZERO
	if esp.get("joy_ini") != null:
		var mov: Vector2 = ((esp["joy"] - esp["joy_ini"]) / 50.0).limit_length(1.0)
		if mov.length() > 0.15:
			desejada = mov * 195.0 * (1.0 + 0.06 * nivel_melhoria("passo"))
	elif esp.get("alvo") != null:
		# (teste automático) ir até um ponto
		var d: Vector2 = esp["alvo"] - Vector2(0, 40) - k_vis
		desejada = d.normalized() * 230.0 * clampf(d.length() / 60.0, 0.0, 1.0)
	andar_kx(desejada, dt)
	k_vis.x = clampf(k_vis.x, 20, LARG - 20)
	k_vis.y = clampf(k_vis.y, 150, ALT - 140)
	for g in esp["cd"]:
		esp["cd"][g] = maxf(0.0, esp["cd"][g] - dt)
	var de := k_vis + Vector2(0, -22)
	esp["t_tiro"] -= dt
	if esp["t_tiro"] <= 0:
		# só alcança quem está perto: é preciso levar o Kravenox até a horda
		var perto = mais_perto(de)
		if perto != null and perto["pos"].distance_to(de) < 190:
			esp["t_tiro"] = cadencia_esp()
			disparar(de)
	extras_esp(de, dt)
	if esp["id"] == "duelo":
		# a cada 12 espantados, 2 monstros vão para o outro; e conta como estou
		if mortes - int(esp["mortes_base"]) >= 12:
			esp["mortes_base"] = int(esp["mortes_base"]) + 12
			enviar_duelo({"t": "ataque", "n": 2})
			texto_voa(k_vis + Vector2(0, -70), tx("Ataque enviado!"), Color8(255, 150, 140), 18)
		esp["t_envio"] -= dt
		if esp["t_envio"] <= 0:
			esp["t_envio"] = 0.5
			enviar_duelo({"t": "estado", "torre": int(100 * torre_hp / maxf(1.0, torre_max)), "onda": w, "mortes": mortes})
	if torre_hp <= 0:
		torre_hp = 0.0
		esp["pontos"] = maxi(0, w - 1)
		if esp["id"] == "duelo":
			enviar_duelo({"t": "estado", "torre": 0, "onda": w, "mortes": mortes})
			enviar_duelo({"t": "caiu", "tempo": esp["t"]})
			esp["motivo"] = "eu_caiu"
		terminar_modo(false)


# ------------------------------------------------------------ Caçada
func proxima_sala() -> void:
	esp["sala"] = int(esp["sala"]) + 1
	esp["porta"] = false
	esp["limpa"] = false
	esp["joy_ini"] = null
	k_vis = Vector2(240, 640)
	tiros_m.clear()
	tiros.clear()
	if hb("escudo") > 0:
		escudo += 40.0 * hb("escudo")
	var s: int = esp["sala"]
	var tipos := tipos_monstro()
	for _i in 4 + s:
		var p := Vector2(randf_range(60, 420), randf_range(190, 470))
		var mc := nasce(tipos.pick_random(), p, 2.0 * (1.0 + 0.18 * s))
		mc["dano"] *= 1.5
		anel(p, 6, 34, 0.4, ROXO)
	if s == 5:
		nasce("larvamae", Vector2(240, 250), 1.4)
	if s == 10:
		nasce("thornox", Vector2(240, 250), 1.6)
	esp["t_tiro"] = 0.8
	aviso("Sala %d de 10" % s, 2.0)


func atualizar_cacada(dt: float) -> void:
	var mov := Vector2.ZERO
	if esp.get("joy_ini") != null:
		mov = ((esp["joy"] - esp["joy_ini"]) / 50.0).limit_length(1.0)
	andar_kx(mov * 195.0 * (1.0 + 0.06 * nivel_melhoria("passo")) if mov.length() > 0.15 else Vector2.ZERO, dt)
	k_vis.x = clampf(k_vis.x, SALA.position.x + 22, SALA.end.x - 22)
	k_vis.y = clampf(k_vis.y, SALA.position.y + 26, SALA.end.y - 24)
	if mov.length() > 0.15:
		esp["t_tiro"] = minf(esp["t_tiro"], 0.12)   # ataca logo que parar
	else:
		esp["t_tiro"] -= dt
		if esp["t_tiro"] <= 0 and not monstros.is_empty():
			esp["t_tiro"] = cadencia_esp() * 1.1
			disparar(k_vis + Vector2(0, -20))
		extras_esp(k_vis, dt)
	for m in monstros:
		if m["tipo"] == "esfera":
			# a sentinela esférica fica de longe e atira
			m["anim"] += dt
			m["flash"] -= dt
			if m["tonto"] > 0:
				m["tonto"] -= dt
				continue
			var d: Vector2 = k_vis - m["pos"]
			if d.length() > 230:
				m["pos"] += d.normalized() * m["vel"] * dt
			elif d.length() < 150:
				m["pos"] -= d.normalized() * m["vel"] * 0.7 * dt
			m["t_poder"] -= dt
			if m["t_poder"] <= 0:
				m["t_poder"] = 1.8
				tiros_m.append({"p": m["pos"], "v": d.normalized() * 210, "dano": m["dano"], "vida": 3.0})
		elif m["chefe"]:
			if mover_monstro(m, k_vis, dt):
				ferir_kx(m["dano"])
			m["t_poder"] -= dt
			if m["t_poder"] <= 0:
				m["t_poder"] = 3.0
				for j in 10:
					tiros_m.append({"p": m["pos"], "v": Vector2.from_angle(j * TAU / 10 + tempo) * 170, "dano": m["dano"] * 0.6, "vida": 3.5})
		elif mover_monstro(m, k_vis, dt):
			ferir_kx(m["dano"])
		m["pos"].x = clampf(m["pos"].x, SALA.position.x + 16, SALA.end.x - 16)
		m["pos"].y = clampf(m["pos"].y, SALA.position.y + 20, SALA.end.y - 16)
	if monstros.is_empty() and not esp["limpa"]:
		esp["limpa"] = true
		esp["pontos"] = esp["sala"]
		if esp["sala"] >= 10:
			terminar_modo(true)
			return
		tiros_m.clear()
		abrir_habs()
		esp["porta"] = true
		aviso("A porta abriu! Ande até ela", 3.0)
	if esp["porta"] and k_vis.y < SALA.position.y + 56 and absf(k_vis.x - 240) < 50:
		proxima_sala()


# ------------------------------------------------------------ Colosso
func atualizar_colosso(dt: float) -> void:
	var t: float = esp["t"]
	if t >= 90.0:
		terminar_modo(true)
		return
	var dx: float = esp["alvo_x"] - k_vis.x
	if absf(dx) > 3:
		k_vis.x += signf(dx) * minf(absf(dx), 470.0 * dt)
		k_andando = true
		k_anim += dt * 10
		k_dir = 1 if dx > 0 else -1
	k_vis.x = clampf(k_vis.x, 40, LARG - 40)
	var boss: Dictionary = esp["boss"]
	boss["flash"] = maxf(0.0, boss["flash"] - dt)
	esp["t_tiro"] -= dt
	if esp["t_tiro"] <= 0:
		esp["t_tiro"] = 0.45
		var mult := 1.0 + t / 15.0
		var crit := randf() < chance_critico()
		var d := dano_base_esp() * mult * (2.0 if crit else 1.0)
		boss["hp"] -= d
		boss["flash"] = 0.06
		esp["dano"] += d
		var alvo := Vector2(240 + randf_range(-60, 60), randf_range(180, 330))
		efeitos.append({"t": "raio", "a": k_vis + Vector2(0, -24), "b": alvo, "vida": 0.15})
		texto_voa(alvo, ("%d!" if crit else "%d") % int(d), OURO if crit else BRANCO, 26 if crit else 18)
		som("corte")
		if boss["hp"] <= 0:
			esp["matou"] = true
			tremer(1.0, 300)
			terminar_modo(true)
			return
	esp["t_ataque"] -= dt
	if esp["t_ataque"] <= 0:
		esp["t_ataque"] = maxf(0.85, 2.3 - t * 0.016)
		var tipos := ["pisada", "faixa", "onda", "chuva"] if t > 20 else ["pisada", "faixa"]
		match tipos.pick_random():
			"pisada":
				esp["ataques"].append({"tipo": "circ", "x": k_vis.x, "r": 75.0, "t": 1.1, "max": 1.1})
			"faixa":
				esp["ataques"].append({"tipo": "col", "x": clampf(k_vis.x + randf_range(-40, 40), 50, LARG - 50), "w": 110.0, "t": 1.0, "max": 1.0})
			"onda":
				esp["ataques"].append({"tipo": "lin", "x": randf_range(70, LARG - 70), "w": 120.0, "t": 1.4, "max": 1.4})
			"chuva":
				for _i in 3:
					esp["ataques"].append({"tipo": "circ", "x": randf_range(40, LARG - 40), "r": 55.0, "t": randf_range(0.9, 1.4), "max": 1.4})
	for a in esp["ataques"]:
		a["t"] -= dt
		if a["t"] <= 0 and not a.get("feito", false):
			a["feito"] = true
			var pega := false
			match a["tipo"]:
				"circ":
					pega = absf(k_vis.x - a["x"]) < a["r"]
				"col":
					pega = absf(k_vis.x - a["x"]) < a["w"] / 2
				"lin":
					pega = absf(k_vis.x - a["x"]) > a["w"] / 2
			tremer(0.3, 0)
			som("esmagamento")
			if pega:
				ferir_kx(hp_max * (0.25 if t < 60 else 0.34))
	esp["ataques"] = esp["ataques"].filter(func(a): return a["t"] > -0.35)


# ------------------------------------------------------------ Refúgio
func custo_ref(id: String, nv: int) -> int:
	for o in REF_OBRAS:
		if o["id"] == id:
			return int(o["custo"]) * (nv + 1)
	return 99


func custo_porta() -> int:
	return 30 * int(esp["porta_nv"])


func atualizar_refugio(dt: float) -> void:
	var t: float = esp["t"]
	if t >= 150.0:
		esp["pontos"] = 150
		terminar_modo(true)
		return
	esp["pontos"] = int(t)
	var casa := Vector2(240, 522)
	var d := casa - k_vis
	if d.length() > 3:
		k_vis += d.normalized() * minf(d.length(), 300.0 * dt)
		k_andando = true
		k_anim += dt * 10
	# renda: 2 por segundo + as fontes
	var fontes := 0
	for s in esp["slots"]:
		if s != null and s["id"] == "fonte":
			fontes += int(s["nv"])
	esp["acc"] += dt * (2.0 + 1.5 * fontes)
	while esp["acc"] >= 1.0:
		esp["acc"] -= 1.0
		essencia += 1
	# monstros chegam por cima e pelos lados, até a porta
	esp["t_spawn"] -= dt
	if esp["t_spawn"] <= 0:
		esp["t_spawn"] = maxf(0.3, 1.5 - t * 0.0095)
		nasce(tipos_monstro().pick_random(), borda(["cima", "cima", "esq_alto", "dir_alto"].pick_random()), 1.4 * (1.0 + t / 40.0), 1)
	if t >= 75 and not esp.get("chefe1", false):
		esp["chefe1"] = true
		nasce("larvamae", borda("cima"), 1.4, 10)
		aviso("A Larva-Mãe vem para a porta!", 2.5)
	if t >= 130 and not esp.get("chefe2", false):
		esp["chefe2"] = true
		nasce("semrosto", borda("cima"), 1.3, 15)
		aviso("A Sentinela sem Rosto!", 2.5)
	var quebrada: bool = esp["quebrada"]
	for m in monstros:
		if not quebrada:
			if mover_monstro(m, PORTA_C + Vector2(0, -16), dt, 30.0):
				esp["porta"] -= m["dano"]
				torre_flash = 0.15
				som("esmagamento")
				texto_voa(PORTA_C + Vector2(0, -30), "-%d" % int(m["dano"]), VERMELHO)
		else:
			# a porta caiu: entram pela porta e vão atrás do Kravenox
			var alvo := k_vis if m["pos"].y > PORTA_C.y + 10 else PORTA_C + Vector2(0, 20)
			if mover_monstro(m, alvo, dt) and alvo == k_vis:
				ferir_kx(m["dano"])
	if not quebrada and esp["porta"] <= 0:
		esp["porta"] = 0.0
		esp["quebrada"] = true
		tremer(0.6, 150)
		aviso("A porta caiu! Conserte com Cristais", 3.0)
	elif quebrada and esp["porta"] >= esp["porta_max"] * 0.5:
		esp["quebrada"] = false
		aviso("A porta foi consertada!", 2.0)
	# o Kravenox se defende quando eles entram
	esp["t_garra"] -= dt
	if esp["t_garra"] <= 0:
		esp["t_garra"] = 0.8
		var perto := false
		for m in monstros:
			if m["pos"].distance_to(k_vis) < 100:
				perto = true
				ferir(m, dano_base_esp() * 1.2)
		if perto:
			efeitos.append({"t": "garra", "p": k_vis, "r": 100.0, "vida": 0.3})
			som("corte")
	# as obras
	for i in REF_SLOTS.size():
		var s = esp["slots"][i]
		if s == null:
			continue
		s["t"] -= dt
		if s["t"] > 0:
			continue
		var pos: Vector2 = REF_SLOTS[i]
		var nv: int = s["nv"]
		match s["id"]:
			"espinhos":
				s["t"] = 1.0 / (1.0 + 0.15 * (nv - 1))
				var alvo = mais_perto(pos)
				if alvo != null and alvo["pos"].distance_to(pos) < 330:
					tiros.append({"p": pos, "v": (alvo["pos"] - pos).normalized() * 460, "dano": dano_base_esp() * 0.7 * (1.0 + 0.6 * (nv - 1)),
						"fura": 0, "vida": 1.2, "cor": Color8(230, 40, 70), "r": 6.0, "acertos": [], "golpe": {}})
			"raio":
				s["t"] = 2.2
				var alvos := monstros.filter(func(m): return m["pos"].distance_to(pos) < 360)
				alvos.sort_custom(func(x, y): return x["pos"].distance_to(pos) < y["pos"].distance_to(pos))
				var a := pos
				for m in alvos.slice(0, 2 + nv):
					efeitos.append({"t": "raio", "a": a, "b": m["pos"], "vida": 0.2})
					ferir(m, dano_base_esp() * 0.9 * (1.0 + 0.5 * (nv - 1)))
					a = m["pos"]
				if not alvos.is_empty():
					som("raio")
			"cristal":
				s["t"] = 1.0
				if esp["porta"] < esp["porta_max"]:
					esp["porta"] = minf(esp["porta_max"], esp["porta"] + 4.0 * nv)
			"fonte":
				s["t"] = 99.0


func clique_refugio(p: Vector2) -> void:
	for i in 5:
		if Rect2(8 + i * 93, ALT - 92, 89, 84).has_point(p):
			if i < 4:
				esp["sel"] = REF_OBRAS[i]["id"]
			else:
				var c := custo_porta()
				if essencia >= c:
					essencia -= c
					esp["porta_nv"] += 1
					esp["porta_max"] *= 1.5
					esp["porta"] = esp["porta_max"]
					esp["quebrada"] = false
					som("nivel")
					aviso("Porta reforçada!", 2.0)
				else:
					aviso("Essência insuficiente")
			return
	for i in REF_SLOTS.size():
		if p.distance_to(REF_SLOTS[i]) < 38:
			var s = esp["slots"][i]
			if s == null:
				var c := custo_ref(esp["sel"], 0)
				if essencia >= c:
					essencia -= c
					esp["slots"][i] = {"id": esp["sel"], "nv": 1, "t": 0.3}
					som("gema")
				else:
					aviso("Essência insuficiente")
			elif int(s["nv"]) < NIVEL_MAX:
				var c := custo_ref(s["id"], int(s["nv"]))
				if essencia >= c:
					essencia -= c
					s["nv"] += 1
					som("nivel")
					aviso("%s nível %d" % [ITENS[s["id"]]["nome"], s["nv"]])
				else:
					aviso("Melhorar custa %d" % c)
			return


# ------------------------------------------------------------ fim, toque e desenho
func terminar_modo(venceu: bool) -> void:
	if esp["fim"] != "":
		return
	esp["fim"] = "venceu" if venceu else "perdeu"
	var id: String = esp["id"]
	var pontos: int = esp["pontos"]
	if id == "duelo":
		pontos = int(esp["onda"])
		var md0: Dictionary = prog.get("modos", {})
		if venceu:
			md0["duelo_vitorias"] = int(md0.get("duelo_vitorias", 0)) + 1
			enviar_recorde("duelo", 1)
		prog["modos"] = md0
		esp["premio"] = (8 if venceu else 3) + mundo_de(nv_esp()) / 3
		esp["pontos"] = pontos
		esp["recorde"] = false
		prog["fragmentos"] = int(prog["fragmentos"]) + int(esp["premio"])
		duelo["fase"] = "fim"
		som("nivel" if venceu else "dano")
		salvar()
		return
	if id == "colosso":
		pontos = int(esp["dano"])
		enviar_recorde("colosso", pontos)
		esp["golpes_ordem"] = 0
		if str(prog.get("ordem", "")) != "":
			esp["golpes_ordem"] = golpes_colosso(esp["dano"])
			enviar_online({"tipo": "ordem", "codigo": prog["ordem"], "golpes": esp["golpes_ordem"]})
	if venceu and id in ["horda", "cacada"]:
		pontos = 10
	var rec := rec_modo(id)
	esp["recorde"] = pontos > rec
	var md: Dictionary = prog.get("modos", {})
	md[id] = maxi(rec, pontos)
	prog["modos"] = md
	var premio := 0
	match id:
		"horda", "cacada":
			premio = pontos + (6 if venceu else 0)
		"colosso":
			premio = int(esp["dano"] / (14.0 * (1.0 + cresce_esp()) * mult_dano()) / 100.0) + (8 if esp.get("matou", false) else 0)
		"refugio":
			premio = int(esp["t"] / 20.0) + (6 if venceu else 0)
	premio = int(premio * (1.0 + mundo_de(nv_esp()) / 12.0))
	esp["premio"] = premio
	esp["pontos"] = pontos
	prog["fragmentos"] = int(prog["fragmentos"]) + premio
	contar_total("modos")
	som("nivel" if venceu else "dano")
	salvar()


func entrada_esp(ev: InputEvent) -> void:
	if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
		var p: Vector2 = make_input_local(ev).position
		if ev.pressed:
			toque_esp(p)
		else:
			esp["joy_ini"] = null
			esp["alvo"] = null
	elif ev is InputEventMouseMotion and (ev.button_mask & MOUSE_BUTTON_MASK_LEFT):
		var p: Vector2 = make_input_local(ev).position
		if esp.get("joy_ini") != null:
			esp["joy"] = p
		if esp.get("id", "") == "colosso":
			esp["alvo_x"] = p.x


func toque_esp(p: Vector2) -> void:
	var b := botoes()
	if esp["fim"] != "":
		if esp["id"] == "duelo":
			if b["denovo"].has_point(p):
				if ws != null:
					duelo["fase"] = "dois" if Array(duelo.get("nomes", [])).size() == 2 else "esperando"
				else:
					duelo = {}
				ir_para("duelo")
			elif b["mundos"].has_point(p):
				sair_duelo()
				ir_para("modos")
			return
		if b["denovo"].has_point(p):
			comecar_modo(esp["id"])
		elif b["mundos"].has_point(p):
			ir_para("modos")
		return
	if not escolha.is_empty():
		for i in escolha["opcoes"].size():
			if b["esc%d" % i].has_point(p):
				escolher(i)
				return
		return
	if b["voltar"].has_point(p):
		if esp["id"] == "duelo":
			# sair no meio do duelo é desistir
			enviar_duelo({"t": "caiu", "tempo": esp["t"]})
			esp["motivo"] = "eu_caiu"
			terminar_modo(false)
			return
		ir_para("modos")
		return
	match esp["id"]:
		"horda", "duelo":
			for g in GOLPES_HORDA:
				if botao_golpe(g).has_point(p):
					usar_golpe(g)
					return
			esp["joy_ini"] = p
			esp["joy"] = p
		"cacada":
			esp["joy_ini"] = p
			esp["joy"] = p
		"colosso":
			esp["alvo_x"] = p.x
		"refugio":
			clique_refugio(p)


func nome_modo(id: String) -> String:
	if id == "duelo":
		return "Duelo ao vivo"
	for m in lista_modos():
		if m["id"] == id:
			return m["nome"]
	return id


func desenhar_esp() -> void:
	desenhar_fundo(0.45)
	var id: String = esp["id"]
	match id:
		"cacada":
			desenhar_sala()
		"refugio":
			desenhar_quarto()
		"colosso":
			desenhar_colosso()
	var itens := []
	for m in monstros:
		itens.append([m["pos"].y, m])
	itens.append([k_vis.y, null])
	if id == "horda" or id == "duelo":
		itens.append([CENTRO.y + 20, "torre"])
	itens.sort_custom(func(a, b): return a[0] < b[0])
	for it in itens:
		if it[1] == null:
			desenhar_kravenox(k_vis)
		elif it[1] is String:
			desenhar_torre()
		else:
			desenhar_monstro(it[1], k_vis)
	for t in tiros_m:
		brilho_suave(t["p"], 16, ROXO, 1.2)
		draw_circle(t["p"], 6, Color8(200, 120, 255))
		draw_circle(t["p"], 3, Color(1, 1, 1, 0.9))
	desenhar_efeitos()
	desenhar_topo_esp()
	if id == "refugio":
		desenhar_painel_refugio()
	if id == "duelo" and not duelo.get("op", {}).is_empty():
		var op: Dictionary = duelo["op"]
		var r := Rect2(16, 132, LARG - 32, 30)
		caixa(r, Color(0.08, 0.03, 0.05, 0.9), 8, 1, Color(VERMELHO, 0.7))
		var fr := clampf(float(op.get("torre", 0)) / 100.0, 0, 1)
		degrade(Rect2(r.position + Vector2(3, 3), Vector2((r.size.x - 6) * fr, r.size.y - 6)), Color8(150, 60, 70), Color8(80, 20, 30))
		escrever(tx("%s · torre %d%% · onda %d") % [nome_op(), int(op.get("torre", 0)), int(op.get("onda", 0))], r.get_center(), 14, BRANCO, true)
	if (id == "horda" or id == "duelo") and esp["fim"] == "":
		for g in GOLPES_HORDA:
			var r := botao_golpe(g)
			var cd: float = esp["cd"][g]
			var pronto := cd <= 0
			caixa(r, Color(0.07, 0.05, 0.09, 0.92), 12, 2, OURO if pronto else PEDRA_BORDA, true, 6)
			if not pronto:
				draw_rect(Rect2(r.position, Vector2(r.size.x * (1.0 - cd / GOLPES_HORDA[g][1]), r.size.y)), Color(OURO, 0.12))
			else:
				brilho_suave(r.get_center(), 70, OURO, 0.4 + 0.2 * sin(tempo * 5))
			icone("esmagamento" if g == "esmagar" else "espinhos", r.position + Vector2(36, r.size.y / 2), 0.7)
			escrever_esq(GOLPES_HORDA[g][0], r.position + Vector2(64, 38), 14, BRANCO if pronto else CINZA, fonte_titulo)
			escrever_esq("pronto!" if pronto else "%.0f s" % ceilf(cd), r.position + Vector2(66, 60), 14, OURO if pronto else CINZA)
		if esp["t"] < 7:
			escrever("Toque e arraste para andar (controle virtual)", Vector2(LARG / 2, 690), 15, BRANCO)
	if id in ["cacada", "horda"] and esp["fim"] == "" and esp.get("joy_ini") != null:
		var c: Vector2 = esp["joy_ini"]
		draw_arc(c, 50, 0, TAU, 32, Color(OURO, 0.5), 3, true)
		draw_circle(c + (esp["joy"] - c).limit_length(50), 18, Color(OURO, 0.6))
	if msg_t > 0 and msg != "" and escolha.is_empty():
		var w := fonte.get_string_size(msg, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
		var a := clampf(msg_t * 2, 0, 1)
		caixa(Rect2(LARG / 2 - w / 2 - 14, 158, w + 28, 28), Color(0.05, 0.04, 0.07, 0.9 * a), 14, 1, Color(OURO, 0.7 * a))
		escrever(msg, Vector2(LARG / 2, 172), 18, Color(BRANCO, a), false)
	if not escolha.is_empty():
		desenhar_escolha()
	if esp["fim"] != "":
		desenhar_fim_esp()


func desenhar_topo_esp() -> void:
	degrade(Rect2(0, 0, LARG, 150), Color(0.02, 0.01, 0.03, 0.85), Color(0.02, 0.01, 0.03, 0.0))
	var bv: Rect2 = botoes()["voltar"]
	botao(bv, "", OURO)
	draw_polyline(PackedVector2Array([bv.get_center() + Vector2(4, -8), bv.get_center() + Vector2(-4, 0), bv.get_center() + Vector2(4, 8)]), OURO, 2.5, true)
	var id: String = esp["id"]
	var dir := ""
	match id:
		"horda":
			dir = "ONDA %d/10" % maxi(1, int(esp["onda"]))
		"duelo":
			dir = "ONDA %d" % maxi(1, int(esp["onda"]))
		"cacada":
			dir = "SALA %d/10" % int(esp["sala"])
		"colosso":
			var r := maxi(0, int(90.0 - esp["t"]))
			dir = "%d:%02d" % [r / 60, r % 60]
		"refugio":
			var r := maxi(0, int(150.0 - esp["t"]))
			dir = "AMANHECER %d:%02d" % [r / 60, r % 60]
	var w := fonte_titulo.get_string_size(dir, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
	escrever_esq(dir, Vector2(LARG - 16 - w, 31), 14, BRANCO, fonte_titulo)
	escrever_esq(nome_modo(id).to_upper(), Vector2(56, 31), 14, OURO, fonte_titulo)
	# caixa da esquerda: o que importa em cada modo
	caixa(Rect2(16, 84, 122, 40), Color(0.05, 0.04, 0.07, 0.85), 8, 1, Color(ROXO, 0.5))
	match id:
		"refugio":
			cristal(Vector2(38, 104), 11)
			escrever_esq(str(essencia), Vector2(58, 113), 24, BRANCO)
		"horda", "duelo":
			escrever_esq("Torre %d%%" % int(100 * torre_hp / maxf(1.0, torre_max)), Vector2(26, 111), 18, Color8(200, 170, 255))
		"colosso":
			escrever_esq("Dano ×%s" % String.num(1.0 + esp["t"] / 15.0, 1).replace(".", ","), Vector2(24, 111), 17, OURO)
		"cacada":
			escrever_esq("Poderes %d" % esp["habs"].size(), Vector2(26, 111), 18, Color8(200, 170, 255))
	var bw := 196.0
	var bx := 148.0
	caixa(Rect2(bx, 88, bw, 30), Color(0.05, 0.04, 0.07, 0.9), 8, 1, Color(VERMELHO, 0.5))
	var fr := clampf(hp / hp_max, 0, 1)
	if fr > 0:
		degrade(Rect2(bx + 4, 92, (bw - 8) * fr, 22), Color8(200, 40, 44), Color8(110, 14, 20))
	if escudo > 0:
		degrade(Rect2(bx + 4, 110, (bw - 8) * clampf(escudo / hp_max, 0, 1), 5), Color8(150, 200, 255), Color8(60, 110, 220))
	escrever("%d / %d" % [int(maxf(0, hp)), int(hp_max)], Vector2(bx + bw / 2, 103), 16, BRANCO)
	if id == "colosso":
		var boss: Dictionary = esp["boss"]
		var wb := LARG - 60
		caixa(Rect2(28, 134, wb + 4, 14), Color(0.05, 0.04, 0.07, 0.9), 4, 1, Color(ROXO, 0.6))
		degrade(Rect2(31, 137, (wb - 2) * clampf(boss["hp"] / boss["hp_max"], 0, 1), 8), Color8(170, 90, 255), Color8(80, 30, 140))
		escrever("GIGANTE DO VAZIO", Vector2(LARG / 2, 160), 13, Color8(210, 180, 255), true, fonte_titulo)


func desenhar_sala() -> void:
	draw_rect(SALA, Color(0.05, 0.03, 0.08, 0.55))
	for k in 6:
		var y := SALA.position.y + 40 + k * 90
		draw_line(Vector2(SALA.position.x, y), Vector2(SALA.end.x, y), Color(1, 1, 1, 0.03), 2)
	caixa(SALA, Color(0, 0, 0, 0), 6, 6, Color8(58, 52, 70), false)
	var porta := Rect2(200, SALA.position.y - 6, 80, 14)
	if esp.get("porta", false):
		brilho_suave(porta.get_center(), 60, OURO, 1.0 + 0.3 * sin(tempo * 5))
		draw_rect(porta, Color8(255, 210, 120))
		escrever("↑", porta.get_center() + Vector2(0, 30 + sin(tempo * 6) * 4), 26, OURO)
	else:
		draw_rect(porta, Color8(70, 40, 30))
	if esp["fim"] == "" and escolha.is_empty() and int(esp["sala"]) == 1 and esp["t"] < 6:
		escrever("Arraste o dedo para andar · parado, ele ataca", Vector2(LARG / 2, SALA.end.y + 40), 15, CINZA)


func desenhar_quarto() -> void:
	var q := QUARTO
	draw_rect(q, Color(0.10, 0.07, 0.06, 0.85))
	for k in 5:
		draw_line(Vector2(q.position.x, q.position.y + 50 * k), Vector2(q.end.x, q.position.y + 50 * k), Color(0, 0, 0, 0.25), 1)
	var parede := Color8(74, 66, 90)
	draw_line(q.position, Vector2(205, q.position.y), parede, 10)
	draw_line(Vector2(275, q.position.y), Vector2(q.end.x, q.position.y), parede, 10)
	draw_line(q.position, Vector2(q.position.x, q.end.y), parede, 10)
	draw_line(Vector2(q.end.x, q.position.y), q.end, parede, 10)
	draw_line(Vector2(q.position.x, q.end.y), q.end, parede, 10)
	# a porta: madeira que escurece quando apanha
	var fr := clampf(esp["porta"] / esp["porta_max"], 0, 1)
	var porta := Rect2(205, q.position.y - 8, 70, 16)
	if esp["quebrada"]:
		for k in 3:
			draw_line(porta.position + Vector2(8 + k * 22, 4), porta.position + Vector2(18 + k * 22, 14), Color8(110, 70, 40), 4)
	else:
		draw_rect(porta, Color8(130, 84, 46).lerp(Color8(60, 20, 20), 1.0 - fr) if torre_flash <= 0 else Color8(220, 90, 80))
		for k in 3:
			draw_line(porta.position + Vector2(0, 4 + k * 4), porta.position + Vector2(70, 4 + k * 4), Color(0, 0, 0, 0.3), 1)
	draw_rect(Rect2(205, q.position.y - 22, 70, 6), Color(0, 0, 0, 0.7))
	draw_rect(Rect2(205, q.position.y - 22, 70 * fr, 6), Color8(220, 160, 90))
	# cama onde o Kravenox descansa
	caixa(Rect2(200, 528, 80, 18), Color8(90, 30, 40), 4, 1, TINTA)
	for i in REF_SLOTS.size():
		var c: Vector2 = REF_SLOTS[i]
		var s = esp["slots"][i]
		draw_circle(c, 32, Color(0, 0, 0, 0.45))
		draw_arc(c, 32, 0, TAU, 32, Color(OURO, 0.35) if s == null else Color(OURO, 0.8), 2, true)
		if s == null:
			escrever("+", c, 22, Color(OURO, 0.4), false)
		else:
			icone(s["id"], c + Vector2(0, -4), 0.62)
			for k in int(s["nv"]):
				var pp: Vector2 = c + Vector2((k - (int(s["nv"]) - 1) / 2.0) * 9, 22)
				draw_colored_polygon(PackedVector2Array([pp + Vector2(0, -3.5), pp + Vector2(3, 0), pp + Vector2(0, 3.5), pp + Vector2(-3, 0)]), OURO)


func desenhar_painel_refugio() -> void:
	caixa(Rect2(4, ALT - 98, LARG - 8, 94), Color(0.04, 0.03, 0.06, 0.94), 10, 2, OURO_ESC, true, 6)
	for i in 5:
		var r := Rect2(8 + i * 93, ALT - 92, 89, 84)
		if i < 4:
			var o: Dictionary = REF_OBRAS[i]
			var sel: bool = esp["sel"] == o["id"]
			caixa(r, Color8(40, 30, 50) if sel else Color8(22, 18, 28), 8, 2 if sel else 1, OURO if sel else PEDRA_BORDA)
			icone(o["id"], r.position + Vector2(r.size.x / 2, 30), 0.5)
			escrever(o["nome"], r.position + Vector2(r.size.x / 2, 58), 13, BRANCO, false)
			cristal(r.position + Vector2(30, 74), 5)
			escrever_esq(str(int(o["custo"])), r.position + Vector2(40, 80), 14, BRANCO if essencia >= int(o["custo"]) else Color8(200, 80, 80))
		else:
			caixa(r, Color8(40, 26, 20), 8, 1, Color8(160, 110, 60))
			poli([r.position + Vector2(30, 14), r.position + Vector2(59, 14), r.position + Vector2(59, 46), r.position + Vector2(30, 46)], Color8(130, 84, 46), 1.2)
			escrever("Porta", r.position + Vector2(r.size.x / 2, 58), 13, BRANCO, false)
			cristal(r.position + Vector2(30, 74), 5)
			escrever_esq(str(custo_porta()), r.position + Vector2(40, 80), 14, BRANCO if essencia >= custo_porta() else Color8(200, 80, 80))
	if esp["t"] < 8 and esp["fim"] == "":
		escrever("Escolha a obra embaixo e toque num círculo do quarto", Vector2(LARG / 2, 610), 14, CINZA)
		escrever("Tocar numa obra pronta melhora ela", Vector2(LARG / 2, 632), 13, CINZA)


func desenhar_colosso() -> void:
	var boss: Dictionary = esp["boss"]
	var t: float = esp["t"]
	var base := Vector2(240, 430)
	brilho_suave(base + Vector2(0, -150), 220, ROXO, 0.8 + 0.2 * sin(tempo * 2))
	sombra_chao(base, 130)
	var resp := 1.0 + 0.02 * sin(tempo * 2.5)
	contorno("sentinela", base, 300 * resp, false, Color(ROXO, 0.7))
	desenhar_arte("sentinela", base, 300 * resp, false, Color(0.55, 0.38, 0.85))
	if boss["flash"] > 0:
		desenhar_arte("sentinela", base, 300 * resp, false, Color(1, 0.8, 1, 0.22), true)
	# o chão por onde o Kravenox anda
	draw_rect(Rect2(0, 600, LARG, 90), Color(0.1, 0.05, 0.12, 0.6))
	draw_line(Vector2(0, 600), Vector2(LARG, 600), Color(ROXO, 0.4), 2)
	draw_line(Vector2(0, 690), Vector2(LARG, 690), Color(ROXO, 0.4), 2)
	for a in esp["ataques"]:
		var f: float = clampf(1.0 - a["t"] / a["max"], 0, 1)
		var cor := Color(1.0, 0.15, 0.2, 0.18 + 0.35 * f) if a["t"] > 0 else Color(1, 0.9, 0.8, 0.8)
		match a["tipo"]:
			"circ":
				draw_set_transform(Vector2(a["x"], 645), 0, Vector2(1, 0.4))
				draw_circle(Vector2.ZERO, a["r"], cor)
				draw_arc(Vector2.ZERO, a["r"] * f, 0, TAU, 32, Color(1, 0.4, 0.4, 0.9), 3, true)
				draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
			"col":
				draw_rect(Rect2(a["x"] - a["w"] / 2, 600, a["w"], 90), cor)
			"lin":
				draw_rect(Rect2(0, 600, a["x"] - a["w"] / 2, 90), cor)
				draw_rect(Rect2(a["x"] + a["w"] / 2, 600, LARG - a["x"] - a["w"] / 2, 90), cor)
	if t < 6:
		escrever("Arraste para os lados para desviar das áreas vermelhas", Vector2(LARG / 2, 730), 14, CINZA)


func desenhar_fim_esp() -> void:
	draw_rect(Rect2(0, 0, LARG, ALT), Color(0.02, 0.01, 0.03, 0.84))
	var venceu: bool = esp["fim"] == "venceu"
	var id: String = esp["id"]
	var base := Vector2(LARG / 2, ALT / 2 - 110)
	brilho_suave(base + Vector2(0, -70), 120, OURO if venceu else VERMELHO, 0.7)
	desenhar_arte("kravenox", base, 140, false, Color.WHITE if venceu else Color(0.45, 0.4, 0.5))
	var titulo := "NOVO RECORDE!" if esp.get("recorde", false) else ("VITÓRIA!" if venceu else "FIM")
	if id == "duelo":
		titulo = "VOCÊ VENCEU!" if venceu else "VOCÊ PERDEU"
	escrever(titulo, Vector2(LARG / 2, ALT / 2 - 76), 26, OURO if venceu or esp.get("recorde", false) else VERMELHO, true, fonte_titulo)
	var t2 := ""
	if id == "duelo":
		titulo = "VOCÊ VENCEU!" if venceu else "VOCÊ PERDEU"
		var op: Dictionary = duelo.get("op", {})
		match str(esp.get("motivo", "")):
			"op_caiu":
				t2 = tx("A torre de %s caiu primeiro!") % nome_op()
			"op_saiu":
				t2 = tx("%s saiu do duelo.") % nome_op()
			"conexao":
				t2 = tx("A conexão caiu.")
			_:
				t2 = tx("Sua torre caiu primeiro.")
	match id:
		"horda":
			t2 = "Aguentou %d de 10 ondas" % int(esp["pontos"])
		"cacada":
			t2 = "Atravessou %d de 10 salas" % int(esp["pontos"])
		"colosso":
			t2 = ("Derrubou o Gigante! " if esp.get("matou", false) else "") + "Dano total: %d" % int(esp["pontos"])
			if int(esp.get("golpes_ordem", 0)) > 0:
				escrever(tx("+%d golpes no Gigante da Ordem") % int(esp["golpes_ordem"]), Vector2(LARG / 2, ALT / 2 + 290), 14, Color8(200, 170, 255), false)
		"refugio":
			t2 = "Chegou ao amanhecer!" if venceu else "Aguentou %d:%02d" % [int(esp["pontos"]) / 60, int(esp["pontos"]) % 60]
	escrever(t2, Vector2(LARG / 2, ALT / 2 - 42), 17, BRANCO)
	cristal(Vector2(LARG / 2 - 58, ALT / 2 - 8), 9, VERMELHO)
	escrever_esq("+%d fragmentos" % int(esp["premio"]), Vector2(LARG / 2 - 42, ALT / 2), 19, Color8(255, 170, 160))
	if id == "duelo":
		var op: Dictionary = duelo.get("op", {})
		escrever(tx("Você: onda %d  ·  %s: onda %d") % [int(esp["onda"]), nome_op(), int(op.get("onda", 0))], Vector2(LARG / 2, ALT / 2 + 18), 14, CINZA, false)
		botao(botoes()["denovo"], "Revanche" if ws != null else "Nova sala", OURO, true, true)
		botao(botoes()["mundos"], "Sair", AZUL)
		return
	escrever(texto_rec(id), Vector2(LARG / 2, ALT / 2 + 18), 14, CINZA, false)
	botao(botoes()["denovo"], "Jogar de novo", OURO, true, true)
	botao(botoes()["mundos"], "Modos", AZUL)


func desenhar_modos() -> void:
	desenhar_fundo(0.68)
	cabecalho("MODOS")
	var lista := lista_modos()
	for i in lista.size():
		var m: Dictionary = lista[i]
		var r := Rect2(14, 118 + i * 88, LARG - 28, 84)
		var ok := int(prog["liberado"]) >= int(m["desde"])
		caixa(r, Color(0.06, 0.05, 0.08, 0.93), 10, 1, Color(OURO if ok else PEDRA_BORDA, 0.8), true, 6)
		var c := r.position + Vector2(44, 42)
		icone_modo(m["id"], c, ok)
		escrever_esq(m["nome"], r.position + Vector2(84, 23), 16, OURO if ok else CINZA, fonte_titulo)
		if ok:
			texto_quebrado(m["desc"], r.position + Vector2(84, 28), r.size.x - 100, 13, Color8(220, 210, 230), 2)
			escrever_esq(texto_rec(m["id"]), r.position + Vector2(84, 77), 12, Color8(200, 170, 255))
		else:
			escrever_esq("Vença o capítulo %d para liberar" % (int(m["desde"]) - 1), r.position + Vector2(84, 48), 14, CINZA)
	desenhar_abas()
	desenhar_popup()


func icone_modo(id: String, c: Vector2, ok: bool) -> void:
	var a := 1.0 if ok else 0.3
	match id:
		"horda":
			brilho_suave(c, 36, ROXO, a)
			for k in 7:
				draw_circle(c + Vector2.from_angle(k * TAU / 7 + tempo * 0.5) * 22, 5, Color(0.6, 0.4, 0.9, a))
			poli([c + Vector2(-8, 12), c + Vector2(8, 12), c + Vector2(6, -10), c + Vector2(-6, -10)], Color(0.3, 0.27, 0.36, a), 1.2)
		"colosso":
			brilho_suave(c, 36, ROXO, a)
			contorno("sentinela", c + Vector2(0, 26), 56, false, Color(0.8, 0.6, 1.0, a))
			desenhar_arte("sentinela", c + Vector2(0, 26), 56, false, Color(0.85, 0.7, 1.0, a))
		"refugio":
			brilho_suave(c, 36, OURO, a)
			draw_rect(Rect2(c + Vector2(-20, -16), Vector2(40, 34)), Color(0.4, 0.26, 0.15, a))
			draw_rect(Rect2(c + Vector2(-7, 0), Vector2(14, 18)), Color(0.12, 0.08, 0.06, a))
			poli([c + Vector2(-26, -14), c + Vector2(0, -32), c + Vector2(26, -14)], Color(0.55, 0.18, 0.18, a), 1.2)
		"cacada":
			brilho_suave(c, 36, VERMELHO, a)
			draw_arc(c, 22, 0, TAU, 32, Color(0.9, 0.3, 0.3, a), 3, true)
			draw_arc(c, 12, 0, TAU, 24, Color(0.9, 0.3, 0.3, a), 3, true)
			draw_circle(c, 4, Color(1, 0.8, 0.6, a))
		"abismo":
			brilho_suave(c, 36, ROXO, a)
			for k in 3:
				draw_arc(c, 22 - k * 7, tempo * (1.0 + k * 0.5), tempo * (1.0 + k * 0.5) + 4.2, 16, Color(0.8, 0.6, 1.0, a * (1.0 - k * 0.25)), 3, true)
		"duelo":
			brilho_suave(c, 36, VERMELHO, a)
			for k in [-1.0, 1.0]:
				draw_line(c + Vector2(-16 * k, 16), c + Vector2(14 * k, -16), Color(0.9, 0.9, 0.95, a), 5, true)
				draw_line(c + Vector2(-11 * k, 4), c + Vector2(-3 * k, 12), Color(0.9, 0.3, 0.3, a), 4, true)
		"desafio":
			brilho_suave(c, 36, Color8(255, 160, 60), a)
			draw_circle(c, 15, Color(1, 0.67, 0.27, a))
			for k in 8:
				var an := k * TAU / 8 + tempo * 0.3
				draw_line(c + Vector2.from_angle(an) * 18, c + Vector2.from_angle(an) * 25, Color(1, 0.78, 0.4, a), 3)


# ============================================================ Loja do Apoiador (9/11)
# Só visual e conforto: nada aqui deixa o Kravenox mais forte (sem "pagar para
# ganhar"). A compra de verdade ainda não está ligada: liga quando o jogo for
# para a loja da Apple ou do Google. Para testar, em Ajustes toque 7 vezes na
# versão (liga e desliga o "modo de teste da loja").
const LOJA_ITENS := [
	{"id": "apoiador", "nome": "Pacote do Apoiador", "preco": "R$ 9,90", "tipo": "pacote", "cor": Color8(255, 70, 50),
		"desc": "Aura Coroa Rubra, Eco Estelar, moldura dourada e selo de Apoiador."},
	{"id": "aura_gelo", "nome": "Aura do Gelo Azul", "preco": "R$ 3,90", "tipo": "aura", "cor": Color8(120, 200, 255), "desc": "a luz em volta do Kravenox fica azul-gelo"},
	{"id": "aura_ouro", "nome": "Aura Dourada", "preco": "R$ 3,90", "tipo": "aura", "cor": Color8(255, 205, 90), "desc": "a luz em volta do Kravenox fica dourada"},
	{"id": "aura_vazio", "nome": "Aura do Vazio", "preco": "R$ 3,90", "tipo": "aura", "cor": Color8(150, 60, 255), "desc": "a luz em volta do Kravenox fica roxa do Vazio"},
	{"id": "skin_gelo", "nome": "Kravenox de Gelo", "preco": "R$ 4,90", "tipo": "skin", "skin": "gelo", "cor": Color8(120, 200, 255), "desc": "o corpo do Kravenox fica azul-gelo e os olhos, ciano"},
	{"id": "skin_ouro", "nome": "Kravenox Dourado", "preco": "R$ 4,90", "tipo": "skin", "skin": "ouro", "cor": Color8(255, 205, 90), "desc": "o corpo do Kravenox fica dourado"},
	{"id": "skin_sombrio", "nome": "Kravenox do Vazio", "preco": "R$ 4,90", "tipo": "skin", "skin": "sombrio", "cor": Color8(170, 110, 255), "desc": "o corpo do Kravenox fica roxo do Vazio"},
	{"id": "skin_brasa", "nome": "Kravenox de Brasa", "preco": "R$ 4,90", "tipo": "skin", "skin": "brasa", "cor": Color8(255, 140, 50), "desc": "o corpo do Kravenox fica cor de brasa"},
	{"id": "skin_pioneiro", "nome": "Kravenox Pioneiro", "preco": "Beta", "tipo": "skin", "skin": "pioneiro", "cor": Color8(90, 255, 160), "desc": "exclusiva de quem testou o jogo antes de todo mundo", "exclusivo": true},
	{"id": "moldura_brasa", "nome": "Moldura de Brasa", "preco": "R$ 2,90", "tipo": "moldura", "cor": Color8(255, 90, 40), "desc": "os quadros com poder ganham borda de brasa"},
	{"id": "vel4", "nome": "Velocidade 4×", "preco": "R$ 4,90", "tipo": "conforto", "cor": Color8(214, 178, 106), "desc": "o botão de velocidade ganha o 4×"},
	{"id": "fora24", "nome": "Vigília de 24 horas", "preco": "R$ 2,90", "tipo": "conforto", "cor": Color8(214, 178, 106), "desc": "a Vigília junta fragmentos por até 24 h, e não 12 h"},
]
var toques_versao := 0


func tem(id: String) -> bool:
	return bool(prog.get("teste_compras", false)) or prog.get("compras", {}).has(id)


func item_loja(id: String) -> Dictionary:
	for it in LOJA_ITENS:
		if it["id"] == id:
			return it
	return {}


func cor_aura() -> Color:
	var a := str(prog.get("aura", ""))
	if a == "coroa" and tem("apoiador"):
		return Color8(255, 70, 50)
	if a != "" and a != "coroa" and tem(a):
		return item_loja(a)["cor"]
	return Color(0, 0, 0, 0)


func cor_moldura() -> Color:
	var m := str(prog.get("moldura", ""))
	if m == "ouro" and tem("apoiador"):
		return OURO
	if m == "moldura_brasa" and tem(m):
		return item_loja(m)["cor"]
	return Color(0, 0, 0, 0)


func eco_estelar() -> bool:
	return tem("apoiador") and bool(prog.get("eco_estelar", false))


func skin_atual() -> String:
	var s := str(prog.get("skin", ""))
	return s if s != "" and tem("skin_" + s) else ""


var tex_skins := {}


func textura_skin(sk: String, nome: String) -> Texture2D:
	var chave := sk + "/" + nome
	if not tex_skins.has(chave):
		var t: Texture2D = load("res://assets/skins/%s/%s.png" % [sk, nome])
		var img := t.get_image()
		if img.is_compressed():
			img.decompress()
		img.generate_mipmaps()
		tex_skins[chave] = ImageTexture.create_from_image(img)
	return tex_skins[chave]


func usando(it: Dictionary) -> bool:
	match it["tipo"]:
		"skin":
			return str(prog.get("skin", "")) == it["skin"]
		"pacote":
			return str(prog.get("aura", "")) == "coroa"
		"aura":
			return str(prog.get("aura", "")) == it["id"]
		"moldura":
			return str(prog.get("moldura", "")) == it["id"]
	return true


var rol_loja := 0.0
var toque_rol_loja := 0.0
const TOPO_LOJA := 210.0


func rol_loja_max() -> float:
	return maxf(0.0, TOPO_LOJA + LOJA_ITENS.size() * 73 + 8 - (ALT - 82))


func ret_loja(i: int) -> Rect2:
	return Rect2(14, TOPO_LOJA + 2 + i * 73 - rol_loja, LARG - 28, 68)


func bau_loja_pronto() -> bool:
	return prog.get("bau_loja", "") != hoje()


# Baú do Dia da loja: grátis, uma vez por dia.
func abrir_bau_loja() -> void:
	if not bau_loja_pronto():
		popup = {"titulo": "BAÚ DO DIA", "texto": "Já aberto hoje. Volte amanhã para outro!"}
		return
	prog["bau_loja"] = hoje()
	var w := mundo_de(int(prog["liberado"]))
	var sorte := randf()
	var visuais := LOJA_ITENS.filter(func(it): return it["tipo"] in ["aura", "moldura"] and not tem(it["id"]))
	if sorte < 0.05 and not visuais.is_empty():
		var it: Dictionary = visuais.pick_random()
		var c: Dictionary = prog.get("compras", {})
		c[it["id"]] = "bau"
		prog["compras"] = c
		salvar()
		som("chefe")
		popup = {"titulo": "BAÚ DO DIA: RARO!", "texto": "Você ganhou %s! Use na Loja." % it["nome"]}
	elif sorte < 0.15:
		ganhar(3 * (6 + w), "BAÚ DO DIA: MONTE GRANDE!")
	elif sorte < 0.40:
		prog["furia_presente"] = int(prog.get("furia_presente", 0)) + 1
		salvar()
		som("nivel")
		popup = {"titulo": "BAÚ DO DIA", "texto": "Fúria pela metade na próxima partida!"}
	else:
		ganhar(6 + w, "BAÚ DO DIA")


func desenhar_bau_loja() -> void:
	var r := Rect2(14, 144, LARG - 28, 62)
	var pronto := bau_loja_pronto()
	caixa(r, Color8(40, 30, 16) if pronto else Color(0.06, 0.05, 0.08, 0.93), 10, 2 if pronto else 1, OURO if pronto else PEDRA_BORDA, true, 4)
	var c := r.position + Vector2(38, 31)
	if pronto:
		brilho_suave(c, 40, OURO, 1.0 + 0.3 * sin(tempo * 4))
	caixa(Rect2(c + Vector2(-17, -4), Vector2(34, 20)), Color8(110, 70, 36), 3, 1, TINTA)
	caixa(Rect2(c + Vector2(-17, -13), Vector2(34, 11)), Color8(140, 90, 46), 5, 1, TINTA)
	draw_rect(Rect2(c + Vector2(-3, -5), Vector2(6, 8)), OURO)
	escrever_esq("Baú do Dia · grátis", r.position + Vector2(76, 26), 16, OURO, fonte_titulo)
	escrever_esq("Toque para abrir!" if pronto else "Aberto hoje · volte amanhã", r.position + Vector2(76, 48), 13, BRANCO if pronto else CINZA)
	if pronto:
		var d := r.position + Vector2(r.size.x - 18, 14)
		draw_circle(d, 8 + sin(tempo * 5), VERMELHO)
		escrever("!", d, 13, BRANCO, false)


func clique_loja(p: Vector2) -> void:
	if Rect2(14, 144, LARG - 28, 62).has_point(p):
		abrir_bau_loja()
		return
	if p.y < TOPO_LOJA or p.y > ALT - 82:
		return
	for i in LOJA_ITENS.size():
		if not Rect2(LARG - 128, ret_loja(i).position.y + 14, 108, 40).has_point(p):
			continue
		var it: Dictionary = LOJA_ITENS[i]
		if not tem(it["id"]) and it.get("exclusivo", false):
			popup = {"titulo": tx(it["nome"]).to_upper(), "texto": "Exclusiva dos beta testers: abre com o código de presente (Ajustes → Código de presente)."}
			return
		if not tem(it["id"]):
			popup = {"titulo": it["nome"].to_upper(), "texto": "A compra ainda não está ligada. Ela começa a funcionar quando o jogo estiver na loja da Apple ou do Google. Obrigado pela vontade de apoiar!"}
			return
		var liga := not usando(it)
		match it["tipo"]:
			"pacote":
				prog["aura"] = "coroa" if liga else ""
				prog["moldura"] = "ouro" if liga else ""
				prog["eco_estelar"] = liga
			"aura":
				prog["aura"] = it["id"] if liga else ""
			"moldura":
				prog["moldura"] = it["id"] if liga else ""
			"skin":
				prog["skin"] = it["skin"] if liga else ""
		som("gema")
		salvar()
		return


func desenhar_loja_apoiador() -> void:
	desenhar_fundo(0.7)
	rol_loja = clampf(rol_loja, 0.0, rol_loja_max())
	for i in LOJA_ITENS.size():
		var it: Dictionary = LOJA_ITENS[i]
		var r := ret_loja(i)
		var dono := tem(it["id"])
		var pacote: bool = it["tipo"] == "pacote"
		caixa(r, Color8(34, 20, 24) if pacote else Color(0.06, 0.05, 0.08, 0.93), 10, 2 if pacote else 1, Color(it["cor"], 0.8) if pacote else Color(PEDRA_BORDA, 0.9), true, 4)
		var c := r.position + Vector2(38, r.size.y / 2)
		match it["tipo"]:
			"aura", "pacote":
				brilho_suave(c, 40, it["cor"], 1.2 + 0.2 * sin(tempo * 3))
				desenhar_arte("kravenox-passo-0", c + Vector2(0, 22), 44, false)
			"skin":
				brilho_suave(c, 34, it["cor"], 0.6)
				draw_texture_rect(textura_skin(it["skin"], "kravenox-passo-0"), Rect2(c - Vector2(26, 24), Vector2(52, 48)), false)
			"moldura":
				draw_texture_rect(textura_laje(false), Rect2(c - Vector2(22, 22), Vector2(44, 44)), false)
				caixa(Rect2(c - Vector2(21, 21), Vector2(42, 42)), Color(0, 0, 0, 0), 5, 3, it["cor"], false)
			"conforto":
				brilho_suave(c, 34, OURO, 0.8)
				if it["id"] == "vel4":
					escrever("4×", c, 24, OURO, true, fonte_titulo)
				else:
					draw_circle(c, 15, Color8(30, 24, 44))
					draw_arc(c, 15, 0, TAU, 24, OURO, 2, true)
					draw_line(c, c + Vector2(0, -10), OURO, 2)
					draw_line(c, c + Vector2(7, 3), OURO, 2)
		escrever_esq(it["nome"], r.position + Vector2(76, 22), 15, OURO, fonte_titulo)
		texto_quebrado(it["desc"], r.position + Vector2(76, 27), r.size.x - 200, 12, Color8(210, 200, 220), 3)
		var bb := Rect2(LARG - 128, r.position.y + 14, 108, 40)
		if not dono:
			botao(bb, it["preco"], OURO, true, true)
		elif it["tipo"] == "conforto":
			botao(bb, "Ativo", VERDE, true, false)
		else:
			botao(bb, "Em uso" if usando(it) else "Usar", VERDE, true, usando(it))
	# topo fixo (por cima da lista que rola)
	draw_rect(Rect2(0, 0, LARG, TOPO_LOJA), Color8(16, 12, 22))
	degrade(Rect2(0, TOPO_LOJA, LARG, 14), Color8(16, 12, 22), Color(0.06, 0.05, 0.09, 0.0))
	cabecalho("LOJA")
	texto_quebrado("Nada aqui deixa o Kravenox mais forte: é só visual e conforto, para apoiar o jogo.", Vector2(24, 106), LARG - 48, 12, Color8(200, 230, 200), 1, true)
	desenhar_bau_loja()
	if not skins_faltando().is_empty():
		escrever(tx("Baús das fases: %d%% de chance de skin") % chance_skin(), Vector2(LARG / 2, 136), 12, OURO, true)
	if rol_loja < rol_loja_max() - 4:
		degrade(Rect2(0, ALT - 124, LARG, 42), Color(0.04, 0.03, 0.06, 0.0), Color(0.04, 0.03, 0.06, 0.95))
		escrever("▼ arraste para ver mais", Vector2(LARG / 2, ALT - 94), 13, OURO, true)
	if prog.get("teste_compras", false):
		escrever("modo de teste da loja: tudo liberado", Vector2(LARG / 2, ALT - 112), 12, Color8(255, 200, 120), false)
	desenhar_abas()
	desenhar_popup()


# ============================================================ levar o progresso para outro celular (9/11)
# Sem servidor e sem internet: o progresso vira um código de texto (JSON
# comprimido em base64). Num celular: Ajustes → Copiar progresso. No outro:
# Ajustes → Colar progresso. O código troca o progresso do celular que recebe.
const PREFIXO_COD := "KRX1-"
var colar_confirma := 0.0
var progresso_recebido := {}


func codigo_progresso() -> String:
	var d := prog.duplicate(true)
	d.erase("partida")
	var bytes := JSON.stringify(d).to_utf8_buffer()
	return PREFIXO_COD + str(bytes.size()) + "-" + Marshalls.raw_to_base64(bytes.compress(FileAccess.COMPRESSION_DEFLATE))


func ler_codigo(c: String) -> Dictionary:
	c = c.strip_edges().replace(" ", "").replace("\n", "").replace("\r", "")
	var i0 := c.find(PREFIXO_COD)
	if i0 < 0:
		return {}
	var resto := c.substr(i0 + PREFIXO_COD.length())
	var i := resto.find("-")
	if i < 0:
		return {}
	var tam := int(resto.substr(0, i))
	if tam <= 0 or tam > 2000000:
		return {}
	var b := Marshalls.base64_to_raw(resto.substr(i + 1)).decompress(tam, FileAccess.COMPRESSION_DEFLATE)
	var d = JSON.parse_string(b.get_string_from_utf8())
	if d is Dictionary and d.has("liberado") and d.has("feitos"):
		return d
	return {}


func copiar_progresso() -> void:
	salvar()
	var c := codigo_progresso()
	if OS.has_feature("web"):
		JavaScriptBridge.eval("try{navigator.clipboard.writeText(%s)}catch(e){}" % JSON.stringify(c))
		JavaScriptBridge.eval("window.prompt(%s, %s)" % [JSON.stringify(tx("Copie este código (toque nele, Selecionar Tudo, Copiar) e mande para o outro celular. Lá: Ajustes → Colar progresso.")), JSON.stringify(c)])
		popup = {"titulo": "CÓDIGO DO PROGRESSO", "texto": "Mande o código para o outro celular (WhatsApp, Notas, e-mail). Lá, em Ajustes, toque em Colar progresso."}
	else:
		DisplayServer.clipboard_set(c)
		popup = {"titulo": "CÓDIGO COPIADO", "texto": "O código já está copiado. Mande para o outro celular (WhatsApp, Notas, e-mail) e lá, em Ajustes, toque em Colar progresso."}


func colar_progresso() -> void:
	if colar_confirma > 0 and not progresso_recebido.is_empty():
		# segundo toque: troca o progresso deste celular
		var f := FileAccess.open(ARQUIVO, FileAccess.WRITE)
		if f:
			f.store_string(JSON.stringify(progresso_recebido))
			f.close()
		carregar_progresso()
		cap_sel = 0
		colar_confirma = 0.0
		progresso_recebido = {}
		som("nivel")
		popup = {"titulo": "PROGRESSO CARREGADO", "texto": "Pronto! Este celular agora está no capítulo %d, com %d fragmentos." % [int(prog["liberado"]), int(prog["fragmentos"])]}
		return
	var c := ""
	if OS.has_feature("web"):
		c = str(JavaScriptBridge.eval("window.prompt(%s, '') || ''" % JSON.stringify(tx("Cole aqui o código do outro celular:"))))
	else:
		c = DisplayServer.clipboard_get()
	if c.strip_edges() == "":
		if not OS.has_feature("web"):
			popup = {"titulo": "COLAR PROGRESSO", "texto": "Copie o código do outro celular primeiro e depois toque aqui."}
		return
	var d := ler_codigo(c)
	if d.is_empty():
		popup = {"titulo": "CÓDIGO INVÁLIDO", "texto": "Esse código não funcionou. Copie de novo o código inteiro (começa com KRX1-)."}
		return
	progresso_recebido = d
	colar_confirma = 10.0
	popup = {"titulo": "CONFIRMAR", "texto": "O código é de um jogo no capítulo %d, com %d fragmentos. Ele vai TROCAR o progresso deste celular. Para confirmar, toque de novo em \"Colar progresso\"." % [int(d["liberado"]), int(d.get("fragmentos", 0))]}


# ============================================================ tutorial curto (9/11)
# Só no capítulo 1 de quem está começando: uma mãozinha mostra as primeiras
# ações (arrastar um poder, começar a onda, fundir). Não trava nada.
func passo_tutorial() -> int:
	if prog.get("tutorial", false) or capitulo != 1 or tipo_partida != "capitulo" or int(prog["liberado"]) > 1:
		return -1
	if estado != "loja" or not escolha.is_empty() or not arrasto.is_empty():
		return -1
	if quadros.all(func(q): return q == null):
		return 0
	if onda == 0:
		return 1
	if onda == 1:
		return 2
	return -1


func mao(p: Vector2, toque: float) -> void:
	# mãozinha branca apontando, com um anel quando "toca"
	if toque > 0:
		draw_arc(p, 14 + 18 * toque, 0, TAU, 28, Color(1, 1, 1, 0.8 * (1.0 - toque)), 3, true)
	var b := p + Vector2(10, 16)
	draw_rect(Rect2(p + Vector2(-4, 0), Vector2(9, 22)), Color(1, 0.95, 0.9))
	draw_circle(p + Vector2(0.5, 0), 4.5, Color(1, 0.95, 0.9))
	draw_circle(b, 13, Color(1, 0.95, 0.9))
	draw_arc(b, 13, 0, TAU, 24, Color(0, 0, 0, 0.6), 1.5, true)


func desenhar_tutorial() -> void:
	var passo := passo_tutorial()
	if passo < 0:
		return
	var b := botoes()
	var t := fmod(tempo, 1.8) / 1.8
	match passo:
		0, 2:
			# arrastar da loja até um quadro (no passo 2: até um poder igual, para fundir)
			var de := -1
			var para := -1
			for i in 3:
				if loja[i] != null and essencia >= preco(loja[i]):
					for k in ANEL.size():
						if passo == 2 and quadros[k] != null and quadros[k]["id"] == loja[i] and int(quadros[k]["nv"]) == 1:
							de = i
							para = k
							break
					if de >= 0:
						break
					if passo == 0 and de < 0:
						de = i
						para = 0
			if passo == 2:
				desenhar_dica_tutorial("Dica: solte um poder igual em cima de outro do mesmo nível. Eles se fundem e ficam mais fortes!")
			else:
				desenhar_dica_tutorial("Arraste um poder da loja até um quadro")
			if de < 0 or para < 0:
				return
			var a: Vector2 = b["loja%d" % de].get_center()
			var z: Vector2 = ret_quadro(para).get_center()
			var f := clampf((t - 0.15) / 0.6, 0, 1)
			var p := a.lerp(z, f * f * (3 - 2 * f))
			if t > 0.15 and t < 0.8:
				icone(loja[de], p + Vector2(0, -30), 0.6)
			mao(p, (t - 0.8) / 0.2 if t > 0.8 else 0.0)
		1:
			desenhar_dica_tutorial("Agora toque em Iniciar onda")
			mao(b["onda"].get_center() + Vector2(30, 6), t)


func desenhar_dica_tutorial(texto: String) -> void:
	var r := Rect2(24, LOJA_Y - 60, LARG - 48, 44)
	caixa(r, Color(0.08, 0.06, 0.12, 0.92), 10, 2, OURO, true, 4)
	texto_quebrado(texto, r.position + Vector2(12, 4 if fonte.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x > r.size.x - 24 else 12), r.size.x - 24, 14, BRANCO, 2, true)


# ============================================================ idiomas (10/11)
# Todo texto passa por tx() na hora de desenhar. O dicionário (dados/en.json)
# vai do português para o inglês; textos com números ("Fase %d de %d") viram
# moldes. Os trechos do livro ficam em português (a língua do livro).
var idioma := "pt"
var EN := {}
var en_maiusc := {}
var en_moldes := []   # [RegEx, molde em inglês, tipos dos buracos]
var cache_tx := {}


func carregar_idioma() -> void:
	var f := FileAccess.open("res://dados/en.json", FileAccess.READ)
	if f == null:
		return
	var d = JSON.parse_string(f.get_as_text())
	if not (d is Dictionary):
		return
	EN = d
	var lista := []
	for k in EN:
		en_maiusc[String(k).to_upper()] = String(EN[k]).to_upper()
		if "%" in k:
			lista.append(k)
	# os moldes com mais texto fixo vêm primeiro (mais específicos)
	lista.sort_custom(func(a, b): return molde_fixo(a) > molde_fixo(b))
	for k in lista:
		var tipos := []
		var rx := "^"
		var i := 0
		while i < k.length():
			var c: String = k[i]
			if c == "%" and i + 1 < k.length():
				var resto: String = k.substr(i + 1, 3)
				if resto.begins_with("%"):
					rx += "%"
					i += 2
					continue
				if resto.begins_with("02d"):
					rx += "(-?[0-9.,:]+)"
					tipos.append("d")
					i += 4
					continue
				if resto.begins_with("d"):
					rx += "(-?[0-9.,:]+)"
					tipos.append("d")
					i += 2
					continue
				if resto.begins_with("s"):
					rx += "(.*?)"
					tipos.append("s")
					i += 2
					continue
			rx += ("\\" + c) if c in "\\^$.|?*+()[]{}" else c
			i += 1
		rx += "$"
		var re := RegEx.new()
		if re.compile(rx) == OK:
			en_moldes.append([re, EN[k], tipos])


func molde_fixo(k: String) -> int:
	return k.replace("%d", "").replace("%s", "").replace("%02d", "").length()


func tx(s: String) -> String:
	if idioma == "pt" or s == "":
		return s
	if cache_tx.has(s):
		return cache_tx[s]
	var r := traduzir(s)
	if cache_tx.size() > 4000:
		cache_tx.clear()
	cache_tx[s] = r
	return r


func traduzir(s: String) -> String:
	if EN.has(s):
		return EN[s]
	if en_maiusc.has(s):
		return en_maiusc[s]
	for e in en_moldes:
		var m: RegExMatch = e[0].search(s)
		if m != null:
			var vals := []
			for g in range(1, m.get_group_count() + 1):
				var v := m.get_string(g)
				vals.append(traduzir(v) if e[2][g - 1] == "s" else v)
			return preencher(e[1], vals, s == s.to_upper())
	if " · " in s:
		var partes := s.split(" · ")
		var saida := []
		for p in partes:
			saida.append(traduzir(p))
		return " · ".join(saida)
	return s


func preencher(molde: String, vals: Array, maiusc: bool) -> String:
	var out := ""
	var i := 0
	var n := 0
	while i < molde.length():
		var c: String = molde[i]
		if c == "%" and i + 1 < molde.length():
			if molde[i + 1] == "%":
				out += "%"
				i += 2
				continue
			var pulo := 4 if molde.substr(i + 1, 3) == "02d" else 2
			if n < vals.size():
				out += str(vals[n])
			n += 1
			i += pulo
			continue
		out += c
		i += 1
	return out.to_upper() if maiusc and out.to_upper() != out and molde.to_upper() == molde else out


func idioma_padrao() -> String:
	return "pt" if OS.get_locale_language() == "pt" else "en"


func trocar_idioma() -> void:
	idioma = "en" if idioma == "pt" else "pt"
	prog["idioma"] = idioma
	cache_tx.clear()
	salvar()


# ============================================================ mais jogos nossos (12/11)
const JOGOS_NOSSOS := [
	{"nome": "Cratera do Cisma", "desc": "O primeiro jogo do Kravenox, na Cratera do Cisma.", "url": "https://the3dig.github.io/kravenox-jogar/", "img": "cratera"},
	{"nome": "Reino Quebrado (RPG)", "desc": "O RPG da história do livro, capítulo por capítulo.", "url": "https://the3dig.github.io/kravenox-jogar/rpg/", "img": "rpg"},
	{"nome": "Kravenox Plataforma", "desc": "Jogo de plataforma em 3D: corra, pule e lute pelas fases.", "url": "https://the3dig.github.io/kravenox-jogar/plataforma/", "img": "plataforma"},
	{"nome": "Reino Quebrado Online", "desc": "O MMO em 3D: escolha um herói do livro e explore o reino.", "url": "https://the3dig.github.io/kravenox-mmo/", "img": "mmo"},
]
var tex_jogos := {}


func abrir_link(url: String) -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("(function(u){var w=window.open(u,'_blank');if(!w){location.href=u;}})(%s)" % JSON.stringify(url))
	else:
		OS.shell_open(url)


func desenhar_jogos() -> void:
	desenhar_fundo(0.7)
	cabecalho("MAIS JOGOS")
	escrever("Outros jogos do universo Kravenox. Todos grátis.", Vector2(LARG / 2, 132), 14, CINZA)
	for i in JOGOS_NOSSOS.size():
		var jg: Dictionary = JOGOS_NOSSOS[i]
		var r := Rect2(14, 152 + i * 132, LARG - 28, 122)
		caixa(r, Color(0.06, 0.05, 0.08, 0.93), 12, 1, Color(OURO, 0.6), true, 6)
		if not tex_jogos.has(jg["img"]):
			tex_jogos[jg["img"]] = load("res://assets/jogos/%s.png" % jg["img"])
		var ri := Rect2(r.position + Vector2(12, 13), Vector2(96, 96))
		brilho_suave(ri.get_center(), 70, VERMELHO, 0.35)
		draw_texture_rect(tex_jogos[jg["img"]], ri, false)
		caixa(ri, Color(0, 0, 0, 0), 10, 2, Color(OURO, 0.7), false)
		escrever_esq(jg["nome"], r.position + Vector2(122, 32), 17, OURO, fonte_titulo)
		texto_quebrado(jg["desc"], r.position + Vector2(122, 40), r.size.x - 136, 14, Color8(220, 210, 230), 2)
		botao(Rect2(r.end.x - 120, r.end.y - 50, 108, 40), "Jogar", VERMELHO, true, true)
	desenhar_abas()


# ============================================================ prêmio de beta tester (12/11)
# Sem servidor: um código de presente (Ajustes → Código de presente) abre o
# Baú do Beta Tester: a skin exclusiva Pioneiro, 1 skin da loja à escolha,
# o selo "Beta Tester" e 100 fragmentos. Vale uma vez por aparelho.
# Um código por pessoa. Aqui fica só a impressão digital (sha256 do código
# sem hífen, em maiúsculas), para os códigos não aparecerem no repositório
# público. Gerar novos com godot/ferramentas/codigo_beta.py.
const CODIGOS_BETA := {
	"6ecd6c57a6a636332edbc2a1389ccdccb0ccb6e04c2646b432df28a835139382": "Ludivicky",
}
const SKINS_BETA := ["gelo", "ouro", "sombrio", "brasa"]


func ret_skin_beta(i: int) -> Rect2:
	return Rect2(24 + (i % 2) * 222, 430 + (i / 2) * 140, 210, 128)


func pedir_codigo() -> void:
	var c := ""
	if OS.has_feature("web"):
		c = str(JavaScriptBridge.eval("window.prompt(%s, '') || ''" % JSON.stringify(tx("Digite o código de presente:"))))
	else:
		c = DisplayServer.clipboard_get()
	c = c.strip_edges().to_upper().replace(" ", "").replace("-", "")
	if c == "":
		if not OS.has_feature("web"):
			popup = {"titulo": "CÓDIGO DE PRESENTE", "texto": "Copie o código e depois toque aqui."}
		return
	var nome_beta: String = CODIGOS_BETA.get(c.sha256_text(), "")
	if nome_beta == "":
		popup = {"titulo": "CÓDIGO DE PRESENTE", "texto": "Esse código não existe. Confira as letras e tente de novo."}
		som("dano")
		return
	if prog.get("beta", "") == "pronto":
		popup = {"titulo": "CÓDIGO DE PRESENTE", "texto": "O Baú do Beta Tester já foi aberto neste aparelho. Obrigado por testar!"}
		return
	prog["beta"] = "escolher"
	prog["beta_nome"] = nome_beta
	var cp: Dictionary = prog.get("compras", {})
	cp["skin_pioneiro"] = "beta"
	prog["compras"] = cp
	if prog.get("beta_frag", false) == false:
		prog["beta_frag"] = true
		prog["fragmentos"] = int(prog["fragmentos"]) + 100
	salvar()
	som("chefe")
	tremer(0.4, 200)
	ir_para("beta")


func clique_beta(p: Vector2) -> void:
	for i in SKINS_BETA.size():
		if ret_skin_beta(i).has_point(p):
			var sk: String = SKINS_BETA[i]
			var cp: Dictionary = prog.get("compras", {})
			cp["skin_" + sk] = "beta"
			prog["compras"] = cp
			prog["skin"] = sk
			prog["beta"] = "pronto"
			salvar()
			som("nivel")
			ir_para("loja")
			popup = {"titulo": (tx("OBRIGADO, %s!") % str(prog.get("beta_nome", "")).to_upper()) if str(prog.get("beta_nome", "")) != "" else "OBRIGADO, BETA TESTER!", "texto": tx("Você ganhou a skin %s e a Pioneiro. Troque quando quiser aqui na Loja.") % tx(item_loja("skin_" + sk)["nome"])}
			return


func desenhar_beta() -> void:
	desenhar_fundo(0.6)
	brilho_suave(Vector2(LARG / 2, 190), 200, Color8(90, 255, 160), 0.6 + 0.2 * sin(tempo * 2))
	escrever("BAÚ DO BETA TESTER", Vector2(LARG / 2, 50), 24, OURO, true, fonte_titulo)
	if str(prog.get("beta_nome", "")) != "":
		escrever(tx("Para %s") % prog["beta_nome"], Vector2(LARG / 2, 84), 18, Color8(170, 255, 200), true)
	var c := Vector2(LARG / 2 - 90, 185)
	brilho_suave(c, 70, OURO, 1.0 + 0.3 * sin(tempo * 4))
	caixa(Rect2(c + Vector2(-44, -8), Vector2(88, 52)), Color8(110, 70, 36), 6, 2, TINTA)
	caixa(Rect2(c + Vector2(-48, -40), Vector2(96, 34)), Color8(140, 90, 46), 10, 2, TINTA)
	draw_rect(Rect2(c + Vector2(-8, -14), Vector2(16, 22)), OURO)
	brilho_suave(Vector2(LARG / 2 + 90, 190), 70, Color8(90, 255, 160), 1.0)
	draw_texture_rect(textura_skin("pioneiro", "kravenox"), Rect2(Vector2(LARG / 2 + 30, 100), Vector2(120, 150)), false)
	var linhas := ["Skin exclusiva: Kravenox Pioneiro", "Selo de Beta Tester", "100 fragmentos", "1 skin da loja à sua escolha"]
	for i in linhas.size():
		escrever("+ " + tx(linhas[i]), Vector2(LARG / 2, 290 + i * 26), 16, Color8(170, 255, 200) if i < 3 else OURO, true)
	escrever("Escolha a sua skin de presente:", Vector2(LARG / 2, 410), 17, BRANCO, true, fonte_titulo)
	for i in SKINS_BETA.size():
		var r := ret_skin_beta(i)
		var it := item_loja("skin_" + SKINS_BETA[i])
		caixa(r, Color(0.06, 0.05, 0.08, 0.95), 12, 2, Color(it["cor"], 0.9), true, 6)
		brilho_suave(r.position + Vector2(r.size.x / 2, 52), 50, it["cor"], 0.7 + 0.2 * sin(tempo * 3 + i))
		draw_texture_rect(textura_skin(SKINS_BETA[i], "kravenox-passo-0"), Rect2(r.position + Vector2(r.size.x / 2 - 40, 8), Vector2(80, 74)), false)
		escrever(it["nome"], r.position + Vector2(r.size.x / 2, 104), 15, it["cor"].lightened(0.3), true)


# ============================================================ Duelo ao vivo (12/11)
# O ÚNICO modo que usa internet. Dois jogadores entram numa sala (código de 4
# letras) no servidor da Cloudflare (servidor-duelo/), começam juntos contra a
# mesma horda (mesma semente), cada um com o seu nível, e veem a torre e a onda
# do outro ao vivo. A cada 12 monstros espantados vão 2 monstros para o outro.
# Quem tiver a torre de pé por mais tempo vence.
const SERVIDOR_DUELO := "wss://kravenox-duelo.kravenox.workers.dev"
const LETRAS_SALA := "ABCDEFGHJKMNPQRSTUVWXYZ23456789"
var ws: WebSocketPeer = null
var duelo := {}          # {"codigo", "fase", "nomes", "voce", "op", "msg", "conta"}
var servidor_duelo := SERVIDOR_DUELO


func nome_duelo() -> String:
	return str(prog.get("nome_duelo", ""))


func pedir_nome_duelo() -> bool:
	if nome_duelo() != "":
		return true
	var n := "Jogador"
	if OS.has_feature("web"):
		n = str(JavaScriptBridge.eval("window.prompt(%s, '') || ''" % JSON.stringify(tx("Seu nome no online (os outros jogadores vão ver):"))))
	n = n.strip_edges().substr(0, 16)
	if n == "":
		return false
	prog["nome_duelo"] = n
	salvar()
	return true


func conectar_duelo(codigo: String) -> void:
	sair_duelo()
	if "SUBDOMINIO" in servidor_duelo:
		duelo = {"fase": "erro", "msg": "O servidor do duelo ainda não está no ar."}
		return
	ws = WebSocketPeer.new()
	var url := "%s/sala/%s?nome=%s" % [servidor_duelo, codigo, nome_duelo().uri_encode()]
	if ws.connect_to_url(url) != OK:
		ws = null
		duelo = {"fase": "erro", "msg": "Sem internet: o Duelo ao vivo precisa de internet."}
		return
	duelo = {"codigo": codigo, "fase": "conectando", "nomes": [], "voce": 0, "op": {}, "msg": "", "t_conexao": 0.0}


func criar_sala() -> void:
	if not pedir_nome_duelo():
		return
	var c := ""
	for _i in 4:
		c += LETRAS_SALA[randi() % LETRAS_SALA.length()]
	conectar_duelo(c)


func entrar_sala() -> void:
	if not pedir_nome_duelo():
		return
	var c := ""
	if OS.has_feature("web"):
		c = str(JavaScriptBridge.eval("window.prompt(%s, '') || ''" % JSON.stringify(tx("Código da sala (4 letras):"))))
	else:
		c = DisplayServer.clipboard_get()
	c = c.strip_edges().to_upper().replace(" ", "")
	if c.length() != 4:
		if c != "":
			popup = {"titulo": "DUELO AO VIVO", "texto": "O código da sala tem 4 letras."}
		return
	conectar_duelo(c)


func sair_duelo() -> void:
	if ws != null:
		ws.close()
	ws = null
	duelo = {}


func enviar_duelo(m: Dictionary) -> void:
	if ws != null and ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		ws.send_text(JSON.stringify(m))


func nome_op() -> String:
	var nomes: Array = duelo.get("nomes", [])
	var v := int(duelo.get("voce", 0))
	return str(nomes[1 - v]) if nomes.size() > 1 else tx("o outro")


func atualizar_duelo(dt: float) -> void:
	if ws == null:
		return
	ws.poll()
	var st := ws.get_ready_state()
	if st == WebSocketPeer.STATE_CONNECTING:
		duelo["t_conexao"] = float(duelo.get("t_conexao", 0.0)) + dt
		if duelo["t_conexao"] > 10.0:
			sair_duelo()
			duelo = {"fase": "erro", "msg": "Não deu para conectar. Confira a internet e tente de novo."}
		return
	if st == WebSocketPeer.STATE_CLOSED:
		var jogando: bool = tela == "especial" and esp.get("id", "") == "duelo" and esp.get("fim", "") == ""
		ws = null
		if jogando:
			duelo["fase"] = "fim"
			terminar_modo(false)
			esp["motivo"] = "conexao"
		elif duelo.get("fase", "") != "erro":
			duelo = {"fase": "erro", "msg": "A conexão caiu. Confira a internet e tente de novo."}
		return
	while ws.get_available_packet_count() > 0:
		var m = JSON.parse_string(ws.get_packet().get_string_from_utf8())
		if m is Dictionary:
			mensagem_duelo(m)


func mensagem_duelo(m: Dictionary) -> void:
	match str(m.get("t", "")):
		"sala":
			duelo["nomes"] = m["nomes"]
			duelo["voce"] = int(m["voce"])
			if duelo.get("fase", "") in ["conectando", "esperando", "dois"]:
				duelo["fase"] = "dois" if Array(m["nomes"]).size() == 2 else "esperando"
				if duelo["fase"] == "dois":
					som("gema")
		"erro":
			var msg := str(m.get("msg", ""))
			sair_duelo()
			duelo = {"fase": "erro", "msg": "Essa sala já está cheia." if msg == "sala cheia" else msg}
		"comecar":
			duelo["fase"] = "contagem"
			duelo["conta"] = 3.0
			duelo["semente"] = int(m["semente"])
			duelo["op"] = {"torre": 100, "onda": 1, "mortes": 0}
			som("chefe")
		"op":
			duelo["op"] = m
		"ataque":
			if tela == "especial" and esp.get("id", "") == "duelo" and esp["fim"] == "":
				for _i in int(m.get("n", 1)):
					var mx := nasce(["larva", "verme"][randi() % 2], borda(["cima", "baixo", "esq", "dir"].pick_random()), 0.8 * pow(1.16, int(esp["onda"]) - 1))
					mx["extra"] = true   # veio do outro: não segura a onda nem conta para mandar de volta
				aviso(tx("%s mandou monstros!") % nome_op(), 2.0)
				tremer(0.2, 60)
		"caiu":
			if tela == "especial" and esp.get("id", "") == "duelo" and esp["fim"] == "":
				esp["motivo"] = "op_caiu"
				terminar_modo(true)
		"saiu":
			if tela == "especial" and esp.get("id", "") == "duelo" and esp["fim"] == "":
				esp["motivo"] = "op_saiu"
				terminar_modo(true)
			else:
				duelo["fase"] = "esperando"
				duelo["nomes"] = [nome_duelo()]


# Na tela da sala: a contagem 3, 2, 1 e a largada.
func atualizar_sala(dt: float) -> void:
	if duelo.get("fase", "") == "contagem":
		duelo["conta"] -= dt
		if duelo["conta"] <= 0:
			duelo["fase"] = "jogando"
			comecar_modo("duelo")


func ret_duelo(n: int) -> Rect2:
	return [Rect2(90, 380, 300, 58), Rect2(90, 452, 300, 58), Rect2(90, 560, 300, 58), Rect2(90, 632, 300, 50)][n]


func clique_duelo(p: Vector2) -> void:
	var fase := str(duelo.get("fase", ""))
	if fase == "" or fase == "erro":
		if ret_duelo(0).has_point(p):
			criar_sala()
		elif ret_duelo(1).has_point(p):
			entrar_sala()
		return
	if fase == "dois" and ret_duelo(2).has_point(p):
		enviar_duelo({"t": "pronto"})
		duelo["fase"] = "pronto"
		som("gema")
	elif ret_duelo(3).has_point(p):
		sair_duelo()


func desenhar_duelo() -> void:
	desenhar_fundo(0.65)
	cabecalho("DUELO AO VIVO")
	brilho_suave(Vector2(LARG / 2, 240), 160, VERMELHO, 0.5 + 0.1 * sin(tempo * 2))
	escrever("Só este modo usa internet. O resto do jogo funciona sem ela.", Vector2(LARG / 2, 134), 13, Color8(150, 220, 170))
	texto_quebrado("Os dois enfrentam a mesma horda ao mesmo tempo, cada um com o seu nível. A cada 12 monstros espantados, 2 vão para o outro. Quem segurar a torre por mais tempo vence.", Vector2(40, 160), LARG - 80, 15, BRANCO, 4, true)
	var fase := str(duelo.get("fase", ""))
	match fase:
		"", "erro":
			if fase == "erro":
				texto_quebrado(str(duelo["msg"]), Vector2(40, 290), LARG - 80, 15, Color8(255, 150, 140), 3, true)
			botao(ret_duelo(0), "Criar sala", VERMELHO, true, true)
			botao(ret_duelo(1), "Entrar com código", AZUL, true, false)
			if nome_duelo() != "":
				escrever(tx("Seu nome: %s") % nome_duelo(), Vector2(LARG / 2, 540), 14, CINZA, false)
		"conectando":
			escrever("Conectando…", Vector2(LARG / 2, 400), 20, BRANCO, true)
			botao(ret_duelo(3), "Sair", CINZA, true, false)
		_:
			escrever("CÓDIGO DA SALA", Vector2(LARG / 2, 300), 14, CINZA, true, fonte_titulo)
			escrever(str(duelo.get("codigo", "")), Vector2(LARG / 2, 350), 56, OURO, true, fonte_titulo)
			var nomes: Array = duelo.get("nomes", [])
			if nomes.size() < 2:
				escrever("Mande o código para o seu amigo e espere ele entrar…", Vector2(LARG / 2, 420), 15, BRANCO, true)
				escrever(".".repeat(1 + int(tempo * 2) % 3), Vector2(LARG / 2, 450), 22, OURO, false)
			else:
				escrever("%s  ×  %s" % [nomes[0], nomes[1]], Vector2(LARG / 2, 430), 22, BRANCO, true, fonte_titulo)
			match fase:
				"dois":
					botao(ret_duelo(2), "PRONTO!", VERMELHO, true, true)
				"pronto":
					escrever(tx("Esperando %s ficar pronto…") % nome_op(), Vector2(LARG / 2, 590), 16, OURO, true)
				"contagem":
					escrever(str(int(ceilf(duelo["conta"]))), Vector2(LARG / 2, 590), 64, VERMELHO, true, fonte_titulo)
			botao(ret_duelo(3), "Sair da sala", CINZA, true, false)
	desenhar_abas()
	desenhar_popup()


# ============================================================ baú de cada fase (13/11)
# No fim de cada fase dos capítulos: 1 ou 2 fragmentos e uma chance de skin
# que começa em 1% e sobe 1% a cada baú sem skin; em 100% a skin é garantida.
# A skin vem entre as da loja que a pessoa ainda não tem e já fica em uso.
var skin_ganha := ""
var skin_ganha_t := 0.0


func chance_skin() -> int:
	return clampi(int(prog.get("chance_skin", 1)), 1, 100)


func skins_faltando() -> Array:
	return ["gelo", "ouro", "sombrio", "brasa"].filter(func(sk): return not tem("skin_" + sk))


func bau_de_fase() -> void:
	if tipo_partida != "capitulo" or em_risco:
		return
	var frag := 1 + (1 if randf() < 0.3 else 0)
	if pesadelo_ativo():
		frag *= 2   # Pesadelo: fragmentos em dobro também no baú
	prog["fragmentos"] = int(prog["fragmentos"]) + frag
	premio_fim += 0
	var faltam := skins_faltando()
	var ch := chance_skin()
	if not faltam.is_empty() and (randi() % 100 < ch or ch >= 100):
		var sk: String = faltam.pick_random()
		var cp: Dictionary = prog.get("compras", {})
		cp["skin_" + sk] = "bau"
		prog["compras"] = cp
		prog["skin"] = sk
		prog["chance_skin"] = 1
		skin_ganha = sk
		skin_ganha_t = 4.5
		som("chefe")
		tremer(0.4, 200)
	else:
		if not faltam.is_empty():
			prog["chance_skin"] = mini(100, ch + (2 if pesadelo_ativo() else 1))   # no Pesadelo sobe 2% por baú
		texto_voa(Vector2(LARG / 2, 150), tx("Baú da fase: +%d fragmentos") % frag, OURO, 16)
	salvar()


func desenhar_skin_ganha() -> void:
	if skin_ganha_t <= 0 or skin_ganha == "":
		return
	skin_ganha_t -= 0.016
	var a := clampf(skin_ganha_t * 2, 0, 1)
	var it := item_loja("skin_" + skin_ganha)
	var r := Rect2(40, 210, LARG - 80, 230)
	caixa(r, Color(0.06, 0.04, 0.09, 0.95 * a), 14, 3, Color(OURO, a), true, 8)
	brilho_suave(r.get_center() + Vector2(0, 10), 140, it["cor"], 1.2 * a)
	escrever("BAÚ RARO!", r.position + Vector2(r.size.x / 2, 30), 24, Color(OURO, a), true, fonte_titulo)
	draw_texture_rect(textura_skin(skin_ganha, "kravenox-passo-0"), Rect2(r.get_center() + Vector2(-50, -60), Vector2(100, 92)), false, Color(1, 1, 1, a))
	escrever(tx("Você ganhou a skin %s!") % tx(it["nome"]), r.position + Vector2(r.size.x / 2, 180), 17, Color(BRANCO, a), true)
	escrever("Já está em uso. Troque na Loja.", r.position + Vector2(r.size.x / 2, 206), 13, Color(CINZA, a), false)


# ============================================================ online: ranking semanal e Ordem (13/11)
# Usa o mesmo servidor da Cloudflare do Duelo. Só esta área usa internet; se
# estiver sem internet, os recordes e os golpes ficam guardados e vão depois.
const CATS_RANKING := [["abismo", "Abismo", "onda"], ["colosso", "Colosso", "dano"], ["duelo", "Duelo", "vitórias"]]
var rank := {"cat": "abismo", "dados": {}, "carregando": false, "erro": ""}
var ordem_dados := {}
var ordem_estado := {"carregando": false, "erro": ""}
var sair_ordem_confirma := 0.0


func online_disponivel() -> bool:
	return not "SUBDOMINIO" in servidor_duelo


func url_api() -> String:
	return servidor_duelo.replace("wss://", "https://").replace("ws://", "http://") + "/api"


func id_jogador() -> String:
	if str(prog.get("id_jogador", "")) == "":
		var c := ""
		for _i in 20:
			c += "abcdefghijklmnopqrstuvwxyz0123456789"[randi() % 36]
		prog["id_jogador"] = c
		salvar()
	return prog["id_jogador"]


func nome_online() -> String:
	return nome_duelo() if nome_duelo() != "" else "Jogador"


func chamar_api(metodo: String, caminho: String, corpo := {}) -> Dictionary:
	var h := HTTPRequest.new()
	h.timeout = 8.0
	add_child(h)
	var post := metodo == "POST"
	var err := h.request(url_api() + caminho, ["Content-Type: application/json"], HTTPClient.METHOD_POST if post else HTTPClient.METHOD_GET, JSON.stringify(corpo) if post else "")
	if err != OK:
		h.queue_free()
		return {"erro": "sem internet"}
	var r = await h.request_completed
	h.queue_free()
	if r[0] != HTTPRequest.RESULT_SUCCESS:
		return {"erro": "sem internet"}
	var d = JSON.parse_string(PackedByteArray(r[3]).get_string_from_utf8())
	return d if d is Dictionary else {"erro": "resposta inválida"}


func enviar_online(item: Dictionary) -> void:
	if not online_disponivel() or robo:
		return
	var r: Dictionary
	if item["tipo"] == "recorde":
		r = await chamar_api("POST", "/recorde", {"id": id_jogador(), "nome": nome_online(), "cat": item["cat"], "valor": item["valor"], "skin": skin_atual()})
	else:
		r = await chamar_api("POST", "/ordem/%s/dano" % item["codigo"], {"id": id_jogador(), "dano": item["golpes"]})
		if not r.has("erro") and tela == "ordem":
			ordem_dados = r
	if str(r.get("erro", "")) == "sem internet":
		var pend: Array = prog.get("pendentes_online", [])
		if pend.size() < 50:
			pend.append(item)
		prog["pendentes_online"] = pend
		salvar()


func reenviar_pendentes() -> void:
	var pend: Array = prog.get("pendentes_online", [])
	if pend.is_empty():
		return
	prog["pendentes_online"] = []
	salvar()
	for item in pend:
		enviar_online(item)


func enviar_recorde(cat: String, valor: int) -> void:
	if valor > 0:
		enviar_online({"tipo": "recorde", "cat": cat, "valor": valor})


# Golpes no Gigante da Ordem: o dano do Colosso dividido pelo dano básico (o nível não pesa demais).
func golpes_colosso(dano: float) -> int:
	return int(dano / (14.0 * (1.0 + cresce_esp()) * mult_dano()))


# ------------------------------------------------------------ telas
func carregar_ranking() -> void:
	rank["carregando"] = true
	rank["erro"] = ""
	reenviar_pendentes()
	var r := await chamar_api("GET", "/ranking?cat=%s&id=%s" % [rank["cat"], id_jogador()])
	rank["carregando"] = false
	if r.has("erro"):
		rank["erro"] = "Sem internet: o ranking precisa de internet." if r["erro"] == "sem internet" else str(r["erro"])
		return
	rank["dados"] = r
	for c in r.get("campeoes", []):
		if c.get("eu", false) and int(c["pos"]) == 1:
			prog["titulo"] = tx("Soberano da Semana") + " (" + tx(nome_cat(rank["cat"])) + ")"
			salvar()


func nome_cat(cat: String) -> String:
	for c in CATS_RANKING:
		if c[0] == cat:
			return c[1]
	return cat


func carregar_ordem() -> void:
	var cod := str(prog.get("ordem", ""))
	if cod == "":
		return
	ordem_estado["carregando"] = true
	ordem_estado["erro"] = ""
	reenviar_pendentes()
	var r := await chamar_api("GET", "/ordem/%s?id=%s" % [cod, id_jogador()])
	ordem_estado["carregando"] = false
	if r.has("erro"):
		if r["erro"] == "Ordem não encontrada":
			prog.erase("ordem")
			salvar()
		ordem_estado["erro"] = "Sem internet: a Ordem precisa de internet." if r["erro"] == "sem internet" else str(r["erro"])
		return
	ordem_dados = r


func criar_ordem() -> void:
	if not pedir_nome_duelo():
		return
	var n := "Ordem do Cisma"
	if OS.has_feature("web"):
		n = str(JavaScriptBridge.eval("window.prompt(%s, '') || ''" % JSON.stringify(tx("Nome da sua Ordem:"))))
	n = n.strip_edges()
	if n == "":
		return
	ordem_estado["carregando"] = true
	var r := await chamar_api("POST", "/ordem/criar", {"id": id_jogador(), "nome": nome_online(), "ordem": n})
	ordem_estado["carregando"] = false
	if r.has("erro"):
		ordem_estado["erro"] = "Sem internet: a Ordem precisa de internet." if r["erro"] == "sem internet" else str(r["erro"])
		return
	prog["ordem"] = r["codigo"]
	salvar()
	ordem_dados = r
	som("nivel")


func entrar_ordem() -> void:
	if not pedir_nome_duelo():
		return
	var c := ""
	if OS.has_feature("web"):
		c = str(JavaScriptBridge.eval("window.prompt(%s, '') || ''" % JSON.stringify(tx("Código da Ordem (5 letras):"))))
	else:
		c = DisplayServer.clipboard_get()
	c = c.strip_edges().to_upper().replace(" ", "")
	if c.length() != 5:
		if c != "":
			popup = {"titulo": "ORDEM", "texto": "O código da Ordem tem 5 letras."}
		return
	ordem_estado["carregando"] = true
	var r := await chamar_api("POST", "/ordem/%s/entrar" % c, {"id": id_jogador(), "nome": nome_online()})
	ordem_estado["carregando"] = false
	if r.has("erro"):
		ordem_estado["erro"] = "Sem internet: a Ordem precisa de internet." if r["erro"] == "sem internet" else str(r["erro"])
		return
	prog["ordem"] = c
	salvar()
	ordem_dados = r
	som("nivel")


func sair_da_ordem() -> void:
	var cod := str(prog.get("ordem", ""))
	prog.erase("ordem")
	salvar()
	ordem_dados = {}
	sair_ordem_confirma = 0.0
	if cod != "":
		chamar_api("POST", "/ordem/%s/sair" % cod, {"id": id_jogador()})


func pegar_premio_ordem() -> void:
	var sem := str(ordem_dados.get("semana", ""))
	if not ordem_dados.get("derrubado", false) or prog.get("ordem_premio", "") == sem:
		return
	prog["ordem_premio"] = sem
	prog["chance_skin"] = mini(100, chance_skin() + 5)
	ganhar(30 + 2 * mundo_de(int(prog["liberado"])), "GIGANTE DERRUBADO!")
	popup["extra"] = tx("+5% de chance de skin no baú das fases")


func ret_online(n: int) -> Rect2:
	return Rect2(24, 200 + n * 130, LARG - 48, 116)


func desenhar_online() -> void:
	desenhar_fundo(0.65)
	cabecalho("ONLINE")
	escrever("Só esta área usa internet. O resto do jogo funciona sem ela.", Vector2(LARG / 2, 134), 13, Color8(150, 220, 170))
	escrever(tx("Seu nome: %s") % nome_online() + "  ·  " + tx("toque para trocar"), Vector2(LARG / 2, 166), 14, CINZA, false)
	var itens := [["ranking", "Ranking semanal", "Os melhores da semana no Abismo, no Colosso e no Duelo. Toda segunda recomeça; o 1º vira Soberano da Semana."],
		["ordem", "Ordem", "O seu clã. Toda semana, derrubem juntos o Gigante do Vazio: cada partida no Colosso conta. Prêmio para todos."],
		["duelo", "Duelo ao vivo", "Você contra um amigo, ao mesmo tempo, contra a mesma horda."]]
	for i in itens.size():
		var r := ret_online(i)
		caixa(r, Color(0.06, 0.05, 0.08, 0.93), 12, 1, Color(OURO, 0.7), true, 6)
		icone_modo({"ranking": "desafio", "ordem": "horda", "duelo": "duelo"}[itens[i][0]], r.position + Vector2(48, 58), true)
		escrever_esq(itens[i][1], r.position + Vector2(92, 34), 18, OURO, fonte_titulo)
		texto_quebrado(itens[i][2], r.position + Vector2(92, 42), r.size.x - 108, 13, Color8(220, 210, 230), 3)
	desenhar_abas()
	desenhar_popup()


func clique_online(p: Vector2) -> void:
	if p.y > 150 and p.y < 182:
		prog["nome_duelo"] = ""
		pedir_nome_duelo()
		return
	for i in 3:
		if ret_online(i).has_point(p):
			som("gema")
			match i:
				0:
					ir_para("ranking")
					carregar_ranking()
				1:
					ir_para("ordem")
					carregar_ordem()
				2:
					ir_para("duelo")
			return


func desenhar_ranking() -> void:
	desenhar_fundo(0.7)
	cabecalho("RANKING SEMANAL")
	for i in CATS_RANKING.size():
		var r := Rect2(16 + i * 150, 118, 144, 40)
		botao(r, CATS_RANKING[i][1], OURO, true, rank["cat"] == CATS_RANKING[i][0])
	var d: Dictionary = rank["dados"]
	if rank["carregando"]:
		escrever("Carregando…", Vector2(LARG / 2, 300), 18, BRANCO, true)
	elif rank["erro"] != "":
		texto_quebrado(rank["erro"], Vector2(40, 280), LARG - 80, 16, Color8(255, 150, 140), 3, true)
	elif not d.is_empty():
		var unidade: String = CATS_RANKING[CATS_RANKING.map(func(c): return c[0]).find(rank["cat"])][2]
		escrever(tx("Semana %s · %d jogadores") % [str(d.get("semana", "")).substr(6), int(d.get("total", 0))], Vector2(LARG / 2, 176), 13, CINZA, false)
		var top: Array = d.get("top", [])
		if top.is_empty():
			escrever("Ninguém jogou esta semana ainda. Seja o primeiro!", Vector2(LARG / 2, 260), 15, BRANCO, true)
		for k in mini(top.size(), 12):
			var l: Dictionary = top[k]
			var y := 192 + k * 36
			var eu: bool = l.get("eu", false)
			caixa(Rect2(16, y, LARG - 32, 32), Color8(50, 36, 20) if eu else Color(0.06, 0.05, 0.08, 0.9), 6, 1, OURO if eu else Color(PEDRA_BORDA, 0.8))
			var cor_pos: Color = [OURO, Color8(200, 200, 215), Color8(205, 130, 70)][int(l["pos"]) - 1] if int(l["pos"]) <= 3 else CINZA
			escrever_esq("%dº" % int(l["pos"]), Vector2(28, y + 22), 16, cor_pos, fonte_titulo)
			escrever_esq(str(l["nome"]), Vector2(76, y + 22), 16, BRANCO)
			var v := "%d %s" % [int(l["valor"]), tx(unidade)]
			var wv := fonte.get_string_size(v, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
			escrever_esq(v, Vector2(LARG - 28 - wv, y + 22), 15, OURO)
		var minha := int(d.get("minha_pos", 0))
		escrever(tx("Sua posição: %dº") % minha if minha > 0 else tx("Você ainda não jogou esta categoria nesta semana"), Vector2(LARG / 2, 640), 15, OURO if minha > 0 else CINZA, true)
		var camp: Array = d.get("campeoes", [])
		if not camp.is_empty():
			var nomes := []
			for c in camp:
				nomes.append("%dº %s" % [int(c["pos"]), c["nome"]])
			escrever(tx("Semana passada: ") + "  ".join(nomes), Vector2(LARG / 2, 668), 13, Color8(200, 170, 255), false)
	botao(Rect2(LARG / 2 - 70, 688, 140, 40), "Atualizar", AZUL, true, false)
	desenhar_abas()


func clique_ranking(p: Vector2) -> void:
	for i in CATS_RANKING.size():
		if Rect2(16 + i * 150, 118, 144, 40).has_point(p):
			rank["cat"] = CATS_RANKING[i][0]
			rank["dados"] = {}
			carregar_ranking()
			return
	if Rect2(LARG / 2 - 70, 688, 140, 40).has_point(p):
		carregar_ranking()


func desenhar_ordem() -> void:
	desenhar_fundo(0.68)
	cabecalho("ORDEM")
	sair_ordem_confirma = maxf(0.0, sair_ordem_confirma - 0.016)
	var d := ordem_dados
	if str(prog.get("ordem", "")) == "":
		texto_quebrado("Uma Ordem é o seu clã. Toda semana nasce um Gigante do Vazio para a Ordem inteira: cada partida no Colosso conta golpes. Derrubando, todos ganham fragmentos e mais chance de skin.", Vector2(36, 140), LARG - 72, 15, BRANCO, 6, true)
		botao(Rect2(90, 330, 300, 58), "Criar uma Ordem", VERMELHO, true, true)
		botao(Rect2(90, 402, 300, 58), "Entrar com código", AZUL, true, false)
	elif ordem_estado["carregando"] and d.is_empty():
		escrever("Carregando…", Vector2(LARG / 2, 300), 18, BRANCO, true)
	elif d.is_empty():
		texto_quebrado(str(ordem_estado["erro"]), Vector2(40, 280), LARG - 80, 16, Color8(255, 150, 140), 3, true)
		botao(Rect2(LARG / 2 - 70, 380, 140, 40), "Tentar de novo", AZUL, true, false)
	else:
		escrever(str(d["nome"]), Vector2(LARG / 2, 140), 24, OURO, true, fonte_titulo)
		escrever(tx("Código para convidar: %s") % str(d["codigo"]), Vector2(LARG / 2, 172), 16, BRANCO, true)
		# o Gigante da semana
		var vida := float(d["gigante_vida"])
		var feito := float(d["gigante_golpes"])
		brilho_suave(Vector2(LARG / 2, 260), 80, ROXO, 0.6)
		desenhar_arte("sentinela", Vector2(LARG / 2, 300), 96, false, Color(0.55, 0.38, 0.85) if not d["derrubado"] else Color(0.3, 0.3, 0.35))
		var barra := Rect2(40, 312, LARG - 80, 18)
		caixa(barra, Color8(20, 16, 26), 6, 1, Color(ROXO, 0.7))
		degrade(Rect2(barra.position + Vector2(2, 2), Vector2((barra.size.x - 4) * clampf(1.0 - feito / vida, 0, 1), 14)), Color8(170, 90, 255), Color8(80, 30, 140))
		escrever(tx("Gigante da semana: %d / %d golpes") % [int(feito), int(vida)] if not d["derrubado"] else tx("GIGANTE DERRUBADO!"), Vector2(LARG / 2, 346), 15, OURO if d["derrubado"] else BRANCO, true)
		var membros: Array = d["membros"]
		for k in mini(membros.size(), 8):
			var m: Dictionary = membros[k]
			var y := 366 + k * 30
			escrever_esq(("➤ " if m.get("eu", false) else "") + str(m["nome"]), Vector2(48, y + 20), 15, OURO if m.get("eu", false) else BRANCO)
			var g := tx("%d golpes") % int(m["golpes"])
			escrever_esq(g, Vector2(LARG - 48 - fonte.get_string_size(g, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x, y + 20), 14, CINZA)
		if membros.size() > 8:
			escrever(tx("+ %d membros") % (membros.size() - 8), Vector2(LARG / 2, 612), 13, CINZA, false)
		if d["derrubado"] and prog.get("ordem_premio", "") != str(d["semana"]):
			botao(Rect2(90, 622, 300, 50), "Pegar a recompensa!", OURO, true, true)
		else:
			botao(Rect2(90, 622, 300, 50), "Lutar no Colosso", VERMELHO, true, true)
		botao(Rect2(LARG / 2 - 90, 684, 180, 36), "Toque de novo para sair" if sair_ordem_confirma > 0 else "Sair da Ordem", CINZA, true, sair_ordem_confirma > 0)
	desenhar_abas()
	desenhar_popup()


func clique_ordem(p: Vector2) -> void:
	if str(prog.get("ordem", "")) == "":
		if Rect2(90, 330, 300, 58).has_point(p):
			criar_ordem()
		elif Rect2(90, 402, 300, 58).has_point(p):
			entrar_ordem()
		return
	if ordem_dados.is_empty():
		if Rect2(LARG / 2 - 70, 380, 140, 40).has_point(p):
			carregar_ordem()
		return
	if Rect2(90, 622, 300, 50).has_point(p):
		if ordem_dados["derrubado"] and prog.get("ordem_premio", "") != str(ordem_dados["semana"]):
			pegar_premio_ordem()
		elif int(prog["liberado"]) >= 10:
			comecar_modo("colosso")
		else:
			popup = {"titulo": "ORDEM", "texto": "O Colosso abre no capítulo 10. Até lá, ajude a Ordem avançando nos capítulos."}
	elif Rect2(LARG / 2 - 90, 684, 180, 36).has_point(p):
		if sair_ordem_confirma > 0:
			sair_da_ordem()
		else:
			sair_ordem_confirma = 3.0
