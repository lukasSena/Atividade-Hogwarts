# Escola de Magia de Hogwarts: DDL, DML, TCL, DCL, views e triggers

**Disciplina:** Manipulação de Dados / Banco de Dados II (ADS242N01)  
**Professor:** Aguinaldo Neto  
**Trabalho:** individual  
**Prazo:** 17/11/2026

## Aluno

| Nome | Matrícula | Usuário do GitHub |
| Lukas Sena |2423995 | lukasSena |
|  |  |  |

## O cenário

A diretoria de Hogwarts cansou de controlar tudo em pergaminho. Você foi contratado para construir o banco que vai gerenciar as casas, os professores, as disciplinas, as notas dos alunos, os pontos da Taça das Casas e as compras no Beco Diagonal.

O enunciado completo, com todas as tabelas, os dados e as questões, está em [`docs/Atividade_Hogwarts.pdf`](docs/Atividade_Hogwarts.pdf).

![Diagrama entidade-relacionamento](docs/diagrama_er.png)

## Etapas

A atividade tem 48 questões numeradas e 27 desafios de consulta. Execute tudo **na ordem**: os resultados das consultas dependem das alterações, dos triggers e das transações das seções anteriores.

| Seção | Conteúdo | Questões |
| --- | --- | --- |
| 1 e 1.1 | DDL: criação do banco e das 10 tabelas; carga inicial (INSERT) | criação + carga |
| 2 | ALTER TABLE e UPDATE (CONCAT, LEAST, CASE, subconsulta com IN) | 1 a 12 |
| 3 | DELETE e testes de restrições (FK, CHECK, UNIQUE) | 13 a 19 |
| 4 | Triggers: Taça das Casas, validação de compra, baixa de estoque, situação automática, auditoria | 20 a 25 |
| 5 | TCL: COMMIT, ROLLBACK, SAVEPOINT, autocommit | 26 a 30 |
| 6 | Consultas: operadores especiais, JOINs, agregação com HAVING, subconsultas, UNION ALL | 6.1 a 6.27 |
| 7 | Views | 31 a 38 |
| 8 | DCL: usuários, GRANT, REVOKE e papéis (roles) | 39 a 48 |

Em cada seção, os blocos **Confira** do enunciado trazem valores para você saber se está no caminho certo antes de seguir.

Quando uma questão pede para explicar um erro ou responder uma pergunta, escreva a resposta como **comentário SQL** logo abaixo do comando, com o código e a mensagem do erro.

## Estrutura do repositório

```
docs/Atividade_Hogwarts.pdf   enunciado completo (não alterar)
docs/diagrama_er.png          diagrama entidade-relacionamento
sql/hogwarts.sql              seu script: todas as respostas aqui
```

## Dicas

- Use **MySQL 8** (MySQL Workbench).
- Se um UPDATE ou DELETE for bloqueado, execute antes `SET SQL_SAFE_UPDATES = 0;`.
- Para criar triggers no Workbench, use `DELIMITER $$` antes e `DELIMITER ;` depois.
- Se algo der errado no meio do caminho, o script deve poder ser rodado do zero: ele começa com `DROP DATABASE IF EXISTS hogwarts;`.
- Na seção 8, para testar um usuário, abra no Workbench uma nova conexão com o login dele.

## Como entregar

1. Logado no GitHub, clique em **Fork** (canto superior direito) e depois em **Create fork**. O fork é a sua cópia individual.
2. No fork, preencha a tabela **Aluno** no topo deste README: clique em `README.md`, depois no lápis ✏️, e em **Commit changes**.
3. Clone o fork (`git clone <link-do-seu-fork>`) e faça o trabalho em `sql/hogwarts.sql`, com **pelo menos 5 commits** ao longo das seções (por exemplo, um commit por seção concluída).
4. Antes de entregar, rode o script inteiro do zero e confira se ele executa sem erros, exceto nos comandos que a atividade pede para falhar. Esses devem ficar **comentados**, com a explicação do erro.
5. Para entregar, no fork clique em **Contribute → Open pull request**, preencha o modelo e clique em **Create pull request**. Cada novo `git push` atualiza o mesmo Pull Request até o prazo.

⚠️ Não edite o repositório do professor, só o seu fork.
