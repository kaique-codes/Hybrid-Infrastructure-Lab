# Runbook de troubleshooting

## DNS: aplicação falha por nome, mas o IP parece responder

1. Confirme o nome informado pelo usuário e o FQDN esperado.
2. Execute `Resolve-DnsName <nome>` e compare com o servidor DNS configurado.
3. Confira sufixos de pesquisa e encaminhadores no servidor autorizado.
4. Teste a porta da aplicação separadamente; resposta DNS não confirma a saúde do serviço.
5. Registre horário, origem, nome consultado, resultado e próxima ação. Oculte metadados confidenciais antes de publicar.

## Falha de autenticação AD

1. Determine se o problema afeta um usuário, um host ou múltiplos sites.
2. Verifique resolução DNS dos controladores e sincronização de horário.
3. Consulte logs de segurança e serviços relacionados com permissões autorizadas.
4. Se houver mais de um DC, utilize `repadmin` e ferramentas de diagnóstico de domínio para avaliar replicação.
5. Altere políticas ou objetos somente após autorização, plano de rollback e validação.

## Serviço indisponível numa VM

1. Valide se o host resolve o nome e se a rota esperada existe.
2. Teste a porta TCP do serviço; não abra portas administrativas para toda a internet.
3. Confira firewall do host, NSG e rotas, quando aplicável.
4. Valide o serviço no destino e consulte eventos.
5. Refaça o teste a partir do mesmo ponto de origem e documente o resultado.

## Modelo de registro

- **Sintoma observado:**
- **Impacto / escopo:**
- **Evidências coletadas:**
- **Hipótese de causa:**
- **Ação autorizada:**
- **Validação após mudança:**
- **Risco de recorrência / prevenção:**
