-- =====================================================================
-- Atividade Prática: Escola de Magia de Hogwarts
-- Disciplina: Manipulação de Dados / Banco de Dados II (ADS242N01)
-- Professor: Aguinaldo Neto
--
-- Aluno:Lukas Sena Carvalho De Moura
-- Matrícula:2423995
--
-- Escreva cada resposta logo abaixo do comentário da questão.
-- Comandos que a atividade pede para FALHAR devem ficar comentados,
-- seguidos do código/mensagem de erro e da sua explicação.
-- =====================================================================

SET SQL_SAFE_UPDATES = 0;

-- =====================================================================
-- 1. PREPARAÇÃO DO AMBIENTE (DDL)
-- =====================================================================
DROP DATABASE IF EXISTS hogwarts;
CREATE DATABASE hogwarts;
USE hogwarts;

-- Tabela casa
CREATE TABLE casa (
    id_casa INT AUTO_INCREMENT PRIMARY KEY,
    nome_casa VARCHAR(30) NOT NULL UNIQUE,
    fundador VARCHAR(60),
    pontos INT DEFAULT 0
);

-- Tabela professor
CREATE TABLE professor (
    id_prof INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    salario DECIMAL(10,2),
    data_contratacao DATE,
    id_casa INT,
    CONSTRAINT chk_professor_salario CHECK (salario > 0),
    CONSTRAINT fk_professor_casa FOREIGN KEY (id_casa)
        REFERENCES casa(id_casa)
);

-- Tabela disciplina
CREATE TABLE disciplina (
    id_disc INT AUTO_INCREMENT PRIMARY KEY,
    nome_disc VARCHAR(60) NOT NULL UNIQUE,
    ano_minimo INT,
    id_prof INT,
    CONSTRAINT chk_disciplina_ano CHECK (ano_minimo BETWEEN 1 AND 7),
    CONSTRAINT fk_disciplina_professor FOREIGN KEY (id_prof)
        REFERENCES professor(id_prof)
);

-- Tabela aluno
CREATE TABLE aluno (
    id_aluno INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    ano_escolar INT,
    id_casa INT,
    saldo_galeoes DECIMAL(10,2) DEFAULT 0,
    CONSTRAINT chk_aluno_ano CHECK (ano_escolar BETWEEN 1 AND 7),
    CONSTRAINT chk_aluno_saldo CHECK (saldo_galeoes >= 0),
    CONSTRAINT fk_aluno_casa FOREIGN KEY (id_casa)
        REFERENCES casa(id_casa)
);

-- Tabela matricula
CREATE TABLE matricula (
    id_aluno INT,
    id_disc INT,
    nota DECIMAL(4,2),
    PRIMARY KEY (id_aluno, id_disc),
    CONSTRAINT chk_matricula_nota CHECK (nota BETWEEN 0 AND 10),
    CONSTRAINT fk_matricula_aluno FOREIGN KEY (id_aluno)
        REFERENCES aluno(id_aluno),
    CONSTRAINT fk_matricula_disciplina FOREIGN KEY (id_disc)
        REFERENCES disciplina(id_disc)
);

-- Tabela registro_pontos
CREATE TABLE registro_pontos (
    id_registro INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT NOT NULL,
    id_prof INT NOT NULL,
    pontos INT NOT NULL,
    motivo VARCHAR(150),
    data_registro DATE NOT NULL,
    CONSTRAINT fk_pontos_aluno FOREIGN KEY (id_aluno)
        REFERENCES aluno(id_aluno),
    CONSTRAINT fk_pontos_professor FOREIGN KEY (id_prof)
        REFERENCES professor(id_prof)
);

-- Tabela produto
CREATE TABLE produto (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome_produto VARCHAR(100) NOT NULL,
    loja VARCHAR(50) NOT NULL,
    preco DECIMAL(10,2),
    estoque INT DEFAULT 0,
    CONSTRAINT chk_produto_preco CHECK (preco > 0),
    CONSTRAINT chk_produto_estoque CHECK (estoque >= 0)
);

