#!/usr/bin/env bash
# funcoeszz
#
# INFORMAÇÕES: http://www.funcoeszz.net
# NASCIMENTO : 22 de Fevereiro de 2000
# AUTORES    : Aurelio Marinho Jargas <verde (a) aurelio net>
#              Itamar Santos de Souza <itamarnet (a) yahoo com br>
#              Thobias Salazar Trevisan <thobias (a) thobias org>
# DESCRIÇÃO  : Funções de uso geral para o shell Bash, que buscam
#              informações em arquivos locais e fontes na Internet
# LICENÇA    : GPLv2
# CHANGELOG  : http://www.funcoeszz.net/changelog.html
#
ZZVERSAO=18.3
ZZUTF=1
#
##############################################################################
#
#                                Configuração
#                                ------------
#
#
### Configuração via variáveis de ambiente
#
# Algumas variáveis de ambiente podem ser usadas para alterar o comportamento
# padrão das funções. Basta defini-las em seu .bashrc ou na própria linha de
# comando antes de chamar as funções. São elas:
#
#      $ZZCOR      - Liga/Desliga as mensagens coloridas (1 e 0)
#      $ZZPATH     - Caminho completo para o arquivo principal (funcoeszz)
#      $ZZDIR      - Caminho completo para o diretório com as funções
#      $ZZTMPDIR   - Diretório para armazenar arquivos temporários
#      $ZZOFF      - Lista das funções que você não quer carregar
#
# Nota: Se você é paranóico com segurança, configure a ZZTMPDIR para
#       um diretório dentro do seu HOME.
#
### Configuração fixa neste arquivo (hardcoded)
#
# A configuração também pode ser feita diretamente neste arquivo, se você
# puder fazer alterações nele.
#
ZZCOR_DFT=1                       # colorir mensagens? 1 liga, 0 desliga
ZZPATH_DFT="/usr/bin/funcoeszz"   # rota absoluta deste arquivo
ZZDIR_DFT="$HOME/zz"              # rota absoluta do diretório com as funções
ZZTMPDIR_DFT="${TMPDIR:-/tmp}"    # diretório temporário
#
#
##############################################################################
#
#                               Inicialização
#                               -------------
#
#
# Variáveis auxiliares usadas pelas Funções ZZ.
# Não altere nada aqui.
#
#

# shellcheck disable=SC2034
ZZSEDURL='s| |+|g;s|&|%26|g;s|@|%40|g'
ZZCODIGOCOR='36;1'            # use zzcores para ver os códigos
ZZBASE='zzajuda zztool zzzz'  # Funções essenciais, guardadas neste script

#
### Truques para descobrir a localização deste arquivo no sistema
#
# Se a chamada foi pelo executável, o arquivo é o $0.
# Senão, tenta usar a variável de ambiente ZZPATH, definida pelo usuário.
# Caso não exista, usa o local padrão ZZPATH_DFT.
# Finalmente, força que ZZPATH seja uma rota absoluta.
#
test "${0##*/}" = 'bash' -o "${0#-}" != "$0" || ZZPATH="$0"
test -n "$ZZPATH" || ZZPATH=$ZZPATH_DFT
test "${ZZPATH#/}" = "$ZZPATH" && ZZPATH="$PWD/${ZZPATH#./}"

test -d ${ZZPATH%/*}/zz && ZZDIR="${ZZPATH%/*}/zz"
test -z "$ZZDIR" && test -d $ZZDIR_DFT && ZZDIR=$ZZDIR_DFT

# Descobre qual o navegador em modo texto está disponível no sistema
if test -z "$ZZBROWSER"
then
	for ZZBROWSER in lynx links links2 elinks w3m
	do
		type "$ZZBROWSER" >/dev/null 2>&1 && break
	done
fi
export ZZBROWSER

#
### Últimos ajustes
#
ZZCOR="${ZZCOR:-$ZZCOR_DFT}"
ZZTMP="${ZZTMPDIR:-$ZZTMPDIR_DFT}"
ZZTMP="${ZZTMP%/}/zz"  # prefixo comum a todos os arquivos temporários
ZZAJUDA="$ZZTMP.ajuda"
unset ZZCOR_DFT ZZPATH_DFT ZZDIR_DFT ZZTMPDIR_DFT

#
### Forçar variáveis via linha de comando
#
while test $# -gt 0
do
	case "$1" in
		--path) ZZPATH="$2"   ; shift; shift ;;
		--dir ) ZZDIR="${2%/}"; shift; shift ;;
		--cor ) ZZCOR="$2"    ; shift; shift ;;
		*) break;;
	esac
done

#
#
##############################################################################
#
#                                Ferramentas
#                                -----------
#
#

# ----------------------------------------------------------------------------
# zztool
# Miniferramentas para auxiliar as funções.
# Uso: zztool [-e] ferramenta [argumentos]
# Ex.: zztool grep_var foo $var
#      zztool eco Minha mensagem colorida
#      zztool testa_numero $num
#      zztool -e testa_numero $num || return
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-03-01
# ----------------------------------------------------------------------------
zztool ()
{
	local erro ferramenta

	# Devo mostrar a mensagem de erro?
	test "$1" = '-e' && erro=1 && shift

	# Libera o nome da ferramenta do $1
	ferramenta="$1"
	shift

	case "$ferramenta" in
		uso)
			# Extrai a mensagem de uso da função $1, usando seu --help
			if test -n "$erro"
			then
				zzzz -h "$1" -h | grep Uso >&2
			else
				zzzz -h "$1" -h | grep Uso
			fi
		;;
		eco)
			# Mostra mensagem colorida caso $ZZCOR esteja ligada
			if test "$ZZCOR" != '1'
			then
				printf "%b\n" "$*"
			else
				printf "%b\n" "\033[${ZZCODIGOCOR}m$*\033[m"
			fi
		;;
		erro)
			# Mensagem de erro
			printf "%b\n" "$*" >&2
		;;
		acha)
			# Destaca o padrão $1 no texto via STDIN ou $2
			# O padrão pode ser uma regex no formato BRE (grep/sed)
			local esc padrao
			esc=$(printf '\033')
			padrao=$(echo "$1" | sed 's,/,\\/,g') # escapa /
			shift
			zztool multi_stdin "$@" |
				if test "$ZZCOR" != '1'
				then
					cat -
				else
					sed "s/$padrao/$esc[${ZZCODIGOCOR}m&$esc[m/g"
				fi
		;;
		grep_var)
			# $1 está presente em $2?
			test "${2#*$1}" != "$2"
		;;
		index_var)
			# $1 está em qual posição em $2?
			local padrao="$1"
			local texto="$2"
			if zztool grep_var "$padrao" "$texto"
			then
				texto="${texto%%$padrao*}"
				echo $((${#texto} + 1))
			else
				echo 0
			fi
		;;
		arquivo_vago)
			# Verifica se o nome de arquivo informado está vago
			if test -e "$1"
			then
				test -n "$erro" && echo "Arquivo $1 já existe. Abortando." >&2
				return 1
			fi
		;;
		arquivo_legivel)
			# Verifica se o arquivo existe e é legível
			if ! test -r "$1"
			then
				test -n "$erro" && echo "Não consegui ler o arquivo $1" >&2
				return 1
			fi

			# TODO Usar em *todas* as funções que lêem arquivos
		;;
		num_linhas)
			# Informa o número de linhas, sem formatação
			local linhas
			linhas=$(zztool file_stdin "$@" | sed -n '$=')
			echo "${linhas:-0}"
		;;
		nl_eof)
			# Garante que a última linha tem um \n no final
			# Necessário porque o GNU sed não adiciona o \n
			# printf abc | bsd-sed ''      #-> abc\n
			# printf abc | gnu-sed ''      #-> abc
			# printf abc | zztool nl_eof   #-> abc\n
			sed '$ { G; s/\n//g; }'
		;;
		testa_ano)
			# Testa se $1 é um ano válido: 1-9999
			# O ano zero nunca existiu, foi de -1 para 1
			# Ano maior que 9999 pesa no processamento
			echo "$1" | grep -v '^00*$' | grep '^[0-9]\{1,4\}$' >/dev/null && return 0

			test -n "$erro" && echo "Ano inválido '$1'" >&2
			return 1
		;;
		testa_numero)
			# Testa se $1 é um número positivo
			echo "$1" | grep '^[0-9]\{1,\}$' >/dev/null && return 0

			test -n "$erro" && echo "Número inválido '$1'" >&2
			return 1

			# TODO Usar em *todas* as funções que recebem números
		;;
		testa_data)
			# Testa se $1 é uma data (dd/mm/aaaa)
			local d29='\(0[1-9]\|[12][0-9]\)/\(0[1-9]\|1[012]\)'
			local d30='30/\(0[13-9]\|1[012]\)'
			local d31='31/\(0[13578]\|1[02]\)'
			echo "$1" | grep "^\($d29\|$d30\|$d31\)/[0-9]\{1,4\}$" >/dev/null && return 0

			test -n "$erro" && echo "Data inválida '$1', deve ser dd/mm/aaaa" >&2
			return 1
		;;
		multi_stdin)
			# Mostra na tela os argumentos *ou* a STDIN, nesta ordem
			# Útil para funções/comandos aceitarem dados das duas formas:
			#     echo texto | funcao
			# ou
			#     funcao texto

			if test -n "$1"
			then
				echo "$*"  # security: always quote to avoid shell expansion
			else
				cat -
			fi
		;;
		file_stdin)
			# Mostra na tela o conteúdo dos arquivos *ou* da STDIN, nesta ordem
			# Útil para funções/comandos aceitarem dados das duas formas:
			#     cat arquivo1 arquivo2 | funcao
			#     cat arquivo1 arquivo2 | funcao -
			# ou
			#     funcao arquivo1 arquivo2
			#
			# Note que o uso de - para indicar STDIN não é portável, mas esta
			# ferramenta o torna portável, pois o cat o suporta no Unix.

			cat "${@:--}"  # Traduzindo: cat $@ ou cat -
		;;
		list2lines)
			# Limpa lista da STDIN e retorna um item por linha
			# Lista: um dois três | um, dois, três | um;dois;três
			sed 's/[;,]/ /g' |
				tr -s '\t ' '  ' |
				tr ' ' '\n' |
				grep .
		;;
		lines2list)
			# Recebe linhas em STDIN e retorna: linha1 linha2 linha3
			# Ignora linhas em branco e remove espaços desnecessários
			grep . |
				tr '\n' ' ' |
				sed 's/^ // ; s/ $//'
		;;
		endereco_sed)
			# Formata um texto para ser usado como endereço no sed.
			# Números e $ não são alterados, resto fica /entre barras/
			#     foo     -> /foo/
			#     foo/bar -> /foo\/bar/

			local texto="$*"

			if zztool testa_numero "$texto" || test "$texto" = '$'
			then
				echo "$texto"  # 1, 99, $
			else
				echo "$texto" | sed 's:/:\\\/:g ; s:.*:/&/:'
			fi
		;;
		terminal_utf8)
			echo "$LC_ALL $LC_CTYPE $LANG" | grep -i utf >/dev/null
		;;
		texto_em_iso)
			if test $ZZUTF = 1
			then
				iconv -f iso-8859-1 -t utf-8 /dev/stdin
			else
				cat -
			fi
		;;
		texto_em_utf8)
			if test $ZZUTF != 1
			then
				iconv -f utf-8 -t iso-8859-1 /dev/stdin
			else
				cat -
			fi
		;;
		mktemp)
			# Cria um arquivo temporário de nome único, usando $1.
			# Lembre-se de removê-lo no final da função.
			#
			# Exemplo de uso:
			#   local tmp=$(zztool mktemp arrumanome)
			#   foo --bar > "$tmp"
			#   rm -f "$tmp"

			mktemp "${ZZTMP:-/tmp/zz}.${1:-anonimo}.XXXXXX"
		;;
		post | dump | source | list | download)
			# Estrutura do comando:
			# zztool <post|dump|source|list|download> [browser] [opções] <url> [dados_post]

			local browser input_charset output_charset output_width user_agent opt_common nbsp_utf

			# A função pode chamar um navegador específico ou assumir o padrão $ZZBROWSER
			case "$1" in
				lynx | links | links2 | elinks | w3m) browser="$1"; shift  ;;
				*                                   ) browser="$ZZBROWSER" ;;
			esac

			# Parâmetros que podem ser modificados na linha de comando.
			while test "${1#-}" != "$1"
			do
				case "$1" in
					-i) input_charset="$2";  shift; shift ;;
					-o) output_charset="$2"; shift; shift ;;
					-w) output_width="$2";   shift; shift ;;
					-u) user_agent="$2";     shift; shift ;;
					-*) break ;;
				esac
			done

			output_charset="${output_charset:-UTF-8}"
			output_width="${output_width:-300}"
			nbsp_utf=$(printf '\302\240')

			# Para POST se não houver ao menos 2 parâmetros (url e dados) interrompe.
			test "$ferramenta" = 'post' && test $# -lt 2 && return 1

			# Para outras requisições ao menos 1 parâmetro (url), senão interrompe.
			test "$ferramenta" != 'post' && test $# -lt 1 && return 1

			# Caracterizando os paramêtros conforme cada navegador.
			case "$browser" in
				links | links2) opt_common="-width ${output_width} -codepage ${output_charset}        ${input_charset:+-html-assume-codepage} ${input_charset} ${user_agent:+-http.fake-user-agent} ${user_agent}" ;;
				lynx          ) opt_common="-width=${output_width} -display_charset=${output_charset} ${input_charset:+-assume_charset=}${input_charset}       ${user_agent:+-useragent=}${user_agent}            -accept_all_cookies" ;;
				w3m           ) opt_common="-cols ${output_width}  -O ${output_charset}               ${input_charset:+-I} ${input_charset}                    ${user_agent:+-o user_agent=}${user_agent}         -cookie -o follow_redirection=9" ;;
				elinks        )
					local aspas='"'
					opt_common="-dump-width ${output_width} -dump-charset ${output_charset} ${input_charset:+-eval 'set document.codepage.assume = ${aspas}${input_charset}${aspas}'} ${user_agent:+-eval 'set protocol.http.user_agent = $user_agent'} -no-numbering"
				;;
			esac

			case "$ferramenta" in
			post)
				# Post conforme o navegador escolhido
				case "$browser" in
					lynx)
						echo "$2" | $browser ${opt_common} -post-data -nolist "$1"
					;;
					links | links2 | elinks | w3m)
						local post_temp
						post_temp=$(zztool mktemp post)
						curl -L -s "${user_agent:+-A}" "${user_agent}" -o "$post_temp" --data "$2" "$1"

						if test "$browser" = 'w3m'
						then
							$browser ${opt_common} -dump -T text/html   "$post_temp"
						elif test "$browser" = 'elinks'
						then
							eval $browser ${opt_common} -dump -no-references "$post_temp" | sed "s/${nbsp_utf}/ /g"
						else
							$browser ${opt_common} -dump         file://"$post_temp"
						fi

						rm -f "$post_temp"
					;;
				esac
			;;
			dump)
				case "$browser" in
					links | links2)      $browser ${opt_common} -dump                "$1" ;;
					lynx          )      $browser ${opt_common} -dump -nolist        "$1" ;;
					w3m           )      $browser ${opt_common} -dump -T text/html   "$1" ;;
					elinks        ) eval $browser ${opt_common} -dump -no-references $(echo "$1" | sed 's/\&/\\&/g') | sed "s/${nbsp_utf}/ /g" ;;
				esac
			;;
			source)
				curl -L -s "${user_agent:+-A}" "${user_agent}" "$1"
			;;
			list)
				case "$browser" in
					links | links2)             $browser ${opt_common} -dump                -html-numbered-links 1   "$1" ;;
					lynx          ) LANG=C      $browser ${opt_common} -dump                                         "$1" ;;
					elinks        ) LANG=C eval $browser ${opt_common} -dump              $(echo "$1" | sed 's/\&/\\&/g') ;;
					w3m           )             $browser ${opt_common} -dump -T text/html   -o display_link_number=1 "$1" ;;
				esac |
				case "$browser" in
					links | links2) sed '1,/^Links:/d' ;;
					lynx  | elinks) sed '1,/^References/d; /Visible links/d; /Hidden links/d' | sed "s/${nbsp_utf}/ /g" ;;
					w3m           ) sed '1,/^References:/d' ;;
				esac |
				sed '/^ *$/d; s/.* //;'
			;;
			download)
				local arq_dest
				test -n "$2" && arq_dest="$2" || arq_dest=$(basename "$1")
				zztool source "$1" > "$arq_dest"
			;;
			esac
		;;
		cache | atualiza)
		# Limpa o cache se solicitado a atualização
		# Atualiza o cache se for fornecido a url
		# e retorna o nome do arquivo de cache
		# Ex.: local cache=$(zztool cache lua <identificador> '$url' dump) # Nome do cache, e atualiza se necessário
		# Ex.: local cache=$(zztool cache php) # Apenas retorna o nome do cache
		# Ex.: zztool cache rm palpite # Apaga o cache diretamente
			local id
			case "${1#zz}" in
			on | off | ajuda)
				# shellcheck disable=SC2104
				break
			;;
			rm)
				if test "$2" = '*'
				then
					rm -f "${ZZTMP:-XXXX}"*
					# Restabelecendo zz.ajuda, zz.on, zz.off
					$ZZPATH
				else
					test -n "$3" && id=".$3"
					test -n "$2" && rm -f "${ZZTMP:-XXXX}.${2#zz}${id}"*
				fi
			;;
			*)
				# Para mais de um arquivo cache pode-se usar um identificador adicional
				# como PID, um numero incremental ou um sufixo qualquer
				test -n "$2" && id=".$2"

				# Para atualizar é necessário prevenir a existência prévia do arquivo
				test "$ferramenta" = "atualiza" && rm -f "${ZZTMP:-XXXX}.${1#zz}$id"

				# Baixo para o cache os dados brutos sem tratamento
				if ! test -s "$ZZTMP.${1#zz}" && test -n "$3"
				then
					case $4 in
					none    ) : ;;
					html    ) zztool source "$3" > "$ZZTMP.${1#zz}$id";;
					list    ) zztool list   "$3" > "$ZZTMP.${1#zz}$id";;
					dump | *) zztool dump   "$3" > "$ZZTMP.${1#zz}$id";;
					esac
				fi
				test "$ferramenta" = "cache" && echo "$ZZTMP.${1#zz}$id"
			;;
			esac
		;;
		# Ferramentas inexistentes são simplesmente ignoradas
		esac
}


# ----------------------------------------------------------------------------
# zzajuda
# Mostra uma tela de ajuda com explicação e sintaxe de todas as funções.
# Opções: --lista  lista de todas as funções, com sua descrição
#         --uso    resumo de todas as funções, com a sintaxe de uso
# Uso: zzajuda [--lista|--uso]
# Ex.: zzajuda
#      zzajuda --lista
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-05-04
# ----------------------------------------------------------------------------
zzajuda ()
{
	zzzz -h ajuda "$1" && return

	local zzcor_pager

	if test ! -r "$ZZAJUDA"
	then
		echo "Ops! Não encontrei o texto de ajuda em '$ZZAJUDA'." >&2
		echo "Para recriá-lo basta executar o script 'funcoeszz' sem argumentos." >&2
		return
	fi

	case "$1" in
		--uso)
			# Lista com sintaxe de uso, basta pescar as linhas Uso:
			sed -n 's/^Uso: zz/zz/p' "$ZZAJUDA" |
				sort |
				zztool acha '^zz[^ ]*'
		;;
		--lista)
			# Lista de todas as funções no formato: nome descrição
			grep -A2 ^zz "$ZZAJUDA" |
				grep -v ^http |
				sed '
					/^zz/ {
						# Padding: o nome deve ter 17 caracteres
						# Maior nome: zzfrenteverso2pdf
						:pad
						s/^.\{1,16\}$/& /
						t pad

						# Junta a descricao (proxima linha)
						N
						s/\n/ /
					}' |
				grep ^zz |
				sort |
				zztool acha '^zz[^ ]*'
		;;
		*)
			# Desliga cores para os paginadores antigos
			test "$PAGER" = 'less' -o "$PAGER" = 'more' && zzcor_pager=0

			# Mostra a ajuda de todas as funções, paginando
			cat "$ZZAJUDA" |
				ZZCOR=${zzcor_pager:-$ZZCOR} zztool acha 'zz[a-z0-9]\{2,\}' |
				${PAGER:-less -r}
		;;
	esac
}


# ----------------------------------------------------------------------------
# zzzz
# Mostra informações sobre as funções, como versão e localidade.
# Opções: --atualiza  baixa a versão mais nova das funções
#         --teste     testa se a codificação e os pré-requisitos estão OK
#         --bashrc    instala as funções no ~/.bashrc
#         --tcshrc    instala as funções no ~/.tcshrc
#         --zshrc     instala as funções no ~/.zshrc
# Uso: zzzz [--atualiza|--teste|--bashrc|--tcshrc|--zshrc]
# Ex.: zzzz
#      zzzz --teste
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2002-01-07
# ----------------------------------------------------------------------------
zzzz ()
{
	local nome_func arg_func padrao func
	local info_instalado info_instalado_zsh info_cor info_utf8 info_base versao_remota
	local arquivo_aliases
	local n_on n_off
	local bashrc="$HOME/.bashrc"
	local tcshrc="$HOME/.tcshrc"
	local zshrc="$HOME/.zshrc"
	local url_site='http://funcoeszz.net'
	local url_exe="$url_site/funcoeszz"
	local instal_msg='Instalacao das Funcoes ZZ (www.funcoeszz.net)'

	case "$1" in

		# Atenção: Prepare-se para viajar um pouco que é meio complicado :)
		#
		# Todas as funções possuem a opção -h e --help para mostrar um
		# texto rápido de ajuda. Normalmente cada função teria que
		# implementar o código para verificar se recebeu uma destas opções
		# e caso sim, mostrar o texto na tela. Para evitar a repetição de
		# código, estas tarefas estão centralizadas aqui.
		#
		# Chamando a zzzz com a opção -h seguido do nome de uma função e
		# seu primeiro parâmetro recebido, o teste é feito e o texto é
		# mostrado caso necessário.
		#
		# Assim cada função só precisa colocar a seguinte linha no início:
		#
		#     zzzz -h beep "$1" && return
		#
		# Ao ser chamada, a zzzz vai mostrar a ajuda da função zzbeep caso
		# o valor de $1 seja -h ou --help. Se no $1 estiver qualquer outra
		# opção da zzbeep ou argumento, nada acontece.
		#
		# Com o "&& return" no final, a função zzbeep pode sair imediatamente
		# caso a ajuda tenha sido mostrada (retorno zero), ou continuar seu
		# processamento normal caso contrário (retorno um).
		#
		# Se a zzzz -h for chamada sem nenhum outro argumento, é porque o
		# usuário quer ver a ajuda da própria zzzz.
		#
		# Nota: Ao invés de "beep" literal, poderíamos usar $FUNCNAME, mas
		#       o Bash versão 1 não possui essa variável.

		-h | --help)

			nome_func=${2#zz}
			arg_func=$3

			# Nenhum argumento, mostre a ajuda da própria zzzz
			if test -z "$nome_func"
			then
				nome_func='zz'
				arg_func='-h'
			fi

			# Se o usuário informou a opção de ajuda, mostre o texto
			if test '-h' = "$arg_func" -o '--help' = "$arg_func"
			then
				# Um xunxo bonito: filtra a saída da zzajuda, mostrando
				# apenas a função informada.
				echo
				ZZCOR=0 zzajuda |
					sed -n "/^zz$nome_func$/,/^----*$/ {
						s/^----*$//
						p
					}" |
					zztool acha zz$nome_func
				return 0
			else

				# Alarme falso, o argumento não é nem -h nem --help
				return 1
			fi
		;;

		# Garantia de compatibilidade do -h com o formato antigo (-z):
		# zzzz -z -h zzbeep
		-z)
			zzzz -h "$3" "$2"
		;;

		# Testes de ambiente para garantir o funcionamento das funções
		--teste)

			### Todos os comandos necessários estão instalados?

			local comando tipo_comando comandos_faltando
			local comandos='awk bc cat chmod- clear- cp cpp- curl cut diff- du- find- fmt grep iconv links- lynx- mktemp mv od- ps- rm sed sleep sort tail- tr uniq unzip-'

			for comando in $comandos
			do
				# Este é um comando essencial ou opcional?
				tipo_comando='ESSENCIAL'
				if zztool grep_var - "$comando"
				then
					tipo_comando='opcional'
					comando=${comando%-}
				fi

				printf '%-30s' "Procurando o comando $comando... "

				# Testa se o comando existe
				if type "$comando" >/dev/null 2>&1
				then
					echo 'OK'
				else
					zztool eco "Comando $tipo_comando '$comando' não encontrado"
					comandos_faltando="$comandos_faltando $tipo_comando"
				fi
			done

			if test -n "$comandos_faltando"
			then
				echo
				zztool eco "**Atenção**"
				if zztool grep_var ESSENCIAL "$comandos_faltando"
				then
					echo 'Há pelo menos um comando essencial faltando.'
					echo 'Você precisa instalá-lo para usar as Funções ZZ.'
				else
					echo 'A falta de um comando opcional quebra uma única função.'
					echo 'Talvez você não precise instalá-lo.'
				fi
				echo
			fi

			### Tudo certo com a codificação do sistema e das ZZ?

			local cod_sistema='ISO-8859-1'
			local cod_funcoeszz='ISO-8859-1'

			printf 'Verificando a codificação do sistema... '
			zztool terminal_utf8 && cod_sistema='UTF-8'
			echo "$cod_sistema"

			printf 'Verificando a codificação das Funções ZZ... '
			test $ZZUTF = 1 && cod_funcoeszz='UTF-8'
			echo "$cod_funcoeszz"

			# Se um dia precisar de um teste direto no arquivo:
			# sed 1d "$ZZPATH" | file - | grep UTF-8

			if test "$cod_sistema" != "$cod_funcoeszz"
			then
				# Deixar sem acentuação mesmo, pois eles não vão aparecer
				echo
				zztool eco "**Atencao**"
				echo 'Ha uma incompatibilidade de codificacao.'
				echo "Baixe as Funcoes ZZ versao $cod_sistema."
			fi
		;;

		# Baixa a versão nova, caso diferente da local
		--atualiza)

			echo 'Procurando a versão nova, aguarde.'
			versao_remota=$(zztool dump "$url_site/v")
			echo "versão local : $ZZVERSAO"
			echo "versão remota: $versao_remota"
			echo

			# Aborta caso não encontrou a versão nova
			test -n "$versao_remota" || return

			# Compara e faz o download
			if test "$ZZVERSAO" != "$versao_remota"
			then
				# Vamos baixar a versão ISO-8859-1?
				test $ZZUTF != '1' && url_exe="${url_exe}-iso"

				printf 'Baixando a versão nova... '
				zztool download "$url_exe" "funcoeszz-$versao_remota"
				echo 'PRONTO!'
				echo "Arquivo 'funcoeszz-$versao_remota' baixado, instale-o manualmente."
				echo "O caminho atual é $ZZPATH"
			else
				echo 'Você já está com a versão mais recente.'
			fi
		;;

		# Instala as funções no arquivo .bashrc
		--bashrc)

			if ! grep "^[^#]*${ZZPATH:-zzpath_vazia}" "$bashrc" >/dev/null 2>&1
			then
				cat - >> "$bashrc" <<-EOS

				# $instal_msg
				export ZZOFF=""  # desligue funcoes indesejadas
				export ZZPATH="$ZZPATH"  # script
				export ZZDIR="$ZZDIR"    # pasta zz/
				source "\$ZZPATH"
				EOS

				echo 'Feito!'
				echo "As Funções ZZ foram instaladas no $bashrc"
			else
				echo "Nada a fazer. As Funções ZZ já estão no $bashrc"
			fi
		;;

		# Cria aliases para as funções no arquivo .tcshrc
		--tcshrc)
			arquivo_aliases="$HOME/.zzcshrc"

			# Chama o arquivo dos aliases no final do .tcshrc
			if ! grep "^[^#]*$arquivo_aliases" "$tcshrc" >/dev/null 2>&1
			then
				# setenv ZZDIR $ZZDIR
				cat - >> "$tcshrc" <<-EOS

				# $instal_msg
				# script
				setenv ZZPATH $ZZPATH
				# pasta zz/
				setenv ZZDIR $ZZDIR
				source $arquivo_aliases
				EOS

				echo 'Feito!'
				echo "As Funções ZZ foram instaladas no $tcshrc"
			else
				echo "Nada a fazer. As Funções ZZ já estão no $tcshrc"
			fi

			# Cria o arquivo de aliases
			echo > "$arquivo_aliases"
			for func in $(ZZCOR=0 zzzz | grep -v '^(' | sed 's/,//g')
			do
				echo "alias zz$func 'funcoeszz zz$func'" >> "$arquivo_aliases"
			done

			# alias para funcoes base
			for func in $(ZZCOR=0 zzzz | grep 'base)' | sed 's/(.*)//; s/,//g')
			do
				echo "alias $func='funcoeszz $func'" >> "$arquivo_aliases"
			done

			echo
			echo "Aliases atualizados no $arquivo_aliases"
		;;

		# Cria aliases para as funções no arquivo .zshrc
		--zshrc)
			arquivo_aliases="$HOME/.zzzshrc"

			# Chama o arquivo dos aliases no final do .zshrc
			if ! grep "^[^#]*$arquivo_aliases" "$zshrc" >/dev/null 2>&1
			then
				# export ZZDIR=$ZZDIR
				cat - >> "$zshrc" <<-EOS

				# $instal_msg
				# script
				export ZZPATH=$ZZPATH
				# pasta zz/
				export ZZDIR=$ZZDIR
				source $arquivo_aliases
				EOS

				echo 'Feito!'
				echo "As Funções ZZ foram instaladas no $zshrc"
			else
				echo "Nada a fazer. As Funções ZZ já estão no $zshrc"
			fi

			# Cria o arquivo de aliases
			echo > "$arquivo_aliases"
			for func in $(ZZCOR=0 zzzz | grep -v '^(' | sed 's/,//g')
			do
				echo "alias zz$func='funcoeszz zz$func'" >> "$arquivo_aliases"
			done

			# alias para funcoes base
			for func in $(ZZCOR=0 zzzz | grep 'base)' | sed 's/(.*)//; s/,//g')
			do
				echo "alias $func='funcoeszz $func'" >> "$arquivo_aliases"
			done

			echo
			echo "Aliases atualizados no $arquivo_aliases"
		;;

		# Mostra informações sobre as funções
		*)
			# As funções estão configuradas para usar cores?
			test "$ZZCOR" = '1' && info_cor='sim' || info_cor='não'

			# A codificação do arquivo das funções é UTF-8?
			test "$ZZUTF" = 1 && info_utf8='UTF-8' || info_utf8='ISO-8859-1'

			# As funções estão instaladas no bashrc?
			if grep "^[^#]*${ZZPATH:-zzpath_vazia}" "$bashrc" >/dev/null 2>&1
			then
				info_instalado="$bashrc"
			else
				info_instalado='não instalado'
			fi

			# As funções estão instaladas no zshrc?
			if grep "^[^#]*${ZZPATH:-zzpath_vazia}" "$zshrc" >/dev/null 2>&1
			then
				info_instalado_zsh="$zshrc"
			else
				info_instalado_zsh='não instalado'
			fi

			# Formata funções essenciais
			info_base=$(echo "$ZZBASE" | sed 's/ /, /g')

			# Informações, uma por linha
			zztool acha '^[^)]*)' "( script) $ZZPATH"
			zztool acha '^[^)]*)' "(  pasta) $ZZDIR"
			zztool acha '^[^)]*)' "( versão) $ZZVERSAO ($info_utf8)"
			zztool acha '^[^)]*)' "(  cores) $info_cor"
			zztool acha '^[^)]*)' "(    tmp) $ZZTMP"
			zztool acha '^[^)]*)' "(browser) $ZZBROWSER"
			zztool acha '^[^)]*)' "( bashrc) $info_instalado"
			zztool acha '^[^)]*)' "(  zshrc) $info_instalado_zsh"
			zztool acha '^[^)]*)' "(   base) $info_base"
			zztool acha '^[^)]*)' "(   site) $url_site"

			# Lista de todas as funções

			# Sem $ZZDIR, provavelmente usando --tudo-em-um
			# Tentarei obter a lista de funções carregadas na shell atual
			if test -z "$ZZDIR"
			then
				set |
					sed -n '/^zz[a-z0-9]/ s/ *().*//p' |
					egrep -v "$(echo "$ZZBASE" | sed 's/ /|/g')" |
					sort > "$ZZTMP.on"
			fi

			if test -r "$ZZTMP.on"
			then
				echo
				n_on=$(zztool num_linhas "$ZZTMP.on")
				zztool eco "(( $n_on funções disponíveis ))"
				cat "$ZZTMP.on" |
					sed 's/^zz//' |
					zztool lines2list |
					sed 's/ /, /g' |
					fmt -w 70
			else
				echo
				echo "Não consegui obter a lista de funções disponíveis."
				echo "Para recriá-la basta executar o script 'funcoeszz' sem argumentos."
			fi

			# Só mostra se encontrar o arquivo...
			if test -r "$ZZTMP.off"
			then
				# ...e se ele tiver ao menos uma zz
				grep zz "$ZZTMP.off" >/dev/null || return

				echo
				n_off=$(zztool num_linhas "$ZZTMP.off")
				zztool eco "(( $n_off funções desativadas ))"
				cat "$ZZTMP.off" |
					sed 's/^zz//' |
					zztool lines2list |
					sed 's/ /, /g' |
					fmt -w 70
			else
				echo
				echo "Não consegui obter a lista de funções desativadas."
				echo "Para recriá-la basta executar o script 'funcoeszz' sem argumentos."
			fi
		;;
	esac
}

# A linha seguinte é usada pela opção --tudo-em-um
#@
# ----------------------------------------------------------------------------
# zzaleatorio
# Gera um número aleatório.
# Sem argumentos, comporta-se igual a $RANDOM.
# Apenas um argumento, número entre 0 e o valor fornecido.
# Com dois argumentos, número entre esses limites informados.
#
# Uso: zzaleatorio [número] [número]
# Ex.: zzaleatorio 10
#      zzaleatorio 5 15
#      zzaleatorio
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-13
# Versão: 5
# Licença: GPL
# Requisitos: zzvira
# ----------------------------------------------------------------------------
zzaleatorio ()
{
	zzzz -h aleatorio "$1" && return

	local inicio=0
	local fim=32767
	local cache=$(zztool cache aleatorio)
	local v_temp

	# Se houver só um número, entre 0 e o número
	test -n "$1" && fim="$1"

	# Se houver dois números, entre o primeiro e o segundo
	test -n "$2" && inicio="$1" fim="$2"

	# Verificações básicas
	zztool testa_numero "$inicio" || return 1
	zztool testa_numero "$fim"    || return 1

	# Se ambos são iguais, retorna o próprio número
	test "$inicio" = "$fim" && { echo "$fim"; return 0; }

	# Se o primeiro é maior, inverte a posição
	if test "$inicio" -gt "$fim"
	then
		v_temp="$inicio"
		inicio="$fim"
		fim="$v_temp"
	fi

	# Usando o dispositivo /dev/urandom
	v_temp=$(od -An -N2 -d /dev/urandom | tr -d -c '[0-9]')

	# Se não estiver disponível, usa o dispositivo /dev/random
	zztool testa_numero $v_temp || v_temp=$(od -An -N2 -d /dev/random | tr -d -c '[0-9]')

	# Se não estiver disponível, usa o tempo em nanosegundos
	zztool testa_numero $v_temp || v_temp=$(date +%N)

	if zztool testa_numero $v_temp
	then
		# Se um dos casos acima atenderem, gera o número aleatório
		echo "$(zzvira $v_temp) $inicio $fim" | awk '{ srand($1); printf "%.0f\n", $2 + rand()*($3 - $2) }'
	else
		# Se existir o cache e o tempo em segundos é o mesmo do atual, aguarda um segundo
		if test -s "$cache"
		then
			test $(cat "$cache") = $(date +%s) && sleep 1
		fi

		# Cria o cache incondicionalmente nesse caso
		echo $(date +%s) > "$cache"

		# Gera o número aleatório
		echo "$inicio $fim" | awk '{ srand(); printf "%.0f\n", $1 + rand()*($2 - $1) }'
	fi
}

# ----------------------------------------------------------------------------
# zzalfabeto
# Central de alfabetos (romano, militar, radiotelefônico, OTAN, RAF, etc).
# Obs.: Sem argumentos mostra a tabela completa, senão traduz uma palavra.
#
# Tipos reconhecidos:
#
#    --militar | --radio | --fone | --otan | --icao | --ansi
#                                   Radiotelefônico internacional
#    --romano | --latino            A B C D E F...
#    --royal-navy | --royal         Marinha Real - Reino Unido, 1914-1918
#    --signalese | --western-front  Primeira Guerra, 1914-1918
#    --raf24                        Força Aérea Real - Reino Unido, 1924-1942
#    --raf42                        Força Aérea Real - Reino Unido, 1942-1943
#    --raf | --raf43                Força Aérea Real - Reino Unido, 1943-1956
#    --us | --us41                  Militar norte-americano, 1941-1956
#    --portugal | --pt              Lugares de Portugal
#    --name | --names               Nomes de pessoas, em inglês
#    --lapd                         Polícia de Los Angeles (EUA)
#    --morse                        Código Morse
#    --german                       Nomes de pessoas, em alemão
#    --all | --todos                Todos os códigos lado a lado
#
# Uso: zzalfabeto [--TIPO] [palavra]
# Ex.: zzalfabeto --militar
#      zzalfabeto --militar cambio
#      zzalfabeto --us --german prossiga
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-07-23
# Versão: 6
# Licença: GPL
# Requisitos: zzmaiusculas zztrim
# ----------------------------------------------------------------------------
zzalfabeto ()
{
	zzzz -h alfabeto "$1" && return

	local char letra colunas cab tam
	local awk_code='
				BEGIN {FS=":"; if (length(cab)>0) { print cab }}
				function campo(campos,  i, arr_camp) {
					split("", arr_camp)
					qtd_camp = split(campos, arr_camp, " ")
					for (i=1;i<=qtd_camp;i++) {
						printf $(arr_camp[i]) (i<qtd_camp?" ":"")
					}
					print ""
				}
				{ if (length(colunas)>0) { campo(colunas) } else print }'
	local coluna=1
	local dados="\
A:Alpha:Apples:Ack:Ace:Apple:Able/Affirm:Able:Aveiro:Alan:Adam:.-:Anton
B:Bravo:Butter:Beer:Beer:Beer:Baker:Baker:Bragança:Bobby:Boy:-...:Berta
C:Charlie:Charlie:Charlie:Charlie:Charlie:Charlie:Charlie:Coimbra:Charlie:Charles:-.-.:Casar
D:Delta:Duff:Don:Don:Dog:Dog:Dog:Dafundo:David:David:-..:Dora
E:Echo:Edward:Edward:Edward:Edward:Easy:Easy:Évora:Edward:Edward:.:Emil
F:Foxtrot:Freddy:Freddie:Freddie:Freddy:Fox:Fox:Faro:Frederick:Frank:..-.:Friedrich
G:Golf:George:Gee:George:George:George:George:Guarda:George:George:--.:Gustav
H:Hotel:Harry:Harry:Harry:Harry:How:How:Horta:Howard:Henry:....:Heinrich
I:India:Ink:Ink:Ink:In:Item/Interrogatory:Item:Itália:Isaac:Ida:..:Ida
J:Juliet:Johnnie:Johnnie:Johnnie:Jug/Johnny:Jig/Johnny:Jig:José:James:John:.---:Julius
K:Kilo:King:King:King:King:King:King:Kilograma:Kevin:King:-.-:Kaufmann/Konrad
L:Lima:London:London:London:Love:Love:Love:Lisboa:Larry:Lincoln:.-..:Ludwig
M:Mike:Monkey:Emma:Monkey:Mother:Mike:Mike:Maria:Michael:Mary:--:Martha
N:November:Nuts:Nuts:Nuts:Nuts:Nab/Negat:Nan:Nazaré:Nicholas:Nora:-.:Nordpol
O:Oscar:Orange:Oranges:Orange:Orange:Oboe:Oboe:Ovar:Oscar:Ocean:---:Otto
P:Papa:Pudding:Pip:Pip:Peter:Peter/Prep:Peter:Porto:Peter:Paul:.--.:Paula
Q:Quebec:Queenie:Queen:Queen:Queen:Queen:Queen:Queluz:Quincy:Queen:--.-:Quelle
R:Romeo:Robert:Robert:Robert:Roger/Robert:Roger:Roger:Rossio:Robert:Robert:.-.:Richard
S:Sierra:Sugar:Esses:Sugar:Sugar:Sugar:Sugar:Setúbal:Stephen:Sam:...:Samuel/Siegfried
T:Tango:Tommy:Toc:Toc:Tommy:Tare:Tare:Tavira:Trevor:Tom:-:Theodor
U:Uniform:Uncle:Uncle:Uncle:Uncle:Uncle:Uncle:Unidade:Ulysses:Union:..-:Ulrich
V:Victor:Vinegar:Vic:Vic:Vic:Victor:Victor:Viseu:Vincent:Victor:...-:Viktor
W:Whiskey:Willie:William:William:William:William:William:Washington:William:William:.--:Wilhelm
X:X-ray/Xadrez:Xerxes:X-ray:X-ray:X-ray:X-ray:X-ray:Xavier:Xavier:X-ray:-..-:Xanthippe/Xavier
Y:Yankee:Yellow:Yorker:Yorker:Yoke/Yorker:Yoke:Yoke:York:Yaakov:Young:-.--:Ypsilon
Z:Zulu:Zebra:Zebra:Zebra:Zebra:Zebra:Zebra:Zulmira:Zebedee:Zebra:--..:Zacharias/Zurich"

	# Escolhe o(s) alfabeto(s) a ser(em) utilizado(s)
	while test "${1#--}" != "$1"
	do
		case "$1" in
			--militar | --radio | --fone | --telefone | --otan | --nato | --icao | --itu | --imo | --faa | --ansi)
				coluna=2 ; shift ;;
			--romano | --latino           ) coluna=1     ; shift ;;
			--royal | --royal-navy        ) coluna=3     ; shift ;;
			--signalese | --western-front ) coluna=4     ; shift ;;
			--raf24                       ) coluna=5     ; shift ;;
			--raf42                       ) coluna=6     ; shift ;;
			--raf43 | --raf               ) coluna=7     ; shift ;;
			--us41 | --us                 ) coluna=8     ; shift ;;
			--pt | --portugal             ) coluna=9     ; shift ;;
			--name | --names              ) coluna=10    ; shift ;;
			--lapd                        ) coluna=11    ; shift ;;
			--morse                       ) coluna=12    ; shift ;;
			--german                      ) coluna=13    ; shift ;;
			--all | --todos               )
				colunas='1 12 2 3 4 5 6 7 8 10 11 13 9'
				coluna="0"
				shift
				break
			;;
			*) break ;;
		esac
		colunas=$(echo "$colunas $coluna" | zztrim | tr -s ' ,')
	done

	if test "$colunas" != "$coluna" -a -n "$colunas"
	then
		cab='ROMANO MILITAR ROYAL-NAVY SIGNALESE RAF24 RAF42 RAF US PORTUGAL NAMES LAPD MORSE GERMAN'
		tam='8 14 12 11 9 14 20 9 0 11 9 7 18'

		# Colocando portugal, quando presente, na última coluna sempre
		# devido a presença dos caracteres especiais nos nomes
		if zztool grep_var 9 "$colunas"
		then
			colunas=$(echo "$colunas" | zztrim | tr -d 9)' 9'
			colunas=$(echo "$colunas" | tr -s ' ')
		fi

		# Definindo cabeçalho e espaçamento
		cab=$(echo "$cab" | tr ' ' ':' | awk -v colunas="$colunas" "$awk_code")
		tam=$(echo "$tam" | tr ' ' ':' | awk -v colunas="$colunas" "$awk_code" |
			awk '{ if (NF > 1){ tot=$1;for(i=2;i<=NF;i++) { printf tot ","; tot+=$i } } } END {print ++tot}'
		)

	fi

	if test -n "$1"
	then
		# Texto informado, vamos fazer a conversão
		# Deixa uma letra por linha e procura seu código equivalente
		echo "$*" |
			zzmaiusculas |
			sed 's/./&\
/g' |
			while IFS='' read -r char
			do
				letra=$(echo "$char" | sed 's/[^A-Z]//g;s/[ÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÇÑÐ£Ø§Ý]//g')
				if test -n "$letra"
				then
					echo "$dados" | grep "^$letra" |
					awk -v colunas="${colunas:-$coluna}" "$awk_code"
				else
					test -n "$char" && echo "$char"
				fi
			done
	else
		# Apenas mostre a tabela
		echo "$dados" |
		awk -v colunas="${colunas:-$coluna}" "$awk_code"
	fi |
	awk -v cab="$cab" "$awk_code" | tr ' ' '\t' |
	expand -t "${tam:-8}" | zztrim
}

# ----------------------------------------------------------------------------
# zzalinhar
# Alinha um texto a esquerda, direita, centro ou justificado.
#
# As opções -l, --left, -e, --esquerda alinham as colunas a esquerda (padrão).
# As opções -r, --right, -d, --direita alinham as colunas a direita.
# As opções -c, --center, --centro centralizam as colunas.
# A opção -j, --justify, --justificar faz o texto ocupar toda a linha.
#
# As opções -w, --width, --largura seguido de um número,
# determinam o tamanho da largura como base ao alinhamento.
# Obs.: Onde a largura é maior do que a informada não é aplicado alinhamento.
#
# Uso: zzalinhar [-l|-e|-r|-d|-c|-j] [-w <largura>] arquivo
# Ex.: zzalinhar arquivo.txt
#      zzalinhar -c -w 20 arquivo.txt
#      zzalinhar -j arquivo.txt
#      cat arquivo.txt | zzalinhar -r
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2014-05-23
# Versão: 4
# Licença: GPL
# Requisitos: zzpad zztrim zzwc
# ----------------------------------------------------------------------------
zzalinhar ()
{
	zzzz -h alinhar "$1" && return

	local alinhamento='r'
	local largura=0
	local larg_efet linha cache

	while test "${1#-}" != "$1"
	do
		case "$1" in
		-l | --left | -e | --esqueda)  alinhamento='r'; shift ;;
		-r | --right | -d | --direita) alinhamento='l'; shift ;;
		-c | --center | --centro)      alinhamento='c'; shift ;;
		-j | --justify | --justificar) alinhamento='j'; shift ;;
		-w | --width | --largura)
			zztool testa_numero "$2" && largura="$2" || { zztool erro "Largura inválida: $2"; return 1; }
			shift; shift
		;;
		--) shift; break ;;
		-*) zztool erro "Opção inválida: $1"; return 1 ;;
		*) break;;
		esac
	done

	cache=$(zztool mktemp alinhar)

	zztool file_stdin -- "$@" > "$cache"

	test $(zztrim "$cache" | zzwc -l) -gt 0 || return 1

	larg_efet=$(zzwc -L "$cache")

	test "$largura" -eq 0 -a "${larg_efet:-0}" -gt "$largura" && largura=$larg_efet

	case $alinhamento in
	'j')
		cat "$cache" |
		zztrim -H |
		sed 's/"/\\"/g' | sed "s/'/\\'/g" |
		awk -v larg=$largura '
			# Função para unir os campos e os separadores de campos(" ")
			function juntar(qtde_campos,  str_saida, j) {
				str_saida=""
				for ( j=1; j<=qtde_campos; j++ ) {
					str_saida = str_saida campos[j] espacos[j]
				}
				sub(/ *$/, "", str_saida)
				return str_saida
			}

			# Função que aumenta a quantidade de espaços intermadiários
			function aumentar_int() {
				espacos[pos_atual] = espacos[pos_atual] " "
				pos_atual--
				pos_atual = (pos_atual == 0 ? qtde : pos_atual)
			}

			# Função para determinar tamanho da string sem erros com codificação
			function tam_linha(entrada,  saida, comando)
			{
				comando = ("echo \"" entrada "\" | wc -m")
				comando | getline saida
				close(comando)
				return saida-1
			}

			{
				# Guardando as linhas em um array
				linha[NR] = $0
			}

			END {
				for (i=1; i<=NR; i++) {
					if (tam_linha(linha[i]) == larg) { print linha[i] }
					else {
						split("", campos)
						split("", espacos)
						qtde = split(linha[i], campos)
						for (x in campos) {
							espacos[x] = " "
						}
						if ( qtde <= 1 ) { print linha[i] }
						else {
							pos_atual = qtde - 1
							saida = juntar(qtde)
							while ( tam_linha(saida) < larg ) {
								aumentar_int()
								saida = juntar(qtde)
							}
							print saida
						}
					}
				}
			}
		' | sed 's/\\"/"/g'
	;;
	*)
		test "$alinhamento" = "c" && alinhamento="a"

		cat "$cache" |
		zztrim -H |
		zzpad -${alinhamento} "$largura" 2>/dev/null
	;;
	esac

	rm -f "$cache"
}

# ----------------------------------------------------------------------------
# zzansi2html
# Converte para HTML o texto colorido do terminal (códigos ANSI).
# Útil para mostrar a saída do terminal em sites e blogs, sem perder as cores.
# Obs.: Exemplos de texto ANSI estão na saída das funções zzcores e zzecho.
# Obs.: Use o comando script para guardar a saída do terminal em um arquivo.
# Uso: zzansi2html [arquivo]
# Ex.: zzecho --letra verde -s -p -N testando | zzansi2html
#      ls --color /etc | zzansi2html > ls.html
#      zzcores | zzansi2html > cores.html
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-09-02
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzansi2html ()
{
	zzzz -h ansi2html "$1" && return

	local esc=$(printf '\033')
	local control_m=$(printf '\r')  # ^M, CR, \r

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" |

	# Limpeza inicial do texto
	sed "
		# No Mac, o ESC[K aparece depois de cada código de cor ao usar
		# o grep --color. Exemplo: ^[[1;33m^[[Kamarelo^[[m^[[K
		# Esse código serve pra apagar até o fim da linha, então neste
		# caso, pode ser removido sem problemas.
		s/$esc\[K//g

		# O comando script deixa alguns \r inúteis no arquivo de saída
		s/$control_m*$//
	" |

	# Um único sed toma conta de toda a tarefa de conversão.
	#
	# Esta função cria um SPAN dentro do outro, sem fechar, pois os códigos ANSI
	# são cumulativos: abrir um novo não desliga os anteriores.
	#    echo -e '\e[4mFOO\e[33mBAR'  # BAR é amarelo *e* sublinhado
	#
	# No CSS, o text-decoration é cumulativo para sub-elementos (FF, Safari), veja:
	# <span style=text-decoration:underline>FOO<span style=text-decoration:none>BAR
	# O BAR também vai aparecer sublinhado, o 'none' no SPAN filho não o desliga.
	# Por isso é preciso uma outra tática para desligar sublinhado e blink.
	#
	# Uma alternativa seria fechar todos os SPANs no ^[0m, mas é difícil no sed
	# saber quantos SPANs estão abertos (multilinha). A solução foi usar DIVs,
	# que ao serem fechados desligam todos os SPANs anteriores.
	#    ^[0m  -->  </div><div style="display:inline">
	#
	sed "
		# Engloba o código na tag PRE para preservar espaços
		1 i\\
<pre style=\"background:#000;color:#FFF\"><div style=\"display:inline\">
		$ a\\
</pre>

		# Escapes do HTML
		s/&/&amp;/g
		s/</&lt;/g
		s/>/&gt;/g

		:ini
		/$esc\[[0-9;]*m/ {

			# Guarda a linha original
			h

			# Isola os números (ex: 33;41;1) da *primeira* ocorrência
			s/\($esc\[[0-9;]*\)m.*/\1/
			s/.*$esc\[\([0-9;]*\)$/\1/

			# Se vazio (^[m) vira zero
			s/^$/0/

			# Adiciona separadores no início e fim
			s/.*/;&;/

			# Zero limpa todos os atributos
			#
			# XXX
			# Note que 33;0;4 (amarelo, reset, sublinhado) vira reset,
			# mas deveria ser reset+sublinhado. É um caso difícil de
			# encontrar, então vamos conviver com essa limitação.
			#
			/;;*00*;;*/ {
				s,.*,</div><div style=\"display:inline\">,
				b end
			}

			# Define as cores
			s/;30;/;color:#000;/g; s/;40;/;background:#000;/g
			s/;31;/;color:#F00;/g; s/;41;/;background:#C00;/g
			s/;32;/;color:#0F0;/g; s/;42;/;background:#0C0;/g
			s/;33;/;color:#FF0;/g; s/;43;/;background:#CC0;/g
			s/;34;/;color:#00F;/g; s/;44;/;background:#00C;/g
			s/;35;/;color:#F0F;/g; s/;45;/;background:#C0C;/g
			s/;36;/;color:#0FF;/g; s/;46;/;background:#0CC;/g
			s/;37;/;color:#FFF;/g; s/;47;/;background:#CCC;/g

			# Define a formatação
			s/;1;/;font-weight:bold;/g
			s/;4;/;text-decoration:underline;/g
			s/;5;/;text-decoration:blink;/g

			# Força remoção da formatação, caso não especificado
			/font-weight/! s/$/;font-weight:normal/
			/text-decoration/! s/$/;text-decoration:none/

			# Remove códigos de texto reverso
			s/;7;/;/g

			# Normaliza os separadores
			s/;;;*/;/g
			s/^;//
			s/;$//

			# Engloba as propriedades na tag SPAN
			s,.*,<span style=\"&\">,

			:end

			# Recupera a linha original e anexa o SPAN no final
			# Ex.: ^[33m amarelo ^[m\n<span style=...>
			x
			G

			# Troca o código ANSI pela tag SPAN
			s/$esc\[[0-9;]*m\(.*\)\n\(.*\)/\2\1/

			# E começa tudo de novo, até acabar todos da linha
			b ini
		}
	"
}

# ----------------------------------------------------------------------------
# zzarrumacidade
# Arruma o nome da cidade informada: maiúsculas, abreviações, acentos, etc.
#
# Uso: zzarrumacidade [cidade]
# Ex.: zzarrumacidade SAO PAULO                     # São Paulo
#      zzarrumacidade rj                            # Rio de Janeiro
#      zzarrumacidade Floripa                       # Florianópolis
#      echo Floripa | zzarrumacidade                # Florianópolis
#      cat cidades.txt | zzarrumacidade             # [uma cidade por linha]
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2013-02-21
# Versão: 3
# Licença: GPL
# Requisitos: zzcapitalize
# ----------------------------------------------------------------------------
zzarrumacidade ()
{
	zzzz -h arrumacidade "$1" && return

	# 1. Texto via STDIN ou argumentos
	# 2. Deixa todas as iniciais em maiúsculas
	# 3. sed mágico®
	zztool multi_stdin "$@" | zzcapitalize | sed "

		# Volta algumas iniciais para minúsculas
		s/ E / e /g
		s/ De / de /g
		s/ Da / da /g
		s/ Do / do /g
		s/ Das / das /g
		s/ Dos / dos /g

		# Expande abreviações comuns
		s/^Sp$/São Paulo/
		s/^Rj$/Rio de Janeiro/
		s/^Bh$/Belo Horizonte/
		s/^Bsb$/Brasília/
		s/^Rio$/Rio de Janeiro/
		s/^Sampa$/São Paulo/
		s/^Floripa$/Florianópolis/
		# s/^Poa$/Porto Alegre/  # Perigoso, pois existe: Poá - SP

		# Abreviações comuns a Belo Horizonte
		s/^B\. H\.$/Belo Horizonte/
		s/^Bhte$/Belo Horizonte/
		s/^B\. Hte$/Belo Horizonte/
		s/^B\. Hzte$/Belo Horizonte/
		s/^Belo Hte$/Belo Horizonte/
		s/^Belo Hzte$/Belo Horizonte/


		### Restaura acentuação de maneira pontual:

		# Restaura acentuação às capitais
		s/^Belem$/Belém/
		s/^Brasilia$/Brasília/
		s/^Cuiaba$/Cuiabá/
		s/^Florianopolis$/Florianópolis/
		s/^Goiania$/Goiânia/
		s/^Joao Pessoa$/João Pessoa/
		s/^Macapa$/Macapá/
		s/^Maceio$/Maceió/
		s/^S[ãa]o Lu[ií][sz]$/São Luís/
		s/^Vitoria$/Vitória/

		# Muitas cidades emprestam o nome do estado
		#   Santana do Piauí
		#   Teresina de Goiás
		#   Pontal do Paraná
		# então é útil acentuar os nomes de estados.
		#
		s/Amapa$/Amapá/
		s/Ceara$/Ceará/
		s/Goias$/Goiás/
		s/Maranhao$/Maranhão/
		s/Para$/Pará/
		s/Paraiba$/Paraíba/
		s/Parana$/Paraná/
		s/Piaui$/Piauí/
		s/Rondonia$/Rondônia/

		# O nome de alguns estados pode aparecer no início/meio
		#   Paraíba do Sul
		#   Pará de Minas
		#
		s/Amapa /Amapá /
		s/Espirito /Espírito /
		s/Para /Pará /
		s/Paraiba /Paraíba /


		### Restaura acentuação de maneira genérica:

		# Uberlândia, Rolândia
		s/landia /lândia /g
		s/landia$/lândia/

		# Florianópolis, Virginópolis
		s/opolis /ópolis /g
		s/opolis$/ópolis/

		# Palavras terminadas em 'ao' viram 'ão'.
		# Exemplos: São, João, Ribeirão, Capão
		#
		# Não achei nenhum caso de cidade com 'ao' no final:
		#   $ zzcidade 'ao '
		#   $
		#
		# Exceção: duas cidades com aó:
		#   $ zzcidade 'aó '
		#   Alto Caparaó (MG)
		#   Caparaó (MG)
		#   $
		#
		# Exceção da exceção: algum Caparão?
		#   $ zzcidade Caparão
		#   $
		#
		# Então resolvida a exceção Caparaó, é seguro fazer a troca.
		#
		s/Caparao$/Caparaó/
		s/ao /ão /g
		s/ao$/ão/


		### Exceções pontuais:

		# Morro Cabeça no Tempo
		s/ No / no /g

		# Passa-e-Fica
		s/-E-/-e-/g

		# São João del-Rei
		s/ Del-Rei/ del-Rei/g

		# Xangri-lá: Wikipédia
		# Xangri-Lá: http://www.xangrila.rs.gov.br
		# ** Vou ignorar a Wikipédia, não precisa arrumar este

		# Nomes de Papas
		s/^Pedro Ii$/Pedro II/
		s/^Pio Ix$/Pio IX/
		s/^Pio Xii$/Pio XII/

		# Estrela d'Oeste
		# Sítio d'Abadia
		# Dias d'Ávila
		# …
		s/ D'/ d'/g

		# São João do Pau-d'Alho
		# Olhos-d'Água
		# Pau-d'Arco
		# …
		s/-D'/-d'/g
	"
}

# ----------------------------------------------------------------------------
# zzarrumanome
# Renomeia arquivos do diretório atual, arrumando nomes estranhos.
# Obs.: Ele deixa tudo em minúsculas, retira acentuação e troca espaços em
#       branco, símbolos e pontuação pelo sublinhado _.
# Opções: -n  apenas mostra o que será feito, não executa
#         -d  também renomeia diretórios
#         -r  funcionamento recursivo (entra nos diretórios)
# Uso: zzarrumanome [-n] [-d] [-r] arquivo(s)
# Ex.: zzarrumanome *
#      zzarrumanome -n -d -r .                   # tire o -n para renomear!
#      zzarrumanome "DOCUMENTO MALÃO!.DOC"       # fica documento_malao.doc
#      zzarrumanome "RAMONES - Don't Go.mp3"     # fica ramones-dont_go.mp3
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2001-07-23
# Versão: 1
# Licença: GPL
# Requisitos: zzarrumanome zzminusculas
# ----------------------------------------------------------------------------
zzarrumanome ()
{
	zzzz -h arrumanome "$1" && return

	local arquivo caminho antigo novo recursivo pastas nao i

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-d) pastas=1    ;;
			-r) recursivo=1 ;;
			-n) nao="[-n] " ;;
			* ) break       ;;
		esac
		shift
	done

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso arrumanome; return 1; }

	# Para cada arquivo que o usuário informou...
	for arquivo
	do
		# Tira a barra no final do nome da pasta
		test "$arquivo" != / && arquivo=${arquivo%/}

		# Ignora arquivos e pastas não existentes
		test -f "$arquivo" -o -d "$arquivo" || continue

		# Se for uma pasta...
		if test -d "$arquivo"
		then
			# Arruma arquivos de dentro dela (-r)
			test "${recursivo:-0}" -eq 1 &&
				zzarrumanome -r ${pastas:+-d} ${nao:+-n} "$arquivo"/*

			# Não renomeia nome da pasta (se não tiver -d)
			test "${pastas:-0}" -ne 1 && continue
		fi

		# A pasta vai ser a corrente ou o 'dirname' do arquivo (se tiver)
		caminho='.'
		zztool grep_var / "$arquivo" && caminho="${arquivo%/*}"

		# $antigo é o arquivo sem path (basename)
		antigo="${arquivo##*/}"

		# $novo é o nome arrumado com a magia negra no Sed
		novo=$(
			echo "$antigo" |
			tr -s '\t ' ' ' |  # Squeeze: TABs e espaços viram um espaço
			zzminusculas |
			sed -e "
				# Remove aspas
				s/[\"']//g

				# Remove espaços do início e do fim
				s/^  *//
				s/  *$//

				# Remove acentos
				y/àáâãäåèéêëìíîïòóôõöùúûü/aaaaaaeeeeiiiiooooouuuu/
				y/çñß¢Ð£Øø§µÝý¥¹²³/cnbcdloosuyyy123/

				# Qualquer caractere estranho vira sublinhado
				s/[^a-z0-9._-]/_/g

				# Remove sublinhados consecutivos
				s/__*/_/g

				# Remove sublinhados antes e depois de pontos e hífens
				s/_\([.-]\)/\1/g
				s/\([.-]\)_/\1/g

				# Hífens no início do nome são proibidos
				s/^-/_/

				# Não permite nomes vazios
				s/^$/_/"
		)

		# Se der problema com a codificação, é o y/// do Sed anterior quem estoura
		if test $? -ne 0
		then
			zztool erro "Ops. Problemas com a codificação dos caracteres."
			zztool erro "O arquivo original foi preservado: $arquivo"
			return 1
		fi

		# Nada mudou, então o nome atual já certo
		test "$antigo" = "$novo" && continue

		# Se já existir um arquivo/pasta com este nome, vai
		# colocando um número no final, até o nome ser único.
		if test -e "$caminho/$novo"
		then
			i=1
			while test -e "$caminho/$novo.$i"
			do
				i=$((i+1))
			done
			novo="$novo.$i"
		fi

		# Tudo certo, temos um nome novo e único

		# Mostra o que será feito
		echo "$nao$arquivo -> $caminho/$novo"

		# E faz
		test -n "$nao" || mv -- "$arquivo" "$caminho/$novo"
	done
}

# ----------------------------------------------------------------------------
# zzascii
# Mostra a tabela ASCII com todos os caracteres imprimíveis (32-126,161-255).
# O formato utilizando é: <decimal> <hexa> <octal> <caractere>.
# O número de colunas e a largura da tabela são configuráveis.
# Uso: zzascii [colunas] [largura]
# Ex.: zzascii
#      zzascii 4
#      zzascii 7 100
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2002-12-06
# Versão: 6
# Licença: GPL
# Requisitos: zzseq zzcolunar
# ----------------------------------------------------------------------------
zzascii ()
{
	zzzz -h ascii "$1" && return

	local largura_coluna decimal hexa octal caractere octal_conversao
	local num_colunas="${1:-5}"
	local largura="${2:-78}"
	local max_colunas=20
	local max_largura=500

	# Verificações básicas
	if (
		! zztool testa_numero "$num_colunas" ||
		! zztool testa_numero "$largura" ||
		test "$num_colunas" -eq 0 ||
		test "$largura" -eq 0)
	then
		zztool -e uso ascii
		return 1
	fi
	if test $num_colunas -gt $max_colunas
	then
		zztool erro "O número máximo de colunas é $max_colunas"
		return 1
	fi
	if test $largura -gt $max_largura
	then
		zztool erro "A largura máxima é de $max_largura"
		return 1
	fi

	# Largura total de cada coluna, usado no printf
	largura_coluna=$((largura / num_colunas))

	echo 'Tabela ASCII - Imprimíveis (decimal, hexa, octal, caractere)'
	echo

	for decimal in $(zzseq 32 126)
	do
		hexa=$( printf '%X'   $decimal)
		octal=$(printf '%03o' $decimal) # NNN
		caractere=$(printf "\\$octal")
		printf "%${largura_coluna}s\n" "$decimal $hexa $octal $caractere"
	done |
		zzcolunar -r -w $largura_coluna $num_colunas |
		sed 's/\(  \)\(32 20 040\)/\2\1/'
		# Sed acima é devido ao alinhamento no zzcolunar que elimina um espaço válido

	echo
	echo 'Tabela ASCII Extendida (ISO-8859-1, Latin-1) - Imprimíveis'
	echo

	# Cada caractere UTF-8 da faixa seguinte é composto por dois bytes,
	# por isso precisamos levar isso em conta no printf final
	largura_coluna=$((largura_coluna + 1))

	for decimal in $(zzseq 161 255)
	do
		hexa=$( printf '%X'   $decimal)
		octal=$(printf '%03o' $decimal) # NNN

		# http://www.lingua-systems.com/unicode-converter/unicode-mappings/encode-iso-8859-1-to-utf-8-unicode.html
		if test $decimal -le 191  # 161-191: ¡-¿
		then
			caractere=$(printf "\302\\$octal")
		else                      # 192-255: À-ÿ
			octal_conversao=$(printf '%03o' $((decimal - 64)))
			caractere=$(printf "\303\\$octal_conversao")
		fi

		# Mostra a célula atual da tabela
		printf "%${largura_coluna}s\n" "$decimal $hexa $octal $caractere"
	done |
		zzcolunar -r -w $((largura_coluna - 1)) $num_colunas
}

# ----------------------------------------------------------------------------
# zzbeep
# Aguarda N minutos e dispara uma sirene usando o 'speaker'.
# Útil para lembrar de eventos próximos no mesmo dia.
# Sem argumentos, restaura o 'beep' para o seu tom e duração originais.
# Obs.: A sirene tem 4 toques, sendo 2 tons no modo texto e apenas 1 no Xterm.
# Uso: zzbeep [números]
# Ex.: zzbeep 0
#      zzbeep 1 5 15    # espere 1 minuto, depois mais 5, e depois 15
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-04-24
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzbeep ()
{
	zzzz -h beep "$1" && return

	local minutos frequencia

	# Sem argumentos, apenas restaura a "configuração de fábrica" do beep
	test -n "$1" || {
		printf '\033[10;750]\033[11;100]\a'
		return 0
	}

	# Para cada quantidade informada pelo usuário...
	for minutos in $*
	do
		# Aguarda o tempo necessário
		printf "Vou bipar em $minutos minutos... "
		sleep $((minutos*60))

		# Ajusta o beep para toque longo (Linux modo texto)
		printf '\033[11;900]'

		# Alterna entre duas freqüências, simulando uma sirene (Linux)
		for frequencia in 500 400 500 400
		do
			printf "\033[10;$frequencia]\a"
			sleep 1
		done

		# Restaura o beep para toque normal
		printf '\033[10;750]\033[11;100]'
		echo OK
	done
}

# ----------------------------------------------------------------------------
# zzbicho
# Jogo do bicho.
# Com um número como argumento indica o bicho e o grupo.
# Se o for um número entre 1 e 25 seguido de "g", lista os números do grupo.
# Sem argumento ou com apenas "g" lista todos os grupos de bichos.
#
# Uso: zzbicho [numero] [g]
# Ex.: zzbicho 123456
#      zzbicho 14 g
#      zzbicho g
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2012-08-27
# Versão: 4
# Licença: GPL
# Requisitos: zztrim
# ----------------------------------------------------------------------------
zzbicho ()
{
	zzzz -h bicho "$1" && return

	# Verificação dos parâmetros: se há $1, ele deve ser 'g' ou um número
	if test $# -gt 0 && test "$1" != 'g' && ! zztool testa_numero "$1"
	then
		zztool -e uso bicho
		return 1
	fi

	echo "$*" |
	awk '{
		grupo[01]="Avestruz"
		grupo[02]="Águia"
		grupo[03]="Burro"
		grupo[04]="Borboleta"
		grupo[05]="Cachorro"
		grupo[06]="Cabra"
		grupo[07]="Carneiro"
		grupo[08]="Camelo"
		grupo[09]="Cobra"
		grupo[10]="Coelho"
		grupo[11]="Cavalo"
		grupo[12]="Elefante"
		grupo[13]="Galo"
		grupo[14]="Gato"
		grupo[15]="Jacaré"
		grupo[16]="Leão"
		grupo[17]="Macaco"
		grupo[18]="Porco"
		grupo[19]="Pavão"
		grupo[20]="Peru"
		grupo[21]="Touro"
		grupo[22]="Tigre"
		grupo[23]="Urso"
		grupo[24]="Veado"
		grupo[25]="Vaca"

		if ($2=="g" && $1 >= 1 && $1 <= 25) {
			numero = $1 * 4
			for (numero = ($1 * 4) - 3;numero <= ($1 *4); numero++) {
				printf "%.2d ", substr(numero,length(numero)-1,2)
			}
			print ""
		}
		else if ($1 == "g" || $1 == "") {
			for (num=1;num<=25;num++) {
				printf "%.2d %s\n",num, grupo[num]
			}
		}
		else {
			numero = substr($1,length($1)-1,2)=="00"?25:int((substr($1,length($1)-1,2) + 3) / 4)
			print grupo[numero], "(" numero ")"
		}
	}' | zztrim -r
}

# ----------------------------------------------------------------------------
# zzbissexto
# Diz se o ano informado é bissexto ou não.
# Obs.: Se o ano não for informado, usa o atual.
# Uso: zzbissexto [ano]
# Ex.: zzbissexto
#      zzbissexto 2000
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-21
# Versão: 1
# Licença: GPL
# Requisitos: zztestar
# Tags: data
# ----------------------------------------------------------------------------
zzbissexto ()
{
	zzzz -h bissexto "$1" && return

	local ano="$1"

	# Se o ano não for informado, usa o atual
	test -z "$ano" && ano=$(date +%Y)

	# Validação
	zztool -e testa_ano "$ano" || return 1

	if zztestar ano_bissexto "$ano"
	then
		echo "$ano é bissexto"
	else
		echo "$ano não é bissexto"
	fi
}

# ----------------------------------------------------------------------------
# zzblist
# Mostra se o IP informado está em alguma blacklist.
# Uso: zzblist IP
# Ex.: zzblist 200.199.198.197
#
# Autor: Vinícius Venâncio Leite <vv.leite (a) gmail com>
# Desde: 2008-10-16
# Versão: 5
# Licença: GPL
# Requisitos: zztestar
# ----------------------------------------------------------------------------
zzblist ()
{
	zzzz -h blist "$1" && return

	local URL="http://addgadgets.com/ip_blacklist/index.php?ipaddr="
	local ip="$1"
	local lista

	test -n "$1" || { zztool -e uso blist; return 1; }

	zztestar -e ip "$ip" || return 1

	lista=$(
		zztool dump "${URL}${ip}" |
		grep 'Listed' |
		sed '
			# Elimina falsos-positivos
			/ahbl\.org/d
			/shlink\.org/d

			# Elimina lixos
			/=/d
			/ *Not/d
		'
	)

	if test "$(echo "$lista" | sed '/^ *$/d' | zztool num_linhas)" -eq 0
	then
		zztool eco "O IP não está em nenhuma blacklist"
	else
		zztool eco "O IP está na(s) seguinte(s) blacklist"
		echo "$lista" | sed 's/ *Listed//'
	fi
}

# ----------------------------------------------------------------------------
# zzbraille
# Grafia Braille.
# A estrutura básica do alfabeto braille é composta por 2 colunas e 3 linhas.
# Essa estrutura é chamada de célula Braille
# E a sequência numérica padronizada é como segue:
#  1 4
#  2 5
#  3 6
# Assim fica como um guia, para quem desejar implantar essa acessibilidade.
#
# Com a opção --s1 muda o símbolo ● (relevo, em destaque, cheio)
# Com a opção --s2 muda o símbolo ○ (plano, sem destaque, vazio)
#
# Abaixo de cada célula Braille, aparece o caractere correspondente.
# Incluindo especiais de maiúscula, numérico, espaço, multi-células.
# +++++ : Maiúsculo
# +-    : Capitalize
# __    : Espaço
# ##    : Número
# -( X ): Caractere especial que ocupa mais de uma célula Braille
#
# Atenção: Prefira usar ! em texto dentro de aspas simples (')
#
# Uso: zzbraille <texto> [texto]
# Ex.: zzbraille 'Olá mundo!'
#      echo 'Good Morning, Vietnam!' | zzbraille --s2 ' '
#      zzbraille --s1 O --s2 'X' 'Um texto qualquer'
#      zzbraille --s1 . --s2 ' ' Mensagem
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-05-26
# Versão: 6
# Licença: GPL
# Requisitos: zzminusculas zzmaiusculas zzcapitalize zzseq zztestar
# ----------------------------------------------------------------------------
zzbraille ()
{
	zzzz -h braille "$1" && return

	# Lista de caracteres (quase todos)
	local caracter="\
a|1|0|0|0|0|0
b|1|1|0|0|0|0
c|1|0|0|1|0|0
d|1|0|0|1|1|0
e|1|0|0|0|1|0
f|1|1|0|1|0|0
g|1|1|0|1|1|0
h|1|1|0|0|1|0
i|0|1|0|1|0|0
j|0|1|0|1|1|0
k|1|0|1|0|0|0
l|1|1|1|0|0|0
m|1|0|1|1|0|0
n|1|0|1|1|1|0
o|1|0|1|0|1|0
p|1|1|1|1|0|0
q|1|1|1|1|1|0
r|1|1|1|0|1|0
s|0|1|1|1|0|0
t|0|1|1|1|1|0
u|1|0|1|0|0|1
v|1|1|1|0|0|1
w|0|1|0|1|1|1
x|1|0|1|1|0|1
y|1|0|1|1|1|1
z|1|0|1|0|1|1
1|1|0|0|0|0|0
2|1|1|0|0|0|0
3|1|0|0|1|0|0
4|1|0|0|1|1|0
5|1|0|0|0|1|0
6|1|1|0|1|0|0
7|1|1|0|1|1|0
8|1|1|0|0|1|0
9|0|1|0|1|0|0
0|0|1|0|1|1|0
.|0|1|0|0|1|1
,|0|1|0|0|0|0
?|0|1|0|0|0|1
;|0|1|1|0|0|0
!|0|1|1|0|1|0
-|0|0|1|0|0|1
'|0|0|1|0|0|0
*|0|0|1|0|1|0
$|0|0|0|0|1|1
:|0|1|0|0|1|0
=|0|1|1|0|1|1
â|1|0|0|0|0|1
ê|1|1|0|0|0|1
ì|1|0|0|1|0|1
ô|1|0|0|1|1|1
ù|1|0|0|0|1|1
à|1|1|0|1|0|1
ï|1|1|0|1|1|1
ü|1|1|0|0|1|1
õ|0|1|0|1|0|1
ò|0|1|0|1|1|1
ç|1|1|1|1|0|1
é|1|1|1|1|1|1
á|1|1|1|0|1|1
è|0|1|1|1|0|1
ú|0|1|1|1|1|1
í|0|0|1|1|0|0
ã|0|0|1|1|1|0
ó|0|0|1|1|0|1
(|1|1|0|0|0|1
)|0|0|1|1|1|0
[|1|1|1|0|1|1
]|0|1|1|1|1|1
{|1|1|1|0|1|1
}|0|1|1|1|1|1
>|1|0|1|0|1|0
<|0|1|0|1|0|1
°|0|0|1|0|1|1
+|0|1|1|0|1|0
×|0|1|1|0|0|1
÷|0|1|0|0|1|1
&|1|1|1|1|0|1
"

	# Caracteres especias que usam mais de uma célula Braille
	local caracter_esp='―|0|0|1|0|0|1|0|0|1|0|0|1
/|0|0|0|0|0|1|0|1|0|0|0|0
_|0|0|0|1|0|1|0|0|1|0|0|1
€|0|0|0|1|0|0|1|0|0|1|1|0
(|1|1|0|0|0|1|0|0|1|0|0|0
)|0|0|0|0|0|1|0|0|1|1|1|0
«|0|0|0|0|0|1|0|1|1|0|0|1
»|0|0|0|0|0|1|0|1|1|0|0|1
→|0|1|0|0|1|0|1|0|1|0|1|0
←|0|1|0|1|0|1|0|1|0|0|1|0
§|0|1|1|1|0|0|0|1|1|1|0|0
"|0|1|1|0|0|1
'

	local largura=$(echo $(($(tput cols)-2)))
	local c='●'
	local v='○'
	local linha1 linha2 linha3 tamanho i letra letra_original codigo linha0

	# Opção para mudar os símbolos a serem exibidos dentro da célula Braille
	# E garantindo que seja apenas um caractere usando sed. O cut e o awk falham dependendo do ambiente
	while test -n "$1"
	do
		case $1 in
			"--s1") c=$(echo "$2" | sed 's/\(.\).*/\1/'); shift; shift;;
			"--s2") v=$(echo "$2" | sed 's/\(.\).*/\1/'); shift; shift;;
			*) break;;
		esac
	done

	set - $(zztool multi_stdin "$@")
	while test -n "$1"
	do
		# Demarcando início do texto (iniciativa do autor para noção dos limites da célula Braille)
		# E sinalizando espaço entre as palavras
		linha0=${linha0}' __'
		linha1=${linha1}' 00'
		linha2=${linha2}' 00'
		linha3=${linha3}' 00'

		if zztestar numero_real "$1"
		then
			linha0=${linha0}' ##' # Para indicar que começa um número, nas apontamento abaixo da célula
			linha1=${linha1}' 01'
			linha2=${linha2}' 01'
			linha3=${linha3}' 11'
		elif test "$1" = $(zzcapitalize "$1") -a "$1" != $(zzminusculas "$1")
		then
			linha0=${linha0}' +-' # Para indicar que o texto a seguir está com a primeira letra em maiúscula (capitalize)
			linha1=${linha1}' 01'
			linha2=${linha2}' 00'
			linha3=${linha3}' 01'
		elif test "$1" = $(zzmaiusculas "$1") -a "$1" != $(zzminusculas "$1")
		then
			linha0=${linha0}' +++++' # Para indicar que o texto a seguir está todo maiúsculo
			linha1=${linha1}' 01 01'
			linha2=${linha2}' 00 00'
			linha3=${linha3}' 01 01'
		fi

		tamanho=$(echo "${#linha1} + ${#1} * 3" | bc)
		if test $tamanho -le $largura
		then
			for i in $(zzseq ${#1})
			do
				letra=$(echo $1| tr ' ' '#' | zzminusculas | sed "s/^\(.\{1,$i\}\).*/\1/" | sed 's/.*\(.\)$/\1/')
				letra_original=$(echo $1| tr ' ' '#' | sed "s/^\(.\{1,$i\}\).*/\1/" | sed 's/.*\(.\)$/\1/')
				if test -n $letra
				then
					test $letra = '/' && letra='\/'
					codigo=$(echo "$caracter" | sed -n "/^[$letra]/p")
					if zztool grep_var / "$letra"
					then
						linha0="${linha0}-( ${letra_original} )"
						linha1=$(awk -v linha="$linha1" 'BEGIN {print linha " 00 00"}')
						linha2=$(awk -v linha="$linha2" 'BEGIN {print linha " 00 10"}')
						linha3=$(awk -v linha="$linha3" 'BEGIN {print linha " 01 00"}')
					elif test $(printf ${letra}) = '\'
					then
						linha0=${linha0}'-( '${letra_original}' )'
						linha1=${linha1}' '$(awk 'BEGIN {print "00 00"}')
						linha2=${linha2}' '$(awk 'BEGIN {print "01 00"}')
						linha3=${linha3}' '$(awk 'BEGIN {print "00 10"}')
					elif test -n "$codigo"
					then
						letra_original=$(echo $letra_original | tr '#' ' ')
						linha0=${linha0}'('${letra_original}')'
						linha1=${linha1}' '$(echo $codigo | awk -F'|' '{print $2 $5}')
						linha2=${linha2}' '$(echo $codigo | awk -F'|' '{print $3 $6}')
						linha3=${linha3}' '$(echo $codigo | awk -F'|' '{print $4 $7}')
					else
						codigo=$(echo "$caracter_esp" | sed -n "/^[$letra]/p")
						test ${#codigo} -ge 25 && linha0=${linha0}'-( '${letra_original}' )'|| linha0=${linha0}'('${letra_original}')'
						linha1=${linha1}' '$(echo $codigo | awk -F'|' '{print $2 $5, $8 $11}')
						linha2=${linha2}' '$(echo $codigo | awk -F'|' '{print $3 $6, $9 $12}')
						linha3=${linha3}' '$(echo $codigo | awk -F'|' '{print $4 $7, $10 $13}')
					fi
				fi
			done
			shift
		else
			echo "$linha1" | sed "s/1/$c/g;s/0/$v/g"
			echo "$linha2" | sed "s/1/$c/g;s/0/$v/g"
			echo "$linha3" | sed "s/1/$c/g;s/0/$v/g"
			echo "$linha0"
			echo
			unset linha1
			unset linha2
			unset linha3
			unset linha0
		fi
	done
	echo "$linha1" | sed "s/1/$c/g;s/0/$v/g"
	echo "$linha2" | sed "s/1/$c/g;s/0/$v/g"
	echo "$linha3" | sed "s/1/$c/g;s/0/$v/g"
	echo "$linha0"
	echo
}

# ----------------------------------------------------------------------------
# zzbrasileirao
# http://esporte.uol.com.br/
# Mostra a tabela atualizada do Campeonato Brasileiro - Série A, B, C ou D.
# Se for fornecido um numero mostra os jogos da rodada, com resultados.
#
# Nomenclatura:
#   PG  - Pontos Ganhos
#   J   - Jogos
#   V   - Vitórias
#   E   - Empates
#   D   - Derrotas
#   GP  - Gols Pró
#   GC  - Gols Contra
#   SG  - Saldo de Gols
#   (%) - Aproveitamento (pontos)
#
# Uso: zzbrasileirao [a|b|c|d] [numero rodada]
# Ex.: zzbrasileirao
#      zzbrasileirao a
#      zzbrasileirao b
#      zzbrasileirao c
#      zzbrasileirao 27
#      zzbrasileirao b 12
#
# Autor: Alexandre Brodt Fernandes, www.xalexandre.com.br
# Desde: 2011-05-28
# Versão: 24
# Licença: GPL
# Requisitos: zzecho zzpad
# ----------------------------------------------------------------------------
zzbrasileirao ()
{
	zzzz -h brasileirao "$1" && return

	test $(date +%Y%m%d) -lt 20180414 && { zztool erro "Campeonato Brasileiro 2018 só a partir de 14 de Abril."; return 1; }

	local rodada serie ano time1 time2 horario linha num_linha
	local url="http://esporte.uol.com.br/futebol"

	test $# -gt 2 && { zztool -e uso brasileirao; return 1; }

	serie='a'
	case $1 in
	a | b | c | d) serie="$1"; shift;;
	esac

	if test -n "$1"
	then
		zztool testa_numero "$1" && rodada="$1" || { zztool -e uso brasileirao; return 1; }
	fi

	test "$serie" = "a" && url="${url}/campeonatos/brasileirao/jogos" || url="${url}/campeonatos/serie-${serie}/jogos"

	if test -n "$rodada"
	then
		zztool testa_numero $rodada || { zztool -e uso brasileirao; return 1; }
		zztool dump "$url" |
		sed -n "/Rodada ${rodada}$/,/\(Rodada\|^ *$\)/p" |
		sed '
		/Rodada /d
		s/^ *//
		/[0-9]h[0-9]/{s/pós[ -]jogo *//; s/\(h[0-9][0-9]\).*/\1/;}
		s/ [A-Z][A-Z][A-Z]$//
		s/ *__*//' |
		awk '
			NR % 3 ~ /^[12]$/ {
				if ($1 ~ /^[0-9-]{1,}$/) {
					placar[NR % 3]=$1; $1=""
				}
				sub(/^ */,"");sub(/ *$/,"")
				time[NR % 3]=" " $0 " "
			}
			NR % 3 == 0 {
				sub(/  *$/,""); print time[1] placar[1] "|" placar[2] time[2] "|" $0
				placar[1]="";placar[2]=""
			}
		' |
		sed '/^ *$/d' |
		while read linha
		do
			time1=$(  echo $linha | cut -d"|" -f 1 )
			time2=$(  echo $linha | cut -d"|" -f 2 )
			horario=$(echo $linha | cut -d"|" -f 3 | sed 's/^ *//' )
			echo "$(zzpad -l 22 $time1) X $(zzpad -r 22 $time2) $horario"
		done
	else
		zztool eco $(echo "Série $serie" | tr 'abcd' 'ABCD')
		if test "$serie" = "c" -o "$serie" = "d"
		then
			zztool dump "$url" |
			sed -n "/Grupo [AB][1-9]\{0,2\} *PG .*/,/Rodada 1 *$/{s/^/_/;s/.*Rodada .*//;s/°/./;p;}" |
			while read linha
			do
				if echo "$linha" | grep -E '[12]\.' >/dev/null && test "$serie" = "c"
				then
					zzecho -f verde -l preto "$linha"
				elif echo "$linha" | grep '1\.' >/dev/null && test "$serie" = "d"
				then
					zzecho -f verde -l preto "$linha"
				elif echo "$linha" | grep -E '[34]\.' >/dev/null && test "$serie" = "c"
				then
					zzecho -f verde -l preto "$linha"
				elif echo "$linha" | grep -E '(9\.|10\.)' >/dev/null && test "$serie" = "c"
				then
					zzecho -f vermelho -l preto "$linha"
				else
					echo "$linha"
				fi
			done |
			tr -d _
			if test "$serie" = "c"
			then
				zzecho -f verde -l preto " Quartas de Final "
				zzecho -f vermelho -l preto "   Rebaixamento   "
			else
				zzecho -f verde -l preto " Segunda Fase "
			fi
		else
			num_linha=0
			zztool dump "$url" |
			sed -n "/^ *Classificação *PG/,/20°/{ s/^/_/; s/°/./; p; }" |
			while read linha
			do
				linha=$(echo "$linha" | awk '{pontos=sprintf("%3d", $NF);sub(/[0-9]+$/,pontos);print}')
				num_linha=$((num_linha + 1))
				case $num_linha in
					[2-5]) zzecho -f verde -l preto "$linha";;
					[67])
						if test "$serie" = "a"
						then
							zzecho -f verde -l preto "$linha"
						else
							echo "$linha"
						fi
					;;
					[89] | 1[0-3])
						if test "$serie" = "a"
						then
							zzecho -f ciano -l preto "$linha"
						else
							echo "$linha"
						fi
					;;
					1[89] | 2[01] ) zzecho -f vermelho -l preto "$linha";;
					*) echo "$linha";;
				esac
			done |
			tr -d _

				echo
				if test "$serie" = "a"
				then
					zzecho -f verde -l preto  " Libertadores  "
					zzecho -f ciano -l preto  " Sul-Americana "
				elif test "$serie" = "b"
				then
					zzecho -f verde -l preto  "   Série  A    "
				fi
				zzecho -f vermelho -l preto   " Rebaixamento  "

		fi
	fi
}

# ----------------------------------------------------------------------------
# zzbyte
# Conversão entre grandezas de bytes (mega, giga, tera, etc).
# Uso: zzbyte N [unidade-entrada] [unidade-saida]  # BKMGTPEZY
# Ex.: zzbyte 2048                    # Quanto é 2048 bytes?  -- 2K
#      zzbyte 2048 K                  # Quanto é 2048KB?      -- 2M
#      zzbyte 7 K M                   # Quantos megas em 7KB? -- 0.006M
#      zzbyte 7 G B                   # Quantos bytes em 7GB? -- 7516192768B
#      for u in b k m g t p e z y; do zzbyte 2 t $u; done
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-03-01
# Versão: 1
# Licença: GPL
# Requisitos: zzmaiusculas
# ----------------------------------------------------------------------------
zzbyte ()
{
	zzzz -h byte "$1" && return

	local i i_entrada i_saida diferenca operacao passo falta
	local unidades='BKMGTPEZY' # kilo, mega, giga, etc
	local n="$1"
	local entrada="${2:-B}"
	local saida="${3:-.}"

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso byte; return 1; }

	# Sejamos amigáveis com o usuário permitindo minúsculas também
	entrada=$(echo "$entrada" | zzmaiusculas)
	saida=$(  echo "$saida"   | zzmaiusculas)

	# Verificações básicas
	if ! zztool grep_var "$entrada" "$unidades"
	then
		zztool erro "Unidade inválida '$entrada'"
		return 1
	fi
	if ! zztool grep_var "$saida" ".$unidades"
	then
		zztool erro "Unidade inválida '$saida'"
		return 1
	fi
	zztool -e testa_numero "$n" || return 1

	# Extrai os números (índices) das unidades de entrada e saída
	i_entrada=$(zztool index_var "$entrada" "$unidades")
	i_saida=$(  zztool index_var "$saida"   "$unidades")

	# Sem $3, a unidade de saída será otimizada
	test $i_saida -eq 0 && i_saida=15

	# A diferença entre as unidades guiará os cálculos
	diferenca=$((i_saida - i_entrada))
	if test "$diferenca" -lt 0
	then
		operacao='*'
		passo='-'
	else
		operacao='/'
		passo='+'
	fi

	i="$i_entrada"
	while test "$i" -ne "$i_saida"
	do
		# Saída automática (sem $3)
		# Chegamos em um número menor que 1024, hora de sair
		test "$n" -lt 1024 -a "$i_saida" -eq 15 && break

		# Não ultrapasse a unidade máxima (Yota)
		test "$i" -eq ${#unidades} -a "$passo" = '+' && break

		# 0 < n < 1024 para unidade crescente, por exemplo: 1 B K
		# É hora de dividir com float e colocar zeros à esquerda
		if test "$n" -gt 0 -a "$n" -lt 1024 -a "$passo" = '+'
		then
			# Quantos dígitos ainda faltam?
			falta=$(( (i_saida - i - 1) * 3))

			# Pulamos direto para a unidade final
			i="$i_saida"

			# Cálculo preciso usando o bc (Retorna algo como .090)
			n=$(echo "scale=3; $n / 1024" | bc)
			test "$n" = '0' && break # 1 / 1024 = 0

			# Completa os zeros que faltam
			test "$falta" -gt 0 && n=$(printf "%0.${falta}f%s" 0 "${n#.}")

			# Coloca o zero na frente, caso necessário
			test "${n#.}" != "$n" && n="0$n"

			break
		fi

		# Terminadas as exceções, este é o processo normal
		# Aumenta/diminui a unidade e divide/multiplica por 1024
		i=$(($i $passo 1))
		n=$(($n $operacao 1024))
	done

	# Mostra o resultado
	echo "$n"$(echo "$unidades" | cut -c "$i")
}

# ----------------------------------------------------------------------------
# zzcalculaip
# Calcula os endereços de rede e broadcast à partir do IP e máscara da rede.
# Obs.: Se não especificada, será usada a máscara padrão (RFC 1918) ou 24.
# Uso: zzcalculaip ip [netmask]
# Ex.: zzcalculaip 127.0.0.1 24
#      zzcalculaip 10.0.0.0/8
#      zzcalculaip 192.168.10.0 255.255.255.240
#      zzcalculaip 10.10.10.0
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2005-09-01
# Versão: 2
# Licença: GPL
# Requisitos: zzconverte zztestar
# ----------------------------------------------------------------------------
zzcalculaip ()
{
	zzzz -h calculaip "$1" && return

	local endereco mascara rede broadcast
	local mascara_binario mascara_decimal mascara_ip
	local i ip1 ip2 ip3 ip4 nm1 nm2 nm3 nm4 componente

	# Verificação dos parâmetros
	test $# -eq 0 -o $# -gt 2 && { zztool -e uso calculaip; return 1; }

	# Obtém a máscara da rede (netmask)
	if zztool grep_var / "$1"
	then
		endereco=${1%/*}
		mascara="${1#*/}"
	else
		endereco=$1

		# Use a máscara informada pelo usuário ou a máscara padrão
		if test $# -gt 1
		then
			mascara=$2
		else
			# A máscara padrão é determinada pela RFC 1918 (valeu jonerworm)
			# http://tools.ietf.org/html/rfc1918
			#
			#   10.0.0.0    - 10.255.255.255  (10/8 prefix)
			#   172.16.0.0  - 172.31.255.255  (172.16/12 prefix)
			#   192.168.0.0 - 192.168.255.255 (192.168/16 prefix)
			#
			case "$1" in
				10.*        ) mascara=8  ;;
				172.1[6-9].*) mascara=12 ;;
				172.2?.*    ) mascara=12 ;;
				172.3[01].* ) mascara=12 ;;
				192.168.*   ) mascara=16 ;;
				127.*       ) mascara=8  ;;
				*           ) mascara=24 ;;
			esac
		fi
	fi

	# Verificações básicas
	if ! (
		zztestar ip $mascara || (
		zztool testa_numero $mascara && test $mascara -le 32))
	then
		zztool erro "Máscara inválida: $mascara"
		return 1
	fi
	zztestar -e ip $endereco || return 1

	# Guarda os componentes da máscara em $1, $2, ...
	# Ou é um ou quatro componentes: 24 ou 255.255.255.0
	set - $(echo $mascara | tr . ' ')

	# Máscara no formato NN
	if test $# -eq 1
	then
		# Converte de decimal para binário
		# Coloca N números 1 grudados '1111111' (N=$1)
		# e completa com zeros à direita até 32, com pontos:
		# $1=12 vira 11111111.11110000.00000000.00000000
		mascara=$(printf "%$1s" 1 | tr ' ' 1)
		mascara=$(
			printf '%-32s' $mascara |
			tr ' ' 0 |
			sed 's/./&./24 ; s/./&./16 ; s/./&./8'
		)
	fi

	# Conversão de decimal para binário nos componentes do IP e netmask
	for i in 1 2 3 4
	do
		componente=$(echo $endereco | cut -d'.' -f $i)
		eval ip$i=$(printf '%08d' $(zzconverte db $componente))

		componente=$(echo $mascara | cut -d'.' -f $i)
		if test -n "$2"
		then
			eval nm$i=$(printf '%08d' $(zzconverte db $componente))
		else
			eval nm$i=$componente
		fi
	done

	# Uma verificação na máscara depois das conversões
	mascara_binario=$nm1$nm2$nm3$nm4
	if ! (
		zztestar binario $mascara_binario &&
		test ${#mascara_binario} -eq 32)
	then
		zztool erro 'Máscara inválida'
		return 1
	fi

	mascara_decimal=$(echo $mascara_binario | tr -d 0)
	mascara_decimal=${#mascara_decimal}
	mascara_ip=$((2#$nm1)).$((2#$nm2)).$((2#$nm3)).$((2#$nm4))

	echo "End. IP  : $endereco"
	echo "Mascara  : $mascara_ip = $mascara_decimal"

	rede=$(( ((2#$ip1$ip2$ip3$ip4)) & ((2#$nm1$nm2$nm3$nm4)) ))
	i=$(echo $nm1$nm2$nm3$nm4 | tr 01 10)
	broadcast=$(($rede | ((2#$i)) ))

	# Cálculo do endereço de rede
	endereco=""
	for i in 1 2 3 4
	do
		ip1=$((rede & 255))
		rede=$((rede >> 8))
		endereco="$ip1.$endereco"
	done

	echo "Rede     : ${endereco%.} / $mascara_decimal"

	# Cálculo do endereço de broadcast
	endereco=''
	for i in 1 2 3 4
	do
		ip1=$((broadcast & 255))
		broadcast=$((broadcast >> 8))
		endereco="$ip1.$endereco"
	done
	echo "Broadcast: ${endereco%.}"
}

# ----------------------------------------------------------------------------
# zzcalcula
# Calculadora.
# Wrapper para o comando bc, que funciona no formato brasileiro: 1.234,56.
# Obs.: Números fracionados podem vir com vírgulas ou pontos: 1,5 ou 1.5.
# Use a opção --soma para somar uma lista de números vindos da STDIN.
#
# Uso: zzcalcula operação|--soma
# Ex.: zzcalcula 2,20 + 3.30          # vírgulas ou pontos, tanto faz
#      zzcalcula '2^2*(4-1)'          # 2 ao quadrado vezes 4 menos 1
#      echo 2 + 2 | zzcalcula         # lendo da entrada padrão (STDIN)
#      zzseq 5 | zzcalcula --soma     # soma números da STDIN
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-05-04
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzcalcula ()
{
	zzzz -h calcula "$1" && return

	local soma

	# Opção de linha de comando
	if test "$1" = '--soma'
	then
		soma=1
		shift
	fi

	# A opção --soma só lê dados da STDIN, não deve ter argumentos
	if test -n "$soma" -a $# -gt 0
	then
		zztool -e uso calcula
		return 1
	fi

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |

	# Limpeza nos dados para chegarem bem no bc
	sed '
		# Espaços só atrapalham (tab+espaço)
		s/[	 ]//g

		# Remove separador de milhares
		s/\.\([0-9][0-9][0-9]\)/\1/g
		' |

	# Temos dados multilinha para serem somados?
	if test -n "$soma"
	then
		sed '
			# Remove linhas em branco
			/^$/d

			# Números sem sinal são positivos
			s/^[0-9]/+&/

			# Se o primeiro da lista tiver sinal + dá erro no bc
			1 s/^+//' |
		# Junta as linhas num única tripa, exemplo: 5+7-3+1-2
		#tr -d '\n'
		paste -s -d ' ' - | sed 's/ //g'
	else
		cat -
	fi |

	# O resultado deve ter somente duas casas decimais
	sed 's/^/scale=2;/' |

	# Entrada de números com vírgulas ou pontos, saída sempre com vírgulas
	sed y/,/./ | bc | sed y/./,/ |

	# Adiciona separador de milhares
	sed '
		s/\([0-9]\)\([0-9][0-9][0-9]\)$/\1.\2/

		:loop
		s/\([0-9]\)\([0-9][0-9][0-9][,.]\)/\1.\2/
		t loop
	'
}

# ----------------------------------------------------------------------------
# zzcapitalize
# Altera Um Texto Para Deixar Todas As Iniciais De Palavras Em Maiúsculas.
# Use a opção -1 para converter somente a primeira letra de cada linha.
# Use a opção -w para adicionar caracteres de palavra (Padrão: A-Za-z0-9áéí…)
#
# Uso: zzcapitalize [texto]
# Ex.: zzcapitalize root                             # Root
#      zzcapitalize kung fu panda                    # Kung Fu Panda
#      zzcapitalize -1 kung fu panda                 # Kung fu panda
#      zzcapitalize quero-quero                      # Quero-Quero
#      zzcapitalize água ênfase último               # Água Ênfase Último
#      echo eu_uso_camel_case | zzcapitalize         # Eu_Uso_Camel_Case
#      echo "i don't care" | zzcapitalize            # I Don'T Care
#      echo "i don't care" | zzcapitalize -w \'      # I Don't Care
#      cat arquivo.txt | zzcapitalize
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2013-02-21
# Versão: 5
# Licença: GPL
# Requisitos: zzminusculas
# ----------------------------------------------------------------------------
zzcapitalize ()
{
	zzzz -h capitalize "$1" && return

	local primeira todas filtros extra x
	local acentuadas='àáâãäåèéêëìíîïòóôõöùúûüçñÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÇÑ'
	local palavra='A-Za-z0-9'
	local soh_primeira=0

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-1)
				soh_primeira=1
				shift
			;;
			-w)
				# Escapa a " pra não dar problema no sed adiante
				extra=$(echo "$2" | sed 's/"/\\"/g')
				shift
				shift
			;;
			*) break ;;
		esac
	done

	# Aqui está a lista de caracteres que compõem uma palavra.
	# Estes caracteres *não* disparam a capitalização da letra seguinte.
	# Esta regex é usada na variável $todas, a seguir.
	x="[^$palavra$acentuadas$extra]"

	# Filtro que converte pra maiúsculas somente a primeira letra da linha
	primeira='
		s_^a_A_ ; s_^n_N_ ; s_^à_À_ ; s_^ï_Ï_ ;
		s_^b_B_ ; s_^o_O_ ; s_^á_Á_ ; s_^ò_Ò_ ;
		s_^c_C_ ; s_^p_P_ ; s_^â_Â_ ; s_^ó_Ó_ ;
		s_^d_D_ ; s_^q_Q_ ; s_^ã_Ã_ ; s_^ô_Ô_ ;
		s_^e_E_ ; s_^r_R_ ; s_^ä_Ä_ ; s_^õ_Õ_ ;
		s_^f_F_ ; s_^s_S_ ; s_^å_Å_ ; s_^ö_Ö_ ;
		s_^g_G_ ; s_^t_T_ ; s_^è_È_ ; s_^ù_Ù_ ;
		s_^h_H_ ; s_^u_U_ ; s_^é_É_ ; s_^ú_Ú_ ;
		s_^i_I_ ; s_^v_V_ ; s_^ê_Ê_ ; s_^û_Û_ ;
		s_^j_J_ ; s_^w_W_ ; s_^ë_Ë_ ; s_^ü_Ü_ ;
		s_^k_K_ ; s_^x_X_ ; s_^ì_Ì_ ; s_^ç_Ç_ ;
		s_^l_L_ ; s_^y_Y_ ; s_^í_Í_ ; s_^ñ_Ñ_ ;
		s_^m_M_ ; s_^z_Z_ ; s_^î_Î_ ;
	'
	# Filtro que converte pra maiúsculas a primeira letra de cada palavra.
	# Note que o delimitador usado no s///g foi o espaço em branco.
	todas="
		s \($x\)a \1A g ; s \($x\)n \1N g ; s \($x\)à \1À g ; s \($x\)ï \1Ï g ;
		s \($x\)b \1B g ; s \($x\)o \1O g ; s \($x\)á \1Á g ; s \($x\)ò \1Ò g ;
		s \($x\)c \1C g ; s \($x\)p \1P g ; s \($x\)â \1Â g ; s \($x\)ó \1Ó g ;
		s \($x\)d \1D g ; s \($x\)q \1Q g ; s \($x\)ã \1Ã g ; s \($x\)ô \1Ô g ;
		s \($x\)e \1E g ; s \($x\)r \1R g ; s \($x\)ä \1Ä g ; s \($x\)õ \1Õ g ;
		s \($x\)f \1F g ; s \($x\)s \1S g ; s \($x\)å \1Å g ; s \($x\)ö \1Ö g ;
		s \($x\)g \1G g ; s \($x\)t \1T g ; s \($x\)è \1È g ; s \($x\)ù \1Ù g ;
		s \($x\)h \1H g ; s \($x\)u \1U g ; s \($x\)é \1É g ; s \($x\)ú \1Ú g ;
		s \($x\)i \1I g ; s \($x\)v \1V g ; s \($x\)ê \1Ê g ; s \($x\)û \1Û g ;
		s \($x\)j \1J g ; s \($x\)w \1W g ; s \($x\)ë \1Ë g ; s \($x\)ü \1Ü g ;
		s \($x\)k \1K g ; s \($x\)x \1X g ; s \($x\)ì \1Ì g ; s \($x\)ç \1Ç g ;
		s \($x\)l \1L g ; s \($x\)y \1Y g ; s \($x\)í \1Í g ; s \($x\)ñ \1Ñ g ;
		s \($x\)m \1M g ; s \($x\)z \1Z g ; s \($x\)î \1Î g ;
	"

	# Aplicando a opção -1, caso informada
	test $soh_primeira -eq 1 && todas=''

	filtros="$primeira $todas"

	# Texto via STDIN ou argumentos
	# Primeiro converte tudo pra minúsculas, depois capitaliza as iniciais
	zztool multi_stdin "$@" | zzminusculas | sed "$filtros"
}

# ----------------------------------------------------------------------------
# zzcaracoroa
# Exibe 'cara' ou 'coroa' aleatoriamente.
# Uso: zzcaracoroa
# Ex.: zzcaracoroa
#
# Autor: Angelito M. Goulart, www.angelitomg.com
# Desde: 2012-12-06
# Versão: 1
# Licença: GPL
# Requisitos: zzaleatorio
# ----------------------------------------------------------------------------
zzcaracoroa ()
{

	# Comando especial das funcoes ZZ
	zzzz -h caracoroa "$1" && return

	# Gera um numero aleatorio entre 0 e 1. 0 -> Cara, 1 -> Coroa
	local NUM="$(zzaleatorio 1)"

	# Verifica o numero gerado e exibe o resultado
	if test $NUM -eq 0
	then
		echo "Cara"
	else
		echo "Coroa"
	fi

}

# ----------------------------------------------------------------------------
# zzcarnaval
# Mostra a data da terça-feira de Carnaval para qualquer ano.
# Obs.: Se o ano não for informado, usa o atual.
# Regra: 47 dias antes do domingo de Páscoa.
# Uso: zzcarnaval [ano]
# Ex.: zzcarnaval
#      zzcarnaval 1999
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-10-23
# Versão: 1
# Licença: GPL
# Requisitos: zzdata zzpascoa
# Tags: data
# ----------------------------------------------------------------------------
zzcarnaval ()
{
	zzzz -h carnaval "$1" && return

	local ano="$1"

	# Se o ano não for informado, usa o atual
	test -z "$ano" && ano=$(date +%Y)

	# Validação
	zztool -e testa_ano $ano || return 1

	# Ah, como é fácil quando se tem as ferramentas certas ;)
	zzdata $(zzpascoa $ano) - 47
}

# ----------------------------------------------------------------------------
# zzcep
# http://www.achecep.com.br
# Busca o CEP de qualquer rua de qualquer cidade do país ou vice-versa.
# Pode-se fornecer apenas o CEP, ou o endereço com estado.
# Uso: zzcep <endereço estado| CEP>
# Ex.: zzcep Rua Santa Ifigênia, São Paulo, SP
#      zzcep 01310-000
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-11-08
# Versão: 4
# Licença: GPL
# Requisitos: zzsemacento zzminusculas zzxml zzjuntalinhas zzcolunar zztrim zzpad
# ----------------------------------------------------------------------------
zzcep ()
{
	zzzz -h cep "$1" && return

	local end cepend pagina1 pages
	local url='http://cep.guiamais.com.br'

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso cep; return 1; }

	# Testando se parametro é o CEP
	if echo "$1" | grep -E '^[0-9]{5}-[0-9]{3}$' > /dev/null
	then
		end=0
		cepend="$1"
	else
		end=1
		cepend=$(echo "$*" | zzsemacento | zzminusculas | sed "s/, */-/g;$ZZSEDURL")
	fi

	# A primeira página ou endereço das várias páginas
	pagina1=$(zztool source "${url}/busca?word=${cepend}")

	if echo "$pagina1" | grep 'sr-only' >/dev/null
	then
		for pages in $(echo "$pagina1" | grep 'sr-only' | sed 's/.*href="//;s/".*//')
		do
			zztool source "$pages"
		done
	else
		echo "$pagina1"
	fi |
		zzxml --tag th --tag td |
		zzjuntalinhas -i '<td' -f '</td>' -d ' ' |
		zzjuntalinhas -i '<th' -f '</th>' -d ' ' |
		sed 's|> </a>|> - </a>|g' |
		zzxml --untag |
		if test "$end" -eq 1
		then
			awk 'NR % 5 != 4' |
			zzcolunar -s '|' -z 4
		else
			awk 'NR % 5 != 4 && NR % 5 != 0' |
			zzcolunar -s '|' -z 3
		fi |
		sed '2,$ { /LOGRADOURO/d; }' |
		zztrim | tr -s ' ' |
		while IFS="|" read logradouro bairro cidade cep
		do
			echo "$(zzpad 65 $logradouro) $(zzpad 25 $bairro) $(zzpad 30 $cidade) $cep"
		done |
		zztrim
}

# ----------------------------------------------------------------------------
# zzchavepgp
# http://pgp.mit.edu
# Busca a identificação da chave PGP, fornecido o nome ou e-mail da pessoa.
# Uso: zzchavepgp nome|e-mail
# Ex.: zzchavepgp Carlos Oliveira da Silva
#      zzchavepgp carlos@dominio.com.br
#
# Autor: Rodrigo Missiaggia
# Desde: 2001-10-01
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzchavepgp ()
{
	zzzz -h chavepgp "$1" && return

	local url='http://pgp.mit.edu:11371'
	local padrao=$(echo $* | sed "$ZZSEDURL")

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso chavepgp; return 1; }

	zztool dump "http://pgp.mit.edu:11371/pks/lookup?search=$padrao&op=index" |
		sed 1,2d |
		sed '
			# Remove linhas em branco
			/^$/ d
			# Remove linhas ____________________
			/^ *___*$/ d
			/^ *---*$/ d'
}

# ----------------------------------------------------------------------------
# zzchecamd5
# Checa o md5sum de arquivos baixados da net.
# Nota: A função checa o arquivo no diretório corrente (./)
# Uso: zzchecamd5 arquivo md5sum
# Ex.: zzchecamd5 ./ubuntu-8.10.iso f9e0494e91abb2de4929ef6e957f7753
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-10-31
# Versão: 3
# Licença: GPLv2
# Requisitos: zzmd5
# ----------------------------------------------------------------------------
zzchecamd5 ()
{

	# Variaveis locais
	local arquivo valor_md5 md5_site

	# Help da funcao zzchecamd5
	zzzz -h checamd5 "$1" && return

	# Faltou argumento mostrar como se usa a zzchecamd5
	if test $# != "2";then
		zztool -e uso checamd5
		return 1
	fi

	# Foi passado o caminho errado do arquivo
	if test ! -f $1 ;then
		zztool erro "Nao foi encontrado: $1"
		return 1
	fi

	# Setando variaveis
	arquivo=./$1
	md5_site=$2
	valor_md5=$(cat "$arquivo" | zzmd5)

	# Verifica se o arquivo nao foi corrompido
	if test "$md5_site" = "$valor_md5"; then
		echo "Imagem OK"
	else
		zztool erro "O md5sum nao confere!!"
		return 1
	fi
}

# ----------------------------------------------------------------------------
# zzcidade
# Lista completa com todas as 5.500+ cidades do Brasil, com busca.
# Obs.: Sem argumentos, mostra uma cidade aleatória.
#
# Uso: zzcidade [palavra|regex]
# Ex.: zzcidade              # mostra uma cidade qualquer
#      zzcidade campos       # mostra as cidades com "Campos" no nome
#      zzcidade '(SE)'       # mostra todas as cidades de Sergipe
#      zzcidade ^X           # mostra as cidades que começam com X
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2013-02-21
# Versão: 4
# Licença: GPL
# Requisitos: zzlinha zztrim zzlimpalixo
# ----------------------------------------------------------------------------
zzcidade ()
{
	zzzz -h cidade "$1" && return

	local url='https://pt.wikipedia.org/wiki/Lista_de_munic%C3%ADpios_do_Brasil'
	local cache=$(zztool cache cidade)
	local padrao="$*"

	# Se o cache está vazio, baixa listagem da Internet
	if ! test -s "$cache"
	then
		# Exemplo:^     * Aracaju (SE)
		zztool dump "$url" |
		sed -n '/A\[/,/Ver também\[/p' |
		sed '/[•*]/!d;s//\
/g;' | zztrim | zzlimpalixo |
		LC_ALL=C sort > "$cache"
	fi

	if test -z "$padrao"
	then
		# Mostra uma cidade qualquer
		zzlinha -t . "$cache"
	else
		# Faz uma busca nas cidades
		grep -h -i -- "$padrao" "$cache"
	fi
}

# ----------------------------------------------------------------------------
# zzcinclude
# Acha as funções de uma biblioteca da linguagem C (arquivos .h).
# Obs.: O diretório padrão de procura é o /usr/include.
# Uso: zzcinclude nome-biblioteca
# Ex.: zzcinclude stdio
#      zzcinclude /minha/rota/alternativa/stdio.h
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-12-15
# Versão: 1
# Licença: GPL
# Nota: requer cpp
# ----------------------------------------------------------------------------
zzcinclude ()
{
	zzzz -h cinclude "$1" && return

	local arquivo="$1"

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso cinclude; return 1; }

	# Se não começar com / (caminho relativo), coloca path padrão
	test "${arquivo#/}" = "$arquivo" && arquivo="/usr/include/$arquivo.h"

	# Verifica se o arquivo existe
	zztool -e arquivo_legivel "$arquivo" || return

	# Saída ordenada, com um Sed mágico para limpar a saída do cpp
	cpp -E "$arquivo" |
		sed '
			/^ *$/d
			/^# /d
			/^typedef/d
			/^[^a-z]/d
			s/ *(.*//
			s/.* \*\{0,1\}//' |
		sort
}

# ----------------------------------------------------------------------------
# zzcinemais
# http://www.cinemais.com.br
# Busca horários das sessões dos filmes no site do Cinemais.
# Sem argumento lista as cidades com os códigos dos cinemas.
#
# Uso: zzcinemais [código cidade]
# Ex.: zzcinemais 9
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-08-25
# Versão: 11
# Licença: GPLv2
# Requisitos: zzecho zzjuntalinhas zztrim zzutf8 zzxml
# Tags: cinema
# ----------------------------------------------------------------------------
zzcinemais ()
{
	zzzz -h cinemais "$1" && return

	local cidades
	local codigo="$1"
	local url='http://www.cinemais.com.br/programacao'

	cidades=$(
		zztool source "$url" |
		zzutf8 |
		sed -n '/cliclabeProg/,/cliclabeProg/p' |
		zzxml --notag script --tag li |
		zztrim |
		zzjuntalinhas -i '<li' -f '</li>' -d '' |
		sed 's/.*id="//; s/">/ - /; s/<.*//' |
		sort -n
	)

	if test -z "$codigo"
	then
		echo "$cidades"
		return
	fi

	if ! zztool testa_numero "$codigo"
	then
		zztool -e uso cinemais
		return 1
	fi

	if ! echo "$cidades" | grep "^${codigo} - " >/dev/null
	then
		zztool erro "Não encontrei o cinema ${codigo}"
		return 1
	fi

	# Especificando User Agent na opçãp -u "Mozilla/5.0"
	zzecho -N -l ciano $(echo "$cidades" | grep "^${codigo} - " | sed 's/^[0-9][0-9]* - //')
	zztool source -u "Mozilla/5.0" "${url}/cinema.php?cc=${codigo}" 2>/dev/null |
	zztool texto_em_iso |
	grep -E '(<td><a href|<td><small|[0-9] a [0-9])' |
	zzutf8 |
	zztrim |
	sed 's/<[^>]*>//g;s/Programa.* - //' |
	awk '{print}; NR%2==1 {print ""}' |
	sed '$d'
}

# ----------------------------------------------------------------------------
# zzcineuci
# http://www.ucicinemas.com.br
# Exibe a programação dos cinemas UCI de sua cidade.
# Se não for passado nenhum parâmetro, são listadas as cidades e cinemas.
# Uso: zzcineuci [codigo_cinema]
# Ex.: zzcineuci 14
#
# Autor: Rodrigo Pereira da Cunha <rodrigopc (a) gmail.com>
# Desde: 2009-05-04
# Versão: 10
# Licença: GPL
# Requisitos: zzunescape zztrim zzcolunar
# Tags: cinema
# ----------------------------------------------------------------------------
zzcineuci ()
{
	zzzz -h cineuci "$1" && return

	local cache=$(zztool cache cineuci)
	local cinema codigo
	local url="http://www.ucicinemas.com.br"

	if test "$1" = '--atualiza'
	then
		zztool atualiza cineuci
		shift
	fi

	# Cidades e código cinemas e cinemas
	if ! test -s "$cache"
	then
		zztool source "${url}/cinemas" |
		sed -n '
			1,/<content>/d
			/class="cinemas / { s/.*_//;s/".*//;n; p; }
			/Avatar/ { s|.*Avatar/||; s|/Avatar\..*||; p; }
			/strong/,/strong/ { /strong/d; p; }
			/<\/content>/q
		' |
		zzunescape --html |
		zztrim |
		awk '{ if ($0 ~/^[0-9]+$/) {cod=sprintf("%02d",$0);getline; print " " cod " - " $0} else print "\n" $0}' |
		tr -d '\r' |
		zztrim -V > "$cache"
	fi

	if test $# -eq 0
	then
		cat "$cache"

	elif zztool testa_numero "$1"
	then
		codigo=$(sed 's/^[ 0]*//' "$cache" | grep -o --color=never "^$1 " | tr -d ' ')
		cinema=$(sed 's/^[ 0]*//' "$cache" | grep --color=never "^$1 " | sed 's/.* - //' | zztrim)
		if test -n "$codigo"
		then
			zztool eco "$cinema"
			zztool source "${url}/api/Filmes/ListarFilmes/cinemas/${codigo}" |
			tr '[{}],' '\n\n\n\n\n' |
			sed -n '/"NomeDestaque":/p; /"Duracao":/,/"Censura":/p' |
			sed 's/.*":"//;s/"//' |
			sed "s/'//" |
			awk 'BEGIN { printf "Filme\nDuração(min)\nGênero\nCensura\n" }; 1' |
			zzcolunar -z 4 |
			zztrim
		else
			zztool erro "Não encontrei o cinema $1"
			return 1
		fi
	else
		zztool -e uso cineuci
		return 1
	fi
}

# ----------------------------------------------------------------------------
# zzcnpj
# Cria, valida ou formata um número de CNPJ.
# Obs.: O CNPJ informado pode estar formatado (pontos e hífen) ou não.
# Uso: zzcnpj [-f] [cnpj]
# Ex.: zzcnpj 12.345.678/0001-95      # valida o CNPJ informado
#      zzcnpj 12345678000195          # com ou sem pontuação
#      zzcnpj                         # gera um CNPJ válido (aleatório)
#      zzcnpj -f 12345678000195       # formata, adicionando pontuação
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2004-12-23
# Versão: 3
# Licença: GPL
# Requisitos: zzaleatorio
# ----------------------------------------------------------------------------
zzcnpj ()
{
	zzzz -h cnpj "$1" && return

	local i n somatoria digito1 digito2 cnpj base auxiliar quieto

	# Atenção:
	# Essa função é irmã-quase-gêmea da zzcpf, que está bem
	# documentada, então não vou repetir aqui os comentários.
	#
	# O cálculo dos dígitos verificadores também é idêntico,
	# apenas com uma máscara numérica maior, devido à quantidade
	# maior de dígitos do CNPJ em relação ao CPF.

	cnpj=$(echo "$*" | tr -d -c 0123456789)

	# CNPJ válido formatado
	if test "$1" = '-f'
	then
		cnpj=$(echo "$cnpj" | sed 's/^0*//')

		# Só continua se o CNPJ for válido
		auxiliar=$(zzcnpj $cnpj 2>&1)
		if test "$auxiliar" != 'CNPJ válido'
		then
			zztool erro "$auxiliar"
			return 1
		fi

		cnpj=$(printf %014d "$cnpj")
		echo $cnpj | sed '
			s|.|&-|12
			s|.|&/|8
			s|.|&.|5
			s|.|&.|2
		'
		return 0
	fi

	# CNPJ válido não formatado
	if test "$1" = '-F'
	then

		if test "${#cnpj}" -eq 0
		then
			zzcnpj | tr -d -c '0123456789\n'
			return 0
		fi

		cnpj=$(echo "$cnpj" | sed 's/^0*//')

		# Só continua se o CNPJ for válido
		auxiliar=$(zzcnpj $cnpj 2>&1)
		if test "$auxiliar" != 'CNPJ válido'
		then
			zztool erro "$auxiliar"
			return 1
		fi

		printf "%014d\n" "$cnpj"
		return 0
	fi

	test "$1" = '-q' && quieto=1

	if test -n "$cnpj"
	then
		# CNPJ do usuário
		cnpj=$(printf %014d "$cnpj")

		if test ${#cnpj} -ne 14
		then
			test -n "$quieto" || zztool erro 'CNPJ inválido (deve ter 14 dígitos)'
			return 1
		fi

		base="${cnpj%??}"

		for ((i=0;i<13;i++))
			do
				auxiliar=$(echo "$base" | sed "s/$i/X/g")
				if test "$auxiliar" = "XXXXXXXXXXXX"
				then
					test -n "$quieto" || zztool erro "CNPJ inválido (não pode conter os 12 primeiros digitos iguais)"
					return 1
				fi
			done
		#Fim do laço de verificação de digitos repetidos

	else
		# CNPJ gerado aleatoriamente

		while test ${#cnpj} -lt 8
		do
			cnpj="$cnpj$(zzaleatorio 8)"
		done

		cnpj="${cnpj}0001"
		base="$cnpj"
	fi

	# Cálculo do dígito verificador 1

	set - $(echo "$base" | sed 's/./& /g')

	somatoria=0
	for i in 5 4 3 2 9 8 7 6 5 4 3 2
	do
		n="$1"
		somatoria=$((somatoria + (i * n)))
		shift
	done

	digito1=$((11 - (somatoria % 11)))
	test $digito1 -ge 10 && digito1=0

	# Cálculo do dígito verificador 2

	set - $(echo "$base" | sed 's/./& /g')

	somatoria=0
	for i in 6 5 4 3 2 9 8 7 6 5 4 3 2
	do
		n="$1"
		somatoria=$((somatoria + (i * n)))
		shift
	done
	somatoria=$((somatoria + digito1 * 2))

	digito2=$((11 - (somatoria % 11)))
	test $digito2 -ge 10 && digito2=0

	# Mostra ou valida o CNPJ
	if test ${#cnpj} -eq 12
	then
		echo "$cnpj$digito1$digito2" |
			sed 's|\(..\)\(...\)\(...\)\(....\)|\1.\2.\3/\4-|'
	else
		if test "${cnpj#????????????}" = "$digito1$digito2"
		then
			test -n "$quieto" || echo 'CNPJ válido'
		else
			# Boa ação do dia: mostrar quais os verificadores corretos
			test -n "$quieto" || zztool erro "CNPJ inválido (deveria terminar em $digito1$digito2)"
			return 1
		fi
	fi
}

# ----------------------------------------------------------------------------
# zzcodchar
# Codifica caracteres como entidades HTML e XML (&lt; &#62; ...).
# Entende entidades (&gt;), códigos decimais (&#62;) e hexadecimais (&#x3E;).
#
# Opções: --html/--xml  Codifica caracteres em códigos HTML/XML
#         --hex         Codifica caracteres em códigos hexadecimais
#         --dec         Codifica caracteres em códigos decimais
#         -s            Com essa opção também codifica os espaços
#         --listar      Mostra a listagem completa de codificação
#                       Ou só a listagem da codificação escolhida
#
# Uso: zzcodchar [-s] [--listar cod] [--html|--xml|--dec|--hex] [arquivo(s)]
# Ex.: zzcodchar --html arquivo.xml
#      zzcodchar --hex  arquivo.html
#      cat arquivo.html | zzcodchar --dec
#      zzcodchar --listar html     #  Listagem dos caracteres e códigos html
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2015-12-07
# Versão: 3
# Licença: GPL
# Requisitos: zztrim zzpad
# ----------------------------------------------------------------------------
zzcodchar ()
{
	zzzz -h codchar "$1" && return

	local cods codspace codsed
	local char html hex dec

	codspace="s/ /\&	nbsp	#xA0	#160	;/g;"

	cods="s/&/\&	amp	#x26	#38	;/g;
s/\"/\&	quot	#x22	#34	;/g;
s/'/\&	apos	#x27	#39	;/g;
s/</\&	lt	#x3C	#60	;/g;
s/>/\&	gt	#x3E	#62	;/g;
s/¡/\&	iexcl	#xA1	#161	;/g;
s/¢/\&	cent	#xA2	#162	;/g;
s/£/\&	pound	#xA3	#163	;/g;
s/¤/\&	curren	#xA4	#164	;/g;
s/¥/\&	yen	#xA5	#165	;/g;
s/¦/\&	brvbar	#xA6	#166	;/g;
s/§/\&	sect	#xA7	#167	;/g;
s/¨/\&	uml	#xA8	#168	;/g;
s/©/\&	copy	#xA9	#169	;/g;
s/ª/\&	ordf	#xAA	#170	;/g;
s/«/\&	laquo	#xAB	#171	;/g;
s/¬/\&	not	#xAC	#172	;/g;
s/­/\&	shy	#xAD	#173	;/g;
s/®/\&	reg	#xAE	#174	;/g;
s/¯/\&	macr	#xAF	#175	;/g;
s/°/\&	deg	#xB0	#176	;/g;
s/±/\&	plusmn	#xB1	#177	;/g;
s/²/\&	sup2	#xB2	#178	;/g;
s/³/\&	sup3	#xB3	#179	;/g;
s/´/\&	acute	#xB4	#180	;/g;
s/µ/\&	micro	#xB5	#181	;/g;
s/¶/\&	para	#xB6	#182	;/g;
s/·/\&	middot	#xB7	#183	;/g;
s/¸/\&	cedil	#xB8	#184	;/g;
s/¹/\&	sup1	#xB9	#185	;/g;
s/º/\&	ordm	#xBA	#186	;/g;
s/»/\&	raquo	#xBB	#187	;/g;
s/¼/\&	frac14	#xBC	#188	;/g;
s/½/\&	frac12	#xBD	#189	;/g;
s/¾/\&	frac34	#xBE	#190	;/g;
s/¿/\&	iquest	#xBF	#191	;/g;
s/À/\&	Agrave	#xC0	#192	;/g;
s/Á/\&	Aacute	#xC1	#193	;/g;
s/Â/\&	Acirc	#xC2	#194	;/g;
s/Ã/\&	Atilde	#xC3	#195	;/g;
s/Ä/\&	Auml	#xC4	#196	;/g;
s/Å/\&	Aring	#xC5	#197	;/g;
s/Æ/\&	AElig	#xC6	#198	;/g;
s/Ç/\&	Ccedil	#xC7	#199	;/g;
s/È/\&	Egrave	#xC8	#200	;/g;
s/É/\&	Eacute	#xC9	#201	;/g;
s/Ê/\&	Ecirc	#xCA	#202	;/g;
s/Ë/\&	Euml	#xCB	#203	;/g;
s/Ì/\&	Igrave	#xCC	#204	;/g;
s/Í/\&	Iacute	#xCD	#205	;/g;
s/Î/\&	Icirc	#xCE	#206	;/g;
s/Ï/\&	Iuml	#xCF	#207	;/g;
s/Ð/\&	ETH	#xD0	#208	;/g;
s/Ñ/\&	Ntilde	#xD1	#209	;/g;
s/Ò/\&	Ograve	#xD2	#210	;/g;
s/Ó/\&	Oacute	#xD3	#211	;/g;
s/Ô/\&	Ocirc	#xD4	#212	;/g;
s/Õ/\&	Otilde	#xD5	#213	;/g;
s/Ö/\&	Ouml	#xD6	#214	;/g;
s/×/\&	times	#xD7	#215	;/g;
s/Ø/\&	Oslash	#xD8	#216	;/g;
s/Ù/\&	Ugrave	#xD9	#217	;/g;
s/Ú/\&	Uacute	#xDA	#218	;/g;
s/Û/\&	Ucirc	#xDB	#219	;/g;
s/Ü/\&	Uuml	#xDC	#220	;/g;
s/Ý/\&	Yacute	#xDD	#221	;/g;
s/Þ/\&	THORN	#xDE	#222	;/g;
s/ß/\&	szlig	#xDF	#223	;/g;
s/à/\&	agrave	#xE0	#224	;/g;
s/á/\&	aacute	#xE1	#225	;/g;
s/â/\&	acirc	#xE2	#226	;/g;
s/ã/\&	atilde	#xE3	#227	;/g;
s/ä/\&	auml	#xE4	#228	;/g;
s/å/\&	aring	#xE5	#229	;/g;
s/æ/\&	aelig	#xE6	#230	;/g;
s/ç/\&	ccedil	#xE7	#231	;/g;
s/è/\&	egrave	#xE8	#232	;/g;
s/é/\&	eacute	#xE9	#233	;/g;
s/ê/\&	ecirc	#xEA	#234	;/g;
s/ë/\&	euml	#xEB	#235	;/g;
s/ì/\&	igrave	#xEC	#236	;/g;
s/í/\&	iacute	#xED	#237	;/g;
s/î/\&	icirc	#xEE	#238	;/g;
s/ï/\&	iuml	#xEF	#239	;/g;
s/ð/\&	eth	#xF0	#240	;/g;
s/ñ/\&	ntilde	#xF1	#241	;/g;
s/ò/\&	ograve	#xF2	#242	;/g;
s/ó/\&	oacute	#xF3	#243	;/g;
s/ô/\&	ocirc	#xF4	#244	;/g;
s/õ/\&	otilde	#xF5	#245	;/g;
s/ö/\&	ouml	#xF6	#246	;/g;
s/÷/\&	divide	#xF7	#247	;/g;
s/ø/\&	oslash	#xF8	#248	;/g;
s/ù/\&	ugrave	#xF9	#249	;/g;
s/ú/\&	uacute	#xFA	#250	;/g;
s/û/\&	ucirc	#xFB	#251	;/g;
s/ü/\&	uuml	#xFC	#252	;/g;
s/ý/\&	yacute	#xFD	#253	;/g;
s/þ/\&	thorn	#xFE	#254	;/g;
s/ÿ/\&	yuml	#xFF	#255	;/g;
s/Œ/\&	OElig	#x152	#338	;/g;
s/œ/\&	oelig	#x153	#339	;/g;
s/Š/\&	Scaron	#x160	#352	;/g;
s/š/\&	scaron	#x161	#353	;/g;
s/Ÿ/\&	Yuml	#x178	#376	;/g;
s/ƒ/\&	fnof	#x192	#402	;/g;
s/ˆ/\&	circ	#x2C6	#710	;/g;
s/˜/\&	tilde	#x2DC	#732	;/g;
s/Α/\&	Alpha	#x391	#913	;/g;
s/Β/\&	Beta	#x392	#914	;/g;
s/Γ/\&	Gamma	#x393	#915	;/g;
s/Δ/\&	Delta	#x394	#916	;/g;
s/Ε/\&	Epsilon	#x395	#917	;/g;
s/Ζ/\&	Zeta	#x396	#918	;/g;
s/Η/\&	Eta	#x397	#919	;/g;
s/Θ/\&	Theta	#x398	#920	;/g;
s/Ι/\&	Iota	#x399	#921	;/g;
s/Κ/\&	Kappa	#x39A	#922	;/g;
s/Λ/\&	Lambda	#x39B	#923	;/g;
s/Μ/\&	Mu	#x39C	#924	;/g;
s/Ν/\&	Nu	#x39D	#925	;/g;
s/Ξ/\&	Xi	#x39E	#926	;/g;
s/Ο/\&	Omicron	#x39F	#927	;/g;
s/Π/\&	Pi	#x3A0	#928	;/g;
s/Ρ/\&	Rho	#x3A1	#929	;/g;
s/Σ/\&	Sigma	#x3A3	#931	;/g;
s/Τ/\&	Tau	#x3A4	#932	;/g;
s/Υ/\&	Upsilon	#x3A5	#933	;/g;
s/Φ/\&	Phi	#x3A6	#934	;/g;
s/Χ/\&	Chi	#x3A7	#935	;/g;
s/Ψ/\&	Psi	#x3A8	#936	;/g;
s/Ω/\&	Omega	#x3A9	#937	;/g;
s/α/\&	alpha	#x3B1	#945	;/g;
s/β/\&	beta	#x3B2	#946	;/g;
s/γ/\&	gamma	#x3B3	#947	;/g;
s/δ/\&	delta	#x3B4	#948	;/g;
s/ε/\&	epsilon	#x3B5	#949	;/g;
s/ζ/\&	zeta	#x3B6	#950	;/g;
s/η/\&	eta	#x3B7	#951	;/g;
s/θ/\&	theta	#x3B8	#952	;/g;
s/ι/\&	iota	#x3B9	#953	;/g;
s/κ/\&	kappa	#x3BA	#954	;/g;
s/λ/\&	lambda	#x3BB	#955	;/g;
s/μ/\&	mu	#x3BC	#956	;/g;
s/ν/\&	nu	#x3BD	#957	;/g;
s/ξ/\&	xi	#x3BE	#958	;/g;
s/ο/\&	omicron	#x3BF	#959	;/g;
s/π/\&	pi	#x3C0	#960	;/g;
s/ρ/\&	rho	#x3C1	#961	;/g;
s/ς/\&	sigmaf	#x3C2	#962	;/g;
s/σ/\&	sigma	#x3C3	#963	;/g;
s/τ/\&	tau	#x3C4	#964	;/g;
s/υ/\&	upsilon	#x3C5	#965	;/g;
s/φ/\&	phi	#x3C6	#966	;/g;
s/χ/\&	chi	#x3C7	#967	;/g;
s/ψ/\&	psi	#x3C8	#968	;/g;
s/ω/\&	omega	#x3C9	#969	;/g;
s/ϑ/\&	thetasym	#x3D1	#977	;/g;
s/ϒ/\&	upsih	#x3D2	#978	;/g;
s/ϖ/\&	piv	#x3D6	#982	;/g;
s/ /\&	ensp	#x2002	#8194	;/g;
s/ /\&	emsp	#x2003	#8195	;/g;
s/ /\&	thinsp	#x2009	#8201	;/g;
s/‌/\&	zwnj	#x200C	#8204	;/g;
s/‍/\&	zwj	#x200D	#8205	;/g;
s/‎/\&	lrm	#x200E	#8206	;/g;
s/‏/\&	rlm	#x200F	#8207	;/g;
s/–/\&	ndash	#x2013	#8211	;/g;
s/—/\&	mdash	#x2014	#8212	;/g;
s/‘/\&	lsquo	#x2018	#8216	;/g;
s/’/\&	rsquo	#x2019	#8217	;/g;
s/‚/\&	sbquo	#x201A	#8218	;/g;
s/“/\&	ldquo	#x201C	#8220	;/g;
s/”/\&	rdquo	#x201D	#8221	;/g;
s/„/\&	bdquo	#x201E	#8222	;/g;
s/†/\&	dagger	#x2020	#8224	;/g;
s/‡/\&	Dagger	#x2021	#8225	;/g;
s/•/\&	bull	#x2022	#8226	;/g;
s/…/\&	hellip	#x2026	#8230	;/g;
s/‰/\&	permil	#x2030	#8240	;/g;
s/′/\&	prime	#x2032	#8242	;/g;
s/″/\&	Prime	#x2033	#8243	;/g;
s/‹/\&	lsaquo	#x2039	#8249	;/g;
s/›/\&	rsaquo	#x203A	#8250	;/g;
s/‾/\&	oline	#x203E	#8254	;/g;
s/⁄/\&	frasl	#x2044	#8260	;/g;
s/€/\&	euro	#x20AC	#8364	;/g;
s/ℑ/\&	image	#x2111	#8465	;/g;
s/℘/\&	weierp	#x2118	#8472	;/g;
s/ℜ/\&	real	#x211C	#8476	;/g;
s/™/\&	trade	#x2122	#8482	;/g;
s/ℵ/\&	alefsym	#x2135	#8501	;/g;
s/←/\&	larr	#x2190	#8592	;/g;
s/↑/\&	uarr	#x2191	#8593	;/g;
s/→/\&	rarr	#x2192	#8594	;/g;
s/↓/\&	darr	#x2193	#8595	;/g;
s/↔/\&	harr	#x2194	#8596	;/g;
s/↵/\&	crarr	#x21B5	#8629	;/g;
s/⇐/\&	lArr	#x21D0	#8656	;/g;
s/⇑/\&	uArr	#x21D1	#8657	;/g;
s/⇒/\&	rArr	#x21D2	#8658	;/g;
s/⇓/\&	dArr	#x21D3	#8659	;/g;
s/⇔/\&	hArr	#x21D4	#8660	;/g;
s/∀/\&	forall	#x2200	#8704	;/g;
s/∂/\&	part	#x2202	#8706	;/g;
s/∃/\&	exist	#x2203	#8707	;/g;
s/∅/\&	empty	#x2205	#8709	;/g;
s/∇/\&	nabla	#x2207	#8711	;/g;
s/∈/\&	isin	#x2208	#8712	;/g;
s/∉/\&	notin	#x2209	#8713	;/g;
s/∋/\&	ni	#x220B	#8715	;/g;
s/∏/\&	prod	#x220F	#8719	;/g;
s/∑/\&	sum	#x2211	#8721	;/g;
s/−/\&	minus	#x2212	#8722	;/g;
s/∗/\&	lowast	#x2217	#8727	;/g;
s/√/\&	radic	#x221A	#8730	;/g;
s/∝/\&	prop	#x221D	#8733	;/g;
s/∞/\&	infin	#x221E	#8734	;/g;
s/∠/\&	ang	#x2220	#8736	;/g;
s/∧/\&	and	#x2227	#8743	;/g;
s/∨/\&	or	#x2228	#8744	;/g;
s/∩/\&	cap	#x2229	#8745	;/g;
s/∪/\&	cup	#x222A	#8746	;/g;
s/∫/\&	int	#x222B	#8747	;/g;
s/∴/\&	there4	#x2234	#8756	;/g;
s/∼/\&	sim	#x223C	#8764	;/g;
s/≅/\&	cong	#x2245	#8773	;/g;
s/≈/\&	asymp	#x2248	#8776	;/g;
s/≠/\&	ne	#x2260	#8800	;/g;
s/≡/\&	equiv	#x2261	#8801	;/g;
s/≤/\&	le	#x2264	#8804	;/g;
s/≥/\&	ge	#x2265	#8805	;/g;
s/⊂/\&	sub	#x2282	#8834	;/g;
s/⊃/\&	sup	#x2283	#8835	;/g;
s/⊄/\&	nsub	#x2284	#8836	;/g;
s/⊆/\&	sube	#x2286	#8838	;/g;
s/⊇/\&	supe	#x2287	#8839	;/g;
s/⊕/\&	oplus	#x2295	#8853	;/g;
s/⊗/\&	otimes	#x2297	#8855	;/g;
s/⊥/\&	perp	#x22A5	#8869	;/g;
s/⋅/\&	sdot	#x22C5	#8901	;/g;
s/⌈/\&	lceil	#x2308	#8968	;/g;
s/⌉/\&	rceil	#x2309	#8969	;/g;
s/⌊/\&	lfloor	#x230A	#8970	;/g;
s/⌋/\&	rfloor	#x230B	#8971	;/g;
s/〈/\&	lang	#x27E8	#10216	;/g;
s/〉/\&	rang	#x27E9	#10217	;/g;
s/◊/\&	loz	#x25CA	#9674	;/g;
s/♠/\&	spades	#x2660	#9824	;/g;
s/♣/\&	clubs	#x2663	#9827	;/g;
s/♥/\&	hearts	#x2665	#9829	;/g;
s/♦/\&	diams	#x2666	#9830	;/g;
"

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-s) cods="$cods$codspace";shift;;
			--html|--xml)
				codsed=$(echo "$cods" | awk 'BEGIN {FS="\t"};{print $1 $2 $5}');
				shift
			;;
			--hex)
				codsed=$(echo "$cods" | awk 'BEGIN {FS="\t"};{print $1 $3 $5}');
				shift
			;;
			--dec)
				codsed=$(echo "$cods" | awk 'BEGIN {FS="\t"};{print $1 $4 $5}');
				shift
			;;
			--listar)
				printf '%s' 'char'
				case $2 in
				html|xml|hex|dec) printf '\t%b\n' "$2";;
				*) printf '%b' ' html        hex         dec\n';;
				esac
				echo "$cods" |
				zztrim |
				sed 's|s/||; s|	;/g;||; s|/\\&||; ${ s| |"&"|; }' |
				case $2 in
				html|xml) sed 's/	/	\&/;s/	#.*/;/;$s/" "/ /';;
				hex)      sed 's/	.*#x/	\&#x/;s/	[#0-9]*$/;/;$s/" "/ /';;
				dec)      sed 's/	.*	/	\&/;s/$/;/;$s/" "/ /';;
				*)
					sed 's/	/	\&/g;s/	/;	/2g;s/$/;/' |
					while read char html hex dec
					do
						echo "$(zzpad 4 $char) $(zzpad 11 $html) $(zzpad 11 $hex) $dec"
					done |
					sed '$s/"  *"  */     /;s/;	&/;      \&/'
				esac
				return
			;;
			*) break ;;
		esac
	done

	# Faz a conversão
	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" | sed "$codsed"
}

# ----------------------------------------------------------------------------
# zzcoin
# Retorna a cotação de criptomoedas em Reais (Bitcoin, Litecoins ou BCash).
# Opções: btc ou bitecoin (padrão) / ltc ou litecoin / bch ou bcash.
#
# Uso: zzcoin [btc|bitcoin|ltc|litecoin|bch|bcash|-a|--all]
# Ex.: zzcoin
#      zzcoin btc
#      zzcoin litecoin
#      zzcoin bch
#
# Autor: Tárcio Zemel <tarciozemel (a) gmail com>
# Desde: 2014-03-24
# Versão: 6
# Licença: GPL
# Requisitos: zzminusculas zznumero zzsemacento
# ----------------------------------------------------------------------------
zzcoin ()
{
	zzzz -h coin "$1" && return

	# Variáveis gerais
	local moeda_informada=$(echo "${1:-btc}" | zzminusculas | zzsemacento)
	local url="https://www.mercadobitcoin.net/api"

	# Se não informou moeda válida, termina
	case "$moeda_informada" in
		btc | bitcoin )
			# Monta URL a ser consultada
			url="${url}/BTC/ticker/"
			zztool dump "$url" |
			sed 's/.*"last": *"//;s/", *"buy.*//' |
			zznumero -m
		;;
		ltc | litecoin )
			# Monta URL a ser consultada
			url="${url}/LTC/ticker/"
			zztool dump "$url" |
			sed 's/.*"last": *"//;s/", *"buy.*//' |
			zznumero -m
		;;
		bch | bcash )
			# Monta URL a ser consultada
			url="${url}/BCH/ticker/"
			zztool dump "$url" |
			sed 's/.*"last": *"//;s/", *"buy.*//' |
			zznumero -m
		;;
		* ) return 1;;
	esac
}

# ----------------------------------------------------------------------------
# zzcolunar
# Transforma uma lista simples, em uma lista de múltiplas colunas.
# É necessário informar a quantidade de colunas como argumento.
#
# Mas opcionalmente pode informar o formato da distribuição das colunas:
# -z:
#   1  2  3
#   4  5  6
#   7  8  9
#   10
#
# -n: (padrão)
#   1  5  9
#   2  6  10
#   3  7
#   4  8
#
# As opções -l, --left, -e, --esquerda alinham as colunas a esquerda (padrão).
# As opções -r, --right, -d, --direita alinham as colunas a direita.
# As opções -c, --center, --centro centralizam as colunas.
# A opção -j justifica as colunas.
#
# As opções -H ou --header usa a primeira linha como cabeçalho,
# repetindo-a no início de cada coluna.
#
# As opções -w, --width, --largura seguido de um número,
# determinam a largura que as colunas terão.
#
# A opção -s seguida de um TEXTO determina o separador de colunas,
# se não for declarado assume por padrão um espaço simples.
#
# Uso: zzcolunar [-n|-z] [-H] [-l|-r|-c|-j] [-w <largura>] <colunas> arquivo
# Ex.: zzcolunar 3 arquivo.txt
#      zzcolunar -c -w 20 5 arquivo.txt
#      cat arquivo.txt | zzcolunar -z 4
#      zzcolunar --header 3 arquivo.txt
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2014-04-24
# Versão: 5
# Licença: GPL
# Requisitos: zzalinhar zztrim
# ----------------------------------------------------------------------------
zzcolunar ()
{
	zzzz -h colunar "$1" && return

	test -n "$1" || { zztool -e uso colunar; return 1; }

	local formato='n'
	local alinhamento='-l'
	local largura=0
	local header=0
	local sep=' '
	local colunas

	while test "${1#-}" != "$1"
	do
		case "$1" in
		-[nN])                         formato='n';      shift ;;
		-[zZ])                         formato='z';      shift ;;
		-H | --header)                 header=1;         shift ;;
		-l | --left | -e | --esqueda)  alinhamento='-l'; shift ;;
		-r | --right | -d | --direita) alinhamento='-r'; shift ;;
		-c | --center | --centro)      alinhamento='-c'; shift ;;
		-j)                            alinhamento='-j'; shift ;;
		-s)                            sep="$2";  shift; shift ;;
		-w | --width | --largura)
			zztool testa_numero "$2" && largura="$2" || { zztool erro "Largura inválida: $2"; return 1; }
			shift
			shift
		;;
		--) shift; break;;
		-*) zztool erro "Opção inválida: $1"; return 1 ;;
		*) break;;
		esac
	done

	if zztool testa_numero "$1"
	then
		colunas="$1"
		shift
	else
		zztool erro "Quantidade de colunas inválidas";
		zztool -e uso colunar
		return 1
	fi

	zztool file_stdin "$@" |
	zzalinhar -w $largura ${alinhamento} |
	awk -v cols=$colunas -v formato=$formato -v cab=$header -v delim="$sep" '

		NR==1 { if (cab) header = $0 }

		{ linha[NR - cab] = $0 }

		END {
			lin = ( int((NR-cab)/cols)==((NR-cab)/cols) ? (NR-cab)/cols : int((NR-cab)/cols)+1 )

			if (cab) {
				for ( j = 1; j <= cols; j++ ) { printf header (j<cols ? delim : "") }
				print ""
			}

			# Formato N ( na verdade é И )
			if (formato == "n") {
				for ( i=1; i <= lin; i++ ) {
					linha_saida = ""

					for ( j = 0; j < cols; j++ ) {
							if ( i + (j * lin ) <= NR )
								linha_saida = linha_saida (j==0 ? "" : delim) linha[ i + ( j * lin ) ]
					}

					print linha_saida
				}
			}

			# Formato Z
			if (formato == "z") {
				i = 1
				while ( i <= NR )
				{
					for ( j = 1; j <= cols; j++ ) {
						if ( i <= NR )
							linha_saida = linha_saida (j==1 ? "" : delim) linha[i]

						if (j == cols || i == NR) {
							print linha_saida
							linha_saida = ""
						}

						i++
					}
				}
			}
		}
	' | zztrim -V |
	if test "$sep" != ' '
	then
		sed "s/${sep}$//"
	else
		cat -
	fi |
	zztrim -r
}

# ----------------------------------------------------------------------------
# zzconjugar
# Conjuga verbo em todos os modos.
# E pode-se filtrar pelo modo no segundo argumento:
#  ind => Indicativo
#  sub => Subjuntivo
#  imp => Imperativo
#  inf => Infinitivo
#
# Ou apenas a definição do verbo se o segundo argumento for: def
#
# Uso: zzconjugar verbo [ ind | sub | imp | inf | def ]
# Ex.: zzconjugar correr
#      zzconjugar comer sub
#
# Autor: Leslie Harlley Watter <leslie (a) watter org>
# Desde: 2003-08-05
# Versão: 5
# Licença: GPL
# Requisitos: zzalinhar zzcolunar zzjuntalinhas zzlblank zzminusculas zzsemacento zzsqueeze zztrim zzutf8 zzxml
# Nota: Colaboração de José Inácio Coelho <jinacio (a) yahoo com>
# ----------------------------------------------------------------------------
zzconjugar ()
{
	zzzz -h conjugar "$1" && return

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso conjugar; return 1; }

	local url='http://www.conjugacao.com.br'
	local contador=1
	local modos='def ind sub imp inf'
	local palavra padrao resultado conteudo modo modos

	if test -n "$1"
	then
		palavra=$(echo "$1" | zzminusculas)
		padrao=$(echo "$palavra" | zzsemacento)
		shift
	else
		zztool -e uso conjugar
		return 1
	fi

	test -n "$1" && modos="$*"

	# Verificando se a palavra confere na pesquisa
	until test "$resultado" = "$palavra"
	do
		conteudo=$(zztool source "$url/verbo-$padrao" | zzutf8 | zzxml --tidy --notag script | sed -n '/<h1/,/ relacionados com /p')
		resultado=$(echo "$conteudo" | sed -n '2 { s/.* //; p; }' | zzminusculas)
		test -n "$resultado" || { zztool erro "Palavra não encontrada"; return 1; }

		# Incrementando o contador no padrão
		padrao=$(echo "$padrao" | sed 's/-[0-9]*$//')
		contador=$((contador + 1))
		test $contador -gt 9 && return 1
		padrao=${padrao}-${contador}
	done

	conteudo=$(
		echo "$conteudo" |
		zzjuntalinhas -i '<h2'                    -f '</h2>'      -d ' ' |
		zzjuntalinhas -i '<h3'                    -f '</h3>'      -d ' ' |
		zzjuntalinhas -i '<h4'                    -f '</h4>'      -d ' ' |
		zzjuntalinhas -i '<strong'                -f '</strong>'  -d ' ' |
		zzjuntalinhas -i '^<span>'                 -f '^</span>$' -d ' ' |
		zzjuntalinhas -i '> Gerúndio <'           -f '^</span>'   -d ' ' |
		zzjuntalinhas -i '> Particípio passado <' -f '^</span>'   -d ' ' |
		zzjuntalinhas -i '> Infinitivo <'         -f ": $palavra" -d ' ' |
		zzjuntalinhas -i '<u'                     -f '</u>'       -d ' ' |
		zzjuntalinhas -i 'Separação silábica:'    -f '</u>'       -d ''
	)

	for modo in $modos
	do
		echo
		case "$modo" in
		def)
			zztool eco $(echo "$conteudo" | sed -n '2 { s/<[^>]*>//g; s/^ *//; s/ *$//; p; }')
			echo "$conteudo" |
			sed '/intro-v/,/div>/d;/id="conjugacao"/q' |
			zzxml --untag |
			sed '1d; s/- /-/; s/ *:/:/;' |
			zzsqueeze |
			zztrim
		;;
		ind)
			zztool eco Indicativo
			echo "$conteudo" |
			sed -n '/"modoconjuga"> Indicativo </,/> Subjuntivo </ { /^<h3/d; /^<p/d; /p>$/d; /^<div/d; /div>$/d; p; }' |
			awk '/tempo-conjugacao-titulo/ { printf "\n\n"; print; next }
				/> tu <|> eles? <|> [nv]ós </ { print "" }
				/<br / { print ""; next }
				{ printf $0 }
			' |
			zzxml --untag |
			zztrim -H |
			zzsqueeze |
			zzcolunar -w 30 3 |
			zztrim -H
		;;
		sub)
			zztool eco Subjuntivo
			echo "$conteudo" |
			sed -n '/"modoconjuga"> Subjuntivo </,/> Imperativo </ {/^<h3/d; /^<p/d; /p>$/d; /^<div/d; /div>$/d; p; }' |
			awk '/tempo-conjugacao-titulo/ { printf "\n\n"; printf $0; next }
				/> que |> se |> quando / { print "" }
				/<br / { print ""; next }
				{ printf $0 }
			' |
			zzxml --untag |
			zztrim -H |
			zzsqueeze |
			zzcolunar -w 30 3 |
			zztrim -H
		;;
		imp)
			zztool eco Imperativo
			echo "$conteudo" |
			sed -n '/"modoconjuga"> Imperativo </,/> Infinitivo </ {/^<h3/d; /^<p/d; /p>$/d; /^<div/d; /div>$/d; p; }' |
			awk '/tempo-conjugacao-titulo/ { printf "\n\n"; print; next }
				/--|> tu <|> eles? <|> vocês? <|> [nv]ós </ { print; next }
				/<br / { print ""; next }
				{ printf $0 }
			' |
			zzxml --untag |
			zzsqueeze |
			zzcolunar -r -w 30 2 |
			zzlblank
		;;
		inf)
			zztool eco Infinitivo
			echo "$conteudo" |
			sed -n '/"modoconjuga"> Infinitivo </,/\/p>$/ {/^<h[23]/d; /^<p/d; /p>$/d; /^<div/d; /div>$/d; p; }' |
			awk '/> [et]u <|> eles? <|> [nv]ós <|tempo-conjugacao-titulo/ { print; next }
				/<br / { print ""; next }
				$0 !~ /^  *$/ { printf $0 }
			' |
			zzxml --untag |
			zzsqueeze |
			zzalinhar -r -w 30 |
			zzlblank |
			zztrim -r
		;;
		esac
	done
}

# ----------------------------------------------------------------------------
# zzcontapalavra
# Conta o número de vezes que uma palavra aparece num arquivo.
# Obs.: É diferente do grep -c, que não conta várias palavras na mesma linha.
# Opções: -i  ignora a diferença de maiúsculas/minúsculas
#         -p  busca parcial, conta trechos de palavras
# Uso: zzcontapalavra [-i|-p] palavra arquivo(s)
# Ex.: zzcontapalavra root /etc/passwd
#      zzcontapalavra -i -p a /etc/passwd      # Compare com grep -ci a
#      cat /etc/passwd | zzcontapalavra root
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2003-10-02
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzcontapalavra ()
{
	zzzz -h contapalavra "$1" && return

	local padrao ignora
	local inteira=1

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-p) inteira=     ;;
			-i) ignora=1     ;;
			--) shift; break ;;
			* ) break        ;;
		esac
		shift
	done

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso contapalavra; return 1; }

	padrao=$1
	shift

	# Contorna a limitação do grep -c pesquisando pela palavra
	# e quebrando o resultado em uma palavra por linha (tr).
	# Então pode-se usar o grep -c para contar.
	# Nota: Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" |
		grep -h ${ignora:+-i} ${inteira:+-w} -- "$padrao" |
		tr '\t./ -,:-@[-_{-~' '\n' |
		grep -c ${ignora:+-i} ${inteira:+-w} -- "$padrao"
}

# ----------------------------------------------------------------------------
# zzcontapalavras
# Conta o número de vezes que cada palavra aparece em um texto.
#
# Opções: -i       Trata maiúsculas e minúsculas como iguais, FOO = Foo = foo
#         -n NÚM   Mostra apenas as NÚM palavras mais frequentes
#
# Uso: zzcontapalavras [-i] [-n N] [arquivo(s)]
# Ex.: zzcontapalavras arquivo.txt
#      zzcontapalavras -i arquivo.txt
#      zzcontapalavras -i -n 10 /etc/passwd
#      cat arquivo.txt | zzcontapalavras
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-07
# Versão: 1
# Licença: GPL
# Requisitos: zzminusculas
# ----------------------------------------------------------------------------
zzcontapalavras ()
{
	zzzz -h contapalavras "$1" && return

	local ignore_case
	local tab=$(printf '\t')
	local limite='$'

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-i)
				ignore_case=1
				shift
			;;
			-n)
				limite="$2"
				shift
				shift
			;;
			*)
				break
			;;
		esac
	done

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" |

		# Remove caracteres que não são parte de palavras
		sed 's/[^A-Za-z0-9ÀàÁáÂâÃãÉéÊêÍíÓóÔôÕõÚúÇç_-]/ /g' |

		# Deixa uma palavra por linha, formando uma lista
		tr -s ' ' '\n' |

		# Converte tudo pra minúsculas?
		if test -n "$ignore_case"
		then
			zzminusculas
		else
			cat -
		fi |

		# Limpa a lista de palavras
		sed '
			# Remove linhas em branco
			/^$/d

			# Remove linhas somente com números e traços
			/^[0-9_-][0-9_-]*$/d
			' |

		# Faz a contagem com o uniq -c
		sort |
		uniq -c |

		# Ordena o resultado, primeiro vem a de maior contagem
		sort -n -r |

		# Temos limite no número de resultados?
		sed "$limite q" |

		# Formata o resultado para Número-Tab-Palavra
		sed "s/^[ $tab]*\([0-9]\{1,\}\)[ $tab]\{1,\}\(.*\)/\1$tab\2/"
}

# ----------------------------------------------------------------------------
# zzconverte
# Conversões de caracteres, temperatura, distância, ângulo, grandeza e escala.
#  Opções:
#   -p seguido de um número sem espaço:
#      define a precisão dos resultados (casas decimais), o padrão é 2
#   -e: Resposta expandida, mais explicativa.
#      Obs: sem essa opção a resposta é curta, apenas o número convertivo.
#
# Temperatura:
#  cf = (C)elsius      => (F)ahrenheit  | fc = (F)ahrenheit  => (C)elsius
#  ck = (C)elsius      => (K)elvin      | kc = (K)elvin      => (C)elsius
#  fk = (F)ahrenheit   => (K)elvin      | kf = (K)elvin      => (F)ahrenheit
#
# Distância:
#  km = (K)Quilômetros => (M)ilhas      | mk = (M)ilhas      => (K)Quilômetros
#  mj = (M)etros       => (J)ardas      | jm = (J)ardas      => (M)etros
#  mp = (M)etros       => (P)és         | pm = (P)és         => (M)etros
#  jp = (J)ardas       => (P)és         | pj = (P)és         => (J)ardas
#
# Ângulo:
#  gr = (G)raus        => (R)adianos    | rg = (R)adianos    => (G)raus
#  ga = (G)raus        => Gr(A)dos      | ag = Gr(A)dos      => (G)raus
#  ra = (R)adianos     => Gr(A)dos      | ar = Gr(A)dos      => (R)adianos
#
# Número:
#  db = (D)ecimal      => (B)inário     | bd = (B)inário     => (D)ecimal
#  dc = (D)ecimal      => (C)aractere   | cd = (C)aractere   => (D)ecimal
#  do = (D)ecimal      => (O)ctal       | od = (O)ctal       => (D)ecimal
#  dh = (D)ecimal      => (H)exadecimal | hd = (H)exadecimal => (D)ecimal
#  hc = (H)exadecimal  => (C)aractere   | ch = (C)aractere   => (H)exadecimal
#  ho = (H)exadecimal  => (O)ctal       | oh = (O)ctal       => (H)exadecimal
#  hb = (H)exadecimal  => (B)inário     | bh = (B)inário     => (H)exadecimal
#  ob = (O)ctal        => (B)inário     | bo = (B)inário     => (O)ctal
#
# Escala:
#  Y => yotta      G => giga       d => deci       p => pico
#  Z => zetta      M => mega       c => centi      f => femto
#  E => exa        K => quilo      m => mili       a => atto
#  P => peta       H => hecto      u => micro      z => zepto
#  T => tera       D => deca       n => nano       y => yocto
#  un => unidade
#
# Uso: zzconverte [-p<número>] [-e] <código(s)> [<código>] número [número ...]
# Ex.: zzconverte cf 5
#      zzconverte dc 65
#      zzconverte db 32 47 28
#      zzconverte -p9 mp 3  # Converte metros em pés com 9 casas decimais
#      zzconverte G u 32    # Converte 32 gigas em 32000000000000000 micros
#      zzconverte f H 7     # Converte 7 femtos em 0.00000000000000007 hecto
#      zzconverte T 4       # Converte 4 teras em 4000000000000 unidades
#      zzconverte un M 3    # Converte 3 unidades em 0.000003 megas
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2003-10-02
# Versão: 6
# Licença: GPL
# Requisitos: zznumero zztestar
# ----------------------------------------------------------------------------
zzconverte ()
{
	zzzz -h converte "$1" && return

	local opt
	local precisao='2'

	while test "${1#-}" != "$1"
	do
		case "$1" in
			-e) opt="e"; shift ;;
			-p*)
				precisao="${1#-p}"
				zztool testa_numero $precisao || precisao='2'
				shift
			;;
		esac
	done

	local s2="scale=$precisao"
	local pi='pi=4*a(1)'
	local operacao=$1
	local unid_escala="yzafpnumcd_DHKMGTPEZY"
	local nome_escala="yocto zepto atto femto pico nano micro mili centi deci un deca hecto quilo mega giga tera peta exa zetta yotta"
	local potencias="-24 -21 -18 -15 -12 -9 -6 -3 -2 -1 0 1 2 3 6 9 12 15 18 21 24"
	local resp suf1 suf2 bc_expr num_hex fator operacao2

	# Verificação dos parâmetros
	test -n "$2" || { zztool -e uso converte; return 1; }

	shift
	while test -n "$1"
	do
		# Verificando consistência para números
		case "$operacao" in
			c[dh]  ) echo "$1" | grep '^-' >/dev/null && { shift; continue; } ;;
			b[dho] ) zztestar binario "$1"            || { shift; continue; } ;;
			d[bohc]) zztestar numero  "$1"            || { shift; continue; } ;;
			o[bdh] ) zztestar octal   "$1"            || { shift; continue; } ;;
			h[bdoc]) zztestar hexa    "$1"            || { shift; continue; }
				num_hex=$(echo ${1#0x} | tr [a-f] [A-F])
			;;
		esac

		case "$operacao" in
			# Escala:
			y|z|a|f|p|n|u|m|c|d|un|D|H|K|M|G|T|P|E|Z|Y)
				case "$1" in
					y|z|a|f|p|n|u|m|c|d|un|D|H|K|M|G|T|P|E|Z|Y) operacao2="$1"; shift ;;
				esac
				num_hex=$(echo $operacao | sed 's/un/_/')
				fator=$(echo "$potencias $(zztool index_var $num_hex $unid_escala)" | awk '{print $$NF}')
				suf1=$(echo "$nome_escala $(zztool index_var $num_hex $unid_escala)" | awk '{print $$NF}')
				if test -n "$operacao2"
				then
					num_hex=$(echo $operacao2 | sed 's/un/_/')
					fator=$(echo "$potencias $(zztool index_var $num_hex $unid_escala)" | awk '{print '$fator' - $$NF}')
					suf2=$(echo "$nome_escala $(zztool index_var $num_hex $unid_escala)" | awk '{print $$NF}')
				else
					suf2='un'
				fi
				test $fator -lt 0 && s2="scale=${fator#-}"
				bc_expr="$s2;${1:-1}*10^$fator"
			;;
			# Temperatura:
			cf) suf1="°C";                 suf2="°F";             bc_expr="$s2;($1*9/5)+32" ;;
			fc) suf1="°F";                 suf2="°C";             bc_expr="$s2;($1-32)*5/9" ;;
			ck) suf1="°C";                 suf2="K";              bc_expr="$s2;$1+273.15" ;;
			kc) suf1="K";                  suf2="°C";             bc_expr="$s2;$1-273.15" ;;
			fk) suf1="°F";                 suf2="K";              bc_expr="$s2;($1+459.67)/1.8" ;;
			kf) suf1="K";                  suf2="°F";             bc_expr="$s2;($1*1.8)-459.67" ;;
			# Distância:
			km) suf1="km";                 suf2="mi";             bc_expr="$s2;$1*0.6214" ;;
			mk) suf1="mi";                 suf2="km";             bc_expr="$s2;$1*1.609" ;;
			mj) suf1="m";                  suf2="yd";             bc_expr="$s2;$1/0.9144" ;;
			jm) suf1="yd";                 suf2="m";              bc_expr="$s2;$1*0.9144" ;;
			mp) suf1="m";                  suf2="ft";             bc_expr="$s2;$1/0.3048" ;;
			pm) suf1="ft";                 suf2="m";              bc_expr="$s2;$1*0.3048" ;;
			jp) suf1="yd";                 suf2="ft";             bc_expr="$s2;$1*3" ;;
			pj) suf1="ft";                 suf2="yd";             bc_expr="$s2;$1/3" ;;
			# Número:
				# Binário:
				bo) suf1="em binário";     suf2="em octal";       bc_expr="obase=8;ibase=2;$1" ;;
				bd) suf1="em binário";     suf2="em decimal";     bc_expr="ibase=2;$1" ;;
				bh) suf1="em binário";     suf2="em hexadecimal"; bc_expr="obase=16;ibase=2;$1" ;;
				# Decimal:
				db) suf1="em decimal";     suf2="em binário";     bc_expr="obase=2;$1" ;;
				do) suf1="em decimal";     suf2="em octal";       bc_expr="obase=8;$1" ;;
				dh) suf1="em decimal";     suf2="em hexadecimal"; resp=$(printf '%x\n' "$1" | tr [a-f] [A-F]) ;;
				# Octal:
				ob) suf1="em octal";       suf2="em binário";     bc_expr="obase=2;ibase=8;${1#0}" ;;
				od) suf1="em octal";       suf2="em decimal";     bc_expr="ibase=8;${1#0}" ;;
				oh) suf1="em octal";       suf2="em hexadecimal"; bc_expr="obase=16;ibase=8;${1#0}" ;;
				# Hexadecimal:
				hb) suf1="em hexadecimal"; suf2="em binário";     bc_expr="obase=2;ibase=16;$num_hex" ;;
				ho) suf1="em hexadecimal"; suf2="em octal";       bc_expr="obase=8;ibase=16;$num_hex" ;;
				hd) suf1="em hexadecimal"; suf2="em decimal";     resp=$(printf '%d\n' "0x${1#0x}") ;;
			# Caractere:
				# Para:
				dc | hc | oc)
					case "$operacao" in
						dc) suf1="em decimal";     fator="$1" ;;
						hc) suf1="em hexadecimal"; fator=$(printf '%d\n' "0x${1#0x}") ;;
						oc) suf1="em octal";       fator=$(echo "ibase=8;${1#0}" | bc) ;;
					esac
					suf2="em caractere"

					if test "$fator" -ge 32 -a "$fator" -le 126
					then
						octal=$(printf "%03o\n" "$fator")
						resp=$(printf "\\$octal")
					elif test "$fator" -ge 161 -a "$fator" -le 191
					then
						octal=$(echo "obase=8;$fator" | bc)
						resp=$(printf "\302\\$octal")
					elif test "$fator" -ge 192 -a "$fator" -le 255
					then
							octal=$(printf '%03o' $((fator - 64)))
							resp=$(printf "\303\\$octal")
					fi
				;;
				# De:
				cd) suf1="em caractere";  suf2="em decimal";     resp=$(printf "%d\n" "'$1") ;;
				ch) suf1="em caractere";  suf2="em hexadecimal"; resp=$(printf "%x\n" "'$1" | tr [a-f] [A-F]) ;;
				co) suf1="em caractere";  suf2="em octal";       resp=$(printf "%o\n" "'$1") ;;
			# Ângulo:
			gr) suf1="°";                 suf2="rad";            resp=$(echo "$s2;$pi;$1*pi/180" | bc -l | zznumero --para en | tr -d ,) ;;
			rg) suf1="rad";               suf2="°";              resp=$(echo "$s2;$pi;$1*180/pi" | bc -l | zznumero --para en | tr -d ,) ;;
			ga) suf1="°";                 suf2="gon";            resp=$(echo "$s2;$1/0.9" | bc -l | zznumero --para en | tr -d ,) ;;
			ag) suf1="gon";               suf2="°";              resp=$(echo "$s2;$1*0.9" | bc -l | zznumero --para en | tr -d ,) ;;
			ra) suf1="rad";               suf2="gon";            resp=$(echo "$s2;$pi;$1*200/pi" | bc -l | zznumero --para en | tr -d ,) ;;
			ar) suf1="gon";               suf2="rad";            resp=$(echo "$s2;$pi;$1*pi/200" | bc -l | zznumero --para en | tr -d ,) ;;
			* ) zztool erro "Conversão inválida $operacao"; return 1 ;;
		esac

		test -n "$bc_expr" && resp=$(echo "$bc_expr" | bc -l | sed 's/^\./0./')

		if test -n "$resp"
		then
			if test "$opt" = "e"
			then
				test "$suf1" != "°" && suf1=" $suf1"
				test "$suf2" != "°" && suf2=" $suf2"
				echo "${1:-1}${suf1} = ${resp}${suf2}"
			else
				echo "$resp"
			fi
		fi

		shift
	done
}

# ----------------------------------------------------------------------------
# zzcores
# Mostra todas as combinações de cores possíveis no console.
# Também mostra os códigos ANSI para obter tais combinações.
# Uso: zzcores
# Ex.: zzcores
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2001-12-11
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzcores ()
{
	zzzz -h cores "$1" && return

	local frente fundo negrito cor

	for frente in 0 1 2 3 4 5 6 7
	do
		for negrito in '' ';1' # alterna entre linhas sem e com negrito
		do
			for fundo in 0 1 2 3 4 5 6 7
			do
				# Compõe o par de cores: NN;NN
				cor="4$fundo;3$frente"

				# Mostra na tela usando caracteres de controle: ESC[ NN m
				printf "\033[$cor${negrito}m $cor${negrito:-  } \033[m"
			done
			echo
		done
	done
}

# ----------------------------------------------------------------------------
# zzcorpuschristi
# Mostra a data de Corpus Christi para qualquer ano.
# Obs.: Se o ano não for informado, usa o atual.
# Regra: 60 dias depois do domingo de Páscoa.
# Uso: zzcorpuschristi [ano]
# Ex.: zzcorpuschristi
#      zzcorpuschristi 2009
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-11-21
# Versão: 1
# Licença: GPL
# Requisitos: zzdata zzpascoa
# Tags: data
# ----------------------------------------------------------------------------
zzcorpuschristi ()
{
	zzzz -h corpuschristi "$1" && return

	local ano="$1"

	# Se o ano não for informado, usa o atual
	test -z "$ano" && ano=$(date +%Y)

	# Validação
	zztool -e testa_ano $ano || return 1

	# Ah, como é fácil quando se tem as ferramentas certas ;)
	# e quando já temos o código e só precisamos mudar os numeros
	# tambem é bom :D ;)
	zzdata $(zzpascoa $ano) + 60
}

# ----------------------------------------------------------------------------
# zzcotacao
# http://www.infomoney.com.br
# Busca cotações do dia de algumas moedas em relação ao Real (compra e venda).
# Uso: zzcotacao
# Ex.: zzcotacao
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-19
# Versão: 3
# Licença: GPL
# Requisitos: zzsemacento
# ----------------------------------------------------------------------------
zzcotacao ()
{
	zzzz -h cotacao "$1" && return

	zztool eco "Infomoney"
	zztool dump "http://www.infomoney.com.br/mercados/cambio" |
	sed -n '/REAL VS. MOEDAS/,/mais cota/p' |
	sed  '1d; $d;/^ *$/d;/n\/d/d;s/\[...png\]/        /' |
	sed 's/Venda  *Var/Venda Var/;s/\[//g;s/\]//g' |
	zzsemacento |
	awk '{
		if ( NR == 1 ) printf "%18s  %6s  %6s   %6s\n", "", $2, $3, $4
		if ( NR >  1 ) {
			if (NF == 4) printf "%-18s  %6s  %6s  %6s\n", $1, $2, $3, $4
			if (NF == 5) printf "%-18s  %6s  %6s  %6s\n", $1 " " $2, $3, $4, $5
		}
	}'

	zztool eco "\nUOL - Economia"
	# Faz a consulta e filtra o resultado
	zztool dump 'http://economia.uol.com.br/cotacoes' |
		tr -s ' ' |
		sed -n '/Dólar comercial /,/Fonte Thompson Reuters/ {
			# Linha original:
			# Dólar com. 2,6203 2,6212 -0,79%

			# faxina
			/Bovespa/d
			/\]/d
			/^[[:blank:]]*$/d
			/Fonte Thompson Reuters/d
			s/com\./Comercial/
			s/tur\./Turismo /
			s/^[[:blank:]]*//
			s/[[:blank:]]*$//
			s/.*Dólar comercial[^0-9]*//
			s/Variação/Var(%)/
			s/arg\./Argentino/
			s/\(.*\) - \(.*\) \{0,1\}\([0-9][0-9]h[0-9][0-9]\)*/\2|\3\
\1/
		p
		}' |
		awk '
		NR==1
		{
			if ( NR == 2 ) printf "%18s  %6s  %6s   %6s\n", "", $1, $2, $3
			if ( NR >  2 ) {
				if (NF == 4 && $2 != "n/d" && $3 != "n/d") printf "%-18s  %6s  %6s  %6s\n", $1, $2, $3, $4
				if (NF == 5 && $3 != "n/d" && $4 != "n/d") printf "%-18s  %6s  %6s  %6s\n", $1 " " $2, $3, $4, $5
			}
		}'
}

# ----------------------------------------------------------------------------
# zzcpf
# Cria, valida, formata ou retorna o(s) estado(s) de um número de CPF.
# Obs.: O CPF informado pode estar formatado (pontos e hífen) ou não.
# Uso: zzcpf [-f|-F|-e|-q] [cpf]
# Ex.: zzcpf 123.456.789-09      # valida o CPF informado
#      zzcpf 12345678909         # com ou sem pontuação
#      zzcpf                     # gera um CPF válido (aleatório)
#      zzcpf -f 12345678909      # formata, adicionando pontuação
#      zzcpf -F 12345678909      # desformata, tirando pontuação
#      zzcpf -e 12345678909      # estado(s) de um CPF Válido
#      zzcpf -q 12345678909      # apenas código de retorno, sem mensagens
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2004-12-23
# Versão: 4
# Licença: GPL
# Requisitos: zzaleatorio zzcut
# ----------------------------------------------------------------------------
zzcpf ()
{
	zzzz -h cpf "$1" && return

	local i n somatoria digito1 digito2 cpf base op estados auxiliar quieto

	# Remove pontuação do CPF informado, deixando apenas números
	cpf=$(echo "$*" | tr -d -c 0123456789)

	#Retorna estado(s) ao qual o CPF pertence
	if test "$1" = '-e'
	then
		# Se o CPF estiver vazio, define com zero
		: ${cpf:=0}

		# Só continua se o CPF for válido
		auxiliar=$(zzcpf $cpf 2>&1)
		if test "$auxiliar" != 'CPF válido'
		then
			zztool erro "$auxiliar"
			return 1
		fi

		# Uso da função zzcut para captura do 9o digito
		op=$(echo "$cpf" | zzcut -c 9)

		#Atribui estado(s) ao qual o CPF pertence
		case $op in
			0) estados="Rio Grande do Sul";;
			1) estados="Distrito Federal, Goiás, Mato Grosso, Mato Grosso do Sul ou Tocantins";;
			2) estados="Amazonas, Pará, Roraima, Amapá, Acre ou Rondônia";;
			3) estados="Ceará, Maranhão ou Piauí";;
			4) estados="Paraíba, Pernambuco, Alagoas ou Rio Grande do Norte";;
			5) estados="Bahia ou Sergipe";;
			6) estados="Minas Gerais";;
			7) estados="Rio de Janeiro ou Espírito Santo";;
			8) estados="São Paulo";;
			9) estados="Paraná ou Santa Catarina";;
		esac

		echo "$estados"
		return 0
	fi

	# CPF válido formatado
	if test "$1" = '-f'
	then
		# Remove os zeros do início (senão é considerado um octal)
		cpf=$(echo "$cpf" | sed 's/^0*//')

		# Só continua se o CPF for válido
		auxiliar=$(zzcpf $cpf 2>&1)
		if test "$auxiliar" != 'CPF válido'
		then
			zztool erro "$auxiliar"
			return 1
		fi

		# Completa com zeros à esquerda, caso necessário
		cpf=$(printf %011d "$cpf")

		# Formata com um sed esperto
		echo $cpf | sed '
			s/./&-/9
			s/./&./6
			s/./&./3
		'

		# Tudo certo, podemos ir embora
		return 0
	fi

	# CPF válido não formatado
	if test "$1" = '-F'
	then
		# Se o CPF estiver vazio, gera um aleatoriamente sem formatação
		if test "${#cpf}" -eq 0
		then
			zzcpf | tr -d -c '0123456789\n'
			return 0
		fi

		# Remove os zeros do início (senão é considerado um octal)
		cpf=$(echo "$cpf" | sed 's/^0*//')

		# Só continua se o CPF for válido
		auxiliar=$(zzcpf $cpf 2>&1)
		if test "$auxiliar" != 'CPF válido'
		then
			zztool erro "$auxiliar"
			return 1
		fi

		printf "%011d\n" "$cpf"
		return 0
	fi

	# Devo ocultar a saída ou mensagem de erro?
	test "$1" = '-q' && quieto=1

	# Extrai os números da base do CPF:
	# Os 9 primeiros, sem os dois dígitos verificadores.
	# Esses dois dígitos serão calculados adiante.
	if test -n "$cpf"
	then

		# Completa com zeros à esquerda, caso necessário
		cpf=$(printf %011d "$cpf")

		# Faltou ou sobrou algum número...
		if test ${#cpf} -ne 11
		then
			test -n "$quieto" || zztool erro 'CPF inválido (deve ter 11 dígitos)'
			return 1
		fi

		# Apaga os dois últimos dígitos
		base="${cpf%??}"

		#Inicia um laço para comparar a base com todas as possíveis situações:
		#De 000.00..-00 até 999.99..-99
		for ((i=0;i<10;i++))
			do
			#Atribuição de variável auxiliar para comparação de cada situação
				auxiliar=$(echo "$base" | sed "s/$i/X/g")

			#Compara o valor atual da variável auxiliar com a base e, caso seja verdadeiro, retorna o erro
				if test "$auxiliar" = "XXXXXXXXX"
				then
					test -n "$quieto" || zztool erro "CPF inválido (não pode conter os 9 primeiros digitos iguais)"
					return 1
				fi
			done
		#Fim do laço de verificação de digitos repetidos
	else
		# Não foi informado nenhum CPF, vamos gerar um escolhendo
		# nove dígitos aleatoriamente para formar a base
		while test ${#cpf} -lt 9
		do
			cpf="$cpf$(zzaleatorio 8)"
		done
		base="$cpf"
	fi

	# Truque para cada dígito da base ser guardado em $1, $2, $3, ...
	set - $(echo "$base" | sed 's/./& /g')

	# Explicação do algoritmo de geração/validação do CPF:
	#
	# Os primeiros 9 dígitos são livres, você pode digitar quaisquer
	# números, não há seqüência. O que importa é que os dois últimos
	# dígitos, chamados verificadores, estejam corretos.
	#
	# Estes dígitos são calculados em cima dos 9 primeiros, seguindo
	# a seguinte fórmula:
	#
	# 1) Aplica a multiplicação de cada dígito na máscara de números
	#    que é de 10 a 2 para o primeiro dígito e de 11 a 3 para o segundo.
	# 2) Depois tira o módulo de 11 do somatório dos resultados.
	# 3) Diminui isso de 11 e se der 10 ou mais vira zero.
	# 4) Pronto, achou o primeiro dígito verificador.
	#
	# Máscara   : 10    9    8    7    6    5    4    3    2
	# CPF       :  2    2    5    4    3    7    1    0    1
	# Multiplica: 20 + 18 + 40 + 28 + 18 + 35 +  4 +  0 +  2 = Somatória
	#
	# Para o segundo é praticamente igual, porém muda a máscara (11 - 3)
	# e ao somatório é adicionado o dígito 1 multiplicado por 2.

	### Cálculo do dígito verificador 1
	# Passo 1
	somatoria=0
	for i in 10 9 8 7 6 5 4 3 2 # máscara
	do
		# Cada um dos dígitos da base ($n) é multiplicado pelo
		# seu número correspondente da máscara ($i) e adicionado
		# na somatória.
		n="$1"
		somatoria=$((somatoria + (i * n)))
		shift
	done
	# Passo 2
	digito1=$((11 - (somatoria % 11)))
	# Passo 3
	test $digito1 -ge 10 && digito1=0

	### Cálculo do dígito verificador 2
	# Tudo igual ao anterior, primeiro setando $1, $2, $3, etc e
	# depois fazendo os cálculos já explicados.
	#
	set - $(echo "$base" | sed 's/./& /g')
	# Passo 1
	somatoria=0
	for i in 11 10 9 8 7 6 5 4 3
	do
		n="$1"
		somatoria=$((somatoria + (i * n)))
		shift
	done
	# Passo 1 e meio (o dobro do verificador 1 entra na somatória)
	somatoria=$((somatoria + digito1 * 2))
	# Passo 2
	digito2=$((11 - (somatoria % 11)))
	# Passo 3
	test $digito2 -ge 10 && digito2=0

	# Mostra ou valida
	if test ${#cpf} -eq 9
	then
		# Esse CPF foi gerado aleatoriamente pela função.
		# Apenas adiciona os dígitos verificadores e mostra na tela.
		echo "$cpf$digito1$digito2" |
			sed 's/\(...\)\(...\)\(...\)/\1.\2.\3-/' # nnn.nnn.nnn-nn
	else
		# Esse CPF foi informado pelo usuário.
		# Compara os verificadores informados com os calculados.
		if test "${cpf#?????????}" = "$digito1$digito2"
		then
			test -n "$quieto" || echo 'CPF válido'
		else
			# Boa ação do dia: mostrar quais os verificadores corretos
			test -n "$quieto" || zztool erro "CPF inválido (deveria terminar em $digito1$digito2)"
			return 1
		fi
	fi
}

# ----------------------------------------------------------------------------
# zzcut
# Exibe partes selecionadas de linhas de cada ARQUIVO/STDIN na saída padrão.
# É uma emulação do comando cut, com recursos adicionais.
#
# Opções:
#  -c LISTA    seleciona apenas estes caracteres.
#
#  -d DELIM    usa DELIM em vez de TAB (padrão) como delimitador de campo.
#
#  -f LISTA    seleciona somente estes campos; também exibe qualquer
#              linha que não contenha o caractere delimitador.
#
#  -s          não emite linhas que não contenham delimitadores.
#
#  -D TEXTO    usa TEXTO como delimitador da saída
#              o padrão é usar o delimitador de entrada.
#
#  -v          Inverter o sentido, apagando as partes selecionadas.
#
#  Obs.:  1) Se o delimitador da entrada for uma Expressão Regular,
#            é recomendando declarar o delimitador de saída.
#         2) Se o delimitador de entrada for ou possuir:
#             - '\' (contra-barra), use '\\' (1 escape) para cada '\'.
#             - '/' (barra), use '[/]' (lista em ER) para cada '/'.
#         3) Se o delimitador de saída for ou possuir:
#             - '\' (contra-barra), use '\\\\' (3 escapes) para cada '\'.
#             - '/' (barra), use '\/' (1 escape) para cada '/'.
#
#  Use uma, e somente uma, das opções -c ou -f.
#  Cada LISTA é feita de um ou vários intervalos separados por vírgulas.
#  Cada intervalo da lista exibe seu trecho, mesmo se for repetido.
#
#  Cada intervalo pode ser:
#    N     caractere ou campo na posição N, começando por 1.
#    N-    Do caractere ou campo na posição N até o fim da linha.
#    N-M   Do caractere ou campo na posição N até a posição M.
#    -M    Do primeiro caractere ou campo até a posição M.
#    -     Do primeiro caractere ou campo até ao fim da linha.
#    N~M   Do caractere ou campo na posição N até o final indo em M saltos.
#    ~M    Do começo até o fim da linha em M saltos de caracteres ou campos.
#    d     Caractere "d", posicionar o delimitador na saida de caracteres.
#
# Uso: zzcut <-c|-f> <número[s]|range> [-d <delimitador>] [-v]
# Ex.: zzcut -c 5,2 arq.txt     # 5º caractere, seguido pelo 2º caractere
#      zzcut -c 7-4,9- arq.txt  # 7º ao 4º e depois do 9º ao fim da linha
#      zzcut -v -c 3-8 arq.txt  # Exclui do 3º ao 8º caractere
#      zzcut -f 1,-,3  arq.txt  # 1º campo, toda linha e 3º campo
#      zzcut -v -f 6-  arq.txt  # Exclui a partir do 6º campo
#      zzcut -f 8,8,8 -d ";" arq.txt   # 8º campo 3 vezes. Delimitador ";"
#      zzcut -f 10,6 -d: -D _ arq.txt  # 10º e 6º campos, novo delimitador _
#      zzcut -c 1,d,10 -D: arq.txt     # 1º e 10º caracteres. Delimitador :
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2016-02-09
# Versão: 4
# Licença: GPL
# Requisitos: zzunescape
# ----------------------------------------------------------------------------
zzcut ()
{

	zzzz -h cut "$1" && return

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso cut; return 1; }

	local tipo range ofd codscript qtd_campos only_delim inverte sp rlm
	local delim=$(printf '\t')

	# Recurso para oferecer a oportunidade de aspas serem usadas no delimitador
	# Usando um caractere não imprimível no lugar da aspas
	local aspas=$(echo "&zwnj;" | zzunescape --html)

	# Definindo qual delimitador apresenta a aspas pelos dois bits na variável
	# O primeiro bit define o delimitador na entrada
	# O segundo bit define o delimitador na saída
	# 0 = não há aspas no delimitador
	# 1 = há aspas no delimitador
	local bit_aspas='00'

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-c*)
				# Caracter
				test -n "$tipo" && { zztool erro "Somente um tipo de lista pode ser especificado"; return 1; }
				tipo='c'
				range="${1#-c}"
				if test -z "$range"
				then
					range="$2"
					shift
				fi
				shift
			;;
			-f*)
				# Campo
				test -n "$tipo" && { zztool erro "Somente um tipo de lista pode ser especificado"; return 1; }
				tipo='f'
				range="${1#-f}"
				if test -z "$range"
				then
					range="$2"
					shift
				fi
				shift
			;;
			-d*)
				# Definindo delimitador para opção campo
				unset delim
				delim="${1#-d}"
				if test -z "$delim"
				then
					delim="$2"
					shift
				fi

				# Apenas usa o recurso se houver aspas no delimitador de entrada
				if zztool grep_var '"' "$delim"
				then
					delim=$(echo "$delim" | sed 's/"/'${aspas}'/g')
					bit_aspas=$(echo "$bit_aspas" | sed 's/^./1/')
				fi
				shift
			;;
			-D*)
				ofd="${1#-D}"
				if test -z "$ofd"
				then
					ofd="$2"
					shift
				fi
				shift
			;;
			# Apenas linha que possuam delimitadores
			-s) only_delim='1'; shift ;;
			# Invertendo a seleção
			-v) inverte='1';    shift ;;
			* ) break ;;
		esac
	done

	# Um tipo de lista é mandatório
	test -z "$tipo" && { zztool erro "Deve-se especificar uma lista de caracteres ou campos"; return 1; }

	# O range é mandatório, seja qual for o tipo
	# O range só pode ser composto de números [0-9], traço [-], til [~], vírgula [,]  ou "d"
	if test -n "$range"
	then
		if echo "${range#=}" | grep -E '^[d0-9,~-]{1,}$' 2>/dev/null >/dev/null
		then
			range=$(echo "${range#=}" | sed 's/[^,]d//g;s/d[^,]//g;s/,,*/,/g;s/^,//;s/,$//')

			case "$tipo" in
				c)
					if test "$inverte" = '1'
					then
						sp=$(echo "&thinsp;" | zzunescape --html)
						codscript=$(
							echo "$range" | zztool list2lines | sort -n |
							awk -v tsp="$sp" '
								# Apagar linha toda
								/^-$/ { print "s/.*//";exit }
								# Apagar desde o início da linha até um caractere
								/^-[0-9]+$/ && NR==1 {sub(/-/,""); inicio = $1 }
								# Apagar de um caractere até o fim da linha
								/^[0-9]+-$/ {sub(/-/,""); print "s/^\\(.\\{"$1-1"\\}\\).*$/\\1/;"; exit}
								Apagar um caractere ou um trecho
								/^[0-9]+(-[0-9]+)*$/ {
									if ($1 ~ /^[0-9]+$/ && $1 > inicio ) { printf "s/./" tsp "/" $1 ";" }
									else {
										split("", faixa); split($1, faixa, "-")
										if (faixa[1] == faixa[2] && faixa[1] > inicio ) { printf "s/./" tsp "/" faixa[1] ";" }
										else {
											if (faixa[2] < faixa[1]) {
												temp = faixa[2]; faixa[2] = faixa[1]; faixa[1] = temp
											}
											for (i=faixa[1]; i<=faixa[2]; i++) { printf "s/./" tsp "/" i ";" }
										}
									}
								}
								# Apagar caracteres em saltos N~M.
								/^[0-9]*~[0-9]+$/ {
									split("", faixa); split($1, faixa, "~")
									faixa[2]*=(faixa[2]>=0?1:-1)
									faixa[2]=(faixa[2]==0?1:faixa[2])
									faixa[1]=(length(faixa[1])>0 && faixa[1]>0?faixa[1]:faixa[2])
									printf "s/./" tsp "/" faixa[1] "\n :ini\n s/\\(" tsp ".\\{" faixa[2]-1 "\\}\\)[^" tsp "]/\\1" tsp "/\n t ini\n"
								}
								END {
									if (inicio) print "s/^.\\{" inicio "\\}//;"
									print "p"
								}
							'
						)
					else
						ofd="${ofd:-$delim}"
						rlm=$(echo "&rlm;" | zzunescape --html)

						qtd_campos=$(echo "$range" |
								awk -F "," '{
									while(NF){
										if ($NF ~ /^[0-9]*~[0-9]+$/ || $NF ~ /^[0-9]*-[0-9]*$/ || $NF ~ /^[d0-9]+$/) i++
										NF--
									}
									print i
								}'
							)

						codscript=$(
							echo "$range" |
							awk -F "," -v ofs="$ofd" -v rlm="$rlm" 'BEGIN {print "h;"} {
								for (i=1; i<=NF; i++) {
									# Apenas um número, um caractere
									if ($i ~ /^[0-9]+$/) print "g;" ($i>1 ? "s/^.\\{1,"$i-1"\\}//;" : "" ) "s/^\\(.\\).*/\\1/;p"
									# Linha inteira ou faixa N-M (faixa de caracteres)
									if ($i ~ /^-$/) print "g;p"
									else if ($i ~ /^[0-9]*-[0-9]*$/) {
										split("", faixa); split($i, faixa, "-")
										faixa[1]=(length(faixa[1])>0?faixa[1]:1)
										faixa[2]=(length(faixa[2])>0?faixa[2]:"*")
										# Se segundo número for menor
										if (faixa[2]!="*" && faixa[2] < faixa[1]) {
											temp = faixa[2]; faixa[2] = faixa[1]; faixa[1] = temp
											inv=1
										}
										else inv=0
										printf "g;" (faixa[1]>1 ? "s/^.\\{1,"faixa[1]-1"\\}//;" : "" )
										print "s/^\\(." (faixa[2]!="*"?"\\{":"") faixa[2]-faixa[1]+1 (faixa[2]!="*"?"\\}":"") "\\)" (faixa[2]!="*"?".*":"") "/" (inv==1?rlm:"") "\\1/;p"
									}
									# Caracteres em saltos N~M.
									if ($i ~ /^[0-9]*~[0-9]+$/) {
										split("", faixa); split($i, faixa, "~")
										faixa[2]*=(faixa[2]>=0?1:-1)
										faixa[2]=(faixa[2]==0?1:faixa[2])
										faixa[1]=(length(faixa[1])>0 && faixa[1]>0?faixa[1]:faixa[2])
										printf "g;" ( faixa[1]>1 ? "s/^.\\{1," faixa[1]-1 "\\}//;" : "" )
										if (faixa[2]>1) printf "s/\\(.\\).\\{" faixa[2]-1 "\\}/\\1/g;"
										print "p"
									}
									if ($i == "d") { print "g;s/.*/" ofs "/g;p" }
								}
							}'
						)
					fi
				;;
				f)
					ofd="${ofd:-$delim}"
					# Apenas usa o recurso se houver aspas no delimitador de saída
					if zztool grep_var '"' "$ofd"
					then
						ofd=$(echo "$ofd" | sed 's/"/'${aspas}'/g')
						bit_aspas=$(echo "$bit_aspas" | sed 's/.$/1/')
					fi

					if test "$only_delim" = "1"
					then
						only_delim=$(zztool endereco_sed "$delim")
					fi

					if test "$inverte" = '1'
					then
						codscript=$(
							echo "$range" | zztool list2lines | sort -n |
							awk -v ofs="$ofd" 'BEGIN { print "BEGIN { OFS=\"" ofs "\" } { " }
								{
								# Apenas um número, um campo
								if ($1 ~ /^[0-9]+$/) { print "$" $1 "=\"\""}
								# Uma faixa N-M, uma faixa de campos
								if ($1 ~ /^[0-9]*-[0-9]*$/) {
									split("", faixa); split($1, faixa, "-")
									faixa[1]=(length(faixa[1])>0?faixa[1]:1)
									faixa[2]=(length(faixa[2])>0?faixa[2]:"FIM")
									# Se segundo número for menor
									if (faixa[2] < faixa[1]) {
										temp = faixa[2]; faixa[2] = faixa[1]; faixa[1] = temp
									}
									if (faixa[2]=="FIM") {
										print " ate_fim(" faixa[1] ", \"\", 1) "
									}
									else {
										for (j=faixa[1]; j<=faixa[2]; j++) {
											print "$" j "=\"\""
										}
									}
								}
								# Apagar caracteres em saltos N~M.
								if ($1 ~ /^[0-9]*~[0-9]+$/) {
									split("", faixa); split($1, faixa, "~")
									faixa[2]=(faixa[2]==0?1:faixa[2])
									faixa[1]=(length(faixa[1])>0 && faixa[1]>0?faixa[1]:faixa[2])
									print " ate_fim(" faixa[1] ", \"\", " faixa[2] ") "
								}
							}
							END { print " print }" }'
						)
					else
						codscript=$(
						echo "$range" |
						awk -F"," -v ofs="$ofd" '{
							printf "{ printf "
							for (i=1; i<=NF; i++) {
								# Apenas um número, um campo
								if ($i ~ /^[0-9]+$/) { printf "$" $i "\"" ofs "\""}
								# Uma faixa N-M, uma faixa de campos
								if ($i ~ /^[0-9]*-[0-9]*$/) {
									split("", faixa); split($i, faixa, "-")
									faixa[1]=(length(faixa[1])>0?faixa[1]:1)
									faixa[2]=(length(faixa[2])>0?faixa[2]:"FIM")

									if (faixa[2]=="FIM") {
										printf " ate_fim("faixa[1] ", \"" ofs "\", 1) "
									}
									else if (faixa[2] < faixa[1]) {
										for (j=faixa[1]; j>=faixa[2]; j--) {
											printf "$" j "\"" ofs "\""
										}
									}
									else {
										for (j=faixa[1]; j<=faixa[2]; j++) {
											printf "$" j "\"" ofs "\""
										}
									}
								}
								# Caracteres em saltos N~M.
								if ($i ~ /^[0-9]*~[0-9]+$/) {
									split("", faixa); split($i, faixa, "~")
									faixa[2]=(faixa[2]==0?1:faixa[2])
									faixa[1]=(length(faixa[1])>0 && faixa[1]>0?faixa[1]:faixa[2])
									printf " ate_fim(" faixa[1] ", \"" ofs "\", " faixa[2] ") "
								}
							}
							printf "; print \"\" }"
						}' 2>/dev/null
					)
				fi
				;;
			esac

		else
			zztool erro "Formato inválido para a lista de caracteres ou campos"; return 1
		fi
	else
		zztool erro "Deve-se definir pelo menos um range de caracteres ou campos"; return 1
	fi

	zztool file_stdin "$@" |
	if echo "$bit_aspas" | grep '^1' >/dev/null
	then
		sed 's/"/'${aspas}'/g'
	else
		cat -
	fi |
	case "$tipo" in
		c)
			sed -n "$codscript" |
			if test "$inverte" = '1'
			then
				sed "s/$sp//g"
			else
				sed "
				/$rlm/ {
					:ini
					s/\(.*\)$rlm\(.\)/\2\1$rlm/
					t ini
					s/$rlm//g
				}
				" |
				awk -v div="${qtd_campos:-1}" '{ printf $0 }; NR % div == 0 { print ""}'
			fi
		;;
		f)
			awk -F "$delim" -v tsp="$inverte" "
				function ate_fim (ini, sep, salto,  saida) {
						for (i=ini; i<=NF; i+=salto) {
							if (tsp == 1) { \$i=\"\" }
							else { saida = saida \$i sep }
						}
						if (tsp != 1) return saida
				}
				$only_delim $codscript" 2>/dev/null |
				sed "s/\(${ofd}\)\{2,\}/${ofd}/g;s/^${ofd}//;s/${ofd}$//"
		;;
	esac |
	if test "$bit_aspas" != '00'
	then
		sed 's/'${aspas}'/"/g'
	else
		cat -
	fi
}

# ----------------------------------------------------------------------------
# zzdado
# Dado virtual.
# Sem argumento, exibe um número aleatório entre 1 e 6.
# Com o argumento -f ou --faces, pode mudar a quantidade de lados do dado.
#
# Uso: zzdado
# Ex.: zzdado
#      zzdado -f 20
#      zzdado --faces 12
#
# Autor: Angelito M. Goulart, www.angelitomg.com
# Desde: 2012-12-05
# Versão: 2
# Licença: GPL
# Requisitos: zzaleatorio
# ----------------------------------------------------------------------------
zzdado ()
{

	local n_faces=6

	# Comando especial das funcoes ZZ
	zzzz -h dado "$1" && return

	while test "${1#-}" != "$1"
	do
		case "$1" in
			-f|--faces)
				if zztool testa_numero $2
				then
					n_faces="$2"
				else
					zztool erro "Numero inválido"
					return 1
				fi
			;;
			*)
				zztool erro "Opção inválida"
				return 2
			;;
		esac
		shift
	done

	# Gera e exibe um numero aleatorio entre 1 e o total de faces
	zzaleatorio 1 $n_faces
}

# ----------------------------------------------------------------------------
# zzdataestelar
# http://scifibrasil.com.br/data/
# Calcula a data estelar, a partir de uma data e horário.
#
# Sem argumentos calcula com a data e hora atual.
#
# Com um argumento, calcula conforme descrito:
#   Se for uma data válida, usa 0h 0min 0seg do dia.
#   Se for um horário, usa a data atual.
#
# Com dois argumentos sendo data seguida da hora.
#
# Uso: zzdataestelar [[data|hora] | data hora]
# Ex.: zzdataestelar
#      zzdataestelar hoje
#      zzdataestelar 25/01/2000
#      zzdataestelar 13:47:26
#      zzdataestelar 08/03/2010 14:25
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-10-28
# Versão: 1
# Licença: GPL
# Requisitos: zzdata zzdatafmt zznumero zzhora
# ----------------------------------------------------------------------------
zzdataestelar ()
{
	zzzz -h dataestelar "$1" && return

	local ano mes dia hora minuto segundo dias
	local tz=$(date "+%:z")

	case "$#" in
	0)
		# Sem agumento usa a data e hora atual UTC
		set - $(date -u "+%Y %m %d %H %M %S")
		ano=$1
		mes=$2
		dia=$3
		hora=$4
		minuto=$5
		segundo=$6
	;;
	1)
		if zzdata "$1" >/dev/null 2>&1
		then
			set - $(zzdatafmt -f "AAAA MM DD" "$1")
			ano=$1
			mes=$2
			dia=$3
			hora=0
			minuto=0
			segundo=0
		fi

		if zztool grep_var ':' "$1"
		then
			set - $(echo "$1" | sed 's/:/ /g')
			segundo=${3:-0}

			set - $(zzhora ${1}:${2} - $tz | sed 's/:/ /g')
			hora=$1
			minuto=$2

			set - $(zzdatafmt -f "AAAA MM DD" hoje)
			ano=$1
			mes=$2
			dia=$3
		fi
	;;
	2)
		if zzdata $1 >/dev/null 2>&1 && zztool grep_var ':' "$2"
		then
			set - $(zzdatafmt -f "AAAA MM DD $2" "$1" | sed 's/:/ /g')
			ano=$1
			mes=$2
			dia=$3
			segundo=${6:-0}

			set - $(zzhora "${4}:${5}" - "$tz" | sed 's/:/ /g')
			hora=$1
			minuto=$2
		fi
	;;
	esac

	if zztool testa_numero $ano
	then
		dias=$(zzdata ${dia}/${mes}/${ano} - 01/01/${ano})
		dias=$((dias + 1))

		echo "scale=6;(($ano + 4712) * 365.25) - 13.375 + ($dias * (1+59.2/86400)) + ($hora/24) + ($minuto/1440) + ($segundo/86400)" |
		bc -l | cut -c 3- | zznumero -f "%.2f" | tr ',' '.'
	else
		zztool -e uso dataestelar
		return 1
	fi
}

# ----------------------------------------------------------------------------
# zzdatafmt
# Muda o formato de uma data, com várias opções de personalização.
# Reconhece datas em vários formatos, como aaaa-mm-dd, dd.mm.aaaa e dd/mm.
# Obs.: Se você não informar o ano, será usado o ano corrente.
#
# Use a opção -f para mudar o formato de saída (o padrão é DD/MM/AAAA):
#
#      Código   Exemplo     Descrição
#      --------------------------------------------------------------
#      AAAA     2003        Ano com 4 dígitos
#      AA       03          Ano com 2 dígitos
#      A        3           Ano sem zeros à esquerda (1 ou 2 dígitos)
#      MM       02          Mês com 2 dígitos
#      M        2           Mês sem zeros à esquerda
#      DD       01          Dia com 2 dígitos
#      D        1           Dia sem zeros à esquerda
#      --------------------------------------------------------------
#      ANO      dois mil    Ano por extenso
#      MES      fevereiro   Nome do mês
#      MMM      fev         Nome do mês com três letras
#      DIA      vinte um    Dia por extenso
#      SEMANA   Domingo     Dia da semana por extenso
#      SSS      Dom         Dia da semana com três letras
#
# Use as opções de idioma para alterar os nomes dos meses. Estas opções também
# mudam o formato padrão da data de saída, caso a opção -f não seja informada.
#     --pt para português     --de para alemão
#     --en para inglês        --fr para francês
#     --es para espanhol      --it para italiano
#     --ptt português textual incluindo os números
#     --iso formato AAAA-MM-DD
#
# Uso: zzdatafmt [-f formato] [data]
# Ex.: zzdatafmt 2011-12-31                 # 31/12/2011
#      zzdatafmt 31.12.11                   # 31/12/2011
#      zzdatafmt 31/12                      # 31/12/2011     (ano atual)
#      zzdatafmt -f MES hoje                # maio           (mês atual)
#      zzdatafmt -f MES --en hoje           # May            (em inglês)
#      zzdatafmt -f AAAA 31/12/11           # 2011
#      zzdatafmt -f MM/DD/AA 31/12/2011     # 12/31/11       (BR -> US)
#      zzdatafmt -f D/M/A 01/02/2003        # 1/2/3
#      zzdatafmt -f "D de MES" 01/05/95     # 1 de maio
#      echo 31/12/2011 | zzdatafmt -f MM    # 12             (via STDIN)
#      zzdatafmt 31 de jan de 2013          # 31/01/2013     (entrada textual)
#      zzdatafmt --de 19/03/2012            # 19. März 2012  (Das ist gut!)
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-24
# Versão: 11
# Licença: GPL
# Requisitos: zzdata zzminusculas zznumero zzdiadasemana
# Tags: data
# ----------------------------------------------------------------------------
zzdatafmt ()
{
	zzzz -h datafmt "$1" && return

	local data data_orig fmt
	local ano_atual ano aaaa aa a
	local meses mes mmm mm m
	local semanas semana sem sss
	local dia dd d
	local meses_pt='janeiro fevereiro março abril maio junho julho agosto setembro outubro novembro dezembro'
	local meses_en='January February March April May June July August September October November December'
	local meses_es='Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre'
	local meses_de='Januar Februar März April Mai Juni Juli August September Oktober November Dezember'
	local meses_fr='Janvier Février Mars Avril Mai Juin Juillet Août Septembre Octobre Novembre Décembre'
	local meses_it='Gennaio Febbraio Marzo Aprile Maggio Giugno Luglio Agosto Settembre Ottobre Novembre Dicembre'
	local semana_pt='Domingo Segunda-feira Terça-feira Quarta-feira Quinta-feira Sexta-feira Sábado'
	local semana_en='Sunday Monday Tuesday Wednesday Thursday Friday Saturday'
	local semana_es='Domingo Lunes Martes Miércoles Jueves Viernes Sábado'
	local semana_de='Sonntag Montag Dienstag Mittwoch Donnerstag Freitag Samstag'
	local semana_fr='Dimanche Lundi Mardi Mercredi Juedi Vendredi Samedi'
	local semana_it='Domenica Lunedi Martedi Mercoledi Giovedi Venerdi Sabato'

	# Idioma padrão
	meses="$meses_pt"
	semanas="$semana_pt"

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			--en)
				meses=$meses_en
				semanas=$semana_en
				test -n "$fmt" || fmt='MES, DD AAAA'
				shift
			;;
			--it)
				meses=$meses_it
				semanas=$semana_it
				test -n "$fmt" || fmt='DD da MES AAAA'
				shift
			;;
			--es)
				meses=$meses_es
				semanas=$semana_es
				test -n "$fmt" || fmt='DD de MES de AAAA'
				shift
			;;
			--pt)
				meses=$meses_pt
				semanas=$semana_pt
				test -n "$fmt" || fmt='DD de MES de AAAA'
				shift
			;;
			--ptt)
				meses=$meses_pt
				semanas=$semana_pt
				test -n "$fmt" || fmt='DIA de MES de ANO'
				shift
			;;
			--de)
				meses=$meses_de
				semanas=$semana_de
				test -n "$fmt" || fmt='DD. MES AAAA'
				shift
			;;
			--fr)
				meses=$meses_fr
				semanas=$semana_fr
				test -n "$fmt" || fmt='Le DD MES AAAA'
				shift
			;;
			--iso)
				fmt="AAAA-MM-DD"; shift;;
			-f)
				fmt="$2"
				shift
				shift
			;;
			*) break ;;
		esac
	done

	# Data via STDIN ou argumentos
	data=$(zztool multi_stdin "$@")
	data_orig="$data"

	# Converte datas estranhas para o formato brasileiro ../../..
	case "$data" in
		# apelidos
		hoje | ontem | anteontem | amanh[ãa] | today | yesterday | tomorrow)
			data=$(zzdata "$data")
		;;
		# semana (curto)
		dom | seg | ter | qua | qui | sex | sab)
			data=$(zzdata "$data")
		;;
		# semana (longo)
		domingo | segunda | ter[cç]a | quarta | quinta | sexta | s[aá]bado)
			data=$(zzdata "$data")
		;;
		# data possivelmente em formato textual
		*[A-Za-z]*)
			# 31 de janeiro de 2013
			# 31 de jan de 2013
			# 31/jan/2013
			# 31-jan-2013
			# 31.jan.2013
			# 31 jan 2013

			# Primeiro converte tudo pra 31/jan/2013 ou 31/janeiro/2013
			data=$(echo "$data" | zzminusculas | sed 's| de |/|g' | tr ' .-' ///)

			# Agora converte o nome do mês para número
			mes=$(echo "$data" | cut -d / -f 2)
			mm=$(echo "$meses_pt" |
				zzminusculas |
				awk '{for (i=1;i<=NF;i++){ if (substr($i,1,3) == substr("'$mes'",1,3) ) printf "%02d\n", i}}')
			zztool testa_numero "$mm" && data=$(echo "$data" | sed "s/$mes/$mm/")
			unset mes mm
		;;
		# aaaa-mm-dd (ISO)
		????-??-??)
			data=$(echo "$data" | sed 's|\(....\)-\(..\)-\(..\)|\3/\2/\1|')
		;;
		# d-m-a, d-m
		# d.m.a, d.m
		*-* | *.*)
			data=$(echo "$data" | tr .- //)
		;;
		# ddmmaaaa
		[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9])
			data=$(echo "$data" | sed 's|.|&/|4 ; s|.|&/|2')
		;;
		# ddmmaa
		[0-9][0-9][0-9][0-9][0-9][0-9])
			data=$(echo "$data" | sed 's|.|&/|4 ; s|.|&/|2')
		;;
	esac

	### Aqui só chegam datas com a barra / como delimitador
	### Mas elas podem ser parcias, como: dia/mês

	# Completa elementos que estão faltando na data
	case "$data" in
		# d/m, dd/m, d/mm, dd/mm
		# Adiciona o ano atual
		[0-9]/[0-9] | [0-9][0-9]/[0-9] | [0-9]/[0-9][0-9] | [0-9][0-9]/[0-9][0-9])
			ano_atual=$(zzdata hoje | cut -d / -f 3)
			data="$data/$ano_atual"
		;;
	esac

	### Aqui só chegam datas completas, com os três elementos: n/n/n
	### Devo acertar o padding delas pra nn/nn/nnnn

	# Valida o formato da data
	if ! echo "$data" | grep '^[0-9][0-9]\{0,1\}/[0-9][0-9]\{0,1\}/[0-9]\{1,4\}$' >/dev/null
	then
		zztool erro "Erro: Data em formato desconhecido '$data_orig'"
		return 1
	fi

	# Extrai os valores da data
	dia=$(echo "$data" | cut -d / -f 1)
	mes=$(echo "$data" | cut -d / -f 2)
	ano=$(echo "$data" | cut -d / -f 3)

	# Faz padding nos valores
	case "$ano" in
		?         ) aaaa="200$ano";;  # 2000-2009
		[0-3][0-9]) aaaa="20$ano";;   # 2000-2039
		[4-9][0-9]) aaaa="19$ano";;   # 1940-1999
		???       ) aaaa="0$ano";;    # 0000-0999
		????      ) aaaa="$ano";;
	esac
	case "$mes" in
		?)  mm="0$mes";;
		??) mm="$mes";;
	esac
	case "$dia" in
		?)  dd="0$dia";;
		??) dd="$dia";;
	esac

	# Ok, agora a data está no formato correto: dd/mm/aaaa
	data="$dd/$mm/$aaaa"

	# Valida a data
	zztool -e testa_data "$data" || return 1

	# O usuário especificou um formato novo?
	if test -n "$fmt"
	then
		aaaa="${data##*/}"
		mm="${data#*/}"; mm="${mm%/*}"
		dd="${data%%/*}"
		aa="${aaaa#??}"
		a="${aa#0}"
		m="${mm#0}"
		d="${dd#0}"
		mes=$(echo "$meses" | cut -d ' ' -f "$m" 2>/dev/null)
		mmm=$(echo "$mes" | sed 's/\(...\).*/\1/')
		sem=$(zzdiadasemana -n $dd/$mm/$aaaa)
		semana=$(echo "$semanas" | cut -d ' ' -f "$sem" 2>/dev/null)
		sss=$(echo "$semana" | sed 's/\(...\).*/\1/')

		# Percorre o formato e vai expandindo, da esquerda para a direita
		while test -n "$fmt"
		do
			# Atenção à ordem das opções do case: AAAA -> AAA -> AA
			# Sempre do maior para o menor para evitar matches parciais
			case "$fmt" in
				SEMANA*)
					printf %s "$semana"
					fmt="${fmt#SEMANA}";;
				SSS*  ) printf %s "$sss"; fmt="${fmt#SSS}";;
				ANO*  )
					printf "$(zznumero --texto $aaaa)"
					fmt="${fmt#ANO}";;
				DIA*  )
					printf "$(zznumero --texto $dd)"
					fmt="${fmt#DIA}";;
				MES*  ) printf %s "$mes" ; fmt="${fmt#MES}";;
				AAAA* ) printf %s "$aaaa"; fmt="${fmt#AAAA}";;
				AA*   ) printf %s "$aa"  ; fmt="${fmt#AA}";;
				A*    ) printf %s "$a"   ; fmt="${fmt#A}";;
				MMM*  ) printf %s "$mmm" ; fmt="${fmt#MMM}";;
				MM*   ) printf %s "$mm"  ; fmt="${fmt#MM}";;
				M*    ) printf %s "$m"   ; fmt="${fmt#M}";;
				DD*   ) printf %s "$dd"  ; fmt="${fmt#DD}";;
				D*    ) printf %s "$d"   ; fmt="${fmt#D}";;
				*     ) printf %c "$fmt" ; fmt="${fmt#?}";;  # 1char
			esac
		done
		echo

	# Senão, é só mostrar no formato normal
	else
		echo "$data"
	fi
}

# ----------------------------------------------------------------------------
# zzdata
# Calculadora de datas, trata corretamente os anos bissextos.
# Você pode somar ou subtrair dias, meses e anos de uma data qualquer.
# Você pode informar a data dd/mm/aaaa ou usar palavras como: hoje, ontem.
# Usar a palavra dias informa número de dias desde o começo do ano corrente.
# Ou os dias da semana como: domingo, seg, ter, qua, qui, sex, sab, dom.
# Na diferença entre duas datas, o resultado é o número de dias entre elas.
# Se informar somente uma data, converte para número de dias (01/01/1970 = 0).
# Se informar somente um número (de dias), converte de volta para a data.
# Esta função também pode ser usada para validar uma data.
#
# Uso: zzdata [data [+|- data|número<d|m|a>]]
# Ex.: zzdata                           # que dia é hoje?
#      zzdata anteontem                 # que dia foi anteontem?
#      zzdata dom                       # que dia será o próximo domingo?
#      zzdata hoje + 15d                # que dia será daqui 15 dias?
#      zzdata hoje - 40d                # e 40 dias atrás, foi quando?
#      zzdata 31/12/2010 + 100d         # 100 dias após a data informada
#      zzdata 29/02/2001                # data inválida, ano não-bissexto
#      zzdata 29/02/2000 + 1a           # 28/02/2001 <- respeita bissextos
#      zzdata 01/03/2000 - 11/11/1999   # quantos dias há entre as duas?
#      zzdata hoje - 07/10/1977         # quantos dias desde meu nascimento?
#      zzdata 21/12/2012 - hoje         # quantos dias para o fim do mundo?
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2003-02-07
# Versão: 5
# Licença: GPL
# Requisitos: zztestar
# Tags: data, cálculo
# ----------------------------------------------------------------------------
zzdata ()
{
	zzzz -h data "$1" && return

	local yyyy mm dd mmdd i m y op dias_ano dias_mes dias_neste_mes
	local valor operacao quantidade grandeza
	local tipo tipo1 tipo2
	local data data1 data2
	local dias dias1 dias2
	local delta delta1 delta2
	local epoch=1970
	local dias_mes_ok='31 28 31 30 31 30 31 31 30 31 30 31'  # jan-dez
	local dias_mes_rev='31 30 31 30 31 31 30 31 30 31 28 31' # dez-jan
	local valor1="$1"
	local operacao="$2"
	local valor2="$3"

	# Verificação dos parâmetros
	case $# in
		0)
			# Sem argumentos, mostra a data atual
			zzdata hoje
			return
		;;
		1)
			# Delta sozinho é relativo ao dia atual
			case "$1" in
				[0-9]*[dma])
					zzdata hoje + "$1"
					return
				;;
			esac
		;;
		3)
			# Validação rápida
			if test "$operacao" != '-' -a "$operacao" != '+'
			then
				zztool erro "Operação inválida '$operacao'. Deve ser + ou -."
				return 1
			fi
		;;
		*)
			zztool -e uso data
			return 1
		;;
	esac

	# Validação do conteúdo de $valor1 e $valor2
	# Formato válidos: 31/12/1999, 123, -123, 5d, 5m, 5a, hoje
	#
	# Este bloco é bem importante, pois além de validar os dados
	# do usuário, também povoa as variáveis que serão usadas na
	# tomada de decisão adiante. São elas:
	# $tipo1 $tipo2 $data1 $data2 $dias1 $dias2 $delta1 $delta2
	#
	# Nota: é o eval quem salva estas variáveis.

	for i in 1 2
	do
		# Obtém o conteúdo de $valor1 ou $valor2
		eval "valor=\$valor$i"

		# Cancela se i=2 e só temos um valor
		test -z "$valor" && break

		# Identifica o tipo do valor e faz a validação
		case "$valor" in

			# Data no formato dd/mm/aaaa
			??/??/?*)

				tipo='data'
				yyyy="${valor##*/}"
				ddmm="${valor%/*}"

				# Data em formato válido?
				zztool -e testa_data "$valor" || return 1

				# 29/02 em um ano não-bissexto?
				if test "$ddmm" = '29/02' && ! zztestar ano_bissexto "$yyyy"
				then
					zztool erro "Data inválida '$valor', pois $yyyy não é um ano bissexto."
					return 1
				fi
			;;

			# Delta de dias, meses ou anos: 5d, 5m, 5a
			[0-9]*[dma])

				tipo='delta'

				# Validação
				if ! echo "$valor" | grep '^[0-9][0-9]*[dma]$' >/dev/null
				then
					zztool erro "Delta inválido '$valor'. Deve ser algo como 5d, 5m ou 5a."
					return 1
				fi
			;;

			# Número negativo ou positivo
			-[0-9]* | [0-9]*)

				tipo='dias'

				# Validação
				if ! zztestar numero_sinal "$valor"
				then
					zztool erro "Número inválido '$valor'"
					return 1
				fi
			;;

			# Apelidos: hoje, ontem, etc
			[a-z]*)

				tipo='data'

				# Converte apelidos em datas
				case "$valor" in
					today | hoje)
						valor=$(date +%d/%m/%Y)
					;;
					yesterday | ontem)
						valor=$(zzdata hoje - 1)
					;;
					anteontem)
						valor=$(zzdata hoje - 2)
					;;
					tomorrow | amanh[aã])
						valor=$(zzdata hoje + 1)
					;;
					dom | domingo)
						valor=$(zzdata hoje + $(echo "7 $(date +%u)" | awk '{ print ($1 >= $2 ? $1 - $2 : 7 + ($1 - $2)) }'))
					;;
					sab | s[aá]bado)
						valor=$(zzdata hoje + $(echo "6 $(date +%u)" | awk '{ print ($1 >= $2 ? $1 - $2 : 7 + ($1 - $2)) }'))
					;;
					sex | sexta)
						valor=$(zzdata hoje + $(echo "5 $(date +%u)" | awk '{ print ($1 >= $2 ? $1 - $2 : 7 + ($1 - $2)) }'))
					;;
					qui | quinta)
						valor=$(zzdata hoje + $(echo "4 $(date +%u)" | awk '{ print ($1 >= $2 ? $1 - $2 : 7 + ($1 - $2)) }'))
					;;
					qua | quarta)
						valor=$(zzdata hoje + $(echo "3 $(date +%u)" | awk '{ print ($1 >= $2 ? $1 - $2 : 7 + ($1 - $2)) }'))
					;;
					ter | ter[cç]a)
						valor=$(zzdata hoje + $(echo "2 $(date +%u)" | awk '{ print ($1 >= $2 ? $1 - $2 : 7 + ($1 - $2)) }'))
					;;
					seg | segunda)
						valor=$(zzdata hoje + $(echo "1 $(date +%u)" | awk '{ print ($1 >= $2 ? $1 - $2 : 7 + ($1 - $2)) }'))
					;;
					days | dias)
						# Quantidade transcorridos de dias do ano.
						valor=$(date +%j)
					;;
					fim)
						valor=21/12/2012  # ;)
					;;
					*)
						zztool erro "Data inválida '$valor', deve ser dd/mm/aaaa"
						return 1
				esac

				# Exceção: se este é o único argumento, mostra a data e sai
				if test $# -eq 1
				then
					echo "$valor"
					return 0
				fi
			;;
			*)
				zztool erro "Data inválida '$valor', deve ser dd/mm/aaaa"
				return 1
			;;
		esac

		# Salva as variáveis $data/$dias/$delta e $tipo,
		# todas com os sufixos 1 ou 2 no nome. Por isso o eval.
		# Exemplo: data1=01/01/1970; tipo1=data
		eval "$tipo$i=$valor; tipo$i=$tipo"
	done

	# Validação: Se há um delta, o outro valor deve ser uma data ou número
	if test "$tipo1" = 'delta' -a "$tipo2" = 'delta'
	then
		zztool -e uso data
		return 1
	fi

	# Se chamada com um único argumento, é uma conversão simples.
	# Se veio uma data, converta para um número.
	# Se veio um número, converta para uma data.
	# E pronto.

	if test $# -eq 1
	then
		case $tipo1 in

			data)
				#############################################################
				### Conversão DATA -> NÚMERO
				#
				# A data dd/mm/aaaa é transformada em um número inteiro.
				# O resultado é o número de dias desde $epoch (01/01/1970).
				# Se a data for anterior a $epoch, o número será negativo.
				# Anos bissextos são tratados corretamente.
				#
				# Exemplos:
				#      30/12/1969 = -2
				#      31/12/1969 = -1
				#      01/01/1970 = 0
				#      02/01/1970 = 1
				#      03/01/1970 = 2
				#
				#      01/02/1970 = 31    (31 dias do mês de janeiro)
				#      01/01/1971 = 365   (um ano)
				#      01/01/1980 = 3652  (365 * 10 anos + 2 bissextos)

				data="$data1"

				# Extrai os componentes da data: ano, mês, dia
				yyyy=${data##*/}
				mm=${data#*/}
				mm=${mm%/*}
				dd=${data%%/*}

				# Retira os zeros à esquerda (pra não confundir com octal)
				mm=${mm#0}
				dd=${dd#0}
				yyyy=$(echo "$yyyy" | sed 's/^00*//; s/^$/0/')

				# Define o marco inicial e a direção dos cálculos
				if test $yyyy -ge $epoch
				then
					# +Epoch: Inicia em 01/01/1970 e avança no tempo
					y=$epoch          # ano
					m=1               # mês
					op='+'            # direção
					dias=0            # 01/01/1970 == 0
					dias_mes="$dias_mes_ok"
				else
					# -Epoch: Inicia em 31/12/1969 e retrocede no tempo
					y=$((epoch - 1))  # ano
					m=12              # mês
					op='-'            # direção
					dias=-1           # 31/12/1969 == -1
					dias_mes="$dias_mes_rev"
				fi

				# Ano -> dias
				while :
				do
					# Sim, os anos bissextos são levados em conta!
					dias_ano=365
					zztestar ano_bissexto $y && dias_ano=366

					# Vai somando (ou subtraindo) até chegar no ano corrente
					test $y -eq $yyyy && break
					dias=$(($dias $op $dias_ano))
					y=$(($y $op 1))
				done

				# Meses -> dias
				for i in $dias_mes
				do
					# Fevereiro de ano bissexto tem 29 dias
					test $dias_ano -eq 366 -a $i -eq 28 && i=29

					# Vai somando (ou subtraindo) até chegar no mês corrente
					test $m -eq $mm && break
					m=$(($m $op 1))
					dias=$(($dias $op $i))
				done
				dias_neste_mes=$i

				# -Epoch: o número de dias indica o quanto deve-se
				# retroceder à partir do último dia do mês
				test $op = '-' && dd=$(($dias_neste_mes - $dd))

				# Somando os dias da data aos anos+meses já contados.
				dias=$(($dias $op $dd))

				# +Epoch: É subtraído um do resultado pois 01/01/1970 == 0
				test $op = '+' && dias=$((dias - 1))

				# Feito, só mostrar o resultado
				echo "$dias"
			;;

			dias)
				#############################################################
				### Conversão NÚMERO -> DATA
				#
				# O número inteiro é convertido para a data dd/mm/aaaa.
				# Se o número for positivo, temos uma data DEPOIS de $epoch.
				# Se o número for negativo, temos uma data ANTES de $epoch.
				# Anos bissextos são tratados corretamente.
				#
				# Exemplos:
				#      -2 = 30/12/1969
				#      -1 = 31/12/1969
				#       0 = 01/01/1970
				#       1 = 02/01/1970
				#       2 = 03/01/1970

				dias="$dias1"

				if test $dias -ge 0
				then
					# POSITIVO: Inicia em 01/01/1970 e avança no tempo
					y=$epoch          # ano
					mm=1              # mês
					op='+'            # direção
					dias_mes="$dias_mes_ok"
				else
					# NEGATIVO: Inicia em 31/12/1969 e retrocede no tempo
					y=$((epoch - 1))  # ano
					mm=12             # mês
					op='-'            # direção
					dias_mes="$dias_mes_rev"

					# Valor negativo complica, vamos positivar: abs()
					dias=$((0 - dias))
				fi

				# O número da Epoch é zero-based, agora vai virar one-based
				dd=$(($dias $op 1))

				# Dias -> Ano
				while :
				do
					# Novamente, o ano bissexto é levado em conta
					dias_ano=365
					zztestar ano_bissexto $y && dias_ano=366

					# Vai descontando os dias de cada ano para saber quantos anos cabem

					# Não muda o ano se o número de dias for insuficiente
					test $dd -lt $dias_ano && break

					# Se for exatamente igual ao total de dias, não muda o
					# ano se estivermos indo adiante no tempo (> Epoch).
					# Caso contrário vai mudar pois cairemos no último dia
					# do ano anterior.
					test $dd -eq $dias_ano -a $op = '+' && break

					dd=$(($dd - $dias_ano))
					y=$(($y $op 1))
				done
				yyyy=$y

				# Dias -> mês
				for i in $dias_mes
				do
					# Fevereiro de ano bissexto tem 29 dias
					test $dias_ano -eq 366 -a $i -eq 28 && i=29

					# Calcula quantos meses cabem nos dias que sobraram

					# Não muda o mês se o número de dias for insuficiente
					test $dd -lt $i && break

					# Se for exatamente igual ao total de dias, não muda o
					# mês se estivermos indo adiante no tempo (> Epoch).
					# Caso contrário vai mudar pois cairemos no último dia
					# do mês anterior.
					test $dd -eq $i -a $op = '+' && break

					dd=$(($dd - $i))
					mm=$(($mm $op 1))
				done
				dias_neste_mes=$i

				# Ano e mês estão OK, agora sobraram apenas os dias

				# Se estivermos antes de Epoch, os número de dias indica quanto
				# devemos caminhar do último dia do mês até o primeiro
				test $op = '-' && dd=$(($dias_neste_mes - $dd))

				# Restaura o zero dos meses e dias menores que 10
				test $dd -le 9 && dd="0$dd"
				test $mm -le 9 && mm="0$mm"

				# E finalmente mostra o resultado em formato de data
				echo "$dd/$mm/$yyyy"
			;;

			*)
				zztool erro "Tipo inválido '$tipo1'. Isso não deveria acontecer :/"
				return 1
			;;
		esac
		return 0
	fi

	# Neste ponto só chega se houver mais de um parâmetro.
	# Todos os valores já foram validados.

	#############################################################
	### Cálculos com datas
	#
	# Temos dois valores informadas pelo usuário: $valor1 e $valor2.
	# Cada valor pode ser uma data dd/mm/aaaa, um número inteiro
	# ou um delta de dias, meses ou anos.
	#
	# Exemplos: 31/12/1999, 123, -123, 5d, 5m, 5a
	#
	# O usuário pode fazer qualquer combinação entre estes valores.
	#
	# Se o cálculo envolver deltas m|a, é usada a data dd/mm/aaaa.
	# Senão, é usado o número inteiro que representa a data.
	#
	# O tipo de cada valor é guardado em $tipo1-2.
	# Dependendo do tipo, o valor foi guardado nas variáveis
	# $data1-2, $dias1-2 ou $delta1-2.
	# Use estas variáveis no bloco seguinte para tomar decisões.

	# Cálculo com delta.
	if test $tipo1 = 'delta' -o $tipo2 = 'delta'
	then
		# Nunca haverá dois valores do mesmo tipo, posso abusar:
		delta="$delta1$delta2"
		data="$data1$data2"
		dias="$dias1$dias2"

		quantidade=$(echo "$delta" | sed 's/[^0-9]//g')
		grandeza=$(  echo "$delta" | sed 's/[^dma]//g')

		case $grandeza in
			d)
				# O cálculo deve ser feito utilizando o número
				test -z "$dias" && dias=$(zzdata "$data")  # data2n

				# Soma ou subtrai o delta
				dias=$(($dias $operacao $quantidade))

				# Converte o resultado para dd/mm/aaaa
				zzdata $dias
				return
			;;
			m | a)
				# O cálculo deve ser feito utilizando a data
				test -z "$data" && data=$(zzdata "$dias")  # n2data

				# Extrai os componentes da data: ano, mês, dia
				yyyy=${data##*/}
				mm=${data#*/}
				mm=${mm%/*}
				dd=${data%%/*}

				# Retira os zeros à esquerda (pra não confundir com octal)
				mm=${mm#0}
				dd=${dd#0}
				yyyy=$(echo "$yyyy" | sed 's/^00*//; s/^$/0/')

				# Anos
				if test $grandeza = 'a'
				then
					yyyy=$(($yyyy $operacao $quantidade))

				# Meses
				else
					mm=$(($mm $operacao $quantidade))

					# Se houver excedente no mês (>12), recalcula mês e ano
					yyyy=$(($yyyy + $mm / 12))
					mm=$(($mm % 12))

					# Se negativou, ajusta os cálculos (voltou um ano)
					if test $mm -le 0
					then
						yyyy=$(($yyyy - 1))
						mm=$((12 + $mm))
					fi
				fi

				# Se o resultado for 29/02 em um ano não-bissexto, muda pra 28/02
				if test $mm -eq 2
				then
					test $dd -eq 29 && ! zztestar ano_bissexto $yyyy && dd=28
					test $dd -gt 29 && zztestar ano_bissexto $yyyy && dd=29
					# Se for 30 ou 31/02 em um ano não bissexto, muda para 01/03
					test $dd -gt 29 && ! zztestar ano_bissexto $yyyy && { dd=1; mm=3; }
				fi

				# Restaura o zero dos meses e dias menores que 10
				test $dd -le 9 && dd="0$dd"
				test $mm -le 9 && mm="0$mm"

				# Tá feito, basta montar a data
				echo "$dd/$mm/$yyyy"
				return 0
			;;
		esac

	# Cálculo normal, sem delta
	else
		# Ambas as datas são sempre convertidas para inteiros
		test "$tipo1" != 'dias' && dias1=$(zzdata "$data1")
		test "$tipo2" != 'dias' && dias2=$(zzdata "$data2")

		# Soma ou subtrai os valores
		dias=$(($dias1 $operacao $dias2))

		# Se as duas datas foram informadas como dd/mm/aaaa,
		# o resultado é o próprio número de dias. Senão converte
		# o resultado para uma data.
		if test "$tipo1$tipo2" = 'datadata'
		then
			echo "$dias"
		else
			zzdata "$dias"  # n2data
		fi
	fi
}

# ----------------------------------------------------------------------------
# zzdefinr
# http://definr.com
# Busca o significado de um termo, palavra ou expressão no site Definr.
# Uso: zzdefinr termo
# Ex.: zzdefinr headphone
#      zzdefinr in force
#
# Autor: Felipe Arruda <felipemiguel (a) gmail com>
# Desde: 2008-08-15
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzdefinr ()
{
	zzzz -h definr "$1" && return

	test -n "$1" || { zztool -e uso definr; return 1; }

	local word=$(echo "$*" | sed 's/ /%20/g')

	zztool source "http://definr.com/$word" |
		sed '
			/<div id="meaning">/,/<\/div>/!d
			s/<[^>]*>//g
			s/&nbsp;/ /g
			/^$/d'
}

# ----------------------------------------------------------------------------
# zzdiadasemana
# Mostra qual o dia da semana de uma data qualquer.
# Com a opção -n mostra o resultado em forma numérica (domingo=1).
# Obs.: Se a data não for informada, usa a data atual.
# Uso: zzdiadasemana [-n] [data]
# Ex.: zzdiadasemana
#      zzdiadasemana 31/12/2010          # sexta-feira
#      zzdiadasemana -n 31/12/2010       # 6
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-10-24
# Versão: 3
# Licença: GPL
# Requisitos: zzdata
# Tags: data
# ----------------------------------------------------------------------------
zzdiadasemana ()
{
	zzzz -h diadasemana "$1" && return

	local data delta dia
	local dias="quinta- sexta- sábado domingo segunda- terça- quarta-"
	local dias_rev="quinta- quarta- terça- segunda- domingo sábado sexta-"
	local dias_n="5 6 7 1 2 3 4"
	local dias_n_rev="5 4 3 2 1 7 6"
	# 1=domingo, assim os números são similares aos nomes: 2=segunda

	# Opção de linha de comando
	if test "$1" = '-n'
	then
		dias="$dias_n"
		dias_rev="$dias_n_rev"
		shift
	fi

	data="$1"

	# Se a data não foi informada, usa a atual
	test -z "$data" && data=$(date +%d/%m/%Y)

	# Validação
	zztool -e testa_data "$data" || return 1

	# O cálculo se baseia na data ZERO (01/01/1970), que é quinta-feira.
	# Basta dividir o delta (intervalo de dias até a data ZERO) por 7.
	# O resto da divisão é o dia da semana, sendo 0=quinta e 6=quarta.
	#
	# A função zzdata considera 01/01/1970 a data zero, e se chamada
	# apenas com uma data, retorna o número de dias de diferença para
	# o dia zero. O número será negativo se o ano for inferior a 1970.
	#
	delta=$(zzdata $data)
	dia=$(( ${delta#-} % 7))  # remove o sinal negativo (se tiver)

	# Se a data é anterior a 01/01/1970, conta os dias ao contrário
	test $delta -lt 0 && dias="$dias_rev"

	# O cut tem índice inicial um e não zero, por isso dia+1
	echo "$dias" |
		cut -d ' ' -f $((dia+1)) |
		sed 's/-/-feira/'
}

# ----------------------------------------------------------------------------
# zzdiasuteis
# Calcula o número de dias úteis entre duas datas, inclusive ambas.
# Chamada sem argumentos, mostra os total de dias úteis no mês atual.
# Obs.: Não leva em conta feriados.
#
# Uso: zzdiasuteis [data-inicial data-final]
# Ex.: zzdiasuteis                          # Fevereiro de 2013 tem 20 dias …
#      zzdiasuteis 01/01/2011 31/01/2011    # 21
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-20
# Versão: 2
# Licença: GPL
# Requisitos: zzdata zzdiadasemana zzdatafmt zzcapitalize
# Tags: data, cálculo
# ----------------------------------------------------------------------------
zzdiasuteis ()
{
	zzzz -h diasuteis "$1" && return

	local data dias dia1 semanas avulsos ini fim hoje mes ano
	local avulsos_uteis=0
	local uteis="0111110"  # D S T Q Q S S
	local data1="$1"
	local data2="$2"

	# Verificação dos parâmetros
	if test $# -eq 0
	then
		# Sem argumentos, calcula para o mês atual
		# Exemplo para fev/2013: zzdiasuteis 01/02/2013 28/02/2013
		hoje=$(zzdata hoje)
		data1=$(zzdatafmt -f 01/MM/AAAA $hoje)
		data2=$(zzdata $(zzdata $data1 + 1m) - 1)
		mes=$(zzdatafmt -f MES $hoje | zzcapitalize)
		ano=$(zzdatafmt -f AAAA $hoje)
		echo "$mes de $ano tem $(zzdiasuteis $data1 $data2) dias úteis."
		return 0

	elif test $# -ne 2
	then
		zztool -e uso diasuteis
		return 1
	fi

	# Valida o formato das datas
	zztool -e testa_data "$data1" || return 1
	zztool -e testa_data "$data2" || return 1

	# Quantos dias há entre as duas datas?
	dias=$(zzdata $data2 - $data1)

	# O usuário inverteu a ordem das datas?
	if test $dias -lt 0
	then
		# Tudo bem, a gente desinverte.
		dias=$((0 - $dias))  # abs()
		data=$data1
		data1=$data2
		data2=$data
	fi

	# A zzdata conta a diferença, então precisamos fazer +1 para incluir
	# ambas as datas no resultado.
	dias=$((dias + 1))

	# Qual dia da semana cai a data inicial?
	dia1=$(zzdiadasemana -n $data1)  # 1=domingo

	# Quantas semanas e quantos dias avulsos?
	semanas=$((dias / 7))
	avulsos=$((dias % 7))

	# Dos avulsos, quantos são úteis?
	#
	# Montei uma matriz de 14 posições ($uteis * 2) que contém 0's
	# e 1's, sendo que os 1's marcam os dias úteis. Faço um recorte
	# nessa matriz que inicia no $dia1 e tem o tamanho do total de
	# dias avulsos ($avulsos, max=6). As variáveis $ini e $fim são
	# usadas no cut e traduzem este recorte. Por fim, removo os
	# zeros e conto quantos 1's sobraram, que são os dias úteis.
	#
	if test $avulsos -gt 0
	then
		ini=$dia1
		fim=$(($dia1 + $avulsos - 1))
		avulsos_uteis=$(
			echo "$uteis$uteis" |
			cut -c $ini-$fim |
			tr -d 0)
		avulsos_uteis=${#avulsos_uteis}  # wc -c
	fi

	# Com os dados na mão, basta calcular
	echo $(($semanas * 5 + $avulsos_uteis))
}

# ----------------------------------------------------------------------------
# zzdicantonimos
# http://www.antonimos.com.br/
# Procura antônimos para uma palavra.
# Uso: zzdicantonimos palavra
# Ex.: zzdicantonimos bom
#
# Autor: gabriell nascimento <gabriellhrn (a) gmail com>
# Desde: 2013-04-15
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzdicantonimos ()
{

	zzzz -h dicantonimos "$1" && return

	local url='http://www.antonimos.com.br/busca.php'
	local palavra="$*"
	local palavra_busca=$( echo "$palavra" | sed "$ZZSEDURL" )

	# Verifica se recebeu parâmetros
	if test -z "$1"
	then
		zztool -e uso dicantonimos
		return 1
	fi

	# Faz a busca do termo no site, deixando somente os antônimos
	zztool dump "${url}?q=${palavra_busca}" |
		sed -n "/[0-9]\{1,\} antônimos\{0,1\} d/,/«/ {
			/[0-9]\{1,\} antônimos\{0,1\} d/d
			/«/d
			/^$/d
			s/^ *//
			s/^[0-9]*\. //
			s/,//g
			s/\.$//
			p
		}" |
		awk '/:/ {printf (NR>1?"\n\n":"") $0 "\n"; next}; NF==0 {print ""}; {printf " " $0}' |
		zztool nl_eof
}

# ----------------------------------------------------------------------------
# zzdicasl
# http://www.dicas-l.unicamp.br
# Procura por dicas sobre determinado assunto na lista Dicas-L.
# Obs.: As opções do grep podem ser usadas (-i já é padrão).
# Uso: zzdicasl [opção-grep] palavra(s)
# Ex.: zzdicasl ssh
#      zzdicasl -w vi
#      zzdicasl -vEw 'windows|unix|emacs'
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2001-08-08
# Versão: 2
# Licença: GPL
# Requisitos: zzutf8
# ----------------------------------------------------------------------------
zzdicasl ()
{
	zzzz -h dicasl "$1" && return

	local opcao_grep
	local url='http://www.dicas-l.com.br/arquivo/'

	# Guarda as opções para o grep (caso informadas)
	test -n "${1##-*}" || {
		opcao_grep=$1
		shift
	}

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso dicasl; return 1; }

	# Faz a consulta e filtra o resultado
	zztool eco "$url"
	zztool source "$url" |
		zzutf8 |
		grep -i $opcao_grep "$*" |
		sed -n 's@^<LI><A HREF=/arquivo/\([^>]*\)> *\([^ ].*\)</A>@\1@p'
}

# ----------------------------------------------------------------------------
# zzdicbabylon
# http://www.babylon.com
# Tradução de uma palavra em inglês para vários idiomas.
# Francês, alemão, italiano, hebreu, espanhol, holandês e português.
# Se nenhum idioma for informado, o padrão é o português.
# Uso: zzdicbabylon [idioma] palavra   #idiomas: nl fr de he it pt es
# Ex.: zzdicbabylon hardcore
#      zzdicbabylon he tree
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzdicbabylon ()
{
	zzzz -h dicbabylon "$1" && return

	local idioma='pt'
	local idiomas=' nl fr de he it pt es '
	local tab=$(printf %b '\t')

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso dicbabylon; return 1; }

	# O primeiro argumento é um idioma?
	if test "${idiomas% $1 *}" != "$idiomas"
	then
		idioma=$1
		shift
	fi

	zztool source "http://bis.babylon.com/?rt=ol&tid=pop&mr=2&term=$1&tl=$idioma" |
		sed '
			/OT_CopyrightStyle/,$ d
			/div class="definition"/,/<\/div>/!d
			s/^[$tab ]*//
			s/<[^>]*>//g
			/^$/d
			N;s/\n/ /
			s/<[^>]*>//g
			s/^ *//
			s/ *$//
			s/      / /
			' |
		zztool texto_em_utf8
}

# ----------------------------------------------------------------------------
# zzdicesperanto
# http://glosbe.com
# Dicionário de Esperanto em inglês, português e alemão.
# Possui busca por palavra nas duas direções. O padrão é português-esperanto.
#
# Uso: zzdicesperanto [-d pt|en|de|eo] [-p pt|en|de|eo] palavra
# Ex.: zzdicesperanto esperança
#      zzdicesperanto -d en job
#      zzdicesperanto -d eo laboro
#      zzdicesperanto -p en trabalho
#
# Autor: Fernando Aires <fernandoaires (a) gmail com>
# Desde: 2005-05-20
# Versão: 5
# Licença: GPL
# Requisitos: zzurlencode
# ----------------------------------------------------------------------------
zzdicesperanto ()
{
	zzzz -h dicesperanto "$1" && return

	test -n "$1" || { zztool -e uso dicesperanto; return 1; }

	local de_ling='pt'
	local para_ling='eo'
	local url="https://glosbe.com"
	local pesquisa

	while test "${1#-}" != "$1"
	do
		case "$1" in
			-d)
				case "$2" in
					pt|en|de|eo)
						de_ling=$2
						shift

						if test $de_ling = "eo"
						then
							para_ling="pt"
						fi
					;;

					*)
						zztool erro "Lingua de origem não suportada"
						return 1
					;;
				esac
			;;

			-p)
				case "$2" in
					pt|en|de|eo)
						para_ling=$2
						shift
					;;

					*)
						zztool erro "Lingua de destino não suportada"
						return 2
					;;
				esac
			;;

			*)
				zztool erro "Parametro desconecido"
				return 3
			;;
		esac
		shift
	done

	pesquisa="$1"

	zztool source $(zzurlencode -n ':/' "$url/$de_ling/$para_ling/$pesquisa") |
		sed -n 's/.*class=" phr">\([^<]*\)<.*/\1/p'
}

# ----------------------------------------------------------------------------
# zzdicjargon
# http://catb.org/jargon/
# Dicionário de jargões de informática, em inglês.
# Uso: zzdicjargon palavra(s)
# Ex.: zzdicjargon vi
#      zzdicjargon all your base are belong to us
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Versão: 2
# Licença: GPL
# Requisitos: zztrim zzdividirtexto
# ----------------------------------------------------------------------------
zzdicjargon ()
{
	zzzz -h dicjargon "$1" && return

	local achei achei2 num mais
	local url='http://catb.org/jargon/html'
	local cache=$(zztool cache dicjargon)
	local padrao=$(echo "$*" | sed 's/ /-/g')

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso dicjargon; return 1; }

	# Se o cache está vazio, baixa listagem da Internet
	if ! test -s "$cache"
	then
		zztool list "$url/go01.html" |
			sed '
				#/^ *[0-9][0-9]*\. /!d
				s@.*/html/@@
				/^[A-Z0]\//!d' > "$cache"
	fi

	achei=$(grep -i "$padrao" $cache)
	num=$(echo "$achei" | zztool num_linhas)

	test -n "$achei" || return

	if test $num -gt 1
	then
		mais=$achei
		achei2=$(echo "$achei" | grep -w "$padrao" | sed 1q)
		test -n "$achei2" && achei="$achei2" && num=1
	fi

	if test $num -eq 1
	then
		zztool dump -w 500 "$url/$achei" |
			awk '
				$0  ~ /^$/  { branco++; if (branco == 3) { print "----------"; branco = 0 } }
				$0 !~ /^$/  { for (i=1;i<=branco;i++) { print "" }; print ; branco = 0 }
			' |
			sed '1,/[_-]\{9\}/d;/[_-]\{9\}/,$d;/^$/d' |
			zzdividirtexto 20 |
			zztrim -l
		test -n "$mais" && zztool eco '\nTermos parecidos:'
	else
		zztool eco 'Achei mais de um! Escolha qual vai querer:'
	fi

	test -n "$mais" && echo "$mais" | sed 's/..// ; s/\.html$//'
}

# ----------------------------------------------------------------------------
# zzdicportugues
# http://www.dicio.com.br
# Dicionário de português.
# Fornecendo uma "palavra" como argumento retorna seu significado e sinônimo.
# Se for seguida do termo "def", retorna suas definições.
#
# Uso: zzdicportugues palavra [def]
# Ex.: zzdicportugues bolacha
#      zzdicportugues comer def
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2003-02-26
# Versão: 11
# Licença: GPL
# Requisitos: zzsemacento zzminusculas zztrim
# ----------------------------------------------------------------------------
zzdicportugues ()
{
	zzzz -h dicportugues "$1" && return

	local url='http://dicio.com.br'
	local ini='^Significado de '
	local fim='^Definição de '
	local palavra=$(echo "$1" | zzminusculas)
	local padrao=$(echo "$palavra" | zzsemacento)
	local contador=1
	local resultado conteudo

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso dicportugues; return 1; }

	# Verificando se a palavra confere na pesquisa
	until test "$resultado" = "$palavra"
	do
		conteudo=$(zztool dump "$url/$padrao")
		resultado=$(
		echo "$conteudo" |
			sed -n "
			/^Significado de /{
				s/^Significado de //
				s/ *$//
				p
				}" |
			zzminusculas
			)
		test -n "$resultado" || { zztool erro "Palavra não encontrada"; return 1; }

		# Incrementando o contador no padrão
		padrao=$(echo "$padrao" | sed 's/_[0-9]*$//')
		contador=$((contador + 1))
		padrao=${padrao}_${contador}
	done

	if test "$2" = "def"
	then
		ini='^Definição de '; fim=' escrit[ao] ao contrário: '
	fi

	echo "$conteudo" |
		sed -n "
			/$ini/,/$fim/ {
				/$ini/d
				/^Definição de /d
				/^ *Exemplos com .*${palavra}$/,/^ *Outras informações sobre /d
				/^Sinônimos de /{N;d;}
				/Mais sinônimos /d
				/^Antônimos de /{N;d;}
				/Mais antônimos /d
				p
			}" |
		zztrim
}

# ----------------------------------------------------------------------------
# zzdicsinonimos
# http://www.sinonimos.com.br/
# Procura sinônimos para um termo.
# Uso: zzdicsinonimos termo
# Ex.: zzdicsinonimos deste modo
#
# Autor: gabriell nascimento <gabriellhrn (a) gmail com>
# Desde: 2013-04-15
# Versão: 3
# Licença: GPL
# Requisitos: zztrim
# ----------------------------------------------------------------------------
zzdicsinonimos ()
{

	zzzz -h dicsinonimos "$1" && return

	local url='http://www.sinonimos.com.br/busca.php'
	local palavra="$*"
	local parametro_busca=$( echo "$palavra" | sed "$ZZSEDURL" )

	# Verifica se recebeu parâmetros
	if test -z "$1"
	then
		zztool -e uso dicsinonimos
		return 1
	fi

	# Faz a busca do termo e limpa, deixando somente os sinônimos
	# O sed no final separa os sentidos, caso a palavra tenha mais de um
	zztool dump "${url}?q=${parametro_busca}" |
		sed -n "
			/[0-9]\{1,\} sinônimos\{0,1\} d/,/«/ {
				/[0-9]\{1,\} sinônimos\{0,1\} d/d
				/«/d
				/^$/d

				# Linhas em branco antes de Foo:
				/^ *[A-Z]/ { x;p;x; }

				p
			}" |
		zztrim
}

# ----------------------------------------------------------------------------
# zzdiffpalavra
# Mostra a diferença entre dois textos, palavra por palavra.
# Útil para conferir revisões ortográficas ou mudanças pequenas em frases.
# Obs.: Se tiver muitas *linhas* diferentes, use o comando diff.
# Uso: zzdiffpalavra arquivo1 arquivo2
# Ex.: zzdiffpalavra texto-orig.txt texto-novo.txt
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2001-07-23
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzdiffpalavra ()
{
	zzzz -h diffpalavra "$1" && return

	local esc tmp1 tmp2
	local n=$(printf '\a')

	# Verificação dos parâmetros
	test $# -ne 2 && { zztool -e uso diffpalavra; return 1; }

	# Verifica se os arquivos existem
	zztool -e arquivo_legivel "$1" || return 1
	zztool -e arquivo_legivel "$2" || return 1

	tmp1=$(zztool mktemp diffpalavra)
	tmp2=$(zztool mktemp diffpalavra)

	# Deixa uma palavra por linha e marca o início de parágrafos
	sed "s/^[[:blank:]]*$/$n$n/;" "$1" | tr ' ' '\n' > "$tmp1"
	sed "s/^[[:blank:]]*$/$n$n/;" "$2" | tr ' ' '\n' > "$tmp2"

	# Usa o diff para comparar as diferenças e formata a saída,
	# agrupando as palavras para facilitar a leitura do resultado
	diff -U 100 "$tmp1" "$tmp2" |
		sed 's/^ /=/' |
		sed '
			# Script para agrupar linhas consecutivas de um mesmo tipo.
			# O tipo da linha é o seu primeiro caractere. Ele não pode
			# ser um espaço em branco.
			#     +um
			#     +dois
			#     .one
			#     .two
			# vira:
			#     +um dois
			#     .one two

			# Apaga os cabeçalhos do diff
			1,3 d

			:join

			# Junta linhas consecutivas do mesmo tipo
			N

			# O espaço em branco é o separador
			s/\n/ /

			# A linha atual é do mesmo tipo da anterior?
			/^\(.\).* \1[^ ]*$/ {

				# Se for a última linha, mostra tudo e sai
				$ s/ ./ /g
				$ q

				# Caso contrário continua juntando...
				b join
			}
			# Opa, linha diferente (antiga \n antiga \n ... \n nova)

			# Salva uma cópia completa
			h

			# Apaga a última linha (nova) e mostra as anteriores
			s/\(.*\) [^ ]*$/\1/
			s/ ./ /g
			p

			# Volta a cópia, apaga linhas antigas e começa de novo
			g
			s/.* //
			$ !b join
			# Mas se for a última linha, acabamos por aqui' |
		sed 's/^=/ /' |

		# Restaura os parágrafos
		tr "$n" '\n' |

		# Podemos mostrar cores?
		if test "$ZZCOR" = 1
		then
			# Pinta as linhas antigas de vermelho e as novas de azul
			esc=$(printf '\033')
			sed "
				s/^-.*/$esc[31;1m&$esc[m/
				s/^+.*/$esc[36;1m&$esc[m/"
		else
			# Sem cores? Que chato. Só mostra então.
			cat -
		fi

	rm -f "$tmp1" "$tmp2"
}

# ----------------------------------------------------------------------------
# zzdistro
# Lista o ranking das distribuições no DistroWatch.
# Sem argumentos lista dos últimos 6 meses
# Se o argumento for 1, 3, 6 ou 12 é a ranking nos meses correspondente.
# Se o argumento for 2002 até o ano passado, é a ranking final desse ano.
# Se o primeiro argumento for -l, lista os links da distribuição no site.
#
# Uso: zzdistro [-l] [meses|ano]
# Ex.: zzdistro
#      zzdistro 2010  # Ranking em 2010
#      zzdistro 3     # Ranking dos últimos 3 meses.
#      zzdistro       # Ranking dos últimos 6 meses, com os links.
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2014-06-15
# Versão: 2
# Licença: GPL
# Requisitos: zzcolunar
# ----------------------------------------------------------------------------
zzdistro ()
{
	zzzz -h distro "$1" && return

	local url="http://distrowatch.com/"
	local lista=0
	local meses="1 4
3 13
6 26
12 52"

	test "$1" = "-l" && { lista=1; shift; }
	case $1 in
	1 | 3 | 6 | 12) url="${url}index.php?dataspan=$(echo "$meses" | awk '$1=='$1' {print $2}')"; shift ;;
	*)
	zztool testa_numero $1 && test $1 -ge 2002 -a $1 -lt $(date +%Y) && url="${url}index.php?dataspan=$1" && shift ;;
	esac

	test -n "$1" && { zztool -e uso distro; return 1; }

	zztool source "$url" | sed '1,/>Rank</d' |
	awk -F'"' '
		/phr1/ || /<th class="News">[0-9][0-9]?[0-9]?<\/th>/ {
			printf "%s\t", $3
			getline
			printf "%s\thttp://distrowatch.com/%s\n", $5, $4
		}
	' |
	sed 's/<[^>]*>//g;s/>//g' |
	if [ $lista -eq 1 ]
	then
		expand -t 4,18 | zzcolunar -w 60 2
	else
		sed 's/ *http.*//' | expand -t 4 | zzcolunar 4
	fi
}

# ----------------------------------------------------------------------------
# zzdividirtexto
# Divide um texto por uma quantidade máxima de palavras por linha.
# Sem argumento a quantidade padrão é 15
#
# Uso: zzdividirtexto [número]
# Ex.: zzdividirtexto 10
#      zzdividirtexto 3 Um texto para servir de exemplo no teste.
#      cat arquivo.txt | zzdividirtexto
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2016-04-12
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzdividirtexto ()
{
	zzzz -h dividirtexto "$1" && return

	local palavras=15

	# Definindo a quantidade de palavras por linha
	if zztool testa_numero "$1"
	then
		# Tamanho zero não vale!
		test "$1" -eq 0 && { zztool uso dividirtexto; return 1; }

		palavras=$1
		shift
	fi

	zztool multi_stdin "$@" |
		# O sed separa as palavras cujo delimitador seja espaço ou tabulação.
		# Obs.: ponto, dois-pontos, traço e vírgula não são considerados delimitadores.
		# Então palavra seguida desses caracteres sem espaço na palavra seguinte
		# são considerados uma única palavra.
		sed "s|\(\([^[:blank:]]\{1,\}[[:blank:]]\{1,\}\)\{${palavras}\}\)|\1\\
|g" |
		# O sed deixa o último separador de cada linha no final.
		# Usar a função trim eliminaria esse espaço que pode ser significativo.
		# Então o awk, move o espaço final de uma linha, para o começo da próxima.
		awk '{
			if ( length(incluir) > 0 )  { sub(/^/, incluir); incluir = "" }
			if ( match($0, /[ 	]+$/) ) {
				incluir = substr($0, RSTART, RLENGTH)
				sub(/[ 	]+$/, "")
			}
			print
		}'
}

# ----------------------------------------------------------------------------
# zzdivisores
# Lista todos os divisores de um número inteiro e positivo, maior que 2.
#
# Uso: zzdivisores <número>
# Ex.: zzdivisores 1400
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-25
# Versão: 6
# Licença: GPL
# ----------------------------------------------------------------------------
zzdivisores ()
{
	zzzz -h divisores "$1" && return

	test -n "$1" || { zztool -e uso divisores; return 1; }

	if zztool testa_numero "$1" && test $1 -ge 2
	then
		# Código adaptado a partir da solução em:
		# http://stackoverflow.com/questions/11699324/
		echo "$1" |
		awk '{
				limits = sqrt($1)
				for (i=1; i <= limits; i++) {
					if ($1 % i == 0) {
						print i
						ind = $1 / i
						if (i != ind ) print ind
					}
				}
		}' |
		sort -n |
		zztool lines2list | zztool nl_eof
	else
		# Se não for um número válido.
		zztool erro "Apenas números naturais maiores ou iguais a 2."
		return 1
	fi
}

# ----------------------------------------------------------------------------
# zzdolar
# http://economia.uol.com.br/cotacoes
# Busca a cotação do dia do dólar (comercial, turismo).
# Uso: zzdolar
# Ex.: zzdolar
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Versão: 7
# Licença: GPL
# ----------------------------------------------------------------------------
zzdolar ()
{
	zzzz -h dolar "$1" && return

	# Faz a consulta e filtra o resultado
	zztool dump 'http://economia.uol.com.br/cotacoes' |
		tr -s ' ' |
		egrep  'Dólar (com\.|tur\.|comercial)' |
		sed '
			# Linha original:
			# Dólar com. 2,6203 2,6212 -0,79%

			# faxina
			/Bovespa/d
			s/com\./Comercial/
			s/  *\(CAPTION: \)\{0,1\}Dólar comercial/  Compra Venda Variação/
			s/tur\./Turismo /
			s/^  *Dólar //
			s/[[:blank:]]*$//
			s/\(.*\) - \(.*\) \{0,1\}\([0-9][0-9]h[0-9][0-9]\)*/\2|\3\
\1/' |
		tr ' |' '\t '
}

# ----------------------------------------------------------------------------
# zzdominiopais
# http://www.ietf.org/timezones/data/iso3166.tab
# Busca a descrição de um código de país da internet (.br, .ca etc).
# Uso: zzdominiopais [.]código|texto
# Ex.: zzdominiopais .br
#      zzdominiopais br
#      zzdominiopais republic
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-05-15
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzdominiopais ()
{
	zzzz -h dominiopais "$1" && return

	local url='http://www.ietf.org/timezones/data/iso3166.tab'
	local cache=$(zztool cache dominiopais)
	local sistema='/usr/share/zoneinfo/iso3166.tab'
	local padrao=$1
	local arquivo

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso dominiopais; return 1; }

	# Se o padrão inicia com ponto, retira-o e casa somente códigos
	if test "${padrao#.}" != "$padrao"
	then
		padrao="^${padrao#.}"
	fi

	# Se já temos o arquivo de dados no sistema, tudo certo
	# Senão, baixa da internet
	if test -f "$sistema"
	then
		arquivo="$sistema"
	else
		arquivo="$cache"

		# Se o cache está vazio, baixa listagem da Internet
		if ! test -s "$cache"
		then
			zztool dump "$url" > "$cache"
		fi
	fi

	# O formato padrão de saída é BR - Brazil
	grep -i "$padrao" "$arquivo" |
		tr -s '\t ' ' ' |
		sed '/^#/d ; / - /! s/ / - /'
}

# ----------------------------------------------------------------------------
# zzdos2unix
# Converte arquivos texto no formato Windows/DOS (CR+LF) para o Unix (LF).
# Obs.: Também remove a permissão de execução do arquivo, caso presente.
# Uso: zzdos2unix arquivo(s)
# Ex.: zzdos2unix frases.txt
#      cat arquivo.txt | zzdos2unix
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzdos2unix ()
{
	zzzz -h dos2unix "$1" && return

	local arquivo tmp
	local control_m=$(printf '\r')  # ^M, CR, \r

	# Sem argumentos, lê/grava em STDIN/STDOUT
	if test $# -eq 0
	then
		sed "s/$control_m*$//"

		# Facinho, terminou já
		return
	fi

	# Definindo arquivo temporário quando há argumentos.
	tmp=$(zztool mktemp dos2unix)

	# Usuário passou uma lista de arquivos
	# Os arquivos serão sobrescritos, todo cuidado é pouco
	for arquivo
	do
		# O arquivo existe?
		zztool -e arquivo_legivel "$arquivo" || continue

		# Remove o \r
		cp "$arquivo" "$tmp" &&
		sed "s/$control_m*$//" "$tmp" > "$arquivo"

		# Segurança
		if test $? -ne 0
		then
			zztool erro "Ops, algum erro ocorreu em $arquivo"
			zztool erro "Seu arquivo original está guardado em $tmp"
			return 1
		fi

		# Remove a permissão de execução, comum em arquivos DOS
		chmod -x "$arquivo"

		echo "Convertido $arquivo"
	done

	# Remove o arquivo temporário
	rm -f "$tmp"
}

# ----------------------------------------------------------------------------
# zzecho
# Mostra textos coloridos, sublinhados e piscantes no terminal (códigos ANSI).
# Opções: -f, --fundo       escolhe a cor de fundo
#         -l, --letra       escolhe a cor da letra
#         -p, --pisca       texto piscante
#         -s, --sublinhado  texto sublinhado
#         -N, --negrito     texto em negrito (brilhante em alguns terminais)
#         -n, --nao-quebra  não quebra a linha no final, igual ao echo -n
# Cores: preto vermelho verde amarelo azul roxo ciano branco
# Obs.: \t, \n e amigos são sempre interpretados (igual ao echo -e).
# Uso: zzecho [-f cor] [-l cor] [-p] [-s] [-N] [-n] [texto]
# Ex.: zzecho -l amarelo Texto em amarelo
#      zzecho -f azul -l branco -N Texto branco em negrito, com fundo azul
#      zzecho -p -s Texto piscante e sublinhado
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-09-02
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzecho ()
{
	zzzz -h echo "$1" && return

	local letra fundo negrito cor pisca sublinhado
	local quebra_linha='\n'

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-l | --letra)
				case "$2" in
					# Permite versões femininas também (--letra preta)
					pret[oa]       ) letra=';30' ;;
					vermelh[oa]    ) letra=';31' ;;
					verde          ) letra=';32' ;;
					amarel[oa]     ) letra=';33' ;;
					azul           ) letra=';34' ;;
					rox[oa] | rosa ) letra=';35' ;;
					cian[oa]       ) letra=';36' ;;
					branc[oa]      ) letra=';37' ;;
					*) zztool -e uso echo; return 1 ;;
				esac
				shift
			;;
			-f | --fundo)
				case "$2" in
					preto       ) fundo='40' ;;
					vermelho    ) fundo='41' ;;
					verde       ) fundo='42' ;;
					amarelo     ) fundo='43' ;;
					azul        ) fundo='44' ;;
					roxo | rosa ) fundo='45' ;;
					ciano       ) fundo='46' ;;
					branco      ) fundo='47' ;;
					*) zztool -e uso echo; return 1 ;;
				esac
				shift
			;;
			-N | --negrito    ) negrito=';1'    ;;
			-p | --pisca      ) pisca=';5'      ;;
			-s | --sublinhado ) sublinhado=';4' ;;
			-n | --nao-quebra ) quebra_linha='' ;;
			*) break ;;
		esac
		shift
	done

	test -n "$1" || { zztool -e uso echo; return 1; }

	# Mostra códigos ANSI somente quando necessário (e quando ZZCOR estiver ligada)
	if test "$ZZCOR" != '1' -o "$fundo$letra$negrito$pisca$sublinhado" = ''
	then
		printf -- "$*$quebra_linha"
	else
		printf -- "\033[$fundo$letra$negrito$pisca${sublinhado}m$*\033[m$quebra_linha"
	fi
}

# ----------------------------------------------------------------------------
# zzencoding
# Informa qual a codificação de um arquivo (ou texto via STDIN).
#
# Uso: zzencoding [arquivo]
# Ex.: zzencoding /etc/passwd          # us-ascii
#      zzencoding index-iso.html       # iso-8859-1
#      echo FooBar | zzencoding        # us-ascii
#      echo Bênção | zzencoding        # utf-8
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2015-03-21
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzencoding ()
{
	zzzz -h encoding "$1" && return

	zztool file_stdin "$@" |
		# A opção --mime é portável, -i/-I não
		# O - pode não ser portável, mas /dev/stdin não funciona
		file -b --mime - |
		sed -n 's/.*charset=//p'
}

# ----------------------------------------------------------------------------
# zzenglish
# http://www.dict.org
# Busca definições em inglês de palavras da língua inglesa em DICT.org.
# Uso: zzenglish palavra-em-inglês
# Ex.: zzenglish momentum
#
# Autor: Luciano ES
# Desde: 2008-09-07
# Versão: 7
# Licença: GPL
# Requisitos: zztrim zzutf8 zzsqueeze
# ----------------------------------------------------------------------------
zzenglish ()
{
	zzzz -h english "$1" && return

	test -n "$1" || { zztool -e uso english; return 1; }

	local cinza verde amarelo fecha
	local url="http://www.dict.org/bin/Dict?Form=Dict2&Database=*&Query=$1"

	if test $ZZCOR -eq 1
	then
		cinza=$(  printf '\033[0;34m')
		verde=$(  printf '\033[0;32;1m')
		amarelo=$(printf '\033[0;33;1m')
		fecha=$(  printf '\033[m')
	fi

	zztool dump "$url" | zzutf8 |
		sed "
			/Questions or comments about this site./d

			# pega o trecho da página que nos interessa
			/[0-9]\{1,\} definitions\{0,1\} found/,/ *[_-][_-][_-][_-][_-]* *$/!d
			s/_____*//
			s/-----*//

			# protege os colchetes dos sinônimos contra o cinza escuro
			s/\[syn:/@SINONIMO@/g

			# aplica cinza escuro em todos os colchetes (menos sinônimos)
			s/\[/$cinza[/g

			# aplica verde nos colchetes dos sinônimos
			s/@SINONIMO@/$verde[syn:/g

			# 'fecha' as cores de todos os sinônimos
			s/\]/]$fecha/g

			# # pinta a pronúncia de amarelo - pode estar delimitada por \\ ou //
			s/\\\\[^\\]\{1,\}\\\\/$amarelo&$fecha/g
			s|/[^/]\{1,\}/|$amarelo&$fecha|g

			# cabeçalho para tornar a separação entre várias consultas mais visível no terminal
			/[0-9]\{1,\} definitions\{0,1\} found/ {
				H
				s/.*/==================== DICT.ORG ====================/
				p
				x
			}" |
		zztrim -V -r |
		zzsqueeze -l
}

# ----------------------------------------------------------------------------
# zzestado
# Lista os estados do Brasil e suas capitais.
# Obs.: Sem argumentos, mostra a lista completa.
#
# Opções: --sigla        Mostra somente as siglas
#         --nome         Mostra somente os nomes
#         --capital      Mostra somente as capitais
#         --slug         Mostra somente os slugs (nome simplificado)
#         --formato FMT  Você escolhe o formato de saída, use os tokens:
#                        {sigla}, {nome}, {capital}, {slug}, \n , \t
#         --python       Formata como listas/dicionários do Python
#         --javascript   Formata como arrays do JavaScript
#         --php          Formata como arrays do PHP
#         --html         Formata usando a tag <SELECT> do HTML
#         --xml          Formata como arquivo XML
#         --url,--url2   Exemplos simples de uso da opção --formato
#
# Uso: zzestado [opção]
# Ex.: zzestado                      # [mostra a lista completa]
#      zzestado --sigla              # AC AL AP AM BA …
#      zzestado --html               # <option value="AC">AC - Acre</option> …
#      zzestado --python             # siglas = ['AC', 'AL', 'AP', …
#      zzestado --formato '{sigla},'             # AC,AL,AP,AM,BA,…
#      zzestado --formato '{sigla} - {nome}\n'   # AC - Acre …
#      zzestado --formato '{capital}-{sigla}\n'  # Rio Branco-AC …
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2013-02-21
# Versão: 5
# Licença: GPL
# Requisitos: zzpad
# ----------------------------------------------------------------------------
zzestado ()
{
	zzzz -h estado "$1" && return

	local sigla nome slug capital fmt resultado

	# {sigla}:{nome}:{slug}:{capital}
	local dados="\
AC:Acre:acre:Rio Branco
AL:Alagoas:alagoas:Maceió
AP:Amapá:amapa:Macapá
AM:Amazonas:amazonas:Manaus
BA:Bahia:bahia:Salvador
CE:Ceará:ceara:Fortaleza
DF:Distrito Federal:distrito-federal:Brasília
ES:Espírito Santo:espirito-santo:Vitória
GO:Goiás:goias:Goiânia
MA:Maranhão:maranhao:São Luís
MT:Mato Grosso:mato-grosso:Cuiabá
MS:Mato Grosso do Sul:mato-grosso-do-sul:Campo Grande
MG:Minas Gerais:minas-gerais:Belo Horizonte
PA:Pará:para:Belém
PB:Paraíba:paraiba:João Pessoa
PR:Paraná:parana:Curitiba
PE:Pernambuco:pernambuco:Recife
PI:Piauí:piaui:Teresina
RJ:Rio de Janeiro:rio-de-janeiro:Rio de Janeiro
RN:Rio Grande do Norte:rio-grande-do-norte:Natal
RS:Rio Grande do Sul:rio-grande-do-sul:Porto Alegre
RO:Rondônia:rondonia:Porto Velho
RR:Roraima:roraima:Boa Vista
SC:Santa Catarina:santa-catarina:Florianópolis
SP:São Paulo:sao-paulo:São Paulo
SE:Sergipe:sergipe:Aracaju
TO:Tocantins:tocantins:Palmas"


	case "$1" in
		--sigla  ) echo "$dados" | cut -d : -f 1 ;;
		--nome   ) echo "$dados" | cut -d : -f 2 ;;
		--slug   ) echo "$dados" | cut -d : -f 3 ;;
		--capital) echo "$dados" | cut -d : -f 4 ;;

		--formato)
			fmt="$2"
			echo "$dados" |
				while IFS=':' read sigla nome slug capital
				do
					resultado=$(printf %s "$fmt" | sed "
						s/{sigla}/$sigla/g
						s/{nome}/$nome/g
						s/{slug}/$slug/g
						s/{capital}/$capital/g
					")
					printf "$resultado"
				done
		;;
		--python | --py)
			sigla=$(  zzestado --formato "'{sigla}', "   | sed 's/, $//')
			nome=$(   zzestado --formato "'{nome}', "    | sed 's/, $//')
			capital=$(zzestado --formato "'{capital}', " | sed 's/, $//')

			printf   'siglas = [%s]\n\n' "$sigla"
			printf    'nomes = [%s]\n\n' "$nome"
			printf 'capitais = [%s]\n\n' "$capital"

			echo 'estados = {'
			zzestado --formato "  '{sigla}': '{nome}',\n"
			echo '}'
			echo
			echo 'estados = {'
			zzestado --formato "  '{sigla}': ('{nome}', '{capital}', '{slug}'),\n"
			echo '}'
		;;
		--php)
			sigla=$(  zzestado --formato '"{sigla}", '   | sed 's/, $//')
			nome=$(   zzestado --formato '"{nome}", '    | sed 's/, $//')
			capital=$(zzestado --formato '"{capital}", ' | sed 's/, $//')

			printf   '$siglas = array(%s);\n\n' "$sigla"
			printf    '$nomes = array(%s);\n\n' "$nome"
			printf '$capitais = array(%s);\n\n' "$capital"

			echo '$estados = array('
			zzestado --formato '  "{sigla}" => "{nome}",\n'
			echo ');'
			echo
			echo '$estados = array('
			zzestado --formato '  "{sigla}" => array("{nome}", "{capital}", "{slug}"),\n'
			echo ');'
		;;
		--javascript | --js)
			sigla=$(  zzestado --formato "'{sigla}', "   | sed 's/, $//')
			nome=$(   zzestado --formato "'{nome}', "    | sed 's/, $//')
			capital=$(zzestado --formato "'{capital}', " | sed 's/, $//')

			printf   'var siglas = [%s];\n\n' "$sigla"
			printf    'var nomes = [%s];\n\n' "$nome"
			printf 'var capitais = [%s];\n\n' "$capital"

			echo 'var estados = {'
			zzestado --formato "  {sigla}: '{nome}',\n" | sed '$ s/,$//'
			echo '};'
			echo
			echo 'var estados = {'
			zzestado --formato "  {sigla}: ['{nome}', '{capital}', '{slug}'],\n" | sed '$ s/,$//'
			echo '}'
		;;
		--html)
			echo '<select>'
			zzestado --formato '  <option value="{sigla}">{sigla} - {nome}</option>\n'
			echo '</select>'
		;;
		--xml)
			echo '<estados>'
			zzestado --formato '\t<uf sigla="{sigla}">\n\t\t<nome>{nome}</nome>\n\t\t<capital>{capital}</capital>\n\t\t<slug>{slug}</slug>\n\t</uf>\n'
			echo '</estados>'
		;;
		--url)
			zzestado --formato 'http://foo.{sigla}.gov.br\n' | tr '[A-Z]' '[a-z]'
		;;
		--url2)
			zzestado --formato 'http://foo.com.br/{slug}/\n'
		;;
		*)
			echo "$dados" |
				while IFS=':' read sigla nome slug capital
				do
					echo "$sigla    $(zzpad 22 $nome) $capital"
				done
		;;
	esac
}

# ----------------------------------------------------------------------------
# zzexcuse
# Da uma desculpa comum de desenvolvedor ( em ingles ).
# Com a opção -t ou --traduzir mostra as desculpas traduzidas.
#
# Uso: zzexcuse [-t|--traduzir]
# Ex.: zzexcuse
#
# Autor: Italo Gonçales, @goncalesi, <italo.goncales (a) gmail com>
# Desde: 2015-09-26
# Versão: 2
# Licença: GPL
# Requisitos: zztrim zztradutor
# ----------------------------------------------------------------------------
zzexcuse ()
{
	zzzz -h excuse "$1" && return

	local url='http://programmingexcuses.com/'

	zztool dump "$url" |
	sed '$d;/Link: /d' |
	zztrim |
	case $1 in
	-t | --traduzir ) zztradutor en-pt ;;
	*) cat - ;;
	esac
}

# ----------------------------------------------------------------------------
# zzextensao
# Informa a extensão de um arquivo.
# Obs.: Caso o arquivo não possua extensão, retorna vazio "".
# Uso: zzextensao arquivo
# Ex.: zzextensao /tmp/arquivo.txt       # resulta em "txt"
#      zzextensao /tmp/arquivo           # resulta em ""
#
# Autor: Lauro Cavalcanti de Sa <lauro (a) ecdesa com>
# Desde: 2009-09-21
# Versão: 3
# Licença: GPLv2
# ----------------------------------------------------------------------------
zzextensao ()
{
	zzzz -h extensao "$1" && return

	# Declara variaveis.
	local nome_arquivo extensao arquivo

	test -n "$1" || { zztool -e uso extensao; return 1; }


	arquivo="$1"

	# Extrai a extensao.
	nome_arquivo=`echo "$arquivo" | awk 'BEGIN { FS = "/" } END { print $NF }'`
	extensao=`echo "$nome_arquivo" | awk 'BEGIN { FS = "." } END { print $NF }'`
	if test "$extensao" = "$nome_arquivo" -o ".$extensao" = "$nome_arquivo" ; then
		extensao=""
	fi

	test -n "$extensao" && echo "$extensao"
}

# ----------------------------------------------------------------------------
# zzfatorar
# Fatora um número em fatores primos.
# Com as opções:
#   --bc: saída apenas da expressão, que pode ser usado no bc, awk ou etc.
#   --no-bc: saída apenas do fatoramento.
#    por padrão exibe tanto o fatoramento como a expressão.
#
# Se o número for primo, é exibido a mensagem apenas.
#
# Uso: zzfatorar [--bc | --no-bc] <número>
# Ex.: zzfatorar 1458
#      zzfatorar --bc 1296
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-14
# Versão: 4
# Licença: GPL
# Requisitos: zzjuntalinhas zzdivisores
# Nota: opcional factor
# ----------------------------------------------------------------------------
zzfatorar ()
{
	zzzz -h fatorar "$1" && return

	local cache=$(zztool cache fatorar)
	local linha_atual=1
	local primo_atual=2
	local bc=0
	local num_atual saida tamanho indice linha

	test -n "$1" || { zztool -e uso fatorar; return 1; }

	while  test "${1#-}" != "$1"
	do
		case "$1" in
		--bc)
			# Apenas sai a expressão matemática que pode ser usado no bc ou awk
			test "$bc" -eq 0 && bc=1
			shift
		;;
		--no-bc)
			# Apenas sai a fatoração
			test "$bc" -eq 0 && bc=2
			shift
		;;
		*) break;;
		esac
	done

	# Apenas para numeros inteiros
	if zztool testa_numero "$1" && test $1 -ge 2
	then

		if which factor >/dev/null 2>&1
		then
			# Se existe o camando factor usa-o
			factor $1 | sed 's/.*: //g' | awk '{for(i=1;i<=NF;i++) print $i }' | uniq > "$cache"
		else
			# Aqui lista todos os divisores do número informado não considerando o 1
			# E descobre entre os divisores, quem é primo usando zzdivisores novamente.
			# Aqueles que tiverem apenas 2 divisores (primos) são mantidos, além do próprio número.
			zzdivisores $1 |
			tr ' ' '\n' |
			sed '1d; $!{ /.\{1,\}[024568]$/d; }' |
			while read linha
			do
				zzdivisores $linha | awk 'NF==2 {print $2}'
			done > "$cache"
		fi
		primo_atual=$(head -n 1 "$cache")

		# Se o número fornecido for primo, retorna-o e sai
		grep "^${1}$" ${cache} > /dev/null
		test "$?" = "0" && { echo "$1 é um número primo."; return; }

		num_atual="$1"
		tamanho=${#1}

		# Enquanto a resultado for maior que o número primo continua, ou dentro dos primos listados no cache.
		while test ${num_atual} -gt ${primo_atual} -a ${linha_atual} -le $(zztool num_linhas "$cache")
		do

			# Repetindo a divisão pelo número primo atual, enquanto for exato
			# e ecoando a fatoração formatada
			while test $((${num_atual} % ${primo_atual})) -eq 0
			do
				test "$bc" != "1" && printf "%${tamanho}s | %s\n" ${num_atual} ${primo_atual}
				num_atual=$((${num_atual} / ${primo_atual}))
				saida="${saida} ${primo_atual}"
				test "$bc" != "1" -a "${num_atual}" = "1" && { printf "%${tamanho}s |\n" 1; break; }
			done

			# Se o número atual é primo finaliza a fatoração
			# ecoando os 2 últimos elementos
			grep "^${num_atual}$" ${cache} > /dev/null
			if test "$?" = "0"
			then
				saida="${saida} ${num_atual}"
				if test "$bc" != "1"
				then
					printf "%${tamanho}s | %s\n" ${num_atual} ${num_atual}
					printf "%${tamanho}s |\n" 1
				fi
				break
			fi

			# Definindo o próximo número primo a ser usado
			if test "${num_atual}" != "1"
			then
				linha_atual=$((${linha_atual} + 1))
				primo_atual=$(sed -n "${linha_atual}p" "$cache")
				test ${#primo_atual} -eq 0 && { zztool erro "Valor não fatorável nessa configuração do script!"; return 1; }
			fi
		done

		if test "$bc" != "2"
		then
			# Formatando a fórmula ao final da fatoração
			saida=$(
				echo "$saida " |
				tr ' ' '\n' |
				sed '/^ *$/d;s/^ *//g' |
				uniq -c |
				awk '{ if ($1==1) {print $2} else {print $2 "^" $1} }' |
				zzjuntalinhas -d ' * '
			)
			test "$bc" -eq "1" || echo
			echo "$1 = $saida"
		fi
	fi

	# Limpeza
	rm -f "$cache"
}

# ----------------------------------------------------------------------------
# zzfeed
# Leitor de Feeds RSS, RDF e Atom.
# Se informar a URL de um feed, são mostradas suas últimas notícias.
# Se informar a URL de um site, mostra a URL do(s) Feed(s).
#
# Opções:
#  -n para limitar o número de resultados (Padrão é 10).
#  -u para simular navegador Mozilla/Firefox (alguns sites precisam disso).
#
# Para uso via pipe digite dessa forma: "zzfeed -", mesma forma que o cat.
#
# Uso: zzfeed [-n número] URL...
# Ex.: zzfeed http://aurelio.net/feed/
#      zzfeed -n 5 aurelio.net/feed/          # O http:// é opcional
#      zzfeed aurelio.net funcoeszz.net       # Mostra URL dos feeds
#      zzfeed -u funcoeszz.net                # UserAgent do lynx diferente
#      cat arquivo.rss | zzfeed -             # Para uso via pipe
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-03
# Versão: 11
# Licença: GPL
# Requisitos: zzxml zzunescape zztrim zzutf8
# ----------------------------------------------------------------------------
zzfeed ()
{
	zzzz -h feed "$1" && return

	local url formato tag_mae tmp useragent cache
	local limite=10

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
		-n) limite=$2; shift ;;
		-u) useragent='-u "Mozilla/5.0"' ;;
		* ) break ;;
		esac
		shift
	done

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso feed; return 1; }

	# Verificação básica
	if ! zztool testa_numero "$limite"
	then
		zztool erro "Número inválido para a opção -n: $limite"
		return 1
	fi

	# Zero notícias? Tudo bem.
	test $limite -eq 0 && return 0

	#-----------------------------------------------------------------
	# ATOM:
	# <?xml version="1.0" encoding="utf-8"?>
	# <feed xmlns="http://www.w3.org/2005/Atom">
	#     <title>Example Feed</title>
	#     <subtitle>A subtitle.</subtitle>
	#     <link href="http://example.org/" />
	#     ...
	#     <entry>
	#         <title>Atom-Powered Robots Run Amok</title>
	#         <link href="http://example.org/2003/12/13/atom03" />
	#         ...
	#     </entry>
	# </feed>
	#-----------------------------------------------------------------
	# RSS:
	# <?xml version="1.0" encoding="UTF-8" ?>
	# <rss version="2.0">
	# <channel>
	#     <title>RSS Title</title>
	#     <description>This is an example of an RSS feed</description>
	#     <link>http://www.someexamplerssdomain.com/main.html</link>
	#     ...
	#     <item>
	#         <title>Example entry</title>
	#         <link>http://www.wikipedia.org/</link>
	#         ...
	#     </item>
	# </channel>
	# </rss>
	#-----------------------------------------------------------------

	tmp=$(zztool mktemp feed)
	cache=$(zztool mktemp feed)

	# Para cada URL que o usuário informou...
	for url
	do
		# Só mostra a url se houver mais de uma
		test $# -gt 1 && zztool eco "* $url"

		# Baixa e limpa o conteúdo do feed
		if test "$1" = "-"
		then
			cat - | zzutf8 | zzxml --tidy > "$tmp"
		else
			zztool download $useragent "$url" "$cache"
			zzutf8 "$cache" | zzxml --tidy > "$tmp"
		fi

		# Tenta identificar o formato: <feed> é Atom, <rss> é RSS
		formato=$(grep -e '^<feed[ >]' -e '^<rss[ >]' -e '^<rdf[:>]' "$tmp")

		# Afinal, isso é um feed ou não?
		if test -n "$formato"
		then
			### É um feed, vamos mostrar as últimas notícias.
			# Atom ou RSS, as manchetes estão sempre na tag <title>,
			# que por sua vez está dentro de <item> ou <entry>.

			if zztool grep_var '<feed' "$formato"
			then
				tag_mae='entry'
			else
				tag_mae='item'
			fi

			# Extrai as tags <title> e formata o resultado
			zzxml --tag $tag_mae "$tmp" |
				zzxml --tag title --untag |
				sed "$limite q" |
				zzunescape --html |
				zztrim
		else
			### Não é um feed, pode ser um site normal.
			# Vamos tentar descobrir o endereço do(s) Feed(s).
			# <link rel="alternate" type="application/rss+xml" href="http://...">

			cat "$tmp" |
				grep -i \
					-e '^<link .*application/rss+xml' \
					-e '^<link .*application/rdf+xml' \
					-e '^<link .*application/atom+xml' |
				# Se não tiver href= não vale (o site do Terra é um exemplo)
				grep -i 'href=' |
				# Extrai a URL, apagando o que tem ao redor
				sed "
					s/.*[Hh][Rr][Ee][Ff]=//
					s/[ >].*//
					s/['\"]//g"
		fi

		# Linha em branco para separar resultados
		[ $# -gt 1 ] && echo
	done
	rm -f "$tmp" "$cache"
}

# ----------------------------------------------------------------------------
# zzferiado
# Verifica se a data passada por parâmetro é um feriado ou não.
# Caso não seja passado nenhuma data é pego a data atual.
# Pode-se configurar a variável ZZFERIADO para os feriados regionais.
# O formato é o dd/mm:descrição, por exemplo: 20/11:Consciência negra.
# Uso: zzferiado -l [ano] | [data]
# Ex.: zzferiado 25/12/2008
#      zzferiado -l
#      zzferiado -l 2010
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-11-21
# Versão: 6
# Licença: GPLv2
# Requisitos: zzcarnaval zzcorpuschristi zzdiadasemana zzsextapaixao zzsemacento
# Tags: data
# ----------------------------------------------------------------------------
zzferiado ()
{
	zzzz -h feriado "$1" && return

	local feriados carnaval corpuschristi
	local hoje data sextapaixao ano listar
	local dia diasemana descricao linha

	hoje=$(date '+%d/%m/%Y')

	# Verifica se foi passado o parâmetro -l
	if test "$1" = "-l"; then
		# Se não for passado $2 pega o ano atual
		ano=${2:-$(basename $hoje)}

		# Seta a flag listar
		listar=1

		# Teste da variável ano
		zztool -e testa_ano $ano || return 1
	else
		# Se não for passada a data é pega a data de hoje
		data=${1:-$hoje}

		# Verifica se a data é valida
		zztool -e testa_data "$data" || return 1

		# Uma coisa interessante, como data pode ser usada com /(20/11/2008)
		# podemos usar o basename e dirname para pegar o que quisermos
		# Ex.: dirname 25/12/2008 ->  25/12
		#      basename 25/12/2008 -> 2008
		#
		# Pega só o dia e o mes no formato: dd/mm
		data=$(dirname $data)
		ano=$(basename ${1:-$hoje})
	fi

	# Para feriados Estaduais ou regionais Existe a variável de
	# ambiente ZZFERIADO que pode ser configurada no $HOME/.bashrc e
	# colocar as datas com dd/mm:descricao
	carnaval=$(dirname $(zzcarnaval $ano ) )
	sextapaixao=$(dirname $(zzsextapaixao $ano ) )
	corpuschristi=$(dirname $(zzcorpuschristi $ano ) )
	feriados="01/01:Confraternização Universal $carnaval:Carnaval $sextapaixao:Sexta-feira da Paixao 21/04:Tiradentes 01/05:Dia do Trabalho $corpuschristi:Corpus Christi 07/09:Independência do Brasil 12/10:Nossa Sra. Aparecida 02/11:Finados 15/11:Proclamação da República 25/12:Natal $ZZFERIADO"

	# Verifica se lista ou nao, caso negativo verifica se a data escolhida é feriado
	if test "$listar" = "1"; then

		# Pega os dados, coloca 1 por linha, inverte dd/mm para mm/dd,
		# ordena, inverte mm/dd para dd/mm
		echo $feriados |
		sed 's# \([0-3]\)#~\1#g' |
		tr '~' '\n' |
		sed 's#^\(..\)/\(..\)#\2/\1#g' |
		sort -n |
		sed 's#^\(..\)/\(..\)#\2/\1#g' |
		while read linha; do
			dia=$(echo $linha | cut -d: -f1)
			diasemana=$(zzdiadasemana $dia/$ano | zzsemacento)
			descricao=$(echo $linha | cut -d: -f2)
			printf "%s %-15s %s\n" "$dia" "$diasemana" "$descricao" |
				sed 's/terca-feira/terça-feira/ ; s/ sabado / sábado /'
			# ^ Estou tirando os acentos do dia da semana e depois recolocando
			# pois o printf não lida direito com acentos. O %-15s não fica
			# exatamente com 15 caracteres quando há acentos.
		done
	else
		# Verifica se a data está dentro da lista de feriados
		# e imprime o resultado
		if zztool grep_var "$data" "$feriados"; then
			echo "É feriado: $data/$ano"
		else
			echo "Não é feriado: $data/$ano"
		fi
	fi

	return 0
}

# ----------------------------------------------------------------------------
# zzfoneletra
# Conversão de telefones contendo letras para apenas números.
# Uso: zzfoneletra telefone
# Ex.: zzfoneletra 2345-LINUX              # Retorna 2345-54689
#      echo 5555-HELP | zzfoneletra        # Retorna 5555-4357
#
# Autor: Rodolfo de Faria <rodolfo faria (a) fujifilm com br>
# Desde: 2006-10-17
# Versão: 1
# Licença: GPL
# Requisitos: zzmaiusculas
# ----------------------------------------------------------------------------
zzfoneletra ()
{
	zzzz -h foneletra "$1" && return

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |
		zzmaiusculas |
		sed y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/22233344455566677778889999/
		# Um Sed faz tudo, é uma tradução letra a letra
}

# ----------------------------------------------------------------------------
# zzfrenteverso2pdf
# Combina 2 arquivos, frentes.pdf e versos.pdf, em um único frenteverso.pdf.
# Opções:
#   -rf, --frentesreversas  informa ordem reversa no arquivo frentes.pdf.
#   -rv, --versosreversos   informa ordem reversa no arquivo versos.pdf.
#    -d, --diretorio        informa o diretório de entrada/saída. Padrão=".".
#    -v, --verbose          exibe informações de debug durante a execução.
# Uso: zzfrenteverso2pdf [-rf] [-rv] [-d diretorio]
# Ex.: zzfrenteverso2pdf
#      zzfrenteverso2pdf -rf
#      zzfrenteverso2pdf -rv -d "/tmp/dir_teste"
#
# Autor: Lauro Cavalcanti de Sa <laurocdesa (a) gmail com>
# Desde: 2009-09-17
# Versão: 4
# Licença: GPLv2
# Nota: requer pdftk
# ----------------------------------------------------------------------------
zzfrenteverso2pdf ()
{
	zzzz -h frenteverso2pdf "$1" && return

	# Declara variaveis.
	local n_frentes n_versos dif n_pag_frente n_pag_verso
	local sinal_frente="+"
	local sinal_verso="+"
	local dir="."
	local arq_frentes="frentes.pdf"
	local arq_versos="versos.pdf"
	local ini_frente=0
	local ini_verso=0
	local numberlist=""
	local n_pag=1

	# Determina o diretorio que estao os arquivos a serem mesclados.
	# Opcoes de linha de comando
	while test $# -ge 1
	do
		case "$1" in
			-rf | --frentesreversas) sinal_frente="-" ;;
			-rv | --versosreversos) sinal_verso="-" ;;
			-d | --diretorio)
				test -n "$2" || { zztool -e uso frenteverso2pdf; return 1; }
				dir=$2
				shift
				;;
			-v | --verbose)
				set -x
				;;
			--) shift; break ;;
			*) { zztool -e uso frenteverso2pdf; set +x; return 1; } ;;
		esac
		shift
	done

	# Verifica se os arquivos existem.
	if test ! -s "$dir/$arq_frentes" -o ! -s "$dir/$arq_versos" ; then
		zztool erro "ERRO: Um dos arquivos $dir/$arq_frentes ou $dir/$arq_versos nao existe!"
		return 1
	fi

	# Verifica se pdftk existe.
	if ! [ -x "$(command -v pdftk)" ]; then
		zztool erro "ERRO: pdftk nao esta instalado!"
		return 2
	fi

	# Determina o numero de paginas de cada arquivo.
	n_frentes=`pdftk "$dir/$arq_frentes" dump_data | grep "NumberOfPages" | cut -d" " -f2`
	n_versos=`pdftk "$dir/$arq_versos" dump_data | grep "NumberOfPages" | cut -d" " -f2`

	# Verifica a compatibilidade do numero de paginas entre os dois arquivos.
	dif=`expr $n_frentes - $n_versos`
	if test $dif -lt 0 -o $dif -gt 1 ; then
		echo "CUIDADO: O numero de paginas dos arquivos nao parecem compativeis!"
	fi

	# Cria ordenacao das paginas.
	if test "$sinal_frente" = "-" ; then
		ini_frente=`expr $n_frentes + 1`
	fi
	if test "$sinal_verso" = "-" ; then
		ini_verso=`expr $n_versos + 1`
	fi

	while test $n_pag -le $n_frentes ; do
		n_pag_frente=`expr $ini_frente $sinal_frente $n_pag`
		numberlist="$numberlist A$n_pag_frente"
		n_pag_verso=`expr $ini_verso $sinal_verso $n_pag`
		if test $n_pag -le $n_versos; then
			numberlist="$numberlist B$n_pag_verso"
		fi
		n_pag=$(($n_pag + 1))
	done

	# Cria arquivo mesclado.
	pdftk A="$dir/$arq_frentes" B="$dir/$arq_versos" cat $numberlist output "$dir/frenteverso.pdf" dont_ask

}

# ----------------------------------------------------------------------------
# zzfutebol
# http://esporte.uol.com.br/futebol/agenda-de-jogos
# Mostra todos os jogos de futebol marcados para os próximos dias.
# Ou os resultados de jogos recentes.
# Além de mostrar os times que jogam, o script também mostra o dia,
# o horário e por qual campeonato será ou foi o jogo.
#
# Suporta um argumento que pode ser um dos dias da semana, como:
#  hoje, amanhã, segunda, terça, quarta, quinta, sexta, sábado, domingo.
#
# Ou um ou dois argumentos para ver resultados do jogos:
#   resultado ou placar, que pode ser acompanhado de hoje, ontem, anteontem.
#
# Nos casos dos dias, podem ser usadas datas no formato DD/MM/AAAA.
#
# Um filtro com nome do campeonato, nome do time, ou horário de uma partida.
#
# Uso: zzfutebol [resultado | placar ] [ argumento ]
# Ex.: zzfutebol                 # Todas as partidas nos próximos dias.
#      zzfutebol hoje            # Partidas que acontecem hoje.
#      zzfutebol sabado          # Partidas que acontecem no sábado.
#      zzfutebol libertadores    # Próximas partidas da Libertadores.
#      zzfutebol 21h             # Partidas que começam entre 21 e 22h.
#      zzfutebol resultado       # Placar dos jogos já ocorridos.
#      zzfutebol placar ontem    # Placar dos jogos de ontem.
#      zzfutebol placar espanhol # Placar dos jogos do Campeonato Espanhol.
#
# Autor: Jefferson Fausto Vaz (www.faustovaz.com)
# Desde: 2014-04-08
# Versão: 10
# Licença: GPL
# Requisitos: zzcut zzdatafmt zzjuntalinhas zzpad zztrim zzxml
# ----------------------------------------------------------------------------
zzfutebol ()
{

	zzzz -h futebol "$1" && return
	local url="http://esporte.uol.com.br/futebol/central-de-jogos"
	local pagina='proximos-jogos'
	local linha campeonato time1 time2

	case "$1" in
		resultado | placar) pagina='resultados'; shift;;
		ontem | anteontem)  pagina='resultados';;
	esac

	zztool source "${url}/${pagina}" |
	zzxml --tidy |
	zzjuntalinhas -i 'td class="league"' -f '</td>' |
	if test "$pagina" = 'proximos-jogos'
	then
		sed -n '/class="league"/p;/<span class="\(data\|hora\)">/,/<\/span>/p;;/<meta itemprop="\(name\|location\)"/{/content=""/d;s/">//;s/.*"//;p;}'
	else
		sed -n '/class="league"/p;/<span class="\(data\|hora\)">/,/<\/span>/p;/abbr title=/{s/">//;s/.*"//;p;};/<label class="gols">/,/label>/p'
	fi |
	zzxml --untag |
	zztrim |
	awk -v pag="$pagina" '
		BEGIN { lim = (pag=="resultados"?7:4) }
		/[0-3][0-9]\// {printf $0; for(i=1;i<lim;i++){getline;printf ":" $0};print ""}
	' |
	case "$1" in
		hoje | amanh[aã] | segunda | ter[cç]a | quarta | quinta | sexta | s[aá]bado | domingo | ontem | anteontem | [0-3][0-9]/[01][0-9]/20[1-9][0-9])
			grep --color=never -e $(zzdatafmt -f 'DD/MM/AA' $1)
			;;
		*)
			grep --color=never -i "${1:-.}"
			;;
	esac |
	while read linha
	do
		campeonato=$(echo $linha | zzcut -d : -D ' ' -f1-3)
		if test "$pagina" = 'proximos-jogos'
		then
			time1=$(echo $linha | zzcut -d : -f 4 | zzcut -d ' x ' -f 1)
			time2=$(echo $linha | zzcut -d : -f 4 | zzcut -d ' x ' -f 2)
		else
			time1=$(echo $linha | zzcut -d : -f 5,4 -D ' ')
			time2=$(echo $linha | zzcut -d : -f 6,7 -D ' ')
		fi
		echo "$(zzpad -r 45 $campeonato) $(zzpad -l 25 $time1) x $time2"
	done
}

# ----------------------------------------------------------------------------
# zzgeoip
# Localiza geograficamente seu IP de Internet ou um que seja informado.
# Uso: zzgeoip [ip]
# Ex.: zzgeoip
#      zzgeoip 187.75.22.192
#
# Autor: Alexandre Magno <alexandre.mbm (a) gmail com>
# Desde: 2013-07-06
# Versão: 3
# Licença: GPLv2
# Requisitos: zzxml zzipinternet zzecho zzminiurl zztestar
# ----------------------------------------------------------------------------
zzgeoip ()
{
	zzzz -h geoip "$1" && return

	local ip pagina latitude longintude cidade uf pais mapa
	local url='http://geoip.s12.com.br'

	if test $# -ge 2
	then
		zztool -e uso geoip
		return 1
	elif test -n "$1"
	then
		zztestar -e ip "$1"
		test $? -ne 0 && zztool -e uso geoip && return 1
		ip="$1"
	else
		ip=$(zzipinternet)
	fi

	pagina=$(
		zztool source http://geoip.s12.com.br?ip=$ip |
			zzxml --tidy --untag --tag td |
			sed '/^[[:blank:]]*$/d;/&/d' |
			awk '{if ($0 ~ /:/) { printf "\n%s",$0 } else printf $0}'
	)

	cidade=$(   echo "$pagina" | grep 'Cidade:'    | cut -d : -f 2         )
	uf=$(       echo "$pagina" | grep 'Estado:'    | cut -d : -f 2         )
	pais=$(     echo "$pagina" | grep 'País:'      | cut -d : -f 2         )
	latitude=$( echo "$pagina" | grep 'Latitude:'  | cut -d : -f 2 | tr , .)
	longitude=$(echo "$pagina" | grep 'Longitude:' | cut -d : -f 2 | tr , .)

	mapa=$(zzminiurl "$url/mapa.asp?lat=$latitude&lon=$longitude&cidade=$cidade&estado=$uf")

	zzecho -n '       IP: '; zzecho -l verde -N "${ip:- }"
	zzecho -n '   Cidade: '; zzecho -N "${cidade:- }"
	zzecho -n '   Estado: '; zzecho -N "${uf:- }"
	zzecho -n '     País: '; zzecho -N "${pais:- }"
	zzecho -n ' Latitude: '; zzecho -l amarelo "${latitude:- }"
	zzecho -n 'Longitude: '; zzecho -l amarelo "${longitude:- }"
	zzecho -n '     Mapa: '; zzecho -l azul "${mapa:- }"
}

# ----------------------------------------------------------------------------
# zzglobo
# Mostra a programação da Rede Globo do dia.
# Uso: zzglobo
# Ex.: zzglobo
#
# Autor: Vinícius Venâncio Leite <vv.leite (a) gmail com>
# Desde: 2017-11-29
# Versão: 8
# Licença: GPL
# Requisitos: zztrim
# ----------------------------------------------------------------------------
zzglobo ()
{
		zzzz -h globo "$1" && return

		local url="http://redeglobo.globo.com/programacao.html"

		zztool dump -i utf-8 "$url" |
				sed '/^$/d' |
				sed -n '/\(Seg\|Ter\|Qua\|Qui\|Sex\|Sab\|Dom\),/p' |
				zztrim
		echo
		zztool dump -i utf-8 "$url" |
				sed '/^$/d' |
				sed 'H;/[0-9][0-9]:[0-9][0-9]/{g;N;s/^\n//p;}; x;s/.*\(\(\n[^\n]*\)\{1\}\)/\1/;x ;d' |
				sed '/No ar/d' |
				sed 's/ *\([0-9][0-9]:[0-9][0-9]\)/\1\:/' |
				sed 'N;s/:\n/: /' |
				zztrim
}

# ----------------------------------------------------------------------------
# zzgravatar
# http://www.gravatar.com
# Monta a URL completa para o Gravatar do email informado.
#
# Opções: -t, --tamanho N      Tamanho do avatar (padrão 80, máx 512)
#         -d, --default TIPO   Tipo do avatar substituto, se não encontrado
#
# Se não houver um avatar para o email, a opção --default informa que tipo
# de avatar substituto será usado em seu lugar:
#     mm          Mistery Man, a silhueta de uma pessoa (não muda)
#     identicon   Padrão geométrico, muda conforme o email
#     monsterid   Monstros, muda cores e rostos
#     wavatar     Rostos, muda características e cores
#     retro       Rostos pixelados, tipo videogame antigo 8-bits
# Veja exemplos em http://gravatar.com/site/implement/images/
#
# Uso: zzgravatar [--tamanho N] [--default tipo] email
# Ex.: zzgravatar fulano@dominio.com.br
#      zzgravatar -t 128 -d mm fulano@dominio.com.br
#      zzgravatar --tamanho 256 --default retro fulano@dominio.com.br
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-06
# Versão: 1
# Licença: GPL
# Requisitos: zzmd5 zzminusculas zztrim
# ----------------------------------------------------------------------------
zzgravatar ()
{
	zzzz -h gravatar "$1" && return

	# Instruções de implementação:
	# http://gravatar.com/site/implement/
	#
	# Exemplo de URL do Gravatar, com tamanho de 96 e MisteryMan:
	# http://www.gravatar.com/avatar/e583bca48acb877efd4a29229bf7927f?size=96&default=mm

	local email default extra codigo
	local tamanho=80  # padrão caso não informado é 80
	local tamanho_maximo=512
	local defaults="mm:identicon:monsterid:wavatar:retro"
	local url='http://www.gravatar.com/avatar/'

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-t | --tamanho)
				tamanho="$2"
				extra="$extra&size=$tamanho"
				shift
				shift
			;;
			-d | --default)
				default="$2"
				extra="$extra&default=$default"
				shift
				shift
			;;
			*)
				break
			;;
		esac
	done

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso gravatar; return 1; }

	# Guarda o email informado, sempre em minúsculas
	email=$(zztrim "$1" | zzminusculas)

	# Foi passado um número mesmo?
	if ! zztool testa_numero "$tamanho" || test "$tamanho" = 0
	then
		zztool erro "Número inválido para a opção -t: $tamanho"
		return 1
	fi

	# Temos uma limitação de tamanho
	if test $tamanho -gt $tamanho_maximo
	then
		zztool erro "O tamanho máximo para a imagem é $tamanho_maximo"
		return 1
	fi

	# O default informado é válido?
	if test -n "$default" && ! zztool grep_var ":$default:"  ":$defaults:"
	then
		zztool erro "Valor inválido para a opção -d: '$default'"
		return 1
	fi

	# Calcula o hash do email
	codigo=$(printf "$email" | zzmd5)

	# Verifica o hash e o coloca na URL
	if test -n "$codigo"
	then
		url="$url$codigo"
	else
		zztool erro "Houve um erro na geração do código MD5 do email"
		return 1
	fi

	# Adiciona as opções extras na URL
	if test -n "$extra"
	then
		url="$url?${extra#&}"
	fi

	# Tá feito, essa é a URL final
	echo "$url"
}

# ----------------------------------------------------------------------------
# zzhexa2str
# Converte os bytes em hexadecimal para a string equivalente.
# Uso: zzhexa2str [bytes]
# Ex.: zzhexa2str 40 4d 65 6e 74 65 42 69 6e 61 72 69 61   # sem prefixo
#      zzhexa2str 0x42 0x69 0x6E                           # com prefixo 0x
#      echo 0x42 0x69 0x6E | zzhexa2str
#
# Autor: Fernando Mercês <fernando (a) mentebinaria.com.br>
# Desde: 2012-02-24
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzhexa2str ()
{
	zzzz -h hexa2str "$1" && return

	local hexa

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |

		# Um hexa por linha
		tr -s '\t ' '\n' |

		# Remove o prefixo opcional
		sed 's/^0x//' |

		# hexa -> str
		while read hexa
		do
			printf "\\x$hexa"
		done

	# Quebra de linha final
	echo
}

# ----------------------------------------------------------------------------
# zzhoracerta
# http://www.worldtimeserver.com
# Mostra a hora certa de um determinado local.
# Se nenhum parâmetro for passado, são listados as localidades disponíveis.
# O parâmetro pode ser tanto a sigla quando o nome da localidade.
# A opção -s realiza a busca somente na sigla.
# Uso: zzhoracerta [-s] local
# Ex.: zzhoracerta rio grande do sul
#      zzhoracerta -s br
#      zzhoracerta rio
#      zzhoracerta us-ny
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2004-03-29
# Versão: 4
# Licença: GPL
# ----------------------------------------------------------------------------
zzhoracerta ()
{
	zzzz -h horacerta "$1" && return

	local codigo localidade localidades
	local cache=$(zztool cache horacerta)
	local url='http://www.worldtimeserver.com'

	# Opções de linha de comando
	if test "$1" = '-s'
	then
		shift
		codigo="$1"
	else
		localidade="$*"
	fi

	# Se o cache está vazio, baixa listagem da Internet
	# De: <li><a href="current_time_in_AR-JY.aspx">Jujuy</a></li>
	# Para: AR-JY -- Jujuy
	if ! test -s "$cache"
	then
		zztool source "$url/country.html" |
			grep 'current_time_in_' |
			sed 's/.*_time_in_// ; s/\.aspx">/ -- / ; s/<.*//' > "$cache"
	fi

	# Se nenhum parâmetro for passado, são listados os países disponíveis
	if ! test -n "$localidade$codigo"
	then
		cat "$cache"
		return
	fi

	# Faz a pesquisa por codigo ou texto
	if test -n "$codigo"
	then
		localidades=$(grep -i "^[^ ]*$codigo" "$cache")
	else
		localidades=$(grep -i "$localidade" "$cache")
	fi

	# Se mais de uma localidade for encontrada, mostre-as
	if test $(echo "$localidades" | zztool num_linhas) != 1
	then
		echo "$localidades"
		return
	fi

	# A localidade existe?
	if ! test -n "$localidades"
	then
		zztool erro "Localidade \"$localidade$codigo\" não encontrada"
		return 1
	fi

	# Grava o código da localidade (BR-RS -- Rio Grande do Sul -> BR-RS)
	localidade=$(echo "$localidades" | sed 's/ .*//')

	# Faz a consulta e filtra o resultado
	zztool dump "$url/current_time_in_$localidade.aspx" |
		sed -n '/Current Time in /,/Daylight Saving Time:/{
			s/Current Time in //
			/[?:]$/d
			/^ *$/d
			s/^ *//
			p
		}'
}

# ----------------------------------------------------------------------------
# zzhoramin
# Converte horas em minutos.
# Obs.: Se não informada a hora, usa o horário atual para o cálculo.
# Uso: zzhoramin [hh:mm]
# Ex.: zzhoramin
#      zzhoramin 10:53       # Retorna 653
#      zzhoramin -10:53      # Retorna -653
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-12-05
# Versão: 4
# Licença: GPLv2
# Requisitos: zzhora zztestar
# ----------------------------------------------------------------------------
zzhoramin ()
{

	zzzz -h horamin "$1" && return

	local mintotal hh mm hora operacao

	operacao='+'

	# Testa se o parâmetro passado é uma hora valida
	if ! zztestar hora "${1#-}"; then
		hora=$(zzhora agora | cut -d ' ' -f 1)
	else
		hora="$1"
	fi

	# Verifica se a hora é positiva ou negativa
	if test "${hora#-}" != "$hora"; then
		operacao='-'
	fi

	# passa a hora para hh e minuto para mm
	hh="${hora%%:*}"
	mm="${hora##*:}"

	# Retira o zero das horas e minutos menores que 10
	hh="${hh#0}"
	mm="${mm#0}"

	# Se tiver algo faltando, salva como zero
	hh="${hh:-0}"
	mm="${mm:-0}"

	# faz o cálculo
	mintotal=$(($hh * 60 $operacao $mm))

	# Tcharã!!!!
	echo "$mintotal"
}

# ----------------------------------------------------------------------------
# zzhorariodeverao
# Mostra as datas de início e fim do horário de verão.
# Obs.: Ano de 2008 em diante. Se o ano não for informado, usa o atual.
# Regra: 3º domingo de outubro/fevereiro, exceto carnaval (4º domingo).
# Uso: zzhorariodeverao [ano]
# Ex.: zzhorariodeverao
#      zzhorariodeverao 2009
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-10-24
# Versão: 1
# Licença: GPL
# Requisitos: zzcarnaval zzdata zzdiadasemana
# Tags: data
# ----------------------------------------------------------------------------
zzhorariodeverao ()
{
	zzzz -h horariodeverao "$1" && return

	local inicio fim data domingo_carnaval
	local dias_3a_semana="15 16 17 18 19 20 21"
	local ano="$1"

	# Se o ano não for informado, usa o atual
	test -z "$ano" && ano=$(date +%Y)

	# Validação
	zztool -e testa_ano "$ano" || return 1

	# Só de 2008 em diante...
	if test "$ano" -lt 2008
	then
		zztool erro 'Antes de 2008 não havia regra fixa para o horário de verão'
		return 1
	fi

	# Encontra os dias de início e término do horário de verão.
	# Sei que o algoritmo não é eficiente, mas é simples de entender.
	#
	for dia in $dias_3a_semana
	do
		data="$dia/10/$ano"
		test $(zzdiadasemana $data) = 'domingo' && inicio="$data"

		data="$dia/02/$((ano+1))"
		test $(zzdiadasemana $data) = 'domingo' && fim="$data"
	done

	# Exceção à regra: Se o domingo de término do horário de verão
	# coincidir com o Carnaval, adia o término para o próximo domingo.
	#
	domingo_carnaval=$(zzdata $(zzcarnaval $((ano+1)) ) - 2)
	test "$fim" = "$domingo_carnaval" && fim=$(zzdata $fim + 7)

	# Datas calculadas, basta mostrar o resultado
	echo "$inicio"
	echo "$fim"
}

# ----------------------------------------------------------------------------
# zzhora
# Faz cálculos com horários.
# A opção -r torna o cálculo relativo à primeira data, por exemplo:
#   02:00 - 03:30 = -01:30 (sem -r) e 22:30 (com -r)
#
# Uso: zzhora [-r] hh:mm [+|- hh:mm] ...
# Ex.: zzhora 8:30 + 17:25        # preciso somar dois horários
#      zzhora 12:00 - agora       # quando falta para o almoço?
#      zzhora -12:00 + -5:00      # horas negativas!
#      zzhora 1000                # quanto é 1000 minutos?
#      zzhora -r 5:30 - 8:00      # que horas ir dormir para acordar às 5:30?
#      zzhora -r agora + 57:00    # e daqui 57 horas, será quando?
#      zzhora 1:00 + 2:00 + 3:00 - 4:00 - 0:30   # cálculos múltiplos
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Versão: 5
# Licença: GPL
# ----------------------------------------------------------------------------
zzhora ()
{
	zzzz -h hora "$1" && return

	local hhmm1 hhmm2 operacao hhmm1_orig hhmm2_orig
	local hh1 mm1 hh2 mm2 n1 n2 resultado parcial exitcode negativo
	local horas minutos dias horas_do_dia hh mm hh_dia extra
	local relativo=0
	local neg1=0
	local neg2=0

	# Opções de linha de comando
	if test "$1" = '-r'
	then
		relativo=1
		shift
	fi

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso hora; return 1; }

	# Cálculos múltiplos? Exemplo: 1:00 + 2:00 + 3:00 - 4:00
	if test $# -gt 3
	then
		if test $relativo -eq 1
		then
			zztool erro "A opção -r não suporta cálculos múltiplos"
			return 1
		fi

		# A zzhora continua simples, suportando apenas dois números
		# e uma única operação entre eles. O que fiz para suportar
		# múltiplos, é chamar a própria zzhora várias vezes, a cada
		# número novo, usando o resultado do cálculo anterior.
		#
		# Início  : parcial = $1
		# Rodada 1: parcial = zzhora $parcial $2 $3
		# Rodada 2: parcial = zzhora $parcial $4 $5
		# Rodada 3: parcial = zzhora $parcial $6 $7
		# e assim vai.
		#
		parcial="$1"
		shift

		# Daqui pra frente é de dois em dois: operador (+-) e a hora.
		# Se tiver um número ímpar de argumentos, tem algo errado.
		#
		if test $(($# % 2)) -eq 1
		then
			zztool -e uso hora
			return 1
		fi

		# Agora sim, vamos fazer o loop e calcular todo mundo
		while test $# -ge 2
		do
			resultado=$(zzhora "$parcial" "$1" "$2")
			exitcode=$?

			# Salva somente o horário. Ex: 02:59 (0d 2h 59m)
			parcial=$(echo "$resultado" | cut -d ' ' -f 1)

			# Esses dois já foram. Venham os próximos!
			shift
			shift
		done

		# Loop terminou, então já temos o total final.
		# Basta mostrar e encerrar, saindo com o exitcode retornado
		# pela execução da última zzhora. Vai que deu erro?
		#
		if test $exitcode -ne 0
		then
			echo "$resultado"
		else
			zztool erro "$resultado"
		fi
		return $exitcode
	fi

	# Dados informados pelo usuário (com valores padrão)
	hhmm1="$1"
	operacao="${2:-+}"
	hhmm2="${3:-0}"
	hhmm1_orig="$hhmm1"
	hhmm2_orig="$hhmm2"

	# Somente adição e subtração são permitidas
	if test "$operacao" != '-' -a "$operacao" != '+'
	then
		zztool erro "Operação inválida '$operacao'. Deve ser + ou -."
		return 1
	fi

	# Remove possíveis sinais de negativo do início
	hhmm1="${hhmm1#-}"
	hhmm2="${hhmm2#-}"

	# Guarda a informação de quem era negativo no início
	test "$hhmm1" != "$hhmm1_orig" && neg1=1
	test "$hhmm2" != "$hhmm2_orig" && neg2=1

	# Atalhos bacanas para a hora atual
	test "$hhmm1" = 'agora' -o "$hhmm1" = 'now' && hhmm1=$(date +%H:%M)
	test "$hhmm2" = 'agora' -o "$hhmm2" = 'now' && hhmm2=$(date +%H:%M)

	# Se as horas não foram informadas, coloca zero
	test "${hhmm1#*:}" = "$hhmm1" && hhmm1="0:$hhmm1"
	test "${hhmm2#*:}" = "$hhmm2" && hhmm2="0:$hhmm2"

	# Extrai horas e minutos para variáveis separadas
	hh1="${hhmm1%:*}"
	mm1="${hhmm1#*:}"
	hh2="${hhmm2%:*}"
	mm2="${hhmm2#*:}"

	# Retira o zero das horas e minutos menores que 10
	hh1="${hh1#0}"
	mm1="${mm1#0}"
	hh2="${hh2#0}"
	mm2="${mm2#0}"

	# Se tiver algo faltando, salva como zero
	hh1="${hh1:-0}"
	mm1="${mm1:-0}"
	hh2="${hh2:-0}"
	mm2="${mm2:-0}"

	# Validação dos dados
	if ! (zztool testa_numero "$hh1" && zztool testa_numero "$mm1")
	then
		zztool erro "Horário inválido '$hhmm1_orig', deve ser HH:MM"
		return 1
	fi
	if ! (zztool testa_numero "$hh2" && zztool testa_numero "$mm2")
	then
		zztool erro "Horário inválido '$hhmm2_orig', deve ser HH:MM"
		return 1
	fi

	# Os cálculos são feitos utilizando apenas minutos.
	# Então é preciso converter as horas:minutos para somente minutos.
	n1=$((hh1*60 + mm1))
	n2=$((hh2*60 + mm2))

	# Restaura o sinal para as horas negativas
	test $neg1 -eq 1 && n1="-$n1"
	test $neg2 -eq 1 && n2="-$n2"

	# Tudo certo, hora de fazer o cálculo
	resultado=$(($n1 $operacao $n2))

	# Resultado negativo, seta a flag e remove o sinal de menos "-"
	if test $resultado -lt 0
	then
		negativo='-'
		resultado="${resultado#-}"
	fi

	# Agora é preciso converter o resultado para o formato hh:mm

	horas=$((resultado/60))
	minutos=$((resultado%60))
	dias=$((horas/24))
	horas_do_dia=$((horas%24))

	# Restaura o zero dos minutos/horas menores que 10
	hh="$horas"
	mm="$minutos"
	hh_dia="$horas_do_dia"
	test $hh -le 9 && hh="0$hh"
	test $mm -le 9 && mm="0$mm"
	test $hh_dia -le 9 && hh_dia="0$hh_dia"

	# Decide como mostrar o resultado para o usuário.
	#
	# Relativo:
	#   $ zzhora -r 10:00 + 48:00            $ zzhora -r 12:00 - 13:00
	#   10:00 (2 dias)                       23:00 (ontem)
	#
	# Normal:
	#   $ zzhora 10:00 + 48:00               $ zzhora 12:00 - 13:00
	#   58:00 (2d 10h 0m)                    -01:00 (0d 1h 0m)
	#
	if test $relativo -eq 1
	then

		# Relativo

		# Somente em resultados negativos o relativo é útil.
		# Para valores positivos não é preciso fazer nada.
		if test -n "$negativo"
		then
			# Para o resultado negativo é preciso refazer algumas contas
			minutos=$(( (60-minutos) % 60))
			dias=$((horas/24))
			hh_dia=$(( (24 - horas_do_dia - (minutos>0)) % 24))
			mm="$minutos"

			# Zeros para dias e minutos menores que 10
			test $mm -le 9 && mm="0$mm"
			test $hh_dia -le 9 && hh_dia="0$hh_dia"
		fi

		# "Hoje", "amanhã" e "ontem" são simpáticos no resultado
		case $negativo$dias in
			1)
				extra='amanhã'
			;;
			-1)
				test ${horas_do_dia} -ne 0 -o ${minutos} -ne 0 && extra='anteontem' || extra='ontem'
			;;
			-0)
				extra='ontem'
			;;
			0)
				extra='hoje'
			;;
			*)
				extra="$negativo$dias dias"
			;;
		esac

		echo "$hh_dia:$mm ($extra)"
	else

		# Normal

		echo "$negativo$hh:$mm (${dias}d ${horas_do_dia}h ${minutos}m)"
	fi
}

# ----------------------------------------------------------------------------
# zzhoroscopo
# http://m.horoscopovirtual.bol.uol.com.br/horoscopo/
# Consulta o horóscopo do dia.
# Deve ser informado o signo que se deseja obter a previsão.
#
# Signos: aquário, peixes, áries, touro, gêmeos, câncer, leão,
#         virgem, libra, escorpião, sagitário, capricórnio
#
# Uso: zzhoroscopo <signo>
# Ex.: zzhoroscopo sagitário    # exibe a previsão para o signo de sagitário
#
# Autor: Juliano Fernandes, http://julianofernandes.com.br
# Desde: 2016-05-07
# Versão: 1
# Licença: GPL
# Requisitos: zzsemacento zzminusculas zzxml
# ----------------------------------------------------------------------------
zzhoroscopo ()
{
	zzzz -h horoscopo "$1" && return

	# Verifica se o usuário informou um possível signo
	if test -z "$1"
	then
		zztool -e uso horoscopo
		return 1
	fi

	# Normaliza o signo para pacilitar sua busca
	local signo=$(zzsemacento "$1" | zzminusculas)

	# Lista de signos válidos
	local signos='aquario peixes aries touro gemeos cancer leao virgem libra escorpiao sagitario capricornio'

	# Se o signo informado pelo usuário for válido faz a consulta ao serviço
	if zztool grep_var $signo "$signos"
	then
		# Define as regras para remover tudo que não se refere ao signo desejado
		local remove_ini='s/^<article><p>//'
		local remove_fim='s/<\/p><\/article>.*$//'

		# Endereço do serviço de consulta do horóscopo
		local url="http://m.horoscopovirtual.bol.uol.com.br/horoscopo/$signo"

		# Faz a mágica acontecer
		zztool source -u 'Mozilla/5.0' "$url" |
			zzxml --tag 'article' |
			tr -ds '\t\n\r' ' ' |
			sed "$remove_ini;$remove_fim" |
			zzxml --untag |
			zztool nl_eof |
			awk '{sub(/$/,"\n",$2);gsub(/\. /,".\n ")};1'
	else
		return 1
	fi
}

# ----------------------------------------------------------------------------
# zzhowto
# http://www.ibiblio.org
# Procura documentos do tipo HOWTO.
# Uso: zzhowto [--atualiza] palavra
# Ex.: zzhowto apache
#      zzhowto --atualiza
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2002-08-27
# Versão: 3
# Licença: GPL
# Requisitos: zztrim zzxml
# ----------------------------------------------------------------------------
zzhowto ()
{
	zzzz -h howto "$1" && return

	local padrao
	local cache=$(zztool cache howto)
	local url='http://www.ibiblio.org/pub/Linux/docs/HOWTO/other-formats/html_single/'

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso howto; return 1; }

	# Força atualização da listagem apagando o cache
	if test "$1" = '--atualiza'
	then
		zztool atualiza howto
		shift
	fi

	padrao=$1

	# Se o cache está vazio, baixa listagem da Internet
	if ! test -s "$cache"
	then
		zztool source "$url" |
			zzxml --untag |
			zztrim |
			fgrep '.html' |
			sed 's/ [0-9][0-9]:.*//' > "$cache"
	fi

	# Pesquisa o termo (se especificado)
	if test -n "$padrao"
	then
		zztool eco "$url"
		grep -i "$padrao" "$cache"
	fi
}

# ----------------------------------------------------------------------------
# zzhsort
# Ordenar palavras ou números horizontalmente.
# Opções:
#   -r                              define o sentido da ordenação reversa.
#   -d <sep>                        define o separador de campos na entrada.
#   -D, --output-delimiter <sep>  define o separador de campos na saída.
#
# O separador na entrada pode ser 1 ou mais caracteres ou uma ER.
# Se não for declarado assume-se espaços em branco como separador.
# Conforme padrão do awk, o default seria FS = "[ \t]+".
#
# Se o separador de saída não for declarado, assume o mesmo da entrada.
# Caso a entrada também não seja declarada assume-se como um espaço.
# Conforme padrão do awk, o default é OFS = " ".
#
# Se o separador da entrada é uma ER, é bom declarar o separador de saída.
#
# Uso: zzhsort [-d <sep>] [-D | --output-delimiter <sep>] <Texto>
# Ex.: zzhsort "isso está desordenado"            # desordenado está isso
#      zzhsort -r -d ":" -D "-" "1:a:z:x:5:o"  # z-x-o-a-5-1
#      cat num.txt | zzhsort -d '[\t:]' --output-delimiter '\t'
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2015-10-07
# Versão: 2
# Licença: GPL
# Requisitos: zztranspor
# ----------------------------------------------------------------------------
zzhsort ()
{
	zzzz -h hsort "$1" && return

	local sep ofs direcao

	while test "${1#-}" != "$1"
	do
		case "$1" in
			-d)
			# Separador de campos na entrada
				sep="-d $2"
				shift
				shift
			;;
			-D | --output-delimiter)
			# Separador de campos na saída
				ofs="-D $2"
				shift
				shift
			;;
			-r)
			# Ordenar decrescente
				direcao="-r"
				shift
			;;
			--) shift; break;;
			-*) zztool -e uso hsort; return 1;;
			*) break;;
		esac
	done

	zztool multi_stdin "$@" |
	while read linha
	do
		if test -z "$linha"
		then
			echo
		else
			echo "$linha" |
			zztranspor $sep |
			sort -n $direcao |
			zztranspor $sep $ofs
		fi
	done
}

# ----------------------------------------------------------------------------
# zzimc
# Calcula o valor do IMC correspodente a sua estrutura corporal.
#
# Uso: zzimc <peso_em_KG> <altura_em_metros>
# Ex.: zzimc 108.5 1.73
#
# Autor: Rafael Araújo <rafaelaraujosilva (a) gmail com>
# Desde: 2015-10-30
# Versão: 1
# Licença: GPL
# Requisitos: zztestar
# ----------------------------------------------------------------------------
zzimc ()
{

	zzzz -h imc "$1" && return

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso imc; return 1; }
	test -n "$2" || { zztool -e uso imc; return 1; }

	local PESO=`echo "$1" | tr "," "."`
	local ALTURA=`echo "$2" | tr "," "."`

	if ! ( zztestar numero_real "$PESO" )
	then

		zztool erro "Valor inserido para o peso está inválido, favor verificar!"
		return 1
	fi

	if ! ( zztestar numero_real "$ALTURA" )
	then

		zztool erro "Valor inserido para a altura está inválido, favor verificar!"
		return 1
	fi

	echo "scale=2;$PESO / ( $ALTURA^2 )" | bc |
	awk '{
		if ($1 >= 40 ) {print "IMC: "$1" - OBESIDADE GRAU III"}
		if ($1 < 40 && $1 >= 35) {print "IMC: "$1" - OBESIDADE GRAU II"}
		if ($1 < 35 && $1 >= 30) {print "IMC: "$1" - OBESIDADE GRAU I"}
		if ($1 < 30 && $1 >= 25) {print "IMC: "$1" - PRE-OBESIDADE"}
		if ($1 < 25 && $1 >= 18.5) {print "IMC: "$1" - PESO ADEQUADO"}
		if ($1 < 18.5 && $1 >= 17) {print "IMC: "$1" - MAGREZA GRAU I"}
		if ($1 < 17 && $1 >= 16) {print "IMC: "$1" - MAGREZA GRAU II"}
		if ($1 < 16 ) {print "IMC: "$1" - MAGREZA GRAU III"}
	}'
}

# ----------------------------------------------------------------------------
# zziostat
# Monitora a utilização dos discos no Linux.
#
# Opções:
#   -n [número]    Quantidade de medições (padrão = 10; contínuo = 0)
#   -t [número]    Mostra apenas os discos mais utilizados
#   -i [segundos]  Intervalo em segundos entre as coletas
#   -d [discos]    Mostra apenas os discos que começam com a string passada
#                  O padrão é 'sd'
#   -o [trwT]      Ordena os discos por:
#                      t (tps)
#                      r (read/s)
#                      w (write/s)
#                      T (total/s = read/s+write/s)
#
# Obs.: Se não for usada a opção -t, é mostrada a soma da utilização
#       de todos os discos.
#
# Uso: zziostat [-t número] [-i segundos] [-d discos] [-o trwT]
# Ex.: zziostat
#      zziostat -n 15
#      zziostat -t 10
#      zziostat -i 5 -o T
#      zziostat -d emcpower
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2015-02-17
# Versão: 2
# Licença: GPL
# Nota: requer iostat
# ----------------------------------------------------------------------------
zziostat ()
{
	zzzz -h iostat "$1" && return

	which iostat 1>/dev/null 2>&1 || { zztool erro "iostat não instalado"; return 1; }

	local top line cycle tps reads writes totals
	local delay=2
	local orderby='t'
	local disk='sd'
	local iteration=10
	local i=0

	# Opcoes de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-n )
				shift
				iteration=$1
				zztool -e testa_numero $iteration || return 1
				test $iteration -eq 0 && unset iteration
				;;
			-t )
				shift
				top=$1
				zztool -e testa_numero $top || return 1
				;;
			-i )
				shift
				delay=$1
				zztool -e testa_numero $delay || return 1
				;;
			-d )
				shift
				disk=$1
				;;
			-o )
				shift
				orderby=$1
				if ! echo $orderby | grep -qs '^[rwtT]$'
				then
					zztool erro "Opção inválida '$orderby'"
					return 1
				fi
				;;
			* )
				zztool erro "Opção inválida $1"; return 1;;
		esac
		shift
	done

	# Coluna para ordenacao:
	# Device tps MB_read/s MB_wrtn/s MB_read MB_wrtn MB_total/s
	test "$orderby" = "t" && orderby=2
	test "$orderby" = "r" && orderby=3
	test "$orderby" = "w" && orderby=4
	test "$orderby" = "T" && orderby=7

	# Executa o iostat, le a saida e agrupa cada "ciclo de execucao"
	# -d device apenas, -m mostra saida em MB/s
	iostat -d -m $delay $iteration |
	while read line
	do

		# Ignorando o cabeçalho do iostat, localizado nas 2 linhas iniciais
		if test $i -lt 2
		then
			i=$((i + 1))
			continue
		fi

		# faz o append da linha do iostat
		if test -n "$line"
		then
			cycle="$cycle
$line"
		# se for line for vazio, terminou de ler o ciclo de saida do iostat
		# mostra a saida conforme opcoes usadas
		else
			if test -n "$top"
			then
				clear
				date '+%d/%m/%y - %H:%M:%S'
				echo 'Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn        MB_total/s'
				echo "$cycle" |
					sed -n "/^${disk}[a-zA-Z]\+[[:blank:]]/p" |
					awk '{print $0"         "$3+$4}' |
					sort -k $orderby -r -n |
					head -$top
			else
				cycle=$(echo "$cycle" | sed -n "/^${disk}[a-zA-Z]\+[[:blank:]]/p")
				tps=$(echo "$cycle" | awk '{ sum += $2 } END { print sum }')
				reads=$(echo "$cycle" | awk '{ sum += $3 } END { print sum }')
				writes=$(echo "$cycle" | awk '{ sum += $4 } END { print sum }')
				totals=$(echo $reads $writes | awk '{print $1+$2}')
				echo "$(date '+%d/%m/%y - %H:%M:%S') TPS = $tps; Read = $reads MB/s; Write = $writes MB/s ; Total = $totals MB/s"
			fi

			# zera ciclo
			cycle=''
		fi
	done
}

# ----------------------------------------------------------------------------
# zzipinternet
# Mostra o seu número IP (externo) na Internet.
# Uso: zzipinternet
# Ex.: zzipinternet
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2005-09-01
# Versão: 5
# Licença: GPL
# ----------------------------------------------------------------------------
zzipinternet ()
{
	zzzz -h ipinternet "$1" && return

	local url='http://ipaddress.com/'

	# O resultado já vem pronto!
	zztool dump "$url" | sed -n 's/.*Your IP .ddress is: //p'
}

# ----------------------------------------------------------------------------
# zzit
# Uma forma de ler o site Inovação Tecnológica.
# Sem opção mostra o resumo da página principal.
#
# Opções podem ser (ano)sub-temas e/ou número:
#
# Sub-temas podem ser:
#   eletronica, energia, espaco, informatica, materiais,
#   mecanica, meioambiente, nanotecnologia, robotica, plantao.
#  Que podem ser precedido do ano ao qual se quer listar
#
# Se a opção for um número mostra a matéria selecionada,
# seja da página principal ou de um sub-tema.
#
# Uso: zzit [[ano] sub-tema] [número]
# Ex.: zzit                 # Um resumo da página principal
#      zzit espaco          # Um resumo do sub-tem espaço
#      zzit 3               # Exibe a terceira matéria da página principal
#      zzit mecanica 7      # Exibe a sétima matéria do sub-tema mecânica
#      zzit 2003 energia    # Um resumo do sub-tema energia em 2003
#      zzit 2012 plantao 2  # Exibe a 2ª matéria de 2012 no sub-tema plantao
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2016-02-28
# Versão: 3
# Licença: GPL
# Requisitos: zzsemacento zzutf8 zzxml zzsqueeze zzdatafmt zzlinha
# ----------------------------------------------------------------------------
zzit ()
{

	zzzz -h it "$1" && return

	local url='http://www.inovacaotecnologica.com.br'
	local ano url2 opcao num

	if test -n "$1" && zztool testa_numero $1
	then
		if test "$1" -ge 2001 -a "$1" -le $(zzdatafmt -f AAAA hoje)
		then
			ano=$1
			shift
		fi
	fi

	opcao=$(echo "$1" | zzsemacento)
	case "$opcao" in
		eletronica | energia | espaco | informatica | materiais | mecanica | meioambiente | nanotecnologia | robotica | plantao )
			if test -n "$ano"
			then
				if test "$opcao" = "meioambiente" -a "$ano" -eq 2001
				then
					return
				fi
				url2="$url/noticias/${opcao}_${ano}.html"
			else
				url2="$url/noticias/assuntos.php?assunto=$opcao"
			fi
			shift ;;
		* )	url2="$url/index.php" ;;
	esac

	zztool testa_numero $1 && num=$1

	if test -n "$ano"
	then
		if test -z "$num"
		then
			zztool dump "$url2" |
			if test "$opcao" = "plantao"
			then
				sed -n '/^ *Plantão /,/- Arquivo/{ /^ *\*/!d; s/^ *\* *//; p; }'
			else
				sed -n '/^ *Notícias /,/- Arquivo/{ /^ *\*/!d; s/^ *\* *//; p; }'
			fi |
			awk '{ printf "%02d - %s\n", NR, $0 }'
		else
			url2=$(
			zztool source "$url2" | zzutf8 |
			sed -n '/Notícias /,/- Arquivo/{ /^<li>/!d; s/.*="//; s/".*//; p; }' |
			zzlinha $num
			)
			zztool eco "$url2"
			zztool dump "$url2" |
			sed '1,/^ *\* *Plantão$/d; s/ *\(Bibliografia:\)/\
\1/' |
			sed 's/\[INS: *:INS\]//g; /Outras notícias sobre:/{s///;q;}' |
			zzsqueeze | fmt -w 120
		fi
	else
		zztool source "$url2" |
		zzutf8 |
		awk '/<div id="manchete">/,/Leia mais/' |
		zzxml --untag=i --untag=u --untag=b --untag=img |
		zzxml --tag a |
		sed '/^<\/a>$/,/^<\/a>$/d;/^ *$/d;/assunto=/{N;d;}' |
		if test -z "$num"
		then
			awk 'NR % 2 == 0 { printf "%02d - %s\n", NR / 2 , $0 }'
		else
			url2=$(awk -v linha=$num 'NR == linha * 2 -1' | sed 's/">//;s/.*"//;s|\.\./||' | sed "s|^|${url}/|")
			zztool eco "$url2"
			zztool dump "$url2" |
			sed '1,/^ *\* *Plantão$/d; s/ *\(Bibliografia:\)/\
\1/' |
			sed 's/\[INS: *:INS\]//g; /Outras notícias sobre:/{s///;q;}' |
			zzsqueeze | fmt -w 120
		fi
	fi
}

# ----------------------------------------------------------------------------
# zzjoin
# Junta as linhas de 2 ou mais arquivos, mantendo a sequência.
# Opções:
#  -o <arquivo> - Define o arquivo de saída.
#  -m - Toma como base o arquivo com menos linhas.
#  -M - Toma como base o arquivo com mais linhas.
#  -<numero> - Toma como base o arquivo na posição especificada.
#  -d - Define o separador entre as linhas dos arquivos juntados (padrão TAB).
#
# Sem opção, toma como base o primeiro arquivo declarado.
#
# Uso: zzjoin [-m | -M | -<numero>] [-o <arq>] [-d <sep>] arq1 arq2 [arqN] ...
# Ex.: zzjoin -m arq1 arq2 arq3      # Base no arquivo com menos linhas
#      zzjoin -2 arq1 arq2 arq3      # Base no segundo arquivo
#      zzjoin -o out.txt arq1 arq2   # Juntando para o arquivo out.txt
#      zzjoin -d ":" arq1 arq2       # Juntando linhas separadas por ":"
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-12-05
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzjoin ()
{
	zzzz -h join "$1" && return

	local lin_arq arquivo arq_saida sep
	local linhas=0
	local tipo=1

	# Opção -m ou -M, -numero ou -o
	while test "${1#-}" != "$1"
	do
		if test "$1" = "-o"
		then
			arq_saida="$2"
			shift
		elif test "$1" = "-d"
		then
			sep="$2"
			shift
		else
			tipo="${1#-}"
		fi
		shift
	done

	test -n "$2" || { zztool -e uso join; return 1; }

	for arquivo
	do
		# Especificar se vai se orientar pelo arquivo com mais ou menos linhas
		if test "$tipo" = "m" || test "$tipo" = "M"
		then
			lin_arq=$(zztool num_linhas "$arquivo")
			if test "$tipo" = "M" && test $lin_arq -gt $linhas
			then
				linhas=$lin_arq
			fi
			if test "$tipo" = "m" && (test $lin_arq -lt $linhas || test $linhas -eq 0)
			then
				linhas=$lin_arq
			fi
		fi

		# Verifica se arquivos são legíveis
		zztool arquivo_legivel "$arquivo" || { zztool erro "Um ou mais arquivos inexistentes ou ilegíveis."; return 1; }
	done

	# Se opção é um numero, o arquivo base para as linhas é o mesmo da posição equivalente
	if zztool testa_numero $tipo && test $tipo -le $#
	then
		arquivo=$(awk -v arg=$tipo 'BEGIN { print ARGV[arg] }' $* 2>/dev/null)
		linhas=$(zztool num_linhas "$arquivo")
	fi

	# Sem quantidade de linhas mínima não há junção.
	test "$linhas" -eq 0 && { zztool erro "Não há linhas para serem \"juntadas\"."; return 1; }

	# Onde a "junção" ocorre efetivamente.
	awk -v linhas_awk=$linhas -v saida_awk="$arq_saida" -v sep_awk="$sep" '
	BEGIN {
		sep_awk = (length(sep_awk)>0 ? sep_awk : "	")

		for (i = 1; i <= linhas_awk; i++) {
			for(j = 1; j < ARGC; j++) {
				if ((getline linha < ARGV[j]) > 0) {
					if (j > 1)
						saida = saida sep_awk linha
					else
						saida = linha
				}
			}
			if (length(saida_awk)>0)
				print saida >> saida_awk
			else
				print saida

			saida = ""
		}
	}' $* 2>/dev/null
}

# ----------------------------------------------------------------------------
# zzjquery
# Exibe a descrição da função jQuery informada.
#
# Opções:
#   --categoria[s]: Lista as Categorias da funções.
#   --lista: Lista todas as funções.
#   --lista <categoria>: Listas as funções dentro da categoria informada.
#
# Caso não seja passado o nome, serão exibidas informações acerca do $().
# Se usado o argumento -s, será exibida somente a sintaxe.
# Uso: zzjquery [-s] função
# Ex.: zzjquery gt
#      zzjquery -s gt
#
# Autor: Felipe Nascimento Silva Pena <felipensp (a) gmail com>
# Desde: 2007-12-04
# Versão: 5
# Licença: GPL
# Requisitos: zzcapitalize zzlimpalixo zzunescape zzxml
# ----------------------------------------------------------------------------
zzjquery ()
{
	zzzz -h jquery "$1" && return

	local url="http://api.jquery.com/"
	local url_aux lista_cat
	local sintaxe=0

	case "$1" in
	--lista)

		if test -n "$2"
		then
			lista_cat=$(echo "$2" | zzcapitalize)
			test "$lista_cat" = "Css" && lista_cat="CSS"
			url_aux=$(
				zztool source "$url" |
				awk '/<aside/,/aside>/{print}' |
				sed "/<ul class='children'>/,/<\/ul>/d" |
				zzxml --untag=aside --tag a |
				awk -F '"' '/href/ {printf $2 " "; getline; print}' |
				awk '$2 ~ /'$lista_cat'/ { print $1 }'
			)
			test -n "$url_aux" && url="$url_aux" || url=''
		fi

		zztool grep_var 'http:' "$url" || url="http:$url"

		if test -n "$url"
		then
			zztool source "$url" |
			sed -n '/title="Permalink to /{s/^[[:blank:]]*//;s/<[^>]*>//g;s/()//;p;}' |
			zzunescape --html
		fi

	;;
	--categoria | --categorias)

		zztool source "$url" |
		awk '/<aside/,/aside>/{print}' |
		sed "/<ul class='children'>/,/<\/ul>/d" |
		zzxml --tag li --untag  | zzlimpalixo | zzunescape --html

	;;
	*)
		test "$1" = "-s" && { sintaxe=1; shift; }

		if test -n "$1"
		then
			url_aux=$(
				zztool source "$url" |
				sed -n '/title="Permalink to /{s/^[[:blank:]]*//;s/()//g;p;}' |
				zzunescape --html |
				awk -F '[<>"]' '{print "http:" $3, $9 }' |
				awk '$2 ~ /^[.:]?'$1'[^a-z]*$/ { print $1 }'
			)
			test -n "$url_aux" && url="$url_aux" || url=''
		else
			url="${url}jQuery/"
		fi

		if test -n "$url"
		then
			for url_aux in $url
			do
				zztool grep_var 'http://' "$url_aux" || url_aux="http://$url_aux"
				zztool eco ${url_aux#*com/} | tr -d '/'
				zztool source "$url_aux" |
				zzxml --tag article |
				awk '/class="entry(-content| method)"/,/<\/article>/{ print }' |
				if test "$sintaxe" = "1"
				then
					awk '/<ul class="signatures">/,/<div class="longdesc"/ { print }' |
					awk '/<span class="name">/,/<\/span>/ { print }; /<h4 class="name">/,/<\/h4>/ { print };'
				else
					awk '
							/<ul class="signatures">/,/(<div class="longdesc"|<section class="entry-examples")/ { if ($0 ~ /<\/h4>/ || $0 ~ /<\/span>/ || $0 ~ /<\/div>/) { print } else { printf $0 }}
							/<span class="name">/,/<\/span>/ { if ($0 ~ /<span class="name">/) { printf "--\n\n" }; print $0 }
							/<p class="desc"/,/<\/p>/ { if ($0 ~ /<\/p>/) { print } else { printf $0 }}
						'
				fi|
				zzxml --untag | zzlimpalixo |
				awk '{if ($0 ~ /: *$/) { printf $0; getline; print} else print }' |
				sed 's/version added: .*//;s/^--//g;/Type: /d'
				echo
			done
		fi

	;;
	esac
}

# ----------------------------------------------------------------------------
# zzjuntalinhas
# Junta várias linhas em uma só, podendo escolher o início, fim e separador.
#
# Melhorias em relação ao comando paste -s:
# - Trata corretamente arquivos no formato Windows (CR+LF)
# - Lê arquivos ISO-8859-1 sem erros no Mac (o paste dá o mesmo erro do tr)
# - O separador pode ser uma string, não está limitado a um caractere
# - Opções -i e -f para delimitar somente um trecho a ser juntado
#
# Opções: -d sep        Separador a ser colocado entre as linhas (padrão: Tab)
#         -i, --inicio  Início do trecho a ser juntado (número ou regex)
#         -f, --fim     Fim do trecho a ser juntado (número ou regex)
#
# Uso: zzjuntalinhas [-d separador] [-i texto] [-f texto] arquivo(s)
# Ex.: zzjuntalinhas arquivo.txt
#      zzjuntalinhas -d @@@ arquivo.txt             # junta toda as linhas
#      zzjuntalinhas -d : -i 10 -f 20 arquivo.txt   # junta linhas 10 a 20
#      zzjuntalinhas -d : -i 10 arquivo.txt         # junta linha 10 em diante
#      cat /etc/named.conf | zzjuntalinhas -d '' -i '^[a-z]' -f '^}'
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-02
# Versão: 3
# Licença: GPL
# Requisitos: zzdos2unix
# ----------------------------------------------------------------------------
zzjuntalinhas ()
{
	zzzz -h juntalinhas "$1" && return

	local separador=$(printf '\t')  # tab
	local inicio='1'
	local fim='$'

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-d           ) separador="$2"; shift; shift;;
			-i | --inicio) inicio="$2"   ; shift; shift;;
			-f | --fim   ) fim="$2"      ; shift; shift;;
			*) break ;;
		esac
	done

	# Formata dados para o sed
	inicio=$(zztool endereco_sed "$inicio")
	fim=$(zztool endereco_sed "$fim")
	separador=$(echo "$separador" | sed 's:/:\\\/:g')

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" |
		zzdos2unix |
		sed "
			# O algoritmo é simples: ao entrar no trecho escolhido ($inicio)
			# vai guardando as linhas. Quando chegar no fim do trecho ($fim)
			# faz a troca das quebras de linha pelo $separador.

			$inicio, $fim {
				H
				$fim {
					s/.*//
					x
					s/^\n//
					s/\n/$separador/g
					p
					d
				}

				# Exceção: Não achei $fim e estou na última linha.
				# Este trecho não será juntado.
				$ {
					x
					s/^\n//
					p
				}

				d
			}"
}

# ----------------------------------------------------------------------------
# zzlblank
# Elimina espaços excedentes no início, mantendo alinhamento.
# por padrão transforma todos os TABs em 4 espaços para uniformização.
# Um número como argumento especifica a quantidade de espaços para cada TAB.
# Caso use a opção -s, apenas espaços iniciais serão considerados.
# Caso use a opção -t, apenas TABs iniciais serão considerados.
#  Obs.: Com as opções -s e -t não há a conversão de tabs para espaço.
#
# Uso: zzlblank [-s|-t|<número>] arquivo.txt
# Ex.: zzlblank arq.txt     # Espaços e tabs iniciais
#      zzlblank -s arq.txt  # Apenas espaços iniciais
#      zzlblank -t arq.txt  # Apenas tabs iniciais
#      zzlblank 12 arq.txt  # Tabs são convertidos em 12 espaços
#      cat arq.txt | zzlblank
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2014-05-11
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzlblank ()
{
	zzzz -h lblank "$1" && return

	local tipo_blank=0
	local tab_spa=4

	while test "${1#-}" != "$1"
	do
		case "$1" in
			-s) tipo_blank=1; shift;;
			-t) tipo_blank=2; shift;;
			* ) break;;
		esac
	done

	if test -n $1
	then
		zztool testa_numero $1 && { tab_spa=$1; shift; }
	fi

	zztool file_stdin "$@" |
	awk -v tipo=$tipo_blank '
		function subs() {
			if (tipo == 2) { sub(/^\t*/, "", $0) }
			else { sub(/^ */, "", $0) }
		}

		BEGIN {
			for (i=1; i<='$tab_spa'; i++)
				espacos = espacos " "
		}

		{
			if ( tipo == 0 ) gsub(/\t/, espacos)
			linha[NR] = $0
			if ( length($0) > 0 ) {
				if ( length(qtde) == 0 ) {
					subs()
					qtde = length(linha[NR]) - length($0)
				}
				else {
					subs()
					qtde_temp = length(linha[NR]) - length($0)
					qtde = qtde <= qtde_temp ? qtde : qtde_temp
				}
			}
		}

		END {
			for (j=1; j<=NR; j++) {
				for (k=1; k<=qtde; k++) {
					if ( tipo == 2 )
						sub(/^\t/, "", linha[j])
					else
						sub(/^ /, "", linha[j])
				}
				print linha[j]
			}
		}
	'
}

# ----------------------------------------------------------------------------
# zzlembrete
# Sistema simples de lembretes: cria, apaga e mostra.
# Uso: zzlembrete [texto]|[número [d]]
# Ex.: zzlembrete                      # Mostra todos
#      zzlembrete 5                    # Mostra o 5º lembrete
#      zzlembrete 5d                   # Deleta o 5º lembrete
#      zzlembrete Almoço com a sogra   # Adiciona lembrete
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-10-22
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzlembrete ()
{
	zzzz -h lembrete "$1" && return

	local numero tmp
	local arquivo="${ZZTMPDIR:-$HOME}/.zzlembrete"

	# Assegura-se que o arquivo de lembretes existe
	test -f "$arquivo" || touch "$arquivo"

	# Sem argumentos, mostra todos os lembretes
	if test $# -eq 0
	then
		cat -n "$arquivo"

	# Tem argumentos, que podem ser para mostrar, apagar ou adicionar
	elif echo "$*" | tr -s '\t ' '  ' | grep '^ *[0-9]\{1,\} *d\{0,1\} *$' >/dev/null
	then
		# Extrai o número da linha
		numero=$(echo "$*" | tr -d -c 0123456789)

		# Se não for um número ou menor igual a zero sai com erro.
		zztool testa_numero "$numero" && test "$numero" -gt 0 || return 1

		if zztool grep_var d "$*"
		then
			# zzlembrete 5d: Apaga linha 5
			tmp=$(zztool mktemp lembrete)
			cp "$arquivo" "$tmp" &&
			sed "$numero d" "$tmp" > "$arquivo" || {
				zztool erro "Ops, deu algum erro no arquivo $arquivo"
				zztool erro "Uma cópia dele está em $tmp"
				return 1
			}
			rm -f "$tmp"
		else
			# zzlembrete 5: Mostra linha 5
			sed -n "$numero p" "$arquivo"
		fi
	else
		# zzlembrete texto: Adiciona o texto
		echo "$*" >> "$arquivo" || {
			zztool erro "Ops, não consegui adicionar esse lembrete"
			return 1
		}
	fi
}

# ----------------------------------------------------------------------------
# zzlibertadores
# Mostra a classificação e jogos do torneio Libertadores da América.
# Opções:
#  <número> | <fase>: Mostra jogos da fase selecionada
#    fases: pre ou primeira, grupos ou segunda, oitavas
#  -g <número>: Jogos da segunda fase do grupo selecionado
#  -c [número]: Mostra a classificação, nos grupos da segunda fase
#  -cg <número> ou -gc <número>: Classificação e jogos do grupo selecionado.
#
# As fases podem ser:
#  pré, pre, primeira ou 1, para a fase pré-libertadores
#  grupos, segunda ou 2, para a fase de grupos da libertadores
#  oitavas ou 3
#  quartas ou 4
#  semi, semi-final ou 5
#  final ou 6
#
# Nomenclatura:
#  PG  - Pontos Ganhos
#  J   - Jogos
#  V   - Vitórias
#  E   - Empates
#  D   - Derrotas
#  GP  - Gols Pró
#  GC  - Gols Contra
#  SG  - Saldo de Gols
#  (%) - Aproveitamento (pontos)
#
# Obs.: Se a opção for --atualiza, o cache usado é renovado
#
# Uso: zzlibertadores [ fase | -c [número] | -g <número> ]
# Ex.: zzlibertadores 2     # Jogos da Fase 2 (Grupos)
#      zzlibertadores -g 5  # Jogos do grupo 5 da fase 2
#      zzlibertadores -c    # Classificação de todos os grupos
#      zzlibertadores -c 3  # Classificação no grupo 3
#      zzlibertadores -cg 7 # Classificação e jogos do grupo 7
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-17
# Versão: 15
# Licença: GPL
# Requisitos: zzecho zzpad zzdatafmt
# ----------------------------------------------------------------------------
zzlibertadores ()
{
	zzzz -h libertadores "$1" && return

	local ano=$(date +%Y)
	local cache=$(zztool cache libertadores)
	local url="http://esporte.uol.com.br/futebol/campeonatos/libertadores/jogos/"
	local awk_jogo='
		NR % 3 ~ /^[12]$/ {
			if ($1 ~ /^[0-9-]+$/ && $2 ~ /^[0-9-]+$/) {
				penais[NR % 3]=$1; placar[NR % 3]=$2; $1=""; $2=""
			}
			else if ($1 ~ /^[0-9-]+$/ && $2 !~ /^[0-9-]+$/) {
				penais[NR % 3]=""; placar[NR % 3]=$1; $1=""
			}
			sub(/^ */,"");sub(/ *$/,"")
			time[NR % 3]=" " $0 " "
		}
		NR % 3 == 0 {
			if (length(penais[1])>0 && length(penais[2])>0) {
				placar[1] = placar[1] " ( " penais[1]
				placar[2] = penais[2] " ) " placar[2]
			}
			else {
				penais[1]="";penais[2]=""
			}
			sub(/  *$/,""); print time[1] placar[1] "|" placar[2] time[2] "|" $0
			placar[1]="";placar[2]=""
		}
		'
	local sed_mata='
		1d; $d
		/Confronto/d;/^ *$/d;
		s/pós[ -]jogo *//; s/^ *//; s/__*//g; s/ [A-Z][A-Z][A-Z]//;
	'
	local time1 time2 horario linha

	test -n "$1" || { zztool -e uso libertadores; return 1; }

	# Tempo de resposta do site está elevando, usando cache para minimizar efeito
	test "$1" = "--atualiza" && { zztool cache rm libertadores; shift; }
	if ! test -s "$cache" || test $(head -n 1 "$cache") != $(zzdatafmt --iso hoje)
	then
		zzdatafmt --iso hoje > "$cache"
		zztool dump "$url" >> "$cache"
	fi

	# Mostrando os jogos
	# Escolhendo as fases
	# Fase 1 (Pré-libertadores)
	case "$1" in
	1 | pr[eé] | primeira)
		sed -n '/PRIMEIRA FASE/,/FASE DE GRUPOS/{/FASE/d; p;}' "$cache" |
		sed "$sed_mata" |
		awk "$awk_jogo" |
		while read linha
		do
			time1=$(  echo $linha | cut -d"|" -f 1 )
			time2=$(  echo $linha | cut -d"|" -f 2 )
			horario=$(echo $linha | cut -d"|" -f 3 )
			echo "$(zzpad -l 45 $time1) X $(zzpad -r 45 $time2) $horario"
		done
	;;
	# Fase 2 (Fase de Grupos)
	2 | grupos | segunda)
		for grupo in 1 2 3 4 5 6 7 8
		do
			zzlibertadores -g $grupo
			echo
		done
	;;
	3 | oitavas)
		sed -n '/^OITAVAS DE FINAL/,/^Notícias/p' "$cache" |
		sed "$sed_mata" |
		sed 's/.*\([0-9]º\)/\1/' |
		awk "$awk_jogo" |
		while read linha
		do
			time1=$(  echo $linha | cut -d"|" -f 1 )
			time2=$(  echo $linha | cut -d"|" -f 2 )
			horario=$(echo $linha | cut -d"|" -f 3 )
			echo "$(zzpad -l 28 $time1) X $(zzpad -r 28 $time2) $horario"
		done
	;;
	4 | quartas | 5 | semi | semi-final | 6 | final)
		case $1 in
		4 | quartas)
			sed -n '/^QUARTAS DE FINAL/,/^OITAVAS DE FINAL/p' "$cache";;
		5 | semi | semi-final)
			sed -n '/^SEMIFINAIS/,/^QUARTAS DE FINAL/p' "$cache";;
		6 | final)
			sed -n '/^FINAL/,/^SEMIFINAIS/p' "$cache";;
		esac |
		sed "$sed_mata" |
		sed 's/.*Vencedor/Vencedor/' |
		awk "$awk_jogo" |
		while read linha
		do
			time1=$(  echo $linha | cut -d"|" -f 1 )
			time2=$(  echo $linha | cut -d"|" -f 2 )
			horario=$(echo $linha | cut -d"|" -f 3 )
			echo "$(zzpad -l 28 $time1) X $(zzpad -r 28 $time2) $horario"
		done
	;;
	esac

	# Escolhendo o grupo para os jogos
	if test "$1" = "-g" && zztool testa_numero $2 && test $2 -le 8  -a $2 -ge 1
	then
		echo "Grupo $2"
		sed -n "/^ *Grupo $2/,/Grupo /p"  "$cache"|
		sed '
			1d; /°/d; /Rodada [2-9]/d;
			/ para as oitavas de final/,$d
			' |
		sed "$sed_mata" |
		awk "$awk_jogo" |
		sed 's/\(h[0-9][0-9]\).*$/\1/' |
		while read linha
		do
			time1=$(  echo $linha | cut -d"|" -f 1 )
			time2=$(  echo $linha | cut -d"|" -f 2 )
			horario=$(echo $linha | cut -d"|" -f 3 )
			echo "$(zzpad -l 28 $time1) X $(zzpad -r 28 $time2) $horario"
		done
	fi

	# Mostrando a classificação (Fase de grupos)
	if test "$1" = "-c" -o "$1" = "-cg" -o "$1" = "-gc"
	then
		if zztool testa_numero $2 && test $2 -le 8  -a $2 -ge 1
		then
			grupo="$2"
			sed -n "/^ *Grupo $2/,/Rodada 1/p" "$cache" | sed -n '/PG/p;/°/p' |
			sed 's/ LDU / ldu /g'|
			sed 's/[^-][A-Z][A-Z][A-Z] //;s/ [A-Z][A-Z][A-Z]//' |
			sed 's/ ldu / LDU /g'|
			awk -v cor_awk="$ZZCOR" '{
				if (NF <  10) { print }
				if (NF == 10) {
					printf "%-28s", $1
					for (i=2;i<=10;i++) { printf " %3s", $i }
					print ""
				}
				if (NF > 10) {
					if (cor_awk==1 && ($1 == "1°" || $1 == "2°")) { printf "\033[42;30m" }
					time=""
					for (i=1;i<NF-8;i++) { time=time " " $i }
					printf "%-28s", time
					for (i=NF-8;i<=NF;i++) { printf " %3s", $i }
					if (cor_awk==1) { printf "\033[m\n" } else {print ""}
				}
			}'
			test "$1" = "-cg" -o "$1" = "-gc" && { echo; zzlibertadores -g $2 | sed '1d'; }
		else
			for grupo in 1 2 3 4 5 6 7 8
			do
				zzlibertadores -c $grupo -n
				test "$1" = "-cg" -o "$1" = "-gc" && { echo; zzlibertadores -g $grupo | sed '1d'; }
				echo
			done
		fi
		if test $ZZCOR -eq 1
		then
			test "$3" != "-n" && { echo ""; zzecho -f verde -l preto " Oitavas de Final "; }
		fi
	fi
}

# ----------------------------------------------------------------------------
# zzlimpalixo
# Retira linhas em branco e comentários.
# Para ver rapidamente quais opções estão ativas num arquivo de configuração.
# Além do tradicional #, reconhece comentários de vários tipos de arquivos.
#  vim, asp, asm, ada, sql, e, bat, tex, c, css, html, cc, d, js, php, scala.
# E inclui os comentários multilinhas (/* ... */), usando opção --multi.
# Obs.: Aceita dados vindos da entrada padrão (STDIN).
# Uso: zzlimpalixo [--multi] [arquivos]
# Ex.: zzlimpalixo ~/.vimrc
#      cat /etc/inittab | zzlimpalixo
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-04-24
# Versão: 3
# Licença: GPL
# Requisitos: zzjuntalinhas
# ----------------------------------------------------------------------------
zzlimpalixo ()
{
	zzzz -h limpalixo "$1" && return

	local comentario='#'
	local multi=0
	local comentario_ini='\/\*'
	local comentario_fim='\*\/'

	# Para comentários multilinhas: /* ... */
	if test "$1" = "--multi"
	then
		multi=1
		shift
	fi

	# Reconhecimento de comentários
	# Incluida opção de escolher o tipo, pois o arquivo pode vir via pipe, e não seria possível reconhecer a extensão do arquivo
	case "$1" in
		*.vim | *.vimrc*)                    comentario='"';;
		--vim)                               comentario='"';   shift;;
		*.asp)                               comentario="'";;
		--asp)                               comentario="'";   shift;;
		*.asm)                               comentario=';';;
		--asm)                               comentario=';';   shift;;
		*.ada | *.sql | *.e)                 comentario='--';;
		--ada | --sql | --e)                 comentario='--';  shift;;
		*.bat)                               comentario='rem';;
		--bat)                               comentario='rem'; shift;;
		*.tex)                               comentario='%';;
		--tex)                               comentario='%';   shift;;
		*.c | *.css)                         multi=1;;
		--c | --css)                         multi=1;shift;;
		*.html | *.htm | *.xml)              comentario_ini='<!--'; comentario_fim='-->'; multi=1;;
		--html | --htm | --xml)              comentario_ini='<!--'; comentario_fim='-->'; multi=1; shift;;
		*.jsp)                               comentario_ini='<%--'; comentario_fim='-->'; multi=1;;
		--jsp)                               comentario_ini='<%--'; comentario_fim='-->'; multi=1; shift;;
		*.cc | *.d | *.js | *.php | *.scala) comentario='\/\/';;
		--cc | --d | --js | --php | --scala) comentario='\/\/'; shift;;
	esac

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" |

	# Junta os comentários multilinhas
	if test $multi -eq 1
	then
		zzjuntalinhas -i "$comentario_ini" -f "$comentario_fim" |
		sed "/^[[:blank:]]*${comentario_ini}/d"

	else
		cat -
	fi |

		# Remove comentários e linhas em branco
		sed "
			/^[[:blank:]]*$comentario/ d
			/^[[:blank:]]*$/ d" |
		uniq
}

# ----------------------------------------------------------------------------
# zzlinha
# Mostra uma linha de um texto, aleatória ou informada pelo número.
# Obs.: Se passado um argumento, restringe o sorteio às linhas com o padrão.
# Uso: zzlinha [número | -t texto] [arquivo(s)]
# Ex.: zzlinha /etc/passwd           # mostra uma linha qualquer, aleatória
#      zzlinha 9 /etc/passwd         # mostra a linha 9 do arquivo
#      zzlinha -2 /etc/passwd        # mostra a penúltima linha do arquivo
#      zzlinha -t root /etc/passwd   # mostra uma das linhas com "root"
#      cat /etc/passwd | zzlinha     # o arquivo pode vir da entrada padrão
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2004-12-23
# Versão: 2
# Licença: GPL
# Requisitos: zzaleatorio zztestar
# ----------------------------------------------------------------------------
zzlinha ()
{
	zzzz -h linha "$1" && return

	local arquivo n padrao resultado num_linhas

	# Opções de linha de comando
	if test "$1" = '-t'
	then
		padrao="$2"
		shift
		shift
	fi

	# Talvez o $1 é o número da linha desejada?
	if zztestar numero_sinal "$1"
	then
		n="$1"
		shift
	fi

	# Se informado um ou mais arquivos, eles existem?
	for arquivo in "$@"
	do
		zztool -e arquivo_legivel "$arquivo" || return 1
	done

	if test -n "$n"
	then
		# Se foi informado um número, mostra essa linha.
		# Nota: Suporte a múltiplos arquivos ou entrada padrão (STDIN)
		for arquivo in "${@:--}"
		do
			# Usando cat para ler do arquivo ou da STDIN
			cat "$arquivo" |
				if test "$n" -lt 0
				then
					tail -n "${n#-}" | sed 1q
				else
					sed -n "${n}p"
				fi
		done
	else
		# Se foi informado um padrão (ou nenhum argumento),
		# primeiro grepa as linhas, depois mostra uma linha
		# aleatória deste resultado.
		# Nota: Arquivos via STDIN ou argumentos
		resultado=$(zztool file_stdin "$@" | grep -h -i -- "${padrao:-.}")
		num_linhas=$(echo "$resultado" | zztool num_linhas)
		n=$(zzaleatorio 1 $num_linhas)
		echo "$resultado" | sed -n "${n}p"
	fi
}

# ----------------------------------------------------------------------------
# zzlinuxnews
# Busca as últimas notícias sobre Linux em sites em inglês.
# Obs.: Cada site tem uma letra identificadora que pode ser passada como
#       parâmetro, para informar quais sites você quer pesquisar:
#
#          S)lashDot            Linux T)oday
#          O)S News             Linux W)eekly News
#          Linux I)nsider       Linux N)ews
#          Linux J)ournal       X) LXer Linux News
#
# Uso: zzlinuxnews [sites]
# Ex.: zzlinuxnews
#      zzlinuxnews ts
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2002-11-07
# Versão: 6
# Licença: GPL
# Requisitos: zzfeed
# ----------------------------------------------------------------------------
zzlinuxnews ()
{
	zzzz -h linuxnews "$1" && return

	local url limite
	local n=5
	local sites='stwoxijn'

	limite="sed ${n}q"

	test -n "$1" && sites="$1"

	# Slashdot
	if zztool grep_var s "$sites"
	then
		url='http://rss.slashdot.org/Slashdot/slashdot'
		echo
		zztool eco "* SlashDot ($url):"
		zzfeed -n $n "$url"
	fi

	# Linux Today
	if zztool grep_var t "$sites"
	then
		url='http://www.linuxtoday.com/backend/biglt.rss'
		echo
		zztool eco "* Linux Today ($url):"
		zzfeed -n $n "$url"
	fi

	# LWN
	if zztool grep_var w "$sites"
	then
		url='http://lwn.net/headlines/newrss'
		echo
		zztool eco "* Linux Weekly News - ($url):"
		zzfeed -n $n "$url"
	fi

	# OS News
	if zztool grep_var o "$sites"
	then
		url='http://www.osnews.com/files/recent.xml'
		echo
		zztool eco "* OS News - ($url):"
		zzfeed -n $n "$url"
	fi

	# LXer Linux News
	if zztool grep_var x "$sites"
	then
		url='http://lxer.com/module/newswire/headlines.rss'
		echo
		zztool eco "*  LXer Linux News- ($url):"
		zzfeed -n $n "$url"
	fi

	# Linux Insider
	if zztool grep_var i "$sites"
	then
		url='http://www.linuxinsider.com/perl/syndication/rssfull.pl'
		echo
		zztool eco "* Linux Insider - ($url):"
		zzfeed -n $n "$url"
	fi

	# Linux Journal
	if zztool grep_var j "$sites"
	then
		url='http://feeds.feedburner.com/linuxjournalcom'
		echo
		zztool eco "* Linux Journal - ($url):"
		zzfeed -n $n "$url"
	fi

	# Linux News
	if zztool grep_var n "$sites"
	then
		url='https://www.linux.com/feeds/all-content'
		echo
		zztool eco "* Linux News - ($url):"
		zzfeed -n $n "$url"
	fi
}

# ----------------------------------------------------------------------------
# zzlinux
# http://www.kernel.org/kdist/finger_banner
# Mostra as versões disponíveis do Kernel Linux.
# Uso: zzlinux
# Ex.: zzlinux
#
# Autor: Diogo Gullit <guuuuuuuuuullit (a) yahoo com br>
# Desde: 2008-05-01
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzlinux ()
{
	zzzz -h linux "$1" && return

	zztool source http://www.kernel.org/kdist/finger_banner | grep -v '^$'
}

# ----------------------------------------------------------------------------
# zzlocale
# Busca o código do idioma (locale) - por exemplo, português é pt_BR.
# Com a opção -c, pesquisa somente nos códigos e não em sua descrição.
# Uso: zzlocale [-c] código|texto
# Ex.: zzlocale chinese
#      zzlocale -c pt
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2005-06-30
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzlocale ()
{
	zzzz -h locale "$1" && return

	local url='https://raw.githubusercontent.com/funcoeszz/funcoeszz/master/local/zzlocale.txt'
	local cache=$(zztool cache locale)
	local padrao="$1"

	# Opções de linha de comando
	if test "$1" = '-c'
	then
		# Padrão de pesquisa válido para última palavra da linha (código)
		padrao="$2[^ ]*$"
		shift
	fi

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso locale; return 1; }

	# Se o cache está vazio, baixa listagem da Internet
	if ! test -s "$cache"
	then
		zztool download "$url" "$cache"
	fi

	# Faz a consulta
	grep -i -- "$padrao" "$cache"
}

# ----------------------------------------------------------------------------
# zzlorem
# Gerador de texto de teste, em latim (Lorem ipsum...).
# Texto obtido em http://br.lipsum.com/
#
# Uso: zzlorem [número-de-palavras]
# Ex.: zzlorem 10
#
# Autor: Angelito M. Goulart, www.angelitomg.com
# Desde: 2012-12-11
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzlorem ()
{

	# Comando especial das funcoes ZZ
	zzzz -h lorem "$1" && return

	# Contador para repetição do texto quando maior que mil
	local contador

	# Conteudo do texto que sera usado pelo script
	local TEXTO="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin euismod blandit pharetra. Vestibulum eu neque eget lorem gravida commodo a cursus massa. Fusce sit amet lorem sem. Donec eu quam leo. Suspendisse consequat risus in ante fringilla sit amet facilisis felis hendrerit. Suspendisse potenti. Pellentesque enim quam, cursus vestibulum porta ac, pharetra vitae ipsum. Sed ullamcorper odio eget diam egestas lacinia. Aenean aliquam tortor quis dolor sollicitudin suscipit. Etiam nec libero vitae magna dignissim molestie. Pellentesque volutpat euismod justo id congue. Proin nibh magna, blandit quis posuere at, sollicitudin nec lectus. Vivamus ut erat erat, in egestas lacus. Vivamus vel nunc elit, ut aliquam nisi.

Vivamus convallis, mi eu consequat scelerisque, lacus lorem elementum quam, vel varius augue lectus sit amet nulla. Integer porta ligula eu risus rhoncus sit amet blandit nulla tincidunt. Nullam fringilla lectus scelerisque elit suscipit venenatis. Donec in ante nec tortor mollis adipiscing. Aliquam id tellus bibendum orci ultricies scelerisque sit amet ut elit. Sed quis turpis molestie tortor consectetur dapibus. Donec hendrerit diam sit amet nibh porta a pellentesque tortor dictum. Curabitur justo libero, rhoncus vitae facilisis nec, vulputate at ipsum. Quisque iaculis diam eget mi tincidunt id sollicitudin diam fermentum.

Vivamus sed orci non nisl elementum adipiscing in et tortor. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. In hac habitasse platea dictumst. Phasellus a dictum magna. Duis vel erat in lacus tempor fermentum sit amet sed felis. Vestibulum arcu libero, convallis sed euismod sit amet, condimentum in orci. Nulla tempus venenatis justo, et porttitor metus pellentesque ut. Nunc vel turpis a risus mollis tempor. Suspendisse purus risus, pharetra eu tincidunt non, adipiscing vitae libero. Nam ut quam sed metus laoreet sagittis vel non risus. Pellentesque vestibulum vehicula porttitor. Donec aliquet lorem nec ipsum auctor laoreet. Nunc pellentesque ligula sed felis venenatis dictum. Donec ut mauris eget purus ornare rhoncus. Integer pellentesque elementum nisi, at consectetur orci placerat eu.

Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec rutrum fermentum mi, id faucibus libero volutpat id. Suspendisse tristique lobortis ligula quis suscipit. Pellentesque velit tellus, aliquet eu cursus a, blandit ac leo. Proin diam ante, iaculis quis commodo vitae, placerat at lacus. In ipsum nisi, aliquam in aliquet ac, congue a nunc. Fusce ut semper erat. Sed fermentum nulla nec tellus convallis ac vestibulum tortor feugiat. Quisque sed est sem, quis adipiscing ipsum. In non velit nibh. Fusce in libero vitae sem dignissim ultrices ac sed mi. Quisque laoreet ipsum eget metus consequat vestibulum. Quisque ornare accumsan nisl sed eleifend.

Donec lacinia lacus sapien. Nunc condimentum volutpat justo, nec euismod justo varius a. Aliquam mattis faucibus interdum. Suspendisse et lorem at odio fringilla lobortis. Nunc ut purus et tortor dignissim lobortis sit amet quis nisl. Aliquam a nulla in est eleifend imperdiet non eu ipsum. Sed diam neque, vehicula id consequat sit amet, lobortis at orci. Etiam et purus ipsum. Sed aliquam eros nec quam faucibus non faucibus velit sollicitudin. Nam tincidunt ullamcorper mattis.

Fusce odio velit, sodales id gravida vel, laoreet at lorem. Fusce malesuada mauris sed enim convallis non pulvinar dui egestas. Nullam sodales cursus quam sed lacinia. Praesent ac lorem ut erat feugiat molestie. Integer quis nisl et libero luctus ornare at vel ante. Integer magna nisi, vestibulum ac aliquam quis, iaculis eget massa. Integer ut venenatis ante. Duis fermentum neque elit, iaculis sagittis dui. Nam faucibus elementum nisl sit amet pulvinar. Duis fringilla, nulla ut porttitor rutrum, diam dolor sagittis neque, a placerat arcu diam nec libero. Nulla dolor tellus, consectetur eget consectetur ac, dapibus quis est. Aenean adipiscing volutpat lectus vitae consequat.

Cras ultrices lacus vitae metus dictum quis iaculis nulla bibendum. Duis aliquam, tellus id pharetra bibendum, dui est condimentum mauris, semper condimentum odio massa vitae nisl. Suspendisse non ipsum mauris. Vestibulum tempor consequat lacus quis commodo. Pellentesque eros urna, adipiscing ut faucibus id, sagittis non purus. Curabitur dignissim, urna id iaculis viverra, tortor libero congue sapien, eget tincidunt diam dolor at odio. Ut vitae lacus velit.

Pellentesque non tellus eget ipsum molestie placerat. Quisque sagittis, mauris facilisis tincidunt aliquet, erat nulla commodo turpis, nec porttitor dolor magna sit amet neque. Etiam ornare lobortis sagittis. Curabitur sit amet nunc at arcu consequat pellentesque at et tortor. Fusce vehicula, ante ut euismod dignissim, eros tellus tincidunt turpis, sit amet placerat nunc tortor ut dui. Cras lacus tortor, congue eget gravida sed, dapibus sed tortor. In hac habitasse platea dictumst. Vivamus ante felis, cursus quis interdum porta, accumsan non nulla. Maecenas lacus lacus, malesuada et lobortis a, ullamcorper ac odio. Sed ac neque massa, eget pharetra justo. Vivamus cursus eleifend nisl vel adipiscing. Sed eget lectus nisi. Donec sed lacus justo, sed semper dolor. Vestibulum mollis fermentum metus, quis hendrerit odio cursus nec.

Sed ac tempor nulla. Nunc eget nunc sit amet magna porta malesuada. Vivamus pharetra lorem vel enim pretium lacinia. Etiam vitae turpis turpis, quis ullamcorper libero. Aenean quis dui id nibh pellentesque eleifend. Cras commodo lectus a sapien laoreet venenatis. Donec facilisis hendrerit diam nec blandit. Duis lectus quam, aliquet quis fringilla non, posuere sit amet massa. Duis pharetra lacinia facilisis.

In gravida, neque a mattis tincidunt, velit arcu cursus nisi, eu blandit risus ligula eget ligula. Aenean faucibus tincidunt bibendum. Nulla nec urna lorem. Suspendisse non lorem in sapien cursus dignissim interdum non ligula. Suspendisse potenti. Sed rutrum libero ut odio varius a condimentum nulla commodo. Etiam in eros diam, vel lobortis nibh. Aliquam quam felis, blandit sit amet placerat non, tristique sit amet nisi. Pellentesque sit amet magna rutrum odio varius volutpat. Quisque consequat, elit ac blandit varius, turpis odio pellentesque urna, eu ultricies elit quam eget elit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nam vel sem sem, vitae vehicula tortor. Etiam ut dui diam. Duis id libero nunc, pharetra bibendum tellus. Praesent accumsan tempus euismod. Vestibulum ante ipsum primis in faucibus orci luctus et."

	if test "$#" -ne 1
	then

		# Se nao for passado um numero de palavras, exibe o texto todo
		echo $TEXTO

	elif zztool testa_numero "$1"
	then

		# Se o parametro for maior e igual a 1000, repete os múltiplos de 1000.
		contador=$(($1 / 1000))
		while test $contador -gt 0
		do
			echo $TEXTO
			contador=$(($contador -1))
		done

		# Se o resto do parâmetro for maior que zero, corta o texto no local certo, até esse limite ou ponto.
		contador=$(($1 % 1000))
		test $contador -gt 0 && echo $TEXTO | cut -d " " -f 1-"$contador" | sed '$s/\.[^.]*$/\./'

	else

		# Caso o parametro nao seja um numero, exibe o modo de utilizacao
		zztool -e uso lorem
		return 1
	fi

}

# ----------------------------------------------------------------------------
# zzloteria
# Resultados da quina, megasena, duplasena, lotomania, lotofácil, federal, timemania e loteca.
#
# Se o 2º argumento for um número, pesquisa o resultado filtrando o concurso.
# Se o 2º argumento for a palavra "quantidade" ou "qtde" mostra quantas vezes
#  um número foi sorteado. ( Não se aplica para federal e loteca )
# Se nenhum argumento for passado, todas as loterias são mostradas.
#
# Uso: zzloteria [[loterias suportadas] [concurso|[quantidade|qtde]]
# Ex.: zzloteria
#      zzloteria quina megasena
#      zzloteria loteca 550
#      zzloteria quina qtde
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2004-05-18
# Versão: 16
# Licença: GPL
# Requisitos: zzdatafmt zztrim zzunescape zzxml
# Nota: requer unzip
# ----------------------------------------------------------------------------
zzloteria ()
{
	zzzz -h loteria "$1" && return

	local tipo num_con qtde
	local url='https://confiraloterias.com.br'
	local tipos='quina megasena duplasena lotomania lotofacil federal timemania loteca'
	local cache=$(zztool cache loteria)
	local tab=$(printf '\t')
	local un_zip='unzip -q -a -C -o'
	local tmp_dir="${ZZTMP%/*}"

	# Caso o segundo argumento seja um numero, filtra pelo concurso equivalente
	if zztool testa_numero "$2"
	then
		tipos=$1
		num_con=$2
	elif test 'quantidade' = "$2" -o 'qtde' = "$2"
	then
		tipos=$1
		num_con=0
	else
		unset num_con
		test -n "$1" && tipos="$*"
	fi

	# Para cada tipo de loteria...
	for tipo in $tipos
	do

		# Para o caso de ser fornecido "lotofácil"
		tipo=$(echo "$tipo" | sed 's/á/a/')

		zztool eco "${tipo}:"
		if ! test -n "$num_con"
		then
			# Resultados mais recentes das loterias selecionadas.
			case "$tipo" in
				quina)
					zztool source "${url}/${tipo}" |
					sed -n 's/</\t</g;/title_detail/p;/_gji _Uii/p;/class="table"/,/<\/table>/p;/.cumulado/p' |
					zzxml --untag |
					zzunescape --html |
					zztrim |
					awk 'NR==2{printf "\t" $0 "\n\n"}; NR>=4 && NR<19{for (i=0;i<3;i++) {if (i!=0) printf $0 "\t"; getline}; print}; NR==20{print ""}; NR==1 || NR>19' |
					sed 's/	 / /' |
					tr -s '\t'
				;;
				megasena)
					zztool source "${url}/${tipo}" |
					sed -n 's/</\t</g;/title_detail/p;/_gji _Uii/p;/class="table"/,/<\/table>/p;/.cumulado/p' |
					zzxml --untag |
					zzunescape --html |
					zztrim |
					awk 'NR==2{printf "\t" $0 "\n\n"}; NR>=4 && NR<15{for (i=0;i<3;i++) {if (i!=0) printf $0 "\t"; getline}; print}; NR==16{print ""}; NR==1 || NR>15' |
					sed 's/	 / /' |
					tr -s '\t'
				;;
				duplasena)
					zztool source "${url}/${tipo}" |
					sed -n 's/</\t</g;/title_detail/p;/ Sorteio/p;/_gji _Uii/p;/class="table"/,/<\/table>/p;/.cumulado/p' |
					zzxml --untag |
					zzunescape --html |
					zztrim |
					awk '
						NR==2 || NR==4{printf "\t" $0 "\n\n"}
						(NR>=7 && NR<23) || (NR>=25 && NR<41) {for (i=0;i<3;i++) {if (i!=0) printf $0 "\t"; getline}; print}
						NR==5 || NR==23 || NR==41 {print ""}
						NR==1 || NR==5 || NR==23 || NR==41
					' |
					sed 's/	 / /' |
					tr -s '\t'
				;;
				lotomania)
					zztool source "${url}/${tipo}" |
					sed -n 's/</\t</g;/title_detail/p;/_gji _Uii/p;/class="table"/,/<\/table>/p;/.cumulado/p' |
					zzxml --untag |
					zzunescape --html |
					zztrim |
					awk '
						# NR==2{printf $0 "\n\n"}
						NR==2{for (i=1;i<=16;i+=5) printf "\t" $i "\t" $(i+1) "\t" $(i+2) "\t" $(i+3) "\t" $(i+4) "\n\n"}
						NR>=4 && NR<31{for (i=0;i<3;i++) {if (i!=0) printf $0 "\t"; getline}; print}
						NR==31{print ""}
						NR==1 || NR>31
					' |
					sed 's/	 / /;1,2s/ 	/ /g' |
					tr -s '\t'
				;;
				lotofacil)
					zztool source "${url}/${tipo}" |
					sed -n 's/</\t</g;/title_detail/p;/_gji _Uii/p;/class="table"/,/<\/table>/p;/.cumulado/p' |
					zzxml --untag |
					zzunescape --html |
					zztrim |
					awk '
						# NR==2{printf $0 "\n\n"}
						NR==2{for (i=1;i<=11;i+=5) printf "\t" $i "\t" $(i+1) "\t" $(i+2) "\t" $(i+3) "\t" $(i+4) "\n\n"}
						NR>=4 && NR<23{for (i=0;i<3;i++) {if (i!=0) printf $0 "\t"; getline}; print}
						NR==24{print ""}
						NR==1 || NR>23' |
					sed 's/	 / /' |
					tr -s '\t'
				;;
				timemania)
					zztool source "${url}/${tipo}" |
					sed -n 's/</\t</g;/title_detail/p;/_gji _Uii/p;/class="table"/,/<\/table>/p;/.cumulado/p' |
					zzxml --untag |
					zzunescape --html |
					zztrim |
					awk '
						NR>1 && NR<=3{printf "\t" $0 "\n\n"}
						NR>=4 && NR<26{for (i=0;i<3;i++) {if (i>1) printf $0 "\t"; getline}; print}
						NR==29{print ""}
						NR==1 || NR>28' |
					tr -s '\t ' |
					sed 's/	 / /;4s/:[ 	]*/:/;s/^	Time/Time/;s/Time	/&	/'
				;;
				federal)
					zztool source "${url}/${tipo}" |
					sed -n 's/</\t</g;/title_detail/p;/quina_text_color/p' |
					zzxml --untag | zztrim | awk 'NR==3{print ""};NR>7{exit};NR>2 {printf "\t" $0 "\n"}; NR==2' |
					sed 's/ 	/	/g' |
					tr -s '\t'
				;;
				loteca)
					if ! test -e ${cache}.loteca.htm || test $(zzdatafmt --iso hoje) != $(tail -n 1 ${cache}.loteca.htm)
					then
						wget -q -O "${cache}.loteca.zip" "http://www1.caixa.gov.br/loterias/_arquivos/loterias/d_loteca.zip"
						$un_zip "${cache}.loteca.zip" "*.HTM" -d "$tmp_dir" 2>/dev/null
						mv -f "${tmp_dir}/D_LOTECA.HTM" ${cache}.loteca.htm
						zzdatafmt --iso hoje >> ${cache}.loteca.htm
						rm -f ${cache}.loteca.zip
					fi
					zztool dump ${cache}.loteca.htm |
					grep -E --color=never '^  *[0-9]+ ' |
					tail -n 1 |
					awk '{
						print "Concurso", $1, "(" $2 ")"
						print " Jogo   Resultado"
						printf "  1    %8s\n", "Col. " ($(NF-15)=="x"?"Meio":$(NF-15))
						printf "  2    %8s\n", "Col. " ($(NF-14)=="x"?"Meio":$(NF-14))
						printf "  3    %8s\n", "Col. " ($(NF-13)=="x"?"Meio":$(NF-13))
						printf "  4    %8s\n", "Col. " ($(NF-12)=="x"?"Meio":$(NF-12))
						printf "  5    %8s\n", "Col. " ($(NF-11)=="x"?"Meio":$(NF-11))
						printf "  6    %8s\n", "Col. " ($(NF-10)=="x"?"Meio":$(NF-10))
						printf "  7    %8s\n", "Col. " ($(NF-9)=="x"?"Meio":$(NF-9))
						printf "  8    %8s\n", "Col. " ($(NF-8)=="x"?"Meio":$(NF-8))
						printf "  9    %8s\n", "Col. " ($(NF-7)=="x"?"Meio":$(NF-7))
						printf " 10    %8s\n", "Col. " ($(NF-6)=="x"?"Meio":$(NF-6))
						printf " 11    %8s\n", "Col. " ($(NF-5)=="x"?"Meio":$(NF-5))
						printf " 12    %8s\n", "Col. " ($(NF-4)=="x"?"Meio":$(NF-4))
						printf " 13    %8s\n", "Col. " ($(NF-3)=="x"?"Meio":$(NF-3))
						printf " 14    %8s\n", "Col. " ($(NF-2)=="x"?"Meio":$(NF-2))
						print ""
						printf "  14 pts.\t%s\t%s\n", ($3==0?"Nao houve acertador":$3), ($3==0?"":"R$ " $(NF-21))
						printf "  13 pts.\t%s\t%s\n", $(NF-18), "R$ " $(NF-17)
					}'
				;;
			esac
			echo
		else
			# Resultados históricos das loterias selecionadas.
			case "$tipo" in
				lotomania)
					if ! test -e ${cache}.lotomania.htm || ! $(zztool dump ${cache}.lotomania.htm | grep "^ *$num_con " >/dev/null)
					then
						wget -q -O "${cache}.lotomania.zip" "http://www1.caixa.gov.br/loterias/_arquivos/loterias/D_lotoma.zip"
						$un_zip "${cache}.lotomania.zip" "*.HTM" -d "$tmp_dir" 2>/dev/null
						mv -f "${tmp_dir}/D_LOTMAN.HTM" ${cache}.lotomania.htm
						rm -f ${cache}.lotomania.zip
					fi
					zztool dump ${cache}.lotomania.htm |
					if test 0 = "$num_con"
					then
						awk '
						BEGIN { printf "## QTD\t## QTD\t## QTD\t## QTD\n" }
						$2 ~ /[0-9]\/[0-9][0-9]\/[0-9]/ { for (i=3;i<23;i++) numeros[$i]++ }
						END {
							for (i=0;i<25;i++) {
								num=sprintf("%02d",i)
								printf "%02d %d\t%02d %d\t%02d %d\t%02d %d\n", i, numeros[num], i+25, numeros[i+25], i+50, numeros[i+50], i+75, numeros[i+75]
							}
						}
						' | expand -t 10
					else
						grep "^ *$num_con " 2>/dev/null |
						tr -d '[A-Z]' |
						awk ' {
							print "Concurso", $1, "(" $2 ")"
							comando="sort -n | paste -d _ - - - - -"
							for (i=3;i<23;i++) {print $i | comando }
							close(comando)
							i=(NF==42?1:0)
							print ""
							printf "20 pts.\t%s\t%s\n", ($24==0?"Nao houve acertador!":$24), ($24==0?"":"R$ " $(NF-13+i))
							printf "19 pts.\t%s\t%s\n", $(NF-18+i), "R$ " $(NF-12+i)
							printf "18 pts.\t%s\t%s\n", $(NF-17+i), "R$ " $(NF-11+i)
							printf "17 pts.\t%s\t%s\n", $(NF-16+i), "R$ " $(NF-10+i)
							printf "16 pts.\t%s\t%s\n", $(NF-15+i), "R$ " $(NF-9+i)
							printf " 0 pts.\t%s\t%s\n", ($(NF-14+i)==0?"Nao houve acertador!":$(NF-14+i)), ($(NF-14+i)==0?"":"R$ " $(NF-8+i))
						}' | sed '/^[0-9 ]/s/^/   /;s/_/     /g' | expand -t 5,15,25
					fi
				;;
				lotofacil)
					if ! test -e ${cache}.lotofacil.htm || ! $(zztool dump ${cache}.lotofacil.htm | grep "^ *$num_con " >/dev/null)
					then
						wget -q -O "${cache}.lotofacil.zip" "http://www1.caixa.gov.br/loterias/_arquivos/loterias/D_lotfac.zip"
						$un_zip "${cache}.lotofacil.zip" "*.HTM" -d "$tmp_dir" 2>/dev/null
						mv -f "${tmp_dir}/D_LOTFAC.HTM" ${cache}.lotofacil.htm
						rm -f ${cache}.lotofacil.zip
					fi
					zztool dump ${cache}.lotofacil.htm |
					if test 0 = "$num_con"
					then
						awk '
						BEGIN { print "## QTD" }
						$2 ~ /[0-9]\/[0-9][0-9]\/[0-9]/ { for (i=3;i<18;i++) numeros[$i]++ }
						END {
							for (i=1;i<=25;i++) {
								num=sprintf("%02d",i)
								printf "%02d %d\n", i, numeros[num]
							}
						}
						' | expand -t 10
					else
						grep "^ *$num_con " 2>/dev/null |
						awk '{
							print "Concurso", $1, "(" $2 ")"
							comando="sort -n | paste -d _ - - - - -"
							for (i=3;i<18;i++) {print $i | comando }
							close(comando)
							print ""
							printf "15 pts.\t%s\t%s\n", ($19==0?"Nao houve acertador!":$19), ($19==0?"":"R$ " $(NF-7))
							printf "14 pts.\t%s\t%s\n", $(NF-11), "R$ " $(NF-6)
							printf "13 pts.\t%s\t%s\n", $(NF-10), "R$ " $(NF-5)
							printf "12 pts.\t%s\t%s\n", $(NF-9), "R$ " $(NF-4)
							printf "11 pts.\t%s\t%s\n", $(NF-8), "R$ " $(NF-3)
						}' | sed '/^[0-9 ]/s/^/   /;s/_/     /g' | expand -t 5,15,25
					fi
				;;
				megasena)
					if ! test -e ${cache}.mega.htm || ! $(zztool dump ${cache}.megasena.htm | grep "^ *$num_con " >/dev/null)
					then
						wget -q -O "${cache}.megasena.zip" "http://www1.caixa.gov.br/loterias/_arquivos/loterias/D_mgsasc.zip"
						$un_zip "${cache}.megasena.zip" "*.htm" -d "$tmp_dir" 2>/dev/null
						mv -f "${tmp_dir}/d_megasc.htm" ${cache}.megasena.htm
						rm -f ${cache}.megasena.zip
					fi
					zztool dump ${cache}.megasena.htm |
					if test 0 = "$num_con"
					then
						awk '
						BEGIN { printf "## QTD\t## QTD\t## QTD\n" }
						$2 ~ /[0-9]\/[0-9][0-9]\/[0-9]/ { for (i=3;i<9;i++) numeros[$i]++ }
						END {
							for (i=1;i<=20;i++) {
								num=sprintf("%02d",i)
								printf "%02d %d\t%02d %d\t%02d %d\n", i, numeros[num], i+20, numeros[i+20], i+40, numeros[i+40]
							}
						}
						' | expand -t 10
					else
						grep "^ *$num_con " 2>/dev/null |
						awk '{
							print "Concurso", $1, "(" $2 ")"
							printf "%4s %4s %4s %4s %4s %4s\n", $3, $4, $5, $6, $7, $8
							print ""
							printf "   Sena  \t%s\t%s\n", ($10==0?"Nao houve acertador!":$10), ($10==0?"":"R$ " $(NF-8))
							printf "   Quina \t%s\t%s\n", $(NF-7), "R$ " $(NF-6)
							printf "   Quadra\t%s\t%s\n", $(NF-5), "R$ " $(NF-4)
						}' | expand -t 15,25,35
					fi
				;;
				duplasena)
					if ! test -e ${cache}.duplasena.htm || ! $(zztool dump ${cache}.duplasena.htm | grep "^ *$num_con " >/dev/null)
					then
						wget -q -O "${cache}.duplasena.zip" "http://www1.caixa.gov.br/loterias/_arquivos/loterias/d_dplsen.zip"
						$un_zip "${cache}.duplasena.zip" "*.HTM" -d "$tmp_dir" 2>/dev/null
						mv -f "${tmp_dir}/D_DPLSEN.HTM" ${cache}.duplasena.htm
						rm -f ${cache}.duplasena.zip
					fi
					zztool dump ${cache}.duplasena.htm |
					if test 0 = "$num_con"
					then
						awk '
						BEGIN {
							printf "1º sorteio          2º sorteio\n"
							printf "## QTD\t## QTD\t## QTD\t## QTD\n"
							}
						$2 ~ /[0-9]\/[0-9][0-9]\/[0-9]/ {
							for (i=3;i<9;i++)  numeros1[$i]++
							for (i=15;i>9;i--) numeros2[$(NF-i) ]++
						}
						END {
							for (i=1;i<=25;i++) {
								num=sprintf("%02d",i)
								printf "%02d %d\t%02d %d\t%02d %d\t%02d %d\n", i, numeros1[num], i+25, numeros1[i+25], i, numeros2[num], i+25, numeros2[i+25]
							}
						}
						' | expand -t 10
					else
						grep "^ *$num_con " 2>/dev/null |
						awk '{
							print "Concurso", $1, "(" $2 ")"
							printf "\n  1º sorteio\n"
							comando="sort -n | paste -d _ - - - - - -"
							for (i=3;i<9;i++) {print $i | comando }
							close(comando)
							printf "\n  2º sorteio\n"
							for (i=15;i>9;i--) {print $(NF-i) | comando }
							close(comando)
							printf "\n  1º Sorteio\n"
							printf "   Sena  \t%s\t%s\n", ($10==0?"Nao houve acertador":$10), ($10==0?"":"R$ " $(NF-22))
							printf "   Quina \t%s\t%s\n", $(NF-21), "R$ " $(NF-20)
							printf "   Quadra\t%s\t%s\n", $(NF-19), "R$ " $(NF-19)
							printf "\n  2º Sorteio\n"
							printf "   Sena  \t%s\t%s\n", ($(NF-9)==0?"Nao houve acertador":$(NF-9)), ($(NF-9)==0?"":"R$ " $(NF-8))
							printf "   Quina \t%s\t%s\n", $(NF-7), "R$ " $(NF-6)
							printf "   Quadra\t%s\t%s\n", $(NF-5), "R$ " $(NF-4)
						}' | sed '/^[0-9][0-9]/s/^/   /;s/_/   /g'
					fi
				;;
				quina)
					if ! test -e ${cache}.quina.htm || ! $(zztool dump ${cache}.quina.htm | grep "^ *$num_con " >/dev/null)
					then
						wget -q -O "${cache}.quina.zip" "http://www1.caixa.gov.br/loterias/_arquivos/loterias/D_quina.zip"
						$un_zip "${cache}.quina.zip" "*.HTM" -d "$tmp_dir" 2>/dev/null
						mv -f "${tmp_dir}/D_QUINA.HTM" ${cache}.quina.htm
						rm -f ${cache}.quina.zip
					fi
					zztool dump ${cache}.quina.htm |
					if test 0 = "$num_con"
					then
						awk '
						BEGIN { printf "## QTD\t## QTD\t## QTD\t## QTD\n" }
						$2 ~ /[0-9]\/[0-9][0-9]\/[0-9]/ { for (i=3;i<8;i++) numeros[$i]++ }
						END {
							for (i=1;i<=20;i++) {
								num=sprintf("%02d",i)
								printf "%02d %d\t%02d %d\t%02d %d\t%02d %d\n", i, numeros[num], i+20, numeros[i+20], i+40, numeros[i+40], i+60, numeros[i+60]
							}
						}
						' | expand -t 10
					else
						grep "^ *$num_con " 2>/dev/null |
						awk '{
							print "Concurso", $1, "(" $2 ")"
							comando="sort -n | paste -d _ - - - - -"
							for (i=3;i<8;i++) {print $i | comando }
							close(comando)
							print ""
							printf "   Quina \t%s\t%s\n", ($9==0?"Nao houve acertador":$9), ($9==0?"":"R$ " $(NF-10))
							printf "   Quadra\t%s\t%s\n", $(NF-9), "R$ " $(NF-8)
							printf "   Terno \t%s\t%s\n", $(NF-7), "R$ " $(NF-6)
						}' | sed '/^[0-9][0-9]/s/^/   /;s/_/   /g' | expand -t 15,25,35
					fi
				;;
				federal)
					if test 0 = "$num_con"
					then
						zztool erro "Não se aplica a loteria federal."
						return 1
					fi

					if ! test -e ${cache}.federal.htm || ! $(zztool dump ${cache}.federal.htm | grep "^[ 0]*$num_con " >/dev/null)
					then
						wget -q -O "${cache}.federal.zip" "http://www1.caixa.gov.br/loterias/_arquivos/loterias/D_federa.zip"
						$un_zip "${cache}.federal.zip" "*.HTM" -d "$tmp_dir" 2>/dev/null
						mv -f "${tmp_dir}/D_LOTFED.HTM" ${cache}.federal.htm
						rm -f ${cache}.federal.zip
					fi
					zztool dump ${cache}.federal.htm |
					grep "^[ 0]*$num_con " 2>/dev/null |
					awk '{
						print "Concurso", $1, "(" $2 ")"
						print ""
						printf "   1º Premio     %s   %s\n", $3, "R$ " $8
						printf "   2º Premio     %s   %s\n", $4, "R$ " $9
						printf "   3º Premio     %s   %s\n", $5, "R$ " $10
						printf "   4º Premio     %s   %s\n", $6, "R$ " $11
						printf "   5º Premio     %s   %s\n", $7, "R$ " $12
					}'
				;;
				timemania)
					if ! test -e ${cache}.timemania.htm || ! $(zztool dump ${cache}.timemania.htm | grep "^ *$num_con " >/dev/null)
					then
						wget -q -O "${cache}.timemania.zip" "http://www1.caixa.gov.br/loterias/_arquivos/loterias/D_timasc.zip"
						$un_zip "${cache}.timemania.zip" "*.HTM" -d "$tmp_dir" 2>/dev/null
						mv -f "${tmp_dir}/D_TIMASC.HTM" ${cache}.timemania.htm
						rm -f ${cache}.timemania.zip
					fi
					zztool dump ${cache}.timemania.htm |
					if test 0 = "$num_con"
					then
						awk '
						BEGIN { printf "## QTD\t## QTD\t## QTD\t## QTD\n" }
						$2 ~ /[0-9]\/[0-9][0-9]\/[0-9]/ { for (i=3;i<10;i++) numeros[$i]++ }
						END {
							for (i=1;i<=20;i++) {
								num=sprintf("%02d",i)
								printf "%02d %d\t%02d %d\t%02d %d\t%02d %d\n", i, numeros[num], i+20, numeros[i+20], i+40, numeros[i+40], i+60, numeros[i+60]
							}
						}
						' | expand -t 10
					else
						grep "^ *$num_con " 2>/dev/null |
						sed 's/\([[:upper:]]\) \([[:upper:]]\)/\1_\2/g' |
						awk '{
							print "Concurso", $1, "(" $2 ")"
							printf "%5s %4s %4s %4s %4s %4s %4s\n", $3, $4, $5, $6, $7, $8, $9
							print ""
							printf "   7 pts.\t%s\t%s\n", ($12==0?"Nao houve acertador!":$12), ($12==0?"":"R$ " $(NF-7))
							printf "   6 pts.\t%s\t%s\n", $(NF-12), "R$ " $(NF-6)
							printf "   5 pts.\t%s\t%s\n", $(NF-11), "R$ " $(NF-5)
							printf "   4 pts.\t%s\t%s\n", $(NF-10), "R$ " $(NF-4)
							printf "   3 pts.\t%s\t%s\n", $(NF-9), "R$ " $(NF-3)
							printf "\n   Time: %s\t\n\t%s\t%s\n", $10, $(NF-8),  "R$ " $(NF-2)
						}' | expand -t 15,25,35
					fi
				;;
				loteca)
					if test 0 = "$num_con"
					then
						zztool erro "Não se aplica a loteca."
						return 1
					fi

					if ! test -e ${cache}.loteca.htm || ! $(zztool dump ${cache}.loteca.htm | grep "^ *$num_con " >/dev/null)
					then
						wget -q -O "${cache}.loteca.zip" "http://www1.caixa.gov.br/loterias/_arquivos/loterias/d_loteca.zip"
						$un_zip "${cache}.loteca.zip" "*.HTM" -d "$tmp_dir"
						mv -f "${tmp_dir}/D_LOTECA.HTM" ${cache}.loteca.htm
						zzdatafmt --iso hoje >> ${cache}.loteca.htm
						rm -f ${cache}.loteca.zip
					fi
					zztool dump ${cache}.loteca.htm |
					grep "^ *$num_con " 2>/dev/null |
					awk '{
						print "Concurso", $1, "(" $2 ")"
						print " Jogo   Resultado"
						printf "  1    %8s\n", "Col. " ($(NF-15)=="x"?"Meio":$(NF-15))
						printf "  2    %8s\n", "Col. " ($(NF-14)=="x"?"Meio":$(NF-14))
						printf "  3    %8s\n", "Col. " ($(NF-13)=="x"?"Meio":$(NF-13))
						printf "  4    %8s\n", "Col. " ($(NF-12)=="x"?"Meio":$(NF-12))
						printf "  5    %8s\n", "Col. " ($(NF-11)=="x"?"Meio":$(NF-11))
						printf "  6    %8s\n", "Col. " ($(NF-10)=="x"?"Meio":$(NF-10))
						printf "  7    %8s\n", "Col. " ($(NF-9)=="x"?"Meio":$(NF-9))
						printf "  8    %8s\n", "Col. " ($(NF-8)=="x"?"Meio":$(NF-8))
						printf "  9    %8s\n", "Col. " ($(NF-7)=="x"?"Meio":$(NF-7))
						printf " 10    %8s\n", "Col. " ($(NF-6)=="x"?"Meio":$(NF-6))
						printf " 11    %8s\n", "Col. " ($(NF-5)=="x"?"Meio":$(NF-5))
						printf " 12    %8s\n", "Col. " ($(NF-4)=="x"?"Meio":$(NF-4))
						printf " 13    %8s\n", "Col. " ($(NF-3)=="x"?"Meio":$(NF-3))
						printf " 14    %8s\n", "Col. " ($(NF-2)=="x"?"Meio":$(NF-2))
						print ""
						printf "  14 pts.\t%s\t%s\n", ($3==0?"Nao houve acertador":$3), ($3==0?"":"R$ " $(NF-21))
						printf "  13 pts.\t%s\t%s\n", $(NF-18), "R$ " $(NF-17)
					}'
				;;
			esac
			echo
		fi
	done
}

# ----------------------------------------------------------------------------
# zzlua
# http://www.lua.org/manual/5.1/pt/manual.html
# Lista de funções da linguagem Lua.
# com a opção -d ou --detalhe busca mais informação da função
# com a opção --atualiza força a atualização do cache local
#
# Uso: zzlua <palavra|regex>
# Ex.: zzlua --atualiza        # Força atualização do cache
#      zzlua file              # mostra as funções com "file" no nome
#      zzlua -d debug.debug    # mostra descrição da função debug.debug
#      zzlua ^d                # mostra as funções que começam com d
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-09
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzlua ()
{
	zzzz -h lua "$1" && return

	local url='http://www.lua.org/manual/5.1/pt/manual.html'
	local cache=$(zztool cache lua)
	local padrao="$*"

	# Força atualização da listagem apagando o cache
	if test "$1" = '--atualiza'
	then
		zztool atualiza lua
		shift
	fi

	# Se o cache está vazio, baixa listagem da Internet
	if ! test -s "$cache"
	then
		zztool dump "$url" |
		awk '
				$0  ~ /^$/  { branco++; if (branco == 3) { print "----------"; branco = 0 } }
				$0 !~ /^$/  { for (i=1;i<=branco;i++) { print "" }; print ; branco = 0 }
			' |
		sed -n '/^ *4\.1/,/^ *6/p' |
		sed '/^ *[4-6]/,/^ *[_-][_-][_-][_-]*$/{/^ *[_-][_-][_-][_-]*$/!d;}' > "$cache"
	fi

	if test "$1" = '-d' -o "$1" = '--detalhe'
	then
		# Detalhe de uma função específica
		if test -n "$2"
		then
			sed -n "/  *$2/,/^ *[_-][_-][_-][_-]*$/p" "$cache" |
			sed '/^ *[_-][_-][_-][_-]*$/d' | sed '$ { /^ *$/ d; }'
		fi
	elif test -n "$padrao"
	then
		# Busca a(s) função(ões)
		sed -n '/^ *[_-][_-][_-][_-]*$/,/^ *[a-z_]/p' "$cache" |
		sed '/^ *[_-][_-][_-][_-]*$/d;/^ *$/d;s/^  //g;s/\([^ ]\) .*$/\1/g' |
		grep -h -i -- "$padrao"
	else
		# Lista todas as funções
		sed -n '/^ *[_-][_-][_-][_-]*$/,/^ *[a-z_]/p' "$cache" |
		sed '/^ *[_-][_-][_-][_-]*$/d;/^ *$/d;s/\([^ ]\) .*$/\1/g'
	fi
}

# ----------------------------------------------------------------------------
# zzmacvendor
# Mostra o fabricante do equipamento utilizando o endereço MAC.
#
# Uso: zzmacvendor <MAC Address>
# Ex.: zzmacvendor 88:5A:92:C7:41:40
#      zzmacvendor 88-5A-92-C7-41-40
#
# Autor: Rafael S. Guimaraes, www.rafaelguimaraes.net
# Desde: 2016-02-03
# Versão: 3
# Licença: GPL
# Requisitos: zztestar zzcut zzdominiopais
# ----------------------------------------------------------------------------
zzmacvendor ()
{
	zzzz -h macvendor "$1" && return

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso macvendor; return 1; }

	local mac="$1"
	local fab end pais linha

	# Validação
	zztestar -e mac "$mac" || return 1

	mac=$(echo "$mac"  | tr -d ':-')

	local url="https://macvendors.co/api/$mac/pipe"
	zztool source "$url" |
	tr -s ' "' '  ' |
	zzcut -f 1,3,6 -d "|" | tr '|' '\n' |
	sed '2{s/,[^,]*$//;}' |
	while read linha
	do
		if test -z "$fab"
		then
			fab="$linha"
			echo 'Fabricante:' $fab
			continue
		fi
		if test -z "$end"
		then
			end="$linha"
			echo 'Endereço:  ' $end
			continue
		fi
		if test -z "$pais"
		then
			pais="$linha"
			echo 'País:      ' $(zzdominiopais ".$pais" | sed 's/.*- //')
		fi
	done
}

# ----------------------------------------------------------------------------
# zzmaiores
# Acha os maiores arquivos/diretórios do diretório atual (ou outros).
# Opções: -r  busca recursiva nos subdiretórios
#         -f  busca somente os arquivos e não diretórios
#         -n  número de resultados (o padrão é 10)
# Uso: zzmaiores [-r] [-f] [-n <número>] [dir1 dir2 ...]
# Ex.: zzmaiores
#      zzmaiores /etc /tmp
#      zzmaiores -r -n 5 ~
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2001-08-28
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzmaiores ()
{
	zzzz -h maiores "$1" && return

	local pastas recursivo modo tab resultado
	local limite=10

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-n)
				limite=$2
				shift; shift
			;;
			-f)
				modo='f'
				shift
				# Até queria fazer um -d também para diretórios somente,
				# mas o du sempre mostra os arquivos quando está recursivo
				# e o find não mostra o tamanho total dos diretórios...
			;;
			-r)
				recursivo=1
				shift
			;;
			*)
				break
			;;
		esac
	done

	if test "$modo" = 'f'
	then
		# Usuário só quer ver os arquivos e não diretórios.
		# Como o 'du' não tem uma opção para isso, usaremos o 'find'.

		# Se forem várias pastas, compõe a lista glob: {um,dois,três}
		# Isso porque o find não aceita múltiplos diretórios sem glob.
		# Caso contrário tenta $1 ou usa a pasta corrente "."
		if test -n "$2"
		then
			pastas=$(echo {$*} | tr -s ' ' ',')
		else
			pastas=${1:-.}
			test "$pastas" = '*' && pastas='.'
		fi

		tab=$(printf %b '\t')
		test -n "$recursivo" && recursivo= || recursivo='-maxdepth 1'

		resultado=$(
			find $pastas $recursivo -type f -ls |
				tr -s ' ' |
				cut -d' ' -f7,11- |
				sed "s/ /$tab/" |
				sort -nr |
				sed "$limite q"
		)
	else
		# Tentei de várias maneiras juntar o glob com o $@
		# para que funcionasse com o ponto e sem argumentos,
		# mas no fim é mais fácil chamar a função de novo...
		pastas="$@"
		if test -z "$pastas" -o "$pastas" = '.'
		then
			zzmaiores ${recursivo:+-r} -n $limite * .[^.]*
			return

		fi

		# O du sempre mostra arquivos e diretórios, bacana
		# Basta definir se vai ser recursivo (-a) ou não (-s)
		test -n "$recursivo" && recursivo='-a' || recursivo='-s'

		# Estou escondendo o erro para caso o * ou o .* não expandam
		# Bash2: nullglob, dotglob
		resultado=$(
			du $recursivo "$@" 2>/dev/null |
				sort -nr |
				awk '{if (NR==1 && $0 ~ /^[0-9]+[	 ]+total$/){} else print}' |
				sed "$limite q"
		)
	fi
	# TODO é K (nem é, só se usar -k -- conferir no SF) se vier do du e bytes se do find
	echo "$resultado"
	# | while read tamanho arquivo
	# do
	# 		echo -e "$(zzbyte $tamanho)\t$arquivo"
	# done
}

# ----------------------------------------------------------------------------
# zzmaiusculas
# Converte todas as letras para MAIÚSCULAS, inclusive acentuadas.
# Uso: zzmaiusculas [texto]
# Ex.: zzmaiusculas eu quero gritar                # via argumentos
#      echo eu quero gritar | zzmaiusculas         # via STDIN
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2003-06-12
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzmaiusculas ()
{
	zzzz -h maiusculas "$1" && return

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |

	sed '
		y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/
		y/àáâãäåèéêëìíîïòóôõöùúûüçñ/ÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÇÑ/'
}

# ----------------------------------------------------------------------------
# zzmariadb
# Lista alguns dos comandos já traduzidos do banco MariaDB, numerando-os.
# Pesquisa detalhe dos comando, ao fornecer o número na listagem a esquerda.
# E filtra a busca se fornecer um texto.
#
# Uso: zzmariadb [ código | filtro ]
# Ex.: zzmariadb        # Lista os comandos disponíveis
#      zzmariadb 18     # Consulta o comando DROP USER
#      zzmariadb alter  # Filtra os comandos que possuam alter na declaração
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-07-03
# Versão: 4
# Licença: GPL
# Requisitos: zzminusculas zzsemacento zztrim
# ----------------------------------------------------------------------------
zzmariadb ()
{
	zzzz -h mariadb "$1" && return

	local url='https://kb.askmonty.org/pt-br'
	local cache=$(zztool cache mariadb)
	local comando

	if test "$1" = "--atualiza"
	then
		zztool atualiza mariadb
		shift
	fi

	if ! test -s "$cache"
	then
		zztool dump "${url}/mariadb-brazilian-portuguese/" |
			sed -n '/^\( *\* \)\{0,1\}[A-Z]\{4,\}/p' |
			sed 's/  *\* *//' |
			awk '{print NR, $0}'> "$cache"
	fi

	if test -n "$1"
	then
		if zztool testa_numero "$1"
		then
			comando=$(
				sed -n "${1}p" "$cache" |
					sed "
						s/^${1} //
						s| / |-|g
						s/ - /-/g
						s/ /-/g
						s/\.//g
					" |
					zzminusculas |
					zzsemacento
			)
			zztool dump "${url}/${comando}/" |
				sed -n '/^ *Localized Versions/,/\* ←/ p' |
				sed '
					1d
					2d
					/^  *\*.*\]$/d
					/^ *Tweet */d
					/^ *\* *$/d
					$d
				' |
				zztrim -V
		else
			grep -i "$1" "$cache"
		fi
	else
		cat "$cache"
	fi
}

# ----------------------------------------------------------------------------
# zzmat
# Uma coletânea de funções matemáticas simples.
# Se o primeiro argumento for um '-p' seguido de número sem espaço
# define a precisão dos resultados ( casas decimais ), o padrão é 6
# Em cada função foi colocado um pequeno help um pouco mais detalhado,
# pois ficou muito extenso colocar no help do zzmat apenas.
#
# Funções matemáticas disponíveis.
# Aritméticas:               | Trigonométricas:
#  mmc    mdc                |  sen   cos   tan
#  media  soma  produto      |  csc   sec   cot
#  log    ln    raiz         |  asen  acos  atan
#  somatoria    produtoria
#  pow, potencia ou elevado
#
# Combinatória:        | Sequências:          | Funções:
#  fat                 |  pa  pa2  pg  lucas  |  area  volume  r3
#  arranjo  arranjo_r  |  fibonacci  ou fib   |  det   vetor   d2p
#  combinacao          |  tribonacci ou trib
#  combinacao_r        |  mersenne  recaman  collatz
#
# Equações:                  | Auxiliares:
#  eq2g  egr    err          |  abs  int
#  egc   egc3p  ege          |  sem_zeros
#  newton ou binomio_newton  |  aleatorio  random
#  conf_eq                   |  compara_num
#
# Mais detalhes: zzmat função
#
# Uso: zzmat [-pnumero] funções [número] [número]
# Ex.: zzmat mmc 8 12
#      zzmat media 5[2] 7 4[3]
#      zzmat somatoria 3 9 2x+3
#      zzmat -p3 sen 60g
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2011-01-19
# Versão: 23
# Licença: GPL
# Requisitos: zzcalcula zzseq zzaleatorio zztrim zzconverte zztestar
# ----------------------------------------------------------------------------
zzmat ()
{
	zzzz -h mat "$1" && return

	local funcao num precisao
	local pi=3.1415926535897932384626433832795
	local LANG=en

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso mat; return 1; }

	# Definindo a precisão dos resultados qdo é pertinente. Padrão é 6.
	echo "$1" | grep '^-p' >/dev/null
	if test "$?" = "0"
	then
		precisao="${1#-p}"
		zztestar numero $precisao || precisao="6"
		shift
	else
		precisao="6"
	fi

	funcao="$1"

	# Atalhos para funções pow e fat, usando operadores unários
	if zztool grep_var '^' "$funcao" && zztestar numero_real "${funcao%^*}" && zztestar numero_real "${funcao#*^}"
	then
		zzmat -p${precisao} pow "${funcao%^*}" "${funcao#*^}"
		return
	elif zztool grep_var '!' "$funcao" && zztestar numero "${funcao%\!}"
	then
		zzmat -p${precisao} fat "${funcao%\!}" $2
		return
	fi

	case "$funcao" in
	sem_zeros)
		# Elimina o zeros nao significativos
		local num1
		shift
		num1=$(zztool multi_stdin "$@" | tr ',' '.')
		num1=$(echo "$num1" | sed 's/^[[:blank:].0]*$/zero/;s/^[[:blank:]0]*//;s/zero/0/')
		if test $precisao -gt 0
			then
			echo "$num1" | grep '\.' > /dev/null
			if test "$?" = "0"
			then
				num1=$(echo "$num1" | sed 's/[0[:blank:]]*$//' | sed 's/\.$//')
			fi
		fi
		num1=$(echo "$num1" | sed 's/^\./0\./')
		echo "$num1"
	;;
	compara_num)
		if test $# -eq "3" && zztestar numero_real $2 && zztestar numero_real $3
		then
			local num1 num2
			num1=$(echo "$2" | tr ',' '.')
			num2=$(echo "$3" | tr ',' '.')
			echo "$num1 $num2" |
			awk '
				$1 > $2  { print "maior" }
				$1 == $2 { print "igual" }
				$1 < $2  { print "menor" }
			'
		else
			zztool erro " zzmat $funcao: Compara 2 numeros"
			zztool erro " Retorna o texto 'maior', 'menor' ou 'igual'"
			zztool erro " Uso: zzmat $funcao numero numero"
			return 1
		fi
	;;
	int)
		local num1
		if test "$2" = "-h"
		then
			zztool erro " zzmat $funcao: Valor Inteiro"
			zztool erro " Uso: zzmat $funcao numero"
			zztool erro "      echo numero | zzmat $funcao"
			return
		fi
		shift
		num1=$(zztool multi_stdin "$@" | tr ',' '.')
		if zztestar numero_real $num1
		then
			echo $num1 | sed 's/\..*$//'
		fi
	;;
	abs)
		local num1
		if test "$2" = "-h"
		then
			zztool erro " zzmat $funcao: Valor Absoluto"
			zztool erro " Uso: zzmat $funcao numero"
			zztool erro "      echo numero | zzmat $funcao"
			return
		fi
		shift
		num1=$(zztool multi_stdin "$@" | tr ',' '.')
		if zztestar numero_real $num1
		then
			echo "$num1" | sed 's/^[-+]//'
		fi
	;;
	sen | cos | tan | csc | sec | cot)
		if test $# -eq "2"
		then
			local num1 num2 ang
			num1=$(echo "$2" | sed 's/g$//; s/gr$//; s/rad$//' | tr , .)
			ang=$(echo "$2" | tr -d -c '[grad]')
			echo "$2" | grep -E '(g|rad|gr)$' >/dev/null
			if test "$?" -eq "0" && zztestar numero_real $num1
			then
				case $ang in
				g)   num2=$(zzconverte -p$((precisao+2)) gr $num1);;
				gr)  num2=$(zzconverte -p$((precisao+2)) ar $num1);;
				rad) num2=$num1;;
				esac

				case $funcao in
				sen) num1="scale=${precisao};s(${num2})" ;;
				cos) num1="scale=${precisao};c(${num2})" ;;
				tan)
					num1="scale=${precisao};if (c(${num2})) {s(${num2})/c(${num2})}" ;;
				sec)
					num1="scale=${precisao};if (c(${num2})) {1/c(${num2})}" ;;
				csc)
					num1="scale=${precisao};if (s(${num2})) {1/s(${num2})}" ;;
				cot)
					num1="scale=${precisao};if (s(${num2})) {c(${num2})/s(${num2})}" ;;
				esac

				test -n "$num1" && num="$num1"
			else
				echo " Uso: zzmat $funcao número(g|rad|gr) {graus|radianos|grado}"
			fi
		else
			zztool erro " zzmat Função Trigonométrica:
	sen: Seno
	cos: Cosseno
	tan: Tangente
	sec: Secante
	csc: Cossecante
	cot: Cotangente"
			zztool erro " Uso: zzmat $funcao número(g|rad|gr) {graus|radianos|grado}"
			return 1
		fi
	;;
	asen | acos | atan)
		if test $# -ge "2" && test $# -le "4" && zztestar numero_real $2
		then
			local num1 num2 num3 sinal
			num1=$(echo "$2" | tr ',' '.')
			test "$funcao" != "atan" && num2=$(awk 'BEGIN {if ('$num1'>1 || '$num1'<-1) print "erro"}')
			if test "$num2" = "erro"
			then
				zzmat $funcao -h >&2;return 1
			fi

			echo "$num1" | grep '^-' >/dev/null && sinal="-" || unset sinal
			num1=$(zzmat abs $num1)

			case $funcao in
			atan)
				num2=$(echo "a(${num1})" | bc -l)
				test -n "$sinal" && num2=$(echo "($pi)-($num2)" | bc -l)
				echo "$4" | grep '2' >/dev/null && num2=$(echo "($num2)+($pi)" | bc -l)
			;;
			asen)
				num3=$(echo "sqrt(1-${num1}^2)" | bc -l | awk '{printf "%.'${precisao}'f\n", $1}')
				if test "$num3" = $(printf '%.'${precisao}'f' 0 | tr ',' '.')
				then
					num2=$(echo "$pi/2" | bc -l)
				else
					num2=$(echo "a(${num1}/sqrt(1-${num1}^2))" | bc -l)
				fi
				echo "$4" | grep '2' >/dev/null && num2=$(echo "($pi)-($num2)" | bc -l)
				test -n "$sinal" && num2=$(echo "($pi)+($num2)" | bc -l)
			;;
			acos)
				num3=$(echo "$num1" | bc -l | awk '{printf "%.'${precisao}'f\n", $1}')
				if test "$num3" = $(printf '%.'${precisao}'f' 0 | tr ',' '.')
				then
					num2=$(echo "$pi/2" | bc -l)
				else
					num2=$(echo "a(sqrt(1-${num1}^2)/${num1})" | bc -l)
				fi
				test -n "$sinal" && num2=$(echo "($pi)-($num2)" | bc -l)
				echo "$4" | grep '2' >/dev/null && num2=$(echo "2*($pi)-($num2)" | bc -l)
			;;
			esac

			echo "$4" | grep 'r' >/dev/null && num2=$(echo "($num2)-2*($pi)" | bc -l)

			case $3 in
			g)        num=$(zzconverte -p$((precisao+2)) rg $num2);;
			gr)       num=$(zzconverte -p$((precisao+2)) ra $num2);;
			rad | "") num="$num2";;
			esac
		else
			zztool erro " zzmat Função Trigonométrica:
	asen: Arco-Seno
	acos: Arco-Cosseno
	atan: Arco-Tangente"
			zztool erro " Retorna o angulo em radianos, graus ou grado."
			zztool erro " Se não for definido retorna em radianos."
			zztool erro " Valores devem estar entre -1 e 1, para arco-seno e arco-cosseno."
			zztool erro " Caso a opção seja '2' retorna o segundo ângulo possível do valor."
			zztool erro " E se for 'r' retorna o ângulo no sentido invertido (replementar)."
			zztool erro " As duas opções poder ser combinadas: r2 ou 2r."
			zztool erro " Uso: zzmat $funcao número [[g|rad|gr] [opção]]"
			return 1
		fi
	;;
	log | ln)
		if test $# -ge "2" && test $# -le "3" && zztestar numero_real $2
		then
			local num1 num2
			num1=$(echo "$2" | tr ',' '.')
			zztestar numero_real "$3" && num2=$(echo "$3" | tr ',' '.')
			if test -n "$num2"
			then
				num="l($num1)/l($num2)"
			elif test "$funcao" = "log"
			then
				num="l($num1)/l(10)"
			else
				num="l($num1)"
			fi
		else
			zztool erro " Se não definir a base no terceiro argumento:"
			zztool erro " zzmat log: Logaritmo base 10"
			zztool erro " zzmat ln: Logaritmo Natural base e"
			zztool erro " Uso: zzmat $funcao numero [base]"
			return 1
		fi
	;;
	raiz)
		if test $# -eq "3" && zztestar numero_real "$3"
		then
			local num1 num2
			case "$2" in
			quadrada)  num1=2;;
			c[úu]bica) num1=3;;
			*)         num1="$2";;
			esac
			num2=$(echo "$3" | tr ',' '.')
			if test $(($num1 % 2)) -eq 0
			then
				if echo "$num2" | grep '^-' > /dev/null
				then
					zztool erro " Não há solução nos números reais para radicando negativo e índice par."
					return 1
				fi
			fi
			if zztestar numero_real $num1
			then
				num=$(awk 'BEGIN {printf "%.'${precisao}'f\n", '$num2'^(1/'$num1')}')
			else
				echo " Uso: zzmat $funcao <quadrada|cubica|numero> numero"
			fi
		else
			zztool erro " zzmat $funcao: Raiz enesima de um número"
			zztool erro " Uso: zzmat $funcao <quadrada|cubica|numero> numero"
			return 1
		fi
	;;
	potencia | elevado | pow)
		if test $# -eq "3" && zztestar numero_real "$2" && zztestar numero_real "$3"
		then
			local num1 num2
			num1=$(echo "$2" | tr ',' '.')
			num2=$(echo "$3" | tr ',' '.')
			if zztestar numero $num2
			then
				num=$(echo "scale=${precisao};${num1}^${num2}" | bc -l | awk '{ printf "%.'${precisao}'f\n", $1 }')
			else
				num=$(awk 'BEGIN {printf "%.'${precisao}'f\n", ('$num1')^('$num2')}')
			fi
		else
			zztool erro " zzmat $funcao: Um número elevado a um potência"
			zztool erro " Uso: zzmat $funcao número potência"
			zztool erro " Uso: zzmat número^potência"
			zztool erro " Ex.: zzmat $funcao 4 3"
			zztool erro " Ex.: zzmat 3^7"
			return 1
		fi
	;;
	area)
		if test $# -ge "2"
		then
			local num1 num2 num3
			case "$2" in
			triangulo)
				if zztestar numero_real $3 && zztestar numero_real $4
				then
					num1=$(echo "$3" | tr ',' '.')
					num2=$(echo "$4" | tr ',' '.')
					num="${num1}*${num2}/2"
				else
					zztool erro " Uso: zzmat $funcao $2 base altura";return 1
				fi
			;;
			retangulo | losango)
				if zztestar numero_real $3 && zztestar numero_real $4
				then
					num1=$(echo "$3" | tr ',' '.')
					num2=$(echo "$4" | tr ',' '.')
					num="${num1}*${num2}"
				else
					printf " Uso: zzmat %s %s " $funcao $2 >&2
					test "$2" = "retangulo" && echo "base altura" >&2 || echo "diagonal_maior diagonal_menor" >&2
					return 1
				fi
			;;
			trapezio)
				if zztestar numero_real $3 && zztestar numero_real $4 && zztestar numero_real $5
				then
					num1=$(echo "$3" | tr ',' '.')
					num2=$(echo "$4" | tr ',' '.')
					num3=$(echo "$5" | tr ',' '.')
					num="((${num1}+${num2})/2)*${num3}"
				else
					zztool erro " Uso: zzmat $funcao $2 base_maior base_menor altura";return 1
				fi
			;;
			toro)
				if zztestar numero_real $3 && zztestar numero_real $4 && test $(zzmat compara_num $3 $4) != "igual"
				then
					num1=$(echo "$3" | tr ',' '.')
					num2=$(echo "$4" | tr ',' '.')
					num="4*${pi}^2*${num1}*${num2}"
				else
					zztool erro " Uso: zzmat $funcao $2 raio1 raio2";return 1
				fi
			;;
			tetraedro | cubo | octaedro | dodecaedro | icosaedro | quadrado | circulo | esfera | cuboctaedro | rombicuboctaedro | rombicosidodecaedro | icosidodecaedro)
				if test -n "$3"
				then
					if zztestar numero_real $3
					then
						num1=$(echo "$3" | tr ',' '.')
						case $2 in
						tetraedro)           num="sqrt(3)*${num1}^2";;
						cubo)                num="6*${num1}^2";;
						octaedro)            num="sqrt(3)*2*${num1}^2";;
						dodecaedro)          num="sqrt(25+10*sqrt(5))*3*${num1}^2";;
						icosaedro)           num="sqrt(3)*5*${num1}^2";;
						quadrado)            num="${num1}^2";;
						circulo)             num="$pi*(${num1})^2";;
						esfera)              num="4*$pi*(${num1})^2";;
						cuboctaedro)         num="(6+2*sqrt(3))*${num1}^2";;
						rombicuboctaedro)    num="2*(9+sqrt(3))*${num1}^2";;
						icosidodecaedro)     num="(5*sqrt(3)+3*sqrt(5)*sqrt(5+2*sqrt(5)))*${num1}^2";;
						rombicosidodecaedro) num="(30+sqrt(30*(10+3*sqrt(5)+sqrt(15*(2+2*sqrt(5))))))*${num1}^2";;
						esac
					elif test $3 = "truncado" && zztestar numero_real $4
					then
						num1=$(echo "$4" | tr ',' '.')
						case $2 in
						tetraedro)       num="7*sqrt(3)*${num1}^2";;
						cubo)            num="2*${num1}^2*(6+6*sqrt(2)+6*sqrt(3))";;
						octaedro)        num="(6+sqrt(3)*12)*${num1}^2";;
						dodecaedro)      num="(sqrt(3)+6*sqrt(5+2*sqrt(5)))*5*${num1}^2";;
						icosaedro)       num="3*(10*sqrt(3)+sqrt(5)*sqrt(5+2*sqrt(5)))*${num1}^2";;
						cuboctaedro)     num="12*(2+sqrt(2)+sqrt(3))*${num1}^2";;
						icosidodecaedro) num="30*(1+sqrt(2*sqrt(4+sqrt(5)+sqrt(15+6*sqrt(6)))))*${num1}^2";;
						esac
					elif test $3 = "snub" && zztestar numero_real $4
					then
						num1=$(echo "$4" | tr ',' '.')
						case $2 in
						cubo)       num="${num1}^2*(6+8*sqrt(3))";;
						dodecaedro) num="55.286744956*${num1}^2";;
						esac
					else
						zztool erro " Uso: zzmat $funcao $2 lado|raio";return 1
					fi
				else
					zztool erro " Uso: zzmat $funcao $2 lado|raio";return 1
				fi
			;;
			esac
		else
			zztool erro " zzmat $funcao: Cálculo da área de figuras planas e superfícies"
			zztool erro " Uso: zzmat area <triangulo|quadrado|retangulo|losango|trapezio|circulo> numero"
			zztool erro " Uso: zzmat area <esfera|rombicuboctaedro|rombicosidodecaedro> numero"
			zztool erro " Uso: zzmat area <tetraedo|cubo|octaedro|dodecaedro|icosaedro|cuboctaedro|icosidodecaedro> [truncado] numero"
			zztool erro " Uso: zzmat area <cubo|dodecaedro> snub numero"
			zztool erro " Uso: zzmat area toro numero numero"
			return 1
		fi
	;;
	volume)
		if test $# -ge "2"
		then
			local num1 num2 num3
			case "$2" in
			paralelepipedo)
				if zztestar numero_real $3 && zztestar numero_real $4 && zztestar numero_real $5
				then
					num1=$(echo "$3" | tr ',' '.')
					num2=$(echo "$4" | tr ',' '.')
					num3=$(echo "$5" | tr ',' '.')
					num="${num1}*${num2}*${num3}"
				else
					zztool erro " Uso: zzmat $funcao $2 comprimento largura altura";return 1
				fi
			;;
			cilindro)
				if zztestar numero_real $3 && zztestar numero_real $4
				then
					num1=$(echo "$3" | tr ',' '.')
					num2=$(echo "$4" | tr ',' '.')
					num="($pi*(${num1})^2)*${num2}"
				else
					zztool erro " Uso: zzmat $funcao $2 raio altura";return 1
				fi
			;;
			cone)
				if zztestar numero_real $3 && zztestar numero_real $4
				then
					num1=$(echo "$3" | tr ',' '.')
					num2=$(echo "$4" | tr ',' '.')
					num="($pi*(${num1})^2)*${num2}/3"
				else
					zztool erro " Uso: zzmat $funcao $2 raio altura";return 1
				fi
			;;
			prisma)
				if zztestar numero_real $3 && zztestar numero_real $4
				then
					num1=$(echo "$3" | tr ',' '.')
					num2=$(echo "$4" | tr ',' '.')
					num="${num1}*${num2}"
				else
					zztool erro " Uso: zzmat $funcao $2 area_base altura";return 1
				fi
			;;
			piramide)
				if zztestar numero_real $3 && zztestar numero_real $4
				then
					num1=$(echo "$3" | tr ',' '.')
					num2=$(echo "$4" | tr ',' '.')
					num="${num1}*${num2}/3"
				else
					zztool erro " Uso: zzmat $funcao $2 area_base altura";return 1
				fi
			;;
			toro)
				local num_maior num_menor
				if zztestar numero_real $3 && zztestar numero_real $4 && test $(zzmat compara_num $3 $4) != "igual"
				then
					num1=$(echo "$3" | tr ',' '.')
					num2=$(echo "$4" | tr ',' '.')
					test $num1 -gt $num2 && num_maior=$num1 || num_maior=$num2
					test $num1 -lt $num2 && num_menor=$num1 || num_menor=$num2
					num="2*${pi}^2*${num_menor}^2*${num_maior}"
				else
					zztool erro " Uso: zzmat $funcao $2 raio1 raio2";return 1
				fi
			;;
			tetraedro | cubo | octaedro | dodecaedro | icosaedro | esfera | cuboctaedro | rombicuboctaedro | rombicosidodecaedro | icosidodecaedro)
				if test -n "$3"
				then
					if zztestar numero_real $3
					then
						num1=$(echo "$3" | tr ',' '.')
						case $2 in
						tetraedro)           num="sqrt(2)/12*${num1}^3";;
						cubo)                num="${num1}^3";;
						octaedro)            num="sqrt(2)/3*${num1}^3";;
						dodecaedro)          num="(15+7*sqrt(5))*${num1}^3/4";;
						icosaedro)           num="(3+sqrt(5))*${num1}^3*5/12";;
						esfera)              num="$pi*(${num1})^3*4/3";;
						cuboctaedro)         num="5/3*sqrt(2)*${num1}^3";;
						rombicuboctaedro)    num="(2*(6+5*sqrt(2))*${num1}^3)/3";;
						icosidodecaedro)     num="((45+17*sqrt(5))*${num1}^3)/6";;
						rombicosidodecaedro) num="(60+29*sqrt(5))/3*${num1}^3";;
						esac
					elif test $3 = "truncado" && zztestar numero_real $4
					then
						num1=$(echo "$4" | tr ',' '.')
						case $2 in
						tetraedro)       num="23*sqrt(2)/12*${num1}^3";;
						cubo)            num="(7*${num1}^3*(3+2*sqrt(2)))/3";;
						octaedro)        num="8*sqrt(2)*${num1}^3";;
						dodecaedro)      num="5*(99+47*sqrt(5))/12*${num1}^3";;
						icosaedro)       num="(125+43*sqrt(5))*${num1}^3*1/4";;
						cuboctaedro)     num="(22+14*sqrt(2))*${num1}^3";;
						icosidodecaedro) num="(90+50*sqrt(5))*${num1}^3";;
						esac
					elif test $3 = "snub" && zztestar numero_real $4
					then
						num1=$(echo "$4" | tr ',' '.')
						case $2 in
						cubo)       num="7.8894774*${num1}^3";;
						dodecaedro) num="37.61664996*${num1}^3";;
						esac
					else
						zztool erro " Uso: zzmat $funcao $2 lado|raio";return 1
					fi
				else
					zztool erro " Uso: zzmat $funcao $2 lado|raio";return 1
				fi
			;;
			esac
		else
			zztool erro " zzmat $funcao: Cálculo de volume de figuras geométricas"
			zztool erro " Uso: zzmat volume <paralelepipedo|cilindro|esfera|cone|prisma|piramide|rombicuboctaedro|rombicosidodecaedro> numero"
			zztool erro " Uso: zzmat volume <tetraedo|cubo|octaedro|dodecaedro|icosaedro|cuboctaedro|icosidodecaedro> [truncado] numero"
			zztool erro " Uso: zzmat volume <cubo|dodecaedro> snub numero"
			zztool erro " Uso: zzmat volume toro numero numero"
			return 1
		fi
	;;
	mmc | mdc)
		if test $# -ge "3"
		then
			local num_maior num_menor resto mdc mmc num2
			local num1=$2
			shift
			shift
			for num2 in $*
			do
				if zztestar numero $num1 && zztestar numero $num2
				then
					test "$num1" -gt "$num2" && num_maior=$num1 || num_maior=$num2
					test "$num1" -lt "$num2" && num_menor=$num1 || num_menor=$num2

					while test "$num_menor" -ne "0"
					do
						resto=$((${num_maior}%${num_menor}))
						num_maior=$num_menor
						num_menor=$resto
					done

					mdc=$num_maior
					mmc=$((${num1}*${num2}/${mdc}))
				fi
				shift
				test "$funcao" = "mdc" && num1="$mdc" || num1="$mmc"
			done

			case $funcao in
			mmc) echo "$mmc";;
			mdc) echo "$mdc";;
			esac
		else
			zztool erro " zzmat mmc: Menor Múltiplo Comum"
			zztool erro " zzmat mdc: Maior Divisor Comum"
			zztool erro " Uso: zzmat $funcao numero numero ..."
			return 1
		fi
	;;
	somatoria | produtoria)
		#colocar x como a variavel a ser substituida
		if test $# -eq "4"
		then
			zzmat $funcao $2 $3 1 $4
		elif test $# -eq "5" && zztestar numero_real $2 && zztestar numero_real $3 && zztestar numero_real $4 && zztool grep_var "x" $5
		then
			local equacao numero operacao sequencia num1 num2
			equacao=$(echo "$5" | sed 's/\[/(/g;s/\]/)/g')
			test "$funcao" = "somatoria" && operacao='+' || operacao='*'
			if test $(zzmat compara_num $2 $3) = 'maior'
			then
				num1=$2; num2=$3
			else
				num1=$3; num2=$2
			fi
			sequencia=$(zzmat pa $num2 $4 $(zzcalcula "(($num1 - $num2)/$4)+1" | zzmat int) | tr ' ' '\n')
			num=$(for numero in $sequencia
			do
				echo "($equacao)" | sed "s/^[x]/($numero)/;s/\([(+-]\)x/\1($numero)/g;s/\([0-9]\)x/\1\*($numero)/g;s/x/$numero/g"
			done | paste -s -d"$operacao" -)
		else
			zztool erro " zzmat $funcao: Soma ou Produto de expressão"
			zztool erro " Uso: zzmat $funcao limite_inferior limite_superior equacao"
			zztool erro " Uso: zzmat $funcao limite_inferior limite_superior razao equacao"
			zztool erro " Usar 'x' como variável na equação"
			zztool erro " Usar '[' e ']' respectivamente no lugar de '(' e ')', ou proteger"
			zztool erro " a fórmula com aspas duplas(\") ou simples(')"
			return 1
		fi
	;;
	media | soma | produto)
		if test $# -ge "2"
		then
			local soma=0
			local qtde=0
			local produto=1
			local peso=1
			local valor
			shift
			while test $# -ne "0"
			do
				if zztool grep_var "[" "$1" && zztool grep_var "]" "$1"
				then
					valor=$(echo "$1" | sed 's/\([0-9]\{1,\}\)\[.*/\1/' | tr ',' '.')
					peso=$(echo "$1" | sed 's/.*\[//;s/\]//')
					if zztestar numero_real "$valor" && zztestar numero "$peso"
					then
						if test $funcao = 'produto'
						then
							produto=$(echo "$produto*(${valor}^${peso})" | bc -l)
						else
							soma=$(echo "$soma+($valor*$peso)" | bc -l)
							qtde=$(($qtde+$peso))
						fi
					fi
				elif zztestar numero_real "$1"
				then
					if test $funcao = 'produto'
					then
						produto=$(echo "($produto) * ($1)" | tr ',' '.' | bc -l)
					else
						soma=$(echo "($soma) + ($1)" | tr ',' '.' | bc -l)
						qtde=$(($qtde+1))
					fi
				else
					zztool -e uso mat; return 1;
				fi
				shift
			done

			case "$funcao" in
			media)   num="${soma}/${qtde}";;
			soma)    num="${soma}";;
			produto) num="${produto}";;
			esac
		else
			zztool erro " zzmat $funcao:Soma, Produto ou Média Aritimética e Ponderada"
			zztool erro " Uso: zzmat $funcao numero[[peso]] [numero[peso]] ..."
			zztool erro " Usar o peso entre '[' e ']', justaposto ao número."
			return 1
		fi
	;;
	fat)
		if test $# -eq "2" -o $# -eq "3" && zztestar numero "$2" && test "$2" -ge "1"
		then
			local num1 num2
			if test "$3" = "s"
			then
				num1=$(zzseq $2)
			else
				num1="$2"
			fi
			for num2 in $(echo "$num1")
			do
				echo "define fat(x) { if (x <= 1) return (1); return (fat(x-1) * x); }; fat($num2)" |
				bc |
				tr -d '\\\n' |
				zztool nl_eof
			done |
			tr '\n' ' ' |
			zztrim |
			zztool nl_eof
		else
			zztool erro " zzmat $funcao: Resultado do produto de 1 ao numero atual (fatorial)"
			zztool erro " Com o argumento 's' imprime a sequência até a posição."
			zztool erro " Uso: zzmat $funcao numero [s]"
			zztool erro " Uso: zzmat numero! [s]"
			zztool erro " Ex.: zzmat $funcao 4"
			zztool erro "      zzmat 5!"
			return 1
		fi
	;;
	arranjo | combinacao | arranjo_r | combinacao_r)
		if test $# -eq "3" && zztestar numero "$2" && zztestar numero "$3" && test "$2" -ge "$3" && test "$3" -ge "1"
		then
			local n p dnp
			n=$(zzmat fat $2)
			p=$(zzmat fat $3)
			dnp=$(zzmat fat $(($2-$3)))
			case "$funcao" in
			arranjo)    test "$2" -gt "$3" && num="${n}/${dnp}" || return 1;;
			arranjo_r)  zzmat elevado "$2" "$3";;
			combinacao) test "$2" -gt "$3" && num="${n}/(${p}*${dnp})" || return 1;;
			combinacao_r)
				if test "$2" -gt "$3"
				then
					n=$(zzmat fat $(($2+$3-1)))
					dnp=$(zzmat fat $(($2-1)))
					num="${n}/(${p}*${dnp})"
				else
					return 1
				fi
			;;
			esac
		else
			zztool erro " zzmat arranjo: n elementos tomados em grupos de p (considera ordem)"
			zztool erro " zzmat arranjo_r: n elementos tomados em grupos de p com repetição (considera ordem)"
			zztool erro " zzmat combinacao: n elementos tomados em grupos de p (desconsidera ordem)"
			zztool erro " zzmat combinacao_r: n elementos tomados em grupos de p com repetição (desconsidera ordem)"
			zztool erro " Uso: zzmat $funcao total_numero quantidade_grupo"
			return 1
		fi
	;;
	newton | binomio_newton)
		if test "$#" -ge "2"
		then
			local num1 num2 grau sinal parcela coeficiente
			num1="a"
			num2="b"
			sinal="+"
			zztestar numero "$2" && grau="$2"
			if test -n "$3"
			then
				if test "$3" = "+" -o "$3" = "-"
				then
					sinal="$3"
					test -n "$4" && num1="$4"
					test -n "$5" && num2="$5"
				else
					test -n "$3" && num1="$3"
					test -n "$4" && num2="$4"
				fi
			fi
			echo "($num1)^$grau"
			for parcela in $(zzseq $((grau-1)))
			do
				coeficiente=$(zzmat combinacao $grau $parcela)
				test "$sinal" = "-" -a $((parcela%2)) -eq 1 && printf "%s" "- " || printf "%s" "+ "
				printf "%s * " "$coeficiente"
				echo "($num1)^$(($grau-$parcela)) * ($num2)^$parcela" | sed 's/\^1\([^0-9]\)/\1/g;s/\^1$//'
			done
			test "$sinal" = "-" -a $((grau%2)) -eq 1 && printf "%s" "- " || printf "%s" "+ "
			echo "($num2)^$grau"
		else
			echo " zzmat $funcao: Exibe o desdobramento do binônimo de Newton."
			echo " Exemplo no grau 3: (a + b)^3 = a^3 + 2a^2b + 2ab^2 + b^3"
			echo " Se nenhum sinal for especificado será assumido '+'"
			echo " Se não declarar variáveis serão assumidos 'a' e 'b'"
			echo " Uso: zzmat $funcao grau [+|-] [variavel(a) [variavel(b)]]"
		fi
	;;
	pa | pa2 | pg)
		if test $# -eq "4" && zztestar numero_real "$2" && zztestar numero_real "$3" && zztestar numero "$4"
		then
			local num_inicial razao passo valor
			num_inicial=$(echo "$2" | tr ',' '.')
			razao=$(echo "$3" | tr ',' '.')
			passo=0
			valor=$num_inicial
			while (test $passo -lt $4)
			do
				if test "$funcao" = "pa"
				then
					valor=$(echo "$num_inicial + ($razao * $passo)" | bc -l |
					awk '{printf "%.'${precisao}'f\n", $1}')
				elif test "$funcao" = "pa2"
				then
					valor=$(echo "$valor + ($razao * $passo)" | bc -l |
					awk '{printf "%.'${precisao}'f\n", $1}')
				else
					valor=$(echo "$num_inicial * $razao^$passo" | bc -l |
					awk '{printf "%.'${precisao}'f\n", $1}')
				fi
				valor=$(echo "$valor" | zzmat -p${precisao} sem_zeros)
				test $passo -lt $(($4 - 1)) && printf "%s " "$valor" || printf "%s" "$valor"
				passo=$(($passo+1))
			done
			echo
		else
			zztool erro " zzmat pa:  Progressão Aritmética"
			zztool erro " zzmat pa2: Progressão Aritmética de Segunda Ordem"
			zztool erro " zzmat pg:  Progressão Geométrica"
			zztool erro " Uso: zzmat $funcao inicial razao quantidade_elementos"
			return 1
		fi
	;;
	fibonacci | fib | lucas)
	# Sequência ou número de fibonacci
		if zztestar numero "$2"
		then
			awk 'BEGIN {
					seq = ( "'$3'" == "s" ? 1 : 0 )
					num1 = ( "'$funcao'" == "lucas" ? 2 : 0 )
					num2 = 1
					for ( i = 0; i < '$2' + seq; i++ ) {
						if ( seq == 1 ) { printf "%s ", num1 }
						num3 = num1 + num2
						num1 = num2
						num2 = num3
					}
					if ( seq != 1 ) { printf "%s ", num1 }
				}' |
				zztrim -r |
				zztool nl_eof
		else
			echo " Número de Fibonacci ou Lucas na posição especificada."
			echo " Com o argumento 's' imprime a sequência até a posição."
			echo " Uso: zzmat $funcao <número> [s]"
		fi
	;;
	tribonacci | trib)
	# Sequência ou número Tribonacci
		if zztestar numero "$2"
		then
			awk 'BEGIN {
					seq = ( "'$3'" == "s" ? 1 : 0 )
					num1 = 0
					num2 = 0
					num3 = 1
					for ( i = 0; i < '$2' + seq; i++ ) {
						if ( seq == 1 ) { printf "%s ", num1 }
						num4 = num1 + num2 + num3
						num1 = num2
						num2 = num3
						num3 = num4
					}
					if ( seq != 1 ) { printf "%s ", num1 }
				}' |
				zztrim -r |
				zztool nl_eof
		else
			echo " Número de Tribonacci na posição especificada."
			echo " Com o argumento 's' imprime a sequência até a posição."
			echo " Uso: zzmat $funcao <número> [s]"
		fi
	;;
	recaman)
	# Sequência ou número Recamán
		if zztestar numero "$2"
		then
			awk 'BEGIN {
					seq = ( "'$3'" == "s" ? 1 : 0 )
					a[0]=0; b[0]=0
					for ( i = 1; i <= '$2'; i++ ) {
						num=a[i-1]
						a[i] = ((num > i && ! ((num - i) in b)) ? num - i : num + i)
						b[a[i]]=i
					}
					if ( seq ) { for (i=0; i<length(a); i++) printf "%d ", a[i] }
					else { print a[length(a)-1] }
				}' |
				zztrim -r |
				zztool nl_eof
		else
			echo " Número de Recamán na posição especificada."
			echo " Com o argumento 's' imprime a sequência até a posição."
			echo " Uso: zzmat $funcao <número> [s]"
		fi
	;;
	mersenne)
	# Sequência ou número de Mersenne
		if zztestar numero "$2"
		then
			zzseq -f '2^%d-1\n' 0 $2 |
			bc |
			awk '{ if ($0 ~ /\\$/) { sub(/\\/,""); printf $0 } else { print } }' |
			if test "s" = "$3"
			then
				zztool lines2list | zztool nl_eof
			else
				sed -n '$p'
			fi
		else
				echo " Número de Mersenne na posição especificada."
				echo " Com o argumento 's' imprime a sequência até a posição."
				echo " Uso: zzmat $funcao <número> [s]"
		fi
	;;
	collatz)
	# Sequência de Collatz
	if zztestar numero "$2"
	then
		awk '
				function collatz(num) {
					printf num " "
					if (num>1) {
						if (num%2==0) { collatz(num/2) }
						else { collatz(3*num+1) }
					}
				}
				BEGIN { collatz('$2')}
			' |
			zztrim |
			zztool nl_eof
	else
		echo " Sequência de Collatz"
		echo " Uso: zzmat $funcao <número>"
	fi
	;;
	r3)
		shift
		if test -n "$1"
		then
			local num num1 num2 ind
			local num3=0
			local num4=0
			while test -n "$1"
			do
				num="$1"
				ind=1
				zztool grep_var "i" "$1" && ind=0 && num=$(echo "$1" | sed 's/i//')
				if (zztestar numero_real ${num%/*} || test ${num%/*} = 'x') && (zztestar numero_real ${num#*/} || test ${num#*/} = 'x')
				then
					num3=$((num3+1))
					if test $((num3%2)) -eq $ind
					then
						test ${num%/*} != 'x' && num1="$num1 ${num%/*}" || num4=$((num4+1))
						test ${num#*/} != 'x' && num2="$num2 ${num#*/}" || num4=$((num4+1))
					else
						test ${num%/*} != 'x' && num2="$num2 ${num%/*}" || num4=$((num4+1))
						test ${num#*/} != 'x' && num1="$num1 ${num#*/}" || num4=$((num4+1))
					fi
				fi
				shift
			done

			unset num
			if test $num4 -eq 1 && test -n "$num1" && test -n "$num2"
			then
				case $(zzmat compara_num $(echo "$num1" | awk '{print NF}') $(echo "$num2" | awk '{print NF}')) in
				maior)
					num=$(echo $(zzmat produto $num1)"/"$(zzmat produto $num2))
				;;
				menor)
					num=$(echo $(zzmat produto $num2)"/"$(zzmat produto $num1))
				;;
				*)
					zzmat $funcao
				;;
				esac
			else
				zzmat $funcao
			fi
		else
			echo " Calcula o valor de 'x', usando a regra de 3 simples ou composta."
			echo " Se alguma das frações tiver a letra i justaposta, é considerada inversamente proporcional."
			echo " Obs.: o i pode ser antes ou depois, mas não pode haver espaço em relação a fração."
			echo "       no local do valor a ser encontrado, digite apenas 'x', e somente uma vez."
			echo " Uso: zzmat $funcao <fração1>[i] <fração2>[i] [<fração3>[i] ...]"
		fi
	;;
	eq2g)
	#Equação do Segundo Grau: Raizes e Vértice
		if test $# = "4" && zztestar numero_real $2 && zztestar numero_real $3 && zztestar numero_real $4
		then
			local delta num_raiz vert_x vert_y raiz1 raiz2
			delta=$(echo "$2 $3 $4" | tr ',' '.' | awk '{valor=$2^2-(4*$1*$3); print valor}')
			num_raiz=$(awk 'BEGIN { if ('$delta' > 0)  {print "2"}
									if ('$delta' == 0) {print "1"}
									if ('$delta' < 0)  {print "0"}}')

			vert_x=$(echo "$2 $3" | tr ',' '.' |
			awk '{valor=((-1 * $2)/(2 * $1)); printf "%.'${precisao}'f\n", valor}' |
			zzmat -p${precisao} sem_zeros )

			vert_y=$(echo "$2 $delta" | tr ',' '.' |
			awk '{valor=((-1 * $2)/(4 * $1)); printf "%.'${precisao}'f\n", valor}' |
			zzmat -p${precisao} sem_zeros )

			case $num_raiz in
			0) raiz1="Sem raiz";;
			1) raiz1=$vert_x;;
			2)
				raiz1=$(echo "$2 $3 $delta" | tr ',' '.' |
				awk '{valor=((-1 * $2)-sqrt($3))/(2 * $1); printf "%.'${precisao}'f\n", valor}' |
				zzmat -p${precisao} sem_zeros )

				raiz2=$(echo "$2 $3 $delta" | tr ',' '.' |
				awk '{valor=((-1 * $2)+sqrt($3))/(2 * $1); printf "%.'${precisao}'f\n", valor}' |
				zzmat -p${precisao} sem_zeros )
			;;
			esac
			test "$num_raiz" = "2" && printf "%b\n" "X1: ${raiz1}\nX2: ${raiz2}" || echo "X: $raiz1"
			echo "Vertice: (${vert_x}, ${vert_y})"
		else
			zztool erro " zzmat $funcao: Equação do Segundo Grau (Raízes e Vértice)"
			zztool erro " Uso: zzmat $funcao A B C"
			return 1
		fi
	;;
	d2p)
		if test $# = "3" && zztool grep_var "," "$2" && zztool grep_var "," "$3"
		then
			local x1 y1 z1 x2 y2 z2 a b
			x1=$(echo "$2" | cut -f1 -d,)
			y1=$(echo "$2" | cut -f2 -d,)
			z1=$(echo "$2" | cut -f3 -d,)
			x2=$(echo "$3" | cut -f1 -d,)
			y2=$(echo "$3" | cut -f2 -d,)
			z2=$(echo "$3" | cut -f3 -d,)
			if zztestar numero_real $x1 && zztestar numero_real $y1 && zztestar numero_real $x2 && zztestar numero_real $y2
			then
				a=$(echo "(($y1)-($y2))^2" | bc -l)
				b=$(echo "(($x1)-($x2))^2" | bc -l)
				if zztestar numero_real $z1 && zztestar numero_real $z2
				then
					num="sqrt((($z1)-($z2))^2+$a+$b)"
				else
					num="sqrt($a+$b)"
				fi
			else
				zztool erro " Uso: zzmat $funcao ponto(a,b) ponto(x,y)";return 1
			fi
		else
			zztool erro " zzmat $funcao: Distância entre 2 pontos"
			zztool erro " Uso: zzmat $funcao ponto(a,b) ponto(x,y)"
			return 1
		fi
	;;
	vetor)
		if test $# -ge "3"
		then
			local valor ang teta fi oper tipo num1 saida
			local x1=0
			local y1=0
			local z1=0
			shift

			test "$1" = "-e" -o "$1" = "-c" && tipo="$1" || tipo="-e"
			oper="+"
			saida=$(echo "$*" | awk '{print $NF}')

			while (test $# -ge "1")
			do
				valor=$(echo "$1" | cut -f1 -d,)
				zztool grep_var "," $1 && teta=$(echo "$1" | cut -f2 -d,)
				zztool grep_var "," $1 && fi=$(echo "$1" | cut -f3 -d,)

				if test -n "$fi" && zztestar numero_real $valor
				then
					num1=$(echo "$fi" | sed 's/g$//; s/gr$//; s/rad$//')
					ang=$(echo "$fi" | tr -d -c '[grad]')
					echo "$fi" | grep -E '(g|rad|gr)$' >/dev/null
					if test "$?" -eq "0" && zztestar numero_real $num1
					then
						case $ang in
						g)   fi=$(zzconverte -p$((precisao+2)) gr $num1);;
						gr)  fi=$(zzconverte -p$((precisao+2)) ar $num1);;
						rad) fi=$num1;;
						esac
						z1=$(echo "$z1 $oper $(zzmat cos ${fi}rad) * $valor" | bc -l)
					elif zztestar numero_real $num1
					then
						z1="$num1"
					fi
				fi

				if test -n "$teta" && zztestar numero_real $valor
				then
					num1=$(echo "$teta" | sed 's/g$//; s/gr$//; s/rad$//')
					ang=$(echo "$teta" | tr -d -c '[grad]')
					echo "$teta" | grep -E '(g|rad|gr)$' >/dev/null
					if test "$?" -eq "0" && zztestar numero_real $num1
					then
						case $ang in
						g)   teta=$(zzconverte -p$((precisao+2)) gr $num1);;
						gr)  teta=$(zzconverte -p$((precisao+2)) ar $num1);;
						rad) teta=$num1;;
						esac
					else
						unset teta
					fi
				fi

				if zztestar numero_real $valor
				then
					test -n "$fi" && num1=$(echo "$(zzmat sen ${fi}rad)*$valor" | bc -l) ||
						num1=$valor
					test -n "$teta" && x1=$(echo "$x1 $oper $(zzmat cos ${teta}rad) * $num1" | bc -l) ||
						x1=$(echo "($x1) $oper ($num1)" | bc -l)
					test -n "$teta" && y1=$(echo "$y1 $oper $(zzmat sen ${teta}rad) * $num1" | bc -l)
				fi
				shift
			done

			valor=$(echo "sqrt(${x1}^2+${y1}^2+${z1}^2)" | bc -l)
			teta=$(zzmat asen $(echo "${y1}/sqrt(${x1}^2+${y1}^2)" | bc -l))
			fi=$(zzmat acos $(echo "${z1}/${valor}" | bc -l))

			case $saida in
			g)
				teta=$(zzconverte -p$((precisao+2)) rg $teta)
				fi=$(zzconverte -p$((precisao+2)) rg $fi)
			;;
			gr)
				teta=$(zzconverte -p$((precisao+2)) ra $teta)
				fi=$(zzconverte -p$((precisao+2)) ra $fi)
			;;
			*) saida="rad";;
			esac

			teta=$(awk 'BEGIN {printf "%.'${precisao}'f\n", '$teta'}' | zzmat -p${precisao} sem_zeros )
			fi=$(awk 'BEGIN {printf "%.'${precisao}'f\n", '$fi'}' | zzmat -p${precisao} sem_zeros )

			if test "$tipo" = "-c"
			then
				valor=$(echo "sqrt(${valor}^2-$z1^2)" | bc -l |
					awk '{printf "%.'${precisao}'f\n", $1}' | zzmat -p${precisao} sem_zeros )
				echo "${valor}, ${teta}${saida}, ${z1}"
			else
				valor=$(echo "$valor" | bc -l |
					awk '{printf "%.'${precisao}'f\n", $1}' | zzmat -p${precisao} sem_zeros )
				echo "${valor}, ${teta}${saida}, ${fi}${saida}"
			fi
		else
			zztool erro " zzmat $funcao: Operação entre vetores"
			zztool erro " Tipo de saída podem ser: padrão (-e)"
			zztool erro "  -e: vetor em coordenadas esférica: valor[,teta(g|rad|gr),fi(g|rad|gr)];"
			zztool erro "  -c: vetor em coordenada cilindrica: raio[,teta(g|rad|gr),altura]."
			zztool erro " Os angulos teta e fi tem sufixos g(graus), rad(radianos) ou gr(grados)."
			zztool erro " Os argumentos de entrada seguem o mesmo padrão do tipo de saída."
			zztool erro " E os tipos podem ser misturados em cada argumento."
			zztool erro " Unidade angular é o angulo de saida usado para o vetor resultante,"
			zztool erro " e pode ser escolhida entre g(graus), rad(radianos) ou gr(grados)."
			zztool erro " Não use separador de milhar. Use o ponto(.) como separador decimal."
			zztool erro " Uso: zzmat $funcao [tipo saida] vetor [vetor2] ... [unidade angular]"
			return 1
		fi
	;;
	egr | err)
	#Equação Geral da Reta
	#ax + by + c = 0
	#y1 – y2 = a
	#x2 – x1 = b
	#x1y2 – x2y1 = c
		if test $# = "3" && zztool grep_var "," "$2" && zztool grep_var "," "$3"
		then
			local x1 y1 x2 y2 a b c redutor m
			x1=$(echo "$2" | cut -f1 -d,)
			y1=$(echo "$2" | cut -f2 -d,)
			x2=$(echo "$3" | cut -f1 -d,)
			y2=$(echo "$3" | cut -f2 -d,)
			if zztestar numero_real $x1 && zztestar numero_real $y1 && zztestar numero_real $x2 && zztestar numero_real $y2
			then
				a=$(awk 'BEGIN {valor=('$y1')-('$y2'); printf "%.'${precisao}'f\n", valor}' | zzmat -p${precisao} sem_zeros)
				b=$(awk 'BEGIN {valor=('$x2')-('$x1');  printf "%+.'${precisao}'f\n", valor}' | zzmat -p${precisao} sem_zeros)
				c=$(zzmat det $x1 $y1 $x2 $y2 | awk '{printf "%+.'${precisao}'f\n", $1}' | zzmat -p${precisao} sem_zeros)
				m=$(awk 'BEGIN {valor=(('$y2'-'$y1')/('$x2'-'$x1')); printf "%.'${precisao}'f\n", valor}' | zzmat -p${precisao} sem_zeros)
				if zztestar numero_sinal $a && zztestar numero_sinal $b && zztestar numero_sinal $c
				then
					redutor=$(zzmat mdc $(zzmat abs $a) $(zzmat abs $b) $(zzmat abs $c))
					a=$(awk 'BEGIN {valor=('$a')/('$redutor'); print valor}')
					b=$(awk 'BEGIN {valor=('$b')/('$redutor');  print (valor<0?"":"+") valor}')
					c=$(awk 'BEGIN {valor=('$c')/('$redutor');  print (valor<0?"":"+") valor}')
				fi

				case "$funcao" in
				egr)
					echo "${a}x${b}y${c}=0" |
					sed 's/\([+-]\)1\([xy]\)/\1\2/g;s/[+]\{0,1\}0[xy]//g;s/+0=0/=0/;s/^+//';;
				err)
					redutor=$(awk 'BEGIN {printf "%+.'${precisao}'f\n", -('$m'*'$x1')+'$y1'}' | zzmat -p${precisao} sem_zeros)
					echo "y=${m}x${redutor}";;
				esac
			else
				zztool erro " Uso: zzmat $funcao ponto(a,b) ponto(x,y)";return 1
			fi
		else
			printf " zzmat %s: " $funcao
			case "$funcao" in
			egr) echo "Equação Geral da Reta.";;
			err) echo "Equação Reduzida da Reta.";;
			esac
			zztool erro " Uso: zzmat $funcao ponto(a,b) ponto(x,y)"
			return 1
		fi
	;;
	egc)
	#Equação Geral da Circunferência: Centro e Raio ou Centro e Ponto
	#x2 + y2 - 2ax - 2by + a2 + b2 - r2 = 0
	#A=-2ax | B=-2by | C=a2+b2-r2
	#r=raio | a=coordenada x do centro | b=coordenada y do centro
		if test $# = "3" && zztool grep_var "," "$2"
		then
			local a b r A B C
			if zztool grep_var "," "$3"
			then
				r=$(zzmat d2p $2 $3)
			elif zztestar numero_real "$3"
			then
				r=$(echo "$3" | tr ',' '.')
			else
				zztool erro " Uso: zzmat $funcao centro(a,b) (numero|ponto(x,y))";return 1
			fi
			a=$(echo "$2" | cut -f1 -d,)
			b=$(echo "$2" | cut -f2 -d,)
			A=$(awk 'BEGIN {valor=-2*('$a'); print (valor<0?"":"+") valor}')
			B=$(awk 'BEGIN {valor=-2*('$b'); print (valor<0?"":"+") valor}')
			C=$(awk 'BEGIN {valor=('$a')^2+('$b')^2-('$r')^2; print (valor<0?"":"+") valor}')
			echo "x^2+y^2${A}x${B}y${C}=0" | sed 's/\([+-]\)1\([xy]\)/\1\2/g;s/[+]0[xy]//g;s/+0=0/=0/'
		else
			zztool erro " zzmat $funcao: Equação Geral da Circunferência (Centro e Raio ou Centro e Ponto)"
			zztool erro " Uso: zzmat $funcao centro(a,b) (numero|ponto(x,y))"
			return 1
		fi
	;;
	egc3p)
	#Equação Geral da Circunferência: 3 Pontos
		if test $# = "4" && zztool grep_var "," "$2" &&	zztool grep_var "," "$3" && zztool grep_var "," "$4"
		then
			local x1 y1 x2 y2 x3 y3 A B C D
			x1=$(echo "$2" | cut -f1 -d,)
			y1=$(echo "$2" | cut -f2 -d,)
			x2=$(echo "$3" | cut -f1 -d,)
			y2=$(echo "$3" | cut -f2 -d,)
			x3=$(echo "$4" | cut -f1 -d,)
			y3=$(echo "$4" | cut -f2 -d,)

			if test $(zzmat det $x1 $y1 1 $x2 $y2 1 $x3 $y3 1) -eq 0
			then
				zztool erro "Pontos formam uma reta."
				return 1
			fi

			if ! zztestar numero_real $x1 || ! zztestar numero_real $x2 || ! zztestar numero_real $x3
			then
				zztool erro " Uso: zzmat $funcao ponto(a,b) ponto(c,d) ponto(x,y)";return 1
			fi

			if ! zztestar numero_real $y1 || ! zztestar numero_real $y2 || ! zztestar numero_real $y3
			then
				zztool erro " Uso: zzmat $funcao ponto(a,b) ponto(c,d) ponto(x,y)";return 1
			fi

			D=$(zzmat det $x1 $y1 1 $x2 $y2 1 $x3 $y3 1)
			A=$(zzmat det -$(echo "$x1^2+$y1^2" | bc) $y1 1 -$(echo "$x2^2+$y2^2" | bc) $y2 1 -$(echo "$x3^2+$y3^2" | bc) $y3 1)
			B=$(zzmat det $x1 -$(echo "$x1^2+$y1^2" | bc) 1 $x2 -$(echo "$x2^2+$y2^2" | bc) 1 $x3 -$(echo "$x3^2+$y3^2" | bc) 1)
			C=$(zzmat det $x1 $y1 -$(echo "$x1^2+$y1^2" | bc) $x2 $y2 -$(echo "$x2^2+$y2^2" | bc) $x3 $y3 -$(echo "$x3^2+$y3^2" | bc))

			A=$(awk 'BEGIN {valor='$A'/'$D';print (valor<0?"":"+") valor}')
			B=$(awk 'BEGIN {valor='$B'/'$D';print (valor<0?"":"+") valor}')
			C=$(awk 'BEGIN {valor='$C'/'$D';print (valor<0?"":"+") valor}')

			x1=$(awk 'BEGIN {valor='$A'/2*-1;print valor}')
			y1=$(awk 'BEGIN {valor='$B'/2*-1;print valor}')

			echo "x^2+y^2${A}x${B}y${C}=0" |
			sed 's/\([+-]\)1\([xy]\)/\1\2/g;s/[+]0[xy]//g;s/+0=0/=0/'
			echo "Centro: (${x1}, ${y1})"
		else
			zztool erro " zzmat $funcao: Equação Geral da Circunferência (3 pontos)"
			zztool erro " Uso: zzmat $funcao ponto(a,b) ponto(c,d) ponto(x,y)"
			return 1
		fi
	;;
	ege)
	#Equação Geral da Esfera: Centro e Raio ou Centro e Ponto
	#x2 + y2 + z2 - 2ax - 2by -2cz + a2 + b2 + c2 - r2 = 0
	#A=-2ax | B=-2by | C=-2cz | D=a2+b2+c2-r2
	#r=raio | a=coordenada x do centro | b=coordenada y do centro | c=coordenada z do centro
		if test $# = "3" && zztool grep_var "," "$2"
		then
			local a b c r A B C D
			if zztool grep_var "," "$3"
			then
				r=$(zzmat d2p $2 $3)
			elif zztestar numero_real "$3"
			then
				r=$(echo "$3" | tr ',' '.')
			else
				zztool erro " Uso: zzmat $funcao centro(a,b,c) (numero|ponto(x,y,z))";return 1
			fi
			a=$(echo "$2" | cut -f1 -d,)
			b=$(echo "$2" | cut -f2 -d,)
			c=$(echo "$2" | cut -f3 -d,)

			if ! zztestar numero_real $a || ! zztestar numero_real $b || ! zztestar numero_real $c
			then
				zztool erro " Uso: zzmat $funcao centro(a,b,c) (numero|ponto(x,y,z))";return 1
			fi
			A=$(awk 'BEGIN {valor=-2*('$a'); print (valor<0?"":"+") valor}')
			B=$(awk 'BEGIN {valor=-2*('$b'); print (valor<0?"":"+") valor}')
			C=$(awk 'BEGIN {valor=-2*('$c'); print (valor<0?"":"+") valor}')
			D=$(awk 'BEGIN {valor='$a'^2+'$b'^2+'$c'^2-'$r'^2;print (valor<0?"":"+") valor}')
			echo "x^2+y^2+z^2${A}x${B}y${C}z${D}=0" |
			sed 's/\([+-]\)1\([xyz]\)/\1\2/g;s/[+]0[xyz]//g;s/+0=0/=0/'
		else
			zztool erro " zzmat $funcao: Equação Geral da Esfera (Centro e Raio ou Centro e Ponto)"
			zztool erro " Uso: zzmat $funcao centro(a,b,c) (numero|ponto(x,y,z))"
			return 1
		fi
	;;
	aleatorio | random)
		#Gera um numero aleatorio (randomico)
		local min=0
		local max=1
		local qtde=1
		local n_temp

		if test "$2" = "-h"
		then
			echo " zzmat $funcao: Gera um número aleatório."
			echo " Sem argumentos gera números entre 0 e 1."
			echo " Com 1 argumento numérico este fica como limite superior."
			echo " Com 2 argumentos numéricos estabelecem os limites inferior e superior, respectivamente."
			echo " Com 3 argumentos numéricos, o último é a quantidade de número aleatórios gerados."
			echo " Usa padrão de 6 casas decimais. Use -p0 logo após zzmat para números inteiros."
			echo " Uso: zzmat $funcao [[minimo] maximo] [quantidade]"
			return
		fi

		if zztestar numero_real $3
		then
			max=$(echo "$3" | tr ',' '.')
			if zztestar numero_real $2;then min=$(echo "$2" | tr ',' '.');fi
		elif zztestar numero_real $2
		then
			max=$(echo "$2" | tr ',' '.')
		fi

		if test $(zzmat compara_num $max $min) = "menor"
		then
			n_temp=$max
			max=$min
			min=$n_temp
			unset n_temp
		fi

		if test -n "$4" && zztestar numero $4;then qtde=$4;fi

		case "$funcao" in
		aleatorio)
			awk 'BEGIN {srand();for(i=1;i<='$qtde';i++) { printf "%.'${precisao}'f\n", sprintf("%.'${precisao}'f\n",'$min'+rand()*('$max'-'$min'))}}' |
			zzmat -p${precisao} sem_zeros
			sleep 1
		;;
		random)
			n_temp=1
			while test $n_temp -le $qtde
			do
				zzaleatorio | awk '{ printf "%.'${precisao}'f\n", sprintf("%.'${precisao}'f\n",'$min'+($1/32767)*('$max'-'$min'))}' |
				zzmat -p${precisao} sem_zeros
				n_temp=$((n_temp + 1))
			done
		;;
		esac
	;;
	det)
		# Determinante de matriz (2x2 ou 3x3)
		if test $# -ge "5" && test $# -le "10"
		then
			local num
			shift
			for num in $*
			do
				if ! zztestar numero_real "$num"
				then
					zztool erro " Uso: zzmat $funcao numero1 numero2 numero3 numero4 [numero5 numero6 numero7 numero8 numero9]"
					return 1
				fi
			done
			case $# in
			4) num=$(echo "($1*$4)-($2*$3)" | tr ',' '.');;
			9) num=$(echo "(($1*$5*$9)+($7*$2*$6)+($4*$8*$3)-($7*$5*$3)-($4*$2*$9)-($1*$8*$6))" | tr ',' '.');;
			*)   zztool erro " Uso: zzmat $funcao numero1 numero2 numero3 numero4 [numero5 numero6 numero7 numero8 numero9]"; return 1;;
			esac
		else
			echo " zzmat $funcao: Calcula o valor da determinante de uma matriz 2x2 ou 3x3."
			echo " Uso: zzmat $funcao numero1 numero2 numero3 numero4 [numero5 numero6 numero7 numero8 numero9]"
			echo " Ex:  zzmat det 1 3 2 4"
		fi
	;;
	conf_eq)
		# Confere equação
		if test $# -ge "2"
		then
			equacao=$(echo "$2" | sed 's/\[/(/g;s/\]/)/g')
			local x y z eq
			shift
			shift
			while (test $# -ge "1")
			do
				x=$(echo "$1" | cut -f1 -d,)
				zztool grep_var "," $1 && y=$(echo "$1" | cut -f2 -d,)
				zztool grep_var "," $1 && z=$(echo "$1" | cut -f3 -d,)
				eq=$(echo $equacao | sed "s/^[x]/$x/;s/\([(+-]\)x/\1($x)/g;s/\([0-9]\)x/\1\*($x)/g;s/x/$x/g" |
					sed "s/^[y]/$y/;s/\([(+-]\)y/\1($y)/g;s/\([0-9]\)y/\1\*($y)/g;s/y/$y/g" |
					sed "s/^[z]/$z/;s/\([(+-]\)z/\1($z)/g;s/\([0-9]\)z/\1\*($z)/g;s/z/$z/g")
				echo "$eq" | bc -l
				unset x y z eq
				shift
			done
		else
			zztool erro " zzmat $funcao: Confere ou resolve equação."
			zztool erro " As variáveis a serem consideradas são x, y ou z nas fórmulas."
			zztool erro " As variáveis são justapostas em cada argumento separados por vírgula."
			zztool erro " Cada argumento adicional é um novo conjunto de variáveis na fórmula."
			zztool erro " Usar '[' e ']' respectivamente no lugar de '(' e ')', ou proteger"
			zztool erro " a fórmula com aspas duplas(\") ou simples(')"
			zztool erro " Potenciação é representado com o uso de '^', ex: 3^2."
			zztool erro " Não use separador de milhar. Use o ponto(.) como separador decimal."
			zztool erro " Uso: zzmat $funcao equacao numero|ponto(x,y[,z])"
			zztool erro " Ex:  zzmat conf_eq x^2+3*[y-1]-2z+5 7,6.8,9 3,2,5.1"
			return 1
		fi
	;;
	*)
	zzmat -h
	;;
	esac

	if test "$?" -ne "0"
	then
		return 1
	elif test -n "$num"
	then
		echo "$num" | bc -l | awk '{printf "%.'${precisao}'f\n", $1}' | zzmat -p${precisao} sem_zeros
	fi
}

# ----------------------------------------------------------------------------
# zzmcd
# Cria diretórios e subdiretórios, e muda diretório de trabalho (primeiro).
#
# Opções:
#      -n: Cria os diretórios, mas não muda o diretório de trabalho atual.
#      -s: Apenas simula o comando mkdir com os argumentos
#
# Uso: zzmcd [-n|-s] <dir[/subdir]> [dir[/subdir]]
# Ex.: zzmcd tmp1/tmp2
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2018-03-30
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzmcd ()
{
	zzzz -h mcd "$1" && return

	local opt dir erro

	# Verificação das opções
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-n) opt="n"; shift;;
			-s) opt="s"; shift;;
			--) shift; break;;
			-*) zztool -e uso mcd; return 1;;
		esac
	done

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso mcd; return 1; }

	# Cria/simula os diretório
	case "$opt" in
		s) echo mkdir -p $*; erro=0 ;;
		*)
			mkdir -p $* 2>/dev/null && test "$opt" = "n" && erro=0
			# Verificando diretórios que falharam
			for dir in $*
			do
				test -d "$dir" || zztool erro "'$dir' não criado."
			done
		;;
	esac

	# Desloca-se ao primeiro diretório criado no último nivel possível
	test -d "$1" && test -z "$opt" && cd "$1"
	return $erro
}

# ----------------------------------------------------------------------------
# zzmd5
# Calcula o código MD5 dos arquivos informados, ou de um texto via STDIN.
# Obs.: Wrapper portável para os comandos md5 (Mac) e md5sum (Linux).
#
# Uso: zzmd5 [arquivo(s)]
# Ex.: zzmd5 arquivo.txt
#      cat arquivo.txt | zzmd5
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-06
# Versão: 1
# Licença: GPL
# Nota: (ou) md5 md5sum
# ----------------------------------------------------------------------------
zzmd5 ()
{
	zzzz -h md5 "$1" && return

	local tab=$(printf '\t')

	# Testa se o comando existe
	if which md5 >/dev/null 2>&1
	then
		comando="md5"

	elif which md5sum >/dev/null 2>&1
	then
		comando="md5sum"
	else
		zztool erro "Erro: Não encontrei um comando para cálculo MD5 em seu sistema"
		return 1
	fi


	##### Diferenças na saída dos comandos
	###
	### $comando_md5 /a/www/favicon.*
	#
	# Linux (separador é 2 espaços):
	# d41d8cd98f00b204e9800998ecf8427e  /a/www/favicon.gif
	# 902591ef89dbe5663dc7ae44a5e3e27a  /a/www/favicon.ico
	#
	# Mac:
	# MD5 (/a/www/favicon.gif) = d41d8cd98f00b204e9800998ecf8427e
	# MD5 (/a/www/favicon.ico) = 902591ef89dbe5663dc7ae44a5e3e27a
	#
	# zzmd5 (separador é Tab):
	# d41d8cd98f00b204e9800998ecf8427e	/a/www/favicon.gif
	# 902591ef89dbe5663dc7ae44a5e3e27a	/a/www/favicon.ico
	#
	###
	### echo abcdef | $comando_md5
	#
	# Linux:
	# 5ab557c937e38f15291c04b7e99544ad  -
	#
	# Mac:
	# 5ab557c937e38f15291c04b7e99544ad
	#
	# zzmd5:
	# 5ab557c937e38f15291c04b7e99544ad
	#
	###
	### CONCLUSÃO
	### A zzmd5 usa o formato do Mac quando o texto vem pela STDIN,
	### que é mostrar somente o hash e mais nada. Já quando os arquivos
	### são informados via argumentos na linha de comando, a zzmd5 usa
	### um formato parecido com o do Linux, com o hash primeiro e depois
	### o nome do arquivo. A diferença é no separador: um Tab em vez de
	### dois espaços em branco.
	###
	### Considero que a saída da zzmd5 é a mais limpa e fácil de extrair
	### os dados usando ferramentas Unix.


	# Executa o comando do cálculo MD5 e formata a saída conforme
	# explicado no comentário anterior: HASH ou HASH-Tab-Arquivo
	$comando "$@" |
		sed "
			# Mac
			s/^MD5 (\(.*\)) = \(.*\)$/\2$tab\1/

			# Linux
			s/^\([0-9a-f]\{1,\}\)  -$/\1/
			s/^\([0-9a-f]\{1,\}\)  \(.*\)$/\1$tab\2/
		"
}

# ----------------------------------------------------------------------------
# zzminiurl
# Encurta uma URL utilizando o google ("https://goo.gl/").
# Caso a URL já seja encurtada, será exibida a URL completa.
# Obs.: Se a URL não tiver protocolo no início, será colocado http://
# Uso: zzminiurl URL
# Ex.: zzminiurl http://www.funcoeszz.net
#      zzminiurl www.funcoeszz.net         # O http:// no início é opcional
#      zzminiurl https://goo.gl/yz4cb9
#
# Autor: Vinícius Venâncio Leite <vv.leite (a) gmail com>
# Desde: 2010-04-26
# Versão: 6
# Licença: GPL
# ----------------------------------------------------------------------------
zzminiurl ()
{
	zzzz -h miniurl "$1" && return

	test -n "$1" || { zztool -e uso miniurl; return 1; }

	local url="$1"
	local prefixo='http://'
	local urlencurtador='https://www.googleapis.com/urlshortener/v1/url?key=AIzaSyAutIDVbN_3CmtxpunVnXruLYYAXs5e9Sw'
	local urlexpansor="https://www.googleapis.com/urlshortener/v1/url?key=AIzaSyAutIDVbN_3CmtxpunVnXruLYYAXs5e9Sw&shortUrl"
	local contenttype='Content-Type: application/json'
	local parametro="{\"longUrl\": \"$url\"}"
	local urlcurta
	local urlcompara

	# Se o usuário não informou o protocolo, adiciona o padrão
	echo "$url" | egrep '^(https?|ftp|mms)://' >/dev/null || url="$prefixo$url"

	urlcompara=$(echo "$url" | sed 's/\(.*\:\/\/\)\(goo\.gl\).*/\2/')
	urlcurta=$(curl -s "$urlencurtador" -H "$contenttype" -d "$parametro" 2>/dev/null)

	if test "$urlcompara" == 'goo.gl'
	then
		curl -s "$urlexpansor=$url" | sed -n '/"longUrl"/ {s/.*\(http[^"]*\)".*/\1/g; p; }'
	else
		echo "$urlcurta" | sed -n '/"id"/ {s/.*\(http[^"]*\)".*/\1/g; p;}'
	fi
}

# ----------------------------------------------------------------------------
# zzminusculas
# Converte todas as letras para minúsculas, inclusive acentuadas.
# Uso: zzminusculas [texto]
# Ex.: zzminusculas NÃO ESTOU GRITANDO             # via argumentos
#      echo NÃO ESTOU GRITANDOO | zzminusculas     # via STDIN
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2003-06-12
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzminusculas ()
{
	zzzz -h minusculas "$1" && return

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |

	sed '
		y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/
		y/ÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÇÑ/àáâãäåèéêëìíîïòóôõöùúûüçñ/'
}

# ----------------------------------------------------------------------------
# zzmix
# Mistura linha a linha 2 ou mais arquivos, mantendo a sequência.
# Opções:
#  -o <arquivo> - Define o arquivo de saída.
#  -m - Toma como base o arquivo com menos linhas.
#  -M - Toma como base o arquivo com mais linhas.
#  -<numero> - Toma como base o arquivo na posição especificada.
#  -p <relação de linhas> - numero de linhas de cada arquivo de origem.
#    Obs1.: A relação são números de linhas de cada arquivo correspondente na
#           sequência, justapostos separados por vírgula (,).
#    Obs2.: Se a quantidade de linhas na relação for menor que a quantidade de
#           arquivos, os arquivos excedentes adotam a último valor na relação.
#
# Sem opção, toma como base o primeiro arquivo declarado.
#
# Uso: zzmix [-m | -M | -<num>] [-o <arq>] [-p <relação>] arq1 arq2 [arqN] ...
# Ex.: zzmix -m arquivo1 arquivo2 arquivo3  # Base no arquivo com menos linhas
#      zzmix -2 arquivo1 arquivo2 arquivo3  # Base no segundo arquivo
#      zzmix -o out.txt arquivo1 arquivo2   # Mixando para o arquivo out.txt
#      zzmix -p 2,5,6 arq1 arq2 arq3
#      # 2 linhas do arq1, 5 linhas do arq2 e 6 linhas do arq3,
#      # e repete a sequência até o final.
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-11-01
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzmix ()
{
	zzzz -h mix "$1" && return

	local lin_arq arquivo arq_saida arq_ref
	local passos=1
	local linhas=0
	local tipo=1

	# Opção -m ou -M, -numero ou -o
	while test "${1#-}" != "$1"
	do
		if test "$1" = "-o"
		then
			arq_saida="$2"
			shift
		elif test "$1" = "-p"
		then
			passos="$2"
			shift
		else
			tipo="${1#-}"
		fi
		shift
	done

	test -n "$2" || { zztool -e uso mix; return 1; }

	for arquivo
	do
		# Especificar se vai se orientar pelo arquivo com mais ou menos linhas
		if test "$tipo" = "m" || test "$tipo" = "M"
		then
			lin_arq=$(zztool num_linhas "$arquivo")
			if test "$tipo" = "M" && test $lin_arq -gt $linhas
			then
				linhas=$lin_arq
				arq_ref=$arquivo
			fi
			if test "$tipo" = "m" && (test $lin_arq -lt $linhas || test $linhas -eq 0)
			then
				linhas=$lin_arq
				arq_ref=$arquivo
			fi
		fi

		# Verifica se arquivos são legíveis
		zztool arquivo_legivel "$arquivo" || { zztool erro "Um ou mais arquivos inexistentes ou ilegíveis."; return 1; }
	done

	# Se opção é um numero, o arquivo base para as linhas é o mesmo da posição equivalente
	if zztool testa_numero $tipo && test $tipo -le $#
	then
		arq_ref=$(awk -v arg=$tipo 'BEGIN { print ARGV[arg] }' $* 2>/dev/null)
		linhas=$(zztool num_linhas "$arq_ref")
	fi

	# Sem quantidade de linhas mínima não há mistura.
	test "$linhas" -eq 0 && { zztool erro "Não há linhas para serem \"mixadas\"."; return 1; }

	# Onde a "mixagem" ocorre efetivamente.
	awk -v linhas_awk=$linhas -v passos_awk="$passos" -v arq_ref_awk="$arq_ref" -v saida_awk="$arq_saida" '
	BEGIN {
		qtde_passos = split(passos_awk, passo, ",")

		if (qtde_passos < ARGC)
		{
			ultimo_valor = passo[qtde_passos]
			for (i = qtde_passos+1; i <= ARGC; i++) {
				passo[i] = ultimo_valor
			}
		}

		div_linhas = 1
		for (i = 1; i <= ARGC-1; i++) {
			if (arq_ref_awk == ARGV[i]) {
				div_linhas = passo[i]
			}
		}

		bloco_linhas=int(linhas_awk/div_linhas) + (linhas_awk/div_linhas==int(linhas_awk/div_linhas)?0:1)

		for (i = 1; i <= bloco_linhas; i++) {
			for(j = 1; j < ARGC; j++) {
				for (k = 1; k <= passo[j]; k++)
				{
					if ((getline linha < ARGV[j]) > 0) {
						if (length(saida_awk)>0)
							print linha >> saida_awk
						else
							print linha
					}
				}
			}
		}
	}' $* 2>/dev/null
}

# ----------------------------------------------------------------------------
# zzmoneylog
# Consulta lançamentos do Moneylog, com pesquisa avançada e saldo total.
# Obs.: Chamado sem argumentos, pesquisa o mês corrente.
# Obs.: Não expande lançamentos recorrentes e parcelados.
#
# Uso: zzmoneylog [-d data] [-v valor] [-t tag] [--total] [texto]
# Ex.: zzmoneylog                       # Todos os lançamentos deste mês
#      zzmoneylog mercado               # Procure por mercado
#      zzmoneylog -t mercado            # Lançamentos com a tag mercado
#      zzmoneylog -t mercado -d 2011    # Tag mercado em 2011
#      zzmoneylog -t mercado --total    # Saldo total da tag mercado
#      zzmoneylog -d 31/01/2011         # Todos os lançamentos desta data
#      zzmoneylog -d 2011               # Todos os lançamentos de 2011
#      zzmoneylog -d ontem              # Todos os lançamentos de ontem
#      zzmoneylog -d mes                # Todos os lançamentos deste mês
#      zzmoneylog -d mes --total        # Saldo total deste mês
#      zzmoneylog -d 2011-0[123]        # Regex: que casa Jan/Fev/Mar de 2011
#      zzmoneylog -v /                  # Todos os pagamentos parcelados
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-25
# Versão: 1
# Licença: GPL
# Requisitos: zzcalcula zzdatafmt zzdos2unix
# ----------------------------------------------------------------------------
zzmoneylog ()
{
	zzzz -h moneylog "$1" && return

	local data valor tag total
	local arquivo=$ZZMONEYLOG

	# Chamado sem argumentos, mostra o mês corrente
	test $# -eq 0 && data=$(zzdatafmt -f AAAA-MM hoje)

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-t | --tag    ) shift; tag="$1";;
			-d | --data   ) shift; data="$1";;
			-v | --valor  ) shift; valor="$1";;
			-a | --arquivo) shift; arquivo="$1";;
			--total) total=1;;
			--) shift; break;;
			-*) zztool erro "Opção inválida $1"; return 1;;
			*) break;;
		esac
		shift
	done

	# O-oh
	if test -z "$arquivo"
	then
		zztool erro 'Ops, não sei onde encontrar seu arquivo de dados do Moneylog.'
		zztool erro 'Use a variável $ZZMONEYLOG para indicar o caminho.'
		zztool erro
		zztool erro 'Se você usa a versão tudo-em-um, indique o arquivo HTML:'
		zztool erro '    export ZZMONEYLOG=/home/fulano/moneylog.html'
		zztool erro
		zztool erro 'Se você usa vários arquivos TXT, indique a pasta:'
		zztool erro '    export ZZMONEYLOG=/home/fulano/moneylog/'
		zztool erro
		zztool erro 'Além da variável, você também pode usar a opção --arquivo.'
		return 1
	fi

	# Consigo ler o arquivo? (Se não for pasta nem STDIN)
	if ! test -d "$arquivo" && test "$arquivo" != '-'
	then
		zztool -e arquivo_legivel "$arquivo" || return 1
	fi

	### DATA
	# Formata (se necessário) a data informada.
	# A data não é validada, assim o usuário pode fazer pesquisas parciais,
	# ou ainda usar expressões regulares, exemplo: 2011-0[123].
	if test -n "$data"
	then
		# Para facilitar a vida, alguns formatos comuns são mapeados
		# para o formato do moneylog. Assim, para pesquisar o mês
		# de janeiro do 2011, pode-se fazer: 2011-01 ou 1/2011.
		case "$data" in
			# m/aaaa -> aaaa-mm
			[1-9]/[12][0-9][0-9][0-9])
				data=$(zzdatafmt -f "AAAA-MM" 01/$data)
			;;
			# mm/aaaa -> aaaa-mm
			[01][0-9]/[12][0-9][0-9][0-9])
				data=$(zzdatafmt -f "AAAA-MM" 01/$data)
			;;
			# data com barras -> aaaa-mm-dd
			*/*)
				data=$(zzdatafmt -f "AAAA-MM-DD" $data)
			;;
			# apelidos especiais zzmoneylog
			ano)
				data=$(zzdatafmt -f "AAAA" hoje)
			;;
			mes | mês)
				data=$(zzdatafmt -f "AAAA-MM" hoje)
			;;
			dia)
				data=$(zzdatafmt -f "AAAA-MM-DD" hoje)
			;;
			# apelidos comuns: hoje, ontem, anteontem, etc
			[a-z]*)
				data=$(zzdatafmt -f "AAAA-MM-DD" $data)
			;;
		esac

		# Deu pau no case?
		if test $? -ne 0
		then
			zztool erro "$data" # Mensagem de erro
			return 1
		fi
	fi

	### VALOR
	# É necessário formatar um pouco o texto do usuário para a pesquisa
	# ficar mais poderosa, pois o formato do Moneylog é bem flexível.
	# Assim o usuário não precisa se preocupar com as pequenas diferenças.
	if test -n "$valor"
	then
		valor=$(echo "$valor" | sed '
			# Escapa o símbolo de recorrência: * vira [*]
			s|[*]|[*]|g

			# Remove espaços em branco
			s/ //g

			# Pesquisa vai funcionar com ambos separadores: . e ,
			s/,/[,.]/

			# É possível ter espaços após o sinal
			s/^[+-]/& */

			# O sinal de + é opcional
			s/^+/+*/

			# Busca por ,99 deve funcionar
			# Lembre-se que é possível haver espaços antes do valor
			s/^/[0-9 ,.+-]*/
		')
	fi

	# Começamos mostrando todos os dados, seja do arquivo HTML, do TXT
	# ou de vários TXT. Os IFs seguintes filtrarão estes dados conforme
	# as opções escolhidas pelo usuário.

	if test -d "$arquivo"
	then
		cat "$arquivo"/*.txt
	else
		cat "$arquivo" |
			# Remove código HTML, caso exista
			sed '/^<!DOCTYPE/,/<pre id="data">/ d'
	fi |

	# Remove linhas em branco.
	# Comentários são mantidos, pois podem ser úteis na pesquisa
	zzdos2unix | sed '/^[	 ]*$/ d' |

	# Filtro: data
	if test -n "$data"
	then
		grep "^[^	]*$data"
	else
		cat -
	fi |

	# Filtro: valor
	if test -n "$valor"
	then
		grep -i "^[^	]*	$valor"
	else
		cat -
	fi |

	# Filtro: tag
	if test -n "$tag"
	then
		grep -i "^[^	]*	[^	]*	[^|]*$tag[^|]*|"
	else
		cat -
	fi |

	# Filtro geral, aplicado na linha toda (default=.)
	grep -i "${*:-.}" |

	# Ordena o resultado por data
	sort -n |

	# Devo mostrar somente o total ou o resultado da busca?
	if test -n "$total"
	then
		cut -f 2 | zzcalcula --soma
	else
		cat -
	fi
}

# ----------------------------------------------------------------------------
# zzmudaprefixo
# Move os arquivos que tem um prefixo comum para um novo prefixo.
# Opções:
#   -a, --antigo informa o prefixo antigo a ser trocado.
#   -n, --novo   informa o prefixo novo a ser trocado.
# Uso: zzmudaprefixo -a antigo -n novo
# Ex.: zzmudaprefixo -a "antigo_prefixo" -n "novo_prefixo"
#      zzmudaprefixo -a "/tmp/antigo_prefixo" -n "/tmp/novo_prefixo"
#
# Autor: Lauro Cavalcanti de Sa <lauro (a) ecdesa com>
# Desde: 2009-09-21
# Versão: 2
# Licença: GPLv2
# ----------------------------------------------------------------------------
zzmudaprefixo ()
{

	#set -x

	zzzz -h mudaprefixo "$1" && return

	# Verifica numero minimo de parametros.
	if test $# -lt 4 ; then
		zztool -e uso mudaprefixo
		return 1
	fi

	# Declara variaveis.
	local antigo novo n_sufixo_ini sufixo

	# Opcoes de linha de comando
	while test $# -ge 1
	do
		case "$1" in
			-a | --antigo)
				test -n "$2" || { zztool -e uso mudaprefixo; return 1; }
				antigo=$2
				shift
				;;
			-n | --novo)
				test -n "$2" || { zztool -e uso mudaprefixo; return 1; }
				novo=$2
				shift
				;;
			*) { zztool -e uso mudaprefixo; return 1; } ;;
		esac
		shift
	done

	# Renomeia os arquivos.
	n_sufixo_ini=`echo ${#antigo}`
	n_sufixo_ini=`expr ${n_sufixo_ini} + 1`
	for sufixo in `ls -1 "${antigo}"* | cut -c${n_sufixo_ini}-`;
	do
		# Verifica se eh arquivo mesmo.
		if test -f "${antigo}${sufixo}" -a ! -s "${novo}${sufixo}" ; then
			mv -v "${antigo}${sufixo}" "${novo}${sufixo}"
		else
			zztool erro "CUIDADO: Arquivo ${antigo}${sufixo} nao foi movido para ${novo}${sufixo} porque ou nao eh ordinario, ou destino ja existe!"
			return 1
		fi
	done

}

# ----------------------------------------------------------------------------
# zznatal
# http://www.ibb.org.br/vidanet
# A mensagem "Feliz Natal" em vários idiomas.
# Uso: zznatal [palavra]
# Ex.: zznatal                   # busca um idioma aleatório
#      zznatal russo             # Feliz Natal em russo
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2004-12-23
# Versão: 1
# Licença: GPL
# Requisitos: zzlinha
# ----------------------------------------------------------------------------
zznatal ()
{
	zzzz -h natal "$1" && return

	local url='http://www.vidanet.org.br/mensagens/feliz-natal-em-varios-idiomas'
	local cache=$(zztool cache natal)
	local padrao=$1

	# Se o cache está vazio, baixa listagem da Internet
	if ! test -s "$cache"
	then
		zztool dump "$url" | sed '
			1,10d
			77,179d
			s/^  *//
			s/^(/Chinês  &/
			s/  */: /' > "$cache"
	fi

	# Mostra uma linha qualquer (com o padrão, se informado)
	printf %s '"Feliz Natal" em '
	zzlinha -t "${padrao:-.}" "$cache"
}

# ----------------------------------------------------------------------------
# zznerdcast
# Lista os episódios do podcast NerdCast.
#
# Opções para a listagem:
#   -n <número> - Quantidade de resultados retornados (padrão = 15)
#   -d <data>   - Filtra por uma data específica.
#   -m <mês>    - Filtra por um mês específico. Sem o ano seleciona atual.
#   -a <ano>    - Filtra por um ano em específico.
#
#   Obs.: No lugar de -d, -m, -a pode usar --data, --mês ou --mes, --ano.
#         Na opção -d, <data> pode ser "hoje", "ontem" e "anteontem".
#         Na opção -n, <número> se for igual a 0, não limita a quantidade.
#
#   Opções adicionais são consideradas termos a serem filtrados na consulta.
#
# Uso: zznerdcast [-n <número>| -d <data> | -m <mês>| -a <ano>] [texto]
# Ex.: zznerdcast
#      zznerdcast -n 30
#      zznerdcast -d 28.10.16
#      zznerdcast -m 5/2014
#      zznerdcast -a 2014 Empreendedor
#      zznerdcast Terra
#
# Autor: Diogo Alexsander Cavilha <diogocavilha (a) gmail com>
# Desde: 2016-09-19
# Versão: 2
# Licença: GPL
# Requisitos: zzdatafmt zzunescape zzxml
# ----------------------------------------------------------------------------
zznerdcast ()
{
	zzzz -h nerdcast "$1" && return

	local cache=$(zztool cache nerdcast)
	local limite='15'
	local filtro='.'
	local data

	# Opções de linha de comando
	while  test "${1#-}" != "$1"
	do
		case "$1" in
		-n)
			if zztool testa_numero "$2"
			then
				limite="$2"
				test "$limite" -eq 0 && limite='$'
				shift
			fi
			shift
		;;
		-d | --data)
			data=$(zzdatafmt --en -f "DD MMM AAAA" "$2" 2>/dev/null)
			if test -n "$data"
			then
				unset limite
				shift
			fi
			shift
		;;
		-m | --m[eê]s)
			data=$(zzdatafmt --en -f "MMM AAAA" "1/$2" 2>/dev/null)
			if test -n "$data"
			then
				unset limite
				shift
			fi
			shift
		;;
		-a | --ano)
			data=$(zzdatafmt --en -f "AAAA" "1/1/$2" 2>/dev/null)
			if test -n "$data"
			then
				unset limite
				shift
			fi
			shift
		;;
		--) shift; break ;;
		-*) zztool -e uso nerdcast; return 1 ;;
		esac
	done

	# Grepando os resultados
	test $# -gt 0 && filtro="$*"
	filtro=$(zztool endereco_sed "$filtro")

	# Usa o cache se existir e estiver atualizado, senão baixa um novo.
	if ! test -s "$cache" || test $(head -n 1 "$cache") != $(zzdatafmt --iso hoje)
	then
		zzdatafmt --iso hoje > "$cache"

		zztool source "https://jovemnerd.com.br/feed-nerdcast/" |
		zzxml --tag title --tag enclosure --tag pubDate |
		awk '
			/<title>/{ getline; if ($0 ~ /[0-9a-z] - /) printf $0 " | "}
			/\.mp3"/{ printf $2 " | " }
			/<pubDate>/{ getline; print $2,$3,$4 }
			' |
		sed '/url="/ { s///;s/"//; }' |
		zzunescape --html >> "$cache"
	fi

	# Filtra pelo assunto
	# Filtra por data ou quantidade
	# E formata  saída
	sed -n "1d;${filtro}p" "$cache" |
	if test -n "$data"
	then
		grep "${data}$"
	else
		sed "${limite}q"
	fi |
	awk -F ' [|] ' '/[|]/ { print $1,"|",$3; print $2; print "" }'
}

# ----------------------------------------------------------------------------
# zznomealeatorio
# Gera um nome aleatório de N caracteres, alternando consoantes e vogais.
# Obs.: Se nenhum parâmetro for passado, gera um nome de 6 caracteres.
# Uso: zznomealeatorio [N]
# Ex.: zznomealeatorio
#      zznomealeatorio 8
#
# Autor: Guilherme Magalhães Gall <gmgall (a) gmail com>
# Desde: 2013-03-03
# Versão: 2
# Licença: GPL
# Requisitos: zzseq zzaleatorio
# ----------------------------------------------------------------------------
zznomealeatorio ()
{
	zzzz -h nomealeatorio "$1" && return

	local vogais='aeiou'
	local consoantes='bcdfghjlmnpqrstvxz'
	# Sem parâmetros, gera nome de 6 caracteres.
	local entrada=${1:-6}
	local contador
	local letra
	local nome
	local posicao
	local lista

	# Se a quantidade de parâmetros for incorreta ou não for número
	# inteiro positivo, mostra mensagem de uso e sai.
	(test $# -gt 1 || ! zztool testa_numero "$entrada") && {
		zztool -e uso nomealeatorio
		return 1
	}

	# Se o usuário quer um nome de 0 caracteres, basta retornar.
	test "$entrada" -eq 0 && return

	# Gera nome aleatório com $entrada caracteres. Alterna consoantes e
	# vogais. Algoritmo baseado na função randomName() do código da
	# página http://geradordenomes.com
	for contador in $(zzseq "$entrada")
	do
		if test $((contador%2)) -eq 1
		then
			lista="$consoantes"
		else
			lista="$vogais"
		fi
		posicao=$(zzaleatorio 1 ${#lista})
		letra=$(echo "$lista" | cut -c "$posicao")
		nome="$nome$letra"
	done
	echo "$nome"
}

# ----------------------------------------------------------------------------
# zznomefoto
# Renomeia arquivos do diretório atual, arrumando a seqüência numérica.
# Obs.: Útil para passar em arquivos de fotos baixadas de uma câmera.
# Opções: -n  apenas mostra o que será feito, não executa
#         -i  define a contagem inicial
#         -d  número de dígitos para o número
#         -p  prefixo padrão para os arquivos
#         --dropbox  renomeia para data+hora da foto, padrão Dropbox
# Uso: zznomefoto [-n] [-i N] [-d N] [-p TXT] arquivo(s)
# Ex.: zznomefoto -n *                        # tire o -n para renomear!
#      zznomefoto -n -p churrasco- *.JPG      # tire o -n para renomear!
#      zznomefoto -n -d 4 -i 500 *.JPG        # tire o -n para renomear!
#      zznomefoto -n --dropbox *.JPG          # tire o -n para renomear!
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2004-11-10
# Versão: 3
# Licença: GPL
# Requisitos: zzminusculas
# Nota: (ou) exiftool exiftime identify
# ----------------------------------------------------------------------------
zznomefoto ()
{
	zzzz -h nomefoto "$1" && return

	local arquivo prefixo contagem extensao nome novo nao previa
	local dropbox exif_info exif_cmd
	local i=1
	local digitos=3

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-p)
				prefixo="$2"
				shift; shift
			;;
			-i)
				i=$2
				shift; shift
			;;
			-d)
				digitos=$2
				shift; shift
			;;
			-n)
				nao='[-n] '
				shift
			;;
			--dropbox)
				dropbox=1
				shift
			;;
			* ) break ;;
		esac
	done

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso nomefoto; return 1; }

	if ! zztool testa_numero "$digitos"
	then
		zztool erro "Número inválido para a opção -d: $digitos"
		return 1
	fi
	if ! zztool testa_numero "$i"
	then
		zztool erro "Número inválido para a opção -i: $i"
		return 1
	fi
	if test "$dropbox" = 1
	then
		if which "exiftool" >/dev/null 2>&1
		then
			exif_cmd=1
		elif which "exiftime" >/dev/null 2>&1
		then
			exif_cmd=2
		elif which "identify" >/dev/null 2>&1
		then
			exif_cmd=3
		else
			zztool erro "A opção --dropbox requer o comando 'exiftool', 'exiftime' ou 'identify', instale um deles."
			zztool erro "O comando 'exiftime' pode fazer parte do pacote 'exiftags'."
			zztool erro "O comando 'identify' faz parte do pacote ImageMagick."
			return 1
		fi
	fi

	# Para cada arquivo que o usuário informou...
	for arquivo
	do
		# O arquivo existe?
		zztool -e arquivo_legivel "$arquivo" || continue

		# Componentes do nome novo
		contagem=$(printf "%0${digitos}d" $i)

		# Se tiver extensão, guarda para restaurar depois
		if zztool grep_var . "$arquivo"
		then
			extensao=".${arquivo##*.}"
		else
			extensao=
		fi

		# Nome do arquivo no formato do Camera Uploads do Dropbox,
		# que usa a data e hora em que a foto foi tirada. Exemplo:
		#
		#     2010-04-05 09.02.11.jpg
		#
		# A data é extraída do campo EXIF chamado DateTimeOriginal.
		# Outra opção seria o campo CreateDate. Veja mais informações em:
		# http://www.sno.phy.queensu.ca/~phil/exiftool/TagNames/EXIF.html
		#
		if test "$dropbox" = 1
		then
			# Extrai a data+hora em que a foto foi tirada conforme o comamdo disponível no sistema
			case $exif_cmd in
				1) exif_info=$(exiftool -s -S -DateTimeOriginal -d '%Y-%m-%d %H.%M.%S' "$arquivo") ;;
				2)
					exif_info=$(exiftime -tg "$arquivo" 2>/dev/null |
					awk -F':' '{print $2 "-" $3 "-" $4 "." $5 "." $6}' |
					sed 's/^ *//') ;;
				3)
					exif_info=$(identify -verbose "$arquivo" |
					awk -F':' '/DateTimeOriginal/ {print $3 "-" $4 "-" $5 "." $6 "." $7}' |
					sed 's/^ *//') ;;
			esac

			# A extensão do arquivo é em minúsculas
			extensao=$(echo "$extensao" | zzminusculas)

			novo="$exif_info$extensao"

			# Será que deu problema na execução do comando?
			if test -z "$exif_info"
			then
				echo "Ignorando $arquivo (não possui dados EXIF)"
				continue
			fi

			# Se o arquivo já está com o nome OK, ignore-o
			if test "$novo" = "$arquivo"
			then
				echo "Arquivo $arquivo já está com o nome correto (nada a fazer)"
				continue
			fi

		# Renomeação normal
		else
			# O nome começa com o prefixo, se informado pelo usuário
			if test -n "$prefixo"
			then
				nome=$prefixo

			# Se não tiver prefixo, usa o nome base do arquivo original,
			# sem extensão nem números no final (se houver).
			# Exemplo: DSC123.JPG -> DSC
			else
				nome=$(echo "${arquivo%.*}" | sed 's/[0-9][0-9]*$//')
			fi

			# Compõe o nome novo
			novo="$nome$contagem$extensao"
		fi

		# Mostra na tela a mudança
		previa="$nao$arquivo -> $novo"

		if test "$novo" = "$arquivo"
		then
			# Ops, o arquivo novo tem o mesmo nome do antigo
			echo "$previa" | sed "s/^\[-n\]/[-ERRO-]/"
		else
			echo "$previa"
		fi

		# Atualiza a contagem (Ah, sério?)
		i=$((i+1))

		# Se não tiver -n, vamos renomear o arquivo
		if ! test -n "$nao"
		then
			# Não sobrescreve arquivos já existentes
			zztool -e arquivo_vago "$novo" || return

			# E finalmente, renomeia
			mv -- "$arquivo" "$novo"
		fi
	done
}

# ----------------------------------------------------------------------------
# zznome
# http://www.significado.origem.nom.br/
# Dicionário de nomes, com sua origem, numerologia e arcanos do tarot.
# Pode-se filtrar por significado, origem, letra (primeira letra), tarot
# marca (no mundo), numerologia ou tudo - como segundo argumento (opcional).
# Por padrão lista origem e significado.
#
# Uso: zznome nome [significado|origem|letra|marca|numerologia|tarot|tudo]
# Ex.: zznome maria
#      zznome josé origem
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2011-04-22
# Versão: 4
# Licença: GPL
# Requisitos: zzsemacento zzminusculas
# ----------------------------------------------------------------------------
zznome ()
{
	zzzz -h nome "$1" && return

	local url='http://www.significado.origem.nom.br'
	local ini='Qual a origem do nome '
	local fim='Analise da Primeira Letra do Nome:'
	local nome=$(echo "$1" | zzminusculas | zzsemacento)

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso nome; return 1; }

	case "$2" in
		origem)
			ini='Qual a origem do nome '
			fim='^ *$'
		;;
		significado)
			ini='Qual o significado do nome '
			fim='^ *$'
		;;
		letra)
			ini='Analise da Primeira Letra do Nome:'
			fim='Sua marca no mundo!'
		;;
		marca)
			ini='Sua marca no mundo!'
			fim='Significado - Numerologia - Expressão'
		;;
		numerologia)
			ini='Significado - Numerologia - Expressão'
			fim=' - Arcanos do Tarot'
		;;
		tarot)
			ini=' - Arcanos do Tarot'
			fim='^VEJA TAMBÉM'
		;;
		tudo)
			ini='Qual a origem do nome '
			fim='^VEJA TAMBÉM'
		;;
	esac

	zztool dump -i 'iso-8859-1' "$url/nomes/?q=$nome" |
		sed -n "
		/$ini/,/$fim/ {
			/$fim/d
			/\[.*: :.*\]/d
			/\[[0-9]\{1,\}\.jpg\]/d
			s/^ *//g
			s/^Qual a origem/Origem/
			s/^Qual o significado/Significado/
			/^Significado de / {
				N
				d
			}
			p
		}" 2>/dev/null
		# Escondendo erros pois a codificação do site é estranha
		# https://github.com/aureliojargas/funcoeszz/issues/27
}

# ----------------------------------------------------------------------------
# zznoticiaslinux
# Busca as últimas notícias sobre Linux em sites nacionais.
# Obs.: Cada site tem uma letra identificadora que pode ser passada como
#       parâmetro, para informar quais sites você quer pesquisar:
#
#         B) Br-Linux             C) Canal Tech
#         D) Diolinux             L) Linux Descomplicado
#         Z) Linuxbuzz
#
# Uso: zznoticiaslinux [sites]
# Ex.: zznoticiaslinux
#      zznoticiaslinux bv
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2001-12-17
# Versão: 10
# Licença: GPL
# Requisitos: zzfeed
# ----------------------------------------------------------------------------
zznoticiaslinux ()
{
	zzzz -h noticiaslinux "$1" && return

	local url limite
	local n=5
	local sites='bcdlz'

	limite="sed ${n}q"

	test -n "$1" && sites="$1"

	# Br Linux
	if zztool grep_var b "$sites"
	then
		url='http://br-linux.org/feed/'
		echo
		zztool eco "* BR-Linux ($url):"
		zzfeed -n $n "$url"
	fi

	# Canal Tech
	if zztool grep_var c "$sites"
	then
		url='https://canaltech.com.br/rss/linux/'
		echo
		zztool eco "* Canal Tech ($url):"
		zzfeed -n $n "$url"
	fi

	# Diolinux
	if zztool grep_var d "$sites"
	then
		url='http://www.diolinux.com.br/feeds/posts/default/'
		echo
		zztool eco "* Diolinux ($url):"
		zzfeed -n $n "$url"
	fi

	# Linux Descomplicado
	if zztool grep_var l "$sites"
	then
		url='https://www.linuxdescomplicado.com.br/category/noticias/feed'
		echo
		zztool eco "* Linux Descomplicado ($url):"
		zzfeed -n $n "$url"
	fi

	# Linuxbuzz
	if zztool grep_var z "$sites"
	then
		url='http://www.linuxbuzz.com.br/feeds/posts/default?alt=rss'
		echo
		zztool eco "* Linuxbuzz ($url):"
		zzfeed -n $n "$url"
	fi
}

# ----------------------------------------------------------------------------
# zznoticiassec
# Busca as últimas notícias em sites especializados em segurança.
# Obs.: Cada site tem uma letra identificadora que pode ser passada como
#       parâmetro, para informar quais sites você quer pesquisar:
#
#       C)ERT/CC            Linux T)oday - Security
#       Linux S)ecurity     Security F)ocus
#
# Uso: zznoticiassec [sites]
# Ex.: zznoticiassec
#      zznoticiassec cft
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2003-07-13
# Versão: 4
# Licença: GPL
# Requisitos: zzfeed
# ----------------------------------------------------------------------------
zznoticiassec ()
{
	zzzz -h noticiassec "$1" && return

	local url limite
	local n=5
	local sites='sctf'

	limite="sed ${n}q"

	test -n "$1" && sites="$1"

	# Linux Security
	if zztool grep_var s "$sites"
	then
		url='http://www.linuxsecurity.com/linuxsecurity_advisories.rdf'
		echo
		zztool eco "* Linux Security ($url):"
		zzfeed -n $n "$url"
	fi

	# CERT/CC
	if zztool grep_var c "$sites"
	then
		url='http://www.us-cert.gov/channels/techalerts.rdf'
		echo
		zztool eco "* CERT/CC ($url):"
		zzfeed -n $n "$url"
	fi

	# Linux Today - Security
	if zztool grep_var t "$sites"
	then
		url='http://feeds.feedburner.com/linuxtoday/linux/'
		echo
		zztool eco "* Linux Today - Security ($url):"
		zzfeed -n $n "$url"
	fi

	# Security Focus
	if zztool grep_var f "$sites"
	then
		url='http://www.securityfocus.com/bid/'
		echo
		zztool eco "* SecurityFocus Vulns Archive ($url):"
		zztool dump "$url" |
			sed -n '
				/^ *\([0-9]\{4\}-[0-9][0-9]-[0-9][0-9]\)/ {
					G
					s/^ *//
					s/\n//p
				}
				h' |
			$limite
	fi
}

# ----------------------------------------------------------------------------
# zznumero
# Formata um número como: inteiro, moeda, por extenso, entre outros.
# Nota: Por extenso suporta 81 dígitos inteiros e até 26 casas decimais.
#
# Opções:
#   -f <padrão|número>  Padrão de formatação do printf, incluindo %'d e %'.f
#                       ou precisão se apenas informado um número
#   -p <prefixo>        Um prefixo para o número, se for R$ igual a opção -m
#   -s <sufixo>         Um sufixo para o número
#   -m | --moeda        Trata valor monetário, sobrepondo as configurações de
#                       -p, -s e -f
#   -t                  Número parcialmente por extenso, ex: 2 milhões 350 mil
#   --texto             Número inteiramente por extenso, ex: quatro mil e cem
#   -l                  Uma classe numérica por linha, quando optar no número
#                       por extenso
#   --de <formato>      Formato de entrada
#   --para <formato>    Formato de saída
#   --int               Parte inteira do número, sem arredondamento
#   --frac              Parte fracionária do número
#
# Formatos para as opções --de e --para:
#   pt ou pt-br => português (brasil)
#   en          => inglês (americano)
#
# Uso: zznumero [opções] <número>
# Ex.: zznumero 12445.78                      # 12.445,78
#      zznumero --texto 4567890,213           # quatro milhões, quinhentos...
#      zznumero -m 85,345                     # R$ 85,34
#      echo 748 | zznumero -f "%'.3f"         # 748,000
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-05
# Versão: 13
# Licença: GPL
# Requisitos: zzvira zztestar
# ----------------------------------------------------------------------------
zznumero ()
{
	zzzz -h numero "$1" && return

	local texto=0
	local prec='-'
	local linha=0
	local sufixo=''
	local num_part=0
	local milhar_de='.'
	local decimal_de=','
	local milhar_para='.'
	local decimal_para=','
	local numero qtde_v qtde_p n_formato num_int num_frac num_saida prefixo sinal n_temp

	# Zero a Novecentos e noventa e nove (base para as demais classes)
	local ordem1="\
0:::
1:um::cento
2:dois:vinte:duzentos
3:três:trinta:trezentos
4:quatro:quarenta:quatrocentos
5:cinco:cinquenta:quinhentos
6:seis:sessenta:seiscentos
7:sete:setenta:setecentos
8:oito:oitenta:oitocentos
9:nove:noventa:novecentos
10:dez::
11:onze::
12:doze::
13:treze::
14:catorze::
15:quinze::
16:dezesseis::
17:dezessete::
18:dezoito::
19:dezenove::"

	# Ordem de grandeza x 1000 (Classe)
	local ordem2="\
0:
1:mil
2:milhões
3:bilhões
4:trilhões
5:quadrilhões
6:quintilhões
7:sextilhões
8:septilhões
9:octilhões
10:nonilhões
11:decilhões
12:undecilhões
13:duodecilhões
14:tredecilhões
15:quattuordecilhões
16:quindecilhões
17:sexdecilhões
18:septendecilhões
19:octodecilhões
20:novendecilhões
21:vigintilhões
22:unvigintilhões
23:douvigintilhões
24:tresvigintilhões
25:quatrivigintilhões
26:quinquavigintilhões"

	# Ordem de grandeza base para a ordem4
	local ordem3="\
1:décimos
2:centésimos"

	# Ordem de grandeza / 1000 (Classe)
	local ordem4="\
1:milésimos
2:milionésimos
3:bilionésimos
4:trilionésimos
5:quadrilionésimos
6:quintilionésimos
7:sextilionésimos
8:septilionésimos"

	# Opções
	while  test "${1#-}" != "$1"
	do
		case "$1" in
		-f)
			# Formato estabelecido pelo usuário conforme printf ou precisão
			# Precisão no formato do printf (esperado)
			n_formato="$2"

			# Sem limites de precisão
			if test "$2" = "-"
			then
				prec="$2"
				unset n_formato
			fi

			# Precisão definida
			if zztool testa_numero "$2"
			then
				prec="$2"
				unset n_formato
			fi
			shift
			shift
		;;

		--de)
			# Formato de entrada
			if test "$2" = "pt" -o "$2" = "pt-br"
			then
				milhar_de='.'
				decimal_de=','
				shift
			elif test "$2" = "en"
			then
				milhar_de=','
				decimal_de='.'
				shift
			fi
			shift
		;;

		--para)
			# Formato de saída
			if test "$2" = "pt" -o "$2" = "pt-br"
			then
				milhar_para='.'
				decimal_para=','
				shift
			elif test "$2" = "en"
			then
				milhar_para=','
				decimal_para='.'
				shift
			fi
			shift
		;;

		# Define qual parte do número a exibir
		# 0 = sem restrição(padrão)  1 = só parte inteira  2 = só parte fracionária
		--int) num_part=1; shift;;
		--frac) num_part=2; shift;;

		-p)
			# Prefixo escolhido pelo usuário
			prefixo="$2"
			echo "$2" | grep '^ *[rR]$ *$' > /dev/null && prefixo='R$ '
			shift
			shift
		;;

		-s)
			# Sufixo escolhido pelo usuário
			sufixo="$2"
			shift
			shift
		;;

		-t | --texto)
			# Variável para número por extenso
			# Flag para formato por extenso
			test "$1" = "-t" && texto=1
			test "$1" = "--texto" && texto=2
			shift
		;;

		-l)
			# No modo texto, uma classe numérica por linha
			linha=1
			shift
		;;

		-m | --moeda)
			# Solicitando formato moeda (sobrepõe as opções de prefixo, sufixo e formato)
			prec=2
			prefixo='R$ '
			unset sufixo
			unset n_formato
			shift
		;;

		*) break;;
		esac
	done

	# Habilitar entrada direta ou através de pipe
	n_temp=$(zztool multi_stdin "$@")

	# Adequando entrada do valor a algumas possíveis armadilhas
	set - $n_temp
	n_temp=$(echo "$1" | sed 's/[.,]$//')
	n_temp=$(echo "$n_temp" | sed 's/^\([.,]\)/0\1/')

	# Verificando se a entrada é apenas numérica, incluindo ponto (.) e vírgula (,)
	test $(printf -- "$n_temp" | tr -d [+0-9.,-] | wc -m) -eq 0 || return 1
	# Verificando se há números
	test $(printf -- "$n_temp" | tr -d -c [0-9] | wc -m) -gt 0 || return 1
	set - $n_temp

	# Armazenando o sinal, se presente
	sinal=$(echo "$1" | cut -c1)
	if test "$sinal" = "+" -o "$sinal" = "-"
	then
		set - $(echo "$1" | sed 's/^[+-]//')
	else
		unset sinal
	fi

	# Trocando o símbolo de milhar de entrada por "m" e depois por . (ponto)
	# Trocando o símbolo de decimal de entrada por "d" e depois , (vírgula)
	n_temp=$(echo "$1" | tr "${milhar_de}" 'm' | tr "${decimal_de}" 'd')
	n_temp=$(echo "$n_temp" | tr 'm' '.' | tr 'd' ',')

	set - $n_temp

	if zztool testa_numero "$1" && ! zztool grep_var 'R$' "$prefixo"
	then
	# Testa se o número é um numero inteiro sem parte fracionária ou separador de milhar
		if test ${#n_formato} -gt 0
		then
			numero=$(printf "${n_formato}" "$1" 2>/dev/null)
		else
			numero=$(echo "$1" | zzvira | sed 's/.../&./g;s/\.$//' | zzvira)
		fi
		num_int="$1"
		if test "$num_part" != "2"
		then
			num_saida="${sinal}${numero}"

			# Aplicando o formato conforme opção --para
			num_saida=$(echo "$num_saida" | tr '.' "${milhar_para}")
		fi

	else

		# Testa se o número é um numero inteiro sem parte fracionária ou separador de milhar
		# e que tem o prefixo 'R$', caracterizando como moeda
		if zztool testa_numero "$1" && zztool grep_var 'R$' "$prefixo"
		then
			numero="${1},00"
		fi

		# Quantidade de pontos ou vírgulas no número informado
		qtde_p=$(echo "$1" | tr -cd '.'); qtde_p=${#qtde_p}
		qtde_v=$(echo "$1" | tr -cd ','); qtde_v=${#qtde_v}

		# Número com o "ponto decimal" separando a parte fracionária, sem separador de milhar
		# Se for padrão 999.999, é considerado um inteiro
		if test $qtde_p -eq 1 -a $qtde_v -eq 0 && zztestar numero_fracionario "$1"
		then
			if echo "$1" | grep '^[0-9]\{1,3\}\.[0-9]\{3\}$' >/dev/null
			then
				numero=$(echo "$1" | tr -d '.')
			else
				numero=$(echo "$1" | tr '.' ',')
			fi
		fi

		# Número com a "vírgula" separando da parte fracionária, sem separador de milhares
		if test $qtde_v -eq 1 -a $qtde_p -eq 0 && zztestar numero_fracionario "$1"
		then
			numero="$1"
		fi

		# Número com o "ponto" como separador de milhar, e sem parte fracionária
		if (test $qtde_p -gt 1 -a $qtde_v -eq 0 && test -z $numero )
		then
			echo $1 | grep '^[0-9]\{1,3\}\(\.[0-9]\{3\}\)\{1,\}$' >/dev/null
			test $? -eq 0  && numero=$(echo $1 | tr -d '.')
		fi

		# Número com a "vírgula" como separador de milhar, e sem parte fracionária
		if (test $qtde_v -gt 1 -a $qtde_p -eq 0 && test -z $numero )
		then
			echo $1 | grep '^[0-9]\{1,3\}\(,[0-9]\{3\}\)\{1,\}$' >/dev/null
			test $? -eq 0  && numero=$(echo $1 | tr -d ',')
		fi

		# Número com uma "vírgula" e um "ponto", nesse caso tem separador de millhar e parte facionária
		if (test $qtde_p -eq 1 -a $qtde_v -eq 1 && test -z $numero )
		then
			numero=$(echo $1 | sed 's/[.,]//' | tr '.' ',')
		fi

		# Numero começando com ponto ou vírgula, sendo considerado só fracionário
		if test -z $numero
		then
			echo $1 | grep '^[,.][0-9]\{1,\}$' >/dev/null
			test $? -eq 0  && numero=$(echo "0${1}" | tr '.' ',')
		fi

		if test -z $numero
		then
		# Deixando o número com o formato 0000,00 (sem separador de milhar)
			# Número com o "ponto" separando a parte fracionária e vírgula como separador de milhar
			echo $1 | grep '^[0-9]\{1,3\}\(,[0-9]\{3\}\)\{1,\}\.[0-9]\{1,\}$' >/dev/null
			test $? -eq 0  && numero=$(echo $1 | tr -d ',' | tr '.' ',')

			# Número com a "vírgula" separando a parte fracionária e ponto como separador de milhar
			echo $1 | grep '^[0-9]\{1,3\}\(\.[0-9]\{3\}\)\{1,\},[0-9]\{1,\}$' >/dev/null
			test $? -eq 0  && numero=$(echo $1 | tr -d '.')
		fi

		if test -n $numero
		then
			# Separando componentes dos números
			num_int=${numero%,*}
			zztool grep_var ',' "$numero" && num_frac=${numero#*,}

			# Tirando os zeros não significativos
			num_int=$(echo "$num_int" | sed 's/^0*//')
			test ${#num_int} -eq 0 && num_int=0

			test ${#num_frac} -gt 0 && num_frac=$(echo "$num_frac" | sed 's/0*$//')

			if test ${#num_frac} -gt 0
			then
				zztool testa_numero $num_frac || { zztool -e uso numero; return 1; }
			fi

			# Se houver precisão estabelecida pela opção -f
			if test "$prec" != "-" && test $prec -ge 0 && test ${#n_formato} -eq 0
			then
				# Para arredondamento usa-se a seguinte regra:
				#  Se o próximo número além da precisão for maior que 5 arredonda-se para cima
				#  Se o próximo número além da precisão for menor que 5 arredonda-se para baixo
				#  Se o próximo número além da precisão for 5, vai depender do número anterior
				#    Se for par arredonda-se para baixo
				#    Se for ímpar arredonda-se para cima
				if test ${#num_frac} -gt $prec
				then

					# Quando for -f 0, sem casas decimais, guardamos o ultimo digito do num_int (parte inteira)
					unset n_temp
					if test $prec -eq 0
					then
						n_temp=${#num_int}
						n_temp=$(echo "$num_int" | cut -c $n_temp)
					fi

					num_frac=$(echo "$num_frac" | cut -c 1-$((prec + 1)))

					if test $(echo "$num_frac" | cut -c $((prec + 1))) -ge 6
					then
						# Último número maior que cinco (além da precisão), arredonda pra cima
						if test $prec -eq 0
						then
							unset num_frac
							num_int=$(echo "$num_int + 1" | bc)
						else
							num_frac=$(echo "$num_frac" | cut -c 1-${prec})
							if echo "$num_frac" | grep -E '^9{1,}$' > /dev/null
							then
								num_int=$(echo "$num_int + 1" | bc)
								num_frac=0
							else
								num_frac=$(echo "$num_frac + 1" | bc)
							fi
						fi

					elif test $(echo "$num_frac" | cut -c $((prec + 1))) -le 4
					then
						# Último número menor que cinco (além da precisão), arredonda pra baixo (trunca)
						if test $prec -eq 0
						then
							unset num_frac
						else
							num_frac=$(echo "$num_frac" | cut -c 1-${prec})
						fi

					else
						if test $prec -eq 0
						then
							unset num_frac
							# Se o último número do num_int for ímpar, arredonda-se para cima
							if test $(($n_temp % 2)) -eq 1
							then
								num_int=$(echo "$num_int + 1" | bc)
							fi
						else
						# Determinando último número dentro da precisão é par
							if test $(echo $(($(echo $num_frac | cut -c ${prec}) % 2))) -eq 0
							then
								# Se sim arredonda-se para baixo (trunca)
								num_frac=$(echo "$num_frac" | cut -c 1-${prec})
							else
								# Se não arredonda-se para cima
								num_frac=$(echo "$num_frac" | cut -c 1-${prec})

								# Exceção: Se num_frac for 9*, vira 0* e aumenta num_int em mais 1
								echo "$num_frac" | cut -c 1-${prec} | grep '^9\{1,\}$' > /dev/null
								if test $? -eq 0
								then
									unset num_frac
									num_int=$(echo "$num_int + 1" | bc)
								else
									num_frac=$(echo "$num_frac + 1" | bc)
								fi
							fi
						fi
					fi

					# Restaurando o tamanho do num_frac
					while test ${#num_frac} -lt $prec -a ${#num_frac} -gt 0
					do
						num_frac="0${num_frac}"
					done
				fi

				# Tirando os zeros não significativos
				num_frac=$(echo "$num_frac" | sed 's/0*$//')
			fi

			test "$num_part" = "1" && unset num_frac
			test "$num_part" = "2" && unset num_int

			if zztool grep_var 'R$' "$prefixo"
			then
			# Caso especial para opção -m, --moedas ou prefixo 'R$'
			# Formato R$ 0.000,00 (sempre)
				# Arredondamento para 2 casas decimais
				test ${#num_frac} -eq 0 -a $texto -eq 0 && num_frac="00"
				test ${#num_frac} -eq 1 && num_frac="${num_frac}0"
				test ${#num_int} -eq 0 -a $texto -eq 0 && num_int=0

				numero=$(echo "${num_int}" | zzvira | sed 's/.../&\./g;s/\.$//' | zzvira)
				num_saida="${numero},${num_frac}"

				# Aplicando o formato conforme opção --para
				num_saida=$(echo "$num_saida" | tr '.' 'm' | tr ',' 'd')
				num_saida=$(echo "$num_saida" | tr 'm' "${milhar_para}" | tr 'd' "${decimal_para}")

			elif test ${#n_formato} -gt 0
			then

			# Conforme formato solicitado pelo usuário
				if test ${#num_frac} -gt 0
				then
				# Se existir parte fracionária

					# Para shell configurado para vírgula como separador da parte decimal
					numero=$(printf "${n_formato}" "${num_int},${num_frac}" 2>/dev/null)
					# Para shell configurado para ponto como separador da parte decimal
					test $? -ne 0 && numero=$(printf "${n_formato}" "${num_int}.${num_frac}" 2>/dev/null)
				else
				# Se tiver apenas a parte inteira
					numero=$(printf "${n_formato}" "${num_int}" 2>/dev/null)
				fi
				num_saida=$numero
			else
				numero=$(echo "${num_int}" | zzvira | sed 's/.../&\./g;s/\.$//' | zzvira)
				num_saida="${numero},${num_frac}"

				# Aplicando o formato conforme opção --para
				num_saida=$(echo "$num_saida" | tr '.' 'm' | tr ',' 'd')
				num_saida=$(echo "$num_saida" | tr 'm' "${milhar_para}" | tr 'd' "${decimal_para}")
			fi

			if zztool grep_var 'R$' "$prefixo"
			then
				num_saida=$(echo "${sinal}${prefixo}${num_saida}" | sed 's/[,.]$//')
			else
				num_saida=$(echo "${sinal}${num_saida}" | sed 's/[,.]$//')
			fi

		fi
	fi

	if test $texto -eq 1 -o $texto -eq 2
	then

		######################################################################

		# Escrevendo a parte inteira. (usando a variável qtde_p emprestada)
		qtde_p=$(((${#num_int}-1) / 3))

		# Colocando os números como argumentos
		set - $(echo "${num_int}" | zzvira | sed 's/.../&\ /g' | zzvira)

		# Liberando as variáveis numero e num_saida para receber o número por extenso
		unset numero
		unset num_saida

		# Caso especial para o 0 (zero)
		if test "$num_int" = "0"
		then
			test $texto -eq 1 && num_saida=$num_int
			test $texto -eq 2 && num_saida='zero'
		fi

		while test -n "$1"
		do
			# Emprestando a variável qtde_v para cada conjunto de 3 números do número original (ordem de grandeza)
			# Tirando os zeros não significativos nesse contexto

			qtde_v=$(echo "$1" | sed 's/^[ 0]*//')

			if test ${#qtde_v} -gt 0
			then
				# Emprestando a variável n_formato para guardar a descrição da ordem2
				n_formato=$(echo "$ordem2" | grep "^${qtde_p}:" 2>/dev/null | cut -f2 -d":")
				test "$qtde_v" = "1" && n_formato=$(echo "$n_formato" | sed 's/ões/ão/')

				if test $texto -eq 2
				then
				# Números também por extenso

					case ${#qtde_v} in
						1)
							# Número unitario, captura direta do texto no segundo campo
							numero=$(echo "$ordem1" | grep "^${qtde_v}:" | cut -f2 -d":")
						;;
						2)
							if test $(echo "$qtde_v" | cut -c1) -eq 1
							then
								# Entre 10 e 19, captura direta do texto no segundo campo
								numero=$(echo "$ordem1" | grep "^${qtde_v}:" | cut -f2 -d":")
							elif test $(echo "$qtde_v" | cut -c2) -eq 0
							then
								# Dezenas, captura direta do texto no terceiro campo
								n_temp=$(echo "$qtde_v" | cut -c1)
								numero=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f3 -d":")
							else
								# 21 a 99, excluindo as dezenas terminadas em zero
								# Dezena
								n_temp=$(echo "$qtde_v" | cut -c1)
								numero=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f3 -d":")

								# Unidade
								n_temp=$(echo "$qtde_v" | cut -c2)
								n_temp=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f2 -d":")

								# Numero dessa classe
								numero="$numero e $n_temp"
							fi
						;;
						3)
							if test $qtde_v -eq 100
							then
								# Exceção para o número cem
								numero="cem"
							else
								# 101 a 999
								# Centena
								n_temp=$(echo "$qtde_v" | cut -c1)
								numero=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f4 -d":")

								# Dezena
								n_temp=$(echo "$qtde_v" | cut -c2)
								if test "$n_temp" != "0"
								then
									if test "$n_temp" = "1"
									then
										n_temp=$(echo "$qtde_v" | cut -c2-3)
										n_temp=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f2 -d":")
										numero="$numero e $n_temp"
									else
										n_temp=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f3 -d":")
										numero="$numero e $n_temp"
									fi
								fi

								# Unidade
								n_temp=$(echo "$qtde_v" | cut -c2)
								if test "$n_temp" != "1"
								then
									n_temp=$(echo "$qtde_v" | cut -c3)
									if test "$n_temp" != "0"
									then
										n_temp=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f2 -d":")
										numero="$numero e $n_temp"
									fi
								fi
							fi
						;;
					esac
				fi

				if test $texto -eq 2
				then
					if test -n "$n_formato"
					then
						test -n "$num_saida" && num_saida="${num_saida}, ${numero} ${n_formato}" || num_saida="${numero} ${n_formato}"
					else
						num_saida="${num_saida} ${numero}"
						num_saida=$(echo "${num_saida}" | sed 's/ilhões  *\([a-z]\)/ilhões, \1/;s/ilhão  *\([a-z]\)/ilhão, \1/')
					fi
				else
					num_saida="${num_saida} ${qtde_v} ${n_formato}"
				fi
			fi

			qtde_p=$((qtde_p - 1))
			shift
		done
		test -n "$num_saida" && num_saida=$(echo "${num_saida}" | sed 's/ *$//;s/ \{1,\}/ /g')

		# Milhar seguido de uma centena terminada em 00.
		# Milhar seguida de uma unidade ou dezena
		# Caso "Um mil" em desuso, apenas "mil" usa-se
		if zztool grep_var ' mil' "${num_saida}"
		then
			# Colocando o "e" entre o mil seguido de 1 ao 19
			for n_temp in $(echo "$ordem1" | cut -f 2 -d: | sed '/^ *$/d')
			do
				num_saida=$(echo "${num_saida}" | sed 's/^ *//;s/ *$//' | sed "s/ mil $n_temp$/ mil e $n_temp/")
				num_saida=$(echo "${num_saida}" | sed 's/^ *//;s/ *$//' | sed "s/^ *mil $n_temp$/ mil e $n_temp/")
			done

			# Colocando o "e" entre o mil seguido de dezenas terminadas em 0
			for n_temp in $(echo "$ordem1" | cut -f 3 -d: | sed '/^ *$/d' )
			do
				num_saida=$(echo "${num_saida}" | sed 's/^ *//;s/ *$//' | sed "s/ mil $n_temp$/ mil e $n_temp/")
				num_saida=$(echo "${num_saida}" | sed 's/^ *//;s/ *$//' | sed "s/^ *mil $n_temp$/ mil e $n_temp/")
			done

			# Colocando o "e" entre o mil seguido de dezenas não terminadas em 0
			# usando as variáveis milhar_para e decimal_para emprestada para esse laço
			for milhar_para in $(echo "$ordem1" | sed -n '3,10p' | cut -f3 -d:)
			do
				for decimal_para in $(echo "$ordem1" | sed -n '2,10p' | cut -f2 -d:)
				do
					n_temp="$milhar_para e $decimal_para"
					num_saida=$(echo "${num_saida}" | sed 's/^ *//;s/ *$//' | sed "s/ mil $n_temp$/ mil e $n_temp/")
					num_saida=$(echo "${num_saida}" | sed 's/^ *//;s/ *$//' | sed "s/^ *mil $n_temp$/ mil e $n_temp/")
				done
			done

			# Trabalhando o contexto do e entre classe do milhar e unidade.
			num_saida=$(echo "${num_saida}" | sed 's/^ *//;s/ *$//' | sed 's/\( mil \)\([a-z]*\)entos$/\1 e \2entos/')
			num_saida=$(echo "${num_saida}" | sed 's/^ *//;s/ *$//' | sed 's/ mil cem$/ mil e cem/')

			# Tabalhando o contexto do "um mil"
			num_saida=$(echo "${num_saida}" | sed 's/^ *//;s/ *$//' | sed 's/^ *um mil /mil /;s/^ *um mil *$/mil/')
			num_saida=$(echo "${num_saida}" | sed 's/, *um mil /, mil /')

			# Substituindo a última vírgula "e", nos casos sem a classe milhar.
			if ! zztool grep_var ' mil ' "$num_saida"
			then
				qtde_v=$(echo "$num_saida" | sed 's/./&\n/g' | grep -c ",")
				test $qtde_v -gt 0 && num_saida=$(echo "${num_saida}" | sed "s/,/ e /${qtde_v}")
			fi
		fi

		# Colocando o sufixo
		num_saida="${num_saida} inteiros"
		test "$num_int" = "1" && num_saida=$(echo "${num_saida}" | sed 's/inteiros/inteiro/')

		######################################################################

		# Validando as parte fracionária do número
		if test ${#num_frac} -gt 0
		then
			zztool testa_numero $num_frac || { zztool -e uso numero; return 1; }
		fi

		# Escrevendo a parte fracionária. (usando a variável qtde_p emprestada)
		qtde_p=$(((${#num_frac}-1) / 3))

		# Colocando os números como argumentos
		set - $(echo "${num_frac}" | zzvira | sed 's/.../&\ /g' | zzvira)

		# Liberando as variáveis numero para receber o número por extenso
		unset numero

		if test -n "$1"
		then
			# Tendo parte fracionário, e inteiro sendo 0 (zero), parte inteira é apagada.
			test "$num_int" = "0" && unset num_saida

			# Tendo parte fracionária, conecta com o "e"
			test -n "$num_saida" && num_saida="${num_saida} e "
		fi

		while test -n "$1"
		do
			# Emprestando a variável qtde_v para cada conjunto de 3 números do número original (ordem de grandeza)
			# Tirando os zeros não significativos nesse contexto
			qtde_v=$(echo "$1" | sed 's/^[ 0]*//')

			if test ${#qtde_v} -gt 0
			then
				# Emprestando a variável n_formato para guardar a descrição da ordem2
				n_formato=$(echo "$ordem2" | grep "^${qtde_p}:" 2>/dev/null | cut -f2 -d":")
				test "$qtde_v" = "1" && n_formato=$(echo "$n_formato" | sed 's/ões/ão/')
				n_formato=$(echo "$n_formato" | sed 's/inteiros//')

				if test $texto -eq 2
				then
				# Numeros também por extenso
					case ${#qtde_v} in
						1)
							# Número unitario, captura direta do texto no segundo campo
							numero=$(echo "$ordem1" | grep "^${qtde_v}:" | cut -f2 -d":")
						;;
						2)
							if test $(echo "$qtde_v" | cut -c1) -eq 1
							then
								# Entre 10 e 19, captura direta do texto no segundo campo
								numero=$(echo "$ordem1" | grep "^${qtde_v}:" | cut -f2 -d":")
							elif test $(echo "$qtde_v" | cut -c2) -eq 0
							then
								# Dezenas, captura direta do texto no terceiro campo
								n_temp=$(echo "$qtde_v" | cut -c1)
								numero=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f3 -d":")
							else
								# 21 a 99, excluindo as dezenas terminadas em zero
								# Dezena
								n_temp=$(echo "$qtde_v" | cut -c1)
								numero=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f3 -d":")

								# Unidade
								n_temp=$(echo "$qtde_v" | cut -c2)
								n_temp=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f2 -d":")

								# Número dessa classe
								numero="$numero e $n_temp"
							fi
						;;
						3)
							if test $qtde_v -eq 100
							then
								# Exceção para o número cem
								numero="cem"
							else
								# 101 a 999
								# Centena
								n_temp=$(echo "$qtde_v" | cut -c1)
								numero=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f4 -d":")

								# Dezena
								n_temp=$(echo "$qtde_v" | cut -c2)
								if test "$n_temp" != "0"
								then
									if test "$n_temp" = "1"
									then
										n_temp=$(echo "$qtde_v" | cut -c2-3)
										n_temp=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f2 -d":")
										numero="$numero e $n_temp"
									else
										n_temp=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f3 -d":")
										numero="$numero e $n_temp"
									fi
								fi

								# Unidade
								n_temp=$(echo "$qtde_v" | cut -c2)
								if test "$n_temp" != "1"
								then
									n_temp=$(echo "$qtde_v" | cut -c3)
									if test "$n_temp" != "0"
									then
										n_temp=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f2 -d":")
										numero="$numero e $n_temp"
									fi
								fi
							fi
						;;
					esac
				fi

				if test $texto -eq 2
				then
					num_saida="${num_saida} ${numero} ${n_formato}"
				else
					num_saida="${num_saida} ${qtde_v} ${n_formato}"
				fi
			fi

			qtde_p=$((qtde_p - 1))
			shift
		done

		if test ${#num_frac} -gt 0
		then
			# Primeiro sub-nível (ordem)
			n_temp=$((${#num_frac} % 3))
			n_temp=$(echo "$ordem3" | grep "^${n_temp}:" | cut -f2 -d":")
			num_saida="${num_saida} ${n_temp}"

			# Segundo sub-nível (classes)
			n_temp=$(((${#num_frac}-1) / 3))
			test $((${#num_frac} % 3)) -eq 0  && n_temp=$((n_temp + 1))
			n_temp=$(echo "$ordem4" | grep "^${n_temp}:" | cut -f2 -d":")
			num_saida="${num_saida} ${n_temp}"

			num_saida=$(echo "$num_saida" |
				sed 's/décimos \([a-z]\)/décimos de \1/;s/centésimos \([a-z]\)/centésimos de \1/' |
				sed 's/ *$//;s/ \{1,\}/ /g')

			# Ajuste para valor unitário na parte fracionária
			$(echo $num_frac | grep '^0\{1,\}1$' > /dev/null) && num_saida=$(echo $num_saida | sed 's/imos/imo/g')
		fi

		######################################################################

		# Zero (0) não é positivo e nem negativo
		n_temp=$(echo "$num_saida" | sed 's/inteiros//' | tr -d ' ')
		if test "$n_temp" != "0" -a "$n_temp" != "zero"
		then
			test "$sinal" = '-' && num_saida="$num_saida negativos"
			test "$sinal" = '+' && num_saida="$num_saida positivos"
		fi

		# Para o caso de ser o número 1, colocar no singular
		if test "$num_int" = "1"
		then
			if test ${#num_frac} -eq 0
			then
				num_saida=$(echo $num_saida | sed 's/s$//')
			elif test "$num_frac" = "00"
			then
				num_saida=$(echo $num_saida | sed 's/s$//')
			fi
		fi

		# Sufixo dependendo se for valor monetário
		if zztool grep_var 'R$' "$prefixo"
		then
			num_saida=$(echo "$num_saida" | sed 's/inteiros/reais/;s/inteiro/real/;s/centésimo/centavo/')
		else
			num_saida=$(echo "$num_saida" | sed "s/inteiros/${sufixo}/;s/inteiro/${sufixo}/")
		fi

		num_saida=$(echo "$num_saida" | sed 's/ e  *e / e /g; s/  */ /g' | sed 's/^ *e //; s/ e *$//; s/^ *//g')

		# Uma classe numérica por linha
		if test $linha -eq 1
		then
			case $texto in
			1)
				num_saida=$(echo " $num_saida" |
				sed 's/ [0-9]/\
&/g' | sed '/^ *$/d')
			;;
			2)
				num_saida=$(echo " $num_saida" |
				sed 's/ilhões/&\
/g;s/ilhão/&\
/g;s/mil /&\
/' |
				sed 's/inteiros*/&\
/;s/rea[li]s*/&\
/')
			;;
			esac
		fi

		zztool grep_var 'R$' "$prefixo" && unset prefixo
		test -n "$prefixo" && num_saida="${prefixo} ${num_saida}"
		echo "${num_saida}" | sed 's/ *$//g;s/ \{1,\}/ /g;s/^[ ,]*//g'

	else
		# Zero (0) não é positivo e nem negativo
		n_temp=$(echo "$num_saida" | sed 's/^[+-]//')
		if test "$n_temp" = "0" -o "$n_temp" = "R$ 0"
		then
			num_saida=$n_temp
		fi

		zztool grep_var 'R$' "$prefixo" && unset prefixo
		test ${#num_saida} -gt 0 && echo ${prefixo}${num_saida}${sufixo}
	fi
}

# ----------------------------------------------------------------------------
# zzora
# http://ora-code.com
# Retorna a descrição do erro Oracle (AAA-99999).
# Uso: zzora numero_erro
# Ex.: zzora 1234
#
# Autor: Rodrigo Pereira da Cunha <rodrigopc (a) gmail.com>
# Desde: 2005-11-03
# Versão: 6
# Licença: GPL
# Requisitos: zzurldecode
# ----------------------------------------------------------------------------
zzora ()
{
	zzzz -h ora "$1" && return

	test $# -ne 1 && { zztool -e uso ora; return 1; } # deve receber apenas um argumento
	zztool -e testa_numero "$1" || return 1 # e este argumento deve ser numérico

	local link
	local url='http://www.oracle.com/pls/db92/error_search?search'
	local cod=$(printf "%05d" $1)

	zztool source "${url}=${cod}" |
	sed -n "/to_URL.*-${cod}/{s/.*name=//;s/\">.*//;p;}" |
	zzurldecode |
	while read link
	do
		zztool dump "$link" |
		sed -n "/^ *[A-Z0-9]\{1,\}-$cod/,/-[0-9]\{5\}[^0-9]/p" |
		sed '/___/,$d; 2,${ /-[0-9]\{5\}[^0-9]/d; }' |
		sed '1s/^ *//; 2,$s/^  */  /'
		echo
	done | awk '
			/^[ 	]*$/{ branco++ }

			! /^[ 	]*$/ {
				if (branco==1) { print ""; branco=0 }
				else if (branco>1)  {
					print "===================================================================================================="
					print ""; branco=0
				}
				print
			}
		'
}

# ----------------------------------------------------------------------------
# zzpad
# Preenche um texto para um certo tamanho com outra string.
#
# Opções:
#   -d, -r     Preenche à direita (padrão)
#   -e, -l     Preenche à esquerda
#   -a, -b     Preenche em ambos os lados
#   -x STRING  String de preenchimento (padrão=" ")
#
# Uso: zzpad [-d | -e | -a] [-x STRING] <tamanho> [texto]
# Ex.: zzpad -x 'NO' 21 foo     # fooNONONONONONONONONO
#      zzpad -a -x '_' 9 foo    # ___foo___
#      zzpad -d -x '♥' 9 foo    # foo♥♥♥♥♥♥
#      zzpad -e -x '0' 9 123    # 000000123
#      cat arquivo.txt | zzpad -x '_' 99
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2014-05-18
# Versão: 5
# Licença: GPL
# ----------------------------------------------------------------------------
zzpad ()
{
	zzzz -h pad "$1" && return

	local largura
	local posicao='r'
	local str_pad=' '

	# Opções da posição do padding (left, right, both | esquerda, direita, ambos)
	while test "${1#-}" != "$1"
	do
		case "$1" in
		-l | -e) posicao='l'; shift ;;
		-r | -d) posicao='r'; shift ;;
		-b | -a) posicao='b'; shift ;;
		-x     ) str_pad="$2"; shift; shift ;;
		-*) zztool erro "Opção inválida: $1"; return 1 ;;
		*) break;;
		esac
	done

	# Tamanho da string
	if zztool testa_numero "$1" && test "$1" -gt 0
	then
		largura="$1"
		shift
	else
		zztool -e uso pad
		return 1
	fi

	if test -z "$str_pad"
	then
		zztool erro "A string de preenchimento está vazia"
		return 1
	fi

	# Escapa caracteres especiais no s/// do sed: \ / &
	str_pad=$(echo "$str_pad" | sed 's,\\,\\\\,g; s,/,\\/,g; s,&,\\&,g')

	zztool multi_stdin "$@" |
		zztool nl_eof |
		case "$posicao" in
			l) sed -e ':loop'	-e "/^.\{$largura\}/ b" -e "s/^/$str_pad/" -e 'b loop';;
			r) sed -e ':loop'	-e "/^.\{$largura\}/ b" -e "s/$/$str_pad/" -e 'b loop';;
			b) sed -e ':loop'	-e "/^.\{$largura\}/ b" -e "s/$/$str_pad/" \
								-e "/^.\{$largura\}/ b" -e "s/^/$str_pad/" -e 'b loop';;
		esac

	### Explicação do algoritmo sed
	# Os três comandos são similares, é um loop que só é quebrado quando o
	# tamanho atual do buffer satisfaz o tamanho desejado ($largura).
	# A cada volta do loop, é adicionado o texto de padding $str_pad antes
	# (s/^/…/) e/ou depois (s/$/…/) do texto atual.
}

# ----------------------------------------------------------------------------
# zzpais
# Lista os países.
# Opções:
#  -a: Todos os países
#  -i: Informa o(s) idioma(s)
#  -o: Exibe o nome do país e capital no idioma nativo
# Outra opção qualquer é usado como filtro para pesquisar entre os países.
# Obs.: Sem argumentos, mostra um país qualquer.
#
# Uso: zzpais [palavra|regex]
# Ex.: zzpais              # mostra um pais qualquer
#      zzpais unidos       # mostra os países com "unidos" no nome
#      zzpais -o nova      # mostra o nome original de países com "nova".
#      zzpais ^Z           # mostra os países que começam com Z
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-29
# Versão: 4
# Licença: GPL
# Requisitos: zzlinha zzpad
# ----------------------------------------------------------------------------
zzpais ()
{
	zzzz -h pais "$1" && return

	local url='https://pt.wikipedia.org/wiki/Lista_de_pa%C3%ADses_e_capitais_em_l%C3%ADnguas_locais'
	local cache=$(zztool cache pais)
	local original=0
	local idioma=0
	local padrao linha field1 field2

	# Se o cache está vazio, baixa-o da Internet
	if ! test -s "$cache"
	then
		zztool source "$url" |
		sed -n '/class="wikitable"/,/<\/table>/p' |
		sed '/<th/d;s|</td>|:|g;s|</tr>|--n--|g;s|<br */*>|, |g;s/<[^>]*>//g;s/([^)]*)//g;s/\[.\]//g' |
		awk '{
			if ($0 == "--n--"){ print ""}
			else {printf "%s", $0}
		}' |
		sed 's/, *:/:/g;s/^ *//g;s/ *, *,/,/g;s/ *$//g;s/[,:] *$//g;/Taiuã:/d;/^ *$/d' > "$cache"
	fi

	while test "${1#-}" != "$1"
	do
		case "$1" in
			# Mostra idioma
			-i) idioma=1; shift;;
			# Mostra nome e capital do país no idioma nativo
			-o) original=1; shift;;
			# Lista todos os países
			-a) padrao='.'; shift;;
			*) break;;
		esac
	done

	test "${#padrao}" -eq 0 && padrao="$*"
	if test -z "$padrao"
	then
		# Mostra um país qualquer
		zzlinha -t . "$cache" |
		awk -v idioma_awk="$idioma" -v original_awk="$original" '
			BEGIN {
				FS=":"
				if (original_awk == 0) {
					printf "%s|%s\n", "País", "Capital"
					print "------------------------------------------|----------------------------------"
				}
			}
			{
			if (original_awk == 0) { printf "%s|%s\n", $1, $2 }
			else {
				print "País     : " $3
				print "Capital  : " $4
			}
			if (idioma_awk == 1) { print "Idioma(s):", $5 }
			}'
	else
		# Faz uma busca nos países
		padrao=$(echo $padrao | sed 's/\$$/:.*:.*:.*:.*\$/')
		padrao=$(echo $padrao | sed 's/[^$]$/&.*:.*:.*:.*:.*/')
		grep -h -i -- "$padrao" "$cache" |
		awk -v idioma_awk="$idioma" -v original_awk="$original" '
			BEGIN {FS=":"}
			{	if (NR==1 && original_awk == 0) {
					printf "%s|%s\n", "País", "Capital"
					print "------------------------------------------|----------------------------------"
				}
				if (original_awk == 0) { printf "%s|%s\n", $1, $2 }
				else {
					print "País     : " $3
					print "Capital  : " $4
				}
				if (idioma_awk == 1) { print "Idioma(s):", $5 }
				if (idioma_awk == 1 || original_awk == 1) print ""
			}'
	fi |
	while read linha
	do
		if zztool grep_var "|" "$linha"
		then
			field1=$(echo "$linha" | cut -f1 -d '|')
			field2=$(echo "$linha" | cut -f2 -d '|')
			echo "$(zzpad 42 $field1) $field2"
		else
			echo "$linha"
			unset field1
			unset field2
		fi
	done |
	sed 's/  *$//'
}

# ----------------------------------------------------------------------------
# zzpalpite
# Palpites de jogos para várias loterias: quina, megasena, lotomania, etc.
# Aqui está a lista completa de todas as loterias suportadas:
# quina, megasena, duplasena, lotomania, lotofácil, timemania, federal, loteca
#
# Uso: zzpalpite [quina|megasena|duplasena|lotomania|lotofacil|federal|timemania|loteca]
# Ex.: zzpalpite
#      zzpalpite megasena
#      zzpalpite megasena federal lotofacil
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2012-06-03
# Versão: 5
# Licença: GPL
# Requisitos: zzminusculas zzsemacento zzseq zzaleatorio
# ----------------------------------------------------------------------------
zzpalpite ()
{
	zzzz -h palpite "$1" && return

	local tipo num posicao numeros palpites inicial final i
	local qtde=0
	local tipos='quina megasena duplasena lotomania lotofacil federal timemania loteca'

	# Escolhe as loteria
	test -n "$1" && tipos=$(echo "$*" | zzminusculas | zzsemacento)

	for tipo in $tipos
	do
		# Cada loteria
		case "$tipo" in
			lotomania)
				inicial=0
				final=99
				qtde=50
			;;
			lotofacil | facil)
				inicial=1
				final=25
				qtde=15
			;;
			megasena | mega)
				inicial=1
				final=60
				qtde=6
			;;
			duplasena | dupla)
				inicial=1
				final=50
				qtde=6
			;;
			quina)
				inicial=1
				final=80
				qtde=5
			;;
			federal)
				inicial=0
				final=99999
				numero=$(zzaleatorio $inicial $final)
				zztool eco $tipo:
				printf " %0.5d\n\n" $numero
				qtde=0
				unset num posicao numeros palpites inicial final i
			;;
			timemania | time)
				inicial=1
				final=80
				qtde=10
			;;
			loteca)
				i=1
				zztool eco $tipo:
				while test "$i" -le "14"
				do
					printf " Jogo %0.2d: Coluna %d\n" $i $(zzaleatorio 0 2) | sed 's/ 0$/ do Meio/g'
					i=$((i + 1))
				done
				echo
				qtde=0
				unset num posicao numeros palpites inicial final i
			;;
		esac

		# Todos os numeros da loteria seleciona
		if test "$qtde" -gt "0"
		then
			numeros=$(zzseq -f '%0.2d ' $inicial $final)
		fi

		# Loop para gerar os palpites
		i="$qtde"
		while test "$i" -gt "0"
		do
			# Posicao a ser escolhida
			posicao=$(zzaleatorio $inicial $final)
			test $tipo = "lotomania" && posicao=$((posicao + 1))

			# Extrai o numero na posicao selecionada
			num=$(echo $numeros | cut -f $posicao -d ' ')

			palpites=$(echo "$palpites $num")

			# Elimina o numero escolhido
			numeros=$(echo "$numeros" | sed "s/$num //")

			# Diminuindo o contador e quantidade de itens em "numeros"
			i=$((i - 1))
			final=$((final - 1))
		done

		if test "${#palpites}" -gt 0
		then
			palpites=$(echo "$palpites" | tr ' ' '\n' | sort -n -t ' ' | tr '\n' ' ')
			if test $(echo " $palpites" | wc -w ) -ge "10"
			then
				palpites=$(echo "$palpites" | sed 's/\(\([0-9]\{2\} \)\{5\}\)/\1\
 /g')
			fi
		fi

		# Exibe palpites
		if test "$qtde" -gt "0"
		then
			zztool eco $tipo:
			echo "$palpites" | sed '/^ *$/d;s/  *$//g'
			echo

			#Zerando as variaveis
			unset num posicao numeros palpites inicial final i
			qtde=0
		fi
	done | sed '$d'
}

# ----------------------------------------------------------------------------
# zzpascoa
# Mostra a data do domingo de Páscoa para qualquer ano.
# Obs.: Se o ano não for informado, usa o atual.
# Regra: Primeiro domingo após a primeira lua cheia a partir de 21 de março.
# Uso: zzpascoa [ano]
# Ex.: zzpascoa
#      zzpascoa 1999
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-10-23
# Versão: 1
# Licença: GPL
# Tags: data
# ----------------------------------------------------------------------------
zzpascoa ()
{
	zzzz -h pascoa "$1" && return

	local dia mes a b c d e f g h i k l m p q
	local ano="$1"

	# Se o ano não for informado, usa o atual
	test -z "$ano" && ano=$(date +%Y)

	# Validação
	zztool -e testa_ano $ano || return 1

	# Algoritmo de Jean Baptiste Joseph Delambre (1749-1822)
	# conforme citado em http://www.ghiorzi.org/portug2.htm
	#
	if test $ano -lt 1583
	then
		a=$(( ano % 4 ))
		b=$(( ano % 7 ))
		c=$(( ano % 19 ))
		d=$(( (19*c + 15) % 30 ))
		e=$(( (2*a + 4*b - d + 34) % 7 ))
		f=$(( (d + e + 114) / 31 ))
		g=$(( (d + e + 114) % 31 ))

		dia=$(( g+1 ))
		mes=$f
	else
		a=$(( ano % 19 ))
		b=$(( ano / 100 ))
		c=$(( ano % 100 ))
		d=$(( b / 4 ))
		e=$(( b % 4 ))
		f=$(( (b + 8) / 25 ))
		g=$(( (b - f + 1) / 3 ))
		h=$(( (19*a + b - d - g + 15) % 30 ))
		i=$(( c / 4 ))
		k=$(( c % 4 ))
		l=$(( (32 + 2*e + 2*i - h - k) % 7 ))
		m=$(( (a + 11*h + 22*l) / 451 ))
		p=$(( (h + l - 7*m + 114) / 31 ))
		q=$(( (h + l - 7*m + 114) % 31 ))

		dia=$(( q+1 ))
		mes=$p
	fi

	# Adiciona zeros à esquerda, se necessário
	test $dia -lt 10 && dia="0$dia"
	test $mes -lt 10 && mes="0$mes"

	echo "$dia/$mes/$ano"
}

# ----------------------------------------------------------------------------
# zzpgsql
# Lista os comandos SQL no PostgreSQL, numerando-os.
# Pesquisa detalhe dos comando, ao fornecer o número na listagem a esquerda.
# E filtra a busca se fornecer um texto.
#
# Uso: zzpgsql [ código | filtro ]
# Ex.: zzpgsql        # Lista os comandos disponíveis
#      zzpgsql 20     # Consulta o comando ALTER SCHEMA
#      zzpgsql alter  # Filtra os comandos que possuam alter na declaração
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-05-11
# Versão: 4
# Licença: GPL
# Requisitos: zztrim zzsqueeze
# ----------------------------------------------------------------------------
zzpgsql ()
{
	zzzz -h pgsql "$1" && return

	local url='http://www.postgresql.org/docs/current/static'
	local cache=$(zztool cache pgsql)
	local comando

	if ! test -s "$cache"
	then
		zztool source "${url}/sql-commands.html" |
		awk '/<dt>/,/<\/dt>/{if ($0 ~ /<dt>/) printf "%3s:", ++i; printf $0; if ($0 ~ /<\/dt>/) print ""}' |
		sed 's/<a href=[^"]*"//;s/\.html">/.html:/;s/<[^>]*>//g;s/: */:/' |
		zztrim |
		zzsqueeze > $cache
	fi

	if test -n "$1"
	then
		if zztool testa_numero $1
		then
			comando=$(sed -n "/^ *${1}:/{s///;s/:.*//;p;}" $cache)
			zztool dump "${url}/${comando}" |
			awk '
				$0  ~ /^$/  { branco++; if (branco == 3) { print "----------"; branco = 0 } }
				$0 !~ /^$/  { for (i=1;i<=branco;i++) { print "" }; print ; branco = 0 }
			' |
			sed -n '/^ *[_-][_-][_-][_-]*/,/^ *[_-][_-][_-][_-]*/p' |
			sed '1d;$d;' | zztrim -V | sed '1s/^ *//;s/        */       /'
		else
			grep -i $1 $cache | awk -F: '{printf "%3s %s\n", $1, $3}'
		fi
	else
		cat "$cache" | awk -F: '{printf "%3s %s\n", $1, $3}'
	fi
}

# ----------------------------------------------------------------------------
# zzphp
# http://www.php.net/manual/pt_BR/indexes.functions.php
# Lista completa com funções do PHP.
# com a opção -d ou --detalhe busca mais informação da função
# com a opção --atualiza força a atualização co cache local
#
# Uso: zzphp <palavra|regex>
# Ex.: zzphp --atualiza              # Força atualização do cache
#      zzphp array                   # mostra as funções com "array" no nome
#      zzphp -d mysql_fetch_object   # mostra descrição do  mysql_fetch_object
#      zzphp ^X                      # mostra as funções que começam com X
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-06
# Versão: 3
# Licença: GPL
# Requisitos: zzunescape
# ----------------------------------------------------------------------------
zzphp ()
{
	zzzz -h php "$1" && return

	local url='http://www.php.net/manual/pt_BR/indexes.functions.php'
	local cache=$(zztool cache php)
	local padrao="$*"
	local end funcao

	# Força atualização da listagem apagando o cache
	if test "$1" = '--atualiza'
	then
		zztool atualiza php
		shift
	fi

	if test "$1" = '-d' -o "$1" = '--detalhe'
	then
		url='http://www.php.net/manual/pt_BR'
		if test -n "$2"
		then
			funcao=$(echo "$2" | sed 's/ .*//')
			end=$(cat "$cache" | grep -h -i -- "^$funcao " | cut -f 2 -d"|")
			# Prevenir casos como do zlib://
			funcao=$(echo "$funcao" | sed 's|//||g')
			test $? -eq 0 && zztool dump "${url}/${end}" |
			sed -n "/^ *${funcao}/,/add a note add a note/{p; /add a note/q; }" |
			sed '$d; /[_-][_-][_-][_-]*$/,$d; s/        */       /'
		fi
	else
		# Se o cache está vazio, baixa listagem da Internet
		if ! test -s "$cache"
		then
			# Formato do arquivo:
			# nome da função - descrição da função : link correspondente
			zztool source "$url" | sed -n '/class="index"/p' |
			awk -F'"' '{print substr($5,2) "|" $2}' |
			sed 's/<[^>]*>//g' |
			zzunescape --html > "$cache"
		fi

		if test -n "$padrao"
		then
			# Busca a(s) função(ões)
			cat "$cache" | cut -f 1 -d"|" | grep -h -i -- "$padrao"
		else
			cat "$cache" | cut -f 1 -d"|"
		fi
	fi
}

# ----------------------------------------------------------------------------
# zzplay
# Toca o arquivo de áudio, escolhendo o player mais adequado instalado.
# Também pode tocar lista de reprodução (playlist).
# Pode-se escolher o player principal passando-o como segundo argumento.
# - Os players possíveis para cada tipo são:
#   wav, au, aiff        afplay, play, mplayer, cvlc, avplay, ffplay
#   mp2, mp3             afplay, mpg321, mpg123, mplayer, cvlc, avplay, ffplay
#   ogg                  ogg123, mplayer, cvlc, avplay, ffplay
#   aac, wma, mka        mplayer, cvlc, avplay, ffplay
#   pls, m3u, xspf, asx  mplayer, cvlc
#
# Uso: zzplay <arquivo-de-áudio> [player]
# Ex.: zzplay os_seminovos_escolha_ja_seu_nerd.mp3
#      zzplay os_seminovos_eu_nao_tenho_iphone.mp3 cvlc   # priorizando o cvlc
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-13
# Versão: 6
# Licença: GPL
# Requisitos: zzextensao zzminusculas zzunescape zzxml
# Nota: (ou) afplay play mplayer cvlc avplay ffplay mpg321 mpg123 ogg123
# ----------------------------------------------------------------------------
zzplay ()
{
	zzzz -h play "$1" && return

	local tipo play_cmd player play_lista
	local lista=0
	local cache="zzplay.pls"

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso play; return 1; }

	tipo=$(zzextensao "$1" | zzminusculas)

	# Para cada tipo de arquivo de audio ou playlist, seleciona o player disponivel
	case "$tipo" in
		wav | au | aiff )        play_lista="afplay play mplayer cvlc avplay ffplay";;
		mp2 | mp3 )              play_lista="afplay mpg321 mpg123 mplayer cvlc avplay ffplay";;
		ogg )                    play_lista="ogg123 mplayer cvlc avplay ffplay";;
		aac | wma | mka )        play_lista="mplayer cvlc avplay ffplay";;
		pls | m3u | xspf | asx ) play_lista="mplayer cvlc"; lista=1;;
		*) zzplay -h && return;;
	esac

	# Coloca player selecionado como prioritário.
	if test -n "$2" && zztool grep_var "$2" "$play_lista"
	then
		play_lista=$(echo "$play_lista" | sed "s/$2//")
		play_lista="$2 $play_lista"
	fi

	# Testa sequencialmente até encontrar o player disponível
	for play_cmd in $play_lista
	do
		if which $play_cmd >/dev/null 2>&1
		then
			player="$play_cmd"
			break
		fi
	done

	if test -n "$player"
	then
		# Mensagens de ajuda se estiver usando uma lista de reprodução
		if test "$player" = "mplayer" -a $lista -eq 1
		then
			zztool eco "Tecla 'q' para sair."
			zztool eco "Tecla '<' para música anterior na playlist."
			zztool eco "Tecla '>' para próxima música na playlist."
			player="$player -playlist"
		elif test "$player" = "cvlc" -a $lista -eq 1
		then
			zztool eco "Digitar Crtl+C para sair."
			zztool eco "Tecla '1' para música anterior na playlist."
			zztool eco "Tecla '2' para próxima música na playlist."
			player="$player --global-key-next 2 --global-key-prev 1"
		elif test "$player" = "avplay" -o "$player" = "ffplay"
		then
			player="$player -vn -nodisp"
		fi

		# Transforma os vários formatos de lista de reprodução numa versão simples de pls
		case "$tipo" in
			m3u)
				sed '/^[[:blank:]]*$/d;/^#/d;s/^[[:blank:]]*//g' "$1" |
				awk 'BEGIN { print "[playlist]" } { print "File" NR "=" $0 }' |
				sed 's/%\([0-9A-F][0-9A-F]\)/\\\\x\1/g' |
				while read linha
				do
					printf "%b\n" "$linha"
				done >> $cache
			;;
			xspf)
				zzxml --indent --tag location "$1" | zzxml --untag | zzunescape --html |
				sed '/^[[:blank:]]*$/d;s/^[[:blank:]]*//g' | sed 's|file://||g' |
				awk 'BEGIN { print "[playlist]" } { print "File" NR "=" $0 }' |
				sed 's/%\([0-9A-F][0-9A-F]\)/\\\\x\1/g' |
				while read linha
				do
					printf "%b\n" "$linha"
				done >> $cache
			;;
			asx)
				zzxml --indent --tag ref "$1" | zzunescape --html | sed '/^[[:blank:]]*$/d' |
				awk -F'""' 'BEGIN { print "[playlist]" } { print "File" NR "=" $2 }' |
				sed 's/%\([0-9A-F][0-9A-F]\)/\\\\x\1/g' |
				while read linha
				do
					printf "%b\n" "$linha"
				done >> $cache
			;;
		esac

		test -s "$cache" && $player "$cache" >/dev/null 2>&1 || $player "$1" >/dev/null 2>&1
	fi

	rm -f "$cache"
}

# ----------------------------------------------------------------------------
# zzporcento
# Calcula porcentagens.
# Se informado um número, mostra sua tabela de porcentagens.
# Se informados dois números, mostra a porcentagem relativa entre eles.
# Se informados um número e uma porcentagem, mostra o valor da porcentagem.
# Se informados um número e uma porcentagem com sinal, calcula o novo valor.
#
# Uso: zzporcento valor [valor|[+|-]porcentagem%]
# Ex.: zzporcento 500           # Tabela de porcentagens de 500
#      zzporcento 500.0000      # Tabela para número fracionário (.)
#      zzporcento 500,0000      # Tabela para número fracionário (,)
#      zzporcento 5.000,00      # Tabela para valor monetário
#      zzporcento 500 25        # Mostra a porcentagem de 25 para 500 (5%)
#      zzporcento 500 1000      # Mostra a porcentagem de 1000 para 500 (200%)
#      zzporcento 500,00 2,5%   # Mostra quanto é 2,5% de 500,00
#      zzporcento 500,00 +2,5%  # Mostra quanto é 500,00 + 2,5%
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-12-11
# Versão: 6
# Licença: GPL
# Requisitos: zztestar
# ----------------------------------------------------------------------------
zzporcento ()
{
	zzzz -h porcento "$1" && return

	local i porcentagem sinal
	local valor1="$1"
	local valor2="$2"
	local escala=0
	local separador=','
	local tabela='200 150 125 100 90 80 75 70 60 50 40 30 25 20 15 10 9 8 7 6 5 4 3 2 1'

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso porcento; return 1; }

	# Remove os pontos dos dinheiros para virarem fracionários (1.234,00 > 1234,00)
	zztestar dinheiro "$valor1" && valor1=$(echo "$valor1" | sed 's/\.//g')
	zztestar dinheiro "$valor2" && valor2=$(echo "$valor2" | sed 's/\.//g')

	### Vamos analisar o primeiro valor

	# Número fracionário (1.2345 ou 1,2345)
	if zztestar numero_fracionario "$valor1"
	then
		separador=$(echo "$valor1" | tr -d 0-9)
		escala=$(echo "$valor1" | sed 's/.*[.,]//')
		escala="${#escala}"

		# Sempre usar o ponto como separador interno (para os cálculos)
		valor1=$(echo "$valor1" | sed 'y/,/./')

	# Número inteiro ou erro
	else
		zztool -e testa_numero "$valor1" || return 1
	fi

	### Vamos analisar o segundo valor

	# O segundo argumento é uma porcentagem
	if test $# -eq 2 && zztool grep_var % "$valor2"
	then
		# O valor da porcentagem é guardado sem o caractere %
		porcentagem=$(echo "$valor2" | tr -d %)

		# Sempre usar o ponto como separador interno (para os cálculos)
		porcentagem=$(echo "$porcentagem" | sed 'y/,/./')

		# Há um sinal no início?
		if test "${porcentagem#[+-]}" != "$porcentagem"
		then
			sinal=$(printf %c $porcentagem)  # pega primeiro char
			porcentagem=${porcentagem#?}     # remove primeiro char
		fi

		# Porcentagem fracionada
		if zztestar numero_fracionario "$porcentagem"
		then
			# Se o valor é inteiro (escala=0) e a porcentagem fracionária,
			# é preciso forçar uma escala para que o resultado apareça correto.
			test $escala -eq 0 && escala=2 valor1="$valor1.00"

		# Porcentagem inteira ou erro
		elif ! zztool testa_numero "$porcentagem"
		then
			zztool erro "O valor da porcentagem deve ser um número. Exemplos: 2 ou 2,5."
			return 1
		fi

	# O segundo argumento é um número
	elif test $# -eq 2
	then
		# Ao mostrar a porcentagem entre dois números, a escala é fixa
		escala=2

		# O separador do segundo número é quem "manda" na saída
		# Sempre usar o ponto como separador interno (para os cálculos)

		# Número fracionário
		if zztestar numero_fracionario "$valor2"
		then
			separador=$(echo "$valor2" | tr -d 0-9)
			valor2=$(echo "$valor2" | sed 'y/,/./')

		# Número normal ou erro
		else
			zztool -e testa_numero "$valor2" || return 1
		fi
	fi

	# Ok. Dados coletados, analisados e formatados. Agora é hora dos cálculos.

	# Mostra tabela
	if test $# -eq 1
	then
		for i in $tabela
		do
			printf "%s%%\t%s\n" $i $(echo "scale=$escala; $valor1*$i/100" | bc)
		done

	# Mostra porcentagem
	elif test $# -eq 2
	then
		# Mostra a porcentagem relativa entre dois números
		if ! zztool grep_var % "$valor2"
		then
			echo "scale=$escala; $valor2*100/$valor1" | bc | sed 's/$/%/'

		# valor + n% é igual a…
		elif test "$sinal" = '+'
		then
			echo "scale=$escala; $valor1+$valor1*$porcentagem/100" | bc

		# valor - n% é igual a…
		elif test "$sinal" = '-'
		then
			echo "scale=$escala; $valor1-$valor1*$porcentagem/100" | bc

		# n% do valor é igual a…
		else
			echo "scale=$escala; $valor1*$porcentagem/100" | bc

			### Saída antiga, uma mini tabelinha
			# printf "%s%%\t%s\n" "+$porcentagem" $(echo "scale=$escala; $valor1+$valor1*$porcentagem/100" | bc)
			# printf "%s%%\t%s\n"  100          "$valor1"
			# printf "%s%%\t%s\n" "-$porcentagem" $(echo "scale=$escala; $valor1-$valor1*$porcentagem/100" | bc)
			# echo
			# printf "%s%%\t%s\n"  "$porcentagem" $(echo "scale=$escala; $valor1*$porcentagem/100" | bc)
			#
			# | sed "s/\([^0-9]\)\./\10./ ; s/^\./0./; y/./$separador/"
		fi
	fi |

	# Assegura 0.123 (em vez de .123) e restaura o separador original
	sed "s/^\./0./; y/./$separador/"
}

# ----------------------------------------------------------------------------
# zzporta
# http://pt.wikipedia.org/wiki/Lista_de_portas_de_protocolos
# Mostra uma lista das portas de protocolos usados na internet.
# Se houver um número como argumento, a listagem é filtrada pelo mesmo.
#
# Uso: zzporta [porta]
# Ex.: zzporta
#      zzporta 513
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2014-11-15
# Versão: 2
# Licença: GPL
# Requisitos: zzjuntalinhas
# ----------------------------------------------------------------------------
zzporta ()
{
	zzzz -h porta "$1" && return

	local url="https://pt.wikipedia.org/wiki/Lista_de_portas_de_protocolos"
	local port=$1
	zztool testa_numero $port || port='.'

	zztool source "$url" |
	awk '/"wikitable"/,/<\/table>/ { sub (/ bgcolor.*>/,">"); print }' |
	zzjuntalinhas -d '' -i '<tr>' -f '</tr>' |
	awk -F '</?t[^>]+>' 'BEGIN {OFS="\t"}{ print $3, $5 }' |
	expand -t 18 |
	sed '
		1d
		# Retira os links
		s/<[^>]*>//g
		3,${
			/^Porta/d
			/^[[:blank:]]*$/d
			/\/IP /d
		}' |
	awk 'NR==1;NR>1 && /'$port'/'
}

# ----------------------------------------------------------------------------
# zzpronuncia
# Fala a pronúncia correta de uma palavra em inglês.
# Uso: zzpronuncia palavra
# Ex.: zzpronuncia apple
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2002-04-10
# Versão: 5
# Licença: GPL
# Requisitos: zzplay zzunescape
# Nota: opcional say
# ----------------------------------------------------------------------------
zzpronuncia ()
{
	zzzz -h pronuncia "$1" && return

	local audio_file
	local palavra=$1
	local cache=$(zztool cache pronuncia "$palavra.mp3")
	local url='http://www.merriam-webster.com/dictionary'
	local url2='http://media.merriam-webster.com/audio/prons'

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso pronuncia; return 1; }

	# O 'say' é um comando do Mac OS X, aí não precisa baixar nada
	if test -x /usr/bin/say
	then
		say $*
		return
	fi

	# Busca o arquivo MP3 na Internet caso não esteja no cache
	if ! test -f "$cache"
	then
		# Extrai o nome do arquivo no site do dicionário
		audio_file=$(
			zztool source "$url/$palavra" |
			sed -n '/data-file=/{s/.*href="//;s/".*//;p;q;}' |
			zzunescape --html |
			awk -F '[=_&]' '{print $3 "/" $4 "/mp3/" $6 "/" $8 ".mp3"}'
		)

		# Ops, não extraiu nada
		if test -z "$audio_file"
		then
			zztool erro "$palavra: palavra não encontrada"
			return 1
		fi

		# Compõe a URL do arquivo e salva-o localmente (cache)
		zztool source "$url2/$audio_file" > "$cache"
	fi

	# Fala que eu te escuto
	zzplay "$cache"
}

# ----------------------------------------------------------------------------
# zzquimica
# Exibe a relação dos elementos químicos.
# Pesquisa na Wikipédia se informado o número atômico ou símbolo do elemento.
#
# Uso: zzquimica [número|símbolo]
# Ex.: zzquimica       # Lista de todos os elementos químicos
#      zzquimica He    # Pesquisa o Hélio na Wikipédia
#      zzquimica 12    # Pesquisa o Magnésio na Wikipédia
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-22
# Versão: 7
# Licença: GPL
# Requisitos: zzcapitalize zzwikipedia zzxml zzpad
# ----------------------------------------------------------------------------
zzquimica ()
{

	zzzz -h quimica "$1" && return

	local elemento linha numero nome simbolo massa orbital familia
	local cache=$(zztool cache quimica)

	# Se o cache está vazio, baixa listagem da Internet
	if ! test -s "$cache"
	then
		zztool source "http://www.tabelaperiodicacompleta.com/" |
		awk '/class="elemento/,/<\/td>/{print}'|
		zzxml --untag=br | zzxml --tidy |
		sed '/id="57-71"/,/<\/td>/d;/id="89-103"/,/<\/td>/d' |
		awk 'BEGIN {print "N.º:Nome:Símbolo:Massa:Orbital:Classificação (estado)"; OFS=":" }
			/^<td /     {
				info["familia"] = $5
					sub(/ao/, "ão", info["familia"])
					sub(/nideo/, "nídeo", info["familia"])
					sub(/gas/, "gás", info["familia"])
					sub(/genio/, "gênio", info["familia"])
					sub(/l[-]t/, "l de t", info["familia"])
					if (info["familia"] ~ /[los][-][rmn]/)
						sub(/-/, " ", info["familia"])

					info["familia"] = info["familia"] ($6 ~ /13$/ ? " [família do boro]":"")
					info["familia"] = info["familia"] ($6 ~ /14$/ ? " [família do carbono]":"")
					info["familia"] = info["familia"] ($6 ~ /15$/ ? " [família do nitrogênio]":"")
					info["familia"] = info["familia"] ($6 ~ /16$/ ? " [calcogênio]":"")

				info["estado"] = $7
					sub(/.>/, "", info["estado"])
					sub(/solido/, "sólido", info["estado"])
					sub(/liquido/, "líquido", info["estado"])
				}
			/^<a /      { info["url"] = $0; sub(/.*href=./, "", info["url"]); sub(/".*/, "", info["url"]) }
			/^<strong / { getline info["numero"] }
			/^<abbr/    { getline info["simbolo"]; sub(/ */, "", info["simbolo"]) }
			/^<em/      { getline info["nome"] }
			/^<i/       { getline info["massa"] }
			/^<small/   { getline info["orbital"]; gsub(/ /, "-", info["orbital"]) }
			/^<\/td>/ { print info["numero"], info["nome"], info["simbolo"], info["massa"], info["orbital"], info["familia"] " (" info["estado"] ")" }
		' |
		# Correção para elmentos novos descobertos e recentemente reclassificados
		sed '
			s/Ununtrio/Nihonium/; s/Uut/Nh/
			s/Ununpentio/Moscovium/; s/Uup/Mc/
			s/Ununséptio/Tennessine/; s/Uus/Ts/
			s/Ununóctio/Oganesson/; s/Uuo/Og/
			' |
		sort -n |
		while IFS=':' read numero nome simbolo massa orbital familia
		do
			echo "$(zzpad 4 $numero) $(zzpad 13 $nome) $(zzpad 7 $simbolo) $(zzpad 12 $massa) $(zzpad 18 $orbital) $familia"
		done > "$cache"
	fi

	if test -n "$1"
	then
		if zztool testa_numero "$1"
		then
			# Testando se forneceu o número atômico
			elemento=$(awk ' $1 ~ /'$1'/ { print $2 }' "$cache")
		else
			# Ou se forneceu o símbolo do elemento químico
			elemento=$(awk '{ if ($3 == "'$(zzcapitalize "$1")'") print $2 }' "$cache")
		fi

		# Se encontrado, pesquisa-o na wikipedia
		if test ${#elemento} -gt 0
		then
			test "$elemento" = "Rádio" -o "$elemento" = "Índio" && elemento="${elemento}_(elemento_químico)"
			zzwikipedia "$elemento"
		else
			zztool -e uso quimica
			return 1
		fi

	else
		# Lista todos os elementos químicos
		cat "$cache" | zzcapitalize | sed 's/ D\([eo]\) / d\1 /g'
	fi
}

# ----------------------------------------------------------------------------
# zzramones
# http://aurelio.net/doc/ramones.txt
# Mostra uma frase aleatória, das letras de músicas da banda punk Ramones.
# Obs.: Informe uma palavra se quiser frases sobre algum assunto especifico.
# Uso: zzramones [palavra]
# Ex.: zzramones punk
#      zzramones
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2001-07-24
# Versão: 1
# Licença: GPL
# Requisitos: zzlinha
# ----------------------------------------------------------------------------
zzramones ()
{
	zzzz -h ramones "$1" && return

	local url='http://aurelio.net/doc/ramones.txt'
	local cache=$(zztool cache ramones)
	local padrao=$1

	# Se o cache está vazio, baixa listagem da Internet
	if ! test -s "$cache"
	then
		zztool download "$url" "$cache"
	fi

	# Mostra uma linha qualquer (com o padrão, se informado)
	zzlinha -t "${padrao:-.}" "$cache"
}

# ----------------------------------------------------------------------------
# zzrastreamento
# http://www.correios.com.br
# Acompanha encomendas via rastreamento dos Correios.
# Uso: zzrastreamento <código_da_encomenda> ...
# Ex.: zzrastreamento RK995267899BR
#      zzrastreamento RK995267899BR RA995267899CN
#
# Autor: Frederico Freire Boaventura <anonymous (a) galahad com br>
# Desde: 2007-06-25
# Versão: 4
# Licença: GPL
# Requisitos: zztrim zzunescape zzxml zzjuntalinhas
# ----------------------------------------------------------------------------
zzrastreamento ()
{
	zzzz -h rastreamento "$1" && return

	test -n "$1" || { zztool -e uso rastreamento; return 1; }

	local url='http://www2.correios.com.br/sistemas/rastreamento/resultado_semcontent.cfm?'

	# Para cada código recebido...
	for codigo
	do
		# Só mostra o código se houver mais de um
		test $# -gt 1 && zztool eco "**** $codigo"

		curl -s $url -d "objetos=$codigo" |
			iconv -f iso-8859-1 -t utf-8 |
			zzxml --tag tr |
			zztrim |
			zzunescape --html |
			sed '/^ *$/d' |
			zzjuntalinhas -i '<tr' -f '</tr>' |
			zzxml --untag |
			tr -s '\t' |
			expand -t 1,13,20 |
			zztrim

		# Linha em branco para separar resultados
		test $# -gt 1 && echo || :
	done
}

# ----------------------------------------------------------------------------
# zzrepete
# Repete um dado texto na quantidade de vezes solicitada.
# Com a opção -l ou --linha cada repetição é uma nova linha.
#
# Uso: zzrepete [-l | --linha] <repetições> <texto>
# Ex.: zzrepete 15 Foo     # FooFooFooFooFooFooFooFooFooFooFooFooFooFooFoo
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2016-04-12
# Versão: 1
# Licença: GPL
# Requisitos: zzseq
# ----------------------------------------------------------------------------
zzrepete ()
{
	zzzz -h repete "$1" && return

	test -n "$1" || { zztool -e uso repete; return 1; }

	# Definindo variáveis
	local linha i qtde

	# Uma repetição por linha
	if test "$1" = "-l" -o "$1" = "--linha"
	then
		linha='\n'
		shift
	fi

	# Ao menos 2 parâmetros: Número de repetições e o resto o que vai ser repetido
	test $# -ge 2 || { zztool -e uso repete; return 1; }

	# Se preenche os requesitos, vamos em frente.
	if zztool testa_numero "$1" && test "$1" -gt 0
	then
		qtde="$1"
		shift

		# É aqui que acontece, o código é auto-explicativo :)
		for i in $(zzseq $qtde)
		do
			printf "$*${linha}"
		done |
		zztool nl_eof

	else
		# Ops! Deu algum erro.
		zztool erro "Número inválido para repetições: $1"
		return 1
	fi
}

# ----------------------------------------------------------------------------
# zzromanos
# Conversor de números romanos para hindu-arábicos e vice-versa.
# Converte corretamente para romanos números até 3999999.
# Converte corretamente para hindu-arábicos números até 4000.
#
# Uso: zzromanos número
# Ex.: zzromanos 1987                # Retorna: MCMLXXXVII
#      zzromanos XLIII               # Retorna: 43
#
# Autor: Guilherme Magalhães Gall <gmgall (a) gmail com>
# Desde: 2011-07-19
# Versão: 4
# Licença: GPL
# Requisitos: zzmaiusculas zztac
# ----------------------------------------------------------------------------
zzromanos ()
{
	zzzz -h romanos "$1" && return

	local arabicos_romanos="\
	1000000:M̄
	900000:C̄M̄
	500000:D̄
	400000:C̄D̄
	100000:C̄
	90000:X̄C̄
	50000:Ḹ
	40000:X̄Ḹ
	10000:X̄
	9000:ĪX̄
	8000:V̄ĪĪĪ
	7000:V̄ĪĪ
	6000:V̄Ī
	5000:V̄
	4000:ĪV̄
	1000:M
	900:CM
	500:D
	400:CD
	100:C
	90:XC
	50:L
	40:XL
	10:X
	9:IX
	5:V
	4:IV
	1:I"

	# Deixa o usuário usar letras maiúsculas ou minúsculas
	local entrada=$(echo "$1" | zzmaiusculas)
	local saida=""
	local indice=1
	local comprimento
	# Regex que valida um número romano de acordo com
	# http://diveintopython.org/unit_testing/stage_5.html
	local regex_validacao='^(M{0,4})(C[MD]|D?C{0,3})(X[CL]|L?X{0,3})(I[XV]|V?I{0,3})$'

	# Se nenhum argumento for passado, mostra lista de algarismos romanos
	# e seus correspondentes hindu-arábicos
	if test $# -eq 0
	then
		echo "$arabicos_romanos" |
		egrep '[15]|4000:' | tr -d '\t' | tr : '\t' |
		zztac

	# Se é um número inteiro positivo, transforma para número romano
	elif zztool testa_numero "$entrada" && test "$entrada" -lt 4000000
	then
		echo "$arabicos_romanos" | { while IFS=: read arabico romano
		do
			while test "$entrada" -ge "$arabico"
			do
				saida="$saida$romano"
				entrada=$((entrada-arabico))
			done
		done
		test "$1" -ge 4000 && printf "\n$saida\n\n" || echo "$saida"
		}

	# Se é uma string que representa um número romano válido,
	# converte para hindu-arábico
	elif echo "$entrada" | egrep "$regex_validacao" > /dev/null
	then
		saida=0
		# Baseado em http://diveintopython.org/unit_testing/stage_4.html
		echo "$arabicos_romanos" | { while IFS=: read arabico romano
		do
			comprimento="${#romano}"
			while test "$(echo "$entrada" | cut -c$indice-$((indice+comprimento-1)))" = "$romano"
			do
				indice=$((indice+comprimento))
				saida=$((saida+arabico))
			done
		done
		echo "$saida"
		}

	# Se não é inteiro posivo ou string que representa número romano válido,
	# imprime mensagem de uso.
	else
		zztool -e uso romanos
		return 1
	fi
}

# ----------------------------------------------------------------------------
# zzrot13
# Codifica/decodifica um texto utilizando a cifra ROT13.
# Uso: zzrot13 texto
# Ex.: zzrot13 texto secreto               # Retorna: grkgb frpergb
#      zzrot13 grkgb frpergb               # Retorna: texto secreto
#      echo texto secreto | zzrot13        # Retorna: grkgb frpergb
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-07-23
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzrot13 ()
{
	zzzz -h rot13 "$1" && return

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |

	# Um tr faz tudo, é uma tradução letra a letra
	# Obs.: Dados do tr entre colchetes para funcionar no Solaris
	tr '[a-zA-Z]' '[n-za-mN-ZA-M]'
}

# ----------------------------------------------------------------------------
# zzrot47
# Codifica/decodifica um texto utilizando a cifra ROT47.
# Uso: zzrot47 texto
# Ex.: zzrot47 texto secreto               # Retorna: E6IE@ D64C6E@
#      zzrot47 E6IE@ D64C6E@               # Retorna: texto secreto
#      echo texto secreto | zzrot47        # Retorna: E6IE@ D64C6E@
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-07-23
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzrot47 ()
{
	zzzz -h rot47 "$1" && return

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |

	# Um tr faz tudo, é uma tradução letra a letra
	# Obs.: Os colchetes são parte da tabela, o tr não funcionará no Solaris
	tr '!-~' 'P-~!-O'
}

# ----------------------------------------------------------------------------
# zzrpmfind
# http://rpmfind.net/linux
# Procura por pacotes RPM em várias distribuições de Linux.
# Obs.: A arquitetura padrão de procura é a i586.
# Uso: zzrpmfind pacote [distro] [arquitetura]
# Ex.: zzrpmfind sed
#      zzrpmfind lilo mandr i586
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2002-02-22
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzrpmfind ()
{
	zzzz -h rpmfind "$1" && return

	local url='http://rpmfind.net/linux/rpm2html/search.php'
	local pacote=$1
	local distro=$2
	local arquitetura=${3:-i586}

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso rpmfind; return 1; }

	# Faz a consulta e filtra o resultado
	resultado=$(
		zztool list "$url?query=$pacote&submit=Search+...&system=$distro" |
			grep --color=never "[^.]*$arquitetura[^.]*.rpm$" |
			sort
	)

	if test -n "$resultado"
	then
		echo "$resultado"
	fi
}

# ----------------------------------------------------------------------------
# zzsecurity
# Mostra os últimos 5 avisos de segurança de sistemas de Linux/UNIX.
# Suportados:
#  Debian, Ubuntu, FreeBSD, NetBSD, Gentoo, Arch, Mageia,
#  Slackware, Suse, OpenSuse, Fedora.
# Uso: zzsecurity [distros]
# Ex.: zzsecurity
#      zzsecurity mageia
#      zzsecurity debian gentoo
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2004-12-23
# Versão: 12
# Licença: GPL
# Requisitos: zzminusculas zzfeed zztac zzdata zzdatafmt
# ----------------------------------------------------------------------------
zzsecurity ()
{
	zzzz -h security "$1" && return

	local url limite distros
	local n=5
	local ano=$(date '+%Y')
	local distros='debian freebsd gentoo slackware suse opensuse ubuntu arch mageia netbsd fedora'

	limite="sed ${n}q"

	test -n "$1" && distros=$(echo $* | zzminusculas)

	# Debian
	if zztool grep_var debian "$distros"
	then
		url='http://www.debian.org'
		echo
		zztool eco '** Atualizações Debian'
		echo "$url"
		zztool dump "$url" |
			sed -n '
				/Security Advisories/,/_______/ {
					/\[[0-9]/ s/^ *//p
				}' |
			$limite
	fi

	# Slackware
	if zztool grep_var slackware "$distros"
	then
		echo
		zztool eco '** Atualizações Slackware'
		url="http://www.slackware.com/security/list.php?l=slackware-security&y=$ano"
		echo "$url"
		zztool dump "$url" |
			sed '
				/[0-9]\{4\}-[0-9][0-9]/!d
				s/\[sla.*ty\]//
				s/^  *//' |
			$limite
	fi

	# Gentoo
	if zztool grep_var gentoo "$distros"
	then
		echo
		zztool eco '** Atualizações Gentoo'
		url='http://www.gentoo.org/security/en/index.xml'
		echo "$url"
		zztool dump "$url" |
			sed -n '
				s/^  *//
				/^GLSA/, /^$/ !d
				/[0-9]\{4\}/ {
					s/\([-0-9]* \) *[a-zA-Z]* *\(.*[^ ]\)  *[0-9][0-9]* *$/\1\2/
					p
				}' |
			$limite
	fi

	# Suse
	if zztool grep_var suse "$distros" || zztool grep_var opensuse "$distros"
	then
		echo
		zztool eco '** Atualizações Suse'
		url='https://www.suse.com/support/update/'
		echo "$url"
		zztool dump "$url" |
			grep 'SUSE-SU' |
			sed 's/^.*\(SUSE-SU\)/ \1/;s/\(.*\) \([A-Z].. .., ....\)$/\2\1/ ; s/  *$//' |
			$limite

		echo
		zztool eco '** Atualizações Opensuse'
		url="http://lists.opensuse.org/opensuse-updates/$(zzdata hoje - 1m | zzdatafmt -f AAAA-MM) http://lists.opensuse.org/opensuse-updates/$(zzdatafmt -f AAAA-MM hoje)"
		echo "$url"
		zztool dump $url |
			grep 'SUSE-SU' |
			sed 's/^ *\* //;s/ [0-9][0-9]:[0-9][0-9]:[0-9][0-9] GMT/,/;s/  *$//' |
			zztac |
			$limite
	fi

	# FreeBSD
	if zztool grep_var freebsd "$distros"
	then
		echo
		zztool eco '** Atualizações FreeBSD'
		url='http://www.freebsd.org/security/advisories.rdf'
		echo "$url"
		zzfeed -n $n "$url"
	fi

	# NetBSD
	if zztool grep_var netbsd "$distros"
	then
		echo
		zztool eco '** Atualizações NetBSD'
		url='http://ftp.netbsd.org/pub/NetBSD/packages/vulns/pkg-vulnerabilities'
		echo "$url"
		zztool dump "$url" |
			sed '1,27d;/#CHECKSUM /,$d;s/ *https*:.*//' |
			zztac |
			$limite
	fi

	# Ubuntu
	if zztool grep_var ubuntu "$distros"
	then
		url='http://www.ubuntu.com/usn/rss.xml'
		echo
		zztool eco '** Atualizações Ubuntu'
		echo "$url"
		zzfeed -n $n "$url"
	fi

	# Fedora
	if zztool grep_var fedora "$distros"
	then
		echo
		zztool eco '** Atualizações Fedora'
		url='http://lwn.net/Alerts/Fedora/'
		echo "$url"
		zztool dump "$url" |
			grep 'FEDORA-' |
			sed 's/^ *//' |
			$limite
	fi

	# Arch
	if zztool grep_var arch "$distros"
	then
		url="https://security.archlinux.org/"
		echo
		zztool eco '** Atualizações Archlinux'
		echo "$url"
		zztool dump "$url" |
			awk '/ AVG-/{++i;print"";sub(/^ */,"")};i>=6{exit}i;' |
			sed '/AVG.* CVE/ {s/ CVE/\n   CVE/}'
	fi
}

# ----------------------------------------------------------------------------
# zzsemacento
# Tira os acentos de todas as letras (áéíóú vira aeiou).
# Uso: zzsemacento texto
# Ex.: zzsemacento AÇÃO 1ª bênção           # Retorna: ACAO 1a bencao
#      echo AÇÃO 1ª bênção | zzsemacento    # Retorna: ACAO 1a bencao
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2010-05-24
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzsemacento ()
{
	zzzz -h semacento "$1" && return

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |

	# Remove acentos
	sed '
		y/àáâãäåèéêëìíîïòóôõöùúûü/aaaaaaeeeeiiiiooooouuuu/
		y/ÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜ/AAAAAAEEEEIIIIOOOOOUUUU/
		y/çÇñÑß¢Ðð£Øø§µÝý¥¹²³ªº/cCnNBcDdLOoSuYyY123ao/
	'
}

# ----------------------------------------------------------------------------
# zzsenha
# Gera uma senha aleatória de N caracteres.
# Obs.: Sem opções, a senha é gerada usando letras e números.
#
# Opções: -p, --pro   Usa letras, números e símbolos para compor a senha
#         -n, --num   Usa somente números para compor a senha
#         -u, --uniq  Gera senhas com caracteres únicos (não repetidos)
#
# Uso: zzsenha [--pro|--num] [n]     (padrão n=8)
# Ex.: zzsenha
#      zzsenha 10
#      zzsenha --num 9
#      zzsenha --pro 30
#      zzsenha --uniq 10
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2002-11-07
# Versão: 4
# Licença: GPL
# Requisitos: zzaleatorio
# ----------------------------------------------------------------------------
zzsenha ()
{
	zzzz -h senha "$1" && return

	local posicao letra senha uniq
	local n=8
	local alpha='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	local num='0123456789'
	local pro='-/:;()$&@.,?!'  # teclado do iPhone, exceto aspas
	local lista="$alpha$num"   # senha padrão: letras e números

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-p | --pro ) shift; lista="$alpha$num$pro";;
			-n | --num ) shift; lista="$num";;
			-u | --uniq) shift; uniq=1;;
			*) break ;;
		esac
	done

	# Guarda o número informado pelo usuário (se existente)
	test -n "$1" && n="$1"

	# Foi passado um número mesmo?
	zztool -e testa_numero "$n" || return 1

	# Quando não se repete caracteres, há uma limitação de tamanho
	if test -n "$uniq" -a "$n" -gt "${#lista}"
	then
		zztool erro "O tamanho máximo desse tipo de senha é ${#lista}"
		return 1
	fi

	# Esquema de geração da senha:
	# A cada volta é escolhido um número aleatório que indica uma
	# posição dentro de $lista. A letra dessa posição é mostrada na
	# tela. Caso --uniq seja usado, a letra é removida de $lista,
	# para que não seja reutilizada.
	while test "$n" -ne 0
	do
		n=$((n-1))
		posicao=$(zzaleatorio 1 ${#lista})
		letra=$(printf "$lista" | cut -c "$posicao")
		test -n "$uniq" && lista=$(echo "$lista" | tr -d "$letra")
		senha="$senha$letra"
	done

	# Mostra a senha
	test -n "$senha" && echo "$senha"
}

# ----------------------------------------------------------------------------
# zzseq
# Mostra uma seqüência numérica, um número por linha, ou outro formato.
# É uma emulação do comando seq, presente no Linux.
# Opções:
#   -f    Formato de saída (printf) para cada número, o padrão é '%d\n'
# Uso: zzseq [-f formato] [número-inicial [passo]] número-final
# Ex.: zzseq 10                   # de 1 até 10
#      zzseq 5 10                 # de 5 até 10
#      zzseq 10 5                 # de 10 até 5 (regressivo)
#      zzseq 0 2 10               # de 0 até 10, indo de 2 em 2
#      zzseq 10 -2 0              # de 10 até 0, indo de 2 em 2
#      zzseq -f '%d:' 5           # 1:2:3:4:5:
#      zzseq -f '%0.4d:' 5        # 0001:0002:0003:0004:0005:
#      zzseq -f '(%d)' 5          # (1)(2)(3)(4)(5)
#      zzseq -f 'Z' 5             # ZZZZZ
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2002-12-06
# Versão: 1
# Licença: GPL
# Requisitos: zztestar
# ----------------------------------------------------------------------------
zzseq ()
{
	zzzz -h seq "$1" && return

	local operacao='+'
	local inicio=1
	local passo=1
	local formato='%d\n'
	local fim i

	# Se tiver -f, guarda o formato e limpa os argumentos
	if test "$1" = '-f'
	then
		formato="$2"
		shift
		shift
	fi

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso seq; return 1; }

	# Se houver só um número, vai "de um ao número"
	fim="$1"

	# Se houver dois números, vai "do primeiro ao segundo"
	test -n "$2" && inicio="$1" fim="$2"

	# Se houver três números, vai "do primeiro ao terceiro em saltos"
	test -n "$3" && inicio="$1" passo="$2" fim="$3"

	# Verificações básicas
	zztestar -e numero_sinal "$inicio" || return 1
	zztestar -e numero_sinal "$passo"  || return 1
	zztestar -e numero_sinal "$fim"    || return 1
	if test "$passo" -eq 0
	then
		zztool erro "O passo não pode ser zero."
		return 1
	fi

	# Internamente o passo deve ser sempre positivo para simplificar
	# Assim mesmo que o usuário faça 0 -2 10, vai funcionar
	test "$passo" -lt 0 && passo=$((0 - passo))

	# Se o primeiro for maior que o segundo, a contagem é regressiva
	test "$inicio" -gt "$fim" && operacao='-'

	# Loop que mostra o número e aumenta/diminui a contagem
	i="$inicio"
	while (
		test "$inicio" -lt "$fim" -a "$i" -le "$fim" ||
		test "$inicio" -gt "$fim" -a "$i" -ge "$fim")
	do
		printf "$formato" "$i"
		i=$(($i $operacao $passo))  # +n ou -n
	done

	# Caso especial: início e fim são iguais
	test "$inicio" -eq "$fim" && echo "$inicio"
}

# ----------------------------------------------------------------------------
# zzsextapaixao
# Mostra a data da sexta-feira da paixão para qualquer ano.
# Obs.: Se o ano não for informado, usa o atual.
# Regra: 2 dias antes do domingo de Páscoa.
# Uso: zzsextapaixao [ano]
# Ex.: zzsextapaixao
#      zzsextapaixao 2008
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-11-21
# Versão: 1
# Licença: GPL
# Requisitos: zzdata zzpascoa
# Tags: data
# ----------------------------------------------------------------------------
zzsextapaixao ()
{
	zzzz -h sextapaixao "$1" && return

	local ano="$1"

	# Se o ano não for informado, usa o atual
	test -z "$ano" && ano=$(date +%Y)

	# Validação
	zztool -e testa_ano $ano || return 1

	# Ah, como é fácil quando se tem as ferramentas certas ;)
	# e quando já temos o código e só precisamos mudar os numeros
	# tambem é bom :D ;)
	zzdata $(zzpascoa $ano) - 2
}

# ----------------------------------------------------------------------------
# zzsheldon
# Exibe aleatoriamente uma frase do Sheldon, do seriado The Big Bang Theory.
# Com a opção -t ou --traduzir mostra os diálogos traduzidos.
#
# Uso: zzsheldon [-t|--traduzir]
# Ex.: zzsheldon
#
# Autor: Jonas Gentina, <jgentina (a) gmail com>
# Desde: 2015-09-25
# Versão: 2
# Licença: GPL
# Requisitos: zzaleatorio zztrim zzjuntalinhas zzlinha zztradutor zzsqueeze zzxml zzutf8
# ----------------------------------------------------------------------------
zzsheldon ()
{
	zzzz -h sheldon "$1" && return

	# Declaracoes locais:
	local url="http://the-big-bang-theory.com/quotes/character/Sheldon/"
	local begin="Quote from the episode"
	local end="Correct this quote"

	zztool source ${url}$(zzaleatorio 211) |
	zzutf8 |
	sed 's/Correct this quote/<p>Correct this quote<\/p>/g' |
	zzxml --tag p |
	zzjuntalinhas -i '<p' -f '<.p>' -d ' ' |
	sed 's/<br \/>/|/g' |
	zzxml --untag |
	zzsqueeze |
	sed -n "/$begin/,/$end/p" |
	zztrim -H |
	zzjuntalinhas -i "$begin" -f "$end" -d "|" |
	zzlinha |
	tr '|' '\n' |
	sed "/$end/d;s/$begin/Episode -/;/^[[:blank:]]*$/d" |
	case $1 in
		-t | --traduzir ) zztradutor en-pt ;;
		*) cat - ;;
		esac |
	zztrim -H |
	sed "2,$ { /:/!s/^/	/; s/: /:	/; }" |
	expand -t 10
}

# ----------------------------------------------------------------------------
# zzshuffle
# Desordena as linhas de um texto (ordem aleatória).
# Uso: zzshuffle [arquivo(s)]
# Ex.: zzshuffle /etc/passwd         # desordena o arquivo de usuários
#      cat /etc/passwd | zzshuffle   # o arquivo pode vir da entrada padrão
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-06-19
# Versão: 1
# Licença: GPL
# Requisitos: zzaleatorio
# ----------------------------------------------------------------------------
zzshuffle ()
{
	zzzz -h shuffle "$1" && return

	local linha

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" |

		# Um número aleatório é colocado no início de cada linha,
		# depois o sort ordena numericamente, bagunçando a ordem
		# original. Então os números são removidos.
		while read linha
		do
			echo "$(zzaleatorio) $linha"
		done |
		sort |
		cut -d ' ' -f 2-
}

# ----------------------------------------------------------------------------
# zzsigla
# http://www.acronymfinder.com
# Dicionário de siglas, sobre qualquer assunto (como DVD, IMHO, WYSIWYG).
# Obs.: Há um limite diário de consultas por IP, pode parar temporariamente.
# Uso: zzsigla sigla
# Ex.: zzsigla RTFM
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2002-02-21
# Versão: 3
# Licença: GPL
# Requisitos: zztrim
# ----------------------------------------------------------------------------
zzsigla ()
{
	zzzz -h sigla "$1" && return

	local url='http://www.acronymfinder.com/af-query.asp'

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso sigla; return 1; }

	local sigla=$1
	# Pesquisa, baixa os resultados e filtra
	# O novo retorno do site retorna todas as opções com três espaços
	#  antes da sigla, e vários ou um espaço depois dependendo do
	#  tamanho da sigla. Assim, o grep utiliza aspas duplas para entender
	#  a filtragem
	zztool dump "$url?acronym=$sigla" |
		grep -i "   $sigla " |
		zztrim -l |
		sed 's/  */   /; s/ *$//'
}

# ----------------------------------------------------------------------------
# zzsplit
# Separa um arquivo linha a linha alternadamente em 2 ou mais arquivos.
# Usa o mesmo nome do arquivo, colocando sufixo numérico sequencial.
#
# Opção:
#  -p <relação de linhas> - numero de linhas de cada arquivo de destino.
#    Obs1.: A relação são números de linhas de cada arquivo correspondente na
#           sequência, justapostos separados por vírgula (,).
#    Obs2.: Se a quantidade de linhas na relação for menor que a quantidade de
#           arquivos, os arquivos excedentes adotam a último valor na relação.
#    Obs3.: Os números negativos na relação, saltam as linha informadas
#           sem repassar ao arquivo destino.
#
# Uso: zzsplit -p <relação> [<numero>] | <numero> <arquivo>
# Ex.: zzsplit 3 arq.txt  # Separa em 3: arq.txt.1, arq.txt.2, arq.txt.3
#      zzsplit -p 3,5,4 5 arq.txt  # Separa em 5 arquivos
#      # 3 linhas no arq.txt.1, 5 linhas no arq.txt.2 e 4 linhas nos demais.
#      zzsplit -p 3,4,2 arq.txt    # Separa em 3 arquivos
#      # 3 linhas no arq.txt.1, 4 linhas no arq.txt.2 e 2 linhas no arq.txt.3
#      zzsplit -p 2,-3,4 arq.txt   # Separa em 2 arquivos
#      # 2 linhas no arq.txt.1, pula 3 linhas e 4 linhas no arq.txt.3
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-11-10
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzsplit ()
{
	zzzz -h split "$1" && return

	local passos=1
	local qtde=0

	test -n "$1" || { zztool -e uso split; return 1; }

	# Quantidade de arquivo a serem separados
	# Estipulando as quantidades de linhas para cada arquivo de saída
	if test "$1" = "-p"
	then
		passos="$2"
		qtde=$(echo "$passos" | awk -F"," '{ print NF }')
		shift
		shift
	fi
	# Estipilando a quantidade de arquivos de saída diretamente
	if zztool testa_numero $1
	then
		qtde=$1
		shift
	fi

	# Garantindo separar em 2 arquivos ou mais
	test "$qtde" -gt "1" || { zztool -e uso split; return 1; }

	# Conferindo se arquivo existe e é legível
	zztool arquivo_legivel "$1" || { zztool -e uso split; return 1; }

	# Onde a "separação" ocorre efetivamente.
	awk -v qtde_awk=$qtde -v passos_awk="$passos" '
		BEGIN {
			tamanho = length(qtde_awk)

			qtde_passos = split(passos_awk, passo, ",")
			if (qtde_passos < qtde_awk) {
				ultimo_valor = passo[qtde_passos]
				for (i = qtde_passos + 1; i <= qtde_awk; i++) {
					passo[i] = ultimo_valor
				}
			}

			ordem = 1
		}

		{
			if (ordem > qtde_awk)
				ordem = 1

			val_abs = passo[ordem] >= 0 ? passo[ordem] : passo[ordem] * -1

			sufixo = sprintf("%0" tamanho "d", ordem)

			if (passo[ordem] > 0)
				print $0 >> (FILENAME "." sufixo)

			if (val_abs > 1) {
				for (i = 2; i <= val_abs; i++) {
					if (getline > 0) {
						if (passo[ordem] > 0)
							print $0 >> (FILENAME "." sufixo)
					}
				}
			}

			ordem++
		}
	' "$1"
}

# ----------------------------------------------------------------------------
# zzsqueeze
# Reduz vários espaços consecutivos vertical ou horizontalmente em apenas um.
#
# Opções:
#  -l ou --linha: Apenas linhas vazias consecutivas, se reduzem a uma.
#  -c ou --coluna: Espaços consecutivos em cada linha, são unidos em um.
#
# Obs.: Linhas inteiras com espaços ou tabulações,
#        tornam-se linhas de comprimento zero (sem nenhum caractere).
#
# Uso: zzsqueeze [-l|--linha] [-c|--coluna] arquivo
# Ex.: zzsqueeze arquivo.txt
#      zzsqueeze -l arq.txt   # Apenas retira linhas consecutivas em branco.
#      zzsqueeze -c arq.txt   # Transforma em 1 espaço, vários espaços juntos.
#      cat arquivo | zzsqueeze
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2015-09-24
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzsqueeze ()
{
	zzzz -h squeeze "$1" && return

	local linha=1
	local coluna=1

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-l | --linha  ) shift; coluna=0;;
			-c | --coluna ) shift; linha=0;;
			--) shift; break;;
			-*) zztool -e uso squeeze; return 1;;
			*) break;;
		esac
	done

	zztool file_stdin "$@" |
	if test $coluna -eq 1
	then
		tr -s '[:blank:]' ' '
	else
		cat -
	fi |
	if test $linha -eq 1
	then
		awk '
			/^[ 	]*$/{ branco++ }

			! /^[ 	]*$/ {
				if (branco>0) { print ""; branco=0 }
				print
			}

			END { if (branco>0) print "" }
		'
	else
		sed 's/^[ 	]*$//'
	fi
}

# ----------------------------------------------------------------------------
# zzss
# Protetor de tela (Screen Saver) para console, com cores e temas.
# Temas: mosaico, espaco, olho, aviao, jacare, alien, rosa, peixe, siri.
# Obs.: Aperte Ctrl+C para sair.
# Uso: zzss [--rapido|--fundo] [--tema <tema>] [texto]
# Ex.: zzss
#      zzss fui ao banheiro
#      zzss --rapido /
#      zzss --fundo --tema peixe
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2003-06-12
# Versão: 1
# Licença: GPL
# Requisitos: zzaleatorio zztrim
# ----------------------------------------------------------------------------
zzss ()
{
	zzzz -h ss "$1" && return

	local mensagem tamanho_mensagem mensagem_colorida
	local cor_fixo cor_muda negrito codigo_cores fundo
	local linha coluna dimensoes
	local linhas=25
	local colunas=80
	local tema='mosaico'
	local pausa=1

	local temas='
		mosaico	#
		espaco	.
		olho	00
		aviao	--o-0-o--
		jacare	==*-,,--,,--
		alien	/-=-\\
		rosa	--/--\-<@
		peixe	>-)))-D
		siri	(_).-=''=-.(_)
	'

	# Tenta obter as dimensões atuais da tela/janela
	dimensoes=$(stty size 2>/dev/null)
	if test -n "$dimensoes"
	then
		linhas=${dimensoes% *}
		colunas=${dimensoes#* }
	fi

	# Opções de linha de comando
	while test $# -ge 1
	do
		case "$1" in
			--fundo)
				fundo=1
			;;
			--rapido)
				unset pausa
			;;
			--tema)
				test -n "$2" || { zztool -e uso ss; return 1; }
				tema=$2
				shift
			;;
			*)
				mensagem="$*"
				unset tema
				break
			;;
		esac
		shift
	done

	# Extrai a mensagem (desenho) do tema escolhido
	if test -n "$tema"
	then
		mensagem=$(
			echo "$temas" |
				grep -w "$tema" |
				zztrim |
				cut -f2
		)

		if ! test -n "$mensagem"
		then
			zztool erro "Tema desconhecido '$tema'"
			return 1
		fi
	fi

	# O 'mosaico' é um tema especial que precisa de ajustes
	if test "$tema" = 'mosaico'
	then
		# Configurações para mostrar retângulos coloridos frenéticos
		mensagem=' '
		fundo=1
		unset pausa
	fi

	# Define se a parte fixa do código de cores será fundo ou frente
	if test -n "$fundo"
	then
		cor_fixo='30;4'
	else
		cor_fixo='40;3'
	fi

	# Então vamos começar, primeiro limpando a tela
	clear

	# O 'trap' mapeia o Ctrl-C para sair do Screen Saver
	( trap "clear;return" 2

	tamanho_mensagem=${#mensagem}

	while :
	do
		# Posiciona o cursor em um ponto qualquer (aleatório) da tela (X,Y)
		# Detalhe: A mensagem sempre cabe inteira na tela ($coluna)
		linha=$(zzaleatorio 1 $linhas)
		coluna=$(zzaleatorio 1 $((colunas - tamanho_mensagem + 1)))
		printf "\033[$linha;${coluna}H"

		# Escolhe uma cor aleatória para a mensagem (ou o fundo): 1 - 7
		cor_muda=$(zzaleatorio 1 7)

		# Usar negrito ou não também é escolhido ao acaso: 0 - 1
		negrito=$(zzaleatorio 1)

		# Podemos usar cores ou não?
		if test "$ZZCOR" = 1
		then
			codigo_cores="$negrito;$cor_fixo$cor_muda"
			mensagem_colorida="\033[${codigo_cores}m$mensagem\033[m"
		else
			mensagem_colorida="$mensagem"
		fi

		# Mostra a mensagem/desenho na tela e (talvez) espera 1s
		printf "$mensagem_colorida"
		${pausa:+sleep 1}
	done )
}

# ----------------------------------------------------------------------------
# zzstr2hexa
# Converte string em bytes em hexadecimal equivalente.
# Uso: zzstr2hexa [string]
# Ex.: zzstr2hexa @MenteBrilhante    # 40 4d 65 6e 74 65 42 72 69 6c 68 61 6e…
#      zzstr2hexa bin                # 62 69 6e
#      echo bin | zzstr2hexa         # 62 69 6e
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2012-03-30
# Versão: 9
# Licença: GPL
# Requisitos: zztrim
# ----------------------------------------------------------------------------
zzstr2hexa ()
{
	zzzz -h str2hexa "$1" && return

	local string caractere
	local nl=$(printf '\n')

	# String vem como argumento ou STDIN?
	# Nota: não use zztool multi_stdin, adiciona \n no final do argumento
	if test $# -ne 0
	then
		string="$*"
	else
		string=$(cat /dev/stdin)
	fi

	# Loop a cada caractere, e o printf o converte para hexa
	printf %s "$string" |
		while IFS= read -r -n 1 caractere
		do
			if test "$caractere" = "$nl"
			then
				# Exceção para contornar um bug:
				#   printf %x 'c retorna 0 quando c=\n
				printf '0a '
			else
				printf '%02x ' "'$caractere"
			fi
		done |
		zztrim -r |
		zztool nl_eof
}

# ----------------------------------------------------------------------------
# zzsubway
# Mostra uma sugestão de sanduíche para pedir na lanchonete Subway.
# Obs.: Se não gostar da sugestão, chame a função novamente para ter outra.
# Uso: zzsubway
# Ex.: zzsubway
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-12-02
# Versão: 1
# Licença: GPL
# Requisitos: zzshuffle zzaleatorio
# ----------------------------------------------------------------------------
zzsubway ()
{
	zzzz -h subway "$1" && return

	local linha quantidade categoria opcoes

	# O formato é quantidade:categoria:opção1:...:opçãoN
	cardapio="\
	1:recheio:(1) B.M.T. Italiano:(2) Atum:(3) Vegetariano:(4) Frutos do Mar Subway:(5) Frango Teriaki:(6) Peru, Presunto & Bacon:(7) Almôndegas:(8) Carne e Queijo:(9) Peru, Presunto & Roast Beef:(10) Peito de Peru:(11) Rosbife:(12) Peito de Peru e Presunto
	1:pão:italiano branco:integral:parmesão e orégano:três queijos:integral aveia e mel
	1:tamanho:15 cm:30 cm
	1:queijo:suíço:prato:cheddar
	1:extra:nenhum:bacon:tomate seco:cream cheese
	1:tostado:sim:não
	*:salada:alface:tomate:pepino:cebola:pimentão:azeitona preta:picles:rúcula
	1:molho:mostarda e mel:cebola agridoce:barbecue:parmesão:chipotle:mostarda:maionese
	*:tempero:sal:vinagre:azeite de oliva:pimenta calabresa:pimenta do reino"

	echo "$cardapio" | while read linha; do
		quantidade=$(echo "$linha" | cut -d : -f 1 | tr -d '\t')
		categoria=$( echo "$linha" | cut -d : -f 2)
		opcoes=$(    echo "$linha" | cut -d : -f 3- | tr : '\n')

		# Que tipo de ingrediente mostraremos agora? Recheio? Pão? Tamanho? ...
		printf "%s\t: " "$categoria"

		# Quantos ingredientes opcionais colocaremos no pão?
		# O asterisco indica "qualquer quantidade", então é escolhido um
		# número qualquer dentre as opções disponíveis.
		if test "$quantidade" = '*'
		then
			quantidade=$(echo "$opcoes" | zztool num_linhas)
			quantidade=$(zzaleatorio 1 $quantidade)
		fi

		# Hora de mostrar os ingredientes.
		# Escolhidos ao acaso (zzshuffle), são pegos N itens ($quantidade).
		# Obs.: Múltiplos itens são mostrados em uma única linha (paste+sed).
		echo "$opcoes" |
			zzshuffle |
			head -n $quantidade |
			paste -s -d : - |
			sed 's/:/, /g'
	done
}

# ----------------------------------------------------------------------------
# zztabuada
# Exibe a tabela de tabuada de um número.
# Com 1 argumento:
#  Tabuada de qualquer número inteiro de 1 a 10.
#
# Com 2 argumentos:
#  Tabuada de qualquer número inteiro de 1 ao segundo argumento.
#  O segundo argumento só pode ser um número positivo de 1 até 99, inclusive.
#
# Se não for informado nenhum argumento será impressa a tabuada de 1 a 9.
#
# Uso: zztabuada [número [número]]
# Ex.: zztabuada
#      zztabuada 2
#      zztabuada -176
#      zztabuada 5 15  # Tabuada do 5, mas multiplicado de 1 até o 15.
#
# Autor: Kl0nEz <kl0nez (a) wifi org br>
# Desde: 2011-08-23
# Versão: 6
# Licença: GPLv2
# Requisitos: zzseq zztestar
# ----------------------------------------------------------------------------
zztabuada ()
{
	zzzz -h tabuada "$1" && return

	local i j
	local numeros='0 1 2 3 4 5 6 7 8 9 10'
	local linha="+--------------+--------------+--------------+"

	case "$#" in
		1 | 2)
			if zztestar numero_sinal "$1"
			then
				if zztool testa_numero "$2" && test $2 -le 99
				then
					numeros=$(zzseq -f '%d ' 0 $2)
				fi

				for i in $numeros
				do
					if test $i -eq 0 && ! zztool testa_numero "$1"
					then
						printf '%d x %-2d = %d\n' "$1" "$i" $(($1*$i)) | sed 's/= 0/=  0/'
					else
						printf '%d x %-2d = %d\n' "$1" "$i" $(($1*$i))
					fi
				done
			else
				zztool -e uso tabuada
				return 1
			fi
		;;
		0)
			for i in 1 4 7
			do
				echo "$linha"
				echo "| Tabuada do $i | Tabuada do $((i+1)) | Tabuada do $((i+2)) |"
				echo "$linha"
				for j in 0 1 2 3 4 5 6 7 8 9 10
				do
					printf '| %d x %-2d = %-3d ' "$i"     "$j" $((i*j))
					printf '| %d x %-2d = %-3d ' $((i+1)) "$j" $(((i+1)*j))
					printf '| %d x %-2d = %-3d ' $((i+2)) "$j" $(((i+2)*j))
					printf '|\n'
				done
				echo "$linha"
				echo
			done | sed '$d'
		;;
		*)
			zztool -e uso tabuada
			return 1
		;;
	esac
}

# ----------------------------------------------------------------------------
# zztac
# Inverte a ordem das linhas, mostrando da última até a primeira.
# É uma emulação (portável) do comando tac, presente no Linux.
#
# Uso: zztac [arquivos]
# Ex.: zztac /etc/passwd
#      zztac arquivo.txt outro.txt
#      cat /etc/passwd | zztac
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2013-02-24
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zztac ()
{
	zzzz -h tac "$1" && return

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" | sed '1!G;h;$!d'

	# Explicação do sed:
	#   A versão simplificada dele é: G;h;d. Esta sequência de comandos
	#   vai empilhando as linhas na ordem inversa no buffer reserva.
	#
	# Supondo o arquivo:
	#   um
	#   dois
	#   três
	#
	# Funcionará assim:
	#                            [principal]            [reserva]
	# --------------------------------------------------------------
	#   Lê a linha 1             um
	#   h                        um                     um
	#   d                                               um
	#   Lê a linha 2             dois
	#   G                        dois\num
	#   h                        dois\num               dois\num
	#   d                                               dois\num
	#   Lê a linha 3             três
	#   h                        três\ndois\num         dois\num
	#   FIM DO ARQUIVO
	#   Mostra o conteúdo do [principal], as linhas invertidas.
}

# ----------------------------------------------------------------------------
# zztempo
# Mostra previsão do tempo obtida em http://wttr.in/ por meio do comando curl.
# Mostra as condições do tempo (clima) em um determinado local.
# Se nenhum parâmetro for passado, é apresentada a previsão de Brasília.
# As siglas de aeroporto também podem ser utilizadas.
#
# Opções:
#
# -l, --lang, --lingua
#    Exibe a previsão em uma das línguas disponíveis: az be bg bs ca cy cs
#    da de el eo es et fi fr hi hr hu hy is it  ja jv ka kk ko ky lt lv mk
#    ml nl nn pt pl ro ru sk sl sr sr-lat sv sw th tr uk uz vi zh zu
#
# -u, --us
#    Retorna leitura em unidades USCS - United States customary units -
#    Unidades Usuais nos Estados Unidos. Isto é: "°F" para temperatura,
#    "mph" para velocidade do vento,  "mi" para visibilidade e "in" para
#    precipitação.
#
# -v, --vento
#    Retorna vento em m/s ao invés de km/h ou mph.
#
# -m, --monocromatico
#    Nao utiliza comandos de cores no terminal
#
# -s, --simples
#    Retorna versão curta, com previsão de meio-dia e noite apenas.
#    Utiliza 63 caracteres de largura contra os 125 da resposta completa.
#
# -c, --completo
#    Retorna versão completa, com 4 horários ao longo do dia.
#    Utiliza 125 caracteres de largura.
#
# -d, --dias
# Determina o número de dias (entre 0 e 3) de previsão apresentados.
#    -d 0 = apenas tempo atual. Também pode se chamado com -0
#    -d 1 = tempo atual mais 1 dia. Também pode se chamado com -1
#    -d 2 = tempo atual mais 2 dias. Também pode se chamado com -2
#    -d 3 = tempo atual mais 3 dias. Padrão.
#
# Uso: zztempo [parametros] <localidade>
# Ex.: zztempo 'São Paulo'
#      zztempo cwb
#      zztempo -d 0 Curitiba
#      zztempo -2 -l fr -s Miami
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2004-02-19
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zztempo ()
{
	zzzz -h tempo "$1" && return

	# Embrulhamos os principais parametros disponiveis em wttr.in/:help
	# Em novos comandos "aportuguesados".

	# Inicializa os modificadores com seus valores padrão.
	local lingua="pt"     # Lingua PT
	local unidade="m"     # Unidades SI
	local vento=""        # Vento Km/h
	local dias="3"        # Máximo número de dias de previsão
	local semcores=""     # Usa terminal colorido
	local simplificado    # Previsao completa ou simplificada

	#Altera para simplificado se largura do shell não comportar
	if [ 125 -gt $(tput cols) ]
	then
		simplificado="n"   # Previsao simplificada
	else
		simplificado=""    # Previsao completa
	fi

	#leitura dos parametros de entrada
	while test "${1#-}" != "$1"
	do
		case "$1" in
		-l | --lang | --lingua)
			lingua="$2";
			shift;shift ;;
		-u | --us)
			unidade="u";
			shift ;;
		-v | --vento)
			vento="M";
			shift ;;
		-s | --simples)
			simplificado="n";
			shift ;;
		-c | --completo)
			simplificado="";
			shift ;;
		-m | --monocromatico)
			semcores="T";
			shift;;
		-d | --dias)
			if zztool testa_numero "$2"
			then
				dias="$2";
			else
				zztool erro "Número de dias inválido: $2";
				return 1;
			fi
			shift; shift;;
		-0)
			dias="0";
			shift ;;
		-1)
			dias="1";
			shift;;
		-2)
			dias="2";
			shift;;
		--) shift; break ;;
		-*) zztool erro "Opção inválida: $1"; return 1 ;;
		*) break;;
		esac
	done


	# Comando bash proposto pelo site em: "wttr.in/:bash.function"
	# Chama Previsão de Brasília se outro parâmetro não for passado

	local opcoes="${unidade}${vento}${simplificado}${dias}${semcores}"
	curl -s -H "Accept-Language: ${lingua}" ${lingua}.wttr.in/"${1:-Brazil}?${opcoes}" |
	sed '/^Follow /d; /^New feature:/d'
}

# ----------------------------------------------------------------------------
# zztestar
# Testa a validade do número no tipo de categoria selecionada.
# Nada é ecoado na saída padrão, apenas deve-se analisar o código de retorno.
# Pode-se ecoar a saída de erro usando a opção -e antes da categoria.
#
#  Categorias:
#   ano                      =>  Ano válido
#   ano_bissexto | bissexto  =>  Ano Bissexto
#   exp | exponencial        =>  Número em notação científica
#   numero | numero_natural  =>  Número Natural ( inteiro positivo )
#   numero_sinal | inteiro   =>  Número Inteiro ( positivo ou negativo )
#   numero_fracionario       =>  Número Fracionário ( casas decimais )
#   numero_real              =>  Número Real ( casas decimais possíveis )
#   complexo                 =>  Número Complexo ( a+bi )
#   dinheiro                 =>  Formato Monetário ( 2 casas decimais )
#   bin | binario            =>  Número Binário ( apenas 0 e 1 )
#   octal | octadecimal      =>  Número Octal ( de 0 a 7 )
#   hexa | hexadecimal       =>  Número Hexadecimal ( de 0 a 9 e A até F )
#   ip                       =>  Endereço de rede IPV4
#   ip6 | ipv6               =>  Endereço de rede IPV6
#   mac                      =>  Código MAC Address válido
#   data                     =>  Data com formatação válida ( dd/mm/aaa )
#   hora                     =>  Hora com formatação válida ( hh:mm )
#
#   Obs.: ano, ano_bissextto e os
#         números naturais, inteiros e reais sem separador de milhar.
#
# Uso: zztestar [-e] categoria número
# Ex.: zztestar ano 1999
#      zztestar ip 192.168.1.1
#      zztestar hexa 4ca9
#      zztestar numero_real -45,678
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2016-03-14
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zztestar ()
{
	zzzz -h testar "$1" && return

	local erro

	# Devo mostrar a mensagem de erro?
	test "$1" = '-e' && erro=1 && shift

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso testar; return 1; }

	case "$1" in
		ano) zztool ${erro:+-e} testa_ano "$2" ;;

		ano_bissexto | bissexto)
			# Testa se $2 é um ano bissexto
			#
			# A year is a leap year if it is evenly divisible by 4
			# ...but not if it's evenly divisible by 100
			# ...unless it's also evenly divisible by 400
			# http://timeanddate.com
			# http://www.delorie.com/gnu/docs/gcal/gcal_34.html
			# http://en.wikipedia.org/wiki/Leap_year
			#
			local y=$2
			test $((y%4)) -eq 0 && test $((y%100)) -ne 0 || test $((y%400)) -eq 0
			test $? -eq 0 && return 0

			test -n "$erro" && zztool erro "Ano bissexto inválido '$2'"
			return 1
		;;

		exp | exponencial)
			# Testa se $2 é um número em notação científica
			echo "$2" | sed 's/^-\([.,]\)/-0\1/;s/^\([.,]\)/0\1/' |
			grep '^[+-]\{0,1\}[0-9]\{1,\}\([,.][0-9]\{1,\}\)\{0,1\}[eE][+-]\{0,1\}[0-9]\{1,\}$' >/dev/null && return 0

			test -n "$erro" && zztool erro "Número exponencial inválido '$2'"
			return 1
		;;

		numero | numero_natural) zztool ${erro:+-e} testa_numero "$2" ;;

		numero_sinal | inteiro)
			# Testa se $2 é um número (pode ter sinal: -2 +2)
			echo "$2" | grep '^[+-]\{0,1\}[0-9]\{1,\}$' >/dev/null && return 0

			test -n "$erro" && zztool erro "Número inteiro inválido '$2'"
			return 1
		;;

		numero_fracionario)
			# Testa se $2 é um número fracionário (1.234 ou 1,234)
			# regex: \d+[,.]\d+
			echo "$2" | grep '^[0-9]\{1,\}[,.][0-9]\{1,\}$' >/dev/null && return 0

			test -n "$erro" && zztool erro "Número fracionário inválido '$2'"
			return 1
		;;

		numero_real)
			# Testa se $2 é um número real (1.234; 1,234; -56.789; 123)
			# regex: [+-]?\d+([,.]\d+)?
			echo "$2" | sed 's/^-\([.,]\)/-0\1/;s/^\([.,]\)/0\1/' |
			grep '^[+-]\{0,1\}[0-9]\{1,\}\([,.][0-9]\{1,\}\)\{0,1\}$' >/dev/null && return 0

			test -n "$erro" && zztool erro "Número real inválido '$2'"
			return 1
		;;

		complexo)
			# Testa se $2 é um número complexo (3+5i ou -9i)
			# regex: ((\d+([,.]\d+)?)?[+-])?\d+([,.]\d+)?i
			echo "$2" | sed 's/^-\([.,]\)/-0\1/;s/^\([.,]\)/0\1/' |
			grep '^\(\([+-]\{0,1\}[0-9]\{1,\}\([,.][0-9]\{1,\}\)\{0,1\}\)\{0,1\}[+-]\)\{0,1\}[0-9]\{1,\}\([,.][0-9]\{1,\}\)\{0,1\}i$' >/dev/null && return 0

			test -n "$erro" && zztool erro "Número complexo inválido '$2'"
			return 1
		;;

		dinheiro)
			# Testa se $2 é um valor monetário (1.234,56 ou 1234,56)
			# regex: (  \d{1,3}(\.\d\d\d)+  |  \d+  ),\d\d
			echo "$2" | grep '^[+-]\{0,1\}\([0-9]\{1,3\}\(\.[0-9][0-9][0-9]\)\{1,\}\|[0-9]\{1,\}\),[0-9][0-9]$' >/dev/null && return 0

			test -n "$erro" && zztool erro "Valor inválido '$2'"
			return 1
		;;

		bin | binario)
			# Testa se $2 é um número binário
			echo "$2" | grep '^[01]\{1,\}$' >/dev/null && return 0

			test -n "$erro" && zztool erro "Número binário inválido '$2'"
			return 1
		;;

		octal | octadecimal)
			# Testa se $2 é um número octal
			echo "$2" | grep '^[0-7]\{1,\}$' >/dev/null && return 0

			test -n "$erro" && zztool erro "Número octal inválido '$2'"
			return 1
		;;

		hexa | hexadecimal)
			# Testa se $2 é um número hexadecimal
			echo "$2" | grep '^[0-9A-Fa-f]\{1,\}$' >/dev/null && return 0

			test -n "$erro" && zztool erro "Número hexadecimal inválido '$2'"
			return 1
		;;

		ip)
			# Testa se $2 é um número IPV4 (nnn.nnn.nnn.nnn)
			local nnn="\([0-9]\{1,2\}\|1[0-9][0-9]\|2[0-4][0-9]\|25[0-5]\)" # 0-255
			echo "$2" | grep "^$nnn\.$nnn\.$nnn\.$nnn$" >/dev/null && return 0

			test -n "$erro" && zztool erro "Número IP inválido '$2'"
			return 1
		;;

		ip6 | ipv6)
			# Testa se $2 é um número IPV6 (hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh)
			echo "$2" |
			awk -F : '
			{
				if ( $0 ~ /^:[^:]/ )      { exit 1 }
				if ( $0 ~ /:::/  )        { exit 1 }
				if ( $0 ~ /:$/ )          { exit 1 }
				if ( NF<8 && $0 !~ /::/ ) { exit 1 }
				if ( NF>8 )               { exit 1 }
				if ( NF<=8 ) {
					for (i=1; i<=NF; i++) {
						if (length($i)>4)  { exit 1 }
						if (length($i)>0 && $i !~ /^[0-9A-Fa-f]+$/) { exit 1 }
					}
				}
			}' && return 0

			test -n "$erro" && zztool erro "Número IPV6 inválido '$2'"
			return 1
		;;

		mac)
			# Testa se $2 tem um formato de MAC válido
			# O MAC poderá ser nos formatos 00:00:00:00:00:00, 00-00-00-00-00-00 ou 0000.0000.0000
			echo "$2" | egrep '^([0-9A-Fa-f]{2}-){5}[0-9A-Fa-f]{2}$' >/dev/null && return 0
			echo "$2" | egrep '^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$' >/dev/null && return 0
			echo "$2" | egrep '^([0-9A-Fa-f]{4}\.){2}[0-9A-Fa-f]{4}$' >/dev/null && return 0

			test -n "$erro" && zztool erro "MAC address inválido '$2'"
			return 1
		;;

		data) zztool ${erro:+-e} testa_data "$2" ;;

		hora)
			# Testa se $2 é uma hora (hh:mm)
			echo "$2" | grep "^\(0\{0,1\}[0-9]\|1[0-9]\|2[0-3]\):[0-5][0-9]$" >/dev/null && return 0

			test -n "$erro" && zztool erro "Hora inválida '$2'"
			return 1
		;;

		*)
			# Qualquer outra opção retorna erro
			test -n "$erro" && zztool erro "Opção '$1' inválida"
			return 1
		;;
	esac
}

# ----------------------------------------------------------------------------
# zztimer
# Mostra um cronômetro regressivo.
# Opções:
#   -n: Os números são ampliados para um formato de 5 linhas e 6 colunas.
#   -x char: Igual a -n, mas os números são compostos pelo caracter "char".
#   -y nums chars: Troca os nums por chars, igual ao comando 'y' no sed.
#      Obs.: nums e chars tem que ter a mesma quantidade de caracteres.
#   -c: Apenas converte o tempo em segundos.
#   -s: Aguarda o tempo como sleep, sem mostrar o cronômetro.
#   -p: Usa uma temporização mais precisa, porém usa mais recursos.
#   --teste: Desabilita centralização (usar depois das opções -n,-x,-y).
#
# Obs: Máximo de 99 horas.
#      Opções -n, -x, -y sempre centralizada na tela, exceto se usar --teste.
#
# Uso: zztimer [-c|-s|-n|-x char|-y nums chars] [-p] [[hh:]mm:]ss
# Ex.: zztimer 90           # Cronomêtro regressivo a partir de 1:30
#      zztimer 2:56         # Cronometragem regressiva simples.
#      zztimer -c 2:22      # Exibe o tempo em segundos (no caso 142)
#      zztimer -s 5:34      # Exibe o tempo em segundos e aguarda o tempo.
#      zztimer --centro 20  # Centralizado horizontal e verticalmente
#      zztimer -n 1:7:23    # Formato ampliado do número
#      zztimer -x H 65      # Com números feito pela letra 'H'
#      zztimer -y 0123456789 9876543210 60  # Troca os números
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2016-01-25
# Versão: 5
# Licença: GPL
# Requisitos: zzcut
# ----------------------------------------------------------------------------
zztimer ()
{

	zzzz -h timer "$1" && return

	local opt str num seg char_para centro left_pad
	local teste=0
	local no_tput=1
	local prec='s'

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso timer; return 1; }

	# Opções de exibição dos números
	while test "${1#-}" != "$1"
	do
		case "$1" in
		-n) opt='n'; shift ;;
		-x)
			opt='x'
			str=$(echo "$2" | zzcut -c 1)
			shift; shift
		;;
		-y)
			opt='x'
			str="$2"
			char_para="$3";
			if test ${#str} -ne ${#char_para}
			then
				opt='n'
				unset str
				unset char_para
			fi
			shift; shift; shift
		;;
		-c) opt='c'; no_tput=1; shift ;;
		-s) opt='s'; no_tput=1; shift ;;
		-p) prec='p'; shift ;;
		--teste) teste=1; shift ;;
		-*) zztool erro "Opção inválida: $1"; return 1 ;;
		*) break;;
		esac
	done

	echo "$1" | grep '^[0-9:]\{1,\}$' >/dev/null || { zztool erro "Entrada inválida"; return 1; }

	if test $teste -eq 1
	then
		no_tput=1
		centro=0
	else
		case "$opt" in
			n|x) no_tput=0; centro=1 ;;
			*)   no_tput=1; centro=0 ;;
		esac
	fi

	# Separando cada elemento de tempo hora, minutos e segundos
	# E ajustando minutos e segundos que extrapolem o limite de 60{min,s}
	set - $(
		echo "$1" |
		awk -F ':' '
		{
			seg  = $NF
			min  = (NF>2?(length($2)?$2:0):(NF==2?(length($1)?$1:0):0))
			hora = (NF>=3?(length($1)?$1:0):0)
			print (hora*3600) + (min*60) + seg
		}'
	)

	if test $1 -lt 360000
	then
		num=$1
		test "$opt" = "c" && { echo $num;  return; }
		test "$opt" = "s" && { sleep $num; return; }
	else
		zztool erro "Valor $1 muito elevado."
		return 1
	fi

	# Restaurando terminal
	test "$no_tput" -eq 0 && tput reset

	# Centralizar?
	if test "$centro" -eq 1
	then
		if test -n "$opt"
		then
			tput cup $(tput lines | awk '{print int(($1 - 5) / 2)}') 0
			left_pad=$(tput cols | awk '{print int(($1 - 56) / 2)}')
		else
			tput cup $(tput lines | awk '{print int($1 / 2)}') $(tput cols | awk '{print int(($1 - 8) / 2)}')
		fi
	fi

	while test $num -ge 0
	do

		# Definindo segundo atual
		seg=$(date +%S)

		# Marcando ponto para retorno do cursor
		test "$no_tput" -eq 0 && tput sc

		# Exibindo os números do cronômetro
		echo "$num" |
		awk -v formato="$opt" -v left_pad="$left_pad" '
		function formatar(hora,  i, j, space) {
			space=(length(left_pad)>0?sprintf("%"left_pad"s"," "):"")
			numero[0, 1] = numero[0, 5] = " 0000 "; numero[0, 2] = numero[0, 3] = numero[0, 4] = "0    0"
			numero[1, 1] = " 111  "; numero[1, 2] = numero[1, 3] = numero[1, 4] = "  11  "; numero[1, 5] = "111111"
			numero[2, 1] = " 2222 "; numero[2, 2] = "    22"; numero[2, 3] = "   22 "; numero[2, 4] = " 22   "; numero[2, 5] = "222222"
			numero[3, 1] = numero[3, 5] = "33333 "; numero[3, 2] =  numero[3, 4] = "     3"; numero[3, 3] = " 3333 "
			numero[4, 1] = "   44 "; numero[4, 2] = "  4 4 "; numero[4, 3] = " 4  4 "; numero[4, 4] = "444444"; numero[4, 5] = "    4 "
			numero[5, 1] = numero[5, 3] = "55555 "; numero[5, 2] = "5     "; numero[5, 4] = "     5"; numero[5, 5] = " 5555 "
			numero[6, 1] = numero[6, 5] = " 6666 "; numero[6, 2] = "6     "; numero[6, 3] = "66666 "; numero[6, 4] = "6    6"
			numero[7, 1] = "777777"; numero[7, 2] = "    7 "; numero[7, 3] = "   7  "; numero[7, 4] = "  7   "; numero[7, 5] = " 7    "
			numero[8, 1] = numero[8, 3] = numero[8, 5] = " 8888 "; numero[8, 2] = numero[8, 4] = "8    8"
			numero[9, 1] = numero[9, 5] = " 9999 "; numero[9, 2] = "9    9"; numero[9, 3] = " 99999"; numero[9, 4] = "     9"
			numero["x", 1] = numero["x", 3] = numero["x", 5] = "      "; numero["x", 2] = numero["x", 4] = "  #   "
			for (i=1; i<6; i++)
				print space numero[substr(hora,1,1), i], numero[substr(hora,2,1), i], numero["x", i], numero[substr(hora,4,1), i], numero[substr(hora,5,1), i], numero["x", i], numero[substr(hora,7,1), i], numero[substr(hora,8,1), i]
		}
		{
			hh = $1/3600
			mm = ($1%3600)/60
			ss = ($1%3600)%60
			if (length(formato)) {
				formatar(sprintf("%02d:%02d:%02d\n", hh, mm, ss))
			}
			else
				printf "%02d:%02d:%02d\n", hh, mm, ss
		}' |
		if test -n "$str"
		then
			if test "${#char_para}" -gt 0
			then
				sed "y/$str/$char_para/"
			else
				sed "s/[0-9#]/$str/g"
			fi
		else
			cat -
		fi

		# Temporizar ( p = mais preciso / s = usando sleep )
		if test "$prec" = 'p'
		then
			# Mais preciso, mas sobrecarrega o processamento
			while test "$seg" = $(date +%S);do :;done
		else
			# Menos preciso, porém mais leve ( padrão )
			sleep 1
		fi

		# Decrementar o contador
		num=$((num-1))

		# Reposicionar o cursor
		if test $num -ge 0
		then
			test "$no_tput" -eq 0 && tput rc
		fi
	done
}

# ----------------------------------------------------------------------------
# zztop
# Lista os 10 computadores mais rápidos do mundo.
# Sem argumentos usa a listagem mais recente.
# Definindo categoria, quantifica os 500 computadores mais rápidos.
#
# Argumentos de ajuda:
#  -c: Exibe categorias possíveis
#  -l: Exibe as listas disponíveis
#
# Argumentos de listagem:
#  [categoria]: Seleciona a categoria desejada.
#  [lista]:     Seleciona a lista, se omitida mostra mais recente.
# Obs: Podem ser usadas em conjunto
#
# Uso: zztop [-c|-l] [categoria] [lista]
# Ex.: zztop             # Lista os 10 mais rápidos.
#      zztop osfam 23    # Famílias de OS em Junho de 2004 ( Virada Linux! )
#      zztop country     # Quantifica por pais entre os 500 mais velozes
#      zztop -c          # Lista as categorias possíveis da listagem
#      zztop -l          # Exibe todas as listas disponíveis
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2015-07-19
# Versão: 2
# Licença: GPL
# Requisitos: zztac zzcolunar zzecho zzxml zzunescape zztrim
# ----------------------------------------------------------------------------
zztop ()
{

	zzzz -h top "$1" && return

	local url="http://top500.org"
	local cor='amarelo'
	local ntab=35
	local cache category release all_releases max_release ano mes

	# Argumento apenas para exibir opções diponíveis e sair
	while test "${1#-}" != "$1"
	do
		case "$1" in
		-c)
		# Categorias pela qual a lista se subdivide
			zzecho -l $cor "vendor        Vendors"
			zzecho -l $cor "app           Application Area"
			zzecho -l $cor "accel         Accelerator/Co-Processor"
			zzecho -l $cor "segment       Segments"
			zzecho -l $cor "continent     Continents"
			zzecho -l $cor "connfam       Interconnect Family"
			zzecho -l $cor "interconnect  Interconnect"
			zzecho -l $cor "country       Countries"
			zzecho -l $cor "region        Geographical Region"
			zzecho -l $cor "procgen       Processor Generation"
			zzecho -l $cor "accelfam      Accelerator/CP Family"
			zzecho -l $cor "architecture  Architecture"
			zzecho -l $cor "osfam         Operating system Family"
			zzecho -l $cor "cores         Cores per Socket"
			zzecho -l $cor "os            Operating System"
			return 0
		;;
		-l)
		# Meses e anos disponíveis, representado por um número sequencial
			zztool source "${url}/statistics/list" |
			sed -n '/option value/{s/^.*value="//;s/<\/option>$//;s/".*>/	/;p;}' |
			sed '/June 1993$/q' | expand -t 3 |
			zztac | zzcolunar -w 20 3
			return 0
		;;
		-*) zztool -e uso top; return 1 ;;
		esac
	done

	all_releases=$(
		zztool source "${url}/statistics/list" |
		sed -n '/option value/{s/^.*value="//;s/<\/option>$//;s/".*>/	/;p;}' |
		sed '/June 1993$/q'
	)

	while test -n "$1"
	do
		# Escolha da categoria
		case "$1" in
			vendor | app | accel | procgen | os)                  category="$1"; ntab=35; shift;;
			connfam | interconnect | country | region | accelfam) category="$1"; ntab=28; shift;;
			segment | continent | architecture | osfam | cores)   category="$1"; ntab=12; shift;;
		esac
		# Escolha da lista
		if zztool testa_numero "$1"
		then
			release="$1"
			shift
		fi
	done

	# Definindo a lista em caso de omissão
	max_release=$(echo "$all_releases" | head -n 1 | sed 's/	.*//')
	if test -z "$release"
	then
		release=$max_release
	elif test "$release" -gt "$max_release"
	then
		release=$max_release
	fi

	# Redefinindo url
	if test -n "$category"
	then
		url="${url}/statistics/list/${release}/${category}"
	else
		ano=$(echo "$all_releases" | sed -n "/^${release}	/{s/.* //;p;}")
		mes=$(
			echo "$all_releases" |
			awk -v awk_release="$release" 'BEGIN {
				mes["January"]=1; mes["February"]=2; mes["March"]=3; mes["April"]=4;
				mes["May"]=5; mes["June"]=6; mes["July"]=7; mes["August"]=8;
				mes["September"]=9; mes["October"]=10; mes["November"]=11; mes["December"]=12;
				}
				{if ($1 == awk_release) printf "%02d\n", mes[$2]}'
		)
		url="${url}/lists/${ano}/${mes}/"
	fi

	# Cacheando
	cache=$(zztool source "$url")

	# Data da lista
	if test -n "$ano"
	then
		echo "$mes/$ano"
	else
		echo "$cache" |
		sed -n '/option value/{s/^.*value="//;s/<\/option>$//;s/".*>/ /;p;}' |
		sed '/June 1993$/q' | sed -n "/^$release /{s/^[0-9]\{1,\} //;p;}"
	fi

	# Extraindo a lista escolhida
	if test -n "$category"
	then
		echo "$cache" |
		sed -n "/dataTable.addRows/{n;p;}" |
		sed "s/^ *//;s/',/	/g" |
		tr -d '\\' | tr -d "['," | tr ']' '\n' |
		expand -t $ntab
	else
		echo "$cache" | sed '/<td style=/,/<\/td>/d' |
		zzxml --tag td --notag thead --untag |
		sed '/^[0-9]\{1,\},/d;/googletag/d' |
		awk '$1 ~ /^[0-9]+$/{print ""};{printf $0"|"}'|
		sed '1d;s/| -/ -/;s/|$//' |
		awk -F'|' '{printf "%02d: ", $1; print $2, "(" $3 ")";print "    " $4, "(" $5 ")", $6; print ""}' |
		zzunescape --html |
		zztrim -r |
		sed 's/ *)/)/g;s/  *(/ (/g'
	fi
}

# ----------------------------------------------------------------------------
# zztradutor
# http://translate.google.com
# Google Tradutor, para traduzir frases para vários idiomas.
# Caso não especificado o idioma, a tradução será português -> inglês.
# Use a opção -l ou --lista para ver todos os idiomas disponíveis.
# Use a opção -a ou --audio para ouvir a frase na voz feminina do google.
#
# Alguns idiomas populares são:
#      pt = português         fr = francês
#      en = inglês            it = italiano
#      es = espanhol          de = alemão
#
# Uso: zztradutor [de-para] palavras
# Ex.: zztradutor o livro está na mesa    # the book is on the table
#      zztradutor pt-en livro             # book
#      zztradutor pt-es livro             # libro
#      zztradutor pt-de livro             # Buch
#      zztradutor de-pt Buch              # livro
#      zztradutor de-es Buch              # Libro
#      cat arquivo | zztradutor           # Traduz o conteúdo do arquivo
#      zztradutor --lista                 # Lista todos os idiomas
#      zztradutor --lista eslo            # Procura por "eslo" nos idiomas
#      zztradutor --audio                 # Gera um arquivo OUT.WAV
#      echo "teste" | zztradutor          # test
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-09-02
# Versão: 13
# Licença: GPLv2
# Requisitos: zzxml zzplay zzunescape zzutf8
# ----------------------------------------------------------------------------
zztradutor ()
{
	zzzz -h tradutor "$1" && return

	# Variaveis locais
	local padrao
	local url='https://translate.google.com.br'
	local lang_de='pt'
	local lang_para='en'
	local charset_para='UTF-8'
	local audio_file=$(zztool cache tradutor "$$.wav")

	case "$1" in
		# O usuário informou um par de idiomas, como pt-en
		[a-z][a-z]-[a-z][a-z])
			lang_de=${1%-??}
			lang_para=${1#??-}
			shift
		;;
		-l | --lista)
			# Uma tag por linha, então extrai e formata as opções do <SELECT>
			zztool source "$url" |
			zzxml --tag option |
			sed -n '/<option value=af>/,/<option value=yi>/p' |
			zzutf8 |
			sort -u |
			sed 's/.*value=\([^>]*\)>\([^<]*\)<.*/\1: \2/g;s/zh-CN/cn/g' |
			grep ${2:-:}
			return
		;;
		-a | --audio)
			# Narrativa
				shift
				padrao=$(echo "$*" | sed "$ZZSEDURL")
				local audio="translate_tts?ie=$charset_para&q=$padrao&tl=pt&prev=input"
				zztool source "$url/$audio" > $audio_file && zzplay $audio_file mplayer
				rm -f $audio_file
				return
		;;
	esac

	padrao=$(zztool multi_stdin "$@" | awk '{ if (NR==1) { printf $0 } else { printf "%%0a" $0 } }' | sed "$ZZSEDURL")

	# Exceção para o chinês, que usa um código diferente
	test $lang_para = 'cn' && lang_para='zh-CN'

	# Baixa a URL, coloca cada tag em uma linha, pega a linha desejada
	# e limpa essa linha para estar somente o texto desejado.
	zztool source -u "Mozilla/5.0" "$url?tr=$lang_de&hl=$lang_para&text=$padrao" 2>/dev/null |
		zzutf8 |
		zzxml --tidy |
		sed -n '/id=result_box/,/<\/div>/p' |
		zzxml --untag |
		sed '/span title=/d;/onmouseout=/d;/^ *$/d' |
		zzunescape --html
}

# ----------------------------------------------------------------------------
# zztranspor
# Trocar linhas e colunas de um arquivo, fazendo uma simples transposição.
# Opções:
#   -d <sep>                        define o separador de campos na entrada.
#   -D, --output-delimiter <sep>  define o separador de campos na saída.
#
# O separador na entrada pode ser 1 ou mais caracteres ou uma ER.
# Se não for declarado assume-se espaços em branco como separador.
# Conforme padrão do awk, o default seria FS = "[ \t]+".
#
# Se o separador de saída não for declarado, assume o mesmo da entrada.
# Caso a entrada também não seja declarada assume-se como um espaço.
# Conforme padrão do awk, o default é OFS = " ".
#
# Se o separador da entrada é uma ER, é bom declarar o separador de saída.
#
# Uso: zztranspor [-d <sep>] [-D | --output-delimiter <sep>] <arquivo>
# Ex.: zztranspor -d ":" --output-delimiter "-" num.txt
#      sed -n '2,5p' num.txt | zztranspor -d '[\t:]' -D '\t'
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-09-03
# Versão: 1
# Licença: GPL
# Requisitos: zztrim
# ----------------------------------------------------------------------------
zztranspor ()
{
	zzzz -h transpor "$1" && return

	local sep ofs

	while test "${1#-}" != "$1"
	do
		case "$1" in
			-d)
			# Separador de campos no arquivo de entrada
				sep="$2"
				shift
				shift
			;;
			-D | --output-delimiter)
			# Separador de campos na saída
				ofs="$2"
				shift
				shift
			;;
			*) break;;
		esac
	done

	zztool file_stdin "$@" |
	awk -v sep_awk="$sep" -v ofs_awk="$ofs" '
	BEGIN {
		# Definindo o separador de campo na entrada do awk
		if (length(sep_awk)>0)
			FS = sep_awk

		# Definindo o separador de campo na saída do awk
		ofs_awk = (length(ofs_awk)>0?ofs_awk:FS)
	}

	{
		# Descobrindo a maior quantidade de campos
		if (max_nf < NF)
			max_nf = NF

		# Criando um array indexado por número do campo e número da linha, nessa ordem
		for (i = 1; i <= NF; i++)
			vetor[i, NR] = $i
	}

	END {
		# Transformando o campo em linha
		for (i = 1; i <= max_nf; i++) {
			# Transformando a linha em campo
			for (j = 1; j <= NR; j++)
				linha = sprintf("%s%s%s", linha, vetor[i, j], ofs_awk)

			# Tirando o separador ao final da linha
			print substr(linha, 1, length(linha) - length(ofs_awk))

			# Limpando a variável para a próxima iteração
			linha=""
		}
	}' | zztrim -r
}

# ----------------------------------------------------------------------------
# zztrim
# Apaga brancos (" " \t \n) ao redor do texto: direita, esquerda, cima, baixo.
# Obs.: Linhas que só possuem espaços e tabs são consideradas em branco.
#
# Opções:
#   -t, --top         Apaga as linhas em branco do início do texto
#   -b, --bottom      Apaga as linhas em branco do final do texto
#   -l, --left        Apaga os brancos do início de todas as linhas
#   -r, --right       Apaga os brancos do final de todas as linhas
#   -V, --vertical    Apaga as linhas em branco do início e final (-t -b)
#   -H, --horizontal  Apaga os brancos do início e final das linhas (-l -r)
#
# Uso: zztrim [opções] [texto]
# Ex.: zztrim "   foo bar   "           # "foo bar"
#      zztrim -l "   foo bar   "        # "foo bar   "
#      zztrim -r "   foo bar   "        # "   foo bar"
#      echo "   foo bar   " | zztrim    # "foo bar"
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2015-03-05
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zztrim ()
{
	zzzz -h trim "$1" && return

	local top left right bottom
	local delete_top delete_left delete_right delete_bottom

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-l | --left      ) shift; left=1;;
			-r | --right     ) shift; right=1;;
			-t | --top       ) shift; top=1;;
			-b | --bottom    ) shift; bottom=1;;
			-H | --horizontal) shift; left=1; right=1;;
			-V | --vertical  ) shift; top=1; bottom=1;;
			--*) zztool erro "Opção inválida $1"; return 1;;
			*) break;;
		esac
	done

	# Comportamento padrão, quando nenhuma opção foi informada
	if test -z "$top$bottom$left$right"
	then
		top=1
		bottom=1
		left=1
		right=1
	fi

	# Compõe os comandos sed para apagar os brancos,
	# levando em conta quais são as opções ativas
	test -n "$top"    && delete_top='/[^[:blank:]]/,$!d;'
	test -n "$left"   && delete_left='s/^[[:blank:]]*//;'
	test -n "$right"  && delete_right='s/[[:blank:]]*$//;'
	test -n "$bottom" && delete_bottom='
		:loop
		/^[[:space:]]*$/ {
			$ d
			N
			b loop
		}
	'

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |
		# Aplica os filtros
		sed "$delete_top $delete_left $delete_right" |
		# Este deve vir sozinho, senão afeta os outros (comando N)
		sed "$delete_bottom"

		# Nota: Não há problema se as variáveis estiverem vazias,
		#       sed "" é um comando nulo e não fará alterações.
}

# ----------------------------------------------------------------------------
# zztrocaarquivos
# Troca o conteúdo de dois arquivos, mantendo suas permissões originais.
# Uso: zztrocaarquivos arquivo1 arquivo2
# Ex.: zztrocaarquivos /etc/fstab.bak /etc/fstab
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-06-12
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zztrocaarquivos ()
{
	zzzz -h trocaarquivos "$1" && return

	# Um terceiro arquivo é usado para fazer a troca
	local tmp=$(zztool mktemp trocaarquivos)

	# Verificação dos parâmetros
	test $# -eq 2 || { zztool -e uso trocaarquivos; return 1; }

	# Verifica se os arquivos existem
	zztool -e arquivo_legivel "$1" || return
	zztool -e arquivo_legivel "$2" || return

	# Tiro no pé? Não, obrigado
	test "$1" = "$2" && return

	# A dança das cadeiras
	cat "$2"   > "$tmp"
	cat "$1"   > "$2"
	cat "$tmp" > "$1"

	# E foi
	rm -f "$tmp"
	echo "Feito: $1 <-> $2"
}

# ----------------------------------------------------------------------------
# zztrocaextensao
# Troca a extensão dos arquivos especificados.
# Com a opção -n, apenas mostra o que será feito, mas não executa.
# Uso: zztrocaextensao [-n] antiga nova arquivo(s)
# Ex.: zztrocaextensao -n .doc .txt *          # tire o -n para renomear!
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-05-15
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zztrocaextensao ()
{
	zzzz -h trocaextensao "$1" && return

	local ext1 ext2 arquivo base novo nao

	# Opções de linha de comando
	if test "$1" = '-n'
	then
		nao='[-n] '
		shift
	fi

	# Verificação dos parâmetros
	test -n "$3" || { zztool -e uso trocaextensao; return 1; }

	# Guarda as extensões informadas
	ext1="$1"
	ext2="$2"
	shift; shift

	# Tiro no pé? Não, obrigado
	test "$ext1" = "$ext2" && return

	# Para cada arquivo que o usuário informou...
	for arquivo
	do
		# O arquivo existe?
		zztool -e arquivo_legivel "$arquivo" || continue

		base="${arquivo%$ext1}"
		novo="$base$ext2"

		# Testa se o arquivo possui a extensão antiga
		test "$base" != "$arquivo" || continue

		# Mostra o que será feito
		echo "$nao$arquivo -> $novo"

		# Se não tiver -n, vamos renomear o arquivo
		if test ! -n "$nao"
		then
			# Não sobrescreve arquivos já existentes
			zztool -e arquivo_vago "$novo" || return

			# Vamos lá
			mv -- "$arquivo" "$novo"
		fi
	done
}

# ----------------------------------------------------------------------------
# zztrocapalavra
# Troca uma palavra por outra, nos arquivos especificados.
# Obs.: Além de palavras, é possível usar expressões regulares.
# Uso: zztrocapalavra antiga nova arquivo(s)
# Ex.: zztrocapalavra excessão exceção *.txt
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-05-04
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zztrocapalavra ()
{
	zzzz -h trocapalavra "$1" && return

	local arquivo antiga_escapada nova_escapada
	local antiga="$1"
	local nova="$2"

	# Precisa do temporário pois nem todos os Sed possuem a opção -i
	local tmp=$(zztool mktemp trocapalavra)

	# Verificação dos parâmetros
	test -n "$3" || { zztool -e uso trocapalavra; return 1; }

	# Escapando a barra "/" dentro dos textos de pesquisa
	antiga_escapada=$(echo "$antiga" | sed 's,/,\\/,g')
	nova_escapada=$(  echo "$nova"   | sed 's,/,\\/,g')

	shift; shift

	# Para cada arquivo que o usuário informou...
	for arquivo
	do
		# O arquivo existe?
		zztool -e arquivo_legivel "$arquivo" || continue

		# Um teste rápido para saber se o arquivo tem a palavra antiga,
		# evitando gravar o temporário desnecessariamente
		grep "$antiga" "$arquivo" >/dev/null 2>&1 || continue

		# Uma seqüência encadeada de comandos para garantir que está OK
		cp "$arquivo" "$tmp" &&
		sed "s/$antiga_escapada/$nova_escapada/g" "$tmp" > "$arquivo" && {
			echo "Feito $arquivo" # Está retornando 1 :/
			continue
		}

		# Em caso de erro, recupera o conteúdo original
		zztool erro "Ops, deu algum erro no arquivo $arquivo"
		zztool erro "Uma cópia dele está em $tmp"
		cat "$tmp" > "$arquivo"
		return 1
	done
	rm -f "$tmp"
}

# ----------------------------------------------------------------------------
# zztv
# Mostra a programação da TV, diária ou semanal, com escolha de emissora.
#
# Opções:
#  canais - lista os canais com seus códigos para consulta.
#
#  <código canal> - Programação do canal escolhido.
#  Obs.: Seguido de "semana" ou "s": toda programação das próximas semanas.
#        Se for seguido de uma data, mostra a programação da data informada.
#
#  cod <número> - mostra um resumo do programa.
#   Obs: número obtido pelas listagens da programação do canal consultado.
#
# Programação corrente:
#  doc ou documentario, esportes ou futebol, filmes, infantil, variedades
#  series ou seriados, aberta, todos ou agora (padrão).
#
# Uso: zztv [<código canal> [s | <DATA>]]  ou  zztv [cod <número> | canais]
# Ex.: zztv CUL          # Programação da TV Cultura
#      zztv fox 31/5     # Programação da Fox na data, se disponível
#      zztv cod 3235238  # Detalhes do programa identificado pelo código
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2002-02-19
# Versão: 13
# Licença: GPL
# Requisitos: zzcolunar zzdatafmt zzjuntalinhas zzsqueeze zztrim zzunescape zzxml
# ----------------------------------------------------------------------------
zztv ()
{
	zzzz -h tv "$1" && return

	local DATA=$(date +%d\\/%m)
	local URL="http://meuguia.tv/programacao"
	local cache=$(zztool cache tv)
	local codigo desc linhas

	# 0 = lista canal especifico
	# 1 = lista programas de vários canais no horário
	# 2 = Detalhes do programa através do código
	local flag=0

	if ! test -s "$cache"
	then
		zztool source "${URL}/categoria/Todos/" |
		sed -n '
			/<a title="/{s/.*href="//;s/".*//;s|.*/||;p;}
			/<h2>/{s/^[^>]*>//;s/<.*//;s/\(TCM - \| \(EP\)\?TV\| Channel\)//;s/Esporte Interativo /EI /;p;}
		' |
		awk '{printf $0 " "; getline; print}' |
		sort |
		zzunescape --html > "$cache"
	fi

	if test -n "$2"
	then
		DATA=$(zzdatafmt -f 'DD\/MM' "$2" 2>/dev/null || echo "$DATA")
	fi

	if test -n "$1" && grep -i "^$1" $cache >/dev/null 2>/dev/null
	then
		codigo=$(grep -i "^$1" $cache | sed "s/ .*//")
		desc=$(grep -i "^$1" $cache | sed "s/^[A-Z0-9]\{3\} *//")

		zztool eco $desc
		zztool source "${URL}/canal/$codigo" |
		zztrim |
		sed -n '
			s/> *$/&|/
			/subheader/{/<!--/d;s/<.\?li[^>]*>|\?//g;p;}
			/<a title=/{s|.*/||;s/-.*/|/;p}
			/lileft/p
			/<h2>/p
		' |
		zzxml --untag |
		if test "$2" != "semana" -a "$2" != "s"
		then
			sed -n "/, ${DATA}$/,/[^|]$/p"
		else
			cat -
		fi |
		awk '
			/[0-9]$/{print "";print}
			/\|/{ printf $0;for (i=1;i<3;i++){getline; printf $0};print "" }' |
		sed '${/[^|]$/d}' |
		zztrim |
		zzunescape --html |
		awk -F '|' 'NF<=1;NF>1{printf "%-5s %-50s cod: %s\n", $2, $3,$1}'

		return
	fi

	case "$1" in
	canais) zzcolunar 4 $cache;;
	aberta)                        URL="${URL}/categoria/Aberta"; flag=1; desc="Aberta";;
	doc | documentario)            URL="${URL}/categoria/Documentarios"; flag=1; desc="Documentários";;
	esporte | esportes | futebol)  URL="${URL}/categoria/Esportes"; flag=1; desc="Esportes";;
	filmes)                        URL="${URL}/categoria/Filmes"; flag=1; desc="Filmes";;
	infantil)                      URL="${URL}/categoria/Infantil"; flag=1; desc="Infantil";;
	noticias)                      URL="${URL}/categoria/Noticias"; flag=1; desc="Notícias";;
	series | seriados)             URL="${URL}/categoria/Series"; flag=1; desc="Séries";;
	variedades)                    URL="${URL}/categoria/Variedades"; flag=1; desc="Variedades";;
	cod)                           URL="${URL}/programa/$2"; flag=2;;
	todos | agora | *)             URL="${URL}/categoria/Todos"; flag=1; desc="Agora";;
	esac

	if test $flag -eq 1
	then
		zztool eco $desc
		zztool source "$URL" |
		sed -n '
			/<a title="/{s/.*title="//;s|".*/|\t|;s/".*//;p;}
			/<h2>/{s/^[^>]*>//;s/<.*//;s/\(TCM - \| \(EP\)\?TV\| Channel\)//;s/Esporte Interativo /EI /;p;}
			/progressbar/{s/.*\([0-2][0-9]:[0-5][0-9]\).*/\1/p}
		' |
		awk -F '[\t]' '{printf "%s|%s|", $1, $2;getline;printf $0 "|";getline; print}' |
		zzunescape --html |
		awk -F '|' '{printf "%5s %-45s %s - %s\n",$4,$1, $2, $3}'
	elif test "$1" = "cod"
	then
		zztool eco "Código: $2"
		zztool source "$URL" |
		sed -n '/<h1 class/p;/body2/,/div>/p;/var str/p' |
		zzjuntalinhas -i '<p' -f 'p>' -d ' ' |
		zzjuntalinhas -i '<script' -f 'script>' -d ' ' |
		sed '
			/var str/{s/.*="//;s/".*//;}
			/<!--/d
			s_</a>_ | _g
			s/<br *\/>/\
/' |
		zzxml --untag |
		sed 's/ | $//' |
		zztrim |
		zzsqueeze |
		zzunescape --html
	fi
}

# ----------------------------------------------------------------------------
# zztweets
# Busca as mensagens mais recentes de um usuário do Twitter.
# Use a opção -n para informar o número de mensagens (padrão é 5, máx 20).
#
# Uso: zztweets [-n N] username
# Ex.: zztweets oreio
#      zztweets -n 10 oreio
#
# Autor: Eri Ramos Bastos <bastos.eri (a) gmail.com>
# Desde: 2009-07-30
# Versão: 10
# Licença: GPL
# Requisitos: zzsqueeze zztrim
# ----------------------------------------------------------------------------
zztweets ()
{
	zzzz -h tweets "$1" && return

	test -n "$1" || { zztool -e uso tweets; return 1; }

	local name
	local limite=5
	local url="https://twitter.com"

	# Opções de linha de comando
	if test "$1" = '-n'
	then
		limite="$2"
		shift
		shift

		zztool -e testa_numero "$limite" || return 1
	fi

	# Informar o @ é opcional
	name=$(echo "$1" | tr -d @)
	url="${url}/${name}"

	LANG=en zztool dump $url |
		awk '/^ *@/{imp=1;next};imp' |
		sed -n '/^ *Tweets *$/,/Back to top/p' |
		sed '1,/^ *More *$/ d
			/Copy link to Tweet/d;
			/Embed Tweet/d;
			/ followed *$/d
			s/ *(BUTTON) View translation *//
			/^ *(BUTTON) */d
			/ · Details *$/d
			/ tweeted yet\. *$/d
			/^   [1-9 ][0-9]\./i \

			/\. Pinned Tweet *$/{N;d;}
			/ Retweeted *$/{N;d;}
			/. Retweeted ./d
			/^    *[1-9 ][0-9]\./d
			/^ *Translated from /d
			/^ *View media/d
			/^ *View summary/d
			/^ *View conversation/d
			/^ *View more photos and videos$/d
			/^ *Embedded image permalink$/d
			/[0-9,]\{1,\} retweets\{0,1\} [0-9,]\{1,\} like/d #,/[o+] (BUTTON) Embed Tweet/d
			/^ *Reply *$/,/^ *More */d
			/[o+] (BUTTON) /d
			s/\[DEL: \(.\) :DEL\] /\1/g
			s/^[[:blank:]]*//g
		' |
		sed '/. added,$/{N;d;}' |
		zzsqueeze -l |
		zztrim |
		awk -v lim=$limite '
			BEGIN { print "" }
			$0 ~ /^[[:blank:]]*$/ {blanks++};{if (blanks>=lim) exit; print}
			END { print "" }
			'
}

# ----------------------------------------------------------------------------
# zzunescape
# Restaura caracteres codificados como entidades HTML e XML (&lt; &#62; ...).
# Entende entidades (&gt;), códigos decimais (&#62;) e hexadecimais (&#x3E;).
#
# Opções: --html  Restaura caracteres HTML
#         --xml   Restaura caracteres XML
#
# Uso: zzunescape [--html] [--xml] [arquivo(s)]
# Ex.: zzunescape --xml arquivo.xml
#      zzunescape --html arquivo.html
#      cat arquivo.html | zzunescape --html
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-03
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzunescape ()
{
	zzzz -h unescape "$1" && return

	local xml html
	local filtro=''

	# http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references
	xml="
		s/&#0*34;/\"/g;     s/&#x0*22;/\"/g;    s/&quot;/\"/g;
		s/&#0*38;/\&/g;     s/&#x0*26;/\&/g;    s/&amp;/\&/g;
		s/&#0*39;/'/g;      s/&#x0*27;/'/g;     s/&apos;/'/g;
		s/&#0*60;/</g;      s/&#x0*3C;/</g;     s/&lt;/</g;
		s/&#0*62;/>/g;      s/&#x0*3E;/>/g;     s/&gt;/>/g;
	"

	# http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references
	## pattern: ^(.*)\t(.*)\tU\+0*(\w+) \((\d+)\)\t.*$
	## replace: s/&#0*$4;/$2/g;\ts/&#x0*$3;/$2/g;\ts/&$1;/$2/g;
	## expand -t 20
	## Escapar na mão: \& e \"
	html="
		s/&#0*34;/\"/g;     s/&#x0*22;/\"/g;    s/&quot;/\"/g;
		s/&#0*38;/\&/g;     s/&#x0*26;/\&/g;    s/&amp;/\&/g;
		s/&#0*39;/'/g;      s/&#x0*27;/'/g;     s/&apos;/'/g;
		s/&#0*60;/</g;      s/&#x0*3C;/</g;     s/&lt;/</g;
		s/&#0*62;/>/g;      s/&#x0*3E;/>/g;     s/&gt;/>/g;
		s/&#0*160;/ /g;     s/&#x0*A0;/ /g;     s/&nbsp;/ /g;
		s/&#0*161;/¡/g;     s/&#x0*A1;/¡/g;     s/&iexcl;/¡/g;
		s/&#0*162;/¢/g;     s/&#x0*A2;/¢/g;     s/&cent;/¢/g;
		s/&#0*163;/£/g;     s/&#x0*A3;/£/g;     s/&pound;/£/g;
		s/&#0*164;/¤/g;     s/&#x0*A4;/¤/g;     s/&curren;/¤/g;
		s/&#0*165;/¥/g;     s/&#x0*A5;/¥/g;     s/&yen;/¥/g;
		s/&#0*166;/¦/g;     s/&#x0*A6;/¦/g;     s/&brvbar;/¦/g;
		s/&#0*167;/§/g;     s/&#x0*A7;/§/g;     s/&sect;/§/g;
		s/&#0*168;/¨/g;     s/&#x0*A8;/¨/g;     s/&uml;/¨/g;
		s/&#0*169;/©/g;     s/&#x0*A9;/©/g;     s/&copy;/©/g;
		s/&#0*170;/ª/g;     s/&#x0*AA;/ª/g;     s/&ordf;/ª/g;
		s/&#0*171;/«/g;     s/&#x0*AB;/«/g;     s/&laquo;/«/g;
		s/&#0*172;/¬/g;     s/&#x0*AC;/¬/g;     s/&not;/¬/g;
		s/&#0*173;/­/g;      s/&#x0*AD;/­/g;      s/&shy;/­/g;
		s/&#0*174;/®/g;     s/&#x0*AE;/®/g;     s/&reg;/®/g;
		s/&#0*175;/¯/g;     s/&#x0*AF;/¯/g;     s/&macr;/¯/g;
		s/&#0*176;/°/g;     s/&#x0*B0;/°/g;     s/&deg;/°/g;
		s/&#0*177;/±/g;     s/&#x0*B1;/±/g;     s/&plusmn;/±/g;
		s/&#0*178;/²/g;     s/&#x0*B2;/²/g;     s/&sup2;/²/g;
		s/&#0*179;/³/g;     s/&#x0*B3;/³/g;     s/&sup3;/³/g;
		s/&#0*180;/´/g;     s/&#x0*B4;/´/g;     s/&acute;/´/g;
		s/&#0*181;/µ/g;     s/&#x0*B5;/µ/g;     s/&micro;/µ/g;
		s/&#0*182;/¶/g;     s/&#x0*B6;/¶/g;     s/&para;/¶/g;
		s/&#0*183;/·/g;     s/&#x0*B7;/·/g;     s/&middot;/·/g;
		s/&#0*184;/¸/g;     s/&#x0*B8;/¸/g;     s/&cedil;/¸/g;
		s/&#0*185;/¹/g;     s/&#x0*B9;/¹/g;     s/&sup1;/¹/g;
		s/&#0*186;/º/g;     s/&#x0*BA;/º/g;     s/&ordm;/º/g;
		s/&#0*187;/»/g;     s/&#x0*BB;/»/g;     s/&raquo;/»/g;
		s/&#0*188;/¼/g;     s/&#x0*BC;/¼/g;     s/&frac14;/¼/g;
		s/&#0*189;/½/g;     s/&#x0*BD;/½/g;     s/&frac12;/½/g;
		s/&#0*190;/¾/g;     s/&#x0*BE;/¾/g;     s/&frac34;/¾/g;
		s/&#0*191;/¿/g;     s/&#x0*BF;/¿/g;     s/&iquest;/¿/g;
		s/&#0*192;/À/g;     s/&#x0*C0;/À/g;     s/&Agrave;/À/g;
		s/&#0*193;/Á/g;     s/&#x0*C1;/Á/g;     s/&Aacute;/Á/g;
		s/&#0*194;/Â/g;     s/&#x0*C2;/Â/g;     s/&Acirc;/Â/g;
		s/&#0*195;/Ã/g;     s/&#x0*C3;/Ã/g;     s/&Atilde;/Ã/g;
		s/&#0*196;/Ä/g;     s/&#x0*C4;/Ä/g;     s/&Auml;/Ä/g;
		s/&#0*197;/Å/g;     s/&#x0*C5;/Å/g;     s/&Aring;/Å/g;
		s/&#0*198;/Æ/g;     s/&#x0*C6;/Æ/g;     s/&AElig;/Æ/g;
		s/&#0*199;/Ç/g;     s/&#x0*C7;/Ç/g;     s/&Ccedil;/Ç/g;
		s/&#0*200;/È/g;     s/&#x0*C8;/È/g;     s/&Egrave;/È/g;
		s/&#0*201;/É/g;     s/&#x0*C9;/É/g;     s/&Eacute;/É/g;
		s/&#0*202;/Ê/g;     s/&#x0*CA;/Ê/g;     s/&Ecirc;/Ê/g;
		s/&#0*203;/Ë/g;     s/&#x0*CB;/Ë/g;     s/&Euml;/Ë/g;
		s/&#0*204;/Ì/g;     s/&#x0*CC;/Ì/g;     s/&Igrave;/Ì/g;
		s/&#0*205;/Í/g;     s/&#x0*CD;/Í/g;     s/&Iacute;/Í/g;
		s/&#0*206;/Î/g;     s/&#x0*CE;/Î/g;     s/&Icirc;/Î/g;
		s/&#0*207;/Ï/g;     s/&#x0*CF;/Ï/g;     s/&Iuml;/Ï/g;
		s/&#0*208;/Ð/g;     s/&#x0*D0;/Ð/g;     s/&ETH;/Ð/g;
		s/&#0*209;/Ñ/g;     s/&#x0*D1;/Ñ/g;     s/&Ntilde;/Ñ/g;
		s/&#0*210;/Ò/g;     s/&#x0*D2;/Ò/g;     s/&Ograve;/Ò/g;
		s/&#0*211;/Ó/g;     s/&#x0*D3;/Ó/g;     s/&Oacute;/Ó/g;
		s/&#0*212;/Ô/g;     s/&#x0*D4;/Ô/g;     s/&Ocirc;/Ô/g;
		s/&#0*213;/Õ/g;     s/&#x0*D5;/Õ/g;     s/&Otilde;/Õ/g;
		s/&#0*214;/Ö/g;     s/&#x0*D6;/Ö/g;     s/&Ouml;/Ö/g;
		s/&#0*215;/×/g;     s/&#x0*D7;/×/g;     s/&times;/×/g;
		s/&#0*216;/Ø/g;     s/&#x0*D8;/Ø/g;     s/&Oslash;/Ø/g;
		s/&#0*217;/Ù/g;     s/&#x0*D9;/Ù/g;     s/&Ugrave;/Ù/g;
		s/&#0*218;/Ú/g;     s/&#x0*DA;/Ú/g;     s/&Uacute;/Ú/g;
		s/&#0*219;/Û/g;     s/&#x0*DB;/Û/g;     s/&Ucirc;/Û/g;
		s/&#0*220;/Ü/g;     s/&#x0*DC;/Ü/g;     s/&Uuml;/Ü/g;
		s/&#0*221;/Ý/g;     s/&#x0*DD;/Ý/g;     s/&Yacute;/Ý/g;
		s/&#0*222;/Þ/g;     s/&#x0*DE;/Þ/g;     s/&THORN;/Þ/g;
		s/&#0*223;/ß/g;     s/&#x0*DF;/ß/g;     s/&szlig;/ß/g;
		s/&#0*224;/à/g;     s/&#x0*E0;/à/g;     s/&agrave;/à/g;
		s/&#0*225;/á/g;     s/&#x0*E1;/á/g;     s/&aacute;/á/g;
		s/&#0*226;/â/g;     s/&#x0*E2;/â/g;     s/&acirc;/â/g;
		s/&#0*227;/ã/g;     s/&#x0*E3;/ã/g;     s/&atilde;/ã/g;
		s/&#0*228;/ä/g;     s/&#x0*E4;/ä/g;     s/&auml;/ä/g;
		s/&#0*229;/å/g;     s/&#x0*E5;/å/g;     s/&aring;/å/g;
		s/&#0*230;/æ/g;     s/&#x0*E6;/æ/g;     s/&aelig;/æ/g;
		s/&#0*231;/ç/g;     s/&#x0*E7;/ç/g;     s/&ccedil;/ç/g;
		s/&#0*232;/è/g;     s/&#x0*E8;/è/g;     s/&egrave;/è/g;
		s/&#0*233;/é/g;     s/&#x0*E9;/é/g;     s/&eacute;/é/g;
		s/&#0*234;/ê/g;     s/&#x0*EA;/ê/g;     s/&ecirc;/ê/g;
		s/&#0*235;/ë/g;     s/&#x0*EB;/ë/g;     s/&euml;/ë/g;
		s/&#0*236;/ì/g;     s/&#x0*EC;/ì/g;     s/&igrave;/ì/g;
		s/&#0*237;/í/g;     s/&#x0*ED;/í/g;     s/&iacute;/í/g;
		s/&#0*238;/î/g;     s/&#x0*EE;/î/g;     s/&icirc;/î/g;
		s/&#0*239;/ï/g;     s/&#x0*EF;/ï/g;     s/&iuml;/ï/g;
		s/&#0*240;/ð/g;     s/&#x0*F0;/ð/g;     s/&eth;/ð/g;
		s/&#0*241;/ñ/g;     s/&#x0*F1;/ñ/g;     s/&ntilde;/ñ/g;
		s/&#0*242;/ò/g;     s/&#x0*F2;/ò/g;     s/&ograve;/ò/g;
		s/&#0*243;/ó/g;     s/&#x0*F3;/ó/g;     s/&oacute;/ó/g;
		s/&#0*244;/ô/g;     s/&#x0*F4;/ô/g;     s/&ocirc;/ô/g;
		s/&#0*245;/õ/g;     s/&#x0*F5;/õ/g;     s/&otilde;/õ/g;
		s/&#0*246;/ö/g;     s/&#x0*F6;/ö/g;     s/&ouml;/ö/g;
		s/&#0*247;/÷/g;     s/&#x0*F7;/÷/g;     s/&divide;/÷/g;
		s/&#0*248;/ø/g;     s/&#x0*F8;/ø/g;     s/&oslash;/ø/g;
		s/&#0*249;/ù/g;     s/&#x0*F9;/ù/g;     s/&ugrave;/ù/g;
		s/&#0*250;/ú/g;     s/&#x0*FA;/ú/g;     s/&uacute;/ú/g;
		s/&#0*251;/û/g;     s/&#x0*FB;/û/g;     s/&ucirc;/û/g;
		s/&#0*252;/ü/g;     s/&#x0*FC;/ü/g;     s/&uuml;/ü/g;
		s/&#0*253;/ý/g;     s/&#x0*FD;/ý/g;     s/&yacute;/ý/g;
		s/&#0*254;/þ/g;     s/&#x0*FE;/þ/g;     s/&thorn;/þ/g;
		s/&#0*255;/ÿ/g;     s/&#x0*FF;/ÿ/g;     s/&yuml;/ÿ/g;
		s/&#0*338;/Œ/g;     s/&#x0*152;/Œ/g;    s/&OElig;/Œ/g;
		s/&#0*339;/œ/g;     s/&#x0*153;/œ/g;    s/&oelig;/œ/g;
		s/&#0*352;/Š/g;     s/&#x0*160;/Š/g;    s/&Scaron;/Š/g;
		s/&#0*353;/š/g;     s/&#x0*161;/š/g;    s/&scaron;/š/g;
		s/&#0*376;/Ÿ/g;     s/&#x0*178;/Ÿ/g;    s/&Yuml;/Ÿ/g;
		s/&#0*402;/ƒ/g;     s/&#x0*192;/ƒ/g;    s/&fnof;/ƒ/g;
		s/&#0*710;/ˆ/g;     s/&#x0*2C6;/ˆ/g;    s/&circ;/ˆ/g;
		s/&#0*732;/˜/g;     s/&#x0*2DC;/˜/g;    s/&tilde;/˜/g;
		s/&#0*913;/Α/g;     s/&#x0*391;/Α/g;    s/&Alpha;/Α/g;
		s/&#0*914;/Β/g;     s/&#x0*392;/Β/g;    s/&Beta;/Β/g;
		s/&#0*915;/Γ/g;     s/&#x0*393;/Γ/g;    s/&Gamma;/Γ/g;
		s/&#0*916;/Δ/g;     s/&#x0*394;/Δ/g;    s/&Delta;/Δ/g;
		s/&#0*917;/Ε/g;     s/&#x0*395;/Ε/g;    s/&Epsilon;/Ε/g;
		s/&#0*918;/Ζ/g;     s/&#x0*396;/Ζ/g;    s/&Zeta;/Ζ/g;
		s/&#0*919;/Η/g;     s/&#x0*397;/Η/g;    s/&Eta;/Η/g;
		s/&#0*920;/Θ/g;     s/&#x0*398;/Θ/g;    s/&Theta;/Θ/g;
		s/&#0*921;/Ι/g;     s/&#x0*399;/Ι/g;    s/&Iota;/Ι/g;
		s/&#0*922;/Κ/g;     s/&#x0*39A;/Κ/g;    s/&Kappa;/Κ/g;
		s/&#0*923;/Λ/g;     s/&#x0*39B;/Λ/g;    s/&Lambda;/Λ/g;
		s/&#0*924;/Μ/g;     s/&#x0*39C;/Μ/g;    s/&Mu;/Μ/g;
		s/&#0*925;/Ν/g;     s/&#x0*39D;/Ν/g;    s/&Nu;/Ν/g;
		s/&#0*926;/Ξ/g;     s/&#x0*39E;/Ξ/g;    s/&Xi;/Ξ/g;
		s/&#0*927;/Ο/g;     s/&#x0*39F;/Ο/g;    s/&Omicron;/Ο/g;
		s/&#0*928;/Π/g;     s/&#x0*3A0;/Π/g;    s/&Pi;/Π/g;
		s/&#0*929;/Ρ/g;     s/&#x0*3A1;/Ρ/g;    s/&Rho;/Ρ/g;
		s/&#0*931;/Σ/g;     s/&#x0*3A3;/Σ/g;    s/&Sigma;/Σ/g;
		s/&#0*932;/Τ/g;     s/&#x0*3A4;/Τ/g;    s/&Tau;/Τ/g;
		s/&#0*933;/Υ/g;     s/&#x0*3A5;/Υ/g;    s/&Upsilon;/Υ/g;
		s/&#0*934;/Φ/g;     s/&#x0*3A6;/Φ/g;    s/&Phi;/Φ/g;
		s/&#0*935;/Χ/g;     s/&#x0*3A7;/Χ/g;    s/&Chi;/Χ/g;
		s/&#0*936;/Ψ/g;     s/&#x0*3A8;/Ψ/g;    s/&Psi;/Ψ/g;
		s/&#0*937;/Ω/g;     s/&#x0*3A9;/Ω/g;    s/&Omega;/Ω/g;
		s/&#0*945;/α/g;     s/&#x0*3B1;/α/g;    s/&alpha;/α/g;
		s/&#0*946;/β/g;     s/&#x0*3B2;/β/g;    s/&beta;/β/g;
		s/&#0*947;/γ/g;     s/&#x0*3B3;/γ/g;    s/&gamma;/γ/g;
		s/&#0*948;/δ/g;     s/&#x0*3B4;/δ/g;    s/&delta;/δ/g;
		s/&#0*949;/ε/g;     s/&#x0*3B5;/ε/g;    s/&epsilon;/ε/g;
		s/&#0*950;/ζ/g;     s/&#x0*3B6;/ζ/g;    s/&zeta;/ζ/g;
		s/&#0*951;/η/g;     s/&#x0*3B7;/η/g;    s/&eta;/η/g;
		s/&#0*952;/θ/g;     s/&#x0*3B8;/θ/g;    s/&theta;/θ/g;
		s/&#0*953;/ι/g;     s/&#x0*3B9;/ι/g;    s/&iota;/ι/g;
		s/&#0*954;/κ/g;     s/&#x0*3BA;/κ/g;    s/&kappa;/κ/g;
		s/&#0*955;/λ/g;     s/&#x0*3BB;/λ/g;    s/&lambda;/λ/g;
		s/&#0*956;/μ/g;     s/&#x0*3BC;/μ/g;    s/&mu;/μ/g;
		s/&#0*957;/ν/g;     s/&#x0*3BD;/ν/g;    s/&nu;/ν/g;
		s/&#0*958;/ξ/g;     s/&#x0*3BE;/ξ/g;    s/&xi;/ξ/g;
		s/&#0*959;/ο/g;     s/&#x0*3BF;/ο/g;    s/&omicron;/ο/g;
		s/&#0*960;/π/g;     s/&#x0*3C0;/π/g;    s/&pi;/π/g;
		s/&#0*961;/ρ/g;     s/&#x0*3C1;/ρ/g;    s/&rho;/ρ/g;
		s/&#0*962;/ς/g;     s/&#x0*3C2;/ς/g;    s/&sigmaf;/ς/g;
		s/&#0*963;/σ/g;     s/&#x0*3C3;/σ/g;    s/&sigma;/σ/g;
		s/&#0*964;/τ/g;     s/&#x0*3C4;/τ/g;    s/&tau;/τ/g;
		s/&#0*965;/υ/g;     s/&#x0*3C5;/υ/g;    s/&upsilon;/υ/g;
		s/&#0*966;/φ/g;     s/&#x0*3C6;/φ/g;    s/&phi;/φ/g;
		s/&#0*967;/χ/g;     s/&#x0*3C7;/χ/g;    s/&chi;/χ/g;
		s/&#0*968;/ψ/g;     s/&#x0*3C8;/ψ/g;    s/&psi;/ψ/g;
		s/&#0*969;/ω/g;     s/&#x0*3C9;/ω/g;    s/&omega;/ω/g;
		s/&#0*977;/ϑ/g;     s/&#x0*3D1;/ϑ/g;    s/&thetasym;/ϑ/g;
		s/&#0*978;/ϒ/g;     s/&#x0*3D2;/ϒ/g;    s/&upsih;/ϒ/g;
		s/&#0*982;/ϖ/g;     s/&#x0*3D6;/ϖ/g;    s/&piv;/ϖ/g;
		s/&#0*8194;/ /g;    s/&#x0*2002;/ /g;   s/&ensp;/ /g;
		s/&#0*8195;/ /g;    s/&#x0*2003;/ /g;   s/&emsp;/ /g;
		s/&#0*8201;/ /g;    s/&#x0*2009;/ /g;   s/&thinsp;/ /g;
		s/&#0*8204;/‌/g;     s/&#x0*200C;/‌/g;    s/&zwnj;/‌/g;
		s/&#0*8205;/‍/g;     s/&#x0*200D;/‍/g;    s/&zwj;/‍/g;
		s/&#0*8206;/‎/g;     s/&#x0*200E;/‎/g;    s/&lrm;/‎/g;
		s/&#0*8207;/‏/g;     s/&#x0*200F;/‏/g;    s/&rlm;/‏/g;
		s/&#0*8211;/–/g;    s/&#x0*2013;/–/g;   s/&ndash;/–/g;
		s/&#0*8212;/—/g;    s/&#x0*2014;/—/g;   s/&mdash;/—/g;
		s/&#0*8216;/‘/g;    s/&#x0*2018;/‘/g;   s/&lsquo;/‘/g;
		s/&#0*8217;/’/g;    s/&#x0*2019;/’/g;   s/&rsquo;/’/g;
		s/&#0*8218;/‚/g;    s/&#x0*201A;/‚/g;   s/&sbquo;/‚/g;
		s/&#0*8220;/“/g;    s/&#x0*201C;/“/g;   s/&ldquo;/“/g;
		s/&#0*8221;/”/g;    s/&#x0*201D;/”/g;   s/&rdquo;/”/g;
		s/&#0*8222;/„/g;    s/&#x0*201E;/„/g;   s/&bdquo;/„/g;
		s/&#0*8224;/†/g;    s/&#x0*2020;/†/g;   s/&dagger;/†/g;
		s/&#0*8225;/‡/g;    s/&#x0*2021;/‡/g;   s/&Dagger;/‡/g;
		s/&#0*8226;/•/g;    s/&#x0*2022;/•/g;   s/&bull;/•/g;
		s/&#0*8230;/…/g;    s/&#x0*2026;/…/g;   s/&hellip;/…/g;
		s/&#0*8240;/‰/g;    s/&#x0*2030;/‰/g;   s/&permil;/‰/g;
		s/&#0*8242;/′/g;    s/&#x0*2032;/′/g;   s/&prime;/′/g;
		s/&#0*8243;/″/g;    s/&#x0*2033;/″/g;   s/&Prime;/″/g;
		s/&#0*8249;/‹/g;    s/&#x0*2039;/‹/g;   s/&lsaquo;/‹/g;
		s/&#0*8250;/›/g;    s/&#x0*203A;/›/g;   s/&rsaquo;/›/g;
		s/&#0*8254;/‾/g;    s/&#x0*203E;/‾/g;   s/&oline;/‾/g;
		s/&#0*8260;/⁄/g;    s/&#x0*2044;/⁄/g;   s/&frasl;/⁄/g;
		s/&#0*8364;/€/g;    s/&#x0*20AC;/€/g;   s/&euro;/€/g;
		s/&#0*8465;/ℑ/g;    s/&#x0*2111;/ℑ/g;   s/&image;/ℑ/g;
		s/&#0*8472;/℘/g;    s/&#x0*2118;/℘/g;   s/&weierp;/℘/g;
		s/&#0*8476;/ℜ/g;    s/&#x0*211C;/ℜ/g;   s/&real;/ℜ/g;
		s/&#0*8482;/™/g;    s/&#x0*2122;/™/g;   s/&trade;/™/g;
		s/&#0*8501;/ℵ/g;    s/&#x0*2135;/ℵ/g;   s/&alefsym;/ℵ/g;
		s/&#0*8592;/←/g;    s/&#x0*2190;/←/g;   s/&larr;/←/g;
		s/&#0*8593;/↑/g;    s/&#x0*2191;/↑/g;   s/&uarr;/↑/g;
		s/&#0*8594;/→/g;    s/&#x0*2192;/→/g;   s/&rarr;/→/g;
		s/&#0*8595;/↓/g;    s/&#x0*2193;/↓/g;   s/&darr;/↓/g;
		s/&#0*8596;/↔/g;    s/&#x0*2194;/↔/g;   s/&harr;/↔/g;
		s/&#0*8629;/↵/g;    s/&#x0*21B5;/↵/g;   s/&crarr;/↵/g;
		s/&#0*8656;/⇐/g;    s/&#x0*21D0;/⇐/g;   s/&lArr;/⇐/g;
		s/&#0*8657;/⇑/g;    s/&#x0*21D1;/⇑/g;   s/&uArr;/⇑/g;
		s/&#0*8658;/⇒/g;    s/&#x0*21D2;/⇒/g;   s/&rArr;/⇒/g;
		s/&#0*8659;/⇓/g;    s/&#x0*21D3;/⇓/g;   s/&dArr;/⇓/g;
		s/&#0*8660;/⇔/g;    s/&#x0*21D4;/⇔/g;   s/&hArr;/⇔/g;
		s/&#0*8704;/∀/g;    s/&#x0*2200;/∀/g;   s/&forall;/∀/g;
		s/&#0*8706;/∂/g;    s/&#x0*2202;/∂/g;   s/&part;/∂/g;
		s/&#0*8707;/∃/g;    s/&#x0*2203;/∃/g;   s/&exist;/∃/g;
		s/&#0*8709;/∅/g;    s/&#x0*2205;/∅/g;   s/&empty;/∅/g;
		s/&#0*8711;/∇/g;    s/&#x0*2207;/∇/g;   s/&nabla;/∇/g;
		s/&#0*8712;/∈/g;    s/&#x0*2208;/∈/g;   s/&isin;/∈/g;
		s/&#0*8713;/∉/g;    s/&#x0*2209;/∉/g;   s/&notin;/∉/g;
		s/&#0*8715;/∋/g;    s/&#x0*220B;/∋/g;   s/&ni;/∋/g;
		s/&#0*8719;/∏/g;    s/&#x0*220F;/∏/g;   s/&prod;/∏/g;
		s/&#0*8721;/∑/g;    s/&#x0*2211;/∑/g;   s/&sum;/∑/g;
		s/&#0*8722;/−/g;    s/&#x0*2212;/−/g;   s/&minus;/−/g;
		s/&#0*8727;/∗/g;    s/&#x0*2217;/∗/g;   s/&lowast;/∗/g;
		s/&#0*8730;/√/g;    s/&#x0*221A;/√/g;   s/&radic;/√/g;
		s/&#0*8733;/∝/g;    s/&#x0*221D;/∝/g;   s/&prop;/∝/g;
		s/&#0*8734;/∞/g;    s/&#x0*221E;/∞/g;   s/&infin;/∞/g;
		s/&#0*8736;/∠/g;    s/&#x0*2220;/∠/g;   s/&ang;/∠/g;
		s/&#0*8743;/∧/g;    s/&#x0*2227;/∧/g;   s/&and;/∧/g;
		s/&#0*8744;/∨/g;    s/&#x0*2228;/∨/g;   s/&or;/∨/g;
		s/&#0*8745;/∩/g;    s/&#x0*2229;/∩/g;   s/&cap;/∩/g;
		s/&#0*8746;/∪/g;    s/&#x0*222A;/∪/g;   s/&cup;/∪/g;
		s/&#0*8747;/∫/g;    s/&#x0*222B;/∫/g;   s/&int;/∫/g;
		s/&#0*8756;/∴/g;    s/&#x0*2234;/∴/g;   s/&there4;/∴/g;
		s/&#0*8764;/∼/g;    s/&#x0*223C;/∼/g;   s/&sim;/∼/g;
		s/&#0*8773;/≅/g;    s/&#x0*2245;/≅/g;   s/&cong;/≅/g;
		s/&#0*8776;/≈/g;    s/&#x0*2248;/≈/g;   s/&asymp;/≈/g;
		s/&#0*8800;/≠/g;    s/&#x0*2260;/≠/g;   s/&ne;/≠/g;
		s/&#0*8801;/≡/g;    s/&#x0*2261;/≡/g;   s/&equiv;/≡/g;
		s/&#0*8804;/≤/g;    s/&#x0*2264;/≤/g;   s/&le;/≤/g;
		s/&#0*8805;/≥/g;    s/&#x0*2265;/≥/g;   s/&ge;/≥/g;
		s/&#0*8834;/⊂/g;    s/&#x0*2282;/⊂/g;   s/&sub;/⊂/g;
		s/&#0*8835;/⊃/g;    s/&#x0*2283;/⊃/g;   s/&sup;/⊃/g;
		s/&#0*8836;/⊄/g;    s/&#x0*2284;/⊄/g;   s/&nsub;/⊄/g;
		s/&#0*8838;/⊆/g;    s/&#x0*2286;/⊆/g;   s/&sube;/⊆/g;
		s/&#0*8839;/⊇/g;    s/&#x0*2287;/⊇/g;   s/&supe;/⊇/g;
		s/&#0*8853;/⊕/g;    s/&#x0*2295;/⊕/g;   s/&oplus;/⊕/g;
		s/&#0*8855;/⊗/g;    s/&#x0*2297;/⊗/g;   s/&otimes;/⊗/g;
		s/&#0*8869;/⊥/g;    s/&#x0*22A5;/⊥/g;   s/&perp;/⊥/g;
		s/&#0*8901;/⋅/g;    s/&#x0*22C5;/⋅/g;   s/&sdot;/⋅/g;
		s/&#0*8968;/⌈/g;    s/&#x0*2308;/⌈/g;   s/&lceil;/⌈/g;
		s/&#0*8969;/⌉/g;    s/&#x0*2309;/⌉/g;   s/&rceil;/⌉/g;
		s/&#0*8970;/⌊/g;    s/&#x0*230A;/⌊/g;   s/&lfloor;/⌊/g;
		s/&#0*8971;/⌋/g;    s/&#x0*230B;/⌋/g;   s/&rfloor;/⌋/g;
		s/&#0*10216;/〈/g;   s/&#x0*27E8;/〈/g;   s/&lang;/〈/g;
		s/&#0*10217;/〉/g;   s/&#x0*27E9;/〉/g;   s/&rang;/〉/g;
		s/&#0*9674;/◊/g;    s/&#x0*25CA;/◊/g;   s/&loz;/◊/g;
		s/&#0*9824;/♠/g;    s/&#x0*2660;/♠/g;   s/&spades;/♠/g;
		s/&#0*9827;/♣/g;    s/&#x0*2663;/♣/g;   s/&clubs;/♣/g;
		s/&#0*9829;/♥/g;    s/&#x0*2665;/♥/g;   s/&hearts;/♥/g;
		s/&#0*9830;/♦/g;    s/&#x0*2666;/♦/g;   s/&diams;/♦/g;
	"

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			--html)
				filtro="$filtro$html"
				shift
			;;
			--xml)
				filtro="$filtro$xml"
				shift
			;;
			--) shift; break ;;
			*) break ;;
		esac
	done

	# Faz a conversão
	# Arquivos via STDIN ou argumentos
	zztool file_stdin -- "$@" | sed "$filtro"
}

# ----------------------------------------------------------------------------
# zzunicode2ascii
# Converte caracteres Unicode (UTF-8) para seus similares ASCII (128).
#
# Uso: zzunicode2ascii [arquivo(s)]
# Ex.: zzunicode2ascii arquivo.txt
#      cat arquivo.txt | zzunicode2ascii
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-06
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzunicode2ascii ()
{
	zzzz -h unicode2ascii "$1" && return

	# Tentei manter o sentido do caractere original na tradução.
	# Outros preferi manter o original a fazer um tradução dúbia.
	# Aceito sugestões de melhorias! @oreio

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" | sed "

	# Nota: Mesma tabela de dados da zzunescape.

	# s \" \" g
	# s & & g
	# s ' ' g
	# s < < g
	# s > > g
	# s/ / /g
	s ¡ i g
	s ¢ c g
	# s £ £ g
	# s ¤ ¤ g
	s ¥ Y g
	s ¦ | g
	# s § § g
	s ¨ \" g
	s © (C) g
	s ª a g
	s « << g
	# s ¬ ¬ g
	s ­ - g
	s ® (R) g
	s ¯ - g
	# s ° ° g
	s ± +- g
	s ² 2 g
	s ³ 3 g
	s ´ ' g
	s µ u g
	# s ¶ ¶ g
	s · . g
	s ¸ , g
	s ¹ 1 g
	s º o g
	s » >> g
	s ¼ 1/4 g
	s ½ 1/2 g
	s ¾ 3/4 g
	# s ¿ ¿ g
	s À A g
	s Á A g
	s Â A g
	s Ã A g
	s Ä A g
	s Å A g
	s Æ AE g
	s Ç C g
	s È E g
	s É E g
	s Ê E g
	s Ë E g
	s Ì I g
	s Í I g
	s Î I g
	s Ï I g
	s Ð D g
	s Ñ N g
	s Ò O g
	s Ó O g
	s Ô O g
	s Õ O g
	s Ö O g
	s × x g
	s Ø O g
	s Ù U g
	s Ú U g
	s Û U g
	s Ü U g
	s Ý Y g
	s Þ P g
	s ß B g
	s à a g
	s á a g
	s â a g
	s ã a g
	s ä a g
	s å a g
	s æ ae g
	s ç c g
	s è e g
	s é e g
	s ê e g
	s ë e g
	s ì i g
	s í i g
	s î i g
	s ï i g
	s ð d g
	s ñ n g
	s ò o g
	s ó o g
	s ô o g
	s õ o g
	s ö o g
	s ÷ / g
	s ø o g
	s ù u g
	s ú u g
	s û u g
	s ü u g
	s ý y g
	s þ p g
	s ÿ y g
	s Œ OE g
	s œ oe g
	s Š S g
	s š s g
	s Ÿ Y g
	s ƒ f g
	s ˆ ^ g
	s ˜ ~ g
	s Α A g
	s Β B g
	# s Γ Γ g
	# s Δ Δ g
	s Ε E g
	s Ζ Z g
	s Η H g
	# s Θ Θ g
	s Ι I g
	s Κ K g
	# s Λ Λ g
	s Μ M g
	s Ν N g
	# s Ξ Ξ g
	s Ο O g
	# s Π Π g
	s Ρ P g
	# s Σ Σ g
	s Τ T g
	s Υ Y g
	# s Φ Φ g
	s Χ X g
	# s Ψ Ψ g
	# s Ω Ω g
	s α a g
	s β b g
	# s γ γ g
	# s δ δ g
	s ε e g
	# s ζ ζ g
	s η n g
	# s θ θ g
	# s ι ι g
	s κ k g
	# s λ λ g
	s μ u g
	s ν v g
	# s ξ ξ g
	s ο o g
	# s π π g
	s ρ p g
	s ς s g
	# s σ σ g
	s τ t g
	s υ u g
	# s φ φ g
	s χ x g
	# s ψ ψ g
	s ω w g
	# s ϑ ϑ g
	# s ϒ ϒ g
	# s ϖ ϖ g
	s/ / /g
	s/ / /g
	s/ / /g
	s/‌/ /g
	s/‍/ /g
	s/‎/ /g
	s/‏/ /g
	s – - g
	s — - g
	s ‘ ' g
	s ’ ' g
	s ‚ , g
	s “ \" g
	s ” \" g
	s „ \" g
	# s † † g
	# s ‡ ‡ g
	s • * g
	s … ... g
	# s ‰ ‰ g
	s ′ ' g
	s ″ \" g
	s ‹ < g
	s › > g
	s ‾ - g
	s ⁄ / g
	s € E g
	# s ℑ ℑ g
	# s ℘ ℘ g
	s ℜ R g
	s ™ TM g
	# s ℵ ℵ g
	s ← <- g
	# s ↑ ↑ g
	s → -> g
	# s ↓ ↓ g
	s ↔ <-> g
	# s ↵ ↵ g
	s ⇐ <= g
	# s ⇑ ⇑ g
	s ⇒ => g
	# s ⇓ ⇓ g
	s ⇔ <=> g
	# s ∀ ∀ g
	# s ∂ ∂ g
	# s ∃ ∃ g
	# s ∅ ∅ g
	# s ∇ ∇ g
	# s ∈ ∈ g
	# s ∉ ∉ g
	# s ∋ ∋ g
	# s ∏ ∏ g
	# s ∑ ∑ g
	s − - g
	s ∗ * g
	# s √ √ g
	# s ∝ ∝ g
	# s ∞ ∞ g
	# s ∠ ∠ g
	s ∧ ^ g
	s ∨ v g
	# s ∩ ∩ g
	# s ∪ ∪ g
	# s ∫ ∫ g
	# s ∴ ∴ g
	s ∼ ~ g
	s ≅ ~= g
	s ≈ ~~ g
	# s ≠ ≠ g
	# s ≡ ≡ g
	s ≤ <= g
	s ≥ >= g
	# s ⊂ ⊂ g
	# s ⊃ ⊃ g
	# s ⊄ ⊄ g
	# s ⊆ ⊆ g
	# s ⊇ ⊇ g
	s ⊕ (+) g
	s ⊗ (x) g
	# s ⊥ ⊥ g
	s ⋅ . g
	# s ⌈ ⌈ g
	# s ⌉ ⌉ g
	# s ⌊ ⌊ g
	# s ⌋ ⌋ g
	s ⟨ < g
	s ⟩ > g
	s ◊ <> g
	# s ♠ ♠ g
	# s ♣ ♣ g
	s ♥ <3 g
	s ♦ <> g
	"
}

# ----------------------------------------------------------------------------
# zzuniq
# Retira as linhas repetidas, consecutivas ou não.
# Obs.: Não altera a ordem original das linhas, diferente do sort|uniq.
#
# Uso: zzuniq [arquivo(s)]
# Ex.: zzuniq /etc/inittab
#      cat /etc/inittab | zzuniq
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2002-06-22
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzuniq ()
{
	zzzz -h uniq "$1" && return

	# Nota: as linhas do arquivo são numeradas para guardar a ordem original

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" |
		cat -n  |      # Numera as linhas do arquivo
		sort -k2 -u |  # Ordena e remove duplos, ignorando a numeração
		sort -n |      # Restaura a ordem original
		cut -f 2-      # Remove a numeração

	# Versão SED, mais lenta para arquivos grandes, mas só precisa do SED
	# PATT: LINHA ATUAL \n LINHA-1 \n LINHA-2 \n ... \n LINHA #1 \n
	# sed "G ; /^\([^\n]*\)\n\([^\n]*\n\)*\1\n/d ; h ; s/\n.*//" $1

	# Versãp AWK, dica retirada do twitter de @augustohp
	# zztool file_stdin "$@" | awk '!line[$0]++'
}

# ----------------------------------------------------------------------------
# zzunix2dos
# Converte arquivos texto no formato Unix (LF) para o Windows/DOS (CR+LF).
# Uso: zzunix2dos arquivo(s)
# Ex.: zzunix2dos frases.txt
#      cat arquivo.txt | zzunix2dos
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzunix2dos ()
{
	zzzz -h unix2dos "$1" && return

	local arquivo tmp
	local control_m=$(printf '\r')  # ^M, CR, \r

	# Sem argumentos, lê/grava em STDIN/STDOUT
	if test $# -eq 0
	then
		sed "s/$control_m*$/$control_m/"

		# Facinho, terminou já
		return
	fi

	# Definindo arquivo temporário quando há argumentos.
	tmp=$(zztool mktemp unix2dos)

	# Usuário passou uma lista de arquivos
	# Os arquivos serão sobrescritos, todo cuidado é pouco
	for arquivo
	do
		# O arquivo existe?
		zztool -e arquivo_legivel "$arquivo" || continue

		# Adiciona um único CR no final de cada linha
		cp "$arquivo" "$tmp" &&
		sed "s/$control_m*$/$control_m/" "$tmp" > "$arquivo"

		# Segurança
		if test $? -ne 0
		then
			zztool erro "Ops, algum erro ocorreu em $arquivo"
			zztool erro "Seu arquivo original está guardado em $tmp"
			return 1
		fi

		echo "Convertido $arquivo"
	done

	# Remove o arquivo temporário
	rm -f "$tmp"
}

# ----------------------------------------------------------------------------
# zzurldecode
# http://en.wikipedia.org/wiki/Percent-encoding
# Decodifica textos no formato %HH, geralmente usados em URLs (%40 → @).
#
# Uso: zzurldecode [texto]
# Ex.: zzurldecode '%73%65%67%72%65%64%6F'
#      echo 'http%3A%2F%2F' | zzurldecode
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2014-03-14
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzurldecode ()
{
	zzzz -h urldecode "$1" && return

	# Converte os %HH para \xHH, que são expandidos pelo printf %b
	printf '%b\n' $(
		zztool multi_stdin "$@" |
		sed 's/%\([0-9A-Fa-f]\{2\}\)/\\x\1/g'
	)

}

# ----------------------------------------------------------------------------
# zzurlencode
# http://en.wikipedia.org/wiki/Percent-encoding
# Codifica o texto como %HH, para ser usado numa URL (a/b → a%2Fb).
# Obs.: Por padrão, letras, números e _.~- não são codificados (RFC 3986)
#
# Opções:
#   -t, --todos  Codifica todos os caracteres, sem exceção
#   -n STRING    Informa caracteres adicionais que não devem ser codificados
#
# Uso: zzurlencode [texto]
# Ex.: zzurlencode http://www            # http%3A%2F%2Fwww
#      zzurlencode -n : http://www       # http:%2F%2Fwww
#      zzurlencode -t http://www         # %68%74%74%70%3A%2F%2F%77%77%77
#      zzurlencode -t -n w/ http://www   # %68%74%74%70%3A//www
#
# Autor: Guilherme Magalhães Gall <gmgall (a) gmail com>
# Desde: 2013-03-19
# Versão: 4
# Licença: GPL
# Requisitos: zzmaiusculas
# ----------------------------------------------------------------------------
zzurlencode ()
{
	zzzz -h urlencode "$1" && return

	local resultado undo

	# RFC 3986, unreserved - Estes nunca devem ser convertidos (exceto se --all)
	local nao_converter='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.~-'

	while test -n "$1"
	do
		case "$1" in
			-t | --todos | -a | --all)
				nao_converter=''
				shift
			;;
			-n)
				if test -z "$2"
				then
					zztool erro 'Faltou informar o valor da opção -n'
					return 1
				fi

				nao_converter="$nao_converter$2"
				shift
				shift
			;;
			--) shift; break;;
			-*) zztool erro "Opção inválida: $1"; return 1;;
			*) break;;
		esac
	done

	# Codifica todos os caracteres, sem exceção
	# foo → %66%6F%6F
	resultado=$(
		if test -n "$1"
		then printf %s "$*"  # texto via argumentos
		else cat -           # texto via STDIN
		fi |
		# Usa o comando od para descobrir o valor hexa de cada caractere.
		# É portável e suporta UTF-8, decompondo cada caractere em seus bytes.
		od -v -A n -t x1 |
		# Converte os números hexa para o formato %HH, sem espaços
		tr -d ' \n\t' |
		sed 's/../%&/g' |
		zzmaiusculas
	)

	# Há caracteres protegidos, que não devem ser convertidos?
	if test -n "$nao_converter"
	then
		# Desfaz a conversão de alguns caracteres (usando magia)
		#
		# Um sed é aplicado no resultado original "desconvertendo"
		# alguns dos %HH de volta para caracteres normais. Mas como
		# fazer isso somente para os caracteres de $nao_converter?
		#
		# É usada a própria zzurlencode para codificar a lista dos
		# protegidos, e um sed formata esse resultado, compondo outro
		# script sed, que será aplicado no resultado original trocando
		# os %HH por \xHH.
		#
		# $ zzurlencode -t -- "ab" | sed 's/%\(..\)/s,&,\\\\x\1,g; /g'
		# s,%61,\\x61,g; s,%62,\\x62,g;
		#
		# Essa string manipulada será mostrada pelo printf %b, que
		# expandirá os \xHH tornando-os caracteres normais novamente.
		# Ufa! :)
		#
		undo=$(zzurlencode -t -- "$nao_converter" | sed 's/%\(..\)/s,&,\\\\x\1,g; /g')
		printf '%b\n' $(echo "$resultado" | sed "$undo")
	else
		printf '%s\n' "$resultado"
	fi
}

# ----------------------------------------------------------------------------
# zzutf8
# Converte o texto para UTF-8, se necessário.
# Obs.: Caso o texto já seja UTF-8, não há conversão.
#
# Uso: zzutf8 [arquivo]
# Ex.: zzutf8 /etc/passwd
#      zzutf8 index-iso.html
#      echo Bênção | zzutf8        # Bênção
#      printf '\341\n' | zzutf8    # á
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2015-03-21
# Versão: 2
# Licença: GPL
# Requisitos: zzencoding
# ----------------------------------------------------------------------------
zzutf8 ()
{
	zzzz -h utf8 "$1" && return

	local encoding
	local tmp=$(zztool mktemp utf8)

	# Guarda o texto de entrada
	zztool file_stdin "$@" > "$tmp"

	# Qual a sua codificação atual?
	encoding=$(zzencoding "$tmp")

	case "$encoding" in

		# Encoding já compatível com UTF-8, nada a fazer
		utf-8 | us-ascii)
			cat "$tmp"
		;;

		# Arquivo vazio ou encoding desconhecido, não mexe
		'' | unknown* | binary )
			cat "$tmp"
		;;

		# Encoding detectado, converte pra UTF-8
		*)
			iconv -f "$encoding" -t utf-8 "$tmp"
		;;
	esac

	rm -f "$tmp"
}

# ----------------------------------------------------------------------------
# zzvdp
# https://vidadeprogramador.com.br
# Mostra o texto das últimas tirinhas de Vida de Programador.
# Sem opção mostra a tirinha mais recente.
# Se a opção for um número, mostra a tirinha que ocupa essa ordem
# Se a opção for 0, mostra todas mais recentes
#
# Uso: zzvdp [número]
# Ex.: zzvdp    # Mostra a tirinha mais recente
#      zzvdp 5  # Mostra a quinta tirinha mais recente
#      zzvdp 0  # Mostra todas as tirinhas mais recentes
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-25
# Versão: 7
# Licença: GPL
# Requisitos: zzunescape zzxml
# ----------------------------------------------------------------------------
zzvdp ()
{
	zzzz -h vdp "$1" && return

	local url="https://vidadeprogramador.com.br"
	local sep='------------------------------------------------------------------------------'
	local ord=1

	zztool testa_numero "$1" && ord=$1

	zztool source "$url" |
	awk '
		/^ *<div.*data-title="/{titulo=$0}
		/<div class="transcription">/ {print titulo}
		/<div class="transcription">/,/<\/div>/
	' |
	sed '
		/^ *<div.*data-title="/{s/.*data-title="//;s/".*//;}
		/"transcription"/s/.*//
		s/<\/div>/----/
		' |
	zzunescape --html |
	zzxml --untag |
	if test $ord -eq 0
	then
		sed "/----/{s//$sep/;}"
	else
		awk -v ord=$ord '
			/----/{i++;next}
			{ if (i==ord-1) print; if (i==ord) {exit} }
		'
	fi

}

# ----------------------------------------------------------------------------
# zzvira
# Vira um texto, de trás pra frente (rev) ou de ponta-cabeça.
# Ideia original de: http://www.revfad.com/flip.html (valeu @andersonrizada)
#
# Uso: zzvira [-X|-E] texto
# Ex.: zzvira Inverte tudo             # odut etrevnI
#      zzvira -X De pernas pro ar      # ɹɐ oɹd sɐuɹǝd ǝp
#      zzvira -E De pernas pro ar      # pǝ dǝɹuɐs dɹo ɐɹ
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2010-05-24
# Versão: 3
# Licença: GPL
# Requisitos: zzsemacento zzminusculas
# ----------------------------------------------------------------------------
zzvira ()
{
	zzzz -h vira "$1" && return

	local rasteira

	if test "$1" = '-X'
	then
		rasteira=1
		shift
	elif test "$1" = '-E'
	then
		rasteira=2
		shift
	fi

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |

	# Vira o texto de trás pra frente (rev)
	if test -z "$rasteira" || test "$rasteira" -ne 2
	then
		sed '
		/\n/!G
		s/\(.\)\(.*\n\)/&\2\1/
		//D
		s/.//'
	else
		cat -
	fi |

	if test -n "$rasteira"
	then
		zzsemacento |
		zzminusculas |
			sed 'y@abcdefghijklmnopqrstuvwxyz._!?(){}<>@ɐqɔpǝɟƃɥıɾʞlɯuodbɹsʇnʌʍxʎz˙‾¡¿)(}{><@' |
			sed "y/'/,/" |
			sed 's/\[/X/g ; s/]/[/g ; s/X/]/g'
	else
		cat -
	fi
}

# ----------------------------------------------------------------------------
# zzwc
# Contabiliza total de bytes, caracteres, palavras ou linhas de um arquivo.
# Ou exibe tamanho da maior linha em bytes, caracteres ou palavras.
# Opcionalmente exibe as maiores linhas, desse arquivo.
# Também aceita receber dados pela entrada padrão (stdin).
# É uma emulação do comando wc, que não contabiliza '\r' e '\n'.
#
# Opções:
#   -c  total de bytes
#   -m  total de caracteres
#   -l  total de linhas
#   -w  total de palavras
#   -C, -L, -W  maior linha em bytes, caracteres ou palavras respectivamente
#   -p Exibe a maior linha em bytes, caracteres ou palavras,
#      usado junto com as opções -C, -L e -W.
#
#    Se as opções forem omitidas adota -l -w -c por padrão.
#
# Uso: zzwc [-c|-C|-m|-l|-L|-w|-W] [-p] arquivo
# Ex.: echo "12345"       | zzwc -c     # 5
#      printf "abcde"     | zzwc -m     # 5
#      printf "abc\123"   | zzwc -l     # 2
#      printf "xz\n789\n" | zzwc -L     # 3
#      printf "wk\n456"   | zzwc -M -p  # 456
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2016-03-10
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzwc ()
{
	zzzz -h wc "$1" && return

	local tb tc tl tw mb mc mw p conteudo saida linha

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-c) tb=0  ;;
			-m) tc=0  ;;
			-l) tl=0  ;;
			-w) tw=0  ;;
			-p) p=1   ;;
			-C) mb=0  ;;
			-L) mc=0  ;;
			-W) mw=0  ;;
			--) shift; break ;;
			-*) zztool -e uso wc; return 1 ;;
			* ) break ;;
		esac
		shift
	done

	if test -z "${tb}${tc}${tl}${tw}${mb}${mc}${mw}"
	then
		tb=0; tl=0; tw=0
	fi

	conteudo=$(zztool file_stdin -- "$@" | sed '${ s/$/ /; }')

	# Linhas
	if test -n "$tl"
	then
		tl=$(echo "$conteudo" | zztool num_linhas)
		saida="$tl"
	fi

	# Palavras
	if test -n "$tw"
	then
		tw=$(echo "$conteudo" | wc -w | tr -d -c '[0-9]')
		test -n "$saida" && saida="$saida|$tw" || saida="$tw"
	fi

	# Caracteres
	if test -n "$tc"
	then
		tc=$(echo "$conteudo" | sed 's/././g' | tr -d '\r\n' | wc -c)
		tc=$((tc-1))
		test -n "$saida" && saida="$saida|$tc" || saida="$tc"
	fi

	# Bytes
	if test -n "$tb"
	then
		tb=$(echo "$conteudo" | tr -d '\r\n' | wc -c)
		tb=$((tb-1))
		test -n "$saida" && saida="$saida|$tb" || saida="$tb"
	fi

	# Saida do resultado dos linhas, palavras, caracteres e/ou bytes.
	if test -n "$saida"
	then
		echo "$saida" | tr '|' '\t'
	fi

	# Exibição do tamanho ou da(s) linha(s) mais longa(s)
	if test -n "${mb}${mc}${mw}"
	then
		maior=$(
		echo "$conteudo" |
		while read linha
		do
			printf "%s" "$linha" |
			if test -n "$mb"
			then
				wc -c
			elif test -n "$mc"
			then
				sed 's/[^[:cntrl:]]/./g' | awk 'BEGIN {FS=""} { print NF }'
			elif test -n "$mw"
			then
				wc -w
			fi
		done |
		awk -v end_sed="$p" '
			{ linha[NR]=$1 ; maior=(maior<$1?$1:maior) }
			END {
				if (length(end_sed)) {
					for (i=1;i<=NR;i++) {
						if (linha[i]==maior) printf i "p;"
					}
				}
				else { print maior }
			}'
		)

		if test -n "$p"
		then
			echo "$conteudo" | sed -n "$maior"
		else
			echo "$maior"
		fi
	fi
}

# ----------------------------------------------------------------------------
# zzwikipedia
# http://www.wikipedia.org
# Procura na Wikipédia, a enciclopédia livre.
# Obs.: Se nenhum idioma for especificado, é utilizado o português.
#
# Idiomas: de (alemão)    eo (esperanto)  es (espanhol)  fr (francês)
#          it (italiano)  ja (japonês)    la (latin)     pt (português)
#
# Uso: zzwikipedia [-idioma] palavra(s)
# Ex.: zzwikipedia sed
#      zzwikipedia Linus Torvalds
#      zzwikipedia -pt Linus Torvalds
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2004-10-28
# Versão: 4
# Licença: GPL
# ----------------------------------------------------------------------------
zzwikipedia ()
{
	zzzz -h wikipedia "$1" && return

	local url
	local idioma='pt'

	# Se o idioma foi informado, guarda-o, retirando o hífen
	if test "${1#-}" != "$1"
	then
		idioma="${1#-}"
		shift
	fi

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso wikipedia; return 1; }

	# Faz a consulta e filtra o resultado, paginando
	url="http://$idioma.wikipedia.org/wiki/"
	zztool dump "$url$(echo "$*" | sed 's/  */_/g')" |
		sed '
			# Limpeza do conteúdo
			/^Views$/,$ d
			/^Vistas$/,$ d
			/^Ferramentas pessoais$/,$ d
			/^.\{0,1\}Ligações externas/,$ d
			/^  *#Wikipedia (/d
			/^  *#alternat/d
			/Click here for more information.$/d
			/^  *#Editar Wikip.dia /d
			/^  *From Wikipedia,/d
			/^  *Origem: Wikipédia,/d
			/^  *Jump to: /d
			/^  *Ir para: /d
			/^  *Link: /d
			/^  *This article does not cite any references/d
			/  *Este artigo ou se(c)ção não cita fontes confiáveis/d
			/  *Esta página ou secção não cita fontes confiáveis/d
			/^  *Please help improve this article/d
			/^  *Por favor, melhore este artigo/d
			/^  *—*Encontre fontes: /d
			/\.svg$/d
			/^  *Categorias* ocultas*:/,$d
			/^  *Hidden categories:/,$d
			/^  *\[IMG\]$/d
			/^  *Ampliar$/d
			/^  *Wikipedia does not have an article with this exact name./q
			s/\[edit\]//; s/\[edit[^]]*\]//
			s/\[editar\]//; s/\[editar[^]]*\]//

			# Guarda URL da página e mostra no final, após Categorias
			# Também adiciona linha em branco antes de Categorias
			/^   Obtid[ao] de "/ { H; d; }
			/^   Retrieved from "/ { H; d; }
			/^   Categor[a-z]*: / { G; x; s/.*//; G; }' |
		cat -s
}

# ----------------------------------------------------------------------------
# zzxml
# Parser simples (e limitado) para arquivos XML/HTML.
# Obs.: Este parser é usado pelas Funções ZZ, não serve como parser genérico.
# Obs.: Necessário pois não há ferramenta portável para lidar com XML no Unix.
#
# Opções: --tidy        Reorganiza o código, deixando uma tag por linha
#         --tag NOME    Extrai (grep) todas as tags NOME e seu conteúdo
#         --notag NOME  Exclui (grep -v) todas as tags NOME e seu conteúdo
#         --list        Lista sem repetição as tags existentes no arquivo
#         --indent      Promove a indentação das tags
#         --untag       Remove todas as tags, deixando apenas texto
#         --untag=NOME  Remove apenas a tag NOME, deixando o seu conteúdo
#         --unescape    Converte as entidades &foo; para caracteres normais
# Obs.: --notag tem precedência sobre --tag e --untag.
#       --untag tem precedência sobre --tag.
#
# Uso: zzxml <opções> [arquivo(s)]
# Ex.: zzxml --tidy arquivo.xml
#      zzxml --untag --unescape arq.xml                   # xml -> txt
#      zzxml --untag=item arq.xml                         # Apaga tags "item"
#      zzxml --tag title --untag --unescape arq.xml       # títulos
#      cat arq.xml | zzxml --tag item | zzxml --tag title # aninhado
#      zzxml --tag item --tag title arq.xml               # tags múltiplas
#      zzxml --notag link arq.xml                         # Sem tag e conteúdo
#      zzxml --indent arq.xml                             # tags indentadas
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-03
# Versão: 15
# Licença: GPL
# Requisitos: zzjuntalinhas zzuniq zzunescape
# ----------------------------------------------------------------------------
zzxml ()
{
	zzzz -h xml "$1" && return

	local tag notag semtag ntag sed_notag sep cache_tag cache_notag
	local tidy=0
	local untag=0
	local unescape=0
	local indent=0

	sep=$(echo '&thinsp;' | zzunescape --html)

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			--tidy    ) shift; tidy=1;;
			--untag   ) shift; untag=1;;
			--unescape) shift; unescape=1;;
			--notag   )
				tidy=1
				shift
				notag="$notag $1"
				shift
			;;
			--tag     )
				tidy=1
				shift
				tag="$tag $1"
				shift
			;;
			--untag=* )
				semtag="$semtag ${1#*=}"
				shift
			;;
			--indent  )
				shift
				tidy=1
				indent=1
			;;
			--list    )
				shift
				zztool file_stdin "$@" |
				# Eliminando comentários ( não deveria existir em arquivos xml! :-/ )
				zzjuntalinhas -i "<!--" -f "-->" | sed '/<!--/d' |
				# Filtrando apenas as tags válidas
				sed '
					# Eliminando texto entre tags
					s/\(>\)[^><]*\(<\)/\1\2/g
					# Eliminando texto antes das tags
					s/^[^<]*//g
					# Eliminado texto depois das tags
					s/[^>]*$//g
					# Eliminando as tags de fechamento
					s|</[^>]*>||g
					# Colocando uma tag por linha
					s/</\
&/g
					# Eliminando < e >
					s/<[?]*//g
					s|[/]*>||g
					# Eliminando os atributos das tags
					s/ .*//g' |
				sed '/^$/d' |
				zzuniq
				return
			;;
			--        ) shift; break;;
			--*       ) zztool erro "Opção inválida $1"; return 1;;
			*         ) break;;
		esac
	done

	cache_tag=$(zztool mktemp xml.tag)
	cache_notag=$(zztool mktemp xml.notag)

	# Montando script awk para excluir tags
	if test -n "$notag"
	then
		echo 'BEGIN { notag=0 } {' > $cache_notag
		for ntag in $notag
		do
			echo '
				if ($0 ~ /<'$ntag' [^>]*[^\/>]>/) { notag++ }
				if ($0 ~ /<\/'$ntag'  >/) { notag--; if (notag==0) { next } }
			' >> $cache_notag
			sed_notag="$sed_notag /<${ntag} [^>]*\/>/d;"
		done
		echo 'if (notag==0) { nolinha[NR] = $0 } }' >> $cache_notag
	fi

	# Montando script awk para selecionar tags
	if test -n "$tag"
	then
		echo 'BEGIN {' > $cache_tag
		for ntag in $tag
		do
			echo 'tag['$ntag']=0' >> $cache_tag
		done
		echo '} {' >> $cache_tag
		for ntag in $tag
		do
			echo '
				if ($0 ~ /^<'$ntag' [^>]*\/>$/) { linha[NR] = $0 }
				if ($0 ~ /^<'$ntag' [^>]*[^\/>]>/) { tag['$ntag']++ }
				if (tag['$ntag']>=1) { linha[NR] = $0 }
				if ($0 ~ /^<\/'$ntag'  >/) { tag['$ntag']-- }
			' >> $cache_tag
		done
		echo '}' >> $cache_tag
	fi

	# Montando script sed para apagar determinadas tags
	if test -n "$semtag"
	then
		for ntag in $semtag
		do
			sed_notag="$sed_notag s|<[/]\{0,1\}${ntag} [^>]*>||g;"
		done
	fi

	# Caso indent=1 mantém uma tag por linha para possibilitar indentação.
	if test -n "$tag"
	then
		if test $tidy -eq 0
		then
			echo 'END { for (lin=1;lin<=NR;lin++) { if (lin in linha) printf "%s", linha[lin] } print ""}' >> $cache_tag
		else
			echo 'END { for (lin=1;lin<=NR;lin++) { if (lin in linha) print linha[lin] } }' >> $cache_tag
		fi
	fi
	if test -n "$notag"
	then
		if test $tidy -eq 0
		then
			echo 'END { for (lin=1;lin<=NR;lin++) { if (lin in nolinha) printf "%s", nolinha[lin] } print ""}' >> $cache_notag
		else
			echo 'END { for (lin=1;lin<=NR;lin++) { if (lin in nolinha) print nolinha[lin] } }' >> $cache_notag
		fi
	fi

	# O código seguinte é um grande filtro, com diversos blocos de comando
	# IF interligados via pipe (logo após o FI). Cada IF pode aplicar um
	# filtro (sed, grep, etc) ao código XML, ou passá-lo adiante inalterado
	# (cat -). Por esta natureza, a ordem dos filtros importa. O tidy deve
	# ser sempre o primeiro, para organizar. O unescape deve ser o último,
	# pois ele pode fazer surgir < e > no código.
	#
	# Essa estrutura toda de IFs interligados é bizarra e não tenho certeza
	# se funciona em versões bem antigas do bash, mas acredito que sim. Fiz
	# assim para evitar ficar lendo e gravando arquivos temporários para
	# cada filtro. Como está, é tudo um grande fluxo de texto, que não usa
	# arquivos externos. Mas se esta função precisar crescer, todo este
	# esquema precisará ser revisto.

	# Arquivos via STDIN ou argumentos
	zztool file_stdin -- "$@" |

	zzjuntalinhas -i "<!--" -f "-->" |

		# --tidy
		if test $tidy -eq 1
		then
			# Deixa somente uma tag por linha.
			# Tags multilinha ficam em somente uma linha.
			# Várias tags em uma mesma linha ficam multilinha.
			# Isso facilita a extração de dados com grep, sed, awk...
			#
			#   ANTES                    DEPOIS
			#   --------------------------------------------------------
			#   <a                       <a href="foo.html" title="Foo">
			#   href="foo.html"
			#   title="Foo">
			#   --------------------------------------------------------
			#   <p>Foo <b>bar</b></p>    <p>
			#                            Foo
			#                            <b>
			#                            bar
			#                            </b>
			#                            </p>

			# Usando um tipo especial de espaço com zzjuntalinhas
			zzjuntalinhas -d "$sep" |
			sed '
				:ini
				/>'$sep'*</ {
					s//>\
</
					t ini
				}

				# quebra linha na abertura da tag
				s/</\
</g
				# quebra linha após fechamento da tag
				s/ *>/  >\
/g' |
			# Rejunta o conteúdo do <![CDATA[...]]>, que pode ter tags
			zzjuntalinhas -i '^<!\[CDATA\[' -f ']]>$' -d '' |

			# Remove linhas em branco (as que adicionamos)
			sed "/^[[:blank:]$sep]*$/d"
		else
			# Espaço antes do fechamento da tag (Recurso usado no script para tag não ambígua)
			sed 's/ *>/  >/g'
		fi |

		# Corrigindo espaço de fechamento de tag única  (Recurso usado no script para tag não ambígua)
		sed 's|/  *>|  />|g' |

		# --notag
		# É sempre usada em conjunto com --tidy (automaticamente)
		if test -n "$notag"
		then
			awk -f "$cache_notag"
		else
			cat -
		fi |

		# --notag ou --notag <tag> ou untag=<tag>
		if test -n "$sed_notag"
		then
			sed "$sed_notag"
		else
			cat -
		fi |

		# --tag
		# É sempre usada em conjunto com --tidy (automaticamente)
		if test -n "$tag"
		then
			awk -f "$cache_tag"
		else
			cat -
		fi |

		# Eliminando o espaço adicional colocado antes do fechamento das tags.
		sed 's| *>|>|g;s|  */>| />|g' |

		# Removendo ou trocando um tipo de espaço especial usado com zzjuntalinhas
		sed "
			s/\([[:blank:]]\)$sep/\1/g
			s/$sep\([[:blank:]]\)/\1/g
			s/^$sep//
			s/$sep$//
			s/$sep/ /g
		" |

		# --indent
		# Indentando conforme as tags que aparecem, mantendo alinhamento.
		# É sempre usada em conjunto com --tidy (automaticamente)
		if test $indent -eq 1
		then
			sed '/^<[^/]/s@/@|@g' | sed 's@|>$@/>@g' |
			awk '
				# Para quantificar as tabulações em cada nível.
				function tabs(t,  saida, i) {
					saida = ""
					if (t>0) {
						for (i=1;i<=t;i++) {
							saida="	" saida
						}
					}
					return saida
				}
				BEGIN {
					# Definições iniciais
					ntab = 0
					tag_ini_regex = "^<[^?!/<>]*>$"
					tag_fim_regex = "^</[^/<>]*>$"
				}
				$0 ~ tag_fim_regex { ntab-- }
				{
					# Suprimindo espaços iniciais da linha
					sub(/^[\t ]+/,"")

					# Saindo com a linha formatada
					print tabs(ntab) $0
				}
				$0 ~ tag_ini_regex { ntab++ }
			' |
			sed '/^[[:blank:]]*<[^/]/s@|@/@g'
		else
			cat -
		fi |

		# --untag
		if test $untag -eq 1
		then
			sed '
				# Caso especial: <![CDATA[Foo bar.]]>
				s/<!\[CDATA\[//g
				s/]]>//g

				# Evita linhas vazias inúteis na saída
				/^[[:blank:]]*<[^>]*>[[:blank:]]*$/ d

				# Remove as tags inline
				s/<[^>]*>//g'
		else
			cat -
		fi |

		# --unescape
		if test $unescape -eq 1
		then
			zzunescape --xml
		else
			cat -
		fi

	# Limpeza
	rm -f "$cache_tag" "$cache_notag"
}


ZZDIR=

##############################################################################
#
#                             Texto de ajuda
#                             --------------
#
#

# Função temporária para extrair o texto de ajuda do cabeçalho das funções
# Passe o arquivo com as funções como parâmetro
_extrai_ajuda() {
	# Extrai somente os cabeçalhos, já removendo o # do início
	sed -n '/^# -----* *$/, /^# -----* *$/ s/^# \{0,1\}//p' "$1" |
		# Agora remove trechos que não podem aparecer na ajuda
		sed '
			# Apaga a metadata (Autor, Desde, Versao, etc)
			/^Autor:/, /^------/ d

			# Apaga a linha em branco apos Ex.:
			/^Ex\.:/, /^------/ {
				/^ *$/d
			}'
}

# Limpa conteúdo do arquivo de ajuda
> "$ZZAJUDA"

# Salva o texto de ajuda das funções deste arquivo
test -r "$ZZPATH" && _extrai_ajuda "$ZZPATH" >> "$ZZAJUDA"


##############################################################################
#
#                    Carregamento das funções do $ZZDIR
#                    ----------------------------------
#
# O carregamento é feito em dois passos para ficar mais robusto:
# 1. Obtenção da lista completa de funções, ativadas e desativadas.
# 2. Carga de cada função ativada, salvando o texto de ajuda.
#
# Com a opção --tudo-em-um, o passo 2 é alterado para mostrar o conteúdo
# da função em vez de carregá-la.
#

### Passo 1

# Limpa arquivos temporários que guardam as listagens
> "$ZZTMP.on"
> "$ZZTMP.off"

# A pasta das funções existe?
if test -n "$ZZDIR" -a -d "$ZZDIR"
then
	# Melhora a lista off: um por linha, sem prefixo zz
	zz_off=$(echo "$ZZOFF" | zztool list2lines | sed 's/^zz//')

	# Primeiro salva a lista de funções disponíveis
	for zz_arquivo in "${ZZDIR%/}"/zz*
	do
		# Só ativa funções que podem ser lidas
		if test -r "$zz_arquivo"
		then
			zz_nome="${zz_arquivo##*/}"  # remove path
			zz_nome="${zz_nome%.sh}"     # remove extensão

			# O usuário desativou esta função?
			echo "$zz_off" | grep "^${zz_nome#zz}$" >/dev/null ||
				# Tudo certo, essa vai ser carregada
				echo "$zz_nome"
		fi
	done >> "$ZZTMP.on"

	# Lista das funções desativadas (OFF = Todas - ON)
	(
	cd "$ZZDIR" &&
	ls -1 zz* |
		sed 's/\.sh$//' |
		grep -v -f "$ZZTMP.on"
	) >> "$ZZTMP.off"
fi

# echo ON ; cat "$ZZTMP.on"  | zztool lines2list
# echo OFF; cat "$ZZTMP.off" | zztool lines2list
# exit

### Passo 2

# Vamos juntar todas as funções em um único arquivo?
if test "$1" = '--tudo-em-um'
then
	# Verifica se a pasta das funções existe
	if test -z "$ZZDIR" -o ! -d "$ZZDIR"
	then
		(
		echo "Ops! Não encontrei as funções na pasta '$ZZDIR'."
		echo 'Informe a localização correta na variável $ZZDIR.'
		echo
		echo 'Exemplo: export ZZDIR="$HOME/zz"'
		) >&2
		exit 1
		# Posso usar exit porque a chamada é pelo executável, e não source
	fi

	# Primeira metade deste arquivo, até #@
	sed '/^#@$/q' "$ZZPATH"

	# Mostra cada função (ativa), inserindo seu nome na linha 2 do cabeçalho
	while read zz_nome
	do
		zz_arquivo="${ZZDIR%/}"/$zz_nome.sh

		# Suporte legado aos arquivos sem a extensão .sh
		test -r "$zz_arquivo" || zz_arquivo="${zz_arquivo%.sh}"

		sed 1q "$zz_arquivo"
		echo "# $zz_nome"
		sed 1d "$zz_arquivo"

		# Linha em branco separadora
		# Também garante quebra se faltar \n na última linha da função
		echo
	done < "$ZZTMP.on"

	# Desliga suporte ao diretório de funções
	echo
	echo 'ZZDIR='

	# Segunda metade deste arquivo, depois de #@
	sed '1,/^#@$/d' "$ZZPATH"

	# Tá feito, simbora.
	exit 0
fi

# Carregamento das funções ativas, salvando texto de ajuda
while read zz_nome
do
	zz_arquivo="${ZZDIR%/}"/$zz_nome.sh

	# Se o arquivo não existir, tenta encontrá-lo sem a extensao .sh.
	# No futuro este suporte às funções sem extensão pode ser removido.
	if ! test -r "$zz_arquivo"
	then
		if test -r "${zz_arquivo%.sh}"
		then
			# Não achei zzfoo.sh, mas achei o zzfoo
			# Vamos usá-lo então.
			zz_arquivo="${zz_arquivo%.sh}"
		else
			# Não achei zzfoo.sh nem zzfoo
			# Cancelaremos o carregamento desta função.
			continue
		fi
	fi

	# Inclui a função na shell atual
	. "$zz_arquivo"

	# Extrai o texto de ajuda
	_extrai_ajuda "$zz_arquivo" |
		# Insere o nome da função na segunda linha
		sed "2 { h; s/.*/$zz_nome/; G; }"

done < "$ZZTMP.on" >> "$ZZAJUDA"

# Separador final do arquivo, com exatamente 77 hífens (7x11)
echo '-------' | sed 's/.*/&&&&&&&&&&&/' >> "$ZZAJUDA"


# Modo --tudo-em-um
# Todas as funções já foram carregadas por estarem dentro deste arquivo.
# Agora faremos o desligamento "manual" das funções ZZOFF.
#
if test -z "$ZZDIR" -a -n "$ZZOFF"
then

	# Lista de funções a desligar: uma por linha, com prefixo zz, exceto ZZBASE
	zz_off=$(
		echo "$ZZOFF" |
		zztool list2lines |
		sed 's/^zz// ; s/^/zz/' |
		egrep -v "$(echo "$ZZBASE" | sed 's/ /|/g')"
	)

	# Desliga todas em uma só linha (note que não usei aspas)
	unset zz_off

	# Agora apaga os textos da ajuda, montando um script em sed e aplicando
	# Veja issue 5 para mais detalhes:
	# https://github.com/funcoeszz/funcoeszz/issues/5
	zz_sed=$(echo "$zz_off" | sed 's@.*@/^&$/,/^----*$/d;@')  # /^zzfoo$/,/^----*$/d
	cp "$ZZAJUDA" "$ZZAJUDA.2" &&
	sed "$zz_sed" "$ZZAJUDA.2" > "$ZZAJUDA"
	rm "$ZZAJUDA.2"
fi


### Carregamento terminado, funções já estão disponíveis

# Limpa variáveis e funções temporárias
# Nota: prefixo zz_ para não conflitar com variáveis da shell atual
unset zz_arquivo
unset zz_nome
unset zz_off
unset zz_sed
unset -f _extrai_ajuda


##----------------------------------------------------------------------------
## Lidando com a chamada pelo executável

# Se há parâmetros, é porque o usuário está nos chamando pela
# linha de comando, e não pelo comando source.
if test -n "$1"
then

	case "$1" in

		# Mostra a tela de ajuda
		-h | --help)

			cat - <<-FIM

				Uso: funcoeszz <função> [<parâmetros>]

				Lista de funções:
				    funcoeszz zzzz
				    funcoeszz zzajuda --lista

				Ajuda:
				    funcoeszz zzajuda
				    funcoeszz zzcores -h
				    funcoeszz zzcalcula -h

				Instalação:
				    funcoeszz zzzz --bashrc
				    source ~/.bashrc
				    zz<TAB><TAB>

				Saiba mais:
				    http://funcoeszz.net

			FIM
		;;

		# Mostra a versão das funções
		-v | --version)
			echo "Funções ZZ v$ZZVERSAO"
		;;

		-*)
			echo "Opção inválida '$1' (tente --help)"
		;;

		# Chama a função informada em $1, caso ela exista
		*)
			zz_func="$1"

			# Garante que a zzzz possa ser chamada por zz somente
			test "$zz_func" = 'zz' && zz_func='zzzz'

			# O prefixo zz é opcional: zzdata e data funcionam
			zz_func="zz${zz_func#zz}"

			# A função existe?
			if type $zz_func >/dev/null 2>&1
			then
				shift
				$zz_func "$@"
			else
				echo "Função inexistente '$zz_func' (tente --help)"
			fi

			unset zz_func
		;;
	esac
fi
