# Ultimate Cleaner

Utilitário em Batch para limpeza e manutenção do Windows, com interface em terminal, modos de execução, confirmação de segurança, geração de logs e relatório do espaço liberado.

> [!IMPORTANT]
> O arquivo principal e atualizado deste projeto é **`Ultimate Cleaner.bat`**.
>
> O diretório também contém outros arquivos `.bat` mais antigos, simples ou desatualizados, mantidos apenas como referência. Para utilizar a versão completa e atual, execute exclusivamente o **`Ultimate Cleaner.bat`**.

## Funcionalidades

O **Ultimate Cleaner** oferece três opções principais:

### Limpeza rápida

Executa a limpeza dos seguintes itens:

- Arquivos temporários do usuário atual
- Arquivos temporários do Windows
- Temporários dos perfis locais
- Cache de miniaturas e ícones
- Cache do DirectX Shader
- Relatórios de falhas de aplicativos
- Cache de Internet do Windows
- Cache do Google Chrome
- Cache do Microsoft Edge
- Cache de DNS
- Lixeira do Windows

### Limpeza completa

Executa tudo que está incluído na limpeza rápida e adiciona:

- Cache de downloads do Windows Update
- Cache do Delivery Optimization
- Limpeza de componentes antigos do Windows com DISM
- Controle de parada e reinicialização dos serviços necessários

### Análise de armazenamento

- Consulta o espaço disponível na unidade do sistema
- Abre as configurações de armazenamento do Windows
- Não remove nenhum arquivo

## Segurança

O script foi desenvolvido para evitar a remoção de arquivos pessoais.

O **Ultimate Cleaner** não exclui intencionalmente:

- Documentos
- Downloads
- Arquivos da Área de Trabalho
- Fotos, vídeos e outros arquivos pessoais
- Configurações dos programas
- Arquivos que estejam bloqueados ou em uso

Antes de iniciar uma limpeza, o script apresenta o modo selecionado e solicita confirmação.

> [!NOTE]
> É recomendável fechar o Google Chrome, o Microsoft Edge e outros programas antes da execução. Isso permite que mais arquivos de cache sejam removidos sem forçar o encerramento dos aplicativos.

## Requisitos

- Windows 10, Windows 11 ou Windows Server compatível com os comandos utilizados
- Windows PowerShell disponível
- Permissão de administrador

O próprio script solicita elevação de privilégio quando necessário.

## Como usar

1. Baixe ou clone este repositório.
2. Localize o arquivo **`Ultimate Cleaner.bat`**.
3. Execute o arquivo com duplo clique.
4. Autorize a execução como administrador.
5. Selecione uma das opções do menu:
   - `1` para limpeza rápida
   - `2` para limpeza completa
   - `3` para analisar o armazenamento
   - `4` para sair
6. Confirme a operação quando solicitado.

## Logs e relatórios

Após a execução, o script cria automaticamente as seguintes pastas no mesmo diretório do arquivo:

```text
Logs_LimpezaRelatorios_Limpeza```

Os logs registram as etapas executadas e possíveis erros. O relatório apresenta:

- Modo utilizado
- Espaço livre antes da limpeza
- Espaço livre depois da limpeza
- Total aproximado de espaço liberado
- Local do log detalhado

## Estrutura recomendada

```text
Ultimate-Cleaner├── Ultimate Cleaner.bat          # Versão principal e atualizada
├── README.md
├── Logs_Limpeza\                 # Criada automaticamente
├── Relatorios_Limpeza\           # Criada automaticamente
└── Outros arquivos .bat          # Versões antigas, simples ou desatualizadas
```

## Sobre os outros arquivos BAT

Este repositório pode conter outros scripts `.bat` relacionados à limpeza do Windows. Esses arquivos representam versões anteriores, testes ou alternativas mais simples.

Eles podem não incluir:

- Interface atualizada
- Modos de limpeza rápida e completa
- Confirmação de segurança
- Cálculo do espaço liberado
- Logs detalhados
- Relatório final
- Tratamento de serviços do Windows
- Retorno ao menu após a execução

Por esse motivo, o arquivo recomendado para uso é sempre:

```text
Ultimate Cleaner.bat
```

## Aviso

Embora o script tenha proteções para evitar a exclusão de arquivos pessoais, revise o código antes de utilizá-lo em ambientes corporativos, servidores ou máquinas críticas.

A execução é de responsabilidade do usuário. Mantenha backups atualizados antes de realizar qualquer rotina de manutenção no sistema.

## Contribuições

Sugestões, correções e melhorias podem ser enviadas por meio de issues ou pull requests.

Ao contribuir, mantenha como arquivo principal o nome **`Ultimate Cleaner.bat`** e deixe claro quando um arquivo alternativo for experimental, antigo ou simplificado.

## Licença

Defina a licença do projeto no arquivo `LICENSE` antes de distribuir ou reutilizar o código publicamente.