-- Tabela compra
CREATE TABLE compra (
    id_compra INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT,
    id_produto INT,
    quantidade INT,
    valor_total DECIMAL(10,2),
    data_compra DATE NOT NULL,
    CONSTRAINT chk_compra_quantidade CHECK (quantidade > 0),
    CONSTRAINT fk_compra_aluno FOREIGN KEY (id_aluno)
        REFERENCES aluno(id_aluno),
    CONSTRAINT fk_compra_produto FOREIGN KEY (id_produto)
        REFERENCES produto(id_produto)
);

-- Tabela log_auditoria
CREATE TABLE log_auditoria (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    tabela VARCHAR(30),
    operacao VARCHAR(10),
    descricao VARCHAR(255),
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================================
-- 2. MANUTENÇÃO PÓS-CARGA (ALTER E UPDATE)
-- =====================================================================
-- Questão 1
ALTER TABLE aluno ADD COLUMN email VARCHAR(100);

-- Questão 2
ALTER TABLE matricula ADD COLUMN situacao VARCHAR(20) DEFAULT 'Cursando';

-- Questão 3
ALTER TABLE produto ADD COLUMN ativo CHAR(1) DEFAULT 'S';

-- Questão 4
ALTER TABLE casa MODIFY COLUMN fundador VARCHAR(100);

-- Questão 5
ALTER TABLE professor RENAME COLUMN data_contratacao TO data_admissao;

-- Questão 6
UPDATE aluno
SET email = LOWER(CONCAT(REPLACE(nome, ' ', '.'), '@hogwarts.edu'));

-- Questão 7
ALTER TABLE aluno
ADD CONSTRAINT uq_aluno_email UNIQUE (email);

-- Questão 8
UPDATE matricula
SET nota = LEAST(nota + 0.5, 10)
WHERE id_disc IN (
    SELECT id_disc
    FROM disciplina
    WHERE id_prof = (SELECT id_prof FROM professor WHERE nome = 'Remo Lupin')
);

-- Questão 9
UPDATE matricula
SET situacao = CASE
    WHEN nota >= 6 THEN 'Aprovado'
    ELSE 'Reprovado'
END;

-- Questão 10
UPDATE professor
SET salario = salario * 1.10
WHERE id_casa IS NOT NULL
  AND data_admissao < '1980-01-01';

-- Questão 11
UPDATE produto
SET ativo = 'N'
WHERE estoque = 0;

-- Questão 12
UPDATE produto
SET preco = preco * 0.80
WHERE loja = 'Dedosdemel';


-- =====================================================================
-- 3. REMOÇÃO DE DADOS (DELETE) E TESTES DE RESTRIÇÕES
-- =====================================================================
-- Questão 13
-- Comando propositalmente inválido: a casa possui alunos e professores vinculados.
-- DELETE FROM casa WHERE nome_casa = 'Sonserina';
-- Erro: 1451 - Cannot delete or update a parent row: a foreign key constraint fails.
-- Explicação: a chave estrangeira impede excluir uma casa que ainda é referenciada
-- por registros nas tabelas aluno e professor.

-- Questão 14
-- Comando propositalmente inválido:
-- INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes, email)
-- VALUES ('Dobby', 8, 1, 0.00, 'dobby@hogwarts.edu');
-- Erro: 3819 - Check constraint 'chk_aluno_ano' is violated.
-- Explicação: o ano escolar deve estar entre 1 e 7; o 8º ano viola o CHECK.

-- Questão 15
-- Comando propositalmente inválido:
-- INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes, email)
-- VALUES ('Harry Potter (Polissuco)', 5, 1, 0.00, 'harry.potter@hogwarts.edu');
-- Erro: 1062 - Duplicate entry 'harry.potter@hogwarts.edu' for key 'uq_aluno_email'.
-- Explicação: o e-mail já pertence ao Harry Potter e a restrição UNIQUE não
-- permite que dois alunos utilizem o mesmo endereço.

