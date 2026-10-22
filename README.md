# Hybrid Infrastructure Lab — Windows Server, AD e conectividade

Laboratório documentado para demonstrar um método repetível de verificação de saúde de infraestrutura Windows e investigação de conectividade em cenários híbridos. Inclui scripts PowerShell **somente de leitura**, checklist e uma arquitetura de referência.

> **Importante:** os scripts coletam informações do computador e da rede em que forem executados. Nenhum script configura DNS, altera firewall, reinicia serviços ou modifica o Active Directory.

## O que demonstra

- Verificações básicas de host, sistema operacional, armazenamento e serviços Windows.
- Verificação de conectividade TCP e resolução DNS para destinos informados pelo operador.
- Coleta opcional de informações de controladores de domínio, replicação e `dcdiag` quando as ferramentas AD/RSAT estiverem disponíveis.
- Registro dos resultados em CSV/JSON local, para documentação de troubleshooting.
- Separação clara entre sintomas, evidências, hipótese, validação e prevenção.

## Requisitos

- Windows Server ou Windows 10/11 com PowerShell 5.1+; PowerShell 7 também pode ser usado, conforme os módulos disponíveis.
- Para verificações de AD: RSAT/ActiveDirectory PowerShell module e ferramentas `repadmin`/`dcdiag` instaladas.
- Execute com uma conta que tenha apenas as permissões necessárias para leitura. Nem todas as verificações exigem administrador.

## Executar scripts

No PowerShell, dentro da pasta do projeto:

```powershell
# Saúde geral do host (somente leitura)
.\scripts\Get-WindowsInfraHealth.ps1

# DNS e conectividade TCP contra destinos definidos por você
.\scripts\Test-HybridConnectivity.ps1 -DnsNames @('contoso.com','www.microsoft.com') -Targets @('www.microsoft.com') -Ports @(443, 80)

# Verificações AD (execute em contexto com RSAT e permissões adequadas)
.\scripts\Test-ActiveDirectoryHealth.ps1
```

Para salvar relatórios, use `-OutputDirectory .\reports`. A pasta de relatórios é ignorada pelo Git porque saídas reais podem incluir nomes de host, domínios, endereços e outros metadados do ambiente.

Se a política de execução bloquear scripts, siga a política de segurança da sua organização. Não altere políticas corporativas sem autorização.

## Roteiro de validação sugerido

1. Registre o host e o contexto em que o teste está sendo executado.
2. Execute a verificação de saúde do host e anote as falhas.
3. Teste primeiro a resolução de nomes e depois portas TCP necessárias para o serviço.
4. Em ambientes AD, compare o estado dos serviços e os resultados de replicação.
5. Formule uma hipótese de causa com base nas evidências; não conclua apenas a partir de um ping.
6. Valide novamente após a mudança autorizada pelo responsável do ambiente.
7. Documente risco de recorrência, monitoramento e rollback.

## Arquitetura de referência

Veja [docs/architecture.md](docs/architecture.md) e o diagrama Mermaid. O ambiente on-premises e a VNet Azure são uma **arquitetura planejada para laboratório**, não uma conexão atualmente provisionada.

## Evidências para o portfólio

Depois de executar no seu próprio laboratório, adicione capturas de tela dos resultados com nomes, IPs públicos, domínios e dados confidenciais ocultados. Nunca publique relatórios brutos de empresa.

## Limitações

- O script de Active Directory precisa dos módulos/ferramentas Microsoft correspondentes.
- O estado da rede varia conforme VPN, DNS, firewall e permissões locais.
- Este repositório não configura nem provisiona uma VPN real com Azure.
- Não é uma ferramenta de monitoramento 24/7 nem substitui soluções de gestão corporativa.

## Licença

MIT — veja [LICENSE](LICENSE).