-- Questão 16
-- Comando propositalmente inválido:
-- DELETE FROM professor WHERE nome = 'Severo Snape';
-- Erro: 1451 - Cannot delete or update a parent row: a foreign key constraint fails.
-- Explicação: Snape está associado à disciplina Poções, que referencia seu id_prof.

-- Questão 17
DELETE FROM professor WHERE nome = 'Gilderoy Lockhart';
-- Funciona porque Lockhart não está referenciado por nenhuma disciplina ou
-- registro de pontos. Não há linha dependente impedindo a exclusão.

-- Questão 18
DELETE FROM matricula
WHERE id_aluno IN (SELECT id_aluno FROM aluno WHERE nome = 'Vicente Crabbe');

DELETE FROM aluno
WHERE nome = 'Vicente Crabbe';

-- Questão 19
DELETE FROM disciplina
WHERE id_disc NOT IN (SELECT id_disc FROM matricula);



-- =====================================================================
-- 4. TRIGGERS
-- =====================================================================
-- Questão 20 - trg_pontos_casa
DELIMITER $$
CREATE TRIGGER trg_pontos_casa
AFTER INSERT ON registro_pontos
FOR EACH ROW
BEGIN
    UPDATE casa
    SET pontos = pontos + NEW.pontos
    WHERE id_casa = (SELECT id_casa FROM aluno WHERE id_aluno = NEW.id_aluno);
END$$
DELIMITER ;

-- Questão 21 - trg_valida_compra
DELIMITER $$
CREATE TRIGGER trg_valida_compra
BEFORE INSERT ON compra
FOR EACH ROW
BEGIN
    DECLARE v_estoque INT;
    DECLARE v_preco DECIMAL(10,2);
    DECLARE v_saldo DECIMAL(10,2);

    SELECT estoque, preco
      INTO v_estoque, v_preco
    FROM produto
    WHERE id_produto = NEW.id_produto;

    SELECT saldo_galeoes
      INTO v_saldo
    FROM aluno
    WHERE id_aluno = NEW.id_aluno;

    IF v_estoque < NEW.quantidade THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Estoque insuficiente no Beco Diagonal';
    END IF;

    IF v_saldo < (v_preco * NEW.quantidade) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Galeões insuficientes no cofre do aluno';
    END IF;

    SET NEW.valor_total = v_preco * NEW.quantidade;
END$$
DELIMITER ;

-- Questão 22 - trg_baixa_compra
DELIMITER $$
CREATE TRIGGER trg_baixa_compra
AFTER INSERT ON compra
FOR EACH ROW
BEGIN
    UPDATE produto
    SET estoque = estoque - NEW.quantidade
    WHERE id_produto = NEW.id_produto;

    UPDATE aluno
    SET saldo_galeoes = saldo_galeoes - NEW.valor_total
    WHERE id_aluno = NEW.id_aluno;
END$$
DELIMITER ;

-- Questão 23 - trg_situacao_nota
DELIMITER $$
CREATE TRIGGER trg_situacao_nota
BEFORE UPDATE ON matricula
FOR EACH ROW
BEGIN
    IF NEW.nota <> OLD.nota THEN
        SET NEW.situacao = CASE
            WHEN NEW.nota >= 6 THEN 'Aprovado'
            ELSE 'Reprovado'
        END;
    END IF;
END$$
DELIMITER ;

-- Questão 24 - trg_audita_salario
DELIMITER $$
CREATE TRIGGER trg_audita_salario
AFTER UPDATE ON professor
FOR EACH ROW
BEGIN
    IF OLD.salario <> NEW.salario THEN
        INSERT INTO log_auditoria (tabela, operacao, descricao)
        VALUES (
            'professor',
            'UPDATE',
            CONCAT(NEW.nome, ': salário de ',
                   FORMAT(OLD.salario, 2, 'en_US'), ' para ',
                   FORMAT(NEW.salario, 2, 'en_US'))
        );
    END IF;
END$$
DELIMITER ;

-- Pergunta para pensar: por que a validação é BEFORE e a baixa é AFTER?
-- Resposta: a validação precisa ocorrer antes da gravação para impedir uma compra
-- sem estoque ou sem saldo e para preencher valor_total. A baixa ocorre depois
-- que a compra foi inserida com sucesso, pois só então estoque e saldo devem mudar.

-- Questão 25 - INSERT registro_pontos
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro) VALUES
(2, 3, 20, 'Feitiço de levitação perfeito', '2026-09-10'),
(1, 2, -10, 'Atraso na aula de Poções', '2026-09-12'),
(5, 2, 15, 'Poção do Morto-Vivo impecável', '2026-09-12'),
(8, 5, 10, 'Cuidou de um testrálio ferido', '2026-09-20'),
(11, 4, 25, 'Ajudou os alunos do 1º ano', '2026-09-25'),
(4, 4, 30, 'Identificou uma Mimbulus mimbletonia', '2026-10-02'),
(6, 1, -20, 'Fora da cama após o toque de recolher', '2026-10-05'),
(1, 6, 50, 'Conjurou um Patrono corpóreo', '2026-10-15'),
(9, 3, 15, 'Duelo exemplar no Clube de Duelos', '2026-10-18'),
(5, 1, -30, 'Duelo proibido no corredor', '2026-10-31'),
(10, 7, 5, 'Interpretação da bola de cristal', '2026-11-03'),
(13, 4, 10, 'Colheita de mandrágoras', '2026-11-05'),
(3, 9, 10, 'Identificou um bezoar', '2026-11-06'),
(8, 3, 20, 'Resposta brilhante sobre o Diadema', '2026-11-08'),
(6, 2, 25, 'Antídoto para venenos comuns', '2026-11-09'),
(5, 9, 40, 'Melhor poção do Clube do Slugue', '2026-11-09');

-- Questão 25 - INSERT compra
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES
(5, 2, 1, '2026-09-01'),
(2, 5, 2, '2026-09-02'),
(1, 3, 10, '2026-09-03'),
(3, 4, 5, '2026-09-03'),
(9, 8, 1, '2026-09-15'),
(8, 5, 1, '2026-09-20'),
(11, 1, 1, '2026-10-01'),
(6, 3, 20, '2026-10-10'),
(1, 7, 2, '2026-10-20'),
(13, 4, 10, '2026-11-02');

-- Questão 25 - Rony tenta comprar a Nimbus
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
-- VALUES (3, 2, 1, '2026-11-10');
-- Resultado: erro 1644 / SQLSTATE 45000: Galeões insuficientes no cofre do aluno.
-- Rony possui apenas 4.50 galeões após as compras anteriores, menos que os 300.00.

-- Questão 25 - Hermione tenta comprar o caldeirão
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
-- VALUES (2, 6, 1, '2026-11-10');
-- Resultado: erro 1644 / SQLSTATE 45000: Estoque insuficiente no Beco Diagonal.
-- O caldeirão está com estoque zero.

-- Questão 25 - Recuperação do Rony em Poções
UPDATE matricula
SET nota = 6.5
WHERE id_aluno = 3
  AND id_disc = (SELECT id_disc FROM disciplina WHERE nome_disc = 'Poções');

-- A situação passa automaticamente para 'Aprovado' pelo trigger.

-- Questão 25 - Salário e data de admissão do Hagrid
UPDATE professor
SET salario = 5000.00
WHERE nome = 'Rúbeo Hagrid';

UPDATE professor
SET data_admissao = '1993-08-15'
WHERE nome = 'Rúbeo Hagrid';

-- Linhas em log_auditoria:
SELECT COUNT(*) AS linhas_log FROM log_auditoria;
-- Resultado esperado: 1 linha, referente à alteração salarial.
-- Por que o reajuste da questão 10 não aparece:
-- O reajuste de Minerva ocorreu antes da criação do trigger de auditoria;
-- triggers não registram alterações retroativamente.


-- =====================================================================
-- 5. CONTROLE DE TRANSAÇÕES (TCL)
-- =====================================================================
-- Questão 26
START TRANSACTION;
UPDATE aluno SET saldo_galeoes = saldo_galeoes - 50
WHERE nome = 'Draco Malfoy';
UPDATE aluno SET saldo_galeoes = saldo_galeoes + 50
WHERE nome = 'Pansy Parkinson';
COMMIT;

-- Questão 27
START TRANSACTION;
UPDATE casa SET pontos = 0;
SELECT nome_casa, pontos FROM casa;
ROLLBACK;
SELECT nome_casa, pontos FROM casa;

-- Questão 28
START TRANSACTION;
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
VALUES (1, 1, 1, '2026-11-10');
SELECT nome, saldo_galeoes FROM aluno WHERE id_aluno = 1;
SELECT nome_produto, estoque FROM produto WHERE id_produto = 1;
ROLLBACK;
SELECT nome, saldo_galeoes FROM aluno WHERE id_aluno = 1;
SELECT nome_produto, estoque FROM produto WHERE id_produto = 1;
-- Resposta: o ROLLBACK desfaz a compra e também as atualizações de estoque e saldo
-- realizadas pelo trigger, pois as tabelas utilizam mecanismo transacional InnoDB.

-- Questão 29
START TRANSACTION;
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (12, 4, 15, 'Cuidou das estufas no feriado', '2026-11-10');
SAVEPOINT sp_pontos_legitimos;
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (6, 2, 100, 'Favoritismo descarado', '2026-11-10');
ROLLBACK TO SAVEPOINT sp_pontos_legitimos;
COMMIT;

-- Questão 30
SELECT @@autocommit;
-- Resposta: valor 1 significa que o MySQL confirma automaticamente cada instrução
-- executada fora de uma transação explícita. Um CREATE TABLE provoca COMMIT implícito
-- (DDL), encerrando a transação aberta; por isso, não se deve esperar que ROLLBACK
-- desfaça essa criação nem as alterações confirmadas implicitamente.

-- =====================================================================
-- 6. DESAFIOS DE CONSULTA
-- =====================================================================
-- ---------- Nível 1: filtros e operadores especiais ----------

-- 6.1
SELECT p.nome, p.salario
FROM professor p
WHERE p.salario BETWEEN 6000.00 AND 9000.00
ORDER BY p.salario DESC;

-- 6.2
SELECT a.nome, a.ano_escolar
FROM aluno a
WHERE a.ano_escolar IN (1, 4, 6, 7)
ORDER BY a.ano_escolar, a.nome;

-- 6.3
SELECT a.nome
FROM aluno a
WHERE a.nome LIKE '_a%';

-- 6.4
SELECT d.nome_disc
FROM disciplina d
WHERE d.id_prof IS NULL;

-- 6.5
SELECT pr.nome_produto, pr.preco
FROM produto pr
WHERE pr.preco NOT BETWEEN 5 AND 20
ORDER BY pr.preco;

-- 6.6
SELECT DISTINCT pr.loja
FROM produto pr
ORDER BY pr.loja;

-- ---------- Nível 2: JOINs ----------

-- 6.7
SELECT a.nome AS aluno, c.nome_casa AS casa
FROM aluno a
INNER JOIN casa c ON c.id_casa = a.id_casa
ORDER BY c.nome_casa, a.nome;
-- Quantos alunos e por quê: 12 alunos, pois Teddy Lupin ainda não possui casa
-- (id_casa NULL) e o INNER JOIN retorna somente correspondências entre as tabelas.

-- 6.8
SELECT a.nome AS aluno,
       COALESCE(c.nome_casa, 'Aguardando o Chapéu Seletor') AS casa
FROM aluno a
LEFT JOIN casa c ON c.id_casa = a.id_casa
ORDER BY a.nome;

-- 6.9
SELECT p.nome AS professor
FROM disciplina d
RIGHT JOIN professor p ON p.id_prof = d.id_prof
WHERE d.id_disc IS NULL;

-- 6.10
SELECT a.nome AS aluno, d.nome_disc AS disciplina,
       COALESCE(p.nome, 'Sem professor') AS professor,
       m.nota, m.situacao
FROM aluno a
JOIN casa c ON c.id_casa = a.id_casa
JOIN matricula m ON m.id_aluno = a.id_aluno
JOIN disciplina d ON d.id_disc = m.id_disc
LEFT JOIN professor p ON p.id_prof = d.id_prof
WHERE c.nome_casa = 'Grifinória'
ORDER BY a.nome, d.nome_disc;

-- 6.11
SELECT co.id_compra, a.nome AS aluno, pr.nome_produto AS produto,
       pr.loja, co.quantidade, co.valor_total, co.data_compra
FROM compra co
JOIN aluno a ON a.id_aluno = co.id_aluno
JOIN produto pr ON pr.id_produto = co.id_produto
ORDER BY co.data_compra, co.id_compra;

-- ---------- Nível 3: agrupamento e agregação ----------

-- 6.12
SELECT d.nome_disc AS disciplina,
       COUNT(m.id_aluno) AS quantidade_alunos,
       ROUND(AVG(m.nota), 2) AS media,
       MAX(m.nota) AS maior_nota,
       MIN(m.nota) AS menor_nota
FROM disciplina d
JOIN matricula m ON m.id_disc = d.id_disc
GROUP BY d.id_disc, d.nome_disc
HAVING AVG(m.nota) >= 7
ORDER BY media DESC;

-- 6.13
SELECT c.nome_casa,
       COUNT(r.id_registro) AS quantidade_registros,
       SUM(CASE WHEN r.pontos > 0 THEN r.pontos ELSE 0 END) AS pontos_ganhos,
       SUM(CASE WHEN r.pontos < 0 THEN r.pontos ELSE 0 END) AS pontos_perdidos,
       COALESCE(SUM(r.pontos), 0) AS saldo_pontos
FROM casa c
LEFT JOIN aluno a ON a.id_casa = c.id_casa
LEFT JOIN registro_pontos r ON r.id_aluno = a.id_aluno
GROUP BY c.id_casa, c.nome_casa
ORDER BY c.nome_casa;

-- 6.14
SELECT pr.loja, COUNT(co.id_compra) AS quantidade_compras,
       SUM(co.valor_total) AS faturamento
FROM compra co
JOIN produto pr ON pr.id_produto = co.id_produto
GROUP BY pr.loja
HAVING SUM(co.valor_total) > 20
ORDER BY faturamento DESC;

-- 6.15
SELECT MONTH(r.data_registro) AS mes,
       COUNT(*) AS quantidade_registros,
       SUM(r.pontos) AS total_pontos
FROM registro_pontos r
GROUP BY MONTH(r.data_registro)
ORDER BY mes;

-- 6.16
SELECT p.nome AS professor,
       COUNT(r.id_registro) AS quantidade_registros,
       SUM(r.pontos) AS total_concedido
FROM professor p
JOIN registro_pontos r ON r.id_prof = p.id_prof
GROUP BY p.id_prof, p.nome
HAVING COUNT(r.id_registro) >= 2
ORDER BY total_concedido DESC;

-- ---------- Nível 4: subconsultas ----------

-- 6.17
SELECT a.nome
FROM aluno a
WHERE a.id_aluno IN (
    SELECT co.id_aluno
    FROM compra co
    WHERE co.id_produto IN (
        SELECT pr.id_produto
        FROM produto pr
        WHERE pr.loja = 'Dedosdemel'
    )
);

-- 6.18
SELECT pr.nome_produto, pr.estoque
FROM produto pr
WHERE pr.id_produto NOT IN (
    SELECT co.id_produto FROM compra co
);

-- 6.19
SELECT a.nome, a.saldo_galeoes
FROM aluno a
WHERE a.saldo_galeoes > (
    SELECT AVG(a2.saldo_galeoes) FROM aluno a2
);

-- 6.20
SELECT p.nome, p.salario
FROM professor p
WHERE p.salario > ALL (
    SELECT p2.salario
    FROM professor p2
    WHERE p2.id_casa IS NULL
);

-- 6.21
SELECT a.nome, a.saldo_galeoes
FROM aluno a
WHERE (a.id_casa IS NULL OR a.id_casa <> 2)
  AND a.saldo_galeoes > ANY (
      SELECT a2.saldo_galeoes
      FROM aluno a2
      WHERE a2.id_casa = 2
  );
-- > ANY equivale a: ser maior que pelo menos um valor da subconsulta,
-- ou seja, maior que o menor valor retornado (não precisa superar o maior).

-- 6.22
SELECT c.nome_casa
FROM casa c
WHERE EXISTS (
    SELECT 1
    FROM aluno a
    JOIN matricula m ON m.id_aluno = a.id_aluno
    WHERE a.id_casa = c.id_casa
      AND m.nota = 10
);

-- 6.23
SELECT a.nome
FROM aluno a
WHERE NOT EXISTS (
    SELECT 1
    FROM compra co
    WHERE co.id_aluno = a.id_aluno
);

-- 6.24
SELECT c.nome_casa,
       ROUND(AVG(da.media_aluno), 2) AS media_da_casa
FROM casa c
JOIN aluno a ON a.id_casa = c.id_casa
JOIN (
    SELECT m.id_aluno, AVG(m.nota) AS media_aluno
    FROM matricula m
    GROUP BY m.id_aluno
) da ON da.id_aluno = a.id_aluno
GROUP BY c.id_casa, c.nome_casa
ORDER BY media_da_casa DESC;

-- ---------- Nível 5: UNION ALL ----------

-- 6.25
SELECT nome, vinculo
FROM (
    SELECT a.nome, 'Aluno' AS vinculo FROM aluno a
    UNION ALL
    SELECT p.nome, 'Professor' AS vinculo FROM professor p
) AS diretorio
ORDER BY nome;

-- 6.26
-- UNION ALL
SELECT a.nome AS aluno
FROM aluno a
WHERE a.id_aluno IN (SELECT co.id_aluno FROM compra co)
UNION ALL
SELECT a.nome
FROM aluno a
WHERE a.id_aluno IN (SELECT r.id_aluno FROM registro_pontos r);

-- UNION
SELECT a.nome AS aluno
FROM aluno a
WHERE a.id_aluno IN (SELECT co.id_aluno FROM compra co)
UNION
SELECT a.nome
FROM aluno a
WHERE a.id_aluno IN (SELECT r.id_aluno FROM registro_pontos r);

-- Linhas com UNION ALL: 27, conforme conferência do enunciado.
-- Linhas com UNION: 12, conforme conferência do enunciado.
-- Explicação: UNION ALL mantém todas as ocorrências, inclusive repetidas;
-- UNION elimina duplicidades do conjunto de resultados.

-- 6.27
SELECT 'Total de pontos distribuídos' AS indicador,
       CAST(COALESCE(SUM(r.pontos), 0) AS CHAR) AS valor
FROM registro_pontos r
UNION ALL
SELECT 'Total de galeões gastos na loja',
       CAST(COALESCE(SUM(co.valor_total), 0) AS CHAR)
FROM compra co
UNION ALL
SELECT 'Folha salarial dos professores',
       CAST(COALESCE(SUM(p.salario), 0) AS CHAR)
FROM professor p
UNION ALL
SELECT 'Total de galeões nos cofres dos alunos',
       CAST(COALESCE(SUM(a.saldo_galeoes), 0) AS CHAR)
FROM aluno a;


-- =====================================================================
-- 7. VIEWS
-- =====================================================================
-- Questão 31
CREATE VIEW vw_placar_casas AS
SELECT c.nome_casa, c.pontos
FROM casa c;

-- Questão 32
CREATE VIEW vw_boletim AS
SELECT a.nome AS aluno,
       COALESCE(c.nome_casa, 'Sem casa') AS casa,
       d.nome_disc AS disciplina,
       COALESCE(p.nome, 'Sem professor') AS professor,
       m.nota, m.situacao
FROM matricula m
JOIN aluno a ON a.id_aluno = m.id_aluno
LEFT JOIN casa c ON c.id_casa = a.id_casa
JOIN disciplina d ON d.id_disc = m.id_disc
LEFT JOIN professor p ON p.id_prof = d.id_prof;

-- Questão 33
CREATE VIEW vw_extrato_loja AS
SELECT a.nome AS aluno, pr.nome_produto AS produto, pr.loja,
       co.quantidade, co.valor_total, co.data_compra
FROM compra co
JOIN aluno a ON a.id_aluno = co.id_aluno
JOIN produto pr ON pr.id_produto = co.id_produto;

-- Questão 34
CREATE VIEW vw_alunos_destaque AS
SELECT a.nome AS aluno, c.nome_casa AS casa,
       ROUND(AVG(m.nota), 2) AS media
FROM aluno a
JOIN casa c ON c.id_casa = a.id_casa
JOIN matricula m ON m.id_aluno = a.id_aluno
GROUP BY a.id_aluno, a.nome, c.nome_casa
HAVING AVG(m.nota) >= 8;

-- Questão 35
CREATE VIEW vw_quadro_professores AS
SELECT p.nome AS professor,
       COALESCE(c.nome_casa, 'Não é diretor') AS casa_que_dirige,
       (SELECT COUNT(*) FROM disciplina d
        WHERE d.id_prof = p.id_prof) AS quantidade_disciplinas,
       COALESCE((SELECT SUM(r.pontos) FROM registro_pontos r
                 WHERE r.id_prof = p.id_prof), 0) AS total_pontos
FROM professor p
LEFT JOIN casa c ON c.id_casa = p.id_casa;

-- Questão 36
-- Consulte o placar
SELECT * FROM vw_placar_casas ORDER BY pontos DESC;

-- Boletim apenas dos alunos da Corvinal
SELECT * FROM vw_boletim WHERE casa = 'Corvinal';

-- Total faturado por loja
SELECT loja, SUM(valor_total) AS total_faturado
FROM vw_extrato_loja
GROUP BY loja
ORDER BY total_faturado DESC;

-- Alunos destaque da maior para a menor média
SELECT * FROM vw_alunos_destaque ORDER BY media DESC;

-- Quadro de professores do maior para o menor total de pontos
SELECT * FROM vw_quadro_professores ORDER BY total_pontos DESC;

-- Questão 37
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (11, 1, 20, 'Venceu a primeira tarefa do Torneio', '2026-11-10');

-- O que mudou e por quê: a pontuação da Lufa-Lufa aumenta em 20 pontos,
-- passando de 50 para 70. A view consulta as tabelas atuais; por isso reflete
-- automaticamente as alterações feitas, sem precisar ser recriada.
SELECT * FROM vw_placar_casas ORDER BY pontos DESC;

-- Questão 38
CREATE OR REPLACE VIEW vw_placar_casas AS
SELECT c.nome_casa, c.fundador, c.pontos
FROM casa c;


-- =====================================================================
-- 8. CONTROLE DE ACESSO (DCL)
-- =====================================================================
-- Questão 39

-- Questão 40

-- Questão 41

-- Questão 42

-- Questão 43

-- Questão 44
-- Resultado de cada comando:

-- Questão 45
-- Como o trigger conseguiu atualizar a casa:

-- Questão 46

-- Questão 47
-- Vantagem dos papéis:

-- Questão 48

